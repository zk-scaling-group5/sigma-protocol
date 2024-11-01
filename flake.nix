{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    my-utils = {
      url = "github:nmrshll/nix-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };
  };

  outputs = { self, nixpkgs, utils, rust-overlay, my-utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };
        customRust = pkgs.rust-bin.stable."1.80.0".default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
          targets = [ "wasm32-unknown-unknown" ];
        };
        # binaries = my-utils.binaries.${system} // { };

        baseInputs = with pkgs; [
          customRust
          python3
        ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
          pkgs.darwin.apple_sdk.frameworks.Security
          pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
          pkgs.darwin.apple_sdk.frameworks.CoreServices
          pkgs.darwin.apple_sdk.frameworks.CoreFoundation
          pkgs.darwin.apple_sdk.frameworks.Foundation
          pkgs.libiconv
        ];

        devInputs = with pkgs; [
          nixpkgs-fmt
          cargo-nextest
        ];

        env = {
          RUST_BACKTRACE = "1";
        };

        scripts = with pkgs; [
          (writeScriptBin "utest" ''cargo nextest run --workspace --nocapture -- $SINGLE_TEST '')
        ];

      in
      {
        devShells.default = with pkgs; mkShell {
          inherit env;
          buildInputs = baseInputs ++ devInputs ++ scripts;
          shellHook = "
              ${my-utils.binaries.${system}.configure-vscode};
              dotenv
            ";
        };
      }
    );
}




