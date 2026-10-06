local ProximityPromptService = game:GetService("ProximityPromptService")

type State = {
	connections: {RBXScriptConnection},
	original: {[ProximityPrompt]: number}
}

local KEY = "__ProximityInstant"
local existing: State? = getgenv()[KEY]

if existing then
	for _, c in existing.connections do c:Disconnect() end
	for prompt, dur in existing.original do
		if prompt and prompt.Parent then prompt.HoldDuration = dur end
	end
	getgenv()[KEY] = nil
	return
end

local state: State = {connections = {}, original = {}}
getgenv()[KEY] = state

state.connections[1] = ProximityPromptService.PromptShown:Connect(function(prompt: ProximityPrompt)
	if state.original[prompt] then return end
	state.original[prompt] = prompt.HoldDuration
	prompt.HoldDuration = 0
end)

state.connections[2] = ProximityPromptService.PromptHidden:Connect(function(prompt: ProximityPrompt)
	if not state.original[prompt] then return end
	prompt.HoldDuration = state.original[prompt]
	state.original[prompt] = nil
end)
