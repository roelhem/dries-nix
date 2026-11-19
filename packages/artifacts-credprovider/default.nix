{
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
}:

buildDotnetModule rec {
  name = "artifacts-credprovider";
  version = "2.0.4";
  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "artifacts-credprovider";
    rev = "v${version}";
    sha256 = "sha256-NAQi/36/1vd8flBtcg/Vd0i9bg2r+qMju3fMC+5mgXs=";
  };
  nugetDeps = ./deps.json;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  executables = [ ];

  # Only build/publish the actual credential provider executable. Building the
  # whole solution (the default) also tries to publish the multi-targeted
  # (net481;net6.0;net8.0) test projects without picking a single framework,
  # which fails with NETSDK1129. Restricting to this project file also makes
  # dotnet pass `--runtime`, which triggers Build.props to pin TargetFrameworks
  # to net8.0 for our runtime identifier.
  projectFile = "CredentialProvider.Microsoft/CredentialProvider.Microsoft.csproj";
  # `dotnet publish` still refuses to auto-select the single remaining
  # framework for a cross-targeting project, even though `dotnet build` does.
  dotnetInstallFlags = [ "-p:TargetFramework=net8.0" ];
}
