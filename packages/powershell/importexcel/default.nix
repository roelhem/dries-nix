{
  lib,
  callPackage,
  modules ? [ "ImportExcel" ],
}:

# The ImportExcel PowerShell module, built straight from the PowerShell Gallery.
#
# Note: the `-AutoSize` switch does not work on macOS or Linux. The EPPlus
# version bundled with ImportExcel measures text through System.Drawing.Common,
# and that assembly throws PlatformNotSupportedException on everything but
# Windows since .NET 7 (pwsh 7.6 ships version 10). Adding pkgs.libgdiplus does
# not help: the native library then loads fine, but the managed side still
# refuses. The module notices this at import time, warns (its advice to install
# libgdiplus is outdated), sets $env:NoAutoSize and skips autosizing; the rest
# of the module works normally.
#
# ./modules.json is regenerated with
# `just update-powershell-module ImportExcel`.

callPackage ../build-gallery-bundle.nix { } {
  pname = "powershell-importexcel";
  lockFile = ./modules.json;
  root = "ImportExcel";
  inherit modules;

  meta = {
    description = "PowerShell module to read and write Excel files without Excel";
    longDescription = ''
      ImportExcel, installed under `share/powershell/Modules` so that it is
      picked up through `PSModulePath`.
    '';
    homepage = "https://github.com/dfinke/ImportExcel";
    license = lib.licenses.asl20;
  };
}
