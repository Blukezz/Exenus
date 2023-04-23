--[[

    EDITED VERSION OF GELATEK'S RENAIMATE
    Edited by: Blukez
    Created by: gelatek

    Features: 

    Anotations (shitty ones cuz i dont exactly understand gelateks code thhat well)
    More hat modes
    Removed isnetworkowner checks
    More settings
    Anti Ragdoll
    No void option
    Fixed noclip
    seperate table for settings

]]--

local Global = (getgenv and getgenv()) or getfenv(0) -- globals


Global.Settings = {
    ['Mode'] = 1, -- 1 is defualt (Sukmas hats) and 2 is free 3 is original (gelateks hats) 4 is rectangle head (looks better but more expensive)
    ['CSCollisionsOff'] = false,
    ['AntiSleepBoost'] = 10,
    ['AntiRagdoll'] = true,
    ['Void'] = false
}


Global.Gelatek_Reanimate_Settings = {
    ['Events'] = {}, -- dont edit those
    ['Bullet'] = nil,-- dont edit those
    ['ScriptStopped'] = false,-- dont edit those
}

if Global.Settings[AntiRagdoll] == true then
	local antiragdoll = Global.Settings[AntiRagdoll]
	antiragdoll = antiragdoll
		and function(v)
			if v:IsA("HingeConstraint") or v:IsA("BallSocketConstraint") then
				v.Parent = nil
			end
		end

	if antiragdoll then
		for i, v in pairs(Character:GetDescendants()) do
			antiragdoll(v)
		end
		Character.DescendantAdded:Connect(antiragdoll)
	end
end
-- variables
local AntiSleepBoost = 10
local Global = (getgenv and getgenv()) or getfenv(0)
local Cos, Sin, Rad, Time = math.cos, math.sin, math.rad, 0
local CFrame_new, CFrame_Angles = CFrame.new, CFrame.Angles
local AnglesZero = CFrame_Angles(0,0,0)
local Check, CFrameCheck = false, false
local Insert = table.insert 
local Loops, Hats  = {}, {}
local AntiSleep = CFrame_new()
local Mode = Global.Settings['Mode']
local Collisions = Global.Settings['CSCollisionsOff']

-- FindFirstChild Alternitive function
local function Get(OfClass, Parent, LookingFor)
    if OfClass then
        return Parent:FindFirstChildOfClass(LookingFor) 
    end
    return Parent:FindFirstChild(LookingFor) 
end

-- gameservices or smth
local Workspace = Get(true, game, "Workspace")
local RunService = Get(true, game, "RunService")
local Players = Get(true, game, "Players")

-- Delete leftovers of previous reanimations
if Workspace:FindFirstChild("Raw_Reanimation") then
    Workspace:FindFirstChild("Raw_Reanimation"):Destroy()
end

-- more variables
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local Humanoid = Get(true, Character, "Humanoid")
local RootPart = Get(false, Character, "HumanoidRootPart")
Character.Archivable = true

-- Create a table of all hats in the character

do --[[ Rename Hats (By Mizt) ]] --
	local HatsNames = {}
	for Index, Accessory in pairs(Character:GetDescendants()) do
		if Accessory:IsA("Accessory") then
			if HatsNames[Accessory.Name] then
				if HatsNames[Accessory.Name] == "Unknown" then
					HatsNames[Accessory.Name] = {}
				end
				Insert(HatsNames[Accessory.Name], Accessory)
			else
				HatsNames[Accessory.Name] = "Unknown"
			end	
		end
	end
	for Index, Tables in pairs(HatsNames) do
		if type(Tables) == "table" then
			local Number = 1
			for Index2, Names in ipairs(Tables) do
				Names.Name = Names.Name .. Number
				Number = Number + 1
			end
		end
	end
	HatsNames = nil  
end

-- make a fake char
local FakeCharacter = game:GetObjects("rbxassetid://8440552086")[1]
FakeCharacter.Parent = Workspace
FakeCharacter.Name = "Raw_Reanimation"
--Workspace.CurrentCamera.CameraSubject = Workspace:FindFirstChildOfClass("Part")

-- link pos between real and fake char
FakeCharacter.HumanoidRootPart.CFrame = RootPart.CFrame * CFrame.new(0,5,0) 
-- i have no idea what this is for
for _, Part in pairs(FakeCharacter:GetDescendants()) do
    if pcall(function() Part.Transparency = 1 end) then
       Part.Transparency = 1
    end
    if pcall(function() Part.Anchored = false end) then
        Part.Anchored = false
    end
end

-- set simulation distance depending on the amount of players
local HowManyPlayers = 1
local SimRadiusOffset = 0
do -- [[ Get Offset Value ]] --
    for i,v in next, Players:GetPlayers() do
        if v ~= LocalPlayer then
            HowManyPlayers = HowManyPlayers + i
            SimRadiusOffset = SimRadiusOffset + gethiddenproperty(v, "SimulationRadius")
        end
    end
end

-- net bypass methods
local Physics = settings().Physics
Physics.AllowSleep = false
Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
Physics.ThrottleAdjustTime = 1/0

Workspace.InterpolationThrottling = "Disabled"
Workspace.Retargeting = "Disabled"
sethiddenproperty(Workspace, "SignalBehavior", "Immediate")

Insert(Loops, RunService.Stepped:Connect(function()
    sethiddenproperty(LocalPlayer, "MaximumSimulationRadius", 1000*HowManyPlayers)
    sethiddenproperty(LocalPlayer, "SimulationRadius", 1000*HowManyPlayers)
    
    Time = Time + 1
    AntiSleep = CFrame_new(1.7 / 110 * Cos(Time / 8), 1.4 / 110 * Sin(Time / 6),0)
    
    if Time == 9e9 then
        Time = 0
    end
end))

local BackupCFrame = RootPart.CFrame

-- find and insert hats into table
for i,v in pairs(Character:GetChildren()) do
    if v:IsA("Accessory") then
        Insert(Hats, v.Handle)
    end
end

-- linkage between real and fake char
Insert(Loops, RunService.Heartbeat:Connect(function()
    for i, Part0 in pairs(Hats) do
        --if Part0 and Part0.Parent and isnetworkowner(Part0) and Check then
        if Part0 and Part0.Parent and Check then
            Part0.Velocity = Vector3.new(FakeCharacter.HumanoidRootPart.Velocity.X * (Part0.Mass*15), 40, FakeCharacter.HumanoidRootPart.Velocity.Z * (Part0.Mass*15))
            if CFrameCheck then Part0.CFrame = FakeCharacter.HumanoidRootPart.CFrame * AntiSleep end
        end
    end
end))


-- stuff
LocalPlayer.Character = nil
LocalPlayer.Character = FakeCharacter
if Global.Settings.Void == true then
    RootPart.CFrame = CFrame.new(0,Workspace.FallenPartsDestroyHeight + 300,SimRadiusOffset*2)
end
FakeCharacter.HumanoidRootPart.CFrame = CFrame.new(0,10,SimRadiusOffset)
FakeCharacter.HumanoidRootPart.Anchored = true
Character.HumanoidRootPart.Anchored = true
wait(Players.RespawnTime + 0.35)
Character:FindFirstChild("Animate"):Destroy()
Character.HumanoidRootPart.Anchored = false
RootPart.Velocity = Vector3.new(0,0,0)
Humanoid:ChangeState(15)
for i,v in pairs(Humanoid:GetPlayingAnimationTracks()) do
    v:Stop()
end

Check = true
CFrameCheck = true

-- why? WHY WHY GELATEK WHY 500??
for i,v in pairs(Character:GetChildren()) do
    if v:IsA("Accessory") then
        v.Handle.Velocity = Vector3.new(0,100,0)
    end
end 

wait(2)
FakeCharacter.HumanoidRootPart.Anchored = false
FakeCharacter.HumanoidRootPart.CFrame = BackupCFrame * CFrame_new(0,10,0)
FakeCharacter.HumanoidRootPart.Velocity = Vector3.new()
if Global.Settings.Void == false then
    FakeCharacter:FindFirstChildOfClass("Humanoid").Health = 0
end
FakeCharacter:FindFirstChildOfClass("Humanoid").Died:Once(function()
    for i, v in pairs(Loops) do
        v:Disconnect()
    end
    for i,v in pairs(Global.Gelatek_Reanimate_Settings['Events']) do
       v:Disconnect() 
    end
    Global.Gelatek_Reanimate_Settings['ScriptStopped'] = true
delay(0.3, function()
        Global.Gelatek_Reanimate_Settings['ScriptStopped'] = false
    end)
    Global.Gelatek_Reanimate_Settings['Bullet'] = nil
    
    LocalPlayer.Character = Character
    Character.Parent = Workspace
    Character:BreakJoints()
    FakeCharacter:Destroy()
end)

-- transfer hats and stuff from real char to fake
local CharDescendants = Character:GetDescendants()
for i,v in pairs(CharDescendants) do
    if v:IsA("Accessory") then
        local Accessory = v:Clone()
        Accessory.Parent = FakeCharacter
        local Handle = Accessory:FindFirstChild("Handle")
        Handle.Transparency = 1
    	pcall(function() Handle:FindFirstChildOfClass("Weld"):Destroy() end)
    	local NewWeld = Instance.new("Weld")
    	NewWeld.Name = "AccessoryWeld"
    	NewWeld.Part0 = Handle
    	local Attachment = Handle:FindFirstChildOfClass("Attachment")
    	if Attachment then
    		NewWeld.C0 = Attachment.CFrame
    		NewWeld.C1 = FakeCharacter:FindFirstChild(tostring(Attachment), true).CFrame
    		NewWeld.Part1 = FakeCharacter:FindFirstChild(tostring(Attachment), true).Parent
    	else
    		NewWeld.Part1 = FakeCharacter:FindFirstChild("Head")
    		NewWeld.C1 = CFrame.new(0,FakeCharacter:FindFirstChild("Head").Size.Y / 2,0) * Accessory.AttachmentPoint:Inverse()
    	end
    	Handle.CFrame = NewWeld.Part1.CFrame * NewWeld.C1 * NewWeld.C0:Inverse()
    	NewWeld.Parent = Accessory.Handle
    end
end


local FakeCharDesc = FakeCharacter:GetDescendants()

-- function to get hat from a mesh id (to stop erroring with hats with the same names)
local function GetHandleFromMeshId(RealMesh)
    for i,v in pairs(CharDescendants) do
        if v:IsA("Accessory") then
            local Handle = v:FindFirstChild("Handle")
            local Mesh = Handle:FindFirstChild("SpecialMesh") or Handle:FindFirstChild("Mesh") or Handle
            
            if Mesh.MeshId == RealMesh then
                FakeCharacter:FindFirstChild(v.Name):Destroy()
                warn(v, v.Parent, v.Parent.Parent, Mesh)
                return Handle
            end
        end
    end
end

local Torso, RightArm, LeftArm, RightLeg, LeftLeg

-- Hats
if Mode == 1 then
    Torso = GetHandleFromMeshId("rbxassetid://12483473635")
    LeftArm = GetHandleFromMeshId("rbxassetid://12344207333")
    RightArm = GetHandleFromMeshId("rbxassetid://12344206657")
    LeftLeg = GetHandleFromMeshId("rbxassetid://11263221350")
    RightLeg = GetHandleFromMeshId("rbxassetid://11159370334")
elseif Mode == 2 then
    Torso = GetHandleFromMeshId("rbxassetid://4819720316")
    LeftArm = GetHandleFromMeshId("rbxassetid://4094864753")
    RightArm = GetHandleFromMeshId("rbxassetid://4154474745")
    LeftLeg = GetHandleFromMeshId("rbxassetid://4324138105") --GetHandleFromMeshId("rbxassetid://3030546036")
    RightLeg = GetHandleFromMeshId("rbxassetid://4489232754")
elseif Mode == 3 then
    Torso = GetHandleFromMeshId("rbxassetid://6963024829");
    LeftArm = GetHandleFromMeshId("rbxassetid://11449386931")
    RightArm = GetHandleFromMeshId("rbxassetid://11449388499")
    LeftLeg = GetHandleFromMeshId("rbxassetid://11263221350")
    RightLeg = GetHandleFromMeshId("rbxassetid://11159370334")
end

-- bind function
local function ConnectTo(Part0, Part1, Offset)
    if Part0 then
    --if Part0 and isnetworkowner(Part0) then
        Part0.CFrame = Part1.CFrame * Offset * AntiSleep
    end
end

task.wait(0.5)

-- fake parts
local FakeTorso = FakeCharacter:FindFirstChild("Torso")
local FakeRA, FakeLA = FakeCharacter:WaitForChild("Right Arm"), FakeCharacter:WaitForChild("Left Arm")
local FakeRL, FakeLL = FakeCharacter:WaitForChild("Right Leg"), FakeCharacter:WaitForChild("Left Leg")

-- part alignment
if Mode == 1 then
    Insert(Loops, RunService.Heartbeat:Connect(function()
        ConnectTo(Torso, FakeTorso, AnglesZero)
        ConnectTo(LeftArm, FakeLA, CFrame_Angles(Rad(-125), 0, 0))
        ConnectTo(RightArm, FakeRA, CFrame_Angles(Rad(-125), 0, 0))
        ConnectTo(LeftLeg, FakeLL, CFrame_Angles(0, Rad(90), Rad(90)))
        ConnectTo(RightLeg, FakeRL, CFrame_Angles(0, Rad(-90), Rad(90)))
        
        for i, Hat in pairs(Hats) do
            if Hat and Hat.Parent and FakeCharacter:FindFirstChild(Hat.Parent.Name) then
                ConnectTo(Hat, FakeCharacter:FindFirstChild(Hat.Parent.Name).Handle, AnglesZero)
            end
        end
    end))
elseif Mode == 2 then
    Insert(Loops, RunService.Heartbeat:Connect(function()
        ConnectTo(Torso, FakeTorso, CFrame_Angles(0, 0, Rad(-15)))
        ConnectTo(LeftArm, FakeLA, CFrame_Angles(Rad(90), 0, Rad(90)))
        ConnectTo(RightArm, FakeRA, CFrame_Angles(Rad(90), 0, Rad(-90)))
        ConnectTo(LeftLeg, FakeLL, CFrame_Angles(Rad(-90), 0, Rad(-90)))
        ConnectTo(RightLeg, FakeRL, CFrame_Angles(Rad(-90), 0, Rad(90)))
        
        for i, Hat in pairs(Hats) do
            if Hat and Hat.Parent and FakeCharacter:FindFirstChild(Hat.Parent.Name) then
                ConnectTo(Hat, FakeCharacter:FindFirstChild(Hat.Parent.Name).Handle, AnglesZero)
            end
        end
    end))
elseif Mode == 3 then
    Insert(Loops, RunService.Heartbeat:Connect(function()
        ConnectTo(Torso, FakeTorso, AnglesZero)
        ConnectTo(LeftArm, FakeLA, CFrame_Angles(Rad(-125), 0, 0))
        ConnectTo(RightArm, FakeRA, CFrame_Angles(Rad(-125), 0, 0))
        ConnectTo(LeftLeg, FakeLL, CFrame_Angles(0, Rad(90), Rad(90)))
        ConnectTo(RightLeg, FakeRL, CFrame_Angles(0, Rad(-90), Rad(90)))
        
        for i, Hat in pairs(Hats) do
            if Hat and Hat.Parent and FakeCharacter:FindFirstChild(Hat.Parent.Name) then
                ConnectTo(Hat, FakeCharacter:FindFirstChild(Hat.Parent.Name).Handle, AnglesZero)
            end
        end
    end))
end

Character.Parent = FakeCharacter
CFrameCheck = false
Workspace.CurrentCamera.CameraSubject = FakeCharacter:FindFirstChildOfClass("Humanoid")
AntiSleepBoost = 1.05

wait(5)

if Collisions then
    Insert(Loops, RunService.Stepped:Connect(function()
        for i, v in pairs(FakeCharDesc) do
            if v and v.Parent and v:IsA("BasePart") then
               v.CanCollide = false
            end
        end
    end))
end
