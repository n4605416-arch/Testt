-- =====================================================
-- RAGALIC CLIENT • FULL MOBILE EDITION
-- =====================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Camera = Workspace.CurrentCamera
local PS = Players
local RS = ReplicatedStorage
local R = RunService
local CE = RS:WaitForChild("CharacterEvents", 10)

-- =====================================================
-- LOAD LIBRARY
-- =====================================================
loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles
Library.ForceCheckbox = false

-- =====================================================
-- WINDOW
-- =====================================================
local Window = Library:CreateWindow({
	Title = "Ragalic Mobile",
	Footer = "Ragalic Mobile",
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local Tabs = {
	Defense = Window:AddTab("defense", "shield"),
	Target = Window:AddTab("target", "crosshair"),
	Grab = Window:AddTab("grab", "hand"),
	Player = Window:AddTab("player", "user"),
	Misc = Window:AddTab("misc", "layers"),
	Build = Window:AddTab("build", "box"),
	Fun = Window:AddTab("fun", "smile"),
	Keybinds = Window:AddTab("keybinds", "keyboard"),
	Notifications = Window:AddTab("notifications", "bell"),
	Auras = Window:AddTab("auras", "sparkles"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings")
}

-- =====================================================
-- MOBILE CONTROLS (FULL TOUCH)
-- =====================================================
local Mobile = {
	Joystick = nil,
	TouchStart = false,
	TouchPos = Vector2.new(0, 0),
	MoveDir = Vector3.new(0, 0, 0),
	Buttons = {},
	JumpPressed = false,
	SitPressed = false,
	ResetPressed = false,
	TPPressed = false,
}

-- Создание джойстика
local function CreateJoystick()
	local size = 120
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, size, 0, size)
	frame.Position = UDim2.new(0.08, 0, 0.78, 0)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frame.BackgroundTransparency = 0.5
	frame.BorderSizePixel = 0
	frame.Parent = CoreGui
	frame.ZIndex = 999
	
	local inner = Instance.new("Frame")
	inner.Size = UDim2.new(0, 50, 0, 50)
	inner.Position = UDim2.new(0.5, -25, 0.5, -25)
	inner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	inner.BackgroundTransparency = 0.4
	inner.BorderSizePixel = 0
	inner.Parent = frame
	
	local function onTouchBegan(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			local pos = input.Position
			local fPos = frame.AbsolutePosition
			local center = fPos + Vector2.new(size/2, size/2)
			if (pos - center).Magnitude < size then
				Mobile.TouchStart = true
				Mobile.TouchPos = pos
			end
		end
	end
	
	local function onTouchMoved(input)
		if input.UserInputType == Enum.UserInputType.Touch and Mobile.TouchStart then
			local pos = input.Position
			local fPos = frame.AbsolutePosition
			local center = fPos + Vector2.new(size/2, size/2)
			local delta = pos - center
			local maxD = size/2 - 15
			local clamped = delta.Magnitude > maxD and delta.Unit * maxD or delta
			inner.Position = UDim2.new(0.5, clamped.X, 0.5, clamped.Y)
			
			local norm = delta.Magnitude > 0 and delta / maxD or Vector2.new(0, 0)
			Mobile.MoveDir = Vector3.new(norm.X, 0, -norm.Y)
		end
	end
	
	local function onTouchEnded(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			Mobile.TouchStart = false
			inner.Position = UDim2.new(0.5, -25, 0.5, -25)
			Mobile.MoveDir = Vector3.new(0, 0, 0)
		end
	end
	
	UserInputService.InputBegan:Connect(onTouchBegan)
	UserInputService.InputChanged:Connect(onTouchMoved)
	UserInputService.InputEnded:Connect(onTouchEnded)
	return frame
end

-- Создание кнопок
local function CreateButtons()
	local btns = {}
	local yOffset = 0.5
	
	local function addBtn(name, icon, yPos, color, callback)
		local btn = Instance.new("ImageButton")
		btn.Size = UDim2.new(0, 65, 0, 65)
		btn.Position = UDim2.new(0.82, 0, yPos, 0)
		btn.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
		btn.BackgroundTransparency = 0.4
		btn.Image = icon
		btn.Parent = CoreGui
		btn.ZIndex = 999
		btn.MouseButton1Click:Connect(callback)
		btns[name] = btn
		return btn
	end
	
	addBtn("Jump", "rbxassetid://1297645249", 0.78, Color3.fromRGB(0, 200, 255), function()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end)
	
	addBtn("Sit", "rbxassetid://1297645336", 0.68, Color3.fromRGB(100, 200, 100), function()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.Sit = not hum.Sit end
	end)
	
	addBtn("Reset", "rbxassetid://1297645513", 0.58, Color3.fromRGB(255, 100, 100), function()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.Health = 0 end
	end)
	
	addBtn("TP", "rbxassetid://1297645697", 0.48, Color3.fromRGB(255, 200, 0), function()
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local pos = Camera.CFrame.Position + Camera.CFrame.LookVector * 15
			hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
		end
	end)
	
	return btns
end

-- Движение через джойстик
local function MobileMovement()
	task.spawn(function()
		while true do
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root and Mobile.MoveDir.Magnitude > 0.1 then
				local cam = Camera.CFrame
				local fwd = cam.LookVector * Vector3.new(1, 0, 1)
				local right = cam.RightVector * Vector3.new(1, 0, 1)
				local move = (fwd * Mobile.MoveDir.Z + right * Mobile.MoveDir.X)
				if move.Magnitude > 1 then move = move.Unit end
				root.CFrame = root.CFrame + move * 0.8
				root.AssemblyLinearVelocity = Vector3.zero
			end
			task.wait(0.03)
		end
	end)
end

-- Запуск мобильных элементов
task.spawn(function()
	CreateJoystick()
	Mobile.Buttons = CreateButtons()
	MobileMovement()
end)

-- =====================================================
-- ВСЯ ФУНКЦИОНАЛЬНОСТЬ ИЗ ОРИГИНАЛА (АДАПТИРОВАНА)
-- =====================================================

-- Утилиты
local function notify(title, content, duration)
	Library:Notify({ Title = title or "Notification", Description = content or "", Time = duration or 5 })
end

local function getPlayerFromSelection(selection)
	if not selection then return nil end
	local username = selection:match("%((.-)%)")
	if username then return PS:FindFirstChild(username) end
	return nil
end

local function getPlayerList()
	local list = {}
	for _, plr in ipairs(PS:GetPlayers()) do
		if plr ~= LocalPlayer then
			table.insert(list, plr.DisplayName .. " (" .. plr.Name .. ")")
		end
	end
	return list
end

-- =====================================================
-- DEFENSE TAB
-- =====================================================
local DefenseGroup = Tabs.Defense:AddLeftGroupbox("Defense Main")
local DefenseExtra = Tabs.Defense:AddRightGroupbox("Extra Defense")

-- Anti Grab (адаптирован)
local autoStruggleConn = nil
DefenseGroup:AddToggle("AntiGrabObsidian", {
	Text = "Anti Grab",
	Default = false,
	Callback = function(Value)
		if Value then
			if autoStruggleConn then autoStruggleConn:Disconnect() end
			autoStruggleConn = R.Heartbeat:Connect(function()
				local char = LocalPlayer.Character
				if char and char:FindFirstChild("Head") and char.Head:FindFirstChild("PartOwner") then
					task.spawn(function()
						local Struggle = RS.CharacterEvents and RS.CharacterEvents:FindFirstChild("Struggle")
						if Struggle then Struggle:FireServer(LocalPlayer) end
						pcall(function() RS.GameCorrectionEvents.StopAllVelocity:FireServer() end)
						for _, part in pairs(char:GetChildren()) do
							if part:IsA("BasePart") then part.Anchored = true end
						end
						local isHeld = LocalPlayer:FindFirstChild("IsHeld")
						while isHeld and isHeld.Value do task.wait() end
						for _, part in pairs(char:GetChildren()) do
							if part:IsA("BasePart") then part.Anchored = false end
						end
					end)
				end
			end)
		else
			if autoStruggleConn then autoStruggleConn:Disconnect() end
		end
	end
})

-- Anti Blobman
local antiBlob1T = false
DefenseGroup:AddToggle("AntiBlobmanToggle", {
	Text = "Anti Blobman",
	Default = false,
	Callback = function(on)
		antiBlob1T = on
		if on then
			workspace.DescendantAdded:Connect(function(toy)
				if toy.Name == "CreatureBlobman" and antiBlob1T then
					pcall(function()
						toy.LeftDetector:Destroy()
						toy.RightDetector:Destroy()
					end)
				end
			end)
		end
	end
})

-- Anti Explosion
local antiExplodeT = false
DefenseGroup:AddToggle("AntiExplosionToggle", {
	Text = "Anti Explosion",
	Default = false,
	Callback = function(on)
		antiExplodeT = on
		if on then
			task.spawn(function()
				local char = LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if not hrp then return end
				workspace.ChildAdded:Connect(function(model)
					if model.Name == "Part" and antiExplodeT then
						local mag = (model.Position - hrp.Position).Magnitude
						if mag <= 20 then
							hrp.Anchored = true
							task.wait(0.01)
							local rightArm = char:FindFirstChild("Right Arm")
							local ragdoll = rightArm and rightArm:FindFirstChild("RagdollLimbPart")
							while ragdoll and ragdoll.CanCollide do task.wait(0.001) end
							hrp.Anchored = false
						end
					end
				end)
			end)
		end
	end
})

-- Anti Burn
local hookBurnConn
DefenseGroup:AddToggle("AntiBurnToggle", {
	Text = "Anti Burn",
	Default = false,
	Callback = function(on)
		if on then
			local char = LocalPlayer.Character
			local hum = char:WaitForChild("Humanoid")
			local hrp = char:WaitForChild("HumanoidRootPart")
			char.PrimaryPart = hrp
			if hookBurnConn then hookBurnConn:Disconnect() end
			hookBurnConn = hum.FireDebounce.Changed:Connect(function(isBurning)
				if isBurning then
					local oldCF = hrp.CFrame
					local plots = workspace:FindFirstChild("Plots")
					if plots and plots:FindFirstChild("Plot2") then
						local pb = plots.Plot2.Barrier and plots.Plot2.Barrier:FindFirstChild("PlotBarrier")
						if pb and pb:IsA("BasePart") then
							char:SetPrimaryPartCFrame(pb.CFrame * CFrame.new(0, 6, 0))
							task.wait(0.3)
							local firePart = char:FindFirstChild("FirePlayerPart", true)
							if firePart then
								for _, obj in pairs(firePart:GetChildren()) do
									if obj:IsA("Sound") then obj:Stop() end
									if obj:IsA("Light") or obj:IsA("ParticleEmitter") then obj.Enabled = false end
								end
								if firePart:FindFirstChild("CanBurn") then firePart.CanBurn.Value = false end
								if hum:FindFirstChild("FireDebounce") then hum.FireDebounce.Value = false end
							end
							task.wait(0.6)
							if char and char.PrimaryPart then char:SetPrimaryPartCFrame(oldCF) end
						end
					end
				end
			end)
		elseif hookBurnConn then hookBurnConn:Disconnect() end
	end
})

-- Anti Void
local antiVoidConn
DefenseGroup:AddToggle("AntiVoidToggle", {
	Text = "Anti Void",
	Default = false,
	Callback = function(on)
		if on then
			if antiVoidConn then antiVoidConn:Disconnect() end
			antiVoidConn = R.Heartbeat:Connect(function()
				local char = LocalPlayer.Character
				if char and char.PrimaryPart then
					local pos = char.PrimaryPart.Position
					if pos.Y < -50 then
						char:SetPrimaryPartCFrame(CFrame.new(pos.X, pos.Y + 100, pos.Z))
						char.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
					end
				end
			end)
		else
			if antiVoidConn then antiVoidConn:Disconnect() end
		end
	end
})

-- Anti Sticky
DefenseGroup:AddToggle("AntiStickyToggle", {
	Text = "Anti Sticky",
	Default = false,
	Callback = function(Value)
		local sticky = LocalPlayer.PlayerScripts:FindFirstChild("StickyPartsTouchDetection")
		if sticky then sticky.Disabled = Value end
	end
})

-- Anti Paint
local paintPartsBackup = {}
local paintConnections = {}
DefenseExtra:AddToggle("PaintDeleteToggle", {
	Text = "Anti Paint",
	Default = false,
	Callback = function(state)
		if state then
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if obj:IsA("BasePart") and obj.Name == "PaintPlayerPart" then
					paintPartsBackup[obj] = obj:Clone()
					obj:Destroy()
				end
			end
			Workspace.DescendantAdded:Connect(function(obj)
				if obj:IsA("BasePart") and obj.Name == "PaintPlayerPart" then
					task.defer(function()
						paintPartsBackup[obj] = obj:Clone()
						obj:Destroy()
					end)
				end
			end)
		else
			for _, obj in pairs(paintPartsBackup) do
				if obj and obj.Parent == nil then obj.Parent = Workspace end
			end
			paintPartsBackup = {}
		end
	end
})

-- Anti Gucci (Blobman)
local autoGucciActive = false
local antiGucciConnection
local safePosition
local restoreFrames = 0

local function spawnBlobman()
	pcall(function()
		RS.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", CFrame.new(0, 5000000, 0), Vector3.new(0, 60, 0))
	end)
end

local function startAntiGucci()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	safePosition = root.Position
	
	local folder = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
	local blob = folder and folder:FindFirstChild("CreatureBlobman")
	local seat = blob and blob:FindFirstChild("VehicleSeat")
	
	if not blob then
		spawnBlobman()
		task.wait(1)
		folder = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
		blob = folder and folder:FindFirstChild("CreatureBlobman")
		seat = blob and blob:FindFirstChild("VehicleSeat")
	end
	
	if seat and seat:IsA("VehicleSeat") then
		root.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
		seat:Sit(hum)
	end
	
	if antiGucciConnection then antiGucciConnection:Disconnect() end
	antiGucciConnection = R.Heartbeat:Connect(function()
		if not root or not hum then return end
		RS.CharacterEvents.RagdollRemote:FireServer(root, 0)
		if restoreFrames > 0 then
			root.CFrame = CFrame.new(safePosition)
			restoreFrames = restoreFrames - 1
		end
	end)
end

DefenseExtra:AddToggle("AutoGucciToggle", {
	Text = "Anti Gucci (Blobman)",
	Default = false,
	Callback = function(Value)
		autoGucciActive = Value
		if Value then
			startAntiGucci()
			task.spawn(function()
				while autoGucciActive do
					local folder = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
					local blob = folder and folder:FindFirstChild("CreatureBlobman")
					if not blob then
						spawnBlobman()
						task.wait(1)
					end
					task.wait(0.5)
				end
			end)
		else
			if antiGucciConnection then antiGucciConnection:Disconnect() end
		end
	end
})

-- =====================================================
-- TARGET TAB
-- =====================================================
local TargetGroup = Tabs.Target:AddLeftGroupbox("Target Interaction")
local BlobGroup = Tabs.Target:AddRightGroupbox("Blobman Kick")

local selectedKickPlayer = nil
local kickLoopEnabled = false

TargetGroup:AddDropdown("KickPlayerDropdown", {
	Values = getPlayerList(),
	Default = 1,
	Multi = false,
	Text = "Select Target",
	Callback = function(Value)
		selectedKickPlayer = getPlayerFromSelection(Value)
	end
})

TargetGroup:AddButton({
	Text = "Refresh List",
	Func = function()
		Options.KickPlayerDropdown:SetValues(getPlayerList())
	end
})

-- Loop Kick (спам граб)
TargetGroup:AddToggle("LoopKickGrabToggle", {
	Text = "Kick (spam grab)",
	Default = false,
	Callback = function(on)
		kickLoopEnabled = on
		if not on then return end
		task.spawn(function()
			local GE = RS:WaitForChild("GrabEvents")
			local myChar = LocalPlayer.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
			if not myRoot then Toggles.LoopKickGrabToggle:SetValue(false) return end
			local savedPos = myRoot.CFrame
			local dragging = false
			local grabStart = 0
			
			while kickLoopEnabled do
				local target = selectedKickPlayer
				if not target or not target.Parent then break end
				
				myChar = LocalPlayer.Character
				myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
				if not myRoot then break end
				
				local tChar = target.Character
				local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
				local tHum = tChar and tChar:FindFirstChild("Humanoid")
				
				if tRoot and tHum and tHum.Health > 0 then
					tRoot.AssemblyLinearVelocity = Vector3.zero
					tRoot.AssemblyAngularVelocity = Vector3.zero
					
					if not dragging then
						myRoot.CFrame = tRoot.CFrame
						pcall(function()
							tHum.PlatformStand = true
							tHum.Sit = true
							GE.SetNetworkOwner:FireServer(tRoot, myRoot.CFrame)
							GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
						end)
						if grabStart == 0 then grabStart = tick() end
						if tick() - grabStart > 0.35 then
							dragging = true
							grabStart = 0
						end
					else
						myRoot.CFrame = savedPos
						local lockPos = savedPos * CFrame.new(0, 17, 0)
						tRoot.CFrame = lockPos
						tRoot.Velocity = Vector3.zero
						pcall(function()
							tHum.PlatformStand = true
							GE.SetNetworkOwner:FireServer(tRoot, lockPos)
							GE.DestroyGrabLine:FireServer(tRoot)
							GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
						end)
					end
				else
					dragging = false
					grabStart = 0
				end
				R.Heartbeat:Wait()
			end
			if myRoot then myRoot.CFrame = savedPos end
			kickLoopEnabled = false
			Toggles.LoopKickGrabToggle:SetValue(false)
		end)
	end
})

-- Fling
local playerFlingActive = false
TargetGroup:AddToggle("PlayerFlingBtn", {
	Text = "Fling",
	Default = false,
	Callback = function(on)
		playerFlingActive = on
		if on and selectedKickPlayer then
			task.spawn(function()
				while playerFlingActive do
					local target = selectedKickPlayer
					local char = LocalPlayer.Character
					local hrp = char and char:FindFirstChild("HumanoidRootPart")
					if not hrp then task.wait(0.5) continue end
					
					local tChar = target and target.Character
					local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
					local tHum = tChar and tChar:FindFirstChild("Humanoid")
					
					if tRoot and tHum and tHum.Health > 0 then
						local bav = Instance.new("BodyAngularVelocity", hrp)
						bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
						bav.AngularVelocity = Vector3.new(0, 10000, 0)
						
						for _, part in pairs(char:GetDescendants()) do
							if part:IsA("BasePart") then part.CanCollide = false end
						end
						
						local start = tick()
						while tick() - start < 1.5 and playerFlingActive do
							hrp.CFrame = tRoot.CFrame
							hrp.Velocity = Vector3.zero
							task.wait(0.05)
						end
						bav:Destroy()
						for _, part in pairs(char:GetDescendants()) do
							if part:IsA("BasePart") then part.CanCollide = true end
						end
					end
					task.wait(0.1)
				end
			end)
		end
	end
})

-- =====================================================
-- GRAB TAB
-- =====================================================
local GrabGroup = Tabs.Grab:AddLeftGroupbox("Grab Customization")

_G.strength = 750
GrabGroup:AddSlider("ThrowPowerSlider", {
	Text = "Power",
	Default = 750,
	Min = 1,
	Max = 20000,
	Rounding = 0,
	Callback = function(value) _G.strength = value end
})

local strengthConnection
GrabGroup:AddToggle("ThrowStrengthToggle", {
	Text = "Strength",
	Default = false,
	Callback = function(enabled)
		if enabled then
			strengthConnection = workspace.ChildAdded:Connect(function(model)
				if model.Name == "GrabParts" then
					local part = model.GrabPart.WeldConstraint.Part1
					if part then
						local bv = Instance.new("BodyVelocity", part)
						model:GetPropertyChangedSignal("Parent"):Connect(function()
							if not model.Parent then
								bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
								bv.Velocity = Camera.CFrame.LookVector * _G.strength
								game:GetService("Debris"):AddItem(bv, 1)
							end
						end)
					end
				end
			end)
		elseif strengthConnection then
			strengthConnection:Disconnect()
		end
	end
})

-- Kill Grab
local killGrabEnabled = false
GrabGroup:AddToggle("KillGrabToggle", {
	Text = "Kill Grab",
	Default = false,
	Callback = function(Value)
		killGrabEnabled = Value
		if Value then
			workspace.ChildAdded:Connect(function(v)
				if v:IsA("Model") and v.Name == "GrabParts" then
					task.wait(0.05)
					local gp = v:FindFirstChild("GrabPart")
					if gp and gp:FindFirstChild("WeldConstraint") then
						local p1 = gp.WeldConstraint.Part1
						if p1 and p1.Parent and p1.Parent ~= LocalPlayer.Character then
							local hum = p1.Parent:FindFirstChildOfClass("Humanoid")
							if hum then hum.Health = 0 end
						end
					end
				end
			end)
		end
	end
})

-- MassLess Grab
GrabGroup:AddToggle("MassLessGrabToggle", {
	Text = "MassLess Grab",
	Default = false,
	Callback = function(Value)
		_G.MassLessGrab = Value
		if Value then
			_G.MLConn = R.Heartbeat:Connect(function()
				local gp = workspace:FindFirstChild("GrabParts")
				if not gp then return end
				local dp = gp:FindFirstChild("DragPart")
				if not dp then return end
				local ap = dp:FindFirstChild("AlignPosition")
				local ao = dp:FindFirstChild("AlignOrientation")
				if ap then
					ap.Responsiveness = 200
					ap.MaxForce = math.huge
				end
				if ao then
					ao.Responsiveness = 200
					ao.MaxTorque = math.huge
				end
			end)
		elseif _G.MLConn then
			_G.MLConn:Disconnect()
		end
	end
})

-- =====================================================
-- PLAYER TAB
-- =====================================================
local PlayerView = Tabs.Player:AddLeftGroupbox("View & Movement")
local PlayerESP = Tabs.Player:AddRightGroupbox("ESP")

-- Third Person
PlayerView:AddToggle("ThirdPersonToggle", {
	Text = "3rd Person View",
	Default = false,
	Callback = function(Value)
		if Value then
			LocalPlayer.CameraMode = Enum.CameraMode.Classic
			Camera.CameraType = Enum.CameraType.Custom
			LocalPlayer.CameraMaxZoomDistance = 999999
		else
			LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
			LocalPlayer.CameraMaxZoomDistance = 0
		end
	end
})

-- Spin
local spinningConnection
local spinSpeed = 5
PlayerView:AddToggle("SpinToggle", {
	Text = "Spin Character",
	Default = false,
	Callback = function(Value)
		if Value then
			spinningConnection = R.Heartbeat:Connect(function()
				local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0) end
			end)
		elseif spinningConnection then
			spinningConnection:Disconnect()
		end
	end
})

PlayerView:AddSlider("SpinSpeed", {
	Text = "Spin Speed",
	Default = 5,
	Min = 1,
	Max = 50,
	Rounding = 0,
	Callback = function(Value) spinSpeed = Value end
})

-- Infinite Jump
local infJump = false
PlayerView:AddToggle("infJumpToggle", {
	Text = "Infinite Jump",
	Default = false,
	Callback = function(Value) infJump = Value end
})
UserInputService.JumpRequest:Connect(function()
	if infJump then
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

-- ESP
local espEnabled = false
PlayerESP:AddToggle("BoxESPWhite", {
	Text = "PCLD View",
	Default = false,
	Callback = function(Value)
		espEnabled = Value
		if Value then
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if obj:IsA("BasePart") and (string.lower(obj.Name) == "partesp" or string.lower(obj.Name) == "playercharacterlocationdetector") then
					local box = Instance.new("BoxHandleAdornment")
					box.Adornee = obj
					box.AlwaysOnTop = true
					box.Color3 = Color3.fromRGB(255, 255, 255)
					box.Transparency = 0.5
					box.Size = obj.Size
					box.Parent = CoreGui
				end
			end
		else
			for _, v in pairs(CoreGui:GetChildren()) do
				if v:IsA("BoxHandleAdornment") then v:Destroy() end
			end
		end
	end
})

-- Nickname ESP
PlayerESP:AddToggle("NicknameESP", {
	Text = "Nickname Esp",
	Default = false,
	Callback = function(Value)
		if Value then
			for _, plr in pairs(PS:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
					local hrp = plr.Character.HumanoidRootPart
					if not hrp:FindFirstChild("NameESP") then
						local bg = Instance.new("BillboardGui", hrp)
						bg.Name = "NameESP"
						bg.Adornee = hrp
						bg.Size = UDim2.new(0, 100, 0, 30)
						bg.StudsOffset = Vector3.new(0, 3, 0)
						bg.AlwaysOnTop = true
						local tl = Instance.new("TextLabel", bg)
						tl.Size = UDim2.new(1, 0, 1, 0)
						tl.BackgroundTransparency = 1
						tl.Text = plr.Name
						tl.TextColor3 = Color3.fromRGB(255, 255, 255)
						tl.TextScaled = true
					end
				end
			end
		else
			for _, plr in pairs(PS:GetPlayers()) do
				if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
					local hrp = plr.Character.HumanoidRootPart
					if hrp:FindFirstChild("NameESP") then hrp.NameESP:Destroy() end
				end
			end
		end
	end
})

-- =====================================================
-- MISC TAB
-- =====================================================
local MiscGroup = Tabs.Misc:AddLeftGroupbox("Miscellaneous")

-- FOV
MiscGroup:AddSlider("FOVSlider", {
	Text = "FOV",
	Default = 90,
	Min = 1,
	Max = 120,
	Rounding = 0,
	Suffix = "°",
	Callback = function(value) Camera.FieldOfView = value end
})

-- Trigger Bot
local Triggerbot = {
	Enabled = false,
	Connection = nil,
	canGrab = true,
	maxDistance = 20,
	lastTarget = nil,
	lastHitTime = 0
}

function Triggerbot:GetTarget()
	local c = LocalPlayer.Character
	if not c or not c:FindFirstChild("HumanoidRootPart") then return end
	local origin, dir = Camera.CFrame.Position, Camera.CFrame.LookVector
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {c, Workspace.Terrain}
	
	local result = Workspace:Raycast(origin, dir * 1000, params)
	if not result then return end
	
	local model = result.Instance:FindFirstAncestorOfClass("Model")
	if not model or model == c then return end
	
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end
	
	local root = model:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	local dist = (c.HumanoidRootPart.Position - root.Position).Magnitude
	if dist > self.maxDistance then return end
	
	return model
end

function Triggerbot:OnHeartbeat()
	if not self.Enabled or not self.canGrab then return end
	local t = self:GetTarget()
	if t then self.lastTarget = t end
	if not self.lastTarget then return end
	
	local c = LocalPlayer.Character
	local root = self.lastTarget:FindFirstChild("HumanoidRootPart")
	if not c or not root then return end
	
	if (c.HumanoidRootPart.Position - root.Position).Magnitude > self.maxDistance then
		self.lastTarget = nil
		return
	end
	
	self.canGrab = false
	task.spawn(function()
		task.wait(0.00001)
		-- Мобильный клик (эмуляция)
		local screen = Camera.ViewportSize
		local center = screen / 2
		UserInputService.InputBegan:Fire({
			Position = center,
			UserInputType = Enum.UserInputType.Touch
		})
		task.wait(0.05)
		UserInputService.InputEnded:Fire({
			Position = center,
			UserInputType = Enum.UserInputType.Touch
		})
		task.wait(0.05)
		self.canGrab = true
		self.lastTarget = nil
	end)
end

MiscGroup:AddToggle("TriggerbotToggle", {
	Text = "Trigger Bot",
	Default = false,
	Callback = function(value)
		Triggerbot.Enabled = value
		if value and not Triggerbot.Connection then
			Triggerbot.Connection = R.Heartbeat:Connect(function() Triggerbot:OnHeartbeat() end)
		elseif not value and Triggerbot.Connection then
			Triggerbot.Connection:Disconnect()
			Triggerbot.Connection = nil
		end
	end
})

-- =====================================================
-- FUN TAB
-- =====================================================
local FanGroup = Tabs.Fun:AddLeftGroupbox("Troll")

-- Jerk Off (анимация)
local jerkOffActive = false
local jerkOffTrack = nil
FanGroup:AddToggle("JerkOffToggle", {
	Text = "Jerk Off",
	Default = false,
	Callback = function(on)
		jerkOffActive = on
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hum then return end
		local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
		
		if on then
			local anim = Instance.new("Animation")
			anim.AnimationId = "rbxassetid://168268306"
			jerkOffTrack = animator:LoadAnimation(anim)
			jerkOffTrack.Priority = Enum.AnimationPriority.Action
			jerkOffTrack:Play()
		elseif jerkOffTrack then
			jerkOffTrack:Stop()
			jerkOffTrack = nil
		end
	end
})

-- Fake Death
FanGroup:AddToggle("FakeDeathToggle", {
	Text = "Fake Death",
	Default = false,
	Callback = function(on)
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if not hum then return end
		if on then
			hum:ChangeState(Enum.HumanoidStateType.Physics)
			hum.PlatformStand = true
		else
			hum.PlatformStand = false
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end
})

-- Bang (анимация)
local bangActive = false
local bangTrack = nil
FanGroup:AddToggle("BangToggle", {
	Text = "Bang (Slow)",
	Default = false,
	Callback = function(on)
		bangActive = on
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hum then return end
		local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
		
		if on then
			local anim = Instance.new("Animation")
			anim.AnimationId = "rbxassetid://148840371"
			bangTrack = animator:LoadAnimation(anim)
			bangTrack.Priority = Enum.AnimationPriority.Action
			bangTrack:Play()
			bangTrack:AdjustSpeed(0.3)
		elseif bangTrack then
			bangTrack:Stop()
			bangTrack = nil
		end
	end
})

-- Follow & Stare
local followActive = false
FanGroup:AddToggle("FollowStare", {
	Text = "Follow & Stare",
	Default = false,
	Callback = function(on)
		followActive = on
		if on then
			task.spawn(function()
				while followActive do
					local target = PS:GetPlayers()[math.random(#PS:GetPlayers())]
					if target ~= LocalPlayer and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
						local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
						local thrp = target.Character.HumanoidRootPart
						if hrp and thrp then
							hrp.CFrame = CFrame.new(thrp.Position + thrp.CFrame.LookVector * -2, thrp.Position)
						end
					end
					task.wait(0.3)
				end
			end)
		end
	end
})

-- =====================================================
-- BUILD TAB
-- =====================================================
local BuildGroup = Tabs.Build:AddLeftGroupbox("Build")

-- Heart Sparkler
local heartActive = false
local heartConnection = nil
local heartToy = nil
BuildGroup:AddToggle("HeartSparklerBuild", {
	Text = "Heart",
	Default = false,
	Callback = function(on)
		heartActive = on
		if on then
			task.spawn(function()
				local char = LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if not hrp then return end
				
				pcall(function() RS.MenuToys.SpawnToyRemoteFunction:InvokeServer("FireworkSparkler", hrp.CFrame * CFrame.new(0, 50, 0), Vector3.zero) end)
				local folder = workspace:WaitForChild(LocalPlayer.Name .. "SpawnedInToys", 5)
				if not folder then return end
				heartToy = folder:WaitForChild("FireworkSparkler", 5)
				if not heartToy then return end
				
				local part = heartToy:FindFirstChild("Handle") or heartToy:FindFirstChildWhichIsA("BasePart")
				if not part then return end
				
				for _, v in pairs(heartToy:GetDescendants()) do
					if v:IsA("BasePart") then
						v.Anchored = false
						v.CanCollide = false
						v.Massless = true
					end
				end
				part:BreakJoints()
				
				local bp = Instance.new("BodyPosition", part)
				bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				bp.P = 20000
				bp.D = 500
				
				local bg = Instance.new("BodyGyro", part)
				bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
				bg.P = 3000
				
				local t = 0
				heartConnection = R.Heartbeat:Connect(function(dt)
					if not heartActive or not part.Parent then
						heartConnection:Disconnect()
						if heartToy then heartToy:Destroy() end
						return
					end
					local currentHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if not currentHrp then return end
					
					t = t + (8 * dt)
					local scale = 1.5
					local x = 16 * math.sin(t) ^ 3
					local y = 13 * math.cos(t) - 5 * math.cos(2*t) - 2 * math.cos(3*t) - math.cos(4*t)
					local relPos = Vector3.new(x * scale, (y * scale) + 25, 3)
					bp.Position = currentHrp.CFrame:PointToWorldSpace(relPos)
					bg.CFrame = currentHrp.CFrame
				end)
			end)
		else
			if heartConnection then heartConnection:Disconnect() end
			if heartToy then heartToy:Destroy() end
		end
	end
})

-- =====================================================
-- AURAS TAB
-- =====================================================
local AurasGroup = Tabs.Auras:AddLeftGroupbox("Auras")

-- Dual Hand Kick Aura
local dualKickAuraEnabled = false
local dualKickAuraRadius = 20
local dualKickAuraConn = nil

AurasGroup:AddDropdown("DualKickAuraRadius", {
	Text = "Radius",
	Values = {"10", "20", "30", "40", "50"},
	Default = 2,
	Callback = function(v) dualKickAuraRadius = tonumber(v) end
})

AurasGroup:AddToggle("DualHandKickAura", {
	Text = "Dual Hand Kick Aura",
	Default = false,
	Callback = function(on)
		dualKickAuraEnabled = on
		if dualKickAuraConn then dualKickAuraConn:Disconnect() end
		if not on then return end
		
		dualKickAuraConn = R.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local seat = hum and hum.SeatPart
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if not (seat and root) then return end
			
			local blob = seat.Parent
			local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
			local grab = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
			local drop = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
			local leftDet = blob:FindFirstChild("LeftDetector")
			local rightDet = blob:FindFirstChild("RightDetector")
			local leftWeld = leftDet and leftDet:FindFirstChild("LeftWeld")
			local rightWeld = rightDet and rightDet:FindFirstChild("RightWeld")
			
			if not (grab and drop and leftDet and rightDet and leftWeld and rightWeld) then return end
			
			for _, plr in pairs(PS:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character then
					local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
					local tHum = plr.Character:FindFirstChildOfClass("Humanoid")
					if tRoot and tHum and tHum.Health > 0 then
						local dist = (tRoot.Position - root.Position).Magnitude
						if dist <= dualKickAuraRadius then
							pcall(function()
								grab:FireServer(leftDet, tRoot, leftWeld)
								task.wait(0.04)
								drop:FireServer(leftWeld, tRoot)
								grab:FireServer(rightDet, tRoot, rightWeld)
								task.wait(0.04)
								drop:FireServer(rightWeld, tRoot)
							end)
						end
					end
				end
			end
		end)
	end
})

-- =====================================================
-- UI SETTINGS
-- =====================================================
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
MenuGroup:AddButton("Unload", function() Library:Unload() end)
MenuGroup:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
	Default = "RightShift",
	NoUI = true,
	Text = "Menu keybind"
})

Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"MenuKeybind"})
ThemeManager:SetFolder("Ragalic Mobile")
SaveManager:SetFolder("Ragalic Mobile/Configs")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

-- =====================================================
-- FINAL NOTIFY
-- =====================================================
notify("Ragalic Mobile", "Full version loaded!", 3)
print("Ragalic Mobile • Ready")
