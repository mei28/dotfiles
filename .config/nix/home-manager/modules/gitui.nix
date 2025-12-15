{ pkgs24, ... }:
{
  programs.gitui = {
    enable = true;
    package = pkgs24.gitui;

    # Key bindings configuration
    # // bit for modifiers
    # // bits: 0  None
    # // bits: 1  SHIFT
    # // bits: 2  CONTROL
    # //
    # // Note:
    # // If the default key layout is lower case,
    # // and you want to use `Shift + q` to trigger the exit event,
    # // the setting should like this `exit: Some(( code: Char('Q'), modifiers: ( bits: 1,),)),`
    # // The Char should be upper case, and the shift modified bit should be set to 1.
    # //
    # // Note:
    # // find `KeysList` type in src/keys/key_list.rs for all possible keys.
    # // every key not overwritten via the config file will use the default specified there
    keyConfig = ''
      (
          open_help: Some(( code: F(1), modifiers: "")),


          popup_up: Some(( code: Char('p'), modifiers: "CONTROL",)),
          popup_down: Some(( code: Char('n'), modifiers: "CONTROL",)),
          page_up: Some(( code: Char('b'), modifiers: "CONTROL",)),
          page_down: Some(( code: Char('f'), modifiers: "CONTROL",)),
          home: Some(( code: Char('g'), modifiers: "")),
          end: Some(( code: Char('G'), modifiers: "SHIFT")),
          shift_up: Some(( code: Char('K'), modifiers: "SHIFT")),
          shift_down: Some(( code: Char('J'), modifiers: "SHIFT")),

          edit_file: Some(( code: Char('I'), modifiers: "SHIFT")),

          status_reset_item: Some(( code: Char('U'), modifiers: "SHIFT")),

          diff_reset_lines: Some(( code: Char('u'), modifiers: "")),
          diff_stage_lines: Some(( code: Char('s'), modifiers: "")),

          stashing_save: Some(( code: Char('w'), modifiers: "")),
          stashing_toggle_index: Some(( code: Char('m'), modifiers: "")),

          stash_open: Some(( code: Char('l'), modifiers: "")),

          abort_merge: Some(( code: Char('M'), modifiers: "SHIFT")),

          push: Some((code: Char('P'), modifiers: "SHIFT")),
          force_push: Some((code: Char('P'), modifiers: "CONTROL")),
          fetch: Some((code: Char('f'), modifiers: "")),
          pull: Some((code: Char('F'), modifiers: "SHIFT")),
      )    '';

    # Theme configuration
    # https://github.com/catppuccin/gitui
    theme = ''
      (
          selected_tab: Some("Reset"),
          command_fg: Some("#DCD7BA"),           // fujiWhite
          selection_bg: Some("#2D4F67"),         // waveBlue2
          selection_fg: Some("#DCD7BA"),         // fujiWhite
          cmdbar_bg: Some("#1F1F28"),            // sumiInk3
          cmdbar_extra_lines_bg: Some("#1F1F28"), // sumiInk3
          disabled_fg: Some("#727169"),          // fujiGray
          diff_line_add: Some("#76946A"),        // autumnGreen
          diff_line_delete: Some("#C34043"),     // autumnRed
          diff_file_added: Some("#98BB6C"),      // springGreen
          diff_file_removed: Some("#E46876"),    // waveRed
          diff_file_moved: Some("#957FB8"),      // oniViolet
          diff_file_modified: Some("#DCA561"),   // autumnYellow
          commit_hash: Some("#7E9CD8"),          // crystalBlue
          commit_time: Some("#938AA9"),          // springViolet1
          commit_author: Some("#7FB4CA"),        // springBlue
          danger_fg: Some("#E82424"),            // samuraiRed
          push_gauge_bg: Some("#7E9CD8"),        // crystalBlue
          push_gauge_fg: Some("#1F1F28"),        // sumiInk3
          tag_fg: Some("#D27E99"),               // sakuraPink
          branch_fg: Some("#7AA89F")             // waveAqua2
            )
    '';
  };
}
