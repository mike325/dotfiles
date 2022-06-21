local wezterm = require 'wezterm'
local sys = require 'sys'
require 'patch_runtime'

wezterm.on('update-right-status', function(window, _)
    -- "Wed Mar 3 08:14"
    local date = wezterm.strftime '%a %b %-d %H:%M '

    local bat = ''
    for _, b in ipairs(wezterm.battery_info()) do
        bat = '🔋 ' .. string.format('%.0f%%', b.state_of_charge * 100)
    end

    window:set_right_status(wezterm.format {
        { Text = bat .. '   ' .. date },
    })
end)

local default_prog

if sys.name == 'windows' then
    -- Use OSC 7 as per the above example
    -- set_environment_variables['prompt'] = '$E]7;file://localhost/$P$E\\$E[32m$T$E[0m $E[35m$P$E[36m$_$G$E[0m '
    -- use a more ls-like output format for dir
    -- set_environment_variables['DIRCMD'] = '/d'
    -- And inject clink into the command prompt
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

local firacode = sys.name == 'windows' and 'FiraCode NF' or 'FiraCode Nerd Font'

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
    { key = 'n', mods = 'CTRL|ALT', action = wezterm.action { ActivatePaneDirection = 'Next' } },
    { key = 'p', mods = 'CTRL|ALT', action = wezterm.action { ActivatePaneDirection = 'Prev' } },

    -- { key = 'Insert', mods = 'SHIFT', action = wezterm.action { PasteFrom = 'Clipboard' } },
    -- { key = 'Insert', mods = 'CTRL', action = wezterm.action { CopyTo = 'Clipboard' } },

    { key = 'q', mods = 'LEADER', action = wezterm.action { CloseCurrentTab = { confirm = false } } },
    { key = 'x', mods = 'LEADER', action = wezterm.action { CloseCurrentPane = { confirm = false } } },
}

for i = 1, 8 do
    -- CTRL+ALT + number to activate that tab
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

return {
    default_prog = default_prog,
    font = wezterm.font_with_fallback {
        {
            family = firacode,
            weight = 'Regular',
            stretch = 'Normal',
            style = 'Normal',
        },
        'JetBrains Mono',
        'Noto Color Emoji',
        'Symbols Nerd Font Mono',
        'Last Resort High-Efficiency',
    },
    font_size = 11.0,
    harfbuzz_features = { 'zero' },
    -- use_dead_keys = false,
    window_close_confirmation = 'NeverPrompt',
    -- initial_cols = 232,
    -- initial_rows = 59,
    hide_tab_bar_if_only_one_tab = true,
    leader = { key = '\\', mods = 'CTRL', timeout_milliseconds = 1000 },
    keys = keys,
}
