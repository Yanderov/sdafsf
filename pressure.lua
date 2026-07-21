--!strict
-- PRESSURE HUB (Hadal Blacksite) — Inertia design engine, full rebuild.
--
-- Engine facts, all live-verified this session:
--  * Speed goes through the game's own StatusEffects.GetSpeed hook — the
--    game rewrites Humanoid.WalkSpeed every frame from CameraModule, so a
--    raw WalkSpeed loop fights it and loses.
--  * Oxygen is client-side: Main.OxygenTank.TankValue (0..100).
--  * Interactions are ProximityPrompts: doors = <Model>.Root, drawers and
--    cabinets = HighLight, pickups/currency/keycards = ProxyPart,
--    lockers = Locker part.
--  * The real next-room door carries ProgressDoor=true. Dead-end fakes are
--    NoEntry/BentDoor/DeadEndDoor/BrokenDoor models (no prompt at all).
--  * A "void" locker (the one with a monster inside) is a Locker model bound
--    to the MonsterLocker interaction — it has a lowercase `highlight` child
--    instead of the safe locker's `HighLight`.
--  * The keypad's real code sits in LocalPlayer:GetAttribute("Code") the
--    moment the server sets it — no need to search for the paper note.
--  * Sidebar layout bug class: NEVER give a decorative sibling of
--    list-managed buttons a Scale-based Size — UIListLayout treats every
--    GuiObject child as a stack item, decorative or not, and a Scale=1
--    height item shoves everything else off-window. All dividers here are
--    parented outside the list, and every list button gets an explicit
--    LayoutOrder.

if _G.Pressure_Script then
	pcall(function() _G.Pressure_Script:Destroy() end)
	_G.Pressure_Script = nil
end
-- _G doesn't reliably survive every re-execution path this session produced
-- (two "PressureHub" ScreenGuis were found live — one in PlayerGui, one in
-- CoreGui — after _G.Pressure_Script alone failed to catch the older one).
-- Sweep every plausible UI parent by NAME instead of trusting global state.
do
	local Players2 = game:GetService("Players")
	local parents = {}
	local CoreGui2
	pcall(function() CoreGui2 = game:GetService("CoreGui") end)
	if CoreGui2 then
		table.insert(parents, CoreGui2)
		local robloxGui = CoreGui2:FindFirstChild("RobloxGui")
		if robloxGui then table.insert(parents, robloxGui) end
	end
	local playerGui = Players2.LocalPlayer:FindFirstChild("PlayerGui")
	if playerGui then table.insert(parents, playerGui) end
	if gethui then pcall(function() table.insert(parents, gethui()) end) end
	local seen = {}
	for _, parent in ipairs(parents) do
		if parent then
			-- Fast path for the two actual parents used by common executors.
			-- It also works when CoreGui hides nested descendants from a script
			-- enumeration but still allows direct access to RobloxGui.
			for _, guiName in ipairs({ "PressureHub", "PressureESP" }) do
				local direct = parent:FindFirstChild(guiName)
				if direct and direct:IsA("ScreenGui") then
					seen[direct] = true
					pcall(function() direct:Destroy() end)
				end
			end
			-- gethui may be nested below CoreGui.  A direct FindFirstChild misses
			-- that protected container and leaves an old menu over the new one.
			-- Sweep descendants as well, but only our uniquely named ScreenGuis.
			for _, inst in ipairs(parent:GetDescendants()) do
				if not seen[inst] and inst:IsA("ScreenGui") and (inst.Name == "PressureHub" or inst.Name == "PressureESP") then
					seen[inst] = true
					pcall(function() inst:Destroy() end)
				end
			end
		end
	end
	-- ESP tags are parented to world objects rather than either ScreenGui.
	-- Remove stale tags from an older injection too, otherwise re-running the
	-- script leaves duplicate highlights and billboards behind.
	for _, inst in ipairs(game:GetService("Workspace"):GetDescendants()) do
		if inst.Name == "PressureEspTag" or inst.Name == "PressureEspHL" or inst.Name == "PressureTeammateCham" then
			pcall(function() inst:Destroy() end)
		end
	end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer
local _origMaxZoom = LP.CameraMaxZoomDistance
local function cam() return Workspace.CurrentCamera end

--------------------------------------------------------------------------------
-- STATE
--------------------------------------------------------------------------------
local S = {
	Connections = {}, Gui = nil, Destroyed = false,
	UITheme = "Graphite", UITextScale = 1, NotificationPosition = "Top Right",
	-- Motion
	SpeedEnabled = false, CustomWalkSpeed = 24, CrouchSpeed = 10, SprintMod = 45,
	JumpEnabled = false, CustomJumpPower = 50,
	Fly = false, FlySpeed = 50, NoClip = false, InfiniteJump = false,
	Spinbot = false, SpinSpeed = 20,
	FastSwim = false, SwimSpeed = 32, GliderSpeed = 60, InfiniteOxygen = false,
	-- Visuals / ESP
	EntityESP = false, WallDwellerESP = false, EyefestESP = false, SquiddleESP = false,
	CarnationESP = false, HazardESP = false, DoorESP = false, LockerESP = false,
	DrawerESP = false, ItemESP = false, KronerESP = false, KeycardESP = false, ObjectiveESP = false,
	NameESP = false, BoxESP = false, HealthESP = false, TracerESP = false, ESPMaxDist = 1500,
	PlayerChams = false, ThreatRadar = false, StatusHUD = false, KeybindHUD = true, NextDoorTracer = false,
	FullBright = false, NoFog = false, Brightness = 2,
	LowLightVision = false, CleanScreenEffects = false, VisualContrast = 0, VisualSaturation = 100,
	CamFOVEnabled = false, CamFOV = 70,
	-- Combat / defense
	EntityWarning = false, WarningSound = false, AutoHideInLocker = false,
	AntiEyefest = false, AutoDozerStealth = false, AutoShakeParasite = false,
	RemoveJumpscares = false, BossAlerts = false,
	-- Automation
	AutoOpenDoors = false, AutoCollectItems = false, AutoSearchDrawers = false,
	AutoCollectKeys = false, AutoRefillBatteries = false, AutoTurnValves = false, AutoRepairGenerators = false,
	AutoDisarmLandmines = false,
	RoomTracker = false, InstantInteract = false, PromptReach = false,
	-- Player
	AntiAFK = false,
	-- UI
	-- Insert, not RightShift: Roblox's stock MouseLockController binds
	-- BOTH LeftShift and RightShift to its own shift-lock toggle, so every
	-- RightShift press was also flipping the game's own mouse-lock feature
	-- and fighting our unlock — this is the actual root cause behind
	-- "mouse never unlocks", confirmed live (MouseBehavior snapped back to
	-- LockCenter even with the menu open and our enforcement loop running).
	MenuKeybind = Enum.KeyCode.Insert,
	Keybinds = {},
}
_G.Pressure_Script = S

local function tc(conn) table.insert(S.Connections, conn); return conn end

-- Collision state belongs to the character, not to the feature.  Record the
-- original value once and restore exactly that value when neither Fly nor
-- Noclip needs it; forcing every part to true breaks accessories and maps
-- that intentionally use non-collidable character parts.
local function restoreNoClip()
	local touched = S._noclipTouched
	if not touched then return end
	for part, originalCanCollide in pairs(touched) do
		pcall(function()
			if part and part.Parent then part.CanCollide = originalCanCollide end
		end)
	end
	S._noclipTouched = nil
end
S._restoreNoClip = restoreNoClip

-- A few game-owned tables are adjusted by sliders.  Keep their original
-- values per table/field so unloading the hub does not leave altered movement
-- values behind, even when a setting was applied after the module loaded.
local function setGameField(container, key, value)
	if type(container) ~= "table" then return end
	S._gameFieldOriginal = S._gameFieldOriginal or {}
	local fields = S._gameFieldOriginal[container]
	if not fields then fields = {}; S._gameFieldOriginal[container] = fields end
	if not fields[key] then fields[key] = { value = container[key] } end
	pcall(function() container[key] = value end)
end

local function restoreGameFields()
	for container, fields in pairs(S._gameFieldOriginal or {}) do
		for key, state in pairs(fields) do
			pcall(function() container[key] = state.value end)
		end
	end
	S._gameFieldOriginal = nil
end
S._restoreGameFields = restoreGameFields

local function restoreJumpPower()
	local saved = S._jumpOriginal
	if not saved then return end
	for hum, state in pairs(saved) do
		pcall(function()
			if hum and hum.Parent then
				hum.UseJumpPower = state.useJumpPower
				hum.JumpPower = state.jumpPower
			end
		end)
	end
	S._jumpOriginal = nil
end
S._restoreJumpPower = restoreJumpPower

local function restoreCameraFov()
	local camera, original = S._fovCamera, S._fovOriginal
	if camera and original ~= nil then
		pcall(function() if camera.Parent then camera.FieldOfView = original end end)
	end
	S._fovCamera, S._fovOriginal = nil, nil
end
S._restoreCameraFov = restoreCameraFov

local function captureLightingState()
	if S._lightingOriginal then return S._lightingOriginal end
	local original = {
		ambient = Lighting.Ambient,
		outdoorAmbient = Lighting.OutdoorAmbient,
		brightness = Lighting.Brightness,
		diffuse = Lighting.EnvironmentDiffuseScale,
		specular = Lighting.EnvironmentSpecularScale,
		fogEnd = Lighting.FogEnd,
		atmospheres = {},
	}
	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("Atmosphere") then
			original.atmospheres[effect] = { density = effect.Density, haze = effect.Haze }
		end
	end
	S._lightingOriginal = original
	return original
end

local function restoreLightingState()
	local original = S._lightingOriginal
	if not original then return end
	pcall(function()
		Lighting.Ambient = original.ambient
		Lighting.OutdoorAmbient = original.outdoorAmbient
		Lighting.Brightness = original.brightness
		Lighting.EnvironmentDiffuseScale = original.diffuse
		Lighting.EnvironmentSpecularScale = original.specular
		Lighting.FogEnd = original.fogEnd
	end)
	for effect, state in pairs(original.atmospheres) do
		pcall(function()
			if effect.Parent then effect.Density = state.density; effect.Haze = state.haze end
		end)
	end
	S._lightingOriginal = nil
	S._lightingApplied = nil
end
S._restoreLighting = restoreLightingState

local function applyLightingOverrides()
	-- Preserve game lighting changes that happen while this override is active.
	-- Without this, turning it off after a room transition restores an old room.
	local function absorbGameLightingChanges(original)
		local applied = S._lightingApplied
		if not applied then return end
		if applied.fullbright then
			if Lighting.Ambient ~= applied.ambient then original.ambient = Lighting.Ambient end
			if Lighting.OutdoorAmbient ~= applied.outdoorAmbient then original.outdoorAmbient = Lighting.OutdoorAmbient end
			if Lighting.Brightness ~= applied.brightness then original.brightness = Lighting.Brightness end
			if Lighting.EnvironmentDiffuseScale ~= applied.diffuse then original.diffuse = Lighting.EnvironmentDiffuseScale end
			if Lighting.EnvironmentSpecularScale ~= applied.specular then original.specular = Lighting.EnvironmentSpecularScale end
		end
		if applied.noFog then
			if Lighting.FogEnd ~= applied.fogEnd then original.fogEnd = Lighting.FogEnd end
			for effect, state in pairs(applied.atmospheres) do
				if effect.Parent and original.atmospheres[effect] then
					if effect.Density ~= state.density then original.atmospheres[effect].density = effect.Density end
					if effect.Haze ~= state.haze then original.atmospheres[effect].haze = effect.Haze end
				end
			end
		end
	end
	local function rememberLightingWrite()
		local applied = { fullbright = S.FullBright == true, noFog = S.NoFog == true, atmospheres = {} }
		if applied.fullbright then
			applied.ambient = Lighting.Ambient; applied.outdoorAmbient = Lighting.OutdoorAmbient
			applied.brightness = Lighting.Brightness; applied.diffuse = Lighting.EnvironmentDiffuseScale
			applied.specular = Lighting.EnvironmentSpecularScale
		end
		if applied.noFog then
			applied.fogEnd = Lighting.FogEnd
			for _, effect in ipairs(Lighting:GetChildren()) do
				if effect:IsA("Atmosphere") then applied.atmospheres[effect] = { density = effect.Density, haze = effect.Haze } end
			end
		end
		S._lightingApplied = applied
	end
	if not (S.FullBright or S.NoFog) then
		restoreLightingState()
		return
	end
	local original = captureLightingState()
	absorbGameLightingChanges(original)
	if S.FullBright then
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
		Lighting.Brightness = S.Brightness or 2
		Lighting.EnvironmentDiffuseScale = 1
		Lighting.EnvironmentSpecularScale = 1
	else
		Lighting.Ambient = original.ambient
		Lighting.OutdoorAmbient = original.outdoorAmbient
		Lighting.Brightness = original.brightness
		Lighting.EnvironmentDiffuseScale = original.diffuse
		Lighting.EnvironmentSpecularScale = original.specular
	end
	if S.NoFog then
		Lighting.FogEnd = 9e9
		for _, effect in ipairs(Lighting:GetChildren()) do
			if effect:IsA("Atmosphere") then
				if not original.atmospheres[effect] then
					original.atmospheres[effect] = { density = effect.Density, haze = effect.Haze }
				end
				effect.Density = 0
				effect.Haze = 0
			end
		end
	else
		Lighting.FogEnd = original.fogEnd
		for effect, state in pairs(original.atmospheres) do
			pcall(function() if effect.Parent then effect.Density = state.density; effect.Haze = state.haze end end)
		end
	end
	rememberLightingWrite()
end

--------------------------------------------------------------------------------
-- GAME BRIDGE — speed hook, jumpscare hook, remote lookup
--------------------------------------------------------------------------------
local GameMain = nil
local SpeedHook = { installed = false, orig = nil, se = nil }
local JumpscareHook = { installed = false, orig = nil, mod = nil }

local function getMain() return GameMain end
local function getEvents() return ReplicatedStorage:FindFirstChild("Events") end
local function findRemote(name)
	local ev = getEvents()
	local r = ev and ev:FindFirstChild(name)
	if r and (r:IsA("RemoteEvent") or r:IsA("UnreliableRemoteEvent") or r:IsA("RemoteFunction")) then
		return r
	end
	return nil
end

local function applyModuleTuning()
	local m = getMain()
	local tuned = S._tunedFields
	if not (m and tuned) then return end
	if tuned.CrouchSpeed and type(m.CameraModule) == "table" then
		setGameField(m.CameraModule, "CrouchWalkSpeed", S.CrouchSpeed)
	end
	if tuned.SprintMod then
		if type(m.CameraModule) == "table" then setGameField(m.CameraModule, "SprintModifier", S.SprintMod) end
	end
	if tuned.GliderSpeed and type(m.Swimming) == "table" then
		setGameField(m.Swimming, "GliderSpeed", S.GliderSpeed)
	end
end

-- Swimming owns CurrentSwimSpeed itself while the player accelerates and slows
-- down.  Touching that field from our timer fights its interpolation and causes
-- the underwater drift/jitter that was reported.  We only tune the static cap.
local function saveSwimDefaults(sw)
	if type(sw) ~= "table" then return nil end
	if not S._savedSwim then
		S._savedSwim = {
			swim = tonumber(sw.SwimmingSpeed) or 18,
			current = tonumber(sw.CurrentSwimSpeed) or tonumber(sw.SwimmingSpeed) or 18,
			glider = tonumber(sw.GliderSpeed) or 60,
		}
	end
	return S._savedSwim
end

local function restoreSwimDefaults(sw, restoreGlider)
	local saved = S._savedSwim
	if type(sw) ~= "table" or not saved then return end
	if saved.swim ~= nil then sw.SwimmingSpeed = saved.swim end
	if saved.current ~= nil then sw.CurrentSwimSpeed = saved.current end
	if restoreGlider and saved.glider ~= nil then sw.GliderSpeed = saved.glider end
end

local function installSpeedHook()
	if SpeedHook.installed then return end
	local m = getMain()
	local se = m and m.StatusEffects
	if type(se) ~= "table" or type(se.GetSpeed) ~= "function" then return end
	SpeedHook.se = se
	SpeedHook.orig = se.GetSpeed
	se.GetSpeed = function(self, plr, ...)
		if S.SpeedEnabled and plr == LP then
			return S.CustomWalkSpeed, S.CustomWalkSpeed, 1
		end
		return SpeedHook.orig(self, plr, ...)
	end
	SpeedHook.installed = true
end

local function refreshGameSpeed()
	local m = getMain()
	if m and type(m.StatusEffects) == "table" then
		pcall(function() m.StatusEffects:RefreshSpeed(LP) end)
	end
end

local function installJumpscareHook()
	if JumpscareHook.installed then return end
	local m = getMain()
	local bj = m and m.BlitzJumpscare
	if type(bj) ~= "table" or type(bj.Start) ~= "function" then return end
	JumpscareHook.mod = bj
	JumpscareHook.orig = bj.Start
	bj.Start = function(...)
		if S.RemoveJumpscares then return end
		return JumpscareHook.orig(...)
	end
	JumpscareHook.installed = true
end

task.spawn(function()
	while not S.Destroyed and not GameMain do
		pcall(function()
			local pg = LP:FindFirstChild("PlayerGui")
			local mg = pg and pg:FindFirstChild("Main")
			local cl = mg and mg:FindFirstChild("Client")
			local mc = cl and cl:FindFirstChild("MainClient")
			local cmod = mc and mc:FindFirstChild("CameraModule")
			if cmod then
				local cmv = require(cmod)
				if type(cmv) == "table" and type(cmv.Main) == "table" then
					GameMain = cmv.Main
				end
			end
		end)
		if GameMain then break end
		task.wait(1)
	end
	if GameMain then
		installSpeedHook()
		installJumpscareHook()
		applyModuleTuning()
	end
end)

function S:Destroy()
	self.Destroyed = true
	pcall(function() RunService:UnbindFromRenderStep("PressureMouseUnlock") end)
	pcall(function() if SpeedHook.installed and SpeedHook.se then SpeedHook.se.GetSpeed = SpeedHook.orig end end)
	pcall(function() if JumpscareHook.installed and JumpscareHook.mod then JumpscareHook.mod.Start = JumpscareHook.orig end end)
	pcall(function() LP.CameraMode = Enum.CameraMode.LockFirstPerson; LP.CameraMaxZoomDistance = _origMaxZoom or 0.5 end)
	pcall(function()
		local m = getMain()
		local sw = m and m.Swimming
		if type(sw) == "table" and self._savedSwim then
			restoreSwimDefaults(sw, true)
		end
	end)
	pcall(function() if self._flyBV then self._flyBV:Destroy() end end)
	pcall(function() if self._restoreNoClip then self._restoreNoClip() end end)
	pcall(function() if self._restoreJumpPower then self._restoreJumpPower() end end)
	pcall(function() if self._restoreCameraFov then self._restoreCameraFov() end end)
	pcall(function() if self._restoreLighting then self._restoreLighting() end end)
	pcall(function() if self._restoreGameFields then self._restoreGameFields() end end)
	pcall(function() if self._stopAutoRepair then self._stopAutoRepair() end end)
	pcall(function() if self._cleanupVisuals then self._cleanupVisuals() end end)
	pcall(function() if self._cleanupESP then self._cleanupESP() end end)
	pcall(function() UIS.MouseBehavior = Enum.MouseBehavior.LockCenter; UIS.MouseIconEnabled = false end)
	pcall(function()
		if self._promptOrig then
			for pr, o in pairs(self._promptOrig) do
				pcall(function()
					if pr.Parent then pr.HoldDuration = o.hold; pr.MaxActivationDistance = o.dist end
				end)
			end
		end
	end)
	S.SpeedEnabled = false
	refreshGameSpeed()
	for _, c in ipairs(self.Connections) do pcall(function() c:Disconnect() end) end
	if self.Gui then pcall(function() self.Gui:Destroy() end) end
end

--------------------------------------------------------------------------------
-- SOUND
--------------------------------------------------------------------------------
local SndCache = {}
local function snd(id, pitch, vol)
	task.spawn(function() pcall(function()
		local k = id .. pitch
		local s = SndCache[k]
		if not s or not s.Parent then
			s = Instance.new("Sound"); s.SoundId = id; s.Parent = SoundService; SndCache[k] = s
		end
		s.PlaybackSpeed = pitch; s.Volume = vol or 0.3; s:Play()
	end) end)
end
local SFX = {
	On = function() snd("rbxassetid://6895079853", 1.35, 0.4) end,
	Off = function() snd("rbxassetid://6895079853", 0.8, 0.25) end,
	Click = function() snd("rbxassetid://6895079853", 1.05, 0.3) end,
	Pop = function() snd("rbxassetid://4590662766", 1.2, 0.35) end,
}

--------------------------------------------------------------------------------
-- Shared visual system from HUD_ClickGUI_Module.lua. Gameplay colors (ESP,
-- warnings and world highlights) stay independent from these interface roles.
--------------------------------------------------------------------------------
local THEMES = {
	Graphite = {
		BG=Color3.fromRGB(32,32,32), Sidebar=Color3.fromRGB(38,38,38), Card=Color3.fromRGB(44,44,44), Elev=Color3.fromRGB(52,52,52),
		Hover=Color3.fromRGB(62,62,62), ActiveBg=Color3.fromRGB(74,74,74), Bd=Color3.fromRGB(58,58,58), Bd2=Color3.fromRGB(80,80,80),
		White=Color3.fromRGB(255,255,255), Tx=Color3.fromRGB(238,238,236), Tx2=Color3.fromRGB(214,213,210), Tx3=Color3.fromRGB(180,179,175), Tx4=Color3.fromRGB(154,153,149),
		Accent=Color3.fromRGB(216,215,211), Glow=Color3.fromRGB(145,144,141),
	},
	Ocean = {
		BG=Color3.fromRGB(14,38,65), Sidebar=Color3.fromRGB(18,48,80), Card=Color3.fromRGB(23,58,95), Elev=Color3.fromRGB(30,70,112),
		Hover=Color3.fromRGB(38,84,130), ActiveBg=Color3.fromRGB(48,102,154), Bd=Color3.fromRGB(44,89,132), Bd2=Color3.fromRGB(62,119,172),
		White=Color3.fromRGB(235,249,255), Tx=Color3.fromRGB(212,238,250), Tx2=Color3.fromRGB(174,215,235), Tx3=Color3.fromRGB(132,181,208), Tx4=Color3.fromRGB(102,150,180),
		Accent=Color3.fromRGB(67,190,255), Glow=Color3.fromRGB(32,114,242),
	},
	Forest = {
		BG=Color3.fromRGB(14,45,26), Sidebar=Color3.fromRGB(18,56,32), Card=Color3.fromRGB(23,67,39), Elev=Color3.fromRGB(30,80,47),
		Hover=Color3.fromRGB(38,95,57), ActiveBg=Color3.fromRGB(48,114,69), Bd=Color3.fromRGB(44,101,61), Bd2=Color3.fromRGB(63,132,81),
		White=Color3.fromRGB(240,255,246), Tx=Color3.fromRGB(220,244,230), Tx2=Color3.fromRGB(184,222,199), Tx3=Color3.fromRGB(142,186,159), Tx4=Color3.fromRGB(110,156,128),
		Accent=Color3.fromRGB(69,220,125), Glow=Color3.fromRGB(23,156,82),
	},
	Wine = {
		BG=Color3.fromRGB(58,16,34), Sidebar=Color3.fromRGB(70,20,42), Card=Color3.fromRGB(82,25,50), Elev=Color3.fromRGB(96,32,60),
		Hover=Color3.fromRGB(113,41,72), ActiveBg=Color3.fromRGB(134,52,87), Bd=Color3.fromRGB(106,44,76), Bd2=Color3.fromRGB(142,61,98),
		White=Color3.fromRGB(255,240,248), Tx=Color3.fromRGB(247,215,231), Tx2=Color3.fromRGB(226,175,201), Tx3=Color3.fromRGB(193,132,163), Tx4=Color3.fromRGB(160,102,131),
		Accent=Color3.fromRGB(255,93,169), Glow=Color3.fromRGB(204,39,118),
	},
	Violet = {
		BG=Color3.fromRGB(45,25,72), Sidebar=Color3.fromRGB(55,31,86), Card=Color3.fromRGB(66,38,101), Elev=Color3.fromRGB(79,47,117),
		Hover=Color3.fromRGB(94,58,135), ActiveBg=Color3.fromRGB(113,71,158), Bd=Color3.fromRGB(92,58,132), Bd2=Color3.fromRGB(127,80,171),
		White=Color3.fromRGB(248,241,255), Tx=Color3.fromRGB(232,216,248), Tx2=Color3.fromRGB(202,178,229), Tx3=Color3.fromRGB(169,138,207), Tx4=Color3.fromRGB(137,107,175),
		Accent=Color3.fromRGB(166,104,255), Glow=Color3.fromRGB(108,61,219),
	},
	Ember = {
		BG=Color3.fromRGB(62,23,8), Sidebar=Color3.fromRGB(74,28,10), Card=Color3.fromRGB(86,34,13), Elev=Color3.fromRGB(101,43,17),
		Hover=Color3.fromRGB(118,54,22), ActiveBg=Color3.fromRGB(139,67,29), Bd=Color3.fromRGB(111,56,26), Bd2=Color3.fromRGB(147,73,35),
		White=Color3.fromRGB(255,246,236), Tx=Color3.fromRGB(248,224,204), Tx2=Color3.fromRGB(231,190,159), Tx3=Color3.fromRGB(201,150,113), Tx4=Color3.fromRGB(169,116,83),
		Accent=Color3.fromRGB(255,116,48), Glow=Color3.fromRGB(225,56,25),
	},
	Amber = {
		BG=Color3.fromRGB(61,47,10), Sidebar=Color3.fromRGB(72,56,13), Card=Color3.fromRGB(84,66,17), Elev=Color3.fromRGB(99,79,22),
		Hover=Color3.fromRGB(116,94,29), ActiveBg=Color3.fromRGB(137,114,39), Bd=Color3.fromRGB(109,91,34), Bd2=Color3.fromRGB(145,120,45),
		White=Color3.fromRGB(255,251,231), Tx=Color3.fromRGB(246,233,195), Tx2=Color3.fromRGB(225,205,151), Tx3=Color3.fromRGB(192,167,106), Tx4=Color3.fromRGB(157,133,78),
		Accent=Color3.fromRGB(255,196,57), Glow=Color3.fromRGB(218,143,21),
	},
	Rose = {
		BG=Color3.fromRGB(62,17,31), Sidebar=Color3.fromRGB(74,21,38), Card=Color3.fromRGB(87,27,47), Elev=Color3.fromRGB(102,35,57),
		Hover=Color3.fromRGB(120,46,70), ActiveBg=Color3.fromRGB(141,58,85), Bd=Color3.fromRGB(113,49,74), Bd2=Color3.fromRGB(150,67,96),
		White=Color3.fromRGB(255,239,244), Tx=Color3.fromRGB(248,214,224), Tx2=Color3.fromRGB(231,175,193), Tx3=Color3.fromRGB(201,131,154), Tx4=Color3.fromRGB(168,99,123),
		Accent=Color3.fromRGB(255,91,126), Glow=Color3.fromRGB(224,34,79),
	},
}
local T = {}
local function loadPalette(name)
	local source = THEMES[name] or THEMES.Graphite
	for key in pairs(T) do T[key] = nil end
	for key, value in pairs(source) do T[key] = value end
	T.TgOff = T.Bd2:Lerp(T.Card, 0.35)
	T.TgOn = T.Accent
	T.KnobOff = T.Tx2
	T.KnobOn = T.White
	return THEMES[name] and name or "Graphite"
end
S.UITheme = loadPalette(S.UITheme)
local TONE = {
	info = Color3.fromRGB(218, 223, 228),
	warn = Color3.fromRGB(255, 192, 88),
	danger = Color3.fromRGB(255, 92, 92),
}
local F, FM, FB = Enum.Font.Gotham, Enum.Font.GothamMedium, Enum.Font.GothamBold

local function Corner(i, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 6); c.Parent = i; return c end
local function Stroke(i, col, th, tr)
	local s = Instance.new("UIStroke")
	s.Color = col or T.Bd; s.Thickness = th or 1; s.Transparency = tr or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = i
	return s
end
local function Grad(i, c1, c2, rot)
	local g = Instance.new("UIGradient"); g.Color = ColorSequence.new(c1, c2); g.Rotation = rot or 90; g.Parent = i
	return g
end
local function Pad(i, t, b, l, r)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, t or 0); p.PaddingBottom = UDim.new(0, b or 0)
	p.PaddingLeft = UDim.new(0, l or 0); p.PaddingRight = UDim.new(0, r or 0)
	p.Parent = i
	return p
end
local function Shadow(i, tr)
	local s = Instance.new("UIStroke")
	s.Color = T.Bd2; s.Thickness = 2; s.Transparency = tr or 0.6
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = i
	return s
end
local function Tween(inst, time, props, style, dir)
	return TweenService:Create(inst, TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
end

-- Lucide navigation icons (ISC): https://github.com/lucide-icons/lucide
S._NavIconData = {
	["eye"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAAC+klEQVRoge2YwU8TQRTGvwWCxEQu9VLTyAkPeCF6ABKTEjnI34EHCByoV2uix14ketMLfwFq8A9ADAcBb8iJg6AmkBAhJBATG9Kfh50mzXS2O20XEN0v2bTbfd/33kxn3r55UooUKVKk+J8RJCECXJU0LOme+bwhKSPpujH5KelA0q6kVUkrktaCIPiVhP+WAHQC48AboEzzKBvuONB5noF3AVPAtxaCjsKO0ew66+DHgC8JBm5jAxhrJiavPQBckfRS0mSESUXh2v4kaU3SlsI1f2CeZ8x1S9KQpBGFe6UjQu+1pNkgCH77xBcXfB/wOWLGtoHHQK4F3ZzhbkdorwM32w3+NrDvED8EZoHuthyEPrqN1qHDzz4w0KpwP7DnEF0EMu0G7vCXMdo29oD+ZsVywA9LqGL+8qh1W+VmgRKwSZgqy+Z7CcjGcDuMj4rl+zu+y5Qwv390zMREDC8AZoATB7eKE2PTMHkAEw7uMj7vC+CJg1zwCH6uQeA25jwG8cjBK8YFPwicWqR5j0HPNBF8FdMeuvMW5xQYbER4bxG+AtdinGSpXzZrQB7oMVfe/FaLY+L3RC/1aXYxyviuY5bue8xSyRF83Vol3Fv2IEoe+mOOuO64DN9ZRh/ixA1v0+LlG9jmLdtNTx/LFu+ty+jIMhr1FLcr0Z4Gtj2WbdnTx6jFO6o+a5jTLwNqB2AvmaeeGlvW/VADW/uZzY3CM+t+qc6Cy76JjbErjfbGOPg70qghXO4XmSGdRynxnLMoJQyxnWJumnBpROHY2MQF/9DB9SvmjECOsIStRQUocvbldJF2yukasYs40NhJBGCXZg80NaIDRB8pCyR3pCyQ9JGyxkEf4QHbhW3zl7d6qC/S5qG+mbbKC0lTESbVtsqq/NoqwwpbK1H+X0kqJNJWqQXhW3EjYsaSwAYeb/92B1FtLe4kGPgOMMk590g7gQfAAq03dxeMRstVcZLt9SGF7fURSVm52+t7CtuPK5LWL7S9niJFihQp/gn8AXDP9oufq13tAAAAAElFTkSuQmCC",
	["crosshair"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAADC0lEQVRoge2asU4bQRCGZ1NHsmiSgspIRlCE4BeAIsg1ooMOpeJVQrpQQEpcQIVS8AJ5AqSk4ApIGihMAZGgASG+FLe213Nre+98Z/sk/sq+nX/2n7u93dmdE3nFZGHycAIYEVkSkXURqYvIgojMishba/IgItciEonImYj8EJFfxhjy6D8zgDqwC1ySHpeWW5+E8CpwnEF0PxwD1XEIrwBfgcccxbfxaH1XihI/D0QDBFwB+8AmsOJpX7Ft+9a2HyKglrf4NeDO09kT8A1YJn6RXU4PVJuxnD3rQ+MWWMtL/DbwrDp4AQ4ZMG4HBaDsqtbXi6I8A9ujil/ziL8DGgHcoAAc+wbJp/wMfMoqvuZxGAHzgfxUAViO7z27Je07QTzbaEcRMJPCR+oALG+mT9/hsxPxdObiLvTOOz5aDr+VkjsP/FMadkPJc/TO8y8EjHmPnw0bRAvYyMBv0PtiPxKy2JFcYQ/Tdp4XgKbScjSMUFeEp6CoC4IdDXqd6Mmd3ijOlvp/YIz5W6zM/jDG/BGR7+rypteYeHXUWeVy4SqHwDMqLlCrftvwozK88hqOGfbGXittS+12dwitK+7pxDccImI1nKrLHa1uAHpj8bMoURmgtXS0ugEsKKPrwuSkh9aymLAA7glDpoVpGOgufCG4b/OM4yDNeL8xxrzPOYCWiLwLtTfGGJHkOlA6uAE8BHJuRGSnAC071ncIklpJprArucobAcCq0ha129wnECne7HjkBUFrOW//cAM4U0arhclJD61Fay1vKqENS5fMdYaQzTlOFP/zuIQOgNZw0jdH80Q79RsaH6m8W0pLqlLmTb0ll/dYxToo98GWdVQjPtbTjqb/aNFxOO7DXT1ssh/uOo77Ha83gblRAyCeKpsUcbzudDKowLFHvH6kLXDUGVzgGO3Oe4KoMbzEdABskUx/sde2rI3ObVzkX2JygqgQl0aLKvLtUlSRTwVSBY5yFH/EJFIW4nH8hWyF7gvLHanQneenBh+k+6nBovg/NTiX7qcGv6fh5O8Vo+I/UeCznCCfR4oAAAAASUVORK5CYII=",
	["gauge"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAAC0UlEQVRoge2YO2wTQRRF30ZyA1WKgEiiSEGKQCAiFCdKlSJpcBUpjatItFBSRuLT86ncuAGJXwFJGsA0/BooAFNF0EVJAYWdQIkUJPtQeCyG5xln197dpNgrrWR577vvzHp2Zz0imTJlynSQCuIKAsZFZF5EpkXkuIgcM4eISN0cNRGpisi7IAi24urds4CzQBnYJrq2Te2ZtKEDYB6o9ADtU8VkxjYjfPBDwHoEsF1zhNUaMJQU/CJQ69J8A7gDFIARIGfV5sx3BePZ6JJTAxbjhr/hadYAngBTPWTmTW3Tk309LvhrngavgYkY8idMlktX+w1fcYTuAVeAgX7hrT4DJnPP0W+l19CCI+wXMBMXuKPnjOmhdSFq0CDwwwEfea5HFTDlGMR3YDBKyEMV8BvIJ8it++dNT1sPwhbPOn7CSwkzuzguOzhmwxSuqqJnJLBCAkWgbo4lx/kAeK5Ynu4XOk7r2d7WH2A0Afhl1afu8Y0ahrYatF4avcG31YjvpgDvHYDx31PeW93Cv1nGJnAqBfgGUOxSc5r/V+uvPuOICv6cEvxyiNqqqhtun7NX0wVV9ypOeBG5r/o1ReRiEASPQkRoFs0qApTUKDtNPaifK29lLKj6ksu0pkwnDgO8yRlWGasu0wdlyjmyojQtxgFvsnIq573LtGkZfvYDb/LqccBbefb70Wb7e/umslfbvq6+Q1FuWJ+6MwGf1BU70kczAZb496rgfc6HzDqq2D66TC+Vyb9kpyzgpGKrtM/ZU2hH1Z1PBy+UNMtu+4M9gC/KFO1fULLSLNUOBzCpfqYtkt5oCiFar9V65++cyzhA5ybU3AEwa645xbSDb0MBeKzML1LmdTHpLUz/o5jWroDWZIq8mkdPa4Dp/YreqoJySrwulrJieaM9rrl0MwW2XrU/G627vkRrl6wKjKUA5mMZMwx7hunAn4qZMmXKlOlw6S+/znsQLzCvmQAAAABJRU5ErkJggg==",
	["user-round"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAACtklEQVRoge2YP2/TQBjGX6NmKZHo1KUZTLsgkZ1/G5WCBBISYSISTPQDwAwfofxZygQrHQCJwhiVmU9AWLJVIplQCCURlX4MOUvuGzuxz2e7FXkkS3mdu+d53vPd6/OJLLDA/w3PJRmwIiK3RaQpIhdEZM38dSAiHRH5ICJ7nuf9dKmbGcAy8BQYMh9D03a5bN8iIgLUgW4C4xpdoF62+U1gYGE+wADYLMt8PcZ8G7gH+EDFXL65145JotgnwWTO62nTBxoJ+jZM2zC6FLkmmCzCMHqAn6K/H5HEkxwtHxNfYbrazB35CJ6G4hgC5/LwrIUfKOF2Bi69Ju6n5ThjodtU8WsLjgBvVHw3A1cyAB01an4GLl9xfXNoNVb0lxKtZOCqKK5BWg6bKXSiYJPAgYrXIlslg+6ruefCJoGOiq9YcAS4quLvGbiS4aSVURtRVy+yG4qjmBeZEddbiX6ackqZWwlj4HRv5oyRWdvpFtPb6Rbx2+mLhZoPJeHig+Z6KeZDSbRI9i2sMQRaZRpfB3YzjH6AXWC9aPNbwNiB+QBjYKsI40vAyxgTR8A+8Ai4BmwAVXNtmHuPTZujGI4XwFKe5vciREfANrCagmvV9BlF8H3MJQkzOhpfgFoGzprh0Hju0nsw5zV2yPAtEOKuAK8i+B+68B5UG71gd5yQH9fRSYyB8y6IdancdzHyETqViOn0NivpZUU4IsOcT6BXY3phX8pC+F6RbTv0G6f5TGm+syU6CxyGiP6SolTagkmJDb8nfmOzUwWaeu7n4DdOW6+FO3FtZ30T31TxZzf2EuGTim/FNZyVgC5hX63tpIfW8uMazkpAH3n8sHVjgZ6K0x/dMH0CV3XjLZF2VWnHntjNegKHod99z/OG7izOhtHqh279SU1iqlDPXPpEOneUrb/AAqcF/wBeUYgm6DTGZQAAAABJRU5ErkJggg==",
	["bot"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAABaElEQVRoge2YMVLDMBBFJUqTGi4FKXIL7gA9ZyA5DZOOk9gXyCTNo8CBjbBlWbIiG/Z1nlnv/9+xpayMURRFWSTABqgZpgY2pf3+ItD8d4hcPm5yNXa4y9U4JcCTMaaZykgsNldjgAsha7NoXesVyoYGKE1QAOAReAcOoetmR49QDq3WQ3I6oAJ2I8SnZgdUKQG2Bc2feYs1vy7tXLCOCbB3mrwCq6inMU531WpJ9jGNjk6T7OaF9srRPvbV9u6OcJ2dNFX/f+wDc0YD8DOZBU1eY+tTjF3gqZOT2eDkFVofqi9v8M64UwnF9pWh5S9nxQ218Yx+fcuYa2JouQ2tH3gYjbX23pg/9hHPYsYNoDFfXv2MeFfn8REnBMiyjIbq63+h0miA0vgCnOQFcJvZi9Ryh6dTZ6HxB/hwrl86Gk9Oq/E84CWo0bKH+jbEco9V2gAVZUNsSTnYEkFGHy0mMN3RoqIoSnY+AasNL0wvBWq1AAAAAElFTkSuQmCC",
	["wrench"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAAC8ElEQVRoge2YQUgUURjH/yNSEERFhBSBKGkIRUEXkY5SkAVCZYLHBK+Bh64ldAvqEhRBUGR0C6JbBoJSFlFdhBLyVEknEy2SXH8d5m1Mn29mR93dmYX9wx5mvv+87/fevLfveyPVla2CaiYDOiT1SDouqV3SPhdalDQjaUrS9SAI5qvJlSggAHqBV6TTF2BP1tySJKAFmEgJHtVI1uwCTgI/SoAWYu6Pp83TUCH4HklPJe0woRVJ9ySdltQmaaukIU8T3yrBlUpAG7DkGdVRoNl4+z1voQAczQq+AZjywF8BAuONg+/PBN5B9Xnghz2+/ME7sA8GamyzIw8cAR4B48AIlfqLBQ4ZqJ9Ai/F0rhPe19mvwK5KdOCySXTf45ncJHxR1yrRgScmyXkTbzRAG4UHGCt6y7kPtJvr5yX83tyuU6NxcaeD6+BKJ2AuMkILMZ7EKRQz8gVgyNwrf7EHfI8kWIzxxC7iBPh+1k6/inTgo0m+P8YXB2r17+0AB0xsutheOdfArLnu8ZmCIHgsaUDSauS25ViVNOC80to5PxP34Gb01lyfiTPGdKIoCy9JZ41nckOESQJumtf8G9hS4plOwoVdcL9JoNN4moE/pu2OcsP75vUC0Jjy+Uafl/A0N2ranaoGfAG4UIa2r3oWd285uIsJKlJVupEf9sBPYIrDqsG7aZK4JpyvFXjhgZ/HFIfVhO8jXBNFDQJ7I/GdzvOAsIq1WgZOZAWfVJgtupFN0hJwKo/wafQGsEViTcC/J5xSJTfaVCsaf4nr2zFL+W9JWpJ0TFKrws8uK5LmJX2S9FrSsyAIplUulWnkszmw1+Hr8BtQrcN31zL8NmC2JuEd0KWahXdQDw3QYIwvf/AO7F0EaA5P3Z1beAc3FoFaBppMPL/wkgTcMHAvgSbC09HFXMNLEtDFWi3z/yfDfMIXBdzxwNYGvCQB24HbCfCfge6sOaPyngeALknnJB2WtFvStMIvb3eDIPhVPby68q+/skEi4gAI/58AAAAASUVORK5CYII=",
	["settings-2"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAABSUlEQVRoge2XMW7CQBBF/wYlIhdIxElS+g7cAnIRmnCv9K5yA2hBSkSKR+ENMit7HVuAd9E8yYXX3/Ifa8eeLxmGYWQBMANWQAkc/FH6tdnY/loBHPAO7Gln7zVubL9nePPriPGQdVJF+Lfal+XYviWd9ny4bT6BApj6o/BrdXak0BNUzRmanzToJg1FrMbwHBorA1NFRFv03Wf/YAPMu3y2NhxwkPRYW3p2zv20aKeSvrseNoCtc+41Jni4wkNvSqyAr+D8LaKNXRvKVtJi8N3cQRPn/RmVMv+RSYNGiQ9SGiWkUxFLvzXa2HlNWubrkOs4bRjGdcj2o4Bl7BEh59GE3IdDxhrPgTlVPr00fTJ22abtbBBgI+llYP0x+mTsX+fcU5P2rjPxHwtV+fTS9MnYYT6/PVjGTgBy/pFJlrHTglzHacMwjDOOf1ZhXlVHNr4AAAAASUVORK5CYII=",
}
S._NavIconCache = {}

function S._DecodeNavIcon(data)
	local env = (getgenv and getgenv()) or _G
	local cryptApi = env and env.crypt
	local decoder
	if type(cryptApi) == "table" then
		if type(cryptApi.base64) == "table" then decoder = cryptApi.base64.decode end
		if type(decoder) ~= "function" then decoder = cryptApi.base64decode end
	end
	local synApi = env and env.syn
	if type(decoder) ~= "function" and type(synApi) == "table" and type(synApi.crypt) == "table"
		and type(synApi.crypt.base64) == "table" then
		decoder = synApi.crypt.base64.decode
	end
	if type(decoder) ~= "function" and env then decoder = env.base64_decode end
	if type(decoder) == "function" then
		local ok, decoded = pcall(decoder, data)
		if ok and type(decoded) == "string" then return decoded end
	end

	local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	local lookup = {}
	for index = 1, #alphabet do lookup[string.byte(alphabet, index)] = index - 1 end
	local output = {}
	for index = 1, #data, 4 do
		local a = lookup[string.byte(data, index)] or 0
		local b = lookup[string.byte(data, index + 1)] or 0
		local cByte, dByte = string.byte(data, index + 2), string.byte(data, index + 3)
		local c, d = lookup[cByte] or 0, lookup[dByte] or 0
		local packed = a * 262144 + b * 4096 + c * 64 + d
		output[#output + 1] = string.char(math.floor(packed / 65536) % 256)
		if cByte and cByte ~= 61 then output[#output + 1] = string.char(math.floor(packed / 256) % 256) end
		if dByte and dByte ~= 61 then output[#output + 1] = string.char(packed % 256) end
	end
	return table.concat(output)
end

function S._MakeNavIcon(parent, kind)
	local data = S._NavIconData[kind]
	local getter = getcustomasset or getsynasset
	if not data or type(getter) ~= "function" or type(writefile) ~= "function" then return nil end
	local path = "InertiaAssets/lucide48_" .. string.gsub(kind, "%-", "_") .. ".png"
	local exists = false
	if type(isfile) == "function" then
		local ok, result = pcall(isfile, path)
		exists = ok and result == true
	end
	if not exists then
		pcall(function()
			if type(makefolder) == "function" and (type(isfolder) ~= "function" or not isfolder("InertiaAssets")) then
				makefolder("InertiaAssets")
			end
		end)
		local ok = pcall(writefile, path, S._DecodeNavIcon(data))
		if not ok then return nil end
	end
	local asset = S._NavIconCache[kind]
	if not asset then
		local ok, result = pcall(getter, path)
		if not ok or type(result) ~= "string" then return nil end
		asset = result
		S._NavIconCache[kind] = asset
	end

	local slot = Instance.new("Frame")
	slot.Name = "NavIconSlot"
	slot.Parent = parent
	slot.Position = UDim2.new(0, 8, 0.5, -11)
	slot.Size = UDim2.fromOffset(22, 22)
	slot.BackgroundColor3 = T.Elev
	slot.BackgroundTransparency = 1
	slot.BorderSizePixel = 0
	Corner(slot, 6)

	local image = Instance.new("ImageLabel")
	image.Name = "NavIcon"
	image.Parent = slot
	image.AnchorPoint = Vector2.new(0.5, 0.5)
	image.Position = UDim2.fromScale(0.5, 0.5)
	image.Size = UDim2.fromOffset(16, 16)
	image.BackgroundTransparency = 1
	image.BorderSizePixel = 0
	image.Image = asset
	image.ImageColor3 = T.Tx3
	image.ImageTransparency = 0.06
	image.ScaleType = Enum.ScaleType.Fit
	return { slot = slot, image = image }
end


--------------------------------------------------------------------------------
-- GUI SHELL
--------------------------------------------------------------------------------
local SG = Instance.new("ScreenGui")
SG.Name = "PressureHub"
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.ResetOnSpawn = false
SG.DisplayOrder = 1000
SG.IgnoreGuiInset = true

local uiP
if gethui then pcall(function() uiP = gethui() end) end
if not uiP then pcall(function() uiP = game:GetService("CoreGui") end) end
if not uiP then uiP = LP:WaitForChild("PlayerGui") end
SG.Parent = uiP
S.Gui = SG

-- Toasts
local NHost = Instance.new("Frame")
NHost.Name = "Notifs"
NHost.Parent = SG
NHost.AnchorPoint = Vector2.new(1, 0)
NHost.BackgroundTransparency = 1
NHost.Position = UDim2.new(1, -20, 0, 74)
NHost.Size = UDim2.new(0, 330, 0, 190)
NHost.ZIndex = 900
local nLayout = Instance.new("UIListLayout")
nLayout.Parent = NHost
nLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
nLayout.SortOrder = Enum.SortOrder.LayoutOrder
nLayout.Padding = UDim.new(0, 6)

local refreshSB
local UIStyle = {
	Roots = { SG },
	BackgroundRoles = { "BG", "Sidebar", "Card", "Elev", "Hover", "ActiveBg", "Bd", "Bd2", "Tx3", "Tx4", "TgOff", "TgOn", "KnobOff", "KnobOn", "Accent", "White" },
	TextRoles = { "White", "Tx", "Tx2", "Tx3", "Tx4", "Accent" },
	StrokeRoles = { "Bd", "Bd2", "Accent", "White", "Tx", "Tx2", "Tx3" },
}

function UIStyle:ReplaceColor(object, property, oldPalette, roles)
	local ok, value = pcall(function() return object[property] end)
	if not ok or typeof(value) ~= "Color3" then return end
	for _, role in ipairs(roles) do
		if oldPalette[role] and value == oldPalette[role] and T[role] then
			pcall(function() object[property] = T[role] end)
			return
		end
	end
end

function UIStyle:ApplyTheme(name)
	local oldPalette = {}
	for key, value in pairs(T) do oldPalette[key] = value end
	S.UITheme = loadPalette(name)
	for _, themeRoot in ipairs(self.Roots) do
		if themeRoot and themeRoot.Parent then
			for _, object in ipairs(themeRoot:GetDescendants()) do
				if object:IsA("GuiObject") and not object:GetAttribute("StaticThemeColor") then
					self:ReplaceColor(object, "BackgroundColor3", oldPalette, self.BackgroundRoles)
				end
				if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
					self:ReplaceColor(object, "TextColor3", oldPalette, self.TextRoles)
					if object:IsA("TextBox") then self:ReplaceColor(object, "PlaceholderColor3", oldPalette, self.TextRoles) end
				elseif object:IsA("ImageLabel") or object:IsA("ImageButton") then
					self:ReplaceColor(object, "ImageColor3", oldPalette, self.TextRoles)
				elseif object:IsA("ScrollingFrame") then
					self:ReplaceColor(object, "ScrollBarImageColor3", oldPalette, self.TextRoles)
				elseif object:IsA("UIStroke") then
					self:ReplaceColor(object, "Color", oldPalette, self.StrokeRoles)
				elseif object:IsA("UIGradient") and object.Parent and object.Parent:IsA("GuiObject") then
					-- UIGradient multiplies the parent's color. Near-white masks preserve
					-- the selected palette instead of crushing cards to black.
					object.Color = ColorSequence.new(T.White:Lerp(T.Accent, 0.12), T.White:Lerp(T.Elev, 0.08))
				end
			end
		end
	end
	if refreshSB then pcall(refreshSB) end
	if S._refreshKeybindHUD then pcall(S._refreshKeybindHUD) end
	if S._refreshAppearance then pcall(S._refreshAppearance) end
end

function UIStyle:ApplyTextScale(scale)
	S.UITextScale = math.clamp(tonumber(scale) or 1, 0.88, 1.18)
	for _, themeRoot in ipairs(self.Roots) do
		if themeRoot and themeRoot.Parent then
			for _, object in ipairs(themeRoot:GetDescendants()) do
				if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
					local original = object:GetAttribute("PressureOriginalTextSize")
					if not original then
						original = object.TextSize
						pcall(function() object:SetAttribute("PressureOriginalTextSize", original) end)
					end
					object.TextSize = math.clamp(math.floor(original * S.UITextScale + 0.5), 8, 28)
				end
			end
		end
	end
	if S._refreshAppearance then pcall(S._refreshAppearance) end
end

UIStyle.NotificationPositions = {
	["Top Left"] = true, ["Top Center"] = true, ["Top Right"] = true,
	["Bottom Left"] = true, ["Bottom Center"] = true, ["Bottom Right"] = true,
}
function UIStyle:PlaceNotifications(value)
	S.NotificationPosition = self.NotificationPositions[value] and value or "Top Right"
	local top = S.NotificationPosition:sub(1, 3) == "Top"
	local left = S.NotificationPosition:sub(-4) == "Left"
	local right = S.NotificationPosition:sub(-5) == "Right"
	local x = left and 0 or (right and 1 or 0.5)
	local y = top and 0 or 1
	NHost.AnchorPoint = Vector2.new(x, y)
	NHost.Position = UDim2.new(x, left and 20 or (right and -20 or 0), y, top and 74 or -74)
	nLayout.HorizontalAlignment = left and Enum.HorizontalAlignment.Left or (right and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Center)
	nLayout.VerticalAlignment = top and Enum.VerticalAlignment.Top or Enum.VerticalAlignment.Bottom
	if S._refreshAppearance then pcall(S._refreshAppearance) end
end
UIStyle:PlaceNotifications(S.NotificationPosition)

local NOrder, ActiveN, RecentNotifs = 0, {}, {}
local function Notify(title, msg, dur, tone)
	if not NHost or not NHost.Parent then return end
	local toneKey = tone == "danger" and "danger" or tone == "warn" and "warn" or "info"
	local key = toneKey .. "\0" .. tostring(title or "") .. "\0" .. tostring(msg or "")
	local now = os.clock()
	if RecentNotifs[key] and now - RecentNotifs[key] < 1.1 then return end
	RecentNotifs[key] = now
	NOrder += 1
	dur = dur or 2.8
	local accent = toneKey == "info" and T.Accent or TONE[toneKey]
	SFX.Pop()

	local toast = Instance.new("Frame")
	toast.Name = "N"
	toast.Parent = NHost
	toast.BackgroundColor3 = T.Card
	toast.BorderSizePixel = 0
	toast.ClipsDescendants = true
	toast.LayoutOrder = NOrder
	toast.Size = UDim2.new(0, 276, 0, 0)
	toast.ZIndex = 901
	Corner(toast, 9)
	Stroke(toast, accent, 1, 0.58)
	Grad(toast, T.White:Lerp(T.Accent, 0.12), T.White:Lerp(T.Elev, 0.08), 90)

	local bar = Instance.new("Frame")
	bar.Parent = toast
	bar.BackgroundColor3 = accent
	bar.BorderSizePixel = 0
	bar.Size = UDim2.new(0, 2, 1, 0)
	bar.ZIndex = 902
	Corner(bar, 2)

	local sc = Instance.new("UIScale"); sc.Scale = 0.9; sc.Parent = toast

	local tt = Instance.new("TextLabel")
	tt.Parent = toast; tt.BackgroundTransparency = 1; tt.Font = FB
	tt.Position = UDim2.new(0, 16, 0, 8); tt.Size = UDim2.new(1, -28, 0, 17)
	tt.Text = string.upper(tostring(title or "")); tt.TextColor3 = T.White; tt.TextSize = 12
	tt.TextXAlignment = Enum.TextXAlignment.Left; tt.TextTruncate = Enum.TextTruncate.AtEnd; tt.ZIndex = 902

	local bt = Instance.new("TextLabel")
	bt.Parent = toast; bt.BackgroundTransparency = 1; bt.Font = F
	bt.Position = UDim2.new(0, 16, 0, 25); bt.Size = UDim2.new(1, -28, 0, 17)
	bt.Text = tostring(msg or ""); bt.TextColor3 = T.Tx2; bt.TextSize = 11
	bt.TextXAlignment = Enum.TextXAlignment.Left; bt.TextTruncate = Enum.TextTruncate.AtEnd; bt.ZIndex = 902

	local timer = Instance.new("Frame")
	timer.Parent = toast; timer.AnchorPoint = Vector2.new(0, 1)
	timer.Position = UDim2.new(0, 2, 1, -1); timer.Size = UDim2.new(1, -2, 0, 1)
	timer.BackgroundColor3 = accent; timer.BackgroundTransparency = 0.15; timer.BorderSizePixel = 0; timer.ZIndex = 902
	Corner(timer, 1)

	table.insert(ActiveN, toast)
	if #ActiveN > 3 then
		local old = table.remove(ActiveN, 1)
		if old and old.Parent then old:Destroy() end
	end

	Tween(toast, 0.28, { Size = UDim2.new(0, 324, 0, 52) }, Enum.EasingStyle.Back):Play()
	Tween(sc, 0.3, { Scale = 1 }, Enum.EasingStyle.Back):Play()
	Tween(timer, dur, { Size = UDim2.new(0, 0, 0, 1) }, Enum.EasingStyle.Linear):Play()

	task.delay(dur, function()
		if not toast.Parent then return end
		for i, t in ipairs(ActiveN) do if t == toast then table.remove(ActiveN, i); break end end
		Tween(toast, 0.22, { BackgroundTransparency = 1, Size = UDim2.new(0, 276, 0, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
		task.wait(0.27)
		if toast.Parent then toast:Destroy() end
	end)
end
-- Warning banner
local WarnFrame = Instance.new("Frame")
WarnFrame.Name = "EntityAlert"
WarnFrame.Parent = SG
WarnFrame.AnchorPoint = Vector2.new(0.5, 0)
WarnFrame.Position = UDim2.new(0.5, 0, 0.11, 0)
WarnFrame.Size = UDim2.new(0, 404, 0, 58)
WarnFrame.BackgroundColor3 = Color3.fromRGB(16, 13, 14)
WarnFrame.BackgroundTransparency = 0.05
WarnFrame.Visible = false
WarnFrame.ZIndex = 890
Corner(WarnFrame, 9)
Stroke(WarnFrame, Color3.fromRGB(255, 88, 88), 1, 0.3)
Grad(WarnFrame, Color3.fromRGB(30, 17, 18), Color3.fromRGB(12, 11, 13), 90)

local warnBar = Instance.new("Frame")
warnBar.Parent = WarnFrame
warnBar.BackgroundColor3 = Color3.fromRGB(255, 88, 88)
warnBar.BorderSizePixel = 0
warnBar.Size = UDim2.new(0, 3, 1, 0)
warnBar.ZIndex = 891
Corner(warnBar, 2)

local warnScale = Instance.new("UIScale"); warnScale.Parent = WarnFrame

local WarnTxt = Instance.new("TextLabel")
WarnTxt.Parent = WarnFrame; WarnTxt.BackgroundTransparency = 1
WarnTxt.Position = UDim2.new(0, 17, 0, 8); WarnTxt.Size = UDim2.new(1, -95, 0, 18)
WarnTxt.Font = FB; WarnTxt.TextColor3 = Color3.fromRGB(255, 238, 238); WarnTxt.TextSize = 15
WarnTxt.TextXAlignment = Enum.TextXAlignment.Left; WarnTxt.Text = "ENTITY INCOMING"; WarnTxt.TextTruncate = Enum.TextTruncate.AtEnd; WarnTxt.ZIndex = 891

local warnPill = Instance.new("TextLabel")
warnPill.Parent = WarnFrame; warnPill.AnchorPoint = Vector2.new(1, 0)
warnPill.Position = UDim2.new(1, -10, 0, 9); warnPill.Size = UDim2.fromOffset(66, 15)
warnPill.BackgroundColor3 = Color3.fromRGB(255, 88, 88); warnPill.BackgroundTransparency = 0.78
warnPill.BorderSizePixel = 0; warnPill.Font = FB; warnPill.TextSize = 8; warnPill.TextColor3 = Color3.fromRGB(255, 150, 150)
warnPill.Text = "THREAT"; warnPill.ZIndex = 891
Corner(warnPill, 5)

local WarnSub = Instance.new("TextLabel")
WarnSub.Parent = WarnFrame; WarnSub.BackgroundTransparency = 1
WarnSub.Position = UDim2.new(0, 17, 0, 30); WarnSub.Size = UDim2.new(1, -30, 0, 16)
WarnSub.Font = F; WarnSub.TextColor3 = Color3.fromRGB(220, 177, 179); WarnSub.TextSize = 11
WarnSub.TextXAlignment = Enum.TextXAlignment.Left; WarnSub.Text = "Get to cover"; WarnSub.ZIndex = 891

local warnToken = 0
local WarnCooldown = {}
local function ShowEntityWarning(entityName, subText)
	if not S.EntityWarning then return end
	local key = string.upper(tostring(entityName))
	local now = os.clock()
	if WarnCooldown[key] and now - WarnCooldown[key] < 8 then return end
	WarnCooldown[key] = now
	warnToken += 1
	local my = warnToken
	WarnTxt.Text = key
	WarnSub.Text = "THREAT // " .. (subText or "Get to cover / hide")
	WarnFrame.Visible = true
	warnScale.Scale = 0.85
	Tween(warnScale, 0.25, { Scale = 1 }, Enum.EasingStyle.Back):Play()
	if S.WarningSound then snd("rbxassetid://9114223177", 1, 0.6) end
	task.delay(3.5, function() if warnToken == my then WarnFrame.Visible = false end end)
end

-- Main window
local WW, WH = 920, 590

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = SG
Main.Active = true
Main.BackgroundColor3 = T.BG
Main.BorderSizePixel = 0
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.Size = UDim2.fromOffset(WW, WH)
Main.ClipsDescendants = true
Main.Visible = false
Corner(Main, 14)
Stroke(Main, T.Bd, 1, 0.1)
Shadow(Main, 0.2)
local mainScale = Instance.new("UIScale"); mainScale.Parent = Main
mainScale.Scale = 0.9

-- Title bar
local TBar = Instance.new("Frame")
TBar.Name = "TBar"
TBar.Parent = Main
TBar.BackgroundTransparency = 1
TBar.Size = UDim2.new(1, 0, 0, 50)
TBar.Position = UDim2.new(0, 0, 0, 1)
TBar.Active = true

local TTitle = Instance.new("TextLabel")
TTitle.Parent = TBar; TTitle.BackgroundTransparency = 1
TTitle.Position = UDim2.new(0, 18, 0, 7); TTitle.Size = UDim2.new(0, 180, 0, 20)
TTitle.Font = FB; TTitle.Text = "PRESSURE"; TTitle.TextColor3 = T.White; TTitle.TextSize = 17
TTitle.TextXAlignment = Enum.TextXAlignment.Left

local TSub = Instance.new("TextLabel")
TSub.Parent = TBar; TSub.BackgroundTransparency = 1
TSub.Position = UDim2.new(0, 18, 0, 27); TSub.Size = UDim2.new(0, 180, 0, 15)
TSub.Font = F; TSub.Text = "HADAL BLACKSITE"; TSub.TextColor3 = T.Tx3; TSub.TextSize = 12
TSub.TextXAlignment = Enum.TextXAlignment.Left

-- Search bar
local UIRegistry = {}
local SearchEmpty
local SearchBox = Instance.new("TextBox")
SearchBox.Parent = TBar
SearchBox.AnchorPoint = Vector2.new(1, 0.5)
-- Right edge at WW-100: btnMin's left edge sits at WW-84, so this leaves a
-- real 16px gap instead of the ~2px it had before (search box and minimize
-- button were nearly touching).
SearchBox.Position = UDim2.new(1, -100, 0.5, 0)
SearchBox.Size = UDim2.new(0, 170, 0, 28)
SearchBox.BackgroundColor3 = T.Elev
SearchBox.BorderSizePixel = 0
SearchBox.Font = F; SearchBox.TextSize = 13; SearchBox.TextColor3 = T.Tx
SearchBox.PlaceholderText = "Search..."
SearchBox.PlaceholderColor3 = T.Tx3
SearchBox.Text = ""
SearchBox.ClearTextOnFocus = false
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
Corner(SearchBox, 6)
Stroke(SearchBox, T.Bd2, 1, 0.4)
Pad(SearchBox, 0, 0, 8, 20)

local ClearSearchBtn = Instance.new("TextButton")
ClearSearchBtn.Parent = SearchBox
ClearSearchBtn.AnchorPoint = Vector2.new(1, 0.5)
ClearSearchBtn.Position = UDim2.new(1, -3, 0.5, 0)
ClearSearchBtn.Size = UDim2.new(0, 16, 0, 16)
ClearSearchBtn.BackgroundTransparency = 1
ClearSearchBtn.Font = FB; ClearSearchBtn.Text = "x"; ClearSearchBtn.TextColor3 = T.Tx3; ClearSearchBtn.TextSize = 12
ClearSearchBtn.Visible = false
ClearSearchBtn.MouseButton1Click:Connect(function() SearchBox.Text = "" end)

local Pages, activePage = {}, nil
local function applySearch()
	local q = string.lower(SearchBox.Text):gsub("^%s+", ""):gsub("%s+$", "")
	local tokens = {}
	for w in string.gmatch(q, "%S+") do table.insert(tokens, w) end
	ClearSearchBtn.Visible = (#tokens > 0)
	local cardVis = {}
	local matches = 0
	for _, e in ipairs(UIRegistry) do
		if e.row and e.row.Parent then
			local vis = true
			if #tokens > 0 then
				local hay = e.label .. " " .. string.lower(e.card and e.card.Name or "")
				for _, tok in ipairs(tokens) do
					if not string.find(hay, tok, 1, true) then vis = false; break end
				end
			end
			e.row.Visible = vis
			if vis then
				matches += 1
				if e.card then cardVis[e.card] = true end
			end
		end
	end
	for _, e in ipairs(UIRegistry) do
		if e.card then e.card.Visible = (#tokens == 0) or (cardVis[e.card] == true) end
	end
	if #tokens == 0 then
		for _, pg in pairs(Pages) do pg.Visible = (pg == activePage) end
	else
		for _, pg in pairs(Pages) do pg.Visible = true end
	end
	SearchEmpty.Visible = #tokens > 0 and matches == 0
end
SearchBox:GetPropertyChangedSignal("Text"):Connect(applySearch)

-- Window buttons
local function mkWinBtn(txt, xOff)
	local b = Instance.new("TextButton")
	b.Parent = TBar
	b.AnchorPoint = Vector2.new(1, 0.5)
	b.Position = UDim2.new(1, xOff, 0.5, 0)
	b.Size = UDim2.new(0, 32, 0, 28)
	b.BackgroundColor3 = T.Elev
	b.BorderSizePixel = 0
	b.AutoButtonColor = false
	b.Font = FB; b.TextSize = 14; b.Text = txt; b.TextColor3 = T.Tx2
	Corner(b, 7)
	Stroke(b, T.Bd, 1, 0.4)
	b.MouseEnter:Connect(function() Tween(b, 0.12, { BackgroundColor3 = T.Hover }):Play(); b.TextColor3 = T.White end)
	b.MouseLeave:Connect(function() Tween(b, 0.12, { BackgroundColor3 = T.Elev }):Play(); b.TextColor3 = T.Tx2 end)
	return b
end
local btnClose = mkWinBtn("X", -16)
local btnMin = mkWinBtn("-", -52)

-- Menu visibility drives mouse unlock: the mouse is free ONLY while this
-- menu is open. No toggle, no Alt bind — closing the menu instantly hands
-- the mouse back to first-person aim.
local menuOpen = false
local function setMenuVisible(v)
	if v == menuOpen and Main.Visible == v then return end
	menuOpen = v
	if v then
		Main.Visible = true
		mainScale.Scale = 0.88
		Tween(mainScale, 0.22, { Scale = 1 }, Enum.EasingStyle.Back):Play()
		SFX.On()
	else
		SFX.Off()
		Tween(mainScale, 0.15, { Scale = 0.9 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
		task.delay(0.15, function() if not menuOpen then Main.Visible = false end end)
		pcall(function() UIS.MouseBehavior = Enum.MouseBehavior.LockCenter; UIS.MouseIconEnabled = false end)
	end
end
-- BindToRenderStep at Camera+1 instead of a plain RenderStepped:Connect —
-- Pressure's own CameraModule re-locks the mouse from inside the Camera
-- render step, so a normal Connect (which can run before it) loses the
-- fight most frames. Running one step after Camera guarantees we always go
-- last. Unbound in Destroy since BindToRenderStep isn't a Connection.
RunService:BindToRenderStep("PressureMouseUnlock", Enum.RenderPriority.Camera.Value + 1, function()
	if menuOpen and Main.Visible then
		pcall(function() UIS.MouseBehavior = Enum.MouseBehavior.Default; UIS.MouseIconEnabled = true end)
	end
end)

-- btnMin's click handler is wired further down, once Sidebar/Footer/etc.
-- exist — minimizing has to hide them explicitly (see there for why).
btnClose.MouseButton1Click:Connect(function() setMenuVisible(false) end)
tc(UIS.InputBegan:Connect(function(input)
	local typing = false
	pcall(function() typing = UIS:GetFocusedTextBox() ~= nil end)
	if not typing and input.KeyCode == S.MenuKeybind then
		setMenuVisible(not menuOpen)
	end
end))

-- Window drag
do
	local dragging, dragStart, startPos = false, nil, nil
	tc(TBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			-- TextBox and title-bar buttons bubble input through TBar.  Without
			-- this hit test, clicking Search starts a window drag and makes the
			-- search feel broken.
			local pos = input.Position
			local function over(gui)
				local p, s = gui.AbsolutePosition, gui.AbsoluteSize
				return pos.X >= p.X and pos.X <= p.X + s.X and pos.Y >= p.Y and pos.Y <= p.Y + s.Y
			end
			if over(SearchBox) or over(btnClose) or over(btnMin) then return end
			dragging = true; dragStart = input.Position; startPos = Main.Position
			local endConn
			endConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if endConn then endConn:Disconnect() end
				end
			end)
		end
	end))
	tc(UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end))
end

--------------------------------------------------------------------------------
-- SIDEBAR + CONTENT
--------------------------------------------------------------------------------
local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Parent = Main
Body.BackgroundTransparency = 1
Body.Position = UDim2.new(0, 0, 0, 51)
Body.Size = UDim2.new(1, 0, 1, -83)

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = Body
Sidebar.BackgroundColor3 = T.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Position = UDim2.fromOffset(8, 0)
Sidebar.Size = UDim2.new(0, 144, 1, -8)
-- ClipsDescendants on Main clips to a plain RECTANGLE, not the rounded shape
-- UICorner draws — so a flat-cornered child poked a sharp square corner
-- through Main's rounded edge (worst at bottom-left, where Sidebar meets
-- Footer). Matching Main's own radius here rounds it away; the two corners
-- this creates mid-window (top-right/bottom-right of Sidebar) sit against
-- Main's own near-identical near-black BG, invisible in practice.
Corner(Sidebar, 10)
Stroke(Sidebar, T.Bd2, 1, 0.32)
Pad(Sidebar, 8, 8, 8, 8)
local SBLayout = Instance.new("UIListLayout")
SBLayout.Parent = Sidebar
SBLayout.SortOrder = Enum.SortOrder.LayoutOrder
SBLayout.Padding = UDim.new(0, 4)

local openAppearance
do
local ProfileButton = Instance.new("TextButton")
ProfileButton.Name = "Profile"
ProfileButton.Parent = Sidebar
ProfileButton.LayoutOrder = -100
ProfileButton.Size = UDim2.new(1, 0, 0, 50)
ProfileButton.BackgroundColor3 = T.Card
ProfileButton.BorderSizePixel = 0
ProfileButton.AutoButtonColor = false
ProfileButton.Text = ""
Corner(ProfileButton, 9)
Stroke(ProfileButton, T.Bd2, 1, 0.34)
local ProfileTitle = Instance.new("TextLabel")
ProfileTitle.Parent = ProfileButton; ProfileTitle.BackgroundTransparency = 1
ProfileTitle.Position = UDim2.fromOffset(11, 7); ProfileTitle.Size = UDim2.new(1, -22, 0, 18)
ProfileTitle.Font = FB; ProfileTitle.TextSize = 12; ProfileTitle.TextColor3 = T.White
ProfileTitle.TextXAlignment = Enum.TextXAlignment.Left; ProfileTitle.Text = "PRESSURE"
local ProfileSub = Instance.new("TextLabel")
ProfileSub.Parent = ProfileButton; ProfileSub.BackgroundTransparency = 1
ProfileSub.Position = UDim2.fromOffset(11, 25); ProfileSub.Size = UDim2.new(1, -22, 0, 16)
ProfileSub.Font = F; ProfileSub.TextSize = 10; ProfileSub.TextColor3 = T.Tx3
ProfileSub.TextXAlignment = Enum.TextXAlignment.Left; ProfileSub.TextTruncate = Enum.TextTruncate.AtEnd
ProfileSub.Text = "@" .. tostring(LP.Name)
ProfileButton.MouseEnter:Connect(function() Tween(ProfileButton, 0.14, { BackgroundColor3 = T.Hover }):Play() end)
ProfileButton.MouseLeave:Connect(function() Tween(ProfileButton, 0.14, { BackgroundColor3 = T.Card }):Play() end)
ProfileButton.MouseButton1Click:Connect(function() if openAppearance then openAppearance() end end)
end

-- Divider: parented to Body (NOT Sidebar) on purpose. Sidebar's UIListLayout
-- treats every GuiObject child as a stack item — a Scale-height decorative
-- line sitting inside it would get a full-height slot and push every real
-- tab button below the window's clipped bounds. This is the exact bug class
-- that made the sidebar tabs vanish before; the fix is structural, not a
-- one-off patch.
local SBLine = Instance.new("Frame")
SBLine.Name = "SBLine"
SBLine.Parent = Body
SBLine.BackgroundColor3 = T.Bd
SBLine.BorderSizePixel = 0
SBLine.Position = UDim2.new(0, 157, 0, 8)
SBLine.Size = UDim2.new(0, 1, 1, -24)
Corner(SBLine, 1)

local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Name = "Content"
ContentArea.Parent = Body
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.Position = UDim2.new(0, 164, 0, 0)
ContentArea.Size = UDim2.new(1, -172, 1, 0)
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentArea.ScrollBarThickness = 3
ContentArea.ScrollBarImageColor3 = T.Tx3

SearchEmpty = Instance.new("TextLabel")
SearchEmpty.Name = "SearchEmpty"
SearchEmpty.Parent = Main
SearchEmpty.BackgroundTransparency = 1
SearchEmpty.Position = UDim2.new(0, 164, 0, 51)
SearchEmpty.Size = UDim2.new(1, -172, 1, -83)
SearchEmpty.Font = FM; SearchEmpty.TextSize = 14; SearchEmpty.TextColor3 = T.Tx3
SearchEmpty.TextXAlignment = Enum.TextXAlignment.Center; SearchEmpty.TextYAlignment = Enum.TextYAlignment.Center
SearchEmpty.Text = "No matching functions"
SearchEmpty.Visible = false
SearchEmpty.ZIndex = 20

-- Footer
local Footer = Instance.new("Frame")
Footer.Parent = Main
Footer.BackgroundColor3 = T.Sidebar
Footer.BorderSizePixel = 0
Footer.AnchorPoint = Vector2.new(0, 1)
Footer.Position = UDim2.new(0, 0, 1, 0)
Footer.Size = UDim2.new(1, 0, 0, 32)
Corner(Footer, 14)

local FootLeft = Instance.new("TextLabel")
FootLeft.Parent = Footer; FootLeft.BackgroundTransparency = 1
FootLeft.Position = UDim2.new(0, 16, 0, 0); FootLeft.Size = UDim2.new(0, 200, 1, 0)
FootLeft.Font = FM; FootLeft.Text = "PRESSURE HUB"; FootLeft.TextColor3 = T.Tx3; FootLeft.TextSize = 12
FootLeft.TextXAlignment = Enum.TextXAlignment.Left

local FootMid = Instance.new("TextLabel")
FootMid.Parent = Footer; FootMid.BackgroundTransparency = 1
FootMid.AnchorPoint = Vector2.new(0.5, 0); FootMid.Position = UDim2.new(0.5, 0, 0, 0)
FootMid.Size = UDim2.new(0, 280, 1, 0)
FootMid.Font = FM; FootMid.Text = ""; FootMid.TextColor3 = T.Tx2; FootMid.TextSize = 12

local FootRight = Instance.new("TextLabel")
FootRight.Parent = Footer; FootRight.BackgroundTransparency = 1
FootRight.AnchorPoint = Vector2.new(1, 0); FootRight.Position = UDim2.new(1, -16, 0, 0)
FootRight.Size = UDim2.new(0, 220, 1, 0)
FootRight.Font = F; FootRight.Text = "Insert — menu"; FootRight.TextColor3 = T.Tx3; FootRight.TextSize = 12
FootRight.TextXAlignment = Enum.TextXAlignment.Right

-- Minimize has to explicitly hide these, not just shrink Main and rely on
-- ClipsDescendants: Footer is anchored to Main's own BOTTOM edge via Scale,
-- so as Main's height tweens down to just the title bar, Footer's anchor
-- rides that shrinking edge up and ends up rendered directly under the
-- title bar instead of disappearing — a second bar squeezed in with no
-- content between them, mid-tween showing a jarring half-clipped flash of
-- Sidebar/ContentArea. Hiding them outright avoids all of that.
local isMinimized = false
btnMin.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		Sidebar.Visible = false; SBLine.Visible = false; ContentArea.Visible = false; Footer.Visible = false; SearchEmpty.Visible = false
		Main:TweenSize(UDim2.fromOffset(WW, 51), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.22, true)
	else
		Main:TweenSize(UDim2.fromOffset(WW, WH), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.22, true, function()
			Sidebar.Visible = true; SBLine.Visible = true; ContentArea.Visible = true; Footer.Visible = true
			applySearch()
		end)
	end
end)

local function mkPage(name)
	local sf = Instance.new("Frame")
	sf.Name = name
	sf.Parent = ContentArea
	sf.BackgroundTransparency = 1
	sf.BorderSizePixel = 0
	sf.Size = UDim2.new(1, 0, 0, 0)
	sf.AutomaticSize = Enum.AutomaticSize.Y
	sf.Visible = false
	local l = Instance.new("UIListLayout")
	l.Parent = sf; l.SortOrder = Enum.SortOrder.LayoutOrder; l.Padding = UDim.new(0, 12)
	Pad(sf, 8, 12, 6, 8)
	Pages[name] = sf
	return sf
end

local TAB_DEFS = {
	{ name = "Visuals", icon = "eye" },
	{ name = "Combat", icon = "crosshair" },
	{ name = "Motion", icon = "gauge" },
	{ name = "Player", icon = "user-round" },
	{ name = "Auto", icon = "bot" },
	{ name = "Misc", icon = "wrench" },
	{ name = "Config", icon = "settings-2" },
}

local SBItems = {}

local function mkSBItem(name, iconKind, page, order)
	local btn = Instance.new("TextButton")
	btn.Name = "Tab_" .. name
	btn.Parent = Sidebar
	btn.LayoutOrder = order
	btn.Size = UDim2.new(1, 0, 0, 34)
	btn.AutoButtonColor = false
	btn.BackgroundTransparency = 1
	btn.BorderSizePixel = 0
	btn.Text = ""
	Corner(btn, 8)

	local barInd = Instance.new("Frame")
	barInd.Parent = btn
	barInd.Size = UDim2.new(0, 3, 0, 20)
	barInd.Position = UDim2.new(0, 0, 0.5, -10)
	barInd.BackgroundColor3 = T.Accent
	barInd.BorderSizePixel = 0
	barInd.Visible = false
	Corner(barInd, 2)

	local icon = S._MakeNavIcon(btn, iconKind)
	local label = Instance.new("TextLabel")
	label.Parent = btn; label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, icon and 38 or 13, 0, 0)
	label.Size = UDim2.new(1, icon and -48 or -20, 1, 0)
	label.Font = F; label.TextSize = 14; label.TextColor3 = T.Tx2
	label.TextXAlignment = Enum.TextXAlignment.Left; label.TextTruncate = Enum.TextTruncate.AtEnd; label.Text = name

	local item = { btn = btn, bar = barInd, icon = icon, label = label, page = page }

	btn.MouseEnter:Connect(function()
		if activePage ~= page then
			Tween(btn, 0.12, { BackgroundTransparency = 0.55 }):Play()
			Tween(btn, 0.12, { BackgroundColor3 = T.Elev }):Play()
		end
	end)
	btn.MouseLeave:Connect(function() refreshSB() end)
	btn.MouseButton1Click:Connect(function()
		activePage = page
		for _, p in pairs(Pages) do p.Visible = (p == page) end
		refreshSB()
		SFX.Click()
	end)

	table.insert(SBItems, item)
	return item
end

refreshSB = function()
	for _, item in ipairs(SBItems) do
		local on = (item.page == activePage)
		item.bar.Visible = on
		if item.icon then
			item.icon.image.ImageColor3 = on and T.White or T.Tx3
			item.icon.image.ImageTransparency = on and 0 or 0.06
			item.icon.slot.BackgroundColor3 = on and T.ActiveBg or T.Elev
			item.icon.slot.BackgroundTransparency = on and 0.24 or 1
		end
		item.label.TextColor3 = on and T.White or T.Tx2
		item.label.Font = on and FM or F
		item.btn.BackgroundColor3 = on and T.ActiveBg or T.Elev
		item.btn.BackgroundTransparency = on and 0.16 or 1
	end
end

for index, tab in ipairs(TAB_DEFS) do
	local page = mkPage(tab.name)
	mkSBItem(tab.name, tab.icon, page, index)
end
do
	local card = Instance.new("Frame")
	card.Name = "QuickStatus"; card.Parent = Sidebar; card.LayoutOrder = 100
	card.Size = UDim2.new(1, 0, 0, 94); card.BackgroundColor3 = T.Card; card.BorderSizePixel = 0
	Corner(card, 9); Stroke(card, T.Bd2, 1, 0.28)
	local headMark = Instance.new("Frame")
	headMark.Parent = card; headMark.Position = UDim2.fromOffset(9, 7); headMark.Size = UDim2.fromOffset(2, 11)
	headMark.BackgroundColor3 = T.Accent; headMark.BorderSizePixel = 0; Corner(headMark, 2)
	local heading = Instance.new("TextLabel")
	heading.Parent = card; heading.BackgroundTransparency = 1
	heading.Position = UDim2.fromOffset(17, 4); heading.Size = UDim2.new(1, -35, 0, 18)
	heading.Font = FB; heading.TextSize = 10; heading.TextColor3 = T.Tx2
	heading.TextXAlignment = Enum.TextXAlignment.Left; heading.Text = "QUICK STATUS"
	local stateDot = Instance.new("Frame")
	stateDot.Parent = card; stateDot.AnchorPoint = Vector2.new(1, 0.5)
	stateDot.Position = UDim2.new(1, -9, 0, 13); stateDot.Size = UDim2.fromOffset(5, 5)
	stateDot.BackgroundColor3 = T.Accent; stateDot.BorderSizePixel = 0; Corner(stateDot, 5)
	local divider = Instance.new("Frame")
	divider.Parent = card; divider.Position = UDim2.fromOffset(9, 25); divider.Size = UDim2.new(1, -18, 0, 1)
	divider.BackgroundColor3 = T.Bd; divider.BackgroundTransparency = 0.48; divider.BorderSizePixel = 0
	local body = Instance.new("Frame")
	body.Parent = card; body.BackgroundTransparency = 1
	body.Position = UDim2.fromOffset(0, 27); body.Size = UDim2.new(1, 0, 1, -29)
	local function statusRow(keyText, index)
		local row = Instance.new("Frame")
		row.Parent = body; row.BackgroundTransparency = 1
		row.Position = UDim2.new(0, 9, 0, (index - 1) * 21); row.Size = UDim2.new(1, -18, 0, 21)
		if index > 1 then
			local line = Instance.new("Frame")
			line.Parent = row; line.Size = UDim2.new(1, 0, 0, 1)
			line.BackgroundColor3 = T.Bd; line.BackgroundTransparency = 0.62; line.BorderSizePixel = 0
		end
		local key = Instance.new("TextLabel")
		key.Parent = row; key.BackgroundTransparency = 1; key.Size = UDim2.new(0, 48, 1, 0)
		key.Font = F; key.TextSize = 9; key.TextColor3 = T.Tx4; key.TextXAlignment = Enum.TextXAlignment.Left; key.Text = keyText
		local value = Instance.new("TextLabel")
		value.Parent = row; value.BackgroundTransparency = 1; value.Position = UDim2.fromOffset(48, 0)
		value.Size = UDim2.new(1, -48, 1, 0); value.Font = FM; value.TextSize = 10; value.TextColor3 = T.Tx
		value.TextXAlignment = Enum.TextXAlignment.Right; value.TextTruncate = Enum.TextTruncate.AtEnd; value.Text = "--"
		return value
	end
	local roomValue = statusRow("ROOM", 1)
	local stateValue = statusRow("STATE", 2)
	local networkValue = statusRow("PING", 3)
	task.spawn(function()
		while not S.Destroyed and card.Parent do
			local room = LP:GetAttribute("RoomNum") or LP:GetAttribute("CurrentRoom") or "--"
			local ping = math.floor((LP:GetNetworkPing() or 0) * 1000 + 0.5)
			local active = S.Ready ~= false
			roomValue.Text = tostring(room)
			stateValue.Text = active and "ACTIVE" or "WAITING"
			stateValue.TextColor3 = active and T.Accent or T.Tx3
			stateDot.BackgroundColor3 = active and T.Accent or T.Tx4
			stateDot.BackgroundTransparency = active and 0 or 0.45
			networkValue.Text = tostring(ping) .. " ms"
			task.wait(0.75)
		end
	end)
end
activePage = Pages.Visuals
Pages.Visuals.Visible = true
refreshSB()

--------------------------------------------------------------------------------
-- CONTROL BUILDERS
--------------------------------------------------------------------------------
local CfgBind = {}
-- Assigned once SaveConfigFile exists (Config tab, later in the file). Every
-- mkToggle/mkSlider closure below captures this local as an upvalue, so the
-- forward reference resolves fine by the time a real click can happen.
local RequestAutoSave

openAppearance = (function()
	local panel = Instance.new("Frame")
	panel.Name = "AppearanceSettings"
	panel.Parent = SG
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromOffset(320, 402)
	panel.BackgroundColor3 = T.Card
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.ZIndex = 1500
	Corner(panel, 12)
	Stroke(panel, T.Bd2, 1, 0.18)
	Grad(panel, T.White:Lerp(T.Accent, 0.10), T.White:Lerp(T.Elev, 0.06), 90)
	local scale = Instance.new("UIScale"); scale.Parent = panel

	local title = Instance.new("TextLabel")
	title.Parent = panel; title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(16, 12); title.Size = UDim2.new(1, -58, 0, 24)
	title.Font = FB; title.TextSize = 15; title.TextColor3 = T.White
	title.TextXAlignment = Enum.TextXAlignment.Left; title.Text = "INTERFACE"
	local subtitle = Instance.new("TextLabel")
	subtitle.Parent = panel; subtitle.BackgroundTransparency = 1
	subtitle.Position = UDim2.fromOffset(16, 34); subtitle.Size = UDim2.new(1, -32, 0, 18)
	subtitle.Font = F; subtitle.TextSize = 10; subtitle.TextColor3 = T.Tx3
	subtitle.TextXAlignment = Enum.TextXAlignment.Left; subtitle.Text = "Theme, readability and notification placement"

	local close = Instance.new("TextButton")
	close.Parent = panel; close.AnchorPoint = Vector2.new(1, 0)
	close.Position = UDim2.new(1, -12, 0, 12); close.Size = UDim2.fromOffset(26, 26)
	close.BackgroundColor3 = T.Elev; close.BorderSizePixel = 0; close.AutoButtonColor = false
	close.Font = FM; close.TextSize = 18; close.TextColor3 = T.Tx2; close.Text = "×"; close.ZIndex = 1502
	Corner(close, 7); Stroke(close, T.Bd2, 1, 0.4)

	local body = Instance.new("Frame")
	body.Parent = panel; body.BackgroundTransparency = 1
	body.Position = UDim2.fromOffset(14, 62); body.Size = UDim2.new(1, -28, 1, -76)
	local layout = Instance.new("UIListLayout")
	layout.Parent = body; layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0, 8)
	local choiceRefreshers = {}

	local function makeChoice(labelText, values, getValue, onValue, order, display)
		local row = Instance.new("Frame")
		row.Parent = body; row.LayoutOrder = order; row.Size = UDim2.new(1, 0, 0, 52)
		row.BackgroundColor3 = T.BG; row.BorderSizePixel = 0
		Corner(row, 9); Stroke(row, T.Bd2, 1, 0.42)
		local label = Instance.new("TextLabel")
		label.Parent = row; label.BackgroundTransparency = 1
		label.Position = UDim2.fromOffset(10, 5); label.Size = UDim2.new(1, -20, 0, 17)
		label.Font = F; label.TextSize = 10; label.TextColor3 = T.Tx3
		label.TextXAlignment = Enum.TextXAlignment.Left; label.Text = labelText
		local button = Instance.new("TextButton")
		button.Parent = row; button.Position = UDim2.fromOffset(8, 24); button.Size = UDim2.new(1, -16, 0, 22)
		button.BackgroundColor3 = T.Elev; button.BorderSizePixel = 0; button.AutoButtonColor = false
		button.Font = FM; button.TextSize = 11; button.TextColor3 = T.Tx; Corner(button, 6)
		local function refresh() local value = getValue(); button.Text = display and display(value) or tostring(value) end
		button.MouseButton1Click:Connect(function()
			local current = getValue(); local index = table.find(values, current) or 1
			onValue(values[index % #values + 1]); refresh()
			if RequestAutoSave then RequestAutoSave() end
		end)
		refresh()
		table.insert(choiceRefreshers, refresh)
		return refresh
	end

	local textValues = { 0.88, 1, 1.18 }
	makeChoice("TEXT SIZE", textValues, function() return S.UITextScale end, function(value)
		UIStyle:ApplyTextScale(value)
	end, 1, function(value) return value == 0.88 and "Small" or (value == 1.18 and "Large" or "Normal") end)
	makeChoice("NOTIFICATION POSITION", { "Top Right", "Bottom Right", "Bottom Center", "Bottom Left", "Top Left", "Top Center" }, function()
		return S.NotificationPosition
	end, function(value)
		UIStyle:PlaceNotifications(value)
	end, 2)
	local themeCard = Instance.new("Frame")
	themeCard.Parent = body; themeCard.LayoutOrder = 3; themeCard.Size = UDim2.new(1, 0, 0, 126)
	themeCard.BackgroundColor3 = T.BG; themeCard.BorderSizePixel = 0
	Corner(themeCard, 9); Stroke(themeCard, T.Bd2, 1, 0.42)
	local themeTitle = Instance.new("TextLabel")
	themeTitle.Parent = themeCard; themeTitle.BackgroundTransparency = 1
	themeTitle.Position = UDim2.fromOffset(10, 5); themeTitle.Size = UDim2.new(1, -20, 0, 17)
	themeTitle.Font = F; themeTitle.TextSize = 10; themeTitle.TextColor3 = T.Tx3
	themeTitle.TextXAlignment = Enum.TextXAlignment.Left; themeTitle.Text = "THEME"
	local gridHost = Instance.new("Frame")
	gridHost.Parent = themeCard; gridHost.BackgroundTransparency = 1
	gridHost.Position = UDim2.fromOffset(8, 26); gridHost.Size = UDim2.new(1, -16, 1, -34)
	local grid = Instance.new("UIGridLayout")
	grid.Parent = gridHost; grid.CellSize = UDim2.new(0.5, -3, 0, 20); grid.CellPadding = UDim2.fromOffset(6, 4)
	grid.FillDirectionMaxCells = 2; grid.SortOrder = Enum.SortOrder.LayoutOrder
	local themeButtons = {}
	local themeNames = { "Graphite", "Ocean", "Forest", "Wine", "Violet", "Ember", "Amber", "Rose" }
	local function refreshThemes()
		for name, button in pairs(themeButtons) do
			local selected = name == S.UITheme
			button.BackgroundColor3 = selected and T.ActiveBg or T.Elev
			button.TextColor3 = selected and T.White or T.Tx2
		end
	end
	for index, name in ipairs(themeNames) do
		local button = Instance.new("TextButton")
		button.Parent = gridHost; button.LayoutOrder = index; button.AutoButtonColor = false
		button.BackgroundColor3 = T.Elev; button.BorderSizePixel = 0
		button.Font = FM; button.TextSize = 10; button.TextColor3 = T.Tx2; button.Text = name
		Corner(button, 6); Stroke(button, T.Bd2, 1, 0.48)
		local dot = Instance.new("Frame")
		dot.Parent = button; dot.AnchorPoint = Vector2.new(1, 0.5); dot.Position = UDim2.new(1, -7, 0.5, 0)
		dot.Size = UDim2.fromOffset(7, 7); dot.BackgroundColor3 = THEMES[name].Accent; dot.BorderSizePixel = 0; Corner(dot, 99)
		dot:SetAttribute("StaticThemeColor", true)
		themeButtons[name] = button
		button.MouseButton1Click:Connect(function()
			UIStyle:ApplyTheme(name); refreshThemes()
			if RequestAutoSave then RequestAutoSave() end
		end)
	end
	refreshThemes()
	S._refreshAppearance = function()
		refreshThemes()
		for _, refresh in ipairs(choiceRefreshers) do refresh() end
	end

	local executor = Instance.new("TextLabel")
	executor.Parent = body; executor.LayoutOrder = 4; executor.Size = UDim2.new(1, 0, 0, 28)
	executor.BackgroundColor3 = T.BG; executor.BorderSizePixel = 0
	executor.Font = F; executor.TextSize = 10; executor.TextColor3 = T.Tx2
	executor.TextXAlignment = Enum.TextXAlignment.Left
	local executorName = "Unknown executor"
	pcall(function() if identifyexecutor then executorName = tostring(identifyexecutor()) end end)
	executor.Text = "   EXECUTOR   " .. executorName
	Corner(executor, 8); Stroke(executor, T.Bd2, 1, 0.44)
	for _, object in ipairs(panel:GetDescendants()) do if object:IsA("GuiObject") then object.ZIndex = math.max(object.ZIndex, 1501) end end

	local opened = false
	local function setOpen(value)
		opened = value
		if value then
			panel.Visible = true; scale.Scale = 0.92; panel.BackgroundTransparency = 0.08
			Tween(scale, 0.2, { Scale = 1 }, Enum.EasingStyle.Back):Play()
			Tween(panel, 0.16, { BackgroundTransparency = 0 }):Play()
		else
			Tween(scale, 0.14, { Scale = 0.94 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
			task.delay(0.15, function() if not opened then panel.Visible = false end end)
		end
	end
	close.MouseButton1Click:Connect(function() setOpen(false) end)
	return function() setOpen(not opened) end
end)()

-- One bind registry for every actionable control.  Keep the implementation in
-- a nested function: this hub is already large enough to hit Luau's 200-local
-- register limit if its private UI variables leak into the main chunk scope.
do
local function setupKeybinds()
local BindRegistry = {}
S._bindRegistry = BindRegistry
local BindCapture = { target = nil, readyAt = 0 }
S._bindHUDDirty = true

local BindPrompt = Instance.new("Frame")
BindPrompt.Name = "PressureBindCapture"
BindPrompt.Parent = SG
BindPrompt.AnchorPoint = Vector2.new(0.5, 0)
BindPrompt.Position = UDim2.new(0.5, 0, 0, 76)
BindPrompt.Size = UDim2.fromOffset(286, 48)
BindPrompt.BackgroundColor3 = T.Card
BindPrompt.BackgroundTransparency = 0.04
BindPrompt.BorderSizePixel = 0
BindPrompt.Visible = false
BindPrompt.ZIndex = 980
Corner(BindPrompt, 9)
Stroke(BindPrompt, T.Accent, 1, 0.18)

local BindPromptTitle = Instance.new("TextLabel")
BindPromptTitle.Parent = BindPrompt; BindPromptTitle.BackgroundTransparency = 1
BindPromptTitle.Position = UDim2.fromOffset(12, 7); BindPromptTitle.Size = UDim2.new(1, -24, 0, 15)
BindPromptTitle.Font = FB; BindPromptTitle.TextSize = 11; BindPromptTitle.TextColor3 = T.White
BindPromptTitle.TextXAlignment = Enum.TextXAlignment.Left; BindPromptTitle.ZIndex = 981

local BindPromptSub = Instance.new("TextLabel")
BindPromptSub.Parent = BindPrompt; BindPromptSub.BackgroundTransparency = 1
BindPromptSub.Position = UDim2.fromOffset(12, 24); BindPromptSub.Size = UDim2.new(1, -24, 0, 15)
BindPromptSub.Font = F; BindPromptSub.TextSize = 11; BindPromptSub.TextColor3 = T.Tx2
BindPromptSub.TextXAlignment = Enum.TextXAlignment.Left; BindPromptSub.Text = "Press a key or mouse button — Esc clears"
BindPromptSub.ZIndex = 981

local function bindTokenFromInput(input)
	if input.KeyCode and input.KeyCode ~= Enum.KeyCode.Unknown then
		if input.KeyCode == S.MenuKeybind then return nil end
		return "key:" .. input.KeyCode.Name
	end
	local kind = input.UserInputType
	if kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.MouseButton2
		or kind == Enum.UserInputType.MouseButton3 then
		return "mouse:" .. kind.Name
	end
	return nil
end

local function bindTokenTitle(token)
	if type(token) ~= "string" then return "—" end
	local kind, value = token:match("^(%a+):(.+)$")
	if not kind or not value then return "—" end
	local pretty = {
		LeftControl = "LCTRL", RightControl = "RCTRL", LeftShift = "LSHIFT", RightShift = "RSHIFT",
		LeftAlt = "LALT", RightAlt = "RALT", MouseButton1 = "M1", MouseButton2 = "M2", MouseButton3 = "M3",
	}
	return pretty[value] or string.upper(value)
end
S._bindTokenTitle = bindTokenTitle

local function markKeybindHUDDirty()
	S._bindHUDDirty = true
end
S._markKeybindHUDDirty = markKeybindHUDDirty

local function refreshBindChips(id)
	local entry = BindRegistry[id]
	if not entry then return end
	local text = bindTokenTitle(S.Keybinds[id])
	for _, chip in ipairs(entry.chips) do
		if chip and chip.Parent then chip.Text = text end
	end
	markKeybindHUDDirty()
end

local function setKeybind(id, token)
	if not BindRegistry[id] then return end
	S.Keybinds = type(S.Keybinds) == "table" and S.Keybinds or {}
	if token then
		-- A physical key has one owner.  Reassigning it removes the old action
		-- rather than toggling two unrelated gameplay features at once.
		for otherId, otherToken in pairs(S.Keybinds) do
			if otherId ~= id and otherToken == token then
				S.Keybinds[otherId] = nil
				refreshBindChips(otherId)
			end
		end
		S.Keybinds[id] = token
	else
		S.Keybinds[id] = nil
	end
	refreshBindChips(id)
	if RequestAutoSave then RequestAutoSave() end
end

local function applyKeybindMap(map)
	S.Keybinds = {}
	if type(map) == "table" then
		for id, token in pairs(map) do
			if BindRegistry[id] and type(token) == "string" then S.Keybinds[id] = token end
		end
	end
	for id in pairs(BindRegistry) do refreshBindChips(id) end
	markKeybindHUDDirty()
end
S._applyKeybindMap = applyKeybindMap

local function clearAllKeybinds()
	applyKeybindMap({})
	if RequestAutoSave then RequestAutoSave() end
	Notify("Keybinds", "All binds cleared", 1.8, "info")
end
S._clearAllKeybinds = clearAllKeybinds

local function startBindCapture(id)
	local entry = BindRegistry[id]
	if not entry then return end
	BindCapture.target = id
	-- Ignore the RMB that opened the capture, but accept a deliberate M2 bind
	-- on the next click.
	BindCapture.readyAt = os.clock() + 0.12
	BindPromptTitle.Text = "BIND // " .. string.upper(entry.label)
	BindPrompt.Visible = true
	SFX.Click()
end

local function finishBindCapture(token)
	local id = BindCapture.target
	BindCapture.target = nil
	BindPrompt.Visible = false
	if not id then return end
	setKeybind(id, token)
	local entry = BindRegistry[id]
	if token then
		Notify("Keybind", entry.label .. " → " .. bindTokenTitle(token), 1.8, "success")
	else
		Notify("Keybind", entry.label .. " cleared", 1.6, "info")
	end
end

local function registerBindable(id, label, trigger, isActive, kind)
	BindRegistry[id] = { label = label, trigger = trigger, isActive = isActive, kind = kind, chips = {} }
	return id
end
S._registerBindable = registerBindable

local function requestBindFromRightClick(target, id)
	target.Active = true
	target:SetAttribute("PressureBindId", id)
end
S._requestBindFromRightClick = requestBindFromRightClick

local function bindTargetAt(position)
	local ok, hits = pcall(function()
		local root = SG.Parent
		if root and type(root.GetGuiObjectsAtPosition) == "function" then
			return root:GetGuiObjectsAtPosition(position.X, position.Y)
		end
		local pg = LP:FindFirstChildOfClass("PlayerGui")
		return pg and pg:GetGuiObjectsAtPosition(position.X, position.Y) or {}
	end)
	if not ok or type(hits) ~= "table" then return nil end
	for _, hit in ipairs(hits) do
		local node = hit
		while node and node ~= SG do
			local id = node:GetAttribute("PressureBindId")
			if id and BindRegistry[id] then return id end
			node = node.Parent
		end
	end
	return nil
end

local function addBindChip(parent, id, rightOffset)
	local chip = Instance.new("TextButton")
	chip.Name = "Bind_" .. id
	chip.Parent = parent
	chip.AnchorPoint = Vector2.new(1, 0.5)
	chip.Position = UDim2.new(1, rightOffset or -52, 0.5, 0)
	chip.Size = UDim2.fromOffset(48, 20)
	chip.BackgroundColor3 = T.Elev
	chip.BorderSizePixel = 0
	chip.AutoButtonColor = false
	chip.Font = FM; chip.TextSize = 10; chip.TextColor3 = T.Tx2
	chip.Text = bindTokenTitle(S.Keybinds[id])
	chip.ZIndex = 3
	Corner(chip, 6)
	Stroke(chip, T.Bd2, 1, 0.42)
	tc(chip.MouseButton1Click:Connect(function() startBindCapture(id) end))
	requestBindFromRightClick(chip, id)
	local entry = BindRegistry[id]
	if entry then table.insert(entry.chips, chip) end
	return chip
end
S._addBindChip = addBindChip

tc(UIS.InputBegan:Connect(function(input, gameProcessed)
	if BindCapture.target then
		if os.clock() < BindCapture.readyAt then return end
		if input.KeyCode == Enum.KeyCode.Escape then finishBindCapture(nil); return end
		local token = bindTokenFromInput(input)
		if token then finishBindCapture(token) end
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		local id = bindTargetAt(input.Position)
		if id then startBindCapture(id); return end
	end
	if gameProcessed or UIS:GetFocusedTextBox() then return end
	local token = bindTokenFromInput(input)
	if not token then return end
	for id, entry in pairs(BindRegistry) do
		if S.Keybinds[id] == token then
			pcall(entry.trigger)
			markKeybindHUDDirty()
			break
		end
	end
end))
end
setupKeybinds()
end

local function mkSection(parent, title, order)
	local card = Instance.new("Frame")
	card.Name = title
	card.Parent = parent
	card.LayoutOrder = order
	card.BackgroundColor3 = T.Card
	card.BorderSizePixel = 0
	card.Size = UDim2.new(1, 0, 0, 0)
	card.AutomaticSize = Enum.AutomaticSize.Y
	Corner(card, 11)
	Stroke(card, T.Bd, 1, 0.3)
	Pad(card, 12, 14, 14, 14)

	local layout = Instance.new("UIListLayout")
	layout.Parent = card; layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0, 7)

	local hdrRow = Instance.new("Frame")
	hdrRow.Parent = card; hdrRow.LayoutOrder = 0; hdrRow.BackgroundTransparency = 1; hdrRow.Size = UDim2.new(1, 0, 0, 24)
	-- Fixed-offset tick, not a list sibling elsewhere — safe since hdrRow
	-- itself isn't inside a UIListLayout that also owns Scale-height peers.
	local tick = Instance.new("Frame")
	tick.Parent = hdrRow; tick.BackgroundColor3 = T.Accent; tick.BorderSizePixel = 0
	tick.Position = UDim2.new(0, 0, 0.5, -6); tick.Size = UDim2.new(0, 3, 0, 13)
	Corner(tick, 2)
	local hdr = Instance.new("TextLabel")
	hdr.Parent = hdrRow; hdr.BackgroundTransparency = 1
	hdr.Position = UDim2.new(0, 13, 0, 0); hdr.Size = UDim2.new(1, -13, 1, 0)
	hdr.Font = FB; hdr.TextSize = 13; hdr.TextColor3 = T.Tx2
	hdr.TextXAlignment = Enum.TextXAlignment.Left; hdr.Text = string.upper(title)

	return card
end

local function mkToggle(parent, label, key, order, callback)
	local row = Instance.new("Frame")
	row.Name = label; row.Parent = parent; row.LayoutOrder = order
	row.Size = UDim2.new(1, 0, 0, 32); row.BackgroundTransparency = 1

	local lbl = Instance.new("TextLabel")
	lbl.Parent = row; lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.new(0, 4, 0, 0); lbl.Size = UDim2.new(1, -120, 1, 0)
	lbl.Font = F; lbl.TextSize = 14; lbl.TextColor3 = T.Tx2
	lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Text = label

	local track = Instance.new("TextButton")
	track.Parent = row
	track.AnchorPoint = Vector2.new(1, 0.5)
	track.Position = UDim2.new(1, -4, 0.5, 0)
	track.Size = UDim2.new(0, 42, 0, 22)
	track.BackgroundColor3 = T.TgOff
	track.AutoButtonColor = false
	track.Text = ""
	Corner(track, 11)
	local trackStroke = Stroke(track, T.Bd2, 1, 0.5)

	local knob = Instance.new("Frame")
	knob.Parent = track
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = UDim2.new(0, 3, 0.5, -8)
	knob.BackgroundColor3 = T.KnobOff
	Corner(knob, 8)

	local function update(val)
		val = val and true or false
		S[key] = val
		Tween(track, 0.15, { BackgroundColor3 = val and T.TgOn or T.TgOff }):Play()
		Tween(knob, 0.15, { Position = val and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) }, Enum.EasingStyle.Back):Play()
		knob.BackgroundColor3 = val and T.KnobOn or T.KnobOff
		lbl.TextColor3 = val and T.White or T.Tx2
		trackStroke.Transparency = val and 1 or 0.5
		if callback then pcall(callback, val) end
		S._markKeybindHUDDirty()
	end

	local bindId = S._registerBindable("toggle:" .. key, label, function()
		update(not S[key])
		SFX.Click()
		if RequestAutoSave then RequestAutoSave() end
	end, function() return S[key] == true end, "toggle")
	S._addBindChip(row, bindId, -52)
	S._requestBindFromRightClick(row, bindId)
	S._requestBindFromRightClick(lbl, bindId)
	S._requestBindFromRightClick(track, bindId)

	track.MouseButton1Click:Connect(function()
		update(not S[key]); SFX.Click()
		if RequestAutoSave then RequestAutoSave() end
	end)

	CfgBind[key] = function(v) update(v) end
	if S[key] then update(true) end
	table.insert(UIRegistry, { card = parent, row = row, label = string.lower(label) })
	return row
end

local function mkSlider(parent, label, minVal, maxVal, key, order, callback)
	local card = Instance.new("Frame")
	card.Name = label; card.Parent = parent; card.LayoutOrder = order
	card.Size = UDim2.new(1, 0, 0, 48); card.BackgroundTransparency = 1

	local lbl = Instance.new("TextLabel")
	lbl.Parent = card; lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.new(0, 4, 0, 2); lbl.Size = UDim2.new(0.6, 0, 0, 18)
	lbl.Font = F; lbl.TextSize = 14; lbl.TextColor3 = T.Tx2
	lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Text = label

	local pill = Instance.new("Frame")
	pill.Parent = card; pill.AnchorPoint = Vector2.new(1, 0)
	pill.Position = UDim2.new(1, -4, 0, 0); pill.Size = UDim2.new(0, 50, 0, 20)
	pill.BackgroundColor3 = T.Elev
	Corner(pill, 7); Stroke(pill, T.Bd, 1, 0.5)
	local valLbl = Instance.new("TextLabel")
	valLbl.Parent = pill; valLbl.BackgroundTransparency = 1; valLbl.Size = UDim2.new(1, 0, 1, 0)
	valLbl.Font = FM; valLbl.TextSize = 13; valLbl.TextColor3 = T.White; valLbl.Text = tostring(S[key] or minVal)

	local bar = Instance.new("Frame")
	bar.Parent = card; bar.Position = UDim2.new(0, 4, 0, 30); bar.Size = UDim2.new(1, -8, 0, 7)
	bar.BackgroundColor3 = T.Elev; bar.Active = true
	Corner(bar, 4)
	local fill = Instance.new("Frame")
	fill.Parent = bar
	fill.Size = UDim2.new(math.clamp(((S[key] or minVal) - minVal) / (maxVal - minVal), 0, 1), 0, 1, 0)
	fill.BackgroundColor3 = T.Accent
	Corner(fill, 4)
	local grab = Instance.new("Frame")
	grab.Parent = bar; grab.AnchorPoint = Vector2.new(0.5, 0.5)
	grab.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0); grab.Size = UDim2.new(0, 12, 0, 12)
	grab.BackgroundColor3 = T.White; grab.ZIndex = 2
	Corner(grab, 6); Stroke(grab, T.Bd2, 1, 0.3)

	local function setVal(val)
		val = math.clamp(math.floor(val + 0.5), minVal, maxVal)
		S[key] = val
		local a = (val - minVal) / (maxVal - minVal)
		fill.Size = UDim2.new(a, 0, 1, 0)
		grab.Position = UDim2.new(a, 0, 0.5, 0)
		valLbl.Text = tostring(val)
		if callback then pcall(callback, val) end
	end

	local dragging = false
	local function updateFromInput(input)
		local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		setVal(minVal + (maxVal - minVal) * pos)
		if RequestAutoSave then RequestAutoSave() end
	end
	tc(bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; updateFromInput(input) end
	end))
	tc(UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateFromInput(input) end
	end))
	tc(UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end))

	CfgBind[key] = setVal
	table.insert(UIRegistry, { card = parent, row = card, label = string.lower(label) })
	return card
end

local function mkButton(parent, label, callback, order)
	local btn = Instance.new("TextButton")
	btn.Name = label; btn.Parent = parent; btn.LayoutOrder = order
	btn.Size = UDim2.new(1, 0, 0, 34)
	btn.BackgroundColor3 = T.Elev; btn.AutoButtonColor = false
	btn.Font = FM; btn.TextSize = 14; btn.TextColor3 = T.White; btn.Text = label
	btn.TextXAlignment = Enum.TextXAlignment.Left
	Corner(btn, 8)
	Pad(btn, 0, 0, 12, 64)
	local bst = Stroke(btn, T.Bd, 1, 0.4)
	btn.MouseEnter:Connect(function() Tween(btn, 0.12, { BackgroundColor3 = T.Hover }):Play(); Tween(bst, 0.12, { Transparency = 0.1 }):Play() end)
	btn.MouseLeave:Connect(function() Tween(btn, 0.12, { BackgroundColor3 = T.Elev }):Play(); Tween(bst, 0.12, { Transparency = 0.4 }):Play() end)
	local bindId = S._registerBindable("button:" .. label:gsub("[^%w]", "_"), label, function()
		pcall(callback)
		SFX.Click()
	end, nil, "button")
	S._addBindChip(btn, bindId, -6)
	S._requestBindFromRightClick(btn, bindId)
	btn.MouseButton1Click:Connect(function() pcall(callback); SFX.Click() end)
	table.insert(UIRegistry, { card = parent, row = btn, label = string.lower(label) })
	return btn
end

--------------------------------------------------------------------------------
-- WORLD HELPERS
--------------------------------------------------------------------------------
local function getGF() return Workspace:FindFirstChild("GameplayFolder") end
local function getHRP() local c = LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function objPos(obj)
	if obj:IsA("BasePart") then return obj.Position end
	if obj:IsA("Model") then
		local ok, piv = pcall(function() return obj:GetPivot() end)
		if ok and piv then return piv.Position end
		local p = obj:FindFirstChildWhichIsA("BasePart", true)
		return p and p.Position
	end
	return nil
end

-- Names confirmed either via live decompile this session or the public
-- Pressure wiki (bloxinformer.com / pressuregame.wiki / pressure.fandom.com).
local MONSTER_NAMES = {
	"angler", "blitz", "pinkie", "froger", "pandemonium", "chainsmoker",
	"a60", "bottomfeeder", "bouncer", "candlebearer", "eyefestation", "squiddle",
	"abomination", "trenchbleeder", "pipsqueak", "educator", "trickster",
	"hotpotato", "lopee", "dozer", "searchlight", "walldweller", "harbinger",
	"carnation", "doppel", "raveyard",
}
local function monsterKind(nameLower)
	if nameLower:find("dweller") then return "dweller" end
	if nameLower:find("eyefest") or nameLower:find("lookman") then return "eyefest" end
	if nameLower:find("squiddle") then return "squiddle" end
	if nameLower:find("carnation") then return "carnation" end
	for _, m in ipairs(MONSTER_NAMES) do
		if nameLower:find(m, 1, true) then return "monster" end
	end
	return nil
end

-- Names and InteractionType values below were read from the live Pressure
-- client (Hadal Blacksite v12926).  Use the type contract first: cosmetic
-- item names change often, but InteractionType is how Pressure instantiates
-- the correct module for a tagged world object.
local ITEM_MODELS = {
	DropBattery = true, Flashlight = true, Lantern = true, FlashBeacon = true,
	Glider = true, HealthCrate = true, OxygenTank = true, Medkit = true,
	BeaconGun = true, Blacklight = true, CaptainsCompass = true, Chainsaw = true,
	Decoder = true, DwellerPiece = true, Flamethrower = true, Gummylight = true,
	Gravelight = true, HealthBoost = true, PanicButton = true, RemoteC4 = true,
	SPRINT = true, Scanner = true, SmallLantern = true, Splorglight = true,
	StunBaton = true, ToolGun = true, WindupLight = true, Defib = true,
}
local ITEM_INTERACTIONS = {
	ItemBase = true, Battery = true, HealthCrate = true, OxygenTank = true,
	Glider = true, RegularDrink = true, NeoStykPickup = true,
}
local KEY_INTERACTIONS = {
	KeyCard = true, InnerKeyCard = true, ElevatorKey = true, PasswordPaper = true,
}
local DOOR_INTERACTIONS = {
	DoorBase = true, DoubleDoor = true, DoubleDoorSide = true, ChaseDoor = true,
	ChaseEmptyDoor = true, LargeRoundDoor = true, BigDoor = true, InnerLock = true,
}
local DRAWER_INTERACTIONS = { DrawerBase = true, Briefcase = true }
local HAZARD_INTERACTIONS = {
	Landmine = true, DrawerLandmine = true, Tripwire = true, Turret = true,
	CustomTurret = true, SeaMines = true, LavaPipe = true,
}
local OBJECTIVE_INTERACTIONS = {
	BoardPuzzle = true, BridgeControl = true, Button = true, Lever = true,
	TreadmillPanel = true, Tram = true, TurretControls = true,
}
local OBJECTIVE_LABELS = {
	BoardPuzzle = "POWER BOARD // ALIGN", BridgeControl = "BRIDGE CONTROL",
	Button = "OBJECTIVE BUTTON", Lever = "OBJECTIVE LEVER",
	TreadmillPanel = "TREADMILL CONTROL", Tram = "TRAM CONTROL",
	TurretControls = "TURRET CONTROL",
}
local PromptCache = {}

-- The prompt is often nested under ProxyPart/Highlight, while the contract
-- lives on a Model or Folder above it.  Walk upward instead of relying on a
-- single model name so Valve/RepairSystem and future room variants classify
-- correctly too.
local function getInteractionType(prompt)
	local node = prompt.Parent
	while node and node ~= Workspace do
		local interactionType = node:GetAttribute("InteractionType")
		if type(interactionType) == "string" and interactionType ~= "" then
			return interactionType, node
		end
		node = node.Parent
	end
	return nil, nil
end
local function classifyPrompt(prompt)
	local parent = prompt.Parent
	local part
	if parent and parent:IsA("BasePart") then
		part = parent
	elseif parent and parent:IsA("Attachment") then
		part = parent.Parent
	end
	if not (part and part:IsA("BasePart")) then
		part = parent and parent:FindFirstAncestorWhichIsA("BasePart")
	end
	if not part then return nil end
	local model = part:FindFirstAncestorOfClass("Model")
	local mname = model and model.Name or part.Name
	local mnameLower = mname:lower()
	local interactionType, interactionRoot = getInteractionType(prompt)
	local kind
	if mname:match("^Currency") or interactionType == "CurrencyBase" then kind = "currency"
	elseif mname == "CodeBreacher" or KEY_INTERACTIONS[interactionType] or mnameLower:find("keycard", 1, true) then kind = "keycard"
	elseif ITEM_MODELS[mname] or ITEM_INTERACTIONS[interactionType] then kind = "item"
	elseif DOOR_INTERACTIONS[interactionType] or (mnameLower:find("door", 1, true) and part.Name == "Root") then kind = "door"
	elseif mname == "Locker" then
		if model and (model:GetAttribute("InteractionType") == "MonsterLocker" or model:FindFirstChild("highlight")) then
			kind = "voidlocker"
		else
			kind = "locker"
		end
	elseif DRAWER_INTERACTIONS[interactionType] or mnameLower:find("drawer", 1, true) or mnameLower:find("cabinet", 1, true) then kind = "drawer"
	elseif HAZARD_INTERACTIONS[interactionType] or mnameLower:find("tripwire", 1, true) or mnameLower:find("turret", 1, true) or mnameLower:find("mine", 1, true) then kind = "hazard"
	elseif interactionType == "RefillBatteries" then kind = "refill"
	elseif interactionType == "Valve" then kind = "valve"
	elseif interactionType == "RepairSystem" then kind = "repair"
	elseif OBJECTIVE_INTERACTIONS[interactionType] then kind = "objective"
	else kind = "other" end
	return {
		prompt = prompt, part = part, model = model or part, kind = kind, name = mname,
		interactionType = interactionType, interactionRoot = interactionRoot,
	}
end

-- Fake dead-end models are decoration only. Filter them before building the
-- ESP registry, so Door ESP never fills a room with misleading markers.
local DEAD_END_DOOR_NAMES = {
	NoEntry = true, BentDoor = true, DeadEndDoor = true, BrokenDoor = true,
}
local function isDeadEndDoor(model)
	if not model then return false end
	return DEAD_END_DOOR_NAMES[model.Name] == true
		or model:GetAttribute("RoomType") == "DeadEnds"
		or model:GetAttribute("DeadEnd") == true
end

local function textMentionsKeycard(value)
	if type(value) ~= "string" then return false end
	local text = value:lower()
	return text:find("keycard", 1, true) ~= nil
		or text:find("key card", 1, true) ~= nil
		or text:find("card reader", 1, true) ~= nil
end

-- Pressure has several card-reader model variants. Prefer explicit attributes,
-- then use model/prompt text as a safe fallback for older room variants.
local function isKeycardDoor(e)
	if not (e and e.kind == "door" and e.model) then return false end
	local model = e.model
	for _, attrName in ipairs({ "RequiresKeycard", "KeycardRequired", "KeyCardRequired", "CardRequired", "RequiresCard", "AccessLevel", "RequiredAccess", "LockType" }) do
		local value = model:GetAttribute(attrName)
		if value == true or (type(value) == "number" and value > 0) or textMentionsKeycard(value) then return true end
	end
	local prompt = e.prompt
	return textMentionsKeycard(model.Name)
		or (prompt and (textMentionsKeycard(prompt.ActionText) or textMentionsKeycard(prompt.ObjectText)))
end
task.spawn(function()
	while not S.Destroyed do
		local new = {}
		local gf = getGF()
		if gf then
			pcall(function()
				for _, d in ipairs(gf:GetDescendants()) do
					if d:IsA("ProximityPrompt") then
						local e = classifyPrompt(d)
						if e then new[#new + 1] = e end
					end
				end
			end)
		end
		PromptCache = new
		task.wait(2)
	end
end)

local ITEM_LABEL = {
	DropBattery = "Battery", Flashlight = "Flashlight", Lantern = "Lantern",
	FlashBeacon = "Flash Beacon", Glider = "Glider", HealthCrate = "Health Crate",
	OxygenTank = "Oxygen Tank", Medkit = "Medkit", SPRINT = "SPR-INT",
	HealthBoost = "Health Boost", SmallLantern = "Small Lantern", WindupLight = "Windup Light",
}
local function tagTitleFor(e)
	if e.kind == "currency" then
		local amt = e.name:match("^Currency(%d+)")
		return amt and (amt .. " Kroner") or "Kroner"
	elseif e.kind == "item" then return ITEM_LABEL[e.name] or e.name
	elseif e.kind == "keycard" then
		if e.name == "CodeBreacher" then return "CODE BREACHER // PICK UP" end
		if e.interactionType == "ElevatorKey" then return "ELEVATOR KEY // PICK UP" end
		if e.interactionType == "PasswordPaper" then return "ACCESS CODE // PICK UP" end
		return "KEYCARD // PICK UP"
	elseif e.kind == "door" then
		local m = e.model
		if m:GetAttribute("ProgressDoor") then return "NEXT ROOM >>" end
		if isKeycardDoor(e) then return "KEYCARD ACCESS // LOCKED" end
		if m:GetAttribute("Locked") then
			local code = LP:GetAttribute("Code")
			return code and ("KEYPAD // " .. tostring(code)) or "KEYPAD // LOCKED"
		end
		return "Door"
	elseif e.kind == "locker" then return "Locker (safe)"
	elseif e.kind == "voidlocker" then return "VOID LOCKER - DO NOT HIDE"
	elseif e.kind == "drawer" then return "Drawer"
	elseif e.kind == "hazard" then
		if e.interactionType == "Landmine" or e.interactionType == "DrawerLandmine" then return "LANDMINE // DISARM" end
		if e.interactionType == "Tripwire" then return "TRIPWIRE // DANGER" end
		if e.interactionType == "Turret" or e.interactionType == "CustomTurret" then return "TURRET // DANGER" end
		if e.interactionType == "SeaMines" then return "SEA MINE // DANGER" end
		return e.name
	elseif e.kind == "refill" then return "BATTERY REFILL"
	elseif e.kind == "valve" then return "VALVE // ROTATE"
	elseif e.kind == "repair" then
		local fixed = e.interactionRoot and e.interactionRoot:FindFirstChild("Fixed")
		local progress = fixed and tonumber(fixed.Value)
		return progress and ("GENERATOR // " .. math.floor(progress + 0.5) .. "%") or "GENERATOR // REPAIR"
	elseif e.kind == "objective" then return OBJECTIVE_LABELS[e.interactionType] or "OBJECTIVE"
	end
	return e.name
end

local function isRepairComplete(e)
	if not (e and e.kind == "repair" and e.interactionRoot) then return false end
	local fixed = e.interactionRoot:FindFirstChild("Fixed")
	return fixed ~= nil and tonumber(fixed.Value) ~= nil and fixed.Value >= 100
end

--------------------------------------------------------------------------------
-- forward decls used by the UI
--------------------------------------------------------------------------------
local hideInLockerNow, attemptRespawn
local SaveConfigFile, LoadConfigFile
local refreshVisionEffects

-- Client-owned colour grading. These effects are kept separate from the
-- game's Lighting effects, so every setting can be removed cleanly on toggle
-- off or script unload without leaving the level in a modified state.
local suppressedPostEffects = {}
-- Pressure hides remote character parts by setting Transparency=1.  A normal
-- Highlight can then have nothing left to render, so teammate chams use a
-- lightweight, client-only proxy that mirrors the real rig without changing
-- anyone else's replicated character.
local TeammateChamReg = {}
local function getVisionGrade()
	local grade = Lighting:FindFirstChild("PressureHubVisionGrade")
	if not grade then
		grade = Instance.new("ColorCorrectionEffect")
		grade.Name = "PressureHubVisionGrade"
		grade.Enabled = false
		grade.Parent = Lighting
	end
	return grade
end

local function restoreSuppressedPostEffects()
	for effect, enabled in pairs(suppressedPostEffects) do
		pcall(function() if effect.Parent then effect.Enabled = enabled end end)
		suppressedPostEffects[effect] = nil
	end
end

refreshVisionEffects = function()
	local grade = getVisionGrade()
	local useGrade = S.LowLightVision or (S.VisualContrast or 0) > 0 or (S.VisualSaturation or 100) ~= 100
	grade.Enabled = useGrade
	if useGrade then
		grade.Brightness = S.LowLightVision and 0.13 or 0
		grade.Contrast = math.clamp((S.VisualContrast or 0) / 220, 0, 0.45)
		grade.Saturation = math.clamp(((S.VisualSaturation or 100) - 100) / 100, -1, 1)
		-- Slightly cool-neutral, not a green "night-vision goggles" filter.
		grade.TintColor = S.LowLightVision and Color3.fromRGB(225, 245, 238) or Color3.new(1, 1, 1)
	end

	if S.CleanScreenEffects then
		local roots = { Lighting, cam() }
		for _, root in ipairs(roots) do
			if root then
				for _, effect in ipairs(root:GetChildren()) do
					local removable = effect:IsA("BlurEffect") or effect:IsA("BloomEffect") or effect:IsA("ColorCorrectionEffect")
					if removable and effect ~= grade then
						if suppressedPostEffects[effect] == nil then suppressedPostEffects[effect] = effect.Enabled end
						effect.Enabled = false
					end
				end
			end
		end
	else
		restoreSuppressedPostEffects()
	end
end

S._cleanupVisuals = function()
	restoreSuppressedPostEffects()
	pcall(function()
		local grade = Lighting:FindFirstChild("PressureHubVisionGrade")
		if grade then grade:Destroy() end
	end)
	for _, plr in ipairs(Players:GetPlayers()) do
		local ch = plr.Character
		local hl = ch and ch:FindFirstChild("PressurePlayerCham")
		if hl then pcall(function() hl:Destroy() end) end
	end
	for plr, entry in pairs(TeammateChamReg) do
		pcall(function() if entry.model then entry.model:Destroy() end end)
		TeammateChamReg[plr] = nil
	end
end

--------------------------------------------------------------------------------
-- TAB: VISUALS
--------------------------------------------------------------------------------
local secEntities = mkSection(Pages.Visuals, "Entity ESP", 1)
mkToggle(secEntities, "Monster ESP (Angler/Blitz/...)", "EntityESP", 1)
mkToggle(secEntities, "Wall Dweller ESP", "WallDwellerESP", 2)
mkToggle(secEntities, "Eyefestation / Lookman ESP", "EyefestESP", 3)
mkToggle(secEntities, "Squiddle ESP", "SquiddleESP", 4)
mkToggle(secEntities, "Carnation ESP (staredown entity)", "CarnationESP", 5)
mkToggle(secEntities, "Hazard ESP (Tripwire/Turret)", "HazardESP", 6)

local secDoors = mkSection(Pages.Visuals, "Doors & Objectives ESP", 2)
mkToggle(secDoors, "Door ESP (next / access / locked)", "DoorESP", 1)
mkToggle(secDoors, "Locker ESP (flags void lockers red)", "LockerESP", 2)
mkToggle(secDoors, "Drawer / Cabinet ESP", "DrawerESP", 3)
mkToggle(secDoors, "Objective ESP (generator / valve / controls)", "ObjectiveESP", 4)

local secItems = mkSection(Pages.Visuals, "Loot ESP", 3)
mkToggle(secItems, "Item ESP (Battery/Light/Crate)", "ItemESP", 1)
mkToggle(secItems, "Kroner ESP (Currency)", "KronerESP", 2)
mkToggle(secItems, "Priority Keycard / Code Breacher ESP", "KeycardESP", 3)

local secPlayers = mkSection(Pages.Visuals, "Player ESP", 4)
	mkToggle(secPlayers, "Name Tags", "NameESP", 1)
	mkToggle(secPlayers, "Box ESP", "BoxESP", 2)
	mkToggle(secPlayers, "Health", "HealthESP", 3)
	mkToggle(secPlayers, "Tracers", "TracerESP", 4)
	mkToggle(secPlayers, "Teammate Chams", "PlayerChams", 5)

local secEnv = mkSection(Pages.Visuals, "Environment & Lighting", 5)
-- No snapshot/restore here on purpose: Pressure dims Ambient/Brightness per
-- room on its own (confirmed live — a dark encounter room sat at Ambient
-- (0,0,0)/Brightness 0 with these toggles never touched). A one-time
-- "restore the value from whenever you turned this on" is exactly the wrong
-- pattern against a value the game keeps changing on its own — turn the
-- toggle off in a normal room, walk into a dark one, and it would force you
-- back to the stale bright snapshot, or vice versa. Instead: force every
-- frame while ON (see the slow loop), do nothing on OFF, and let the game's
-- own per-room lighting reassert itself the moment we stop overriding it —
-- same fix pattern as the mouse-unlock/camera fights.
	mkToggle(secEnv, "Fullbright", "FullBright", 1)
	mkToggle(secEnv, "No Fog", "NoFog", 2)
	mkToggle(secEnv, "Low-Light Vision", "LowLightVision", 3, refreshVisionEffects)
	mkToggle(secEnv, "Clean Screen Effects (blur / flash)", "CleanScreenEffects", 4, refreshVisionEffects)
	mkSlider(secEnv, "Fullbright Brightness", 1, 10, "Brightness", 5)
	mkSlider(secEnv, "World Contrast", 0, 100, "VisualContrast", 6, refreshVisionEffects)
	mkSlider(secEnv, "World Saturation", 0, 200, "VisualSaturation", 7, refreshVisionEffects)
	mkToggle(secEnv, "Custom FOV", "CamFOVEnabled", 8, function(v) if not v and cam() then pcall(function() cam().FieldOfView = 70 end) end end)
-- Pressure's first-person viewmodel starts clipping/disappearing above ~85.
-- Keep the useful range, but never let a saved 99/120 FOV hide the arms.
mkSlider(secEnv, "FOV", 55, 85, "CamFOV", 9)

local secVisualHUD = mkSection(Pages.Visuals, "Visual HUD & Range", 6)
	mkToggle(secVisualHUD, "Off-Screen Threat Radar", "ThreatRadar", 1)
	mkToggle(secVisualHUD, "Status HUD (room / oxygen / health)", "StatusHUD", 2)
	mkToggle(secVisualHUD, "Keybind HUD (active features)", "KeybindHUD", 3)
	mkToggle(secVisualHUD, "Next Door Waypoint", "NextDoorTracer", 4)
	mkSlider(secVisualHUD, "ESP Max Distance", 250, 2500, "ESPMaxDist", 5)

--------------------------------------------------------------------------------
-- TAB: COMBAT
--------------------------------------------------------------------------------
local secDef = mkSection(Pages.Combat, "Alerts & Defense", 1)
mkToggle(secDef, "Entity Warning Banner", "EntityWarning", 1)
mkToggle(secDef, "Audio Siren Warning", "WarningSound", 2)
mkToggle(secDef, "Boss Encounter Alerts (Dozer/Doombringer)", "BossAlerts", 3)
mkToggle(secDef, "Auto Hide in Locker", "AutoHideInLocker", 4)
mkButton(secDef, "Hide in Locker NOW", function() hideInLockerNow(true) end, 5)

local secCounters = mkSection(Pages.Combat, "Monster Counters", 2)
mkToggle(secCounters, "Anti-Eyefestation (Look Away)", "AntiEyefest", 1)
mkToggle(secCounters, "Auto Dozer Stealth (crouch ping)", "AutoDozerStealth", 2)
mkToggle(secCounters, "Auto Shake Off Parasites", "AutoShakeParasite", 3)
mkToggle(secCounters, "Remove Blitz Jumpscare", "RemoveJumpscares", 4)

--------------------------------------------------------------------------------
-- TAB: MOTION
--------------------------------------------------------------------------------
local secMovement = mkSection(Pages.Motion, "Speed & Flight", 1)
mkToggle(secMovement, "Custom WalkSpeed", "SpeedEnabled", 1, function() refreshGameSpeed() end)
mkSlider(secMovement, "WalkSpeed", 8, 120, "CustomWalkSpeed", 2, function() refreshGameSpeed() end)
mkSlider(secMovement, "Crouch Speed", 4, 60, "CrouchSpeed", 3, function(v)
	S._tunedFields = S._tunedFields or {}; S._tunedFields.CrouchSpeed = true
	local m = getMain(); if m and type(m.CameraModule) == "table" then setGameField(m.CameraModule, "CrouchWalkSpeed", v) end
end)
mkSlider(secMovement, "Sprint Modifier", 0, 150, "SprintMod", 4, function(v)
	S._tunedFields = S._tunedFields or {}; S._tunedFields.SprintMod = true
	local m = getMain()
	if m then
		if type(m.CameraModule) == "table" then setGameField(m.CameraModule, "SprintModifier", v) end
	end
end)
mkToggle(secMovement, "Custom JumpPower", "JumpEnabled", 5, function(v)
	if not v then restoreJumpPower() end
end)
mkSlider(secMovement, "JumpPower", 50, 250, "CustomJumpPower", 6)
mkToggle(secMovement, "Fly", "Fly", 7, function(v)
	if not v then
		pcall(function() if S._flyBV then S._flyBV:Destroy(); S._flyBV = nil end end)
		if not S.NoClip then restoreNoClip() end
	end
end)
mkSlider(secMovement, "Fly Speed", 10, 200, "FlySpeed", 8)
mkToggle(secMovement, "Noclip", "NoClip", 9, function(v)
	if not v and not S.Fly then restoreNoClip() end
end)
mkToggle(secMovement, "Infinite Jump", "InfiniteJump", 10)
mkToggle(secMovement, "Spinbot", "Spinbot", 11)
mkSlider(secMovement, "Spin Speed", 2, 50, "SpinSpeed", 12)

local secPhysics = mkSection(Pages.Motion, "Swimming & Oxygen", 2)
mkToggle(secPhysics, "Fast Swim", "FastSwim", 1, function(v)
	local m = getMain(); local sw = m and m.Swimming
	if type(sw) ~= "table" then return end
	if v then
		saveSwimDefaults(sw)
		sw.SwimmingSpeed = math.clamp(tonumber(S.SwimSpeed) or 32, 18, 65)
	else
		-- Glider Speed is its own setting; disabling Fast Swim must not erase it.
		restoreSwimDefaults(sw, false)
	end
end)
mkSlider(secPhysics, "Swim Speed", 18, 65, "SwimSpeed", 2, function(v)
	local m = getMain(); local sw = m and m.Swimming
	if S.FastSwim and type(sw) == "table" then
		saveSwimDefaults(sw)
		sw.SwimmingSpeed = v
	end
end)
mkSlider(secPhysics, "Glider Speed", 60, 140, "GliderSpeed", 3, function(v)
	S._tunedFields = S._tunedFields or {}; S._tunedFields.GliderSpeed = true
	local m = getMain(); if m and type(m.Swimming) == "table" then setGameField(m.Swimming, "GliderSpeed", v) end
end)
mkToggle(secPhysics, "Infinite Oxygen", "InfiniteOxygen", 4)

--------------------------------------------------------------------------------
-- TAB: PLAYER
--------------------------------------------------------------------------------
local secChar = mkSection(Pages.Player, "Character", 1)
mkButton(secChar, "Attempt Respawn", function() attemptRespawn() end, 1)
mkToggle(secChar, "Anti-AFK Disconnect", "AntiAFK", 2)

-- No 3rd-person toggle: Pressure's own CameraModule forces the camera back
-- to LockFirstPerson/near-zero zoom every frame regardless of CameraMode or
-- CameraMaxZoomDistance — confirmed live (set Classic + 25-stud zoom, held
-- it, camera distance stayed ~2 studs). The game genuinely doesn't support
-- third person; a toggle that visibly does nothing is worse than no toggle.
local secMouse = mkSection(Pages.Player, "Mouse", 2)
do
	local note = Instance.new("TextLabel")
	note.Parent = secMouse; note.LayoutOrder = 1; note.BackgroundTransparency = 1
	note.Size = UDim2.new(1, 0, 0, 30); note.Font = F; note.TextSize = 12
	note.TextColor3 = T.Tx3; note.TextWrapped = true; note.TextXAlignment = Enum.TextXAlignment.Left
	note.Text = "Mouse unlocks automatically while this menu is open, and locks back the moment you close it."
end

--------------------------------------------------------------------------------
-- TAB: AUTO
--------------------------------------------------------------------------------
local secAuto = mkSection(Pages.Auto, "Automation", 1)
mkToggle(secAuto, "Auto Open Doors", "AutoOpenDoors", 1)
mkToggle(secAuto, "Auto Collect Kroner & Items", "AutoCollectItems", 2)
mkToggle(secAuto, "Auto Search Drawers", "AutoSearchDrawers", 3)
mkToggle(secAuto, "Auto Collect Keys & Code Breachers", "AutoCollectKeys", 4)
mkToggle(secAuto, "Auto Buy Batteries (spends Research)", "AutoRefillBatteries", 5)
mkToggle(secAuto, "Auto Turn Valves", "AutoTurnValves", 6)
mkToggle(secAuto, "Auto Repair Generators", "AutoRepairGenerators", 7)
mkToggle(secAuto, "Auto Disarm Landmines", "AutoDisarmLandmines", 8)
mkToggle(secAuto, "Room Tracker (notify room #)", "RoomTracker", 9)

local secInteract = mkSection(Pages.Auto, "Interaction Tweaks", 2)
mkToggle(secInteract, "Instant Interact (no hold)", "InstantInteract", 1)
mkToggle(secInteract, "Extended Prompt Reach (x3)", "PromptReach", 2)

--------------------------------------------------------------------------------
-- TAB: MISC (Teleports + Server actions — both were too thin to earn a tab)
--------------------------------------------------------------------------------
local secTP = mkSection(Pages.Misc, "Teleports", 1)
mkButton(secTP, "Teleport to Nearest Door", function()
	local hrp = getHRP(); if not hrp then return end
	local best, bestD = nil, math.huge
	for _, e in ipairs(PromptCache) do
		if e.kind == "door" and e.part.Parent and not isDeadEndDoor(e.model) and not PassedDoors[e.model] then
			local d = (e.part.Position - hrp.Position).Magnitude
			if d < bestD then best, bestD = e.part, d end
		end
	end
	if best then hrp.CFrame = best.CFrame * CFrame.new(0, 0, 3); Notify("Teleport", "Teleported to nearest door", 2, "success")
	else Notify("Teleport", "No door found", 2, "warn") end
end, 1)
mkButton(secTP, "Teleport to Nearest Locker", function()
	local hrp = getHRP(); if not hrp then return end
	local best, bestD = nil, math.huge
	for _, e in ipairs(PromptCache) do
		if e.kind == "locker" and e.part.Parent then
			local d = (e.part.Position - hrp.Position).Magnitude
			if d < bestD then best, bestD = e.part, d end
		end
	end
	if best then hrp.CFrame = best.CFrame + best.CFrame.LookVector * 2; Notify("Teleport", "Teleported to nearest locker", 2, "success")
	else Notify("Teleport", "No locker found", 2, "warn") end
end, 2)

--------------------------------------------------------------------------------
-- TAB: CONFIG
--------------------------------------------------------------------------------
local secCfg = mkSection(Pages.Config, "Configuration", 1)

-- Some executors implement readfile/writefile but not isfile.  The previous
-- loader treated that as "config missing", so autoload silently never ran.
-- Read directly, validate JSON, and keep a tiny recovery copy during writes.
S._readConfigData = function(name)
	if not readfile then return false, nil, "readfile unavailable" end
	local base = "Pressure_Configs/" .. name .. ".json"
	local function readCandidate(path)
		if isfile and not isfile(path) then return false, nil, "missing" end
		local ok, raw = pcall(readfile, path)
		if not ok or type(raw) ~= "string" then return false, nil, "missing" end
		local parsedOk, data = pcall(function() return HttpService:JSONDecode(raw) end)
		if not parsedOk or type(data) ~= "table" then return false, nil, "invalid json" end
		return true, data
	end
	local ok, data, reason = readCandidate(base)
	if ok then return true, data end
	local backupOk, backupData = readCandidate(base .. ".tmp")
	if backupOk then return true, backupData, "recovered" end
	return false, nil, reason
end

S._applyConfigData = function(data)
	if type(data) ~= "table" then return end
	if type(data._ui) == "table" then
		if data._ui.Theme then pcall(function() UIStyle:ApplyTheme(data._ui.Theme) end) end
		if data._ui.TextScale then pcall(function() UIStyle:ApplyTextScale(data._ui.TextScale) end) end
		if data._ui.NotificationPosition then pcall(function() UIStyle:PlaceNotifications(data._ui.NotificationPosition) end) end
	end
	-- Apply sliders and other scalar values first, then toggles.  A toggle such
	-- as Fast Swim therefore starts with its saved speed rather than a default
	-- for one frame, regardless of unordered table iteration.
	for key, value in pairs(data) do
		if CfgBind[key] and type(S[key]) ~= "boolean" then pcall(CfgBind[key], value) end
	end
	for key, value in pairs(data) do
		if CfgBind[key] and type(S[key]) == "boolean" then pcall(CfgBind[key], value) end
	end
	S._applyKeybindMap(type(data._keybinds) == "table" and data._keybinds or {})
	task.defer(function()
		if S.Destroyed then return end
		pcall(applyModuleTuning)
		pcall(refreshGameSpeed)
		pcall(applyLightingOverrides)
		pcall(refreshVisionEffects)
	end)
end

SaveConfigFile = function(name)
	if not writefile then Notify("Config", "Executor has no writefile", 2, "warn") return end
	local ok, err = pcall(function()
		if makefolder and (not isfolder or not isfolder("Pressure_Configs")) then
			-- Executors without isfolder may report "already exists" here; that
			-- is harmless, while treating it as a save failure is not.
			pcall(makefolder, "Pressure_Configs")
		end
		local data = {}
		for key in pairs(CfgBind) do data[key] = S[key] end
		data._keybinds = S.Keybinds
		data._ui = { Theme = S.UITheme, TextScale = S.UITextScale, NotificationPosition = S.NotificationPosition }
		data._schema = 2
		local path = "Pressure_Configs/" .. name .. ".json"
		local encoded = HttpService:JSONEncode(data)
		-- The .tmp file gives the loader a valid fallback if an executor aborts
		-- in the middle of replacing the main file.
		writefile(path .. ".tmp", encoded)
		writefile(path, encoded)
		if readfile then
			local verify = readfile(path)
			assert(type(verify) == "string" and type(HttpService:JSONDecode(verify)) == "table", "config verification failed")
		end
		if delfile and (not isfile or isfile(path .. ".tmp")) then pcall(delfile, path .. ".tmp") end
	end)
	Notify("Config", ok and ("Saved '" .. name .. "'") or ("Save failed: " .. tostring(err)), 2, ok and "success" or "danger")
	return ok, err
end
LoadConfigFile = function(name, silent)
	local ok, data, reason = S._readConfigData(name)
	if not ok then
		if not silent then Notify("Config", reason == "missing" and "No saved config found" or ("Load failed: " .. tostring(reason)), 2, "warn") end
		return false, reason
	end
	local applied, err = xpcall(function() S._applyConfigData(data) end, debug.traceback)
	if not applied then
		if not silent then Notify("Config", "Load failed: " .. tostring(err), 2, "danger") end
		return false, err
	end
	if not silent then Notify("Config", "Loaded '" .. name .. "'" .. (reason == "recovered" and " (recovered)" or ""), 2, "success") end
	return true, reason
end
mkButton(secCfg, "Save Default Config", function() SaveConfigFile("_autoload") end, 1)
mkButton(secCfg, "Load Default Config", function() LoadConfigFile("_autoload") end, 2)
mkButton(secCfg, "Clear All Keybinds", function() S._clearAllKeybinds() end, 3)

-- Auto-save: every toggle click / slider drag reschedules a single debounced
-- write 1s out, so flipping five settings in a row writes the file once, not
-- five times. LoadConfigFile itself never triggers this (it calls CfgBind
-- directly), so loading a config on startup can't immediately re-save it.
do
	local scheduled = false
	RequestAutoSave = function()
		if scheduled or not writefile then return end
		scheduled = true
		task.delay(1, function() scheduled = false; SaveConfigFile("_autoload") end)
	end
end
do
	local note = Instance.new("TextLabel")
	note.Parent = secCfg; note.LayoutOrder = 4; note.BackgroundTransparency = 1
	note.Size = UDim2.new(1, 0, 0, 18); note.Font = F; note.TextSize = 12
	note.TextColor3 = T.Tx3; note.TextXAlignment = Enum.TextXAlignment.Left
	note.Text = "ПКМ по функции — назначить бинд. Все изменения сохраняются автоматически."
end

--------------------------------------------------------------------------------
-- HELPERS BEHIND FORWARD DECLS
--------------------------------------------------------------------------------
attemptRespawn = function()
	task.spawn(function()
		local r = findRemote("Respawn")
		if r and r:IsA("RemoteFunction") then
			local ok, res = pcall(function() return r:InvokeServer() end)
			Notify("Respawn", ok and ("Requested (" .. tostring(res) .. ")") or "Respawn refused", 2, ok and "success" or "warn")
		else
			Notify("Respawn", "Respawn remote not found", 2, "warn")
		end
	end)
end

local lastHideAt = 0
hideInLockerNow = function(manual)
	local now = os.clock()
	if not manual and now - lastHideAt < 12 then return end
	lastHideAt = now
	task.spawn(function()
		local chk = findRemote("CheckLockerStatus")
		if chk and chk:IsA("RemoteFunction") then
			local ok, inLocker = pcall(function() return chk:InvokeServer() end)
			if ok and inLocker == true then return end
		end
		local hrp = getHRP(); if not hrp then return end
		local best, bestD, bestPrompt = nil, math.huge, nil
		-- Void lockers are excluded here at the source, not filtered later —
		-- auto-hide and this button can physically never pick one.
		for _, e in ipairs(PromptCache) do
			if e.kind == "locker" and e.part.Parent then
				local d = (e.part.Position - hrp.Position).Magnitude
				if d < bestD then best, bestD, bestPrompt = e.part, d, e.prompt end
			end
		end
		if not best then
			if manual then Notify("Hide", "No safe locker found", 2, "warn") end
			return
		end
		hrp.CFrame = best.CFrame + best.CFrame.LookVector * 2
		task.wait(0.1)
		if fireproximityprompt and bestPrompt.Parent then pcall(fireproximityprompt, bestPrompt) end
		Notify("Hide", "Hiding in locker", 2, "success")
	end)
end

-- Anti-AFK
tc(LP.Idled:Connect(function()
	if S.AntiAFK then
		local VirtualUser = game:GetService("VirtualUser")
		VirtualUser:Button2Down(Vector2.new(0, 0), cam() and cam().CFrame or CFrame.new())
		task.wait(1)
		VirtualUser:Button2Up(Vector2.new(0, 0), cam() and cam().CFrame or CFrame.new())
	end
end))

-- Infinite Jump
tc(UIS.JumpRequest:Connect(function()
	if S.InfiniteJump then
		local hum = getHum()
		if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
	end
end))

--------------------------------------------------------------------------------
-- PER-FRAME LOOP
--------------------------------------------------------------------------------
tc(RunService.Heartbeat:Connect(function(dt)
	local c = LP.Character
	local hrp = c and c:FindFirstChild("HumanoidRootPart")
	local hum = c and c:FindFirstChildOfClass("Humanoid")

	if S.JumpEnabled and hum then
		S._jumpOriginal = S._jumpOriginal or {}
		if not S._jumpOriginal[hum] then
			S._jumpOriginal[hum] = { useJumpPower = hum.UseJumpPower, jumpPower = hum.JumpPower }
		end
		pcall(function() hum.UseJumpPower = true; hum.JumpPower = S.CustomJumpPower or 50 end)
	elseif not S.JumpEnabled then
		restoreJumpPower()
	end
	for savedHum in pairs(S._jumpOriginal or {}) do
		if not savedHum.Parent then S._jumpOriginal[savedHum] = nil end
	end

	local cc = cam()
	if S.CamFOVEnabled and cc then
		if S._fovCamera ~= cc then
			restoreCameraFov()
			S._fovCamera, S._fovOriginal = cc, cc.FieldOfView
		end
		pcall(function() cc.FieldOfView = math.clamp(S.CamFOV or 70, 55, 85) end)
	elseif not S.CamFOVEnabled then
		restoreCameraFov()
	end
	if S.Spinbot and hrp then
		pcall(function() hrp.CFrame = hrp.CFrame * CFrame.Angles(0, (S.SpinSpeed or 20) * dt, 0) end)
	end
	if S.Fly and hrp then
		local bv = S._flyBV
		if not bv or bv.Parent ~= hrp then
			pcall(function() if bv then bv:Destroy() end end)
			bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(9e4, 9e4, 9e4); bv.Velocity = Vector3.zero; bv.Parent = hrp
			S._flyBV = bv
		end
		local cc = cam()
		if cc then
			local dir = Vector3.zero
			local look, right = cc.CFrame.LookVector, cc.CFrame.RightVector
			if UIS:IsKeyDown(Enum.KeyCode.W) then dir += look end
			if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= look end
			if UIS:IsKeyDown(Enum.KeyCode.D) then dir += right end
			if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= right end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
			if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
			if dir.Magnitude > 0 then dir = dir.Unit end
			bv.Velocity = dir * (S.FlySpeed or 50)
		end
	end
end))

tc(RunService.Stepped:Connect(function()
	if S.NoClip or S.Fly then
		local c = LP.Character
		if c then
			S._noclipTouched = S._noclipTouched or {}
			for _, p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") then
					if S._noclipTouched[p] == nil then S._noclipTouched[p] = p.CanCollide end
					if p.CanCollide then p.CanCollide = false end
				end
			end
		end
	else
		restoreNoClip()
	end
end))

--------------------------------------------------------------------------------
-- SLOW LOOPS
--------------------------------------------------------------------------------
task.spawn(function()
	while not S.Destroyed do
		if S.SpeedEnabled then installSpeedHook(); refreshGameSpeed() end
		task.wait(0.5)
	end
end)

task.spawn(function()
	while not S.Destroyed do
		pcall(applyLightingOverrides)
		pcall(refreshVisionEffects)
		if S.InfiniteOxygen then
			pcall(function()
				local m = getMain(); local ox = m and m.OxygenTank
				if type(ox) == "table" and ox.TankValue then ox.TankValue.Value = 100 end
			end)
		end
		if S.FastSwim then
			pcall(function()
				local m = getMain(); local sw = m and m.Swimming
				if type(sw) == "table" then
					saveSwimDefaults(sw)
					-- Do not write CurrentSwimSpeed here: it is a live acceleration value.
					sw.SwimmingSpeed = math.clamp(tonumber(S.SwimSpeed) or 32, 18, 65)
				end
			end)
		end
		task.wait(0.4)
	end
end)

task.spawn(function()
	while not S.Destroyed do
		if S.AutoShakeParasite then
			local r = findRemote("ParasiteShakeOff")
			if r and r.FireServer then pcall(function() r:FireServer() end) end
		end
		task.wait(0.5)
	end
end)
task.spawn(function()
	while not S.Destroyed do
		if S.AutoDozerStealth then
			-- Same ping the game's own LocalFish sends while crouched near the Dozer.
			local r = findRemote("DozerCrouchingCheck")
			if r and r.FireServer then pcall(function() r:FireServer() end) end
		end
		task.wait(1.5)
	end
end)

-- Instant Interact / Extended Reach: patch prompt HoldDuration and
-- MaxActivationDistance with original-value bookkeeping so toggling off
-- restores the game's own values exactly.
S._promptOrig = {}
task.spawn(function()
	while not S.Destroyed do
		local wantAny = S.InstantInteract or S.PromptReach
		if wantAny or next(S._promptOrig) then
			pcall(function()
				if wantAny then
					for _, e in ipairs(PromptCache) do
						local pr = e.prompt
						if pr.Parent then
							local o = S._promptOrig[pr]
							if not o then o = { hold = pr.HoldDuration, dist = pr.MaxActivationDistance }; S._promptOrig[pr] = o end
							pr.HoldDuration = S.InstantInteract and 0 or o.hold
							pr.MaxActivationDistance = S.PromptReach and math.min(o.dist * 3, 60) or o.dist
						end
					end
				else
					for pr, o in pairs(S._promptOrig) do
						pcall(function() if pr.Parent then pr.HoldDuration = o.hold; pr.MaxActivationDistance = o.dist end end)
						S._promptOrig[pr] = nil
					end
				end
				for pr in pairs(S._promptOrig) do if not pr.Parent then S._promptOrig[pr] = nil end end
			end)
		end
		task.wait(0.5)
	end
end)

-- Keypad code watcher: the game hands the real code to the client as a
-- Player attribute the moment it's set.
do
	local function announceCode()
		local code = LP:GetAttribute("Code")
		if code and tostring(code) ~= "" then
			local rn = LP:GetAttribute("RoomNum")
			Notify("Keypad Code", tostring(code) .. (rn and ("  (room " .. tostring(rn) .. ")") or ""), 6, "warn")
		end
	end
	tc(LP:GetAttributeChangedSignal("Code"):Connect(announceCode))
	task.spawn(announceCode)
end

--------------------------------------------------------------------------------
-- ENTITY SCANNER
--------------------------------------------------------------------------------
local EntityCache = {}
task.spawn(function()
	while not S.Destroyed do
		local found = {}
		local gf = getGF()
		local monstersFolder = gf and gf:FindFirstChild("Monsters")
		local function scan(container)
			if not container then return end
			for _, obj in ipairs(container:GetChildren()) do
				if obj:IsA("Model") or obj:IsA("BasePart") then
					local kind = monsterKind(obj.Name:lower())
					if kind then found[#found + 1] = { obj = obj, kind = kind } end
				end
			end
		end
		pcall(scan, monstersFolder)
		pcall(scan, Workspace)
		EntityCache = found
		for _, e in ipairs(found) do
			if e.kind == "monster" or e.kind == "dweller" then
				ShowEntityWarning(e.obj.Name)
				if S.AutoHideInLocker and e.kind == "monster" then hideInLockerNow(false) end
			end
		end
		task.wait(0.45)
	end
end)

-- Anti-Eyefestation: never fight Pressure's scripted locker camera.  The
-- character is normally anchored while entering/hiding, and the server's
-- CheckLockerStatus lets us hold the pause for the short exit transition too.
local antiEyePauseUntil, antiEyeLockerCheckAt = 0, 0
local function shouldPauseAntiEyeCamera()
	local now = os.clock()
	local hrp, hum, cc = getHRP(), getHum(), cam()
	if (hrp and hrp.Anchored) or (cc and hum and cc.CameraSubject ~= hum) then
		antiEyePauseUntil = now + 0.9
	end
	if now >= antiEyeLockerCheckAt then
		antiEyeLockerCheckAt = now + 0.35
		local check = findRemote("CheckLockerStatus")
		if check and check:IsA("RemoteFunction") then
			local ok, inLocker = pcall(function() return check:InvokeServer() end)
			if ok and inLocker == true then antiEyePauseUntil = now + 0.9 end
		end
	end
	return now < antiEyePauseUntil
end
task.spawn(function()
	while not S.Destroyed do
		if S.AntiEyefest then
			pcall(function()
				local cc = cam(); if not cc or shouldPauseAntiEyeCamera() then return end
				for _, e in ipairs(EntityCache) do
					if e.kind == "eyefest" and e.obj.Parent then
						local p = objPos(e.obj)
						if p then
							local toIt = p - cc.CFrame.Position
							local flat = Vector3.new(toIt.X, 0, toIt.Z)
							if flat.Magnitude > 1 then
								flat = flat.Unit
								if cc.CFrame.LookVector:Dot(flat) > -0.2 then
									local pos = cc.CFrame.Position
									cc.CFrame = CFrame.lookAt(pos, pos - flat * 10)
								end
							end
						end
						break
					end
				end
			end)
		end
		task.wait(0.12)
	end
end)

task.spawn(function()
	local hooked = {}
	while not S.Destroyed do
		pcall(function()
			local gf = getGF()
			local mf = gf and gf:FindFirstChild("Monsters")
			if mf and not hooked[mf] then
				hooked[mf] = true
				tc(mf.ChildAdded:Connect(function(monster)
					if not monster then return end
					ShowEntityWarning(monster.Name)
					if S.AutoHideInLocker then hideInLockerNow(false) end
				end))
			end
		end)
		task.wait(3)
	end
end)

--------------------------------------------------------------------------------
-- ESP: demonology-style billboard tags + outline highlights
--------------------------------------------------------------------------------
local ESP_COLORS = {
	monster = Color3.fromRGB(255, 60, 60), dweller = Color3.fromRGB(255, 150, 0),
	eyefest = Color3.fromRGB(170, 70, 255), squiddle = Color3.fromRGB(255, 220, 40),
	carnation = Color3.fromRGB(255, 120, 200), hazard = Color3.fromRGB(255, 100, 100),
	door = Color3.fromRGB(70, 200, 255), nextdoor = Color3.fromRGB(80, 255, 120),
	keycarddoor = Color3.fromRGB(255, 162, 66), locker = Color3.fromRGB(70, 255, 150),
	voidlocker = Color3.fromRGB(255, 40, 90), drawer = Color3.fromRGB(180, 255, 130),
	item = Color3.fromRGB(90, 170, 255), currency = Color3.fromRGB(255, 215, 0),
	keycard = Color3.fromRGB(255, 228, 72), refill = Color3.fromRGB(255, 188, 82),
	valve = Color3.fromRGB(112, 225, 190), repair = Color3.fromRGB(255, 142, 82),
	objective = Color3.fromRGB(180, 255, 130), other = Color3.fromRGB(150, 220, 255),
}

-- Doors persist in the world after you walk through them (unlike loot,
-- which the game removes on pickup), so they're the one ESP category that
-- needs explicit "stop showing it" tracking — once you're within 7 studs of
-- a door you've clearly already gone through it.
local PassedDoors = {}
local function doorPassed(model, pos, myPos)
	if PassedDoors[model] then return true end
	if myPos and pos and (pos - myPos).Magnitude <= 7 then
		PassedDoors[model] = true
		return true
	end
	return false
end

local TagReg = {}
local function centerOffsetFor(adornee)
	if not adornee:IsA("Model") then return Vector3.new(0, 0, 0) end
	local ok, boxCF = pcall(function() return (adornee:GetBoundingBox()) end)
	if not ok or not boxCF then return Vector3.new(0, 0, 0) end
	local ok2, pivot = pcall(function() return adornee:GetPivot() end)
	if not ok2 or not pivot then return Vector3.new(0, 0, 0) end
	return boxCF.Position - pivot.Position
end
local function mkEspTag(adornee, title, color, strong, style)
	local priority = style == "keycard" or style == "keycarddoor"
	local bb = Instance.new("BillboardGui")
	bb.Name = "PressureEspTag"
	bb.Adornee = adornee; bb.AlwaysOnTop = true; bb.LightInfluence = 0
	bb.Size = UDim2.fromOffset(priority and 172 or 134, priority and 42 or 38)
	bb.StudsOffset = Vector3.new(0, 1.8, 0)
	bb.StudsOffsetWorldSpace = centerOffsetFor(adornee)
	bb.MaxDistance = S.ESPMaxDist or 1500
	bb.Parent = adornee

	local card = Instance.new("Frame")
	card.Parent = bb; card.BackgroundColor3 = Color3.fromRGB(9, 9, 10); card.BackgroundTransparency = 0.22
	card.BorderSizePixel = 0; card.Size = UDim2.new(1, 0, 1, 0)
	Corner(card, 9); Stroke(card, color, 1.2, 0.25); Grad(card, Color3.fromRGB(26, 26, 28), Color3.fromRGB(9, 9, 10), 90)

	local dot = Instance.new("Frame")
	dot.Parent = card; dot.AnchorPoint = Vector2.new(0, 0.5)
	dot.Position = UDim2.new(0, 8, 0.3, 0); dot.Size = UDim2.new(0, priority and 8 or 6, 0, priority and 8 or 6); dot.BackgroundColor3 = color
	Corner(dot, priority and 4 or 3)

	local tl = Instance.new("TextLabel")
	tl.Parent = card; tl.BackgroundTransparency = 1
	tl.Position = UDim2.new(0, 18, 0, 2); tl.Size = UDim2.new(1, priority and -72 or -22, 0, 16)
	tl.Font = FM; tl.Text = title; tl.TextColor3 = T.White; tl.TextSize = 13
	tl.TextXAlignment = Enum.TextXAlignment.Left; tl.TextTruncate = Enum.TextTruncate.AtEnd
	if priority then
		local badge = Instance.new("TextLabel")
		badge.Parent = card; badge.AnchorPoint = Vector2.new(1, 0)
		badge.Position = UDim2.new(1, -7, 0, 6); badge.Size = UDim2.fromOffset(48, 13)
		badge.BackgroundColor3 = color; badge.BackgroundTransparency = 0.72
		badge.BorderSizePixel = 0; badge.Font = FB; badge.TextSize = 8; badge.TextColor3 = color
		badge.Text = style == "keycard" and "PICK UP" or "ACCESS"
		Corner(badge, 4); Stroke(badge, color, 1, 0.25)
	end

	local distLbl = Instance.new("TextLabel")
	distLbl.Parent = card; distLbl.BackgroundTransparency = 1
	distLbl.Position = UDim2.new(0, 18, 0, 19); distLbl.Size = UDim2.new(1, -22, 0, 14)
	distLbl.Font = F; distLbl.Text = ""; distLbl.TextColor3 = T.Tx2; distLbl.TextSize = 11
	distLbl.TextXAlignment = Enum.TextXAlignment.Left

	local sc = Instance.new("UIScale"); sc.Scale = 0.6; sc.Parent = card
	Tween(sc, 0.25, { Scale = 1 }, Enum.EasingStyle.Back):Play()

	local hl = Instance.new("Highlight")
	hl.Name = "PressureEspHL"; hl.Adornee = adornee; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.OutlineColor = color; hl.FillColor = color
	hl.FillTransparency = strong and 0.55 or 0.9; hl.OutlineTransparency = strong and 0 or 0.15
	hl.Parent = adornee

	-- Priority objects pulse gently; keycards and card-reader doors use the
	-- same restrained motion so they are visible without flooding the screen.
	if strong then
		task.spawn(function()
			while hl.Parent do
				Tween(hl, 0.7, { FillTransparency = 0.8 }, Enum.EasingStyle.Sine):Play()
				task.wait(0.7)
				if not hl.Parent then break end
				Tween(hl, 0.7, { FillTransparency = 0.55 }, Enum.EasingStyle.Sine):Play()
				task.wait(0.7)
			end
		end)
	end

	return { bb = bb, hl = hl, distLbl = distLbl, title = tl, adornee = adornee, color = color, strong = strong, style = style }
end
local function destroyTag(obj)
	local e = TagReg[obj]
	if e then pcall(function() e.bb:Destroy() end); pcall(function() e.hl:Destroy() end) end
	TagReg[obj] = nil
end

task.spawn(function()
	while not S.Destroyed do
	pcall(function()
			local hrp = getHRP()
			local myPos = hrp and hrp.Position
			local wants = {}
			for door in pairs(PassedDoors) do
				if not door.Parent then PassedDoors[door] = nil end
			end

			local entKindOn = {
				monster = S.EntityESP, dweller = S.WallDwellerESP, eyefest = S.EyefestESP,
				squiddle = S.SquiddleESP, carnation = S.CarnationESP,
			}
			for _, e in ipairs(EntityCache) do
				if e.obj.Parent and entKindOn[e.kind] then
					local p = objPos(e.obj)
					if p then
						wants[e.obj] = { title = e.obj.Name, color = ESP_COLORS[e.kind], strong = true, d = myPos and (p - myPos).Magnitude or 0 }
					end
				end
			end

			local promptKindOn = {
				door = S.DoorESP, locker = S.LockerESP, drawer = S.DrawerESP,
				item = S.ItemESP, currency = S.KronerESP, hazard = S.HazardESP,
				keycard = S.KeycardESP, refill = S.ObjectiveESP, valve = S.ObjectiveESP,
				repair = S.ObjectiveESP, objective = S.ObjectiveESP, other = S.ItemESP,
				-- Always on, no toggle: a void locker kills you if you hide
				-- in it. This warning shouldn't be optional.
				voidlocker = true,
			}
			local perKind = {}
			for _, e in ipairs(PromptCache) do
				-- A completed RepairSystem keeps its model around after the prompt
				-- disappears. It is no longer an objective, so never leave ESP/chams
				-- on it once Fixed reaches 100.
				local completedRepair = e.kind == "repair" and isRepairComplete(e)
				if e.part.Parent and promptKindOn[e.kind] and not completedRepair and not (e.kind == "door" and isDeadEndDoor(e.model)) then
					local displayKind = e.kind
					if e.kind == "door" and isKeycardDoor(e) then displayKind = "keycarddoor" end
					local d = myPos and (e.part.Position - myPos).Magnitude or 0
					if d <= math.min(S.ESPMaxDist or 1500, 500) then
						perKind[displayKind] = perKind[displayKind] or {}
						table.insert(perKind[displayKind], { e = e, d = d, displayKind = displayKind })
					end
				end
			end
			local KIND_CAP = {
				door = 6, keycarddoor = 6, locker = 8, voidlocker = 8, drawer = 10,
				item = 10, currency = 10, keycard = 6, hazard = 8, refill = 5,
				valve = 6, repair = 4, objective = 7, other = 6,
			}
			for kind, list in pairs(perKind) do
				table.sort(list, function(a, b) return a.d < b.d end)
				for i = 1, math.min(#list, KIND_CAP[kind] or 8) do
					local c = list[i]
					if not wants[c.e.model] then
						if c.e.kind == "door" and doorPassed(c.e.model, objPos(c.e.model) or c.e.part.Position, myPos) then
							-- already walked through it, don't re-clutter the screen
						else
							local displayKind = c.displayKind
							if c.e.kind == "door" and c.e.model:GetAttribute("ProgressDoor") then displayKind = "nextdoor" end
							local priority = displayKind == "keycard" or displayKind == "keycarddoor"
								or displayKind == "nextdoor" or displayKind == "repair" or displayKind == "valve"
							wants[c.e.model] = {
								title = tagTitleFor(c.e), color = ESP_COLORS[displayKind] or ESP_COLORS[c.e.kind],
								strong = priority or c.e.kind == "hazard" or c.e.kind == "voidlocker",
								style = displayKind, d = c.d,
							}
						end
					end
				end
			end

			-- Some real next-room doors have no prompt in the early loading frame.
			-- Scan those only; fake/dead-end door models are intentionally never added.
			if S.DoorESP then
				local gf2 = getGF()
				local rooms = gf2 and gf2:FindFirstChild("Rooms")
				if rooms then
					for _, room in ipairs(rooms:GetChildren()) do
						for _, ch in ipairs(room:GetChildren()) do
							if ch:IsA("Model") then
								local isNext = ch:GetAttribute("ProgressDoor") == true
								if isNext and not isDeadEndDoor(ch) then
									local p = objPos(ch)
									if p and not doorPassed(ch, p, myPos) then
										local d = (myPos and p) and (p - myPos).Magnitude or 0
										if d <= 500 then
											wants[ch] = { title = "NEXT ROOM >>", color = ESP_COLORS.nextdoor, strong = true, style = "nextdoor", d = d }
										end
									end
								end
							end
						end
					end
				end
			end

			-- Roblox renders ~31 Highlights at once — keep the nearest 26,
			-- entities (strong) always win the budget.
			local ordered = {}
			for obj, w in pairs(wants) do ordered[#ordered + 1] = { obj = obj, w = w } end
			table.sort(ordered, function(a, b)
				if a.w.strong ~= b.w.strong then return a.w.strong end
				return a.w.d < b.w.d
			end)
			local allowHL = {}
			for i, it in ipairs(ordered) do if i <= 26 then allowHL[it.obj] = true end end

			for obj in pairs(TagReg) do if not wants[obj] or not obj.Parent then destroyTag(obj) end end
			for obj, w in pairs(wants) do
				local e = TagReg[obj]
				if not e or not e.bb.Parent or e.style ~= w.style then
					if e then destroyTag(obj) end
					TagReg[obj] = mkEspTag(obj, w.title, w.color, w.strong, w.style)
					e = TagReg[obj]
				end
				if e.title.Text ~= w.title then e.title.Text = w.title end
				local wantHLT = allowHL[obj] and (w.strong and 0.55 or 0.9) or 1
				local wantOLT = allowHL[obj] and (w.strong and 0 or 0.15) or 1
				if e.hl and e.hl.Parent then e.hl.FillTransparency = wantHLT; e.hl.OutlineTransparency = wantOLT end
			end
		end)
		task.wait(0.4)
	end
end)

task.spawn(function()
	while not S.Destroyed do
		pcall(function()
			local hrp = getHRP()
			local myPos = hrp and hrp.Position
			for obj, e in pairs(TagReg) do
				if not obj.Parent then destroyTag(obj)
				elseif myPos then
					local p = objPos(obj)
					if p then e.distLbl.Text = math.floor((p - myPos).Magnitude + 0.5) .. "m" end
				end
			end
		end)
		task.wait(0.15)
	end
end)

-- AUTOMATION LOOP (only interaction contracts verified in the live client)
task.spawn(function()
	while not S.Destroyed do
		if (S.AutoOpenDoors or S.AutoCollectItems or S.AutoSearchDrawers or S.AutoCollectKeys
			or S.AutoRefillBatteries or S.AutoTurnValves or S.AutoDisarmLandmines) and fireproximityprompt then
			pcall(function()
				local hrp = getHRP(); if not hrp then return end
				local myPos = hrp.Position
				for _, e in ipairs(PromptCache) do
					if e.prompt.Parent and e.part.Parent then
						local d = (e.part.Position - myPos).Magnitude
						if S.AutoOpenDoors and e.kind == "door" and not isDeadEndDoor(e.model) and d <= 12 then pcall(fireproximityprompt, e.prompt)
						elseif S.AutoCollectItems and (e.kind == "currency" or e.kind == "item") and d <= 18 then pcall(fireproximityprompt, e.prompt)
						elseif S.AutoSearchDrawers and e.kind == "drawer" and d <= 10 then pcall(fireproximityprompt, e.prompt)
						elseif S.AutoCollectKeys and e.kind == "keycard" and d <= 18 then pcall(fireproximityprompt, e.prompt)
						elseif S.AutoRefillBatteries and e.kind == "refill" and d <= 7 then pcall(fireproximityprompt, e.prompt)
						elseif S.AutoTurnValves and e.kind == "valve" and d <= 5 then pcall(fireproximityprompt, e.prompt)
						elseif S.AutoDisarmLandmines and e.interactionType == "Landmine" and d <= 5.5 then pcall(fireproximityprompt, e.prompt)
						end
						-- NEVER auto-fire: locker (traps you), voidlocker, other hazards,
						-- repair and generic objectives/minigames.
					end
				end
			end)
		end
		task.wait(0.4)
	end
end)

-- RepairSystem is not a ProximityPrompt-only interaction: Pressure first
-- grants the player the generator through RemoteFunction, then accepts a
-- successful repair tick through its local RemoteEvent.  The server rejects
-- ticks faster than 0.3s, so stay above that limit and never teleport to a
-- machine.  Turning the feature off sends the documented clean exit branch
-- (false, true), avoiding the damage branch and releasing the generator.
local autoRepair = { root = nil, event = nil, lastStart = 0, lastTick = 0 }
S._stopAutoRepair = function()
	if autoRepair.event and autoRepair.event.Parent then
		pcall(function() autoRepair.event:FireServer(false, true) end)
	end
	autoRepair.root, autoRepair.event, autoRepair.lastStart, autoRepair.lastTick = nil, nil, 0, 0
end
task.spawn(function()
	while not S.Destroyed do
		pcall(function()
			if not S.AutoRepairGenerators then
				if autoRepair.root then S._stopAutoRepair() end
				return
			end
			local hrp = getHRP(); if not hrp then return end
			local myPos = hrp.Position
			local target
			for _, e in ipairs(PromptCache) do
				if e.kind == "repair" and e.interactionRoot and e.interactionRoot.Parent and e.part.Parent then
					local fixed = e.interactionRoot:FindFirstChild("Fixed")
					if fixed and tonumber(fixed.Value) and fixed.Value < 100 and (e.part.Position - myPos).Magnitude <= 5.25 then
						target = e
						break
					end
				end
			end
			if not target then return end

			local root = target.interactionRoot
			local remoteFunction = root:FindFirstChild("RemoteFunction")
			local remoteEvent = root:FindFirstChild("RemoteEvent")
			if not (remoteFunction and remoteFunction:IsA("RemoteFunction") and remoteEvent and remoteEvent:IsA("RemoteEvent")) then return end
			local now = os.clock()
			if autoRepair.root and autoRepair.root ~= root then
				S._stopAutoRepair()
			end
			if autoRepair.root ~= root then
				if now - autoRepair.lastStart < 1 then return end
				autoRepair.lastStart = now
				local ok, accepted = pcall(function() return remoteFunction:InvokeServer() end)
				if not (ok and accepted == true) then return end
				autoRepair.root, autoRepair.event, autoRepair.lastTick = root, remoteEvent, 0
			end
			if now - autoRepair.lastTick >= 0.36 then
				autoRepair.lastTick = now
				pcall(function() remoteEvent:FireServer(true) end)
			end
		end)
		task.wait(0.12)
	end
end)

--------------------------------------------------------------------------------
-- PLAYER ESP
--------------------------------------------------------------------------------
local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "PressureESP"; ESPGui.ResetOnSpawn = false; ESPGui.IgnoreGuiInset = true; ESPGui.DisplayOrder = 950
pcall(function() ESPGui.Parent = uiP end)
table.insert(UIStyle.Roots, ESPGui)
SG.Destroying:Connect(function() pcall(function() ESPGui:Destroy() end) end)

-- One waypoint tracer to the nearest keycard/code breacher — a straight
-- line from screen-bottom-center is a lot easier to follow at a glance than
-- hunting for a small tag in a dark room.
local KeycardTracer = Instance.new("Frame")
KeycardTracer.BorderSizePixel = 0
KeycardTracer.AnchorPoint = Vector2.new(0.5, 0.5)
KeycardTracer.Size = UDim2.new(0, 2, 0, 0)
KeycardTracer.BackgroundColor3 = ESP_COLORS.keycard
KeycardTracer.BackgroundTransparency = 0.03
KeycardTracer.Visible = false
KeycardTracer.Parent = ESPGui
Corner(KeycardTracer, 1)

local KeycardBeacon = Instance.new("TextLabel")
KeycardBeacon.Name = "PressureKeycardBeacon"
KeycardBeacon.AnchorPoint = Vector2.new(0.5, 1)
KeycardBeacon.Size = UDim2.fromOffset(138, 24)
KeycardBeacon.BackgroundColor3 = Color3.fromRGB(24, 19, 7)
KeycardBeacon.BackgroundTransparency = 0.12
KeycardBeacon.BorderSizePixel = 0
KeycardBeacon.Font = FB
KeycardBeacon.TextSize = 11
KeycardBeacon.TextColor3 = ESP_COLORS.keycard
KeycardBeacon.Text = "KEYCARD"
KeycardBeacon.Visible = false
KeycardBeacon.Parent = ESPGui
Corner(KeycardBeacon, 7)
Stroke(KeycardBeacon, ESP_COLORS.keycard, 1, 0.15)

local NextDoorTracer = Instance.new("Frame")
NextDoorTracer.Name = "PressureNextDoorWaypoint"
NextDoorTracer.BorderSizePixel = 0
NextDoorTracer.AnchorPoint = Vector2.new(0.5, 0.5)
NextDoorTracer.Size = UDim2.new(0, 2, 0, 0)
NextDoorTracer.BackgroundColor3 = ESP_COLORS.nextdoor
NextDoorTracer.BackgroundTransparency = 0.05
NextDoorTracer.Visible = false
NextDoorTracer.Parent = ESPGui
Corner(NextDoorTracer, 1)

-- Compact in-game status card.  It lives in the ESP GUI (not the click GUI),
-- so it remains readable while the menu is closed and costs only a handful of
-- UI instances.
local StatusHUD = Instance.new("Frame")
StatusHUD.Name = "PressureStatusHUD"
StatusHUD.AnchorPoint = Vector2.new(0, 1)
StatusHUD.Position = UDim2.new(0, 18, 1, -20)
StatusHUD.Size = UDim2.fromOffset(204, 92)
StatusHUD.BackgroundColor3 = T.Card
StatusHUD.BackgroundTransparency = 0.12
StatusHUD.BorderSizePixel = 0
StatusHUD.Visible = false
StatusHUD.Parent = ESPGui
Corner(StatusHUD, 10)
Stroke(StatusHUD, T.Bd2, 1, 0.38)
Grad(StatusHUD, T.White:Lerp(T.Accent, 0.12), T.White:Lerp(T.Elev, 0.08), 90)

local statusHeader = Instance.new("TextLabel")
statusHeader.Parent = StatusHUD; statusHeader.BackgroundTransparency = 1
statusHeader.Position = UDim2.fromOffset(12, 7); statusHeader.Size = UDim2.new(1, -24, 0, 16)
statusHeader.Font = FB; statusHeader.TextSize = 11; statusHeader.TextColor3 = T.Tx2
statusHeader.TextXAlignment = Enum.TextXAlignment.Left; statusHeader.Text = "HADAL // VITALS"

local statusRoom = Instance.new("TextLabel")
statusRoom.Parent = StatusHUD; statusRoom.BackgroundTransparency = 1
statusRoom.Position = UDim2.fromOffset(12, 25); statusRoom.Size = UDim2.new(1, -24, 0, 16)
statusRoom.Font = FM; statusRoom.TextSize = 12; statusRoom.TextColor3 = T.White
statusRoom.TextXAlignment = Enum.TextXAlignment.Left; statusRoom.Text = "ROOM —"

local function mkVitalRow(parent, label, y)
	local text = Instance.new("TextLabel")
	text.Parent = parent; text.BackgroundTransparency = 1
	text.Position = UDim2.fromOffset(12, y); text.Size = UDim2.new(1, -24, 0, 14)
	text.Font = F; text.TextSize = 11; text.TextColor3 = T.Tx2; text.TextXAlignment = Enum.TextXAlignment.Left
	local back = Instance.new("Frame")
	back.Parent = parent; back.Position = UDim2.fromOffset(12, y + 16); back.Size = UDim2.new(1, -24, 0, 4)
	back.BackgroundColor3 = Color3.fromRGB(40, 47, 53); back.BorderSizePixel = 0; Corner(back, 2)
	local fill = Instance.new("Frame")
	fill.Parent = back; fill.Size = UDim2.new(1, 0, 1, 0); fill.BackgroundColor3 = T.Tx
	fill.BorderSizePixel = 0; Corner(fill, 2)
	return text, fill
end
local oxygenText, oxygenFill = mkVitalRow(StatusHUD, "", 43)
local healthText, healthFill = mkVitalRow(StatusHUD, "", 66)

-- Bound controls get a separate, compact HUD.  Toggle rows appear only while
-- they are active; action buttons remain visible so their hotkeys are never a
-- mystery.  It automatically sits above the vitals card when both are enabled.
local KeybindHUD = Instance.new("Frame")
KeybindHUD.Name = "PressureKeybindHUD"
KeybindHUD.AnchorPoint = Vector2.new(0, 1)
KeybindHUD.Position = UDim2.new(0, 18, 1, -20)
KeybindHUD.Size = UDim2.fromOffset(228, 30)
KeybindHUD.BackgroundColor3 = T.Card
KeybindHUD.BackgroundTransparency = 0.12
KeybindHUD.BorderSizePixel = 0
KeybindHUD.Visible = false
KeybindHUD.Parent = ESPGui
Corner(KeybindHUD, 10)
Stroke(KeybindHUD, T.Accent, 1, 0.38)
Grad(KeybindHUD, T.White:Lerp(T.Accent, 0.12), T.White:Lerp(T.Elev, 0.08), 90)

local keybindTitle = Instance.new("TextLabel")
keybindTitle.Parent = KeybindHUD; keybindTitle.BackgroundTransparency = 1
keybindTitle.Position = UDim2.fromOffset(12, 7); keybindTitle.Size = UDim2.new(1, -24, 0, 15)
keybindTitle.Font = FB; keybindTitle.TextSize = 11; keybindTitle.TextColor3 = T.Tx2
keybindTitle.TextXAlignment = Enum.TextXAlignment.Left; keybindTitle.Text = "KEYBINDS"

local KeybindRows = {}
local function getKeybindRow(index)
	local row = KeybindRows[index]
	if row then return row end
	row = Instance.new("Frame")
	row.Name = "BindRow"; row.Parent = KeybindHUD
	row.BackgroundColor3 = T.Elev; row.BackgroundTransparency = 0.38
	row.BorderSizePixel = 0; row.Size = UDim2.new(1, -16, 0, 18)
	Corner(row, 5)
	local label = Instance.new("TextLabel")
	label.Name = "Label"; label.Parent = row; label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(7, 0); label.Size = UDim2.new(1, -66, 1, 0)
	label.Font = F; label.TextSize = 11; label.TextColor3 = T.Tx2
	label.TextXAlignment = Enum.TextXAlignment.Left; label.TextTruncate = Enum.TextTruncate.AtEnd
	local key = Instance.new("TextLabel")
	key.Name = "Key"; key.Parent = row; key.BackgroundTransparency = 1
	key.AnchorPoint = Vector2.new(1, 0); key.Position = UDim2.new(1, -7, 0, 0)
	key.Size = UDim2.fromOffset(54, 18); key.Font = FM; key.TextSize = 10
	key.TextColor3 = T.White; key.TextXAlignment = Enum.TextXAlignment.Right; key.TextTruncate = Enum.TextTruncate.AtEnd
	KeybindRows[index] = row
	return row
end

S._refreshKeybindHUD = function()
	S._bindHUDDirty = false
	local entries = {}
	for id, entry in pairs(S._bindRegistry or {}) do
		local token = S.Keybinds[id]
		if token then
			local show = entry.kind ~= "toggle"
			if entry.kind == "toggle" and entry.isActive then
				local ok, active = pcall(entry.isActive)
				show = ok and active == true
			end
			if show then table.insert(entries, { entry = entry, token = token }) end
		end
	end
	table.sort(entries, function(a, b) return a.entry.label < b.entry.label end)
	KeybindHUD.Visible = S.KeybindHUD == true and #entries > 0
	if not KeybindHUD.Visible then return end
	local height = 29 + (#entries * 21)
	KeybindHUD.Size = UDim2.fromOffset(228, height)
	KeybindHUD.Position = UDim2.new(0, 18, 1, S.StatusHUD and -122 or -20)
	for i, data in ipairs(entries) do
		local row = getKeybindRow(i)
		row.Position = UDim2.new(0, 8, 0, 25 + ((i - 1) * 21))
		row.Visible = true
		row.Label.Text = string.upper(data.entry.label)
		row.Key.Text = S._bindTokenTitle(data.token)
		row.Label.TextColor3 = data.entry.kind == "toggle" and T.White or T.Tx2
		row.Key.TextColor3 = data.entry.kind == "toggle" and T.Accent or T.Tx
	end
	for i = #entries + 1, #KeybindRows do KeybindRows[i].Visible = false end
end
S._markKeybindHUDDirty()

-- Up to four nearest off-screen threats.  The arrow itself rotates; the name
-- stays level, which makes it readable during fast turns and chase scenes.
local ThreatArrowPool = {}
local function getThreatArrow(index)
	local entry = ThreatArrowPool[index]
	if entry then return entry end
	local holder = Instance.new("Frame")
	holder.Name = "PressureThreatArrow"
	holder.AnchorPoint = Vector2.new(0.5, 0.5)
	holder.Size = UDim2.fromOffset(96, 46)
	holder.BackgroundTransparency = 1
	holder.Visible = false
	holder.Parent = ESPGui
	local arrow = Instance.new("TextLabel")
	arrow.Parent = holder; arrow.BackgroundTransparency = 1
	arrow.AnchorPoint = Vector2.new(0.5, 0.5); arrow.Position = UDim2.fromOffset(48, 12)
	arrow.Size = UDim2.fromOffset(24, 24); arrow.Font = FB; arrow.TextSize = 20
	arrow.Text = "▲"; arrow.TextColor3 = Color3.fromRGB(255, 85, 85)
	local label = Instance.new("TextLabel")
	label.Parent = holder; label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(0, 25); label.Size = UDim2.new(1, 0, 0, 16)
	label.Font = FB; label.TextSize = 10; label.TextColor3 = T.White
	label.TextTruncate = Enum.TextTruncate.AtEnd; label.TextXAlignment = Enum.TextXAlignment.Center
	entry = { holder = holder, arrow = arrow, label = label }
	ThreatArrowPool[index] = entry
	return entry
end

local CHAM_FILL = Color3.fromRGB(104, 222, 196)
local CHAM_OUTLINE = Color3.fromRGB(218, 255, 244)
local function clearTeammateCham(plr)
	local entry = TeammateChamReg[plr]
	if entry then
		pcall(function() if entry.model then entry.model:Destroy() end end)
		TeammateChamReg[plr] = nil
	end
	local ch = plr and plr.Character
	local legacy = ch and ch:FindFirstChild("PressurePlayerCham")
	if legacy then pcall(function() legacy:Destroy() end) end
end

local function createTeammateCham(plr, ch)
	local proxy = Instance.new("Model")
	proxy.Name = "PressureTeammateCham"
	local links = {}
	for _, source in ipairs(ch:GetDescendants()) do
		if source:IsA("BasePart") and source.Name ~= "HumanoidRootPart" then
			local ok, copy = pcall(function() return source:Clone() end)
			if ok and copy and copy:IsA("BasePart") then
				-- Keep geometry/decals for MeshParts and heads, but remove joints,
				-- emitters and scripts so the proxy stays visual-only and inert.
				for _, child in ipairs(copy:GetChildren()) do
					if not (child:IsA("SpecialMesh") or child:IsA("Decal") or child:IsA("Texture")) then
						child:Destroy()
					end
				end
				copy.Name = source.Name
				copy.Anchored = true; copy.CanCollide = false; copy.CanTouch = false; copy.CanQuery = false
				copy.CastShadow = false; copy.Massless = true
				copy.Material = Enum.Material.ForceField
				copy.Color = CHAM_FILL; copy.Transparency = 0.38; copy.LocalTransparencyModifier = 0
				copy.CFrame = source.CFrame
				copy.Parent = proxy
				links[source] = copy
			end
		end
	end
	local hl = Instance.new("Highlight")
	hl.Name = "PressurePlayerCham"; hl.Adornee = proxy; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.FillColor = CHAM_FILL; hl.OutlineColor = CHAM_OUTLINE
	hl.FillTransparency = 0.88; hl.OutlineTransparency = 0.03; hl.Parent = proxy
	proxy.Parent = Workspace
	TeammateChamReg[plr] = { model = proxy, character = ch, links = links }
	return TeammateChamReg[plr]
end

local function setPlayerChams()
	for plr in pairs(TeammateChamReg) do
		if plr.Parent ~= Players or not S.PlayerChams or plr.Character ~= TeammateChamReg[plr].character then clearTeammateCham(plr) end
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP then
			local ch = plr.Character
			if S.PlayerChams and ch then
				local entry = TeammateChamReg[plr]
				if not entry or not (entry.model and entry.model.Parent) then entry = createTeammateCham(plr, ch) end
				for source, copy in pairs(entry.links) do
					if source.Parent and copy.Parent then
						copy.CFrame = source.CFrame; copy.Size = source.Size
						copy.Transparency = 0.38; copy.LocalTransparencyModifier = 0
					else
						pcall(function() copy:Destroy() end); entry.links[source] = nil
					end
				end
			else
				clearTeammateCham(plr)
			end
		end
	end
end

local lastHUDRefresh = 0
tc(RunService.Heartbeat:Connect(function()
	local now = os.clock()
	if now - lastHUDRefresh < 0.1 then return end
	lastHUDRefresh = now
	setPlayerChams()

	StatusHUD.Visible = S.StatusHUD == true
	if S._bindHUDDirty and S._refreshKeybindHUD then S._refreshKeybindHUD() end
	if S.StatusHUD then
		local room = LP:GetAttribute("RoomNum")
		statusRoom.Text = "ROOM " .. (room and tostring(room) or "—")
		local hum = getHum()
		local hp = hum and math.clamp(hum.Health, 0, hum.MaxHealth > 0 and hum.MaxHealth or 100) or 0
		local maxHp = hum and hum.MaxHealth > 0 and hum.MaxHealth or 100
		local hpRatio = math.clamp(hp / maxHp, 0, 1)
		healthText.Text = "VITALS  " .. tostring(math.floor(hp + 0.5)) .. " / " .. tostring(math.floor(maxHp + 0.5))
		healthFill.Size = UDim2.new(hpRatio, 0, 1, 0)
		healthFill.BackgroundColor3 = hpRatio <= 0.3 and Color3.fromRGB(255, 82, 82) or T.Tx

		local m = getMain(); local ox = m and m.OxygenTank
		local tank = type(ox) == "table" and ox.TankValue or nil
		local oxygen = tank and tonumber(tank.Value) or 100
		local oxyRatio = math.clamp(oxygen / 100, 0, 1)
		oxygenText.Text = "OXYGEN  " .. tostring(math.floor(oxygen + 0.5)) .. "%"
		oxygenFill.Size = UDim2.new(oxyRatio, 0, 1, 0)
		oxygenFill.BackgroundColor3 = oxyRatio <= 0.25 and Color3.fromRGB(255, 180, 75) or T.Tx
	end

	if not S.ThreatRadar then
		for _, arrow in pairs(ThreatArrowPool) do arrow.holder.Visible = false end
		return
	end
	local cc = cam(); local hrp = getHRP()
	if not (cc and hrp) then return end
	local candidates = {}
	for _, e in ipairs(EntityCache) do
		if e.obj.Parent and (e.kind == "monster" or e.kind == "dweller" or e.kind == "eyefest" or e.kind == "squiddle" or e.kind == "carnation") then
			local pos = objPos(e.obj)
			if pos then
				local distance = (pos - hrp.Position).Magnitude
				if distance <= (S.ESPMaxDist or 1500) then
					local projected, onScreen = cc:WorldToViewportPoint(pos)
					if not onScreen or projected.Z <= 0 then
						candidates[#candidates + 1] = { e = e, p = projected, d = distance }
					end
				end
			end
		end
	end
	table.sort(candidates, function(a, b) return a.d < b.d end)
	local vp = cc.ViewportSize
	local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
	local radius = math.max(85, math.min(vp.X, vp.Y) * 0.34)
	for i = 1, math.max(#ThreatArrowPool, math.min(#candidates, 4)) do
		local arrow = getThreatArrow(i)
		local candidate = candidates[i]
		if candidate then
			local dir = Vector2.new(candidate.p.X - center.X, candidate.p.Y - center.Y)
			if candidate.p.Z <= 0 then dir = -dir end
			if dir.Magnitude < 0.01 then dir = Vector2.new(0, -1) else dir = dir.Unit end
			arrow.holder.Position = UDim2.fromOffset(center.X + dir.X * radius, center.Y + dir.Y * radius)
			arrow.arrow.Rotation = math.deg(math.atan2(dir.Y, dir.X)) + 90
			arrow.arrow.TextColor3 = ESP_COLORS[candidate.e.kind] or Color3.fromRGB(255, 85, 85)
			arrow.label.Text = string.upper(candidate.e.obj.Name) .. "  " .. tostring(math.floor(candidate.d + 0.5)) .. "m"
			arrow.holder.Visible = true
		else
			arrow.holder.Visible = false
		end
	end
end))

local ESPObjects = {}
local function makeESP(plr)
	local o = {}
	o.box = Instance.new("Frame")
	o.box.BackgroundTransparency = 1; o.box.BorderSizePixel = 0; o.box.Visible = false; o.box.Parent = ESPGui
	o.boxStroke = Instance.new("UIStroke")
	o.boxStroke.Thickness = 1.5; o.boxStroke.Color = Color3.fromRGB(120, 220, 255); o.boxStroke.Parent = o.box
	Corner(o.box, 4)

	o.tracer = Instance.new("Frame")
	o.tracer.BorderSizePixel = 0; o.tracer.AnchorPoint = Vector2.new(0.5, 0.5)
	o.tracer.Size = UDim2.new(0, 1, 0, 0); o.tracer.BackgroundColor3 = Color3.fromRGB(120, 220, 255)
	o.tracer.BackgroundTransparency = 0.25; o.tracer.Visible = false; o.tracer.Parent = ESPGui
	Corner(o.tracer, 1)

	o.bill = Instance.new("BillboardGui")
	o.bill.Size = UDim2.fromOffset(150, 36); o.bill.AlwaysOnTop = true; o.bill.LightInfluence = 0
	o.bill.StudsOffset = Vector3.new(0, 2.6, 0); o.bill.Enabled = false; o.bill.Parent = ESPGui

	o.card = Instance.new("Frame")
	o.card.Parent = o.bill; o.card.BackgroundColor3 = Color3.fromRGB(9, 9, 10); o.card.BackgroundTransparency = 0.22
	o.card.BorderSizePixel = 0; o.card.Size = UDim2.new(1, 0, 1, 0)
	Corner(o.card, 8); Stroke(o.card, Color3.fromRGB(120, 220, 255), 1.2, 0.25); Grad(o.card, Color3.fromRGB(26, 26, 28), Color3.fromRGB(9, 9, 10), 90)

	local dot = Instance.new("Frame")
	dot.Parent = o.card; dot.AnchorPoint = Vector2.new(0, 0.5)
	dot.Position = UDim2.new(0, 8, 0.5, 0); dot.Size = UDim2.new(0, 6, 0, 6); dot.BackgroundColor3 = Color3.fromRGB(120, 220, 255)
	Corner(dot, 3)

	o.txt = Instance.new("TextLabel")
	o.txt.BackgroundTransparency = 1; o.txt.Position = UDim2.new(0, 20, 0, 0); o.txt.Size = UDim2.new(1, -26, 1, 0)
	o.txt.Font = FM; o.txt.TextSize = 12; o.txt.TextColor3 = Color3.fromRGB(255, 255, 255)
	o.txt.TextXAlignment = Enum.TextXAlignment.Left; o.txt.TextTruncate = Enum.TextTruncate.AtEnd; o.txt.Text = ""
	o.txt.Parent = o.card
	ESPObjects[plr] = o
	return o
end
local function removeESP(plr)
	local o = ESPObjects[plr]
	if o then
		pcall(function() o.box:Destroy() end); pcall(function() o.tracer:Destroy() end); pcall(function() o.bill:Destroy() end)
		ESPObjects[plr] = nil
	end
end

-- World-space tags and player ESP do not share a parent with the menu.  A
-- real teardown has to remove both explicitly, otherwise each re-injection
-- accumulates orphaned highlights and billboard labels.
S._cleanupESP = function()
	for obj in pairs(TagReg) do destroyTag(obj) end
	for plr in pairs(ESPObjects) do removeESP(plr) end
	for door in pairs(PassedDoors) do PassedDoors[door] = nil end
	pcall(function() if ESPGui and ESPGui.Parent then ESPGui:Destroy() end end)
end
tc(Players.PlayerRemoving:Connect(removeESP))

local espWasActive = false
tc(RunService.RenderStepped:Connect(function()
	local espOn = S.NameESP or S.BoxESP or S.HealthESP or S.TracerESP
	if not espOn then
		if espWasActive then
			for _, o in pairs(ESPObjects) do o.box.Visible = false; o.tracer.Visible = false; o.bill.Enabled = false end
			espWasActive = false
		end
	else
		espWasActive = true
	end
	local cc = cam(); if not cc then return end
	local vp = cc.ViewportSize
	if espOn then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LP then
			local o = ESPObjects[plr] or makeESP(plr)
			local ch = plr.Character
			local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
			local head = ch and (ch:FindFirstChild("Head") or hrp)
			local hum = ch and ch:FindFirstChildOfClass("Humanoid")
			local show = hrp and head
			local dist = 0
			if show then
				local myHrp = getHRP()
				dist = myHrp and (myHrp.Position - hrp.Position).Magnitude or 0
				if dist > (S.ESPMaxDist or 1500) then show = false end
			end
			if show then
				local topP = cc:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
				local botP = cc:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.6, 0))
				local onScreen = topP.Z > 0 and botP.Z > 0
				local bh = math.abs(botP.Y - topP.Y)
				local bw = bh * 0.44
				if S.BoxESP and onScreen then
					o.box.Visible = true
					o.box.Position = UDim2.fromOffset(topP.X - bw / 2, topP.Y)
					o.box.Size = UDim2.fromOffset(bw, bh)
				else o.box.Visible = false end
				if S.TracerESP and onScreen then
					local from = Vector2.new(vp.X / 2, vp.Y)
					local to = Vector2.new(botP.X, botP.Y)
					local mid = (from + to) / 2
					local len = (to - from).Magnitude
					o.tracer.Visible = true
					o.tracer.Position = UDim2.fromOffset(mid.X, mid.Y)
					o.tracer.Size = UDim2.fromOffset(1, len)
					o.tracer.Rotation = math.deg(math.atan2(to.Y - from.Y, to.X - from.X)) - 90
				else o.tracer.Visible = false end
				if (S.NameESP or S.HealthESP) and onScreen then
					o.bill.Enabled = true; o.bill.Adornee = head
					local parts = {}
					if S.NameESP then parts[#parts + 1] = plr.Name end
					if S.HealthESP and hum then parts[#parts + 1] = math.floor(hum.Health + 0.5) .. " HP" end
					parts[#parts + 1] = math.floor(dist + 0.5) .. "m"
					o.txt.Text = table.concat(parts, "  ·  ")
				else o.bill.Enabled = false end
			else
				o.box.Visible = false; o.tracer.Visible = false; o.bill.Enabled = false
			end
			end
		end
	end

	if S.KeycardESP then
		local hrp = getHRP()
		local best, bestD, bestEntry
		for _, e in ipairs(PromptCache) do
			if e.kind == "keycard" and e.part.Parent and hrp then
				local d = (e.part.Position - hrp.Position).Magnitude
				if d <= (S.ESPMaxDist or 1500) and (not bestD or d < bestD) then best, bestD, bestEntry = e.part, d, e end
			end
		end
		if best then
			local toP = cc:WorldToViewportPoint(best.Position)
			if toP.Z > 0 then
				local from = Vector2.new(vp.X / 2, vp.Y)
				local to = Vector2.new(toP.X, toP.Y)
				local mid = (from + to) / 2
				KeycardTracer.Visible = true
				KeycardTracer.Position = UDim2.fromOffset(mid.X, mid.Y)
				KeycardTracer.Size = UDim2.fromOffset(2, (to - from).Magnitude)
				KeycardTracer.Rotation = math.deg(math.atan2(to.Y - from.Y, to.X - from.X)) - 90
				KeycardBeacon.Text = bestEntry and bestEntry.name == "CodeBreacher" and "CODE BREACHER" or "KEYCARD"
				KeycardBeacon.Position = UDim2.fromOffset(to.X, to.Y - 8)
				KeycardBeacon.Visible = true
			else
				KeycardTracer.Visible = false; KeycardBeacon.Visible = false
			end
		else
			KeycardTracer.Visible = false; KeycardBeacon.Visible = false
		end
	elseif KeycardTracer.Visible or KeycardBeacon.Visible then
		KeycardTracer.Visible = false; KeycardBeacon.Visible = false
	end

	if S.NextDoorTracer then
		local hrp = getHRP()
		local best, bestD
		for _, e in ipairs(PromptCache) do
			if e.kind == "door" and e.part.Parent and not isDeadEndDoor(e.model) and e.model:GetAttribute("ProgressDoor") and hrp then
				local d = (e.part.Position - hrp.Position).Magnitude
				-- Once close enough to interact, it is no longer a waypoint; this
				-- also prevents the line pointing backwards at a door just passed.
				if d > 8 and d <= (S.ESPMaxDist or 1500) and (not bestD or d < bestD) then best, bestD = e.part, d end
			end
		end
		if best then
			local toP = cc:WorldToViewportPoint(best.Position)
			if toP.Z > 0 then
				local from = Vector2.new(vp.X * 0.5, vp.Y)
				local to = Vector2.new(toP.X, toP.Y)
				local mid = (from + to) * 0.5
				NextDoorTracer.Visible = true
				NextDoorTracer.Position = UDim2.fromOffset(mid.X, mid.Y)
				NextDoorTracer.Size = UDim2.fromOffset(2, (to - from).Magnitude)
				NextDoorTracer.Rotation = math.deg(math.atan2(to.Y - from.Y, to.X - from.X)) - 90
			else
				NextDoorTracer.Visible = false
			end
		else
			NextDoorTracer.Visible = false
		end
	elseif NextDoorTracer.Visible then
		NextDoorTracer.Visible = false
	end
end))

--------------------------------------------------------------------------------
-- REMOTE HOOKS — URSpecialEffects is an UnreliableRemoteEvent, which an
-- IsA("RemoteEvent") check would silently skip.
--------------------------------------------------------------------------------
task.spawn(function()
	local ev = getEvents()
	if not ev then return end

	local function hookEvent(name, fn)
		local r = ev:FindFirstChild(name)
		if r and (r:IsA("RemoteEvent") or r:IsA("UnreliableRemoteEvent")) then
			tc(r.OnClientEvent:Connect(function(...) pcall(fn, ...) end))
		end
	end

	hookEvent("Chase", function()
		ShowEntityWarning("CHASE INCOMING", "Run or hide in a locker")
		if S.AutoHideInLocker then hideInLockerNow(false) end
	end)
	hookEvent("Squiddle", function() ShowEntityWarning("SQUIDDLE", "Shine your light / keep distance") end)
	hookEvent("PandemoniumDoorLock", function() ShowEntityWarning("PANDEMONIUM", "Doors are locking") end)
	hookEvent("PermanentEyefestation", function() ShowEntityWarning("EYEFESTATION", "Do not look at it") end)
	hookEvent("CarnationIndicator", function() ShowEntityWarning("CARNATION", "Stare it down, don't look away") end)
	hookEvent("DozerScreenShow", function() if S.BossAlerts then Notify("Dozer", "Dozer encounter active — move quietly", 4, "warn") end end)
	hookEvent("DoombringerToggleScream", function() if S.BossAlerts then Notify("Doombringer", "Boss is active", 4, "danger") end end)

	hookEvent("ZoneChange", function(zone)
		local zname = typeof(zone) == "Instance" and zone.Name or tostring(zone)
		if zname and zname ~= "nil" then Notify("Zone", "Entered: " .. zname, 2) end
	end)
	hookEvent("LocalDamage", function(amount)
		if type(amount) == "number" then Notify("Damage", "Took " .. tostring(amount) .. " damage", 1.5, "danger") end
	end)
	hookEvent("NextRoom", function(n)
		FootMid.Text = "ROOM " .. tostring(n)
		if S.RoomTracker then Notify("Room", "Room: " .. tostring(n), 2) end
	end)
	hookEvent("GeneratorCount", function(n) Notify("Generators", "Generators: " .. tostring(n), 2.5, "warn") end)
	hookEvent("RespawnTimer", function(n) if type(n) == "number" then Notify("Respawn", "Respawn in " .. tostring(n) .. "s", 2) end end)
	hookEvent("URSpecialEffects", function(effectName)
		if type(effectName) ~= "string" then return end
		if effectName == "NeonFlicker" or effectName == "RidgeFlicker" or effectName == "SebFlicker"
			or effectName == "EntityIndicator" or effectName == "A60StaticIndicator"
			or effectName == "A60StaticIndicatorTrack" or effectName == "PandemoniumCameraShake" then
			ShowEntityWarning(effectName:gsub("CameraShake", ""):gsub("Flicker", " FLICKER"))
			if S.AutoHideInLocker then hideInLockerNow(false) end
		end
	end)

	local roomFn = ev:FindFirstChild("CurrentRoomNumber")
	if roomFn and roomFn:IsA("RemoteFunction") then
		task.spawn(function()
			local ok, n = pcall(function() return roomFn:InvokeServer() end)
			if ok and n then FootMid.Text = "ROOM " .. tostring(n) end
		end)
	end
end)

--------------------------------------------------------------------------------
-- STARTUP
--------------------------------------------------------------------------------
task.spawn(function()
	local loaded, reason = false, "missing"
	for attempt = 1, 3 do
		task.wait(attempt == 1 and 1 or 1.5)
		if S.Destroyed then return end
		loaded, reason = LoadConfigFile("_autoload", true)
		if loaded or reason == "missing" or reason == "readfile unavailable" then break end
	end
	S._autoConfigLoaded, S._autoConfigReason = loaded, reason
	if loaded then
		Notify("Pressure Hub", "Config restored — Insert opens the menu", 3, "success")
	elseif reason ~= "missing" and reason ~= "readfile unavailable" then
		Notify("Config", "Autoload skipped: " .. tostring(reason), 3, "warn")
	else
		Notify("Pressure Hub", "Loaded — Insert opens the menu", 3, "info")
	end
	print("[PressureHub] Loaded OK")
end)
