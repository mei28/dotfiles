# suiko: Japanese prose linter (translationese, repetition, rhythm, reading load).
# Prebuilt release binary; the Sudachi dictionary is embedded, so the binary is ~200MB.
# Consumed by ~/.claude/skills/japanese-tech-writing/scripts/lint.sh via PATH.
# Update: bump `version` and replace the four hashes from the release `.sha256` files
# (`nix hash convert --hash-algo sha256 --to sri <hex>`).
{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
}:
let
  version = "0.3.8";
  baseUrl = "https://github.com/nwiizo/suiko/releases/download/v${version}";

  sources = {
    "aarch64-darwin" = {
      target = "aarch64-apple-darwin";
      hash = "sha256-Nnwt8Quqh8ZFH61ACn/5zJOn8MLunoDbpl2tVAMwl6A=";
    };
    "x86_64-darwin" = {
      target = "x86_64-apple-darwin";
      hash = "sha256-/BfIiSKxFWsX5QsS8SAHkQB9pWfPB3zDi/7Qkgh77HM=";
    };
    "x86_64-linux" = {
      target = "x86_64-unknown-linux-gnu";
      hash = "sha256-/YnhOhrcZo+21UHPkVkAxAkqQgWlVKkoJs+Bf2vG9C0=";
    };
    "aarch64-linux" = {
      target = "aarch64-unknown-linux-gnu";
      hash = "sha256-SJ1m1YbCP4ESTT23Cps0DK1oFCmnJgGz3HFFupt2uOg=";
    };
  };

  system = stdenv.hostPlatform.system;
  src = sources.${system} or (throw "suiko: unsupported system ${system}");
in
stdenvNoCC.mkDerivation {
  pname = "suiko";
  inherit version;

  src = fetchurl {
    url = "${baseUrl}/suiko-v${version}-${src.target}.tar.gz";
    inherit (src) hash;
  };

  nativeBuildInputs = lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  # The tarball unpacks into suiko-v<version>-<target>/, which stdenv enters for us.
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 suiko $out/bin/suiko
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/suiko --version | grep -F "${version}"
    # Not `grep -q`: it exits on the first match and closes the pipe while suiko
    # is still writing the JSON, and suiko (Rust, SIGPIPE ignored) then panics
    # with "failed printing to stdout: Broken pipe". Read to EOF instead.
    printf '重要なのは、結論です。\n' | $out/bin/suiko lint - --json | grep -F forbidden_phrase > /dev/null
    runHook postInstallCheck
  '';

  meta = {
    description = "Japanese prose linter for translationese, repetition and reading load";
    homepage = "https://github.com/nwiizo/suiko";
    license = lib.licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "suiko";
  };
}
