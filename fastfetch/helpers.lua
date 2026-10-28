local borderColor = "\27[38;2;143;162;132m"
local accentColor = "\27[38;2;196;255;176m"
local resetColor = "\27[0m"

local function text(value)
    if value == nil then
        return ""
    end
    return tostring(value)
end

function ffpad(value, width)
    local s = text(value)
    local len = #s
    if len < width then
        return s .. string.rep(" ", width - len)
    end
    return s
end

function ffcut(value, width)
    local s = text(value)
    if #s <= width then
        return s
    end
    return s:sub(1, width - 3) .. "..."
end

function ffline(value)
    local s = text(value):gsub("\27%[[0-9;]*m", "")
    return ffpad(ffcut(s, 50), 50) .. borderColor .. " â”‚" .. resetColor
end

function fftop(title)
    local label = " " .. title .. " "
    local inner = 54
    local left = math.floor((inner - #label) / 2)
    local right = inner - #label - left
    return borderColor .. "â”Œ" .. string.rep("â”€", left) .. accentColor .. label .. borderColor .. string.rep("â”€", right) .. "â”" .. resetColor
end

function ffbottom()
    return borderColor .. "â””" .. string.rep("â”€", 54) .. "â”˜" .. resetColor
end

function ffos(a)
    return a.prettyName .. " " .. a.arch
end

function ffkernel(a)
    return a.sysname .. " " .. a.release
end

function ffpackages(a)
    local managers = {
        { "scoop", (a.scoopUser or 0) + (a.scoopGlobal or 0) },
        { "winget", a.winget or 0 },
        { "choco", a.choco or 0 },
        { "pacman", a.pacman or 0 },
        { "dpkg", a.dpkg or 0 },
        { "rpm", a.rpm or 0 },
        { "brew", a.brewAll or 0 },
        { "flatpak", a.flatpakAll or 0 },
    }
    local name, count = nil, 0
    for _, manager in ipairs(managers) do
        if manager[2] > count then
            name, count = manager[1], manager[2]
        end
    end
    if name then
        return count .. " (" .. name .. ")"
    end
    return (a.all or 0) .. " packages"
end

function ffshell(a)
    if a.version and a.version ~= "" then
        return a.prettyName .. " " .. a.version
    end
    return a.prettyName
end

function ffwm(a)
    return a.prettyName
end

function fftheme(a)
    if a.theme2 and a.theme2 ~= "" then
        return a.theme1 .. " / " .. a.theme2
    end
    return a.theme1
end

function ffterminal(a)
    return a.prettyName
end

function fffont(a)
    return a.combined
end

function ffdisplay(a)
    return a.width .. "x" .. a.height .. " @ " .. a.refreshRate .. " Hz"
end

function ffcpu(a)
    return a.name .. " (" .. a.coreTypes .. ") @ " .. a.freqMax
end

function ffcpuusage(a)
    if type(a) == "table" and a.avg and a.avg ~= "" then
        return tostring(a.avg) .. " usage | " .. tostring(a.max) .. " peak"
    end
    return "n/a"
end

function ffgpu(a)
    local s = a.name
    if a.frequency and a.frequency ~= "" then
        s = s .. " @ " .. a.frequency
    end
    if a.type and a.type ~= "" then
        s = s .. " [" .. a.type .. "]"
    end
    return s
end

function ffgpu_specs(a)
    local parts = {}
    if a.driver and a.driver ~= "" then
        parts[#parts + 1] = "driver " .. a.driver
    end
    local memory = a.dedicatedTotal
    if a.type == "Integrated" and a.sharedTotal and a.sharedTotal ~= "" then
        memory = a.sharedTotal
    end
    if (not memory or memory == "") and a.sharedTotal then
        memory = a.sharedTotal
    end
    if memory and memory ~= "" and memory ~= "0 B" then
        parts[#parts + 1] = memory
    end
    if a.platformApi and a.platformApi ~= "" then
        parts[#parts + 1] = a.platformApi
    end
    if a.temperature and a.temperature ~= "" then
        parts[#parts + 1] = a.temperature
    end
    if a.coreUsageNum and a.coreUsageNum ~= "" then
        parts[#parts + 1] = a.coreUsageNum
    end
    if #parts == 0 then
        return "specs unavailable"
    end
    return table.concat(parts, " | ")
end

function ffmemory(a)
    return a.used .. " / " .. a.total .. " (" .. a.percentage .. ")"
end

function ffdisk(a)
    return a.mountpoint .. " " .. a.sizeUsed .. " / " .. a.sizeTotal .. " (" .. a.sizePercentage .. ")"
end

function ffuptime(a)
    return a.formatted
end

function fflocalip(a)
    if a.ifname and a.ifname ~= "" then
        return a.ipv4 .. " (" .. a.ifname .. ")"
    end
    return a.ipv4
end

function ffbattery(a)
    local status = a.status
    if type(status) == "table" then
        status = table.concat(status, ", ")
    end
    return text(a.capacity) .. " [" .. text(status) .. "]"
end

