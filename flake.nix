{
  description = "Homebridge";

  inputs.flake.url = "github:nixology/flake.nix";

  inputs.environments.url = "github:nixology/environments.nix";
  inputs.environments.inputs.flake.follows = "flake";

  inputs.homebridge-config-ui-x.url = "github:homebridge/homebridge-config-ui-x/v5.24.0";
  inputs.homebridge-config-ui-x.flake = false;

  inputs.homebridge.url = "github:homebridge/homebridge/v2.1.0";
  inputs.homebridge.flake = false;

  inputs.homebridge-blink-security.url = "github:BitWise-0x/homebridge-blink-security/v1.11.2";
  inputs.homebridge-blink-security.flake = false;

  outputs =
    inputs: with inputs.flake.lib; mkFlake { inherit inputs; } { imports = modulesIn ./modules; };
}
