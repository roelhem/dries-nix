#!/usr/bin/env python3
"""Regenerate the modules.json lock file of a PowerShell Gallery package.

Resolves the full dependency closure of a module on the PowerShell Gallery and
writes every resolved package (name, version, sha512 hash and its direct
dependencies) to `<module slug>/modules.json`.

The gallery exposes the SHA512 of every .nupkg through its OData feed, so no
package has to be downloaded to compute the hashes.
"""

from __future__ import annotations

import argparse
import base64
import binascii
import json
import re
import sys
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

GALLERY = "https://www.powershellgallery.com/api/v2"


def fetch(url: str) -> str:
    request = urllib.request.Request(url, headers={"User-Agent": "dries-nix-psgallery-updater"})
    with urllib.request.urlopen(request, timeout=60) as response:
        return response.read().decode("utf-8")


def prop(xml: str, name: str) -> str | None:
    match = re.search(rf"<d:{name}[^>]*>(.*?)</d:{name}>", xml, re.S)
    if match is None or match.group(1) == "":
        return None
    return match.group(1)


def parse_version(version: str) -> tuple[int, ...]:
    return tuple(int(part) for part in re.findall(r"\d+", version))


def latest_version(name: str) -> str:
    query = urllib.parse.quote(f"Id eq '{name}' and IsLatestVersion", safe="")
    xml = fetch(f"{GALLERY}/Packages()?$filter={query}&$select=Version")
    version = prop(xml, "Version")
    if version is None:
        raise SystemExit(f"no stable version found for {name}")
    return version


def package_metadata(name: str, version: str) -> tuple[str, str]:
    """Return the SRI hash and the raw dependency string of a package."""
    xml = fetch(f"{GALLERY}/Packages(Id='{name}',Version='{version}')")

    algorithm = prop(xml, "PackageHashAlgorithm")
    if algorithm != "SHA512":
        raise SystemExit(f"{name} {version}: unexpected hash algorithm {algorithm}")

    package_hash = prop(xml, "PackageHash")
    if package_hash is None:
        raise SystemExit(f"{name} {version}: no package hash in the feed")

    # Sanity check: the feed value must be base64 of a 64 byte digest.
    try:
        digest = base64.b64decode(package_hash, validate=True)
    except binascii.Error as error:
        raise SystemExit(f"{name} {version}: malformed package hash: {error}")
    if len(digest) != 64:
        raise SystemExit(f"{name} {version}: package hash is not a SHA512 digest")

    return f"sha512-{package_hash}", prop(xml, "Dependencies") or ""


def resolve_range(name: str, version_range: str) -> str:
    """Pick a concrete version for a NuGet version range.

    Exact ranges (`[1.2.3, 1.2.3]`) are used as-is, open ranges resolve to the
    latest stable version that satisfies the lower bound.
    """
    version_range = version_range.strip()

    bracketed = re.fullmatch(r"[\[(]\s*([^,\]) ]*)\s*,\s*([^,\]) ]*)\s*[\])]", version_range)
    if bracketed is None:
        # A bare version is a minimum bound.
        minimum, maximum = version_range, ""
    else:
        minimum, maximum = bracketed.group(1), bracketed.group(2)

    if minimum and minimum == maximum:
        return minimum

    candidate = latest_version(name)
    if minimum and parse_version(candidate) < parse_version(minimum):
        return minimum
    if maximum and parse_version(candidate) > parse_version(maximum):
        return maximum
    return candidate


def parse_dependencies(dependencies: str) -> dict[str, str]:
    """Turn `A:[1.0.0, 1.0.0]:|B:[2.0.0, ):` into `{name: resolved version}`."""
    resolved: dict[str, str] = {}
    for entry in filter(None, (entry.strip() for entry in dependencies.split("|"))):
        name, _, rest = entry.partition(":")
        version_range, _, _framework = rest.partition(":")
        resolved[name] = resolve_range(name, version_range)
    return resolved


def build_closure(root: str, root_version: str) -> dict[str, dict]:
    modules: dict[str, dict] = {}
    pending = [(root, root_version)]

    while pending:
        with ThreadPoolExecutor(max_workers=8) as pool:
            batch = pool.map(lambda item: (item, package_metadata(*item)), pending)
            batch = list(batch)
        pending = []

        for (name, version), (module_hash, dependencies) in batch:
            if name in modules:
                continue
            resolved = parse_dependencies(dependencies)
            modules[name] = {
                "version": version,
                "hash": module_hash,
                "dependencies": dict(sorted(resolved.items())),
            }
            print(f"  {name} {version}", file=sys.stderr)
            pending += [item for item in resolved.items() if item[0] not in modules]

        # Drop duplicates that different modules pulled in at the same time.
        pending = list(dict.fromkeys(pending))

    conflicts = {}
    for module in modules.values():
        for name, version in module["dependencies"].items():
            if modules[name]["version"] != version:
                conflicts[name] = (modules[name]["version"], version)
    for name, (used, wanted) in conflicts.items():
        print(f"WARNING: {name} pinned at {used}, but {wanted} was also requested", file=sys.stderr)

    return dict(sorted(modules.items()))


def slug(name: str) -> str:
    return name.lower().replace(".", "-")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("module", help="name of the root module on the gallery, e.g. Az")
    parser.add_argument(
        "--version",
        default="latest",
        help="version of the root module to pin (default: latest stable)",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=None,
        help="where to write the lock file (default: ./<module slug>/modules.json)",
    )
    args = parser.parse_args()

    output = args.output or Path(__file__).parent / slug(args.module) / "modules.json"
    version = latest_version(args.module) if args.version == "latest" else args.version
    print(f"Resolving {args.module} {version} from the PowerShell Gallery...", file=sys.stderr)

    modules = build_closure(args.module, version)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(modules, indent=2) + "\n")
    print(f"Wrote {len(modules)} modules to {output}", file=sys.stderr)


if __name__ == "__main__":
    main()
