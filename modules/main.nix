local@{ ... }:
let
  inherit (local.inputs.flake.lib.components) uses;
in
uses {
  components =
    (with local.inputs.flake.components; [
      nixology.flake.packages
      nixology.extra.easyOverlay
      nixology.extra.shellEnvs
    ])
    ++ (with local.inputs.environments.components; [
      nixology.environments.just
      nixology.environments.nix
      nixology.environments.node
    ]);
}
