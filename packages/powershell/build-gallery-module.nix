{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  unzip,
  autoPatchelfHook,
}:

# Builds a PowerShell module from a .nupkg on the PowerShell Gallery.
#
# The result follows the layout PowerShell expects on its `PSModulePath`:
#   $out/share/powershell/Modules/<pname>/<version>/<module files>
# The version directory keeps modules side-by-side installable, so joining
# several of them into one profile never conflicts.

{
  pname,
  version,
  # SRI hash of the .nupkg. The gallery publishes it as `PackageHash`
  # (base64 SHA512), so it can be taken from the feed without downloading.
  hash,
  # Some modules ship prebuilt native libraries that need their RPATH fixed
  # before they can be dlopen()ed on NixOS. Set this and list what they link
  # against in `buildInputs`.
  autoPatchelf ? false,
  nativeBuildInputs ? [ ],
  meta ? { },
  ...
}@args:

let

  usePatchelf = autoPatchelf && stdenv.hostPlatform.isLinux;

in

stdenvNoCC.mkDerivation (
  (removeAttrs args [
    "hash"
    "autoPatchelf"
  ])
  // {
    inherit pname version;

    src = fetchurl {
      name = "${pname}.${version}.nupkg";
      url = "https://www.powershellgallery.com/api/v2/package/${pname}/${version}";
      inherit hash;
    };

    nativeBuildInputs = [ unzip ] ++ lib.optional usePatchelf autoPatchelfHook ++ nativeBuildInputs;

    unpackPhase = ''
      runHook preUnpack
      mkdir -p module
      unzip -q "$src" -d module
      runHook postUnpack
    '';

    dontBuild = true;
    dontStrip = true; # The payload is .NET assemblies, not ELF binaries.

    installPhase = ''
      runHook preInstall

      # Drop the NuGet packaging metadata; it is not part of the module.
      rm -rf module/_rels module/package "module/[Content_Types].xml" module/*.nuspec

      mkdir -p "$out/share/powershell/Modules/${pname}"
      cp -r module "$out/share/powershell/Modules/${pname}/${version}"

      runHook postInstall
    '';

    meta = {
      homepage = "https://www.powershellgallery.com/packages/${pname}/${version}";
      platforms = lib.platforms.all;
    }
    // meta;
  }
)
