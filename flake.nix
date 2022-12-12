{
  description = "This is Sherlock's sister, Modern shiny CLI tool written with Golang to help you: mag_right Hunt down social media accounts by username across social networks";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "github:Nixos/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let

      version = "0.1";

      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in
    {

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          enola = pkgs.buildGoModule {
            pname = "enola";
            inherit version;
            # In 'nix develop', we don't need a copy of the source tree
            # in the Nix store.
            src = ./.;

            # This hash locks the dependencies of this package. It is
            # necessary because of how Go requires network access to resolve
            # VCS.  See https://www.tweag.io/blog/2021-03-04-gomod2nix/ for
            # details. Normally one can build with a fake sha256 and rely on native Go
            # mechanisms to tell you what the hash should be or determine what
            # it should be "out-of-band" with other tooling (eg. gomod2nix).
            # To begin with it is recommended to set this, but one must
            # remeber to bump this hash when your dependencies change.
            # vendorSha256 = pkgs.lib.fakeSha256;

            vendorSha256 = "sha256-koq3rtQhDudOpkjZRqk1PL9a1q+wIdJeoa0hx8esz/U=";
          };
        });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.enola}/bin/enola";
        };
      });

      formatter = forAllSystems (system: nixpkgsFor.${system}.nixpkgs-fmt);

      devShells = forAllSystems (system: {
        default = nixpkgsFor.${system}.mkShell {
          packages = [
            nixpkgsFor.${system}.go
            # jq is useful to debug the database
            self.packages.${system}.enola
          ];
        };
      });


      defaultPackage = forAllSystems (system: self.packages.${system}.enola);
    };
}
