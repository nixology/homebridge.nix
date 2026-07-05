{ ... }: {
  perSystem =
    { config, lib, ... }:
    {
      shellEnvs.default =
        with config.shellEnvs;
        lib.mkMerge [
          just
          nix
          node
        ];
    };
}
