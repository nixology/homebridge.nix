{ ... }@local:
let
  inherit (local.inputs) homebridge homebridge-config-ui-x self;

  inherit (local.lib) metadataForFlakeInput;

  _homebridge_ = metadataForFlakeInput self homebridge;

  _homebridge-config-ui-x_ = metadataForFlakeInput self homebridge-config-ui-x;
in
{
  perSystem =
    {
      config,
      final,
      ...
    }:
    let
      inherit (final) buildNpmPackage importNpmLock;
    in
    {
      overlayAttrs = {
        inherit (config.packages) homebridge;
      };

      packages = {
        homebridge = buildNpmPackage (finalAttrs: {
          inherit (_homebridge_) pname src version;
          npmDeps = importNpmLock { npmRoot = finalAttrs.src; };
          npmConfigHook = importNpmLock.npmConfigHook;
        });

        homebridge-config-ui-x = buildNpmPackage (
          finalAttrs:
          let
            inherit (_homebridge-config-ui-x_) pname src version;

            homebridge-config-ui = buildNpmPackage (
              _finalAttrs:
              let
                pname = "homebridge-config-ui";
                inherit (_homebridge-config-ui-x_) src version;
              in
              {
                inherit pname src version;

                setSourceRoot = ''
                  sourceRoot="$(echo */ui)"
                '';

                npmDepsHash = "sha256-cwfF+J+zLLyj0iTdP+rh/Tz0OaJPMUtyo/SuCubZx5Y=";

                nodejs = final.nodejs_22;

                postPatch = ''
                  substituteInPlace angular.json \
                    --replace-fail '"crossOrigin": "use-credentials"' '"crossOrigin": "none"'
                '';

                # Angular normally writes to ../public, which would escape this
                # derivation's sourceRoot. Override it to a local output dir.
                npmBuildFlags = [
                  "--"
                  "--output-path"
                  "./dist"
                  "--base-href"
                  "/"
                ];

                installPhase = ''
                  runHook preInstall

                  mkdir -p $out
                  cp -r dist/browser/. $out/public/

                  runHook postInstall
                '';
              }
            );
          in
          {
            inherit pname src version;

            nativeBuildInputs = [
              final.makeWrapper
            ];

            nodejs = final.nodejs_22;

            npmDeps = importNpmLock { npmRoot = finalAttrs.src; };
            npmConfigHook = importNpmLock.npmConfigHook;

            # Do not run the root "build", because it tries to build the UI without
            # ui/node_modules.
            npmBuildScript = "build:server";

            postBuild = ''
              rm -rf public
              cp -r ${homebridge-config-ui}/public public
            '';

            postInstall = ''
              mkdir -p $out/lib/node_modules
              ln -s ${final.homebridge}/lib/node_modules/homebridge \
                $out/lib/node_modules/homebridge

              wrapProgram $out/bin/hb-service \
                --prefix PATH : ${final.lib.makeBinPath [ final.homebridge ]}
            '';
          }
        );
      };
    };
}
