-- NOTE: We cannot import anything outside of the wezterm confif dir yet
--       we first need to patch the runtime
local wezterm = require 'wezterm'
local is_windows = wezterm.target_triple == 'x86_64-pc-windows-msvc'

local function system_name()
    local name = wezterm.target_triple:lower()
    local system = name:match '%-(%w+)%-'
    if system and system == 'apple' then
        system = 'macos'
    elseif system and system == 'pc' then
        system = 'windows'
    end
    return system or 'unknown'
end

local function homedir()
    return wezterm.home_dir
end

local function basedir()
    return wezterm.config_dir
end

local function configfile()
    return wezterm.config_file
end

-- local function hostname()
--     return wezterm.hostname()
-- end

-- local function cachedir()
--     return ''
-- end

-- local function datadir()
--     return ''
-- end

local sys = {
    name = system_name(),
    home = homedir(),
    base = basedir(),
    configfile = configfile(),
    hostname = wezterm.hostname(),
    -- data = datadir(),
    -- cache = cachedir(),
    -- luajit = luajit_version(),
    -- db_root = db_root_path(),
    -- has_sqlite = has_sqlite(),
    -- user = vim.loop.os_get_passwd(),
    username = is_windows and os.getenv('USERNAME') or os.getenv('USER'),
    version = wezterm.version,
}

function sys.tmp()
    -- local tmpdir = is_windows and 'c:/temp/' or '/tmp/'
    -- return tmpdir .. filename
    return os.tmpname()
end

function sys.basename(str)
    return string.gsub(str, '(.*[/\\])(.*)', '%2')
end

function sys.open(uri)
    local cmd = {}
    if sys.name == 'windows' then
        table.insert(cmd, 'powershell')
        require('utils.tables').list_extend(cmd, { '-noexit', '-executionpolicy', 'bypass', 'Start-Process' })
    elseif sys.name == 'linux' then
        table.insert(cmd, 'xdg-open')
    else
        -- Problably macos
        table.insert(cmd, 'open')
    end
    table.insert(cmd, uri)
    local success, _, _ = wezterm.run_child_process(cmd)
    return success
end

return sys
