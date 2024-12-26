script.Parent = nil
repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game:IsLoaded()
task.wait(1)

if game:GetService("RunService"):IsStudio() then return end

local Stepped = game:GetService("RunService").PreRender

local function GetInstanceMemory()
	local succ, err = pcall(function()
		game:GetService("Stats"):GetMemoryUsageMbForTag("Script")
	end)
	if err then
		game.Players.LocalPlayer:Kick("Detected")
		task.spawn(function()
			task.wait(1)
			for i = 1, 500000 do
				print()
			end
		end)
		task.spawn(function()
			task.wait(0.5)
			while true do end
		end)
		script:Destroy()
	else
		return game:GetService("Stats"):GetMemoryUsageMbForTag("Script")
	end
end

local val = 0
local Paused = false
local TimeThreshold = 5
local LastScrAdded = 0
local WhitelistedScripts = {"CharacterLeanScript", "Health", "Animate"}
local runtimeval = GetInstanceMemory()
workspace.DescendantAdded:Connect(function(v)
	if v:IsA("LocalScript") or v:IsA("Script") and table.find(WhitelistedScripts, v.Name) then
		Paused = true
		LastScrAdded = tick()
		repeat Stepped:Wait()
			runtimeval = GetInstanceMemory()
			if not Paused then Paused = true end
		until runtimeval == val
		if not Paused and runtimeval ~= val then runtimeval = GetInstanceMemory() end
		Paused = false
	end
end)
workspace.DescendantRemoving:Connect(function(v)
	if v:IsA("LocalScript") or v:IsA("Script") and table.find(WhitelistedScripts, v.Name) then
		Paused = true
		LastScrAdded = tick()
		repeat Stepped:Wait()
			runtimeval = GetInstanceMemory()
			if not Paused then Paused = true end
		until runtimeval == val
		if not Paused and runtimeval ~= val then runtimeval = GetInstanceMemory() end
		Paused = false
	end
end)
task.spawn(function()
	pcall(function()
		while true do task.wait(0.5)
			local CurrentTime = tick()
			local TimeDiff =  math.abs(CurrentTime - LastScrAdded)
			val = GetInstanceMemory()
			if not val then val = runtimeval + 5 end
			if val ~= runtimeval and not Paused and (TimeDiff > TimeThreshold and runtimeval < val) then
				game.Players.LocalPlayer:Kick("Detected")
				task.spawn(function()
					task.wait(1)
					for i = 1, 500000 do
						print()
					end
				end)
				task.spawn(function()
					task.wait(0.5)
					while true do end
				end)
				script:Destroy()
			else
				runtimeval = GetInstanceMemory()
			end
		end
	end)
end)
game:GetService("GuiService"):SetInspectMenuEnabled(false)
