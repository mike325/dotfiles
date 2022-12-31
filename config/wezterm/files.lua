local sys = require 'sys'
local utils = require 'utils.strings'

local M = {}

function M.forward_path(path)
    if sys.name == 'windows' then
        path = path:gsub('/', '\\')
        return path
    end
    return path
end

function M.exists(filename)
    assert(type(filename) == type '' and filename ~= '')
    local fd = io.open(filename, 'r')
    if fd ~= nil then
        fd:close()
        return true
    end
    return false
end

function M.readfile(path, split)
    assert(M.exists(path))
    local fd = io.open(path, 'r')
    local data = fd:read '*a'
    fd:close()

    if split ~= nil and not split then
        return data
    end
    return utils.split(data, '\n')
end

function M.writefile(filename, data)
    assert(type(filename) == type '' and filename ~= '')
    assert(type(data) == type {} or type(data) == type '')

    if type(data) == type {} then
        data = table.concat(data, '\n')
    end

    local fd = io.open(filename, 'w')
    fd:write(data)
    fd:close()
end

return M
