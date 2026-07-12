if _G.MM2_Visuals_Script then
    pcall(function() _G.MM2_Visuals_Script:Destroy() end)
    _G.MM2_Visuals_Script = nil
end

-- Destroy PartSwim to stop the massive error spam in the console
pcall(function()
    local ps = game:GetService("Players").LocalPlayer.PlayerScripts:FindFirstChild("PartSwim")
    if ps then ps:Destroy() end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
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
    MurderChams = false, SheriffChams = false, HeroChams = false,
    InnocentChams = false, GunChams = false, GunNotify = false,
    AutoGrabGun = false, XrayOn = false, CamClip = false, NoCamLimit = false,
    AntiFling = false, AntiVoid = false, NoClip = false, AntiRagdoll = false,
    Fly = false, FlySpeed = 50, TouchFling = false,
    KnifeAura = false, KnifeAuraRange = 15,
    KillMurder = false, ActiveShader = "None", rtxLowToggle = false, rtxMedToggle = false, rtxHighToggle = false, nightToggle = false, pinkToggle = false,
    HUD_Roles = false, HUD_Keybinds = false, HUD_GunStatus = false, HUD_FPS = false,
    HUD_Ping = false, HUD_Coords = false, HUD_Time = false, HUD_Players = false,
    NameESP = false, DistanceESP = false, RoleESP = false, HealthESP = false,
    BoxESP = false, BoxFillESP = false, HealthBarESP = false, TracerESP = false, ESPMaxDist = 1000,
    HeadDot = false, TracerOrigin = "Bottom",
    ChamsOpacity = 50, GunHeldChams = false,
    FullBright = false, NoFog = false, ForceDay = false, ForceNight = false, NoShadows = false, Brightness = 2,
    Saturation = 0, Contrast = 0, CamFOV = 70,
    SkyEnabled = false, SkyPreset = "Day", SkyTint = "Preset", SkyRainbow = false,
    FogEnabled = false, FogColorName = "Gray", FogStart = 0, FogEnd = 500, FogRainbow = false,
    FogMode = "Classic", FogDensity = 40,
    HandShader = false, HandShaderType = "Both", HandTarget = "Full Body", HandColor = "Cyan", HandRainbow = false, HandFill = 60,
    Crosshair = false,
    FOVEnabled = false, ShowFOV = false, RainbowFOV = false,
    FOVThickness = 2, FOVColor = "White", FOVRadius = 360,
    HUD_Watermark = false, HUD_Speed = false, HUD_Session = false, HUD_KillFeed = false,
    AutoRespawn = false, WalkOnWater = false, AutoSprint = false, AntiLag = false,
    InfiniteJump = false, Spinbot = false, SpinSpeed = 20, AntiAFK = false, Freeze = false,
    Bhop = false, BhopMax = 28, SpeedGlitch = false, AirSpeed = 50,
    ClickTP = false,
    AutoSaveCfg = true,
    WalkFling = false,
    WallTP = false, HeadSit = false,
    Orbit = false, OrbitSpeed = 20, OrbitDist = 6, OrbitHeight = 0,
    Bang = false, BangSpeed = 3, Jerk = false,
    InvisibleFE = false, FreeCam = false, Blink = false, ClickFling = false,
    CoinESP = false, AutoCoins = false, FastAutofarm = false, FastAutofarmSpeed = 20, AfterFarm = "Auto (Role)",
    FollowPlayer = false, FollowPlayerDistance = 4, FollowPlayerMode = "Follow", FollowPlayerSpeed = 60, FollowPlayerOrbitSpeed = 20,
    CustomTime = false, TimeOfDay = 14, Gravity = 196, MoonGravity = false, DisableBlur = false,
    FakeLag = false, FakeLagLimit = 15,
    TriggerBot = false,
    CrosshairShape = "Cross", CrosshairColor = "Cyan", CrosshairSize = 12, CrosshairThickness = 2, CrosshairGap = 4, CrosshairRotation = 0,
    AutoEvade = false, AutoEvadeRange = 25, AutoGG = false, CustomGGText = "GG!", UseCustomGG = false,
    AutoDodgeKnife = false, AutoDodgeMode = "Teleport", AutoDodgeSpeed = 16,
    AimLock = false, AimLockTarget = "Nearest",
    AimLockHoldRMB = true, AimSmooth = 1, AimPrediction = 0, AimPart = "Head",
    MuteGun = false, MuteCoin = false, MuteKill = false, MuteKillNotify = false, MuteKillEffect = false, HideKillFX = false,
    Whitelist = {},   -- [playerName]=true : right-click in Targets; skipped by fling / kill / aura / aim
    ManualTargets = {},  -- [playerName]=true : left-click multi-select in Targets (Fun / Follow). empty = Auto
    PiercingBullet = false,
}
_G.MM2_Visuals_Script = S
local createHighlight, getRole, rebuildCrosshair, moveTo, isRoundActive, playEmote, stopEmote
local OriginalSheriff, Heroes, RoleCache = nil, {}, {}
local HeroPresent = false  -- true once a Hero exists this round; while true, nobody is a Sheriff
local LastRemoteFetch, LastRoundHadRoles = 0, false
local VelocityHistory = {}
function S:Destroy()
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
        Visuals = "Визуалы", Combat = "Бой", Motion = "Движение", Misc = "Разное", Fun = "Веселье",
        Targets = "Цели", Teleport = "Телепорт", HUD = "ХУД", Shaders = "Шейдеры", World = "Мир",
        Autofarm = "Автофарм", Servers = "Сервера", Config = "Конфиг", Settings = "Настройки",
        ["Text Size"] = "Размер текста", Language = "Язык", Theme = "Тема", Close = "Закрыть",
        ["Theme Style"] = "Цветовая тема",
    },
    UK = {
        Visuals = "Візуали", Combat = "Бій", Motion = "Рух", Misc = "Різне", Fun = "Розваги",
        Targets = "Цілі", Teleport = "Телепорт", HUD = "ХУД", Shaders = "Шейдери", World = "Світ",
        Autofarm = "Автофарм", Servers = "Сервери", Config = "Конфіг", Settings = "Налаштування",
        ["Text Size"] = "Розмір тексту", Language = "Мова", Theme = "Тема", Close = "Закрити",
        ["Theme Style"] = "Колірна тема",
    },
    SPANISH = {
        Visuals = "Visuales", Combat = "Combate", Motion = "Movimiento", Misc = "Varios", Fun = "Diversión",
        Targets = "Objetivos", Teleport = "Teletransporte", HUD = "HUD", Shaders = "Shaders", World = "Mundo",
        Autofarm = "Autofarm", Servers = "Servidores", Config = "Config", Settings = "Ajustes",
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
    Hero     = Color3.fromRGB(255, 255, 0),
    Innocent = Color3.fromRGB(0, 255, 0),
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
    TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 310, 0, 46)
    }):Play()
    TweenService:Create(sc, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = 1
    }):Play()
    TweenService:Create(tt, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
    TweenService:Create(bt, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
    task.delay(dur, function()
        if not toast.Parent then return end
        TweenService:Create(tt, TweenInfo.new(0.15), { TextTransparency = 1 }):Play()
        TweenService:Create(bt, TweenInfo.new(0.15), { TextTransparency = 1 }):Play()
        TweenService:Create(tst, TweenInfo.new(0.15), { Transparency = 1 }):Play()
        TweenService:Create(toast, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 260, 0, 0)
        }):Play()
        TweenService:Create(sc, TweenInfo.new(0.25), { Scale = 0.9 }):Play()
        task.wait(0.27)
        for i, v in ipairs(ActiveN) do
            if v == toast then table.remove(ActiveN, i); break end
        end
        if toast.Parent then toast:Destroy() end
    end)
end

local currentEmoteToggle = nil
local currentEmoteTrack = nil
local currentEmoteId = nil
local playingEmoteRecurse = false

playEmote = function(toggleObj, animId, title)
    if playingEmoteRecurse then return end
    playingEmoteRecurse = true
    
    if currentEmoteToggle and currentEmoteToggle ~= toggleObj then
        pcall(function()
            currentEmoteToggle.state = false
            currentEmoteToggle.updateVisuals()
        end)
    end
    
    if currentEmoteTrack then
        pcall(function()
            currentEmoteTrack:Stop()
            currentEmoteTrack:Destroy()
        end)
        currentEmoteTrack = nil
    end
    
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 and hum.RigType == Enum.HumanoidRigType.R15 then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. animId
        local ok, track = pcall(function() return hum:LoadAnimation(anim) end)
        if ok and track then
            currentEmoteTrack = track
            currentEmoteTrack.Looped = true
            currentEmoteTrack:Play()
            currentEmoteToggle = toggleObj
            currentEmoteId = animId
        else
            if toggleObj then
                toggleObj.state = false
                toggleObj.updateVisuals()
            end
            Notify("Animation Error", "Failed to load animation", 3)
        end
    else
        if toggleObj then
            toggleObj.state = false
            toggleObj.updateVisuals()
        end
        Notify("Animation Error", "This animation only works with R15 characters!", 3)
    end
    
    playingEmoteRecurse = false
end

stopEmote = function(toggleObj)
    if playingEmoteRecurse then return end
    playingEmoteRecurse = true
    
    if currentEmoteToggle == toggleObj or not toggleObj then
        if currentEmoteTrack then
            pcall(function()
                currentEmoteTrack:Stop()
                currentEmoteTrack:Destroy()
            end)
            currentEmoteTrack = nil
        end
        currentEmoteToggle = nil
        currentEmoteId = nil
    end
    
    playingEmoteRecurse = false
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
local mainSt = Stroke(Main, T.Bd, 1, 0.1)
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
        TweenService:Create(accGrad, TweenInfo.new(3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Offset = Vector2.new(0.45, 0)
        }):Play()
        task.wait(3.5)
        TweenService:Create(accGrad, TweenInfo.new(3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
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
        TweenService:Create(b, TweenInfo.new(0.12), { BackgroundColor3 = T.Hover })
        b.TextColor3 = T.White; pcall(function() b:SetAttribute("ThemeColorRole_TextColor3", "White") end)
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), { BackgroundColor3 = T.Elev })
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
                -- search by feature ("aimlock"), by section ("sheriff"), or by tab ("combat").
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
                if page then SearchPageHits[page] = true end
            end
        end
    end
    for _, e in ipairs(UIRegistry) do
        if e.card and e.card.Parent then
            e.card.Visible = (#tokens == 0) or (cardVis[e.card] == true)
        end
    end
    if #tokens == 0 then
        -- Not searching: restore the normal single active page and hide the search headers.
        for _, pg in pairs(Pages) do
            pg.Visible = (pg == activePage)
            local h = pg:FindFirstChild("SearchHdr"); if h then h.Visible = false end
        end
    else
        -- Searching: show EVERY tab that has a match. ContentArea has a UIListLayout, so the visible
        -- pages stack into one scrollable list — the matching settings from all tabs appear together,
        -- each with its live slider/toggle. A per-page header labels which tab each group came from.
        for _, pg in pairs(Pages) do
            local hit = SearchPageHits[pg] == true
            pg.Visible = hit
            local h = pg:FindFirstChild("SearchHdr"); if h then h.Visible = hit end
        end
    end
    -- Sidebar dots: flag every tab that has matches.
    if SBItems then
        for _, item in ipairs(SBItems) do
            if item.dot then
                item.dot.Visible = (#tokens > 0) and (SearchPageHits[item.page] == true)
            end
        end
    end
end
local SearchBox = Instance.new("TextBox")
SearchBox.Parent = TBar
SearchBox.AnchorPoint = Vector2.new(1, 0.5)
SearchBox.Position = UDim2.new(1, -76, 0.5, 0)
SearchBox.Size = UDim2.new(0, 150, 0, 22)
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
Stroke(SearchBox, T.Bd2, 1, 0.4)
Pad(SearchBox, 0, 0, 8, 6)
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
local langLabel = mkModalLabel("Language", 1)
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
    pcall(saveConfig, "_autoload")
end)

-- 2. Text Size Option
local sizeLabel = mkModalLabel("Text Size", 3)
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
    pcall(saveConfig, "_autoload")
end)

-- 3. Theme Selector
local themeLabel = mkModalLabel("Theme Style", 5)
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
        pcall(saveConfig, "_autoload")
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
AvatarImage.Position = UDim2.new(0, 10, 0.5, -18)
AvatarImage.Size = UDim2.fromOffset(36, 36)
AvatarImage.BackgroundTransparency = 1
AvatarImage.Image = avatarUrl
AvatarImage.ZIndex = 50
Corner(AvatarImage, 9999)
Stroke(AvatarImage, T.Bd2, 1, 0.4)

local UserLabel = Instance.new("TextLabel")
UserLabel.Parent = ProfileHeader
UserLabel.BackgroundTransparency = 1
UserLabel.Position = UDim2.new(0, 52, 0.5, -16)
UserLabel.Size = UDim2.new(1, -58, 0, 16)
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
SubLabel.Position = UDim2.new(0, 52, 0.5, 2)
SubLabel.Size = UDim2.new(1, -58, 0, 12)
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
    -- which tab each group of settings came from. Hidden during normal single-tab browsing.
    local hdr = Instance.new("TextLabel")
    hdr.Name = "SearchHdr"
    hdr.Parent = sf
    hdr.LayoutOrder = -1
    hdr.BackgroundTransparency = 1
    hdr.Size = UDim2.new(1, 0, 0, 20)
    hdr.Font = FB
    hdr.TextSize = 13
    hdr.TextColor3 = T.Tx; pcall(function() hdr:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
    hdr.TextXAlignment = Enum.TextXAlignment.Left
    hdr.Text = string.upper(name)
    hdr.Visible = false
    Pages[name] = sf
    return sf
end
mkPage("Visuals")
mkPage("Combat")
mkPage("Motion")
mkPage("Misc")
mkPage("Fun")
mkPage("Targets")
mkPage("Teleport")
mkPage("HUD")
mkPage("Shaders")
mkPage("World")
mkPage("Autofarm")
mkPage("Servers")
mkPage("Config")
local PTest = mkPage("Test")
Pages.Visuals.Visible = true
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
mkSBItem("Shaders", "diamond", Pages.Shaders, 2)
mkSBItem("Combat", "cross", Pages.Combat, 3)
mkSBItem("Motion", "sliders", Pages.Motion, 4)
mkSBItem("Targets", "shield", Pages.Targets, 5)
mkSBItem("World", "grid", Pages.World, 6)
mkSBItem("Autofarm", "diamond", Pages.Autofarm, 7)
mkSBItem("Misc", "sliders", Pages.Misc, 8)
mkSBItem("Fun", "diamond", Pages.Fun, 9)
mkSBItem("Teleport", "diamond", Pages.Teleport, 10)
mkSBItem("Servers", "server", Pages.Servers, 11)
mkSBItem("HUD", "grid", Pages.HUD, 12)
mkSBItem("Config", "sliders", Pages.Config, 13)
mkSBItem("Test", "diamond", PTest, 14)
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
            TweenService:Create(track, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = tCol
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
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
            TweenService:Create(row, TweenInfo.new(0.1), { BackgroundColor3 = T.ActiveBg })
        end
    end)
    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 0.4 })
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 1 })
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
        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = T.ActiveBg })
    end)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = T.Hover })
        TweenService:Create(bst, TweenInfo.new(0.12), { Transparency = 0.1 })
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = T.Elev })
        TweenService:Create(bst, TweenInfo.new(0.12), { Transparency = 0.4 })
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
        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = T.Hover }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = T.Elev }):Play()
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
local bodyParts = {
    "HumanoidRootPart","Torso","UpperTorso","LowerTorso","Head",
    "Left Arm","Right Arm","Left Leg","Right Leg",
    "LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm",
    "LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg",
    "LeftHand","RightHand","LeftFoot","RightFoot"
}
local function getToolRemote(tool)
    if not tool then return end
    for _, child in pairs(tool:GetChildren()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            return child
        end
    end
end

local function predictPos(targetPart, originPos, speed)
    local pos = targetPart.Position
    local vel = targetPart.AssemblyLinearVelocity
    local dist = (pos - originPos).Magnitude
    local timeToHit = dist / (speed or 900)
    return pos + (vel * timeToHit)
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

local function createCham(adornee, color, name)
    if not adornee then return end
    
    local parentModel = adornee:IsA("Model") and adornee or adornee:FindFirstAncestorOfClass("Model")
    local hlParent = parentModel
    if not hlParent then
        hlParent = adornee:FindFirstChild(name.."_Container")
        if not hlParent then
            hlParent = Instance.new("Model")
            hlParent.Name = name.."_Container"
            hlParent.Parent = adornee
        end
    end
    
    local hl = hlParent:FindFirstChild(name)
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = name
        hl.Adornee = adornee
        hl.FillColor = color
        hl.FillTransparency = 0.4
        hl.OutlineColor = color
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = hlParent
    else
        hl.FillColor = color
        hl.OutlineColor = color
        hl.Adornee = adornee
    end
    return hl
end

local function removeCham(adornee, name)
    if not adornee then return end
    local container = adornee:FindFirstChild(name.."_Container")
    if container then
        container:Destroy()
    else
        local hl = adornee:FindFirstChild(name)
        if hl then hl:Destroy() end
    end
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
        local targetSegmentCF = CFrame.new(targetSegmentPos, targetCF.Position)
        
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

local function grabGun()
    task.spawn(function()
        local gd = workspace:FindFirstChild("GunDrop") or workspace:FindFirstChild("GunDrop", true)
        if not gd then return end
        local c = LP.Character; if not c or not c:FindFirstChild("HumanoidRootPart") then return end
        local hrp = c.HumanoidRootPart; local old = hrp.CFrame
        local handle = gd:FindFirstChild("Handle") or gd:FindFirstChildOfClass("BasePart") or gd
        if not handle then return end
        
        hrp.CFrame = handle.CFrame
        if firetouchinterest then
            pcall(function()
                firetouchinterest(hrp, handle, 0)
                firetouchinterest(hrp, handle, 1)
            end)
        end
        task.wait()
        if hrp and hrp.Parent then
            hrp.CFrame = old
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end)
end
local function killAll()
    task.spawn(function()
        local c = LP.Character
        if not c then Notify("Error","No character",3); return end
        local knife = c:FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
        if not knife then Notify("Error","Need Knife (Murderer)",3); return end
        if knife.Parent == LP.Backpack then
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:EquipTool(knife)
                task.wait(0.2)
            end
        end
        knife = c:FindFirstChild("Knife")
        if not knife then Notify("Error","Failed to equip Knife",3); return end
        local events = knife:FindFirstChild("Events")
        if not events then Notify("Error","Knife.Events not found",3); return end
        local HandleTouched = events:FindFirstChild("HandleTouched")
        if not HandleTouched then Notify("Error","HandleTouched not found",3); return end
        local cnt = 0
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character and not isWhitelisted(v) then
                local primary = v.Character:FindFirstChild("HumanoidRootPart")
                if not primary then continue end
                pcall(function() HandleTouched:FireServer(primary) end)
                cnt = cnt + 1
                task.wait(0.05)
            end
        end
        Notify("Kill All","Fired at "..cnt.." players",3)
    end)
end
local function killMurder()
    task.spawn(function()
        local c = LP.Character; if not c then Notify("Error","No character",3); return end
        local hrp = c:FindFirstChild("HumanoidRootPart"); local hum = c:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local gun = LP.Backpack:FindFirstChild("Gun") or c:FindFirstChild("Gun") or LP.Backpack:FindFirstChild("Revolver") or c:FindFirstChild("Revolver")
        if not gun then Notify("Error","Need Gun (Sheriff/Hero)",3); return end
        if gun.Parent == LP.Backpack then hum:EquipTool(gun); task.wait(0.2) end
        local murderer = nil
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                if getRole(p) == "Murderer" then
                    local pr = p.Character:FindFirstChild("HumanoidRootPart"); local ph = p.Character:FindFirstChildOfClass("Humanoid")
                    if pr and ph and ph.Health > 0 then murderer = {player=p, hrp=pr, char=p.Character}; break end
                end
            end
        end
        if not murderer then Notify("Kill Murder","Murderer not found",3); return end
        local saved = hrp.CFrame; local dir = (hrp.Position - murderer.hrp.Position)
        dir = dir.Magnitude > 0.1 and dir.Unit or Vector3.new(1,0,0)
        local killPos = murderer.hrp.Position + dir * 8
        hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(Vector3.new(killPos.X, murderer.hrp.Position.Y, killPos.Z), murderer.hrp.Position)
        task.wait(0.06)
        for attempt = 1, 5 do
            if not murderer.hrp or not murderer.hrp.Parent then break end
            local tp = murderer.hrp.Position; hrp.CFrame = CFrame.new(hrp.Position, tp)
            pcall(function() gun:Activate() end)
            local origin = hrp.Position
            local cf1 = CFrame.new(origin, tp)
            local cf2 = CFrame.new(tp)
            for _, ch in pairs(gun:GetDescendants()) do
                if ch:IsA("RemoteEvent") then
                    pcall(function() ch:FireServer(1, CFrame.new(tp), "AH2") end)
                    pcall(function() ch:FireServer(tp, murderer.hrp) end)
                end
                if ch:IsA("RemoteFunction") then
                    pcall(function() ch:InvokeServer(1, CFrame.new(tp), "AH2") end)
                    pcall(function() ch:InvokeServer(tp, murderer.hrp) end)
                end
            end
            if firetouchinterest then
                local h = gun:FindFirstChild("Handle")
                if h then for _, n in ipairs(bodyParts) do local pt = murderer.char:FindFirstChild(n)
                    if pt then pcall(function() firetouchinterest(h,pt,0); firetouchinterest(h,pt,1) end) end
                end end
            end
            task.wait(0.1)
        end
        task.wait(0.08)
        if hrp and hrp.Parent then hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero; hrp.CFrame = saved end
        Notify("Kill Murder","Shot at "..murderer.player.Name,3)
    end)
end
-- Proven "skid fling": ram our own character into the target at insane velocity
-- so the physics solver launches them. Returns true if the target was flung.
local function skidFling(TargetPlayer)
    local Character = LP.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    if not (Character and Humanoid and RootPart) then return false end
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return false end
    if not Character.PrimaryPart then Character.PrimaryPart = RootPart end

    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")

    local startPos = (TRootPart and TRootPart.Position) or (THead and THead.Position)
    if not startPos then return false end
    if not TCharacter:FindFirstChildWhichIsA("BasePart") then return false end

    local OldPos = RootPart.CFrame
    if THead then workspace.CurrentCamera.CameraSubject = THead
    elseif Handle then workspace.CurrentCamera.CameraSubject = Handle
    elseif THumanoid then workspace.CurrentCamera.CameraSubject = THumanoid end

    local FPos = function(BasePart, Pos, Ang)
        RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
        pcall(function() Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang) end)
        RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
        RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end
    local SFBasePart = function(BasePart)
        local TimeToWait = 2
        local Time = tick()
        local Angle = 0
        repeat
            if RootPart and THumanoid then
                if BasePart.Velocity.Magnitude < 50 then
                    Angle = Angle + 100
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                else
                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0)); task.wait()
                end
            else
                break
            end
        until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character
            or TargetPlayer.Parent ~= Players or (THumanoid and THumanoid.Sit) or Humanoid.Health <= 0
            or tick() > Time + TimeToWait
    end

    local FPDH = workspace.FallenPartsDestroyHeight
    workspace.FallenPartsDestroyHeight = 0 / 0
    local BV = Instance.new("BodyVelocity")
    BV.Name = "EpixVel"; BV.Parent = RootPart
    BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
    BV.MaxForce = Vector3.new(1 / 0, 1 / 0, 1 / 0)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    if TRootPart and THead then
        if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then SFBasePart(THead) else SFBasePart(TRootPart) end
    elseif TRootPart then SFBasePart(TRootPart)
    elseif THead then SFBasePart(THead)
    elseif Handle then SFBasePart(Handle)
    end

    pcall(function() BV:Destroy() end)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    workspace.CurrentCamera.CameraSubject = Humanoid
    local rt = tick()
    repeat
        RootPart.CFrame = OldPos * CFrame.new(0, .5, 0)
        pcall(function() Character:SetPrimaryPartCFrame(OldPos * CFrame.new(0, .5, 0)) end)
        pcall(function() Humanoid:ChangeState("GettingUp") end)
        for _, x in ipairs(Character:GetChildren()) do
            if x:IsA("BasePart") then x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new() end
        end
        task.wait()
    until (RootPart.Position - OldPos.p).Magnitude < 25 or tick() > rt + 3
    workspace.FallenPartsDestroyHeight = FPDH

    local thrp = TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not thrp then return true end
    return (thrp.Position - startPos).Magnitude > 40
end
-- In MM2 the "Sheriff" role effectively includes the Hero (whoever holds the gun).
-- If the Sheriff is dead, the Hero picked up the gun -> collecting alive targets
-- with either role automatically flings the Hero instead.
local function roleMatches(p, roleFilter)
    if not roleFilter then return true end
    local r = getRole(p)
    if roleFilter == "Sheriff" then return r == "Sheriff" or r == "Hero" end
    return r == roleFilter
end
local function collectTargets(roleFilter)
    local out = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and roleMatches(p, roleFilter) and not isWhitelisted(p) then
            local th = p.Character:FindFirstChildOfClass("Humanoid")
            if th and th.Health > 0 then table.insert(out, p) end
        end
    end
    return out
end
local function doFling(label, roleFilter)
    task.spawn(function()
        local c = LP.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if not hrp then Notify(label, "No character", 3); return end
        local targets = collectTargets(roleFilter)
        if #targets == 0 then Notify(label, (roleFilter or "Target") .. " not found", 3); return end
        local flung = 0
        for _, p in ipairs(targets) do
            local ok, res = pcall(skidFling, p)
            if ok and res then flung = flung + 1 end
            task.wait(0.1)
        end
        if flung > 0 then
            Notify(label, "Success - flung " .. flung .. "/" .. #targets, 3)
        else
            Notify(label, "Failed - target not flung", 4)
        end
    end)
end
local function flingAll()
    doFling("Fling All", nil)
end
local function flingByRole(role)
    doFling("Fling " .. role, role)
end
-- Walk Fling: fling anyone you walk into (noclip + rapid velocity flip)
do
    local wfNoclipped = false
    task.spawn(function()
        while S.Gui and S.Gui.Parent do
            if S.WalkFling then
                local c = LP.Character
                local root = c and c:FindFirstChild("HumanoidRootPart")
                if c and root then
                    for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
                    wfNoclipped = true
                    local vel = root.AssemblyLinearVelocity
                    root.AssemblyLinearVelocity = vel * 10000 + Vector3.new(0, 10000, 0)
                    RunService.RenderStepped:Wait()
                    root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    if root then root.AssemblyLinearVelocity = vel end
                    RunService.Stepped:Wait()
                    root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    if root then root.AssemblyLinearVelocity = vel + Vector3.new(0, 0.1, 0) end
                end
            elseif wfNoclipped then
                local c = LP.Character
                if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
                wfNoclipped = false
            end
            RunService.Heartbeat:Wait()
        end
    end)
end
-- ===== Action helpers (used by Misc / Teleport buttons) =====
local function respawnChar()
    local c = LP.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if h then h.Health = 0; Notify("Respawn", "Resetting character", 2)
    else pcall(function() LP:LoadCharacter() end) end
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
    local sec1 = mkSection(Pages.Visuals, "Chams", 1)
    mkToggle(sec1, "Murderer", false, function(v) S.MurderChams = v end, 1)
    mkToggle(sec1, "Sheriff", false, function(v) S.SheriffChams = v end, 2)
    mkToggle(sec1, "Hero", false, function(v) S.HeroChams = v end, 3)
    mkToggle(sec1, "Innocent", false, function(v) S.InnocentChams = v end, 4)
    mkToggle(sec1, "Gun", false, function(v) S.GunHeldChams = v end, 5)
    mkSlider(sec1, "Chams Opacity", 0, 100, 50, function(v) S.ChamsOpacity = v end, 6)
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
    local sec4 = mkSection(Pages.Visuals, "World", 4)
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
    local secFx = mkSection(Pages.Visuals, "Effects", 5)
    mkSlider(secFx, "Saturation", -100, 100, 0, function(v) S.Saturation = v end, 1)
    mkSlider(secFx, "Contrast", -100, 100, 0, function(v) S.Contrast = v end, 2)
    mkSlider(secFx, "Camera FOV", 40, 120, 70, function(v) S.CamFOV = v end, 3)
    local secCrosshair = mkSection(Pages.Visuals, "Custom Crosshair", 6)
    mkToggle(secCrosshair, "Enable Crosshair", false, function(v) S.Crosshair = v; rebuildCrosshair() end, 1)
    mkCycle(secCrosshair, "Crosshair Shape", {"Cross", "X", "Dot", "Circle", "Heart"}, "Cross", function(v) S.CrosshairShape = v; rebuildCrosshair() end, 2)
    mkCycle(secCrosshair, "Crosshair Color", {"Cyan", "Red", "Green", "Yellow", "Pink", "White", "Purple", "Orange", "Blue", "Rainbow"}, "Cyan", function(v) S.CrosshairColor = v; rebuildCrosshair() end, 3)
    mkSlider(secCrosshair, "Crosshair Size", 4, 50, 12, function(v) S.CrosshairSize = v; rebuildCrosshair() end, 4)
    mkSlider(secCrosshair, "Crosshair Thickness", 1, 8, 2, function(v) S.CrosshairThickness = v; rebuildCrosshair() end, 5)
    mkSlider(secCrosshair, "Crosshair Gap", 0, 20, 4, function(v) S.CrosshairGap = v; rebuildCrosshair() end, 6)
    mkSlider(secCrosshair, "Crosshair Rotation", 0, 360, 0, function(v) S.CrosshairRotation = v; rebuildCrosshair() end, 7)

    local secSky = mkSection(Pages.Visuals, "Sky", 7)
    mkToggle(secSky, "Custom Sky", false, function(v) S.SkyEnabled = v end, 1)
    mkCycle(secSky, "Sky Preset", {"Day", "Sunset", "Night", "Aurora", "Space", "Blood", "Toxic", "Ocean", "Sakura", "Midnight", "Storm", "Desert"}, "Day", function(v) S.SkyPreset = v end, 2)
    mkCycle(secSky, "Sky Color", {"Preset", "Blue", "Purple", "Pink", "Cyan", "Orange", "Green", "Red", "White"}, "Preset", function(v) S.SkyTint = v end, 3)
    mkToggle(secSky, "Rainbow Sky", false, function(v) S.SkyRainbow = v end, 4)
    local secFog = mkSection(Pages.Visuals, "Fog", 8)
    mkToggle(secFog, "Custom Fog", false, function(v) S.FogEnabled = v end, 1)
    -- Classic = sharp legacy fog (Start/End). Atmosphere = soft volumetric-style haze whose
    -- thickness comes from the Density slider (Start/End are ignored in that mode).
    mkCycle(secFog, "Fog Mode", {"Classic", "Atmosphere"}, "Classic", function(v) S.FogMode = v end, 2)
    mkCycle(secFog, "Fog Color", {"Gray", "White", "Black", "Blue", "Purple", "Pink", "Cyan", "Orange", "Green", "Red"}, "Gray", function(v) S.FogColorName = v end, 3)
    mkSlider(secFog, "Fog Start", 0, 2000, 0, function(v) S.FogStart = v end, 4)
    mkSlider(secFog, "Fog End", 50, 5000, 500, function(v) S.FogEnd = v end, 5)
    mkSlider(secFog, "Fog Density", 5, 95, 40, function(v) S.FogDensity = v end, 6)
    mkToggle(secFog, "Rainbow Fog", false, function(v) S.FogRainbow = v end, 7)
    local secFov = mkSection(Pages.Visuals, "FOV", 9)
    mkToggle(secFov, "FOV Enabled", false, function(v) S.FOVEnabled = v end, 1)
    mkToggle(secFov, "Show FOV", false, function(v) S.ShowFOV = v end, 2)
    mkToggle(secFov, "Rainbow FOV", false, function(v) S.RainbowFOV = v end, 3)
    mkSlider(secFov, "FOV Radius", 30, 360, 360, function(v) S.FOVRadius = v end, 4)
    mkSlider(secFov, "FOV Thickness", 1, 8, 2, function(v) S.FOVThickness = v end, 5)
    mkCycle(secFov, "FOV Color", {"White", "Red", "Green", "Blue", "Yellow", "Cyan", "Purple", "Orange", "Pink", "Black"}, "White", function(v) S.FOVColor = v end, 6)

    local sec5 = mkSection(Pages.Visuals, "Alerts", 10)
    mkToggle(sec5, "Gun Drop Notify", false, function(v) S.GunNotify = v end, 1)
end

do
    local sec1 = mkSection(Pages.Combat, "Gun", 1)
    mkToggle(sec1, "Auto Grab Gun", false, function(v) S.AutoGrabGun = v end, 1)
    mkAction(sec1, "Grab Gun", function() grabGun() end, 2)
    mkToggle(sec1, "Piercing Bullet", false, function(v) S.PiercingBullet = v end, 3)
    local sec2 = mkSection(Pages.Combat, "Murderer", 2)
    mkAction(sec2, "Kill All", function() killAll() end, 1)
    mkToggle(sec2, "Knife Aura", false, function(v) S.KnifeAura = v end, 3)
    mkSlider(sec2, "Aura Range", 5, 50, 15, function(v) S.KnifeAuraRange = v end, 4)
    local animMurderToggle
    animMurderToggle = mkToggle(sec2, "Animation Murder", false, function(v)
        if v then
            playEmote(animMurderToggle, "108747312576405", "Animation Murder")
        else
            stopEmote(animMurderToggle)
        end
    end, 5)
    local sec3 = mkSection(Pages.Combat, "Sheriff", 3)
    -- Trigger Bot's firing loop lives in the auto-gun do-block below and reads S.TriggerBot.
    mkToggle(sec3, "Trigger Bot", false, function(v) S.TriggerBot = v end, 4)
    -- Normal aim lock: enable, then (by default) HOLD Right Mouse to snap the camera onto the target.
    mkToggle(sec3, "Aim Lock", false, function(v) S.AimLock = v end, 5)
    mkCycle(sec3, "Aim Lock Target", {"Nearest", "Murderer", "Sheriff"}, "Nearest", function(v) S.AimLockTarget = v end, 6)
    -- Aim Part = which body part Aim Lock actually aims at. Target PICK (who) still uses the
    -- visible Head for the FOV circle; this only changes WHERE on that player the aim lands.
    mkCycle(sec3, "Aim Part", {"Head", "Torso", "HumanoidRootPart"}, "Head", function(v) S.AimPart = v end, 7)
    -- Hold RMB ON = lock only while right mouse is held; OFF = lock continuously while Aim Lock is on.
    mkToggle(sec3, "Aim Lock Hold RMB", true, function(v) S.AimLockHoldRMB = v end, 8)
    -- Smoothness 1 = instant snap; higher = the camera eases toward the target (Aim Lock only).
    mkSlider(sec3, "Aim Smoothness", 1, 30, 1, function(v) S.AimSmooth = v end, 9)
    -- Prediction leads a moving target by its velocity — helps Aim Lock. 0 = off.
    mkSlider(sec3, "Aim Prediction", 0, 50, 0, function(v) S.AimPrediction = v end, 10)
    local secDodge = mkSection(Pages.Combat, "Knife Dodge", 5)
    mkToggle(secDodge, "Auto Dodge Knife", false, function(v) S.AutoDodgeKnife = v end, 1)
    mkCycle(secDodge, "Dodge Mode", {"Teleport", "Walk Away", "Jump"}, "Teleport", function(v) S.AutoDodgeMode = v end, 2)
    mkSlider(secDodge, "Dodge Speed", 16, 100, 16, function(v) S.AutoDodgeSpeed = v end, 3)

    local sec5 = mkSection(Pages.Combat, "Fling", 6)
    mkAction(sec5, "Fling All", function() flingAll() end, 1)
    mkAction(sec5, "Fling Murder", function() flingByRole("Murderer") end, 2)
    mkAction(sec5, "Fling Sheriff", function() flingByRole("Sheriff") end, 3)
    mkToggle(sec5, "Walk Fling", false, function(v) S.WalkFling = v end, 4)

end
do
    -- Auto gun for the sheriff: auto-fire the equipped gun at the murderer. Both features target
    -- the Murderer ONLY, so you never shoot an innocent by accident.
    local function equippedGun()
        local c = LP.Character
        return c and (c:FindFirstChild("Gun") or c:FindFirstChild("Revolver"))
    end
    local function fireGunAt(hrp)
        local gun = equippedGun()
        if not gun or not hrp then return end
        pcall(function() gun:Activate() end)

        local c = LP.Character
        local originPart = c and (c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart"))
        local originPos = originPart and originPart.Position or hrp.Position + Vector3.new(0, 3, 0)
        
        local vel = hrp.AssemblyLinearVelocity or hrp.Velocity or Vector3.new(0, 0, 0)
        local pos = hrp.Position + vel * 0.1
        
        local hitCf = CFrame.lookAt(originPos, pos)

        for _, ch in ipairs(gun:GetDescendants()) do
            if ch:IsA("RemoteEvent") then
                pcall(function() ch:FireServer(1, hitCf, "AH2") end)
                pcall(function() ch:FireServer(hitCf, pos) end)
            elseif ch:IsA("RemoteFunction") then
                pcall(function() ch:InvokeServer(1, hitCf, "AH2") end)
                pcall(function() ch:InvokeServer(hitCf, pos) end)
            end
        end
    end
    local function murdererHRP()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and getRole(p) == "Murderer" then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then return hrp end
            end
        end
    end
    task.spawn(function()
        while S.Gui and S.Gui.Parent do
            if S.TriggerBot and equippedGun() then
                pcall(function()
                    local cam = workspace.CurrentCamera
                    local h = murdererHRP()
                    if cam and h then
                        -- Measure from the MOUSE, not the viewport centre: the custom crosshair
                        -- (and the FOV circle) follow the cursor, so this matches what you see.
                        -- WorldToViewportPoint already accounts for the GUI inset -> compare to the
                        -- RAW mouse (do NOT subtract the inset, or it sits ~36px off the crosshair).
                        local m = UIS:GetMouseLocation()
                        local center = Vector2.new(m.X, m.Y)
                        local sp, on = cam:WorldToViewportPoint(h.Position)
                        if on and (Vector2.new(sp.X, sp.Y) - center).Magnitude < 55 then fireGunAt(h) end
                    end
                end)
            end
            task.wait(0.15)
        end
    end)
    -- (UI toggle for Trigger Bot lives in the "Sheriff" section above.)
end
do
    -- Normal aim lock: while the toggle is on, HOLD Right Mouse Button to snap the camera onto the
    -- selected target's head. It is FOV-based: among role-matched alive players it picks the one
    -- CLOSEST TO YOUR CROSSHAIR that is inside the FOV circle (S.FOVRadius px) — nothing outside the
    -- FOV is locked. Target mode filters who's eligible: Nearest (any role), Murderer, or Sheriff
    -- (incl. the Hero holding the gun). NOTE: Aim Lock deliberately IGNORES the Targets tab pick
    -- (ManualTarget) — it always aims by FOV + mode, per request.
    local function aimTargetChar()
        local cam = workspace.CurrentCamera
        if not cam then return nil end
        local mode = S.AimLockTarget or "Nearest"
        local radius = S.FOVRadius or 360
        -- Measure from the MOUSE (the crosshair / FOV circle follow the cursor). WorldToViewportPoint
        -- ALREADY accounts for the GUI inset, so compare it to the RAW mouse (exactly like the FOV
        -- circle at draw-time and the getTarget() helper). Subtracting the inset shifts the hit-area
        -- ~36px above the visible FOV circle — that was the "aims/locks outside the FOV" bug.
        local m = UIS:GetMouseLocation()
        local center = Vector2.new(m.X, m.Y)
        local best, bestScore = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and not isWhitelisted(p) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
                if hum and head and hum.Health > 0 then
                    local r = getRole(p)
                    local ok
                    if mode == "Murderer" then ok = (r == "Murderer")
                    elseif mode == "Sheriff" then ok = (r == "Sheriff" or r == "Hero")
                    else ok = true end
                    if ok then
                        local sp, on = cam:WorldToViewportPoint(head.Position)
                        if on then
                            local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if d < radius and d < bestScore then bestScore = d; best = p.Character end
                        end
                    end
                end
            end
        end
        return best
    end
    -- Aim Lock precomputes its FOV target once per frame and eases the camera onto the chosen body part.
    tc(RunService.RenderStepped:Connect(function()
        -- Hold RMB on -> lock only while right mouse is held; off -> lock whenever Aim Lock is on.
        local rmb = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        local locked = S.AimLock and (not S.AimLockHoldRMB or rmb)
        if not locked then return end
        pcall(function()
            local ch = aimTargetChar()
            if not ch then return end
            -- Aim Part: aim at the chosen body part (fall back to Head, then HRP, if it's missing).
            local partName = S.AimPart or "Head"
            local aimPart = ch:FindFirstChild(partName) or ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
            if not aimPart then return end
            -- Prediction: lead a moving target by its own velocity (seconds ≈ slider / 100).
            local thrp = ch:FindFirstChild("HumanoidRootPart")
            local tvel = (thrp and thrp.AssemblyLinearVelocity) or Vector3.new()
            local aimPos = aimPart.Position + tvel * ((S.AimPrediction or 0) / 100)
            -- Move the camera toward the target, eased by Smoothness (1 = instant snap).
            local cam = workspace.CurrentCamera
            if cam then
                local goal = CFrame.lookAt(cam.CFrame.Position, aimPos)
                local sm = math.max(S.AimSmooth or 1, 1)
                cam.CFrame = (sm <= 1) and goal or cam.CFrame:Lerp(goal, math.clamp(1 / sm, 0, 1))
            end
        end)
    end))

end
do
    local oldNamecall
    local hookFunc = function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if (method == "FireServer" or method == "InvokeServer") and self:IsA("LuaSourceContainer") == false then
            local className = self.ClassName
            if className == "RemoteEvent" or className == "RemoteFunction" then
                local tool = self:FindFirstAncestorOfClass("Tool")
                if tool and (tool.Name == "Gun" or tool.Name == "Revolver") then
                    if S.PiercingBullet then
                        local murderer = nil
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= LP and p.Character and getRole(p) == "Murderer" then
                                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                                if hrp and hum and hum.Health > 0 then
                                    murderer = p.Character
                                    break
                                end
                            end
                        end
                        if murderer then
                            local head = murderer:FindFirstChild("Head") or murderer:FindFirstChild("HumanoidRootPart")
                            if head then
                                local targetPos = head.Position
                                local startPos = targetPos + Vector3.new(0, 5, 0)
                                local newCf = CFrame.lookAt(startPos, targetPos)
                                if #args == 3 and args[1] == 1 and typeof(args[2]) == "CFrame" and args[3] == "AH2" then
                                    args[2] = newCf
                                    return oldNamecall(self, table.unpack(args))
                                elseif #args == 2 then
                                    if typeof(args[1]) == "CFrame" and typeof(args[2]) == "Vector3" then
                                        args[1] = newCf
                                        args[2] = targetPos
                                        return oldNamecall(self, table.unpack(args))
                                    elseif typeof(args[1]) == "Vector3" and typeof(args[2]) == "Instance" then
                                        args[1] = targetPos
                                        args[2] = head
                                        return oldNamecall(self, table.unpack(args))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end
    if newcclosure then
        hookFunc = newcclosure(hookFunc)
    end
    oldNamecall = hookmetamethod(game, "__namecall", hookFunc)
end
do
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

    local sec3 = mkSection(Pages.Misc, "Camera", 3)
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
    mkToggle(sec4, "Anti-Fling", false, function(v) S.AntiFling = v end, 1)
    mkToggle(sec4, "Anti-Void", false, function(v) S.AntiVoid = v end, 2)
    mkToggle(sec4, "Anti-AFK", false, function(v) S.AntiAFK = v end, 3)
    mkToggle(sec4, "Auto Respawn", false, function(v) S.AutoRespawn = v end, 4)
    mkToggle(sec4, "Anti Ragdoll", false, function(v) S.AntiRagdoll = v end, 5)
    local sec6 = mkSection(Pages.Misc, "Performance", 5)
    mkToggle(sec6, "Anti Lag", false, function(v) S.AntiLag = v end, 1)

    -- ============ FOLLOW & ORBIT SECTION ============
    local secFollow = mkSection(Pages.Misc, "Follow & Orbit", 6)
    
    -- Custom Target Player TextBox row
    local rowF = Instance.new("Frame")
    rowF.Parent = secFollow
    rowF.LayoutOrder = 1
    rowF.Size = UDim2.new(1, 0, 0, 30)
    rowF.BackgroundTransparency = 1
    Corner(rowF, 6)
    
    local lblF = Instance.new("TextLabel")
    lblF.Parent = rowF
    lblF.BackgroundTransparency = 1
    lblF.Position = UDim2.new(0, 6, 0, 0)
    lblF.Size = UDim2.new(1, -12, 1, 0)
    lblF.Font = F
    lblF.TextSize = 12
    lblF.TextColor3 = T.Tx4; pcall(function() lblF:SetAttribute("ThemeColorRole_TextColor3", "Tx4") end)
    lblF.TextWrapped = true
    lblF.TextXAlignment = Enum.TextXAlignment.Left
    lblF.Text = "Target is picked in the Targets tab (Auto = nearest)."

    mkToggle(secFollow, "Enable Follow/Orbit", false, function(v)
        S.FollowPlayer = v
        if v and not next(S.ManualTargets) then Notify("Follow", "No player picked in Targets tab - following nearest", 3) end
    end, 2)
    mkCycle(secFollow, "Follow Mode", {"Follow", "Orbit"}, "Follow", function(v) S.FollowPlayerMode = v end, 3)
    mkSlider(secFollow, "Follow Distance", 1, 30, 4, function(v) S.FollowPlayerDistance = v end, 4)
    mkSlider(secFollow, "Orbit Speed", 5, 1000, 20, function(v) S.FollowPlayerOrbitSpeed = v end, 5)
    mkSlider(secFollow, "Travel Speed", 10, 300, 60, function(v) S.FollowPlayerSpeed = v end, 6)

    -- Follow/Orbit loop
    local followAngle = 0
    task.spawn(function()
        while S.Gui and S.Gui.Parent do
            if S.FollowPlayer then
                pcall(function()
                    local c = LP.Character
                    local hrp = c and c:FindFirstChild("HumanoidRootPart")
                    local hum = c and c:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        -- Target from the Targets tab list (multi-select): nearest alive player among the
                        -- picked set; empty set = nearest of everyone.
                        local target = nil
                        local sel = S.ManualTargets
                        local picking = next(sel) ~= nil
                        local bestD
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= LP and p.Character and (not picking or sel[p.Name]) then
                                local phrp = p.Character:FindFirstChild("HumanoidRootPart")
                                local ph = p.Character:FindFirstChildOfClass("Humanoid")
                                if phrp and ph and ph.Health > 0 then
                                    local d = (phrp.Position - hrp.Position).Magnitude
                                    if not bestD or d < bestD then bestD = d; target = p end
                                end
                            end
                        end

                        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                            local th = target.Character:FindFirstChildOfClass("Humanoid")
                            local thrp = target.Character.HumanoidRootPart
                            if th and th.Health > 0 and thrp then
                                -- Noclip character
                                for _, pt in pairs(c:GetDescendants()) do
                                    if pt:IsA("BasePart") then pt.CanCollide = false end
                                end
                                
                                local targetCF
                                local dist = S.FollowPlayerDistance or 4
                                
                                if S.FollowPlayerMode == "Orbit" then
                                    followAngle = (followAngle + (S.FollowPlayerOrbitSpeed or 20) * 0.6) % 360
                                    local offset = Vector3.new(math.cos(math.rad(followAngle)) * dist, 0, math.sin(math.rad(followAngle)) * dist)
                                    targetCF = CFrame.new(thrp.Position + offset, thrp.Position)
                                    
                                    hrp.AssemblyLinearVelocity = Vector3.zero
                                    hrp.AssemblyAngularVelocity = Vector3.zero
                                    hrp.CFrame = targetCF
                                else
                                    -- Follow behind target
                                    targetCF = thrp.CFrame * CFrame.new(0, 0, dist)
                                    
                                    local distance = (targetCF.Position - hrp.Position).Magnitude
                                    if distance > 0.5 then
                                        local speed = S.FollowPlayerSpeed or 60
                                        if distance > 40 then
                                            hrp.AssemblyLinearVelocity = Vector3.zero
                                            hrp.AssemblyAngularVelocity = Vector3.zero
                                            hrp.CFrame = targetCF
                                        else
                                            local step = math.min((speed * 0.016) / distance, 1)
                                            hrp.AssemblyLinearVelocity = Vector3.zero
                                            hrp.AssemblyAngularVelocity = Vector3.zero
                                            hrp.CFrame = hrp.CFrame:Lerp(targetCF, step)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
            task.wait(0.016)
        end
    end)

    local sec5 = mkSection(Pages.Misc, "Utility", 7)
    mkAction(sec5, "Reset Character", function() respawnChar() end, 1)
    mkAction(sec5, "Ceiling Teleport", function() ceilingTP() end, 2)
    mkAction(sec5, "Rejoin Server", function() rejoinServer() end, 3)
    mkAction(sec5, "Server Hop", function() serverHop() end, 4)

    -- Custom Goto Player row
    local row = Instance.new("Frame")
    row.Parent = sec5
    row.LayoutOrder = 5
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
        TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = T.Hover })
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = T.Elev })
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
                Notify("Goto", "Teleported to " .. found.Name, 2)
            end
            else
                Notify("Goto", "Player not found", 2)
            end
        end)

    local secSocial = mkSection(Pages.Misc, "Social & HUD", 8)
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
    end)

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
        -- Re-evaluate every existing sound (catch pre-existing ones on toggle-on; restore on toggle-off).
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
        mkToggle(secSnd, "Mute Gun Sound",     false, function(v) S.MuteGun = v;        refreshMutes() end, 1)
        mkToggle(secSnd, "Mute Coin Sound",    false, function(v) S.MuteCoin = v;       refreshMutes() end, 2)
        mkToggle(secSnd, "Mute Kill Sound",    false, function(v) S.MuteKill = v;       refreshMutes() end, 3)
        mkToggle(secSnd, "Mute Kill Effect Sound", false, function(v) S.MuteKillEffect = v; refreshMutes() end, 5)
        mkToggle(secSnd, "Mute Kill Notify",   false, function(v) S.MuteKillNotify = v; refreshMutes() end, 4)
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
        mkToggle(secKE, "Hide Kill Effects", false, function(v) S.HideKillFX = v end, 1)
    end
end
do
    local sec1 = mkSection(Pages.Teleport, "Roles", 1)
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
        local c = LP.Character; if not c or not c:FindFirstChild("HumanoidRootPart") then return end
        local far, md = nil, 0
        for _, p in pairs(Players:GetPlayers()) do if p ~= LP and p.Character then
            local pr = p.Character:FindFirstChild("HumanoidRootPart"); if pr then
                local d = pr.Position.Magnitude; if d > md then md = d; far = pr end end end end
        if far then c.HumanoidRootPart.CFrame = far.CFrame + Vector3.new(0,0,5); Notify("Moved","Map area",2) end
    end, 2)
    mkToggle(sec2, "Click TP (press E)", false, function(v) S.ClickTP = v end, 3)
    local sec3 = mkSection(Pages.Teleport, "Players", 3)
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
                TweenService:Create(b, TweenInfo.new(0.1), { BackgroundColor3 = T.Hover })
            end)
            b.MouseLeave:Connect(function()
                TweenService:Create(b, TweenInfo.new(0.1), { BackgroundColor3 = T.Elev })
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
end
do
    -- Teleport utilities: waypoint (save/load a position) and a forward blink.
    local savedPos
    local sec = mkSection(Pages.Teleport, "Utility", 4)
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
-- ============ TARGETS TAB (pick one player for Fun functions) ============
do
    local sec1 = mkSection(Pages.Targets, "Manual Target", 1)
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
    info.Text = "Left-click = select targets (multi — pick several; Fun & Follow use the NEAREST selected). 'Auto' clears the selection = nearest of all. Right-click = Whitelist (green WL): that player is SKIPPED by Fling, Kill All, Knife Aura and Aim Lock."
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
        local function mkRow(labelText, plrName)
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
            -- "WL" tag on the right, shown when this player is whitelisted (protected / skipped).
            local wl = Instance.new("TextLabel")
            wl.Name = "WLTag"
            wl.Parent = b
            wl.AnchorPoint = Vector2.new(1, 0.5)
            wl.Position = UDim2.new(1, -8, 0.5, 0)
            wl.Size = UDim2.new(0, 30, 0, 16)
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
            end
            refreshVis()
            b.MouseEnter:Connect(function()
                -- Only plain rows get the hover tint; selected (blue) and whitelisted (green) rows keep
                -- their colour so it doesn't flicker away on hover.
                if not isSelected() and not isWL() then TweenService:Create(b, TweenInfo.new(0.1), { BackgroundColor3 = T.Hover }):Play() end
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
        mkRow("Auto (role / nearest)", nil)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and (searchQ == "" or string.find(string.lower(p.Name), searchQ, 1, true)) then
                mkRow(p.Name, p.Name)
            end
        end
    end
    refreshTargets()
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
-- Wall TP
local walltpConn
local function startWallTP()
    if walltpConn then walltpConn:Disconnect() end
    local c = LP.Character
    local torso = c and (c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso"))
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if not torso or not hum then return end
    walltpConn = torso.Touched:Connect(function(hit)
        local Root = getRoot(LP.Character)
        if not Root or not hit:IsA("BasePart") then return end
        if hit.Position.Y > Root.Position.Y - hum.HipHeight then
            local hitP = getRoot(hit.Parent)
            local lv = Root.CFrame.LookVector
            if hitP then
                Root.CFrame = hit.CFrame * CFrame.new(lv.X, hitP.Size.Z / 2 + hum.HipHeight, lv.Z)
            else
                Root.CFrame = hit.CFrame * CFrame.new(lv.X, hit.Size.Y / 2 + hum.HipHeight, lv.Z)
            end
        end
    end)
end
local function stopWallTP()
    if walltpConn then walltpConn:Disconnect(); walltpConn = nil end
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
    headSitConn = RunService.Heartbeat:Connect(function()
        local tRoot = target.Character and getRoot(target.Character)
        local myRoot = getRoot(LP.Character)
        local myHum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if tRoot and myRoot and myHum and myHum.Sit then
            myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 1.6, 0.4)
        end
    end)
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
    orbitConns.a = RunService.Heartbeat:Connect(function()
        pcall(function()
            rotation = rotation + (S.OrbitSpeed or 20) / 100
            local troot = getRoot(target.Character)
            local center = troot.Position + Vector3.new(0, S.OrbitHeight or 0, 0)
            root.CFrame = CFrame.new(center) * CFrame.Angles(0, math.rad(rotation), 0) * CFrame.new(S.OrbitDist or 6, 0, 0)
        end)
    end)
    orbitConns.b = RunService.RenderStepped:Connect(function()
        pcall(function()
            local troot = getRoot(target.Character)
            root.CFrame = CFrame.new(root.Position, troot.Position)
        end)
    end)
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
        bangConn = RunService.Stepped:Connect(function()
            pcall(function()
                local otherRoot = getTorso(target.Character)
                local myRoot = getRoot(LP.Character)
                if otherRoot and myRoot then myRoot.CFrame = otherRoot.CFrame * offset end
            end)
        end)
    end
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
        workspace.FallenPartsDestroyHeight = -1e9
        -- Drop WAY below the fall-destroy line (was only -25, too shallow to shake off flingers).
        -- We're safe because FallenPartsDestroyHeight is -1e9 while we're down here; the leftover
        -- flinger parts get nuked when it's restored to OrgDestroyHeight below.
        root.CFrame = CFrame.new(Vector3.new(0, OrgDestroyHeight - 10000, 0))
        task.wait(1)
        root = getRoot(LP.Character)
        if root then root.CFrame = oldpos end
        workspace.FallenPartsDestroyHeight = OrgDestroyHeight
        Notify("Fake Out", "Done - attached flingers dropped", 3)
    end)
end
-- Wall Walk (external)
local function doWallWalk()
    task.spawn(function()
        local ok = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/wallwalker.lua"))()
        end)
        Notify("Wall Walk", ok and "Loaded" or "Failed to load", 3)
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
    local function cleanup()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
    end
    stopInvisibleFE = function()
        if not running then return end
        running = false
        cleanup()
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
                pcall(function() LP:LoadCharacter() end)
            end
        end)
        realChar, cloneChar = nil, nil
        if not ok then pcall(function() LP:LoadCharacter() end) end
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
            if ch then table.insert(conns, ch.Died:Connect(function() stopInvisibleFE() end)) end
            local Void = workspace.FallenPartsDestroyHeight
            table.insert(conns, RunService.Stepped:Connect(function()
                local r = cloneChar and cloneChar:FindFirstChild("HumanoidRootPart")
                if r and r.Position.Y <= Void + 5 then stopInvisibleFE() end
            end))
        end)
        if not ok then
            running = false
            cleanup()
            realChar, cloneChar = nil, nil
            pcall(function() LP:LoadCharacter() end)
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
    local function cleanup()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
    end
    stopBlink = function()
        if not running then return end
        running = false
        cleanup()
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
                pcall(function() LP:LoadCharacter() end)
            end
        end)
        realChar, cloneChar = nil, nil
        if not ok then pcall(function() LP:LoadCharacter() end) end
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
            if ch then table.insert(conns, ch.Died:Connect(function() stopBlink() end)) end
            local Void = workspace.FallenPartsDestroyHeight
            table.insert(conns, RunService.Stepped:Connect(function()
                local r = cloneChar and cloneChar:FindFirstChild("HumanoidRootPart")
                if r and r.Position.Y <= Void + 5 then stopBlink() end
            end))
        end)
        if not ok then
            running = false
            cleanup()
            realChar, cloneChar = nil, nil
            pcall(function() LP:LoadCharacter() end)
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
        mkToggle(secM, "Wall TP", false, function(v) S.WallTP = v; if v then startWallTP() else stopWallTP() end end, 2)
    mkAction(secM, "Wall Walk", function() doWallWalk() end, 3)
    mkAction(secM, "Trip", function() doTrip() end, 4)
    mkAction(secM, "Fake Out (Flinger Kill)", function() doFakeOut() end, 5)
    local secTr = mkSection(Pages.Fun, "Troll", 3)
    mkToggle(secTr, "Spinbot", false, function(v) S.Spinbot = v end, 1)
    mkSlider(secTr, "Spin Speed", 5, 1000, 20, function(v) S.SpinSpeed = v end, 2)
    mkToggle(secTr, "Jerk", false, function(v) S.Jerk = v; if v then startJerk() else stopJerk() end end, 3)
    mkToggle(secTr, "Click Fling", false, function(v) S.ClickFling = v end, 4)
    local secC = mkSection(Pages.Fun, "Camera & Body", 4)
    mkToggle(secC, "Free Cam", false, function(v) S.FreeCam = v; if v then startFreecam() else stopFreecam() end end, 1)
    toggleInvisible = mkToggle(secC, "Invisible (FE)", false, function(v) S.InvisibleFE = v; if v then startInvisibleFE() else stopInvisibleFE() end end, 2)
    toggleBlink = mkToggle(secC, "Blink", false, function(v) S.Blink = v; if v then startBlink() else stopBlink() end end, 3)

    local animPacks = {
        Levitation = { idle1 = '616006778', idle2 = '616008087', walk = '616013216', run = '616010382', jump = '616008936', climb = '616003713', fall = '616005863' },
        Astronaut = { idle1 = '891621366', idle2 = '891633237', walk = '891667138', run = '891636393', jump = '891627522', climb = '891609353', fall = '891617961' },
        Ninja = { idle1 = '656117400', idle2 = '656118341', walk = '656121766', run = '656118852', jump = '656117878', climb = '656114359', fall = '656115606' },
        Pirate = { idle1 = '750781874', idle2 = '750782770', walk = '750785693', run = '750783738', jump = '750782230', climb = '750779899', fall = '750780242' },
        Toy = { idle1 = '782841498', idle2 = '782845736', walk = '782843345', run = '782842708', jump = '782847020', climb = '782843869', fall = '782846423' },
        Cowboy = { idle1 = '1014390418', idle2 = '1014398616', walk = '1014421541', run = '1014401683', jump = '1014394726', climb = '1014380606', fall = '1014384571' },
        Princess = { idle1 = '941003647', idle2 = '941013098', walk = '941028902', run = '941015281', jump = '941008832', climb = '940996062', fall = '941000007' },
        Knight = { idle1 = '657595757', idle2 = '657568135', walk = '657552124', run = '657564596', jump = '658409194', climb = '658360781', fall = '657600338' },
        Vampire = { idle1 = '1083445855', idle2 = '1083450166', walk = '1083473930', run = '1083462077', jump = '1083455352', climb = '1083439238', fall = '1083443587' },
        Patrol = { idle1 = '1149612882', idle2 = '1150842221', walk = '1151231493', run = '1150967949', jump = '1150944216', climb = '1148811837', fall = '1148863382' },
        Elder = { idle1 = '845397899', idle2 = '845400520', walk = '845403856', run = '845386501', jump = '845398858', climb = '845392038', fall = '845396048' },
        Mage = { idle1 = '707742142', idle2 = '707855907', walk = '707897309', run = '707861613', jump = '707853694', climb = '707826056', fall = '707829716' },
        Werewolf = { idle1 = '1083195517', idle2 = '1083214717', walk = '1083178339', run = '1083216690', jump = '1083218792', climb = '1083182000', fall = '1083189019' },
        Cartoony = { idle1 = '742637544', idle2 = '742638445', walk = '742640026', run = '742638842', jump = '742637942', climb = '742636889', fall = '742637151' },
        Sneaky = { idle1 = '1132473842', idle2 = '1132477671', walk = '1132510133', run = '1132494274', jump = '1132489853', climb = '1132461372', fall = '1132469004' },
        Stylish = { idle1 = '616136790', idle2 = '616138447', walk = '616146177', run = '616140816', jump = '616139451', climb = '616133594', fall = '616134815' },
        Bubbly = { idle1 = '910004836', idle2 = '891633237', walk = '910034870', run = '910025107', jump = '910016857', climb = '909997997', fall = '910001910' },
        Superhero = { idle1 = '616111295', idle2 = '616113536', walk = '616122287', run = '616117076', jump = '616115533', climb = '616104706', fall = '616108001' },
        Stylized = { idle1 = '4708191566', idle2 = '4708192150', walk = '4708193840', run = '4708192705', jump = '4708188025', climb = '4708184253', fall = '4708186162' },
        Popstar = { idle1 = '1212900985', idle2 = '1212954651', walk = '1212980338', run = '1212980348', jump = '1212954642', climb = '1213044939', fall = '1212900995' },
        Wickind = { idle1 = '118832222982049', idle2 = '76049494037641', walk = '92072849924640', run = '72301599441680', jump = '104325245285198', climb = '121152442762481', fall = '121152442762481' },
        AnimationGUI = { idle1 = '122257458498464', idle2 = '102357151005774', walk = '122150855457006', run = '82598234841035', jump = '104325245285198', climb = '10921271391', fall = '121152442762481' },
        NFL = { idle1 = '92080889861410', idle2 = '74451233229259', walk = '110358958299415', run = '117333533048078', jump = '119846112151352', climb = '134630013742019', fall = '129773241321032' },
        NoBoundAries = { idle1 = '18747067405', idle2 = '18747063918', walk = '18747074203', run = '18747070484', jump = '18747069148', climb = '18747060903', fall = '18747062535' },
        CatWalkGlam = { idle1 = '133806214992291', idle2 = '94970088341563', walk = '109168724482748', run = '81024476153754', jump = '116936326516985', climb = '119377220967554', fall = '92294537340807' },
        Bload = { idle1 = '16738333868', idle2 = '16738334710', walk = '16738340646', run = '16738337225', jump = '16738336650', climb = '16738332169', fall = '16738333171' },
        AdidasSports = { idle1 = '18537376492', idle2 = '18537371272', walk = '18537392113', run = '18537384940', jump = '18537380791', climb = '18537363391', fall = '18537367238' }
    }

    local animNames = {}
    for name in pairs(animPacks) do
        table.insert(animNames, name)
    end
    table.sort(animNames)

    local activeAnim = nil
    local animEntries = {}
    local resetEntry = nil

    local function refreshAnimButtons()
        if resetEntry then resetEntry.updateVisuals() end
        for _, ent in pairs(animEntries) do
            pcall(function() ent.updateVisuals() end)
        end
    end

    local function applyAnim(packName)
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        if hum.RigType ~= Enum.HumanoidRigType.R15 then
            Notify("Animations", "R15 Rig Type required!", 3)
            return
        end
        local anims = animPacks[packName]
        if not anims then return end
        local animate = char:FindFirstChild("Animate")
        if not animate then return end

        animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=" .. anims.idle1
        animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=" .. anims.idle2
        animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. anims.walk
        animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. anims.run
        animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. anims.jump
        animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. anims.climb
        animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. anims.fall

        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        animate.Disabled = false
        activeAnim = packName
        refreshAnimButtons()
        Notify("Animations", packName .. " applied", 2)
    end

    tc(LP.CharacterAdded:Connect(function(char)
        task.wait(2)
        if activeAnim then
            pcall(applyAnim, activeAnim)
        end
        if currentEmoteId and currentEmoteToggle then
            pcall(playEmote, currentEmoteToggle, currentEmoteId, currentEmoteToggle.label)
        end
    end))

    local secAnim = mkSection(Pages.Fun, "Animations", 5)
    resetEntry = mkAction(secAnim, "Reset to Default", function()
        activeAnim = nil
        refreshAnimButtons()
        Notify("Animations", "Animations reset. Reset character to apply.", 3)
    end, 1)

    local origResetUpdate = resetEntry.updateVisuals
    resetEntry.updateVisuals = function()
        origResetUpdate()
        local activeSuffix = (activeAnim == nil) and "   [ ACTIVE ]" or ""
        local bk = resetEntry.bindKey and ("   [ " .. resetEntry.bindKey.Name .. " ]") or ""
        resetEntry.btn.Text = "Reset to Default" .. activeSuffix .. bk
        resetEntry.btn.TextColor3 = (activeAnim == nil) and T.Accent or T.Tx
    end

    for i, name in ipairs(animNames) do
        local entry = mkAction(secAnim, name .. " Animation", function()
            applyAnim(name)
        end, i + 1)
        animEntries[name] = entry

        local origUpdate = entry.updateVisuals
        entry.updateVisuals = function()
            origUpdate()
            local activeSuffix = (activeAnim == name) and "   [ ACTIVE ]" or ""
            local bk = entry.bindKey and ("   [ " .. entry.bindKey.Name .. " ]") or ""
            entry.btn.Text = name .. " Animation" .. activeSuffix .. bk
            entry.btn.TextColor3 = (activeAnim == name) and T.Accent or T.Tx
        end
    end

    refreshAnimButtons()

    local secDance = mkSection(Pages.Fun, "Dance R15", 6)
    local dances = {
        { name = "hose", id = "99665733544814" },
        { name = "gun", id = "107728954756412" },
        { name = "Little Obbyist", id = "115569573258316" },
        { name = "Dead Player", id = "88130117312312" },
        { name = "Biblically", id = "109873544976020" },
        { name = "Poo Animation", id = "90708290447388" }
    }
    for idx, dance in ipairs(dances) do
        local toggle
        toggle = mkToggle(secDance, dance.name, false, function(v)
            if v then
                playEmote(toggle, dance.id, dance.name)
            else
                stopEmote(toggle)
            end
        end, idx)
    end

    local secMock = mkSection(Pages.Fun, "Mockery Animation", 7)
    local mockeries = {
        { name = "Da Hood Dance", id = "115048845533448" },
        { name = "Caramelldansen", id = "88315693621494" },
        { name = "Default Dance", id = "88455578674030" },
        { name = "Cute Stomach Lay", id = "80754582835479" }
    }
    for idx, mock in ipairs(mockeries) do
        local toggle
        toggle = mkToggle(secMock, mock.name, false, function(v)
            if v then
                playEmote(toggle, mock.id, mock.name)
            else
                stopEmote(toggle)
            end
        end, idx)
    end

    -- ---- Target Actions live on the TARGETS tab (built here so they can reuse the Fun module's
    -- start/stop helpers + funTarget/skidFling). They all act on the player picked in the Targets
    -- list; with "Auto" selected that resolves to the nearest player.
    local function currentTarget() return funTarget() end
    local secTgt = mkSection(Pages.Targets, "Target Actions", 2)
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
    mkAction(secTgt, "Teleport to Target", function()
        local t = currentTarget()
        local troot = t and t.Character and getRoot(t.Character)
        local myroot = getRoot(LP.Character)
        if troot and myroot then
            myroot.CFrame = troot.CFrame * CFrame.new(0, 0, 3)
            Notify("Teleport", "Teleported to " .. t.Name, 2)
        else Notify("Teleport", "No valid target", 2) end
    end, 2)
    mkToggle(secTgt, "Orbit Target", false, function(v) S.Orbit = v; if v then startOrbit() else stopOrbit() end end, 3)
    mkSlider(secTgt, "Orbit Speed", 5, 1000, 20, function(v) S.OrbitSpeed = v end, 4)
    mkSlider(secTgt, "Orbit Distance", 3, 30, 6, function(v) S.OrbitDist = v end, 5)
    mkSlider(secTgt, "Orbit Height", -30, 30, 0, function(v) S.OrbitHeight = v end, 6)
    mkToggle(secTgt, "Sit on Target", false, function(v) S.HeadSit = v; if v then startHeadSit() else stopHeadSit() end end, 7)
    mkToggle(secTgt, "Bang Target", false, function(v) S.Bang = v; if v then startBang() else stopBang() end end, 8)
    mkSlider(secTgt, "Bang Speed", 1, 10, 3, function(v) S.BangSpeed = v end, 9)
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
            end
        end))
    end
    HUDEls[name] = { frame = f, content = ct }
    return HUDEls[name]
end
HUD.hRoles = mkDragHUD("Roles", UDim2.new(0, 10, 0, 200), UDim2.fromOffset(260, 160), 850)
Instance.new("UIListLayout", HUD.hRoles.content).Padding = UDim.new(0, 2)
HUD.hBinds = mkDragHUD("Keybinds", UDim2.new(0, 10, 0, 370), UDim2.fromOffset(260, 150), 851)
Instance.new("UIListLayout", HUD.hBinds.content).Padding = UDim.new(0, 2)
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
HUD.hFps = mkDragHUD("FPS", UDim2.new(1, -115, 0, 10), UDim2.fromOffset(100, 42), 854)
HUD.fpsLbl = Instance.new("TextLabel")
HUD.fpsLbl.Parent = HUD.hFps.content
HUD.fpsLbl.BackgroundTransparency = 1
HUD.fpsLbl.Size = UDim2.new(1, 0, 1, 0)
HUD.fpsLbl.Font = FB
HUD.fpsLbl.TextSize = 22
HUD.fpsLbl.TextColor3 = T.White; pcall(function() HUD.fpsLbl:SetAttribute("ThemeColorRole_TextColor3", "White") end)
HUD.fpsLbl.Text = "0"
HUD.fpsLbl.ZIndex = 855
local function mkStatHUD(name, pos, w, h, z, tsize)
    local hud = mkDragHUD(name, pos, UDim2.fromOffset(w, h), z)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = hud.content
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.Font = FM
    lbl.TextSize = tsize or 15
    lbl.TextColor3 = T.Tx; pcall(function() lbl:SetAttribute("ThemeColorRole_TextColor3", "Tx") end)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Top
    lbl.TextWrapped = true
    lbl.Text = "..."
    lbl.ZIndex = z + 1
    return hud, lbl
end
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
    local iSt = Stroke(icon, Color3.fromRGB(70, 70, 75), 1.2, 0.4)
    
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
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dr = false end
        end))
    end
    HUDEls["Watermark"] = { frame = f, content = f }
    return f, lbl
end
HUD.hPing, HUD.pingLbl = mkStatHUD("Ping", UDim2.new(1, -115, 0, 60), 100, 44, 856, 18)
HUD.hCoords, HUD.coordLbl = mkStatHUD("Coords", UDim2.new(0, 10, 0, 540), 210, 74, 857, 14)
HUD.hTime, HUD.timeLbl = mkStatHUD("Time", UDim2.new(1, -165, 0, 112), 150, 44, 858, 16)
HUD.hPlayers, HUD.playersLbl = mkStatHUD("Players", UDim2.new(1, -165, 0, 164), 150, 60, 859, 15)
HUD.hWatermark, HUD.watermarkLbl = mkWatermark()
HUD.hSpeed, HUD.speedLbl = mkStatHUD("Speed", UDim2.new(1, -165, 0, 284), 150, 62, 861, 24)
HUD.hSession, HUD.sessionLbl = mkStatHUD("Session", UDim2.new(1, -165, 0, 232), 150, 44, 863, 16)
-- Kill Feed is NOT a window/panel anymore — it's a transparent container anchored top-right where
-- kill cards pop in, hold, then fade + collapse out. It auto-sizes to its cards, so with no recent
-- kills nothing is drawn (no big empty box). Registered in HUDEls so the toggle + config still work.

do
    local f = Instance.new("Frame")
    f.Name = "HUD_Kill Feed"
    f.Parent = SG
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.Position = UDim2.new(1, -272, 0, 110)
    f.Size = UDim2.new(0, 256, 0, 0)
    f.AutomaticSize = Enum.AutomaticSize.Y
    f.Visible = false
    f.ZIndex = 864
    local kfl = Instance.new("UIListLayout")
    kfl.Parent = f
    kfl.SortOrder = Enum.SortOrder.LayoutOrder
    kfl.Padding = UDim.new(0, 6)
    kfl.HorizontalAlignment = Enum.HorizontalAlignment.Right
    kfl.VerticalAlignment = Enum.VerticalAlignment.Top
    HUDEls["Kill Feed"] = { frame = f, content = f }
    HUD.hKillFeed = HUDEls["Kill Feed"]
end
do
    local sec = mkSection(Pages.HUD, "HUD Elements", 1)
    mkToggle(sec, "Roles HUD", false, function(v)
        S.HUD_Roles = v
        HUDEls["Roles"].frame.Visible = v
    end, 1)
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
    mkToggle(sec, "Time HUD", false, function(v)
        S.HUD_Time = v
        HUDEls["Time"].frame.Visible = v
    end, 7)
    mkToggle(sec, "Players HUD", false, function(v)
        S.HUD_Players = v
        HUDEls["Players"].frame.Visible = v
    end, 8)
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
    local info = Instance.new("TextLabel")
    info.Parent = sec
    info.LayoutOrder = 13
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

local function applyShader(name)
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
do
    local sec = mkSection(Pages.Shaders, "Presets", 1)
    -- One exclusive toggle per preset, generated from this list: turning one on switches the
    -- others off; turning the active one off returns to "None".
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
        shaderToggles[nm] = mkToggle(sec, nm, false, function(v)
            if v then
                clearOtherToggles(nm)
                applyShader(nm)
            elseif S.ActiveShader == nm then
                applyShader("None")
            end
        end, i)
    end
    mkAction(sec, "Disable Shaders", function()
        clearOtherToggles(nil)
        applyShader("None")
        Notify("Shaders", "All shaders disabled", 2)
    end, #SHADER_LIST + 1)
end
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
    local sec = mkSection(Pages.Shaders, "Hand Shaders (Self)", 2)
    mkToggle(sec, "Enable Hand Shader", false, function(v) S.HandShader = v end, 1)
    mkCycle(sec, "Shader Type", {"Both", "Fill", "Outline", "Mirror", "Bloom", "Maze", "Crystal", "Chrome", "Plasma"}, "Both", function(v) S.HandShaderType = v end, 2)
    mkCycle(sec, "Apply To", {"Full Body", "Held Item"}, "Full Body", function(v) S.HandTarget = v end, 3)
    mkCycle(sec, "Color", {"Cyan", "White", "Red", "Green", "Blue", "Yellow", "Purple", "Orange", "Pink", "Black"}, "Cyan", function(v) S.HandColor = v end, 4)
    mkToggle(sec, "Rainbow", false, function(v) S.HandRainbow = v end, 5)
    mkSlider(sec, "Fill Opacity", 0, 100, 60, function(v) S.HandFill = v end, 6)

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
-- ============ WORLD TAB (coins + environment: time / gravity / effects) ============
do
    local sec2 = mkSection(Pages.World, "Environment", 1)
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

    -- Fly STRAIGHT THROUGH WALLS to a point: noclip every step + set the CFrame directly. Returns
    -- true only if we actually arrived (used to tell "collected" from "bag full won't collect").
    local function moveTo(targetCF, speed, checkFn)
        local spd = math.max(speed or S.FastAutofarmSpeed or 20, 1)
        local deadline = tick() + 12
        while tick() < deadline do
            if not S.FastAutofarm then return false end
            if checkFn and not checkFn() then return false end
            local c = LP.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then return false end
            -- Noclip so walls never block the path.
            for _, pt in ipairs(c:GetDescendants()) do
                if pt:IsA("BasePart") then pt.CanCollide = false end
            end
            local dt = math.min(task.wait(), 1 / 30)
            c = LP.Character
            hrp = c and c:FindFirstChild("HumanoidRootPart")
            if not hrp then return false end
            local delta = targetCF.Position - hrp.Position
            local dist = delta.Magnitude
            local step = spd * dt
            if dist <= math.max(2.5, step) then
                hrp.CFrame = CFrame.new(targetCF.Position)
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                return true
            end
            local dir = delta / dist
            local newPos = hrp.Position + dir * step
            -- Match the velocity to the glide. This keeps the server seeing consistent motion (no
            -- rubber-band -> passes THROUGH walls) AND overrides gravity so we don't fall into the
            -- void when there's no floor under us. Never zero it (rubber-band) or leave it (gravity).
            hrp.AssemblyLinearVelocity = dir * spd
            hrp.AssemblyAngularVelocity = Vector3.zero
            local flat = Vector3.new(dir.X, 0, dir.Z)
            hrp.CFrame = (flat.Magnitude > 0.05) and CFrame.new(newPos, newPos + flat) or CFrame.new(newPos)
        end
        return false
    end

    -- ---------- UI ----------
    local secCoins = mkSection(Pages.Autofarm, "Coins", 1)
    mkToggle(secCoins, "Coin ESP", false, function(v) S.CoinESP = v end, 1)

    local secAuto = mkSection(Pages.Autofarm, "Automated", 2)
    mkToggle(secAuto, "Fast Autofarm", false, function(v) S.FastAutofarm = v end, 1)
    -- Studs/s (1-40). Lower = safer / less likely the position validator lags you back through walls.
    mkSlider(secAuto, "Autofarm Speed", 1, 40, 20, function(v) S.FastAutofarmSpeed = v end, 2)

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
                            bb.Size = UDim2.fromOffset(14, 14)
                            bb.AlwaysOnTop = true
                            bb.LightInfluence = 0
                            bb.Parent = host
                            local dot = Instance.new("Frame")
                            dot.Size = UDim2.fromScale(1, 1)
                            dot.BackgroundColor3 = Color3.fromRGB(255, 210, 0)
                            dot.BorderSizePixel = 0
                            dot.Parent = bb
                            local uc = Instance.new("UICorner")
                            uc.CornerRadius = UDim.new(1, 0)
                            uc.Parent = dot
                            local us = Instance.new("UIStroke")
                            us.Color = Color3.fromRGB(70, 50, 0)
                            us.Thickness = 1
                            us.Parent = dot
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
                                    if cn.Parent and cn.Transparency < 1 and (h.Position - cn.Position).Magnitude < 11 then
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
                            -- Nothing left to collect -> hover in place (anchored so noclip doesn't
                            -- drop us through the floor) and wait. Autofarm does nothing but collect.
                            hrp.Anchored = true
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
local function _cfgEnsureDir()
    if not FILE_OK then return end
    pcall(function()
        if makefolder and isfolder and not isfolder(CFG_DIR) then makefolder(CFG_DIR) end
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
    for name, el in pairs(HUDEls) do
        local f = el.frame
        data.hud[name] = {
            v = f.Visible,
            xs = f.Position.X.Scale, x = f.Position.X.Offset,
            ys = f.Position.Y.Scale, y = f.Position.Y.Offset,
        }
    end
    -- Keybinds: id (page/section/label) -> KeyCode name
    for _, e in ipairs(AllBinds) do
        if e.bindKey and e.cfgId then data.binds[e.cfgId] = e.bindKey.Name end
    end
    return data
end
local function applyConfig(data)
    if type(data) ~= "table" then return end
    if type(data.controls) == "table" then
        for _, c in ipairs(ConfigControls) do
            local v = data.controls[c.id]
            if v ~= nil then pcall(function() c.set(v) end) end
        end
    end
    if type(data.hud) == "table" then
        for name, h in pairs(data.hud) do
            local el = HUDEls[name]
            if el and type(h) == "table" then
                pcall(function()
                    el.frame.Position = UDim2.new(h.xs or 0, h.x or 0, h.ys or 0, h.y or 0)
                    el.frame.Visible = (h.v == true)
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
    return true
end
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
            if nm and nm ~= "_autoload" then table.insert(out, nm) end
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
        info.Text = "Auto Save keeps your current settings + HUD layout and restores them automatically on next launch."
    end
end
if FILE_OK then
    task.spawn(function()
        task.wait(1)
        pcall(function() loadConfig("_autoload") end)
    end)
    -- Auto-save writes to disk ONLY when the config actually changed. The old version rewrote the
    -- file every 5s no matter what, so it did constant synchronous disk I/O (a periodic micro-stutter)
    -- even while idle. Now an unchanged config is a no-op; a change is persisted within ~5s.
    task.spawn(function()
        local lastEnc = nil
        while S.Gui and S.Gui.Parent do
            task.wait(5)
            if S.AutoSaveCfg then
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

    -- ---------- Current server ----------
    local secCur = mkSection(Pages.Servers, "Current Server", 1)
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
        TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = UDim2.fromOffset(Main.AbsoluteSize.X, 42)
        }):Play()
    else
        TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
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
    TweenService:Create(Main, TweenInfo.new(0.2), { Size = UDim2.fromOffset(0, 0) }):Play()
    task.wait(0.22)
    S:Destroy()
end)
tc(UIS.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == Enum.KeyCode.LeftControl then
        Main.Visible = not Main.Visible
    end
end))
createHighlight = function(adornee, color, name)
    local hl = Instance.new("Highlight")
    hl.Name = name
    hl.Adornee = adornee
    hl.FillColor = color
    hl.FillTransparency = 1 - (S.ChamsOpacity or 50) / 100
    hl.OutlineColor = color
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = adornee
    return hl
end
task.spawn(function()
    local notified = false
    local _roleRemote  -- cache the remote so we don't recursively search ReplicatedStorage every poll
    while S.Gui and S.Gui.Parent do
        local now = tick()
        if now - LastRemoteFetch >= 0.3 then
            LastRemoteFetch = now
            if not (_roleRemote and _roleRemote.Parent) then
                _roleRemote = game:GetService("ReplicatedStorage"):FindFirstChild("GetPlayerData", true)
            end
            local rem = _roleRemote
            if rem then
                local ok, data = pcall(function() return rem:InvokeServer() end)
                if ok and type(data) == "table" then
                    local fm, fs, hasRole, anyHero = nil, nil, false, false
                    for pn, pd in pairs(data) do
                        if type(pd) == "table" and pd.Role then
                            RoleCache[pn] = pd.Role
                            if pd.Role == "Murderer" then fm = pn; hasRole = true end
                            if pd.Role == "Sheriff" then fs = pn; hasRole = true end
                            if pd.Role == "Hero" then hasRole = true; anyHero = true end
                        end
                    end
                    HeroPresent = anyHero
                    if hasRole then LastRoundHadRoles = true end
                    if not hasRole and LastRoundHadRoles then
                        LastRoundHadRoles = false
                        OriginalSheriff = nil
                        Heroes = {}
                        RoleCache = {}
                        HeroPresent = false
                        notified = false
                        VelocityHistory = {}
                    end
                    if fm and not notified then
                        notified = true
                        -- Two lines (title = murderer, body = sheriff) so neither name is truncated:
                        -- the old single "Murder: X | Sheriff: Y" line overflowed the toast width and
                        -- cut the Sheriff name off to "...".
                        Notify("Murderer: "..fm, "Sheriff: "..(fs or "?"), 5)
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)
getRole = function(player)
    local cached = RoleCache[player.Name]
    if cached == "Murderer" then return "Murderer" end
    local c, bp = player.Character, player:FindFirstChild("Backpack")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    local alive = hum and hum.Health > 0
    local hk = (c and (c:FindFirstChild("Knife") or c:FindFirstChild("KnifeServer"))) or (bp and (bp:FindFirstChild("Knife") or bp:FindFirstChild("KnifeServer")))
    if hk then return "Murderer" end
    if alive then
        if cached == "Sheriff" and not HeroPresent then OriginalSheriff = player; return "Sheriff" end
        local hg = (c and (c:FindFirstChild("Gun") or c:FindFirstChild("Revolver"))) or (bp and (bp:FindFirstChild("Gun") or bp:FindFirstChild("Revolver")))
        if hg then
            if cached == "Hero" then return "Hero" end
            if HeroPresent then return "Hero" end
            if not OriginalSheriff or not OriginalSheriff.Parent then OriginalSheriff = player end
            return (OriginalSheriff == player) and "Sheriff" or "Hero"
        end
    end
    return "Innocent"
end

tc(workspace.ChildAdded:Connect(function(ch)
    if ch.Name == "GunDrop" then
        if S.GunNotify then Notify("Gun Dropped", "Sheriff killed, gun on floor", 5) end
        if S.AutoGrabGun then grabGun() end
    end
end))
task.spawn(function()
    -- Knife Aura: any alive player within range of a knife auto-dies. The knife source can be
    -- the one held in hand (range measured from you) OR a knife you threw that is now flying in
    -- the workspace (range measured from the thrown knife itself). Works by opening the held
    -- knife's stab window (Activate) and firing each knife handle's TouchInterest against every
    -- in-range target body part so the server registers the hit.
    while S.Gui and S.Gui.Parent do
        if S.KnifeAura then
            pcall(function()
                local c = LP.Character
                local myHrp = c and c:FindFirstChild("HumanoidRootPart")
                local range = S.KnifeAuraRange or 15

                -- Collect knives we can hit with. The HELD knife also carries its Events.HandleTouched
                -- remote — the SAME reliable server-side kill that Kill All uses. Thrown knives don't
                -- have it, so they fall back to firetouchinterest.
                local sources = {}
                local heldKnife = c and c:FindFirstChild("Knife")
                if heldKnife and myHrp then
                    local handle = heldKnife:FindFirstChild("Handle")
                    local events = heldKnife:FindFirstChild("Events")
                    local ht = events and events:FindFirstChild("HandleTouched")
                    table.insert(sources, { handle = handle, origin = myHrp.Position, tool = heldKnife, remote = ht })
                end
                -- Thrown / dropped knives live as direct children of the workspace.
                for _, v in ipairs(workspace:GetChildren()) do
                    if v ~= c and (v.Name == "Knife" or v.Name == "NormalKnife" or v.Name == "ThrowingKnife") then
                        local h = v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart")
                        if h then
                            table.insert(sources, { handle = h, origin = h.Position, tool = nil })
                        end
                    end
                end
                if #sources == 0 then return end

                for _, src in ipairs(sources) do
                    local victims = {}
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LP and p.Character then
                            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                            local hum = p.Character:FindFirstChildOfClass("Humanoid")
                            if hrp and hum and hum.Health > 0 and (src.origin - hrp.Position).Magnitude <= range then
                                table.insert(victims, p.Character)
                            end
                        end
                    end
                    if #victims > 0 then
                        if src.tool then pcall(function() src.tool:Activate() end) end
                        for _, char in ipairs(victims) do
                            local vhrp = char:FindFirstChild("HumanoidRootPart")
                            if src.remote and vhrp then
                                -- Reliable MM2 kill: fire the knife's HandleTouched remote at the victim's HRP.
                                pcall(function() src.remote:FireServer(vhrp) end)
                            elseif firetouchinterest and src.handle then
                                -- Fallback (thrown knife, or no remote): simulate a touch on each body part.
                                for _, partName in ipairs(bodyParts) do
                                    local pt = char:FindFirstChild(partName)
                                    if pt then
                                        pcall(function()
                                            firetouchinterest(src.handle, pt, 0)
                                            firetouchinterest(src.handle, pt, 1)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.12)
    end
end)
local _antivoidBaseHeight = workspace.FallenPartsDestroyHeight
-- Anti-Fling (Infinite Yield method): disable collision for all players' character parts
-- on Stepped to prevent you from being flung by anyone.
local antiFlingConn = nil
task.spawn(function()
    while S.Gui and S.Gui.Parent do
        if S.AntiFling then
            if not antiFlingConn then
                antiFlingConn = RunService.Stepped:Connect(function()
                    pcall(function()
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LP and player.Character then
                                -- PERF: body parts (the ones that fling you) are DIRECT children;
                                -- GetChildren avoids walking accessory handles/decals every frame.
                                for _, v in pairs(player.Character:GetChildren()) do
                                    if v:IsA("BasePart") then
                                        v.CanCollide = false
                                    end
                                end
                            end
                        end
                    end)
                end)
            end
        else
            if antiFlingConn then
                antiFlingConn:Disconnect()
                antiFlingConn = nil
            end
        end
        task.wait(0.1)
    end
    if antiFlingConn then
        antiFlingConn:Disconnect()
        antiFlingConn = nil
    end
end)
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
        -- Anti-Fling runs in its own throttled loop (defined above the connection) so it never
        -- does per-frame work here.
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
                if hrp.Position.Y <= _antivoidBaseHeight + 50 then
                    hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 250, hrp.AssemblyLinearVelocity.Z)
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

        -- PERF: skip this whole per-player loop (it calls getRole for EVERYONE every frame) unless at
        -- least one cham / wall-detect toggle is on. When they all turn off we run ONE final pass to
        -- clean up leftover highlights, then stop — a big CPU saving in the common (chams-off) case.
        local anyCham = S.MurderChams or S.SheriffChams or S.HeroChams or S.InnocentChams or S.GunHeldChams
        if anyCham or S._chamsWereOn then
        -- PERF: chams don't need a per-frame refresh. Throttling to ~12x/sec means we're not running
        -- getRole for EVERY player on EVERY frame — that per-frame role scan is the main CPU spike when
        -- roles are handed out (which is exactly when the freeze happens). No visible difference.
        if tick() - (S._chamsAt or 0) >= 0.08 then
        S._chamsAt = tick()
        S._chamsWereOn = anyCham
        for _, pl in pairs(Players:GetPlayers()) do if pl ~= LP and pl.Character then
            local ch = pl.Character; local role = getRole(pl)
            if role ~= "Murderer" then local x = ch:FindFirstChild("MurdChams"); if x then x:Destroy() end end
            if role ~= "Sheriff" then local x = ch:FindFirstChild("SherChams"); if x then x:Destroy() end end
            if role ~= "Hero" then local x = ch:FindFirstChild("HeroChams"); if x then x:Destroy() end end
            if role ~= "Innocent" then local x = ch:FindFirstChild("InnoChams"); if x then x:Destroy() end end
            if role == "Murderer" then
                if S.MurderChams then if not ch:FindFirstChild("MurdChams") then createHighlight(ch, Color3.fromRGB(255,0,0), "MurdChams") end
                else local x = ch:FindFirstChild("MurdChams"); if x then x:Destroy() end end
            elseif role == "Sheriff" then
                if S.SheriffChams then if not ch:FindFirstChild("SherChams") then createHighlight(ch, Color3.fromRGB(0,100,255), "SherChams") end
                else local x = ch:FindFirstChild("SherChams"); if x then x:Destroy() end end
            elseif role == "Hero" then
                if S.HeroChams then if not ch:FindFirstChild("HeroChams") then createHighlight(ch, Color3.fromRGB(255,255,0), "HeroChams") end
                else local x = ch:FindFirstChild("HeroChams"); if x then x:Destroy() end end
            else
                if S.InnocentChams then if not ch:FindFirstChild("InnoChams") then createHighlight(ch, Color3.fromRGB(0,255,0), "InnoChams") end
                else local x = ch:FindFirstChild("InnoChams"); if x then x:Destroy() end end
            end
            -- Gun chams: highlight the held Gun/Revolver so the pistol shows through walls. A Highlight
            -- only adorns a Model/BasePart, so we target the tool's Handle (or its first BasePart).
            local gunTool = ch:FindFirstChild("Gun") or ch:FindFirstChild("Revolver")
            local gunPart = gunTool and (gunTool:FindFirstChild("Handle") or gunTool:FindFirstChildWhichIsA("BasePart"))
            if gunPart then
                if S.GunHeldChams then
                    if not gunPart:FindFirstChild("GunHeldChams") then createHighlight(gunPart, Color3.fromRGB(255,128,0), "GunHeldChams") end
                else
                    local x = gunPart:FindFirstChild("GunHeldChams"); if x then x:Destroy() end
                end
            end
            -- Live-apply Chams Opacity to highlights that already exist, so the slider takes effect
            -- immediately instead of only on the next role change.
            for _, x in ipairs(ch:GetChildren()) do
                if x:IsA("Highlight") and string.find(x.Name, "Chams", 1, true) then
                    x.FillTransparency = 1 - (S.ChamsOpacity or 50) / 100
                end
            end
        end end
        end -- close the ~12x/sec throttle
        end -- close the "anyCham or S._chamsWereOn" gate
        -- PERF: throttle the GunDrop lookup to avoid recursive workspace scans every single frame.
        if S.AutoGrabGun or S.GunChams or S.GunHeldChams then
            local now = tick()
            if now - (S._lastGunDropScan or 0) >= 0.25 then
                S._lastGunDropScan = now
                local gd = workspace:FindFirstChild("GunDrop")
                if not gd then
                    gd = workspace:FindFirstChild("GunDrop", true)
                end
                S._cachedGunDrop = gd
            end
            local gd = S._cachedGunDrop
            if gd and gd.Parent then
                if S.AutoGrabGun then
                    local n = tick()
                    if not S.LastGrab or n - S.LastGrab > 1 then
                        S.LastGrab = n
                        grabGun()
                    end
                end
                if S.GunChams or S.GunHeldChams then
                    createCham(gd, Color3.fromRGB(255, 128, 0), "GunDropChams")
                else
                    removeCham(gd, "GunDropChams")
                end
            else
                if S._hadGunDrop then
                    S._hadGunDrop = false
                    removeCham(gd, "GunDropChams")
                end
            end
            if gd and gd.Parent then
                S._hadGunDrop = true
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
        local c = LP.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if hum and hum.PlatformStand then
            hum.PlatformStand = false
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
    Hero     = Color3.fromRGB(255, 230, 60),
    Innocent = Color3.fromRGB(90, 220, 120),
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
            local show = espOn and cam and hrp and head and hum and hum.Health > 0
            local dist = 0
            if show then
                local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                dist = myHrp and (myHrp.Position - hrp.Position).Magnitude or 0
                if dist > (S.ESPMaxDist or 1000) then show = false end
            end
            if show then
                local role = "Innocent"
                role = getRole(plr)
                local col = RoleColorOf[role] or Color3.fromRGB(235, 235, 235)
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
                if S.HealthBarESP and onScreen then
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
                if S.NameESP then table.insert(lines, plr.Name) end
                if S.RoleESP then table.insert(lines, role) end
                if S.HealthESP then table.insert(lines, "HP " .. math.floor(hum.Health)) end
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
                pcall(function() LP:LoadCharacter() end)
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
    local spinY, wasFrozen = 0, false
    while S.Gui and S.Gui.Parent do
        local c = LP.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if hrp then
            if S.Spinbot then
                spinY = (spinY + (S.SpinSpeed or 20)) % 360
                pcall(function() hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(spinY), 0) end)
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
        if S.Bhop or S.SpeedGlitch then
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
    if S.ClickFling and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mouse = LP:GetMouse()
        local target = mouse and mouse.Target
        if target then
            local parent = target.Parent
            local p
            while parent and parent ~= workspace do
                p = Players:GetPlayerFromCharacter(parent)
                if p then break end
                parent = parent.Parent
            end
            if p and p ~= LP and not isWhitelisted(p) then
                local th = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                if th and th.Health > 0 then
                    Notify("Click Fling", "Flinging " .. p.Name, 2)
                    task.spawn(function() pcall(skidFling, p) end)
                end
            end
        end
    end
end))
-- ============ HUD STATS (ping / coords / time / players) ============
local scriptStart = os.time()
task.spawn(function()
    local Stats = game:FindService("Stats")
    while S.Gui and S.Gui.Parent do
        pcall(function()
            if S.HUD_Ping then
                local ping = 0
                pcall(function() ping = math.floor(LP:GetNetworkPing() * 1000) end)
                if ping == 0 and Stats then
                    pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                end
                HUD.pingLbl.Text = ping .. " ms"
            end
            if S.HUD_Coords then
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local p = hrp.Position
                    HUD.coordLbl.Text = string.format("X  %d\nY  %d\nZ  %d", p.X, p.Y, p.Z)
                end
            end
            if S.HUD_Time then HUD.timeLbl.Text = os.date("%H:%M:%S") end
            if S.HUD_Players then
                HUD.playersLbl.Text = #Players:GetPlayers() .. " / " .. Players.MaxPlayers .. " players"
            end
            if S.HUD_Watermark then
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
            if S.HUD_Speed then
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local sp = 0
                if hrp then local v = hrp.AssemblyLinearVelocity; sp = math.floor(Vector3.new(v.X, 0, v.Z).Magnitude) end
                HUD.speedLbl.Text = sp .. " sps"
            end
            if S.HUD_Session then
                local el = os.time() - scriptStart
                HUD.sessionLbl.Text = string.format("%02d:%02d:%02d", math.floor(el/3600), math.floor((el%3600)/60), el%60)
            end
        end)
        task.wait(0.25)
    end
end)


-- Draws a small state glyph out of rotated bars (NO emoji): a green check when a bound toggle is ON,
-- a red X when it's OFF. Used in the Keybinds HUD.
local function drawStateIcon(parent, on, z)
    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.Size = UDim2.fromOffset(14, 14)
    box.ZIndex = z
    box.Parent = parent
    local col = on and Color3.fromRGB(85, 220, 120) or Color3.fromRGB(235, 85, 85)
    local function seg(len, rot, ox, oy)
        local s = Instance.new("Frame")
        s.AnchorPoint = Vector2.new(0.5, 0.5)
        s.Position = UDim2.new(0.5, ox, 0.5, oy)
        s.Size = UDim2.fromOffset(2, len)
        s.BackgroundColor3 = col
        s.BorderSizePixel = 0
        s.Rotation = rot
        s.ZIndex = z
        Corner(s, 1)
        s.Parent = box
    end
    if on then
        seg(7, -26, -3, 0)   -- short arm: upper-left down to the vertex
        seg(11, 45, 2, -1)   -- long arm: vertex up to the upper-right
    else
        seg(13, 45, 0, 0)    -- two crossing diagonals form the X
        seg(13, -45, 0, 0)
    end
    return box
end
task.spawn(function() while S.Gui and S.Gui.Parent do
    if S.HUD_Roles and HUD.hRoles.content and HUD.hRoles.content.Parent then
        for _, ch in pairs(HUD.hRoles.content:GetChildren()) do if ch:IsA("TextLabel") then ch:Destroy() end end
        local TS = game:GetService("TextService")
        local o, maxW = 0, 0
        for _, p in pairs(Players:GetPlayers()) do o = o + 1; local r = getRole(p)
            local l = Instance.new("TextLabel"); l.Name = p.Name; l.LayoutOrder = o; l.BackgroundTransparency = 1
            l.Size = UDim2.new(1,0,0,20); l.Font = (r == "Murderer") and FM or F; l.TextSize = 15
            l.TextColor3 = RoleShade[r] or T.Tx3
            l.TextXAlignment = Enum.TextXAlignment.Left; l.Text = p.Name.."  -  "..r; l.ZIndex = 851
            l.TextTruncate = Enum.TextTruncate.AtEnd; l.Parent = HUD.hRoles.content
            -- Measure the full (untruncated) line so we can size the panel to fit it.
            local ok, sz = pcall(function() return TS:GetTextSize(l.Text, l.TextSize, l.Font, Vector2.new(9999, 100)) end)
            if ok and sz.X > maxW then maxW = sz.X end
        end
        -- Auto-fit width to the widest "name  -  role" line so nothing gets cut to "...".
        -- +28 covers the content inset (~18px) plus a little right margin; clamped 260..560.
        local newW = math.clamp(math.ceil(maxW) + 28, 260, 560)
        HUD.hRoles.frame.Size = UDim2.new(0, newW, 0, 32 + (o * 22))
    end
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

    TweenService:Create(L, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
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
            TweenService:Create(lbf, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
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
                TweenService:Create(o, TweenInfo.new(0.25), { TextTransparency = 1 }):Play()
            elseif o:IsA("Frame") then
                TweenService:Create(o, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
            elseif o:IsA("UIStroke") then
                TweenService:Create(o, TweenInfo.new(0.25), { Transparency = 1 }):Play()
            end
        end
        TweenService:Create(L, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(0, 0),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.38)
        L:Destroy()
        Main.Visible = true
        local fw, fh = expandedSize.X.Offset, expandedSize.Y.Offset
        Main.Size = UDim2.fromOffset(math.floor(fw*0.80), math.floor(fh*0.80))
        TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
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
            TweenService:Create(card, ti, { BackgroundTransparency = 0.08 }):Play()
            if st then TweenService:Create(st, ti, { Transparency = 0.5 }):Play() end
            TweenService:Create(bar, ti, { BackgroundTransparency = 0 }):Play()
            TweenService:Create(nameL, ti, { TextTransparency = 0 }):Play()
            TweenService:Create(tagL, ti, { TextTransparency = 0.05 }):Play()
        end)
        -- Hold, then fade + collapse (height -> 0 so the stack closes the gap smoothly)
        task.spawn(function()
            task.wait(4.5)
            local to = TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            pcall(function()
                TweenService:Create(card, to, { BackgroundTransparency = 1, Size = UDim2.new(0, cardW, 0, 0) }):Play()
                if st then TweenService:Create(st, to, { Transparency = 1 }):Play() end
                TweenService:Create(bar, to, { BackgroundTransparency = 1 }):Play()
                TweenService:Create(nameL, to, { TextTransparency = 1 }):Play()
                TweenService:Create(tagL, to, { TextTransparency = 1 }):Play()
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
            -- Small sidestep: just enough to pull the hitbox off the knife's line, not a big obvious warp.
            hrp.CFrame = hrp.CFrame + escapeDir * 6
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
print("[Inertia]: Loaded.")
