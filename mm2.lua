if _G.MM2_Visuals_Script then
    pcall(function() _G.MM2_Visuals_Script:Destroy() end)
    _G.MM2_Visuals_Script = nil
end

-- Destroy PartSwim to stop the massive error spam in the console
pcall(function()
    local ps = game:GetService("Players").LocalPlayer.PlayerScripts:FindFirstChild("PartSwim")
    if ps then ps:Destroy() end
end)

-- HUD cleanup removed to restore native level badges and game timers.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = {
    Create = function(self, instance, tweenInfo, properties)
        local time = tweenInfo and tweenInfo.Time or 1
        local style = tweenInfo and tweenInfo.EasingStyle or Enum.EasingStyle.Quad

        local startValues = {}
        for prop, _ in pairs(properties) do
            pcall(function() startValues[prop] = instance[prop] end)
        end
        
        local conn
        local play = function()
            local startTime = tick()
            conn = game:GetService("RunService").Heartbeat:Connect(function()
                if not instance or not instance.Parent then
                    conn:Disconnect()
                    return
                end
                local elapsed = tick() - startTime
                local t = math.clamp(elapsed / time, 0, 1)
                
                local ease = t
                if style == Enum.EasingStyle.Sine then
                    ease = math.sin(t * math.pi / 2)
                elseif style == Enum.EasingStyle.Back then
                    ease = 1 - (1 - t)^3 + 0.1 * math.sin(t * math.pi)
                elseif style == Enum.EasingStyle.Quad then
                    ease = t * t
                end
                
                for prop, targetVal in pairs(properties) do
                    local startVal = startValues[prop]
                    if startVal ~= nil then
                        if typeof(targetVal) == "UDim2" then
                            instance[prop] = UDim2.new(
                                startVal.X.Scale + (targetVal.X.Scale - startVal.X.Scale) * ease,
                                startVal.X.Offset + (targetVal.X.Offset - startVal.X.Offset) * ease,
                                startVal.Y.Scale + (targetVal.Y.Scale - startVal.Y.Scale) * ease,
                                startVal.Y.Offset + (targetVal.Y.Offset - startVal.Y.Offset) * ease
                            )
                        elseif typeof(targetVal) == "Color3" then
                            instance[prop] = startVal:Lerp(targetVal, ease)
                        elseif typeof(targetVal) == "number" then
                            instance[prop] = startVal + (targetVal - startVal) * ease
                        elseif typeof(targetVal) == "Vector2" then
                            instance[prop] = startVal:Lerp(targetVal, ease)
                        end
                    end
                end
                
                if t >= 1 then
                    conn:Disconnect()
                end
            end)
        end
        
        return {
            Play = function(twn) play() end,
            Cancel = function() if conn then conn:Disconnect() end end
        }
    end
}
local SoundService = game:GetService("SoundService")
local LP = Players.LocalPlayer
-- The game's real max camera zoom, captured BEFORE anything (incl. config auto-load) changes it.
-- "No Camera Limit" restores THIS when off, so executing the script never widens your zoom-out.
local _origMaxZoom = LP.CameraMaxZoomDistance
local ncPlat = nil
local S = {
    Connections = {}, Gui = nil, OriginalTransparencies = {},
    VoidPlatform = nil, LastGrab = 0,
    CustomWalkSpeed = 16, CustomJumpPower = 50,
    GunChams = false, GunNotify = false,
    AutoGrabGun = false, XrayOn = false, CamClip = false, NoCamLimit = false,
    AntiFling = false, AntiVoid = false, NoClip = false, AntiRagdoll = false,
    Fly = false, FlySpeed = 50, TouchFling = false, FlingDuration = 6,
    PixelSurf = false, SurfSpeed = 60, SurfGravity = 80, SurfJumpPower = 50,
    AutoKillSheriff = false, AutoKillNearest = false, ClickKill = false, KillAura = false, KillAuraRange = 18,
    ActiveShader = "None",
    HUD_Keybinds = false, HUD_GunStatus = false, HUD_FPS = false,
    HUD_Ping = false, HUD_Coords = false, NoEmoteStop = false, LoopEmote = false,
    NameESP = false, DistanceESP = false, RoleESP = false, HealthESP = false,
    BoxESP = false, BoxFillESP = false, HealthBarESP = false, TracerESP = false, ESPMaxDist = 1000,
    HeadDot = false, TracerOrigin = "Bottom",
    ChamsOpacity = 50, GunHeldChams = false, RoleChams = false, RoleHUDEnabled = false,
    ItemChamsMode = "Outline", ItemChamsColor = "Cyan", ItemChamsRainbow = false,
    FullBright = false, NoFog = false, ForceDay = false, ForceNight = false, NoShadows = false, Brightness = 2,
    Saturation = 0, Contrast = 0, CamFOV = 70,
    SkyEnabled = false, SkyPreset = "Day", SkyTint = "Preset", SkyRainbow = false,
    FogEnabled = false, FogColorName = "Gray", FogStart = 0, FogEnd = 500, FogRainbow = false,
    FogMode = "Classic", FogDensity = 40,
    HandShader = false, HandShaderType = "Both", HandTarget = "Full Body", HandColor = "Cyan", HandRainbow = false, HandFill = 60,
    DualWield = false,
    Crosshair = false,
    FOVEnabled = false, ShowFOV = false, RainbowFOV = false,
    FOVThickness = 2, FOVColor = "White", FOVRadius = 360,
    HUD_Watermark = false, HUD_Speed = false, HUD_Session = false, HUD_KillFeed = false,
    AutoRespawn = false, WalkOnWater = false, AutoSprint = false, AntiLag = false,
    InfiniteJump = false, Spinbot = false, SpinSpeed = 20, AntiAFK = false, Freeze = false,
    Bhop = false, BhopMax = 28, SpeedGlitch = false, AirSpeed = 50,
    ClickTP = false,
    AutoSaveCfg = true,
    HeadSit = false,
    Orbit = false, OrbitSpeed = 20, OrbitDist = 6, OrbitHeight = 0,
    Bang = false, BangSpeed = 3, Jerk = false,
    BlockJump = false,
    InvisibleFE = false, FreeCam = false, Blink = false, ClickFling = false,
    Fling = false, WalkFling = false, FlyFling = false, InvisFling = false,
    CoinESP = false, FastAutofarm = false, FastAutofarmSpeed = 20,
    FollowPlayer = false, FollowPlayerDistance = 4, FollowPlayerMode = "Follow", FollowPlayerSpeed = 60, FollowPlayerOrbitSpeed = 20,
    CustomTime = false, TimeOfDay = 14, Gravity = 196, MoonGravity = false, DisableBlur = false,
    FakeLag = false, FakeLagLimit = 15,
    TriggerBot = false,
    CrosshairShape = "Cross", CrosshairColor = "Cyan", CrosshairSize = 12, CrosshairThickness = 2, CrosshairGap = 4, CrosshairRotation = 0,
    AutoEvade = false, AutoEvadeRange = 25, AutoGG = false, CustomGGText = "GG!", UseCustomGG = false,
    AutoDodgeKnife = false, AutoDodgeMode = "Teleport", AutoDodgeSpeed = 16,
    KnifeDodgeDistance = 8,
    VoteFarmSlot = "1", VoteFarmCount = 5,
    MuteGun = false, MuteCoin = false, MuteKill = false, MuteKillNotify = false, MuteKillEffect = false, HideKillFX = false,
    Whitelist = {},   -- [playerName]=true : right-click in Targets; skipped by fling / kill / aura / aim
    ManualTargets = {},  -- [playerName]=true : left-click multi-select in Targets (Fun / Follow). empty = Auto
    SheriffSilentAim = false,
    -- No UI for these two anymore: MM2 guns 1-shot anywhere, so the target is hardwired to the
    -- Murderer and the aim part to HumanoidRootPart (central hitbox + matches the velocity tracker).
    SheriffSilentAimTarget = "Murderer",
    SheriffSilentAimPart = "HumanoidRootPart",
    SheriffSilentAimWallCheck = false,
    SheriffSilentAimPredictMode = "Perfect",
    SheriffSilentAimPrediction = 25,
    SheriffSilentAimFOVEnabled = true,
    SheriffSilentAimPiercing = false,
    KnifeSilentAim = false,
    KnifeSilentAimPrioritizeSheriff = true,
    KnifeSilentAimPredictMode = "Perfect",
    KnifeSilentAimPrediction = 25,
    KnifeSilentAimWallCheck = false,
    KnifeSilentAimFOVEnabled = false,
    FastThrow = false,
    CustomKillSound = false, CustomKillSoundId = "rbxassetid://4590662766",
    CustomShootSound = false, CustomShootSoundId = "",
    CustomKnifeSound = false, CustomKnifeKillSoundId = "rbxassetid://9120386446",
    CustomMurdererWinSound = false, CustomMurdererWinSoundId = "rbxassetid://1837849285",
    CustomSheriffWinSound = false, CustomSheriffWinSoundId = "rbxassetid://1837849285",
    AmbientMusic = false, AmbientMusicId = "rbxassetid://1843323335", AmbientMusicVol = 0.4,
    AIChatEnabled = false, AIChatAPIKey = "", AIChatTriggerMode = "Mention", AIChatRespondToAll = false, AIChatCooldown = 10, AIChatPersonality = "Friendly",
    AIChatProvider = "DeepSeek",
    AIChatResponseChance = 100,
}
_G.MM2_Visuals_Script = S
local createHighlight, getRole, rebuildCrosshair, moveTo, isRoundActive, silentAimTargetChar, getPredictedPosition, skidFling
-- applyShader is defined ~4900 lines down (main chunk) but the Shader Presets toggles are built much
-- earlier inside the Visuals do-block; without this forward declaration those toggle callbacks captured
-- a nil GLOBAL `applyShader` and every shader preset silently did nothing.
local applyShader
-- CurrentHero (was the dead/unused `Heroes` table) tracks the name of whoever the server most
-- recently tagged Role="Hero" — used by getRole to tell a CURRENT Hero apart from a STALE one (the
-- server never clears a past holder's Role field back down when someone newer picks up the gun).
local OriginalSheriff, CurrentHero, RoleCache, GearCache = nil, nil, {}, {}
local LastRoundHadRoles = false

-- SYSTEMIC BUG FIX (2026-07-17, live-verified): every "force a respawn" fallback in this file called
-- `LP:LoadCharacter()` wrapped in a pcall — that API is SERVER-ONLY ("LoadCharacter can only be called
-- by the backend server"), confirmed live by calling it directly and getting exactly that error. Every
-- one of those pcalls has been silently eating that error and doing NOTHING, this whole time, in every
-- feature that relied on it as a recovery/reset path. The only respawn trigger actually available to a
-- client is killing your OWN humanoid (`Humanoid.Health = 0`, always allowed) and letting the game's own
-- Humanoid.Died -> CharacterAutoLoads respawn flow run — the same thing the real "Reset" button does
-- under the hood. Every old `pcall(function() LP:LoadCharacter() end)` call site was replaced with this.
-- Stored as a field on `S` (an already-permanent local) instead of its own top-level local — the main
-- chunk was already sitting at Luau's 200-local-register ceiling, and one more persistent local here
-- was enough to tip a function hundreds of lines further down (refreshPacks) over the edge.
S._resetMyCharacter = function()
    local c = LP.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 then
        pcall(function() hum.Health = 0 end)
    end
end

-- Expose to global/S table for debugging and MCP access
S.getRole = function(...) return getRole(...) end
S.silentAimTargetChar = function(...) return silentAimTargetChar(...) end
S.getPredictedPosition = function(...) return getPredictedPosition(...) end
function S:Destroy()
    -- Old namecall/beam wrappers can outlive their RBXScriptConnections after a re-inject.
    -- Clear shot-related flags first so those stale wrappers become no-ops immediately.
    self.Destroyed = true
    self.AIChatEnabled = false
    self.SheriffSilentAim = false
    self.SheriffSilentAimPiercing = false
    self.TriggerBot = false
    pcall(function() if self._StopReferenceFlings then self._StopReferenceFlings() end end)
    pcall(function()
        LP.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
        LP.CameraMaxZoomDistance = _origMaxZoom
    end)
    pcall(function()
        local c = LP.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = 16; h.JumpPower = 50; h.PlatformStand = false end
        if c and c:FindFirstChild("HumanoidRootPart") then
            local hrp = c.HumanoidRootPart
            for _, n in ipairs({"FlyBV","FlyBG"}) do local x = hrp:FindFirstChild(n); if x then x:Destroy() end end
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
        if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
    end)
    pcall(function()
        for part, t in pairs(self.OriginalTransparencies) do if part and part.Parent then part.Transparency = t end end
    end)
    if self.VoidPlatform then pcall(function() self.VoidPlatform:Destroy() end); self.VoidPlatform = nil end
    if ncPlat then pcall(function() ncPlat:Destroy() end); ncPlat = nil end
    for _, c in ipairs(self.Connections) do pcall(function() c:Disconnect() end) end
    if self.Gui then pcall(function() self.Gui:Destroy() end) end
end
local function tc(conn) table.insert(S.Connections, conn); return conn end
-- Whitelisted players are SKIPPED by offensive/targeting features (Fling, Kill All, Knife Aura, Aim
-- Lock). Toggled per-player by right-clicking their row in the Targets tab.
local function isWhitelisted(p) return p ~= nil and S.Whitelist and S.Whitelist[p.Name] == true end
local SndCache = {}
local function snd(id, pitch, vol)
    task.spawn(function() pcall(function()
        local k = id..pitch
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
    Bind = function() snd("rbxassetid://6895079853", 1.7, 0.35) end,
    Unbind = function() snd("rbxassetid://6895079853", 0.55, 0.2) end,
    Click = function() snd("rbxassetid://6895079853", 1.05, 0.3) end,
    Pop = function() snd("rbxassetid://4590662766", 1.2, 0.35) end,
    Ready = function() snd("rbxassetid://4590662766", 1.5, 0.45) end,
}
local T = {
    BG        = Color3.fromRGB(5, 5, 5),
    Sidebar   = Color3.fromRGB(3, 3, 3),
    Card      = Color3.fromRGB(10, 10, 10),
    Elev      = Color3.fromRGB(18, 18, 18),
    Hover     = Color3.fromRGB(24, 24, 24),
    ActiveBg  = Color3.fromRGB(30, 30, 30),
    White     = Color3.fromRGB(255, 255, 255),
    Tx        = Color3.fromRGB(238, 238, 238),
    Tx2       = Color3.fromRGB(160, 160, 160),
    Tx3       = Color3.fromRGB(95, 95, 95),
    Tx4       = Color3.fromRGB(55, 55, 55),
    Bd        = Color3.fromRGB(28, 28, 28),
    Bd2       = Color3.fromRGB(42, 42, 42),
    TgOff     = Color3.fromRGB(30, 30, 30),
    TgOn      = Color3.fromRGB(255, 255, 255),
    KnobOff   = Color3.fromRGB(100, 100, 100),
    KnobOn    = Color3.fromRGB(3, 3, 3),
    Accent    = Color3.fromRGB(255, 255, 255),
    Glow      = Color3.fromRGB(255, 255, 255),
}
local Themes = {
    Monochrome = {
        BG = Color3.fromRGB(5, 5, 5),
        Sidebar = Color3.fromRGB(3, 3, 3),
        Card = Color3.fromRGB(10, 10, 10),
        Elev = Color3.fromRGB(18, 18, 18),
        Hover = Color3.fromRGB(24, 24, 24),
        ActiveBg = Color3.fromRGB(30, 30, 30),
        Bd = Color3.fromRGB(28, 28, 28),
        Bd2 = Color3.fromRGB(42, 42, 42),
        TgOn = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(255, 255, 255),
        Glow = Color3.fromRGB(100, 100, 100),
    },
    ["Neon Blue"] = {
        BG = Color3.fromRGB(5, 6, 10),
        Sidebar = Color3.fromRGB(3, 4, 6),
        Card = Color3.fromRGB(8, 10, 16),
        Elev = Color3.fromRGB(12, 16, 26),
        Hover = Color3.fromRGB(18, 24, 38),
        ActiveBg = Color3.fromRGB(22, 30, 48),
        Bd = Color3.fromRGB(20, 30, 50),
        Bd2 = Color3.fromRGB(30, 45, 75),
        TgOn = Color3.fromRGB(0, 180, 255),
        Accent = Color3.fromRGB(0, 180, 255),
        Glow = Color3.fromRGB(0, 100, 200),
    },
    ["Ruby Red"] = {
        BG = Color3.fromRGB(8, 4, 4),
        Sidebar = Color3.fromRGB(5, 3, 3),
        Card = Color3.fromRGB(14, 8, 8),
        Elev = Color3.fromRGB(22, 12, 12),
        Hover = Color3.fromRGB(32, 18, 18),
        ActiveBg = Color3.fromRGB(42, 24, 24),
        Bd = Color3.fromRGB(40, 18, 18),
        Bd2 = Color3.fromRGB(60, 26, 26),
        TgOn = Color3.fromRGB(255, 60, 60),
        Accent = Color3.fromRGB(255, 60, 60),
        Glow = Color3.fromRGB(200, 40, 40),
    },
    ["Emerald Green"] = {
        BG = Color3.fromRGB(4, 8, 5),
        Sidebar = Color3.fromRGB(3, 5, 3),
        Card = Color3.fromRGB(8, 14, 10),
        Elev = Color3.fromRGB(12, 22, 16),
        Hover = Color3.fromRGB(18, 32, 24),
        ActiveBg = Color3.fromRGB(24, 42, 32),
        Bd = Color3.fromRGB(18, 40, 24),
        Bd2 = Color3.fromRGB(26, 60, 36),
        TgOn = Color3.fromRGB(40, 220, 100),
        Accent = Color3.fromRGB(40, 220, 100),
        Glow = Color3.fromRGB(30, 180, 80),
    },
    ["Amethyst Purple"] = {
        BG = Color3.fromRGB(7, 5, 10),
        Sidebar = Color3.fromRGB(4, 3, 6),
        Card = Color3.fromRGB(12, 8, 16),
        Elev = Color3.fromRGB(18, 12, 26),
        Hover = Color3.fromRGB(26, 18, 38),
        ActiveBg = Color3.fromRGB(34, 24, 48),
        Bd = Color3.fromRGB(30, 20, 45),
        Bd2 = Color3.fromRGB(45, 30, 70),
        TgOn = Color3.fromRGB(160, 80, 255),
        Accent = Color3.fromRGB(160, 80, 255),
        Glow = Color3.fromRGB(120, 50, 200),
    },
    ["Sakura Pink"] = {
        BG = Color3.fromRGB(8, 6, 8),
        Sidebar = Color3.fromRGB(5, 4, 5),
        Card = Color3.fromRGB(16, 12, 16),
        Elev = Color3.fromRGB(26, 18, 26),
        Hover = Color3.fromRGB(38, 26, 38),
        ActiveBg = Color3.fromRGB(48, 32, 48),
        Bd = Color3.fromRGB(45, 30, 45),
        Bd2 = Color3.fromRGB(70, 45, 70),
        TgOn = Color3.fromRGB(255, 120, 200),
        Accent = Color3.fromRGB(255, 120, 200),
        Glow = Color3.fromRGB(220, 90, 160),
    },
    ["Amber Gold"] = {
        BG = Color3.fromRGB(8, 6, 4),
        Sidebar = Color3.fromRGB(5, 4, 3),
        Card = Color3.fromRGB(16, 12, 8),
        Elev = Color3.fromRGB(26, 20, 12),
        Hover = Color3.fromRGB(38, 28, 18),
        ActiveBg = Color3.fromRGB(48, 36, 24),
        Bd = Color3.fromRGB(45, 35, 20),
        Bd2 = Color3.fromRGB(70, 55, 30),
        TgOn = Color3.fromRGB(255, 180, 0),
        Accent = Color3.fromRGB(255, 180, 0),
        Glow = Color3.fromRGB(200, 140, 0),
    },
    ["Midnight Navy"] = {
        BG = Color3.fromRGB(3, 5, 10),
        Sidebar = Color3.fromRGB(2, 3, 6),
        Card = Color3.fromRGB(6, 10, 20),
        Elev = Color3.fromRGB(10, 16, 32),
        Hover = Color3.fromRGB(14, 24, 48),
        ActiveBg = Color3.fromRGB(18, 32, 64),
        Bd = Color3.fromRGB(15, 25, 55),
        Bd2 = Color3.fromRGB(25, 40, 85),
        TgOn = Color3.fromRGB(40, 120, 255),
        Accent = Color3.fromRGB(40, 120, 255),
        Glow = Color3.fromRGB(30, 90, 200),
    },
    ["Toxic Lime"] = {
        BG = Color3.fromRGB(5, 8, 4),
        Sidebar = Color3.fromRGB(3, 5, 3),
        Card = Color3.fromRGB(10, 16, 8),
        Elev = Color3.fromRGB(16, 26, 12),
        Hover = Color3.fromRGB(24, 38, 18),
        ActiveBg = Color3.fromRGB(32, 48, 24),
        Bd = Color3.fromRGB(25, 45, 20),
        Bd2 = Color3.fromRGB(40, 70, 30),
        TgOn = Color3.fromRGB(120, 255, 0),
        Accent = Color3.fromRGB(120, 255, 0),
        Glow = Color3.fromRGB(90, 200, 0),
    },
    ["Sunset Orange"] = {
        BG = Color3.fromRGB(8, 5, 4),
        Sidebar = Color3.fromRGB(5, 3, 3),
        Card = Color3.fromRGB(16, 10, 8),
        Elev = Color3.fromRGB(26, 16, 12),
        Hover = Color3.fromRGB(38, 24, 18),
        ActiveBg = Color3.fromRGB(48, 30, 24),
        Bd = Color3.fromRGB(45, 25, 20),
        Bd2 = Color3.fromRGB(70, 40, 30),
        TgOn = Color3.fromRGB(255, 90, 0),
        Accent = Color3.fromRGB(255, 90, 0),
        Glow = Color3.fromRGB(200, 70, 0),
    }
}
local Translations = {
    RU = {
        Visuals = "Визуалы", Combat = "Бой", Motion = "Движение", Misc = "Разное",
        Teleport = "Телепорт", Shaders = "Шейдеры",
        Servers = "Сервера", Config = "Конфиг", Settings = "Настройки",
        ["Text Size"] = "Размер текста", Language = "Язык", Theme = "Тема", Close = "Закрыть",
        ["Theme Style"] = "Цветовая тема",
    },
    UK = {
        Visuals = "Візуали", Combat = "Бій", Motion = "Рух", Misc = "Різне",
        Teleport = "Телепорт", Shaders = "Шейдери",
        Servers = "Сервери", Config = "Конфіг", Settings = "Налаштування",
        ["Text Size"] = "Розмір тексту", Language = "Мова", Theme = "Тема", Close = "Закрити",
        ["Theme Style"] = "Колірна тема",
    },
    SPANISH = {
        Visuals = "Visuales", Combat = "Combate", Motion = "Movimiento", Misc = "Varios",
        Teleport = "Teletransporte", Shaders = "Shaders",
        Servers = "Servidores", Config = "Config", Settings = "Ajustes",
        ["Text Size"] = "Tamaño de texto", Language = "Idioma", Theme = "Tema", Close = "Cerrar",
        ["Theme Style"] = "Tema de color",
    },
    ENG = {}
}
local function lang(str)
    local l = S.Language or "ENG"
    local t = Translations[l]
    return t and t[str] or str
end
local function updateLanguage()
    for _, item in ipairs(SBItems) do
        pcall(function() item.label.Text = lang(item.name) end)
    end
end
local function updateTextSizes()
    local scale = S.TextSizeScale or 1
    for _, obj in ipairs(SG:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            pcall(function()
                if not obj:GetAttribute("OrigTextSize") then
                    obj:SetAttribute("OrigTextSize", obj.TextSize)
                end
                local orig = obj:GetAttribute("OrigTextSize")
                obj.TextSize = math.clamp(math.round(orig * scale), 8, 24)
            end)
        end
    end
end
local function applyTheme(themeName)
    local theme = Themes[themeName]
    if not theme then return end
    S.SelectedTheme = themeName
    for k, v in pairs(theme) do
        T[k] = v
    end
    local function recolor(obj)
        for attr, role in pairs(obj:GetAttributes()) do
            if attr:sub(1, 15) == "ThemeColorRole_" then
                local prop = attr:sub(16)
                pcall(function()
                    obj[prop] = T[role]
                end)
            end
        end
        if obj.Name == "Main" then
            obj.BackgroundColor3 = T.BG; pcall(function() obj:SetAttribute("ThemeColorRole_BackgroundColor3", "BG") end)
        elseif obj.Name == "Sidebar" or obj.Name == "Status" or obj.Name == "ProfileHeader" then
            obj.BackgroundColor3 = T.Sidebar; pcall(function() obj:SetAttribute("ThemeColorRole_BackgroundColor3", "Sidebar") end)
        elseif obj.Name == "InertiaSettings" then
            obj.BackgroundColor3 = T.Card; pcall(function() obj:SetAttribute("ThemeColorRole_BackgroundColor3", "Card") end)
        elseif obj.Name == "track" or obj.Name == "SliderTrack" then
            obj.BackgroundColor3 = T.TgOff; pcall(function() obj:SetAttribute("ThemeColorRole_BackgroundColor3", "TgOff") end)
        elseif obj.Name == "fill" or obj.Name == "SliderFill" then
            obj.BackgroundColor3 = T.Accent; pcall(function() obj:SetAttribute("ThemeColorRole_BackgroundColor3", "Accent") end)
        elseif obj.Name == "knob" then
            obj.BackgroundColor3 = obj:GetAttribute("Active") and T.KnobOn or T.KnobOff
        elseif obj.Name == "StatusBarLine" or obj.Name == "SBLine" or obj.Name == "Line" or obj.Name == "phLine" then
            obj.BackgroundColor3 = T.Bd; pcall(function() obj:SetAttribute("ThemeColorRole_BackgroundColor3", "Bd") end)
        elseif obj:IsA("TextButton") then
            if obj.Name == "track" then
                obj.BackgroundColor3 = obj:GetAttribute("Active") and T.TgOn or T.TgOff
            elseif obj.Parent and obj.Parent.Name == "TBar" then
                obj.BackgroundColor3 = T.Elev; pcall(function() obj:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
            elseif obj.Parent and obj.Parent.Name == "Sidebar" then
                local on = (obj.Name == activePage.Name)
                obj.BackgroundColor3 = T.Elev; pcall(function() obj:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
            end
        elseif obj:IsA("UIStroke") then
            if obj.Parent and obj.Parent.Name == "Main" then
                obj.Color = T.Bd; pcall(function() obj:SetAttribute("ThemeColorRole_Color", "Bd") end)
            else
                obj.Color = T.Bd2; pcall(function() obj:SetAttribute("ThemeColorRole_Color", "Bd2") end)
            end
        elseif obj:IsA("UIGradient") then
            if obj.Parent and (obj.Parent.Name == "fill" or obj.Parent.Name == "lbf") then
                obj.Color = ColorSequence.new(T.Accent, T.Glow)
            end
        elseif obj.Name:sub(1, 4) == "HUD_" then
            obj.BackgroundColor3 = T.Card; pcall(function() obj:SetAttribute("ThemeColorRole_BackgroundColor3", "Card") end)
            local stroke = obj:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = T.Bd2; pcall(function() stroke:SetAttribute("ThemeColorRole_Color", "Bd2") end) end
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("Frame") and child.Size.Y.Offset == 26 then
                    child.BackgroundColor3 = T.Elev; pcall(function() child:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
                    local line = child:FindFirstChildOfClass("Frame")
                    if line then line.BackgroundColor3 = T.Bd; pcall(function() line:SetAttribute("ThemeColorRole_BackgroundColor3", "Bd") end) end
                    local tick = child:FindFirstChild("tick") or child:FindFirstChildOfClass("Frame")
                    if tick and tick.Size.X.Offset == 2 then
                        tick.BackgroundColor3 = T.Accent; pcall(function() tick:SetAttribute("ThemeColorRole_BackgroundColor3", "Accent") end)
                    end
                end
            end
        elseif obj.Name == "MobileHUD" then
            obj.BackgroundColor3 = T.Card; pcall(function() obj:SetAttribute("ThemeColorRole_BackgroundColor3", "Card") end)
            local stroke = obj:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = T.Bd2; pcall(function() stroke:SetAttribute("ThemeColorRole_Color", "Bd2") end) end
        elseif obj.Parent and obj.Parent.Name == "MobileHUD" and obj:IsA("TextButton") then
            local active = obj:GetAttribute("Active")
            obj.BackgroundColor3 = active and T.Accent or T.Elev
            obj.TextColor3 = active and T.KnobOn or T.White
            local stroke = obj:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = T.Bd; pcall(function() stroke:SetAttribute("ThemeColorRole_Color", "Bd") end) end
        end
    end
    for _, obj in ipairs(SG:GetDescendants()) do
        pcall(recolor, obj)
    end
end

-- Synchronously pre-load settings before creating any UI or loading screen
pcall(function()
    if readfile and isfile and isfile("MM2_Configs/_autoload.json") then
        local data = game:GetService("HttpService"):JSONDecode(readfile("MM2_Configs/_autoload.json"))
        if data then
            if data.SelectedTheme and Themes[data.SelectedTheme] then
                S.SelectedTheme = data.SelectedTheme
                for k, v in pairs(Themes[data.SelectedTheme]) do
                    T[k] = v
                end
            end
            if data.Language then
                S.Language = data.Language
            end
            if data.TextSizeScale then
                S.TextSizeScale = data.TextSizeScale
            end
        end
    end
end)

local RoleShade = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff  = Color3.fromRGB(0, 100, 255),
    Hero     = Color3.fromRGB(0, 100, 255), -- same as Sheriff, no separate yellow Hero cham
    Innocent = Color3.fromRGB(0, 255, 0),
    ["???"]  = Color3.fromRGB(180, 180, 180),
}
local F  = Enum.Font.Gotham
local FM = Enum.Font.GothamMedium
local FB = Enum.Font.GothamBold
local function Corner(i, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = i
    return c
end
local function Stroke(i, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or T.Bd
    s.Thickness = th or 1
    s.Transparency = tr or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = i
    return s
end
local function Grad(i, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rot or 90
    g.Parent = i
    return g
end
local function Pad(i, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0,t or 0)
    p.PaddingBottom = UDim.new(0,b or 0)
    p.PaddingLeft = UDim.new(0,l or 0)
    p.PaddingRight = UDim.new(0,r or 0)
    p.Parent = i
    return p
end
local function Shadow(i, transparency)
    local s = Instance.new("UIStroke")
    s.Color = T.Bd2; pcall(function() s:SetAttribute("ThemeColorRole_Color", "Bd2") end)
    s.Thickness = 2
    s.Transparency = transparency or 0.6
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = i
    return s
end
-- Shared subtab-bar helpers (DEDUPED — this exact pair used to be redeclared once per tab: Visuals,
-- Combat, Motion, Misc, Teleport, Servers, Player each had their own byte-identical copy under a
-- different name, e.g. styleMotionSubTabBtn/styleMiscBtn/stylePlBtn/etc. That was ~11 extra top-level
-- locals for zero behavioral difference — it's what pushed the main chunk over Luau's 200-local-
-- register limit ("Out of local registers ... packScroll"). One shared pair now; widthScale/gapOffset
-- only need overriding for Misc's 3-way split (1/3, -6) — everyone else uses the default 2-way split.
local function mkSubTabBtn(bar, btn, text, order, widthScale, gapOffset)
    btn.Name = text
    btn.Parent = bar
    btn.LayoutOrder = order
    btn.Size = UDim2.new(widthScale or 0.5, gapOffset or -4, 1, 0)
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Font = FM
    btn.TextSize = 13
    btn.Text = text
    Corner(btn, 6)
    return Stroke(btn, T.Bd, 1, 0.4)
end
-- Deduped: Blink and InvisibleFE each declared their own identical "disconnect every connection in
-- this list" closure. One shared helper, called as `conns = disconnectAll(conns)`.
local function disconnectAll(conns)
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    return {}
end
local function styleSubTabActive(btn, stroke, active)
    btn.BackgroundColor3 = active and T.ActiveBg or T.Elev
    btn.TextColor3 = active and T.White or T.Tx2
    pcall(function() btn:SetAttribute("ThemeColorRole_BackgroundColor3", active and "ActiveBg" or "Elev") end)
    pcall(function() btn:SetAttribute("ThemeColorRole_TextColor3", active and "White" or "Tx2") end)
    stroke.Color = active and T.Accent or T.Bd
    pcall(function() stroke:SetAttribute("ThemeColorRole_Color", active and "Accent" or "Bd") end)
end
local function mkIcon(parent, kind)
    local box = Instance.new("Frame")
    box.Parent = parent
    box.BackgroundTransparency = 1
    box.Size = UDim2.fromOffset(18, 18)
    local paints = {}
    local function frame(px, py, sx, sy, round)
        local f = Instance.new("Frame")
        f.Parent = box
        f.BorderSizePixel = 0
        f.Position = UDim2.fromOffset(px, py)
        f.Size = UDim2.fromOffset(sx, sy)
        f.BackgroundColor3 = T.Tx2; pcall(function() f:SetAttribute("ThemeColorRole_BackgroundColor3", "Tx2") end)
        if round then Corner(f, round) end
        table.insert(paints, {f, "bg"})
        return f
    end
    local function ring(px, py, sx, sy)
        local f = Instance.new("Frame")
        f.Parent = box
        f.BackgroundTransparency = 1
        f.Position = UDim2.fromOffset(px, py)
        f.Size = UDim2.fromOffset(sx, sy)
        Corner(f, 999)
        local st = Stroke(f, T.Tx2, 1.6, 0)
        table.insert(paints, {st, "stroke"})
        return f
    end
    local function hollow(px, py, sx, sy, round, rot)
        local f = Instance.new("Frame")
        f.Parent = box
        f.BackgroundTransparency = 1
        f.Position = UDim2.fromOffset(px, py)
        f.Size = UDim2.fromOffset(sx, sy)
        f.Rotation = rot or 0
        if round then Corner(f, round) end
        local st = Stroke(f, T.Tx2, 1.6, 0)
        table.insert(paints, {st, "stroke"})
        return f
    end
    if kind == "eye" then
        ring(2, 4, 14, 9)
        frame(7, 6, 4, 5, 999)
        frame(4, 8, 2, 2, 999)
        frame(12, 8, 2, 2, 999)
    elseif kind == "cross" then
        ring(3, 3, 12, 12)
        frame(8, 0, 2, 4, 1)
        frame(8, 14, 2, 4, 1)
        frame(0, 8, 4, 2, 1)
        frame(14, 8, 4, 2, 1)
    elseif kind == "sliders" then
        frame(2, 3, 14, 2, 1)
        frame(10, 2, 5, 5, 2)
        frame(2, 8, 14, 2, 1)
        frame(3, 7, 5, 5, 2)
        frame(2, 13, 14, 2, 1)
        frame(8, 12, 5, 5, 2)
    elseif kind == "diamond" then
        hollow(4, 4, 10, 10, 2, 45)
        frame(7, 7, 4, 4, 999).Rotation = 45
    elseif kind == "grid" then
        frame(1, 1, 7, 7, 2)
        frame(10, 1, 7, 7, 2)
        frame(1, 10, 7, 7, 2)
        frame(10, 10, 7, 7, 2)
    elseif kind == "shield" then
        hollow(3, 1, 12, 15, 3)
        frame(8, 5, 2, 6, 1)
        frame(6, 8, 6, 2, 1)
    elseif kind == "server" then
        -- Two stacked rack units, each with a status LED.
        hollow(2, 2, 14, 6, 2)
        frame(4, 4, 2, 2, 999)
        hollow(2, 10, 14, 6, 2)
        frame(4, 12, 2, 2, 999)
    end
    local api = { box = box }
    function api.setColor(col)
        for _, p in ipairs(paints) do
            if p[2] == "bg" then
                p[1].BackgroundColor3 = col
            else
                p[1].Color = col
            end
        end
    end
    return api
end
local SG = Instance.new("ScreenGui")
SG.Name = "Inertia"
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.ResetOnSpawn = false
SG.DisplayOrder = 1000
SG.IgnoreGuiInset = true
SG.Enabled = true
local uiP
if gethui then pcall(function() uiP = gethui() end) end
if not uiP then pcall(function() uiP = game:GetService("CoreGui") end) end
if not uiP then uiP = LP:WaitForChild("PlayerGui") end
SG.Parent = uiP
S.Gui = SG
local NHost = Instance.new("Frame")
NHost.Name = "Notifs"
NHost.Parent = SG
NHost.AnchorPoint = Vector2.new(0.5, 0)
NHost.BackgroundTransparency = 1
NHost.BorderSizePixel = 0
NHost.Position = UDim2.new(0.5, 0, 0.04, 0)
NHost.Size = UDim2.new(0, 340, 0, 180)
NHost.ZIndex = 900
local nLayout = Instance.new("UIListLayout")
nLayout.Parent = NHost
nLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
nLayout.SortOrder = Enum.SortOrder.LayoutOrder
nLayout.Padding = UDim.new(0, 8)
local NOrder, ActiveN = 0, {}
local function Notify(title, msg, dur)
    if not NHost or not NHost.Parent then return end
    NOrder = NOrder + 1
    dur = dur or 2.8
    SFX.Pop()
    local toast = Instance.new("Frame")
    toast.Name = "N"
    toast.Parent = NHost
    toast.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    toast.BackgroundTransparency = 0
    toast.BorderSizePixel = 0
    toast.ClipsDescendants = true
    toast.LayoutOrder = NOrder
    toast.Size = UDim2.new(0, 260, 0, 0)
    toast.ZIndex = 901
    Corner(toast, 10)
    local tst = Stroke(toast, T.Bd2, 1, 0.5)
    Shadow(toast, 0.5)
    Grad(toast, Color3.fromRGB(14, 14, 14), Color3.fromRGB(6, 6, 6), 90)
    local sc = Instance.new("UIScale")
    sc.Scale = 0.9
    sc.Parent = toast
    local strip = Instance.new("Frame")
    strip.Parent = toast
    strip.BackgroundColor3 = T.White; pcall(function() strip:SetAttribute("ThemeColorRole_BackgroundColor3", "White") end)
    strip.BorderSizePixel = 0
    strip.Position = UDim2.new(0, 0, 0, 0)
    strip.Size = UDim2.new(1, 0, 0, 1)
    strip.ZIndex = 902
    local tt = Instance.new("TextLabel")
    tt.Parent = toast
    tt.BackgroundTransparency = 1
    tt.Font = FB
    tt.Position = UDim2.new(0, 14, 0, 8)
    tt.Size = UDim2.new(1, -28, 0, 16)
    tt.Text = tostring(title or "")
    tt.TextColor3 = T.White; pcall(function() tt:SetAttribute("ThemeColorRole_TextColor3", "White") end)
    tt.TextSize = 13
    tt.TextTransparency = 1
    tt.TextTruncate = Enum.TextTruncate.AtEnd
    tt.TextXAlignment = Enum.TextXAlignment.Left
    tt.ZIndex = 902
    local bt = Instance.new("TextLabel")
    bt.Parent = toast
    bt.BackgroundTransparency = 1
    bt.Font = F
    bt.Position = UDim2.new(0, 14, 0, 24)
    bt.Size = UDim2.new(1, -28, 0, 16)
    bt.Text = tostring(msg or "")
    bt.TextColor3 = T.Tx2; pcall(function() bt:SetAttribute("ThemeColorRole_TextColor3", "Tx2") end)
    bt.TextSize = 12
    bt.TextTransparency = 1
    bt.TextTruncate = Enum.TextTruncate.AtEnd
    bt.TextXAlignment = Enum.TextXAlignment.Left
    bt.ZIndex = 902
    table.insert(ActiveN, toast)
    if #ActiveN > 3 then
        local old = table.remove(ActiveN, 1)
        if old and old.Parent then
            old:Destroy()
        end
    end
    TweenService.Create(TweenService, toast, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 310, 0, 46)
    }):Play()
    TweenService.Create(TweenService, sc, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = 1
    }):Play()
    TweenService.Create(TweenService, tt, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
    TweenService.Create(TweenService, bt, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
    task.delay(dur, function()
        if not toast.Parent then return end
        TweenService.Create(TweenService, tt, TweenInfo.new(0.15), { TextTransparency = 1 }):Play()
        TweenService.Create(TweenService, bt, TweenInfo.new(0.15), { TextTransparency = 1 }):Play()
        TweenService.Create(TweenService, tst, TweenInfo.new(0.15), { Transparency = 1 }):Play()
        TweenService.Create(TweenService, toast, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 260, 0, 0)
        }):Play()
        TweenService.Create(TweenService, sc, TweenInfo.new(0.25), { Scale = 0.9 }):Play()
        task.wait(0.27)
        for i, v in ipairs(ActiveN) do
            if v == toast then table.remove(ActiveN, i); break end
        end
        if toast.Parent then toast:Destroy() end
    end)
end

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOV"
FOVCircle.Parent = SG
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Size = UDim2.fromOffset(200, 200)
FOVCircle.Visible = false
FOVCircle.ZIndex = 800
Corner(FOVCircle, 99999)
local fovSt = Stroke(FOVCircle, T.White, 1.5, 0.7)

local FOV_COLORS = {
    White  = Color3.fromRGB(255, 255, 255),
    Red    = Color3.fromRGB(255, 60, 60),
    Green  = Color3.fromRGB(90, 220, 120),
    Blue   = Color3.fromRGB(60, 140, 255),
    Yellow = Color3.fromRGB(255, 225, 90),
    Cyan   = Color3.fromRGB(80, 220, 230),
    Purple = Color3.fromRGB(180, 120, 255),
    Orange = Color3.fromRGB(255, 150, 60),
    Pink   = Color3.fromRGB(255, 120, 200),
    Black  = Color3.fromRGB(15, 15, 15),
}

local WW, WH = 640, 460
local expandedSize = UDim2.fromOffset(WW, WH)
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = SG
Main.Active = true
Main.BackgroundColor3 = T.BG; pcall(function() Main:SetAttribute("ThemeColorRole_BackgroundColor3", "BG") end)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.5, -WW/2, 0.5, -WH/2)
Main.Size = expandedSize
Main.ClipsDescendants = true
Corner(Main, 12)
Stroke(Main, T.Bd, 1, 0.1)
Shadow(Main, 0.2)
local AccLine = Instance.new("Frame")
AccLine.Parent = Main
AccLine.Size = UDim2.new(1, 0, 0, 1)
AccLine.Position = UDim2.new(0, 0, 0, 0)
AccLine.BackgroundColor3 = T.White; pcall(function() AccLine:SetAttribute("ThemeColorRole_BackgroundColor3", "White") end)
AccLine.BorderSizePixel = 0
AccLine.ZIndex = 10
AccLine.BackgroundTransparency = 0.15
local accGrad = Instance.new("UIGradient")
accGrad.Parent = AccLine
accGrad.Rotation = 0
accGrad.Color = ColorSequence.new(T.White)
accGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0.65),
    NumberSequenceKeypoint.new(1, 1),
})
task.spawn(function()
    while S.Gui and S.Gui.Parent do
        TweenService.Create(TweenService, accGrad, TweenInfo.new(3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Offset = Vector2.new(0.45, 0)
        }):Play()
        task.wait(3.5)
        TweenService.Create(TweenService, accGrad, TweenInfo.new(3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Offset = Vector2.new(-0.45, 0)
        }):Play()
        task.wait(3.5)
    end
end)
local TBar = Instance.new("Frame")
TBar.Name = "TBar"
TBar.Parent = Main
TBar.BackgroundTransparency = 1
TBar.Size = UDim2.new(1, 0, 0, 40)
TBar.Position = UDim2.new(0, 0, 0, 1)
local TIcon = Instance.new("Frame")
TIcon.Parent = TBar
TIcon.BackgroundColor3 = T.White; pcall(function() TIcon:SetAttribute("ThemeColorRole_BackgroundColor3", "White") end)
TIcon.BorderSizePixel = 0
TIcon.Position = UDim2.new(0, 16, 0.5, -5)
TIcon.Size = UDim2.new(0, 2, 0, 10)
Corner(TIcon, 2)
local TTitle = Instance.new("TextLabel")
TTitle.Parent = TBar
TTitle.BackgroundTransparency = 1
TTitle.Position = UDim2.new(0, 26, 0, 0)
TTitle.Size = UDim2.new(0, 80, 1, 0)
TTitle.Font = FB
TTitle.Text = "Inertia"
TTitle.TextColor3 = T.White; pcall(function() TTitle:SetAttribute("ThemeColorRole_TextColor3", "White") end)
TTitle.TextSize = 16
TTitle.TextXAlignment = Enum.TextXAlignment.Left
local function mkWinBtn(txt, xOff)
    local b = Instance.new("TextButton")
    b.Parent = TBar
    b.AnchorPoint = Vector2.new(1, 0.5)
    b.Position = UDim2.new(1, xOff, 0.5, 0)
    b.Size = UDim2.new(0, 26, 0, 22)
    b.BackgroundColor3 = T.Elev; pcall(function() b:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
    b.BorderSizePixel = 0
    b.Font = FB
    b.TextSize = 13
    b.Text = txt
    b.TextColor3 = T.Tx2; pcall(function() b:SetAttribute("ThemeColorRole_TextColor3", "Tx2") end)
    b.AutoButtonColor = false
    Corner(b, 6)
    Stroke(b, T.Bd, 1, 0.4)
    b.MouseEnter:Connect(function()
        TweenService.Create(TweenService, b, TweenInfo.new(0.12), { BackgroundColor3 = T.Hover }):Play()
        b.TextColor3 = T.White; pcall(function() b:SetAttribute("ThemeColorRole_TextColor3", "White") end)
    end)
    b.MouseLeave:Connect(function()
        TweenService.Create(TweenService, b, TweenInfo.new(0.12), { BackgroundColor3 = T.Elev }):Play()
        b.TextColor3 = T.Tx2; pcall(function() b:SetAttribute("ThemeColorRole_TextColor3", "Tx2") end)
    end)
    return b
end
local CloseBtn = mkWinBtn("X", -10)
local MinBtn = mkWinBtn("-", -40)
-- ===== Feature search =====
local UIRegistry = {}
-- ===== Config system: each toggle/slider/cycle registers a get/set here =====
local ConfigControls = {}
local function _cfgId(parent, label)
    local card = parent.Parent
    local page = card and card.Parent
    return (page and page.Name or "?") .. "/" .. (card and card.Name or "?") .. "/" .. label
end
local Pages = {}
local activePage
local SBItems, refreshSB, SearchPageHits
local SearchEmptyLbl -- "Nothing found" placeholder, created after the pages exist
local SearchQuery = ""
-- Split a query into whitespace-separated terms. An entry matches only if EVERY term is found in its
-- haystack, so multi-word / out-of-order searches work ("lock aim", "aim head", "night shader").
local function _searchTokens(q)
    local t = {}
    for w in string.gmatch(q, "%S+") do t[#t + 1] = w end
    return t
end
local function applySearch()
    -- trim leading/trailing spaces so a stray space doesn't wipe every result
    local q = (string.lower(SearchQuery):gsub("^%s+", ""):gsub("%s+$", ""))
    local tokens = _searchTokens(q)
    local cardVis = {}
    SearchPageHits = {}
    for _, e in ipairs(UIRegistry) do
        if e.row and e.row.Parent then
            local vis = true
            if #tokens > 0 then
                -- Match against the control label AND its section title AND its tab name, so you can
                -- search by feature ("triggerbot"), by section ("sheriff"), or by tab ("combat").
                local card = e.card
                local page = card and card.Parent
                local hay = e.label
                    .. " " .. string.lower(card and card.Name or "")
                    .. " " .. string.lower(page and page.Name or "")
                for _, tok in ipairs(tokens) do
                    if not string.find(hay, tok, 1, true) then vis = false; break end
                end
            end
            e.row.Visible = vis
            if vis and e.card then
                cardVis[e.card] = true
                local page = e.card.Parent
                -- count matches per page so the search header can show "COMBAT · 4"
                if page then SearchPageHits[page] = (SearchPageHits[page] or 0) + 1 end
            end
        end
    end
    for _, e in ipairs(UIRegistry) do
        if e.card and e.card.Parent then
            -- While searching, force every matching card visible regardless of which subtab owns it —
            -- that's the whole point (cross-tab results). When the search is CLEARED, don't touch
            -- card.Visible here at all: it used to force every card back to true unconditionally,
            -- which blew away whatever a page's own subtab system (Sheriff/Murderer/Targets,
            -- ESP/Environment, Emotes/Animations, Protection/Movement/Utility, Teleport/Autofarm) had
            -- hidden — e.g. clearing the search box after typing anything made every Combat subtab's
            -- sections appear stacked together at once. The updateXSubTabs() calls below reassert the
            -- correct per-subtab visibility instead.
            if #tokens > 0 then
                e.card.Visible = cardVis[e.card] == true
            end
        end
    end
    if #tokens == 0 then
        -- Not searching: restore the normal single active page, hide the search headers, bring the
        -- subtab bars back, and let each page's own subtab system re-show only the selected subtab.
        for _, pg in pairs(Pages) do
            pg.Visible = (pg == activePage)
            local h = pg:FindFirstChild("SearchHdr"); if h then h.Visible = false end
            local bar = pg:FindFirstChild("SubTabBar") or pg:FindFirstChild("VisualsSubTabBar")
            if bar then bar.Visible = true end
        end
        if SearchEmptyLbl then SearchEmptyLbl.Visible = false end
        if S._UpdateCombatSubtabs then S._UpdateCombatSubtabs() end
        if S._UpdateMiscSubtabs then S._UpdateMiscSubtabs() end
        if S._UpdateTeleportSubtabs then S._UpdateTeleportSubtabs() end
        if S._UpdateVisualsSubtabs then S._UpdateVisualsSubtabs() end
        if S._UpdatePlayerSubtabs then S._UpdatePlayerSubtabs() end
        if S._UpdateMotionSubtabs then S._UpdateMotionSubtabs() end
    else
        -- Searching: show EVERY tab that has a match. ContentArea has a UIListLayout, so the visible
        -- pages stack into one scrollable list — the matching settings from all tabs appear together,
        -- each with its live slider/toggle. A per-page header labels which tab each group came from
        -- (with its match count). Subtab bars are HIDDEN while searching: their buttons are
        -- meaningless inside the combined results list and only cluttered it up.
        local anyHit = false
        for _, pg in pairs(Pages) do
            local hits = SearchPageHits[pg] or 0
            local hit = hits > 0
            anyHit = anyHit or hit
            pg.Visible = hit
            local h = pg:FindFirstChild("SearchHdr")
            if h then
                h.Visible = hit
                if hit then h.Text = string.upper(pg.Name) .. "  ·  " .. hits end
            end
            local bar = pg:FindFirstChild("SubTabBar") or pg:FindFirstChild("VisualsSubTabBar")
            if bar then bar.Visible = false end
        end
        if SearchEmptyLbl then SearchEmptyLbl.Visible = not anyHit end
    end
    -- Sidebar dots: flag every tab that has matches.
    if SBItems then
        for _, item in ipairs(SBItems) do
            if item.dot then
                item.dot.Visible = (#tokens > 0) and ((SearchPageHits[item.page] or 0) > 0)
            end
        end
    end
end
local SearchBox = Instance.new("TextBox")
SearchBox.Parent = TBar
SearchBox.AnchorPoint = Vector2.new(1, 0.5)
SearchBox.Position = UDim2.new(1, -76, 0.5, 0)
SearchBox.Size = UDim2.new(0, 190, 0, 24)
SearchBox.BackgroundColor3 = T.Elev; pcall(function() SearchBox:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
SearchBox.BorderSizePixel = 0
SearchBox.Font = F
SearchBox.TextSize = 12
SearchBox.TextColor3 = T.Tx; pcall(function() SearchBox:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
SearchBox.PlaceholderText = "Search features..."
SearchBox.PlaceholderColor3 = T.Tx4
SearchBox.Text = ""
SearchBox.ClearTextOnFocus = false
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
Corner(SearchBox, 6)
do
    -- Search field polish: the stroke lights up while the box is focused (so it reads as an active
    -- input), the text is padded away from the clear button, and a small × appears only while a
    -- query is typed — one click wipes the query and restores the normal tab view.
    local sbStroke = Stroke(SearchBox, T.Bd2, 1, 0.4)
    pcall(function() sbStroke:SetAttribute("ThemeColorRole_Color", "Bd2") end)
    Pad(SearchBox, 0, 0, 8, 20)
    SearchBox.Focused:Connect(function()
        sbStroke.Transparency = 0.05
        sbStroke.Color = T.White; pcall(function() sbStroke:SetAttribute("ThemeColorRole_Color", "White") end)
    end)
    SearchBox.FocusLost:Connect(function()
        sbStroke.Transparency = 0.4
        sbStroke.Color = T.Bd2; pcall(function() sbStroke:SetAttribute("ThemeColorRole_Color", "Bd2") end)
    end)
    local clearBtn = Instance.new("TextButton")
    clearBtn.Name = "SearchClear"
    clearBtn.Parent = TBar
    clearBtn.AnchorPoint = Vector2.new(1, 0.5)
    clearBtn.Position = UDim2.new(1, -79, 0.5, 0)
    clearBtn.Size = UDim2.new(0, 18, 0, 18)
    clearBtn.BackgroundTransparency = 1
    clearBtn.BorderSizePixel = 0
    clearBtn.AutoButtonColor = false
    clearBtn.Font = FB
    clearBtn.TextSize = 14
    clearBtn.Text = "×"
    clearBtn.TextColor3 = T.Tx3; pcall(function() clearBtn:SetAttribute("ThemeColorRole_TextColor3", "Tx3") end)
    clearBtn.Visible = false
    clearBtn.ZIndex = SearchBox.ZIndex + 1
    clearBtn.MouseEnter:Connect(function()
        clearBtn.TextColor3 = T.White; pcall(function() clearBtn:SetAttribute("ThemeColorRole_TextColor3", "White") end)
    end)
    clearBtn.MouseLeave:Connect(function()
        clearBtn.TextColor3 = T.Tx3; pcall(function() clearBtn:SetAttribute("ThemeColorRole_TextColor3", "Tx3") end)
    end)
    clearBtn.MouseButton1Click:Connect(function()
        SFX.Click()
        SearchBox.Text = "" -- the Text change signal below re-runs applySearch and restores the tabs
    end)
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        clearBtn.Visible = SearchBox.Text ~= ""
    end)
end
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    SearchQuery = string.lower(SearchBox.Text)
    applySearch()
end)
do
    local dr, ds, sp
    TBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dr = true
            ds = i.Position
            sp = Main.Position
        end
    end)
    tc(UIS.InputChanged:Connect(function(i)
        if dr and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end))
    tc(UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dr = false
        end
    end))
end
local SB = Instance.new("ScrollingFrame")
SB.Name = "Sidebar"
SB.Parent = Main
SB.BackgroundColor3 = T.Sidebar; pcall(function() SB:SetAttribute("ThemeColorRole_BackgroundColor3", "Sidebar") end)
SB.BorderSizePixel = 0
SB.Position = UDim2.new(0, 0, 0, 110)
SB.Size = UDim2.new(0, 140, 1, -136)
SB.CanvasSize = UDim2.new(0, 0, 0, 0)
SB.AutomaticCanvasSize = Enum.AutomaticSize.Y
SB.ScrollBarThickness = 2
SB.ScrollBarImageColor3 = T.Tx3; pcall(function() SB:SetAttribute("ThemeColorRole_ScrollBarImageColor3", "Tx3") end)
SB.ScrollBarImageTransparency = 0.5
local SBLine = Instance.new("Frame")
SBLine.Parent = Main
SBLine.BackgroundColor3 = T.Bd; pcall(function() SBLine:SetAttribute("ThemeColorRole_BackgroundColor3", "Bd") end)
SBLine.BackgroundTransparency = 0.3
SBLine.BorderSizePixel = 0
SBLine.Position = UDim2.new(0, 140, 0, 41)
SBLine.Size = UDim2.new(0, 1, 1, -67)
local SBLayout = Instance.new("UIListLayout")
SBLayout.Parent = SB
SBLayout.SortOrder = Enum.SortOrder.LayoutOrder
SBLayout.Padding = UDim.new(0, 4)
Pad(SB, 12, 12, 8, 8)

-- Settings Modal definition
do
local SettingsModal = Instance.new("Frame")
SettingsModal.Name = "InertiaSettings"
SettingsModal.Parent = SG
SettingsModal.Active = true
SettingsModal.AnchorPoint = Vector2.new(0.5, 0.5)
SettingsModal.Position = UDim2.new(0.5, 0, 0.5, 0)
SettingsModal.Size = UDim2.fromOffset(300, 340)
SettingsModal.BackgroundColor3 = T.Card; pcall(function() SettingsModal:SetAttribute("ThemeColorRole_BackgroundColor3", "Card") end)
SettingsModal.BorderSizePixel = 0
SettingsModal.ZIndex = 999
SettingsModal.Visible = false
Corner(SettingsModal, 12)
Stroke(SettingsModal, T.Bd2, 1.2, 0.4)
Shadow(SettingsModal, 0.4)

-- Modal Header
local mHdr = Instance.new("TextLabel")
mHdr.Parent = SettingsModal
mHdr.BackgroundTransparency = 1
mHdr.Position = UDim2.new(0, 16, 0, 10)
mHdr.Size = UDim2.new(1, -64, 0, 24)
mHdr.Font = FB
mHdr.TextSize = 15
mHdr.TextColor3 = T.White; pcall(function() mHdr:SetAttribute("ThemeColorRole_TextColor3", "White") end)
mHdr.TextXAlignment = Enum.TextXAlignment.Left
mHdr.Text = "Settings"
mHdr.ZIndex = 1000

-- Close button
local mClose = Instance.new("TextButton")
mClose.Parent = SettingsModal
mClose.AnchorPoint = Vector2.new(1, 0)
mClose.Position = UDim2.new(1, -10, 0, 10)
mClose.Size = UDim2.fromOffset(24, 24)
mClose.BackgroundColor3 = T.Elev; pcall(function() mClose:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
mClose.BorderSizePixel = 0
mClose.Font = FB
mClose.TextSize = 13
mClose.TextColor3 = T.Tx2; pcall(function() mClose:SetAttribute("ThemeColorRole_TextColor3", "Tx2") end)
mClose.Text = "X"
mClose.ZIndex = 1000
Corner(mClose, 6)
Stroke(mClose, T.Bd, 1, 0.4)
mClose.MouseButton1Click:Connect(function()
    SettingsModal.Visible = false
    SFX.Off()
end)

-- Layout for Settings
local mScroll = Instance.new("ScrollingFrame")
mScroll.Parent = SettingsModal
mScroll.BackgroundTransparency = 1
mScroll.BorderSizePixel = 0
mScroll.Position = UDim2.new(0, 16, 0, 44)
mScroll.Size = UDim2.new(1, -32, 1, -60)
mScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
mScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
mScroll.ScrollBarThickness = 3
mScroll.ScrollBarImageColor3 = T.Tx3; pcall(function() mScroll:SetAttribute("ThemeColorRole_ScrollBarImageColor3", "Tx3") end)
mScroll.ZIndex = 1000

local mList = Instance.new("UIListLayout")
mList.Parent = mScroll
mList.SortOrder = Enum.SortOrder.LayoutOrder
mList.Padding = UDim.new(0, 12)

-- Helper to make setting labels
local function mkModalLabel(text, order)
    local l = Instance.new("TextLabel")
    l.Parent = mScroll
    l.LayoutOrder = order
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, 0, 0, 18)
    l.Font = FM
    l.TextSize = 12
    l.TextColor3 = T.Tx2; pcall(function() l:SetAttribute("ThemeColorRole_TextColor3", "Tx2") end)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = text
    l.ZIndex = 1001
    return l
end

-- 1. Language Option (Cycle style)
mkModalLabel("Language", 1)
local langBtn = Instance.new("TextButton")
langBtn.Parent = mScroll
langBtn.LayoutOrder = 2
langBtn.Size = UDim2.new(1, 0, 0, 28)
langBtn.BackgroundColor3 = T.Elev; pcall(function() langBtn:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
langBtn.BorderSizePixel = 0
langBtn.Font = F
langBtn.TextSize = 13
langBtn.TextColor3 = T.White; pcall(function() langBtn:SetAttribute("ThemeColorRole_TextColor3", "White") end)
langBtn.Text = S.Language or "ENG"
langBtn.ZIndex = 1001
Corner(langBtn, 6)
Stroke(langBtn, T.Bd, 1, 0.4)

local langList = {"ENG", "RU", "UK", "SPANISH"}
langBtn.MouseButton1Click:Connect(function()
    local cur = table.find(langList, S.Language or "ENG") or 1
    local nextIdx = (cur % #langList) + 1
    local nextLang = langList[nextIdx]
    S.Language = nextLang
    langBtn.Text = nextLang
    updateLanguage()
    SFX.Click()
    pcall(function() if S.SaveConfig then S.SaveConfig("_autoload") end end)
end)

-- 2. Text Size Option
mkModalLabel("Text Size", 3)
local sizeBtn = Instance.new("TextButton")
sizeBtn.Parent = mScroll
sizeBtn.LayoutOrder = 4
sizeBtn.Size = UDim2.new(1, 0, 0, 28)
sizeBtn.BackgroundColor3 = T.Elev; pcall(function() sizeBtn:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
sizeBtn.BorderSizePixel = 0
sizeBtn.Font = F
sizeBtn.TextSize = 13
sizeBtn.TextColor3 = T.White; pcall(function() sizeBtn:SetAttribute("ThemeColorRole_TextColor3", "White") end)
local sizeNames = { [0.85] = "Small", [1.0] = "Medium", [1.15] = "Large" }
sizeBtn.Text = sizeNames[S.TextSizeScale or 1.0] or "Medium"
sizeBtn.ZIndex = 1001
Corner(sizeBtn, 6)
Stroke(sizeBtn, T.Bd, 1, 0.4)

local sizeList = {0.85, 1.0, 1.15}
sizeBtn.MouseButton1Click:Connect(function()
    local cur = table.find(sizeList, S.TextSizeScale or 1.0) or 2
    local nextIdx = (cur % #sizeList) + 1
    local nextScale = sizeList[nextIdx]
    S.TextSizeScale = nextScale
    sizeBtn.Text = sizeNames[nextScale]
    updateTextSizes()
    SFX.Click()
    pcall(function() if S.SaveConfig then S.SaveConfig("_autoload") end end)
end)

-- 3. Theme Selector
mkModalLabel("Theme Style", 5)
local themeContainer = Instance.new("Frame")
themeContainer.Parent = mScroll
themeContainer.LayoutOrder = 6
themeContainer.BackgroundTransparency = 1
themeContainer.Size = UDim2.new(1, 0, 0, 150)
themeContainer.ZIndex = 1001

local themeScroll = Instance.new("ScrollingFrame")
themeScroll.Parent = themeContainer
themeScroll.BackgroundTransparency = 0.5
themeScroll.BackgroundColor3 = T.Elev; pcall(function() themeScroll:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
themeScroll.BorderSizePixel = 0
themeScroll.Size = UDim2.new(1, 0, 1, 0)
themeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
themeScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
themeScroll.ScrollBarThickness = 3
themeScroll.ScrollBarImageColor3 = T.Tx3; pcall(function() themeScroll:SetAttribute("ThemeColorRole_ScrollBarImageColor3", "Tx3") end)
themeScroll.ZIndex = 1001
Corner(themeScroll, 6)
Stroke(themeScroll, T.Bd, 1, 0.4)
Pad(themeScroll, 6, 6, 6, 6)

local themeListLayout = Instance.new("UIListLayout")
themeListLayout.Parent = themeScroll
themeListLayout.SortOrder = Enum.SortOrder.LayoutOrder
themeListLayout.Padding = UDim.new(0, 4)

local themeNames = {
    "Monochrome", "Neon Blue", "Ruby Red", "Emerald Green",
    "Amethyst Purple", "Sakura Pink", "Amber Gold", "Midnight Navy",
    "Toxic Lime", "Sunset Orange"
}

for idx, tName in ipairs(themeNames) do
    local btn = Instance.new("TextButton")
    btn.Name = tName
    btn.Parent = themeScroll
    btn.LayoutOrder = idx
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.BackgroundColor3 = T.Card; pcall(function() btn:SetAttribute("ThemeColorRole_BackgroundColor3", "Card") end)
    btn.BorderSizePixel = 0
    btn.Font = F
    btn.TextSize = 12
    btn.TextColor3 = T.Tx2; pcall(function() btn:SetAttribute("ThemeColorRole_TextColor3", "Tx2") end)
    btn.Text = "   " .. tName
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.ZIndex = 1002
    Corner(btn, 4)
    Stroke(btn, T.Bd, 1, 0.4)

    local pDot = Instance.new("Frame")
    pDot.Parent = btn
    pDot.AnchorPoint = Vector2.new(1, 0.5)
    pDot.Position = UDim2.new(1, -8, 0.5, 0)
    pDot.Size = UDim2.fromOffset(10, 10)
    pDot.BackgroundColor3 = Themes[tName].Accent
    pDot.BorderSizePixel = 0
    pDot.ZIndex = 1003
    Corner(pDot, 9999)

    btn.MouseButton1Click:Connect(function()
        applyTheme(tName)
        SFX.Click()
        pcall(function() if S.SaveConfig then S.SaveConfig("_autoload") end end)
    end)
    btn.MouseEnter:Connect(function() btn.TextColor3 = T.White; pcall(function() btn:SetAttribute("ThemeColorRole_TextColor3", "White") end) end)
    btn.MouseLeave:Connect(function() btn.TextColor3 = T.Tx2; pcall(function() btn:SetAttribute("ThemeColorRole_TextColor3", "Tx2") end) end)
end

-- Profile Header
local ProfileHeader = Instance.new("Frame")
ProfileHeader.Name = "ProfileHeader"
ProfileHeader.Parent = Main
ProfileHeader.Position = UDim2.new(0, 0, 0, 41)
ProfileHeader.Size = UDim2.new(0, 140, 0, 69)
ProfileHeader.BackgroundColor3 = T.Sidebar; pcall(function() ProfileHeader:SetAttribute("ThemeColorRole_BackgroundColor3", "Sidebar") end)
ProfileHeader.BorderSizePixel = 0

local phLine = Instance.new("Frame")
phLine.Name = "phLine"
phLine.Parent = ProfileHeader
phLine.BackgroundColor3 = T.Bd; pcall(function() phLine:SetAttribute("ThemeColorRole_BackgroundColor3", "Bd") end)
phLine.BackgroundTransparency = 0.3
phLine.BorderSizePixel = 0
phLine.Position = UDim2.new(0, 0, 1, -1)
phLine.Size = UDim2.new(1, 0, 0, 1)

local avatarUrl = "rbxasset://textures/ui/Guidetool/PlayerIcon.png"
pcall(function()
    avatarUrl = Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
end)

local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Parent = ProfileHeader
AvatarImage.Position = UDim2.new(0, 8, 0.5, -22)
AvatarImage.Size = UDim2.fromOffset(44, 44)
AvatarImage.BackgroundTransparency = 1
AvatarImage.Image = avatarUrl
AvatarImage.ZIndex = 50
Corner(AvatarImage, 9999)
Stroke(AvatarImage, T.Bd2, 1, 0.4)

local UserLabel = Instance.new("TextLabel")
UserLabel.Parent = ProfileHeader
UserLabel.BackgroundTransparency = 1
UserLabel.Position = UDim2.new(0, 58, 0.5, -16)
UserLabel.Size = UDim2.new(1, -64, 0, 16)
UserLabel.Font = FM
UserLabel.TextSize = 12
UserLabel.TextColor3 = T.Tx; pcall(function() UserLabel:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
UserLabel.TextXAlignment = Enum.TextXAlignment.Left
UserLabel.TextTruncate = Enum.TextTruncate.AtEnd
UserLabel.Text = LP.DisplayName
UserLabel.ZIndex = 50

local SubLabel = Instance.new("TextLabel")
SubLabel.Parent = ProfileHeader
SubLabel.BackgroundTransparency = 1
SubLabel.Position = UDim2.new(0, 58, 0.5, 2)
SubLabel.Size = UDim2.new(1, -64, 0, 12)
SubLabel.Font = F
SubLabel.TextSize = 10
SubLabel.TextColor3 = T.Tx3; pcall(function() SubLabel:SetAttribute("ThemeColorRole_TextColor3", "Tx3") end)
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Text = "Premium"
SubLabel.ZIndex = 50

local ProfileBtn = Instance.new("TextButton")
ProfileBtn.Parent = ProfileHeader
ProfileBtn.Size = UDim2.fromScale(1, 1)
ProfileBtn.BackgroundTransparency = 1
ProfileBtn.Text = ""
ProfileBtn.ZIndex = 51

ProfileBtn.MouseButton1Click:Connect(function()
    SettingsModal.Visible = not SettingsModal.Visible
    if SettingsModal.Visible then SFX.On() else SFX.Off() end
end)

mScroll.Active = true

-- Make settings modal draggable by header
do
    local dr, ds, sp
    mHdr.Active = true
    mHdr.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dr = true
            ds = i.Position
            sp = SettingsModal.Position
        end
    end)
    tc(UIS.InputChanged:Connect(function(i)
        if dr and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            SettingsModal.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end))
    tc(UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dr = false
        end
    end))
end

end
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Name = "Content"
ContentArea.Parent = Main
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.Position = UDim2.new(0, 146, 0, 41)
ContentArea.Size = UDim2.new(1, -152, 1, -67)
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentArea.ScrollBarThickness = 3
ContentArea.ScrollBarImageColor3 = T.Tx3; pcall(function() ContentArea:SetAttribute("ThemeColorRole_ScrollBarImageColor3", "Tx3") end)
ContentArea.ScrollBarImageTransparency = 0.5
local caLayout = Instance.new("UIListLayout")
caLayout.Parent = ContentArea
caLayout.SortOrder = Enum.SortOrder.LayoutOrder
local StatusBar = Instance.new("Frame")
StatusBar.Name = "Status"
StatusBar.Parent = Main
StatusBar.BackgroundColor3 = Color3.fromRGB(4, 4, 4)
StatusBar.BorderSizePixel = 0
StatusBar.Position = UDim2.new(0, 0, 1, -26)
StatusBar.Size = UDim2.new(1, 0, 0, 26)
local sbTop = Instance.new("Frame")
sbTop.Parent = StatusBar
sbTop.BorderSizePixel = 0
sbTop.BackgroundColor3 = T.Bd; pcall(function() sbTop:SetAttribute("ThemeColorRole_BackgroundColor3", "Bd") end)
sbTop.BackgroundTransparency = 0.3
sbTop.Size = UDim2.new(1, 0, 0, 1)
local StatusRole = Instance.new("TextLabel")
StatusRole.Parent = StatusBar
StatusRole.BackgroundTransparency = 1
StatusRole.Position = UDim2.new(0, 16, 0, 0)
StatusRole.Size = UDim2.new(0, 150, 1, 0)
StatusRole.Font = FM
StatusRole.TextSize = 12
StatusRole.TextColor3 = T.Tx2; pcall(function() StatusRole:SetAttribute("ThemeColorRole_TextColor3", "Tx2") end)
StatusRole.TextXAlignment = Enum.TextXAlignment.Left
StatusRole.Text = "ROLE  ..."
local StatusFPS = Instance.new("TextLabel")
StatusFPS.Parent = StatusBar
StatusFPS.BackgroundTransparency = 1
StatusFPS.Position = UDim2.new(0, 180, 0, 0)
StatusFPS.Size = UDim2.new(0, 80, 1, 0)
StatusFPS.Font = FM
StatusFPS.TextSize = 12
StatusFPS.TextColor3 = T.Tx; pcall(function() StatusFPS:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
StatusFPS.TextXAlignment = Enum.TextXAlignment.Left
StatusFPS.Text = "FPS  0"
local StatusPing = Instance.new("TextLabel")
StatusPing.Parent = StatusBar
StatusPing.BackgroundTransparency = 1
StatusPing.Position = UDim2.new(0, 270, 0, 0)
StatusPing.Size = UDim2.new(0, 90, 1, 0)
StatusPing.Font = FM
StatusPing.TextSize = 12
StatusPing.TextColor3 = T.Tx3; pcall(function() StatusPing:SetAttribute("ThemeColorRole_TextColor3", "Tx3") end)
StatusPing.TextXAlignment = Enum.TextXAlignment.Left
StatusPing.Text = ""
local StatusHint = Instance.new("TextLabel")
StatusHint.Parent = StatusBar
StatusHint.BackgroundTransparency = 1
StatusHint.AnchorPoint = Vector2.new(1, 0)
StatusHint.Position = UDim2.new(1, -16, 0, 0)
StatusHint.Size = UDim2.new(0, 200, 1, 0)
StatusHint.Font = F
StatusHint.TextSize = 11
StatusHint.TextColor3 = T.Tx4; pcall(function() StatusHint:SetAttribute("ThemeColorRole_TextColor3", "Tx4") end)
StatusHint.TextXAlignment = Enum.TextXAlignment.Right
StatusHint.Text = "LCtrl = menu  |  RMB = bind"
local fpsCount, lastFpsT, curFPS = 0, tick(), 0
local lastStatusT = 0  -- throttles the role/ping status-bar labels (no need to recompute per frame)
local function mkPage(name)
    local sf = Instance.new("Frame")
    sf.Name = name
    sf.Parent = ContentArea
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.Position = UDim2.new(0, 0, 0, 0)
    sf.Size = UDim2.new(1, 0, 0, 0)
    sf.AutomaticSize = Enum.AutomaticSize.Y
    sf.Visible = false
    local l = Instance.new("UIListLayout")
    l.Parent = sf
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, 12)
    Pad(sf, 8, 12, 6, 8)
    -- Tab header, shown ONLY while searching so the combined multi-tab results list is labelled by
    -- which tab each group of settings came from (applySearch appends the match count, e.g.
    -- "COMBAT  ·  4"). Styled as a subtle pill so it separates the groups instead of blending into
    -- the section titles. Hidden during normal single-tab browsing.
    local hdr = Instance.new("TextLabel")
    hdr.Name = "SearchHdr"
    hdr.Parent = sf
    hdr.LayoutOrder = -1
    hdr.BackgroundColor3 = T.Elev; pcall(function() hdr:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
    hdr.BackgroundTransparency = 0.25
    hdr.BorderSizePixel = 0
    hdr.Size = UDim2.new(1, 0, 0, 24)
    hdr.Font = FB
    hdr.TextSize = 11
    hdr.TextColor3 = T.Tx2; pcall(function() hdr:SetAttribute("ThemeColorRole_TextColor3", "Tx2") end)
    hdr.TextXAlignment = Enum.TextXAlignment.Left
    hdr.Text = string.upper(name)
    hdr.Visible = false
    Corner(hdr, 6)
    Pad(hdr, 0, 0, 10, 10)
    Pages[name] = sf
    return sf
end
mkPage("Visuals")
mkPage("Combat")
mkPage("Motion")
mkPage("Player")
mkPage("Misc")
mkPage("Teleport")
mkPage("Servers")
mkPage("Config")
Pages.Visuals.Visible = true
-- Shown instead of a blank content area when a search query matches nothing (applySearch toggles it).
SearchEmptyLbl = Instance.new("TextLabel")
SearchEmptyLbl.Name = "SearchEmpty"
SearchEmptyLbl.Parent = ContentArea
SearchEmptyLbl.BackgroundTransparency = 1
SearchEmptyLbl.Size = UDim2.new(1, 0, 0, 80)
SearchEmptyLbl.Font = F
SearchEmptyLbl.TextSize = 13
SearchEmptyLbl.TextColor3 = T.Tx3; pcall(function() SearchEmptyLbl:SetAttribute("ThemeColorRole_TextColor3", "Tx3") end)
SearchEmptyLbl.Text = "Nothing found"
SearchEmptyLbl.Visible = false
SBItems = {}
activePage = Pages.Visuals
refreshSB = function()
    for _, item in ipairs(SBItems) do
        local on = (item.page == activePage)
        item.bar.Visible = on
        item.icon.setColor(on and T.White or T.Tx3)
        item.label.TextColor3 = on and T.White or T.Tx2
        item.label.Font = on and FM or F
        item.btn.BackgroundColor3 = T.Elev; pcall(function() item.btn:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
        item.btn.BackgroundTransparency = on and 0 or 1
        if on then
            item.btn.BorderSizePixel = 0
            Stroke(item.btn, T.Bd2, 1, 0.3)
        else
            item.btn.BorderSizePixel = 0
            Stroke(item.btn, T.Bd, 1, 0.5)
        end
    end
end
local function mkSBItem(name, iconKind, page, order)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = SB
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.AutoButtonColor = false
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = ""
    Corner(btn, 8)
    local bar = Instance.new("Frame")
    bar.Parent = btn
    bar.Size = UDim2.new(0, 2, 0, 18)
    bar.Position = UDim2.new(0, 0, 0.5, -9)
    bar.BackgroundColor3 = T.White; pcall(function() bar:SetAttribute("ThemeColorRole_BackgroundColor3", "White") end)
    bar.BorderSizePixel = 0
    bar.Visible = false
    Corner(bar, 2)
    local icon = mkIcon(btn, iconKind)
    icon.box.Position = UDim2.new(0, 12, 0.5, -9)
    local label = Instance.new("TextLabel")
    label.Parent = btn
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 40, 0, 0)
    label.Size = UDim2.new(1, -44, 1, 0)
    label.Font = F
    label.TextSize = 14
    label.TextColor3 = T.Tx2; pcall(function() label:SetAttribute("ThemeColorRole_TextColor3", "Tx2") end)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = name
    -- Small dot shown while searching if THIS tab has matches but isn't the one on screen.
    local dot = Instance.new("Frame")
    dot.Name = "MatchDot"
    dot.Parent = btn
    dot.AnchorPoint = Vector2.new(1, 0.5)
    dot.Position = UDim2.new(1, -18, 0.5, 0)
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.BackgroundColor3 = T.White; pcall(function() dot:SetAttribute("ThemeColorRole_BackgroundColor3", "White") end)
    dot.BorderSizePixel = 0
    dot.Visible = false
    Corner(dot, 3)
    -- Favourite pin (gold dot). Right-click a tab to pin it to the very top of the sidebar.
    local pin = Instance.new("Frame")
    pin.Name = "FavPin"
    pin.Parent = btn
    pin.AnchorPoint = Vector2.new(1, 0.5)
    pin.Position = UDim2.new(1, -8, 0.5, 0)
    pin.Size = UDim2.new(0, 6, 0, 6)
    pin.BackgroundColor3 = Color3.fromRGB(255, 200, 70)
    pin.BorderSizePixel = 0
    pin.Visible = false
    Corner(pin, 3)
    local item = { btn = btn, bar = bar, icon = icon, label = label, page = page, dot = dot, pin = pin, order = order, fav = false }
    btn.MouseButton1Click:Connect(function()
        SFX.Click()
        -- Clicking a tab clears any active search and opens that full tab (setting the SearchBox text
        -- fires applySearch, which hides the search headers and drops back to single-tab view).
        if SearchBox and SearchBox.Text ~= "" then SearchBox.Text = "" end
        for _, pg in pairs(Pages) do
            pg.Visible = (pg == page)
        end
        activePage = page
        refreshSB()
    end)
    -- Right-click toggles favourite: pinned tabs jump to the top (LayoutOrder pushed far below the
    -- others so they sort first, keeping their relative order); right-click again to unpin.
    btn.MouseButton2Click:Connect(function()
        item.fav = not item.fav
        btn.LayoutOrder = item.fav and (order - 1000) or order
        pin.Visible = item.fav
        SFX.Click()
        Notify("Sidebar", item.fav and (name .. " pinned to top") or (name .. " unpinned"), 2)
    end)
    btn.MouseEnter:Connect(function()
        if page ~= activePage then
            btn.BackgroundTransparency = 0.35
            btn.BackgroundColor3 = T.Elev; pcall(function() btn:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
        end
    end)
    btn.MouseLeave:Connect(function()
        refreshSB()
    end)
    table.insert(SBItems, item)
end
mkSBItem("Visuals", "eye", Pages.Visuals, 1)
mkSBItem("Combat", "cross", Pages.Combat, 2)
mkSBItem("Motion", "sliders", Pages.Motion, 3)
mkSBItem("Player", "diamond", Pages.Player, 4)
mkSBItem("Misc", "sliders", Pages.Misc, 5)
mkSBItem("Teleport", "diamond", Pages.Teleport, 6)
mkSBItem("Servers", "server", Pages.Servers, 7)
mkSBItem("Config", "sliders", Pages.Config, 8)
refreshSB()
local BindReg = {}
local PendingBind = nil
local AllBinds = {}
tc(UIS.InputBegan:Connect(function(input, processed)
    if PendingBind then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local e = PendingBind
            PendingBind = nil
            local cancel = (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete)
            if e.oldKey then BindReg[e.oldKey] = nil end
            if cancel then
                e.bindKey = nil
                SFX.Unbind()
                Notify("Bind Cleared", e.label, 2)
            else
                e.bindKey = input.KeyCode
                BindReg[input.KeyCode] = e
                SFX.Bind()
                Notify("Bind Set", e.label .. "  >  " .. input.KeyCode.Name, 2.5)
            end
            e.updateVisuals()
            pcall(function()
                if S._RequestAutoSave then S._RequestAutoSave() end
            end)
        end
        return
    end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        -- Skip only while actually typing in a text box. GetFocusedTextBox is pcall-guarded so that if
        -- it ever throws on an executor it can't kill the whole trigger branch (that would make every
        -- bind silently do nothing even though binding worked). trigger() is pcall-guarded too.
        local typing = false
        pcall(function() typing = (UIS:GetFocusedTextBox() ~= nil) end)
        if not typing then
            local e = BindReg[input.KeyCode]
            if e and e.trigger then pcall(e.trigger) end
        end
    end
end))
local function mkSection(parent, title, order)
    local card = Instance.new("Frame")
    card.Name = title
    card.Parent = parent
    card.LayoutOrder = order
    card.BackgroundColor3 = T.Card; card:SetAttribute("ThemeColorRole_BackgroundColor3", "Card"); pcall(function() card:SetAttribute("ThemeColorRole_BackgroundColor3", "Card") end)
    card.BorderSizePixel = 0
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    Corner(card, 10)
    local cardSt = Stroke(card, T.Bd, 1, 0.3); cardSt:SetAttribute("ThemeColorRole_Color", "Bd")
    local inner = Instance.new("Frame")
    inner.Name = "Inner"
    inner.Parent = card
    inner.BackgroundTransparency = 1
    inner.Size = UDim2.new(1, 0, 0, 0)
    inner.AutomaticSize = Enum.AutomaticSize.Y
    Pad(inner, 12, 14, 14, 14)
    local layout = Instance.new("UIListLayout")
    layout.Parent = inner
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    local hdrRow = Instance.new("Frame")
    hdrRow.Parent = inner
    hdrRow.LayoutOrder = 0
    hdrRow.BackgroundTransparency = 1
    hdrRow.Size = UDim2.new(1, 0, 0, 20)
    local tick = Instance.new("Frame")
    tick.Parent = hdrRow
    tick.BorderSizePixel = 0
    tick.BackgroundColor3 = T.White; pcall(function() tick:SetAttribute("ThemeColorRole_BackgroundColor3", "White") end)
    tick.Position = UDim2.new(0, 0, 0.5, -5)
    tick.Size = UDim2.new(0, 2, 0, 10)
    Corner(tick, 2)
    local hdr = Instance.new("TextLabel")
    hdr.Parent = hdrRow
    hdr.BackgroundTransparency = 1
    hdr.Position = UDim2.new(0, 10, 0, 0)
    hdr.Size = UDim2.new(1, -10, 1, 0)
    hdr.Font = FB
    hdr.TextSize = 12
    hdr.TextColor3 = T.Tx3; hdr:SetAttribute("ThemeColorRole_TextColor3", "Tx3"); pcall(function() hdr:SetAttribute("ThemeColorRole_TextColor3", "Tx3") end)
    hdr.TextXAlignment = Enum.TextXAlignment.Left
    hdr.Text = string.upper(title)
    return inner
end
local function mkToggle(parent, label, default, callback, order)
    local row = Instance.new("Frame")
    row.Name = label
    row.Parent = parent
    row.LayoutOrder = order
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundTransparency = 1
    row.BackgroundColor3 = T.Hover; pcall(function() row:SetAttribute("ThemeColorRole_BackgroundColor3", "Hover") end)
    row.Active = true
    row.BorderSizePixel = 0
    Corner(row, 6)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = row
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 6, 0, 0)
    lbl.Size = UDim2.new(1, -100, 1, 0)
    lbl.Font = F
    lbl.TextSize = 13
    lbl.TextColor3 = T.Tx2; lbl:SetAttribute("ThemeColorRole_TextColor3", "Tx2"); pcall(function() lbl:SetAttribute("ThemeColorRole_TextColor3", "Tx2") end)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = label
    local badge = Instance.new("TextLabel")
    badge.Parent = row
    badge.BackgroundTransparency = 0
    badge.BackgroundColor3 = T.Elev; pcall(function() badge:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
    badge.AnchorPoint = Vector2.new(1, 0.5)
    badge.Position = UDim2.new(1, -52, 0.5, 0)
    badge.Size = UDim2.new(0, 0, 0, 18)
    badge.Font = FM
    badge.TextSize = 11
    badge.TextColor3 = T.Tx2; pcall(function() badge:SetAttribute("ThemeColorRole_TextColor3", "Tx2") end)
    badge.Text = ""
    badge.Visible = false
    badge.AutomaticSize = Enum.AutomaticSize.X
    Corner(badge, 4)
    Stroke(badge, T.Bd2, 1, 0.5)
    Pad(badge, 0, 0, 8, 8)
    local track = Instance.new("TextButton")
    track.Parent = row
    track.AnchorPoint = Vector2.new(1, 0.5)
    track.Position = UDim2.new(1, -6, 0.5, 0)
    track.Size = UDim2.new(0, 40, 0, 20)
    track.BackgroundColor3 = T.TgOff; pcall(function() track:SetAttribute("ThemeColorRole_BackgroundColor3", "TgOff") end)
    track.BorderSizePixel = 0
    track.Text = ""
    track.AutoButtonColor = false
    Corner(track, 10)
    local trackSt = Stroke(track, T.Bd2, 1, 0.6)
    local knob = Instance.new("Frame")
    knob.Parent = track
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = T.KnobOff; pcall(function() knob:SetAttribute("ThemeColorRole_BackgroundColor3", "KnobOff") end)
    knob.BorderSizePixel = 0
    Corner(knob, 7)
    local entry = { label = label, cfgId = _cfgId(parent, label), bindKey = nil, oldKey = nil, isToggle = true, state = default }
    local function setVis(on, anim)
        local tCol = on and T.TgOn or T.TgOff
        local kCol = on and T.KnobOn or T.KnobOff
        local kPos = on and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        lbl.TextColor3 = on and T.Tx or T.Tx2
        trackSt.Transparency = on and 1 or 0.6
        if anim then
            TweenService.Create(TweenService, track, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = tCol
            }):Play()
            TweenService.Create(TweenService, knob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = kPos,
                BackgroundColor3 = kCol
            }):Play()
        else
            track.BackgroundColor3 = tCol
            knob.Position = kPos
            knob.BackgroundColor3 = kCol
        end
    end
    function entry.updateVisuals()
        if entry.bindKey then
            badge.Text = entry.bindKey.Name
            badge.Visible = true
        else
            badge.Visible = false
        end
        setVis(entry.state, false)
    end
    local function toggle()
        entry.state = not entry.state
        setVis(entry.state, true)
        callback(entry.state)
        pcall(function()
            if S._RequestAutoSave then S._RequestAutoSave() end
        end)
        if entry.state then SFX.On() else SFX.Off() end
        Notify(label, entry.state and "Enabled" or "Disabled", 1.8)
    end
    function entry.trigger()
        toggle()
    end
    setVis(entry.state, false)
    entry.updateVisuals()
    track.MouseButton1Click:Connect(function()
        if not PendingBind then toggle() end
    end)
    row.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton2 then
            entry.oldKey = entry.bindKey
            PendingBind = entry
            badge.Text = "..."
            badge.Visible = true
            row.BackgroundTransparency = 0
            TweenService.Create(TweenService, row, TweenInfo.new(0.1), { BackgroundColor3 = T.ActiveBg }):Play()
        end
    end)
    row.MouseEnter:Connect(function()
        TweenService.Create(TweenService, row, TweenInfo.new(0.12), { BackgroundTransparency = 0.4 }):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService.Create(TweenService, row, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play()
    end)
    table.insert(AllBinds, entry)
    table.insert(UIRegistry, { label = string.lower(label), row = row, card = parent.Parent })
    table.insert(ConfigControls, {
        id = _cfgId(parent, label),
        get = function() return entry.state end,
        set = function(v) entry.state = (v == true); setVis(entry.state, false); pcall(callback, entry.state) end,
    })
    return entry
end
local function mkAction(parent, label, callback, order)
    local btn = Instance.new("TextButton")
    btn.Name = label
    btn.Parent = parent
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.AutoButtonColor = false
    btn.BackgroundColor3 = T.Elev; pcall(function() btn:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
    btn.BorderSizePixel = 0
    btn.Font = FM
    btn.TextSize = 13
    btn.TextColor3 = T.Tx; pcall(function() btn:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
    btn.Text = label
    Corner(btn, 7)
    local bst = Stroke(btn, T.Bd2, 1, 0.4)
    local entry = { label = label, cfgId = _cfgId(parent, label), bindKey = nil, oldKey = nil, isToggle = false, btn = btn }
    function entry.updateVisuals()
        local bk = entry.bindKey and ("   [ " .. entry.bindKey.Name .. " ]") or ""
        btn.Text = label .. bk
    end
    function entry.trigger()
        SFX.Click()
        callback()
    end
    entry.updateVisuals()
    btn.MouseButton1Click:Connect(function()
        if not PendingBind then
            SFX.Click()
            callback()
        end
    end)
    btn.MouseButton2Click:Connect(function()
        entry.oldKey = entry.bindKey
        PendingBind = entry
        btn.Text = label .. "   [ ... ]"
        TweenService.Create(TweenService, btn, TweenInfo.new(0.12), { BackgroundColor3 = T.ActiveBg }):Play()
    end)
    btn.MouseEnter:Connect(function()
        TweenService.Create(TweenService, btn, TweenInfo.new(0.12), { BackgroundColor3 = T.Hover }):Play()
        TweenService.Create(TweenService, bst, TweenInfo.new(0.12), { Transparency = 0.1 }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService.Create(TweenService, btn, TweenInfo.new(0.12), { BackgroundColor3 = T.Elev }):Play()
        TweenService.Create(TweenService, bst, TweenInfo.new(0.12), { Transparency = 0.4 }):Play()
        entry.updateVisuals()
    end)
    table.insert(AllBinds, entry)
    table.insert(UIRegistry, { label = string.lower(label), row = btn, card = parent.Parent })
    return entry
end
local function mkSlider(parent, label, min, max, def, callback, order)
    local frame = Instance.new("Frame")
    frame.Name = label
    frame.Parent = parent
    frame.LayoutOrder = order
    frame.Size = UDim2.new(1, 0, 0, 42)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    local lbl = Instance.new("TextLabel")
    lbl.Parent = frame
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 4, 0, 0)
    lbl.Size = UDim2.new(0.6, 0, 0, 18)
    lbl.Font = F
    lbl.TextSize = 12
    lbl.TextColor3 = T.Tx2; lbl:SetAttribute("ThemeColorRole_TextColor3", "Tx2"); pcall(function() lbl:SetAttribute("ThemeColorRole_TextColor3", "Tx2") end)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = label
    local vlbl = Instance.new("TextLabel")
    vlbl.Parent = frame
    vlbl.BackgroundTransparency = 1
    vlbl.AnchorPoint = Vector2.new(1, 0)
    vlbl.Position = UDim2.new(1, -4, 0, 0)
    vlbl.Size = UDim2.new(0.35, 0, 0, 18)
    vlbl.Font = FM
    vlbl.TextSize = 13
    vlbl.TextColor3 = T.White; pcall(function() vlbl:SetAttribute("ThemeColorRole_TextColor3", "White") end)
    vlbl.TextXAlignment = Enum.TextXAlignment.Right
    local bar = Instance.new("Frame")
    bar.Parent = frame
    bar.AnchorPoint = Vector2.new(0.5, 0)
    bar.Position = UDim2.new(0.5, 0, 0, 24)
    bar.Size = UDim2.new(1, -12, 0, 5)
    bar.BackgroundColor3 = T.TgOff; pcall(function() bar:SetAttribute("ThemeColorRole_BackgroundColor3", "TgOff") end)
    bar.BorderSizePixel = 0
    Corner(bar, 3)
    local fill = Instance.new("Frame")
    fill.Parent = bar
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = T.White; pcall(function() fill:SetAttribute("ThemeColorRole_BackgroundColor3", "White") end)
    fill.BorderSizePixel = 0
    Corner(fill, 3)
    local handle = Instance.new("Frame")
    handle.Parent = bar
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.Position = UDim2.new(0, 0, 0.5, 0)
    handle.Size = UDim2.new(0, 13, 0, 13)
    handle.BackgroundColor3 = T.White; pcall(function() handle:SetAttribute("ThemeColorRole_BackgroundColor3", "White") end)
    handle.BorderSizePixel = 0
    Corner(handle, 7)
    Stroke(handle, T.BG, 2, 0)
    local val = def
    local function upd(v)
        local pct = math.clamp((v - min) / (max - min), 0, 1)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        handle.Position = UDim2.new(pct, 0, 0.5, 0)
        vlbl.Text = tostring(v)
    end
    upd(val)
    local active = false
    local function fromMouse(input)
        local bp = bar.AbsolutePosition
        local bs = bar.AbsoluteSize
        local pct = math.clamp((input.Position.X - bp.X) / bs.X, 0, 1)
        local nv = math.floor(min + (max - min) * pct + 0.5)
        if nv ~= val then
            val = nv
            upd(val)
            callback(val)
        end
    end
    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            active = true
            fromMouse(i)
        end
    end)
    tc(UIS.InputChanged:Connect(function(i)
        if active and i.UserInputType == Enum.UserInputType.MouseMovement then
            fromMouse(i)
        end
    end))
    tc(UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            active = false
        end
    end))
    table.insert(UIRegistry, { label = string.lower(label), row = frame, card = parent.Parent })
    table.insert(ConfigControls, {
        id = _cfgId(parent, label),
        get = function() return val end,
        set = function(v)
            v = tonumber(v); if not v then return end
            val = math.clamp(math.floor(v + 0.5), min, max)
            upd(val); pcall(callback, val)
        end,
    })
end
local function mkCycle(parent, label, options, default, callback, order)
    local row = Instance.new("Frame")
    row.Name = label
    row.Parent = parent
    row.LayoutOrder = order
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundTransparency = 1
    Corner(row, 6)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = row
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 6, 0, 0)
    lbl.Size = UDim2.new(1, -136, 1, 0)
    lbl.Font = F
    lbl.TextSize = 13
    lbl.TextColor3 = T.Tx2; lbl:SetAttribute("ThemeColorRole_TextColor3", "Tx2"); pcall(function() lbl:SetAttribute("ThemeColorRole_TextColor3", "Tx2") end)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = label
    local btn = Instance.new("TextButton")
    btn.Parent = row
    btn.AnchorPoint = Vector2.new(1, 0.5)
    btn.Position = UDim2.new(1, -6, 0.5, 0)
    btn.Size = UDim2.new(0, 120, 0, 22)
    btn.BackgroundColor3 = T.Elev; pcall(function() btn:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Font = FM
    btn.TextSize = 12
    btn.TextColor3 = T.Tx; pcall(function() btn:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
    Corner(btn, 6)
    Stroke(btn, T.Bd2, 1, 0.4)
    local idx = 1
    for i, o in ipairs(options) do if o == default then idx = i break end end
    local function apply(fire)
        btn.Text = tostring(options[idx])
        if fire then callback(options[idx]) end
    end
    apply(false)
    btn.MouseButton1Click:Connect(function()
        SFX.Click()
        idx = idx % #options + 1
        apply(true)
    end)
    btn.MouseButton2Click:Connect(function()
        SFX.Click()
        idx = (idx - 2) % #options + 1
        apply(true)
    end)
    btn.MouseEnter:Connect(function()
        TweenService.Create(TweenService, btn, TweenInfo.new(0.12), { BackgroundColor3 = T.Hover }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService.Create(TweenService, btn, TweenInfo.new(0.12), { BackgroundColor3 = T.Elev }):Play()
    end)
    table.insert(UIRegistry, { label = string.lower(label), row = row, card = parent.Parent })
    table.insert(ConfigControls, {
        id = _cfgId(parent, label),
        get = function() return options[idx] end,
        set = function(v)
            for i, o in ipairs(options) do
                if o == v then idx = i; apply(true); return end
            end
        end,
    })
    return { get = function() return options[idx] end }
end
local function getTarget(arg1, arg2, arg3)
    local fov, priorityRole
    if typeof(arg1) == "Vector3" then
        fov = arg2
        priorityRole = arg3
    else
        fov = arg1
        priorityRole = arg2
    end

    local maxDist = math.huge
    local closestTarget = nil
    local shortestDist = math.huge
    local cam = workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local role = getRole(p)
            if not priorityRole or role == priorityRole then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 and cam and cam:IsA("Camera") then
                    local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local mousePos = UIS:GetMouseLocation()
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < maxDist and dist < shortestDist then
                            shortestDist = dist
                            closestTarget = { player = p, hrp = hrp, char = p.Character }
                        end
                    end
                end
            end
        end
    end

    if not closestTarget and priorityRole then
        return getTarget(fov, nil)
    end

    return closestTarget
end

-- Chams are plain Highlight instances parented directly to whatever they're adorning (character,
-- gun handle, gun-drop part). createHighlight (defined further down, once ChamsOpacity etc. are in
-- scope) creates/reuses/updates one by name; this just tears one down by that same name.
local function removeCham(adornee, name)
    if not adornee then return end
    local hl = adornee:FindFirstChild(name)
    if hl then hl:Destroy() end
end

moveTo = function(targetCF, speed, checkFn, ignoreAutofarmCheck)
    local c = LP.Character; local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    
    local startCF = hrp.CFrame
    local distance = (targetCF.Position - startCF.Position).Magnitude
    
    local segmentDistance = 30
    local segments = math.ceil(distance / segmentDistance)
    local spd = math.max(speed or S.FastAutofarmSpeed or 60, 1)
    local waitTime = segmentDistance / spd
    
    for i = 1, segments do
        if not ignoreAutofarmCheck and not S.FastAutofarm then break end
        if checkFn and not checkFn() then break end
        
        local targetSegmentPos = startCF.Position:Lerp(targetCF.Position, i / segments)
        local dir = targetCF.Position - targetSegmentPos
        local targetSegmentCF
        if dir.Magnitude > 0.01 then
            targetSegmentCF = CFrame.new(targetSegmentPos, targetCF.Position)
        else
            targetSegmentCF = targetCF
        end
        
        -- Noclip character
        for _, pt in pairs(c:GetDescendants()) do
            if pt:IsA("BasePart") then pt.CanCollide = false end
        end
        
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = targetSegmentCF
        
        task.wait(waitTime)
    end
end

-- [Removed old Combat functions]

local function respawnChar()
    local c = LP.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if h then h.Health = 0; Notify("Respawn", "Resetting character", 2)
    else Notify("Respawn", "No character to reset", 2) end
end
local function rejoinServer()
    Notify("Rejoin", "Rejoining this server...", 3)
    pcall(function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end)
end
local function serverHop()
    Notify("Server Hop", "Searching for a new server...", 3)
    task.spawn(function()
        local TS = game:GetService("TeleportService")
        local ok, res = pcall(function()
            return game:GetService("HttpService"):JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if ok and res and res.data then
            for _, srv in ipairs(res.data) do
                if type(srv) == "table" and srv.playing and srv.maxPlayers
                    and srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
                    pcall(function() TS:TeleportToPlaceInstance(game.PlaceId, srv.id, LP) end)
                    return
                end
            end
        end
        Notify("Server Hop", "No server found, retrying default", 3)
        pcall(function() TS:Teleport(game.PlaceId, LP) end)
    end)
end
local function ceilingTP()
    local c = LP.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, 250, 0); Notify("Teleport", "Up 250 studs", 2) end
end

do
    -- Subtab bar setup for Visuals
    local visualsSubTabBar = Instance.new("Frame")
    visualsSubTabBar.Name = "VisualsSubTabBar"
    visualsSubTabBar.LayoutOrder = 0
    visualsSubTabBar.BackgroundTransparency = 1
    visualsSubTabBar.Size = UDim2.new(1, 0, 0, 32)
    visualsSubTabBar.Parent = Pages.Visuals

    local subTabList = Instance.new("UIListLayout")
    subTabList.FillDirection = Enum.FillDirection.Horizontal
    subTabList.SortOrder = Enum.SortOrder.LayoutOrder
    subTabList.Padding = UDim.new(0, 8)
    subTabList.Parent = visualsSubTabBar

    local espBtn = Instance.new("TextButton")
    local envBtn = Instance.new("TextButton")


    local espStroke = mkSubTabBtn(visualsSubTabBar, espBtn, "ESP", 1)
    local envStroke = mkSubTabBtn(visualsSubTabBar, envBtn, "Environment", 2)

    local sec1 = mkSection(Pages.Visuals, "Chams", 1)
    mkToggle(sec1, "Gun", false, function(v) S.GunHeldChams = v end, 1)
    mkToggle(sec1, "Role Chams", false, function(v) S.RoleChams = v end, 2)
    mkSlider(sec1, "Chams Opacity", 0, 100, 50, function(v) S.ChamsOpacity = v end, 3)

    local sec2 = mkSection(Pages.Visuals, "Player ESP", 2)
    mkToggle(sec2, "Name ESP", false, function(v) S.NameESP = v end, 1)
    mkToggle(sec2, "Distance ESP", false, function(v) S.DistanceESP = v end, 2)
    mkToggle(sec2, "Role ESP", false, function(v) S.RoleESP = v end, 3)
    mkToggle(sec2, "Health ESP", false, function(v) S.HealthESP = v end, 4)
    mkToggle(sec2, "Box ESP", false, function(v) S.BoxESP = v end, 5)
    mkToggle(sec2, "Box Fill", false, function(v) S.BoxFillESP = v end, 6)
    mkToggle(sec2, "Health Bar", false, function(v) S.HealthBarESP = v end, 7)
    mkToggle(sec2, "Tracers", false, function(v) S.TracerESP = v end, 8)
    mkToggle(sec2, "Head Dot", false, function(v) S.HeadDot = v end, 9)
    mkCycle(sec2, "Tracer Origin", {"Bottom", "Center", "Top", "Mouse"}, "Bottom", function(v) S.TracerOrigin = v end, 10)
    mkSlider(sec2, "ESP Max Dist", 100, 2000, 1000, function(v) S.ESPMaxDist = v end, 11)

    local sec3 = mkSection(Pages.Visuals, "Item ESP", 3)
    mkToggle(sec3, "Gun Drop ESP", false, function(v) S.GunChams = v end, 1)
    -- Item Chams styling: shared by the ground Gun Drop highlight above and the "Gun" held-highlight
    -- in the Chams section — both are the same gun item, so one Mode/Color/Rainbow set covers both.
    mkCycle(sec3, "Item Cham Mode", {"Outline", "Fill", "Both"}, "Outline", function(v) S.ItemChamsMode = v end, 2)
    mkCycle(sec3, "Item Cham Color", {"White", "Red", "Green", "Blue", "Yellow", "Cyan", "Purple", "Orange", "Pink", "Black"}, "Cyan", function(v) S.ItemChamsColor = v end, 3)
    mkToggle(sec3, "Item Cham Rainbow", false, function(v) S.ItemChamsRainbow = v end, 4)

    local sec5 = mkSection(Pages.Visuals, "Alerts", 4)
    mkToggle(sec5, "Gun Drop Notify", false, function(v) S.GunNotify = v end, 1)

    local secFov = mkSection(Pages.Visuals, "FOV", 5)
    mkToggle(secFov, "FOV Enabled", false, function(v) S.FOVEnabled = v end, 1)
    mkToggle(secFov, "Show FOV", false, function(v) S.ShowFOV = v end, 2)
    mkToggle(secFov, "Rainbow FOV", false, function(v) S.RainbowFOV = v end, 3)
    mkSlider(secFov, "FOV Radius", 30, 360, 360, function(v) S.FOVRadius = v end, 4)
    mkSlider(secFov, "FOV Thickness", 1, 8, 2, function(v) S.FOVThickness = v end, 5)
    mkCycle(secFov, "FOV Color", {"White", "Red", "Green", "Blue", "Yellow", "Cyan", "Purple", "Orange", "Pink", "Black"}, "White", function(v) S.FOVColor = v end, 6)

    -- Environment components
    local sec4 = mkSection(Pages.Visuals, "World", 6)
    mkToggle(sec4, "Fullbright", false, function(v) S.FullBright = v end, 1)
    mkToggle(sec4, "No Fog", false, function(v) S.NoFog = v end, 2)
    mkToggle(sec4, "Force Day", false, function(v)
        S.ForceDay = v; if v then S.ForceNight = false end
    end, 3)
    mkToggle(sec4, "Force Night", false, function(v)
        S.ForceNight = v; if v then S.ForceDay = false end
    end, 4)
    mkToggle(sec4, "No Shadows", false, function(v) S.NoShadows = v end, 5)
    mkSlider(sec4, "Brightness", 1, 5, 2, function(v) S.Brightness = v end, 6)

    local secFx = mkSection(Pages.Visuals, "Effects", 7)
    mkSlider(secFx, "Saturation", -100, 100, 0, function(v) S.Saturation = v end, 1)
    mkSlider(secFx, "Contrast", -100, 100, 0, function(v) S.Contrast = v end, 2)
    mkSlider(secFx, "Camera FOV", 40, 120, 70, function(v) S.CamFOV = v end, 3)

    local secCrosshair = mkSection(Pages.Visuals, "Custom Crosshair", 8)
    mkToggle(secCrosshair, "Enable Crosshair", false, function(v) S.Crosshair = v; rebuildCrosshair() end, 1)
    mkCycle(secCrosshair, "Crosshair Shape", {"Cross", "X", "Dot", "Circle", "Heart"}, "Cross", function(v) S.CrosshairShape = v; rebuildCrosshair() end, 2)
    mkCycle(secCrosshair, "Crosshair Color", {"Cyan", "Red", "Green", "Yellow", "Pink", "White", "Purple", "Orange", "Blue", "Rainbow"}, "Cyan", function(v) S.CrosshairColor = v; rebuildCrosshair() end, 3)
    mkSlider(secCrosshair, "Crosshair Size", 4, 50, 12, function(v) S.CrosshairSize = v; rebuildCrosshair() end, 4)
    mkSlider(secCrosshair, "Crosshair Thickness", 1, 8, 2, function(v) S.CrosshairThickness = v; rebuildCrosshair() end, 5)
    mkSlider(secCrosshair, "Crosshair Gap", 0, 20, 4, function(v) S.CrosshairGap = v; rebuildCrosshair() end, 6)
    mkSlider(secCrosshair, "Crosshair Rotation", 0, 360, 0, function(v) S.CrosshairRotation = v; rebuildCrosshair() end, 7)

    local secSky = mkSection(Pages.Visuals, "Sky", 9)
    mkToggle(secSky, "Custom Sky", false, function(v) S.SkyEnabled = v end, 1)
    mkCycle(secSky, "Sky Preset", {"Day", "Sunset", "Night", "Aurora", "Space", "Blood", "Toxic", "Ocean", "Sakura", "Midnight", "Storm", "Desert"}, "Day", function(v) S.SkyPreset = v end, 2)
    mkCycle(secSky, "Sky Color", {"Preset", "Blue", "Purple", "Pink", "Cyan", "Orange", "Green", "Red", "White"}, "Preset", function(v) S.SkyTint = v end, 3)
    mkToggle(secSky, "Rainbow Sky", false, function(v) S.SkyRainbow = v end, 4)

    local secFog = mkSection(Pages.Visuals, "Fog", 10)
    mkToggle(secFog, "Custom Fog", false, function(v) S.FogEnabled = v end, 1)
    mkCycle(secFog, "Fog Mode", {"Classic", "Atmosphere"}, "Classic", function(v) S.FogMode = v end, 2)
    mkCycle(secFog, "Fog Color", {"Gray", "White", "Black", "Blue", "Purple", "Pink", "Cyan", "Orange", "Green", "Red"}, "Gray", function(v) S.FogColorName = v end, 3)
    mkSlider(secFog, "Fog Start", 0, 2000, 0, function(v) S.FogStart = v end, 4)
    mkSlider(secFog, "Fog End", 50, 5000, 500, function(v) S.FogEnd = v end, 5)
    mkSlider(secFog, "Fog Density", 5, 95, 40, function(v) S.FogDensity = v end, 6)
    mkToggle(secFog, "Rainbow Fog", false, function(v) S.FogRainbow = v end, 7)

    local secShaders = mkSection(Pages.Visuals, "Shader Presets", 11)
    local SHADER_LIST = {
        "RTX Low", "RTX Medium", "RTX High", "RTX Ultra", "Night Shaders", "Pink Shaders",
        "Cinematic", "Golden Hour", "Arctic", "Neon", "Noir",
    }
    local shaderToggles = {}
    local function clearOtherToggles(exceptName)
        for nm, t in pairs(shaderToggles) do
            if nm ~= exceptName and t.state then
                t.state = false
                t.updateVisuals()
            end
        end
    end
    for i, nm in ipairs(SHADER_LIST) do
        shaderToggles[nm] = mkToggle(secShaders, nm, false, function(v)
            if v then
                clearOtherToggles(nm)
                applyShader(nm)
            elseif S.ActiveShader == nm then
                applyShader("None")
            end
        end, i)
    end
    mkAction(secShaders, "Disable Shaders", function()
        clearOtherToggles(nil)
        applyShader("None")
        Notify("Shaders", "All shaders disabled", 2)
    end, #SHADER_LIST + 1)

    local secHandShaders = mkSection(Pages.Visuals, "Hand Shaders (Self)", 12)
    mkToggle(secHandShaders, "Enable Hand Shader", false, function(v) S.HandShader = v end, 1)
    mkCycle(secHandShaders, "Shader Type", {"Both", "Fill", "Outline", "Mirror", "Bloom", "Maze", "Crystal", "Chrome", "Plasma"}, "Both", function(v) S.HandShaderType = v end, 2)
    mkCycle(secHandShaders, "Apply To", {"Full Body", "Held Item"}, "Full Body", function(v) S.HandTarget = v end, 3)
    mkCycle(secHandShaders, "Color", {"Cyan", "White", "Red", "Green", "Blue", "Yellow", "Purple", "Orange", "Pink", "Black"}, "Cyan", function(v) S.HandColor = v end, 4)
    mkToggle(secHandShaders, "Rainbow", false, function(v) S.HandRainbow = v end, 5)
    mkSlider(secHandShaders, "Fill Opacity", 0, 100, 60, function(v) S.HandFill = v end, 6)

    -- Dual Wield: purely visual — clones whatever's currently in your hand into the OTHER hand too,
    -- welded the same way the real Tool is (mirrored), so it just looks like you're holding two.
    -- Deliberately NOT an arm-stretch/IK trick; the off-hand keeps moving naturally with your
    -- animations, it just now has a weapon rigidly attached to it like the real one is.
    local secDualWield = mkSection(Pages.Visuals, "Dual Wield", 14)
    mkToggle(secDualWield, "Dual Wield", false, function(v) S.DualWield = v end, 1)

    local activeVisualsSubTab = "ESP"
    -- Sections created in OTHER do-blocks further down the file (e.g. the merged World page) register
    -- here through S._RegisterVisualsEnvSection so they participate in the Environment subtab too.
    local extraEnvSections = {}
    S._RegisterVisualsEnvSection = function(sec)
        table.insert(extraEnvSections, sec)
        if sec and sec.Parent then sec.Parent.Visible = (activeVisualsSubTab == "Environment") end
    end
    local function updateVisualsSubTabs()
        local isESP = (activeVisualsSubTab == "ESP")


        -- Style ESP Button
        espBtn.BackgroundColor3 = isESP and T.ActiveBg or T.Elev
        espBtn.TextColor3 = isESP and T.White or T.Tx2
        espBtn:SetAttribute("ThemeColorRole_BackgroundColor3", isESP and "ActiveBg" or "Elev")
        espBtn:SetAttribute("ThemeColorRole_TextColor3", isESP and "White" or "Tx2")
        espStroke.Color = isESP and T.Accent or T.Bd
        espStroke:SetAttribute("ThemeColorRole_Color", isESP and "Accent" or "Bd")

        -- Style Environment Button
        envBtn.BackgroundColor3 = (not isESP) and T.ActiveBg or T.Elev
        envBtn.TextColor3 = (not isESP) and T.White or T.Tx2
        envBtn:SetAttribute("ThemeColorRole_BackgroundColor3", (not isESP) and "ActiveBg" or "Elev")
        envBtn:SetAttribute("ThemeColorRole_TextColor3", (not isESP) and "White" or "Tx2")
        envStroke.Color = (not isESP) and T.Accent or T.Bd
        envStroke:SetAttribute("ThemeColorRole_Color", (not isESP) and "Accent" or "Bd")

        -- Toggle ESP section visibilities
        if sec1 and sec1.Parent then sec1.Parent.Visible = isESP end
        if sec2 and sec2.Parent then sec2.Parent.Visible = isESP end
        if sec3 and sec3.Parent then sec3.Parent.Visible = isESP end
        if sec5 and sec5.Parent then sec5.Parent.Visible = isESP end
        if secFov and secFov.Parent then secFov.Parent.Visible = isESP end

        -- Toggle Environment section visibilities
        if sec4 and sec4.Parent then sec4.Parent.Visible = not isESP end
        if secFx and secFx.Parent then secFx.Parent.Visible = not isESP end
        if secCrosshair and secCrosshair.Parent then secCrosshair.Parent.Visible = not isESP end
        if secSky and secSky.Parent then secSky.Parent.Visible = not isESP end
        if secFog and secFog.Parent then secFog.Parent.Visible = not isESP end
        if secShaders and secShaders.Parent then secShaders.Parent.Visible = not isESP end
        if secHandShaders and secHandShaders.Parent then secHandShaders.Parent.Visible = not isESP end
        if secDualWield and secDualWield.Parent then secDualWield.Parent.Visible = not isESP end
        for _, s in ipairs(extraEnvSections) do if s and s.Parent then s.Parent.Visible = not isESP end end
    end
    S._UpdateVisualsSubtabs = updateVisualsSubTabs

    espBtn.MouseButton1Click:Connect(function()
        SFX.Click()
        activeVisualsSubTab = "ESP"
        updateVisualsSubTabs()
    end)

    envBtn.MouseButton1Click:Connect(function()
        SFX.Click()
        activeVisualsSubTab = "Environment"
        updateVisualsSubTabs()
    end)

    updateVisualsSubTabs()
end

do
    -- Subtab bar setup
    local combatSubTabBar = Instance.new("Frame")
    combatSubTabBar.Name = "SubTabBar"
    combatSubTabBar.LayoutOrder = 0
    combatSubTabBar.BackgroundTransparency = 1
    combatSubTabBar.Size = UDim2.new(1, 0, 0, 32)
    combatSubTabBar.Parent = Pages.Combat

    local subTabList = Instance.new("UIListLayout")
    subTabList.FillDirection = Enum.FillDirection.Horizontal
    subTabList.SortOrder = Enum.SortOrder.LayoutOrder
    subTabList.Padding = UDim.new(0, 8)
    subTabList.Parent = combatSubTabBar

    local sheriffBtn = Instance.new("TextButton")
    local murderBtn = Instance.new("TextButton")

    local sheriffStroke = mkSubTabBtn(combatSubTabBar, sheriffBtn, "Sheriff", 1)
    local murderStroke = mkSubTabBtn(combatSubTabBar, murderBtn, "Murderer", 2)

    local secSilentAim = mkSection(Pages.Combat, "Silent Aim", 1)
    mkToggle(secSilentAim, "Sheriff", false, function(v) S.SheriffSilentAim = v end, 1)
    mkToggle(secSilentAim, "Piercing Bullet", false, function(v) S.SheriffSilentAimPiercing = v end, 1.5)
    -- Target Role / AimPart / Predict Mode / Prediction pickers were removed on request: any MM2 gun
    -- is a 1-shot kill, so there is nothing to choose. The target is ALWAYS the Murderer (S default),
    -- the aim part is locked to HumanoidRootPart — the biggest, most central hitbox AND the exact
    -- part the velocity history tracks, so the prediction lines up with it perfectly — and the gun's
    -- lead is computed automatically from ping by Silent Aim v2 (the old mode/amount knobs no longer
    -- affected the gun at all; the knife section keeps its own working prediction controls).
    mkToggle(secSilentAim, "Wall Check", false, function(v) S.SheriffSilentAimWallCheck = v end, 2)
    mkToggle(secSilentAim, "FOV Check", true, function(v) S.SheriffSilentAimFOVEnabled = v end, 3)
    -- Trigger Bot: fires the gun for you the instant a valid target lines up in your FOV — you still
    -- aim, this just pulls the trigger. Independent of Silent Aim (works with or without it on).
    mkToggle(secSilentAim, "Trigger Bot", false, function(v) S.TriggerBot = v end, 4)
    -- Shoot bind: a single bindable action (right-click to set a key, same as every action in this
    -- UI) that draws the gun if it's still in your Backpack, then fires once — at the Murderer if
    -- one is found, otherwise wherever your mouse is currently pointing (a normal manual shot).
    mkAction(secSilentAim, "Shoot", function()
        local c = LP.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if not (c and hum and hum.Health > 0) then Notify("Shoot", "No character", 2); return end
        local bp = LP:FindFirstChild("Backpack")
        local gun = c:FindFirstChild("Gun") or (bp and bp:FindFirstChild("Gun"))
        if not gun then Notify("Shoot", "No gun", 2); return end
        task.spawn(function()
            if gun.Parent ~= c then
                pcall(function() hum:EquipTool(gun) end)
                task.wait(0.15) -- let the equip actually attach/replicate before firing
            end
            local hrp = c:FindFirstChild("HumanoidRootPart")
            local shoot = gun:FindFirstChild("Shoot")
            if not (hrp and shoot) then Notify("Shoot", "Gun not ready", 2); return end
            local targetPos
            local murdererChar = S._GetMurdererChar and S._GetMurdererChar()
            if murdererChar then
                local mHrp = murdererChar:FindFirstChild("HumanoidRootPart")
                targetPos = mHrp and mHrp.Position
            end
            if not targetPos then
                local mouse = LP:GetMouse()
                targetPos = mouse and mouse.Hit and mouse.Hit.Position
            end
            if not targetPos then Notify("Shoot", "No target", 2); return end
            local att = hrp:FindFirstChild("GunRaycastAttachment")
            local originCF = att and att.WorldCFrame or CFrame.lookAt(hrp.Position, targetPos)
            pcall(function() shoot:FireServer(originCF, CFrame.new(targetPos)) end)
            if S.CustomShootSound and S._playOnce and S.CustomShootSoundId ~= "" then
                pcall(S._playOnce, S.CustomShootSoundId, 0.6)
            end
        end)
    end, 5)

    local secKnifeDodge = mkSection(Pages.Combat, "Knife Dodge", 3)
    mkToggle(secKnifeDodge, "Knife Dodge", false, function(v) S.KnifeDodge = v end, 1)
    mkSlider(secKnifeDodge, "Dodge Distance", 3, 12, 6, function(v) S.KnifeDodgeDistance = v end, 2)

    local secKnifeCombat = mkSection(Pages.Combat, "Knife Combat & Exploits", 4)
    mkToggle(secKnifeCombat, "Knife Silent Aim", false, function(v) S.KnifeSilentAim = v end, 1)
    mkToggle(secKnifeCombat, "Wall Check", false, function(v) S.KnifeSilentAimWallCheck = v end, 2)
    mkToggle(secKnifeCombat, "FOV Check", false, function(v) S.KnifeSilentAimFOVEnabled = v end, 3)
    mkToggle(secKnifeCombat, "Prioritize Sheriff/Hero", true, function(v) S.KnifeSilentAimPrioritizeSheriff = v end, 4)
    mkToggle(secKnifeCombat, "Fast Knife Throw (No Windup/Animation)", false, function(v)
        S.FastThrow = v
        pcall(function() if S._ReapplyThrowSpeed then S._ReapplyThrowSpeed() end end)
    end, 5)
    mkSlider(secKnifeCombat, "Throw Speed", 1, 10, 6, function(v)
        S.KnifeThrowSpeedControl = true
        S.KnifeThrowWindup = (10 - v) / 10
        pcall(function() if S._ReapplyThrowSpeed then S._ReapplyThrowSpeed() end end)
    end, 6)

    -- ===== Murderer Kill Suite (all built on the proven KnifeStabbed+HandleTouched one-shot; work at
    -- any range, through walls, the instant you hold the Knife) — every kill-related control lives
    -- here now, nothing split off into other sections. =====
    local secMurder = mkSection(Pages.Combat, "Murderer Kill Suite", 5)
    -- Auto Kill Sheriff/Hero: instantly deletes whoever picks up the gun — removes the only threat.
    mkToggle(secMurder, "Auto Kill Sheriff / Hero", false, function(v) S.AutoKillSheriff = v end, 1)
    -- Auto Kill Nearest: continuously kills the closest living player without you doing anything.
    mkToggle(secMurder, "Auto Kill Nearest", false, function(v) S.AutoKillNearest = v end, 2)
    -- Kill Aura: everything within range dies while you just walk around normally.
    mkToggle(secMurder, "Kill Aura", false, function(v) S.KillAura = v end, 3)
    mkSlider(secMurder, "Kill Aura Range", 5, 60, 18, function(v) S.KillAuraRange = v end, 4)
    -- Click to Kill: left-click any player to instantly kill them.
    mkToggle(secMurder, "Click to Kill", false, function(v) S.ClickKill = v end, 5)
    -- One-press actions (bindable via right-click, like every toggle/action in this UI).
    mkAction(secMurder, "Kill Nearest", function()
        local n = S._MurdererNearest and S._MurdererNearest()
        if n and S._MurdererKill then
            if S._MurdererKill(n) then Notify("Murderer", "Killed " .. n.Name, 2)
            else Notify("Murderer", "Hold the Knife first (be the Murderer)", 2) end
        else Notify("Murderer", "No target", 2) end
    end, 6)
    mkAction(secMurder, "Kill All", function()
        if S._MurdererKillAll then S._MurdererKillAll() else Notify("Murderer", "Not ready", 2) end
    end, 7)

    local activeSubTab = "Sheriff"
    local function updateSubTabs()
        local isSheriff = (activeSubTab == "Sheriff")
        local isMurder = (activeSubTab == "Murder")

        styleSubTabActive(sheriffBtn, sheriffStroke, isSheriff)
        styleSubTabActive(murderBtn, murderStroke, isMurder)

        -- Toggle section visibilities
        if secSilentAim and secSilentAim.Parent then
            secSilentAim.Parent.Visible = isSheriff
        end
        if secKnifeDodge and secKnifeDodge.Parent then
            secKnifeDodge.Parent.Visible = isSheriff
        end
        if secKnifeCombat and secKnifeCombat.Parent then
            secKnifeCombat.Parent.Visible = isMurder
        end
        if secMurder and secMurder.Parent then
            secMurder.Parent.Visible = isMurder
        end
    end
    S._UpdateCombatSubtabs = updateSubTabs

    sheriffBtn.MouseButton1Click:Connect(function()
        SFX.Click()
        activeSubTab = "Sheriff"
        updateSubTabs()
    end)

    murderBtn.MouseButton1Click:Connect(function()
        SFX.Click()
        activeSubTab = "Murder"
        updateSubTabs()
    end)

    updateSubTabs()
end
do
    silentAimTargetChar = function(mode, fovCheck, wallCheck, aimPartName)
        local cam = workspace.CurrentCamera
        if not cam then return nil end
        mode = mode or "Nearest"
        local radius = S.FOVRadius or 360
        local m = UIS:GetMouseLocation()
        local center = Vector2.new(m.X, m.Y)
        local best, bestScore = nil, math.huge
        local rp
        if wallCheck then
            rp = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Exclude
            rp.FilterDescendantsInstances = { LP.Character }
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and not isWhitelisted(p) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then continue end
                local head = p.Character:FindFirstChild("Head")
                    or p.Character:FindFirstChild("UpperTorso")
                    or p.Character:FindFirstChild("Torso")
                    or p.Character:FindFirstChild("HumanoidRootPart")
                if not head then continue end
                local r = getRole(p)
                local ok = false
                if mode == "Nearest" then ok = true
                elseif mode == "Murderer" then ok = (r == "Murderer")
                elseif mode == "Sheriff" then ok = (r == "Sheriff")
                elseif mode == "Hero" then ok = (r == "Hero")
                elseif mode == "SheriffOrHero" then ok = (r == "Sheriff" or r == "Hero")
                elseif mode == "Innocent" then ok = (r == "Innocent")
                end
                if not ok then continue end
                local isVisible = true
                if wallCheck and rp and LP.Character and LP.Character:FindFirstChild("Head") then
                    rp.FilterDescendantsInstances = { LP.Character, p.Character }
                    local startPos = LP.Character.Head.Position
                    local dir = head.Position - startPos
                    local ray = workspace:Raycast(startPos, dir, rp)
                    if ray and ray.Instance then isVisible = false end
                end
                if not isVisible then continue end
                local targetPart = head
                if aimPartName == "Closest" then
                    local closestPart, closestPartDist = head, math.huge
                    for _, part in ipairs(p.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            local sp2, on2 = cam:WorldToViewportPoint(part.Position)
                            if on2 then
                                local d = (Vector2.new(sp2.X, sp2.Y) - center).Magnitude
                                if d < closestPartDist then closestPartDist = d; closestPart = part end
                            end
                        end
                    end
                    targetPart = closestPart
                elseif aimPartName == "Random" then
                    local parts = {"Head", "UpperTorso", "Torso", "HumanoidRootPart"}
                    local chosen = parts[math.random(1, #parts)]
                    targetPart = p.Character:FindFirstChild(chosen) or head
                elseif aimPartName then
                    targetPart = p.Character:FindFirstChild(aimPartName)
                        or p.Character:FindFirstChild("Head")
                        or p.Character:FindFirstChild("UpperTorso")
                        or p.Character:FindFirstChild("Torso")
                        or p.Character:FindFirstChild("HumanoidRootPart")
                        or head
                end
                if fovCheck then
                    local sp2, on2 = cam:WorldToViewportPoint(targetPart.Position)
                    if on2 then
                        local d = (Vector2.new(sp2.X, sp2.Y) - center).Magnitude
                        if d < radius and d < bestScore then bestScore = d; best = p.Character end
                    end
                else
                    local lpPart = LP.Character and (LP.Character:FindFirstChild("HumanoidRootPart") or LP.Character:FindFirstChild("Head"))
                    if lpPart then
                        local dist = (targetPart.Position - lpPart.Position).Magnitude
                        if dist < bestScore then bestScore = dist; best = p.Character end
                    end
                end
            end
        end
        return best
    end
end
do
    -- Piercing keeps its server-side point-blank origin, but the game's GunFired beam would otherwise
-- visibly start beside the target. Wrap the existing beam callback and draw that local beam from the
    -- real GunRaycastAttachment instead. This uses the exact GunFired/CreateBeam path from the dump.
    local beamHooks = {}
    local piercingVisualHookReady = false
    S._PiercingVisualHookReady = function() return piercingVisualHookReady end
    local function muzzlePosition()
        local c = LP.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local att = hrp and hrp:FindFirstChild("GunRaycastAttachment")
        return att and att.WorldPosition
    end
    local function installGunBeamHook()
        if not (getconnections and hookfunction) then return end
        local ok, event = pcall(function()
            return game:GetService("ReplicatedStorage"):FindFirstChild("ClientServices", true)
                and game:GetService("ReplicatedStorage").ClientServices:FindFirstChild("GunFired")
        end)
        if not (ok and event and event.OnClientEvent) then return end
        local okConnections, connections = pcall(function() return getconnections(event.OnClientEvent) end)
        if not (okConnections and type(connections) == "table") then return end
        for _, connection in ipairs(connections) do
            local fn = connection and connection.Function
            if fn and not beamHooks[fn] then
                local oldFn
                local wrapper = function(handle, startPos, endPos, hitPart, ...)
                    if S.SheriffSilentAimPiercing and typeof(startPos) == "Vector3" then
                        local origin = muzzlePosition()
                        if origin then return oldFn(handle, origin, endPos, hitPart, ...) end
                    end
                    return oldFn(handle, startPos, endPos, hitPart, ...)
                end
                if newcclosure then wrapper = newcclosure(wrapper) end
                local hooked = pcall(function() oldFn = hookfunction(fn, wrapper) end)
                if hooked and oldFn then
                    beamHooks[fn] = true
                    piercingVisualHookReady = true
                end
            end
        end
    end
    task.spawn(function()
        for _ = 1, 12 do
            pcall(installGunBeamHook)
            if piercingVisualHookReady then break end
            task.wait(0.5)
        end
    end)
end
do
    -- ===== SILENT AIM — dead simple, rebuilt from scratch off the raw Cobalt FireServer dumps =====
    -- Wire format (verified live from the dumps given): Gun.Shoot:FireServer(originCF, targetCF)
    --   arg 1 = HumanoidRootPart.GunRaycastAttachment.WorldCFrame (the muzzle) — LEFT ALONE
    --   arg 2 = GetMouseTargetCFrame(), where the bullet aims — WE REDIRECT THIS
    -- The gun is HITSCAN (no projectile) — the server just raycasts origin -> target. So the entire
    -- Sheriff Silent Aim is: find the alive Murderer, overwrite arg 2 with his position. That's it —
    -- no prediction, no lead time, no FOV/wall gating, no clever origin math. Plainest possible
    -- redirect, matching the exact request: "just find the murderer and shoot him."
    local function getMurdererChar()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and not isWhitelisted(p) and getRole(p) == "Murderer" then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and p.Character:FindFirstChild("HumanoidRootPart") then
                    return p.Character
                end
            end
        end
        return nil
    end
    S._GetMurdererChar = getMurdererChar

    -- Piercing Bullet is a separate, explicitly-requested feature: spawn the bullet point-blank next
    -- to the murderer so the server ray can't be blocked by a wall. Kept minimal, on its own.
    local function piercingOrigin(hitPos, targetChar)
        local hrp = targetChar:FindFirstChild("HumanoidRootPart")
        local vel = hrp and hrp.AssemblyLinearVelocity or Vector3.zero
        local back = (vel.Magnitude > 1.5) and (-vel.Unit * 2) or Vector3.new(0, 1.25, 0)
        return CFrame.lookAt(hitPos + back, hitPos)
    end

    local function handleFireServer(self, ...)
        local args = {...}

        -- ===== GUN: Sheriff Silent Aim — shoots the Murderer, nothing else, no fancy math =====
        if self.Name == "Shoot" and (S.SheriffSilentAim or S.SheriffSilentAimPiercing) then
            local targetChar = getMurdererChar()
            if not targetChar then return nil end
            local hrp = targetChar:FindFirstChild("HumanoidRootPart")
            local pos = hrp.Position
            if S.SheriffSilentAimPiercing then
                args[1] = piercingOrigin(pos, targetChar)
            end
            -- Plain aim: arg 1 (origin) stays exactly what GunClient sent — untouched.
            args[2] = (typeof(args[2]) == "Vector3") and pos or CFrame.new(pos)
            return args
        end

        -- ===== KNIFE: real thrown projectile, keeps its prediction. When "Prioritize Sheriff/Hero" is
        -- on (default), targets the Sheriff (Hero counts as Sheriff — same gun-holding threat) over
        -- anyone else, falling back to Nearest only if no Sheriff/Hero is in range/FOV/visible. When
        -- off, just goes straight for Nearest. =====
        if self.Name == "KnifeThrown" and S.KnifeSilentAim then
            local targetChar = (S.KnifeSilentAimPrioritizeSheriff and silentAimTargetChar("SheriffOrHero", S.KnifeSilentAimFOVEnabled, S.KnifeSilentAimWallCheck, "Head"))
                or silentAimTargetChar("Nearest", S.KnifeSilentAimFOVEnabled, S.KnifeSilentAimWallCheck, "Head")
            if not targetChar then return nil end
            local aimPart = targetChar:FindFirstChild("Head")
                or targetChar:FindFirstChild("UpperTorso")
                or targetChar:FindFirstChild("Torso")
                or targetChar:FindFirstChild("HumanoidRootPart")
            if not aimPart then return nil end
            local pos = getPredictedPosition(
                targetChar, aimPart.Name,
                S.KnifeSilentAimPredictMode or "Perfect",
                S.KnifeSilentAimPrediction or 0, 0, 80)
            args[2] = (typeof(args[2]) == "Vector3") and pos or CFrame.new(pos)
            return args
        end

        return nil
    end

    -- ONE __namecall hook, pcall-protected — deliberately the only hook (two hooks double-processing
    -- the same shot is what ate knife throws before). Re-fires through self.FireServer (method-
    -- independent) rather than oldNamecall, because handleFireServer's own namecalls leave
    -- getnamecallmethod() stale by the time we get here.
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local cc = checkcaller and checkcaller()
            if not cc and getnamecallmethod() == "FireServer" then
                local ok, modArgs = pcall(handleFireServer, self, ...)
                if ok and type(modArgs) == "table" then
                    return self.FireServer(self, table.unpack(modArgs))
                end
                return self.FireServer(self, ...)
            end
            return oldNamecall(self, ...)
        end))
    end

    -- Trigger Bot (Sheriff): fires the gun for you the instant the Murderer lines up under your
    -- crosshair/FOV. This is OUR OWN FireServer call (checkcaller true), so the hook above skips it —
    -- the shot is built directly here, same dead-simple target position, no prediction.
    local lastTriggerShot = 0
    tc(RunService.Heartbeat:Connect(function()
        if not S.TriggerBot then return end
        if (tick() - lastTriggerShot) < 0.4 then return end
        local c = LP.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local gun = c and (c:FindFirstChild("Gun") or (LP.Backpack and LP.Backpack:FindFirstChild("Gun")))
        local shoot = gun and gun:FindFirstChild("Shoot")
        if not (hrp and shoot) then return end
        -- Same FOV/Wall Check toggles as before, hardcoded to the Murderer.
        local targetChar = silentAimTargetChar("Murderer", S.SheriffSilentAimFOVEnabled, S.SheriffSilentAimWallCheck, "HumanoidRootPart")
        if not targetChar then return end
        local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetHrp then return end
        local pos = targetHrp.Position
        lastTriggerShot = tick()
        local originCF
        if S.SheriffSilentAimPiercing then
            originCF = piercingOrigin(pos, targetChar)
        else
            local att = hrp:FindFirstChild("GunRaycastAttachment")
            originCF = att and att.WorldCFrame or CFrame.lookAt(hrp.Position, pos)
        end
        pcall(function() shoot:FireServer(originCF, CFrame.new(pos)) end)
    end))
end

do
    local MSP = {History = {}, Latency = 0}
    S._MSP = MSP
    local function getPing()
        local ping = 0
        pcall(function() ping = LP:GetNetworkPing() * 1000 end)
        return math.clamp(ping, 50, 500)
    end
    tc(RunService.Heartbeat:Connect(function()
        MSP.Latency = getPing() / 1000
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                local now = tick()
                local entry = MSP.History[p.Name]
                if entry then
                    local dt = now - entry.Time
                    if dt > 0 then
                        local newVel = (hrp.Position - entry.Pos) / dt
                        local prevVel = entry.Vel or newVel
                        local rawAcc = (newVel - prevVel) / dt
                        local prevAcc = entry.Acc or Vector3.new()
                        local smoothAcc = prevAcc:Lerp(rawAcc, 0.3)
                        MSP.History[p.Name] = { Pos = hrp.Position, Time = now, Vel = newVel, Acc = smoothAcc }
                    end
                else
                    MSP.History[p.Name] = { Pos = hrp.Position, Time = now, Vel = Vector3.new(), Acc = Vector3.new() }
                end
            end
        end
        -- Flying knife CHAMS only here; the speed control moved to its own Stepped connection below
        -- (physics-synced, right before each physics step) so it reliably wins against the game's own
        -- velocity updates instead of fighting them a frame late on Heartbeat.
        for _, v in ipairs(workspace:GetChildren()) do
            if v.Name == "Knife" or v.Name == "NormalKnife" or v.Name == "ThrowingKnife" then
                local h = v:FindFirstChild("Handle") or v:FindFirstChild("KnifeVisual") or v:FindFirstChildWhichIsA("BasePart")
                if h and not h.Anchored then
                    if S.KnifeChams then
                        createHighlight(v, Color3.fromRGB(255, 0, 0), "KnifeChamsHighlight")
                    else
                        removeCham(v, "KnifeChamsHighlight")
                    end
                end
            end
        end
        -- Fast Throw is handled by the CACHED upvalue controller further down (it scans getgc() once
        -- and re-uses the found closure instead of re-scanning the whole GC heap every frame).
    end))
    getPredictedPosition = function(targetChar, partName, mode, predAmount, customPingOffset, customBulletSpeed)
        local hrp = targetChar:FindFirstChild("HumanoidRootPart")
        local part = targetChar:FindFirstChild(partName)
            or targetChar:FindFirstChild("Head")
            or targetChar:FindFirstChild("UpperTorso")
            or targetChar:FindFirstChild("Torso")
            or hrp
        if not part or not hrp then return Vector3.new() end
        if predAmount == 0 then return part.Position end
        local hist = MSP.History[targetChar.Name]
        local vel = hist and hist.Vel or hrp.AssemblyLinearVelocity
        local ping = MSP.Latency + (customPingOffset or 0)
        local pos = part.Position
        
        if mode == "Standard" then
            return pos + vel * (predAmount / 100)
        elseif mode == "Lag Comp" then
            return pos + vel * ping * (predAmount / 100)
        elseif mode == "Perfect" then
            local acc = hist and hist.Acc or Vector3.new()
            local accMag = acc.Magnitude
            if accMag > 400 then acc = acc * (400 / accMag) end
            
            local t = (ping + (1 / 60)) * (predAmount / 100)
            if customBulletSpeed and customBulletSpeed > 0 then
                local shooterHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if shooterHrp then
                    local dist = (pos - shooterHrp.Position).Magnitude
                    t = t + (dist / customBulletSpeed)
                end
            end
            local predictedPos = pos + vel * t + 0.5 * acc * t * t
            
            -- Apply gravity compensation if target is in the air
            local hum = targetChar:FindFirstChildOfClass("Humanoid")
            if hum and hum.FloorMaterial == Enum.Material.Air then
                predictedPos = predictedPos - Vector3.new(0, 0.5 * workspace.Gravity * t * t, 0)
            end
            return predictedPos
        end
        return pos
    end
end
do
    -- Subtab bar (same pattern as Combat): Movement holds the movement-tweak sections built in this
    -- do-block (plus Movement Tricks, registered later via the bridge below); Targets holds player
    -- selection + the target-dependent Fun actions (Fling/Teleport/Orbit/Sit/Bang), moved here from
    -- Combat since they're Motion/Fun features, not Combat ones.
    local motionSubTabBar = Instance.new("Frame")
    motionSubTabBar.Name = "SubTabBar"
    motionSubTabBar.LayoutOrder = 0
    motionSubTabBar.BackgroundTransparency = 1
    motionSubTabBar.Size = UDim2.new(1, 0, 0, 32)
    motionSubTabBar.Parent = Pages.Motion

    local motionSubTabList = Instance.new("UIListLayout")
    motionSubTabList.FillDirection = Enum.FillDirection.Horizontal
    motionSubTabList.SortOrder = Enum.SortOrder.LayoutOrder
    motionSubTabList.Padding = UDim.new(0, 8)
    motionSubTabList.Parent = motionSubTabBar

    local moveBtn = Instance.new("TextButton")
    local targetsBtn = Instance.new("TextButton")
    local moveStroke = mkSubTabBtn(motionSubTabBar, moveBtn, "Movement", 1)
    local targetsStroke = mkSubTabBtn(motionSubTabBar, targetsBtn, "Targets", 2)
    local activeMotionSubTab = "Movement"

    local sec1 = mkSection(Pages.Motion, "Speed & Jump", 1)
    mkSlider(sec1, "WalkSpeed", 16, 100, 16, function(v) S.CustomWalkSpeed = v end, 1)
    mkSlider(sec1, "JumpPower", 50, 150, 50, function(v) S.CustomJumpPower = v end, 2)
    local sec2 = mkSection(Pages.Motion, "Movement", 2)
    mkToggle(sec2, "No Clip", false, function(v) S.NoClip = v end, 1)
    mkToggle(sec2, "Fly", false, function(v)
        S.Fly = v
        if not v then local c = LP.Character; if c then local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp then for _, n in ipairs({"FlyBV","FlyBG"}) do local x = hrp:FindFirstChild(n); if x then x:Destroy() end end
                hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero end
            local h = c:FindFirstChildOfClass("Humanoid"); if h then h.PlatformStand = false end
        end end
    end, 2)
    mkSlider(sec2, "Fly Speed", 10, 200, 50, function(v) S.FlySpeed = v end, 3)
    -- Pixel Surf: real surf physics — WASD air-strafe (camera-relative) builds speed, gravity pulls you
    -- down a slope, and when you contact any angled surface your velocity is PROJECTED along it
    -- (Velocity - Normal*Dot(Velocity,Normal)) so you slide/surf instead of stopping. Space = hop.
    mkToggle(sec2, "Pixel Surf", false, function(v) S.PixelSurf = v end, 16)
    mkSlider(sec2, "Surf Speed", 20, 200, 60, function(v) S.SurfSpeed = v end, 17)
    mkSlider(sec2, "Surf Gravity", 0, 200, 80, function(v) S.SurfGravity = v end, 18)
    mkSlider(sec2, "Surf Jump Power", 20, 120, 50, function(v) S.SurfJumpPower = v end, 19)
    mkToggle(sec2, "Infinite Jump", false, function(v) S.InfiniteJump = v end, 4)
    mkToggle(sec2, "Freeze", false, function(v) S.Freeze = v end, 7)
    mkToggle(sec2, "Auto Sprint", false, function(v) S.AutoSprint = v end, 8)
    mkToggle(sec2, "Walk On Water", false, function(v) S.WalkOnWater = v end, 9)
    mkToggle(sec2, "Bhop", false, function(v) S.Bhop = v end, 10)
    mkSlider(sec2, "Bhop Max Speed", 16, 200, 28, function(v) S.BhopMax = v end, 11)
    mkToggle(sec2, "Speed Glitch", false, function(v) S.SpeedGlitch = v end, 12)
    mkSlider(sec2, "Air Speed", 20, 150, 50, function(v) S.AirSpeed = v end, 13)
    mkToggle(sec2, "Fake Lag", false, function(v) S.FakeLag = v end, 14)
    mkSlider(sec2, "Fake Lag Limit", 5, 60, 15, function(v) S.FakeLagLimit = v end, 15)

    -- ---- Motion subtab visibility ----
    -- Movement Tricks (built in the later Fun-module do-block) and the Targets sections (Manual
    -- Target + Target Actions, also built later — moved here from Combat) register through these
    -- bridge functions, same pattern as Combat/Misc/Teleport use for their own merged-in pages.
    local motionMovementSections = {}
    local motionTargetsSections = {}
    S._RegisterMotionMovementSection = function(sec)
        table.insert(motionMovementSections, sec)
        if sec and sec.Parent then sec.Parent.Visible = (activeMotionSubTab == "Movement") end
    end
    S._RegisterMotionTargetsSection = function(sec)
        table.insert(motionTargetsSections, sec)
        if sec and sec.Parent then sec.Parent.Visible = (activeMotionSubTab == "Targets") end
    end
    local function updateMotionSubTabs()
        local isMove = (activeMotionSubTab == "Movement")
        local isTargets = (activeMotionSubTab == "Targets")
        styleSubTabActive(moveBtn, moveStroke, isMove)
        styleSubTabActive(targetsBtn, targetsStroke, isTargets)
        if sec1 and sec1.Parent then sec1.Parent.Visible = isMove end
        if sec2 and sec2.Parent then sec2.Parent.Visible = isMove end
        for _, s in ipairs(motionMovementSections) do if s and s.Parent then s.Parent.Visible = isMove end end
        for _, s in ipairs(motionTargetsSections) do if s and s.Parent then s.Parent.Visible = isTargets end end
    end
    S._UpdateMotionSubtabs = updateMotionSubTabs
    moveBtn.MouseButton1Click:Connect(function()
        SFX.Click()
        activeMotionSubTab = "Movement"
        updateMotionSubTabs()
    end)
    targetsBtn.MouseButton1Click:Connect(function()
        SFX.Click()
        activeMotionSubTab = "Targets"
        updateMotionSubTabs()
    end)
    updateMotionSubTabs()

    -- Tick-based Fake Lag loop (tracked via tc() so a re-execute can't leave a stale
    -- connection anchoring the character forever).
    local fakeLagTicks = 0
    task.spawn(function()
        tc(RunService.Heartbeat:Connect(function()
            if S.FakeLag then
                local c = LP.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    fakeLagTicks = fakeLagTicks + 1
                    local limit = S.FakeLagLimit or 15
                    if fakeLagTicks >= limit then
                        hrp.Anchored = false
                        fakeLagTicks = 0
                    else
                        hrp.Anchored = true
                    end
                end
            else
                fakeLagTicks = 0
                local c = LP.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Anchored then
                    hrp.Anchored = false
                end
            end
        end))
    end)
    do
        -- Knife Dodge v2: the old version just nudged you 3.5 studs straight away from the knife EVERY
        -- single frame it was within range — a twitchy little shuffle, and blind to geometry (it could
        -- just as easily shuffle you behind a barrier or into a corner as away from danger).
        -- Now: ONE decisive juke (cooldown-gated, no more frame-by-frame twitching), in whichever
        -- direction actually has the most open space — tried perpendicular to the knife's real travel
        -- direction first (a proper side-step off its flight line, not just "back away from where it
        -- currently is"), then straight-away, each raycast-checked so it can't throw you into a wall.
        local knifeHistory = {}
        local lastDodgeTime = 0
        tc(RunService.Heartbeat:Connect(function()
            if not (S.KnifeDodge and getRole(LP) ~= "Murderer") then return end
            local c = LP.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if not (hrp and hum and hum.Health > 0) then return end

            local now = tick()
            if now - lastDodgeTime < 0.6 then return end

            local seen, threatPos, threatDist, threatDir = {}, nil, nil, nil
            for _, child in ipairs(workspace:GetChildren()) do
                if child.Name == "Knife" or child.Name == "NormalKnife" or child.Name == "ThrowingKnife" then
                    seen[child] = true
                    local pos
                    if child:IsA("BasePart") then
                        pos = child.Position
                    elseif child:IsA("Model") then
                        local ok, cf = pcall(function() return child:GetPivot() end)
                        pos = ok and cf.Position or nil
                    end
                    if pos then
                        local dist = (hrp.Position - pos).Magnitude
                        if dist < 45 and (not threatDist or dist < threatDist) then
                            local hist = knifeHistory[child]
                            threatDir = nil
                            if hist and (now - hist.time) > 0 then
                                local delta = pos - hist.pos
                                if delta.Magnitude > 0.05 then threatDir = delta.Unit end
                            end
                            threatPos, threatDist = pos, dist
                        end
                        local hist = knifeHistory[child]
                        if not hist then hist = {}; knifeHistory[child] = hist end
                        hist.pos, hist.time = pos, now
                    end
                end
            end
            for k in pairs(knifeHistory) do if not seen[k] then knifeHistory[k] = nil end end

            local meleeThreat = false
            if not threatPos then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and getRole(p) == "Murderer" then
                        local mhrp = p.Character:FindFirstChild("HumanoidRootPart")
                        local mhum = p.Character:FindFirstChildOfClass("Humanoid")
                        local hasKnife = p.Character:FindFirstChild("Knife") or p.Character:FindFirstChild("KnifeServer")
                        if mhrp and mhum and mhum.Health > 0 and hasKnife then
                            local dist = (hrp.Position - mhrp.Position).Magnitude
                            if dist < 18 then
                                threatPos = mhrp.Position
                                threatDist = dist
                                threatDir = (hrp.Position - mhrp.Position).Unit
                                meleeThreat = true
                                break
                            end
                        end
                    end
                end
            end

            if not threatPos then return end

            local away = hrp.Position - threatPos
            away = Vector3.new(away.X, 0, away.Z)
            if away.Magnitude < 0.05 then away = hrp.CFrame.LookVector end
            away = away.Unit

            local candidates = { away }
            if threatDir then
                local flat = Vector3.new(threatDir.X, 0, threatDir.Z)
                if flat.Magnitude > 0.05 then
                    flat = flat.Unit
                    local perp = Vector3.new(-flat.Z, 0, flat.X)
                    table.insert(candidates, 1, perp)
                    table.insert(candidates, 2, -perp)
                end
            end

            local rp = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Exclude
            rp.FilterDescendantsInstances = { c }

            local DODGE_DIST = S.KnifeDodgeDistance or 8
            if DODGE_DIST < 8 then DODGE_DIST = 8 end
            local bestDir, bestClear = nil, -1
            for _, dir in ipairs(candidates) do
                local hit = workspace:Raycast(hrp.Position, dir * DODGE_DIST, rp)
                local clear = hit and hit.Distance or DODGE_DIST
                if clear > bestClear then bestDir, bestClear = dir, clear end
            end
            bestDir = bestDir or away

            lastDodgeTime = now
            local travel = math.clamp(bestClear - 1.5, 3.5, DODGE_DIST)
            local newPos = hrp.Position + bestDir * travel
            local groundHit = workspace:Raycast(newPos + Vector3.new(0, 3, 0), Vector3.new(0, -6, 0), rp)
            local landY = groundHit and (groundHit.Position.Y + 3) or hrp.Position.Y
            hrp.CFrame = CFrame.new(newPos.X, landY, newPos.Z) * (hrp.CFrame - hrp.CFrame.Position)
            Notify("Knife Dodge", "Evaded threat! (" .. math.floor(travel) .. " studs)", 1.5)
        end))
    end

    -- Subtab bar (same pattern as Combat): splits Misc's many sections into 3 groups.
    local miscSubTabBar = Instance.new("Frame")
    miscSubTabBar.Name = "SubTabBar"
    miscSubTabBar.LayoutOrder = 0
    miscSubTabBar.BackgroundTransparency = 1
    miscSubTabBar.Size = UDim2.new(1, 0, 0, 32)
    miscSubTabBar.Parent = Pages.Misc

    local miscSubTabList = Instance.new("UIListLayout")
    miscSubTabList.FillDirection = Enum.FillDirection.Horizontal
    miscSubTabList.SortOrder = Enum.SortOrder.LayoutOrder
    miscSubTabList.Padding = UDim.new(0, 8)
    miscSubTabList.Parent = miscSubTabBar

    local protectionBtn, utilityBtn = Instance.new("TextButton"), Instance.new("TextButton")
    local protectionStroke = mkSubTabBtn(miscSubTabBar, protectionBtn, "Protection", 1, 1/2, -4)
    local utilityStroke = mkSubTabBtn(miscSubTabBar, utilityBtn, "Utility", 2, 1/2, -4)

    local miscGroups = { Protection = {}, Utility = {} }
    local activeMiscSubTab = "Protection"
    S._RegisterMiscSection = function(sec, group)
        table.insert(miscGroups[group], sec)
        if sec and sec.Parent then sec.Parent.Visible = (activeMiscSubTab == group) end
    end
    local function updateMiscSubTabs()
        styleSubTabActive(protectionBtn, protectionStroke, activeMiscSubTab == "Protection")
        styleSubTabActive(utilityBtn, utilityStroke, activeMiscSubTab == "Utility")
        for group, secs in pairs(miscGroups) do
            for _, sec in ipairs(secs) do
                if sec and sec.Parent then sec.Parent.Visible = (activeMiscSubTab == group) end
            end
        end
    end
    S._UpdateMiscSubtabs = updateMiscSubTabs
    protectionBtn.MouseButton1Click:Connect(function() SFX.Click(); activeMiscSubTab = "Protection"; updateMiscSubTabs() end)
    utilityBtn.MouseButton1Click:Connect(function() SFX.Click(); activeMiscSubTab = "Utility"; updateMiscSubTabs() end)
    -- Apply the initial tab state immediately; otherwise Roblox's default TextButton
    -- background remains gray until the first click.
    updateMiscSubTabs()

    local sec3 = mkSection(Pages.Misc, "Camera", 3)
    S._RegisterMiscSection(sec3, "Protection")
    mkToggle(sec3, "X-Ray Map", false, function(v) S.XrayOn = v
        for _, pt in pairs(workspace:GetDescendants()) do if pt:IsA("BasePart") and pt.Name ~= "Baseplate" then
            local pr = pt.Parent; if pr and not pr:FindFirstChild("Humanoid") then
                if v then if not S.OriginalTransparencies[pt] then S.OriginalTransparencies[pt] = pt.Transparency end; pt.Transparency = 0.7
                else if S.OriginalTransparencies[pt] then pt.Transparency = S.OriginalTransparencies[pt] end end
            end
        end end
    end, 1)
    mkToggle(sec3, "Camera Clip", false, function(v) S.CamClip = v
        LP.DevCameraOcclusionMode = v and Enum.DevCameraOcclusionMode.Invisicam or Enum.DevCameraOcclusionMode.Zoom
    end, 2)
    mkToggle(sec3, "No Camera Limit", false, function(v) S.NoCamLimit = v
        LP.CameraMaxZoomDistance = v and 100000 or _origMaxZoom
    end, 3)
    local sec4 = mkSection(Pages.Misc, "Protection", 4)
    S._RegisterMiscSection(sec4, "Protection")
    mkToggle(sec4, "Anti-Fling", false, function(v) S.AntiFling = v end, 1)
    mkToggle(sec4, "Anti-Void", false, function(v) S.AntiVoid = v end, 2)
    mkToggle(sec4, "Anti-AFK", false, function(v) S.AntiAFK = v end, 3)
    mkToggle(sec4, "Auto Respawn", false, function(v) S.AutoRespawn = v end, 4)
    mkToggle(sec4, "Anti Ragdoll", false, function(v) S.AntiRagdoll = v end, 5)
    -- Auto Evade: if the Murderer gets within range, instantly hop yourself a safe distance away.
    mkToggle(sec4, "Auto Evade", false, function(v) S.AutoEvade = v end, 6)
    mkSlider(sec4, "Auto Evade Range", 10, 60, 25, function(v) S.AutoEvadeRange = v end, 7)
    local sec6 = mkSection(Pages.Misc, "Performance", 5)
    S._RegisterMiscSection(sec6, "Protection")
    mkToggle(sec6, "Anti Lag", false, function(v) S.AntiLag = v end, 1)

    local sec5 = mkSection(Pages.Misc, "Utility", 7)
    S._RegisterMiscSection(sec5, "Utility")
    mkAction(sec5, "Reset Character", function() respawnChar() end, 1)
    mkAction(sec5, "Ceiling Teleport", function() ceilingTP() end, 2)
    mkAction(sec5, "Rejoin Server", function() rejoinServer() end, 3)
    mkAction(sec5, "Server Hop", function() serverHop() end, 4)
    mkToggle(sec5, "Auto Grab Gun", false, function(v)
        S.AutoGrabGun = v
        -- Start an immediate scan when enabled; the frame loop is started by the grab helper
        -- once that helper has been defined below in the script.
        if v and S.GrabGunNow then S.GrabGunNow(true) end
    end, 5)
    -- Right-click this action and press any keyboard key to bind an instant gun pickup.
    mkAction(sec5, "Grab Gun Now", function()
        if S.GrabGunNow then S.GrabGunNow(false) end
    end, 6)

    -- Custom Goto Player row
    local row = Instance.new("Frame")
    row.Parent = sec5
    row.LayoutOrder = 7
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundTransparency = 1
    Corner(row, 6)
    
    local lbl = Instance.new("TextLabel")
    lbl.Parent = row
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 6, 0, 0)
    lbl.Size = UDim2.new(0, 80, 1, 0)
    lbl.Font = F
    lbl.TextSize = 13
    lbl.TextColor3 = T.Tx2; lbl:SetAttribute("ThemeColorRole_TextColor3", "Tx2"); pcall(function() lbl:SetAttribute("ThemeColorRole_TextColor3", "Tx2") end)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = "Goto Player:"
    
    local box = Instance.new("TextBox")
    box.Parent = row
    box.Position = UDim2.new(0, 90, 0.5, -10)
    box.Size = UDim2.new(1, -150, 0, 20)
    box.BackgroundColor3 = T.Elev; pcall(function() box:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
    box.BorderSizePixel = 0
    box.Font = F
    box.TextSize = 12
    box.TextColor3 = T.Tx; pcall(function() box:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
    box.PlaceholderText = "Player name..."
    box.PlaceholderColor3 = T.Tx4
    box.Text = ""
    box.ClearTextOnFocus = false
    box.TextXAlignment = Enum.TextXAlignment.Left
    Corner(box, 4)
    Stroke(box, T.Bd2, 1, 0.5)
    Pad(box, 0, 0, 6, 6)
    
    local btn = Instance.new("TextButton")
    btn.Parent = row
    btn.AnchorPoint = Vector2.new(1, 0.5)
    btn.Position = UDim2.new(1, -6, 0.5, 0)
    btn.Size = UDim2.new(0, 48, 0, 20)
    btn.BackgroundColor3 = T.Elev; pcall(function() btn:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
    btn.BorderSizePixel = 0
    btn.Font = FM
    btn.TextSize = 12
    btn.TextColor3 = T.Tx; pcall(function() btn:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
    btn.Text = "Go"
    btn.AutoButtonColor = false
    Corner(btn, 4)
    Stroke(btn, T.Bd2, 1, 0.5)
    
    btn.MouseEnter:Connect(function()
        TweenService.Create(TweenService, btn, TweenInfo.new(0.1), { BackgroundColor3 = T.Hover }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService.Create(TweenService, btn, TweenInfo.new(0.1), { BackgroundColor3 = T.Elev }):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        local text = box.Text:lower()
        if text == "" then return end
        local found = nil
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and string.find(p.Name:lower(), text, 1, true) then
                found = p
                break
            end
        end
        if found and found.Character and found.Character:FindFirstChild("HumanoidRootPart") then
            local c = LP.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = found.Character.HumanoidRootPart.CFrame + Vector3.new(0,0,3)
                -- Keep following continuously afterward, reusing the Follow/Orbit system above (same
                -- Follow Distance / Travel Speed sliders control it) instead of a single one-off hop.
                for k in pairs(S.ManualTargets) do S.ManualTargets[k] = nil end
                S.ManualTargets[found.Name] = true
                S.FollowTarget = true
                pcall(function() if S._StartFollowTarget then S._StartFollowTarget() end end)
                Notify("Goto", "Following " .. found.Name, 2)
            end
            else
                Notify("Goto", "Player not found", 2)
            end
        end)

    local secSocial = mkSection(Pages.Misc, "Social & HUD", 8)
    S._RegisterMiscSection(secSocial, "Utility")
    mkToggle(secSocial, "Auto Say GG", false, function(v) S.AutoGG = v end, 2)
    mkToggle(secSocial, "Use Custom Phrase", false, function(v) S.UseCustomGG = v end, 3)
    
    local rowGG = Instance.new("Frame")
    rowGG.Parent = secSocial
    rowGG.LayoutOrder = 4
    rowGG.Size = UDim2.new(1, 0, 0, 30)
    rowGG.BackgroundTransparency = 1
    Corner(rowGG, 6)
    
    local lblGG = Instance.new("TextLabel")
    lblGG.Parent = rowGG
    lblGG.BackgroundTransparency = 1
    lblGG.Position = UDim2.new(0, 6, 0, 0)
    lblGG.Size = UDim2.new(0, 110, 1, 0)
    lblGG.Font = F
    lblGG.TextSize = 13
    lblGG.TextColor3 = T.Tx2; pcall(function() lblGG:SetAttribute("ThemeColorRole_TextColor3", "Tx2") end)
    lblGG.TextXAlignment = Enum.TextXAlignment.Left
    lblGG.Text = "Custom GG Phrase:"
    
    local boxGG = Instance.new("TextBox")
    boxGG.Parent = rowGG
    boxGG.Position = UDim2.new(0, 120, 0.5, -10)
    boxGG.Size = UDim2.new(1, -126, 0, 20)
    boxGG.BackgroundColor3 = T.Elev; pcall(function() boxGG:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
    boxGG.BorderSizePixel = 0
    boxGG.Font = F
    boxGG.TextSize = 12
    boxGG.TextColor3 = T.Tx; pcall(function() boxGG:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
    boxGG.PlaceholderText = "GG!"
    boxGG.PlaceholderColor3 = T.Tx4
    boxGG.Text = S.CustomGGText or "GG!"
    boxGG.ClearTextOnFocus = false
    boxGG.TextXAlignment = Enum.TextXAlignment.Left
    Corner(boxGG, 4)
    Stroke(boxGG, T.Bd2, 1, 0.5)
    Pad(boxGG, 0, 0, 6, 6)
    boxGG:GetPropertyChangedSignal("Text"):Connect(function()
        S.CustomGGText = boxGG.Text
        pcall(function() if S._RequestAutoSave then S._RequestAutoSave() end end)
    end)
    -- Unlike mkToggle/mkSlider (which auto-register), this raw TextBox never had a ConfigControls
    -- entry, so buildConfig() never saved it and applyConfig() had nothing to restore it from — the
    -- toggle for Auto Say GG persisted fine, but the phrase itself reset to "GG!" every launch.
    local secAIChat = mkSection(Pages.Misc, "AI Chat", 8.5)
    S._RegisterMiscSection(secAIChat, "Utility")
    
    mkToggle(secAIChat, "AI Chat Enabled", false, function(v) S.AIChatEnabled = v end, 1)
    mkCycle(secAIChat, "AI Provider", {"DeepSeek", "Groq", "Gemini"}, "DeepSeek", function(v)
        S.AIChatProvider = v
        pcall(function() S._ClearAIChatHistory() end)
    end, 1.5)

    local rowAPI = Instance.new("Frame")
    rowAPI.Parent = secAIChat
    rowAPI.LayoutOrder = 2
    rowAPI.Size = UDim2.new(1, 0, 0, 30)
    rowAPI.BackgroundTransparency = 1
    Corner(rowAPI, 6)
    
    local lblAPI = Instance.new("TextLabel")
    lblAPI.Parent = rowAPI
    lblAPI.BackgroundTransparency = 1
    lblAPI.Position = UDim2.new(0, 6, 0, 0)
    lblAPI.Size = UDim2.new(0, 110, 1, 0)
    lblAPI.Font = F
    lblAPI.TextSize = 13
    lblAPI.TextColor3 = T.Tx2; pcall(function() lblAPI:SetAttribute("ThemeColorRole_TextColor3", "Tx2") end)
    lblAPI.TextXAlignment = Enum.TextXAlignment.Left
    lblAPI.Text = "API Key:"
    
    local boxAPI = Instance.new("TextBox")
    boxAPI.Parent = rowAPI
    boxAPI.Position = UDim2.new(0, 120, 0.5, -10)
    boxAPI.Size = UDim2.new(1, -126, 0, 20)
    boxAPI.BackgroundColor3 = T.Elev; pcall(function() boxAPI:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
    boxAPI.BorderSizePixel = 0
    boxAPI.Font = F
    boxAPI.TextSize = 12
    boxAPI.TextColor3 = T.Tx; pcall(function() boxAPI:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
    boxAPI.PlaceholderText = "Paste API Key..."
    boxAPI.PlaceholderColor3 = T.Tx4
    boxAPI.Text = S.AIChatAPIKey or ""
    boxAPI.ClearTextOnFocus = false
    boxAPI.TextXAlignment = Enum.TextXAlignment.Left
    Corner(boxAPI, 4)
    Stroke(boxAPI, T.Bd2, 1, 0.5)
    Pad(boxAPI, 0, 0, 6, 6)
    boxAPI:GetPropertyChangedSignal("Text"):Connect(function()
        S.AIChatAPIKey = boxAPI.Text
        pcall(function() if S._RequestAutoSave then S._RequestAutoSave() end end)
    end)
    table.insert(ConfigControls, {
        id = "Misc/AIChat/APIKey",
        get = function() return S.AIChatAPIKey end,
        set = function(v) S.AIChatAPIKey = tostring(v); boxAPI.Text = S.AIChatAPIKey end,
    })
    table.insert(ConfigControls, {
        id = "Misc/AIChat/Provider",
        get = function() return S.AIChatProvider end,
        set = function(v) S.AIChatProvider = tostring(v) end,
    })
    table.insert(ConfigControls, {
        id = "Misc/AIChat/ResponseChance",
        get = function() return S.AIChatResponseChance end,
        set = function(v) S.AIChatResponseChance = tonumber(v) or 100 end,
    })
    table.insert(ConfigControls, {
        id = "Misc/AIChat/RespondToAll",
        get = function() return S.AIChatRespondToAll end,
        set = function(v) S.AIChatRespondToAll = (v == true) end,
    })

    mkToggle(secAIChat, "Respond to All Messages", false, function(v)
        S.AIChatRespondToAll = v
        if v then S.AIChatTriggerMode = "All Messages" end
        pcall(function() S._ClearAIChatHistory() end)
    end, 2.5)

    mkCycle(secAIChat, "Trigger Mode", {"Mention", "All Messages", "Question Only"}, "Mention", function(v)
        S.AIChatTriggerMode = v
        if v == "All Messages" then S.AIChatRespondToAll = true else S.AIChatRespondToAll = false end
        pcall(function() S._ClearAIChatHistory() end)
    end, 3)
    mkSlider(secAIChat, "AI Cooldown", 0, 30, 10, function(v) S.AIChatCooldown = v end, 4)
    mkCycle(secAIChat, "AI Personality", {"Friendly", "Cheeky Slang", "Kawaii Anime", "Nerd"}, "Friendly", function(v)
        S.AIChatPersonality = v
        pcall(function() S._ClearAIChatHistory() end)
    end, 5)
    mkSlider(secAIChat, "AI Response Chance (%)", 0, 100, 100, function(v) S.AIChatResponseChance = v end, 6)

    -- AI Chat Logic
    do
        local chatHistory = {}
        local lastAIChatTime = 0

        S._ClearAIChatHistory = function()
            chatHistory = {}
        end

        local function say(message)
            if not message or message == "" then return end
            message = message:gsub('^"(.*)"$', '%1'):gsub("^'(.*)'$", '%1')
            local sent = false
            pcall(function()
                local TextChatService = game:GetService("TextChatService")
                local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral") 
                    or TextChatService.TextChannels:FindFirstChildWhichIsA("TextChannel")
                if channel then
                    channel:SendAsync(message)
                    sent = true
                end
            end)
            if not sent then
                pcall(function()
                    local sayRemote = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents") 
                        and game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
                    if sayRemote then
                        sayRemote:FireServer(message, "All")
                        sent = true
                    end
                end)
            end
        end

        local aiRequestInProgress = false
        local function makeAIRequest(apiKey, history)
            local req = (syn and syn.request) or (http and http.request) or request
            if not req then return nil, "No HTTP request function found in executor" end
            
            local messages = {}
            local systemPrompt = "You are '" .. LP.Name .. "', a real human Roblox player in a Murder Mystery 2 match. You are chatting naturally in the server chat with other players.\n"
            systemPrompt = systemPrompt .. "RULES:\n"
            systemPrompt = systemPrompt .. "- Talk like a real Roblox player. Be natural and conversational.\n"
            systemPrompt = systemPrompt .. "- NEVER act like an AI, bot, assistant, or support helper. Never say 'how can I help', 'as an AI', or 'don't worry'.\n"
            systemPrompt = systemPrompt .. "- If anyone asks who you are or what model you run (кто ты, какая модель), reply strictly that you are 'super ultra sigma rizz premium VIP' (or in Russian 'супер ультра сигма ризз премиум ВИП') with something funny like 'skibidi giga chad status'.\n"
            systemPrompt = systemPrompt .. "- If prompt has Russian letters (Cyrillic), respond strictly in Russian. Если пишут на русском, отвечай СТРОГО на русском! Otherwise, respond in English.\n"

            local personality = S.AIChatPersonality or "Friendly"
            if personality == "Cheeky Slang" then
                systemPrompt = systemPrompt .. "\nPERSONALITY (Cheeky Slang): Cocky and funny Roblox player. Uses gamer slang naturally ('ez', 'nah', 'L', 'cooked', 'ratio', 'rizz', 'sigma'). Playful trash-talker."
            elseif personality == "Kawaii Anime" then
                systemPrompt = systemPrompt .. "\nPERSONALITY (Kawaii Anime): Cute anime girl waifu gamer. Speaks sweetly, uses cute expressions naturally ('uwu', 'nya~', 'senpai', 'desu'). Fun, cute, and sweet."
            elseif personality == "Nerd" then
                systemPrompt = systemPrompt .. "\nPERSONALITY (Nerd): Analytical and super smart MM2 expert. Gives exact game details, coordinates, map statistics, and strategy.\n"
                
                -- Live Game Context for Nerd personality
                local active = isRoundActive()
                if active then
                    local mapName = "Unknown Map"
                    local normal = workspace:FindFirstChild("Normal")
                    if normal then
                        for _, child in ipairs(normal:GetChildren()) do
                            if child:IsA("Model") and child.Name ~= "CoinContainer" then
                                mapName = child.Name
                                break
                            end
                        end
                    end
                    
                    local murderer = "Unknown"
                    local sheriff = "Unknown"
                    local gunHolder = "Unknown"
                    local alivePlayers = {}
                    local deadPlayers = {}
                    
                    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                        local char = p.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        local isAlive = (hum and hum.Health > 0)
                        
                        local role = RoleCache[p.Name] or "Innocent"
                        if role == "Murderer" then
                            murderer = p.Name
                        elseif role == "Sheriff" then
                            sheriff = p.Name
                        elseif role == "Hero" then
                            gunHolder = p.Name
                        end
                        
                        if isAlive then
                            table.insert(alivePlayers, p.Name)
                        else
                            table.insert(deadPlayers, p.Name)
                        end
                    end
                    
                    local gd = workspace:FindFirstChild("GunDrop") or workspace:FindFirstChild("GunDrop", true)
                    local gunDropped = (gd ~= nil)
                    local gunPos = nil
                    if gd then
                        if gd:IsA("BasePart") then
                            gunPos = gd.Position
                        else
                            local bp = gd:FindFirstChildWhichIsA("BasePart", true)
                            if bp then gunPos = bp.Position end
                        end
                    end
                    
                    local matchContext = "\nLIVE MM2 GAME TELEMETRY:\n"
                    matchContext = matchContext .. "- Active Map: " .. mapName .. "\n"
                    matchContext = matchContext .. "- Your Username: " .. LP.Name .. " (Role: " .. (RoleCache[LP.Name] or "Innocent") .. ")\n"
                    matchContext = matchContext .. "- Murderer: " .. murderer .. "\n"
                    matchContext = matchContext .. "- Sheriff: " .. sheriff .. "\n"
                    if gunHolder ~= "Unknown" then
                        matchContext = matchContext .. "- Gun Holder (Hero/Sheriff): " .. gunHolder .. "\n"
                    end
                    if gunDropped then
                        matchContext = matchContext .. "- Gun Dropped: YES at Position "
                        if gunPos then
                            matchContext = matchContext .. string.format("Vector3.new(%.1f, %.1f, %.1f)", gunPos.X, gunPos.Y, gunPos.Z)
                        else
                            matchContext = matchContext .. "Unknown"
                        end
                        matchContext = matchContext .. "\n"
                    else
                        matchContext = matchContext .. "- Gun Dropped: NO\n"
                    end
                    matchContext = matchContext .. "- Alive Players: " .. table.concat(alivePlayers, ", ") .. "\n"
                    matchContext = matchContext .. "- Dead Players: " .. table.concat(deadPlayers, ", ") .. "\n"
                    
                    systemPrompt = systemPrompt .. matchContext .. "If asked about the murderer, sheriff, or gun location, provide the exact telemetry data above in Nerd style.\n"
                end
            else
                systemPrompt = systemPrompt .. "\nPERSONALITY (Friendly): Friendly, casual Roblox teammate. Positive, direct, and fun."
            end

            table.insert(messages, {
                role = "system",
                content = systemPrompt
            })

            for _, msg in ipairs(history) do
                table.insert(messages, msg)
            end

            local provider = S.AIChatProvider or "DeepSeek"

            if provider == "Gemini" then
                local contents = {}
                for _, msg in ipairs(history) do
                    table.insert(contents, {
                        role = (msg.role == "assistant") and "model" or "user",
                        parts = { { text = msg.content } },
                    })
                end
                local geminiBody = game:GetService("HttpService"):JSONEncode({
                    contents = contents,
                    systemInstruction = { parts = { { text = systemPrompt } } },
                    generationConfig = { maxOutputTokens = 150, temperature = 0.7 },
                })
                local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=" .. apiKey
                local success, response = pcall(function()
                    return req({
                        Url = url,
                        Method = "POST",
                        Headers = { ["Content-Type"] = "application/json" },
                        Body = geminiBody,
                    })
                end)
                if success and response then
                    if response.StatusCode == 200 then
                        local ok, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(response.Body) end)
                        local text = ok and decoded and decoded.candidates and decoded.candidates[1]
                            and decoded.candidates[1].content and decoded.candidates[1].content.parts
                            and decoded.candidates[1].content.parts[1] and decoded.candidates[1].content.parts[1].text
                        if text then return text end
                    else
                        return nil, "Gemini Status " .. tostring(response.StatusCode)
                    end
                end
                return nil, "Gemini Request failed"
            end

            local url, model
            if provider == "Groq" then
                url = "https://api.groq.com/openai/v1/chat/completions"
                model = "llama-3.3-70b-versatile"
            else
                url = "https://api.deepseek.com/v1/chat/completions"
                model = "deepseek-chat"
            end

            local body = game:GetService("HttpService"):JSONEncode({
                model = model,
                messages = messages,
                max_tokens = 150,
                temperature = 0.7
            })

            local success, response = pcall(function()
                return req({
                    Url = url,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["Authorization"] = "Bearer " .. apiKey
                    },
                    Body = body
                })
            end)

            if success and response then
                if response.StatusCode == 200 then
                    local ok, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(response.Body) end)
                    if ok and decoded and decoded.choices and decoded.choices[1] and decoded.choices[1].message then
                        return decoded.choices[1].message.content
                    end
                else
                    return nil, provider .. " API Error: Status " .. tostring(response.StatusCode)
                end
            end
            return nil, provider .. " HTTP Request Failed"
        end

        local function processIncomingChatMessage(senderName, text)
            if not S.AIChatEnabled then return end
            if S.Destroyed then return end
            if aiRequestInProgress then return end
            
            -- Ignore empty, very short, or pure punctuation messages (e.g. "." or "...")
            local cleanText = text:gsub("[%s%p]", "")
            if #cleanText < 2 then return end
            
            local apiKey = S.AIChatAPIKey or ""
            if apiKey == "" then
                if not S._warnedMissingAPIKey then
                    S._warnedMissingAPIKey = true
                    Notify("AI Chat", "Please enter an API Key in Misc > AI Chat", 4)
                end
                return
            end
            
            local now = tick()
            local cooldown = S.AIChatCooldown or 10
            if now - lastAIChatTime < cooldown then return end
            
            -- AI Response Chance Check
            local chance = S.AIChatResponseChance or 100
            if math.random(1, 100) > chance then return end
            
            local mode = S.AIChatTriggerMode or "Mention"
            local trigger = false
            local lowerText = text:lower()
            
            if S.AIChatRespondToAll or mode == "All Messages" then
                trigger = true
            elseif mode == "Question Only" then
                if text:sub(-1) == "?" or text:find("?") then
                    trigger = true
                end
            elseif mode == "Mention" then
                if lowerText:find(LP.Name:lower(), 1, true) or lowerText:find("ai", 1, true) or lowerText:find("ии", 1, true) or lowerText:find("бот", 1, true) then
                    trigger = true
                end
            end
            
            if trigger then
                aiRequestInProgress = true
                lastAIChatTime = now
                addToHistory("user", senderName .. ": " .. text)
                
                task.spawn(function()
                    local okRequest, reply, err = pcall(function()
                        return makeAIRequest(apiKey, chatHistory)
                    end)
                    aiRequestInProgress = false -- Always unlock the request queue even if the API call crashed
                    if okRequest and reply then
                        local rep = reply:match("^(.+)%s+%1$") or reply:match("^(.+)%s*%1$")
                        if rep then reply = rep end
                        say(reply)
                    elseif err then
                        Notify("AI Error", tostring(err), 4)
                    end
                end)
            end
        end

        -- Listen for messages
        local TextChatService = game:GetService("TextChatService")
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            tc(TextChatService.MessageReceived:Connect(function(textMessage)
                if S.Destroyed then return end
                local sender = textMessage.TextSource
                if not sender then return end
                local senderName = sender.Name
                if senderName == LP.Name then
                    addToHistory("assistant", textMessage.Text)
                    return
                end
                
                processIncomingChatMessage(senderName, textMessage.Text)
            end))
        else
            local defaultChatEvents = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            local onMessageDoneFiltering = defaultChatEvents and defaultChatEvents:FindFirstChild("OnMessageDoneFiltering")
            if onMessageDoneFiltering then
                tc(onMessageDoneFiltering.OnClientEvent:Connect(function(messageData)
                    if S.Destroyed or not messageData then return end
                    local senderName = messageData.FromSpeaker
                    if senderName == LP.Name then
                        addToHistory("assistant", messageData.Message)
                        return
                    end
                    
                    processIncomingChatMessage(senderName, messageData.Message)
                end))
            end
        end
    end

    -- ===== Sound Mutes =====
    -- MM2 doesn't give sounds tidy names, so each category matches by the Sound's name / SoundId and
    -- the names of its parent objects (e.g. a "Fire" sound inside a "Gun" tool). Muting = force the
    -- Volume to 0 while the toggle is on; the original volume is restored when you turn it back off.
    -- If a sound slips through or the wrong one gets muted, tell me the sound's name and I'll retune
    -- these keyword lists (or add its exact SoundId).
    do
        local muteWords = {
            MuteGun        = { "gun", "revolver", "fire", "shoot", "shot", "bang", "pistol" },
            MuteCoin       = { "coin", "pickup", "collect", "ding", "cash", "gem" },
            MuteKill       = { "death", "die", "dead", "stab", "slash", "knife", "hit", "hurt", "ough", "splat", "kill", "blood",
                               "gib", "corpse", "bodyfall", "body_fall", "thud", "squish", "impale", "scream", "grunt", "pain", "damage", "explo" },
            MuteKillNotify = { "gameover", "game_over", "roundover", "results", "win", "victory", "lose", "defeat", "sheriffwin", "murdererwin" },
            MuteKillEffect = { "ghost", "laser", "fire", "teddy", "slasher", "ice", "freeze", "vampire", "glitch",
                               "radioactive", "ninja", "sparkler", "portal", "blackhole", "tornado", "statue", "gold",
                               "stone", "crystal", "snowman", "pumpkin", "bat", "flame", "soul", "skull", "skeleton",
                               "reaper", "effect", "shatter", "freeze", "burn", "disintegrate" },
        }
        local muted = {}   -- [Sound] = original Volume (only while we've silenced it)
        local function anyMuteOn() return S.MuteGun or S.MuteCoin or S.MuteKill or S.MuteKillNotify or S.MuteKillEffect end
        local function catFor(s)
            local hay = s.Name .. " " .. tostring(s.SoundId)
            local a = s.Parent
            for _ = 1, 3 do if a then hay = hay .. " " .. a.Name; a = a.Parent end end
            hay = hay:lower()
            for cat, words in pairs(muteWords) do
                if S[cat] then
                    for _, w in ipairs(words) do if hay:find(w, 1, true) then return cat end end
                end
            end
            return nil
        end
        local function applyMute(s)
            if not s:IsA("Sound") then return end
            if catFor(s) then
                if muted[s] == nil then muted[s] = s.Volume end
                s.Volume = 0
            elseif muted[s] ~= nil then
                pcall(function() s.Volume = muted[s] end); muted[s] = nil
            end
        end
        local function refreshMutes()
            for _, r in ipairs({ workspace, SoundService, game:GetService("ReplicatedStorage") }) do
                pcall(function()
                    for _, v in ipairs(r:GetDescendants()) do if v:IsA("Sound") then applyMute(v) end end
                end)
            end
            for s, vol in pairs(muted) do
                if not s or not s.Parent or not catFor(s) then
                    pcall(function() if s and s.Parent then s.Volume = vol end end); muted[s] = nil
                end
            end
        end
        -- Silence new sounds the moment they appear (and again when they start playing, in case the
        -- game sets the volume right before Play()).
        tc(game.DescendantAdded:Connect(function(v)
            if v:IsA("Sound") and anyMuteOn() then
                applyMute(v)
                v.Played:Connect(function() if anyMuteOn() then applyMute(v) end end)
            end
        end))

        local secSnd = mkSection(Pages.Misc, "Sound Mutes", 9)
        S._RegisterMiscSection(secSnd, "Utility")
        mkToggle(secSnd, "Mute Gun Sound",     false, function(v) S.MuteGun = v;        refreshMutes() end, 1)
        mkToggle(secSnd, "Mute Coin Sound",    false, function(v) S.MuteCoin = v;       refreshMutes() end, 2)
        mkToggle(secSnd, "Mute Kill Sound",    false, function(v) S.MuteKill = v;       refreshMutes() end, 3)
        mkToggle(secSnd, "Mute Kill Effect Sound", false, function(v) S.MuteKillEffect = v; refreshMutes() end, 4)
        mkToggle(secSnd, "Mute Kill Notify",   false, function(v) S.MuteKillNotify = v; refreshMutes() end, 5)

        local secCustomAudio = mkSection(Pages.Misc, "Custom Audio & Presets", 10)
        S._RegisterMiscSection(secCustomAudio, "Utility")

        -- Custom sound replacements
        local function mkIdBox(parent, label, order, placeholder, getId, setId)
            local row = Instance.new("Frame")
            row.Name = label
            row.Parent = parent
            row.LayoutOrder = order
            row.Size = UDim2.new(1, 0, 0, 30)
            row.BackgroundTransparency = 1
            Corner(row, 6)
            
            local lbl = Instance.new("TextLabel")
            lbl.Parent = row
            lbl.BackgroundTransparency = 1
            lbl.Position = UDim2.new(0, 6, 0, 0)
            lbl.Size = UDim2.new(0.55, -10, 1, 0)
            lbl.Font = F
            lbl.TextSize = 13
            lbl.TextColor3 = T.Tx2; pcall(function() lbl:SetAttribute("ThemeColorRole_TextColor3", "Tx2") end)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Text = label
            
            local box = Instance.new("TextBox")
            box.Parent = row
            box.AnchorPoint = Vector2.new(1, 0.5)
            box.Position = UDim2.new(1, -6, 0.5, 0)
            box.Size = UDim2.new(0.45, 0, 0, 22)
            box.BackgroundColor3 = T.Elev; pcall(function() box:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
            box.BorderSizePixel = 0
            box.Font = F
            box.TextSize = 11
            box.TextColor3 = T.Tx; pcall(function() box:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
            box.PlaceholderText = placeholder
            box.PlaceholderColor3 = T.Tx4
            box.Text = getId() or ""
            box.ClearTextOnFocus = false
            box.TextXAlignment = Enum.TextXAlignment.Center
            Corner(box, 4)
            Stroke(box, T.Bd2, 1, 0.4)
            
            box.FocusLost:Connect(function()
                local t = box.Text:gsub("^%s+", ""):gsub("%s+$", "")
                setId(t)
                pcall(function() if S._RequestAutoSave then S._RequestAutoSave() end end)
            end)
            
            table.insert(ConfigControls, {
                id = _cfgId(parent, label),
                get = function() return getId() end,
                set = function(v) setId(tostring(v)); box.Text = tostring(v) end,
            })
            
            row.MouseEnter:Connect(function()
                TweenService.Create(TweenService, row, TweenInfo.new(0.12), { BackgroundTransparency = 0.8 }):Play()
            end)
            row.MouseLeave:Connect(function()
                TweenService.Create(TweenService, row, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play()
            end)
            
            return box
        end

        local SHOOT_SOUND_PRESETS = {
            { name = "Bell",      id = "rbxassetid://7128958209" },
            { name = "Boink",     id = "rbxassetid://5682262154" },
            { name = "Vine Boom", id = "rbxassetid://5058160717" },
            { name = "Bruh",      id = "rbxassetid://6700501985" },
            { name = "Airhorn",   id = "rbxassetid://6006451857" },
        }
        local WIN_SOUND_PRESETS = {
            { name = "Victory",   id = "rbxassetid://6684542570" },
            { name = "Anime Wow", id = "rbxassetid://2976402600" },
            { name = "Tada",      id = "rbxassetid://7784495221" },
            { name = "Applause",  id = "rbxassetid://9112766203" },
            { name = "Level Up",  id = "rbxassetid://277180368" },
        }

        local function mkSoundPresetCycle(parent, label, order, presets, box, setId)
            local names = {}
            for _, p in ipairs(presets) do table.insert(names, p.name) end
            mkCycle(parent, label, names, names[1], function(name)
                for _, p in ipairs(presets) do
                    if p.name == name then
                        setId(p.id)
                        box.Text = p.id
                        break
                    end
                end
            end, order)
        end

        mkToggle(secCustomAudio, "Murderer Knife Kill Sound", false, function(v) S.CustomKnifeSound = v end, 1)
        mkIdBox(secCustomAudio, "Knife Kill Sound ID", 2, "rbxassetid://...", function() return S.CustomKnifeKillSoundId end, function(id) S.CustomKnifeKillSoundId = id end)

        mkToggle(secCustomAudio, "Sheriff Gun Kill Sound", false, function(v) S.CustomKillSound = v end, 3)
        mkIdBox(secCustomAudio, "Gun Kill Sound ID", 4, "rbxassetid://...", function() return S.CustomKillSoundId end, function(id) S.CustomKillSoundId = id end)

        mkToggle(secCustomAudio, "Custom Shoot Sound (Gun)", false, function(v) S.CustomShootSound = v end, 5)
        local shootIdBox = mkIdBox(secCustomAudio, "Shoot Sound ID", 6, "rbxassetid://...", function() return S.CustomShootSoundId end, function(id) S.CustomShootSoundId = id end)
        mkSoundPresetCycle(secCustomAudio, "Shoot Sound Preset", 7, SHOOT_SOUND_PRESETS, shootIdBox, function(id) S.CustomShootSoundId = id end)

        mkToggle(secCustomAudio, "Murderer Win Sound", false, function(v) S.CustomMurdererWinSound = v end, 8)
        local murdWinIdBox = mkIdBox(secCustomAudio, "Murderer Win Sound ID", 9, "rbxassetid://...", function() return S.CustomMurdererWinSoundId end, function(id) S.CustomMurdererWinSoundId = id end)
        mkSoundPresetCycle(secCustomAudio, "Murd Win Sound Preset", 10, WIN_SOUND_PRESETS, murdWinIdBox, function(id) S.CustomMurdererWinSoundId = id end)

        mkToggle(secCustomAudio, "Sheriff Win Sound", false, function(v) S.CustomSheriffWinSound = v end, 11)
        local sherWinIdBox = mkIdBox(secCustomAudio, "Sheriff Win Sound ID", 12, "rbxassetid://...", function() return S.CustomSheriffWinSoundId end, function(id) S.CustomSheriffWinSoundId = id end)
        mkSoundPresetCycle(secCustomAudio, "Sheriff Win Sound Preset", 13, WIN_SOUND_PRESETS, sherWinIdBox, function(id) S.CustomSheriffWinSoundId = id end)

        mkToggle(secCustomAudio, "Ambient Music", false, function(v)
            S.AmbientMusic = v
            if v then
                if S._StartAmbientMusic then S._StartAmbientMusic() end
            else
                if S._StopAmbientMusic then S._StopAmbientMusic() end
            end
        end, 19)
    end

    -- ===== Kill Effects (visual) =====
    -- Strips the particle / trail / beam / smoke effects that spawn (and linger) when someone is
    -- killed. New effects are disabled the instant they appear; existing ones are swept once when you
    -- turn it on. Turning it off just stops enforcing (already-disabled emitters stay off until they
    -- respawn). Broad by design — MM2 has little decorative particle ambiance to lose.
    do
        local FX_CLASSES = { ParticleEmitter = true, Trail = true, Beam = true, Smoke = true, Fire = true, Sparkles = true }
        local function killFX(v)
            if not S.HideKillFX then return end
            if FX_CLASSES[v.ClassName] then
                pcall(function() v.Enabled = false end)
            elseif v:IsA("Explosion") then
                pcall(function() v.Visible = false; v.BlastPressure = 0; v.BlastRadius = 0 end)
            end
        end
        tc(workspace.DescendantAdded:Connect(function(v) if S.HideKillFX then killFX(v) end end))
        local swept = false
        task.spawn(function()
            while S.Gui and S.Gui.Parent do
                if S.HideKillFX then
                    if not swept then
                        swept = true
                        pcall(function() for _, v in ipairs(workspace:GetDescendants()) do killFX(v) end end)
                    end
                else
                    swept = false
                end
                task.wait(0.5)
            end
        end)

        local secKE = mkSection(Pages.Misc, "Kill Effects", 10)
        S._RegisterMiscSection(secKE, "Utility")
        mkToggle(secKE, "Hide Kill Effects", false, function(v) S.HideKillFX = v end, 1)
    end
end
do
    -- Subtab bar (same pattern as Combat): Teleport / Autofarm merged into one page.
    local teleportSubTabBar = Instance.new("Frame")
    teleportSubTabBar.Name = "SubTabBar"
    teleportSubTabBar.LayoutOrder = 0
    teleportSubTabBar.BackgroundTransparency = 1
    teleportSubTabBar.Size = UDim2.new(1, 0, 0, 32)
    teleportSubTabBar.Parent = Pages.Teleport

    local tpSubTabList = Instance.new("UIListLayout")
    tpSubTabList.FillDirection = Enum.FillDirection.Horizontal
    tpSubTabList.SortOrder = Enum.SortOrder.LayoutOrder
    tpSubTabList.Padding = UDim.new(0, 8)
    tpSubTabList.Parent = teleportSubTabBar

    local teleportBtn = Instance.new("TextButton")
    local autofarmBtn = Instance.new("TextButton")

    local teleportStroke = mkSubTabBtn(teleportSubTabBar, teleportBtn, "Teleport", 1)
    local autofarmStroke = mkSubTabBtn(teleportSubTabBar, autofarmBtn, "Autofarm", 2)

    local teleportSections, autofarmSections = {}, {}
    local activeTpSubTab = "Teleport"
    local function updateTpSubTabs()
        local isTeleport = (activeTpSubTab == "Teleport")
        styleSubTabActive(teleportBtn, teleportStroke, isTeleport)
        styleSubTabActive(autofarmBtn, autofarmStroke, not isTeleport)
        for _, s in ipairs(teleportSections) do if s and s.Parent then s.Parent.Visible = isTeleport end end
        for _, s in ipairs(autofarmSections) do if s and s.Parent then s.Parent.Visible = not isTeleport end end
    end
    -- Autofarm's sections are built in a later do-block, so they register here instead of inline.
    S._RegisterTeleportSection = function(sec)
        table.insert(teleportSections, sec)
        if sec and sec.Parent then sec.Parent.Visible = (activeTpSubTab == "Teleport") end
    end
    S._RegisterAutofarmSection = function(sec)
        table.insert(autofarmSections, sec)
        if sec and sec.Parent then sec.Parent.Visible = (activeTpSubTab == "Autofarm") end
    end
    S._UpdateTeleportSubtabs = updateTpSubTabs
    teleportBtn.MouseButton1Click:Connect(function() SFX.Click(); activeTpSubTab = "Teleport"; updateTpSubTabs() end)
    autofarmBtn.MouseButton1Click:Connect(function() SFX.Click(); activeTpSubTab = "Autofarm"; updateTpSubTabs() end)

    local sec1 = mkSection(Pages.Teleport, "Roles", 1)
    S._RegisterTeleportSection(sec1)
    mkAction(sec1, "Go to Murderer", function()
        for _, p in pairs(Players:GetPlayers()) do if p ~= LP and p.Character and getRole(p) == "Murderer" then
            local pr = p.Character:FindFirstChild("HumanoidRootPart"); if pr then
                local c = LP.Character; if c and c:FindFirstChild("HumanoidRootPart") then
                    c.HumanoidRootPart.CFrame = pr.CFrame + Vector3.new(0,0,3); Notify("Moved","> "..p.Name,2) end; return end end end
        Notify("Notify","Murderer not found",2)
    end, 1)
    mkAction(sec1, "Go to Sheriff", function()
        for _, p in pairs(Players:GetPlayers()) do if p ~= LP and p.Character and (getRole(p) == "Sheriff" or getRole(p) == "Hero") then
            local pr = p.Character:FindFirstChild("HumanoidRootPart"); if pr then
                local c = LP.Character; if c and c:FindFirstChild("HumanoidRootPart") then
                    c.HumanoidRootPart.CFrame = pr.CFrame + Vector3.new(0,0,3); Notify("Moved","> "..p.Name,2) end; return end end end
        Notify("Notify","Sheriff not found",2)
    end, 2)
    local sec2 = mkSection(Pages.Teleport, "Location", 2)
    S._RegisterTeleportSection(sec2)
    mkAction(sec2, "Go to Lobby", function()
        local lb = workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("LobbySpawn")
        if lb then local sp = lb:FindFirstChildOfClass("SpawnLocation") or lb:FindFirstChildOfClass("BasePart")
            if sp then local c = LP.Character; if c and c:FindFirstChild("HumanoidRootPart") then
                c.HumanoidRootPart.CFrame = sp.CFrame + Vector3.new(0,3,0); Notify("Moved","Lobby",2); return end end end
        for _, v in pairs(workspace:GetDescendants()) do if v:IsA("SpawnLocation") then
            local c = LP.Character; if c and c:FindFirstChild("HumanoidRootPart") then
                c.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0,3,0); Notify("Moved","Spawn",2); return end end end
        Notify("Notify","Lobby not found",2)
    end, 1)
    mkAction(sec2, "Go to Map", function()
        -- isRoundActive() (the same round-state check already used by Kill Feed/Auto Dodge Knife) is
        -- only true once a real round is underway — i.e. an actual map is loaded. Without this check,
        -- calling this during intermission/lobby found the lobby's OWN big flat floor (the only large
        -- geometry in workspace at that time — the model is literally named "RegularLobby") and
        -- "teleported to the map" by just moving you a few studs within the same lobby (root cause of
        -- "go to map just teleports around in the lobby").
        if not isRoundActive() then
            Notify("Go to Map", "Still in Lobby - no map loaded yet", 3)
            return
        end
        local c = LP.Character
        if not c or not c:FindFirstChild("HumanoidRootPart") then return end
        local hrp = c.HumanoidRootPart
        local lobbyModel = workspace:FindFirstChild("RegularLobby") or workspace:FindFirstChild("Lobby")
        -- Strategy 1: find the biggest non-Baseplate, non-terrain, non-lobby part in workspace that
        -- looks like map geometry (large size, not a character part, not anchored by a ragdoll).
        local best, bestSize = nil, 0
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Anchored and v ~= workspace.Terrain then
                if not (lobbyModel and v:IsDescendantOf(lobbyModel)) then
                -- skip parts that belong to player characters
                local isChar = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character and v:IsDescendantOf(p.Character) then isChar = true; break end
                end
                if not isChar then
                    local sz = v.Size
                    local vol = sz.X * sz.Y * sz.Z
                    -- prefer large flat parts (floors/ground), skip tiny props
                    if vol > bestSize and sz.X > 8 and sz.Z > 8 and sz.Y < 20 then
                        bestSize = vol; best = v
                    end
                end
                end
            end
        end
        if best then
            -- land on top of the part
            hrp.CFrame = CFrame.new(best.Position + Vector3.new(0, best.Size.Y / 2 + 5, 0))
            Notify("Moved", "Map (" .. best.Name .. ")", 2)
            return
        end
        -- Strategy 2 (fallback): geometric center of ALL alive players (not LP)
        local sum, count = Vector3.zero, 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local pr = p.Character:FindFirstChild("HumanoidRootPart")
                if pr then sum = sum + pr.Position; count = count + 1 end
            end
        end
        if count > 0 then
            hrp.CFrame = CFrame.new(sum / count + Vector3.new(0, 5, 0))
            Notify("Moved", "Map center (avg)", 2)
        else
            Notify("Go to Map", "No reference point found", 2)
        end
    end, 2)
    mkToggle(sec2, "Click TP (press E)", false, function(v) S.ClickTP = v end, 3)
    local sec3 = mkSection(Pages.Teleport, "Players", 3)
    S._RegisterTeleportSection(sec3)
    local pScroll = Instance.new("ScrollingFrame")
    pScroll.Name = "PList"
    pScroll.Parent = sec3
    pScroll.LayoutOrder = 1
    pScroll.BackgroundColor3 = T.Card; pcall(function() pScroll:SetAttribute("ThemeColorRole_BackgroundColor3", "Card") end)
    pScroll.BorderSizePixel = 0
    pScroll.Size = UDim2.new(1, 0, 0, 130)
    pScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    pScroll.ScrollBarThickness = 3
    pScroll.ScrollBarImageColor3 = T.Tx3; pcall(function() pScroll:SetAttribute("ThemeColorRole_ScrollBarImageColor3", "Tx3") end)
    pScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Corner(pScroll, 8)
    Stroke(pScroll, T.Bd, 1, 0.4)
    local pLayout = Instance.new("UIListLayout")
    pLayout.Parent = pScroll
    pLayout.SortOrder = Enum.SortOrder.Name
    pLayout.Padding = UDim.new(0, 4)
    Pad(pScroll, 6, 6, 6, 6)
    local function refreshPL()
        for _, ch in pairs(pScroll:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
        for _, p in pairs(Players:GetPlayers()) do if p ~= LP then
            local b = Instance.new("TextButton")
            b.Name = p.Name
            b.AutoButtonColor = false
            b.BorderSizePixel = 0
            b.Font = F
            b.TextSize = 13
            b.TextColor3 = T.Tx; pcall(function() b:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
            b.BackgroundColor3 = T.Elev; pcall(function() b:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
            b.Size = UDim2.new(1, 0, 0, 32)
            b.Text = "  " .. p.Name
            b.Parent = pScroll
            Corner(b, 6)
            b.MouseEnter:Connect(function()
                TweenService.Create(TweenService, b, TweenInfo.new(0.1), { BackgroundColor3 = T.Hover }):Play()
            end)
            b.MouseLeave:Connect(function()
                TweenService.Create(TweenService, b, TweenInfo.new(0.1), { BackgroundColor3 = T.Elev }):Play()
            end)
            b.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local c = LP.Character; if c and c:FindFirstChild("HumanoidRootPart") then
                        c.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0,0,3)
                        Notify("Moved","> "..p.Name,2)
                    end
                end
            end)
        end end
    end
    refreshPL()
    tc(Players.PlayerAdded:Connect(function() task.wait(1); refreshPL() end))
    tc(Players.PlayerRemoving:Connect(function() task.wait(0.5); refreshPL() end))
    updateTpSubTabs()
end
do
    -- Teleport utilities: waypoint (save/load a position) and a forward blink.
    local savedPos
    local sec = mkSection(Pages.Teleport, "Utility", 4)
    if S._RegisterTeleportSection then S._RegisterTeleportSection(sec) end
    mkAction(sec, "Save Position", function()
        local c = LP.Character; local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if hrp then savedPos = hrp.CFrame; Notify("Teleport", "Position saved", 2)
        else Notify("Teleport", "No character", 2) end
    end, 1)
    mkAction(sec, "Load Position", function()
        if not savedPos then Notify("Teleport", "Nothing saved yet", 2); return end
        local c = LP.Character; local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = savedPos; Notify("Teleport", "Position loaded", 2)
        else Notify("Teleport", "No character", 2) end
    end, 2)
end
-- ============ TARGETS (merged into Combat > Targets subtab: pick one player for Fun functions) ============
do
    local sec1 = mkSection(Pages.Motion, "Manual Target", 4)
    if S._RegisterMotionTargetsSection then S._RegisterMotionTargetsSection(sec1) end
    local info = Instance.new("TextLabel")
    info.Parent = sec1
    info.LayoutOrder = 1
    info.BackgroundTransparency = 1
    info.Size = UDim2.new(1, 0, 0, 52)
    info.Font = F
    info.TextSize = 12
    info.TextColor3 = T.Tx4; pcall(function() info:SetAttribute("ThemeColorRole_TextColor3", "Tx4") end)
    info.TextWrapped = true
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Text = "Left-click = select targets (multi — pick several; Fun & Follow use the NEAREST selected). 'Auto' clears the selection = nearest of all. Right-click = Whitelist (green WL): that player is SKIPPED by Fling, Kill All, and Knife Aura."
    local searchBox = Instance.new("TextBox")
    searchBox.Parent = sec1
    searchBox.LayoutOrder = 2
    searchBox.Size = UDim2.new(1, 0, 0, 30)
    searchBox.BackgroundColor3 = T.Elev; pcall(function() searchBox:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
    searchBox.BorderSizePixel = 0
    searchBox.Font = F
    searchBox.TextSize = 13
    searchBox.TextColor3 = T.Tx; pcall(function() searchBox:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
    searchBox.PlaceholderText = "Search player..."
    searchBox.PlaceholderColor3 = T.Tx4
    searchBox.Text = ""
    searchBox.ClearTextOnFocus = false
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    Corner(searchBox, 6)
    Stroke(searchBox, T.Bd2, 1, 0.4)
    Pad(searchBox, 0, 0, 8, 8)
    local tScroll = Instance.new("ScrollingFrame")
    tScroll.Parent = sec1
    tScroll.LayoutOrder = 3
    tScroll.BackgroundColor3 = T.Card; pcall(function() tScroll:SetAttribute("ThemeColorRole_BackgroundColor3", "Card") end)
    tScroll.BorderSizePixel = 0
    tScroll.Size = UDim2.new(1, 0, 0, 220)
    tScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tScroll.ScrollBarThickness = 3
    tScroll.ScrollBarImageColor3 = T.Tx3; pcall(function() tScroll:SetAttribute("ThemeColorRole_ScrollBarImageColor3", "Tx3") end)
    tScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Corner(tScroll, 8)
    Stroke(tScroll, T.Bd, 1, 0.4)
    local tLayout = Instance.new("UIListLayout")
    tLayout.Parent = tScroll
    tLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tLayout.Padding = UDim.new(0, 4)
    Pad(tScroll, 6, 6, 6, 6)
    local rowRefreshers = {}
    local searchQ = ""
    local function refreshTargets()
        for _, ch in pairs(tScroll:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
        rowRefreshers = {}
        local order = 0
        local ROLE_COLORS = {
            Murderer = Color3.fromRGB(255, 66, 66),
            Sheriff = Color3.fromRGB(66, 140, 255),
            Hero = Color3.fromRGB(255, 224, 66),
            Innocent = Color3.fromRGB(96, 222, 128),
        }
        local function mkRow(labelText, plrName, plr)
            order = order + 1
            local b = Instance.new("TextButton")
            b.Name = plrName or "_Auto"
            b.LayoutOrder = order
            b.AutoButtonColor = false
            b.BorderSizePixel = 0
            b.Font = F
            b.TextSize = 13
            b.TextColor3 = T.Tx; pcall(function() b:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
            b.BackgroundColor3 = T.Elev; pcall(function() b:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
            b.Size = UDim2.new(1, 0, 0, 32)
            b.Text = "  " .. labelText
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.Parent = tScroll
            Corner(b, 6)
            -- Role tag on the right (Murderer/Sheriff/Hero/Innocent), coloured by role. Player rows only.
            local roleLbl = Instance.new("TextLabel")
            roleLbl.Name = "RoleTag"
            roleLbl.Parent = b
            roleLbl.AnchorPoint = Vector2.new(1, 0.5)
            roleLbl.Position = UDim2.new(1, -8, 0.5, 0)
            roleLbl.Size = UDim2.new(0, 80, 0, 16)
            roleLbl.BackgroundTransparency = 1
            roleLbl.Font = FB
            roleLbl.TextSize = 11
            roleLbl.TextColor3 = Color3.fromRGB(170, 170, 170)
            roleLbl.TextXAlignment = Enum.TextXAlignment.Right
            roleLbl.Text = ""
            -- "WL" tag, shown left of the role tag when this player is whitelisted (protected / skipped).
            local wl = Instance.new("TextLabel")
            wl.Name = "WLTag"
            wl.Parent = b
            wl.AnchorPoint = Vector2.new(1, 0.5)
            wl.Position = UDim2.new(1, -92, 0.5, 0)
            wl.Size = UDim2.new(0, 26, 0, 16)
            wl.BackgroundTransparency = 1
            wl.Font = FB
            wl.TextSize = 11
            wl.TextColor3 = Color3.fromRGB(90, 220, 120)
            wl.TextXAlignment = Enum.TextXAlignment.Right
            wl.Text = "WL"
            wl.Visible = false
            -- Multi-select: a player row is "selected" if it's in the ManualTargets set; the Auto row
            -- is "selected" when the set is empty.
            local function isSelected()
                if plrName == nil then return not next(S.ManualTargets) end
                return S.ManualTargets[plrName] == true
            end
            local function isWL() return plrName ~= nil and S.Whitelist[plrName] == true end
            local function refreshVis()
                if isSelected() then
                    b.BackgroundColor3 = T.ActiveBg; pcall(function() b:SetAttribute("ThemeColorRole_BackgroundColor3", "ActiveBg") end); b.TextColor3 = T.White; pcall(function() b:SetAttribute("ThemeColorRole_TextColor3", "White") end)
                elseif isWL() then
                    b.BackgroundColor3 = Color3.fromRGB(26, 44, 32); b.TextColor3 = T.Tx; pcall(function() b:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
                else
                    b.BackgroundColor3 = T.Elev; pcall(function() b:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end); b.TextColor3 = T.Tx; pcall(function() b:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
                end
                wl.Visible = isWL()
                -- live role tag (roles change during a round; the periodic refresh below keeps it current)
                if plr and plr.Parent then
                    local role = getRole and getRole(plr) or nil
                    if role and role ~= "???" then
                        roleLbl.Text = string.upper(role)
                        roleLbl.TextColor3 = ROLE_COLORS[role] or Color3.fromRGB(170, 170, 170)
                    else
                        roleLbl.Text = ""
                    end
                    roleLbl.Position = UDim2.new(1, wl.Visible and -8 or -8, 0.5, 0)
                end
            end
            refreshVis()
            b.MouseEnter:Connect(function()
                -- Only plain rows get the hover tint; selected (blue) and whitelisted (green) rows keep
                -- their colour so it doesn't flicker away on hover.
                if not isSelected() and not isWL() then TweenService.Create(TweenService, b, TweenInfo.new(0.1), { BackgroundColor3 = T.Hover }):Play() end
            end)
            b.MouseLeave:Connect(function() refreshVis() end)
            b.MouseButton1Click:Connect(function()
                SFX.Click()
                if plrName == nil then
                    S.ManualTargets = {}   -- Auto row: clear all selections
                    Notify("Target", "Auto (nearest)", 2)
                else
                    if S.ManualTargets[plrName] then S.ManualTargets[plrName] = nil else S.ManualTargets[plrName] = true end
                    Notify("Target", (S.ManualTargets[plrName] and "Added: " or "Removed: ") .. plrName, 2)
                end
                for _, r in ipairs(rowRefreshers) do r() end
            end)
            -- Right-click toggles the whitelist for this player (not the Auto row).
            if plrName then
                b.MouseButton2Click:Connect(function()
                    SFX.Click()
                    if S.Whitelist[plrName] then S.Whitelist[plrName] = nil else S.Whitelist[plrName] = true end
                    Notify("Whitelist", (S.Whitelist[plrName] and "Protected (skipped): " or "Removed: ") .. plrName, 2)
                    for _, r in ipairs(rowRefreshers) do r() end
                end)
            end
            table.insert(rowRefreshers, refreshVis)
        end
        mkRow("Auto (role / nearest)", nil, nil)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and (searchQ == "" or string.find(string.lower(p.Name), searchQ, 1, true)) then
                mkRow(p.Name, p.Name, p)
            end
        end
    end
    refreshTargets()

    -- Keep the role tags live (roles are handed out mid-round without any player join/leave).
    task.spawn(function()
        while S.Gui and S.Gui.Parent do
            task.wait(1)
            for _, r in ipairs(rowRefreshers) do pcall(r) end
        end
    end)
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        searchQ = string.lower(searchBox.Text)
        refreshTargets()
    end)
    tc(Players.PlayerAdded:Connect(function() task.wait(1); refreshTargets() end))
    tc(Players.PlayerRemoving:Connect(function(p)
        if S.ManualTargets then S.ManualTargets[p.Name] = nil end
        if S.Whitelist then S.Whitelist[p.Name] = nil end
        task.wait(0.5); refreshTargets()
    end))
    table.insert(ConfigControls, {
        id = "Targets/Manual/ManualTargets",
        get = function()
            local list = {}
            for n in pairs(S.ManualTargets) do list[#list + 1] = n end
            return list
        end,
        set = function(v)
            S.ManualTargets = {}
            if type(v) == "table" then
                for _, n in ipairs(v) do if type(n) == "string" then S.ManualTargets[n] = true end end
            end
            refreshTargets()
        end,
    })
end
-- ============ FUN MODULE (swim / walltp / bang / orbit / freecam / invisible / etc.) ============
-- Wrapped in a do-block so its ~35 locals free up after (Luau has a 200-local limit
-- per function); toggle callbacks keep the functions alive via upvalue capture.
do
local function getRoot(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char.PrimaryPart)
end
local function getTorso(char)
    return char and (char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart"))
end
local function isR15(plr)
    local ch = plr and plr.Character
    local h = ch and ch:FindFirstChildOfClass("Humanoid")
    return h and h.RigType == Enum.HumanoidRigType.R15
end
-- Pick a target player: the pick from the Targets tab list wins (the ONLY manual selector);
-- with "Auto" selected we fall back to the nearest alive player.
local function funTarget()
    -- Multi-select: pick the NEAREST alive player among the picked set. Empty set = Auto (nearest of all).
    local myRoot = getRoot(LP.Character)
    local sel = S.ManualTargets
    local picking = next(sel) ~= nil
    local best, bestD
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and (not picking or sel[p.Name]) then
            local r = getRoot(p.Character)
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if r and h and h.Health > 0 then
                local d = myRoot and (r.Position - myRoot.Position).Magnitude or 0
                if not bestD or d < bestD then bestD = d; best = p end
            end
        end
    end
    return best
end

-- Head Sit
local headSitConn
local function stopHeadSit()
    if headSitConn then headSitConn:Disconnect(); headSitConn = nil end
end
local function startHeadSit()
    stopHeadSit()
    local target = funTarget()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if not target or not hum then Notify("Head Sit", "No target", 2); S.HeadSit = false; return end
    hum.Sit = true
    headSitConn = tc(RunService.Heartbeat:Connect(function()
        local tRoot = target.Character and getRoot(target.Character)
        local myRoot = getRoot(LP.Character)
        local myHum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if tRoot and myRoot and myHum and myHum.Sit then
            myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 1.6, 0.4)
        end
    end))
end
-- Orbit
local orbitConns = {}
local function stopOrbit()
    for _, c in pairs(orbitConns) do pcall(function() c:Disconnect() end) end
    orbitConns = {}
end
local function startOrbit()
    stopOrbit()
    local target = funTarget()
    local root = getRoot(LP.Character)
    if not (target and target.Character and getRoot(target.Character) and root) then
        Notify("Orbit", "No target", 2); S.Orbit = false; return
    end
    local rotation = 0
    orbitConns.a = tc(RunService.Heartbeat:Connect(function()
        pcall(function()
            rotation = rotation + (S.OrbitSpeed or 20) / 100
            local troot = getRoot(target.Character)
            if not (troot and root and root.Parent) then return end
            local center = troot.Position + Vector3.new(0, S.OrbitHeight or 0, 0)
            local rad = math.rad(rotation)
            local dist = S.OrbitDist or 6
            local orbitPos = center + Vector3.new(math.cos(rad) * dist, 0, math.sin(rad) * dist)
            root.CFrame = CFrame.lookAt(orbitPos, troot.Position)
        end)
    end))
end
-- Bang
local bangConn, bangTrack, bangAnimInst
local function stopBang()
    if bangConn then bangConn:Disconnect(); bangConn = nil end
    if bangTrack then pcall(function() bangTrack:Stop() end); bangTrack = nil end
    if bangAnimInst then pcall(function() bangAnimInst:Destroy() end); bangAnimInst = nil end
end
local function startBang()
    stopBang()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local target = funTarget()
    bangAnimInst = Instance.new("Animation")
    bangAnimInst.AnimationId = not isR15(LP) and "rbxassetid://148840371" or "rbxassetid://5918726674"
    pcall(function()
        bangTrack = hum:LoadAnimation(bangAnimInst)
        bangTrack:Play(0.1, 1, 1)
        bangTrack:AdjustSpeed(S.BangSpeed or 3)
    end)
    if target and target.Character then
        local offset = CFrame.new(0, 0, 1.1)
        bangConn = tc(RunService.Stepped:Connect(function()
            pcall(function()
                local otherRoot = getTorso(target.Character)
                local myRoot = getRoot(LP.Character)
                if otherRoot and myRoot then myRoot.CFrame = otherRoot.CFrame * offset end
            end)
        end))
    end
end
-- Block Jump: hover your FEET (not your hip/root) just above the target's head, close enough that
-- the instant they try to jump their own head runs into your feet instead of getting anywhere.
--
-- First version placed your HumanoidRootPart itself 0.3 studs above their head — but HRP sits at
-- HIP height, so your actual feet ended up a HipHeight-worth of studs BELOW their head (overlapping
-- their torso, not blocking above it), which is why the jump still went through. Fixed by offsetting
-- up by the local Humanoid's HipHeight so it's your feet, not your hip, that end up at the gap.
--
-- It also only fights this out client-side — an exploit script can't spawn a part the target's own
-- client would ever see or collide with (client-created instances never replicate to other players
-- under FilteringEnabled). YOUR character is the one thing here that genuinely replicates, so it has
-- to be your own body doing the blocking, not a fake invisible part.
--
-- Second version also ragdolled you face-down: forcing CFrame onto an already-overlapping body every
-- physics step fights the Humanoid's own state machine, which was giving up and dropping you into
-- Ragdoll/FallingDown. PlatformStand=true suspends that state machine the same way "Fly" already
-- does elsewhere in this file, so the forced position just holds instead of fighting itself into a
-- flop. Restored back to false on stop so you can walk normally again afterward.
local blockJumpConn
local blockJumpHumanoid
local function stopBlockJump()
    if blockJumpConn then blockJumpConn:Disconnect(); blockJumpConn = nil end
    if blockJumpHumanoid and blockJumpHumanoid.Parent then
        pcall(function() blockJumpHumanoid.PlatformStand = false end)
    end
    blockJumpHumanoid = nil
end
local function startBlockJump()
    stopBlockJump()
    local target = funTarget()
    local root = getRoot(LP.Character)
    local myHum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if not (target and target.Character and getRoot(target.Character) and root and myHum) then
        Notify("Block Jump", "No target", 2); S.BlockJump = false; return
    end
    myHum.PlatformStand = true
    blockJumpHumanoid = myHum
    blockJumpConn = tc(RunService.Stepped:Connect(function()
        pcall(function()
            local tChar = target.Character
            local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
            local tHead = tChar and tChar:FindFirstChild("Head")
            local myRoot = getRoot(LP.Character)
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if tHead and myRoot and hum and tHum and tHum.Health > 0 then
                if not hum.PlatformStand then hum.PlatformStand = true end
                blockJumpHumanoid = hum -- keep pointed at the current (possibly respawned) humanoid
                -- Small fixed gap (not zero) so it isn't literally welded through their skull, but
                -- tight enough that a jump's upward velocity has nowhere to go before it's cancelled.
                local gap = 0.2
                local headTop = tHead.Position.Y + tHead.Size.Y / 2
                local footClearance = (hum.HipHeight or 2) + 1  -- HipHeight + ~half the root's own height
                local pos = Vector3.new(tHead.Position.X, headTop + gap + footClearance, tHead.Position.Z)
                myRoot.CFrame = CFrame.new(pos) * (myRoot.CFrame - myRoot.CFrame.Position)
                myRoot.AssemblyLinearVelocity = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end))
end
-- Jerk
local jerkTool
local function stopJerk()
    if jerkTool then pcall(function() jerkTool:Destroy() end); jerkTool = nil end
end
local function startJerk()
    stopJerk()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    local backpack = LP:FindFirstChildWhichIsA("Backpack")
    if not hum or not backpack then return end
    jerkTool = Instance.new("Tool")
    jerkTool.Name = "Jerk"
    jerkTool.RequiresHandle = false
    jerkTool.Parent = backpack
    local jorkin, track = false, nil
    jerkTool.Equipped:Connect(function() jorkin = true end)
    jerkTool.Unequipped:Connect(function() jorkin = false; if track then pcall(function() track:Stop() end); track = nil end end)
    task.spawn(function()
        while jerkTool and jerkTool.Parent and S.Jerk do
            task.wait()
            if jorkin then
                local isR = isR15(LP)
                if not track then
                    local anim = Instance.new("Animation")
                    anim.AnimationId = not isR and "rbxassetid://72042024" or "rbxassetid://698251653"
                    pcall(function() track = hum:LoadAnimation(anim) end)
                end
                if track then
                    pcall(function()
                        track:Play(); track:AdjustSpeed(isR and 0.7 or 0.65); track.TimePosition = 0.6
                    end)
                    task.wait(0.1)
                    while track and track.TimePosition < (not isR and 0.65 or 0.7) do task.wait(0.1) end
                    if track then pcall(function() track:Stop() end); track = nil end
                end
            end
        end
    end)
end
-- Trip (one-shot)
local function doTrip()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    local root = getRoot(LP.Character)
    if hum and root then
        hum:ChangeState(Enum.HumanoidStateType.FallingDown)
        root.Velocity = root.CFrame.LookVector * 30
    end
end
-- Fake Out (TP to void and back, kills anyone attached / flinging you)
local function doFakeOut()
    task.spawn(function()
        local root = getRoot(LP.Character)
        if not root then return end
        local oldpos = root.CFrame
        local OrgDestroyHeight = workspace.FallenPartsDestroyHeight
        pcall(function() workspace.FallenPartsDestroyHeight = -1e9 end)
        root.CFrame = CFrame.new(Vector3.new(0, OrgDestroyHeight - 10000, 0))
        task.wait(1)
        pcall(function()
            local currentRoot = getRoot(LP.Character)
            if currentRoot then currentRoot.CFrame = oldpos end
        end)
        pcall(function() workspace.FallenPartsDestroyHeight = OrgDestroyHeight end)
        Notify("Fake Out", "Done - attached flingers dropped", 3)
    end)
end
-- Invisible (FE): REAL invisibility — swaps control to a client-side CLONE while your real body freezes
-- on the server, so OTHER players stop seeing your movement. You CANNOT shoot/stab while it's on (the
-- server tracks your frozen body); it's for hiding / escaping — turn it off to fight. Crash-proof:
-- toggling off / dying / falling in the void ALWAYS hands back a real, controllable character, and if
-- the swap-back ever fails it force-respawns you, so you can't get stranded. Wrapped in a do-block so
-- only the two toggle functions are top-level locals (stays under the 200-local limit).
local startInvisibleFE, stopInvisibleFE, toggleInvisible, toggleBlink
do
    local running = false
    local conns = {}
    local realChar, cloneChar = nil, nil
    stopInvisibleFE = function()
        if not running then return end
        running = false
        conns = disconnectAll(conns)
        if toggleInvisible and toggleInvisible.state then
            pcall(function() toggleInvisible.trigger() end)
        end
        local ok = pcall(function()
            local real, clone = realChar, cloneChar
            local cf
            if clone and clone:FindFirstChild("HumanoidRootPart") then cf = clone.HumanoidRootPart.CFrame end
            if real and real:FindFirstChildOfClass("Humanoid") and real:FindFirstChild("HumanoidRootPart") then
                real.Parent = workspace
                if cf then real.HumanoidRootPart.CFrame = cf end
                LP.Character = real
                pcall(function() workspace.CurrentCamera.CameraSubject = real:FindFirstChildOfClass("Humanoid") end)
                pcall(function() real.Animate.Disabled = true; real.Animate.Disabled = false end)
                if clone then clone:Destroy() end
            else
                if clone then pcall(function() clone:Destroy() end) end
                S._resetMyCharacter()
            end
        end)
        realChar, cloneChar = nil, nil
        if not ok then S._resetMyCharacter() end
        Notify("Invisible", "You are visible again", 3)
    end
    startInvisibleFE = function()
        if running then return end
        if toggleBlink and toggleBlink.state then toggleBlink.trigger() end
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not (char and hrp and hum) then Notify("Invisible", "No character", 3); return end
        running = true
        local ok = pcall(function()
            char.Archivable = true
            local cf = hrp.CFrame
            local clone = char:Clone()
            clone.Parent = workspace
            if clone:FindFirstChild("HumanoidRootPart") then clone.HumanoidRootPart.CFrame = cf end
            for _, p in ipairs(clone:GetDescendants()) do
                if p:IsA("BasePart") then p.Transparency = (p.Name == "HumanoidRootPart") and 1 or 0.6 end
            end
            LP.Character = clone
            pcall(function() workspace.CurrentCamera.CameraSubject = clone:FindFirstChildOfClass("Humanoid") end)
            pcall(function() clone.Animate.Disabled = true; clone.Animate.Disabled = false end)
            char.Parent = game:GetService("Lighting")
            realChar, cloneChar = char, clone
            local ch = clone:FindFirstChildOfClass("Humanoid")
            -- Also tracked via tc() (not just the local `conns` table stopInvisibleFE disconnects via
            -- disconnectAll): if the script gets re-injected while Invisible is still ON, nothing
            -- would otherwise call stopInvisibleFE, and this Stepped connection — plus the
            -- leftover clone parented in Lighting — would keep running forever, compounding with every
            -- re-inject during a testing session (the likely source of the reported micro-stutter).
            if ch then table.insert(conns, tc(ch.Died:Connect(function() stopInvisibleFE() end))) end
            local Void = workspace.FallenPartsDestroyHeight
            table.insert(conns, tc(RunService.Stepped:Connect(function()
                local r = cloneChar and cloneChar:FindFirstChild("HumanoidRootPart")
                if r and r.Position.Y <= Void + 5 then stopInvisibleFE() end
            end)))
        end)
        if not ok then
            running = false
            conns = disconnectAll(conns)
            realChar, cloneChar = nil, nil
            S._resetMyCharacter()
            Notify("Invisible", "Failed (game blocks it)", 3)
        else
            Notify("Invisible", "Invisible to others — you CAN'T shoot while on (for hiding)", 4)
        end
    end
end
-- Blink: lag switch clone teleport
local startBlink, stopBlink
do
    local running = false
    local conns = {}
    local realChar, cloneChar = nil, nil
    stopBlink = function()
        if not running then return end
        running = false
        conns = disconnectAll(conns)
        if toggleBlink and toggleBlink.state then
            pcall(function() toggleBlink.trigger() end)
        end
        local ok = pcall(function()
            local real, clone = realChar, cloneChar
            local cf
            if clone and clone:FindFirstChild("HumanoidRootPart") then cf = clone.HumanoidRootPart.CFrame end
            if real and real:FindFirstChildOfClass("Humanoid") and real:FindFirstChild("HumanoidRootPart") then
                real.Parent = workspace
                if cf then real.HumanoidRootPart.CFrame = cf end
                LP.Character = real
                pcall(function() workspace.CurrentCamera.CameraSubject = real:FindFirstChildOfClass("Humanoid") end)
                pcall(function() real.Animate.Disabled = true; real.Animate.Disabled = false end)
                if clone then clone:Destroy() end
            else
                if clone then pcall(function() clone:Destroy() end) end
                S._resetMyCharacter()
            end
        end)
        realChar, cloneChar = nil, nil
        if not ok then S._resetMyCharacter() end
        Notify("Blink", "Blink deactivated", 3)
    end
    startBlink = function()
        if running then return end
        if toggleInvisible and toggleInvisible.state then toggleInvisible.trigger() end
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not (char and hrp and hum) then Notify("Blink", "No character", 3); return end
        running = true
        local ok = pcall(function()
            char.Archivable = true
            local cf = hrp.CFrame
            local clone = char:Clone()
            clone.Parent = workspace
            if clone:FindFirstChild("HumanoidRootPart") then clone.HumanoidRootPart.CFrame = cf end

            LP.Character = clone
            pcall(function() workspace.CurrentCamera.CameraSubject = clone:FindFirstChildOfClass("Humanoid") end)
            pcall(function() clone.Animate.Disabled = true; clone.Animate.Disabled = false end)
            char.Parent = game:GetService("Lighting")
            realChar, cloneChar = char, clone
            local ch = clone:FindFirstChildOfClass("Humanoid")
            if ch then table.insert(conns, tc(ch.Died:Connect(function() stopBlink() end))) end
            local Void = workspace.FallenPartsDestroyHeight
            table.insert(conns, tc(RunService.Stepped:Connect(function()
                local r = cloneChar and cloneChar:FindFirstChild("HumanoidRootPart")
                if r and r.Position.Y <= Void + 5 then stopBlink() end
            end)))
        end)
        if not ok then
            running = false
            conns = disconnectAll(conns)
            realChar, cloneChar = nil, nil
            S._resetMyCharacter()
            Notify("Blink", "Failed to activate Blink", 3)
        else
            Notify("Blink", "Blink active — move to teleport", 4)
        end
    end
end
-- Free Cam (adapted from Infinite Yield)
local startFreecam, stopFreecam
do
    local ContextActionService = game:GetService("ContextActionService")
    local Camera = workspace.CurrentCamera
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        if workspace.CurrentCamera then Camera = workspace.CurrentCamera end
    end)
    local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value
    local fcRunning = false
    local Spring = {}; Spring.__index = Spring
    function Spring.new(freq, pos) return setmetatable({ f = freq, p = pos, v = pos * 0 }, Spring) end
    function Spring:Update(dt, goal)
        local f = self.f * 2 * math.pi
        local p0, v0 = self.p, self.v
        local offset = goal - p0
        local decay = math.exp(-f * dt)
        local p1 = goal + (v0 * dt - offset * (f * dt + 1)) * decay
        local v1 = (f * dt * (offset * f - v0) + v0) * decay
        self.p, self.v = p1, v1
        return p1
    end
    function Spring:Reset(pos) self.p = pos; self.v = pos * 0 end
    local cameraPos, cameraRot, cameraFov = Vector3.new(), Vector2.new(), 70
    local velSpring = Spring.new(5, Vector3.new())
    local panSpring = Spring.new(5, Vector2.new())
    local keyboard = { W = 0, A = 0, S = 0, D = 0, E = 0, Q = 0, Up = 0, Down = 0 }
    local mouseD = Vector2.new()
    local navSpeed = 1
    local NAV_ADJ_SPEED, NAV_SHIFT_MUL = 0.75, 0.25
    local PAN_MOUSE_SPEED = Vector2.new(1, 1) * (math.pi / 64)
    local function InputVel(dt)
        navSpeed = math.clamp(navSpeed + dt * (keyboard.Up - keyboard.Down) * NAV_ADJ_SPEED, 0.01, 4)
        local k = Vector3.new(keyboard.D - keyboard.A, keyboard.E - keyboard.Q, keyboard.S - keyboard.W)
        local shift = UIS:IsKeyDown(Enum.KeyCode.LeftShift)
        return k * (navSpeed * (shift and NAV_SHIFT_MUL or 1))
    end
    local function InputPan() local m = mouseD * PAN_MOUSE_SPEED; mouseD = Vector2.new(); return m end
    local function Keypress(_, state, input)
        keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
        return Enum.ContextActionResult.Sink
    end
    local function MousePan(_, _, input)
        local d = input.Delta; mouseD = Vector2.new(-d.y, -d.x)
        return Enum.ContextActionResult.Sink
    end
    local function GetFocusDistance(cf)
        local znear = 0.1
        local vp = Camera.ViewportSize
        local projy = 2 * math.tan(cameraFov / 2)
        local projx = vp.X / vp.Y * projy
        local fx, fy, fz = cf.RightVector, cf.UpVector, cf.LookVector
        local minVect, minDist = Vector3.new(), 512
        for x = 0, 1, 0.5 do
            for y = 0, 1, 0.5 do
                local cx = (x - 0.5) * projx
                local cy = (y - 0.5) * projy
                local offset = fx * cx - fy * cy + fz
                local origin = cf.Position + offset * znear
                local rp = RaycastParams.new()
                rp.FilterType = Enum.RaycastFilterType.Exclude
                local res = workspace:Raycast(origin, offset.Unit * minDist, rp)
                local hit = res and res.Position or (origin + offset.Unit * minDist)
                local dist = (hit - origin).Magnitude
                if minDist > dist then minDist = dist; minVect = offset.Unit end
            end
        end
        return fz:Dot(minVect) * minDist
    end
    local function StepFreecam(dt)
        local vel = velSpring:Update(dt, InputVel(dt))
        local pan = panSpring:Update(dt, InputPan())
        local zoomFactor = math.sqrt(math.tan(math.rad(70 / 2)) / math.tan(math.rad(cameraFov / 2)))
        cameraRot = cameraRot + pan * Vector2.new(0.75, 1) * 8 * (dt / zoomFactor)
        cameraRot = Vector2.new(math.clamp(cameraRot.X, -math.rad(90), math.rad(90)), cameraRot.Y % (2 * math.pi))
        local cf = CFrame.new(cameraPos) * CFrame.fromOrientation(cameraRot.X, cameraRot.Y, 0) * CFrame.new(vel * 64 * dt)
        cameraPos = cf.Position
        Camera.CFrame = cf
        Camera.Focus = cf * CFrame.new(0, 0, -GetFocusDistance(cf))
        Camera.FieldOfView = cameraFov
    end
    local saved = {}
    startFreecam = function()
        if fcRunning then return end
        local cf = Camera.CFrame
        cameraRot = Vector2.new(); cameraPos = cf.Position; cameraFov = Camera.FieldOfView
        velSpring:Reset(Vector3.new()); panSpring:Reset(Vector2.new())
        saved.fov = Camera.FieldOfView; saved.type = Camera.CameraType
        saved.cf = Camera.CFrame; saved.focus = Camera.Focus
        saved.mib = UIS.MouseBehavior; saved.mie = UIS.MouseIconEnabled
        Camera.FieldOfView = 70; Camera.CameraType = Enum.CameraType.Custom
        UIS.MouseIconEnabled = true; UIS.MouseBehavior = Enum.MouseBehavior.Default
        ContextActionService:BindActionAtPriority("MM2FreecamKb", Keypress, false, INPUT_PRIORITY,
            Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
            Enum.KeyCode.E, Enum.KeyCode.Q, Enum.KeyCode.Up, Enum.KeyCode.Down)
        ContextActionService:BindActionAtPriority("MM2FreecamPan", MousePan, false, INPUT_PRIORITY, Enum.UserInputType.MouseMovement)
        RunService:BindToRenderStep("MM2Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
        fcRunning = true
        Notify("Free Cam", "WASD move, Q/E up-down, Shift slow", 4)
    end
    stopFreecam = function()
        if not fcRunning then return end
        navSpeed = 1
        for k in pairs(keyboard) do keyboard[k] = 0 end
        mouseD = Vector2.new()
        pcall(function() ContextActionService:UnbindAction("MM2FreecamKb") end)
        pcall(function() ContextActionService:UnbindAction("MM2FreecamPan") end)
        pcall(function() RunService:UnbindFromRenderStep("MM2Freecam") end)
        pcall(function()
            Camera.FieldOfView = saved.fov or 70
            Camera.CameraType = saved.type or Enum.CameraType.Custom
            UIS.MouseIconEnabled = saved.mie
            UIS.MouseBehavior = saved.mib or Enum.MouseBehavior.Default
            local c = LP.Character
            if c then Camera.CameraSubject = c:FindFirstChildOfClass("Humanoid") end
        end)
        fcRunning = false
    end
end
do
    local secM = mkSection(Pages.Motion, "Movement Tricks", 3)
    if S._RegisterMotionMovementSection then S._RegisterMotionMovementSection(secM) end

    mkAction(secM, "Trip", function() doTrip() end, 4)
    mkAction(secM, "Fake Out (Flinger Kill)", function() doFakeOut() end, 5)
    local secTr = mkSection(Pages.Motion, "Troll", 12)
    if S._RegisterMotionTargetsSection then S._RegisterMotionTargetsSection(secTr) end
    mkToggle(secTr, "Spinbot", false, function(v) S.Spinbot = v end, 1)
    mkSlider(secTr, "Spin Speed", 5, 1000, 20, function(v) S.SpinSpeed = v end, 2)
    mkToggle(secTr, "Jerk", false, function(v) S.Jerk = v; if v then startJerk() else stopJerk() end end, 3)
    mkToggle(secTr, "Click Fling", false, function(v) S.ClickFling = v end, 4)
    -- ALL fling mechanics below are ported AS LITERALLY AS POSSIBLE from the Infinite Yield reference
    -- file (New Text Document.txt) — two distinct commands, kept distinct here too:
    --   Touch Fling = IY 'fling'     (BodyAngularVelocity spin — launches anyone who touches you)
    --   Walk Fling  = IY 'walkfling' (per-frame Velocity spike, no spin — launches whoever you walk into)
    -- The targeted actions (All/Murderer/Sheriff/Target/Click) reuse the 'fling' spin engine as their
    -- base (the reference has no concept of "fling THIS specific player" — that targeting/homing part
    -- is necessarily this script's own addition on top of the verbatim spin).
    mkToggle(secTr, "Touch Fling", false, function(v)
        S.TouchFling = v
        if S._TouchFlingToggle then S._TouchFlingToggle(v) end
    end, 5)
    mkToggle(secTr, "Walk Fling", false, function(v)
        S.WalkFling = v
        if S._WalkFlingToggle then S._WalkFlingToggle(v) end
    end, 6)
    -- How long each targeted fling (Fling Target / All / Murderer / Sheriff / Click) rides the victim.
    -- Longer = the spin keeps ramming them for more time, so they get launched harder and it doesn't
    -- give up early on a target that's briefly stuck on geometry.
    mkSlider(secTr, "Fling Duration (s)", 1, 15, 6, function(v) S.FlingDuration = v end, 7)
    mkAction(secTr, "Fling All", function() if S._FlingAll then S._FlingAll() end end, 8)
    mkAction(secTr, "Fling Murderer", function() if S._FlingRole then S._FlingRole("Murderer") end end, 9)
    mkAction(secTr, "Fling Sheriff", function() if S._FlingRole then S._FlingRole("Sheriff") end end, 10)
    local secC = mkSection(Pages.Motion, "Camera & Body", 13)
    if S._RegisterMotionTargetsSection then S._RegisterMotionTargetsSection(secC) end
    mkToggle(secC, "Free Cam", false, function(v) S.FreeCam = v; if v then startFreecam() else stopFreecam() end end, 1)
    toggleInvisible = mkToggle(secC, "Invisible (FE)", false, function(v) S.InvisibleFE = v; if v then startInvisibleFE() else stopInvisibleFE() end end, 2)
    toggleBlink = mkToggle(secC, "Blink", false, function(v) S.Blink = v; if v then startBlink() else stopBlink() end end, 3)

    -- NOTE: the old hardcoded "Animations" / "Dance R15" / "Mockery Animation" pack lists lived here.
    -- They were replaced by the Player tab (Emotes + Animations subtabs), which browses Roblox's real
    -- official animation catalog per movement slot (AvatarEditorService:SearchCatalog) instead of a
    -- fixed hardcoded list.

    -- ---- Target Actions live on the TARGETS tab (built here so they can reuse the Fun module's
    -- start/stop helpers + funTarget/skidFling). They all act on the player picked in the Targets
    -- list; with "Auto" selected that resolves to the nearest player.
    local function currentTarget() return funTarget() end
    local secTgt = mkSection(Pages.Motion, "Target Actions", 5)
    if S._RegisterMotionTargetsSection then S._RegisterMotionTargetsSection(secTgt) end
    -- Flings EVERY player selected in the Targets list (multi-select), skipping whitelisted ones.
    mkAction(secTgt, "Fling Target", function()
        task.spawn(function()
            local c = LP.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            if not hrp then Notify("Fling Target", "No character", 3); return end
            local targets = {}
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and S.ManualTargets[p.Name] and not isWhitelisted(p) then
                    local th = p.Character:FindFirstChildOfClass("Humanoid")
                    if th and th.Health > 0 then table.insert(targets, p) end
                end
            end
            if #targets == 0 then Notify("Fling Target", "No targets selected (pick players in the Targets tab)", 3); return end
            local flung = 0
            for _, p in ipairs(targets) do
                local ok, res = pcall(skidFling, p)
                if ok and res then flung = flung + 1 end
                task.wait(0.1)
            end
            Notify("Fling Target", flung > 0 and ("Flung " .. flung .. "/" .. #targets) or "Failed", 3)
        end)
    end, 1)
    -- "TP to Selected Target" / "Goto Target" moved here from the old Manual Target section — same
    -- picked-player logic (currentTarget()/funTarget honors the Targets list selection, or nearest
    -- alive player when nothing's picked), just relocated so all target-driven actions live together.
    mkAction(secTgt, "TP to Selected Target", function()
        local t = currentTarget()
        local troot = t and t.Character and getRoot(t.Character)
        local myroot = getRoot(LP.Character)
        if troot and myroot then
            myroot.CFrame = troot.CFrame * CFrame.new(0, 0, 3)
            Notify("Teleport", "Teleported to " .. t.Name, 2)
        else Notify("Teleport", "No valid target", 2) end
    end, 2)
    local followConnection = nil
    local function startFollowTarget()
        if followConnection then return end
        followConnection = RunService.Heartbeat:Connect(function()
            if not S.FollowTarget then
                if followConnection then followConnection:Disconnect(); followConnection = nil end
                return
            end
            local picked = currentTarget()
            if not picked or not picked.Character then return end
            local tr = picked.Character:FindFirstChild("HumanoidRootPart")
            local th = picked.Character:FindFirstChildOfClass("Humanoid")
            local c = LP.Character
            local mr = c and c:FindFirstChild("HumanoidRootPart")
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if not (tr and th and mr and hum and hum.Health > 0) then return end
            
            local dist = (tr.Position - mr.Position).Magnitude
            if dist > 3 then
                hum.WalkSpeed = S.FollowSpeed or 24
                hum:MoveTo(tr.Position)
            else
                hum:MoveTo(mr.Position)
            end
            
            if S.FollowMirrorActions then
                if th.Jump or th:GetState() == Enum.HumanoidStateType.Jumping then
                    hum.Jump = true
                end
                if th.Sit then
                    hum.Sit = true
                elseif hum.Sit and not th.Sit then
                    hum.Sit = false
                end
            end
        end)
    end
    local function stopFollowTarget()
        if followConnection then
            followConnection:Disconnect()
            followConnection = nil
        end
        pcall(function()
            local c = LP.Character
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = S.WalkSpeed or 16 end
        end)
    end

    S._StartFollowTarget = startFollowTarget
    S._StopFollowTarget = stopFollowTarget
    S.FollowSpeed = 24
    S.FollowMirrorActions = true
    mkToggle(secTgt, "Follow Target", false, function(v)
        S.FollowTarget = v
        if v then startFollowTarget() else stopFollowTarget() end
    end, 3)
    mkSlider(secTgt, "Follow Speed", 16, 120, 24, function(v) S.FollowSpeed = v end, 3.1)
    mkToggle(secTgt, "Mirror Actions (Jumps, etc.)", true, function(v) S.FollowMirrorActions = v end, 3.2)
    mkToggle(secTgt, "Orbit Target", false, function(v) S.Orbit = v; if v then startOrbit() else stopOrbit() end end, 4)
    mkSlider(secTgt, "Orbit Speed", 5, 1000, 20, function(v) S.OrbitSpeed = v end, 5)
    mkSlider(secTgt, "Orbit Distance", 3, 30, 6, function(v) S.OrbitDist = v end, 6)
    mkSlider(secTgt, "Orbit Height", -30, 30, 0, function(v) S.OrbitHeight = v end, 7)
    mkToggle(secTgt, "Sit on Target", false, function(v) S.HeadSit = v; if v then startHeadSit() else stopHeadSit() end end, 8)
    mkToggle(secTgt, "Bang Target", false, function(v) S.Bang = v; if v then startBang() else stopBang() end end, 9)
    mkSlider(secTgt, "Bang Speed", 1, 10, 3, function(v) S.BangSpeed = v end, 10)
    mkToggle(secTgt, "Block Jump", false, function(v) S.BlockJump = v; if v then startBlockJump() else stopBlockJump() end end, 11)
end
end -- end FUN MODULE do-block
local HUD = {}
local HUDEls = {}
local function mkDragHUD(name, pos, size, z)
    local f = Instance.new("Frame")
    f.Name = "HUD_"..name
    f.Parent = SG
    f.Active = true
    f.Position = pos
    f.Size = size
    f.BackgroundColor3 = T.Card; f:SetAttribute("ThemeColorRole_BackgroundColor3", "Card")
    f.BackgroundTransparency = 0.05
    f.BorderSizePixel = 0
    f.Visible = false
    f.ZIndex = z or 850
    Corner(f, 10)
    local fSt = Stroke(f, T.Bd2, 1, 0.35); fSt:SetAttribute("ThemeColorRole_Color", "Bd2")
    Shadow(f, 0.45)
    local tb = Instance.new("Frame")
    tb.Parent = f
    tb.BackgroundColor3 = T.Elev; tb:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev")
    tb.BorderSizePixel = 0
    tb.Size = UDim2.new(1, 0, 0, 26)
    tb.ZIndex = z + 1
    Corner(tb, 8)
    local tbLine = Instance.new("Frame")
    tbLine.Parent = tb
    tbLine.BackgroundColor3 = T.Bd; pcall(function() tbLine:SetAttribute("ThemeColorRole_BackgroundColor3", "Bd") end)
    tbLine.BackgroundTransparency = 0.2
    tbLine.BorderSizePixel = 0
    tbLine.AnchorPoint = Vector2.new(0, 1)
    tbLine.Position = UDim2.new(0, 0, 1, 0)
    tbLine.Size = UDim2.new(1, 0, 0, 1)
    tbLine.ZIndex = z + 1
    local tick = Instance.new("Frame")
    tick.Parent = tb
    tick.BackgroundColor3 = T.White; pcall(function() tick:SetAttribute("ThemeColorRole_BackgroundColor3", "White") end)
    tick.BorderSizePixel = 0
    tick.Position = UDim2.new(0, 8, 0.5, -5)
    tick.Size = UDim2.new(0, 2, 0, 10)
    tick.ZIndex = z + 2
    Corner(tick, 2)
    local tl = Instance.new("TextLabel")
    tl.Parent = tb
    tl.BackgroundTransparency = 1
    tl.Size = UDim2.new(1, -18, 1, 0)
    tl.Position = UDim2.new(0, 16, 0, 0)
    tl.Font = FB
    tl.TextSize = 12
    tl.TextColor3 = T.Tx3; pcall(function() tl:SetAttribute("ThemeColorRole_TextColor3", "Tx3") end)
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Text = string.upper(name)
    tl.ZIndex = z + 2
    local ct = Instance.new("Frame")
    ct.Name = "C"
    ct.Parent = f
    ct.BackgroundTransparency = 1
    ct.Position = UDim2.new(0, 10, 0, 30)
    ct.Size = UDim2.new(1, -18, 1, -36)
    ct.ZIndex = z + 1
    do
        local dr, ds, sp
        tb.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dr = true
                ds = i.Position
                sp = f.Position
            end
        end)
        tc(UIS.InputChanged:Connect(function(i)
            if dr and i.UserInputType == Enum.UserInputType.MouseMovement then
                local d = i.Position - ds
                f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
            end
        end))
        tc(UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dr = false
                pcall(function()
                    if S._RequestAutoSave then S._RequestAutoSave() end
                end)
            end
        end))
    end
    HUDEls[name] = { frame = f, content = ct }
    return HUDEls[name]
end
HUD.hBinds = mkDragHUD("Keybinds", UDim2.new(0, 10, 0, 370), UDim2.fromOffset(260, 150), 851)
do
    local bindsLayout = Instance.new("UIListLayout", HUD.hBinds.content)
    bindsLayout.Padding = UDim.new(0, 2)
    -- UIListLayout's real default is SortOrder.Name, not LayoutOrder. This section's rows are all
    -- unnamed ("Frame"), so it happened to render correctly by coincidence (ties preserve creation
    -- order) — pinning it explicitly so it can't silently break the same way.
    bindsLayout.SortOrder = Enum.SortOrder.LayoutOrder
end
HUD.hGun = mkDragHUD("Gun Status", UDim2.new(1, -272, 0, 200), UDim2.fromOffset(260, 80), 852)
HUD.gunLbl = Instance.new("TextLabel")
HUD.gunLbl.Parent = HUD.hGun.content
HUD.gunLbl.BackgroundTransparency = 1
HUD.gunLbl.Size = UDim2.new(1, 0, 1, 0)
HUD.gunLbl.Font = F
HUD.gunLbl.TextSize = 15
HUD.gunLbl.TextColor3 = T.Tx; pcall(function() HUD.gunLbl:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
HUD.gunLbl.TextXAlignment = Enum.TextXAlignment.Left
HUD.gunLbl.TextYAlignment = Enum.TextYAlignment.Top
HUD.gunLbl.TextWrapped = true
HUD.gunLbl.Text = "..."
HUD.gunLbl.ZIndex = 853

HUD.hRole = mkDragHUD("Role HUD", UDim2.new(0, 10, 0, 100), UDim2.fromOffset(260, 110), 856)
HUD.roleLbl = Instance.new("TextLabel")
HUD.roleLbl.Parent = HUD.hRole.content
HUD.roleLbl.BackgroundTransparency = 1
HUD.roleLbl.Size = UDim2.new(1, 0, 1, 0)
HUD.roleLbl.Font = F
HUD.roleLbl.TextSize = 15
HUD.roleLbl.TextColor3 = T.Tx; pcall(function() HUD.roleLbl:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
HUD.roleLbl.TextXAlignment = Enum.TextXAlignment.Left
HUD.roleLbl.TextYAlignment = Enum.TextYAlignment.Top
HUD.roleLbl.TextWrapped = true
HUD.roleLbl.Text = "..."
HUD.roleLbl.ZIndex = 857
-- Compact single-line stat pill: small gray tag on the left, mono value on the right. Styled to
-- match the watermark (same dark plate / corner radius / stroke) so every floating readout reads
-- as one family instead of a pile of mini-windows. Drag anywhere on the pill to move it.
local function mkStatHUD(name, pos, w, z)
    local f = Instance.new("Frame")
    f.Name = "HUD_" .. name
    f.Parent = SG
    f.Active = true
    f.Position = pos
    f.Size = UDim2.fromOffset(w, 30)
    f.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    f.BackgroundTransparency = 0.06
    f.BorderSizePixel = 0
    f.Visible = false
    f.ZIndex = z
    Corner(f, 8)
    local st = Stroke(f, T.Bd2, 1, 0.3); pcall(function() st:SetAttribute("ThemeColorRole_Color", "Bd2") end)
    Shadow(f, 0.45)
    local tag = Instance.new("TextLabel")
    tag.Parent = f
    tag.BackgroundTransparency = 1
    tag.Position = UDim2.new(0, 10, 0, 0)
    tag.Size = UDim2.new(0, 48, 1, 0)
    tag.Font = FB
    tag.TextSize = 10
    tag.TextColor3 = T.Tx4; pcall(function() tag:SetAttribute("ThemeColorRole_TextColor3", "Tx4") end)
    tag.TextXAlignment = Enum.TextXAlignment.Left
    tag.Text = string.upper(name)
    tag.ZIndex = z + 1
    local lbl = Instance.new("TextLabel")
    lbl.Parent = f
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 58, 0, 0)
    lbl.Size = UDim2.new(1, -68, 1, 0)
    lbl.Font = FM
    lbl.TextSize = 13
    lbl.TextColor3 = T.Tx; pcall(function() lbl:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
    lbl.TextXAlignment = Enum.TextXAlignment.Right
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.Text = "\u{2014}"
    lbl.ZIndex = z + 1
    do
        local dr, ds, sp
        f.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dr = true; ds = i.Position; sp = f.Position end
        end)
        tc(UIS.InputChanged:Connect(function(i)
            if dr and i.UserInputType == Enum.UserInputType.MouseMovement then
                local d = i.Position - ds
                f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
            end
        end))
        tc(UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dr = false
                pcall(function()
                    if S._RequestAutoSave then S._RequestAutoSave() end
                end)
            end
        end))
    end
    HUDEls[name] = { frame = f, content = f }
    return HUDEls[name], lbl
end
-- Right-edge stat stack starts at y=290: Roblox's own top-right social panel (Friends Playing /
-- Trade Requests) covers roughly y=30-200 in that corner and sits ABOVE our GUI, so anything placed
-- higher would be hidden behind it (verified live via screenshot).
HUD.hFps, HUD.fpsLbl = mkStatHUD("FPS", UDim2.new(1, -142, 0, 290), 130, 854)
-- Compact colored watermark pill (icon + MM2 + user + ping + fps + session)
local function mkWatermark()
    local f = Instance.new("Frame")
    f.Name = "HUD_Watermark"
    f.Parent = SG
    f.Active = true
    f.Position = UDim2.new(0, 12, 0, 12)
    f.AutomaticSize = Enum.AutomaticSize.X
    f.Size = UDim2.new(0, 0, 0, 30)
    f.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    f.BackgroundTransparency = 0.06
    f.BorderSizePixel = 0
    f.Visible = false
    f.ZIndex = 864
    Corner(f, 8)
    Stroke(f, T.Bd2, 1, 0.3)
    Shadow(f, 0.45)
    local pad = Instance.new("UIPadding")
    pad.Parent = f
    pad.PaddingLeft = UDim.new(0, 11)
    pad.PaddingRight = UDim.new(0, 13)
    local lay = Instance.new("UIListLayout")
    lay.Parent = f
    lay.FillDirection = Enum.FillDirection.Horizontal
    lay.VerticalAlignment = Enum.VerticalAlignment.Center
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Padding = UDim.new(0, 9)
    local icon = Instance.new("Frame")
    icon.Parent = f
    icon.LayoutOrder = 1
    icon.Size = UDim2.fromOffset(18, 18)
    icon.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
    icon.BorderSizePixel = 0
    icon.ZIndex = 865
    Corner(icon, 9999)
    Stroke(icon, Color3.fromRGB(70, 70, 75), 1.2, 0.4)

    local gun = Instance.new("Frame")
    gun.Parent = icon
    gun.Size = UDim2.fromScale(1, 1)
    gun.BackgroundTransparency = 1
    gun.ZIndex = 866

    local barrel = Instance.new("Frame")
    barrel.Parent = gun
    barrel.Size = UDim2.fromOffset(10, 3)
    barrel.Position = UDim2.fromOffset(4, 6)
    barrel.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    barrel.BorderSizePixel = 0
    barrel.ZIndex = 867

    local grip = Instance.new("Frame")
    grip.Parent = gun
    grip.Size = UDim2.fromOffset(3, 4)
    grip.Position = UDim2.fromOffset(4, 9)
    grip.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    grip.BorderSizePixel = 0
    grip.ZIndex = 867

    local trig = Instance.new("Frame")
    trig.Parent = gun
    trig.Size = UDim2.fromOffset(2, 2)
    trig.Position = UDim2.fromOffset(8, 9)
    trig.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    trig.BorderSizePixel = 0
    trig.ZIndex = 867
    local lbl = Instance.new("TextLabel")
    lbl.Parent = f
    lbl.LayoutOrder = 2
    lbl.BackgroundTransparency = 1
    lbl.AutomaticSize = Enum.AutomaticSize.X
    lbl.Size = UDim2.new(0, 0, 1, 0)
    lbl.Font = FM
    lbl.TextSize = 14
    lbl.RichText = true
    lbl.TextColor3 = T.Tx; pcall(function() lbl:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = "Inertia"
    lbl.ZIndex = 865
    do
        local dr, ds, sp
        f.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dr = true; ds = i.Position; sp = f.Position end
        end)
        tc(UIS.InputChanged:Connect(function(i)
            if dr and i.UserInputType == Enum.UserInputType.MouseMovement then
                local d = i.Position - ds
                f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
            end
        end))
        tc(UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dr = false
                pcall(function()
                    if S._RequestAutoSave then S._RequestAutoSave() end
                end)
            end
        end))
    end
    HUDEls["Watermark"] = { frame = f, content = f }
    return f, lbl
end
HUD.hPing, HUD.pingLbl = mkStatHUD("Ping", UDim2.new(1, -142, 0, 326), 130, 856)
HUD.hSession, HUD.sessionLbl = mkStatHUD("Session", UDim2.new(1, -142, 0, 362), 130, 863)
HUD.hSpeed, HUD.speedLbl = mkStatHUD("Speed", UDim2.new(1, -142, 0, 398), 130, 861)
HUD.hCoords, HUD.coordLbl = mkStatHUD("Coords", UDim2.new(0, 10, 0, 540), 190, 857)
HUD.hWatermark, HUD.watermarkLbl = mkWatermark()
-- Pinned Emotes: a small draggable HUD tray of emote icons pinned from the Player > Emotes list.
-- Starts empty/hidden; each pin adds an icon button here (click plays that emote), each unpin removes
-- it. Registered in HUDEls like the other HUD boxes, but its own logic lives with the Emotes tab code.
-- 310 wide (was 260): content is width-18, so 310 fits a 6th 44+5px grid cell per row (289 <= 292).
HUD.hPinnedEmotes = mkDragHUD("Pinned Emotes", UDim2.new(0, 230, 0, 540), UDim2.fromOffset(310, 92), 865)
HUD.hPinnedEmotes.frame.Visible = false
local pinnedEmotesGrid = Instance.new("UIGridLayout")
pinnedEmotesGrid.CellSize = UDim2.fromOffset(44, 44)
pinnedEmotesGrid.CellPadding = UDim2.fromOffset(5, 5)
pinnedEmotesGrid.SortOrder = Enum.SortOrder.LayoutOrder
pinnedEmotesGrid.Parent = HUD.hPinnedEmotes.content
-- Let the tray grow from the grid instead of stretching the content against the frame height.
HUD.hPinnedEmotes.content.Size = UDim2.new(1, -18, 0, 0)
HUD.hPinnedEmotes.content.AutomaticSize = Enum.AutomaticSize.Y
HUD.hPinnedEmotes.frame.AutomaticSize = Enum.AutomaticSize.Y
-- Kill Feed stays chrome-free (no big panel/background) so with no recent kills nothing is drawn —
-- but it needs to be re-positionable, so a small always-visible grip pill sits above the card list.
-- Only the grip is draggable (same drag pattern as mkDragHUD's titlebar); the auto-sizing card list
-- lives below it and is NOT part of the drag hitbox, so clicking through cards never moves it by
-- accident. Position drags/saves on the OUTER frame, exactly like every other HUD element.
do
    local f = Instance.new("Frame")
    f.Name = "HUD_Kill Feed"
    f.Parent = SG
    f.Active = true
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.Position = UDim2.new(1, -272, 0, 110)
    f.Size = UDim2.new(0, 256, 0, 16)
    f.Visible = false
    f.ZIndex = 864

    local grip = Instance.new("Frame")
    grip.Name = "Grip"
    grip.Parent = f
    grip.AnchorPoint = Vector2.new(1, 0)
    grip.Position = UDim2.new(1, 0, 0, 0)
    grip.Size = UDim2.new(0, 44, 0, 14)
    grip.BackgroundColor3 = T.Elev; pcall(function() grip:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
    grip.BackgroundTransparency = 0.25
    grip.BorderSizePixel = 0
    grip.ZIndex = 865
    Corner(grip, 6)
    local gripStroke = Stroke(grip, T.Bd2, 1, 0.5); pcall(function() gripStroke:SetAttribute("ThemeColorRole_Color", "Bd2") end)
    local gripDot = Instance.new("Frame")
    gripDot.Parent = grip
    gripDot.AnchorPoint = Vector2.new(0.5, 0.5)
    gripDot.Position = UDim2.new(0.5, 0, 0.5, 0)
    gripDot.Size = UDim2.new(0, 18, 0, 3)
    gripDot.BackgroundColor3 = T.Tx3; pcall(function() gripDot:SetAttribute("ThemeColorRole_BackgroundColor3", "Tx3") end)
    gripDot.BorderSizePixel = 0
    gripDot.ZIndex = 866
    Corner(gripDot, 2)
    grip.MouseEnter:Connect(function() TweenService.Create(TweenService, grip, TweenInfo.new(0.1), { BackgroundTransparency = 0.05 }):Play() end)
    grip.MouseLeave:Connect(function() TweenService.Create(TweenService, grip, TweenInfo.new(0.1), { BackgroundTransparency = 0.25 }):Play() end)

    local kfContentFrame = Instance.new("Frame")
    kfContentFrame.Name = "Content"
    kfContentFrame.Parent = f
    kfContentFrame.BackgroundTransparency = 1
    kfContentFrame.Position = UDim2.new(0, 0, 0, 18)
    kfContentFrame.Size = UDim2.new(1, 0, 0, 0)
    kfContentFrame.AutomaticSize = Enum.AutomaticSize.Y
    kfContentFrame.ZIndex = 864
    local kfl = Instance.new("UIListLayout")
    kfl.Parent = kfContentFrame
    kfl.SortOrder = Enum.SortOrder.LayoutOrder
    kfl.Padding = UDim.new(0, 6)
    kfl.HorizontalAlignment = Enum.HorizontalAlignment.Right
    kfl.VerticalAlignment = Enum.VerticalAlignment.Top

    do
        local dr, ds, sp
        grip.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dr = true
                ds = i.Position
                sp = f.Position
            end
        end)
        tc(UIS.InputChanged:Connect(function(i)
            if dr and i.UserInputType == Enum.UserInputType.MouseMovement then
                local d = i.Position - ds
                f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
            end
        end))
        tc(UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dr = false
                pcall(function() if S._RequestAutoSave then S._RequestAutoSave() end end)
            end
        end))
    end

    HUDEls["Kill Feed"] = { frame = f, content = kfContentFrame }
    HUD.hKillFeed = HUDEls["Kill Feed"]
end
do
    local sec = mkSection(Pages.Misc, "HUD Elements", 11)
    S._RegisterMiscSection(sec, "Utility")
    mkToggle(sec, "Keybind HUD", false, function(v)
        S.HUD_Keybinds = v
        HUDEls["Keybinds"].frame.Visible = v
    end, 2)
    mkToggle(sec, "Gun Status", false, function(v)
        S.HUD_GunStatus = v
        HUDEls["Gun Status"].frame.Visible = v
    end, 3)
    mkToggle(sec, "FPS HUD", false, function(v)
        S.HUD_FPS = v
        HUDEls["FPS"].frame.Visible = v
    end, 4)
    mkToggle(sec, "Ping HUD", false, function(v)
        S.HUD_Ping = v
        HUDEls["Ping"].frame.Visible = v
    end, 5)
    mkToggle(sec, "Coords HUD", false, function(v)
        S.HUD_Coords = v
        HUDEls["Coords"].frame.Visible = v
    end, 6)
    mkToggle(sec, "Watermark HUD", false, function(v)
        S.HUD_Watermark = v
        local wf = HUDEls["Watermark"].frame
        if v then
            -- If it was dragged (or a saved config restored it) off-screen, snap it back so it can't
            -- silently "disappear".
            local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
            local px, py = wf.Position.X.Offset, wf.Position.Y.Offset
            if (not vp) or px < 0 or py < 0 or px > (vp.X - 20) or py > (vp.Y - 20) then
                wf.Position = UDim2.new(0, 12, 0, 12)
            end
        end
        wf.Visible = v
    end, 9)
    mkToggle(sec, "Speed HUD", false, function(v)
        S.HUD_Speed = v
        HUDEls["Speed"].frame.Visible = v
    end, 10)
    mkToggle(sec, "Session HUD", false, function(v)
        S.HUD_Session = v
        HUDEls["Session"].frame.Visible = v
    end, 11)
    mkToggle(sec, "Kill Feed", false, function(v)
        S.HUD_KillFeed = v
        HUDEls["Kill Feed"].frame.Visible = v
    end, 12)
    mkToggle(sec, "Role HUD", false, function(v)
        S.RoleHUDEnabled = v
        if HUD.hRole and HUD.hRole.frame then
            HUD.hRole.frame.Visible = v and isRoundActive()
        end
    end, 13)
    local info = Instance.new("TextLabel")
    info.Parent = sec
    info.LayoutOrder = 14
    info.BackgroundTransparency = 1
    info.Size = UDim2.new(1, 0, 0, 22)
    info.Font = F
    info.TextSize = 13
    info.TextColor3 = T.Tx4; pcall(function() info:SetAttribute("ThemeColorRole_TextColor3", "Tx4") end)
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Text = "Drag HUD elements by their header"
end
-- ============ WORLD / LIGHTING (fullbright / no fog / force day / no shadows) ============
local Lighting = game:GetService("Lighting")
local savedLighting = {}
local function saveLighting()
    if savedLighting.done then return end
    savedLighting.Brightness = Lighting.Brightness
    savedLighting.ClockTime = Lighting.ClockTime
    savedLighting.FogEnd = Lighting.FogEnd
    savedLighting.GlobalShadows = Lighting.GlobalShadows
    savedLighting.Ambient = Lighting.Ambient
    savedLighting.OutdoorAmbient = Lighting.OutdoorAmbient
    savedLighting.done = true
end
-- Snapshot pristine map lighting immediately (before any shader/sky/fog can touch it) so that
-- Custom Sky / Fog can always be fully restored, even if no other World toggle was ever used.
saveLighting()

local shaderEffects = {}
local function clearShaderEffects()
    for _, eff in ipairs(shaderEffects) do
        pcall(function() eff:Destroy() end)
    end
    shaderEffects = {}
    S._ultraFX = nil   -- stop the RTX Ultra animator from touching destroyed effects
end

-- Central atmosphere manager (sky / fog / shader haze). Defined below; forward-declared
-- here so applyShader() can trigger an instant atmosphere refresh.
local applyAtmo

applyShader = function(name)
    saveLighting()
    clearShaderEffects()
    
    if name == "None" then
        S.ActiveShader = "None"
        pcall(function() Lighting.ExposureCompensation = 0 end)
        if savedLighting.done then
            Lighting.Brightness = savedLighting.Brightness
            Lighting.ClockTime = savedLighting.ClockTime
            Lighting.FogEnd = savedLighting.FogEnd
            Lighting.GlobalShadows = savedLighting.GlobalShadows
            Lighting.Ambient = savedLighting.Ambient
            Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
            Lighting.FogColor = Color3.fromRGB(192, 192, 192)
            Lighting.FogStart = 0
        end
        if applyAtmo then pcall(applyAtmo) end
        return
    end
    
    S.ActiveShader = name
    pcall(function() Lighting.ExposureCompensation = 0 end)

    if name == "RTX Low" then
        -- Clean, softly lit look: gentle bloom + subtle warm grade. No blown-out highlights.
        Lighting.ClockTime = 14
        Lighting.Brightness = 1.8
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(90, 94, 102)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 132, 142)
        pcall(function() Lighting.ExposureCompensation = 0.03 end)

        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.35
        bloom.Size = 18
        bloom.Threshold = 1.7
        bloom.Parent = Lighting
        table.insert(shaderEffects, bloom)

        local cc = Instance.new("ColorCorrectionEffect")
        cc.Brightness = 0.0
        cc.Contrast = 0.08
        cc.Saturation = 0.12
        cc.TintColor = Color3.fromRGB(255, 252, 246)
        cc.Parent = Lighting
        table.insert(shaderEffects, cc)

    elseif name == "RTX Medium" then
        -- Balanced daylight with soft sun shafts and a warm cinematic tint.
        Lighting.ClockTime = 14.5
        Lighting.Brightness = 2.0
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(96, 100, 110)
        Lighting.OutdoorAmbient = Color3.fromRGB(138, 142, 154)
        pcall(function() Lighting.ExposureCompensation = 0.06 end)

        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.55
        bloom.Size = 24
        bloom.Threshold = 1.6
        bloom.Parent = Lighting
        table.insert(shaderEffects, bloom)

        local sunrays = Instance.new("SunRaysEffect")
        sunrays.Intensity = 0.07
        sunrays.Spread = 0.55
        sunrays.Parent = Lighting
        table.insert(shaderEffects, sunrays)

        local cc = Instance.new("ColorCorrectionEffect")
        cc.Brightness = 0.0
        cc.Contrast = 0.12
        cc.Saturation = 0.18
        cc.TintColor = Color3.fromRGB(255, 250, 242)
        cc.Parent = Lighting
        table.insert(shaderEffects, cc)

    elseif name == "RTX High" then
        -- Cinematic contrast + sun shafts + subtle depth-of-field. Tuned to avoid glare.
        Lighting.ClockTime = 15.2
        Lighting.Brightness = 2.2
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(100, 104, 116)
        Lighting.OutdoorAmbient = Color3.fromRGB(144, 148, 162)
        pcall(function() Lighting.ExposureCompensation = 0.08 end)

        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.8
        bloom.Size = 30
        bloom.Threshold = 1.5
        bloom.Parent = Lighting
        table.insert(shaderEffects, bloom)

        local sunrays = Instance.new("SunRaysEffect")
        sunrays.Intensity = 0.11
        sunrays.Spread = 0.65
        sunrays.Parent = Lighting
        table.insert(shaderEffects, sunrays)

        local cc = Instance.new("ColorCorrectionEffect")
        cc.Brightness = 0.0
        cc.Contrast = 0.16
        cc.Saturation = 0.22
        cc.TintColor = Color3.fromRGB(255, 248, 236)
        cc.Parent = Lighting
        table.insert(shaderEffects, cc)

    elseif name == "RTX Ultra" then
        -- Premium cinematic look: bright & vibrant with soft glowing highlights, gentle god-rays and a
        -- light depth-of-field — WITHOUT blowing the scene out. Only genuinely bright spots bloom (high
        -- threshold), exposure is modest, saturation is rich but not crushed. The animator just makes it
        -- "breathe" softly instead of pulsing hard.
        Lighting.ClockTime = 15.2
        Lighting.Brightness = 2.3
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(104, 108, 122)
        Lighting.OutdoorAmbient = Color3.fromRGB(150, 155, 170)
        pcall(function() Lighting.ExposureCompensation = 0.09 end)

        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.9
        bloom.Size = 34
        bloom.Threshold = 1.4
        bloom.Parent = Lighting
        table.insert(shaderEffects, bloom)

        local sunrays = Instance.new("SunRaysEffect")
        sunrays.Intensity = 0.16
        sunrays.Spread = 0.7
        sunrays.Parent = Lighting
        table.insert(shaderEffects, sunrays)

        local dof = Instance.new("DepthOfFieldEffect")
        dof.FarIntensity = 0.08
        dof.FocusDistance = 45
        dof.InFocusRadius = 55
        dof.NearIntensity = 0.2
        dof.Parent = Lighting
        table.insert(shaderEffects, dof)

        local cc = Instance.new("ColorCorrectionEffect")
        cc.Brightness = 0.0
        cc.Contrast = 0.18
        cc.Saturation = 0.32
        cc.TintColor = Color3.fromRGB(255, 251, 246)
        cc.Parent = Lighting
        table.insert(shaderEffects, cc)

        -- Live references for the animator loop (cleared in clearShaderEffects).
        S._ultraFX = { bloom = bloom, sunrays = sunrays, cc = cc }

    elseif name == "Night Shaders" then
        -- Moody moonlit blue with soft glow and a cool tint. Ambient lifted so
        -- shadowed corners / indoors don't crush to black.
        Lighting.ClockTime = 0
        Lighting.Brightness = 1.7
        Lighting.Ambient = Color3.fromRGB(72, 86, 122)
        Lighting.OutdoorAmbient = Color3.fromRGB(88, 104, 146)
        Lighting.GlobalShadows = true
        pcall(function() Lighting.ExposureCompensation = 0.15 end)

        local cc = Instance.new("ColorCorrectionEffect")
        cc.Brightness = 0.06
        cc.TintColor = Color3.fromRGB(165, 186, 255)
        cc.Contrast = 0.15
        cc.Saturation = 0.28
        cc.Parent = Lighting
        table.insert(shaderEffects, cc)

        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.7
        bloom.Size = 24
        bloom.Threshold = 1.2
        bloom.Parent = Lighting
        table.insert(shaderEffects, bloom)

    elseif name == "Pink Shaders" then
        -- Dreamy sunset: warm pink/orange glow, soft blooming highlights.
        Lighting.ClockTime = 17.4
        Lighting.Brightness = 1.8
        Lighting.Ambient = Color3.fromRGB(110, 86, 100)
        Lighting.OutdoorAmbient = Color3.fromRGB(195, 145, 168)
        Lighting.GlobalShadows = true
        pcall(function() Lighting.ExposureCompensation = 0.06 end)

        local cc = Instance.new("ColorCorrectionEffect")
        cc.Brightness = 0.0
        cc.TintColor = Color3.fromRGB(255, 205, 226)
        cc.Contrast = 0.11
        cc.Saturation = 0.18
        cc.Parent = Lighting
        table.insert(shaderEffects, cc)

        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.7
        bloom.Size = 26
        bloom.Threshold = 1.4
        bloom.Parent = Lighting
        table.insert(shaderEffects, bloom)

    elseif name == "Cinematic" then
        -- Film look: strong contrast, warm highlights, soft depth-of-field.
        Lighting.ClockTime = 15.8
        Lighting.Brightness = 2.0
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(92, 96, 106)
        Lighting.OutdoorAmbient = Color3.fromRGB(138, 144, 156)
        pcall(function() Lighting.ExposureCompensation = 0.05 end)

        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.5
        bloom.Size = 22
        bloom.Threshold = 1.6
        bloom.Parent = Lighting
        table.insert(shaderEffects, bloom)

        local cc = Instance.new("ColorCorrectionEffect")
        cc.Contrast = 0.25
        cc.Saturation = 0.10
        cc.TintColor = Color3.fromRGB(255, 244, 228)
        cc.Parent = Lighting
        table.insert(shaderEffects, cc)

    elseif name == "Golden Hour" then
        -- Low warm sun, long golden light, heavy glow.
        Lighting.ClockTime = 17.8
        Lighting.Brightness = 2.3
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(140, 105, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(215, 160, 105)
        pcall(function() Lighting.ExposureCompensation = 0.08 end)

        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.9
        bloom.Size = 32
        bloom.Threshold = 1.35
        bloom.Parent = Lighting
        table.insert(shaderEffects, bloom)

        local sunrays = Instance.new("SunRaysEffect")
        sunrays.Intensity = 0.18
        sunrays.Spread = 0.8
        sunrays.Parent = Lighting
        table.insert(shaderEffects, sunrays)

        local cc = Instance.new("ColorCorrectionEffect")
        cc.Contrast = 0.12
        cc.Saturation = 0.22
        cc.TintColor = Color3.fromRGB(255, 214, 165)
        cc.Parent = Lighting
        table.insert(shaderEffects, cc)

    elseif name == "Arctic" then
        -- Crisp cold daylight: icy blue tint, slightly desaturated, bright and clean.
        Lighting.ClockTime = 13
        Lighting.Brightness = 2.4
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(120, 132, 148)
        Lighting.OutdoorAmbient = Color3.fromRGB(170, 185, 205)
        pcall(function() Lighting.ExposureCompensation = 0.04 end)

        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.45
        bloom.Size = 20
        bloom.Threshold = 1.6
        bloom.Parent = Lighting
        table.insert(shaderEffects, bloom)

        local cc = Instance.new("ColorCorrectionEffect")
        cc.Brightness = 0.03
        cc.Contrast = 0.15
        cc.Saturation = -0.08
        cc.TintColor = Color3.fromRGB(205, 228, 255)
        cc.Parent = Lighting
        table.insert(shaderEffects, cc)

    elseif name == "Neon" then
        -- Cyberpunk night: deep purple ambient, saturated colours, heavy bloom on lights.
        Lighting.ClockTime = 0
        Lighting.Brightness = 1.4
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(55, 30, 85)
        Lighting.OutdoorAmbient = Color3.fromRGB(80, 45, 130)
        pcall(function() Lighting.ExposureCompensation = 0.0 end)

        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 1.1
        bloom.Size = 34
        bloom.Threshold = 1.1
        bloom.Parent = Lighting
        table.insert(shaderEffects, bloom)

        local cc = Instance.new("ColorCorrectionEffect")
        cc.Contrast = 0.2
        cc.Saturation = 0.35
        cc.TintColor = Color3.fromRGB(200, 150, 255)
        cc.Parent = Lighting
        table.insert(shaderEffects, cc)

    elseif name == "Noir" then
        -- Black & white detective film: no colour, hard contrast, soft glow.
        Lighting.ClockTime = 16
        Lighting.Brightness = 1.7
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(90, 90, 90)
        Lighting.OutdoorAmbient = Color3.fromRGB(130, 130, 130)
        pcall(function() Lighting.ExposureCompensation = 0.0 end)

        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.3
        bloom.Size = 16
        bloom.Threshold = 1.8
        bloom.Parent = Lighting
        table.insert(shaderEffects, bloom)

        local cc = Instance.new("ColorCorrectionEffect")
        cc.Brightness = -0.02
        cc.Contrast = 0.35
        cc.Saturation = -1
        cc.Parent = Lighting
        table.insert(shaderEffects, cc)
    end

    if applyAtmo then pcall(applyAtmo) end
end

task.spawn(function()
    while S.Gui and S.Gui.Parent do
        pcall(function()
            if S.FullBright or S.NoFog or S.ForceDay or S.ForceNight or S.NoShadows then saveLighting() end
            if S.ActiveShader == "None" then
                if S.FullBright then
                    Lighting.Brightness = (S.Brightness or 2)
                    Lighting.Ambient = Color3.fromRGB(178, 178, 178)
                    Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
                elseif not S.SkyEnabled and savedLighting.done then
                    -- Custom Sky owns Ambient/OutdoorAmbient while active; don't fight it here.
                    Lighting.Brightness = savedLighting.Brightness
                    Lighting.Ambient = savedLighting.Ambient
                    Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
                end
                if S.NoFog and not S.FogEnabled then Lighting.FogEnd = 1e9 elseif not S.FogEnabled and savedLighting.done then Lighting.FogEnd = savedLighting.FogEnd end
                -- ClockTime: manual force > Custom Time > Custom Sky preset > saved value
                if S.ForceDay then Lighting.ClockTime = 14
                elseif S.ForceNight then Lighting.ClockTime = 0
                elseif not S.SkyEnabled and not S.CustomTime and savedLighting.done then Lighting.ClockTime = savedLighting.ClockTime end
                if S.NoShadows then Lighting.GlobalShadows = false elseif savedLighting.done then Lighting.GlobalShadows = savedLighting.GlobalShadows end
            end
        end)
        task.wait(0.2)
    end
end)
-- RTX Ultra animator: softly "breathes" the glow / god-rays / saturation so the preset feels alive
-- without ever spiking into an over-bright, blown-out look. Only runs while RTX Ultra is active.
task.spawn(function()
    while S.Gui and S.Gui.Parent do
        local fx = S._ultraFX
        if S.ActiveShader == "RTX Ultra" and fx then
            pcall(function()
                local t = tick()
                if fx.bloom and fx.bloom.Parent then fx.bloom.Intensity = 0.85 + 0.12 * math.sin(t * 1.1) end
                if fx.sunrays and fx.sunrays.Parent then fx.sunrays.Intensity = 0.15 + 0.05 * math.sin(t * 0.8) end
                if fx.cc and fx.cc.Parent then
                    fx.cc.Saturation = 0.32 + 0.05 * math.sin(t * 1.0)
                end
            end)
            task.wait(0.05)
        else
            task.wait(0.2)
        end
    end
end)
-- Removed duplicate shader UI registration (already merged into Visuals page)
-- ============ ENVIRONMENT MANAGER (custom sky, legacy fog, shader haze) ============
-- Wrapped in a do-block so its lookup tables stay out of the main chunk's local budget.
-- Roblox rule that drives the design: legacy fog (FogStart/End/Color) is IGNORED whenever any
-- Atmosphere exists. So Fog uses legacy fog and parks any Atmosphere; Sky uses an Atmosphere for
-- colour (only when Fog is off) plus ClockTime + Ambient + skybox removal so the change is obvious.
do
    -- Base haze applied while a shader preset is active (only when sky/fog aren't managing it).
    local SHADER_ATMO = {
        ["RTX Low"]       = {density=0.20, offset=0.15, color=Color3.fromRGB(200,206,216), decay=Color3.fromRGB(120,140,182), glare=0.08, haze=1.1},
        ["RTX Medium"]    = {density=0.24, offset=0.20, color=Color3.fromRGB(206,210,218), decay=Color3.fromRGB(110,140,190), glare=0.15, haze=1.5},
        ["RTX High"]      = {density=0.28, offset=0.25, color=Color3.fromRGB(212,215,224), decay=Color3.fromRGB(100,136,200), glare=0.25, haze=1.9},
        ["RTX Ultra"]     = {density=0.28, offset=0.26, color=Color3.fromRGB(214,219,230), decay=Color3.fromRGB(96,140,210),  glare=0.22, haze=1.8},
        ["Night Shaders"] = {density=0.36, offset=0.10, color=Color3.fromRGB(34,44,88),   decay=Color3.fromRGB(12,16,46),   glare=0.05, haze=1.9},
        ["Pink Shaders"]  = {density=0.28, offset=0.20, color=Color3.fromRGB(255,192,216), decay=Color3.fromRGB(255,150,185), glare=0.25, haze=2.0},
        ["Cinematic"]     = {density=0.30, offset=0.22, color=Color3.fromRGB(198,205,215), decay=Color3.fromRGB(105,130,175), glare=0.22, haze=2.0},
        ["Golden Hour"]   = {density=0.34, offset=0.18, color=Color3.fromRGB(255,190,120), decay=Color3.fromRGB(230,140,70),  glare=0.50, haze=2.5},
        ["Arctic"]        = {density=0.30, offset=0.20, color=Color3.fromRGB(215,230,245), decay=Color3.fromRGB(150,185,225), glare=0.15, haze=1.6},
        ["Neon"]          = {density=0.38, offset=0.12, color=Color3.fromRGB(120,70,180),  decay=Color3.fromRGB(60,20,120),   glare=0.10, haze=2.4},
        ["Noir"]          = {density=0.30, offset=0.15, color=Color3.fromRGB(150,150,155), decay=Color3.fromRGB(70,70,80),    glare=0.05, haze=2.2},
    }

    -- Sky presets change the WHOLE environment so the effect is clearly visible: time of day,
    -- ambient/outdoor light colour, plus an atmosphere that recolours the (procedural) sky.
    local SKY_PRESETS = {
        Day    = {clock=14.0, atmColor=Color3.fromRGB(190,210,235), decay=Color3.fromRGB(90,140,220),  glare=0.20, haze=1.4, density=0.30, ambient=Color3.fromRGB(120,128,140), outdoor=Color3.fromRGB(150,160,175)},
        Sunset = {clock=17.6, atmColor=Color3.fromRGB(255,150,90),  decay=Color3.fromRGB(255,110,70),  glare=0.55, haze=2.4, density=0.36, ambient=Color3.fromRGB(150,100,80),  outdoor=Color3.fromRGB(230,150,110)},
        Night  = {clock=0.0,  atmColor=Color3.fromRGB(40,55,110),   decay=Color3.fromRGB(14,20,55),    glare=0.00, haze=2.0, density=0.40, ambient=Color3.fromRGB(30,38,70),    outdoor=Color3.fromRGB(45,55,95)},
        Aurora = {clock=1.0,  atmColor=Color3.fromRGB(60,200,170),  decay=Color3.fromRGB(80,60,205),   glare=0.35, haze=2.6, density=0.44, ambient=Color3.fromRGB(50,90,90),    outdoor=Color3.fromRGB(80,140,140)},
        Space  = {clock=0.0,  atmColor=Color3.fromRGB(30,15,55),    decay=Color3.fromRGB(60,25,95),    glare=0.00, haze=0.6, density=0.18, ambient=Color3.fromRGB(30,25,50),    outdoor=Color3.fromRGB(45,40,75)},
        Blood  = {clock=17.2, atmColor=Color3.fromRGB(180,40,40),   decay=Color3.fromRGB(90,12,16),    glare=0.45, haze=2.8, density=0.44, ambient=Color3.fromRGB(90,35,35),    outdoor=Color3.fromRGB(150,60,55)},
        Toxic  = {clock=9.0,  atmColor=Color3.fromRGB(150,220,70),  decay=Color3.fromRGB(70,150,35),   glare=0.35, haze=2.8, density=0.44, ambient=Color3.fromRGB(80,110,45),   outdoor=Color3.fromRGB(120,170,70)},
        Ocean  = {clock=12.0, atmColor=Color3.fromRGB(90,180,220),  decay=Color3.fromRGB(30,95,155),   glare=0.30, haze=2.0, density=0.40, ambient=Color3.fromRGB(60,100,120),  outdoor=Color3.fromRGB(90,150,180)},
        Sakura = {clock=15.5, atmColor=Color3.fromRGB(255,185,210), decay=Color3.fromRGB(235,120,170), glare=0.30, haze=2.2, density=0.36, ambient=Color3.fromRGB(150,110,125), outdoor=Color3.fromRGB(230,170,190)},
        Midnight={clock=0.0, atmColor=Color3.fromRGB(70,40,130),    decay=Color3.fromRGB(30,12,70),    glare=0.00, haze=2.2, density=0.42, ambient=Color3.fromRGB(45,32,75),    outdoor=Color3.fromRGB(70,50,110)},
        Storm  = {clock=11.0, atmColor=Color3.fromRGB(105,112,125), decay=Color3.fromRGB(55,60,75),    glare=0.00, haze=3.0, density=0.48, ambient=Color3.fromRGB(75,80,90),    outdoor=Color3.fromRGB(105,112,125)},
        Desert = {clock=13.5, atmColor=Color3.fromRGB(235,200,140), decay=Color3.fromRGB(200,150,90),  glare=0.45, haze=2.6, density=0.38, ambient=Color3.fromRGB(140,120,90),  outdoor=Color3.fromRGB(210,180,130)},
    }
    -- Optional flat sky-gradient tint that overrides the preset's sky colour.
    local SKY_TINTS = {
        Blue   = Color3.fromRGB(60,120,235), Purple = Color3.fromRGB(150,80,225),
        Pink   = Color3.fromRGB(240,110,190), Cyan   = Color3.fromRGB(60,205,220),
        Orange = Color3.fromRGB(240,140,55),  Green  = Color3.fromRGB(70,190,80),
        Red    = Color3.fromRGB(220,55,55),   White  = Color3.fromRGB(220,224,235),
    }
    local FOG_COLORS = {
        Gray  = Color3.fromRGB(150,150,158), White = Color3.fromRGB(236,236,242), Black = Color3.fromRGB(14,14,20),
        Blue  = Color3.fromRGB(70,120,200),  Purple= Color3.fromRGB(140,80,200),  Pink  = Color3.fromRGB(235,120,185),
        Cyan  = Color3.fromRGB(90,200,215),  Orange= Color3.fromRGB(235,150,70),  Green = Color3.fromRGB(90,190,90),
        Red   = Color3.fromRGB(210,70,65),
    }

    local ATMO_NAME = "MM2_Atmo"
    local atmoRef          -- our Atmosphere (created only when we need sky colour / shader haze)
    local mapAtmoParked    -- a map Atmosphere we temporarily removed so legacy fog can work
    local removedSky       -- a map Sky (skybox) we removed so the procedural sky shows
    local savedFog         -- original FogColor / FogStart / FogEnd

    local function getAtmo()
        if atmoRef and atmoRef.Parent then return atmoRef end
        atmoRef = Lighting:FindFirstChild(ATMO_NAME)
        if not atmoRef then
            atmoRef = Instance.new("Atmosphere")
            atmoRef.Name = ATMO_NAME
        end
        atmoRef.Parent = Lighting
        return atmoRef
    end
    local function clearAtmo()
        if atmoRef then pcall(function() atmoRef:Destroy() end); atmoRef = nil end
    end
    -- Temporarily remove / restore a map's own Atmosphere (needed for legacy fog to render).
    local function parkMapAtmo(on)
        if on then
            if not mapAtmoParked then
                local a = Lighting:FindFirstChildOfClass("Atmosphere")
                if a and a.Name ~= ATMO_NAME then mapAtmoParked = a; a.Parent = nil end
            end
        elseif mapAtmoParked then
            pcall(function() mapAtmoParked.Parent = Lighting end)
            mapAtmoParked = nil
        end
    end
    -- Remove / restore a map's skybox so the (recolourable) procedural sky is visible.
    local function removeSky(on)
        if on then
            if not removedSky then
                local sk = Lighting:FindFirstChildOfClass("Sky")
                if sk then removedSky = sk; sk.Parent = nil end
            end
        elseif removedSky then
            pcall(function() removedSky.Parent = Lighting end)
            removedSky = nil
        end
    end
    local function saveFog()
        if not savedFog then savedFog = {c = Lighting.FogColor, s = Lighting.FogStart, e = Lighting.FogEnd} end
    end
    local function restoreFog()
        if savedFog then
            pcall(function()
                Lighting.FogColor = savedFog.c
                Lighting.FogStart = savedFog.s
                Lighting.FogEnd   = savedFog.e
            end)
            savedFog = nil
        end
    end

    local skyHue, fogHue = 0, 0
    -- Assign the forward-declared upvalue so applyShader() can call it for an instant refresh.
    applyAtmo = function()
        pcall(function()
            skyHue = (skyHue + 0.006) % 1
            fogHue = (fogHue + 0.004) % 1
            local shaderBase = SHADER_ATMO[S.ActiveShader]

            -- Fog has two modes: Classic (legacy FogStart/End -- needs every Atmosphere gone)
            -- and Atmosphere (density-based soft haze -- needs OUR Atmosphere present).
            local classicFog = S.FogEnabled and S.FogMode ~= "Atmosphere"
            local atmoFog    = S.FogEnabled and S.FogMode == "Atmosphere"
            local fogColor = FOG_COLORS[S.FogColorName] or FOG_COLORS.Gray
            if S.FogRainbow and S.FogEnabled then fogColor = Color3.fromHSV(fogHue, 0.55, 0.85) end

            -- We own an Atmosphere for atmo-fog, sky colour or shader haze -- never for classic fog.
            local needOwnAtmo = atmoFog or ((not classicFog) and (S.SkyEnabled or shaderBase ~= nil))
            -- Any real (map or our) Atmosphere must be gone for legacy fog to draw.
            parkMapAtmo(needOwnAtmo or classicFog)

            -- ---------- LEGACY FOG (Start / End / Color) ----------
            if classicFog then
                saveFog()
                clearAtmo()
                local fs = S.FogStart or 0
                Lighting.FogColor = fogColor
                Lighting.FogStart = fs
                Lighting.FogEnd   = math.max(fs + 1, S.FogEnd or 500)
            else
                restoreFog()
            end

            -- ---------- SKY (time / ambient / skybox / colour) ----------
            if S.SkyEnabled then
                local p = SKY_PRESETS[S.SkyPreset] or SKY_PRESETS.Day
                removeSky(true)
                if not (S.ForceDay or S.ForceNight or S.CustomTime) then Lighting.ClockTime = p.clock end
                Lighting.Ambient = p.ambient
                Lighting.OutdoorAmbient = p.outdoor
            else
                removeSky(false)
            end

            -- ---------- ATMOSPHERE (atmo-fog, else sky colour, else shader haze) ----------
            if needOwnAtmo then
                local a = getAtmo()
                if atmoFog then
                    a.Density = math.clamp((S.FogDensity or 40) / 100, 0, 0.95)
                    a.Offset  = 0
                    a.Color   = fogColor
                    a.Decay   = fogColor
                    a.Glare   = 0
                    a.Haze    = 2.4
                elseif S.SkyEnabled then
                    local p = SKY_PRESETS[S.SkyPreset] or SKY_PRESETS.Day
                    a.Density = p.density
                    a.Offset  = 0.25
                    a.Glare   = p.glare
                    a.Haze    = p.haze
                    a.Color   = p.atmColor
                    local decay = p.decay
                    if S.SkyRainbow then decay = Color3.fromHSV(skyHue, 0.7, 0.85)
                    elseif SKY_TINTS[S.SkyTint] then decay = SKY_TINTS[S.SkyTint] end
                    a.Decay = decay
                else
                    a.Density = shaderBase.density
                    a.Offset  = shaderBase.offset
                    a.Color   = shaderBase.color
                    a.Decay   = shaderBase.decay
                    a.Glare   = shaderBase.glare
                    a.Haze    = shaderBase.haze
                end
            elseif not classicFog then
                clearAtmo()
            end
        end)
    end

    task.spawn(function()
        while S.Gui and S.Gui.Parent do
            applyAtmo()
            task.wait(0.1)
        end
    end)
    SG.Destroying:Connect(function()
        pcall(function() parkMapAtmo(false) end)
        pcall(function() removeSky(false) end)
        pcall(clearAtmo)
        pcall(restoreFog)
    end)
end
-- ============ HAND SHADERS (self highlight / outline for the local player only) ============
do
    -- UI Section is now registered inside the Visuals page instead of the old Shaders page.
    local hl
    local function killHL()
        if hl then pcall(function() hl:Destroy() end); hl = nil end
    end

    local origMaterials = {}
    local origColors = {}
    local origReflectances = {}
    local origTransparencies = {}

    local function restoreHandMaterials()
        for part, mat in pairs(origMaterials) do
            pcall(function()
                if part and part.Parent then
                    part.Material = mat
                    if origColors[part] then part.Color = origColors[part] end
                    if origReflectances[part] then part.Reflectance = origReflectances[part] end
                    if origTransparencies[part] then part.Transparency = origTransparencies[part] end
                end
            end)
        end
        table.clear(origMaterials)
        table.clear(origColors)
        table.clear(origReflectances)
        table.clear(origTransparencies)
    end

    local lastAdornee = nil
    local lastType = nil
    local lastShaderOn = false

    task.spawn(function()
        local hue = 0
        while S.Gui and S.Gui.Parent do
            pcall(function()
                local c = LP.Character
                local adornee = c
                local hlEnabled = true
                if S.HandShader and c then
                    if S.HandTarget == "Held Item" then
                        local tool = c:FindFirstChildOfClass("Tool")
                        if tool then
                            adornee = tool
                        else
                            adornee = nil
                            hlEnabled = false
                        end
                    end
                else
                    hlEnabled = false
                end

                local shaderOn = S.HandShader and hlEnabled
                local shaderType = S.HandShaderType

                if shaderOn ~= lastShaderOn or adornee ~= lastAdornee or shaderType ~= lastType then
                    restoreHandMaterials()
                    if hl then hl.Enabled = false end
                    lastShaderOn = shaderOn
                    lastAdornee = adornee
                    lastType = shaderType
                end

                if shaderOn and adornee then
                    local isMaterialShader = (shaderType == "Mirror" or shaderType == "Bloom" or shaderType == "Maze"
                        or shaderType == "Crystal" or shaderType == "Chrome" or shaderType == "Plasma")
                    
                    local col
                    if S.HandRainbow then
                        hue = (hue + 0.02) % 1
                        col = Color3.fromHSV(hue, 0.85, 1)
                    else
                        col = (S.HandColor == "Black") and Color3.fromRGB(0, 0, 0) or (FOV_COLORS[S.HandColor] or Color3.fromRGB(0, 255, 255))
                    end

                    if isMaterialShader then
                        if hl then hl.Enabled = false end
                        for _, part in ipairs(adornee:GetDescendants()) do
                            if part:IsA("BasePart") then
                                if not origMaterials[part] then
                                    origMaterials[part] = part.Material
                                    origColors[part] = part.Color
                                    origReflectances[part] = part.Reflectance
                                    origTransparencies[part] = part.Transparency
                                end
                                
                                local partCol = col
                                if shaderType == "Mirror" then
                                    part.Material = Enum.Material.Glass
                                    part.Reflectance = 1
                                    part.Transparency = 0.2
                                elseif shaderType == "Bloom" then
                                    part.Material = Enum.Material.Neon
                                    part.Reflectance = 0
                                    part.Transparency = 1 - (S.HandFill or 60) / 100
                                elseif shaderType == "Maze" then
                                    part.Material = Enum.Material.ForceField
                                    part.Reflectance = 0
                                    part.Transparency = 1 - (S.HandFill or 60) / 100
                                elseif shaderType == "Crystal" then
                                    -- Translucent gemstone: glassy, lightly reflective, see-through.
                                    part.Material = Enum.Material.Glass
                                    part.Reflectance = 0.4
                                    part.Transparency = 0.55
                                elseif shaderType == "Chrome" then
                                    -- Polished solid metal, mirror-like but not see-through.
                                    part.Material = Enum.Material.Metal
                                    part.Reflectance = 0.9
                                    part.Transparency = 0
                                elseif shaderType == "Plasma" then
                                    -- Pulsing neon energy: brightness breathes over time.
                                    part.Material = Enum.Material.Neon
                                    part.Reflectance = 0
                                    part.Transparency = 1 - (S.HandFill or 60) / 100
                                    local h, s, v = col:ToHSV()
                                    local pulse = 0.65 + 0.35 * math.sin(tick() * 4)
                                    partCol = Color3.fromHSV(h, s, math.clamp(v * pulse, 0, 1))
                                end
                                part.Color = partCol
                            end
                        end
                    else
                        if not (hl and hl.Parent) then
                            hl = Instance.new("Highlight")
                            hl.Name = "MM2_HandShader"
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Parent = c
                        end
                        hl.Adornee = adornee
                        hl.Enabled = true
                        hl.FillColor = col
                        hl.OutlineColor = col
                        hl.FillTransparency = (shaderType == "Outline") and 1 or (1 - (S.HandFill or 60) / 100)
                        hl.OutlineTransparency = (shaderType == "Fill") and 1 or 0
                    end
                else
                    if hl then hl.Enabled = false end
                end
            end)
            task.wait((S.HandRainbow or S.HandShaderType == "Plasma") and 0.03 or 0.1)
        end
    end)

    local function cleanupAll()
        killHL()
        restoreHandMaterials()
    end
    SG.Destroying:Connect(cleanupAll)
end
-- ============ DUAL WIELD (visual only) ============
-- Clones whatever weapon Tool is currently equipped and welds a cosmetic copy of its Handle into the
-- OFF hand, mirroring the exact grip joint Roblox itself created for the real one — so it's rigidly
-- attached and reads correctly, not an arm stretched out toward a floating gun. The clone has no
-- scripts/remotes; it cannot fire or throw, it's decoration only. Own do-block: own local-register
-- budget, per the running rule for this file (it lives right at Luau's 200-local ceiling).
do
    local dualModel, trackedHandle = nil, nil

    local function clearDual()
        if dualModel then pcall(function() dualModel:Destroy() end) end
        dualModel, trackedHandle = nil, nil
    end

    -- Mirrors a right-hand grip offset across the character's sagittal plane so a copy welded to the
    -- LEFT hand points the same way the real one does in the right, instead of backwards/inside-out.
    local function mirrorGrip(cf)
        local rx, ry, rz = cf:ToOrientation()
        local pos = cf.Position
        return CFrame.new(-pos.X, pos.Y, pos.Z) * CFrame.fromOrientation(rx, -ry, -rz)
    end

    -- BUG FIX: the arm-stretch code below used to reuse mirrorGrip() (above) on the SHOULDER JOINT's
    -- Transform too — that's wrong. mirrorGrip does an Euler-angle sign flip, which only happens to be
    -- correct for a grip OFFSET; a Motor6D.Transform is a rotation MATRIX delta, and mirroring a
    -- rotation matrix across the character's left/right plane is a different operation (conjugate by
    -- the reflection matrix diag(-1,1,1): negate the position X and the R01/R02/R10/R20 components,
    -- keep R00/R11/R12/R21/R22). Using the wrong formula here produced a near-identity/garbled result
    -- — the left shoulder barely moved, i.e. the arm never visibly reached out for the cloned gun even
    -- though the clone itself was correctly attached. This is the real, standard reflection-conjugation
    -- formula for mirroring a joint pose, verified algebraically (F*R*F for F = diag(-1,1,1)).
    local function mirrorTransform(cf)
        local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
        return CFrame.new(-x, y, z, r00, -r01, -r02, -r10, r11, r12, -r20, r21, r22)
    end

    local function buildDual(handle, rightHand, leftHand)
        clearDual()
        local grip
        for _, j in ipairs(rightHand:GetChildren()) do
            if (j:IsA("Motor6D") or j:IsA("Weld")) and j.Part1 == handle then grip = j; break end
        end
        -- Fallback offset if Roblox's own grip joint isn't found yet (still mid-equip) — close enough
        -- for a first frame, and it self-corrects next Heartbeat once the real joint exists.
        local gripC0 = (grip and grip.C0) or CFrame.new(0, -1, 0)
        local gripC1 = (grip and grip.C1) or CFrame.new()

        local ok, clone = pcall(function() return handle:Clone() end)
        if not (ok and clone) then return end
        clone.Name = "DualWieldHandle"
        pcall(function() clone.CanCollide = false end)
        pcall(function() clone.Massless = true end)
        for _, d in ipairs(clone:GetDescendants()) do
            if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("RemoteEvent") or d:IsA("RemoteFunction") or d:IsA("BindableEvent") then
                pcall(function() d:Destroy() end)
            end
        end
        local c = LP.Character
        if not c then pcall(function() clone:Destroy() end); return end
        clone.Parent = c

        local weld = Instance.new("Motor6D")
        weld.Name = "DualWieldGrip"
        weld.Part0 = leftHand
        weld.Part1 = clone
        weld.C0 = mirrorGrip(gripC0)
        weld.C1 = gripC1
        weld.Parent = leftHand

        dualModel, trackedHandle = clone, handle
    end

    tc(RunService.Heartbeat:Connect(function()
        if not S.DualWield then
            if dualModel then clearDual() end
            return
        end
        local c = LP.Character
        local tool = c and c:FindFirstChildWhichIsA("Tool")
        local handle = tool and tool:FindFirstChild("Handle")
        local rightHand = c and c:FindFirstChild("RightHand")
        local leftHand = c and c:FindFirstChild("LeftHand")
        if not (handle and rightHand and leftHand) then
            if dualModel then clearDual() end
            return
        end
        if handle ~= trackedHandle or not dualModel or not dualModel.Parent then
            pcall(buildDual, handle, rightHand, leftHand)
        end
        
        -- Вытягивание левой руки: копируем и зеркалим трансформ правого плеча в левое плечо!
        pcall(function()
            local rShoulder, lShoulder
            if c:FindFirstChild("RightUpperArm") and c.RightUpperArm:FindFirstChild("RightShoulder") then
                rShoulder = c.RightUpperArm.RightShoulder
                lShoulder = c.LeftUpperArm and c.LeftUpperArm:FindFirstChild("LeftShoulder")
            elseif c:FindFirstChild("Torso") then
                rShoulder = c.Torso:FindFirstChild("Right Shoulder")
                lShoulder = c.Torso:FindFirstChild("Left Shoulder")
            end
            if rShoulder and lShoulder then
                lShoulder.Transform = mirrorTransform(rShoulder.Transform)
            end
        end)
    end))
    tc(LP.CharacterAdded:Connect(function() clearDual() end))
end
-- ============ WORLD ENVIRONMENT (merged into Visuals > Environment: time / gravity / effects) ============
do
    local sec2 = mkSection(Pages.Visuals, "World Environment", 13)
    if S._RegisterVisualsEnvSection then S._RegisterVisualsEnvSection(sec2) end
    mkToggle(sec2, "Custom Time", false, function(v) S.CustomTime = v end, 1)
    mkSlider(sec2, "Time of Day", 0, 24, 14, function(v) S.TimeOfDay = v end, 2)
    mkSlider(sec2, "Gravity", 10, 200, 196, function(v)
        S.Gravity = v
        if not S.MoonGravity then pcall(function() workspace.Gravity = v end) end
    end, 3)
    mkToggle(sec2, "Moon Gravity", false, function(v)
        S.MoonGravity = v
        pcall(function() workspace.Gravity = v and 25 or (S.Gravity or 196) end)
    end, 4)
    mkToggle(sec2, "Disable Blur", false, function(v) S.DisableBlur = v end, 5)

    -- Custom time-of-day + blur removal.
    task.spawn(function()
        while S.Gui and S.Gui.Parent do
            pcall(function()
                if S.CustomTime then Lighting.ClockTime = S.TimeOfDay end
                if S.DisableBlur then
                    for _, e in ipairs(Lighting:GetDescendants()) do
                        if e:IsA("BlurEffect") then e.Enabled = false end
                    end
                    local cam = workspace.CurrentCamera
                    if cam then for _, e in ipairs(cam:GetChildren()) do
                        if e:IsA("BlurEffect") then e.Enabled = false end
                    end end
                end
            end)
            task.wait(0.3)
        end
    end)
end

-- ============ AUTOFARM TAB (coins + fast autofarm) ============
isRoundActive = function()
    if next(RoleCache) ~= nil then return true end
    if workspace:FindFirstChild("CoinContainer", true) then return true end
    return workspace:FindFirstChild("Normal") ~= nil
end

do
    -- Find every coin part. A part is a coin if ITS name OR its parent MODEL's name contains "coin"
    -- (this game's coins are Model "Coin_Server" > "CoinVisual" > MeshParts).
    -- PERF: the coin list is CACHED. The old version did `workspace:GetDescendants()` (the WHOLE game)
    -- every call — ~20x/sec while farming — which was the main cause of the lag / RAM churn. Now we
    -- locate the small "CoinContainer" once and rebuild the coin-part list at most ~once per second;
    -- every other call just reuses the cached list (coins don't respawn mid-round, they only fade).
    local coinContainer, coinCache, coinCacheAt = nil, {}, 0
    local function eachCoin(fn)
        if not (coinContainer and coinContainer.Parent) then
            coinContainer = workspace:FindFirstChild("CoinContainer", true)
        end
        if tick() - coinCacheAt > 1 or #coinCache == 0 then
            coinCache = {}
            local root = coinContainer or workspace:FindFirstChild("Normal")
            if root then
                for _, v in ipairs(root:GetDescendants()) do
                    if v:IsA("BasePart") then
                        local par = v.Parent
                        if string.find(string.lower(v.Name), "coin") or (par and string.find(string.lower(par.Name), "coin")) then
                            table.insert(coinCache, v)
                        end
                    end
                end
            end
            coinCacheAt = tick()
        end
        for _, v in ipairs(coinCache) do
            if v.Parent then fn(v) end
        end
    end

    -- Fly STRAIGHT THROUGH WALLS to a point. The HRP is ANCHORED during the glide so it has zero
    -- physics — it passes cleanly through glass, floors and thin textures instead of the velocity-driven
    -- version snagging on / bouncing off them (that was the "autofarm gets stuck on some geometry" bug:
    -- the old code set both a CFrame AND a velocity, and on certain parts the physics fought the CFrame).
    -- Anchored + direct CFrame can't be fought. We ALWAYS unanchor on every exit path so a stopped
    -- autofarm never leaves the character frozen mid-air (the levitation bug).
    local function moveTo(targetCF, speed, checkFn)
        local spd = math.max(speed or S.FastAutofarmSpeed or 20, 1)
        local deadline = tick() + 12
        local arrived = false
        while tick() < deadline do
            if not S.FastAutofarm then break end
            if checkFn and not checkFn() then break end
            local c = LP.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then break end
            hrp.Anchored = true
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            local dt = math.min(task.wait(), 1 / 30)
            c = LP.Character
            hrp = c and c:FindFirstChild("HumanoidRootPart")
            if not hrp then break end
            local delta = targetCF.Position - hrp.Position
            local dist = delta.Magnitude
            local step = spd * dt
            if dist <= math.max(4.0, step) then
                hrp.CFrame = CFrame.new(targetCF.Position)
                arrived = true
                break
            end
            local dir = delta / dist
            local newPos = hrp.Position + dir * step
            local flat = Vector3.new(dir.X, 0, dir.Z)
            hrp.CFrame = (flat.Magnitude > 0.05) and CFrame.new(newPos, newPos + flat) or CFrame.new(newPos)
        end
        -- ALWAYS unanchor on exit (arrived, cancelled, or timed out).
        local c = LP.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Anchored = false
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
        return arrived
    end

    -- ---------- UI ---------- (merged into Teleport > Autofarm subtab)
    local secCoins = mkSection(Pages.Teleport, "Coins", 5)
    if S._RegisterAutofarmSection then S._RegisterAutofarmSection(secCoins) end
    mkToggle(secCoins, "Coin ESP", false, function(v) S.CoinESP = v end, 1)

    local secAuto = mkSection(Pages.Teleport, "Automated", 6)
    if S._RegisterAutofarmSection then S._RegisterAutofarmSection(secAuto) end
    mkToggle(secAuto, "Fast Autofarm", false, function(v) S.FastAutofarm = v end, 1)
    -- Studs/s (1-120). Speed up to 120 studs/s.
    mkSlider(secAuto, "Autofarm Speed", 1, 120, 20, function(v) S.FastAutofarmSpeed = v end, 2)

    -- Vote Farm: just teleport to the map-vote slot's coords, reset, repeat — no gating, per explicit
    -- user request. Coords are the slot's own live-measured standing position (user walked to each pad
    -- and read them off the coords HUD): Slot1=(25,507,48), Slot2=(13,507,51), Slot3=(2,507,49).
    local secVote = mkSection(Pages.Teleport, "Vote Farm", 7)
    if S._RegisterAutofarmSection then S._RegisterAutofarmSection(secVote) end
    mkCycle(secVote, "Map Slot", {"1", "2", "3"}, "1", function(v) S.VoteFarmSlot = v end, 1)
    mkSlider(secVote, "Reset Count", 1, 20, 5, function(v) S.VoteFarmCount = v end, 2)
    local voteFarmBusy = false
    local VoteSlotCoords = {
        ["1"] = Vector3.new(25, 507, 48),
        ["2"] = Vector3.new(13, 507, 51),
        ["3"] = Vector3.new(2, 507, 49),
    }
    mkAction(secVote, "Start Vote Farm", function()
        if voteFarmBusy then Notify("Vote Farm", "Already running", 2); return end
        voteFarmBusy = true
        task.spawn(function()
            local slot = S.VoteFarmSlot or "1"
            local count = math.floor(S.VoteFarmCount or 5)
            local target = VoteSlotCoords[slot] or VoteSlotCoords["1"]
            for i = 1, count do
                S._resetMyCharacter()
                local newChar = LP.CharacterAdded:Wait()
                local hrp = newChar:WaitForChild("HumanoidRootPart", 5)
                if hrp then hrp.CFrame = CFrame.new(target) end
                task.wait(0.5)
                Notify("Vote Farm", "Vote " .. i .. "/" .. count .. " (slot " .. slot .. ")", 2)
            end
            voteFarmBusy = false
        end)
    end, 3)

    -- ---------- Coin ESP (one BillboardGui dot per coin; ~75 coins blow past the ~31 Highlight cap) ----------
    local function coinHost(part)
        local p = part
        while p and p.Parent and p.Parent ~= workspace do
            if string.find(string.lower(p.Parent.Name), "coincontainer") then return p end
            p = p.Parent
        end
        return part.Parent or part
    end
    local espWasOn = false
    local espHosts = {}
    task.spawn(function()
        while S.Gui and S.Gui.Parent do
            if S.CoinESP then
                espWasOn = true
                pcall(function()
                    local live = {}
                    eachCoin(function(coin)
                        if coin.Transparency < 1 then
                            local host = coinHost(coin)
                            if host and not live[host] then live[host] = coin end
                        end
                    end)
                    for host in pairs(espHosts) do
                        if not live[host] or not host.Parent then
                            local m = host and host:FindFirstChild("MM2_CoinESP")
                            if m then m:Destroy() end
                            espHosts[host] = nil
                        end
                    end
                    for host, coin in pairs(live) do
                        if not host:FindFirstChild("MM2_CoinESP") then
                            local bb = Instance.new("BillboardGui")
                            bb.Name = "MM2_CoinESP"
                            bb.Adornee = coin
                            bb.Size = UDim2.fromOffset(22, 22)
                            bb.AlwaysOnTop = true
                            bb.LightInfluence = 0
                            bb.Parent = host
                            -- soft outer glow ring (larger, faint gold circle)
                            local glow = Instance.new("Frame")
                            glow.Size = UDim2.fromScale(1.7, 1.7)
                            glow.Position = UDim2.fromScale(-0.35, -0.35)
                            glow.BackgroundColor3 = Color3.fromRGB(255, 200, 60)
                            glow.BackgroundTransparency = 0.7
                            glow.BorderSizePixel = 0
                            glow.ZIndex = 1
                            glow.Parent = bb
                            Instance.new("UICorner", glow).CornerRadius = UDim.new(1, 0)
                            -- coin body with a gold gradient + bright rim
                            local dot = Instance.new("Frame")
                            dot.Size = UDim2.fromScale(1, 1)
                            dot.BackgroundColor3 = Color3.fromRGB(255, 205, 45)
                            dot.BorderSizePixel = 0
                            dot.ZIndex = 2
                            dot.Parent = bb
                            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
                            local grad = Instance.new("UIGradient")
                            grad.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 244, 170)),
                                ColorSequenceKeypoint.new(1, Color3.fromRGB(228, 150, 18)),
                            })
                            grad.Rotation = 90
                            grad.Parent = dot
                            local us = Instance.new("UIStroke")
                            us.Color = Color3.fromRGB(255, 255, 255)
                            us.Thickness = 1.4
                            us.Transparency = 0.15
                            us.Parent = dot
                            -- glossy highlight dot (top-left) for a coin-like shine
                            local shine = Instance.new("Frame")
                            shine.Size = UDim2.fromScale(0.38, 0.38)
                            shine.Position = UDim2.fromScale(0.16, 0.1)
                            shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                            shine.BackgroundTransparency = 0.4
                            shine.BorderSizePixel = 0
                            shine.ZIndex = 3
                            shine.Parent = dot
                            Instance.new("UICorner", shine).CornerRadius = UDim.new(1, 0)
                            espHosts[host] = true
                        end
                    end
                end)
            elseif espWasOn then
                espWasOn = false
                pcall(function()
                    for host in pairs(espHosts) do
                        if host and host.Parent then
                            local m = host:FindFirstChild("MM2_CoinESP")
                            if m then m:Destroy() end
                        end
                    end
                    espHosts = {}
                end)
            end
            task.wait(0.4)
        end
    end)

    -- ---------- Fast Autofarm: ONLY collect coins (fly through walls to each). Nothing else. ----------
    task.spawn(function()
        local skip = {}          -- coins that refused to collect (bag full / stuck) -> stop chasing
        while S.Gui and S.Gui.Parent do
            if S.FastAutofarm then
                pcall(function()
                    local c = LP.Character
                    local hrp = c and c:FindFirstChild("HumanoidRootPart")
                    local hum = c and c:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 and isRoundActive() then
                        local myPos = hrp.Position
                        local coins = {}
                        local murderPos = nil
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= LP and p.Character and getRole(p) == "Murderer" then
                                local mHrp = p.Character:FindFirstChild("HumanoidRootPart")
                                if mHrp then
                                    murderPos = mHrp.Position
                                    break
                                end
                            end
                        end
                        eachCoin(function(coin)
                            if coin.Transparency < 1 and not skip[coin] then
                                local isSafe = true
                                if murderPos then
                                    local distToMurd = (coin.Position - murderPos).Magnitude
                                    if distToMurd < 45 then
                                        isSafe = false
                                    end
                                end
                                if isSafe then
                                    table.insert(coins, coin)
                                end
                            end
                        end)
                        if #coins == 0 then
                            eachCoin(function(coin)
                                if coin.Transparency < 1 and not skip[coin] then
                                    table.insert(coins, coin)
                                end
                            end)
                            if #coins > 0 then
                                if murderPos then
                                    table.sort(coins, function(a, b)
                                        return (a.Position - murderPos).Magnitude > (b.Position - murderPos).Magnitude
                                    end)
                                else
                                    table.sort(coins, function(a, b)
                                        return (a.Position - myPos).Magnitude < (b.Position - myPos).Magnitude
                                    end)
                                end
                            end
                        else
                            table.sort(coins, function(a, b)
                                return (a.Position - myPos).Magnitude < (b.Position - myPos).Magnitude
                            end)
                        end
                        if #coins > 0 then
                            hrp.Anchored = false
                            local targetCoin = coins[1]
                            local function vacuum()
                                if not firetouchinterest then return end
                                local h = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                                if not h then return end
                                for _, cn in ipairs(coins) do
                                    if cn.Parent and cn.Transparency < 1 and (h.Position - cn.Position).Magnitude < 14 then
                                        pcall(firetouchinterest, h, cn, 0)
                                        pcall(firetouchinterest, h, cn, 1)
                                    end
                                end
                            end
                            local reached = moveTo(targetCoin.CFrame, S.FastAutofarmSpeed or 20, function()
                                vacuum()
                                return targetCoin and targetCoin.Parent and targetCoin.Transparency < 1 and c and c.Parent and hum and hum.Health > 0
                            end)
                            vacuum()
                            -- Arrived ON it but it stayed -> can't collect (bag full / stuck) -> skip it.
                            if reached and targetCoin.Parent and targetCoin.Transparency < 1 then
                                skip[targetCoin] = true
                            end
                            task.wait(0.05)
                        else
                            -- Nothing left to collect -> simply wait; never anchor the HRP
                            -- because anchoring while bhop/speedglitch is active freezes the player
                            -- in mid-air permanently (the levitation bug).
                            if hrp.Anchored then hrp.Anchored = false end
                            task.wait(0.3)
                        end
                    else
                        skip = {}
                        local ch = LP.Character
                        local h = ch and ch:FindFirstChild("HumanoidRootPart")
                        if h and h.Anchored then h.Anchored = false end
                        task.wait(1)
                    end
                end)
            else
                skip = {}
                local ch = LP.Character
                local h = ch and ch:FindFirstChild("HumanoidRootPart")
                if h and h.Anchored then h.Anchored = false end
            end
            task.wait(0.05)
        end
    end)
end

-- ============ CONFIG SYSTEM (persist settings + HUD across launches) ============
-- Wrapped in a do-block to keep its locals out of the main chunk's 200-local budget.
do
local CfgHttp = game:GetService("HttpService")
local CFG_DIR = "MM2_Configs"
local FILE_OK = (writefile and readfile and isfile) and true or false
local configLoadedSuccessfully = false

local function _cfgEnsureDir()
    if not FILE_OK then return end
    pcall(function()
        if makefolder and isfolder and not isfolder(CFG_DIR) then makefolder(CFG_DIR) end
    end)
end

if FILE_OK then
    pcall(function()
        _cfgEnsureDir()
        if not isfile(CFG_DIR .. "/_autoload.json") then
            configLoadedSuccessfully = true
        end
    end)
end

local function _cfgSanitize(name)
    name = tostring(name or ""):gsub("[^%w _%-]", "")
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    return name
end
local function buildConfig()
    local data = {
        SelectedTheme = S.SelectedTheme,
        Language = S.Language,
        TextSizeScale = S.TextSizeScale, controls = {}, hud = {}, binds = {} }
    for _, c in ipairs(ConfigControls) do
        local ok, val = pcall(c.get)
        if ok and val ~= nil then data.controls[c.id] = val end
    end
    -- Persist HUD visibility and drag positions. Positions are restored with a viewport clamp below,
    -- so a layout saved at another resolution cannot strand an element permanently off-screen.
    for name, el in pairs(HUDEls) do
        local p = el.frame.Position
        data.hud[name] = {
            v = el.frame.Visible,
            p = { xs = p.X.Scale, xo = p.X.Offset, ys = p.Y.Scale, yo = p.Y.Offset },
        }
    end
    -- Keybinds: id (page/section/label) -> KeyCode name
    for _, e in ipairs(AllBinds) do
        if e.bindKey and e.cfgId then data.binds[e.cfgId] = e.bindKey.Name end
    end
    return data
end
local configApplying = false
local autoSaveRequestId = 0
-- Called by bind changes, toggles, and HUD drag-end events. Debouncing keeps rapid slider/UI
-- interactions from causing a disk write for every input event while still saving almost instantly.
S._RequestAutoSave = function()
    if not FILE_OK or not S.AutoSaveCfg or configApplying or not configLoadedSuccessfully then return end
    autoSaveRequestId = autoSaveRequestId + 1
    local requestId = autoSaveRequestId
    task.delay(0.15, function()
        if requestId ~= autoSaveRequestId or not FILE_OK or not S.AutoSaveCfg or configApplying or not configLoadedSuccessfully then return end
        pcall(function()
            local enc = CfgHttp:JSONEncode(buildConfig())
            _cfgEnsureDir()
            writefile(CFG_DIR .. "/_autoload.json", enc)
        end)
    end)
end
local function applyConfig(data)
    if type(data) ~= "table" then return end
    configApplying = true
    if type(data.controls) == "table" then
        for _, c in ipairs(ConfigControls) do
            local v = data.controls[c.id]
            if v ~= nil then pcall(function() c.set(v) end) end
        end
    end
    if type(data.hud) == "table" then
        -- "Pinned Emotes" keeps its visibility under the pin-list logic — forcing v=true here
        -- could show an empty tray — but its saved drag position is still restored.
        for name, h in pairs(data.hud) do
            local el = HUDEls[name]
            if el and type(h) == "table" then
                pcall(function()
                    if name ~= "Pinned Emotes" then el.frame.Visible = (h.v == true) end
                    local p = h.p
                    local xs, xo = p and tonumber(p.xs), p and tonumber(p.xo)
                    local ys, yo = p and tonumber(p.ys), p and tonumber(p.yo)
                    if xs and xo and ys and yo then
                        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
                        if vp and vp.X > 0 and vp.Y > 0 then
                            local fs = el.frame.AbsoluteSize
                            local w = math.max(fs.X, 20)
                            local hgt = math.max(fs.Y, 20)
                            local absX = math.clamp(vp.X * xs + xo, -math.max(w - 20, 0), vp.X - 20)
                            local absY = math.clamp(vp.Y * ys + yo, -math.max(hgt - 20, 0), vp.Y - 20)
                            xo = absX - vp.X * xs
                            yo = absY - vp.Y * ys
                        end
                        el.frame.Position = UDim2.new(xs, xo, ys, yo)
                    end
                end)
            end
        end
    end
    if type(data.binds) == "table" then
        for _, e in ipairs(AllBinds) do
            local keyName = e.cfgId and data.binds[e.cfgId]
            if keyName then
                pcall(function()
                    local kc = Enum.KeyCode[keyName]
                    if kc then
                        if e.bindKey then BindReg[e.bindKey] = nil end
                        e.bindKey = kc
                        BindReg[kc] = e
                        e.updateVisuals()
                    end
                end)
            end
        end
    end
    pcall(function() rebuildCrosshair() end)
    configApplying = false
end
local function saveConfig(name)
    name = _cfgSanitize(name)
    if name == "" then return false end
    if not FILE_OK then return false end
    _cfgEnsureDir()
    local ok, enc = pcall(function() return CfgHttp:JSONEncode(buildConfig()) end)
    if not ok then return false end
    return (pcall(function() writefile(CFG_DIR .. "/" .. name .. ".json", enc) end))
end
S.SaveConfig = saveConfig
local function loadConfig(name)
    name = _cfgSanitize(name)
    if not FILE_OK or name == "" then return false end
    local path = CFG_DIR .. "/" .. name .. ".json"
    if not isfile(path) then return false end
    local ok, content = pcall(function() return readfile(path) end)
    if not ok then return false end
    local ok2, data = pcall(function() return CfgHttp:JSONDecode(content) end)
    if not ok2 then return false end
    if name == "_autoload" and type(data.controls) == "table" then
        for k, v in pairs(data.controls) do
            local kl = k:lower()
            if kl:find("noclip") or kl:find("autofarm") or kl:find("fly") or kl:find("blink") or kl:find("invisible") or kl:find("fling") or kl:find("gravity") then
                data.controls[k] = false
            end
        end
    end
    applyConfig(data)
    if name == "_autoload" then
        configLoadedSuccessfully = true
    end
    return true
end
S.LoadConfig = loadConfig
local function deleteConfig(name)
    name = _cfgSanitize(name)
    if not FILE_OK or name == "" then return false end
    local path = CFG_DIR .. "/" .. name .. ".json"
    return (pcall(function() if isfile(path) and delfile then delfile(path) end end))
end
local function listConfigs()
    local out = {}
    if not FILE_OK or not listfiles then return out end
    _cfgEnsureDir()
    pcall(function()
        for _, path in ipairs(listfiles(CFG_DIR)) do
            local nm = tostring(path):match("([^/\\]+)%.json$")
            -- Every internal cache/data file this script writes to MM2_Configs (mesh cache, emotes
            -- cache, anim pack lists, server list, autoload) is prefixed with "_" by convention. Only
            -- user-typed config names (from the "config name..." box) are shown here — those never
            -- start with "_" in normal use, so this filters out everything that isn't an actual saved
            -- config someone chose to save, without needing a separate list of every internal filename.
            if nm and nm:sub(1, 1) ~= "_" then table.insert(out, nm) end
        end
    end)
    return out
end
do
    if not FILE_OK then
        local sec = mkSection(Pages.Config, "Configs", 1)
        local warn = Instance.new("TextLabel")
        warn.Parent = sec; warn.LayoutOrder = 1; warn.BackgroundTransparency = 1
        warn.Size = UDim2.new(1, 0, 0, 46); warn.Font = F; warn.TextSize = 13
        warn.TextColor3 = T.Tx2; pcall(function() warn:SetAttribute("ThemeColorRole_TextColor3", "Tx2") end); warn.TextWrapped = true
        warn.TextXAlignment = Enum.TextXAlignment.Left
        warn.Text = "This executor has no file API (writefile/readfile), so configs cannot be saved."
    else
        local sec1 = mkSection(Pages.Config, "Configs", 1)
        local nameBox = Instance.new("TextBox")
        nameBox.Parent = sec1; nameBox.LayoutOrder = 1
        nameBox.Size = UDim2.new(1, 0, 0, 30); nameBox.BackgroundColor3 = T.Elev; pcall(function() nameBox:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
        nameBox.BorderSizePixel = 0; nameBox.Font = F; nameBox.TextSize = 13
        nameBox.TextColor3 = T.Tx; pcall(function() nameBox:SetAttribute("ThemeColorRole_TextColor3", "Tx") end); nameBox.PlaceholderText = "config name..."
        nameBox.PlaceholderColor3 = T.Tx4; nameBox.Text = ""
        nameBox.ClearTextOnFocus = false; nameBox.TextXAlignment = Enum.TextXAlignment.Left
        Corner(nameBox, 6); Stroke(nameBox, T.Bd2, 1, 0.4); Pad(nameBox, 0, 0, 8, 8)
        local list = Instance.new("ScrollingFrame")
        list.Parent = sec1; list.LayoutOrder = 2
        list.Size = UDim2.new(1, 0, 0, 120); list.BackgroundColor3 = T.Card; pcall(function() list:SetAttribute("ThemeColorRole_BackgroundColor3", "Card") end)
        list.BorderSizePixel = 0; list.CanvasSize = UDim2.new(0, 0, 0, 0)
        list.AutomaticCanvasSize = Enum.AutomaticSize.Y; list.ScrollBarThickness = 3
        list.ScrollBarImageColor3 = T.Tx3; pcall(function() list:SetAttribute("ThemeColorRole_ScrollBarImageColor3", "Tx3") end)
        Corner(list, 8); Stroke(list, T.Bd, 1, 0.4)
        local ll = Instance.new("UIListLayout"); ll.Parent = list
        ll.SortOrder = Enum.SortOrder.Name; ll.Padding = UDim.new(0, 4)
        Pad(list, 6, 6, 6, 6)
        local selected = nil
        local function refreshList()
            for _, ch in pairs(list:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
            for _, nm in ipairs(listConfigs()) do
                local b = Instance.new("TextButton")
                b.Name = nm; b.Parent = list; b.Size = UDim2.new(1, 0, 0, 28)
                b.BackgroundColor3 = T.Elev; pcall(function() b:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end); b.BorderSizePixel = 0; b.AutoButtonColor = false
                b.Font = F; b.TextSize = 13; b.TextColor3 = T.Tx; pcall(function() b:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
                b.Text = "  " .. nm; b.TextXAlignment = Enum.TextXAlignment.Left
                Corner(b, 6)
                b.MouseButton1Click:Connect(function()
                    selected = nm; nameBox.Text = nm
                    for _, cb in pairs(list:GetChildren()) do if cb:IsA("TextButton") then cb.BackgroundColor3 = T.Elev; pcall(function() cb:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end) end end
                    b.BackgroundColor3 = T.ActiveBg; pcall(function() b:SetAttribute("ThemeColorRole_BackgroundColor3", "ActiveBg") end)
                end)
            end
        end
        refreshList()
        local function curName()
            local n = _cfgSanitize(nameBox.Text)
            if n == "" then n = selected end
            return n
        end
        mkAction(sec1, "Save Config", function()
            local n = _cfgSanitize(nameBox.Text)
            if n == "" then Notify("Config", "Enter a name first", 3); return end
            if saveConfig(n) then Notify("Config", "Saved: " .. n, 3); refreshList()
            else Notify("Config", "Save failed", 3) end
        end, 3)
        mkAction(sec1, "Load Config", function()
            local n = curName()
            if not n or n == "" then Notify("Config", "Select or type a name", 3); return end
            if loadConfig(n) then Notify("Config", "Loaded: " .. n, 3)
            else Notify("Config", "Load failed", 3) end
        end, 4)
        mkAction(sec1, "Delete Config", function()
            local n = curName()
            if not n or n == "" then Notify("Config", "Select a config", 3); return end
            deleteConfig(n); selected = nil; nameBox.Text = ""; refreshList()
            Notify("Config", "Deleted: " .. n, 3)
        end, 5)
        mkAction(sec1, "Refresh List", function() refreshList() end, 6)
        local sec2 = mkSection(Pages.Config, "Auto", 2)
        mkToggle(sec2, "Auto Save", true, function(v) S.AutoSaveCfg = v end, 1)
        local info = Instance.new("TextLabel")
        info.Parent = sec2; info.LayoutOrder = 2; info.BackgroundTransparency = 1
        info.Size = UDim2.new(1, 0, 0, 46); info.Font = F; info.TextSize = 12
        info.TextColor3 = T.Tx4; pcall(function() info:SetAttribute("ThemeColorRole_TextColor3", "Tx4") end); info.TextWrapped = true
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.Text = "Auto Save keeps settings, keybinds, HUD visibility and HUD positions; changes are saved immediately and restored on next launch."
    end
end
if FILE_OK then
    task.spawn(function()
        task.wait(1)
        pcall(function() if S.LoadConfig then S.LoadConfig("_autoload") end end)
    end)
    -- Periodic fallback: immediate save requests handle normal changes, while this loop catches any
    -- state mutation that happened outside a UI callback. Unchanged configs are still a no-op.
    task.spawn(function()
        local lastEnc = nil
        while S.Gui and S.Gui.Parent do
            task.wait(5)
            if S.AutoSaveCfg and configLoadedSuccessfully then
                pcall(function()
                    local enc = CfgHttp:JSONEncode(buildConfig())
                    if enc ~= lastEnc then
                        _cfgEnsureDir()
                        writefile(CFG_DIR .. "/_autoload.json", enc)
                        lastEnc = enc
                    end
                end)
            end
        end
    end)
end
end -- end CONFIG SYSTEM do-block
-- ============ SERVER LIST TAB (recent / saved / favourite servers, copy Job ID) ============
-- Wrapped in a do-block so its ~30 locals free up afterwards (200-local budget). Persists its
-- own list to MM2_Configs/_mm2_servers.json, independent of the settings configs, so saved and
-- favourited servers survive relaunches and config swaps.
do
    local TS = game:GetService("TeleportService")
    local HttpSvc = game:GetService("HttpService")
    local clip = setclipboard or toclipboard or writeclipboard or (syn and syn.write_clipboard)
    local SRV_FILE_OK = (writefile and readfile and isfile) and true or false
    local STORE_PATH = "MM2_Configs/_mm2_servers.json"

    local function ensureDir()
        if not SRV_FILE_OK then return end
        pcall(function() if makefolder and isfolder and not isfolder("MM2_Configs") then makefolder("MM2_Configs") end end)
    end

    -- store.saved  = { {id=jobId, label=name, fav=bool}, ... }
    -- store.recent = { {id=jobId, ts=epoch}, ... }  (newest first, capped)
    local store = { saved = {}, recent = {} }
    local function persist()
        if not SRV_FILE_OK then return end
        ensureDir()
        pcall(function() writefile(STORE_PATH, HttpSvc:JSONEncode(store)) end)
    end
    pcall(function()
        if SRV_FILE_OK and isfile(STORE_PATH) then
            local d = HttpSvc:JSONDecode(readfile(STORE_PATH))
            if type(d) == "table" then
                if type(d.saved) == "table" then store.saved = d.saved end
                if type(d.recent) == "table" then store.recent = d.recent end
            end
        end
    end)

    local function shortId(id) return tostring(id):sub(1, 8) end
    -- Roblox's public-servers API returns per-server `ping` (avg ms across its players) and
    -- `fps` (server tick rate). Country/region is NOT exposed per-server, only ping/fps are.
    local function srvMeta(srv)
        local png  = math.floor(tonumber(srv.ping) or 0)
        local pfps = math.floor(tonumber(srv.fps) or 0)
        local s = tostring(srv.playing) .. "/" .. tostring(srv.maxPlayers)
        if png  > 0 then s = s .. "  \u{00B7}  " .. png .. "ms" end
        if pfps > 0 then s = s .. "  \u{00B7}  " .. pfps .. "fps" end
        return s
    end
    local function isSaved(id)
        for _, s in ipairs(store.saved) do if s.id == id then return s end end
        return nil
    end
    local function pushRecent(id)
        if not id or id == "" then return end
        for i = #store.recent, 1, -1 do if store.recent[i].id == id then table.remove(store.recent, i) end end
        table.insert(store.recent, 1, { id = id, ts = os.time() })
        while #store.recent > 25 do table.remove(store.recent) end
        persist()
    end
    -- Record the server we're currently in, so it shows up under Recent next time too.
    pushRecent(game.JobId)

    local function copyId(id)
        if not id or id == "" then Notify("Servers", "No Job ID to copy", 2); return end
        if clip then pcall(clip, id); Notify("Servers", "Job ID copied to clipboard", 2)
        else Notify("Servers", "Executor has no clipboard API", 3) end
    end
    local function joinId(id)
        if not id or id == "" then Notify("Servers", "No Job ID", 2); return end
        if id == game.JobId then Notify("Servers", "Already in this server", 3); return end
        Notify("Servers", "Teleporting to server...", 3)
        pcall(function() TS:TeleportToPlaceInstance(game.PlaceId, id, LP) end)
    end
    local function addSaved(id, label)
        id = tostring(id or ""):gsub("%s", "")
        if id == "" then Notify("Servers", "Enter a Job ID first", 3); return false end
        if isSaved(id) then Notify("Servers", "That server is already saved", 2); return false end
        label = tostring(label or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if label == "" then label = "Server " .. shortId(id) end
        table.insert(store.saved, { id = id, label = label, fav = false })
        persist()
        Notify("Servers", "Saved: " .. label, 2)
        return true
    end
    local function removeSaved(id)
        for i = #store.saved, 1, -1 do if store.saved[i].id == id then table.remove(store.saved, i) end end
        persist()
    end
    local function toggleFav(id)
        local s = isSaved(id)
        if s then s.fav = not s.fav; persist() end
    end

    -- A list row: truncated text on the left + a strip of 26px action buttons on the right.
    -- buttons = { {text=, color=, cb=}, ... } laid out right-to-left.
    local function mkRow(parent, order, mainText, buttons)
        local n = #buttons
        local row = Instance.new("Frame")
        row.Name = "SrvRow"
        row.LayoutOrder = order
        row.Size = UDim2.new(1, 0, 0, 34)
        row.BackgroundColor3 = T.Elev; pcall(function() row:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
        row.BorderSizePixel = 0
        row.Parent = parent
        Corner(row, 6)
        local lbl = Instance.new("TextLabel")
        lbl.Parent = row
        lbl.BackgroundTransparency = 1
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.Size = UDim2.new(1, -14 - n * 30, 1, 0)
        lbl.Font = F
        lbl.TextSize = 12
        lbl.TextColor3 = T.Tx; pcall(function() lbl:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.Text = mainText
        for i, b in ipairs(buttons) do
            local btn = Instance.new("TextButton")
            btn.Parent = row
            btn.AnchorPoint = Vector2.new(1, 0.5)
            btn.Position = UDim2.new(1, -6 - (n - i) * 30, 0.5, 0)
            btn.Size = UDim2.fromOffset(26, 26)
            btn.BackgroundColor3 = T.Card; pcall(function() btn:SetAttribute("ThemeColorRole_BackgroundColor3", "Card") end)
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            btn.Font = FM
            btn.TextSize = 14
            btn.Text = b.text
            btn.TextColor3 = b.color or T.Tx
            Corner(btn, 6)
            local base = T.Card
            btn.MouseEnter:Connect(function() btn.BackgroundColor3 = T.Hover; pcall(function() btn:SetAttribute("ThemeColorRole_BackgroundColor3", "Hover") end) end)
            btn.MouseLeave:Connect(function() btn.BackgroundColor3 = base end)
            btn.MouseButton1Click:Connect(function() SFX.Click(); b.cb() end)
        end
        return row
    end
    local function mkScroll(parent, order, height)
        local sc = Instance.new("ScrollingFrame")
        sc.Parent = parent
        sc.LayoutOrder = order
        sc.Size = UDim2.new(1, 0, 0, height)
        sc.BackgroundColor3 = T.Card; pcall(function() sc:SetAttribute("ThemeColorRole_BackgroundColor3", "Card") end)
        sc.BorderSizePixel = 0
        sc.CanvasSize = UDim2.new(0, 0, 0, 0)
        sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sc.ScrollBarThickness = 3
        sc.ScrollBarImageColor3 = T.Tx3; pcall(function() sc:SetAttribute("ThemeColorRole_ScrollBarImageColor3", "Tx3") end)
        Corner(sc, 8)
        Stroke(sc, T.Bd, 1, 0.4)
        local ll = Instance.new("UIListLayout")
        ll.Parent = sc
        ll.SortOrder = Enum.SortOrder.LayoutOrder
        ll.Padding = UDim.new(0, 4)
        Pad(sc, 6, 6, 6, 6)
        return sc
    end
    local function clearRows(sc)
        for _, ch in ipairs(sc:GetChildren()) do if ch.Name == "SrvRow" then ch:Destroy() end end
    end
    local FAV_COLOR = Color3.fromRGB(255, 210, 80)
    local DEL_COLOR = Color3.fromRGB(240, 95, 95)

    -- Subtab bar (same pattern as Combat): Manage / Browse.
    local srvSubTabBar = Instance.new("Frame")
    srvSubTabBar.Name = "SubTabBar"
    srvSubTabBar.LayoutOrder = 0
    srvSubTabBar.BackgroundTransparency = 1
    srvSubTabBar.Size = UDim2.new(1, 0, 0, 32)
    srvSubTabBar.Parent = Pages.Servers

    local srvSubTabList = Instance.new("UIListLayout")
    srvSubTabList.FillDirection = Enum.FillDirection.Horizontal
    srvSubTabList.SortOrder = Enum.SortOrder.LayoutOrder
    srvSubTabList.Padding = UDim.new(0, 8)
    srvSubTabList.Parent = srvSubTabBar

    local manageBtn, browseBtn = Instance.new("TextButton"), Instance.new("TextButton")
    local manageStroke = mkSubTabBtn(srvSubTabBar, manageBtn, "Manage", 1)
    local browseStroke = mkSubTabBtn(srvSubTabBar, browseBtn, "Browse", 2)

    local manageSections = {}
    local activeSrvSubTab = "Manage"
    local function registerManage(sec)
        table.insert(manageSections, sec)
        if sec and sec.Parent then sec.Parent.Visible = (activeSrvSubTab == "Manage") end
    end
    local secBrowseRef -- set once "Browse Public Servers" is built below
    local function updateSrvSubTabs()
        local isManage = (activeSrvSubTab == "Manage")
        styleSubTabActive(manageBtn, manageStroke, isManage)
        styleSubTabActive(browseBtn, browseStroke, not isManage)
        for _, sec in ipairs(manageSections) do if sec and sec.Parent then sec.Parent.Visible = isManage end end
        if secBrowseRef and secBrowseRef.Parent then secBrowseRef.Parent.Visible = not isManage end
    end
    manageBtn.MouseButton1Click:Connect(function() SFX.Click(); activeSrvSubTab = "Manage"; updateSrvSubTabs() end)
    browseBtn.MouseButton1Click:Connect(function() SFX.Click(); activeSrvSubTab = "Browse"; updateSrvSubTabs() end)

    -- ---------- Current server ----------
    local secCur = mkSection(Pages.Servers, "Current Server", 1)
    registerManage(secCur)
    local idBox = Instance.new("TextBox")
    idBox.Parent = secCur
    idBox.LayoutOrder = 1
    idBox.Size = UDim2.new(1, 0, 0, 30)
    idBox.BackgroundColor3 = T.Elev; pcall(function() idBox:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
    idBox.BorderSizePixel = 0
    idBox.Font = F
    idBox.TextSize = 12
    idBox.TextColor3 = T.Tx; pcall(function() idBox:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
    idBox.Text = (game.JobId ~= "" and game.JobId) or "(no Job ID - Studio?)"
    idBox.ClearTextOnFocus = false
    idBox.TextEditable = false
    idBox.TextXAlignment = Enum.TextXAlignment.Left
    Corner(idBox, 6)
    Stroke(idBox, T.Bd2, 1, 0.4)
    Pad(idBox, 0, 0, 8, 8)

    -- Live region + ping readout for the server we're currently in. Roblox exposes no per-server
    -- country, so region is geolocated from THIS client's connection (best-effort); ping is the
    -- real live latency to the current server.
    local curInfo = Instance.new("TextLabel")
    curInfo.Parent = secCur
    curInfo.LayoutOrder = 2
    curInfo.BackgroundTransparency = 1
    curInfo.Size = UDim2.new(1, 0, 0, 18)
    curInfo.Font = F
    curInfo.TextSize = 12
    curInfo.TextColor3 = T.Tx3; pcall(function() curInfo:SetAttribute("ThemeColorRole_TextColor3", "Tx3") end)
    curInfo.TextXAlignment = Enum.TextXAlignment.Left
    curInfo.RichText = true
    curInfo.Text = "Region: \u{2026}   \u{00B7}   Ping: \u{2026}"

    local regionStr = "\u{2026}"
    task.spawn(function()
        local ok2, geo = pcall(function()
            return HttpSvc:JSONDecode(game:HttpGet("http://ip-api.com/json/?fields=country,countryCode"))
        end)
        if ok2 and type(geo) == "table" and geo.country then
            regionStr = tostring(geo.country) .. (geo.countryCode and (" (" .. tostring(geo.countryCode) .. ")") or "")
        else
            regionStr = "unavailable"
        end
    end)
    do
        local StatsSvc = game:FindService("Stats")
        task.spawn(function()
            while secCur and secCur.Parent do
                local png = 0
                pcall(function() png = math.floor(LP:GetNetworkPing() * 1000) end)
                if png == 0 and StatsSvc then
                    pcall(function() png = math.floor(StatsSvc.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                end
                local pcol = png < 90 and "#7ee787" or (png < 180 and "#e3b341" or "#ff7b72")
                curInfo.Text = string.format(
                    'Region: <font color="#d0d0d0">%s</font>   \u{00B7}   Ping: <font color="%s">%d ms</font>',
                    regionStr, pcol, png)
                task.wait(2)
            end
        end)
    end

    mkAction(secCur, "Copy Current Job ID", function() copyId(game.JobId) end, 3)

    -- forward declarations so the buttons below can refresh the lists
    local refreshSaved, refreshRecent

    mkAction(secCur, "Save This Server", function()
        if addSaved(game.JobId, "Server " .. shortId(game.JobId)) then refreshSaved() end
    end, 4)
    mkAction(secCur, "Rejoin This Server", function() joinId(game.JobId) end, 5)

    -- ---------- Add server by Job ID ----------
    local secAdd = mkSection(Pages.Servers, "Add Server", 2)
    registerManage(secAdd)
    local addId = Instance.new("TextBox")
    addId.Parent = secAdd
    addId.LayoutOrder = 1
    addId.Size = UDim2.new(1, 0, 0, 30)
    addId.BackgroundColor3 = T.Elev; pcall(function() addId:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
    addId.BorderSizePixel = 0
    addId.Font = F
    addId.TextSize = 12
    addId.TextColor3 = T.Tx; pcall(function() addId:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
    addId.PlaceholderText = "Job ID (paste here)..."
    addId.PlaceholderColor3 = T.Tx4
    addId.Text = ""
    addId.ClearTextOnFocus = false
    addId.TextXAlignment = Enum.TextXAlignment.Left
    Corner(addId, 6)
    Stroke(addId, T.Bd2, 1, 0.4)
    Pad(addId, 0, 0, 8, 8)
    local addName = Instance.new("TextBox")
    addName.Parent = secAdd
    addName.LayoutOrder = 2
    addName.Size = UDim2.new(1, 0, 0, 30)
    addName.BackgroundColor3 = T.Elev; pcall(function() addName:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
    addName.BorderSizePixel = 0
    addName.Font = F
    addName.TextSize = 12
    addName.TextColor3 = T.Tx; pcall(function() addName:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
    addName.PlaceholderText = "Label (optional)..."
    addName.PlaceholderColor3 = T.Tx4
    addName.Text = ""
    addName.ClearTextOnFocus = false
    addName.TextXAlignment = Enum.TextXAlignment.Left
    Corner(addName, 6)
    Stroke(addName, T.Bd2, 1, 0.4)
    Pad(addName, 0, 0, 8, 8)
    mkAction(secAdd, "Add to Saved", function()
        if addSaved(addId.Text, addName.Text) then addId.Text = ""; addName.Text = ""; refreshSaved() end
    end, 3)
    mkAction(secAdd, "Join Entered Job ID", function() joinId((addId.Text or ""):gsub("%s", "")) end, 4)

    -- ---------- Saved servers (favourites float to the top) ----------
    local secSaved = mkSection(Pages.Servers, "Saved Servers", 3)
    registerManage(secSaved)
    local savedScroll = mkScroll(secSaved, 1, 168)
    local savedEmpty = Instance.new("TextLabel")
    savedEmpty.Parent = secSaved
    savedEmpty.LayoutOrder = 2
    savedEmpty.BackgroundTransparency = 1
    savedEmpty.Size = UDim2.new(1, 0, 0, 18)
    savedEmpty.Font = F
    savedEmpty.TextSize = 12
    savedEmpty.TextColor3 = T.Tx4; pcall(function() savedEmpty:SetAttribute("ThemeColorRole_TextColor3", "Tx4") end)
    savedEmpty.TextXAlignment = Enum.TextXAlignment.Left
    savedEmpty.Text = "★ = favourite (kept at top).  → join   ⧉ copy   ✕ remove"
    refreshSaved = function()
        clearRows(savedScroll)
        local arr = {}
        for _, s in ipairs(store.saved) do table.insert(arr, s) end
        table.sort(arr, function(a, b)
            local fa, fb = a.fav and 1 or 0, b.fav and 1 or 0
            if fa ~= fb then return fa > fb end
            return tostring(a.label):lower() < tostring(b.label):lower()
        end)
        for i, s in ipairs(arr) do
            local prefix = s.fav and "★ " or ""
            mkRow(savedScroll, i, prefix .. tostring(s.label) .. "   ·   " .. shortId(s.id), {
                { text = s.fav and "★" or "☆", color = FAV_COLOR, cb = function() toggleFav(s.id); refreshSaved() end },
                { text = "\u{2192}", color = T.Tx, cb = function() joinId(s.id) end },
                { text = "\u{29C9}", color = T.Tx, cb = function() copyId(s.id) end },
                { text = "\u{2715}", color = DEL_COLOR, cb = function() removeSaved(s.id); refreshSaved() end },
            })
        end
    end

    -- ---------- Recent servers (auto-recorded across sessions) ----------
    local secRecent = mkSection(Pages.Servers, "Recent Servers", 4)
    registerManage(secRecent)
    local recentScroll = mkScroll(secRecent, 1, 140)
    refreshRecent = function()
        clearRows(recentScroll)
        for i, r in ipairs(store.recent) do
            local here = (r.id == game.JobId) and "  (here)" or ""
            mkRow(recentScroll, i, shortId(r.id) .. here, {
                { text = "\u{2192}", color = T.Tx, cb = function() joinId(r.id) end },
                { text = "\u{29C9}", color = T.Tx, cb = function() copyId(r.id) end },
                { text = "\u{002B}", color = FAV_COLOR, cb = function() if addSaved(r.id) then refreshSaved() end end },
            })
        end
    end
    mkAction(secRecent, "Clear Recent", function()
        store.recent = {}
        pushRecent(game.JobId) -- keep the current one
        refreshRecent()
    end, 2)

    -- ---------- Browse public servers ----------
    local secBrowse = mkSection(Pages.Servers, "Browse Public Servers", 5)
    secBrowseRef = secBrowse
    updateSrvSubTabs()
    local browseScroll = mkScroll(secBrowse, 1, 168)
    local function fetchServers()
        clearRows(browseScroll)
        mkRow(browseScroll, 1, "Fetching servers...", {})
        task.spawn(function()
            local ok, res = pcall(function()
                return HttpSvc:JSONDecode(game:HttpGet(
                    "https://games.roblox.com/v1/games/" .. game.PlaceId ..
                    "/servers/Public?sortOrder=Desc&limit=100"))
            end)
            clearRows(browseScroll)
            if ok and res and type(res.data) == "table" and #res.data > 0 then
                -- lowest-ping servers first; servers with no reported ping sink to the bottom
                table.sort(res.data, function(a, b)
                    local pa = tonumber(a.ping) or 0
                    local pb = tonumber(b.ping) or 0
                    if (pa > 0) ~= (pb > 0) then return pa > 0 end
                    if pa ~= pb then return pa < pb end
                    return (tonumber(a.playing) or 0) < (tonumber(b.playing) or 0)
                end)
                local order = 0
                for _, srv in ipairs(res.data) do
                    if type(srv) == "table" and srv.id and srv.playing and srv.maxPlayers then
                        order = order + 1
                        local here = (srv.id == game.JobId) and "  (here)" or ""
                        mkRow(browseScroll, order,
                            srvMeta(srv) .. "   \u{00B7}   " .. shortId(srv.id) .. here, {
                            { text = "\u{2192}", color = T.Tx, cb = function() joinId(srv.id) end },
                            { text = "\u{29C9}", color = T.Tx, cb = function() copyId(srv.id) end },
                            { text = "\u{002B}", color = FAV_COLOR, cb = function() if addSaved(srv.id) then refreshSaved() end end },
                        })
                    end
                end
                Notify("Servers", "Found " .. order .. " public servers", 2)
            else
                mkRow(browseScroll, 1, "No servers found (HTTP blocked?)", {})
            end
        end)
    end
    mkAction(secBrowse, "Fetch Server List", function() fetchServers() end, 2)
    mkAction(secBrowse, "Join Smallest Server", function()
        task.spawn(function()
            local ok, res = pcall(function()
                return HttpSvc:JSONDecode(game:HttpGet(
                    "https://games.roblox.com/v1/games/" .. game.PlaceId ..
                    "/servers/Public?sortOrder=Asc&limit=100"))
            end)
            if ok and res and type(res.data) == "table" then
                for _, srv in ipairs(res.data) do
                    if type(srv) == "table" and srv.id and srv.playing and srv.maxPlayers
                        and srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
                        joinId(srv.id); return
                    end
                end
            end
            Notify("Servers", "No joinable server found", 3)
        end)
    end, 3)

    refreshSaved()
    refreshRecent()
    if not SRV_FILE_OK then
        Notify("Servers", "No file API: saved servers won't persist after you close", 4)
    end
end
local RH = Instance.new("TextButton")
RH.Name = "Resize"
RH.Parent = Main
RH.Size = UDim2.new(0, 18, 0, 18)
RH.Position = UDim2.new(1, -18, 1, -18)
RH.BackgroundTransparency = 1
RH.Text = ""
RH.ZIndex = 1005
for k = 1, 3 do
    local ln = Instance.new("Frame")
    ln.Parent = RH
    ln.BorderSizePixel = 0
    ln.BackgroundColor3 = T.Tx3; pcall(function() ln:SetAttribute("ThemeColorRole_BackgroundColor3", "Tx3") end)
    ln.Rotation = -45
    ln.ZIndex = 1005
    ln.Size = UDim2.new(0, 12 - (k-1)*4, 0, 1.5)
    ln.Position = UDim2.new(0, 3 + (k-1)*2.5, 0, 10 + (k-1)*2.5)
end
do
    local rs, rm, rz
    RH.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            rs = true
            rm = i.Position
            rz = Main.AbsoluteSize
        end
    end)
    tc(UIS.InputChanged:Connect(function(i)
        if rs and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - rm
            expandedSize = UDim2.fromOffset(math.max(460, rz.X + d.X), math.max(310, rz.Y + d.Y))
            Main.Size = expandedSize
        end
    end))
    tc(UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            rs = false
        end
    end))
end
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    SFX.Click()
    minimized = not minimized
    if minimized then
        for _, pg in pairs(Pages) do pg.Visible = false end
        SB.Visible = false
        SBLine.Visible = false
        ContentArea.Visible = false
        StatusBar.Visible = false
        RH.Visible = false
        TweenService.Create(TweenService, Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = UDim2.fromOffset(Main.AbsoluteSize.X, 42)
        }):Play()
    else
        TweenService.Create(TweenService, Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = expandedSize
        }):Play()
        task.wait(0.2)
        SB.Visible = true
        SBLine.Visible = true
        ContentArea.Visible = true
        StatusBar.Visible = true
        RH.Visible = true
        activePage.Visible = true
        refreshSB()
    end
end)
CloseBtn.MouseButton1Click:Connect(function()
    TweenService.Create(TweenService, Main, TweenInfo.new(0.2), { Size = UDim2.fromOffset(0, 0) }):Play()
    task.wait(0.22)
    S:Destroy()
end)
tc(UIS.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == Enum.KeyCode.LeftControl then
        Main.Visible = not Main.Visible
    end
end))
-- fillT/outlineT are optional overrides (0..1) for callers that need a specific Fill/Outline/Both
-- look (e.g. Item Chams' Mode setting); omitted, it falls back to the original role-cham behavior
-- (opacity from the Chams Opacity slider, solid outline).
createHighlight = function(adornee, color, name, fillT, outlineT)
    -- IDEMPOTENT (freeze fix): if this adornee already has a highlight with this name, reuse it and
    -- just refresh its properties. The old version made a BRAND-NEW Highlight on every call, so any
    -- caller that ran per-frame without its own dedupe check (e.g. the KnifeChams loop) spawned a
    -- fresh Highlight every frame — an instance leak that piled up until the game stuttered/froze.
    local hl = adornee:FindFirstChild(name)
    if not (hl and hl:IsA("Highlight")) then
        hl = Instance.new("Highlight")
        hl.Name = name
        hl.Adornee = adornee
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = adornee
    end
    hl.FillColor = color
    hl.FillTransparency = fillT or (1 - (S.ChamsOpacity or 50) / 100)
    hl.OutlineColor = color
    hl.OutlineTransparency = outlineT or 0
    return hl
end
-- Item Chams styling (gun held + gun drop share one look): Mode picks Outline/Fill/Both via
-- fill/outline transparency pairs, Color picks from the same palette FOV/Crosshair/Fog already use,
-- Rainbow overrides Color with a cycling hue exactly like RainbowFOV etc. do elsewhere in this file.
-- Wrapped in its own do-block and hung off S (not a new top-level local) for the same reason as
-- S._resetMyCharacter above: the main chunk was already at Luau's 200-local ceiling.
do
    local ITEM_CHAM_TRANSPARENCY = {
        Outline = { fill = 1,   outline = 0 },
        Fill    = { fill = 0.4, outline = 1 },
        Both    = { fill = 0.4, outline = 0 },
    }
    S._getItemChamStyle = function()
        local color = S.ItemChamsRainbow and Color3.fromHSV((tick() * 0.25) % 1, 0.8, 1)
            or FOV_COLORS[S.ItemChamsColor] or Color3.fromRGB(255, 128, 0)
        local t = ITEM_CHAM_TRANSPARENCY[S.ItemChamsMode] or ITEM_CHAM_TRANSPARENCY.Outline
        return color, t.fill, t.outline
    end
end
-- ===== ROLE TRACKING (event-driven — NO per-frame / repeated blocking InvokeServer) =====
do
    local notified = false
    
    local function processData(data)
        if type(data) ~= "table" then return end
        local fm, fs, hasRole = nil, nil, false
        for pn, pd in pairs(data) do
            if type(pd) == "table" and pd.Role then
                RoleCache[pn] = pd.Role
                if pd.Role == "Murderer" then fm = pn; hasRole = true end
                if pd.Role == "Sheriff" then
                    fs = pn
                    hasRole = true
                    if not OriginalSheriff then
                        OriginalSheriff = pn
                    end
                end
                if pd.Role == "Hero" then
                    hasRole = true
                    -- Only a LIVE hero may become CurrentHero. The server keeps DEAD past heroes
                    -- tagged Role="Hero" forever (sticky — never cleared on death), so over a round
                    -- where the gun changed hands more than once, several Hero tags coexist in the
                    -- data. The old code set CurrentHero to whichever Hero pairs() happened to visit
                    -- LAST (arbitrary order) — it could latch onto a CORPSE. Then getRole's stale-Hero
                    -- check (cached=="Hero" and CurrentHero~=name -> Innocent) collapsed the REAL new
                    -- gun-holder to Innocent, so an innocent who just picked up the gun showed green
                    -- instead of blue. Filtering to alive (Dead ~= true) makes iteration order
                    -- irrelevant: exactly one Hero can hold the single Gun Tool, so exactly one is alive.
                    if pd.Dead ~= true then CurrentHero = pn end
                end
            end
            if type(pd) == "table" and (pd.Gun or pd.Knife) then
                GearCache[pn] = { Gun = pd.Gun, Knife = pd.Knife }
            end
        end
        if hasRole then LastRoundHadRoles = true end
        if fm and not notified then
            notified = true
            Notify("Murderer: "..fm, "Sheriff: "..(fs or "?"), 5)
        end
    end

    local rs = game:GetService("ReplicatedStorage")
    local changedEvent = rs:FindFirstChild("PlayerDataChanged", true)
    if changedEvent and changedEvent:IsA("RemoteEvent") then
        tc(changedEvent.OnClientEvent:Connect(processData))
    end
    task.spawn(function()
        local rem = rs:FindFirstChild("GetCurrentPlayerData", true) or rs:FindFirstChild("GetPlayerData", true)
        if rem then
            local ok, data = pcall(function() return rem:InvokeServer() end)
            if ok then processData(data) end
        end
    end)

    -- Автоматический сброс ролей при завершении раунда (исчезновении папки Normal)
    local wasRoundActive = false
    tc(RunService.Heartbeat:Connect(function()
        local active = (workspace:FindFirstChild("Normal") ~= nil)
        if not active and wasRoundActive then
            RoleCache = {}
            OriginalSheriff = nil
            CurrentHero = nil
            notified = false
        end
        wasRoundActive = active
    end))

    -- RESTORED (2026-07-17): this function was found partially overwritten by an old, WRONG
    -- weapon-sniffing-first implementation (probably from a botched edit earlier in the session) —
    -- the corruption left the tail of THIS correct version dangling as dead code a few hundred lines
    -- below, which is how it was rediscovered. Live-verified in an earlier session: MM2 does NOT keep
    -- the Knife/Gun as a findable child of Character/Backpack in the current build for OTHER players
    -- (a live scan of all 12 players during an active round found zero), so weapon-sniffing as the
    -- PRIMARY signal silently returns "Innocent" for everyone, including the murderer — the exact bug
    -- this file spent a whole session chasing before. Trust RoleCache (fed live by PlayerDataChanged)
    -- first; weapon-sniff only as a fallback before the remote has answered.
    getRole = function(player)
        if not isRoundActive() then return "Innocent" end
        if not (player and player.Parent) then return "Innocent" end

        local c = player.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        local alive = hum and hum.Health > 0
        if not alive then return "Innocent" end

        -- 1. Direct tool check on Character (always authoritative & instant for active weapons in hand)
        if c then
            if c:FindFirstChild("Knife") or c:FindFirstChild("KnifeServer") then
                return "Murderer"
            end
            local gunTool = c:FindFirstChild("Gun") or c:FindFirstChild("Revolver")
            if gunTool then
                if RoleCache[player.Name] == "Sheriff" or player.Name == OriginalSheriff then
                    return "Sheriff"
                else
                    return "Hero"
                end
            end
        end

        -- 2. Direct tool check in Backpack
        local bp = player:FindFirstChild("Backpack")
        if bp then
            if bp:FindFirstChild("Knife") or bp:FindFirstChild("KnifeServer") then
                return "Murderer"
            end
            local gunTool = bp:FindFirstChild("Gun") or bp:FindFirstChild("Revolver")
            if gunTool then
                if RoleCache[player.Name] == "Sheriff" or player.Name == OriginalSheriff then
                    return "Sheriff"
                else
                    return "Hero"
                end
            end
        end

        -- 3. Server-authoritative RoleCache (when weapon is unequipped or not visible in character/backpack)
        local cached = RoleCache[player.Name]
        if cached then
            if cached == "Murderer" then
                return "Murderer"
            elseif cached == "Sheriff" then
                return "Sheriff"
            elseif cached == "Hero" then
                return "Hero"
            end
        end

        return "Innocent"
    end
end

-- Auto Grab Gun: move to a dropped Sheriff gun and fire the touch pair immediately. The old
-- implementation waited 0.1 s, which made a manual pickup lose races. Auto mode now retries on
-- Heartbeat until the gun is actually in the backpack/character; the bind uses the same fast path.
local cachedGunDrop = nil
local lastGunDropScan = 0
local gunGrabLoopToken = 0
local function findGunDrop()
    if cachedGunDrop and cachedGunDrop.Parent then
        if cachedGunDrop:IsA("BasePart") or cachedGunDrop:FindFirstChildWhichIsA("BasePart", true) then
            return cachedGunDrop
        end
        cachedGunDrop = nil
    end
    cachedGunDrop = workspace:FindFirstChild("GunDrop")
    if cachedGunDrop then return cachedGunDrop end
    -- The normal MM2 drop is a direct Workspace child. Recursive fallback is throttled and is
    -- only needed for map variants that nest the drop under a folder/model.
    local now = tick()
    if now - lastGunDropScan >= 0.1 then
        lastGunDropScan = now
        cachedGunDrop = workspace:FindFirstChild("GunDrop", true)
    end
    return cachedGunDrop
end
local function hasGunInHandOrBackpack()
    local c, bp = LP.Character, LP:FindFirstChild("Backpack")
    return (c and (c:FindFirstChild("Gun") or c:FindFirstChild("Revolver")))
        or (bp and (bp:FindFirstChild("Gun") or bp:FindFirstChild("Revolver")))
end
local function grabGun(dropInst, announce)
    if not (dropInst and dropInst.Parent) then return false end
    local part = dropInst:IsA("BasePart") and dropInst or dropInst:FindFirstChildWhichIsA("BasePart", true)
    if not part then return false end
    local c = LP.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    -- One direct CFrame jump to the drop, immediate touch, then restore the exact original CFrame.
    -- There is intentionally no wait: the automatic Heartbeat retry handles the rare case where the
    -- server has not accepted the first touch yet, while the player never stays at the gun.
    local oldCFrame = hrp.CFrame
    local oldLinearVelocity = hrp.AssemblyLinearVelocity
    local oldAngularVelocity = hrp.AssemblyAngularVelocity
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = part.CFrame + Vector3.new(0, 1.25, 0)
    if firetouchinterest then
        pcall(firetouchinterest, hrp, part, 0)
        pcall(firetouchinterest, hrp, part, 1)
    end
    if hrp.Parent then
        hrp.CFrame = oldCFrame
        hrp.AssemblyLinearVelocity = oldLinearVelocity
        hrp.AssemblyAngularVelocity = oldAngularVelocity
    end
    if announce then Notify("Grab Gun", "Gun pickup triggered", 2) end
    return true
end
-- Fires a tight, no-yield burst of grab attempts (same-frame, zero real delay between them) instead of
-- a single try — this is genuinely the fastest a client script can act: no wait() between attempts, no
-- waiting for a frame boundary, just repeated CFrame-snap + firetouchinterest pairs back to back. Bounded
-- to a small fixed count so it can't hang; stops the instant the gun is actually ours.
local function burstGrabGun(dropInst, announce)
    for _ = 1, 8 do
        if hasGunInHandOrBackpack() then return true end
        pcall(grabGun, dropInst, false)
    end
    local got = hasGunInHandOrBackpack()
    if got and announce then Notify("Grab Gun", "Gun pickup triggered", 2) end
    return got
end
local function startGunGrabLoop(dropInst)
    gunGrabLoopToken = gunGrabLoopToken + 1
    local token = gunGrabLoopToken
    local deadline = tick() + 0.6
    task.spawn(function()
        -- A bounded burst is important: if the server rejects a stale/invalid drop, an endless
        -- CFrame loop would keep snapping the player back and look like movement is frozen.
        -- This loop is the fallback for when the drop wasn't grabbable yet on the initial burst
        -- (e.g. not fully replicated); the per-iteration burst keeps every retry maximally fast too.
        while S.AutoGrabGun and token == gunGrabLoopToken and S.Gui and S.Gui.Parent and tick() < deadline do
            if hasGunInHandOrBackpack() then break end
            local drop = dropInst
            if not (drop and drop.Parent) then drop = findGunDrop() end
            if not drop then break end
            if burstGrabGun(drop, false) then break end
            RunService.Heartbeat:Wait()
        end
    end)
end

-- Public action used by the Misc button and by its user-assigned keyboard bind.
S.GrabGunNow = function(silent)
    if S.AutoGrabGun then startGunGrabLoop() end
    if hasGunInHandOrBackpack() then
        if not silent then Notify("Grab Gun", "You already have the gun", 2) end
        return true
    end
    local drop = findGunDrop()
    if drop then
        if burstGrabGun(drop, not silent) then return true end
    end
    if not silent then Notify("Grab Gun", "No dropped gun found", 2) end
    return false
end

tc(workspace.DescendantAdded:Connect(function(ch)
    if ch.Name == "GunDrop" then
        cachedGunDrop = ch
        if S.GunNotify then Notify("Gun Dropped", "Sheriff killed, gun on floor", 5) end
        if S.AutoGrabGun then
            burstGrabGun(ch, false)
            startGunGrabLoop(ch)
        end
    end
end))
tc(workspace.DescendantRemoving:Connect(function(ch)
    if ch == cachedGunDrop then cachedGunDrop = nil end
end))
if S.AutoGrabGun then startGunGrabLoop() end

-- ===== IY FLING ENGINE (ported from the Infinite Yield reference file — New Text Document.txt) =====
-- Core = IY 'fling': every body part gets heavy CustomPhysicalProperties(100, 0.3, 0.5), noclip goes
-- on, a BodyAngularVelocity (0,99999,0 / MaxTorque (0,inf,0) / P=inf) is parked on the root and pulsed
-- (0.2s on, 0.1s off) exactly like IY does — the pulsing re-assertion is what actually launches anyone
-- your spinning body touches. The old Epix skidFling only ever SPUN the target without launching them;
-- targeted flings now start this same IY spin, teleport your root INTO the victim until their velocity
-- spikes, then teleport you back and restore everything.
-- NOTE: the whole engine lives in this do-block ON PURPOSE — Luau caps a chunk at 200 local registers,
-- and these locals at top level pushed the file over the limit ("Out of local registers ... clickPack").
do
local iyFlinging = false
local iySpinBAV, iyDiedConn = nil, nil
local iyPulseToken = 0
local iyNoClipWasOn = false
local iyPartState = {}

local function stopIYFling()
    iyPulseToken = iyPulseToken + 1
    if not iyFlinging then return end
    iyFlinging = false
    S.TouchFling = false
    if iyDiedConn then pcall(function() iyDiedConn:Disconnect() end); iyDiedConn = nil end
    if iySpinBAV then pcall(function() iySpinBAV:Destroy() end); iySpinBAV = nil end
    local c = LP.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if root then
        for _, v in ipairs(root:GetChildren()) do
            if v.ClassName == "BodyAngularVelocity" then pcall(function() v:Destroy() end) end
        end
        pcall(function()
            root.Velocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    for part, state in pairs(iyPartState) do
        if part and part.Parent then
            pcall(function()
                part.CustomPhysicalProperties = state.Props
                part.CanCollide = state.CanCollide
                part.Massless = state.Massless
            end)
        end
    end
    iyPartState = {}
    S.NoClip = iyNoClipWasOn
end

local function startIYFling()
    if iyFlinging then return true end
    local c = LP.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if not (c and hum and root and hum.Health > 0) then return false end

    iyPartState = {}
    for _, child in ipairs(c:GetDescendants()) do
        if child:IsA("BasePart") then
            iyPartState[child] = {
                Props = child.CustomPhysicalProperties,
                CanCollide = child.CanCollide,
                Massless = child.Massless,
            }
            pcall(function() child.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5) end)
        end
    end

    iyNoClipWasOn = S.NoClip == true
    S.NoClip = true
    task.wait(0.1)

    iyFlinging = true
    iyDiedConn = tc(hum.Died:Connect(stopIYFling))

    iyPulseToken = iyPulseToken + 1
    local myToken = iyPulseToken
    task.spawn(function()
        local movel = 0.1
        while iyFlinging and myToken == iyPulseToken do
            RunService.Heartbeat:Wait()
            local character = LP.Character
            local r = character and character:FindFirstChild("HumanoidRootPart")
            while iyFlinging and myToken == iyPulseToken and not (character and character.Parent and r and r.Parent) do
                RunService.Heartbeat:Wait()
                character = LP.Character
                r = character and character:FindFirstChild("HumanoidRootPart")
            end
            if not (iyFlinging and myToken == iyPulseToken) then break end

            local vel = r.Velocity
            pcall(function() r.Velocity = vel * 10000 + Vector3.new(0, 10000, 0) end)

            RunService.RenderStepped:Wait()
            if iyFlinging and myToken == iyPulseToken and character.Parent and r.Parent then
                pcall(function() r.Velocity = vel end)
            end

            RunService.Stepped:Wait()
            if iyFlinging and myToken == iyPulseToken and character.Parent and r.Parent then
                pcall(function() r.Velocity = vel + Vector3.new(0, movel, 0) end)
                movel = movel * -1
            end
        end
    end)
    return true
end

-- Targeted fling: IY spin + ride inside the victim until they're launched, then come home.
-- FallenPartsDestroyHeight is NaN'd for the duration so nobody void-dies mid-throw.
local flingBusy = false
local function flingPlayer(target)
    if flingBusy then return false end
    local c = LP.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if not (c and hum and root and hum.Health > 0) then return false end
    local tchar = target and target.Character
    local thum = tchar and tchar:FindFirstChildOfClass("Humanoid")
    local troot = tchar and tchar:FindFirstChild("HumanoidRootPart")
    if not (thum and thum.Health > 0 and troot) then return false end

    flingBusy = true
    local oldCF = root.CFrame
    local origFPDH = workspace.FallenPartsDestroyHeight
    local ownSpin = not iyFlinging
    local flung = false
    pcall(function()
        workspace.FallenPartsDestroyHeight = 0 / 0 -- NaN
        if ownSpin and not startIYFling() then return end
        
        local deadline = tick() + 3
        local lastT = tick()
        repeat
            tchar = target.Character
            troot = tchar and tchar:FindFirstChild("HumanoidRootPart")
            local thum = tchar and tchar:FindFirstChildOfClass("Humanoid")
            if not (troot and thum and thum.Health > 0) then break end
            
            -- Teleport directly onto target with velocity leading
            local lead = troot.AssemblyLinearVelocity * 0.045
            root.CFrame = troot.CFrame * CFrame.new(0, 0, 0) + lead
            task.wait()
            flung = troot and troot.Parent and troot.AssemblyLinearVelocity.Magnitude > 900
        until flung or tick() > deadline or hum.Health <= 0
    end)
    if ownSpin and not S.TouchFling then stopIYFling() end
    -- ALWAYS bring yourself back to where you started
    pcall(function()
        local returnT = tick()
        repeat
            root.CFrame = oldCF
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            task.wait()
        until (root.Position - oldCF.Position).Magnitude < 15 or tick() > returnT + 1.5
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    end)
    pcall(function() workspace.FallenPartsDestroyHeight = origFPDH end)
    pcall(function() workspace.CurrentCamera.CameraSubject = hum end)
    flingBusy = false
    return flung
end

-- Fling All: every alive, non-whitelisted player, one after another.
local function flingAll()
    task.spawn(function()
        local targets = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and not isWhitelisted(p) then
                local h = p.Character:FindFirstChildOfClass("Humanoid")
                if h and h.Health > 0 then targets[#targets + 1] = p end
            end
        end
        if #targets == 0 then Notify("Fling All", "No targets", 3); return end
        Notify("Fling All", "Flinging " .. #targets .. " players...", 2)
        local flung = 0
        for _, p in ipairs(targets) do
            local ok, res = pcall(flingPlayer, p)
            if ok and res then flung = flung + 1 end
            task.wait(0.1)
        end
        Notify("Fling All", "Flung " .. flung .. "/" .. #targets, 3)
    end)
end

-- Fling Murderer / Fling Sheriff: role comes from the same getRole used by silent aim/ESP.
local function flingRole(role)
    task.spawn(function()
        local target
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and not isWhitelisted(p) and getRole(p) == role then
                local h = p.Character:FindFirstChildOfClass("Humanoid")
                if h and h.Health > 0 then target = p; break end
            end
        end
        if not target then Notify("Fling " .. role, "No alive " .. role .. " found", 3); return end
        Notify("Fling " .. role, "Flinging " .. target.Name, 2)
        local ok, res = pcall(flingPlayer, target)
        Notify("Fling " .. role, (ok and res) and (target.Name .. " flung") or "Failed", 3)
    end)
end

skidFling = function(target) return flingPlayer(target) end
S._TouchSpinFling = skidFling
S._FlingPlayer = flingPlayer
S._FlingAll = flingAll
S._FlingRole = flingRole
S._TouchFlingToggle = function(enabled)
    if enabled then
        if not startIYFling() then S.TouchFling = false end
    else
        stopIYFling()
    end
end
S._IYFlingStop = stopIYFling
end

-- ===== WALK FLING (IY 'walkfling' / 'unwalkfling', ported as literally as possible) =====
-- Reference loop, verbatim: repeat RunService.Heartbeat:Wait() -> spike root.Velocity to
-- vel*10000 + (0,10000,0) -> RunService.RenderStepped:Wait() -> restore vel -> RunService.Stepped:Wait()
-- -> vel + alternating (0, ±0.1, 0) -> until walkflinging == false. No spin, no BodyAngularVelocity —
-- purely a per-frame velocity spike, so contact launches whoever you WALK INTO, while noclip (like the
-- reference's "noclip nonotify") keeps your own body from being shoved back by the impact.
do
local walkFlinging = false
local walkNoClipWasOn = false
local walkToken = 0
local walkDiedConn

local function stopWalkFling()
    walkFlinging = false
    walkToken = walkToken + 1
    if walkDiedConn then pcall(function() walkDiedConn:Disconnect() end); walkDiedConn = nil end
    S.NoClip = walkNoClipWasOn
    S.WalkFling = false
end

local function startWalkFling()
    if walkFlinging then return true end
    local c = LP.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if not (c and hum and root and hum.Health > 0) then return false end

    walkNoClipWasOn = S.NoClip == true
    S.NoClip = true
    walkFlinging = true
    S.WalkFling = true
    walkToken = walkToken + 1
    local myToken = walkToken
    walkDiedConn = tc(hum.Died:Connect(stopWalkFling))

    task.spawn(function()
        local movel = 0.1
        while walkFlinging and myToken == walkToken do
            RunService.Heartbeat:Wait()
            local character = LP.Character
            local r = character and character:FindFirstChild("HumanoidRootPart")
            while walkFlinging and myToken == walkToken and not (character and character.Parent and r and r.Parent) do
                RunService.Heartbeat:Wait()
                character = LP.Character
                r = character and character:FindFirstChild("HumanoidRootPart")
            end
            if not (walkFlinging and myToken == walkToken) then break end

            local vel = r.Velocity
            pcall(function() r.Velocity = vel * 10000 + Vector3.new(0, 10000, 0) end)

            RunService.RenderStepped:Wait()
            if walkFlinging and myToken == walkToken and character.Parent and r.Parent then
                pcall(function() r.Velocity = vel end)
            end

            RunService.Stepped:Wait()
            if walkFlinging and myToken == walkToken and character.Parent and r.Parent then
                pcall(function() r.Velocity = vel + Vector3.new(0, movel, 0) end)
                movel = movel * -1
            end
        end
    end)
    return true
end

S._WalkFlingToggle = function(enabled) if enabled then startWalkFling() else stopWalkFling() end end
S._WalkFlingStop = stopWalkFling
end

-- Compat aliases for older callers (config restores, unload path).
S._ReferenceFlingToggle = S._TouchFlingToggle
S._ReferenceWalkFlingToggle = S._WalkFlingToggle
S._ReferenceFlyFlingToggle = function() end
S._ReferenceInvisFlingToggle = function() end
S._StopReferenceFlings = function()
    if S._IYFlingStop then S._IYFlingStop() end
    if S._WalkFlingStop then S._WalkFlingStop() end
    S.Fling = false
    S.TouchFling = false
    S.WalkFling = false
    S.FlyFling = false
    S.InvisFling = false
end

-- Knife Aura REMOVED — it was a fully redundant duplicate of "Kill Aura" in the Murderer Aimbot
-- section (same 0.15s-interval range-kill pattern, same HandleTouched primitive, just a second
-- S.KnifeAura/KnifeAuraRange flag doing the identical job under a different name in a different
-- section). Kill Aura / Kill Aura Range (Combat > Murder > Murderer Aimbot) is the one surviving
-- control for this.

-- Touch Fling is the IY 'fling' spin itself (S._TouchFlingToggle above): while the toggle is on, your
-- character spins with the pulsed BodyAngularVelocity and ANYONE who touches/bumps you gets launched.
-- Walk Fling is the separate IY 'walkfling' velocity-spike loop (S._WalkFlingToggle). Both toggles'
-- state is per-character (BodyAngularVelocity / the Heartbeat loop's character reference), so if you
-- respawn while either is on, re-arm it on the new character automatically.
tc(LP.CharacterAdded:Connect(function(char)
    local wantTouch, wantWalk = S.TouchFling, S.WalkFling
    if not (wantTouch or wantWalk) then return end
    task.spawn(function()
        char:WaitForChild("HumanoidRootPart", 10)
        task.wait(0.5)
        if wantTouch and S.TouchFling and S._TouchFlingToggle then
            if S._IYFlingStop then S._IYFlingStop() end
            S.TouchFling = true
            S._TouchFlingToggle(true)
        end
        if wantWalk and S.WalkFling and S._WalkFlingToggle then
            if S._WalkFlingStop then S._WalkFlingStop() end
            S.WalkFling = true
            S._WalkFlingToggle(true)
        end
    end)
end))

local _antivoidBaseHeight = workspace.FallenPartsDestroyHeight
tc(RunService.RenderStepped:Connect(function()
    pcall(function()
        fpsCount = fpsCount + 1
        local now = tick()
        if now - lastFpsT >= 1 then
            curFPS = fpsCount
            fpsCount = 0
            lastFpsT = now
            StatusFPS.Text = "FPS  "..curFPS
            StatusFPS.TextColor3 = curFPS >= 30 and T.Tx or T.Tx2
            if HUD.fpsLbl and HUD.fpsLbl.Parent then
                HUD.fpsLbl.Text = tostring(curFPS)
                HUD.fpsLbl.TextColor3 = curFPS >= 30 and T.White or T.Tx2
            end
        end
        -- Role + ping labels don't need per-frame updates (getRole + Stats lookup every frame was
        -- needless CPU); refresh them 4x/sec instead.
        if now - lastStatusT >= 0.25 then
            lastStatusT = now
            local myRole = getRole(LP)
            StatusRole.Text = "ROLE  "..string.upper(myRole)
            StatusRole.TextColor3 = RoleShade[myRole] or T.Tx3
            pcall(function()
                local perf = game:GetService("Stats"):FindFirstChild("PerformanceStats")
                if perf then local ps = perf:FindFirstChild("Ping")
                    if ps then StatusPing.Text = "PING  "..math.floor(ps:GetValue()).."ms" end
                end
            end)
        end
        local mc = LP.Character
        if mc then local h = mc:FindFirstChildOfClass("Humanoid")
            if h then
                local ws = S.CustomWalkSpeed or 16
                if S.AutoSprint and ws < 24 then ws = 24 end
                if h.WalkSpeed ~= ws then h.WalkSpeed = ws end
                if S.CustomJumpPower and h.JumpPower ~= S.CustomJumpPower then h.UseJumpPower = true; h.JumpPower = S.CustomJumpPower end
            end
        end
        -- Anti-Fling (Infinite Yield method): disable collision on nearby players' character parts so
        -- their body can't push you. MUST run every frame, not throttled — a fling burst can slam
        -- 10,000+ studs/s of velocity into you in a SINGLE physics step, so the old 10x/sec (~100ms)
        -- poll left a window wide enough for one contact frame to already launch you before collision
        -- got disabled (root cause of "anti-fling barely works"). Scoped to players within 25 studs —
        -- only proximity matters for contact-based flinging — so the per-frame cost stays tiny even
        -- though it now runs at full framerate instead of 10Hz.
        if S.AntiFling then
            local myRoot = mc and mc:FindFirstChild("HumanoidRootPart")
            if myRoot then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LP and player.Character then
                        local r = player.Character:FindFirstChild("HumanoidRootPart")
                        if r and (r.Position - myRoot.Position).Magnitude <= 25 then
                            for _, v in pairs(player.Character:GetChildren()) do
                                if v:IsA("BasePart") and v.CanCollide then
                                    v.CanCollide = false
                                end
                            end
                        end
                    end
                end
            end
        end
        if S.AntiRagdoll then
            -- Never trip / ragdoll / fall over (from speed, flings, etc). Disable the states that
            -- cause it, keep the humanoid on its feet, and instantly get up if something forces it.
            local c = LP.Character; local hum = c and c:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function()
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
                    if hum.PlatformStand then hum.PlatformStand = false end
                    local st = hum:GetState()
                    if st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.Physics then
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end)
            end
        end
        if S.AntiVoid then
            -- Uses the map's own FallenPartsDestroyHeight so it adapts to any map,
            -- and launches you upward the instant you get close instead of catching
            -- you with a floating platform (which was too slow to react reliably).
            local c = LP.Character; if c and c:FindFirstChild("HumanoidRootPart") then local hrp = c.HumanoidRootPart
                -- Fire only while actually FALLING toward the void. Without the velocity check this
                -- re-triggered every frame for anyone standing in a low part of a map (random upward
                -- launches that looked like unexplained levitation).
                if hrp.Position.Y <= _antivoidBaseHeight + 50 and hrp.AssemblyLinearVelocity.Y < -10 then
                    hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 250, hrp.AssemblyLinearVelocity.Z)
                end
            end
        end
        if S.AutoEvade and (tick() - (S._lastEvade or 0)) >= 1 then
            -- If the Murderer gets within range, instantly hop yourself a safe distance directly away.
            local c = LP.Character; local hrp = c and c:FindFirstChild("HumanoidRootPart")
            if hrp then
                local range = S.AutoEvadeRange or 25
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and getRole(p) == "Murderer" then
                        local mhrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if mhrp and (mhrp.Position - hrp.Position).Magnitude < range then
                            S._lastEvade = tick()
                            local away = hrp.Position - mhrp.Position
                            if away.Magnitude < 0.1 then away = Vector3.new(1, 0, 0) end
                            hrp.CFrame = hrp.CFrame + away.Unit * 20
                            Notify("Auto Evade", "Fled from Murderer!", 2)
                            break
                        end
                    end
                end
            end
        end
        -- Noclip logic moved to RunService.Stepped connection for physics sync
        if S.Fly then local c = LP.Character; if c and c:FindFirstChild("HumanoidRootPart") then
            local hrp = c.HumanoidRootPart; local h = c:FindFirstChildOfClass("Humanoid")
            if not hrp:FindFirstChild("FlyBV") then
                local bv = Instance.new("BodyVelocity"); bv.Name = "FlyBV"; bv.MaxForce = Vector3.new(1e9,1e9,1e9); bv.Velocity = Vector3.zero; bv.Parent = hrp
                local bg = Instance.new("BodyGyro"); bg.Name = "FlyBG"; bg.MaxTorque = Vector3.new(1e9,1e9,1e9); bg.D = 100; bg.P = 10000; bg.CFrame = hrp.CFrame; bg.Parent = hrp
            end
            local bv, bg = hrp:FindFirstChild("FlyBV"), hrp:FindFirstChild("FlyBG")
            local cam = workspace.CurrentCamera; local spd = S.FlySpeed or 50; local md = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then md = md + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then md = md - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then md = md - cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then md = md + cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then md = md + Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then md = md - Vector3.new(0,1,0) end
            if md.Magnitude > 0 then md = md.Unit end
            bv.Velocity = md * spd; bg.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
            if h then h.PlatformStand = true end
        end end

        local showFOV = S.ShowFOV and S.FOVEnabled
        FOVCircle.Visible = showFOV
        if showFOV then
            FOVCircle.Size = UDim2.fromOffset(S.FOVRadius*2, S.FOVRadius*2)
            -- SG has IgnoreGuiInset = true, so its coordinate space matches GetMouseLocation()
            -- 1:1 (top-left = screen top-left). Raw mouse position.
            local mp = UIS:GetMouseLocation()
            FOVCircle.Position = UDim2.fromOffset(mp.X, mp.Y)
            fovSt.Thickness = S.FOVThickness or 2
            if S.RainbowFOV then
                fovSt.Color = Color3.fromHSV((tick()*0.25) % 1, 0.8, 1)
            else
                fovSt.Color = FOV_COLORS[S.FOVColor] or T.White
            end
        end

        -- PERF: skip this whole per-player loop unless the Gun Held cham toggle is on. When it turns
        -- off we run ONE final pass to clean up leftover highlights, then stop.
        local anyCham = S.GunHeldChams or S.RoleChams
        if anyCham or S._chamsWereOn then
        -- PERF: chams don't need a per-frame refresh. Throttling to ~12x/sec avoids scanning every
        -- player's Character every single frame.
        if tick() - (S._chamsAt or 0) >= 0.08 then
        S._chamsAt = tick()
        S._chamsWereOn = anyCham
        for _, pl in pairs(Players:GetPlayers()) do
            if pl ~= LP and pl.Character then
                local ch = pl.Character
                local hum = ch:FindFirstChildOfClass("Humanoid")
                local alive = hum and hum.Health > 0

                -- Role chams (highlight whole character model)
                if S.RoleChams then
                    local isTarget = S.ManualTargets[pl.Name] == true
                    if isTarget then
                        -- Pulsing neon magenta highlight for targets
                        local pulse = 0.15 + 0.3 * math.sin(tick() * 12)
                        local targetCol = Color3.fromRGB(255, 0, 128)
                        createHighlight(ch, targetCol, "RoleChamsHighlight", pulse, 0)
                    elseif not alive then
                        -- Dead players are highlighted in grey
                        local deadCol = Color3.fromRGB(120, 120, 120)
                        createHighlight(ch, deadCol, "RoleChamsHighlight", 0.45, 0)
                    else
                        local role = getRole(pl)
                        local color = RoleShade[role] or RoleShade.Innocent
                        createHighlight(ch, color, "RoleChamsHighlight")
                    end
                else
                    removeCham(ch, "RoleChamsHighlight")
                end

                -- Gun chams (gun currently in a player's hand)
                local gunTool = ch:FindFirstChild("Gun") or ch:FindFirstChild("Revolver")
                local gunPart = gunTool and (gunTool:FindFirstChild("Handle") or gunTool:FindFirstChildWhichIsA("BasePart"))
                if gunPart then
                    if S.GunHeldChams then
                        local color, fillT, outlineT = S._getItemChamStyle()
                        createHighlight(gunPart, color, "GunHeldChams", fillT, outlineT)
                    else
                        removeCham(gunPart, "GunHeldChams")
                    end
                end
            end
        end
        end -- close the ~12x/sec throttle
        end -- close the "anyCham or S._chamsWereOn" gate
        -- PERF: throttle the GunDrop lookup to avoid recursive workspace scans every single frame.
        local wantGunDropCham = S.GunChams or S.GunHeldChams
        if wantGunDropCham or S._hadGunDrop then
            local now = tick()
            if now - (S._lastGunDropScan or 0) >= 0.25 then
                S._lastGunDropScan = now
                S._cachedGunDrop = workspace:FindFirstChild("GunDrop") or workspace:FindFirstChild("GunDrop", true)
            end
            local gd = S._cachedGunDrop
            if gd and gd.Parent then
                if wantGunDropCham then
                    local color, fillT, outlineT = S._getItemChamStyle()
                    createHighlight(gd, color, "GunDropChams", fillT, outlineT)
                else
                    removeCham(gd, "GunDropChams")
                end
                S._hadGunDrop = true
            elseif S._hadGunDrop then
                S._hadGunDrop = false
                if gd then removeCham(gd, "GunDropChams") end
            end
        end
    end)
end))
local function getNcPlat()
    if not ncPlat or not ncPlat.Parent then
        ncPlat = Instance.new("Part")
        ncPlat.Name = "Inertia_NcPlat"
        ncPlat.Size = Vector3.new(4, 0.5, 4)
        ncPlat.Transparency = 1
        ncPlat.Anchored = true
        ncPlat.CanCollide = true
        ncPlat.Parent = workspace
    end
    return ncPlat
end

tc(RunService.Stepped:Connect(function()
    if S.NoClip or S.FastAutofarm then
        local c = LP.Character
        if c then
            local hum = c:FindFirstChildOfClass("Humanoid")
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if S.FastAutofarm then
                if hum then hum.PlatformStand = true end
                if ncPlat then ncPlat.CanCollide = false end
            else
                if hum and hum.PlatformStand then hum.PlatformStand = false end
                if hrp then
                    local plat = getNcPlat()
                    local params = RaycastParams.new()
                    params.FilterType = Enum.RaycastFilterType.Exclude
                    params.FilterDescendantsInstances = {c, plat}
                    local res = workspace:Raycast(hrp.Position, Vector3.new(0, -3.8, 0), params)
                    if res and hrp.AssemblyLinearVelocity.Y <= 0.1 then
                        plat.Position = Vector3.new(hrp.Position.X, res.Position.Y - 0.25, hrp.Position.Z)
                        plat.CanCollide = true
                    else
                        plat.CanCollide = false
                    end
                end
            end
            if c ~= S._ncChar or (tick() - (S._ncAt or 0)) > 2 then
                S._ncChar = c; S._ncAt = tick(); S._ncParts = {}
                for _, pt in ipairs(c:GetDescendants()) do if pt:IsA("BasePart") then table.insert(S._ncParts, pt) end end
            end
            for _, pt in ipairs(S._ncParts) do if pt.Parent then pt.CanCollide = false end end
        end
    else
        if ncPlat then ncPlat.CanCollide = false end
        -- While Fly is on it manages PlatformStand itself; don't fight it here.
        if not S.Fly then
            local c = LP.Character
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if hum and hum.PlatformStand then
                hum.PlatformStand = false
            end
            -- A respawn while Fly was being toggled off could leave the BodyVelocity behind on the
            -- old/new root part — a leftover FlyBV with zero velocity holds the character mid-air
            -- (the "random levitation" report). Sweep it whenever Fly is off.
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv = hrp:FindFirstChild("FlyBV")
                local bg = hrp:FindFirstChild("FlyBG")
                if bv then bv:Destroy() end
                if bg then bg:Destroy() end
            end
        end
    end
end))
-- ============ ESP SYSTEM (names / distance / role / health / box / tracers) ============
local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "MM2_ESP"
ESPGui.ResetOnSpawn = false
ESPGui.IgnoreGuiInset = true
ESPGui.DisplayOrder = 950
pcall(function() ESPGui.Parent = uiP end)
SG.Destroying:Connect(function() pcall(function() ESPGui:Destroy() end) end)
local ESPObjects = {}
local RoleColorOf = {
    Murderer = Color3.fromRGB(255, 60, 60),
    Sheriff  = Color3.fromRGB(60, 140, 255),
    Hero     = Color3.fromRGB(60, 140, 255), -- same as Sheriff, no yellow
    Innocent = Color3.fromRGB(90, 220, 120),
    ["???"]  = Color3.fromRGB(180, 180, 180),
}
local function makeESP(plr)
    local o = {}
    o.box = Instance.new("Frame")
    o.box.BackgroundTransparency = 1
    o.box.BorderSizePixel = 0
    o.box.Visible = false
    o.box.ZIndex = 2
    o.box.Parent = ESPGui
    o.boxStroke = Instance.new("UIStroke")
    o.boxStroke.Thickness = 1.5
    o.boxStroke.Color = Color3.fromRGB(255, 255, 255)
    o.boxStroke.Parent = o.box
    -- Vertical health bar hugging the box's left edge (fill drains top-down with HP).
    o.hbBack = Instance.new("Frame")
    o.hbBack.BorderSizePixel = 0
    o.hbBack.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    o.hbBack.BackgroundTransparency = 0.25
    o.hbBack.Visible = false
    o.hbBack.ZIndex = 2
    o.hbBack.Parent = ESPGui
    o.hbFill = Instance.new("Frame")
    o.hbFill.BorderSizePixel = 0
    o.hbFill.AnchorPoint = Vector2.new(0, 1)
    o.hbFill.Position = UDim2.new(0, 0, 1, 0)
    o.hbFill.ZIndex = 3
    o.hbFill.Parent = o.hbBack
    o.tracer = Instance.new("Frame")
    o.tracer.BorderSizePixel = 0
    o.tracer.AnchorPoint = Vector2.new(0.5, 0.5)
    o.tracer.Size = UDim2.new(0, 1, 0, 0)
    o.tracer.Visible = false
    o.tracer.ZIndex = 1
    o.tracer.Parent = ESPGui
    o.dot = Instance.new("Frame")
    o.dot.BorderSizePixel = 0
    o.dot.AnchorPoint = Vector2.new(0.5, 0.5)
    o.dot.Size = UDim2.fromOffset(6, 6)
    o.dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    o.dot.Visible = false
    o.dot.ZIndex = 3
    Corner(o.dot, 99)
    o.dot.Parent = ESPGui
    o.bill = Instance.new("BillboardGui")
    o.bill.Size = UDim2.new(0, 220, 0, 64)
    o.bill.AlwaysOnTop = true
    o.bill.StudsOffset = Vector3.new(0, 2.5, 0)
    o.bill.Enabled = false
    o.bill.Parent = ESPGui
    o.txt = Instance.new("TextLabel")
    o.txt.BackgroundTransparency = 1
    o.txt.Size = UDim2.new(1, 0, 1, 0)
    o.txt.Font = FB
    o.txt.TextSize = 13
    o.txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    o.txt.TextStrokeTransparency = 0.4
    o.txt.Text = ""
    o.txt.Parent = o.bill
    ESPObjects[plr] = o
    return o
end
local function removeESP(plr)
    local o = ESPObjects[plr]
    if o then
        pcall(function() o.box:Destroy() end)
        pcall(function() o.hbBack:Destroy() end)
        pcall(function() o.tracer:Destroy() end)
        pcall(function() o.dot:Destroy() end)
        pcall(function() o.bill:Destroy() end)
        ESPObjects[plr] = nil
    end
end
tc(Players.PlayerRemoving:Connect(function(p) removeESP(p) end))
local espWasActive = false
tc(RunService.RenderStepped:Connect(function()
    local espOn = S.NameESP or S.DistanceESP or S.RoleESP or S.HealthESP or S.BoxESP or S.TracerESP or S.HeadDot
    if not espOn then
        if espWasActive then
            for _, o in pairs(ESPObjects) do
                o.box.Visible = false; o.hbBack.Visible = false; o.tracer.Visible = false; o.dot.Visible = false; o.bill.Enabled = false
            end
            espWasActive = false
        end
        return
    end
    espWasActive = true
    local cam = workspace.CurrentCamera
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local o = ESPObjects[plr] or makeESP(plr)
            local ch = plr.Character
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            local head = ch and (ch:FindFirstChild("Head") or hrp)
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            local show = espOn and cam and hrp and head and hum
            local dist = 0
            if show then
                local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                dist = myHrp and (myHrp.Position - hrp.Position).Magnitude or 0
                if dist > (S.ESPMaxDist or 1000) then show = false end
            end
            if show then
                local alive = hum.Health > 0
                local role = alive and getRole(plr) or "Dead"
                local col = alive and (RoleColorOf[role] or RoleColorOf.Innocent) or Color3.fromRGB(120, 120, 120)
                local topP = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
                local botP = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                local onScreen = topP.Z > 0 and botP.Z > 0
                local bh = math.abs(botP.Y - topP.Y)
                local bw = bh * 0.62
                if S.BoxESP and onScreen then
                    o.box.Visible = true
                    o.box.Position = UDim2.fromOffset(topP.X - bw / 2, topP.Y)
                    o.box.Size = UDim2.fromOffset(bw, bh)
                    o.boxStroke.Color = col
                    if S.BoxFillESP then
                        o.box.BackgroundColor3 = col
                        o.box.BackgroundTransparency = 0.85
                    else
                        o.box.BackgroundTransparency = 1
                    end
                else o.box.Visible = false end
                if S.HealthBarESP and onScreen and alive then
                    local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                    o.hbBack.Visible = true
                    o.hbBack.Position = UDim2.fromOffset(topP.X - bw / 2 - 7, topP.Y)
                    o.hbBack.Size = UDim2.fromOffset(4, bh)
                    o.hbFill.Size = UDim2.new(1, 0, pct, 0)
                    o.hbFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60):Lerp(Color3.fromRGB(60, 220, 90), pct)
                else o.hbBack.Visible = false end
                if S.TracerESP and onScreen then
                    local vp = cam.ViewportSize
                    local originMode = S.TracerOrigin or "Bottom"
                    local fromX, fromY
                    if originMode == "Top" then fromX, fromY = vp.X / 2, 0
                    elseif originMode == "Center" then fromX, fromY = vp.X / 2, vp.Y / 2
                    elseif originMode == "Mouse" then
                        local m = UIS:GetMouseLocation(); fromX, fromY = m.X, m.Y
                    else fromX, fromY = vp.X / 2, vp.Y end
                    local dx, dy = botP.X - fromX, botP.Y - fromY
                    local len = math.sqrt(dx * dx + dy * dy)
                    o.tracer.Visible = true
                    o.tracer.BackgroundColor3 = col
                    o.tracer.Position = UDim2.fromOffset((fromX + botP.X) / 2, (fromY + botP.Y) / 2)
                    o.tracer.Size = UDim2.fromOffset(1, len)
                    o.tracer.Rotation = math.deg(math.atan2(dy, dx)) - 90
                else o.tracer.Visible = false end
                if S.HeadDot and onScreen then
                    local hp = cam:WorldToViewportPoint(head.Position)
                    o.dot.Visible = true
                    o.dot.BackgroundColor3 = col
                    o.dot.Position = UDim2.fromOffset(hp.X, hp.Y)
                else o.dot.Visible = false end
                local lines = {}
                if S.NameESP then table.insert(lines, plr.Name .. (not alive and " [Dead]" or "")) end
                if S.RoleESP then table.insert(lines, role) end
                if S.HealthESP and alive then table.insert(lines, "HP " .. math.floor(hum.Health)) end
                if S.DistanceESP then table.insert(lines, math.floor(dist) .. "m") end
                if #lines > 0 then
                    o.bill.Adornee = head
                    o.bill.Enabled = true
                    o.txt.Text = table.concat(lines, "\n")
                    o.txt.TextColor3 = col
                else o.bill.Enabled = false end
            else
                o.box.Visible = false
                o.hbBack.Visible = false
                o.tracer.Visible = false
                o.dot.Visible = false
                o.bill.Enabled = false
            end
        end
    end
end))
-- ============ EFFECTS (saturation / contrast / camera FOV / crosshair) ============
local ccEffect = Instance.new("ColorCorrectionEffect")
ccEffect.Name = "MM2_CC"
ccEffect.Enabled = false
pcall(function() ccEffect.Parent = Lighting end)
SG.Destroying:Connect(function() pcall(function() ccEffect:Destroy() end) end)
local Crosshair = Instance.new("Frame")
Crosshair.Name = "MM2_Crosshair"
Crosshair.Parent = SG
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
Crosshair.Size = UDim2.fromOffset(1, 1)
Crosshair.BackgroundTransparency = 1
Crosshair.Visible = false
Crosshair.ZIndex = 799

rebuildCrosshair = function()
    Crosshair:ClearAllChildren()
    if not S.Crosshair then
        Crosshair.Visible = false
        UIS.MouseIconEnabled = true
        return
    end
    
    Crosshair.Visible = true
    UIS.MouseIconEnabled = true
    
    local shape = S.CrosshairShape or "Cross"
    local color = Color3.fromRGB(0, 255, 130)
    if S.CrosshairColor == "Red" then color = Color3.fromRGB(255, 50, 50)
    elseif S.CrosshairColor == "Green" then color = Color3.fromRGB(50, 255, 50)
    elseif S.CrosshairColor == "Yellow" then color = Color3.fromRGB(255, 255, 50)
    elseif S.CrosshairColor == "Pink" then color = Color3.fromRGB(255, 100, 200)
    elseif S.CrosshairColor == "White" then color = Color3.fromRGB(255, 255, 255)
    elseif S.CrosshairColor == "Cyan" then color = Color3.fromRGB(0, 255, 255)
    elseif S.CrosshairColor == "Purple" then color = Color3.fromRGB(170, 80, 255)
    elseif S.CrosshairColor == "Orange" then color = Color3.fromRGB(255, 150, 40)
    elseif S.CrosshairColor == "Blue" then color = Color3.fromRGB(60, 120, 255)
    end
    
    local size = S.CrosshairSize or 12
    local thick = S.CrosshairThickness or 2
    local gap = S.CrosshairGap or 4
    
    if shape == "Cross" or shape == "X" then
        local rotationOffset = (shape == "X") and 45 or 0
        Crosshair.Rotation = (S.CrosshairRotation or 0) + rotationOffset
        
        local function mkLine(w, h, x, y)
            local ln = Instance.new("Frame")
            ln.Parent = Crosshair
            ln.BorderSizePixel = 0
            ln.BackgroundColor3 = color
            ln.Size = UDim2.fromOffset(w, h)
            ln.Position = UDim2.fromOffset(x, y)
            ln.ZIndex = 799
            if S.CrosshairColor == "Rainbow" then
                task.spawn(function()
                    while ln and ln.Parent do
                        ln.BackgroundColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                        task.wait(0.03)
                    end
                end)
            end
        end
        -- Top
        mkLine(thick, size, -thick/2, -gap - size)
        -- Bottom
        mkLine(thick, size, -thick/2, gap)
        -- Left
        mkLine(size, thick, -gap - size, -thick/2)
        -- Right
        mkLine(size, thick, gap, -thick/2)
        
    elseif shape == "Dot" then
        Crosshair.Rotation = S.CrosshairRotation or 0
        local dot = Instance.new("Frame")
        dot.Parent = Crosshair
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Position = UDim2.new(0.5, 0, 0.5, 0)
        dot.Size = UDim2.fromOffset(size, size)
        dot.BorderSizePixel = 0
        dot.BackgroundColor3 = color
        dot.ZIndex = 799
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = dot
        
        if S.CrosshairColor == "Rainbow" then
            task.spawn(function()
                while dot and dot.Parent do
                    dot.BackgroundColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                    task.wait(0.03)
                end
            end)
        end
        
    elseif shape == "Circle" then
        Crosshair.Rotation = S.CrosshairRotation or 0
        local circ = Instance.new("Frame")
        circ.Parent = Crosshair
        circ.AnchorPoint = Vector2.new(0.5, 0.5)
        circ.Position = UDim2.new(0.5, 0, 0.5, 0)
        circ.Size = UDim2.fromOffset(size, size)
        circ.BackgroundTransparency = 1
        circ.ZIndex = 799
        
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = thick
        stroke.Color = color
        stroke.Parent = circ
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = circ
        
        if S.CrosshairColor == "Rainbow" then
            task.spawn(function()
                while stroke and stroke.Parent do
                    stroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                    task.wait(0.03)
                end
            end)
        end
        
    elseif shape == "Heart" then
        Crosshair.Rotation = S.CrosshairRotation or 0
        local container = Instance.new("Frame")
        container.Parent = Crosshair
        container.Size = UDim2.fromOffset(size, size)
        container.BackgroundTransparency = 1
        container.AnchorPoint = Vector2.new(0.5, 0.5)
        container.Position = UDim2.new(0.5, 0, 0.5, 0)
        container.ZIndex = 799
        
        -- Left lobe
        local left = Instance.new("Frame")
        left.Parent = container
        left.Size = UDim2.fromScale(0.6, 0.6)
        left.Position = UDim2.fromScale(0.1, 0.1)
        left.BackgroundColor3 = color
        left.BorderSizePixel = 0
        local cornerL = Instance.new("UICorner")
        cornerL.CornerRadius = UDim.new(1, 0)
        cornerL.Parent = left
        
        -- Right lobe
        local right = Instance.new("Frame")
        right.Parent = container
        right.Size = UDim2.fromScale(0.6, 0.6)
        right.Position = UDim2.fromScale(0.3, 0.1)
        right.BackgroundColor3 = color
        right.BorderSizePixel = 0
        local cornerR = Instance.new("UICorner")
        cornerR.CornerRadius = UDim.new(1, 0)
        cornerR.Parent = right
        
        -- Base
        local base = Instance.new("Frame")
        base.Parent = container
        base.Size = UDim2.fromScale(0.5, 0.5)
        base.Position = UDim2.fromScale(0.25, 0.3)
        base.Rotation = 45
        base.BackgroundColor3 = color
        base.BorderSizePixel = 0
        
        if S.CrosshairColor == "Rainbow" then
            task.spawn(function()
                while container and container.Parent do
                    local rainbowCol = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                    left.BackgroundColor3 = rainbowCol
                    right.BackgroundColor3 = rainbowCol
                    base.BackgroundColor3 = rainbowCol
                    task.wait(0.03)
                end
            end)
        end
    end
end

task.spawn(function()
    while S.Gui and S.Gui.Parent do
        pcall(function()
            local on = (S.Saturation ~= 0 or S.Contrast ~= 0)
            ccEffect.Enabled = on
            ccEffect.Saturation = (S.Saturation or 0) / 100
            ccEffect.Contrast = (S.Contrast or 0) / 100
        end)
        task.wait(0.1)
    end
end)
tc(RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    if cam and S.CamFOV and math.abs(cam.FieldOfView - S.CamFOV) > 0.4 then
        pcall(function() cam.FieldOfView = S.CamFOV end)
    end
    if S.Crosshair then
        local m = UIS:GetMouseLocation()
        Crosshair.Position = UDim2.fromOffset(m.X, m.Y)
    end
end))
-- ============ AUTO RESPAWN ============
local function hookRespawn(ch)
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Died:Connect(function()
            if S.AutoRespawn then
                task.wait(0.4)
                S._resetMyCharacter()
            end
        end)
    end
end
if LP.Character then hookRespawn(LP.Character) end
tc(LP.CharacterAdded:Connect(function(ch) task.wait(0.3); hookRespawn(ch) end))
-- ============ WALK ON WATER ============
task.spawn(function()
    local plat
    while S.Gui and S.Gui.Parent do
        if S.WalkOnWater then
            local c = LP.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            if hrp then
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = { c, plat }
                params.IgnoreWater = false
                local res = workspace:Raycast(hrp.Position, Vector3.new(0, -18, 0), params)
                if res and res.Material == Enum.Material.Water then
                    if not plat or not plat.Parent then
                        plat = Instance.new("Part")
                        plat.Name = "MM2_WaterPlat"; plat.Anchored = true; plat.CanCollide = true
                        plat.Transparency = 1; plat.Size = Vector3.new(14, 1, 14); plat.Parent = workspace
                    end
                    plat.Position = Vector3.new(hrp.Position.X, res.Position.Y + 0.5, hrp.Position.Z)
                elseif plat then plat:Destroy(); plat = nil end
            end
        elseif plat then plat:Destroy(); plat = nil end
        RunService.Heartbeat:Wait()
    end
end)
-- ============ PIXEL SURF (real surf physics) ============
-- The actual CS-style surf: we drive the character's own velocity. Gravity pulls you down; WASD does
-- camera-relative AIR-STRAFE that accelerates you up to Surf Speed; and every frame we raycast in the
-- direction we're moving (and straight down) and, if we're heading INTO a surface, PROJECT the velocity
-- onto that surface — `vel = vel - Normal * dot(vel, Normal)` — so the into-surface component is removed
-- and the tangential part is kept: you slide/surf along ramps, walls and edges instead of stopping.
-- PlatformStand keeps the Humanoid from fighting the velocity we set.
do
    local surfing = false
    tc(RunService.RenderStepped:Connect(function(dt)
        dt = math.min(dt, 1 / 30)
        local c = LP.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if not S.PixelSurf then
            if surfing then
                surfing = false
                if hum then pcall(function() hum.PlatformStand = false end) end
                -- No hard zero here: momentum carries over and the Humanoid's own physics/gravity
                -- takes back control from wherever your velocity actually was, like a real surf mod
                -- ending — not an instant, unnatural full stop.
            end
            return
        end
        if not (hrp and hum and hum.Health > 0) then
            surfing = false
            return
        end
        if not surfing then
            surfing = true
            Notify("Pixel Surf", "Surfing — WASD to strafe, Space to hop", 2)
        end
        pcall(function() hum.PlatformStand = true end)
        local cam = workspace.CurrentCamera
        local vel = hrp.AssemblyLinearVelocity

        -- gravity (Surf Gravity = how hard you're pulled down the slope)
        vel = vel - Vector3.new(0, (S.SurfGravity or 80) * dt, 0)

        -- camera-relative air-strafe up to Surf Speed (quake/CS air-accel feel)
        local fwd = cam.CFrame.LookVector; fwd = Vector3.new(fwd.X, 0, fwd.Z)
        if fwd.Magnitude > 0 then fwd = fwd.Unit end
        local right = cam.CFrame.RightVector; right = Vector3.new(right.X, 0, right.Z)
        if right.Magnitude > 0 then right = right.Unit end
        local wish = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then wish = wish + fwd end
        if UIS:IsKeyDown(Enum.KeyCode.S) then wish = wish - fwd end
        if UIS:IsKeyDown(Enum.KeyCode.D) then wish = wish + right end
        if UIS:IsKeyDown(Enum.KeyCode.A) then wish = wish - right end
        local maxSpeed = S.SurfSpeed or 60
        if wish.Magnitude > 0 then
            wish = wish.Unit
            local horiz = Vector3.new(vel.X, 0, vel.Z)
            local cur = horiz:Dot(wish)
            local add = maxSpeed - cur
            if add > 0 then
                vel = vel + wish * math.min(maxSpeed * 12 * dt, add)
            end
        end

        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances = { c }

        -- Ground-gated hop (the piece that was actually missing / broken): the old version did
        -- `vel.Y = max(vel.Y, 50)` on EVERY frame Space was held, with NO ground check at all — that
        -- let you hold Space in mid-air and continuously clamp your own upward speed floor, i.e. an
        -- infinite hover exploit, not a hop. A real bhop only re-boosts the instant you're actually
        -- back near a surface, so this now raycasts a short distance down and only re-applies the
        -- hop when grounded and not already rising fast — holding Space still auto-bhops seamlessly
        -- across ramps/flats (re-triggers the moment you touch down), it just can't hover.
        local groundHit = workspace:Raycast(hrp.Position, Vector3.new(0, -3.5, 0), rp)
        if UIS:IsKeyDown(Enum.KeyCode.Space) and groundHit and vel.Y <= 5 then
            vel = Vector3.new(vel.X, S.SurfJumpPower or 50, vel.Z)
        end

        -- SURF projection: slide along whatever we're heading into (forward hit + down hit)
        local function slide(dir, len)
            if dir.Magnitude < 0.05 then return end
            local res = workspace:Raycast(hrp.Position, dir.Unit * len, rp)
            if res and res.Normal then
                local into = vel:Dot(res.Normal)
                if into < 0 then vel = vel - res.Normal * into end  -- keep tangential, drop into-surface
                -- stay glued to the ramp instead of clipping in
                local push = 2.2 - res.Distance
                if push > 0 then hrp.CFrame = hrp.CFrame + res.Normal * push end
            end
        end
        slide(Vector3.new(vel.X, 0, vel.Z), 3)          -- wall / ramp ahead
        slide(Vector3.new(0, -1, 0), 4)                 -- slope underfoot

        hrp.AssemblyLinearVelocity = vel
    end))
end
-- ============ ANTI LAG (thorough, adapted from Infinite Yield) ============
do
    local applied = false
    local antilagConn
    task.spawn(function()
        while S.Gui and S.Gui.Parent do
            if S.AntiLag and not applied then
                applied = true
                pcall(function()
                    local Terrain = workspace:FindFirstChildWhichIsA("Terrain")
                    if Terrain then
                        Terrain.WaterWaveSize = 0; Terrain.WaterWaveSpeed = 0
                        Terrain.WaterReflectance = 0; Terrain.WaterTransparency = 1
                    end
                    Lighting.GlobalShadows = false
                    Lighting.FogEnd = 9e9; Lighting.FogStart = 9e9
                    settings().Rendering.QualityLevel = 1
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CastShadow = false; v.Material = Enum.Material.Plastic; v.Reflectance = 0
                        elseif v:IsA("Decal") or v:IsA("Texture") then
                            v.Transparency = 1
                        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                            v.Lifetime = NumberRange.new(0)
                        elseif v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                            v.Enabled = false
                        end
                    end
                    for _, e in pairs(Lighting:GetDescendants()) do
                        if e:IsA("PostEffect") then e.Enabled = false end
                    end
                    antilagConn = workspace.DescendantAdded:Connect(function(child)
                        if not S.AntiLag then return end
                        task.spawn(function()
                            if child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
                                RunService.Heartbeat:Wait(); pcall(function() child:Destroy() end)
                            elseif child:IsA("BasePart") then
                                child.CastShadow = false
                            end
                        end)
                    end)
                end)
                Notify("Anti Lag", "Reduced graphics & effects. (Cannot be fully undone until rejoin!)", 5)
            elseif not S.AntiLag and applied then
                applied = false
                if antilagConn then antilagConn:Disconnect(); antilagConn = nil end
                -- We cannot easily restore all materials, so we just stop enforcing it on new parts.
            end
            task.wait(1)
        end
    end)
end
-- ============ MISC (infinite jump / spinbot / freeze / anti-afk / click TP) ============
tc(UIS.JumpRequest:Connect(function()
    if S.InfiniteJump then
        local c = LP.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end
end))
task.spawn(function()
    local spinY, wasFrozen, spinAutoRotateOff = 0, false, false
    while S.Gui and S.Gui.Parent do
        local c = LP.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if hrp then
            if S.Spinbot then
                -- Kill Humanoid.AutoRotate while spinning. AutoRotate is the game constantly turning
                -- your body to FACE your movement direction; with the spinbot also writing the CFrame
                -- every frame the two fight, which yanks/redirects you sideways instead of a clean
                -- spin. With it off it's a pure flat Y-spin and WASD still moves you camera-relative.
                -- Read the live property (not just our flag) so a respawn — which resets AutoRotate
                -- back to true on the new Humanoid — gets re-disabled instead of staying stuck.
                if hum and hum.AutoRotate then
                    pcall(function() hum.AutoRotate = false end)
                end
                spinAutoRotateOff = true
                spinY = (spinY + (S.SpinSpeed or 20)) % 360
                -- Only overwrite the yaw, keep the exact current position — no pitch/roll, so the body
                -- stays upright and never leans/points off in another direction.
                pcall(function() hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(spinY), 0) end)
            elseif spinAutoRotateOff then
                if hum then pcall(function() hum.AutoRotate = true end) end
                spinAutoRotateOff = false
            end
            if S.Freeze then
                if not wasFrozen then pcall(function() hrp.Anchored = true end); wasFrozen = true end
            elseif wasFrozen then
                pcall(function() hrp.Anchored = false end); wasFrozen = false
            end
        end
        RunService.Heartbeat:Wait()
    end
end)
-- Bhop (auto-hop with building, persistent momentum) + Speed Glitch (controllable air speed)
task.spawn(function()
    local function airborne(hum)
        local st = hum:GetState()
        return st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.Jumping
    end
    local function grounded(hum)
        local st = hum:GetState()
        return st == Enum.HumanoidStateType.Running
            or st == Enum.HumanoidStateType.RunningNoPhysics
            or st == Enum.HumanoidStateType.Landed
    end
    local bhopSpeed = 16  -- current built-up horizontal speed; kept while Bhop stays on
    while S.Gui and S.Gui.Parent do
        -- Pixel Surf drives velocity manually every frame too (PlatformStand-based); running it
        -- alongside Bhop/Speed Glitch would just have both fight over hrp.AssemblyLinearVelocity.
        if (S.Bhop or S.SpeedGlitch) and not S.PixelSurf then
            local c = LP.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local moveDir = hum.MoveDirection
                local vel = hrp.AssemblyLinearVelocity
                if S.SpeedGlitch then
                    -- Airborne: apply a controllable speed; on the ground leave it normal
                    if airborne(hum) and moveDir.Magnitude > 0.05 then
                        hrp.AssemblyLinearVelocity = moveDir * (S.AirSpeed or 50) + Vector3.new(0, vel.Y, 0)
                    end
                elseif S.Bhop then
                    -- No upper clamp anymore (user raised the slider limit): high values may trip
                    -- MM2's anti-cheat ("invalid position") on some servers — that's on the user.
                    local maxS = math.max(S.BhopMax or 28, 16)
                    if moveDir.Magnitude > 0.05 then
                        -- Build momentum each time we touch the ground, so speed ramps up the longer
                        -- you keep hopping. We DO NOT force a jump — Bhop never hops by itself; YOU
                        -- press space. The boost is only applied while you're actually jumping.
                        if grounded(hum) then
                            bhopSpeed = math.min(math.max(bhopSpeed, hum.WalkSpeed) + 5, maxS)
                        end
                        if airborne(hum) or UIS:IsKeyDown(Enum.KeyCode.Space) then
                            hrp.AssemblyLinearVelocity = moveDir * bhopSpeed + Vector3.new(0, vel.Y, 0)
                        end
                    else
                        -- Stopped moving -> drop the built-up speed so you must ramp up again.
                        bhopSpeed = hum.WalkSpeed
                    end
                end
            end
        else
            bhopSpeed = 16  -- only reset once Bhop is switched off
        end
        RunService.Heartbeat:Wait()
    end
end)
do
    local ok, VU = pcall(function() return game:GetService("VirtualUser") end)
    if ok and VU then
        tc(LP.Idled:Connect(function()
            if S.AntiAFK then
                pcall(function() VU:CaptureController(); VU:ClickButton2(Vector2.new()) end)
            end
        end))
    end
end
tc(UIS.InputBegan:Connect(function(input, processed)
    if UIS:GetFocusedTextBox() then return end
    if S.ClickTP and input.KeyCode == Enum.KeyCode.E then
        local c = LP.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local mouse = LP:GetMouse()
        if hrp and mouse and mouse.Hit then
            hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            Notify("Click TP", "Teleported", 1.5)
        end
    end
    if S.ClickFling and input.UserInputType == Enum.UserInputType.MouseButton1 and not processed then
        -- Click Fling: click a player → they get IY-flung. `processed` guard means clicking the GUI
        -- never triggers it. mouse.Target alone was unreliable (a pixel off the character, or an
        -- accessory/transparent part in the way, and nothing happened), so it resolves the victim in
        -- three passes: mouse.Target → camera raycast through the cursor → nearest player to the
        -- cursor on screen (within 120 px).
        local function playerFromInstance(inst)
            local node = inst
            while node and node ~= workspace do
                local pl = Players:GetPlayerFromCharacter(node)
                if pl then return pl end
                node = node.Parent
            end
            return nil
        end
        local cam = workspace.CurrentCamera
        local m = UIS:GetMouseLocation()
        local p
        local mouse = LP:GetMouse()
        if mouse and mouse.Target then p = playerFromInstance(mouse.Target) end
        if not p and cam then
            local ray = cam:ViewportPointToRay(m.X, m.Y)
            local rp = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Exclude
            rp.FilterDescendantsInstances = { LP.Character }
            local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000, rp)
            if hit and hit.Instance then p = playerFromInstance(hit.Instance) end
        end
        if not p and cam then
            local center = Vector2.new(m.X, m.Y)
            local bestD = 120
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LP and pl.Character then
                    local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local sp, on = cam:WorldToViewportPoint(hrp.Position)
                        if on then
                            local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if d < bestD then bestD = d; p = pl end
                        end
                    end
                end
            end
        end
        if p and p ~= LP and not isWhitelisted(p) then
            local th = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
            if th and th.Health > 0 then
                Notify("Click Fling", "Flinging " .. p.Name, 2)
                task.spawn(function() pcall(skidFling, p) end)
            end
        end
    end
end))
-- ============ HUD STATS (ping / coords / speed / session) ============
local scriptStart = os.time()
task.spawn(function()
    local Stats = game:FindService("Stats")
    while S.Gui and S.Gui.Parent do
        pcall(function()
            -- Gate on actual frame visibility (not S flags): visibility can be set by the toggle,
            -- a config restore, or code — the labels should update in every case.
            if HUD.hPing.frame.Visible then
                local ping = 0
                pcall(function() ping = math.floor(LP:GetNetworkPing() * 1000) end)
                if ping == 0 and Stats then
                    pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                end
                HUD.pingLbl.Text = ping .. " ms"
            end
            if HUD.hCoords.frame.Visible then
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local p = hrp.Position
                    HUD.coordLbl.Text = string.format("X %d  Y %d  Z %d", p.X, p.Y, p.Z)
                end
            end
            if HUD.hWatermark.Visible then
                local wping = 0
                pcall(function() wping = math.floor(LP:GetNetworkPing() * 1000) end)
                if wping == 0 and Stats then
                    pcall(function() wping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                end
                local el = os.time() - scriptStart
                local sess = string.format("%02d:%02d:%02d", math.floor(el / 3600), math.floor((el % 3600) / 60), el % 60)
                local pcol = wping < 90 and "#7ee787" or (wping < 180 and "#e3b341" or "#ff7b72")
                local fcol = curFPS >= 50 and "#7ee787" or (curFPS >= 30 and "#e3b341" or "#ff7b72")
                local sep = '<font color="#333333"> | </font>'
                HUD.watermarkLbl.Text = string.format(
                    '<font color="#ffffff"><b>Inertia</b></font>%s<font color="#d0d0d0">%s</font>%s<font color="%s">%d ms</font>%s<font color="%s">%d fps</font>%s<font color="#b78bff">%s</font>',
                    sep, LP.Name, sep, pcol, wping, sep, fcol, curFPS, sep, sess)
            end
            if HUD.hSpeed.frame.Visible then
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local sp = 0
                if hrp then local v = hrp.AssemblyLinearVelocity; sp = math.floor(Vector3.new(v.X, 0, v.Z).Magnitude) end
                HUD.speedLbl.Text = sp .. " sps"
            end
            if HUD.hSession.frame.Visible then
                local el = os.time() - scriptStart
                HUD.sessionLbl.Text = string.format("%02d:%02d:%02d", math.floor(el/3600), math.floor((el%3600)/60), el%60)
            end
        end)
        task.wait(0.25)
    end
end)


task.spawn(function() while S.Gui and S.Gui.Parent do
    if S.HUD_Keybinds and HUD.hBinds.content and HUD.hBinds.content.Parent then
        for _, ch in pairs(HUD.hBinds.content:GetChildren()) do if not ch:IsA("UIListLayout") then ch:Destroy() end end
        local o = 0
        for _, e in ipairs(AllBinds) do if e.bindKey then o = o + 1
            local row = Instance.new("Frame")
            row.LayoutOrder = o; row.BackgroundTransparency = 1
            row.Size = UDim2.new(1,0,0,20); row.ZIndex = 852; row.Parent = HUD.hBinds.content
            -- Toggle binds show a check/X for their state; action binds (momentary) leave the slot empty.
            local l = Instance.new("TextLabel"); l.BackgroundTransparency = 1
            l.Position = UDim2.new(0, 2, 0, 0); l.Size = UDim2.new(1, -2, 1, 0)
            l.Font = F; l.TextSize = 15; l.TextColor3 = T.Tx; pcall(function() l:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
            l.TextXAlignment = Enum.TextXAlignment.Left; l.Text = "[ "..e.bindKey.Name.." ]  "..e.label
            l.TextTruncate = Enum.TextTruncate.AtEnd; l.ZIndex = 852; l.Parent = row
        end end
        if o == 0 then local l = Instance.new("TextLabel"); l.BackgroundTransparency = 1
            l.Size = UDim2.new(1,0,0,20); l.Font = F; l.TextSize = 15; l.TextColor3 = T.Tx3; pcall(function() l:SetAttribute("ThemeColorRole_TextColor3", "Tx3") end)
            l.TextXAlignment = Enum.TextXAlignment.Left; l.Text = "No binds set"; l.ZIndex = 852; l.Parent = HUD.hBinds.content end
        HUD.hBinds.frame.Size = UDim2.new(HUD.hBinds.frame.Size.X.Scale, HUD.hBinds.frame.Size.X.Offset, 0, 32 + (math.max(o, 1) * 22))
    end
    if S.HUD_GunStatus and HUD.gunLbl and HUD.gunLbl.Parent then
        local gd = workspace:FindFirstChild("GunDrop") or workspace:FindFirstChild("GunDrop", true)
        local c = LP.Character; local bp = LP:FindFirstChild("Backpack"); local hg = false
        if (c and (c:FindFirstChild("Gun") or c:FindFirstChild("Revolver"))) or (bp and (bp:FindFirstChild("Gun") or bp:FindFirstChild("Revolver"))) then hg = true end
        local lines = {"Role: "..getRole(LP)}
        table.insert(lines, hg and "Gun: IN HAND" or gd and "Gun: DROPPED" or "Gun: N/A")
        local sn = "?"
        for _, p in pairs(Players:GetPlayers()) do local r = getRole(p); if r == "Sheriff" or r == "Hero" then sn = p.Name; break end end
        table.insert(lines, "Sheriff: "..sn)
        HUD.gunLbl.Text = table.concat(lines, "\n")
    end
    if S.RoleHUDEnabled and HUD.roleLbl and HUD.roleLbl.Parent then
        local active = isRoundActive()
        HUD.hRole.frame.Visible = active
        if active then
            local murdererName = "None"
            local sheriffName = "None"
            local gunHolderName = nil
            local innocentsAlive = 0
            local innocentsTotal = 0
            
            for _, pl in ipairs(Players:GetPlayers()) do
                local ch = pl.Character
                local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                local alive = hum and hum.Health > 0
                local role = alive and getRole(pl) or "Dead"
                
                if role == "Murderer" then
                    murdererName = pl.Name
                elseif role == "Sheriff" then
                    sheriffName = pl.Name
                    gunHolderName = pl.Name
                elseif role == "Hero" then
                    gunHolderName = pl.Name
                elseif role == "Dead" then
                    local cached = RoleCache[pl.Name]
                    if cached == "Murderer" then
                        murdererName = pl.Name .. " (Dead)"
                    elseif cached == "Sheriff" then
                        sheriffName = pl.Name .. " (Dead)"
                    end
                elseif role == "Innocent" then
                    if alive then
                        innocentsAlive = innocentsAlive + 1
                    end
                    innocentsTotal = innocentsTotal + 1
                end
            end
            
            local gd = workspace:FindFirstChild("GunDrop") or workspace:FindFirstChild("GunDrop", true)
            local gunStatusText = "None"
            if gd and gd.Parent then
                local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if myHrp then
                    local dist = (myHrp.Position - gd.Position).Magnitude
                    gunStatusText = string.format("Dropped (%dm)", math.floor(dist))
                else
                    gunStatusText = "Dropped"
                end
            elseif gunHolderName then
                gunStatusText = "Held by " .. gunHolderName
            end
            
            local lines = {
                "Murderer: " .. murdererName,
                "Sheriff: " .. sheriffName,
                "Gun: " .. gunStatusText,
                string.format("Innocents: %d Alive", innocentsAlive)
            }
            HUD.roleLbl.Text = table.concat(lines, "\n")
        end
    else
        if HUD.hRole and HUD.hRole.frame then
            HUD.hRole.frame.Visible = false
        end
    end
    task.wait(0.5) end end)
do
    Main.Visible = false
    local L = Instance.new("Frame")
    L.Parent = SG
    L.AnchorPoint = Vector2.new(0.5, 0.5)
    L.Position = UDim2.new(0.5, 0, 0.5, 0)
    L.Size = UDim2.fromOffset(0, 0)
    L.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    L.BackgroundTransparency = 0.1
    L.BorderSizePixel = 0
    L.ZIndex = 500
    L.ClipsDescendants = true
    Corner(L, 16)
    local lSt = Stroke(L, Color3.fromRGB(60, 60, 65), 1.5, 0.6)
    Shadow(L, 0.5)
    Grad(L, Color3.fromRGB(15, 15, 20), Color3.fromRGB(4, 4, 6), 90)

    local glow = Instance.new("Frame")
    glow.Parent = L
    glow.Size = UDim2.new(1, 4, 1, 4)
    glow.Position = UDim2.new(0, -2, 0, -2)
    glow.BackgroundTransparency = 1
    Corner(glow, 16)
    local glowSt = Stroke(glow, Color3.fromRGB(100, 100, 105), 2.5, 0.8)
    glow.ZIndex = 501

    local lt = Instance.new("TextLabel")
    lt.Parent = L
    lt.BackgroundTransparency = 1
    lt.Position = UDim2.new(0, 0, 0.12, 0)
    lt.Size = UDim2.new(1, 0, 0.25, 0)
    lt.Font = FB
    lt.Text = "INERTIA"
    lt.TextSize = 34
    lt.TextColor3 = T.White; pcall(function() lt:SetAttribute("ThemeColorRole_TextColor3", "White") end)
    lt.ZIndex = 502
    local ltGrad = Grad(lt, Color3.fromRGB(255, 255, 255), Color3.fromRGB(130, 130, 130), 45)

    local ls = Instance.new("TextLabel")
    ls.Parent = L
    ls.BackgroundTransparency = 1
    ls.Position = UDim2.new(0, 0, 0.44, 0)
    ls.Size = UDim2.new(1, 0, 0.1, 0)
    ls.Font = F
    ls.Text = "initializing systems..."
    ls.TextSize = 13
    ls.TextColor3 = Color3.fromRGB(150, 150, 160)
    ls.ZIndex = 502

    local lbb = Instance.new("Frame")
    lbb.Parent = L
    lbb.AnchorPoint = Vector2.new(0.5, 0.5)
    lbb.Position = UDim2.new(0.5, 0, 0.68, 0)
    lbb.Size = UDim2.new(0.75, 0, 0, 6)
    lbb.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    lbb.BorderSizePixel = 0
    lbb.ZIndex = 502
    Corner(lbb, 3)
    Stroke(lbb, Color3.fromRGB(30, 30, 40), 1, 0.5)

    local lbf = Instance.new("Frame")
    lbf.Parent = lbb
    lbf.Size = UDim2.new(0, 0, 1, 0)
    lbf.BackgroundColor3 = T.White; pcall(function() lbf:SetAttribute("ThemeColorRole_BackgroundColor3", "White") end)
    lbf.BorderSizePixel = 0
    lbf.ZIndex = 503
    Corner(lbf, 3)
    Grad(lbf, Color3.fromRGB(255, 255, 255), Color3.fromRGB(100, 100, 105), 0)

    local lp = Instance.new("TextLabel")
    lp.Parent = L
    lp.BackgroundTransparency = 1
    lp.Position = UDim2.new(0, 0, 0.78, 0)
    lp.Size = UDim2.new(1, 0, 0.12, 0)
    lp.Font = FM
    lp.Text = "0%"
    lp.TextSize = 14
    lp.TextColor3 = Color3.fromRGB(240, 240, 240)
    lp.ZIndex = 502

    TweenService.Create(TweenService, L, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(380, 200)
    }):Play()

    task.spawn(function()
        while L and L.Parent do
            local t = tick()
            ltGrad.Rotation = (t * 50) % 360
            glowSt.Transparency = 0.5 + 0.3 * math.sin(t * 3.5)
            lSt.Transparency = 0.4 + 0.2 * math.cos(t * 3.5)
            task.wait()
        end
    end)

    task.spawn(function()
        local stages = {
            {0.18, "connecting secure modules"},
            {0.38, "loading role tracker"},
            {0.56, "injecting visual components"},
            {0.74, "initializing hud stats"},
            {0.90, "linking network events"},
            {1.00, "client ready"},
        }
        local cur = 0
        for _, st in ipairs(stages) do
            ls.Text = st[2]
            TweenService.Create(TweenService, lbf, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = UDim2.new(st[1], 0, 1, 0)
            }):Play()
            local tgt = math.floor(st[1]*100)
            while cur < tgt do
                cur = cur + 1
                lp.Text = cur.."%"
                task.wait(0.005)
            end
            task.wait(0.1)
        end
        task.wait(0.2)
        for _, o in ipairs(L:GetDescendants()) do
            if o:IsA("TextLabel") then
                TweenService.Create(TweenService, o, TweenInfo.new(0.25), { TextTransparency = 1 }):Play()
            elseif o:IsA("Frame") then
                TweenService.Create(TweenService, o, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
            elseif o:IsA("UIStroke") then
                TweenService.Create(TweenService, o, TweenInfo.new(0.25), { Transparency = 1 }):Play()
            end
        end
        TweenService.Create(TweenService, L, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(0, 0),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.38)
        L:Destroy()
        Main.Visible = true
        local fw, fh = expandedSize.X.Offset, expandedSize.Y.Offset
        Main.Size = UDim2.fromOffset(math.floor(fw*0.80), math.floor(fh*0.80))
        TweenService.Create(TweenService, Main, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = expandedSize
        }):Play()
        SFX.Ready()
        pcall(function() rebuildCrosshair() end)
        Notify("Inertia", "LCtrl = menu | RMB = bind", 4)
    end)
    -- ============ SOCIAL & HUD (KILL FEED & AUTO GG) ============
    -- Kill Feed is a proper HUD panel (draggable + toggled from the HUD tab). Cards are inserted into
    -- the "Kill Feed" HUD's content frame; a role-coloured accent bar replaces the old emojis.
    local kfContent = HUDEls["Kill Feed"].content
    local kfCards, kfOrder = {}, 0
    local function addKillFeed(name, tag, color)
        color = color or Color3.new(1, 1, 1)
        kfOrder = kfOrder + 1
        -- Size the card to fit the name so long nicks aren't cut to "..." (12 left pad + name + 8 gap
        -- + 60 tag + 12 right pad). Clamped so it never gets silly-wide; cards right-align, so wider
        -- ones just extend further left.
        local nameW = 100
        pcall(function()
            nameW = game:GetService("TextService"):GetTextSize(name, 14, FM, Vector2.new(9999, 100)).X
        end)
        local cardW = math.clamp(math.ceil(nameW) + 92, 170, 300)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0, cardW, 0, 28)
        card.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
        card.BackgroundTransparency = 1          -- fade in from invisible
        card.BorderSizePixel = 0
        card.LayoutOrder = -kfOrder               -- newest card sits on top
        card.ZIndex = 866
        card.Parent = kfContent
        Corner(card, 6)
        local st = Stroke(card, color, 1, 1)      -- coloured edge, starts transparent
        local bar = Instance.new("Frame")
        bar.Parent = card
        bar.BackgroundColor3 = color
        bar.BackgroundTransparency = 1
        bar.BorderSizePixel = 0
        bar.AnchorPoint = Vector2.new(0, 0.5)
        bar.Position = UDim2.new(0, 0, 0.5, 0)
        bar.Size = UDim2.new(0, 3, 0, 18)
        bar.ZIndex = 867
        Corner(bar, 2)
        local nameL = Instance.new("TextLabel")
        nameL.Parent = card
        nameL.BackgroundTransparency = 1
        nameL.Position = UDim2.new(0, 12, 0, 0)
        nameL.Size = UDim2.new(1, -84, 1, 0)
        nameL.Font = FM
        nameL.TextSize = 14
        nameL.TextColor3 = Color3.fromRGB(240, 240, 245)
        nameL.TextTransparency = 1
        nameL.TextXAlignment = Enum.TextXAlignment.Left
        nameL.TextTruncate = Enum.TextTruncate.AtEnd
        nameL.Text = name
        nameL.ZIndex = 867
        local tagL = Instance.new("TextLabel")
        tagL.Parent = card
        tagL.BackgroundTransparency = 1
        tagL.AnchorPoint = Vector2.new(1, 0)
        tagL.Position = UDim2.new(1, -12, 0, 0)
        tagL.Size = UDim2.new(0, 60, 1, 0)
        tagL.Font = FB
        tagL.TextSize = 12
        tagL.TextColor3 = color
        tagL.TextTransparency = 1
        tagL.TextXAlignment = Enum.TextXAlignment.Right
        tagL.Text = tag
        tagL.ZIndex = 867
        table.insert(kfCards, card)
        while #kfCards > 6 do  -- keep only the most recent
            local old = table.remove(kfCards, 1)
            if old then pcall(function() old:Destroy() end) end
        end
        -- Fade in
        local ti = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        pcall(function()
            TweenService.Create(TweenService, card, ti, { BackgroundTransparency = 0.08 }):Play()
            if st then TweenService.Create(TweenService, st, ti, { Transparency = 0.5 }):Play() end
            TweenService.Create(TweenService, bar, ti, { BackgroundTransparency = 0 }):Play()
            TweenService.Create(TweenService, nameL, ti, { TextTransparency = 0 }):Play()
            TweenService.Create(TweenService, tagL, ti, { TextTransparency = 0.05 }):Play()
        end)
        -- Hold, then fade + collapse (height -> 0 so the stack closes the gap smoothly)
        task.spawn(function()
            task.wait(4.5)
            local to = TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            pcall(function()
                TweenService.Create(TweenService, card, to, { BackgroundTransparency = 1, Size = UDim2.new(0, cardW, 0, 0) }):Play()
                if st then TweenService.Create(TweenService, st, to, { Transparency = 1 }):Play() end
                TweenService.Create(TweenService, bar, to, { BackgroundTransparency = 1 }):Play()
                TweenService.Create(TweenService, nameL, to, { TextTransparency = 1 }):Play()
                TweenService.Create(TweenService, tagL, to, { TextTransparency = 1 }):Play()
            end)
            task.wait(0.34)
            for i, cc in ipairs(kfCards) do if cc == card then table.remove(kfCards, i); break end end
            pcall(function() card:Destroy() end)
        end)
    end

    local function setupPlayerDeathTrack(p)
        local function connectChar(char)
            local hum = char:WaitForChild("Humanoid", 5)
            if hum then
                hum.Died:Connect(function()
                    if S.HUD_KillFeed and isRoundActive() then
                        local r = getRole(p)
                        local color, tag
                        if r == "Murderer" then color = Color3.fromRGB(255, 70, 70); tag = "Murderer"
                        elseif r == "Sheriff" or r == "Hero" then color = Color3.fromRGB(70, 140, 255); tag = r
                        else color = Color3.fromRGB(190, 190, 190); tag = "Innocent" end
                        addKillFeed(p.Name, tag, color)
                    end
                end)
            end
        end
        if p.Character then connectChar(p.Character) end
        p.CharacterAdded:Connect(connectChar)
    end
    
    for _, p in ipairs(Players:GetPlayers()) do
        setupPlayerDeathTrack(p)
    end
    tc(Players.PlayerAdded:Connect(setupPlayerDeathTrack))
    
    local function sendChat(text)
        pcall(function()
            local textChatService = game:GetService("TextChatService")
            local generalChannel = textChatService and textChatService:FindFirstChild("TextChannels") and textChatService.TextChannels:FindFirstChild("RBXGeneral")
            if generalChannel then
                generalChannel:SendAsync(text)
            else
                local remote = game:GetService("ReplicatedStorage"):FindFirstChild("SayMessageRequest", true)
                if remote then remote:FireServer(text, "All") end
            end
        end)
    end
    
    local lastRoundState = false
    task.spawn(function()
        while S.Gui and S.Gui.Parent do
            local active = isRoundActive()
            if lastRoundState and not active then
                if S.AutoGG then
                    task.wait(1.5)
                    local phrase = "GG!"
                    if S.UseCustomGG and tostring(S.CustomGGText) ~= "" then
                        phrase = S.CustomGGText
                    else
                        local defaults = {"GG!", "gg WP!", "Nice round!", "GG guys", "gg"}
                        phrase = defaults[math.random(1, #defaults)]
                    end
                    sendChat(phrase)
                end
            end
            lastRoundState = active
            task.wait(1)
        end
    end)
    
    -- ============ AUTO DODGE KNIFE LOOP ============
    -- The old version only reacted to thrown-knife OBJECTS in the workspace, so a murderer simply
    -- walking up and stabbing (their knife stays a Tool INSIDE their character, never in workspace)
    -- was never dodged — that's why it "didn't work". Now we handle both threats:
    --   (1) a murderer with an equipped knife closing to melee range  -> flee away from them
    --   (2) a knife OBJECT actually flying toward us                   -> sidestep its path
    local lastDodge = 0
    local function performEvade(hrp, hum, escapeDir, label)
        lastDodge = tick()
        local mode = S.AutoDodgeMode or "Teleport"
        if mode == "Teleport" then
            -- 3.5 studs: enough to leave the hitbox without a big obvious warp.
            hrp.CFrame = hrp.CFrame + escapeDir * 3.5
            Notify("Auto Dodge", label .. " (Teleported)", 2)
        elseif mode == "Jump" then
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 18, 0)
            Notify("Auto Dodge", label .. " (Jumped)", 2)
        elseif mode == "Walk Away" then
            local spd = S.AutoDodgeSpeed or 16
            hrp.AssemblyLinearVelocity = escapeDir * spd
            hum:Move(escapeDir)
            local oldSpeed = hum.WalkSpeed
            hum.WalkSpeed = oldSpeed + spd
            task.spawn(function()
                task.wait(0.5)
                if hum and hum.Parent then hum.WalkSpeed = oldSpeed end
            end)
            Notify("Auto Dodge", label .. " (Dodge Walk)", 2)
        end
    end
    task.spawn(function()
        while S.Gui and S.Gui.Parent do
            if S.AutoDodgeKnife and isRoundActive() then
                pcall(function()
                    local c = LP.Character
                    local hrp = c and c:FindFirstChild("HumanoidRootPart")
                    local hum = c and c:FindFirstChildOfClass("Humanoid")
                    local myRole = getRole(LP)

                    if hrp and hum and hum.Health > 0 and myRole ~= "Murderer" and tick() - lastDodge > 0.8 then
                        local dodged = false

                        -- (1) MELEE THREAT: a murderer holding an equipped knife within stab range.
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= LP and p.Character and getRole(p) == "Murderer" then
                                local mhrp = p.Character:FindFirstChild("HumanoidRootPart")
                                local mhum = p.Character:FindFirstChildOfClass("Humanoid")
                                local hasKnife = p.Character:FindFirstChild("Knife") -- equipped knife = can stab now
                                if mhrp and mhum and mhum.Health > 0 and hasKnife then
                                    if (hrp.Position - mhrp.Position).Magnitude < 14 then
                                        local away = hrp.Position - mhrp.Position
                                        local escapeDir = (away.Magnitude > 0.05) and away.Unit or Vector3.new(1, 0, 0)
                                        performEvade(hrp, hum, escapeDir, "Murderer too close!")
                                        dodged = true
                                        break
                                    end
                                end
                            end
                        end

                        -- (2) THROWN KNIFE THREAT: a knife OBJECT actually in flight toward us.
                        if not dodged then
                            for _, v in ipairs(workspace:GetChildren()) do
                                if v ~= c and v.Name:lower():find("knife") then
                                    local part = v:IsA("BasePart") and v or v:FindFirstChild("Handle") or v:FindFirstChildOfClass("BasePart")
                                    if part then
                                        local vel = part.AssemblyLinearVelocity
                                        local dist = (hrp.Position - part.Position).Magnitude
                                        -- only dodge knives that are moving (vel>10) AND heading at us; a
                                        -- knife on the floor (murderer dead) is harmless and left alone.
                                        if vel.Magnitude > 10 and dist < 40 then
                                            local dir = vel.Unit
                                            local toMe = (hrp.Position - part.Position).Unit
                                            if dir:Dot(toMe) > 0.4 then
                                                -- Perpendicular to the knife's flight; guard the near-vertical case
                                                -- where (-Z,0,X) is ~zero and .Unit would NaN (NaN CFrame = death fling).
                                                local perp = Vector3.new(-dir.Z, 0, dir.X)
                                                local escapeDir = (perp.Magnitude > 0.05) and perp.Unit or Vector3.new(1, 0, 0)
                                                if ((hrp.Position + escapeDir * 5) - part.Position).Magnitude < ((hrp.Position - escapeDir * 5) - part.Position).Magnitude then
                                                    escapeDir = -escapeDir
                                                end
                                                performEvade(hrp, hum, escapeDir, "Knife evaded!")
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
            task.wait(0.02)
        end
    end)
end

-- ============ PLAYER TAB (Emotes + Animations, thumbnails + search) ============
do
    -- Subtab bar (same pattern as Combat/Teleport): Emotes / Animations.
    -- LayoutOrder 0 = always the first child so it sits at the very top of Pages.Player.
    local playerSubTabBar = Instance.new("Frame")
    playerSubTabBar.Name = "SubTabBar"
    playerSubTabBar.LayoutOrder = 0
    playerSubTabBar.BackgroundTransparency = 1
    playerSubTabBar.Size = UDim2.new(1, 0, 0, 32)
    playerSubTabBar.Parent = Pages.Player

    local plSubTabList = Instance.new("UIListLayout")
    plSubTabList.FillDirection = Enum.FillDirection.Horizontal
    plSubTabList.SortOrder = Enum.SortOrder.LayoutOrder
    plSubTabList.Padding = UDim.new(0, 8)
    plSubTabList.Parent = playerSubTabBar

    local emotesBtn = Instance.new("TextButton")
    local animsBtn = Instance.new("TextButton")
    local skinsBtn = Instance.new("TextButton")
    local emotesStroke = mkSubTabBtn(playerSubTabBar, emotesBtn, "Emotes", 1, 1/3, -6)
    local animsStroke = mkSubTabBtn(playerSubTabBar, animsBtn, "Animations", 2, 1/3, -6)
    local skinsStroke = mkSubTabBtn(playerSubTabBar, skinsBtn, "Skins", 3, 1/3, -6)
    -- _pl: shared table to pass section-card references OUT of the nested do-blocks
    -- below so the subtab-switching closure (at the end of this outer block) can
    -- still show/hide them even though their local variables are out of scope.
    local _pl = {}

    -- ---- shared helpers ----
    -- One clickable row: thumbnail (rbxthumb, no HTTP needed) + title. Used by both Emotes and the
    -- Animations catalog browse results.
    local function mkThumbRow(parent, order, imgId, titleText, onClick)
        local row = Instance.new("TextButton")
        row.Name = "Row"
        row.LayoutOrder = order
        row.AutoButtonColor = false
        row.BorderSizePixel = 0
        row.Text = ""
        row.BackgroundColor3 = T.Elev; pcall(function() row:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
        row.Size = UDim2.new(1, 0, 0, 56)
        row.Parent = parent
        Corner(row, 6)
        row.MouseEnter:Connect(function() TweenService.Create(TweenService, row, TweenInfo.new(0.1), { BackgroundColor3 = T.Hover }):Play() end)
        row.MouseLeave:Connect(function() TweenService.Create(TweenService, row, TweenInfo.new(0.1), { BackgroundColor3 = T.Elev }):Play() end)

        local img = Instance.new("ImageLabel")
        img.Name = "Thumb"
        img.Parent = row
        img.BackgroundTransparency = 1
        img.AnchorPoint = Vector2.new(0, 0.5)
        img.Position = UDim2.new(0, 4, 0.5, 0)
        img.Size = UDim2.new(0, 48, 0, 48)
        -- "bundle:<id>" renders the bundle's pack art; a plain id renders the asset thumbnail.
        local thumbUrl = ""
        if imgId and imgId ~= "" then
            local bId = tostring(imgId):match("^bundle:(%d+)$")
            thumbUrl = bId and ("rbxthumb://type=BundleThumbnail&id=" .. bId .. "&w=150&h=150")
                or ("rbxthumb://type=Asset&id=" .. imgId .. "&w=150&h=150")
        end
        img.Image = thumbUrl
        Corner(img, 6)

        local lbl = Instance.new("TextLabel")
        lbl.Name = "Title"
        lbl.Parent = row
        lbl.BackgroundTransparency = 1
        lbl.Position = UDim2.new(0, 60, 0, 0)
        lbl.Size = UDim2.new(1, -68, 1, 0)
        lbl.Font = F
        lbl.TextSize = 13
        lbl.TextColor3 = T.Tx; pcall(function() lbl:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextWrapped = true
        lbl.Text = titleText

        row.MouseButton1Click:Connect(function() SFX.Click(); onClick() end)
        return row
    end
    local function mkSearchBox(parent, order, placeholder)
        local box = Instance.new("TextBox")
        box.Parent = parent
        box.LayoutOrder = order
        box.Size = UDim2.new(1, 0, 0, 30)
        box.BackgroundColor3 = T.Elev; pcall(function() box:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
        box.BorderSizePixel = 0
        box.Font = F
        box.TextSize = 13
        box.TextColor3 = T.Tx; pcall(function() box:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
        box.PlaceholderText = placeholder
        box.PlaceholderColor3 = T.Tx4
        box.Text = ""
        box.ClearTextOnFocus = false
        box.TextXAlignment = Enum.TextXAlignment.Left
        Corner(box, 6)
        Stroke(box, T.Bd2, 1, 0.4)
        Pad(box, 0, 0, 8, 8)
        return box
    end
    local function mkListScroll(parent, order, height)
        local scroll = Instance.new("ScrollingFrame")
        scroll.Parent = parent
        scroll.LayoutOrder = order
        scroll.BackgroundColor3 = T.Card; pcall(function() scroll:SetAttribute("ThemeColorRole_BackgroundColor3", "Card") end)
        scroll.BorderSizePixel = 0
        scroll.Size = UDim2.new(1, 0, 0, height)
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = T.Tx3; pcall(function() scroll:SetAttribute("ThemeColorRole_ScrollBarImageColor3", "Tx3") end)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Corner(scroll, 8)
        Stroke(scroll, T.Bd, 1, 0.4)
        local layout = Instance.new("UIListLayout")
        layout.Parent = scroll
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 4)
        Pad(scroll, 6, 6, 6, 6)
        return scroll
    end

    -- ================= EMOTES =================
    -- Wrapped in its own do-block so its locals don't count toward the outer scope's
    -- 200-register budget. _pl.eCard is written before the block ends so the subtab
    -- switcher can still reference the card.
    do
    -- Source of truth: Roblox's complete emote catalog (AvatarEditorService:SearchCatalogAsync,
    -- fully paginated, with no creator filter) — so the tab includes Roblox and community emotes,
    -- not just the handful you personally own.
    local secEmotes = mkSection(Pages.Player, "Emotes", 1)
    local emSearch = mkSearchBox(secEmotes, 1, "Search emotes...")
    local emScroll = mkListScroll(secEmotes, 2, 320)

    local emoteTracks = {}
    local function stopEmote()
        for _, tr in ipairs(emoteTracks) do pcall(function() tr:Stop(); tr:Destroy() end) end
        emoteTracks = {}
    end
    -- Same resilience pattern as the reference script: try the built-in emote player first; if the
    -- Humanoid doesn't recognize the id yet, register it via HumanoidDescription:AddEmote and retry.
    -- Falls back to a raw LoadAnimation if PlayEmoteAndGetAnimTrackById isn't available at all.
    --
    -- "No Emote Stop": Roblox's native emote player (PlayEmoteAndGetAnimTrackById / the old
    -- Humanoid:PlayEmote) is watched by the engine's own emote controller, which auto-cancels the
    -- track the instant you move, jump, or take most other actions — that's a built-in platform
    -- behavior, not something this script does. A raw hum:LoadAnimation() track is NOT watched by
    -- that controller, so it only stops when code calls :Stop() on it. Playing it at a high enough
    -- AnimationPriority also makes it override the walk/run/idle tracks visually while you move,
    -- instead of the movement animation fighting it for the same body parts.
    -- Snapshot of what's currently playing, so after a native emote play we can pick out the NEW track.
    local function playingSet(hum)
        local set = {}
        pcall(function() for _, t in ipairs(hum:GetPlayingAnimationTracks()) do set[t] = true end end)
        return set
    end
    -- Emotes MUST be played via Roblox's native emote player — the ONLY path that reliably loads
    -- catalog emote ids (raw hum:LoadAnimation on an emote id fails / gives a 0-length track, which is
    -- exactly what made emotes "stop working" when Loop / No-Emote-Stop were on).
    local function playEmoteById(name, id)
        stopEmote()
        local c = LP.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if not hum then Notify("Emotes", "No character", 2); return end
        if hum.RigType ~= Enum.HumanoidRigType.R15 then
            Notify("Emotes", "R15 required for this emote system", 3); return
        end
        if not hum.PlayEmoteAndGetAnimTrackById then Notify("Emotes", "Emotes unsupported here", 3); return end
        -- Play through the native emote player (plays as a side-effect; on this version it returns
        -- (success, nil), so we locate the started track by diffing the playing set).
        local before = playingSet(hum)
        local function nativePlay()
            local ok, success = pcall(function() return hum:PlayEmoteAndGetAnimTrackById(tostring(id)) end)
            if ok and success == true then return true end
            pcall(function() hum:GetAppliedDescription():AddEmote(name, id) end)
            local ok2, s2 = pcall(function() return hum:PlayEmoteAndGetAnimTrackById(tostring(id)) end)
            return ok2 and s2 == true
        end
        if not nativePlay() then Notify("Emotes", "Failed to play " .. tostring(name), 2); return end
        task.wait()
        -- find the emote track that just started
        local newTrack
        pcall(function()
            for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
                if not before[t] and t.Animation and tostring(t.Animation.AnimationId) ~= "" then newTrack = t end
            end
        end)
        if not (S.NoEmoteStop or S.LoopEmote) then
            -- normal one-shot: just remember it so Stop Emote works
            if newTrack then table.insert(emoteTracks, newTrack) end
            return
        end
        -- Loop / No-Emote-Stop: take the emote's RESOLVED real Animation id (which raw-loads fine and is
        -- NOT watched by the engine's emote auto-cancel), stop the native track, and play our own looping
        -- copy so it survives movement/jumping.
        local resolvedId = newTrack and newTrack.Animation and newTrack.Animation.AnimationId
        if newTrack then pcall(function() newTrack:Stop() end) end
        if not resolvedId or tostring(resolvedId) == "" then
            if newTrack then table.insert(emoteTracks, newTrack) end -- fall back to the native one-shot
            return
        end
        local anim = Instance.new("Animation")
        anim.AnimationId = resolvedId
        local ok, track = pcall(function() return hum:LoadAnimation(anim) end)
        if ok and track then
            track.Looped = true
            track.Priority = S.NoEmoteStop and Enum.AnimationPriority.Action4 or Enum.AnimationPriority.Action
            track:Play()
            table.insert(emoteTracks, track)
        elseif newTrack then
            table.insert(emoteTracks, newTrack)
        end
    end

    -- Full Roblox emote catalog: fetched once, paginated, cached for the session.
    -- Cached to disk once fetched, so every FUTURE launch loads instantly from file (no network call,
    -- no rate-limit exposure at all) instead of re-hitting Roblox's catalog search every single time.
    -- Versioned path: older releases cached only the Roblox creator subset, so they must not
    -- short-circuit the new complete-catalog search.
    local EMOTES_CACHE_PATH = "MM2_Configs/_emotes_cache_all_v2.json"
    local officialEmotes -- nil = not fetched yet, table = ready (possibly empty on failure)
    local fetchingEmotes = false
    local function loadEmotesCacheFromDisk()
        if not (readfile and isfile and isfile(EMOTES_CACHE_PATH)) then return nil end
        local ok, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(EMOTES_CACHE_PATH))
        end)
        return (ok and type(data) == "table" and #data > 0) and data or nil
    end
    local function saveEmotesCacheToDisk(results)
        if not (writefile and makefolder and isfolder) then return end
        pcall(function()
            if not isfolder("MM2_Configs") then makefolder("MM2_Configs") end
            writefile(EMOTES_CACHE_PATH, game:GetService("HttpService"):JSONEncode(results))
        end)
    end
    -- All official emotes frozen into the script (harvested once from the live catalog), so the list
    -- renders instantly with zero network calls. A background catalog fetch still runs once per launch
    -- and only APPENDS emotes Roblox released after this list was generated (merged result is cached).
    local BUILTIN_EMOTES = {
        { name = "Thanos Happy Jump", id = 76228547293788 },
        { name = "Robot M3GAN", id = 90569436057900 },
        { name = "NBA Monster Dunk", id = 82163305721376 },
        { name = "Fashion Spin", id = 130046968468383 },
        { name = "Chappell Roan HOT TO GO!", id = 79312439851071 },
        { name = "BLACKPINK As If It's Your Last", id = 18855603653 },
        { name = "BLACKPINK Don't know what to do", id = 18855609889 },
        { name = "Olympic Dismount", id = 18666650035 },
        { name = "Vroom Vroom", id = 18526410572 },
        { name = "Shrek Roar", id = 18524331128 },
        { name = "SpongeBob Dance", id = 18443271885 },
        { name = "Vans Ollie", id = 18305539673 },
        { name = "Rock Out - Bebe Rexha", id = 18225077553 },
        { name = "Mini Kong", id = 17000058939 },
        { name = "BLACKPINK - Lovesick Girls", id = 16874600526 },
        { name = "BLACKPINK - How You Like That", id = 16874596971 },
        { name = "BLACKPINK Boombayah Emote", id = 16553259683 },
        { name = "BLACKPINK DDU-DU DDU-DU", id = 16553262614 },
        { name = "Skadoosh Emote - Kung Fu Panda 4", id = 16371235025 },
        { name = "BLACKPINK Ice Cream", id = 16181840356 },
        { name = "BLACKPINK Kill This Love", id = 16181843366 },
        { name = "Mean Girls Dance Break", id = 15963348695 },
        { name = "BLACKPINK ROSÉ On The Ground", id = 15679958535 },
        { name = "BLACKPINK LISA Money", id = 15679957363 },
        { name = "Nicki Minaj Anaconda", id = 15571539403 },
        { name = "Nicki Minaj That's That Super Bass Emote", id = 15571536896 },
        { name = "BLACKPINK JENNIE You and Me", id = 15439457146 },
        { name = "BLACKPINK JISOO Flower", id = 15439454888 },
        { name = "BLACKPINK Shut Down - Part 2", id = 14901371589 },
        { name = "BLACKPINK Shut Down - Part 1", id = 14901369589 },
        { name = "BLACKPINK Pink Venom - Straight to Ya Dome", id = 14548711723 },
        { name = "BLACKPINK Pink Venom - I Bring the Pain Like…", id = 14548710952 },
        { name = "BLACKPINK Pink Venom - Get em Get em Get em", id = 14548709888 },
        { name = "Man City Scorpion Kick", id = 13694139364 },
        { name = "Man City Backflip", id = 13694140956 },
        { name = "Man City Bicycle Kick", id = 13422286833 },
        { name = "MANIAC - Stray Kids", id = 11309309359 },
        { name = "Swag Walk", id = 10478377385 },
        { name = "You can't sit with us - Sunmi", id = 9983549160 },
        { name = "Gashina - SUNMI", id = 9528294735 },
        { name = "Annyeong (안녕)", id = 9528286240 },
        { name = "Hwaiting (화이팅)", id = 9528291779 },
        { name = "Hyperfast 5G Dance Move", id = 9408642191 },
        { name = "Quiet Waves", id = 7466046574 },
        { name = "Flowing Breeze", id = 7466047578 },
        { name = "Swan Dance", id = 7466048475 },
        { name = "Up and Down - Twenty One Pilots", id = 7422843994 },
        { name = "Dancin' Shoes - Twenty One Pilots", id = 7405123844 },
        { name = "On The Outside - Twenty One Pilots", id = 7422841700 },
        { name = "Drummer Moves - Twenty One Pilots", id = 7422838770 },
        { name = "Saturday Dance - Twenty One Pilots", id = 7422833723 },
        { name = "Boxing Punch - KSI", id = 7202896732 },
        { name = "Wake Up Call - KSI", id = 7202900159 },
        { name = "Show Dem Wrists - KSI", id = 7202898984 },
        { name = "Block Partier", id = 6865011755 },
        { name = "Samba", id = 6869813008 },
        { name = "Cha Cha", id = 6865013133 },
        { name = "Rock Guitar - Royal Blood", id = 6532155086 },
        { name = "Drum Solo - Royal Blood", id = 6532844183 },
        { name = "Rock Star - Royal Blood", id = 6533100850 },
        { name = "Drum Master - Royal Blood", id = 6531538868 },
        { name = "Old Town Road Dance - Lil Nas X (LNX)", id = 5938394742 },
        { name = "Rodeo Dance - Lil Nas X (LNX)", id = 5938397555 },
        { name = "HOLIDAY Dance - Lil Nas X (LNX)", id = 5938396308 },
        { name = "Panini Dance - Lil Nas X (LNX)", id = 5915781665 },
        { name = "Country Line Dance - Lil Nas X (LNX)", id = 5915780563 },
        { name = "Floss Dance", id = 5917570207 },
        { name = "Break Dance", id = 5915773992 },
        { name = "Dolphin Dance", id = 5938365243 },
        { name = "Rock On", id = 5915782672 },
        { name = "High Wave", id = 5915776835 },
        { name = "Jumping Cheer", id = 5895009708 },
        { name = "Applaud", id = 5915779043 },
        { name = "Beckon", id = 5230615437 },
        { name = "Bored", id = 5230661597 },
        { name = "Cower", id = 4940597758 },
        { name = "Tantrum", id = 5104374556 },
        { name = "Confused", id = 4940592718 },
        { name = "Hero Landing", id = 5104377791 },
        { name = "Jumping Wave", id = 4940602656 },
        { name = "Keeping Time", id = 4646306072 },
        { name = "Disagree", id = 4849495710 },
        { name = "Sleep", id = 4689362868 },
        { name = "Agree", id = 4849487550 },
        { name = "Power Blast", id = 4849497510 },
        { name = "Happy", id = 4849499887 },
        { name = "Sad", id = 4849502101 },
        { name = "Chicken Dance", id = 4849493309 },
        { name = "Curtsy", id = 4646306583 },
        { name = "Air Dance", id = 4646302011 },
        { name = "Bunny Hop", id = 4646296016 },
        { name = "Sandwich Dance", id = 4390121879 },
        { name = "Shuffle", id = 4391208058 },
        { name = "Y", id = 4391211308 },
        { name = "Baby Dance", id = 4272484885 },
        { name = "Fast Hands", id = 4272351660 },
        { name = "Zombie", id = 4212496830 },
        { name = "Dorky Dance", id = 4212499637 },
        { name = "Idol", id = 4102317848 },
        { name = "Haha", id = 4102315500 },
        { name = "Line Dance", id = 4049646104 },
        { name = "Tree", id = 4049634387 },
        { name = "Bodybuilder", id = 3994130516 },
        { name = "Fishing", id = 3994129128 },
        { name = "Celebrate", id = 3994127840 },
        { name = "Fancy Feet", id = 3934988903 },
        { name = "Dizzy", id = 3934986896 },
        { name = "Get Out", id = 3934984583 },
        { name = "Louder", id = 3576751796 },
        { name = "Greatest", id = 3762654854 },
        { name = "Side to Side", id = 3762641826 },
        { name = "Godlike", id = 3823158750 },
        { name = "Swish", id = 3821527813 },
        { name = "Sneaky", id = 3576754235 },
        { name = "Superhero Reveal", id = 3696759798 },
        { name = "Heisman Pose", id = 3696763549 },
        { name = "Cha-Cha", id = 3696764866 },
        { name = "Air Guitar", id = 3696761354 },
        { name = "Hype Dance", id = 3696757129 },
        { name = "Fashionable", id = 3576745472 },
        { name = "Jacks", id = 3570649048 },
        { name = "Twirl", id = 3716633898 },
        { name = "Monkey", id = 3716636630 },
        { name = "Around Town", id = 3576747102 },
        { name = "Borock's Rage", id = 3236848555 },
        { name = "Ud'zal's Summoning", id = 3307604888 },
        { name = "T", id = 3576719440 },
        { name = "Robot", id = 3576721660 },
        { name = "Top Rock", id = 3570535774 },
        { name = "Shy", id = 3576717965 },
        { name = "Shrug", id = 3576968026 },
        { name = "Point2", id = 3576823880 },
        { name = "Hello", id = 3576686446 },
        { name = "Salute", id = 3360689775 },
        { name = "Stadium", id = 3360686498 },
        { name = "Tilt", id = 3360692915 },
        { name = "Arm Wave", id = 5915773155 },
        { name = "Head Banging", id = 5915779725 },
        { name = "Face Calisthenics", id = 9830731012 },
    }
    local function fetchOfficialEmotes(onDone)
        if officialEmotes then onDone(officialEmotes); return end
        local cached = loadEmotesCacheFromDisk()
        -- Use the disk cache as an instant first page, but always refresh it in the
        -- background. The old early return made a stale cache permanently hide new emotes.
        local seed, seen = {}, {}
        local function addSeed(list)
            for _, e in ipairs(list or {}) do
                local id = tonumber(e.id)
                if id and not seen[id] then
                    seen[id] = true
                    table.insert(seed, { name = tostring(e.name or id), id = id })
                end
            end
        end
        addSeed(cached)
        addSeed(BUILTIN_EMOTES)
        officialEmotes = seed
        onDone(officialEmotes)
        if fetchingEmotes then return end
        fetchingEmotes = true
        task.spawn(function()
            local avatarEditor = game:GetService("AvatarEditorService")
            local params = CatalogSearchParams.new()
            params.AssetTypes = { Enum.AvatarAssetType.EmoteAnimation }
            params.SortType = Enum.CatalogSortType.RecentlyCreated
            params.SortAggregation = Enum.CatalogSortAggregation.AllTime
            params.IncludeOffSale = true
            -- Do not limit this to CreatorName = "Roblox".  The Player Emotes tab is meant
            -- to contain the complete Roblox catalog, including creator/community emotes,
            -- not only the older Roblox-published subset.
            params.Limit = 120

            local page
            for _ = 1, 3 do
                local ok, p = pcall(function()
                    if avatarEditor.SearchCatalogAsync then
                        return avatarEditor:SearchCatalogAsync(params)
                    end
                    return avatarEditor:SearchCatalog(params)
                end)
                if ok then page = p; break end
                task.wait(2)
            end
            if not page then fetchingEmotes = false; return end -- builtin list is already on screen

            local results = {}
            -- 120 items/page; keep walking until Roblox says the catalog is finished (with
            -- a generous safety cap so a broken page cursor can never loop forever).
            for _ = 1, 100 do
                local ok, items = pcall(function() return page:GetCurrentPage() end)
                if ok and items then
                    for _, it in ipairs(items) do
                        table.insert(results, { name = it.Name, id = it.Id })
                    end
                end
                if page.IsFinished then break end
                local advanced = false
                for _ = 1, 3 do
                    if pcall(function() page:AdvanceToNextPageAsync() end) then advanced = true; break end
                    task.wait(1)
                end
                if not advanced then break end
            end
            local have = {}
            for _, e in ipairs(officialEmotes) do have[e.id] = true end
            local fresh = {}
            for _, e in ipairs(results) do if not have[e.id] then table.insert(fresh, e) end end
            if #fresh > 0 then
                -- newest releases first, then everything we already had
                for _, e in ipairs(officialEmotes) do table.insert(fresh, e) end
                officialEmotes = fresh
                saveEmotesCacheToDisk(fresh)
                onDone(fresh)
            end
            fetchingEmotes = false
        end)
    end

    -- Pinned Emotes HUD tray: left-click plays; right-click removes the emote from the tray.
    -- The pin list is written to disk on every pin/unpin and restored on the next launch, so pins
    -- survive rejoins the same way configs do.
    local PINNED_EMOTES_PATH = "MM2_Configs/_pinned_emotes.json"
    local pinnedButtons = {} -- [id] = ImageButton
    local pinnedNames = {} -- [id] = display name (needed to rebuild the tray from disk)
    local restoringPins = false
    local function savePinsToDisk()
        if restoringPins then return end
        if not (writefile and makefolder and isfolder) then return end
        pcall(function()
            if not isfolder("MM2_Configs") then makefolder("MM2_Configs") end
            local list = {}
            for id, nm in pairs(pinnedNames) do table.insert(list, { name = nm, id = id }) end
            writefile(PINNED_EMOTES_PATH, game:GetService("HttpService"):JSONEncode(list))
        end)
    end
    local function unpinEmote(id)
        local b = pinnedButtons[id]
        if b then b:Destroy(); pinnedButtons[id] = nil end
        pinnedNames[id] = nil
        HUD.hPinnedEmotes.frame.Visible = next(pinnedButtons) ~= nil
        savePinsToDisk()
    end
    local function pinEmote(name, id)
        if pinnedButtons[id] then return end
        local b = Instance.new("ImageButton")
        b.Name = "Pin_" .. tostring(id)
        b.BackgroundColor3 = T.Elev; pcall(function() b:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
        b.BorderSizePixel = 0
        b.Active = true
        b.Image = "rbxthumb://type=Asset&id=" .. tostring(id) .. "&w=150&h=150"
        Corner(b, 6)
        b.Parent = HUD.hPinnedEmotes.content
        b.MouseButton1Click:Connect(function() SFX.Click(); playEmoteById(name, id) end)
        local removed = false
        local function removePinned()
            if removed then return end
            removed = true
            SFX.Click()
            unpinEmote(id)
            Notify("Emotes", "Unpinned " .. name, 2)
        end
        -- Use both GuiButton's RMB event and InputBegan: some Roblox UI layers swallow
        -- MouseButton2Click on ImageButtons, while InputBegan still receives the click.
        b.MouseButton2Click:Connect(removePinned)
        b.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then removePinned() end
        end)
        pinnedButtons[id] = b
        pinnedNames[id] = name  -- track name so savePinsToDisk can persist it
        HUD.hPinnedEmotes.frame.Visible = true
        if not restoringPins then savePinsToDisk() end
    end
    -- Restore pinned emotes from disk on every launch so they survive rejoins.
    -- Runs immediately after pinEmote is defined; uses a task.spawn so the HUD frame
    -- is guaranteed to exist before we try to parent buttons to its content.
    task.spawn(function()
        if not (readfile and isfile) then return end
        if not isfile(PINNED_EMOTES_PATH) then return end
        local ok, list = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(PINNED_EMOTES_PATH))
        end)
        if not (ok and type(list) == "table") then return end
        restoringPins = true
        for _, entry in ipairs(list) do
            local n, i = tostring(entry.name or ""), tonumber(entry.id)
            if i and n ~= "" then
                pinnedButtons[i] = nil  -- ensure pinEmote doesn't early-return
                pinEmote(n, i)
            end
        end
        restoringPins = false
        -- savePinsToDisk is intentionally NOT called here; we just restored, not changed.
    end)

    local emSearchQ = ""
    local function refreshEmotes()
        for _, ch in ipairs(emScroll:GetChildren()) do if ch.Name == "Row" or ch.Name == "Status" then ch:Destroy() end end
        -- Render the complete fetched catalog. Search remains available as a filter, but it is no
        -- longer required just to reveal entries hidden behind an artificial 60-row cap.
        local EMOTE_RENDER_CAP = math.huge
        local function render(items)
            for _, ch in ipairs(emScroll:GetChildren()) do if ch.Name == "Row" or ch.Name == "Status" then ch:Destroy() end end
            local order = 0
            local matches = 0
            for _, item in ipairs(items) do
                if emSearchQ == "" or tostring(item.name):lower():find(emSearchQ, 1, true) then
                    matches = matches + 1
                    if order < EMOTE_RENDER_CAP then
                    order = order + 1
                    local row = mkThumbRow(emScroll, order, tostring(item.id), item.name, function()
                        playEmoteById(item.name, item.id)
                    end)
                    local title = row:FindFirstChild("Title")
                    if title then title.Size = UDim2.new(1, -104, 1, 0) end -- make room for the pin button
                    local pinBtn = Instance.new("TextButton")
                    pinBtn.Name = "PinBtn"
                    pinBtn.AnchorPoint = Vector2.new(1, 0.5)
                    pinBtn.Position = UDim2.new(1, -6, 0.5, 0)
                    pinBtn.Size = UDim2.new(0, 32, 0, 32)
                    pinBtn.BackgroundColor3 = T.Card; pcall(function() pinBtn:SetAttribute("ThemeColorRole_BackgroundColor3", "Card") end)
                    pinBtn.BorderSizePixel = 0
                    pinBtn.Font = FM
                    pinBtn.TextSize = 16
                    pinBtn.Text = "📌"
                    pinBtn.AutoButtonColor = false
                    Corner(pinBtn, 6)
                    pinBtn.Parent = row
                    pinBtn.MouseButton1Click:Connect(function()
                        SFX.Click()
                        pinEmote(item.name, item.id)
                        Notify("Emotes", "Pinned " .. item.name .. " to HUD", 2)
                    end)
                    end
                end
            end
            if order == 0 then
                local lbl = Instance.new("TextLabel")
                lbl.Name = "Status"
                lbl.Parent = emScroll
                lbl.BackgroundTransparency = 1
                lbl.Size = UDim2.new(1, 0, 0, 30)
                lbl.Font = F
                lbl.TextSize = 12
                lbl.TextColor3 = T.Tx4; pcall(function() lbl:SetAttribute("ThemeColorRole_TextColor3", "Tx4") end)
                lbl.Text = (#items == 0) and "No official emotes found (Roblox catalog unavailable right now)." or "No matches."
            end
        end
        if officialEmotes then
            render(officialEmotes)
        else
            local lbl = Instance.new("TextLabel")
            lbl.Name = "Status"
            lbl.Parent = emScroll
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 0, 30)
            lbl.Font = F
            lbl.TextSize = 12
            lbl.TextColor3 = T.Tx4; pcall(function() lbl:SetAttribute("ThemeColorRole_TextColor3", "Tx4") end)
            lbl.Text = "Loading from Roblox catalog..."
            fetchOfficialEmotes(render)
        end
    end
    emSearch:GetPropertyChangedSignal("Text"):Connect(function()
        emSearchQ = emSearch.Text:lower()
        refreshEmotes() -- also retries the fetch if the previous attempt failed (rate limit etc.)
    end)
    tc(LP.CharacterAdded:Connect(function()
        stopEmote()
        -- Safety unanchor: if the character spawns while autofarm had anchored HRP,
        -- make absolutely sure physics are re-enabled on the new body.
        task.delay(0.1, function()
            local nc = LP.Character
            local nh = nc and nc:FindFirstChild("HumanoidRootPart")
            if nh and nh.Anchored then nh.Anchored = false end
        end)
    end))
    refreshEmotes()
    mkToggle(secEmotes, "Loop Animation", false, function(v) S.LoopEmote = v end, 3)
    mkToggle(secEmotes, "No Emote Stop", false, function(v) S.NoEmoteStop = v end, 4)
    mkAction(secEmotes, "Stop Emote", function() stopEmote() end, 5)
    _pl.eCard = secEmotes and secEmotes.Parent  -- expose card to outer scope
    end -- end Emotes do-block

    -- ================= ANIMATIONS =================
    -- Wrapped in its own do-block (same reason: avoid hitting the 200-local limit).
    -- _pl.pCard is written before this block ends.
    do
    -- Real Animate script structure (verified live on this game): each movement state is a
    -- StringValue holding one or more Animation children whose .AnimationId we overwrite directly.
    local slots = {
        { name = "Idle",     group = "idle",     children = { "Animation1", "Animation2" } },
        { name = "Walk",     group = "walk",     children = { "WalkAnim" } },
        { name = "Run",      group = "run",      children = { "RunAnim" } },
        { name = "Jump",     group = "jump",     children = { "JumpAnim" } },
        { name = "Fall",     group = "fall",     children = { "FallAnim" } },
        { name = "Climb",    group = "climb",    children = { "ClimbAnim" } },
        { name = "Swim",     group = "swim",     children = { "Swim" } },
        { name = "SwimIdle", group = "swimidle", children = { "SwimIdle" } },
    }
    local function getAnimateGroup(groupName)
        local c = LP.Character
        local anim = c and c:FindFirstChild("Animate")
        return anim and anim:FindFirstChild(groupName)
    end
    -- Creates the Animation object under the slot's group if it's missing instead of silently skipping
    -- (some groups, like swimidle, don't always have their Animation child pre-made).
    local function ensureSlotAnim(grp, childName)
        local a = grp:FindFirstChild(childName)
        if not a then
            a = Instance.new("Animation")
            a.Name = childName
            a.Parent = grp
        end
        return a
    end
    -- First time a slot is touched we remember the game's own AnimationId, so Reset To Default can
    -- put everything back without waiting for a respawn (a leftover floating idle from the
    -- Levitation-style packs otherwise looks like an unexplained levitation bug).
    local origAnims = {}
    local function applyToSlot(slot, id, quiet)
        local grp = getAnimateGroup(slot.group)
        if not grp then if not quiet then Notify("Animations", "Character not ready", 2) end; return end
        for _, childName in ipairs(slot.children) do
            local child = ensureSlotAnim(grp, childName)
            local key = slot.group .. "/" .. childName
            if origAnims[key] == nil then origAnims[key] = child.AnimationId end
            child.AnimationId = "rbxassetid://" .. tostring(id)
        end
        if not quiet then Notify("Animations", slot.name .. " animation updated", 2) end
    end
    local originalAvatarDescription = nil
    local function applyCatalogPackDescription(hum, pack)
        if not (hum and pack and pack.catalog) then return false end
        local okDesc, desc = pcall(function() return hum:GetAppliedDescription() end)
        if not (okDesc and desc) then return false end
        if not originalAvatarDescription then
            local okClone, clone = pcall(function() return desc:Clone() end)
            originalAvatarDescription = (okClone and clone) or desc
        end
        local changed = false
        local fields = {
            IdleAnimation = pack.Animation1 or pack.Animation2,
            WalkAnimation = pack.WalkAnim,
            RunAnimation = pack.RunAnim,
            JumpAnimation = pack.JumpAnim,
            FallAnimation = pack.FallAnim,
            ClimbAnimation = pack.ClimbAnim,
            SwimAnimation = pack.Swim,
        }
        for field, id in pairs(fields) do
            if id then
                local ok = pcall(function() desc[field] = tonumber(id) end)
                if ok then changed = true end
            end
        end
        if not changed then return false end
        local okApply = pcall(function() hum:ApplyDescription(desc) end)
        return okApply
    end

    -- Shared revert used both by the "Reset To Default Animations" button and automatically whenever
    -- a just-applied pack turns out to be blocked in this place (see packJustFailed below).
    local function resetToDefaultAnimations(quiet)
        local c = LP.Character
        local animate = c and c:FindFirstChild("Animate")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if not (animate and hum) then if not quiet then Notify("Animations", "Character not ready", 2) end; return end
        if next(origAnims) == nil and not originalAvatarDescription then
            if not quiet then Notify("Animations", "Nothing to reset", 2) end
            return
        end
        for key, id in pairs(origAnims) do
            local grpName, childName = key:match("^(.-)/(.+)$")
            local g = grpName and animate:FindFirstChild(grpName)
            local ch = g and g:FindFirstChild(childName)
            if ch then ch.AnimationId = id end
        end
        if originalAvatarDescription then
            pcall(function() hum:ApplyDescription(originalAvatarDescription) end)
            originalAvatarDescription = nil
        end
        pcall(function() for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop(0) end end)
        pcall(function() animate.Disabled = true end)
        task.wait(0.06)
        pcall(function() animate.Disabled = false end)
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.Landed)
            task.wait(0.03)
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end)
        currentPackName = nil  -- stop the respawn re-apply from re-installing the pack
        pcall(function() if S._RequestAutoSave then S._RequestAutoSave() end end)
        if not quiet then Notify("Animations", "Default animations restored", 2) end
    end

    -- Offline fallback packs. The live catalog loader below appends every BundleType.Animations
    -- result (including newer UGC/community packs) and caches the result for future launches.
    -- `bundle` is used only for the row thumbnail (rbxthumb BundleThumbnail).
    local STATIC_PACKS = {
        ["Adidas Aura"] = { bundle = 4294795, Animation1 = 110211186840347, Animation2 = 114191137265065, WalkAnim = 83842218823011, RunAnim = 118320322718866, JumpAnim = 109996626521204, FallAnim = 95603166884636, ClimbAnim = 97824616490448, Swim = 134530128383903, SwimIdle = 94922130551805 },
        ["Adidas Community"] = { Animation1 = 122257458498464, Animation2 = 102357151005774, WalkAnim = 122150855457006, RunAnim = 82598234841035, JumpAnim = 75290611992385, FallAnim = 98600215928904, ClimbAnim = 88763136693023, Swim = 133308483266208, SwimIdle = 109346520324160 },
        ["Adidas Sports"] = { bundle = 427999, Animation1 = 18537376492, Animation2 = 18537371272, WalkAnim = 18537392113, RunAnim = 18537384940, JumpAnim = 18537380791, FallAnim = 18537367238, ClimbAnim = 18537363391, Swim = 18537389531, SwimIdle = 18537387180 },
        ["Amazon Unboxed"] = { bundle = 4164795, Animation1 = 98281136301627, WalkAnim = 90478085024465, RunAnim = 134824450619865, JumpAnim = 121454505477205, FallAnim = 94788218468396, ClimbAnim = 121145883950231, Swim = 105962919001086, SwimIdle = 129126268464847 },
        ["Astronaut"] = { bundle = 34, Animation1 = 10921034824, Animation2 = 10921036806, WalkAnim = 10921046031, RunAnim = 10921039308, JumpAnim = 10921042494, FallAnim = 10921040576, ClimbAnim = 10921032124, Swim = 10921044000, SwimIdle = 10921045006 },
        ["Bubbly"] = { bundle = 39, Animation1 = 910004836, Animation2 = 910009958, WalkAnim = 910034870, RunAnim = 910025107, JumpAnim = 910016857, FallAnim = 910001910, ClimbAnim = 909997997, Swim = 910028158, SwimIdle = 910030921 },
        ["Cartoon"] = { bundle = 56, Animation1 = 742637544, Animation2 = 742638445, WalkAnim = 742640026, RunAnim = 742638842, JumpAnim = 742637942, FallAnim = 742637151, ClimbAnim = 742636889, Swim = 742639220, SwimIdle = 742639812 },
        ["Catwalk Glam"] = { Animation1 = 133806214992291, Animation2 = 94970088341563, WalkAnim = 109168724482748, RunAnim = 81024476153754, JumpAnim = 116936326516985, FallAnim = 92294537340807, ClimbAnim = 119377220967554, Swim = 134591743181628, SwimIdle = 98854111361360 },
        ["Elder"] = { bundle = 48, Animation1 = 10921101664, Animation2 = 10921102574, WalkAnim = 10921111375, RunAnim = 10921104374, JumpAnim = 10921107367, FallAnim = 10921105765, ClimbAnim = 10921100400, Swim = 10921108971, SwimIdle = 10921110146 },
        ["Levitation"] = { bundle = 79, Animation1 = 616006778, Animation2 = 616008087, WalkAnim = 616013216, RunAnim = 616010382, JumpAnim = 616008936, FallAnim = 616005863, ClimbAnim = 616003713, Swim = 616011509, SwimIdle = 616012453 },
        ["Mage"] = { bundle = 63, Animation1 = 10921144709, Animation2 = 10921145797, WalkAnim = 10921152678, RunAnim = 10921148209, JumpAnim = 10921149743, FallAnim = 10921148939, ClimbAnim = 10921143404, Swim = 10921150788, SwimIdle = 10921151661 },
        ["NFL"] = { Animation1 = 92080889861410, Animation2 = 74451233229259, WalkAnim = 110358958299415, RunAnim = 117333533048078, JumpAnim = 119846112151352, FallAnim = 129773241321032, ClimbAnim = 134630013742019, Swim = 132697394189921, SwimIdle = 79090109939093 },
        ["Ninja"] = { bundle = 75, Animation1 = 656117400, Animation2 = 656118341, WalkAnim = 656121766, RunAnim = 656118852, JumpAnim = 656117878, FallAnim = 656115606, ClimbAnim = 656114359, Swim = 656119721, SwimIdle = 656121397 },
        ["No Boundaries"] = { Animation1 = 18747067405, Animation2 = 18747063918, WalkAnim = 18747074203, RunAnim = 18747070484, JumpAnim = 18747069148, FallAnim = 18747062535, ClimbAnim = 18747060903, Swim = 18747073181, SwimIdle = 18747071682 },
        ["Robot"] = { bundle = 82, Animation1 = 616088211, Animation2 = 616089559, WalkAnim = 616095330, RunAnim = 616091570, JumpAnim = 616090535, FallAnim = 616087089, ClimbAnim = 616086039, Swim = 616092998, SwimIdle = 616094091 },
        ["Stylish"] = { bundle = 83, Animation1 = 616136790, Animation2 = 616138447, WalkAnim = 616146177, RunAnim = 616140816, JumpAnim = 616139451, FallAnim = 616134815, ClimbAnim = 616133594, Swim = 616143378, SwimIdle = 616144772 },
        ["Superhero"] = { bundle = 81, Animation1 = 10921288909, Animation2 = 10921290167, WalkAnim = 10921298616, RunAnim = 10921291831, JumpAnim = 10921294559, FallAnim = 10921293373, ClimbAnim = 10921286911, Swim = 10921295495, SwimIdle = 10921297391 },
        ["Toy"] = { bundle = 43, Animation1 = 10921301576, WalkAnim = 10921312010, RunAnim = 10921306285, JumpAnim = 10921308158, FallAnim = 10921307241, ClimbAnim = 10921300839, Swim = 10921309319, SwimIdle = 10921310341 },
        ["Vampire"] = { bundle = 33, Animation1 = 10921315373, WalkAnim = 10921326949, RunAnim = 10921320299, JumpAnim = 10921322186, FallAnim = 10921321317, ClimbAnim = 10921314188, Swim = 10921324408, SwimIdle = 10921325443 },
        ["Werewolf"] = { bundle = 32, Animation1 = 10921330408, Animation2 = 10921333667, WalkAnim = 10921342074, RunAnim = 10921336997, FallAnim = 10921337907, ClimbAnim = 10921329322, Swim = 10921340419, SwimIdle = 10921341319 },
        ["Wicked \"Dancing Through Life\""] = { Animation1 = 92849173543269, Animation2 = 132238900951109, WalkAnim = 73718308412641, RunAnim = 135515454877967, JumpAnim = 78508480717326, FallAnim = 78147885297412, ClimbAnim = 129447497744818, Swim = 110657013921774, SwimIdle = 129183123083281 },
        ["Wicked Popular"] = { bundle = 1189398, Animation1 = 118832222982049, Animation2 = 76049494037641, WalkAnim = 92072849924640, RunAnim = 72301599441680, JumpAnim = 104325245285198, FallAnim = 121152442762481, ClimbAnim = 131326830509784, Swim = 99384245425157, SwimIdle = 113199415118199 },
        ["Zombie"] = { bundle = 80, Animation1 = 10921344533, Animation2 = 10921345304, WalkAnim = 10921355261, RunAnim = 616163682, JumpAnim = 10921351278, FallAnim = 10921350320, ClimbAnim = 10921343576, Swim = 10921352344, SwimIdle = 10921353442 },
    }

    -- Keep the Player > Animations tab focused on popular, complete legacy packs.
    -- The full Roblox bundle catalog contains many new UGC packs that are visible in the
    -- catalog but are not consistently loadable by every experience.
    local POPULAR_PACK_ORDER = {
        "Adidas Sports", "Astronaut", "Bubbly", "Cartoon", "Elder", "Levitation",
        "Mage", "Ninja", "Robot", "Stylish", "Superhero", "Toy", "Vampire", "Zombie",
    }
    local MAX_ANIMATION_BUNDLES = 100
    local function hasWorkingAnimationSlots(pack)
        return type(pack) == "table"
            and pack.Animation1 and pack.WalkAnim and pack.RunAnim
            and pack.JumpAnim and pack.FallAnim and pack.ClimbAnim and pack.Swim
    end

    -- =================================================================================
    -- LIMITED ROBLOX ANIMATION-PACK CATALOG — capped at 100 bundles:
    --   * The LIST only needs each pack's NAME + BUNDLE ID. That comes from ONE paginated
    --     AvatarEditorService:SearchCatalog(BundleTypes = Animations) call — the same API Emotes
    --     uses — cached to disk, so every future launch shows the entire catalog instantly.
    --   * Resolving a pack's individual per-slot animation ids (idle/walk/run/...) is the slow part
    --     (a GetProductInfo per bundle), so it is DEFERRED to the moment you CLICK a pack — never done
    --     for the whole catalog up front. Resolved packs are cached to disk too, so re-clicking is
    --     instant. This is why the list can hold the full Roblox catalog without lag.
    --   * The curated STATIC_PACKS above are the pre-resolved, known-good "instant" floor: they show
    --     (and apply) even before the catalog fetch finishes or if the catalog is unreachable.
    -- =================================================================================
    local slotToStaticKey = { Walk = "WalkAnim", Run = "RunAnim", Jump = "JumpAnim", Fall = "FallAnim", Climb = "ClimbAnim", Swim = "Swim", SwimIdle = "SwimIdle" }
    local HttpSvc = game:GetService("HttpService")

    -- Versioned caches discard the older list/entries that were marked "blocked" by a
    -- client-side preload check even when Roblox allowed them in-game.
    local PACKS_LIST_CACHE = "MM2_Configs/_anim_packs_list_v3.json"       -- [{name, id}] — max 100 catalog rows
    local PACKS_RESOLVED_CACHE = "MM2_Configs/_anim_packs_resolved_v3.json" -- catalog packs must use HumanoidDescription
    local PACKS_BLOCKED_CACHE = "MM2_Configs/_anim_packs_blocked_v1.json"   -- name -> true, proven blocked in THIS place
    -- Grouped into ONE table (was 6 separate locals) to save registers — this whole file lives right at
    -- Luau's 200-local-register ceiling, and 6 scalars collapsed into 1 table local is a straight save
    -- of 5 registers for zero behavior change.
    local PackState = {
        catalogPacks = nil,      -- nil = not fetched yet; else array of { name, id }
        fetchingPacks = false,
        resolvedCache = {},      -- name -> { bundle=, WalkAnim=, Animation1=, ... }
        blockedPacks = {},       -- name -> true, once Roblox itself has rejected one of its animation ids here
        refreshPacksFn = nil,    -- forward ref: assigned once refreshPacks() is defined further down
        recentlyFailedIds = {},  -- assetId (string) -> tick() it was last reported as load-failed
    }

    -- restore the resolved-pack cache (things you've applied before) so re-clicking is instant
    if readfile and isfile and isfile(PACKS_RESOLVED_CACHE) then
        local ok, data = pcall(function() return HttpSvc:JSONDecode(readfile(PACKS_RESOLVED_CACHE)) end)
        if ok and type(data) == "table" then PackState.resolvedCache = data end
    end
    if readfile and isfile and isfile(PACKS_BLOCKED_CACHE) then
        local ok, data = pcall(function() return HttpSvc:JSONDecode(readfile(PACKS_BLOCKED_CACHE)) end)
        if ok and type(data) == "table" then PackState.blockedPacks = data end
    end
    local function saveResolvedCache()
        if not (writefile and makefolder and isfolder) then return end
        pcall(function()
            if not isfolder("MM2_Configs") then makefolder("MM2_Configs") end
            writefile(PACKS_RESOLVED_CACHE, HttpSvc:JSONEncode(PackState.resolvedCache))
        end)
    end
    -- ===== "Not allowed in this place" detection =====
    -- Roblox does NOT throw a catchable Lua error for a place-restricted animation — LoadAnimation and
    -- :Play() both "succeed" and the track just silently has Length == 0 forever. The ONLY signal is a
    -- LogService MessageError, verified live: "Failed to load animation with sanitized ID
    -- rbxassetid://<id>: Animation failed to load, assetId: https://assetdelivery.roblox.com/v1/asset?
    -- id=<id>&serverplaceid=<place>". (A prior attempt used ContentProvider:PreloadAsync to pre-guess
    -- this — removed because it false-flagged valid assets. This instead reacts to Roblox's OWN report
    -- of a REAL failure for that EXACT asset id, so it cannot false-positive.)
    tc(game:GetService("LogService").MessageOut:Connect(function(msg, msgType)
        if msgType ~= Enum.MessageType.MessageError then return end
        local id = tostring(msg):match("Failed to load animation with sanitized ID rbxassetid://(%d+)")
        if id then PackState.recentlyFailedIds[id] = tick() end
    end))
    local function loadPacksListCache()
        if not (readfile and isfile and isfile(PACKS_LIST_CACHE)) then return nil end
        local ok, data = pcall(function() return HttpSvc:JSONDecode(readfile(PACKS_LIST_CACHE)) end)
        return (ok and type(data) == "table" and #data > 0) and data or nil
    end
    local function savePacksListCache(list)
        if not (writefile and makefolder and isfolder) then return end
        pcall(function()
            if not isfolder("MM2_Configs") then makefolder("MM2_Configs") end
            writefile(PACKS_LIST_CACHE, HttpSvc:JSONEncode(list))
        end)
    end

    -- Fetch only the first limited slice of the catalog; never keep the whole catalog in memory.
    local function fetchAllPacks(onDone)
        if PackState.catalogPacks then onDone(PackState.catalogPacks); return end
        local cached = loadPacksListCache()
        -- Show the cached list immediately, then still refresh the catalog in the background;
        -- otherwise a one-time partial cache could hide Cat/Wolf/Dog and newer UGC packs forever.
        if cached then PackState.catalogPacks = cached; onDone(cached) end
        if PackState.fetchingPacks then return end
        PackState.fetchingPacks = true
        task.spawn(function()
            local AES = game:GetService("AvatarEditorService")
            local params = CatalogSearchParams.new()
            params.BundleTypes = { Enum.BundleType.Animations }
            local sortOk, popularSort = pcall(function() return Enum.CatalogSortType.MostFavorited end)
            params.SortType = sortOk and popularSort or Enum.CatalogSortType.RecentlyCreated
            params.SortAggregation = Enum.CatalogSortAggregation.AllTime
            params.IncludeOffSale = true
            params.Limit = MAX_ANIMATION_BUNDLES

            local page
            for _ = 1, 5 do
                local ok, p = pcall(function()
                    if AES.SearchCatalogAsync then return AES:SearchCatalogAsync(params) end
                    return AES:SearchCatalog(params)
                end)
                if ok then page = p; break end
                task.wait(2)
            end
            if not page then PackState.fetchingPacks = false; onDone({}); return end -- don't cache a failed attempt

            local results, seen = {}, {}
            for _ = 1, 10 do
                local ok, items = pcall(function() return page:GetCurrentPage() end)
                if ok and items then
                    for _, it in ipairs(items) do
                        if #results >= MAX_ANIMATION_BUNDLES then break end
                        if it.Id and not seen[it.Id] then
                            seen[it.Id] = true
                            table.insert(results, { name = tostring(it.Name), id = it.Id })
                        end
                    end
                end
                if #results >= MAX_ANIMATION_BUNDLES then break end
                if page.IsFinished then break end
                local advanced = false
                for _ = 1, 3 do
                    if pcall(function() page:AdvanceToNextPageAsync() end) then advanced = true; break end
                    task.wait(1)
                end
                if not advanced then break end
            end
            PackState.catalogPacks = results
            PackState.fetchingPacks = false
            if #results > 0 then savePacksListCache(results) end
            onDone(results)
        end)
    end

    -- "Swim Idle Animation" contains both "idle" and "swim" as substrings, so the more specific
    -- SwimIdle patterns must be checked before the generic Idle/Swim ones or they'd never match.
    local PACK_SLOT_KEYWORDS = {
        { key = "SwimIdle", pat = "swim idle" }, { key = "SwimIdle", pat = "swimidle" },
        { key = "Idle", pat = "idle" }, { key = "Walk", pat = "walk" }, { key = "Run", pat = "run" },
        { key = "Jump", pat = "jump" }, { key = "Fall", pat = "fall" }, { key = "Climb", pat = "climb" },
        { key = "Swim", pat = "swim" },
    }
    -- CLICK-TIME resolution: turn a bundle id into per-slot animation ids via GetProductInfo.
    local function resolveBundleAnims(bundleId)
        local mps = game:GetService("MarketplaceService")
        local ok, info = pcall(function() return mps:GetProductInfo(bundleId, Enum.InfoType.Bundle) end)
        if not (ok and info and info.Items) then return nil end
        local pack = { bundle = bundleId, catalog = true }
        for _, it in ipairs(info.Items) do
            if tostring(it.Type) == "Asset" then
                local lname = tostring(it.Name):lower()
                for _, kw in ipairs(PACK_SLOT_KEYWORDS) do
                    if lname:find(kw.pat, 1, true) then
                        if kw.key == "Idle" then
                            if not pack.Animation1 then pack.Animation1 = it.Id
                            elseif not pack.Animation2 then pack.Animation2 = it.Id end
                        else
                            local slotKey = slotToStaticKey[kw.key]
                            if slotKey and not pack[slotKey] then pack[slotKey] = it.Id end
                        end
                        break
                    end
                end
            end
        end
        if pack.Animation1 or pack.Animation2 or pack.WalkAnim or pack.RunAnim or pack.JumpAnim
            or pack.FallAnim or pack.ClimbAnim or pack.Swim or pack.SwimIdle then
            return pack
        end
        return nil
    end
    -- Remembered so (a) the pack re-applies after every respawn — MM2 rebuilds the Animate script
    -- each round, which wipes our ids — and (b) it persists across relaunches via the ConfigControl
    -- registered at the end of this block.
    local currentPackName = nil

    local function applyResolvedPack(packName, pack)
        local c = LP.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        local animate = c and c:FindFirstChild("Animate")
        if not (hum and animate) then Notify("Animations", "Character not ready", 2); return end
        
        currentPackName = packName
        pcall(function() if S._RequestAutoSave then S._RequestAutoSave() end end)
        pcall(function() for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop(0) end end)
        
        local applied = 0
        local descApplied = false
        if pack and pack.catalog then
            descApplied = applyCatalogPackDescription(hum, pack)
        end
        
        if not descApplied then
            for _, slot in ipairs(slots) do
                if slot.name == "Idle" then
                    local a1, a2 = pack.Animation1, pack.Animation2
                    local id1, id2 = a1 or a2, a2 or a1
                    if id1 then applyToSlot(slot, id1, true); applied = applied + 1 end
                    if id2 and id2 ~= id1 then
                        local grp = getAnimateGroup(slot.group)
                        if grp then
                            local an2 = ensureSlotAnim(grp, "Animation2")
                            local key = slot.group .. "/Animation2"
                            if origAnims[key] == nil then origAnims[key] = an2.AnimationId end
                            an2.AnimationId = "rbxassetid://" .. tostring(id2)
                        end
                    end
                else
                    local id = pack[slotToStaticKey[slot.name]]
                    if id then applyToSlot(slot, id, true); applied = applied + 1 end
                end
            end
            pcall(function() animate.Disabled = true end)
            task.wait(0.06)
            pcall(function() animate.Disabled = false end)
            pcall(function()
                hum:ChangeState(Enum.HumanoidStateType.Landed)
                task.wait(0.03)
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end)
            Notify("Animations", packName .. " applied (" .. applied .. " animations)", 3)
        else
            Notify("Animations", packName .. " applied through avatar settings", 3)
        end
    end

    -- Click handler: resolve (if needed) -> apply. Do not use ContentProvider:PreloadAsync as a
    -- moderation test: it reports false failures for valid catalog animation assets in experiences.
    local function clickPack(name, bundleId)
        if PackState.blockedPacks[name] then
            return
        end
        task.spawn(function()
            local pack = STATIC_PACKS[name]
            if not pack then
                local c = PackState.resolvedCache[name]
                pack = (type(c) == "table") and c or nil
                if pack then pack.catalog = true end
            end
            if pack then
                -- Every animation-pack row is a catalog bundle, including the curated fallback
                -- rows. Apply it through HumanoidDescription so new asset types 48-55 are not
                -- written directly into Animate and rejected by Roblox's sanitizer.
                pack.catalog = true
                applyResolvedPack(name, pack)
                return
            end
            if not bundleId then Notify("Animations", "No bundle id for " .. name, 2); return end
            Notify("Animations", "Loading " .. name .. "...", 1)
            local resolved = resolveBundleAnims(bundleId)
            if not resolved then Notify("Animations", "Couldn't load " .. name, 3); return end
            resolved.catalog = true
            PackState.resolvedCache[name] = resolved
            saveResolvedCache()
            applyResolvedPack(name, resolved)
        end)
    end

    local secPacks = mkSection(Pages.Player, "Animation Pack", 2)
    local packSearch = mkSearchBox(secPacks, 1, "Search animation packs...")
    local packScroll = mkListScroll(secPacks, 2, 320)
    local function refreshPacks()
        for _, ch in ipairs(packScroll:GetChildren()) do
            if ch.Name == "Row" or ch.Name == "Status" then ch:Destroy() end
        end
        -- Keep the curated known-good packs, then add at most enough catalog rows to reach 100.
        -- Anything in PackState.blockedPacks has already been proven ("not allowed in this place") by an actual
        -- apply attempt (LogService MessageOut catches the "not allowed" toast) — skip it so the list only
        -- ever shows packs that either work here or haven't been tried yet.
        local byName, list = {}, {}
        for _, nm in ipairs(POPULAR_PACK_ORDER) do
            local pk = STATIC_PACKS[nm]
            if hasWorkingAnimationSlots(pk) and not PackState.blockedPacks[nm] then
                byName[nm] = true
                table.insert(list, { name = nm, bundle = pk.bundle })
            end
        end
        if PackState.catalogPacks then
            for _, e in ipairs(PackState.catalogPacks) do
                if #list >= MAX_ANIMATION_BUNDLES then break end
                if e.name and not byName[e.name] and not PackState.blockedPacks[e.name] then
                    byName[e.name] = true
                    table.insert(list, { name = e.name, bundle = e.id })
                end
            end
        end
        table.sort(list, function(a, b) return a.name:lower() < b.name:lower() end)
        local q = packSearch.Text:lower()
        -- Search filters the capped list; it never triggers loading of more catalog pages.
        local PACK_RENDER_CAP = MAX_ANIMATION_BUNDLES
        local order, matches = 0, 0
        for _, e in ipairs(list) do
            if q == "" or e.name:lower():find(q, 1, true) then
                matches = matches + 1
                if order < PACK_RENDER_CAP then
                    order = order + 1
                    local thumb = e.bundle and ("bundle:" .. e.bundle) or ""
                    local nm, bid = e.name, e.bundle
                    mkThumbRow(packScroll, order, thumb, nm, function() clickPack(nm, bid) end)
                end
            end
        end
        if order == 0 then
            local lbl = Instance.new("TextLabel")
            lbl.Name = "Status"
            lbl.Parent = packScroll
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 0, 30)
            lbl.Font = F
            lbl.TextSize = 12
            lbl.TextColor3 = T.Tx4; pcall(function() lbl:SetAttribute("ThemeColorRole_TextColor3", "Tx4") end)
            lbl.Text = "No matches."
        end
    end
    PackState.refreshPacksFn = refreshPacks
    packSearch:GetPropertyChangedSignal("Text"):Connect(refreshPacks)
    refreshPacks()
    -- Load the limited catalog slice in the background; the UI never renders more than 100 rows.
    fetchAllPacks(function() refreshPacks() end)

    mkAction(secPacks, "Reset To Default Animations", function() resetToDefaultAnimations(false) end, 3)

    -- Re-apply the chosen pack after every respawn: MM2 rebuilds the Animate script each round, which
    -- would otherwise silently revert you to the default walk/idle mid-session.
    tc(LP.CharacterAdded:Connect(function()
        if not currentPackName then return end
        task.spawn(function()
            task.wait(1) -- let MM2's Animate script finish rebuilding first
            local pack = STATIC_PACKS[currentPackName] or PackState.resolvedCache[currentPackName]
            if pack and type(pack) == "table" then applyResolvedPack(currentPackName, pack) end
        end)
    end))
    -- Persist the applied pack across relaunches (only re-applies packs we can resolve offline:
    -- curated STATIC_PACKS or ones already in PackState.resolvedCache from a previous click).
    table.insert(ConfigControls, {
        id = "Player/Animation Pack/AppliedPack",
        get = function() return currentPackName end,
        set = function(v)
            if type(v) ~= "string" or v == "" then return end
            currentPackName = v
            task.spawn(function()
                for _ = 1, 6 do
                    local pack = STATIC_PACKS[v] or PackState.resolvedCache[v]
                    local c = LP.Character
                    if pack and type(pack) == "table" and c and c:FindFirstChild("Animate")
                        and c:FindFirstChildOfClass("Humanoid") then
                        applyResolvedPack(v, pack)
                        return
                    end
                    task.wait(1)
                end
            end)
        end,
    })
    _pl.pCard = secPacks and secPacks.Parent  -- expose card to outer scope
    end -- end Animations do-block

    do
    -- ================= SKINS (Gun + Knife) =================
    -- Purely visual, local-only: overwrites the SpecialMesh on whichever Handle (Character or
    -- Backpack) your Gun/Knife Tool currently has. Reads Sync.Item DIRECTLY — the exact same item
    -- database MM2's own shop/inventory UI reads from (live-verified: 973 entries total, ItemType
    -- Gun=343 / Knife=614) — so this covers literally every skin in the game with zero hardcoded
    -- data and zero catalog-fetch delay (unlike Emotes/Animation Packs, this is one synchronous
    -- require(), no async search needed).
    local secSkins = mkSection(Pages.Player, "Skins", 3)

    local skinCatBar = Instance.new("Frame")
    skinCatBar.Name = "SkinCatBar"
    skinCatBar.LayoutOrder = 0
    skinCatBar.BackgroundTransparency = 1
    skinCatBar.Size = UDim2.new(1, 0, 0, 30)
    skinCatBar.Parent = secSkins
    local skinCatList = Instance.new("UIListLayout")
    skinCatList.FillDirection = Enum.FillDirection.Horizontal
    skinCatList.SortOrder = Enum.SortOrder.LayoutOrder
    skinCatList.Padding = UDim.new(0, 8)
    skinCatList.Parent = skinCatBar
    local gunCatBtn = Instance.new("TextButton")
    local knifeCatBtn = Instance.new("TextButton")
    local gunCatStroke = mkSubTabBtn(skinCatBar, gunCatBtn, "Gun Skins", 1)
    local knifeCatStroke = mkSubTabBtn(skinCatBar, knifeCatBtn, "Knife Skins", 2)

    local skinSearch = mkSearchBox(secSkins, 1, "Search skins...")
    -- Dedicated GRID scroll (not the shared mkListScroll, which is a single-column list used by
    -- Emotes/Animation Packs) — user asked for actual picture tiles ("квадратики") rather than a
    -- text list with a tiny icon, so this is its own square-tile layout local to the Skins tab only.
    local skinScroll = Instance.new("ScrollingFrame")
    skinScroll.Name = "SkinGrid"
    skinScroll.LayoutOrder = 2
    skinScroll.BackgroundColor3 = T.Card; pcall(function() skinScroll:SetAttribute("ThemeColorRole_BackgroundColor3", "Card") end)
    skinScroll.BorderSizePixel = 0
    skinScroll.Size = UDim2.new(1, 0, 0, 340)
    skinScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    skinScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    skinScroll.ScrollBarThickness = 3
    skinScroll.ScrollBarImageColor3 = T.Tx3; pcall(function() skinScroll:SetAttribute("ThemeColorRole_ScrollBarImageColor3", "Tx3") end)
    skinScroll.Parent = secSkins
    Corner(skinScroll, 8)
    Stroke(skinScroll, T.Bd, 1, 0.4)
    Pad(skinScroll, 6, 6, 6, 6)
    local skinGridLayout = Instance.new("UIGridLayout")
    skinGridLayout.CellSize = UDim2.new(1/3, -6, 0, 108)
    skinGridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
    skinGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    skinGridLayout.Parent = skinScroll

    -- Square picture tile: the image fills almost the whole tile (that's the actual point — see a
    -- real picture of the skin, not just its name), name caption sits in a thin strip underneath.
    local function mkSkinTile(parent, order, imgUrl, titleText, onClick)
        local tile = Instance.new("TextButton")
        tile.Name = "Row"
        tile.LayoutOrder = order
        tile.AutoButtonColor = false
        tile.BorderSizePixel = 0
        tile.Text = ""
        tile.BackgroundColor3 = T.Elev; pcall(function() tile:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
        tile.Parent = parent
        Corner(tile, 8)
        tile.MouseEnter:Connect(function() TweenService.Create(TweenService, tile, TweenInfo.new(0.1), { BackgroundColor3 = T.Hover }):Play() end)
        tile.MouseLeave:Connect(function() TweenService.Create(TweenService, tile, TweenInfo.new(0.1), { BackgroundColor3 = T.Elev }):Play() end)

        local img = Instance.new("ImageLabel")
        img.Name = "Thumb"
        img.Parent = tile
        img.BackgroundTransparency = 1
        img.AnchorPoint = Vector2.new(0.5, 0)
        img.Position = UDim2.new(0.5, 0, 0, 6)
        img.Size = UDim2.new(1, -12, 1, -34)
        img.ScaleType = Enum.ScaleType.Fit
        img.Image = imgUrl or ""
        Corner(img, 6)

        local lbl = Instance.new("TextLabel")
        lbl.Name = "Title"
        lbl.Parent = tile
        lbl.BackgroundTransparency = 1
        lbl.AnchorPoint = Vector2.new(0.5, 1)
        lbl.Position = UDim2.new(0.5, 0, 1, -4)
        lbl.Size = UDim2.new(1, -8, 0, 24)
        lbl.Font = F
        lbl.TextSize = 11
        lbl.TextColor3 = T.Tx; pcall(function() lbl:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
        lbl.TextXAlignment = Enum.TextXAlignment.Center
        lbl.TextWrapped = true
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.Text = titleText

        tile.MouseButton1Click:Connect(function() SFX.Click(); onClick() end)
        return tile
    end

    -- Grouped into one table (same register-saving move as PackState elsewhere in this file — this
    -- whole script lives right at Luau's 200-local ceiling): activeCat, the Gun/Knife skin lists, the
    -- per-weapon "original mesh" snapshot cache (so Reset can put it back), and the PERSISTENT learned-
    -- mesh cache (see below) all live under one local — every helper function below is attached as a
    -- SkinState.* field instead of its own top-level local, for the same register-pressure reason.
    local SkinState = { activeCat = "Gun", gunSkins = {}, knifeSkins = {}, originalMesh = {}, meshCache = {}, activeSkins = { Gun = nil, Knife = nil } }
    SkinState.fallbackMeshes = {
        DefaultKnife = {
            MeshId = "rbxassetid://121946387", TextureId = "rbxassetid://121944805", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        Heat = {
            MeshId = "rbxassetid://105351545", TextureId = "rbxassetid://105351561", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        HeatChroma = {
            MeshId = "rbxassetid://105351545", TextureId = "rbxassetid://105351561", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        Slasher = {
            MeshId = "rbxassetid://237305910", TextureId = "rbxassetid://237305963", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        SlasherChroma = {
            MeshId = "rbxassetid://237305910", TextureId = "rbxassetid://237305963", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        Tides = {
            MeshId = "rbxassetid://141115205", TextureId = "rbxassetid://141115217", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        TidesChroma = {
            MeshId = "rbxassetid://141115205", TextureId = "rbxassetid://141115217", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        Deathshard = {
            MeshId = "rbxassetid://173747681", TextureId = "rbxassetid://173747690", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        DeathshardChroma = {
            MeshId = "rbxassetid://173747681", TextureId = "rbxassetid://173747690", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        Fang = {
            MeshId = "rbxassetid://207865261", TextureId = "rbxassetid://207865287", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        FangChroma = {
            MeshId = "rbxassetid://207865261", TextureId = "rbxassetid://207865287", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        Candy = {
            MeshId = "rbxassetid://186981885", TextureId = "rbxassetid://186981907", MeshType = "FileMesh",
            Scale = Vector3.new(1.1, 1.1, 1.1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        Icewing = {
            MeshId = "rbxassetid://2618991475", TextureId = "rbxassetid://2618991660", MeshType = "FileMesh",
            Scale = Vector3.new(1.1, 1.1, 1.1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        ElderwoodScythe = {
            MeshId = "rbxassetid://4303499120", TextureId = "rbxassetid://4303499252", MeshType = "FileMesh",
            Scale = Vector3.new(1.1, 1.1, 1.1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        Batwing = {
            MeshId = "rbxassetid://1250269389", TextureId = "rbxassetid://1250269490", MeshType = "FileMesh",
            Scale = Vector3.new(1.1, 1.1, 1.1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        DefaultGun = {
            MeshId = "rbxassetid://116035017", TextureId = "rbxassetid://116035012", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        Luger = {
            MeshId = "rbxassetid://95356090", TextureId = "rbxassetid://95387789", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        LugerChroma = {
            MeshId = "rbxassetid://95356090", TextureId = "rbxassetid://95387789", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        GingerLuger = {
            MeshId = "rbxassetid://186981958", TextureId = "rbxassetid://186981987", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        Laser = {
            MeshId = "rbxassetid://116035039", TextureId = "rbxassetid://116035031", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        LaserChroma = {
            MeshId = "rbxassetid://116035039", TextureId = "rbxassetid://116035031", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        Amerilaser = {
            MeshId = "rbxassetid://116035039", TextureId = "rbxassetid://298565538", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        Lightbringer = {
            MeshId = "rbxassetid://4580517812", TextureId = "rbxassetid://4580518047", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        ChromaLightbringer = {
            MeshId = "rbxassetid://4580517812", TextureId = "rbxassetid://4580518047", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        Darkbringer = {
            MeshId = "rbxassetid://4580517812", TextureId = "rbxassetid://4580518210", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        ChromaDarkbringer = {
            MeshId = "rbxassetid://4580517812", TextureId = "rbxassetid://4580518210", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        Sugar = {
            MeshId = "rbxassetid://186981958", TextureId = "rbxassetid://186981987", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        Icebreaker = {
            MeshId = "rbxassetid://6078330752", TextureId = "rbxassetid://6078330962", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        },
        ElderwoodGun = {
            MeshId = "rbxassetid://4303498802", TextureId = "rbxassetid://4303498967", MeshType = "FileMesh",
            Scale = Vector3.new(1, 1, 1), Offset = Vector3.zero, VertexColor = Vector3.new(1, 1, 1)
        }
    }

    -- PERSISTENT MESH CACHE: every real MeshId/TextureId this account has ever actually SEEN on a live
    -- player gets saved to disk (MM2_Configs/_skin_mesh_cache.json), keyed by "ItemType|skinKey". This is
    -- what actually gets you closer to "wear any skin any time" within the hard constraint that the real
    -- mesh mapping is server-only data (see the note below findLiveMeshFor) — a skin only needs to be
    -- learned ONCE, ever, by anyone in any past match, and after that it's instantly available forever,
    -- even if nobody's currently wearing it. A background scan (every 3s) passively learns from EVERY
    -- visible player's gear, not just whatever skin you happen to click on, so the library grows just
    -- from playing normally.
    do
        local MESH_CACHE_PATH = "MM2_Configs/_skin_mesh_cache.json"
        function SkinState.cacheKey(itemType, key) return itemType .. "|" .. key end
        function SkinState.saveMeshCache()
            if not (writefile and makefolder and isfolder) then return end
            pcall(function()
                if not isfolder("MM2_Configs") then makefolder("MM2_Configs") end
                local out = {}
                for k, v in pairs(SkinState.meshCache) do
                    out[k] = {
                        MeshId = v.MeshId, TextureId = v.TextureId, MeshType = v.MeshType,
                        Scale = { x = v.Scale.X, y = v.Scale.Y, z = v.Scale.Z },
                        Offset = { x = v.Offset.X, y = v.Offset.Y, z = v.Offset.Z },
                        VertexColor = { x = v.VertexColor.X, y = v.VertexColor.Y, z = v.VertexColor.Z },
                    }
                end
                writefile(MESH_CACHE_PATH, game:GetService("HttpService"):JSONEncode(out))
            end)
        end
        if readfile and isfile and isfile(MESH_CACHE_PATH) then
            local ok, data = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(MESH_CACHE_PATH)) end)
            if ok and type(data) == "table" then
                for k, v in pairs(data) do
                    if type(v) == "table" then
                        SkinState.meshCache[k] = {
                            MeshId = v.MeshId, TextureId = v.TextureId, MeshType = v.MeshType,
                            Scale = Vector3.new(v.Scale.x, v.Scale.y, v.Scale.z),
                            Offset = Vector3.new(v.Offset.x, v.Offset.y, v.Offset.z),
                            VertexColor = Vector3.new(v.VertexColor.x, v.VertexColor.y, v.VertexColor.z),
                        }
                    end
                end
            end
        end
        function SkinState.learnMesh(itemType, key, mesh)
            local ck = SkinState.cacheKey(itemType, key)
            if SkinState.meshCache[ck] then return end -- already known — don't rewrite the file every scan
            local mType = mesh.MeshType
            local mTypeName = (typeof(mType) == "EnumItem") and mType.Name or tostring(mType)
            SkinState.meshCache[ck] = {
                MeshId = mesh.MeshId, TextureId = mesh.TextureId, MeshType = mTypeName,
                Scale = mesh.Scale, Offset = mesh.Offset, VertexColor = mesh.VertexColor,
            }
            SkinState.saveMeshCache()
        end
        function SkinState.meshFromCache(itemType, key)
            local c = SkinState.meshCache[SkinState.cacheKey(itemType, key)]
            if not c then return nil end
            local mType = c.MeshType
            if type(mType) == "string" then
                mType = Enum.MeshType[mType] or Enum.MeshType.FileMesh
            end
            return {
                MeshType = mType or Enum.MeshType.FileMesh,
                MeshId = c.MeshId, TextureId = c.TextureId,
                Scale = c.Scale, Offset = c.Offset, VertexColor = c.VertexColor,
            }
        end
    end
    -- Passive learner: scans everyone currently visible and caches any skin we haven't recorded yet.
    -- Runs regardless of whether the Skins tab is even open — the library builds up just from playing
    -- normally. Sped up from the original 3s interval to 1s (a plain GearCache/Handle/SpecialMesh scan
    -- is cheap — no per-player getRole or network calls) so new skins get cached as fast as possible,
    -- and exposed as SkinState.scanNow() so the Skins tab can also trigger an immediate scan the instant
    -- it's opened instead of waiting for the next tick.
    function SkinState.scanNow()
        for pn, gear in pairs(GearCache) do
            local p = Players:FindFirstChild(pn)
            if p and p ~= LP and p.Character then
                local pbp = p:FindFirstChild("Backpack")
                for _, itemType in ipairs({ "Gun", "Knife" }) do
                    local key = gear[itemType]
                    if key and key ~= ("Default" .. itemType) and not SkinState.meshCache[SkinState.cacheKey(itemType, key)] then
                        local ptool = nil
                        if itemType == "Knife" then
                            ptool = p.Character:FindFirstChild("Knife") or p.Character:FindFirstChild("KnifeServer")
                                or (pbp and (pbp:FindFirstChild("Knife") or pbp:FindFirstChild("KnifeServer")))
                        elseif itemType == "Gun" then
                            ptool = p.Character:FindFirstChild("Gun") or p.Character:FindFirstChild("Revolver")
                                or (pbp and (pbp:FindFirstChild("Gun") or pbp:FindFirstChild("Revolver")))
                        end
                        local phandle = ptool and ptool:FindFirstChild("Handle")
                        local pmesh = phandle and phandle:FindFirstChildOfClass("SpecialMesh")
                        if pmesh then SkinState.learnMesh(itemType, key, pmesh) end
                    end
                end
            end
        end
    end
    S._SkinScanNow = SkinState.scanNow
    task.spawn(function()
        while S.Gui and S.Gui.Parent do
            task.wait(1)
            pcall(SkinState.scanNow)
        end
    end)
    do
        local ok, Sync = pcall(function()
            return require(game:GetService("ReplicatedStorage"):WaitForChild("Database"):WaitForChild("Sync"))
        end)
        if ok and Sync and type(Sync.Item) == "table" then
            for key, v in pairs(Sync.Item) do
                if type(v) == "table" and v.ItemID then
                    local entry = { key = key, name = tostring(v.ItemName or key), id = v.ItemID }
                    if v.ItemType == "Gun" then table.insert(SkinState.gunSkins, entry)
                    elseif v.ItemType == "Knife" then table.insert(SkinState.knifeSkins, entry) end
                end
            end
            table.sort(SkinState.gunSkins, function(a, b) return a.name:lower() < b.name:lower() end)
            table.sort(SkinState.knifeSkins, function(a, b) return a.name:lower() < b.name:lower() end)
        end
    end

    -- IMPORTANT (live-verified 2026-07-17): the real 3D MeshId/TextureId for a skin is NOT derivable
    -- from Sync.Item's ItemID — that id is only the 2D shop-icon thumbnail (confirmed against the
    -- game's own ItemService.GetItemImage, which uses the exact same id the exact same way we do for
    -- thumbnails). Inspected an actually-equipped skin live: its real MeshId/TextureId matched NOTHING
    -- in Sync.Item/Sync.Weapons and doesn't appear in any client-visible script at all — that mapping
    -- only exists server-side, full stop, confirmed by an exhaustive script-grep for the literal real
    -- mesh id across every client-visible script. There is NO way to fabricate the correct mesh for a
    -- skin the client has never observed. What we CAN do (and now do): copy it from whoever is CURRENTLY
    -- wearing it, AND permanently remember it afterward (SkinState.meshCache, persisted to disk) so it
    -- never needs to be re-observed again — see the cache block above. Applying now checks, in order:
    -- (1) the persistent cache (works even if nobody's around wearing it), (2) a live player currently
    -- wearing it (and learns it for next time), (3) gives up honestly.
    local function findLiveMeshFor(itemType, key)
        for pn, gear in pairs(GearCache) do
            if gear[itemType] == key then
                local p = Players:FindFirstChild(pn)
                if p and p ~= LP and p.Character then
                    local pbp = p:FindFirstChild("Backpack")
                    local ptool = nil
                    if itemType == "Knife" then
                        ptool = p.Character:FindFirstChild("Knife") or p.Character:FindFirstChild("KnifeServer")
                            or (pbp and (pbp:FindFirstChild("Knife") or pbp:FindFirstChild("KnifeServer")))
                    elseif itemType == "Gun" then
                        ptool = p.Character:FindFirstChild("Gun") or p.Character:FindFirstChild("Revolver")
                            or (pbp and (pbp:FindFirstChild("Gun") or pbp:FindFirstChild("Revolver")))
                    end
                    local phandle = ptool and ptool:FindFirstChild("Handle")
                    local pmesh = phandle and phandle:FindFirstChildOfClass("SpecialMesh")
                    if pmesh then return pmesh end
                end
            end
        end
        return nil
    end

    local function findMeshInReplicatedStorage(itemType, key)
        local rep = game:GetService("ReplicatedStorage")
        local lkey = key:lower()
        for _, desc in ipairs(rep:GetDescendants()) do
            local dName = desc.Name:lower()
            if dName == lkey or dName == lkey .. "knife" or dName == lkey .. "gun" or dName == lkey .. "revolver" then
                local mesh = desc:FindFirstChildOfClass("SpecialMesh") 
                    or (desc:IsA("MeshPart") and desc)
                if not mesh and desc:FindFirstChild("Handle") then
                    mesh = desc.Handle:FindFirstChildOfClass("SpecialMesh") 
                        or (desc.Handle:IsA("MeshPart") and desc.Handle)
                end
                if mesh then
                    return {
                        MeshType = mesh:IsA("SpecialMesh") and mesh.MeshType or Enum.MeshType.FileMesh,
                        MeshId = mesh.MeshId,
                        TextureId = mesh.TextureId,
                        Scale = mesh.Scale,
                        Offset = mesh:IsA("SpecialMesh") and mesh.Offset or Vector3.zero,
                        VertexColor = mesh:IsA("SpecialMesh") and mesh.VertexColor or Vector3.new(1, 1, 1),
                    }
                end
            end
        end
        return nil
    end

    local function applyEffectsAndSounds(tool, itemType)
        local key = SkinState.activeSkins[itemType]
        if not key then return end
        local handle = tool:FindFirstChild("Handle")
        if not handle then return end
        
        for _, child in ipairs(handle:GetChildren()) do
            if child.Name:sub(1, 11) == "SkinEffect_" then
                child:Destroy()
            end
        end
        
        local lkey = key:lower()
        if lkey == "heat" or lkey == "heatchroma" then
            local f = Instance.new("Fire")
            f.Name = "SkinEffect_Fire"
            f.Color = Color3.fromRGB(255, 80, 0)
            f.SecondaryColor = Color3.fromRGB(255, 180, 0)
            f.Size = 3
            f.Heat = 5
            f.Parent = handle
            
            local a0 = Instance.new("Attachment", handle)
            a0.Name = "SkinEffect_A0"
            a0.Position = Vector3.new(0, -0.4, 0)
            local a1 = Instance.new("Attachment", handle)
            a1.Name = "SkinEffect_A1"
            a1.Position = Vector3.new(0, 1.2, 0)
            local t = Instance.new("Trail")
            t.Name = "SkinEffect_Trail"
            t.Attachment0 = a0
            t.Attachment1 = a1
            t.Color = ColorSequence.new(Color3.fromRGB(255, 80, 0), Color3.fromRGB(255, 180, 0))
            t.Lifetime = 0.25
            t.Parent = handle
        elseif lkey == "slasher" or lkey == "slasherchroma" then
            local pe = Instance.new("ParticleEmitter")
            pe.Name = "SkinEffect_PE"
            pe.Color = ColorSequence.new(Color3.fromRGB(150, 0, 255))
            pe.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 0)})
            pe.Lifetime = NumberRange.new(0.3, 0.6)
            pe.Rate = 30
            pe.Speed = NumberRange.new(0.2, 1.0)
            pe.Texture = "rbxassetid://258129035"
            pe.Parent = handle
            
            local a0 = Instance.new("Attachment", handle)
            a0.Name = "SkinEffect_A0"
            a0.Position = Vector3.new(0, -0.4, 0)
            local a1 = Instance.new("Attachment", handle)
            a1.Name = "SkinEffect_A1"
            a1.Position = Vector3.new(0, 1.2, 0)
            local t = Instance.new("Trail")
            t.Name = "SkinEffect_Trail"
            t.Attachment0 = a0
            t.Attachment1 = a1
            t.Color = ColorSequence.new(Color3.fromRGB(100, 0, 200), Color3.fromRGB(50, 0, 100))
            t.Lifetime = 0.25
            t.Parent = handle
        elseif lkey == "laser" or lkey == "laserchroma" or lkey == "amerilaser" then
            local sparkles = Instance.new("Sparkles")
            sparkles.Name = "SkinEffect_Sparkles"
            sparkles.SparkleColor = Color3.fromRGB(0, 255, 255)
            sparkles.Parent = handle
        elseif lkey == "luger" or lkey == "lugerchroma" or lkey == "gingerluger" then
            local sparkles = Instance.new("Sparkles")
            sparkles.Name = "SkinEffect_Sparkles"
            sparkles.SparkleColor = Color3.fromRGB(255, 215, 0)
            sparkles.Parent = handle
        elseif lkey == "icewing" or lkey == "icebreaker" then
            local pe = Instance.new("ParticleEmitter")
            pe.Name = "SkinEffect_PE"
            pe.Color = ColorSequence.new(Color3.fromRGB(150, 220, 255))
            pe.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 0)})
            pe.Lifetime = NumberRange.new(0.4, 0.8)
            pe.Rate = 25
            pe.Speed = NumberRange.new(0.2, 0.8)
            pe.Texture = "rbxassetid://252795493"
            pe.Parent = handle
        elseif lkey == "candy" or lkey == "sugar" then
            local pe = Instance.new("ParticleEmitter")
            pe.Name = "SkinEffect_PE"
            pe.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 0, 0))
            pe.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 0)})
            pe.Lifetime = NumberRange.new(0.3, 0.5)
            pe.Rate = 35
            pe.Speed = NumberRange.new(0.4, 1.2)
            pe.Texture = "rbxassetid://108499119"
            pe.Parent = handle
        end
        
        local function checkSound(sound)
            local name = sound.Name:lower()
            if itemType == "Knife" then
                if name:find("slash") or name:find("swing") then
                    sound.SoundId = "rbxassetid://2616235552"
                elseif name:find("equip") then
                    sound.SoundId = "rbxassetid://2616235122"
                end
            elseif itemType == "Gun" then
                if name:find("shoot") or name:find("fire") then
                    if lkey == "luger" or lkey == "lugerchroma" or lkey == "gingerluger" then
                        sound.SoundId = "rbxassetid://130113146"
                    elseif lkey == "laser" or lkey == "laserchroma" or lkey == "amerilaser" then
                        sound.SoundId = "rbxassetid://130113146"
                    end
                elseif name:find("equip") or name:find("reload") then
                    if lkey == "luger" or lkey == "lugerchroma" or lkey == "gingerluger" then
                        sound.SoundId = "rbxassetid://131072979"
                    end
                end
            end
        end
        
        for _, child in ipairs(tool:GetDescendants()) do
            if child:IsA("Sound") then
                checkSound(child)
            end
        end
        -- Hook future Sound children ONCE per tool. applySkin (hence this function) runs on every tool
        -- equip AND every skin click, so an unguarded Connect here piled a fresh DescendantAdded handler
        -- onto the same tool each time — a connection leak. The attribute guard caps it at one; existing
        -- sounds are still re-tweaked every call by the loop above (which uses the current skin's lkey).
        if not tool:GetAttribute("_SkinSoundHooked") then
            tool:SetAttribute("_SkinSoundHooked", true)
            tool.DescendantAdded:Connect(function(desc)
                if desc:IsA("Sound") then
                    checkSound(desc)
                end
            end)
        end
    end

    local function applySkin(itemType, key, name, silent)
        SkinState.activeSkins[itemType] = key
        local c = LP.Character
        local bp = LP:FindFirstChild("Backpack")
        local tool = nil
        if itemType == "Knife" then
            tool = (c and (c:FindFirstChild("Knife") or c:FindFirstChild("KnifeServer")))
                or (bp and (bp:FindFirstChild("Knife") or bp:FindFirstChild("KnifeServer")))
        elseif itemType == "Gun" then
            tool = (c and (c:FindFirstChild("Gun") or c:FindFirstChild("Revolver")))
                or (bp and (bp:FindFirstChild("Gun") or bp:FindFirstChild("Revolver")))
        end
        if not tool then return end
        local handle = tool:FindFirstChild("Handle")
        if not handle then return end

        local srcMesh = SkinState.meshFromCache(itemType, key)
        if not srcMesh then
            local liveMesh = findLiveMeshFor(itemType, key)
            if liveMesh then
                SkinState.learnMesh(itemType, key, liveMesh)
                srcMesh = SkinState.meshFromCache(itemType, key)
            end
        end
        if not srcMesh then
            srcMesh = findMeshInReplicatedStorage(itemType, key)
        end
        if not srcMesh then
            local lkey = key:lower()
            for fKey, fMesh in pairs(SkinState.fallbackMeshes) do
                if fKey:lower() == lkey then
                    srcMesh = fMesh
                    break
                end
            end
            if srcMesh then
                SkinState.learnMesh(itemType, key, srcMesh)
                srcMesh = SkinState.meshFromCache(itemType, key)
            end
        end
        if not srcMesh then
            if not silent then
                Notify("Skins", "Skin not cached yet. Wait for someone to equip it!", 3)
            end
            return
        end

        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
        if mesh then
            if SkinState.originalMesh[itemType] == nil then
                SkinState.originalMesh[itemType] = { existed = true, MeshId = mesh.MeshId, TextureId = mesh.TextureId, Scale = mesh.Scale, Offset = mesh.Offset, VertexColor = mesh.VertexColor, MeshType = mesh.MeshType }
            end
        else
            mesh = Instance.new("SpecialMesh")
            mesh.Name = "SkinMesh"
            mesh.Parent = handle
            if SkinState.originalMesh[itemType] == nil then
                SkinState.originalMesh[itemType] = { existed = false }
            end
        end
        pcall(function()
            mesh.MeshType = srcMesh.MeshType
            mesh.MeshId = srcMesh.MeshId
            mesh.TextureId = srcMesh.TextureId
            mesh.Scale = srcMesh.Scale
            mesh.Offset = srcMesh.Offset
            mesh.VertexColor = srcMesh.VertexColor
        end)
        applyEffectsAndSounds(tool, itemType)
        if not silent then
            Notify("Skins", "Applied " .. tostring(name), 2)
        end
    end

    local function monitorInventory(parent)
        parent.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                local itemType = nil
                if child.Name == "Knife" or child.Name == "KnifeServer" then
                    itemType = "Knife"
                elseif child.Name == "Gun" or child.Name == "Revolver" then
                    itemType = "Gun"
                end
                if itemType then
                    task.wait(0.05)
                    local activeKey = SkinState.activeSkins[itemType]
                    if activeKey then
                        applySkin(itemType, activeKey, activeKey, true)
                    end
                end
            end
        end)
    end
    if LP.Character then monitorInventory(LP.Character) end
    LP.CharacterAdded:Connect(function(char)
        monitorInventory(char)
    end)
    task.spawn(function()
        local bp = LP:WaitForChild("Backpack", 5)
        if bp then monitorInventory(bp) end
    end)

    local function refreshSkinList()
        for _, ch in ipairs(skinScroll:GetChildren()) do
            if ch.Name == "Row" or ch.Name == "Status" then ch:Destroy() end
        end
        local list = (SkinState.activeCat == "Gun") and SkinState.gunSkins or SkinState.knifeSkins
        local q = skinSearch.Text:lower()
        local order = 0
        for _, e in ipairs(list) do
            if q == "" or e.name:lower():find(q, 1, true) then
                order = order + 1
                if order > 120 then break end -- render cap; search still reaches every item, just not all rendered at once
                local thumb = "rbxthumb://type=Asset&id=" .. tostring(e.id) .. "&w=150&h=150"
                mkSkinTile(skinScroll, order, thumb, e.name, function()
                    applySkin(SkinState.activeCat, e.key, e.name)
                end)
            end
        end
        if order == 0 then
            local lbl = Instance.new("TextLabel")
            lbl.Name = "Status"
            lbl.Parent = skinScroll
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 0, 30)
            lbl.Font = F
            lbl.TextSize = 12
            lbl.TextColor3 = T.Tx4; pcall(function() lbl:SetAttribute("ThemeColorRole_TextColor3", "Tx4") end)
            lbl.Text = "No matches."
        end
    end
    skinSearch:GetPropertyChangedSignal("Text"):Connect(refreshSkinList)
    local function updateSkinCatButtons()
        styleSubTabActive(gunCatBtn, gunCatStroke, SkinState.activeCat == "Gun")
        styleSubTabActive(knifeCatBtn, knifeCatStroke, SkinState.activeCat == "Knife")
    end
    gunCatBtn.MouseButton1Click:Connect(function() SFX.Click(); SkinState.activeCat = "Gun"; updateSkinCatButtons(); refreshSkinList() end)
    knifeCatBtn.MouseButton1Click:Connect(function() SFX.Click(); SkinState.activeCat = "Knife"; updateSkinCatButtons(); refreshSkinList() end)
    updateSkinCatButtons()
    refreshSkinList()

    mkAction(secSkins, "Reset Skin (current category)", function()
        local c = LP.Character
        local bp = LP:FindFirstChild("Backpack")
        local tool = nil
        if SkinState.activeCat == "Knife" then
            tool = (c and (c:FindFirstChild("Knife") or c:FindFirstChild("KnifeServer")))
                or (bp and (bp:FindFirstChild("Knife") or bp:FindFirstChild("KnifeServer")))
        elseif SkinState.activeCat == "Gun" then
            tool = (c and (c:FindFirstChild("Gun") or c:FindFirstChild("Revolver")))
                or (bp and (bp:FindFirstChild("Gun") or bp:FindFirstChild("Revolver")))
        end
        local handle = tool and tool:FindFirstChild("Handle")
        local mesh = handle and handle:FindFirstChildOfClass("SpecialMesh")
        local orig = SkinState.originalMesh[SkinState.activeCat]
        if mesh and orig ~= nil then
            if orig.existed then
                pcall(function()
                    mesh.MeshType = orig.MeshType
                    mesh.MeshId = orig.MeshId
                    mesh.TextureId = orig.TextureId
                    mesh.Scale = orig.Scale
                    mesh.Offset = orig.Offset
                    mesh.VertexColor = orig.VertexColor
                end)
            else
                mesh:Destroy()
            end
            SkinState.originalMesh[SkinState.activeCat] = nil
            Notify("Skins", "Reset " .. SkinState.activeCat, 2)
        else
            Notify("Skins", "Nothing to reset", 2)
        end
    end, 3)

    local secOutfit = mkSection(Pages.Player, "Character Outfit", 4)
    _pl.oCard = secOutfit and secOutfit.Parent

    local outfitUserBox = Instance.new("TextBox")
    outfitUserBox.Parent = secOutfit
    outfitUserBox.LayoutOrder = 1
    outfitUserBox.Size = UDim2.new(1, 0, 0, 30)
    outfitUserBox.BackgroundColor3 = T.Elev; pcall(function() outfitUserBox:SetAttribute("ThemeColorRole_BackgroundColor3", "Elev") end)
    outfitUserBox.BorderSizePixel = 0
    outfitUserBox.Font = F
    outfitUserBox.TextSize = 13
    outfitUserBox.TextColor3 = T.Tx; pcall(function() outfitUserBox:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
    outfitUserBox.PlaceholderText = "Enter Roblox Username..."
    outfitUserBox.PlaceholderColor3 = T.Tx4
    outfitUserBox.Text = ""
    outfitUserBox.ClearTextOnFocus = false
    outfitUserBox.TextXAlignment = Enum.TextXAlignment.Left
    Corner(outfitUserBox, 6)
    Stroke(outfitUserBox, T.Bd2, 1, 0.4)
    Pad(outfitUserBox, 0, 0, 8, 8)

    local activeVisualOutfitUserId = nil
    
    local function applyVisualOutfit(userId)
        local c = LP.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if not (c and hum) then return end
        
        -- Clean up existing visual appearance
        for _, child in ipairs(c:GetChildren()) do
            if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("BodyColors") or child:IsA("ShirtGraphic") or child:IsA("CharacterMesh") then
                child:Destroy()
            end
        end
        local head = c:FindFirstChild("Head")
        local face = head and head:FindFirstChild("face")
        if face then face:Destroy() end

        -- Fetch avatar JSON from Roblox Web API (works completely client-side in executors!)
        local function httpGet(url)
            local ok, res = pcall(function() return game:HttpGet(url) end)
            if ok and res then return res end
            
            local req = (syn and syn.request) or (http and http.request) or request
            if req then
                local ok2, response = pcall(function()
                    return req({ Url = url, Method = "GET" })
                end)
                if ok2 and response and response.Body then
                    return response.Body
                end
            end
            return nil
        end

        local dataStr = httpGet("https://avatar.roblox.com/v1/users/" .. tostring(userId) .. "/avatar")
        if not dataStr then
            Notify("Visual Outfit", "Failed to load avatar data", 3)
            return
        end

        local httpService = game:GetService("HttpService")
        local ok, data = pcall(function() return httpService:JSONDecode(dataStr) end)
        if not (ok and data) then
            Notify("Visual Outfit", "Failed to parse avatar JSON", 3)
            return
        end

        -- 1. Apply Body Colors
        if data.bodyColors then
            local bc = c:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors", c)
            local function parseHex(hex)
                local r = tonumber(hex:sub(2,3), 16) / 255
                local g = tonumber(hex:sub(4,5), 16) / 255
                local b = tonumber(hex:sub(6,7), 16) / 255
                return Color3.new(r, g, b)
            end
            pcall(function()
                bc.HeadColor3 = parseHex(data.bodyColors.headColorHex)
                bc.TorsoColor3 = parseHex(data.bodyColors.torsoColorHex)
                bc.LeftArmColor3 = parseHex(data.bodyColors.leftArmColorHex)
                bc.RightArmColor3 = parseHex(data.bodyColors.rightArmColorHex)
                bc.LeftLegColor3 = parseHex(data.bodyColors.leftLegColorHex)
                bc.RightLegColor3 = parseHex(data.bodyColors.rightLegColorHex)
            end)
        end

        -- Accessories do NOT auto-weld when you just set `Accessory.Parent = character` on the CLIENT
        -- (verified live: the Handle stays unwelded ~600 studs away at the world origin), and neither
        -- `Humanoid:AddAccessory` nor `Humanoid:ApplyDescription` work here — ApplyDescription is
        -- server-only ("can only be called by the backend server") and client AddAccessory silently
        -- fails to create the rig link in an executor context. Modern R15 accessories are held on by a
        -- `RigidConstraint` (named AccessoryRigidConstraint) tying the Handle's attachment (HatAttachment,
        -- HairAttachment, FaceFrontAttachment, ...) to the matching attachment on a body part — exactly
        -- how the character's OWN accessories are rigged. So we build that constraint by hand, which is
        -- the only thing that actually lands the hat/hair on the head client-side (verified: 0.6 studs).
        local function attachAccessory(acc)
            local handle = acc:FindFirstChild("Handle")
            if not handle then acc.Parent = c; return end
            if handle:FindFirstChildOfClass("RigidConstraint") or handle:FindFirstChildOfClass("Weld") then
                acc.Parent = c; return
            end
            local accAtt = handle:FindFirstChildOfClass("Attachment")
            if accAtt then
                local bodyAtt
                for _, part in ipairs(c:GetChildren()) do
                    if part:IsA("BasePart") then
                        local m = part:FindFirstChild(accAtt.Name)
                        if m and m:IsA("Attachment") then bodyAtt = m; break end
                    end
                end
                if bodyAtt then
                    local rc = Instance.new("RigidConstraint")
                    rc.Name = "AccessoryRigidConstraint"
                    rc.Attachment0 = accAtt
                    rc.Attachment1 = bodyAtt
                    rc.Parent = handle
                end
            end
            acc.Parent = c
        end

        -- 2. Load and Apply Assets (clothing, accessories, hair, face, etc.)
        if data.assets then
            for _, asset in ipairs(data.assets) do
                local assetTypeName = asset.assetType and asset.assetType.name
                -- Skip animations (they fail to load client-side due to Roblox creator ownership checks)
                if assetTypeName ~= "Animation" and assetTypeName ~= "EmoteAnimation" then
                    task.spawn(function()
                        local okObj, objects = pcall(function()
                            return game:GetObjects("rbxassetid://" .. tostring(asset.id))
                        end)
                        if okObj and objects then
                            local function applySingleObj(obj)
                                if obj:IsA("Accessory") then
                                    attachAccessory(obj:Clone())
                                elseif obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or obj:IsA("CharacterMesh") then
                                    obj:Clone().Parent = c
                                elseif obj:IsA("Decal") and (obj.Name == "face" or obj.Parent and obj.Parent.Name:lower():find("face")) then
                                    if head then
                                        local newFace = obj:Clone()
                                        newFace.Parent = head
                                    end
                                end
                            end

                            for _, rootObj in ipairs(objects) do
                                pcall(function()
                                    applySingleObj(rootObj)
                                    for _, sub in ipairs(rootObj:GetDescendants()) do
                                        applySingleObj(sub)
                                    end
                                end)
                            end
                        end
                    end)
                end
            end
        end
    end

    tc(LP.CharacterAdded:Connect(function(char)
        if activeVisualOutfitUserId then
            task.wait(0.3)
            pcall(applyVisualOutfit, activeVisualOutfitUserId)
        end
    end))

    mkAction(secOutfit, "Apply Outfit", function()
        local name = outfitUserBox.Text
        if name == "" then
            Notify("Visual Outfit", "Please enter a username", 2)
            return
        end
        Notify("Visual Outfit", "Loading appearance...", 2)
        task.spawn(function()
            local success, uid = pcall(function()
                return Players:GetUserIdFromNameAsync(name)
            end)
            if success and uid then
                activeVisualOutfitUserId = uid
                pcall(applyVisualOutfit, uid)
                Notify("Visual Outfit", "Outfit applied!", 2)
            else
                Notify("Visual Outfit", "User not found", 3)
            end
        end)
    end, 2)

    mkAction(secOutfit, "Reset Outfit", function()
        activeVisualOutfitUserId = nil
        Notify("Visual Outfit", "Outfit reset...", 2)
        -- Run in its own thread like "Apply Outfit" does: applyVisualOutfit YIELDS (game:HttpGet + the
        -- per-asset game:GetObjects loads), and yielding directly inside the click handler cleaned up the
        -- old accessories first but could leave the character bald if the yield/spawn context got cut off.
        task.spawn(function() pcall(applyVisualOutfit, LP.UserId) end)
    end, 3)

    _pl.sCard = secSkins and secSkins.Parent
    end -- end Skins do-block

    -- ---- subtab visibility ----
    -- Uses _pl.eCard / _pl.pCard / _pl.sCard written by the nested do-blocks above.
    local activePlSubTab = "Emotes"
    local function updatePlSubTabs()
        local isEmotes = (activePlSubTab == "Emotes")
        local isAnims = (activePlSubTab == "Animations")
        local isSkins = (activePlSubTab == "Skins")
        styleSubTabActive(emotesBtn, emotesStroke, isEmotes)
        styleSubTabActive(animsBtn, animsStroke, isAnims)
        styleSubTabActive(skinsBtn, skinsStroke, isSkins)
        if _pl.eCard then pcall(function() _pl.eCard.Visible = isEmotes end) end
        if _pl.pCard then pcall(function() _pl.pCard.Visible = isAnims end) end
        if _pl.sCard then pcall(function() _pl.sCard.Visible = isSkins end) end
        if _pl.oCard then pcall(function() _pl.oCard.Visible = isSkins end) end
    end
    S._UpdatePlayerSubtabs = updatePlSubTabs
    emotesBtn.MouseButton1Click:Connect(function() SFX.Click(); activePlSubTab = "Emotes"; updatePlSubTabs() end)
    animsBtn.MouseButton1Click:Connect(function() SFX.Click(); activePlSubTab = "Animations"; updatePlSubTabs() end)
    skinsBtn.MouseButton1Click:Connect(function()
        SFX.Click(); activePlSubTab = "Skins"; updatePlSubTabs()
        -- Catch whoever's already visible RIGHT NOW instead of waiting up to 1s for the next background tick.
        if S._SkinScanNow then pcall(S._SkinScanNow) end
    end)
    updatePlSubTabs()
end

do
    -- FAST THROW / THROW SPEED — attribute-driven, NO getgc.
    -- Decompiled the live KnifeClient: the throw wind-up is simply `u7 = Knife:GetAttribute("ThrowSpeed")`
    -- (smaller = the knife leaves your hand faster) and the re-throw cooldown is `2 * u7`. The client
    -- snapshots that attribute ONCE, right after it WaitForChild("Handle")/("Events") — which yield — so
    -- if we set the attribute the instant the Knife tool appears we win that race and control the speed
    -- with ZERO ongoing cost. The old approach scanned the ENTIRE GC heap (`getgc()` + `getinfo` on every
    -- closure) every 0.4s to find and patch that upvalue; that heap scan was a ~190ms hitch each pass and
    -- was the real, confirmed source of the "micro freezes" (verified: turning these toggles off removed
    -- the spike entirely). Attributes need none of that.
    local function throwSpeedValue()
        if S.FastThrow then return 0.05 end               -- effectively instant, tiny cooldown
        if S.KnifeThrowSpeedControl then return math.max(S.KnifeThrowWindup or 0, 0.03) end
        return nil                                        -- feature off: leave the game's own value
    end
    local function applyThrowSpeed(knife)
        if not knife then return end
        local v = throwSpeedValue()
        if v == nil then return end
        pcall(function() knife:SetAttribute("ThrowSpeed", v) end)
    end
    -- Set it on any Knife we already hold and on every Knife that appears (race-wins the client read).
    local function watchContainer(container)
        if not container then return end
        local k = container:FindFirstChild("Knife")
        if k then applyThrowSpeed(k) end
        tc(container.ChildAdded:Connect(function(child)
            if child.Name == "Knife" then applyThrowSpeed(child) end
        end))
    end
    local function hookChar(ch)
        watchContainer(ch)
    end
    if LP.Character then hookChar(LP.Character) end
    tc(LP.CharacterAdded:Connect(hookChar))
    local bp = LP:FindFirstChildOfClass("Backpack")
    if bp then watchContainer(bp) end
    tc(LP.ChildAdded:Connect(function(c) if c:IsA("Backpack") then watchContainer(c) end end))
    -- Re-assert when the toggles/slider change so a mid-round change takes effect on the current knife.
    S._ReapplyThrowSpeed = function()
        local c = LP.Character
        if c then applyThrowSpeed(c:FindFirstChild("Knife")) end
        local b = LP:FindFirstChildOfClass("Backpack")
        if b then applyThrowSpeed(b:FindFirstChild("Knife")) end
    end

    -- Fast Throw also suppresses the throw wind-up ANIMATION locally. Event-driven (fires only when an
    -- animation actually starts), matched by name — no per-frame work, no getgc, no id table needed.
    local function isThrowAnimationTrack(track)
        return tostring(track.Name or ""):lower():find("throw", 1, true) ~= nil
    end
    local function hookThrowAnimator(char)
        local hum = char and (char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5))
        local animator = hum and (hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 5))
        if not animator then return end
        tc(animator.AnimationPlayed:Connect(function(track)
            if S.FastThrow and isThrowAnimationTrack(track) then
                pcall(function() track:Stop(0) end)
            end
        end))
    end
    if LP.Character then task.defer(function() hookThrowAnimator(LP.Character) end) end
    tc(LP.CharacterAdded:Connect(function(ch) task.defer(function() hookThrowAnimator(ch) end) end))
end

do
    -- ============ MURDERER KILL SUITE ============
    -- Confirmed kill primitive (decompiled KnifeClient + verified live one-shot): enter the stab state
    -- with KnifeStabbed:FireServer(), then fire HandleTouched:FireServer(part) at the victim's parts
    -- within the ~0.85s stab window. The server registers a knife kill per valid part touched and does
    -- NOT check distance or line-of-sight — so this kills anyone, anywhere, through walls, the instant
    -- you hold the Knife. Everything below is built on this one primitive.
    local function getKnifeEvents()
        -- The Knife lives in the BACKPACK when you haven't equipped it — and its remotes fire fine from
        -- there (verified: killed straight from the backpack knife). Checking only the character missed
        -- that, so every auto-kill silently did nothing until you happened to equip the knife.
        local c = LP.Character
        local knife = (c and c:FindFirstChild("Knife"))
            or (LP:FindFirstChildOfClass("Backpack") and LP.Backpack:FindFirstChild("Knife"))
        local ev = knife and knife:FindFirstChild("Events")
        if not ev then return nil, nil end
        return ev:FindFirstChild("KnifeStabbed"), ev:FindFirstChild("HandleTouched")
    end
    -- No-teleport instant kill: stab + touch only. It never changes the local HumanoidRootPart CFrame,
    -- so it is safe for the standing-still Kill All action and the Kill All toggle.
    local function killInstant(p)
        if not (p and p ~= LP and p.Character) or isWhitelisted(p) then return false end
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        if not (hum and hum.Health > 0) then return false end
        local stab, touched = getKnifeEvents()
        if not (stab and touched) then return false end
        pcall(function() stab:FireServer() end)
        for _, part in ipairs(p.Character:GetChildren()) do
            if part:IsA("BasePart") then pcall(function() touched:FireServer(part) end) end
        end
        return true
    end
    -- Any-range kill: if the victim is too far for the server's proximity check, BLINK to them, kill,
    -- and blink straight back to where you were (verified live: killed a target 113 studs away). Runs on
    -- its own thread and is serialized by `killing` so the auto-loops never yield and two blinks never
    -- fight over the HumanoidRootPart.
    local killing = false
    local function murdererKill(p)
        if killing then return false end
        if not (p and p ~= LP and p.Character) or isWhitelisted(p) then return false end
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        if not (hum and hum.Health > 0) then return false end
        local stab, touched = getKnifeEvents()
        if not (stab and touched) then return false end
        killing = true
        task.spawn(function()
            local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            local vRoot = p.Character:FindFirstChild("HumanoidRootPart")
            local saved
            if myRoot and vRoot and (myRoot.Position - vRoot.Position).Magnitude > 10 then
                saved = myRoot.CFrame
                pcall(function() myRoot.CFrame = vRoot.CFrame * CFrame.new(0, 0, 3) end)
                task.wait(0.2) -- let the blink replicate so the server sees the knife next to them (0.12 was too tight — verified 0.2 kills at range)
            end
            pcall(function() stab:FireServer() end)
            if p.Character then
                for _, part in ipairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") then pcall(function() touched:FireServer(part) end) end
                end
            end
            -- hold at the victim until the server has processed the kill, THEN blink back (blinking back
            -- too early put us far again before the server registered the touch — that's why it missed).
            if saved then task.wait(0.2); pcall(function() myRoot.CFrame = saved end) end
            killing = false
        end)
        return true
    end
    S._MurdererKill = murdererKill  -- exposed for the Kill Nearest / Kill Target action buttons + keybinds
    local function nearestPlayer()
        local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return nil end
        local best, bestD
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and not isWhitelisted(p) then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if r and hum and hum.Health > 0 then
                    local d = (r.Position - myRoot.Position).Magnitude
                    if not bestD or d < bestD then bestD = d; best = p end
                end
            end
        end
        return best
    end
    S._MurdererNearest = nearestPlayer
    local function isArmed(p)  -- Sheriff/Hero = the only players who can shoot back
        if not (p and p.Character) then return false end
        return p.Character:FindFirstChild("Gun") ~= nil
            or (p:FindFirstChildOfClass("Backpack") and p.Backpack:FindFirstChild("Gun") ~= nil)
    end

    local function equipKnife()
        local c = LP.Character
        local bp = LP:FindFirstChild("Backpack")
        local knife = (c and (c:FindFirstChild("Knife") or c:FindFirstChild("KnifeServer")))
            or (bp and (bp:FindFirstChild("Knife") or bp:FindFirstChild("KnifeServer")))
        if knife and knife.Parent ~= c then
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:EquipTool(knife)
                task.wait(0.1)
            else
                knife.Parent = c
                task.wait(0.1)
            end
        end
        return knife
    end

    local lastNear, lastSheriff, lastAura = 0, 0, 0
    tc(RunService.Heartbeat:Connect(function()
        local stab = getKnifeEvents()
        if not stab then return end  -- not holding the Knife (not the Murderer): nothing to do
        local now = tick()
        -- Auto Kill Sheriff/Hero: delete the only threat the moment they're armed, so nobody can fight back.
        if S.AutoKillSheriff and (now - lastSheriff) >= 0.25 then
            lastSheriff = now
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and isArmed(p) then pcall(murdererKill, p) end
            end
        end
        -- Auto Kill Nearest: continuously eliminate the closest living player.
        if S.AutoKillNearest and (now - lastNear) >= 0.25 then
            lastNear = now
            local n = nearestPlayer()
            if n then pcall(murdererKill, n) end
        end
        -- Kill Aura: kill anyone (not whitelisted) who comes within KillAuraRange studs — play normally
        -- and everything near you dies. (Separate from the old Fun-tab Knife Aura; this one is on the
        -- Murderer combat tab and shares the same proven primitive.)
        if S.KillAura and (now - lastAura) >= 0.15 then
            lastAura = now
            local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            local range = S.KillAuraRange or 18
            if myRoot then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local r = p.Character:FindFirstChild("HumanoidRootPart")
                        if r and (r.Position - myRoot.Position).Magnitude <= range then pcall(killInstant, p) end
                    end
                end
            end
        end
    end))
    -- Kill the whole lobby from the current position. This deliberately uses killInstant rather than
    -- murdererKill: murdererKill is the separate target routine that blinks to the victim.
    S._MurdererKillAll = function()
        task.spawn(function()
            local knife = equipKnife()
            if not knife then
                Notify("Murderer", "Knife not found", 3)
                return
            end
            local n = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and not isWhitelisted(p) then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        if killInstant(p) then n = n + 1 end
                    end
                end
            end
            Notify("Murderer", n > 0 and ("Killed " .. n .. " players") or "No valid targets", 3)
        end)
    end

    -- Click to Kill: left-click any player (or their body) to instantly kill them.
    tc(UIS.InputBegan:Connect(function(input, gp)
        if gp or not S.ClickKill then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local m = LP:GetMouse()
        local hit = m and m.Target
        local ch = hit and hit:FindFirstAncestorWhichIsA("Model")
        local p = ch and Players:GetPlayerFromCharacter(ch)
        if p then pcall(murdererKill, p) end
    end))
end

print("[Inertia]: Loaded.")

-- ===== KNIFE PROJECTILE SPEED — REMOVED, cannot work =====
-- This used to multiply `part.AssemblyLinearVelocity` on the thrown Knife every frame to make it
-- "arrive faster". Live-verified (see [[mm2-knife-throw-and-anim-mechanics]]): the thrown knife
-- (`ThrowingKnife` in workspace) is **Anchored = true** with ~zero AssemblyLinearVelocity — its
-- position is set directly by the SERVER'S OWN CFrame every frame (server-authoritative, replicated),
-- not by Roblox physics at all. Multiplying a velocity the engine never reads has zero effect; the
-- `vel.Magnitude > 5` gate this code checked was essentially never true, so it silently did nothing
-- the entire time it existed. There is no client-side way to change the flying knife's actual travel
-- speed — changing it would require server authority this script doesn't have.

-- ===== CUSTOM SOUNDS (Kill / Knife Kill / Win / Ambient Music) =====
do
    local function playOnce(id, vol, pitch)
        task.spawn(function() pcall(function()
            local s = Instance.new("Sound")
            s.SoundId = id
            s.Volume = vol or 0.6
            s.PlaybackSpeed = pitch or 1
            s.RollOffMaxDistance = 0
            s.Parent = SoundService
            s:Play()
            s.Ended:Connect(function() pcall(function() s:Destroy() end) end)
        end) end)
    end
    -- Exposed on S (not a new top-level local) so the Silent Aim hook further up the file — which
    -- runs at load time before this do-block even executes — can still call it once a real shot
    -- fires later, the same forward-reference-via-S trick as S._MSP / S._GetMurdererChar.
    S._playOnce = playOnce

    -- Gun kill: GunFired fires client-side when a bullet connects
    task.spawn(function()
        local ok, ws = pcall(function()
            return game:GetService("ReplicatedStorage")
                :WaitForChild("ClientServices", 10)
                :WaitForChild("WeaponService", 10)
        end)
        if not (ok and ws) then return end
        local gf = ws:FindFirstChild("GunFired")
        if not gf then return end
        tc(gf.OnClientEvent:Connect(function(_, _, _, hitPart)
            if not S.CustomKillSound or not hitPart then return end
            local mdl = hitPart:FindFirstAncestorWhichIsA("Model")
            if mdl and Players:GetPlayerFromCharacter(mdl) then
                playOnce(S.CustomKillSoundId or "rbxassetid://4590662766", 0.7)
            end
        end))
    end)

    -- Knife kill: detect when another player's Humanoid dies while a Knife projectile exists
    tc(Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function(ch)
            local hum = ch:WaitForChild("Humanoid", 10)
            if not hum then return end
            hum.Died:Connect(function()
                if not S.CustomKnifeSound then return end
                local hasKnifeObj = false
                for _, v in ipairs(workspace:GetChildren()) do
                    if v.Name:lower():find("knife") then hasKnifeObj = true; break end
                end
                if hasKnifeObj then
                    playOnce(S.CustomKnifeKillSoundId or "rbxassetid://9120386446", 0.7)
                end
            end)
        end)
    end))

    -- Win sound: hooks the REAL round-end remote instead of scanning PlayerGui text (live-verified
    -- signature: Remotes.Gameplay.VictoryScreen fires (youWon, yourRole, winCondition, winnerName,
    -- roundCount) — winCondition is exactly "MurdererWin" / "MurdererDied" / "Time"). Murderer Win
    -- Sound plays on "MurdererWin"; Sheriff Win Sound plays on anything else (MurdererDied/Time —
    -- i.e. the murderer did NOT win, Sheriff/Hero/Innocents survived).
    task.spawn(function()
        local ok, gp = pcall(function()
            return game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 10):WaitForChild("Gameplay", 10)
        end)
        if not (ok and gp) then return end
        local vs = gp:FindFirstChild("VictoryScreen")
        if not vs then return end
        tc(vs.OnClientEvent:Connect(function(_, _, winCondition)
            if winCondition == "MurdererWin" then
                if S.CustomMurdererWinSound then
                    playOnce(S.CustomMurdererWinSoundId or "rbxassetid://1837849285", 0.8)
                end
            else
                if S.CustomSheriffWinSound then
                    playOnce(S.CustomSheriffWinSoundId or "rbxassetid://1837849285", 0.8)
                end
            end
        end))
    end)

    -- Ambient music loop
    local ambientSnd = nil
    local function startAmbient()
        if ambientSnd and ambientSnd.Parent then return end
        pcall(function()
            ambientSnd = Instance.new("Sound")
            ambientSnd.Name = "InertiaAmbient"
            ambientSnd.SoundId = S.AmbientMusicId or "rbxassetid://1843323335"
            ambientSnd.Volume = S.AmbientMusicVol or 0.4
            ambientSnd.Looped = true
            ambientSnd.RollOffMaxDistance = 0
            ambientSnd.Parent = SoundService
            ambientSnd:Play()
        end)
    end
    local function stopAmbient()
        pcall(function()
            if ambientSnd and ambientSnd.Parent then ambientSnd:Stop(); ambientSnd:Destroy() end
        end)
        ambientSnd = nil
    end
    S._StartAmbientMusic = startAmbient
    S._StopAmbientMusic = stopAmbient
end

-- ===== VISUAL DUAL WIELD — REMOVED (duplicate/conflicting with the real one) =====
-- This was a SECOND, independent Dual Wield implementation that toggled the SAME S.DualWield flag as
-- the actual one (Visuals > Environment > "Dual Wield", ~line 5937 "DUAL WIELD (visual only)") — the
-- exact "two systems fighting over one flag" bug this file has hit before (silent aim, fling). This
-- one was also strictly worse: it only matched a Tool literally named "Gun" (never the Knife), used a
-- hand-guessed weld offset (`CFrame.new(-0.1, -1.2, 0.35) * CFrame.Angles(0, math.pi, 0)`) instead of
-- mirroring the REAL grip joint Roblox creates, only reacted to Character.ChildAdded (so it never
-- fired if the weapon was already equipped before the toggle was flipped on), and injected its own
-- second, redundant UI toggle by fragile runtime string-searching for a "Fun"/"Visual" section. The
-- surviving implementation covers every case this one did, correctly.

