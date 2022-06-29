vim.g.ale_sign_error='E'
vim.g.ale_sign_warning='W'
vim.g.ale_sign_column_always=1
vim.g.ale_statusline_format={'⨉ %d', '⚠ %d', '⬥ ok'}
vim.g.ale_echo_msg_error_str='E'
vim.g.ale_echo_msg_warning_str='W'
vim.g.ale_echo_msg_format='[%linter%] %s [%severity%]'
vim.g.ale_fix_on_save=1


vim.g.ale_linters={
  python={'flake8'}
}

vim.g.ale_fixers={
  python={'black','isort'}
}
