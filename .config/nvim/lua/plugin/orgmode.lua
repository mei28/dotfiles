-- org-mode as a task engine only. Prose stays in markdown.
-- Files live in ~/organon, a private repo synced with `os`. The shell side
-- (org/oa/om/...) lives in .config/nix/home-manager/modules/configs/org.bash
local spec = {
  {
    'nvim-orgmode/orgmode',
    event = 'VeryLazy',
    ft = { 'org' },
    -- Lets `nvim -c "Org agenda d"` work: lazy.nvim registers a stub :Org and
    -- loads the plugin on first use, so the shell aliases need no :Lazy call.
    cmd = { 'Org' },
    config = function()
      require('orgmode').setup({
        org_agenda_files = '~/organon/**/*',
        org_default_notes_file = '~/organon/inbox.org',

        -- Open agenda/capture as a split pinned to the top of the screen.
        -- Other values: 'horizontal', 'vertical', 'auto', 'tabnew', {'float', 0.9}.
        win_split_mode = 'topleft 20split',

        -- NEXT marks what is actually being worked on right now.
        -- It drives the "日報" agenda view below.
        org_todo_keywords = { 'TODO', 'NEXT', 'WAITING', '|', 'DONE', 'CANCELLED' },
        org_log_into_drawer = 'LOGBOOK',
        org_agenda_start_on_weekday = 1,

        -- <C-a> is globally mapped to <Home> (lua/config/keymap.lua:10).
        -- Orgmode's buffer-local date increment would shadow it inside org files,
        -- so move it to +/- instead. Those are agenda-only defaults
        -- (org_agenda_priority_up/down) and unused in org file buffers.
        mappings = {
          org = {
            org_timestamp_up = '+',
            org_timestamp_down = '-',
          },
        },

        org_capture_templates = {
          t = {
            description = 'times (流し書き)',
            template = '* %U\n%?',
            target = '~/organon/journal/%<%Y-%m-%d>.org',
          },
          T = {
            -- %a links back to the file:line capture was invoked from,
            -- so a thought jotted mid-coding keeps its way back.
            description = 'times + 現在地リンク',
            template = '* %U\n%?\n%a',
            target = '~/organon/journal/%<%Y-%m-%d>.org',
          },
          i = {
            description = 'inbox (あとで整理)',
            template = '* TODO %?\n  %U',
            target = '~/organon/inbox.org',
          },
          n = {
            description = 'NEXT (今から着手)',
            template = '* NEXT %?\n  %U',
            target = '~/organon/tasks.org',
          },
        },

        org_agenda_custom_commands = {
          d = {
            description = '日報 (今日)',
            types = {
              {
                type = 'agenda',
                org_agenda_span = 'day',
                org_agenda_overriding_header = '今日の予定と締切',
              },
              {
                type = 'tags_todo',
                match = 'TODO="NEXT"',
                org_agenda_overriding_header = 'いま手を付けているもの',
              },
            },
          },
          w = {
            description = '他人待ち',
            types = {
              {
                type = 'tags',
                match = '他人待ち',
                org_agenda_overriding_header = '自分ではなく他人で止まっているもの',
              },
            },
          },
        },
      })
    end,
  },
}

return spec
