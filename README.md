# DRIES-NIX

Nix-configuratie voor de Yielder MacBook van Dries. Gebouwd met
[nix-darwin](https://github.com/nix-darwin/nix-darwin) (macOS-instellingen),
[home-manager](https://github.com/nix-community/home-manager) (gebruikersinstellingen) en
[flake-parts](https://flake.parts) (structuur van `flake.nix`).

## WAT ZIT ERIN

- **Homebrew** (`modules/darwin/homebrew.nix`): Homebrew zelf en de apps die je opgeeft.
- **Yielder-apps** (`modules/darwin/yielder-apps.nix`): Office, Teams, OneDrive, Azure VPN Client, Docker, browsers.
- **.NET** (`modules/home/dotnet.nix`): SDK 8 t/m 11, `dotnet ef`, `func` en NuGet-toegang tot de venecodev-feed.
- **Azure** (`modules/home/azure.nix`): `az` met extensies en `azcopy`.
- **Git** (`modules/home/git.nix`): inloggen bij yielder.ghe.com, github.com en Azure DevOps.
- **direnv** (`modules/home/direnv.nix`): laadt de omgeving van een project automatisch.
- **PowerShell** (`modules/home/powershell.nix`): `pwsh` met Az, Microsoft.Graph, ImportExcel en SimplySql via nix.

## EERSTE INSTALLATIE

1. Log in bij de **App Store** (nodig voor de App Store-apps).
2. Installeer **Nix**:
   ```sh
   curl -L https://nixos.org/nix/install | sh
   ```
   Open daarna een nieuwe terminal.
3. Clone deze repository naar `~/dries-nix` (of pas `configDirectory` aan in `settings.nix`).
4. Vul **`settings.nix`** in. Dit is het enige bestand dat je hoeft aan te passen.
5. Activeer de configuratie voor de eerste keer:
   ```sh
   cd ~/dries-nix
   sudo nix --extra-experimental-features 'nix-command flakes' \
     run nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake .#<hostname>
   ```
   `<hostname>` is de waarde van `hostname` in `settings.nix`.
6. Open een nieuwe terminal en log in:
   ```sh
   gh auth login --hostname yielder.ghe.com
   gh auth login --hostname github.com
   az login
   ```
   Azure DevOps opent een browser zodra je voor het eerst een repository clonet.
   Voor de venecodev NuGet-feed draai je de eerste keer `dotnet restore --interactive`.

## DAGELIJKS GEBRUIK

| Commando        | Wat het doet                                                 |
|-----------------|--------------------------------------------------------------|
| `just switch`   | Past de configuratie toe na een wijziging.                   |
| `just build`    | Bouwt de configuratie zonder hem toe te passen (check).      |
| `just update`   | Werkt alle versies bij (nixpkgs, Homebrew, ...).             |
| `just clean`    | Ruimt oude versies op in de nix store.                       |
| `just update-powershell-module <Naam>` | Pint een PowerShell Gallery-module opnieuw. |

Nieuwe bestanden moet je eerst `git add`-en: een flake ziet alleen bestanden die git kent.

## LET OP

- `homebrew.onActivation.cleanup = "zap"`: apps die je met de hand via `brew install`
  installeert, verdwijnen bij de volgende `just switch`. Zet ze in de configuratie.
- home-manager beheert `~/.zshrc`. Een bestaande versie krijgt de extensie `.backup`.
