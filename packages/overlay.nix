# An overlay adds (or changes) packages in `pkgs`. This one adds the packages
# that are not in nixpkgs (yet), so you can use them like any other package:
#
#   home.packages = [ pkgs.powershell-az ];
#
# `final` is the finished package set (including these additions), `prev` is
# the package set before this overlay was applied.
final: prev: {
  # Lets `dotnet restore` log in to Azure DevOps NuGet feeds (see
  # ../modules/home/dotnet.nix).
  artifacts-credprovider = final.callPackage ./artifacts-credprovider { };

  # PowerShell modules from the PowerShell Gallery (see
  # ../modules/home/powershell.nix).
  powershell-az = final.callPackage ./powershell/az { };
  powershell-microsoft-graph = final.callPackage ./powershell/microsoft-graph { };
  powershell-importexcel = final.callPackage ./powershell/importexcel { };
  powershell-simplysql = final.callPackage ./powershell/simplysql { };
}
