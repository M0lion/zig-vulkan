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
					buildInputs = with pkgs; [ zig glfw wayland ];
					buildPhase = ''
						zig build
					'';
					installPhase = ''
						mkdir -p $out/bin
						cp zig-out/bin/zig-vulkan $out/bin/zig-vulkan
					'';
				};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ 
						zig
						glfw
						libGL
						wayland
						vulkan-tools
						vulkan-headers
						vulkan-loader
						vulkan-validation-layers
					];

					shellHook = ''
						export LD_LIBRARY_PATH=${pkgs.wayland}/lib:$LD_LIBRARY_PATH
					'';
        };

				packages.default = zig-vulkan;
      });
}
