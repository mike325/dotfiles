local wezterm = require 'wezterm'

local M = {}

function M.get_windows()
    return wezterm.gui.gui_windows()
end

function M.get_active_window()
    local windows = wezterm.gui.gui_windows()
    for _, win in ipairs(windows) do
        if win:is_focused() then
            return win
        end
    end
    return windows[1]
end

function M.get_active_tab(window)
    if not window then
        window = M.get_active_window()
    end
    local tab = window:active_tab()
    return tab
end

function M.get_active_pane(tab)
    if not tab then
        tab = M.get_active_tab()
    end
    local pane = tab:active_pane()
    return pane
end

function M.get_user_vars(pane)
    if not pane then
        pane = M.get_active_pane()
    end
    return pane:get_user_vars()
end

return M
