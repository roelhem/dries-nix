# PowerShell (`pwsh`), with modules installed through nix.
#
# PowerShell looks for modules in the folders listed in the `PSModulePath`
# environment variable. The packages in ../../packages/powershell put their
# modules in `share/powershell/Modules`, so adding that folder of your nix
# profile to `PSModulePath` makes every installed module available.
#
# To add a module from the PowerShell Gallery:
#   1. Pin it:  `just update-powershell-module <Name>` (creates
#      packages/powershell/<name>/modules.json).
#   2. Copy one of the folders in packages/powershell (e.g. `importexcel`)
#      and point it at the new modules.json.
#   3. Add it to packages/overlay.nix and to `home.packages` below.
#
# `Install-Module` keeps working too, for quick experiments.
{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.powershell

    # The Az (Azure) cmdlets. The full bundle is big; to install only some
    # of its modules, use for example:
    #   (pkgs.powershell-az.override { modules = [ "Az.Accounts" "Az.Storage" ]; })
    pkgs.powershell-az

    # The Microsoft Graph cmdlets (users, groups, Intune, ...). Can be
    # trimmed the same way as Az.
    pkgs.powershell-microsoft-graph

    # Read and write Excel files without Excel.
    pkgs.powershell-importexcel

    # Query SQL Server, PostgreSQL and MySQL from PowerShell.
    pkgs.powershell-simplysql
  ];

  # Add the modules folder of your nix profile to PSModulePath. PowerShell
  # adds its own default folders to this when it starts.
  home.sessionSearchVariables.PSModulePath = [
    "${config.home.profileDirectory}/share/powershell/Modules"
  ];
}
