--[[
usage:
enable: loadstring(game:HttpGet("https://raw.githubusercontent.com/XVCHub/scripts/main/pausegameplaynotify.lua"))(true)
disable: loadstring(game:HttpGet("https://raw.githubusercontent.com/XVCHub/scripts/main/pausegameplaynotify.lua"))(false)

just change the () value to true or false
--]]

return function(enabled: boolean)
	game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(enabled)
end
