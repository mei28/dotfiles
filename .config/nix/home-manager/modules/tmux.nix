{
  config,
  pkgs,
  inputs,
  ...
}:
let
  tmux-sensible = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "sensible";
    version = "unstable-2017-09-05";
    src = pkgs.fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-sensible";
      rev = "e91b178ff832b7bcbbf4d99d9f467f63fd1b76b5";
      sha256 = "1z8dfbwblrbmb8sgb0k8h1q0dvfdz7gw57las8nwd5gj6ss1jyvx";
    };
  };
  tmux-online-status = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "online-status";
    version = "unstable-2018-11-30";
    src = pkgs.fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-online-status";
      rev = "ea86704ced8a20f4a431116aa43f57edcf5a6312";
      sha256 = "1hy3vg8v2sir865ylpm2r4ip1zgd4wlrf24jbwh16m23qdcvc19r";
    };
  };
  tmux-mutagen-status = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "mutagen-status";
    version = "unstable";
    src = inputs.tmux-mutagen-status;
    # mkTmuxPlugin は pluginName のハイフンをアンダースコアに変換したファイル名を探す
    # プラグインの実ファイルは mutagen-status.tmux なのでリネームして合わせる
    postInstall = ''
      mv $out/share/tmux-plugins/mutagen-status/mutagen-status.tmux \
         $out/share/tmux-plugins/mutagen-status/mutagen_status.tmux
    '';
  };
in
{
  programs.tmux = {
    enable = true;
    # see: https://github.com/nix-community/home-manager/issues/5952
    # https://suzumiyaaoba.github.io/blog/2024-10-14-tmux-with-nix/
    package = pkgs.tmux.overrideAttrs (old: rec {
      version = "3.5";
      src = pkgs.fetchFromGitHub {
        owner = "tmux";
        repo = "tmux";
        rev = version;
        hash = "sha256-8CRZj7UyBhuB5QO27Y+tHG62S/eGxPOHWrwvh1aBqq0=";
      };
    });

    # tmuxプラグインの設定
    plugins = with pkgs; [
      {
        plugin = tmux-sensible;
        extraConfig = ''

          # ステータスバーの設定
          set-option -g status-position top
          set-option -g status-left-length 90
          set-option -g status-right-length 90
          set-option -g status-left "#[fg=#ECEFF4,bg=#5E81AC] #S:#I.#P #[fg=colour253,bg=colour236] #( [ -n \"\$SSH_CONNECTION\" ] && echo \"󰒍 \$(hostname -I | awk '{print \$1}') \" || echo \"\" )"
          set-option -g status-interval 1
          set-option -g status-justify centre
          set-option -g status-bg "colour238"
          set-option -g status-fg "colour255"
        '';
      }
      {
        plugin = tmux-online-status;
        extraConfig = ''
          set-option -g status-right "#{mutagen_status} #[fg=colour253,bg=colour236] [%m/%d(%a) %H:%M]|#[fg=colour250,bg=colour240]#{online_status}"
        '';
      }
      {
        plugin = tmux-mutagen-status;
        extraConfig = ''
          set-option -g @mutagen_status_icon_synced "mut:✓"
          set-option -g @mutagen_status_icon_syncing "mut:⟳"
          set-option -g @mutagen_status_icon_paused "mut:⏸"
          set-option -g @mutagen_status_icon_error "mut:✗"
          set-option -g @mutagen_status_icon_forward "mut:⇄"
          set-option -g @mutagen_status_cache_seconds "5"
        '';
      }
    ];
    shell = "~/.nix-profile/bin/bash";
    terminal = "tmux-256color";
    mouse = true;

    # .tmux.conf の内容を extraConfig に記述
    extraConfig = ''
      # tmux起動時のシェルをbashにする
      # set-option -g default-shell /bin/bash
      # 256色: default-terminal は programs.tmux.terminal = "tmux-256color" で設定済み
      set -g terminal-overrides 'xterm*:colors=256'

      # OSC52 clipboard support
      set -s set-clipboard on
      # Advertise clipboard capability so tmux forwards inner-app (nvim) OSC 52 to the outer terminal
      set -as terminal-features 'xterm*:clipboard'

      # Bracketed paste: 外側ターミナルと内側ペインの間で正しく協調させる
      set -as terminal-features 'xterm*:bpaste'

      # allow-passthrough で nvim が直接 Ghostty と kitty keyboard protocol を交渉する
      # (tmux 側で extended-keys を有効にするとペースト内の改行が ESC[27;5;106~ に化けるため削除)
      set -g allow-passthrough on

      # # prefixキーをC-qに変更
      # set -g prefix C-q
      #
      # # C-bのキーバインドを解除
      # unbind C-b

      # vimのキーバインドでペインを移動する
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # vimのキーバインドでペインをリサイズする
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # | でペインを縦分割する
      bind | split-window -h

      # - でペインを縦分割する
      bind - split-window -v

      # 番号基準値を変更
      set-option -g base-index 1

      # マウス操作は programs.tmux.mouse = true で有効化
      bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'copy-mode -e'"

      # OS が Linux の時は xsel を使う
      if-shell -b '[ "$(uname)" = "Linux" ]' {
        set -s copy-command "xsel --clipboard --input"
      }

      # OS が Darwin の時は pbcopy を使う
      if-shell -b '[ "$(uname)" = "Darwin" ]' {
        set -s copy-command "pbcopy"
      }

      # コピーモードを設定する
      # コピーモードでvimキーバインドを使う
      setw -g mode-keys vi

      # 'v' で選択を始める
      bind -T copy-mode-vi v send -X begin-selection

      # 'V' で行選択
      bind -T copy-mode-vi V send -X select-line

      # 'C-v' で矩形選択
      bind -T copy-mode-vi C-v send -X rectangle-toggle

      # 'y' でヤンク
      # bind -T copy-mode-vi y send -X copy-selection
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel

      # 'Y' で行ヤンク
      bind -T copy-mode-vi Y send -X copy-line

      # マウスホイールのスクロール速度を遅くする（既定 5 行/ノッチ → 2 行）
      bind -T copy-mode    WheelUpPane   send-keys -X -N 2 scroll-up
      bind -T copy-mode    WheelDownPane send-keys -X -N 2 scroll-down
      bind -T copy-mode-vi WheelUpPane   send-keys -X -N 2 scroll-up
      bind -T copy-mode-vi WheelDownPane send-keys -X -N 2 scroll-down

      # 'C-p'でペースト
      bind-key C-p paste-buffer
      
      # 'Shift Enter'で改行
      bind -n S-Enter send-keys Escape "[13;2u"
    '';
  };
}
