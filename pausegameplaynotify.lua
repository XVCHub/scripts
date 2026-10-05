--[[
usage:
default: loadstring(game:HttpGet("https://raw.githubusercontent.com/XVCHub/scripts/main/pausegameplaynotify.lua"))()
enable: loadstring(game:HttpGet("https://raw.githubusercontent.com/XVCHub/scripts/main/pausegameplaynotify.lua"))(true)
disable: loadstring(game:HttpGet("https://raw.githubusercontent.com/XVCHub/scripts/main/pausegameplaynotify.lua"))(false)

just change the () value to true or false
--]]

local GuiService = game:GetService("GuiService")

return function(enabled: boolean?)
	if enabled == nil then
		enabled = not GuiService:GetGameplayPausedNotificationEnabled()
	end
	GuiService:SetGameplayPausedNotificationEnabled(enabled)
end
