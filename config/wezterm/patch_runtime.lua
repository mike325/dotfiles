local wezterm = require("wezterm")
local sys = require("sys")
local is_windows = wezterm.target_triple == "x86_64-pc-windows-msvc"

local function split(str, sep)
	sep = sep or "%s"
	local t = {}
	for s in string.gmatch(str, "([^" .. sep .. "]+)") do
		table.insert(t, s)
	end
	return t
end

local runtimepath = split(package.path, ";")
local paths = {}
local bases
local neovim_path

-- NOTE: Unfortunally wezterm cannot load C modules, which limits how much we can import
--       ex. no libuv support which could make neovim <-> wezterm configs much more compatible
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
