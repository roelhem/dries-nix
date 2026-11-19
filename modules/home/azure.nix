# The Azure command line tools. Log in with `az login`.
{ pkgs, ... }:

let

  # The Azure CLI (`az`) with extra extensions built in. Normally `az`
  # installs extensions on the fly, but that doesn't work when it is installed
  # with nix. Add the ones you need here; the names are listed on
  # https://search.nixos.org/packages?query=azure-cli.extensions
  az = pkgs.azure-cli.withExtensions (
    with pkgs.azure-cli.extensions;
    [
      ad # Microsoft Entra ID (Azure AD).
      alb # Application Gateway for Containers.
      alertsmanagement
      amg # Azure Managed Grafana.
      application-insights
      automation
      azure-devops # `az devops`, `az repos`, `az pipelines`, `az boards`.
      azure-firewall
      dns-resolver
      eventgrid
      kusto # Azure Data Explorer.
      log-analytics
      log-analytics-solution
      network-analytics
      nsp # Network Security Perimeter.
      resource-graph # `az graph query`: search across all resources.
      ssh # `az ssh`: log in to VMs with your Entra ID account.
      subscription
      terraform
      virtual-wan
      webapp
    ]
  );

in

{
  home.packages = [
    az
    pkgs.azure-storage-azcopy # `azcopy`: fast copies to/from Azure Storage.
  ];

  # Only show errors from `az`, not the warnings about previews and
  # deprecations it prints on almost every command.
  home.sessionVariables.AZURE_CORE_ONLY_SHOW_ERRORS = "true";
}
