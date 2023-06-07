local wezterm = require 'wezterm'

wezterm.on('update-right-status', function(window, _)
    -- NOTE: Date sample format "Wed Mar 3 08:14"
    local date = wezterm.strftime '%a %b %-d %H:%M '

    local bat = ''
    for _, b in ipairs(wezterm.battery_info()) do
        bat = '🔋 ' .. string.format('%.0f%%', b.state_of_charge * 100)
    end

    window:set_right_status(wezterm.format {
        { Text = bat .. '   ' .. date },
    })
end)

wezterm.on('user-var-changed', function(window, pane, name, value)
    if name == 'open' then
        require('sys').open(value)
    elseif name == 'vnc' then
        local success, _, stderr = wezterm.run_child_process { 'vncviewer', '-Quality=high', value }
        if not success then
            wezterm.log_error(stderr)
        end
    else
        wezterm.log_error('Unsupported command: ' .. name)
    end
end)
