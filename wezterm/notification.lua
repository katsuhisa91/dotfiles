-- notification.lua
-- Claude Code の Notification/Stop フックから書き出された
-- /tmp/wezterm-notifications/<pane_id>.json を読み込み、
-- タブタイトルやステータスバーに [WAIT]/[DONE] を表示する。

local wezterm = require('wezterm')
local M = {}

local NOTIFY_DIR = '/tmp/wezterm-notifications'

-- wezterm.GLOBAL はコンフィグリロードをまたいで永続する
if not wezterm.GLOBAL.claude_notifs then
  wezterm.GLOBAL.claude_notifs = {}
end

-- /tmp/wezterm-notifications/*.json を取り込んでストアを更新する。
-- 読み込み後にファイルを削除するため、次回以降は再取得しない。
function M.ingest()
  local ok, files = pcall(wezterm.glob, NOTIFY_DIR .. '/*.json')
  if not ok or not files then return end

  for _, path in ipairs(files) do
    local pane_id = path:match('(%d+)%.json$')
    if pane_id then
      local f = io.open(path, 'r')
      if f then
        local raw = f:read('*a')
        f:close()
        local status = raw:match('"status"%s*:%s*"([^"]+)"')
        local ts = tonumber(raw:match('"timestamp"%s*:%s*(%d+)')) or 0
        if status then
          local prev = wezterm.GLOBAL.claude_notifs[pane_id]
          local changed = not prev or prev.status ~= status
          wezterm.GLOBAL.claude_notifs[pane_id] = {
            status = status,
            timestamp = ts,
            read = (not changed) and (prev and prev.read or false) or false,
          }
        end
        os.remove(path)
      end
    end
  end
end

-- ペインIDに対応する未読インジケータを返す。
-- 戻り値: "" | "WAIT" | "DONE"
function M.get_indicator(pane_id)
  local n = wezterm.GLOBAL.claude_notifs[tostring(pane_id)]
  if not n or n.read then return '' end
  if n.status == 'waiting' then return 'WAIT' end
  if n.status == 'done' then return 'DONE' end
  return ''
end

-- 未読通知の件数を返す。
function M.get_unread_count()
  local count = 0
  for _, n in pairs(wezterm.GLOBAL.claude_notifs) do
    if not n.read then count = count + 1 end
  end
  return count
end

-- 指定ペインの通知を既読にする。
function M.mark_read(pane_id)
  local n = wezterm.GLOBAL.claude_notifs[tostring(pane_id)]
  if n then n.read = true end
end

-- 最新の未読通知のペインIDを返す (number | nil)。
function M.get_latest_unread_pane_id()
  local latest_ts, latest_id = -1, nil
  for pane_id, n in pairs(wezterm.GLOBAL.claude_notifs) do
    if not n.read and n.timestamp > latest_ts then
      latest_ts = n.timestamp
      latest_id = tonumber(pane_id)
    end
  end
  return latest_id
end

-- 指定ペインIDのペインオブジェクトを全タブ・全ペインから検索する。
local function find_pane_by_id(mux_window, target_id)
  for _, tab in ipairs(mux_window:tabs()) do
    for _, pane_info in ipairs(tab:panes_with_info()) do
      if pane_info.pane:pane_id() == target_id then
        return tab, pane_info.pane
      end
    end
  end
  return nil, nil
end

-- Leader+u で通知一覧を表示する action を返す。
-- config.keys に渡して使う。
function M.list_action()
  return wezterm.action_callback(function(window, _pane)
    local choices = {}
    for pane_id, n in pairs(wezterm.GLOBAL.claude_notifs) do
      local label = string.format(
        '[%s] pane:%s%s',
        n.status:upper(),
        pane_id,
        n.read and '' or '  (unread)'
      )
      table.insert(choices, { label = label, id = pane_id })
    end
    if #choices == 0 then return end
    table.sort(choices, function(a, b) return a.label < b.label end)

    window:perform_action(
      wezterm.action.InputSelector({
        title = 'Claude Code Notifications',
        choices = choices,
        fuzzy = true,
        action = wezterm.action_callback(function(inner_window, _inner_pane, id, _label)
          if not id then return end
          M.mark_read(id)
          local target_id = tonumber(id)
          if not target_id then return end
          local tab, _p = find_pane_by_id(inner_window:mux_window(), target_id)
          if tab then tab:activate() end
        end),
      }),
      _pane
    )
  end)
end

-- Leader+n で最新未読ペインへジャンプする action を返す。
function M.jump_action()
  return wezterm.action_callback(function(window, _pane)
    local target_id = M.get_latest_unread_pane_id()
    if not target_id then return end
    M.mark_read(tostring(target_id))
    local tab, _p = find_pane_by_id(window:mux_window(), target_id)
    if tab then tab:activate() end
  end)
end

return M
