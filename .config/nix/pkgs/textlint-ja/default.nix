# textlint bundled with the two AI-writing presets that the japanese-tech-writing skill
# uses. The three packages live in one node_modules tree, and the wrapper bakes in
# `--rules-base-directory` pointing at that tree, so the skill's .textlintrc.json can
# stay where it is and be passed with `--config`. This textlint therefore resolves only
# the bundled presets; it is not a general-purpose textlint.
# Update: edit package.json, regenerate package-lock.json with
# `npm install --package-lock-only --ignore-scripts`, then replace npmDepsHash with
# `nix run nixpkgs#prefetch-npm-deps -- package-lock.json`.
{
  lib,
  buildNpmPackage,
  nodejs_24,
  makeWrapper,
}:
buildNpmPackage {
  pname = "textlint-ja";
  version = "15.8.0";

  src = ./.;
  npmDepsHash = "sha256-My09nV0M6A7VipB6NH2Lytf98MUK/eYgMbhq6Kfrlww=";
  nodejs = nodejs_24;

  dontNpmBuild = true;
  npmFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    modules=$out/lib/node_modules/textlint-ja/node_modules
    makeWrapper ${nodejs_24}/bin/node $out/bin/textlint \
      --add-flags "$modules/textlint/bin/textlint.js" \
      --add-flags "--rules-base-directory $modules"
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    # Both presets must resolve through the baked-in rules directory. Severity is
    # pinned to warning as in the skill's config, so findings do not make textlint
    # exit 1 (stdenv runs with pipefail).
    cat > rc.json <<'JSON'
    {"rules":{
      "preset-ai-words-ja":{"no-ai-words":{"severity":"warning"}},
      "@textlint-ja/preset-ai-writing":{
        "no-ai-list-formatting":{"severity":"warning"},
        "no-ai-hype-expressions":{"severity":"warning"},
        "no-ai-emphasis-patterns":{"severity":"warning"},
        "no-ai-colon-continuation":{"severity":"warning"},
        "ai-tech-writing-guideline":{"severity":"warning"}}}}
    JSON
    printf 'この道具は設計の入口である。\n\n- **重要**: 土台を作る。\n' > t.md
    $out/bin/textlint --config rc.json --format unix t.md > out.txt
    grep -q 'ai-words-ja/no-ai-words' out.txt
    grep -q '@textlint-ja/ai-writing/no-ai-list-formatting' out.txt
    runHook postInstallCheck
  '';

  meta = {
    description = "textlint with preset-ai-words-ja and preset-ai-writing for Japanese prose";
    homepage = "https://github.com/textlint/textlint";
    license = lib.licenses.mit;
    mainProgram = "textlint";
  };
}
