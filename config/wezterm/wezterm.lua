if not _G['unpack'] then
    _G['unpack'] = _G['table'].unpack
end

require 'patch_runtime'

local wezterm = require 'wezterm'
local sys = require 'sys'
-- local str = require 'utils.strings'
require 'globals'
require 'events'

local default_prog
if sys.name == 'windows' then
    default_prog = {
        'powershell.exe',
        '-NoLogo',
        -- '-NoProfile',
        '-ExecutionPolicy',
        'RemoteSigned',
        -- '-Command',
        -- '[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;',
    }
end

local firacode = sys.name == 'windows' and 'Fira Code' or 'FiraCode Nerd Font'

local keys = {
    { key = 'z', mods = 'LEADER', action = 'TogglePaneZoomState' },

    { key = 'v', mods = 'LEADER', action = wezterm.action { SplitHorizontal = { domain = 'CurrentPaneDomain' } } },
    { key = 's', mods = 'LEADER', action = wezterm.action { SplitVertical = { domain = 'CurrentPaneDomain' } } },

    {
        key = 'n',
        mods = 'LEADER',
        action = wezterm.action { SpawnCommandInNewTab = { domain = 'CurrentPaneDomain' } },
    },

    { key = 'h', mods = 'LEADER', action = wezterm.action { ActivatePaneDirection = 'Left' } },
    { key = 'l', mods = 'LEADER', action = wezterm.action { ActivatePaneDirection = 'Right' } },
    { key = 'k', mods = 'LEADER', action = wezterm.action { ActivatePaneDirection = 'Up' } },
    { key = 'j', mods = 'LEADER', action = wezterm.action { ActivatePaneDirection = 'Down' } },

    { key = 'R', mods = 'CTRL|SHIFT', action = wezterm.action.ReloadConfiguration },
    { key = 'N', mods = 'CTRL|SHIFT', action = wezterm.action { ActivatePaneDirection = 'Next' } },
    { key = 'P', mods = 'CTRL|SHIFT', action = wezterm.action { ActivatePaneDirection = 'Prev' } },

    {
        key = 'f',
        mods = 'LEADER',
        action = wezterm.action {
            ActivateKeyTable = {
                name = 'font_size',
                one_shot = false,
                replace_current = false,
            },
        },
    },

    {
        key = 'r',
        mods = 'LEADER',
        action = wezterm.action {
            ActivateKeyTable = {
                name = 'resize_pane',
                one_shot = false,
                replace_current = false,
            },
        },
    },

    { key = 'c', mods = 'LEADER', action = 'ActivateCopyMode' },

    { key = 'Insert', mods = 'SHIFT', action = wezterm.action { PasteFrom = 'Clipboard' } },
    { key = 'Insert', mods = 'CTRL', action = wezterm.action { CopyTo = 'ClipboardAndPrimarySelection' } },
    { key = 'Paste', action = wezterm.action { PasteFrom = 'Clipboard' } },
    { key = 'Copy', action = wezterm.action { CopyTo = 'ClipboardAndPrimarySelection' } },
    { key = 'v', mods = 'CTRL|SHIFT', action = wezterm.action { PasteFrom = 'Clipboard' } },

    { key = 'q', mods = 'LEADER', action = wezterm.action { CloseCurrentTab = { confirm = false } } },
    { key = 'x', mods = 'LEADER', action = wezterm.action { CloseCurrentPane = { confirm = false } } },

    { key = 'p', mods = 'CTRL|ALT', action = wezterm.action.ShowLauncher },

    { key = 'D', mods = 'CTRL|SHIFT', action = wezterm.action.ShowDebugOverlay },

    { key = 'o', mods = 'LEADER', action = wezterm.action.EmitEvent 'toggle-opacity' },
}

for i = 1, 8 do
    -- CTRL+\\ + number to activate that tab
    table.insert(keys, {
        key = tostring(i),
        mods = 'LEADER',
        action = wezterm.action { ActivateTab = i - 1 },
    })
    -- -- F1 through F8 to activate that tab
    -- table.insert(tabkeys, {
    --     key = 'F' .. tostring(i),
    --     action = wezterm.action { ActivateTab = i - 1 },
    -- })
end

if sys.name == 'macos' then
    table.insert(keys, {
        key = 'c',
        mods = 'CMD',
        action = wezterm.action { CopyTo = 'ClipboardAndPrimarySelection' },
    })

    table.insert(keys, {
        key = 'v',
        mods = 'CMD',
        action = wezterm.action { PasteFrom = 'Clipboard' },
    })
end

local launch_menu = {}
if sys.name == 'windows' then
    table.insert(launch_menu, {
        label = 'PowerShell',
        args = default_prog,
    })
else
    -- TODO: Add a glob to discover these programs
    table.insert(launch_menu, {
        label = 'Bash',
        args = { 'bash', '-l' },
    })

    table.insert(launch_menu, {
        label = 'Zsh',
        args = { 'zsh', '-l' },
    })
end

return {
    color_scheme = 'Wez (Gogh)',
    disable_default_key_bindings = true,
    launch_menu = launch_menu,
    default_prog = default_prog,
    font = wezterm.font_with_fallback {
        {
            family = firacode,
            weight = 'Regular',
            stretch = 'Normal',
            style = 'Normal',
        },
        'Fira Code',
        'JetBrains Mono',
        'Noto Color Emoji',
        'Symbols Nerd Font Mono',
        'Last Resort High-Efficiency',
    },
    notification_handling = "AlwaysShow",
    window_background_opacity = 0.9,
    scrollback_lines = 10000,
    -- TODO: Dynamic check for DPi?
    font_size = sys.name == 'windows' and 11.0 or 13.0,
    harfbuzz_features = { 'zero' },
    -- use_dead_keys = false,
    window_close_confirmation = 'NeverPrompt',
    -- initial_cols = 232,
    -- initial_rows = 59,
    hide_tab_bar_if_only_one_tab = true,
    leader = { key = '\\', mods = 'CTRL', timeout_milliseconds = 1000 },
    keys = keys,
    key_tables = {
        font_size = {
            { key = '+', mods = 'SHIFT', action = 'IncreaseFontSize' },
            { key = '-', action = 'DecreaseFontSize' },
            { key = '_', mods = 'SHIFT', action = 'DecreaseFontSize' },
            { key = '=', action = 'ResetFontSize' },
            { key = 'Escape', action = 'PopKeyTable' },
            { key = 'q', action = 'PopKeyTable' },
            { key = 'c', mods = 'CTRL', action = 'PopKeyTable' },
        },
        resize_pane = {
            { key = 'LeftArrow', action = wezterm.action { AdjustPaneSize = { 'Left', 1 } } },
            { key = 'h', action = wezterm.action { AdjustPaneSize = { 'Left', 1 } } },

            { key = 'RightArrow', action = wezterm.action { AdjustPaneSize = { 'Right', 1 } } },
            { key = 'l', action = wezterm.action { AdjustPaneSize = { 'Right', 1 } } },

            { key = 'UpArrow', action = wezterm.action { AdjustPaneSize = { 'Up', 1 } } },
            { key = 'k', action = wezterm.action { AdjustPaneSize = { 'Up', 1 } } },

            { key = 'DownArrow', action = wezterm.action { AdjustPaneSize = { 'Down', 1 } } },
            { key = 'j', action = wezterm.action { AdjustPaneSize = { 'Down', 1 } } },

            { key = 'Escape', action = 'PopKeyTable' },
            { key = 'q', action = 'PopKeyTable' },
            { key = 'c', mods = 'CTRL', action = 'PopKeyTable' },
        },
    },
    mouse_bindings = {
        {
            event = { Up = { streak = 1, button = 'Left' } },
            mods = 'CTRL',
            action = 'OpenLinkAtMouseCursor',
        },
        {
            event = { Down = { streak = 1, button = { WheelUp = 1 } } },
            mods = 'CTRL',
            action = wezterm.action.IncreaseFontSize,
        },
        {
            event = { Down = { streak = 1, button = { WheelDown = 1 } } },
            mods = 'CTRL',
            action = wezterm.action.DecreaseFontSize,
        },
    },
}
