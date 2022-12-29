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

function M.writefile(path, data)
    assert(type(filename) == type '' and filename ~= '')
    assert(type(data) == type {} or type(data) == type '')

    if type(data) == type {} then
        data = table.concat(data, '\n')
    end

    local fd = io.open(path, 'w')
    fd:write(data)
    fd:close()
end

function M.read_sshconfig()
    local ssh_config = sys.home .. '/.ssh/config'

    if M.exists(ssh_config) then
        local host = ''
        local hosts = {}
        local lines = M.readfile(ssh_config)
        for _, line in pairs(lines) do
            if line ~= '' and line:match '[hH]ost%s+[a-zA-Z0-9_-%.]+' then
                host = line:match '[hH]ost%s+([a-zA-Z0-9_-%.]+)'
            elseif line:match '%s+[hH]ostname%s+[a-zA-Z0-9_-%.]+' and host ~= '' then
                local addr = line:match '%s+[hH]ostname%s+([a-zA-Z0-9_-%.]+)'
                hosts[host] = addr
                host = ''
            end
        end
        return hosts
    end
    return false
end

return M
