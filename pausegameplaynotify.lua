--[[
true  = enabled
false = disabled
--]]

local GuiService = game:GetService("GuiService")

GuiService:SetGameplayPausedNotificationEnabled(not GuiService:GetGameplayPausedNotificationEnabled())
