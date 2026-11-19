{
  lib,
  callPackage,
  zlib,
  modules ? [ "SimplySql" ],
}:

# The SimplySql PowerShell module, built straight from the PowerShell Gallery.
#
# Note: the SQLite engine does not work on aarch64-darwin. SimplySql ships a
# native SQLite.Interop.dll per platform, but upstream builds none for
# osx-arm64 (neither does the System.Data.SQLite nuget package it comes from),
# so Open-SQLiteConnection fails with a DllNotFoundException there. The SQL
# Server, PostgreSQL and MySQL engines are fully managed and work fine.
#
# On Linux that same interop library is shipped, but it is a foreign binary
# that needs libz.so.1; without an RPATH the runtime cannot dlopen() it on
# NixOS, so it is patched below.
#
# ./modules.json is regenerated with
# `just update-powershell-module SimplySql`.

callPackage ../build-gallery-bundle.nix { } {
  pname = "powershell-simplysql";
  lockFile = ./modules.json;
  root = "SimplySql";
  inherit modules;

  moduleArgs.SimplySql = {
    autoPatchelf = true;
    buildInputs = [ zlib ];
  };

  meta = {
    description = "PowerShell cmdlets for querying SQL Server, PostgreSQL, MySQL, SQLite and ODBC";
    longDescription = ''
      SimplySql, installed under `share/powershell/Modules` so that it is
      picked up through `PSModulePath`.
    '';
    homepage = "https://github.com/mithrandyr/SimplySql";
    license = lib.licenses.asl20;
  };
}
