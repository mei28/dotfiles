{ pkgsStable, ... }:
{
  programs.gitui = {
    enable = true;
    package = pkgsStable.gitui;

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
          selected_tab: Some(Reset),
          command_fg: Some(Rgb(205, 214, 244)),
          selection_bg: Some(Rgb(88, 91, 112)),
          selection_fg: Some(Rgb(205, 214, 244)),
          cmdbar_bg: Some(Rgb(24, 24, 37)),
          cmdbar_extra_lines_bg: Some(Rgb(24, 24, 37)),
          disabled_fg: Some(Rgb(127, 132, 156)),
          diff_line_add: Some(Rgb(166, 227, 161)),
          diff_line_delete: Some(Rgb(243, 139, 168)),
          diff_file_added: Some(Rgb(249, 226, 175)),
          diff_file_removed: Some(Rgb(235, 160, 172)),
          diff_file_moved: Some(Rgb(203, 166, 247)),
          diff_file_modified: Some(Rgb(250, 179, 135)),
          commit_hash: Some(Rgb(180, 190, 254)),
          commit_time: Some(Rgb(186, 194, 222)),
          commit_author: Some(Rgb(116, 199, 236)),
          danger_fg: Some(Rgb(243, 139, 168)),
          push_gauge_bg: Some(Rgb(137, 180, 250)),
          push_gauge_fg: Some(Rgb(30, 30, 46)),
          tag_fg: Some(Rgb(245, 224, 220)),
          branch_fg: Some(Rgb(148, 226, 213))
      )
    '';
  };
}
