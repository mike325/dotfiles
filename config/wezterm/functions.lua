local wezterm = require 'wezterm'

local M = {}

function M.get_windows()
    -- return wezterm.gui.gui_windows()
    return wezterm.mux.all_windows()
end

function M.get_active_tab(window)
    if not window then
        local windows = wezterm.mux.all_windows()
        window = windows[1]
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
