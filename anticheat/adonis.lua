local Adonis = {
    Name = "Adonis",
    Game = "*",
}

local AdonisThreads = {}
local Hooks = {}

function Adonis.Detect(): boolean
    if not getreg or not getgc or not isfunctionhooked then
        return false
    end

    for _, thread in getreg() do
        if typeof(thread) ~= "thread" then continue end
        local ok, src = pcall(debug.info, thread, 1, "s")
        if not ok or not src then continue end
        if src:find("%.Core%.Anti") or src:find("%.Plugins%.Anti_Cheat") then
            AdonisThreads[#AdonisThreads + 1] = thread
        end
    end

    return #AdonisThreads > 0
end

function Adonis.Bypass(): boolean
    for _, thread in AdonisThreads do
        pcall(coroutine.close, thread)
    end

    local AdonisTables = {}

    if filtergc then
        for _, t in filtergc("table", { Keys = { "Detected", "RLocked" } }, false) do
            if typeof(rawget(t, "Detected")) == "function" then
                AdonisTables[#AdonisTables + 1] = t
            end
        end
    else
        for _, t in getgc(true) do
            if typeof(t) ~= "table" then continue end
            if typeof(rawget(t, "Detected")) == "function" and rawget(t, "RLocked") then
                AdonisTables[#AdonisTables + 1] = t
            end
        end
    end

    for _, tbl in AdonisTables do
        for _, fn in tbl do
            if typeof(fn) ~= "function" or isfunctionhooked(fn) then continue end
            Hooks[fn] = hookfunction(fn, function()
                coroutine.yield()
                return task.wait(9e9)
            end)
        end
    end

    return true
end

function Adonis.Restore()
    for fn in Hooks do
        pcall(restorefunction, fn)
    end
    table.clear(Hooks)
    table.clear(AdonisThreads)
end

-- usage:
if Adonis.Detect() then
    Adonis.Bypass()
end
