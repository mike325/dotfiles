local wezterm = require("wezterm")
local is_windows = wezterm.target_triple == "x86_64-pc-windows-msvc"

local forward_slash = function(str)
    return str:gsub("\\", "/")
end

local function split(str, sep)
    sep = sep or "%s"
    local t = {}
    for s in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, s)
    end
    return t
end

local function system_name()
    local name = wezterm.target_triple:lower()
    if name:match("%-windows%-") then
        return "windows"
    elseif name:match("%-darwin$") then
        return 'macos'
    end
    return "unix"
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
    -- version = version(),
}

-- sys.user.name = sys.user.username
-- sys.username = sys.user.username

function sys.tmp(filename)
    local tmpdir = is_windows == "windows" and "c:/temp/" or "/tmp/"
    return tmpdir .. filename
end

local runtimepath = split(package.path, ";")
local paths = {}
local bases
local neovim_path

if is_windows then
    bases = {
        sys.home .. "/scoop/apps/luarocks/current/rocks/",
        sys.home .. "/AppData/Local/Temp/nvim/packer_hererocks/2.1.0-beta3/",
    }
    neovim_path = sys.home .. "/AppData/Local/nvim/lua/"
else
    bases = {
        sys.home .. "/.luarocks/",
        sys.home .. "/.cache/nvim/packer_hererocks/2.1.0-beta3/",
    }
    neovim_path = sys.home .. "/.config/nvim/lua/"
end

-- TODO: Find version "dinamically"
for _, complement in ipairs({ "lib", "share" }) do
    for _, base in ipairs(bases) do
        table.insert(paths, ("%s/%s/%s"):format(base, complement, "lua/5.4/"))
        table.insert(paths, ("%s/%s/%s"):format(base, complement, "lua/5.1/"))
    end
end
table.insert(paths, neovim_path)

for _, path in ipairs(paths) do
    table.insert(runtimepath, path .. "/?.lua")
    table.insert(runtimepath, path .. "/?/init.lua")
end

package.path = table.concat(runtimepath, ";")

return sys
