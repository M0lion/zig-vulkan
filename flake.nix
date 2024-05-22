{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
				zig-vulkan = pkgs.stdenv.mkDerivation {
					name = "zig-vulkan";
					src = builtins.path { path = ./.; name = "zig-vulkan"; };
					version = "0.0.1";
					buildInputs = with pkgs; [ zig ];
					buildPhase = ''
						mkdir -p $out/build
						cp -r ./* $out/build
						zig build install --prefix $out
						mkdir $out/bin
						cp $out/build/zig-out/bin/* $out/bin
					'';
				};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ 
						zig
						glfw
						wayland
					];
        };

				packages.default = zig-vulkan;
      });
}
