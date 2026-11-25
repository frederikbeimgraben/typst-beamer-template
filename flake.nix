{
  description = "bgslides - Typst presentation template in the style of beimgraben.net";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: nixpkgs.legacyPackages.${system};

      fonts = "src/assets/fonts";
      packageDir = "$HOME/.local/share/typst/packages/local/bgslides/1.0.0";
    in
    {
      packages = forAllSystems (system:
        let pkgs = pkgsFor system; in
        rec {
          default = example;

          # The example document, compiled to $out/slides.pdf.
          example = pkgs.stdenvNoCC.mkDerivation {
            pname = "bgslides-example";
            version = "1.0.0";
            src = self;
            nativeBuildInputs = [ pkgs.typst ];
            # The example imports @local/bgslides, so the checkout serves as
            # that package.
            buildPhase = ''
              mkdir -p packages/local/bgslides
              ln -s "$PWD" packages/local/bgslides/1.0.0
              typst compile --package-path packages --font-path ${fonts} example/main.typ slides.pdf
            '';
            installPhase = ''
              install -Dm644 slides.pdf $out/slides.pdf
            '';
          };
        });

      apps = forAllSystems (system:
        let
          pkgs = pkgsFor system;

          app = name: text: {
            type = "app";
            program = "${pkgs.writeShellApplication {
              inherit name text;
              runtimeInputs = [ pkgs.typst ];
            }}/bin/${name}";
          };
        in
        rec {
          default = build;

          # Compile the example document.
          build = app "build" ''
            mkdir -p build/packages/local/bgslides
            ln -sfn "$PWD" build/packages/local/bgslides/1.0.0
            typst compile --package-path build/packages --font-path ${fonts} example/main.typ build/slides.pdf
          '';

          # Compile the example document on every change.
          watch = app "watch" ''
            mkdir -p build/packages/local/bgslides
            ln -sfn "$PWD" build/packages/local/bgslides/1.0.0
            typst watch --package-path build/packages --font-path ${fonts} example/main.typ build/slides.pdf
          '';

          # Link the template into the Typst package directory, so that
          # `@local/bgslides:1.0.0` resolves. Inside a clone it links the
          # working tree, from GitHub it links this revision.
          install = app "install" ''
            source="${self}"
            if [ -f "$PWD/typst.toml" ] && grep -q 'name = "bgslides"' "$PWD/typst.toml"; then
              source="$PWD"
            fi
            mkdir -p "$(dirname "${packageDir}")"
            ln -sfn "$source" "${packageDir}"
            echo "linked ${packageDir} -> $source"
          '';

          # Copy the template fonts into the font directory of the user. After
          # this, typst finds them without --font-path.
          install-fonts = app "install-fonts" ''
            target="$HOME/.local/share/fonts/bgslides"
            source="${self}/${fonts}"
            mkdir -p "$target"
            cp "$source"/*/*.ttf "$target"/
            if command -v fc-cache > /dev/null; then fc-cache -f "$target"; fi
            echo "installed the template fonts into $target"
          '';

          # Render the first page of the example document as the package
          # thumbnail.
          thumbnail = {
            type = "app";
            program = "${pkgs.writeShellApplication {
              name = "thumbnail";
              runtimeInputs = [ pkgs.typst pkgs.poppler-utils ];
              text = ''
                mkdir -p build/packages/local/bgslides
                ln -sfn "$PWD" build/packages/local/bgslides/1.0.0
                typst compile --package-path build/packages --font-path ${fonts} example/main.typ build/slides.pdf
                pdftoppm -r 100 -png -f 1 -l 1 -singlefile build/slides.pdf thumbnail
              '';
            }}/bin/thumbnail";
          };
        });

      devShells = forAllSystems (system:
        let pkgs = pkgsFor system; in
        {
          default = pkgs.mkShell {
            packages = [ pkgs.typst pkgs.tinymist ];
            shellHook = ''
              echo "typst $(typst --version | cut -d' ' -f2)"
              echo "nix run .#build | .#watch | .#install | .#install-fonts"
            '';
          };
        });

      formatter = forAllSystems (system: (pkgsFor system).nixpkgs-fmt);
    };
}
