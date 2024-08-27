# Get versions easier from https://lazamar.co.uk/nix-versions/ 

# Get latest versions of packages
let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-23.11";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in

# Use specific Terraform version 
let
    pkgs = import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/976fa3369d722e76f37c77493d99829540d43845.tar.gz";
    }) {};

    terraform_1_5_5 = pkgs.terraform;
in

# Use specific Terragrunt version
let
    pkgs = import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/9957cd48326fe8dbd52fdc50dd2502307f188b0d.tar.gz";
    }) {};

    terragrunt_0_51_7 = pkgs.terragrunt;
in

# Use specific Azure CLI version
let
    pkgs = import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/9957cd48326fe8dbd52fdc50dd2502307f188b0d.tar.gz";
    }) {};

    azure-cli_2_53_0 = pkgs.azure-cli;
in

# Use specific Go version
let
    pkgs = import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/9957cd48326fe8dbd52fdc50dd2502307f188b0d.tar.gz";
    }) {};

    go_1_21 = pkgs.go_1_21;
in

# Use specific JQ version
let
    pkgs = import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/9957cd48326fe8dbd52fdc50dd2502307f188b0d.tar.gz";
    }) {};

    jq_1_7 = pkgs.jq;
in


pkgs.mkShell {
  packages = with pkgs; [
    git
    tflint
    terraform_1_5_5
    terragrunt_0_51_7
    azure-cli_2_53_0
    go_1_21
    jq_1_7
  ];
  
  # Shellhook to export environment variables
  shellHook = ''
    if [ -f $(git rev-parse --show-toplevel)/env.list ]; then 
        echo "[INFO] Sourced $(git rev-parse --show-toplevel)/env.list" 
        source $(git rev-parse --show-toplevel)/env.list
    fi
    export AZURE_CONFIG_DIR="$(git rev-parse --show-toplevel)/.azure"
    export AZURE_EXTENSION_DIR="$(git rev-parse --show-toplevel)/.azure/cliextensions"
    export AZURE_EXTENSION_USE_DYNAMIC_INSTALL="yes_without_prompt"
  '';
}