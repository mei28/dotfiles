{
  # kasane: 外付けキーボードを載せている間だけ内蔵キーボードを止める (github:mei28/kasane)。
  # モジュールは flake.nix で kasane の flake から読み込む。
  # activation でログインキーチェーンの署名用証明書を使うので、Mac ごとに最初の switch の前に
  # `nix run github:mei28/kasane#signing-identity` で作っておく。
  services.kasane.enable = true;
}
