--[[
	IsHooked
	Detects whether one or more functions have been hooked.

	BEHAVIOR
	  On first call with a function, a snapshot is taken automatically.
	  Subsequent calls compare against that baseline.
	  If a function was already hooked before IsHooked was first called,
	  it cannot be detected — call IsHooked early, before any hooks are installed.

	SIGNATURES
	  IsHooked(fn: Function) -> boolean
	  IsHooked(fn1, fn2, ...) -> boolean
	  IsHooked("checkall")   -> string

	RETURNS
	  boolean  true if any of the provided functions are hooked, false otherwise
	  string   "checkall" mode: newline-separated list of hooked function names,
	           or "none" if nothing is hooked

	EXAMPLES
	  -- single
	  print(IsHooked(print))
	  --> false

	  -- multiple, true if any are hooked
	  print(IsHooked(print, warn, error))
	  --> false

	  -- checkall, lists every hooked function seen so far
	  print(IsHooked("checkall"))
	  --> none

	  -- after a hook is installed
	  local a; a = hookfunction(isfunctionhooked, newcclosure(function(...) return false end))

	  print(IsHooked(isfunctionhooked))
	  --> true

	  print(IsHooked("checkall"))
	  --> isfunctionhooked

	  -- multiple hooked
	  print(IsHooked("checkall"))
	  --> isfunctionhooked
	  --> hookfunction
]]

type Function = (...any) -> ...any

type Snapshot = {
	hash: string?,
	iscc: boolean,
	islc: boolean,
	isnewcc: boolean,
	source: string?,
}

local Snapshots: { [Function]: Snapshot } = {}

local function TakeSnapshot(fn: Function)
	if Snapshots[fn] then return end
	local ok, hash = pcall(getfunctionhash, fn)
	Snapshots[fn] = {
		hash = ok and hash or nil,
		iscc = iscclosure(fn),
		islc = islclosure(fn),
		isnewcc = isnewcclosure(fn),
		source = debug.info(fn, "s"),
	}
end

local function CheckOne(fn: Function): boolean
	TakeSnapshot(fn)

	if isnewcclosure(fn) then return true end

	if islclosure(fn) then
		local source = debug.info(fn, "s")
		if source == "[C]" or source == "" or source == nil then
			return true
		end
	end

	local snap = Snapshots[fn]
	if iscclosure(fn) ~= snap.iscc then return true end
	if islclosure(fn) ~= snap.islc then return true end
	if isnewcclosure(fn) ~= snap.isnewcc then return true end

	if snap.hash then
		local ok, h = pcall(getfunctionhash, fn)
		if ok and h ~= snap.hash then return true end
	end

	return false
end

local function IsHooked(...: any): boolean | string
	local args = { ... }
	if args[1] == "checkall" then
		local hooked = {}
		local env = getgenv()
		for name, val in env do
			if type(val) == "function" and type(name) == "string" then
				if CheckOne(val) then
					hooked[#hooked + 1] = name
				end
			end
		end
		table.sort(hooked)
		return if #hooked == 0 then "none" else table.concat(hooked, "\n")
	end
	for _, fn in args do
		if CheckOne(fn :: Function) then return true end
	end
	return false
end

print(IsHooked("checkall"))
