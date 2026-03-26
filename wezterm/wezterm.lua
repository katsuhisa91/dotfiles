local wezterm = require("wezterm")
local smart_paste = require("smart_paste")
local config = wezterm.config_builder()

-- ============================================================
-- 基本設定
-- ============================================================
config.automatically_reload_config = true
config.use_ime = true

-- ============================================================
-- フォント
-- ============================================================
config.font = wezterm.font_with_fallback({
  { family = "JetBrains Mono", weight = "Medium" },
  { family = "Hack Nerd Font" },
  { family = "Hiragino Sans" },
})
config.font_size = 13.5
config.line_height = 1.2

-- ============================================================
-- カラースキーム
-- ============================================================
config.color_scheme = "tokyonight_storm"

-- ============================================================
-- ウィンドウ
-- ============================================================
config.window_background_opacity = 0.88
config.macos_window_background_blur = 30
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_padding = {
  left = 12,
  right = 12,
  top = 8,
  bottom = 8,
}
config.initial_cols = 220
config.initial_rows = 50

-- タイトルバー透過
config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
  font = wezterm.font({ family = "JetBrains Mono", weight = "Bold" }),
  font_size = 11.0,
}

config.window_background_gradient = {
  colors = { "#1a1b26" },
}

-- ============================================================
-- タブバー
-- ============================================================
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 36

-- タブバーの色
config.colors = {
  tab_bar = {
    background = "none",
    inactive_tab_edge = "none",
    active_tab = {
      bg_color = "#7aa2f7",
      fg_color = "#1a1b26",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#24283b",
      fg_color = "#565f89",
    },
    inactive_tab_hover = {
      bg_color = "#2e3248",
      fg_color = "#7aa2f7",
    },
    new_tab = {
      bg_color = "none",
      fg_color = "#565f89",
    },
  },
}

-- タブデザイン（Powerline 風）
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local active_bg = "#7aa2f7"
  local active_fg = "#1a1b26"
  local inactive_bg = "#24283b"
  local inactive_fg = "#565f89"
  local bar_bg = "none"

  local background = inactive_bg
  local foreground = inactive_fg

  if tab.is_active then
    background = active_bg
    foreground = active_fg
  elseif hover then
    background = "#2e3248"
    foreground = "#7aa2f7"
  end

  local edge_foreground = background
  local index = string.format(" %d ", tab.tab_index + 1)
  local title = tab.active_pane.title
  if #title > max_width - 8 then
    title = wezterm.truncate_right(title, max_width - 8) .. "…"
  end

  return {
    { Background = { Color = bar_bg } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Attribute = { Intensity = tab.is_active and "Bold" or "Normal" } },
    { Text = index .. title .. " " },
    { Background = { Color = bar_bg } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

-- ============================================================
-- ステータスバー（右側）
-- ============================================================
wezterm.on("update-right-status", function(window, pane)
  local cells = {}

  -- キーテーブル（モード表示）
  local name = window:active_key_table()
  if name then
    table.insert(cells, { text = "  " .. name:upper() .. " ", fg = "#1a1b26", bg = "#e0af68" })
  end

  -- Leader キー待機中
  if window:leader_is_active() then
    table.insert(cells, { text = "  LEADER ", fg = "#1a1b26", bg = "#f7768e" })
  end

  -- 日時
  local date = wezterm.strftime(" %Y-%m-%d  %H:%M ")
  table.insert(cells, { text = date, fg = "#7aa2f7", bg = "#1e2030" })

  -- ホスト名
  local hostname = wezterm.hostname()
  table.insert(cells, { text = " " .. hostname .. " ", fg = "#9ece6a", bg = "#1e2030" })

  local result = {}
  for i, cell in ipairs(cells) do
    local is_first = i == 1
    table.insert(result, { Background = { Color = "none" } })
    table.insert(result, { Foreground = { Color = cell.bg } })
    if is_first then
      table.insert(result, { Text = wezterm.nerdfonts.ple_left_half_circle_thick })
    else
      table.insert(result, { Text = wezterm.nerdfonts.ple_lower_right_triangle })
    end
    table.insert(result, { Background = { Color = cell.bg } })
    table.insert(result, { Foreground = { Color = cell.fg } })
    table.insert(result, { Text = cell.text })
  end
  table.insert(result, { Background = { Color = "none" } })

  window:set_right_status(wezterm.format(result))
end)

-- ============================================================
-- キーバインド
-- ============================================================
config.disable_default_key_bindings = false
config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 2000 }

config.keys = {
  -- ペイン分割
  {
    key = "-",
    mods = "LEADER",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "\\",
    mods = "LEADER",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  -- ペイン移動（vim 風）
  { key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") },
  { key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") },
  -- ペインサイズ変更モード
  {
    key = "r",
    mods = "LEADER",
    action = wezterm.action.ActivateKeyTable({
      name = "resize_pane",
      one_shot = false,
      timeout_milliseconds = 3000,
    }),
  },
  -- タブ操作
  { key = "c", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
  { key = "x", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
  { key = "n", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
  { key = "p", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },
  -- タブ番号で移動（Cmd+数字）
  { key = "1", mods = "CMD", action = wezterm.action.ActivateTab(0) },
  { key = "2", mods = "CMD", action = wezterm.action.ActivateTab(1) },
  { key = "3", mods = "CMD", action = wezterm.action.ActivateTab(2) },
  { key = "4", mods = "CMD", action = wezterm.action.ActivateTab(3) },
  { key = "5", mods = "CMD", action = wezterm.action.ActivateTab(4) },
  { key = "6", mods = "CMD", action = wezterm.action.ActivateTab(5) },
  { key = "7", mods = "CMD", action = wezterm.action.ActivateTab(6) },
  { key = "8", mods = "CMD", action = wezterm.action.ActivateTab(7) },
  { key = "9", mods = "CMD", action = wezterm.action.ActivateTab(8) },
  -- コピーモード
  { key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
  -- フォントサイズ
  { key = "+", mods = "CMD", action = wezterm.action.IncreaseFontSize },
  { key = "-", mods = "CMD", action = wezterm.action.DecreaseFontSize },
  { key = "0", mods = "CMD", action = wezterm.action.ResetFontSize },
  -- コピー
  { key = "c", mods = "CMD", action = wezterm.action.CopyTo("Clipboard") },
  -- ペースト（CMD+v は smart_paste が上書き）
  -- 検索
  { key = "f", mods = "CMD", action = wezterm.action.Search({ CaseSensitiveString = "" }) },
  -- ウィンドウフルスクリーン
  { key = "Enter", mods = "CMD", action = wezterm.action.ToggleFullScreen },
  -- 設定リロード
  { key = "r", mods = "CMD|SHIFT", action = wezterm.action.ReloadConfiguration },
}

config.key_tables = {
  resize_pane = {
    { key = "h", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
    { key = "l", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
    { key = "k", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
    { key = "j", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },
    { key = "Escape", action = wezterm.action.PopKeyTable },
    { key = "q", action = wezterm.action.PopKeyTable },
  },
}

-- ============================================================
-- マウス
-- ============================================================
config.mouse_bindings = {
  -- Cmd+クリックでURLを開く
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CMD",
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

-- ============================================================
-- スクロール
-- ============================================================
config.scrollback_lines = 10000
config.enable_scroll_bar = false

-- ============================================================
-- ベル
-- ============================================================
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = "CursorColor",
}

-- ============================================================
-- Smart Paste（画像 → ファイル保存＋パスペースト）
-- ============================================================
smart_paste.apply(config)

return config
