local base64 = require("base64")
local json = require("json")

if (xch) then print("\169255000000XCH library already loaded!") end

xch = {
    __listeners = {}
}

function xch.queued()
    local fd = io.open("./.xch", "rb")
    if (not fd) then return false end
    local data = fd:read("*all")
    fd:close()
    return #data > 0
end

function xch.lock()
    local fd = io.open("./.xch.lock", "rb")
    if (fd) then
        fd:close()
        return false
    end
    io.open("./.xch.lock", "wb"):close()
    return true
end

function xch.unlock()
    local fd = io.open("./.xch.lock", "rb")
    if (not fd) then return false end
    fd:close()
    os.remove("./.xch.lock")
    return true
end

function xch.read()
    local fd = io.open("./.xch", "rb")
    if (fd) then
        local data = fd:read("*all")
        fd:close()
        return data
    end
    return nil
end

function xch.write(data)
    if (not xch.lock()) then return false end
    local fd = io.open("./.xch", "wb")
    fd:write(data)
    fd:close()
    xch.unlock()
    return true
end

function xch.on(chan, func)
    if (not xch.__listeners[chan]) then xch.__listeners[chan] = {} end
    table.insert(xch.__listeners[chan], func)
end

addhook("ms100", "xch.__run")
function xch.__run()
    if (xch.queued()) then
        local pkt = json.decode(xch.read())
        pkt.data = base64.from(pkt.data)
        for chan, listeners in pairs(xch.__listeners) do
            if (pkt.chan == chan) then
                for _, listener in pairs(listeners) do
                    listener(pkt.data, chan)
                end
            end
        end
        while not xch.write("") do end
    end
end