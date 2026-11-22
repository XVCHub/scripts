local results = {}

local function bench(name, iterations, fn)
	local start = os.clock()
	for i = 1, iterations do
		fn(i)
	end
	local elapsed = os.clock() - start
	results[#results + 1] = { name = name, iterations = iterations, time = elapsed }
end

-- arithmetic loop
bench("arithmetic loop", 500000, function(i)
	local _ = i * 3.14 + i / 2 - i % 7
end)

-- function calls
local function dummy(a, b) return a + b end
bench("function calls", 400000, function(i)
	dummy(i, i + 1)
end)

-- table create/insert
bench("table create/insert", 600000, function(i)
	local t = {}
	t[1] = i
	t[2] = i * 2
	t[3] = i * 3
end)

-- table iteration
bench("table iteration", 6000, function(i)
	local t = {}
	for j = 1, 100 do t[j] = j * i end
	local sum = 0
	for _, v in t do sum += v end
end)

-- string concat
bench("string concat", 40000, function(i)
	local _ = "hello" .. tostring(i) .. "world" .. tostring(i * 2)
end)

-- closure creation
bench("closure creation", 300000, function(i)
	local _ = function() return i * 2 end
end)

-- metatable index
local mt = { __index = function(_, k) return k end }
bench("metatable index", 200000, function(i)
	local t = setmetatable({}, mt)
	local _ = t[i]
end)

-- build output
local lines = {}
local total = 0

local col1, col2, col3 = 22, 12, 10
lines[#lines + 1] = string.format("%-"..col1.."s %-"..col2.."s %s", "name", "iterations", "time(s)")

for _, r in results do
	total += r.time
	lines[#lines + 1] = string.format(
		"%-"..col1.."s %-"..col2.."d %.4f",
		r.name, r.iterations, r.time
	)
end

lines[#lines + 1] = string.format("%-"..col1.."s %-"..col2.."s %.4f", "total", "", total)

local output = table.concat(lines, "\n")
print(output)
if setclipboard then setclipboard(output) end
