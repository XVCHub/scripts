local HOST = "https://sigmaspy.shie-22-idy.online"
local BYPASS_LIST = { "adonis" }
local SS_FOLDER = "Sigma spy"

local HookFn = hookfunction or hookfunc or replaceclosure
local ctx = { Hooks = {}, HookFunction = HookFn }

local function fetch(path)
    return game:HttpGet(HOST .. "/" .. path)
end

local function loadBypassModules()
    local out = {}
    for _, name in BYPASS_LIST do
        local src = fetch("bypass/" .. name .. ".lua")
        local chunk = loadstring(src, name)
        if not chunk then continue end
        local ok, mod = pcall(chunk)
        if not ok or typeof(mod) ~= "table" then continue end
        local isDedicated = false
        if typeof(mod.Game) == "table" then
            isDedicated = table.find(mod.Game, game.PlaceId)
                or table.find(mod.Game, tostring(game.PlaceId))
        else
            isDedicated = tostring(mod.Game) == tostring(game.PlaceId)
        end
        table.insert(out, { mod = mod, dedicated = isDedicated })
    end
    return out
end

local function detect(modules)
    if not HookFn then return nil end
    for _, entry in modules do
        if entry.dedicated then
            local ok, det = pcall(entry.mod.Detect)
            if ok and det then return entry.mod end
        end
    end
    for _, entry in modules do
        if entry.mod.Game == "*" then
            local ok, det = pcall(entry.mod.Detect)
            if ok and det then return entry.mod end
        end
    end
    return nil
end

local function showModal(matchedName)
    local ReGui = loadstring(fetch("ReGui.lua"), "ReGui")()

    local Window = ReGui:Window({
        Title = "Sigma Spy Loader",
        Size = UDim2.fromOffset(380, matchedName and 210 or 170),
        NoCollapse = true,
        NoResize = true,
        NoClose = true,
    }):Center()

    if matchedName then
        Window:Label({
            Text = ("Load Sigma Spy?\n\nDetected anticheat: %s\nEnable the bypass to neutralise it before Sigma Spy hooks in."):format(matchedName),
            TextWrapped = true,
        })
    else
        Window:Label({
            Text = "Load Sigma Spy?\n\nNo known anticheat detected in this place.",
            TextWrapped = true,
        })
    end
    Window:Separator()

    local bypassChecked = matchedName ~= nil
    if matchedName then
        Window:Checkbox({
            Label = "Enable anticheat bypass",
            Value = true,
            Callback = function(_, v) bypassChecked = v end,
        })
        Window:Separator()
    end

    local answered, choice = false, nil
    local Row = Window:Row({ Expanded = true })
    Row:Button({ Text = "Yes", Callback = function() choice = "Yes"; answered = true end })
    Row:Button({ Text = "No",  Callback = function() choice = "No";  answered = true end })

    while not answered do task.wait() end
    pcall(function() Window:Close() end)
    return choice, bypassChecked
end

getgenv().wax = getgenv().wax or {}
getgenv().wax.shared = getgenv().wax.shared or { Hooks = ctx.Hooks, Hooking = { HookFunction = HookFn } }

task.spawn(function()
    local modules = loadBypassModules()
    task.wait()
    local matched = detect(modules)
    task.wait()

    local choice, wantBypass = showModal(matched and matched.Name or nil)
    if choice ~= "Yes" then return end

    if matched and wantBypass then
        pcall(matched.Bypass, ctx)
        task.wait()
    end

    local function throttle(name, every)
        local orig = getgenv()[name] or getfenv(0)[name] or _G[name]
        if typeof(orig) ~= "function" then return end
        local n = 0
        getgenv()[name] = function(...)
            n += 1
            if n % every == 0 then task.wait() end
            return orig(...)
        end
    end
    throttle("getcustomasset", 15)
    throttle("writefile", 15)
    throttle("readfile", 40)

    task.spawn(function()
        loadstring(fetch("Main.lua"), "SigmaSpyMain")()
    end)
end)
