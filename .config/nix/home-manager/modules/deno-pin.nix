# Pin Deno to 2.7.11 to avoid the 2.7.12 TLS regression (deno#33231).
# 2.7.12 breaks wss:// via npm:ws because the new native TLSWrap path
# leaves `kStreamBaseField` undefined; nvim-overleaf (and other users of
# npm:ws over TLS) crash with:
#   Cannot read properties of undefined (reading 'Symbol(Deno.internal.rid)')
# Fix is merged upstream in denoland/deno#33208 but not yet released.
# Remove this module once Deno 2.7.13+ lands in nixpkgs.
{ pkgs, lib, ... }:
let
  version = "2.7.11";
  baseUrl = "https://github.com/denoland/deno/releases/download/v${version}";

  sources = {
    "aarch64-darwin" = {
      asset = "deno-aarch64-apple-darwin.zip";
      hash = "sha256-Lab9Ua1q87hxH/MntEi3ax3I7nVniEKv9je2gnIF2L0=";
    };
    "x86_64-darwin" = {
      asset = "deno-x86_64-apple-darwin.zip";
      hash = "sha256-oBq642AkuabPqf+l+oMl1xmT4RX7eoq3nycg/oO3+1s=";
    };
    "aarch64-linux" = {
      asset = "deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-HJAkk35xHRfCC8D9UQFHq6bVMV7Wz74PoObTzuimgbc=";
    };
    "x86_64-linux" = {
      asset = "deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-FpkM1PNyi4Kw8UMrIzIU/nk6DgPCfXei7onyez6YQJc=";
    };
  };

  mkDeno =
    finalPkgs:
    let
      system = finalPkgs.stdenv.hostPlatform.system;
      src =
        sources.${system} or (throw "deno-pin: unsupported system ${system}");
    in
    finalPkgs.stdenvNoCC.mkDerivation {
      pname = "deno";
      inherit version;

      src = finalPkgs.fetchurl {
        url = "${baseUrl}/${src.asset}";
        hash = src.hash;
      };

      nativeBuildInputs =
        [ finalPkgs.unzip ]
        ++ lib.optional finalPkgs.stdenv.isLinux finalPkgs.autoPatchelfHook;

      unpackPhase = ''
        runHook preUnpack
        unzip $src
        runHook postUnpack
      '';

      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        runHook preInstall
        install -Dm755 deno $out/bin/deno
        runHook postInstall
      '';

      meta = {
        description = "Deno pinned to ${version} (workaround for denoland/deno#33231)";
        homepage = "https://deno.land";
        license = lib.licenses.mit;
        platforms = builtins.attrNames sources;
        mainProgram = "deno";
      };
    };
in
{
  nixpkgs.overlays = [
    (final: _prev: { deno = mkDeno final; })
  ];
}
