if _G.MM2_Visuals_Script then
    pcall(function() _G.MM2_Visuals_Script:Destroy() end)
    _G.MM2_Visuals_Script = nil
end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local LP = Players.LocalPlayer
local S = {
    Connections = {}, Gui = nil, OriginalTransparencies = {},
    VoidPlatform = nil, LastGrab = 0,
    CustomWalkSpeed = 16, CustomJumpPower = 50,
    MurderChams = false, SheriffChams = false, HeroChams = false,
    InnocentChams = false, GunChams = false, GunNotify = false, KnifeChams = false,
    WallDetectChams = false,
    AutoGrabGun = false, XrayOn = false, CamClip = false, NoCamLimit = false,
    AntiFling = false, AntiVoid = false, NoClip = false, AntiRagdoll = false,
    Fly = false, FlySpeed = 50, TouchFling = false,
    KnifeAura = false, KnifeAuraRange = 15,
    KillMurder = false, PiercingBullet = false, ActiveShader = "None", rtxLowToggle = false, rtxMedToggle = false, rtxHighToggle = false, nightToggle = false, pinkToggle = false,
    HUD_Roles = false, HUD_Keybinds = false, HUD_GunStatus = false, HUD_FPS = false,
    HUD_Ping = false, HUD_Coords = false, HUD_Time = false, HUD_Players = false,
    NameESP = false, DistanceESP = false, RoleESP = false, HealthESP = false,
    BoxESP = false, BoxFillESP = false, HealthBarESP = false, TracerESP = false, ESPMaxDist = 1000,
    ChamsAll = false, HeadDot = false, TracerOrigin = "Bottom",
    ChamsOpacity = 50, ChamsVisibleCheck = false,
    FullBright = false, NoFog = false, ForceDay = false, ForceNight = false, NoShadows = false, Brightness = 2,
    Saturation = 0, Contrast = 0, CamFOV = 70,
    SkyEnabled = false, SkyPreset = "Day", SkyTint = "Preset", SkyRainbow = false,
    FogEnabled = false, FogColorName = "Gray", FogStart = 0, FogEnd = 500, FogRainbow = false,
    FogMode = "Classic", FogDensity = 40,
    HandShader = false, HandShaderType = "Both", HandTarget = "Full Body", HandColor = "Cyan", HandRainbow = false, HandFill = 60,
    Crosshair = false,
    FOVEnabled = false, ShowFOV = false, RainbowFOV = false,
    FOVThickness = 2, FOVColor = "White", FOVRadius = 360,
    HitboxExpand = false, HitboxTarget = "Murderer", HitboxSize = 10,
    HUD_Watermark = false, HUD_Speed = false, HUD_Session = false,
    AutoRespawn = false, WalkOnWater = false, AutoSprint = false, AntiLag = false,
    InfiniteJump = false, Spinbot = false, SpinSpeed = 20, AntiAFK = false, Freeze = false,
    Bhop = false, BhopMax = 28, SpeedGlitch = false, AirSpeed = 50,
    ClickTP = false,
    AutoSaveCfg = true,
    WalkFling = false,
    Swim = false, WallTP = false, HeadSit = false,
    Orbit = false, OrbitSpeed = 20, OrbitDist = 6, OrbitHeight = 0,
    Bang = false, BangSpeed = 3, Jerk = false,
    InvisibleFE = false, FreeCam = false,
    CoinESP = false, AutoCoins = false, FastAutofarm = false, FastAutofarmSpeed = 60,
    FollowPlayer = false, FollowPlayerDistance = 4, FollowPlayerMode = "Follow", FollowPlayerSpeed = 60, FollowPlayerOrbitSpeed = 20,
    CustomTime = false, TimeOfDay = 14, Gravity = 196, MoonGravity = false, DisableBlur = false,
    FakeLag = false, FakeLagLimit = 15,
    AutoShootMurder = false, TriggerBot = false, BlinkDist = 20,
    CrosshairShape = "Cross", CrosshairColor = "Cyan", CrosshairSize = 12, CrosshairThickness = 2, CrosshairGap = 4, CrosshairRotation = 0, HideRealCursor = false,
    AutoEvade = false, AutoEvadeRange = 25, KillFeed = false, AutoGG = false, CustomGGText = "GG!", UseCustomGG = false,
    AutoDodgeKnife = false, AutoDodgeMode = "Teleport", AutoDodgeSpeed = 16,
    AimLock = false, AimLockTarget = "Nearest", SilentAim = false,
    AimLockHoldRMB = true, AimSmooth = 1, AimPrediction = 0,
}
_G.MM2_Visuals_Script = S
local createHighlight, getRole, rebuildCrosshair, moveTo, isRoundActive
local OriginalSheriff, Heroes, RoleCache = nil, {}, {}
local HeroPresent = false  -- true once a Hero exists this round; while true, nobody is a Sheriff
local LastRemoteFetch, LastRoundHadRoles = 0, false
local VelocityHistory = {}
function S:Destroy()
    pcall(function()
        LP.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
        LP.CameraMaxZoomDistance = 128
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
    for _, c in ipairs(self.Connections) do pcall(function() c:Disconnect() end) end
    if self.Gui then pcall(function() self.Gui:Destroy() end) end
end
local function tc(conn) table.insert(S.Connections, conn); return conn end
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
    s.Color = T.Bd2
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
        f.BackgroundColor3 = T.Tx2
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
SG.Name = "MM2"
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
    strip.BackgroundColor3 = T.White
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
    tt.TextColor3 = T.White
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
    bt.TextColor3 = T.Tx2
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
Main.BackgroundColor3 = T.BG
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
AccLine.BackgroundColor3 = T.White
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
TIcon.BackgroundColor3 = T.White
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
TTitle.Text = "MM2"
TTitle.TextColor3 = T.White
TTitle.TextSize = 16
TTitle.TextXAlignment = Enum.TextXAlignment.Left
local function mkWinBtn(txt, xOff)
    local b = Instance.new("TextButton")
    b.Parent = TBar
    b.AnchorPoint = Vector2.new(1, 0.5)
    b.Position = UDim2.new(1, xOff, 0.5, 0)
    b.Size = UDim2.new(0, 26, 0, 22)
    b.BackgroundColor3 = T.Elev
    b.BorderSizePixel = 0
    b.Font = FB
    b.TextSize = 13
    b.Text = txt
    b.TextColor3 = T.Tx2
    b.AutoButtonColor = false
    Corner(b, 6)
    Stroke(b, T.Bd, 1, 0.4)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), { BackgroundColor3 = T.Hover })
        b.TextColor3 = T.White
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), { BackgroundColor3 = T.Elev })
        b.TextColor3 = T.Tx2
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
local SearchQuery = ""
local function applySearch()
    local q = string.lower(SearchQuery)
    local cardVis = {}
    for _, e in ipairs(UIRegistry) do
        if e.row and e.row.Parent then
            local vis = (q == "") or (string.find(string.lower(e.label), q, 1, true) ~= nil)
            e.row.Visible = vis
            if vis and e.card then cardVis[e.card] = true end
        end
    end
    for _, e in ipairs(UIRegistry) do
        if e.card and e.card.Parent then
            e.card.Visible = (q == "") or (cardVis[e.card] == true)
        end
    end
    if q == "" then
        for _, pg in pairs(Pages) do
            pg.Visible = (pg == activePage)
        end
    else
        for _, pg in pairs(Pages) do
            local hasVis = false
            for _, c in ipairs(pg:GetChildren()) do
                if c:IsA("Frame") and c.Visible then
                    hasVis = true
                    break
                end
            end
            pg.Visible = hasVis
        end
    end
end
local SearchBox = Instance.new("TextBox")
SearchBox.Parent = TBar
SearchBox.AnchorPoint = Vector2.new(1, 0.5)
SearchBox.Position = UDim2.new(1, -76, 0.5, 0)
SearchBox.Size = UDim2.new(0, 150, 0, 22)
SearchBox.BackgroundColor3 = T.Elev
SearchBox.BorderSizePixel = 0
SearchBox.Font = F
SearchBox.TextSize = 12
SearchBox.TextColor3 = T.Tx
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
SB.BackgroundColor3 = T.Sidebar
SB.BorderSizePixel = 0
SB.Position = UDim2.new(0, 0, 0, 41)
SB.Size = UDim2.new(0, 140, 1, -67)
SB.CanvasSize = UDim2.new(0, 0, 0, 0)
SB.AutomaticCanvasSize = Enum.AutomaticSize.Y
SB.ScrollBarThickness = 2
SB.ScrollBarImageColor3 = T.Tx3
SB.ScrollBarImageTransparency = 0.5
local SBLine = Instance.new("Frame")
SBLine.Parent = Main
SBLine.BackgroundColor3 = T.Bd
SBLine.BackgroundTransparency = 0.3
SBLine.BorderSizePixel = 0
SBLine.Position = UDim2.new(0, 140, 0, 48)
SBLine.Size = UDim2.new(0, 1, 1, -82)
local SBLayout = Instance.new("UIListLayout")
SBLayout.Parent = SB
SBLayout.SortOrder = Enum.SortOrder.LayoutOrder
SBLayout.Padding = UDim.new(0, 4)
Pad(SB, 12, 12, 8, 8)
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
ContentArea.ScrollBarImageColor3 = T.Tx3
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
sbTop.BackgroundColor3 = T.Bd
sbTop.BackgroundTransparency = 0.3
sbTop.Size = UDim2.new(1, 0, 0, 1)
local StatusRole = Instance.new("TextLabel")
StatusRole.Parent = StatusBar
StatusRole.BackgroundTransparency = 1
StatusRole.Position = UDim2.new(0, 16, 0, 0)
StatusRole.Size = UDim2.new(0, 150, 1, 0)
StatusRole.Font = FM
StatusRole.TextSize = 12
StatusRole.TextColor3 = T.Tx2
StatusRole.TextXAlignment = Enum.TextXAlignment.Left
StatusRole.Text = "ROLE  ..."
local StatusFPS = Instance.new("TextLabel")
StatusFPS.Parent = StatusBar
StatusFPS.BackgroundTransparency = 1
StatusFPS.Position = UDim2.new(0, 180, 0, 0)
StatusFPS.Size = UDim2.new(0, 80, 1, 0)
StatusFPS.Font = FM
StatusFPS.TextSize = 12
StatusFPS.TextColor3 = T.Tx
StatusFPS.TextXAlignment = Enum.TextXAlignment.Left
StatusFPS.Text = "FPS  0"
local StatusPing = Instance.new("TextLabel")
StatusPing.Parent = StatusBar
StatusPing.BackgroundTransparency = 1
StatusPing.Position = UDim2.new(0, 270, 0, 0)
StatusPing.Size = UDim2.new(0, 90, 1, 0)
StatusPing.Font = FM
StatusPing.TextSize = 12
StatusPing.TextColor3 = T.Tx3
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
StatusHint.TextColor3 = T.Tx4
StatusHint.TextXAlignment = Enum.TextXAlignment.Right
StatusHint.Text = "LCtrl = menu  |  RMB = bind"
local fpsCount, lastFpsT, curFPS = 0, tick(), 0
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
    Pages[name] = sf
    return sf
end
local PVisuals  = mkPage("Visuals")
local PCombat   = mkPage("Combat")
local PMisc     = mkPage("Misc")
local PFun      = mkPage("Fun")
local PTargets  = mkPage("Targets")
local PTeleport = mkPage("Teleport")
local PHUD      = mkPage("HUD")
local PShaders  = mkPage("Shaders")
local PWorld    = mkPage("World")
local PAutofarm = mkPage("Autofarm")
local PServers  = mkPage("Servers")
local PConfig   = mkPage("Config")
PVisuals.Visible = true
local SBItems = {}
activePage = PVisuals
local function refreshSB()
    for _, item in ipairs(SBItems) do
        local on = (item.page == activePage)
        item.bar.Visible = on
        item.icon.setColor(on and T.White or T.Tx3)
        item.label.TextColor3 = on and T.White or T.Tx2
        item.label.Font = on and FM or F
        item.btn.BackgroundColor3 = T.Elev
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
    bar.BackgroundColor3 = T.White
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
    label.TextColor3 = T.Tx2
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = name
    btn.MouseButton1Click:Connect(function()
        SFX.Click()
        if SearchBox and SearchBox.Text ~= "" then
            SearchBox.Text = ""
        end
        for _, pg in pairs(Pages) do
            pg.Visible = (pg == page)
        end
        activePage = page
        refreshSB()
    end)
    btn.MouseEnter:Connect(function()
        if page ~= activePage then
            btn.BackgroundTransparency = 0.35
            btn.BackgroundColor3 = T.Elev
        end
    end)
    btn.MouseLeave:Connect(function()
        refreshSB()
    end)
    table.insert(SBItems, { btn = btn, bar = bar, icon = icon, label = label, page = page })
end
mkSBItem("Visuals", "eye", PVisuals, 1)
mkSBItem("Shaders", "diamond", PShaders, 2)
mkSBItem("Combat", "cross", PCombat, 3)
mkSBItem("Targets", "shield", PTargets, 4)
mkSBItem("World", "grid", PWorld, 5)
mkSBItem("Autofarm", "diamond", PAutofarm, 6)
mkSBItem("Misc", "sliders", PMisc, 7)
mkSBItem("Fun", "diamond", PFun, 8)
mkSBItem("Teleport", "diamond", PTeleport, 9)
mkSBItem("Servers", "server", PServers, 10)
mkSBItem("HUD", "grid", PHUD, 11)
mkSBItem("Config", "sliders", PConfig, 12)
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
    if not processed and input.UserInputType == Enum.UserInputType.Keyboard then
        local e = BindReg[input.KeyCode]
        if e then e.trigger() end
    end
end))
local function mkSection(parent, title, order)
    local card = Instance.new("Frame")
    card.Name = title
    card.Parent = parent
    card.LayoutOrder = order
    card.BackgroundColor3 = T.Card
    card.BorderSizePixel = 0
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    Corner(card, 10)
    Stroke(card, T.Bd, 1, 0.3)
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
    tick.BackgroundColor3 = T.White
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
    hdr.TextColor3 = T.Tx3
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
    row.BackgroundColor3 = T.Hover
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
    lbl.TextColor3 = T.Tx2
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = label
    local badge = Instance.new("TextLabel")
    badge.Parent = row
    badge.BackgroundTransparency = 0
    badge.BackgroundColor3 = T.Elev
    badge.AnchorPoint = Vector2.new(1, 0.5)
    badge.Position = UDim2.new(1, -52, 0.5, 0)
    badge.Size = UDim2.new(0, 0, 0, 18)
    badge.Font = FM
    badge.TextSize = 11
    badge.TextColor3 = T.Tx2
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
    track.BackgroundColor3 = T.TgOff
    track.BorderSizePixel = 0
    track.Text = ""
    track.AutoButtonColor = false
    Corner(track, 10)
    local trackSt = Stroke(track, T.Bd2, 1, 0.6)
    local knob = Instance.new("Frame")
    knob.Parent = track
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = T.KnobOff
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
    btn.BackgroundColor3 = T.Elev
    btn.BorderSizePixel = 0
    btn.Font = FM
    btn.TextSize = 13
    btn.TextColor3 = T.Tx
    btn.Text = label
    Corner(btn, 7)
    local bst = Stroke(btn, T.Bd2, 1, 0.4)
    local entry = { label = label, cfgId = _cfgId(parent, label), bindKey = nil, oldKey = nil, isToggle = false }
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
    lbl.TextColor3 = T.Tx2
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
    vlbl.TextColor3 = T.White
    vlbl.TextXAlignment = Enum.TextXAlignment.Right
    local bar = Instance.new("Frame")
    bar.Parent = frame
    bar.AnchorPoint = Vector2.new(0.5, 0)
    bar.Position = UDim2.new(0.5, 0, 0, 24)
    bar.Size = UDim2.new(1, -12, 0, 5)
    bar.BackgroundColor3 = T.TgOff
    bar.BorderSizePixel = 0
    Corner(bar, 3)
    local fill = Instance.new("Frame")
    fill.Parent = bar
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = T.White
    fill.BorderSizePixel = 0
    Corner(fill, 3)
    local handle = Instance.new("Frame")
    handle.Parent = bar
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.Position = UDim2.new(0, 0, 0.5, 0)
    handle.Size = UDim2.new(0, 13, 0, 13)
    handle.BackgroundColor3 = T.White
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
    lbl.TextColor3 = T.Tx2
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = label
    local btn = Instance.new("TextButton")
    btn.Parent = row
    btn.AnchorPoint = Vector2.new(1, 0.5)
    btn.Position = UDim2.new(1, -6, 0.5, 0)
    btn.Size = UDim2.new(0, 120, 0, 22)
    btn.BackgroundColor3 = T.Elev
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Font = FM
    btn.TextSize = 12
    btn.TextColor3 = T.Tx
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
        local knife = c:FindFirstChild("Knife")
        if not knife then Notify("Error","Need Knife (Murderer)",3); return end
        local events = knife:FindFirstChild("Events")
        if not events then Notify("Error","Knife.Events not found",3); return end
        local HandleTouched = events:FindFirstChild("HandleTouched")
        if not HandleTouched then Notify("Error","HandleTouched not found",3); return end
        local cnt = 0
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character then
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
        if p ~= LP and p.Character and roleMatches(p, roleFilter) then
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
    local sec1 = mkSection(PVisuals, "Chams", 1)
    mkToggle(sec1, "Murderer", false, function(v) S.MurderChams = v end, 1)
    mkToggle(sec1, "Sheriff", false, function(v) S.SheriffChams = v end, 2)
    mkToggle(sec1, "Hero", false, function(v) S.HeroChams = v end, 3)
    mkToggle(sec1, "Innocent", false, function(v) S.InnocentChams = v end, 4)
    mkToggle(sec1, "Chams All", false, function(v) S.ChamsAll = v end, 5)
    mkSlider(sec1, "Chams Opacity", 0, 100, 50, function(v) S.ChamsOpacity = v end, 6)
    mkToggle(sec1, "Visible Only (no wallhack)", false, function(v) S.ChamsVisibleCheck = v end, 7)
    -- One toggle: everyone gets green where you can see them and dark-red where they're behind a
    -- wall, so you instantly read who's peeking / hidden.
    mkToggle(sec1, "Wall Detect", false, function(v) S.WallDetectChams = v end, 8)
    local sec2 = mkSection(PVisuals, "Player ESP", 2)
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
    local sec3 = mkSection(PVisuals, "Item ESP", 3)
    mkToggle(sec3, "Gun Drop ESP", false, function(v) S.GunChams = v end, 1)
    mkToggle(sec3, "Thrown Knife ESP", false, function(v) S.KnifeChams = v end, 2)
    local sec4 = mkSection(PVisuals, "World", 4)
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
    local secFx = mkSection(PVisuals, "Effects", 5)
    mkSlider(secFx, "Saturation", -100, 100, 0, function(v) S.Saturation = v end, 1)
    mkSlider(secFx, "Contrast", -100, 100, 0, function(v) S.Contrast = v end, 2)
    mkSlider(secFx, "Camera FOV", 40, 120, 70, function(v) S.CamFOV = v end, 3)
    local secCrosshair = mkSection(PVisuals, "Custom Crosshair", 6)
    mkToggle(secCrosshair, "Enable Crosshair", false, function(v) S.Crosshair = v; rebuildCrosshair() end, 1)
    mkToggle(secCrosshair, "Hide Real Cursor", false, function(v) S.HideRealCursor = v; rebuildCrosshair() end, 2)
    mkCycle(secCrosshair, "Crosshair Shape", {"Cross", "X", "Dot", "Circle", "Heart"}, "Cross", function(v) S.CrosshairShape = v; rebuildCrosshair() end, 3)
    mkCycle(secCrosshair, "Crosshair Color", {"Cyan", "Red", "Green", "Yellow", "Pink", "White", "Purple", "Orange", "Blue", "Rainbow"}, "Cyan", function(v) S.CrosshairColor = v; rebuildCrosshair() end, 4)
    mkSlider(secCrosshair, "Crosshair Size", 4, 50, 12, function(v) S.CrosshairSize = v; rebuildCrosshair() end, 5)
    mkSlider(secCrosshair, "Crosshair Thickness", 1, 8, 2, function(v) S.CrosshairThickness = v; rebuildCrosshair() end, 6)
    mkSlider(secCrosshair, "Crosshair Gap", 0, 20, 4, function(v) S.CrosshairGap = v; rebuildCrosshair() end, 7)
    mkSlider(secCrosshair, "Crosshair Rotation", 0, 360, 0, function(v) S.CrosshairRotation = v; rebuildCrosshair() end, 8)

    local secSky = mkSection(PVisuals, "Sky", 7)
    mkToggle(secSky, "Custom Sky", false, function(v) S.SkyEnabled = v end, 1)
    mkCycle(secSky, "Sky Preset", {"Day", "Sunset", "Night", "Aurora", "Space", "Blood", "Toxic", "Ocean", "Sakura", "Midnight", "Storm", "Desert"}, "Day", function(v) S.SkyPreset = v end, 2)
    mkCycle(secSky, "Sky Color", {"Preset", "Blue", "Purple", "Pink", "Cyan", "Orange", "Green", "Red", "White"}, "Preset", function(v) S.SkyTint = v end, 3)
    mkToggle(secSky, "Rainbow Sky", false, function(v) S.SkyRainbow = v end, 4)
    local secFog = mkSection(PVisuals, "Fog", 8)
    mkToggle(secFog, "Custom Fog", false, function(v) S.FogEnabled = v end, 1)
    -- Classic = sharp legacy fog (Start/End). Atmosphere = soft volumetric-style haze whose
    -- thickness comes from the Density slider (Start/End are ignored in that mode).
    mkCycle(secFog, "Fog Mode", {"Classic", "Atmosphere"}, "Classic", function(v) S.FogMode = v end, 2)
    mkCycle(secFog, "Fog Color", {"Gray", "White", "Black", "Blue", "Purple", "Pink", "Cyan", "Orange", "Green", "Red"}, "Gray", function(v) S.FogColorName = v end, 3)
    mkSlider(secFog, "Fog Start", 0, 2000, 0, function(v) S.FogStart = v end, 4)
    mkSlider(secFog, "Fog End", 50, 5000, 500, function(v) S.FogEnd = v end, 5)
    mkSlider(secFog, "Fog Density", 5, 95, 40, function(v) S.FogDensity = v end, 6)
    mkToggle(secFog, "Rainbow Fog", false, function(v) S.FogRainbow = v end, 7)
    local secFov = mkSection(PVisuals, "FOV", 9)
    mkToggle(secFov, "FOV Enabled", false, function(v) S.FOVEnabled = v end, 1)
    mkToggle(secFov, "Show FOV", false, function(v) S.ShowFOV = v end, 2)
    mkToggle(secFov, "Rainbow FOV", false, function(v) S.RainbowFOV = v end, 3)
    mkSlider(secFov, "FOV Radius", 30, 360, 360, function(v) S.FOVRadius = v end, 4)
    mkSlider(secFov, "FOV Thickness", 1, 8, 2, function(v) S.FOVThickness = v end, 5)
    mkCycle(secFov, "FOV Color", {"White", "Red", "Green", "Blue", "Yellow", "Cyan", "Purple", "Orange", "Pink", "Black"}, "White", function(v) S.FOVColor = v end, 6)

    local sec5 = mkSection(PVisuals, "Alerts", 10)
    mkToggle(sec5, "Gun Drop Notify", false, function(v) S.GunNotify = v end, 1)
end
do
    local sec1 = mkSection(PCombat, "Gun", 1)
    mkToggle(sec1, "Auto Grab Gun", false, function(v) S.AutoGrabGun = v end, 1)
    mkAction(sec1, "Grab Gun", function() grabGun() end, 2)
    local sec2 = mkSection(PCombat, "Murderer", 2)
    mkAction(sec2, "Kill All", function() killAll() end, 1)
    mkToggle(sec2, "Knife Aura", false, function(v) S.KnifeAura = v end, 3)
    mkSlider(sec2, "Aura Range", 5, 50, 15, function(v) S.KnifeAuraRange = v end, 4)
    local sec3 = mkSection(PCombat, "Sheriff", 3)
    mkToggle(sec3, "Piercing Bullet", false, function(v)
        S.PiercingBullet = v
        if v then
            task.spawn(function()
                pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/Lutosys/opensrc/refs/heads/main/mm2bulletTp"))()
                end)
            end)
        end
    end, 2)
    -- Auto Gun (formerly its own "Auto Gun (Sheriff)" section) folded into Sheriff. The toggles only
    -- flip S flags; the firing loops live in the auto-gun do-block below and read these flags.
    mkToggle(sec3, "Auto Shoot Murderer", false, function(v) S.AutoShootMurder = v end, 3)
    mkToggle(sec3, "Trigger Bot", false, function(v) S.TriggerBot = v end, 4)
    -- Normal aim lock: enable, then (by default) HOLD Right Mouse to snap the camera onto the target.
    mkToggle(sec3, "Aim Lock", false, function(v) S.AimLock = v end, 5)
    mkCycle(sec3, "Aim Lock Target", {"Nearest", "Murderer", "Sheriff"}, "Nearest", function(v) S.AimLockTarget = v end, 6)
    -- Hold RMB ON = lock only while right mouse is held; OFF = lock continuously while Aim Lock is on.
    mkToggle(sec3, "Aim Lock Hold RMB", true, function(v) S.AimLockHoldRMB = v end, 7)
    -- Smoothness 1 = instant snap; higher = the camera eases toward the target (Aim Lock only).
    mkSlider(sec3, "Aim Smoothness", 1, 30, 1, function(v) S.AimSmooth = v end, 8)
    -- Prediction leads a moving target by its velocity — helps both Aim Lock and Silent Aim. 0 = off.
    mkSlider(sec3, "Aim Prediction", 0, 50, 0, function(v) S.AimPrediction = v end, 9)
    -- Silent Aim: redirects the gun's bullet AND the murderer's thrown knife to the FOV target
    -- (uses the same "Aim Lock Target" pick). This is what actually lands shots/knives — a hitbox
    -- expander can't, because MM2 decides those hits from the position you SEND, not your hitboxes.
    mkToggle(sec3, "Silent Aim", false, function(v) S.SilentAim = v end, 10)
    local secDodge = mkSection(PCombat, "Knife Dodge", 5)
    mkToggle(secDodge, "Auto Dodge Knife", false, function(v) S.AutoDodgeKnife = v end, 1)
    mkCycle(secDodge, "Dodge Mode", {"Teleport", "Walk Away", "Jump"}, "Teleport", function(v) S.AutoDodgeMode = v end, 2)
    mkSlider(secDodge, "Dodge Speed", 16, 100, 16, function(v) S.AutoDodgeSpeed = v end, 3)

    local sec5 = mkSection(PCombat, "Fling", 6)
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
            if S.AutoShootMurder and equippedGun() then
                pcall(function() local h = murdererHRP(); if h then fireGunAt(h) end end)
            end
            task.wait(0.35)
        end
    end)
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
    -- (UI toggles for Auto Shoot Murderer / Trigger Bot now live in the "Sheriff" section above.)
end
do
    -- Normal aim lock: while the toggle is on, HOLD Right Mouse Button to snap the camera onto the
    -- selected target's head. It is FOV-based: among role-matched alive players it picks the one
    -- CLOSEST TO YOUR CROSSHAIR that is inside the FOV circle (S.FOVRadius px) — nothing outside the
    -- FOV is locked. Target mode filters who's eligible: Nearest (any role), Murderer, or Sheriff
    -- (incl. the Hero holding the gun). NOTE: Aim Lock / Silent Aim deliberately IGNORE the Targets
    -- tab pick (ManualTarget) — they always aim by FOV + mode, per request.
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
            if p ~= LP and p.Character then
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
    -- Both Aim Lock and Silent Aim share the same FOV target. We precompute the target position
    -- ONCE per frame here (memory rule: never do namecalls / heavy math inside the __namecall hook);
    -- silentPos is only set while a weapon is actually equipped so unrelated remotes are untouched.
    local silentPos, silentCF = nil, nil
    tc(RunService.RenderStepped:Connect(function()
        -- Hold RMB on -> lock only while right mouse is held; off -> lock whenever Aim Lock is on.
        local rmb = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        local locked = S.AimLock and (not S.AimLockHoldRMB or rmb)
        if not (locked or S.SilentAim) then silentPos, silentCF = nil, nil; return end
        pcall(function()
            local ch = aimTargetChar()
            if not ch then silentPos, silentCF = nil, nil; return end
            local head = ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
            if not head then silentPos, silentCF = nil, nil; return end
            -- Prediction: lead a moving target by its own velocity (seconds ≈ slider / 100).
            local thrp = ch:FindFirstChild("HumanoidRootPart")
            local tvel = (thrp and thrp.AssemblyLinearVelocity) or Vector3.new()
            local aimPos = head.Position + tvel * ((S.AimPrediction or 0) / 100)
            -- Aim Lock: move the camera toward the target, eased by Smoothness (1 = instant snap).
            if locked then
                local cam = workspace.CurrentCamera
                if cam then
                    local goal = CFrame.lookAt(cam.CFrame.Position, aimPos)
                    local sm = math.max(S.AimSmooth or 1, 1)
                    cam.CFrame = (sm <= 1) and goal or cam.CFrame:Lerp(goal, math.clamp(1 / sm, 0, 1))
                end
            end
            -- Silent Aim: stash the (predicted) target for the hook, only if a Gun/Revolver/Knife is out.
            if S.SilentAim then
                local c = LP.Character
                local muzzle = c and (c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart"))
                local weapon = c and (c:FindFirstChild("Gun") or c:FindFirstChild("Revolver") or c:FindFirstChild("Knife"))
                if muzzle and weapon then
                    silentPos = aimPos
                    silentCF = CFrame.lookAt(muzzle.Position, aimPos)
                else
                    silentPos, silentCF = nil, nil
                end
            else
                silentPos, silentCF = nil, nil
            end
        end)
    end))

    -- Silent Aim hook: rewrite the FIRST CFrame (else first Vector3) argument of the gun-shot /
    -- knife-throw remote to the target. MM2 reads that CFrame's POSITION as the hit point, so the
    -- bullet/knife lands on the target (and ignores walls). Rewriting ONLY one arg is deliberate —
    -- touching the extra args makes the server reject the shot. Executor-only (needs metamethod hook).
    if hookmetamethod and getnamecallmethod and checkcaller and not _G.MM2_SilentHook then
        _G.MM2_SilentHook = true
        local oldNC
        oldNC = hookmetamethod(game, "__namecall", function(self, ...)
            if S.SilentAim and silentPos and not checkcaller() then
                local ok, method = pcall(getnamecallmethod)
                if ok and (method == "FireServer" or method == "InvokeServer") then
                    local n = select("#", ...)
                    local args = { ... }
                    for i = 1, n do
                        if typeof(args[i]) == "CFrame" then
                            args[i] = silentCF or CFrame.new(silentPos)
                            return oldNC(self, table.unpack(args, 1, n))
                        end
                    end
                    for i = 1, n do
                        if typeof(args[i]) == "Vector3" then
                            args[i] = silentPos
                            return oldNC(self, table.unpack(args, 1, n))
                        end
                    end
                end
            end
            return oldNC(self, ...)
        end)
    end
end
do
    -- Hitbox Expander: enlarge the chosen role's HumanoidRootPart so shots/knives land far more
    -- easily. The HRP is kept invisible and non-collidable, and the original size is restored when
    -- you turn it off (or the target no longer matches).
    local sec = mkSection(PCombat, "Hitbox Expander", 9)
    mkToggle(sec, "Hitbox Expander", false, function(v) S.HitboxExpand = v end, 1)
    mkCycle(sec, "Hitbox Target", {"Murderer", "Sheriff", "All"}, "Murderer", function(v) S.HitboxTarget = v end, 2)
    mkSlider(sec, "Hitbox Size", 4, 30, 10, function(v) S.HitboxSize = v end, 3)

    task.spawn(function()
        local original = {}
        local function restoreAll()
            for hrp, sz in pairs(original) do
                if hrp and hrp.Parent then
                    pcall(function()
                        hrp.Size = sz
                        hrp.Massless = false
                    end)
                end
            end
            original = {}
        end
        
        local stepConn
        while S.Gui and S.Gui.Parent do
            if S.HitboxExpand then
                if not stepConn then
                    stepConn = RunService.Stepped:Connect(function()
                        for hrp, _ in pairs(original) do
                            if hrp and hrp.Parent then
                                hrp.CanCollide = false
                            end
                        end
                    end)
                end
                
                pcall(function()
                    local target = S.HitboxTarget or "Murderer"
                    local sz = S.HitboxSize or 10
                    local sv = Vector3.new(sz, sz, sz)
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LP and p.Character then
                            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local r = getRole(p)
                                local match = (target == "All")
                                    or (target == "Murderer" and r == "Murderer")
                                    or (target == "Sheriff" and (r == "Sheriff" or r == "Hero"))
                                if match then
                                    if not original[hrp] then original[hrp] = hrp.Size end
                                    if hrp.Size ~= sv then
                                        hrp.Size = sv
                                        hrp.Massless = true
                                    end
                                    hrp.Transparency = 1
                                    hrp.CanCollide = false
                                elseif original[hrp] then
                                    pcall(function()
                                        hrp.Size = original[hrp]
                                        hrp.Massless = false
                                    end)
                                    original[hrp] = nil
                                end
                            end
                        end
                    end
                end)
            elseif next(original) then
                restoreAll()
                if stepConn then
                    stepConn:Disconnect()
                    stepConn = nil
                end
            end
            task.wait(0.2)
        end
        restoreAll()
        if stepConn then stepConn:Disconnect() end
    end)
end
do
    local sec1 = mkSection(PMisc, "Player", 1)
    mkSlider(sec1, "WalkSpeed", 16, 100, 16, function(v) S.CustomWalkSpeed = v end, 1)
    mkSlider(sec1, "JumpPower", 50, 150, 50, function(v) S.CustomJumpPower = v end, 2)
    local sec2 = mkSection(PMisc, "Movement", 2)
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

    local sec3 = mkSection(PMisc, "Camera", 3)
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
        LP.CameraMaxZoomDistance = v and 100000 or 128
    end, 3)
    local sec4 = mkSection(PMisc, "Protection", 4)
    mkToggle(sec4, "Anti-Fling", false, function(v) S.AntiFling = v end, 1)
    mkToggle(sec4, "Anti-Void", false, function(v) S.AntiVoid = v end, 2)
    mkToggle(sec4, "Anti-AFK", false, function(v) S.AntiAFK = v end, 3)
    mkToggle(sec4, "Auto Respawn", false, function(v) S.AutoRespawn = v end, 4)
    mkToggle(sec4, "Anti Ragdoll", false, function(v) S.AntiRagdoll = v end, 5)
    local sec6 = mkSection(PMisc, "Performance", 5)
    mkToggle(sec6, "Anti Lag", false, function(v) S.AntiLag = v end, 1)

    -- ============ FOLLOW & ORBIT SECTION ============
    local secFollow = mkSection(PMisc, "Follow & Orbit", 6)
    
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
    lblF.TextColor3 = T.Tx4
    lblF.TextWrapped = true
    lblF.TextXAlignment = Enum.TextXAlignment.Left
    lblF.Text = "Target is picked in the Targets tab (Auto = nearest)."

    mkToggle(secFollow, "Enable Follow/Orbit", false, function(v)
        S.FollowPlayer = v
        if v and not S.ManualTarget then Notify("Follow", "No player picked in Targets tab - following nearest", 3) end
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
                        -- Target comes from the Targets tab list; Auto = nearest alive player.
                        local target = nil
                        if S.ManualTarget then
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p ~= LP and p.Name == S.ManualTarget then target = p; break end
                            end
                        else
                            local bestD
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p ~= LP and p.Character then
                                    local phrp = p.Character:FindFirstChild("HumanoidRootPart")
                                    local ph = p.Character:FindFirstChildOfClass("Humanoid")
                                    if phrp and ph and ph.Health > 0 then
                                        local d = (phrp.Position - hrp.Position).Magnitude
                                        if not bestD or d < bestD then bestD = d; target = p end
                                    end
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

    local sec5 = mkSection(PMisc, "Utility", 7)
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
    lbl.TextColor3 = T.Tx2
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = "Goto Player:"
    
    local box = Instance.new("TextBox")
    box.Parent = row
    box.Position = UDim2.new(0, 90, 0.5, -10)
    box.Size = UDim2.new(1, -150, 0, 20)
    box.BackgroundColor3 = T.Elev
    box.BorderSizePixel = 0
    box.Font = F
    box.TextSize = 12
    box.TextColor3 = T.Tx
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
    btn.BackgroundColor3 = T.Elev
    btn.BorderSizePixel = 0
    btn.Font = FM
    btn.TextSize = 12
    btn.TextColor3 = T.Tx
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

    local secSocial = mkSection(PMisc, "Social & HUD", 8)
    mkToggle(secSocial, "Custom Kill Feed", false, function(v) S.KillFeed = v end, 1)
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
    lblGG.TextColor3 = T.Tx2
    lblGG.TextXAlignment = Enum.TextXAlignment.Left
    lblGG.Text = "Custom GG Phrase:"
    
    local boxGG = Instance.new("TextBox")
    boxGG.Parent = rowGG
    boxGG.Position = UDim2.new(0, 120, 0.5, -10)
    boxGG.Size = UDim2.new(1, -126, 0, 20)
    boxGG.BackgroundColor3 = T.Elev
    boxGG.BorderSizePixel = 0
    boxGG.Font = F
    boxGG.TextSize = 12
    boxGG.TextColor3 = T.Tx
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
end
do
    local sec1 = mkSection(PTeleport, "Roles", 1)
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
    local sec2 = mkSection(PTeleport, "Location", 2)
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
    local sec3 = mkSection(PTeleport, "Players", 3)
    local pScroll = Instance.new("ScrollingFrame")
    pScroll.Name = "PList"
    pScroll.Parent = sec3
    pScroll.LayoutOrder = 1
    pScroll.BackgroundColor3 = T.Card
    pScroll.BorderSizePixel = 0
    pScroll.Size = UDim2.new(1, 0, 0, 130)
    pScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    pScroll.ScrollBarThickness = 3
    pScroll.ScrollBarImageColor3 = T.Tx3
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
            b.TextColor3 = T.Tx
            b.BackgroundColor3 = T.Elev
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
    local sec = mkSection(PTeleport, "Utility", 4)
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
    mkSlider(sec, "Blink Distance", 5, 100, 20, function(v) S.BlinkDist = v end, 3)
    mkAction(sec, "Blink Forward", function()
        local c = LP.Character; local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local cam = workspace.CurrentCamera
        if hrp and cam then
            hrp.CFrame = hrp.CFrame + cam.CFrame.LookVector * (S.BlinkDist or 20)
            Notify("Teleport", "Blinked", 1.5)
        end
    end, 4)
end
-- ============ TARGETS TAB (pick one player for Fun functions) ============
do
    local sec1 = mkSection(PTargets, "Manual Target", 1)
    local info = Instance.new("TextLabel")
    info.Parent = sec1
    info.LayoutOrder = 1
    info.BackgroundTransparency = 1
    info.Size = UDim2.new(1, 0, 0, 34)
    info.Font = F
    info.TextSize = 12
    info.TextColor3 = T.Tx4
    info.TextWrapped = true
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Text = "THE target selector: the player picked here is used by Fun (Orbit/Bang/Head Sit) and Follow/Orbit. (Aim Lock / Silent Aim ignore this and use their own FOV + target mode.)"
    local searchBox = Instance.new("TextBox")
    searchBox.Parent = sec1
    searchBox.LayoutOrder = 2
    searchBox.Size = UDim2.new(1, 0, 0, 30)
    searchBox.BackgroundColor3 = T.Elev
    searchBox.BorderSizePixel = 0
    searchBox.Font = F
    searchBox.TextSize = 13
    searchBox.TextColor3 = T.Tx
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
    tScroll.BackgroundColor3 = T.Card
    tScroll.BorderSizePixel = 0
    tScroll.Size = UDim2.new(1, 0, 0, 220)
    tScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tScroll.ScrollBarThickness = 3
    tScroll.ScrollBarImageColor3 = T.Tx3
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
            b.TextColor3 = T.Tx
            b.BackgroundColor3 = T.Elev
            b.Size = UDim2.new(1, 0, 0, 32)
            b.Text = "  " .. labelText
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.Parent = tScroll
            Corner(b, 6)
            local function isSelected() return S.ManualTarget == plrName end
            local function refreshVis()
                b.BackgroundColor3 = isSelected() and T.ActiveBg or T.Elev
                b.TextColor3 = isSelected() and T.White or T.Tx
            end
            refreshVis()
            b.MouseEnter:Connect(function()
                if not isSelected() then TweenService:Create(b, TweenInfo.new(0.1), { BackgroundColor3 = T.Hover }):Play() end
            end)
            b.MouseLeave:Connect(function() refreshVis() end)
            b.MouseButton1Click:Connect(function()
                SFX.Click()
                S.ManualTarget = plrName
                Notify("Target", plrName and ("Selected: " .. plrName) or "Auto (nearest)", 2)
                for _, r in ipairs(rowRefreshers) do r() end
            end)
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
        if S.ManualTarget == p.Name then S.ManualTarget = nil end
        task.wait(0.5); refreshTargets()
    end))
    table.insert(ConfigControls, {
        id = "Targets/Manual/ManualTarget",
        get = function() return S.ManualTarget end,
        set = function(v)
            S.ManualTarget = (type(v) == "string" and v ~= "") and v or nil
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
    if S.ManualTarget then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name == S.ManualTarget and p ~= LP and p.Character then
                local h = p.Character:FindFirstChildOfClass("Humanoid")
                if h and h.Health > 0 then return p end
            end
        end
        return nil -- a specific player was picked but isn't valid right now: don't guess
    end
    local myRoot = getRoot(LP.Character)
    if not myRoot then return nil end
    local best, bestD
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local r = getRoot(p.Character)
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if r and h and h.Health > 0 then
                local d = (r.Position - myRoot.Position).Magnitude
                if not bestD or d < bestD then bestD = d; best = p end
            end
        end
    end
    return best
end
-- Swim
local swimBeat, swimGrav
local function startSwim()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    swimGrav = workspace.Gravity
    workspace.Gravity = 0
    for _, v in pairs(Enum.HumanoidStateType:GetEnumItems()) do
        if v ~= Enum.HumanoidStateType.None then pcall(function() hum:SetStateEnabled(v, false) end) end
    end
    hum:ChangeState(Enum.HumanoidStateType.Swimming)
    swimBeat = RunService.Heartbeat:Connect(function()
        pcall(function()
            local root = getRoot(LP.Character)
            if root then
                root.Velocity = ((hum.MoveDirection ~= Vector3.new() or UIS:IsKeyDown(Enum.KeyCode.Space)) and root.Velocity or Vector3.new())
            end
        end)
    end)
end
local function stopSwim()
    if swimGrav then workspace.Gravity = swimGrav end
    if swimBeat then swimBeat:Disconnect(); swimBeat = nil end
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, v in pairs(Enum.HumanoidStateType:GetEnumItems()) do
            if v ~= Enum.HumanoidStateType.None then pcall(function() hum:SetStateEnabled(v, true) end) end
        end
    end
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
        root.CFrame = CFrame.new(Vector3.new(0, OrgDestroyHeight - 25, 0))
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
-- Invisible (FE) - clones character and swaps, appears invisible to others
local invisRunning = false
local invisRespawn = nil
local function startInvisibleFE()
    if invisRunning then return end
    invisRunning = true
    local ok = pcall(function()
        local Player = LP
        local Character = Player.Character
        if not Character then invisRunning = false; return end
        Character.Archivable = true
        local Lighting2 = game:GetService("Lighting")
        local InvisibleCharacter = Character:Clone()
        InvisibleCharacter.Parent = Lighting2
        InvisibleCharacter.Name = ""
        local Void = workspace.FallenPartsDestroyHeight
        local invisFix, invisDied
        local function Respawn()
            pcall(function()
                -- Reappear at the invisible clone's current spot (not falling from the void),
                -- swap control back to the REAL character and keep its Humanoid intact so it is
                -- visible and controllable again. Destroying the real Humanoid here was the old
                -- bug that left you stuck / never reappearing.
                local cf
                if InvisibleCharacter and InvisibleCharacter:FindFirstChild("HumanoidRootPart") then
                    cf = InvisibleCharacter.HumanoidRootPart.CFrame
                end
                Player.Character = Character
                Character.Parent = workspace
                if cf and Character:FindFirstChild("HumanoidRootPart") then
                    Character.HumanoidRootPart.CFrame = cf
                end
                local rhum = Character:FindFirstChildOfClass("Humanoid")
                pcall(function() workspace.CurrentCamera.CameraSubject = rhum end)
                pcall(function() Character.Animate.Disabled = true; Character.Animate.Disabled = false end)
                if InvisibleCharacter then InvisibleCharacter:Destroy() end
            end)
            invisRunning = false
            if invisFix then invisFix:Disconnect() end
            if invisDied then invisDied:Disconnect() end
        end
        invisRespawn = Respawn
        invisFix = RunService.Stepped:Connect(function()
            pcall(function()
                local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local Y = root.Position.Y
                    if Void < 0 then if Y <= Void then Respawn() end else if Y >= Void then Respawn() end end
                end
            end)
        end)
        for _, v in pairs(InvisibleCharacter:GetDescendants()) do
            if v:IsA("BasePart") then v.Transparency = (v.Name == "HumanoidRootPart") and 1 or 0.5 end
        end
        local ihum = InvisibleCharacter:FindFirstChildOfClass("Humanoid")
        if ihum then invisDied = ihum.Died:Connect(function() Respawn() end) end
        local CF_1 = Character:FindFirstChild("HumanoidRootPart") and Character.HumanoidRootPart.CFrame
        Character:MoveTo(Vector3.new(0, math.pi * 1000000, 0))
        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        task.wait(0.2)
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        Character.Parent = Lighting2
        InvisibleCharacter.Parent = workspace
        if CF_1 and InvisibleCharacter:FindFirstChild("HumanoidRootPart") then
            InvisibleCharacter.HumanoidRootPart.CFrame = CF_1
        end
        Player.Character = InvisibleCharacter
        pcall(function() workspace.CurrentCamera.CameraSubject = ihum end)
        pcall(function() InvisibleCharacter.Animate.Disabled = true; InvisibleCharacter.Animate.Disabled = false end)
        Notify("Invisible", "You appear invisible to other players", 3)
    end)
    if not ok then invisRunning = false; Notify("Invisible", "Failed (game blocks it)", 3) end
end
local function stopInvisibleFE()
    if invisRespawn then pcall(invisRespawn); invisRespawn = nil end
    invisRunning = false
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
    local secM = mkSection(PFun, "Movement", 2)
    mkToggle(secM, "Swim", false, function(v) S.Swim = v; if v then startSwim() else stopSwim() end end, 1)
    mkToggle(secM, "Wall TP", false, function(v) S.WallTP = v; if v then startWallTP() else stopWallTP() end end, 2)
    mkAction(secM, "Wall Walk", function() doWallWalk() end, 3)
    mkAction(secM, "Trip", function() doTrip() end, 4)
    mkAction(secM, "Fake Out (Flinger Kill)", function() doFakeOut() end, 5)
    local secTr = mkSection(PFun, "Troll", 3)
    mkToggle(secTr, "Spinbot", false, function(v) S.Spinbot = v end, 1)
    mkSlider(secTr, "Spin Speed", 5, 100, 20, function(v) S.SpinSpeed = v end, 2)
    mkToggle(secTr, "Jerk", false, function(v) S.Jerk = v; if v then startJerk() else stopJerk() end end, 3)
    local secC = mkSection(PFun, "Camera & Body", 4)
    mkToggle(secC, "Free Cam", false, function(v) S.FreeCam = v; if v then startFreecam() else stopFreecam() end end, 1)
    mkToggle(secC, "Invisible (FE)", false, function(v) S.InvisibleFE = v; if v then startInvisibleFE() else stopInvisibleFE() end end, 2)

    -- ---- Target Actions live on the TARGETS tab (built here so they can reuse the Fun module's
    -- start/stop helpers + funTarget/skidFling). They all act on the player picked in the Targets
    -- list; with "Auto" selected that resolves to the nearest player.
    local function currentTarget() return funTarget() end
    local secTgt = mkSection(PTargets, "Target Actions", 2)
    mkAction(secTgt, "Fling Target", function()
        local t = currentTarget()
        if not t or not t.Character then Notify("Fling", "No valid target", 2); return end
        Notify("Fling", "Flinging " .. t.Name, 2)
        task.spawn(function() pcall(skidFling, t) end)
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
local HUDEls = {}
local function mkDragHUD(name, pos, size, z)
    local f = Instance.new("Frame")
    f.Name = "HUD_"..name
    f.Parent = SG
    f.Active = true
    f.Position = pos
    f.Size = size
    f.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
    f.BackgroundTransparency = 0.05
    f.BorderSizePixel = 0
    f.Visible = false
    f.ZIndex = z or 850
    Corner(f, 10)
    Stroke(f, T.Bd2, 1, 0.35)
    Shadow(f, 0.45)
    local tb = Instance.new("Frame")
    tb.Parent = f
    tb.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    tb.BorderSizePixel = 0
    tb.Size = UDim2.new(1, 0, 0, 26)
    tb.ZIndex = z + 1
    Corner(tb, 8)
    local tbLine = Instance.new("Frame")
    tbLine.Parent = tb
    tbLine.BackgroundColor3 = T.Bd
    tbLine.BackgroundTransparency = 0.2
    tbLine.BorderSizePixel = 0
    tbLine.AnchorPoint = Vector2.new(0, 1)
    tbLine.Position = UDim2.new(0, 0, 1, 0)
    tbLine.Size = UDim2.new(1, 0, 0, 1)
    tbLine.ZIndex = z + 1
    local tick = Instance.new("Frame")
    tick.Parent = tb
    tick.BackgroundColor3 = T.White
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
    tl.TextColor3 = T.Tx3
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
local hRoles = mkDragHUD("Roles", UDim2.new(0, 10, 0, 200), UDim2.fromOffset(260, 160), 850)
Instance.new("UIListLayout", hRoles.content).Padding = UDim.new(0, 2)
local hBinds = mkDragHUD("Keybinds", UDim2.new(0, 10, 0, 370), UDim2.fromOffset(260, 150), 851)
Instance.new("UIListLayout", hBinds.content).Padding = UDim.new(0, 2)
local hGun = mkDragHUD("Gun Status", UDim2.new(1, -272, 0, 200), UDim2.fromOffset(260, 80), 852)
local gunLbl = Instance.new("TextLabel")
gunLbl.Parent = hGun.content
gunLbl.BackgroundTransparency = 1
gunLbl.Size = UDim2.new(1, 0, 1, 0)
gunLbl.Font = F
gunLbl.TextSize = 15
gunLbl.TextColor3 = T.Tx
gunLbl.TextXAlignment = Enum.TextXAlignment.Left
gunLbl.TextYAlignment = Enum.TextYAlignment.Top
gunLbl.TextWrapped = true
gunLbl.Text = "..."
gunLbl.ZIndex = 853
local hFps = mkDragHUD("FPS", UDim2.new(1, -115, 0, 10), UDim2.fromOffset(100, 42), 854)
local fpsLbl = Instance.new("TextLabel")
fpsLbl.Parent = hFps.content
fpsLbl.BackgroundTransparency = 1
fpsLbl.Size = UDim2.new(1, 0, 1, 0)
fpsLbl.Font = FB
fpsLbl.TextSize = 22
fpsLbl.TextColor3 = T.White
fpsLbl.Text = "0"
fpsLbl.ZIndex = 855
local function mkStatHUD(name, pos, w, h, z, tsize)
    local hud = mkDragHUD(name, pos, UDim2.fromOffset(w, h), z)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = hud.content
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.Font = FM
    lbl.TextSize = tsize or 15
    lbl.TextColor3 = T.Tx
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
    icon.Size = UDim2.new(0, 10, 0, 10)
    icon.Rotation = 45
    icon.BackgroundColor3 = T.White
    icon.BorderSizePixel = 0
    icon.ZIndex = 865
    Corner(icon, 2)
    Grad(icon, Color3.fromRGB(120, 180, 255), Color3.fromRGB(255, 255, 255), 45)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = f
    lbl.LayoutOrder = 2
    lbl.BackgroundTransparency = 1
    lbl.AutomaticSize = Enum.AutomaticSize.X
    lbl.Size = UDim2.new(0, 0, 1, 0)
    lbl.Font = FM
    lbl.TextSize = 14
    lbl.RichText = true
    lbl.TextColor3 = T.Tx
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = "MM2"
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
local hPing, pingLbl = mkStatHUD("Ping", UDim2.new(1, -115, 0, 60), 100, 44, 856, 18)
local hCoords, coordLbl = mkStatHUD("Coords", UDim2.new(0, 10, 0, 540), 210, 74, 857, 14)
local hTime, timeLbl = mkStatHUD("Time", UDim2.new(1, -165, 0, 112), 150, 44, 858, 16)
local hPlayers, playersLbl = mkStatHUD("Players", UDim2.new(1, -165, 0, 164), 150, 60, 859, 15)
local hWatermark, watermarkLbl = mkWatermark()
local hSpeed, speedLbl = mkStatHUD("Speed", UDim2.new(1, -115, 0, 110), 100, 44, 861, 16)
local hSession, sessionLbl = mkStatHUD("Session", UDim2.new(1, -165, 0, 232), 150, 44, 863, 16)
do
    local sec = mkSection(PHUD, "HUD Elements", 1)
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
        HUDEls["Watermark"].frame.Visible = v
    end, 9)
    mkToggle(sec, "Speed HUD", false, function(v)
        S.HUD_Speed = v
        HUDEls["Speed"].frame.Visible = v
    end, 10)
    mkToggle(sec, "Session HUD", false, function(v)
        S.HUD_Session = v
        HUDEls["Session"].frame.Visible = v
    end, 11)
    local info = Instance.new("TextLabel")
    info.Parent = sec
    info.LayoutOrder = 13
    info.BackgroundTransparency = 1
    info.Size = UDim2.new(1, 0, 0, 22)
    info.Font = F
    info.TextSize = 13
    info.TextColor3 = T.Tx4
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

        local dof = Instance.new("DepthOfFieldEffect")
        dof.FarIntensity = 0.05
        dof.FocusDistance = 55
        dof.InFocusRadius = 60
        dof.NearIntensity = 0.25
        dof.Parent = Lighting
        table.insert(shaderEffects, dof)

        local cc = Instance.new("ColorCorrectionEffect")
        cc.Brightness = 0.0
        cc.Contrast = 0.16
        cc.Saturation = 0.22
        cc.TintColor = Color3.fromRGB(255, 248, 236)
        cc.Parent = Lighting
        table.insert(shaderEffects, cc)

    elseif name == "Night Shaders" then
        -- Moody moonlit blue with soft glow and a cool tint.
        Lighting.ClockTime = 0
        Lighting.Brightness = 1.0
        Lighting.Ambient = Color3.fromRGB(26, 34, 62)
        Lighting.OutdoorAmbient = Color3.fromRGB(34, 44, 82)
        Lighting.GlobalShadows = true
        pcall(function() Lighting.ExposureCompensation = 0.0 end)

        local cc = Instance.new("ColorCorrectionEffect")
        cc.Brightness = 0.0
        cc.TintColor = Color3.fromRGB(155, 178, 255)
        cc.Contrast = 0.16
        cc.Saturation = 0.04
        cc.Parent = Lighting
        table.insert(shaderEffects, cc)

        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.5
        bloom.Size = 20
        bloom.Threshold = 1.3
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

        local dof = Instance.new("DepthOfFieldEffect")
        dof.FarIntensity = 0.12
        dof.FocusDistance = 45
        dof.InFocusRadius = 40
        dof.NearIntensity = 0.3
        dof.Parent = Lighting
        table.insert(shaderEffects, dof)

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
do
    local sec = mkSection(PShaders, "Presets", 1)
    -- One exclusive toggle per preset, generated from this list: turning one on switches the
    -- others off; turning the active one off returns to "None".
    local SHADER_LIST = {
        "RTX Low", "RTX Medium", "RTX High", "Night Shaders", "Pink Shaders",
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
    local sec = mkSection(PShaders, "Hand Shaders (Self)", 2)
    mkToggle(sec, "Enable Hand Shader", false, function(v) S.HandShader = v end, 1)
    mkCycle(sec, "Shader Type", {"Both", "Fill", "Outline", "Mirror", "Bloom", "Maze"}, "Both", function(v) S.HandShaderType = v end, 2)
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
                    local isMaterialShader = (shaderType == "Mirror" or shaderType == "Bloom" or shaderType == "Maze")
                    
                    local col
                    if S.HandRainbow then
                        hue = (hue + 0.02) % 1
                        col = Color3.fromHSV(hue, 0.85, 1)
                    else
                        col = FOV_COLORS[S.HandColor] or Color3.fromRGB(0, 255, 255)
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
                                end
                                part.Color = col
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
            task.wait(S.HandRainbow and 0.03 or 0.1)
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
    local sec2 = mkSection(PWorld, "Environment", 1)
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
do
    local function eachCoin(fn)
        -- A coin part matches if ITS name OR its parent MODEL's name contains "coin". MM2 coins are
        -- often a Model named "Coin" holding a differently-named MeshPart, so the old check (BasePart
        -- name only) found nothing → that was the "Coin ESP doesn't work" bug. We scan the "Normal"
        -- map folder first, and fall back to the whole workspace if the coins live elsewhere / the
        -- map folder isn't named "Normal" in this version.
        local found = false
        local function scan(root)
            if not root then return end
            for _, v in ipairs(root:GetDescendants()) do
                if v:IsA("BasePart") then
                    local n = string.lower(v.Name)
                    local pn = v.Parent and string.lower(v.Parent.Name) or ""
                    if string.find(n, "coin") or string.find(pn, "coin") then
                        found = true
                        fn(v)
                    end
                end
            end
        end
        scan(workspace:FindFirstChild("Normal"))
        if not found then scan(workspace) end
    end

    local function getCoinStats()
        local mainRound = LP:FindFirstChild("PlayerGui") and LP.PlayerGui:FindFirstChild("MainRound")
        if mainRound then
            local coinBag = mainRound:FindFirstChild("CoinBag", true)
            if coinBag then
                local label = coinBag:FindFirstChildOfClass("TextLabel") or (coinBag:IsA("TextLabel") and coinBag)
                if label then
                    local txt = label.Text
                    local cur, maxVal = string.match(txt, "(%d+)%s*/%s*(%d+)")
                    if cur and maxVal then
                        return tonumber(cur), tonumber(maxVal)
                    end
                    local singleVal = string.match(txt, "(%d+)")
                    if singleVal then
                        return tonumber(singleVal), 40
                    end
                end
            end
        end
        return nil, nil
    end

    isRoundActive = function()
        -- Round is active when roles have been dealt (RoleCache is filled by the GetPlayerData poll
        -- and cleared at round end) OR the classic map folder is loaded. Relying ONLY on
        -- "workspace.Normal" silently killed everything gated by this (autofarm, auto-evade, coin ESP,
        -- knife dodge) on any map/mode where that folder isn't named "Normal".
        if next(RoleCache) ~= nil then return true end
        return workspace:FindFirstChild("Normal") ~= nil
    end

    local secCoins = mkSection(PAutofarm, "Coins", 1)
    mkToggle(secCoins, "Coin ESP", false, function(v) S.CoinESP = v end, 1)

    local secAuto = mkSection(PAutofarm, "Automated", 2)
    mkToggle(secAuto, "Fast Autofarm", false, function(v) S.FastAutofarm = v end, 1)
    -- Glide speed in studs/s. ~60-120 is safe; past ~150 the position validator starts
    -- lagging you back on some servers (the glide auto-recovers, but it wastes time).
    mkSlider(secAuto, "Autofarm Speed", 20, 200, 60, function(v) S.FastAutofarmSpeed = v end, 2)
    mkToggle(secAuto, "Auto Evade Murderer", false, function(v) S.AutoEvade = v end, 3)
    mkSlider(secAuto, "Evade Distance", 10, 50, 25, function(v) S.AutoEvadeRange = v end, 4)

    -- Glide to the target with PER-FRAME steps (speed*dt studs) instead of the old 30-stud
    -- jumps with zeroed velocity. The server then sees continuous motion whose replicated
    -- velocity matches the movement, which passes MM2's "invalid position" (teleport
    -- distance) check instead of tripping the lagback.
    -- If the server DOES roll us back (position suddenly far from where we put it), we
    -- re-path from wherever it dropped us and crawl at low speed for a moment before
    -- resuming full speed, so one rejection doesn't turn into an endless fight.
    -- Returns true when the target was reached.
    local function moveTo(targetCF, speed, checkFn)
        local spd = math.max(speed or S.FastAutofarmSpeed or 60, 10)
        local c = LP.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        local expected = hrp.Position
        local slowUntil = 0
        local deadline = tick() + 15
        while tick() < deadline do
            if not S.FastAutofarm then return false end
            if checkFn and not checkFn() then return false end
            c = LP.Character
            hrp = c and c:FindFirstChild("HumanoidRootPart")
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then return false end

            -- Lagback detection: the server moved us away from where we last put ourselves.
            if (hrp.Position - expected).Magnitude > 20 then
                slowUntil = tick() + 1.2
                expected = hrp.Position
            end

            local dt = math.min(task.wait(), 1 / 30) -- clamp lag spikes so one frame never TPs far
            local curSpd = (tick() < slowUntil) and math.min(spd, 25) or spd
            local delta = targetCF.Position - hrp.Position
            local dist = delta.Magnitude

            -- Noclip so walls/props never wedge us into a "stuck fighting geometry" state.
            for _, pt in pairs(c:GetDescendants()) do
                if pt:IsA("BasePart") then pt.CanCollide = false end
            end

            local step = curSpd * dt
            if dist <= math.max(2.5, step) then
                hrp.CFrame = CFrame.new(targetCF.Position)
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                return true
            end

            local dir = delta / dist
            local newPos = hrp.Position + dir * step
            -- Face along the horizontal travel direction (guard the straight-up case where a
            -- horizontal lookAt would degenerate).
            local flat = Vector3.new(dir.X, 0, dir.Z)
            if flat.Magnitude > 0.05 then
                hrp.CFrame = CFrame.new(newPos, newPos + flat)
            else
                hrp.CFrame = CFrame.new(newPos)
            end
            -- Replicated velocity matches the motion -- a mover with zero velocity is exactly
            -- what the position validator flags.
            hrp.AssemblyLinearVelocity = dir * curSpd
            hrp.AssemblyAngularVelocity = Vector3.zero
            expected = newPos
        end
        return false
    end

    -- Coin ESP (per-coin Highlight so each coin is marked independently).
    local espWasOn = false
    task.spawn(function()
        while S.Gui and S.Gui.Parent do
            if S.CoinESP then
                espWasOn = true
                pcall(function()
                    eachCoin(function(coin)
                        if not coin:FindFirstChild("MM2_CoinESP") then
                            local h = Instance.new("Highlight")
                            h.Name = "MM2_CoinESP"
                            h.Adornee = coin
                            h.FillColor = Color3.fromRGB(255, 215, 0)
                            h.FillTransparency = 0.35
                            h.OutlineColor = Color3.fromRGB(255, 240, 150)
                            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            h.Parent = coin
                        end
                    end)
                end)
            elseif espWasOn then
                espWasOn = false
                pcall(function()
                    eachCoin(function(coin)
                        local e = coin:FindFirstChild("MM2_CoinESP"); if e then e:Destroy() end
                    end)
                end)
            end
            task.wait(0.5)
        end
    end)


    -- Fast Autofarm logic loop
    task.spawn(function()
        while S.Gui and S.Gui.Parent do
            if S.FastAutofarm then
                pcall(function()
                    local c = LP.Character
                    local hrp = c and c:FindFirstChild("HumanoidRootPart")
                    local hum = c and c:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 and isRoundActive() then
                        local curCoins, maxCoins = getCoinStats()
                        curCoins = curCoins or 0
                        maxCoins = maxCoins or 40
                        if curCoins < 50 and curCoins < maxCoins then
                            local coins = {}
                            eachCoin(function(coin)
                                if coin.Transparency < 1 then
                                    table.insert(coins, coin)
                                end
                            end)
                            if #coins > 0 then
                                table.sort(coins, function(a, b)
                                    return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
                                end)
                                local targetCoin = coins[1]

                                -- Vacuum: fire the touch on EVERY coin within reach, so coins we
                                -- merely fly past get collected too (the server accepts pickups a
                                -- few studs out). Runs every frame of the glide via checkFn.
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

                                -- Glide to the target coin, hoovering everything on the way.
                                moveTo(targetCoin.CFrame, S.FastAutofarmSpeed or 60, function()
                                    vacuum()
                                    return targetCoin and targetCoin.Parent and targetCoin.Transparency < 1 and c and c.Parent and hum and hum.Health > 0
                                end)
                                vacuum()

                                task.wait(0.05)
                            else
                                task.wait(0.2)
                            end
                        else
                            -- 50 coins reached or bag full, now execute role
                            local myRole = getRole(LP)
                            if myRole == "Murderer" then
                                local knife = LP.Backpack:FindFirstChild("Knife") or c:FindFirstChild("Knife")
                                if knife then
                                    if knife.Parent == LP.Backpack then
                                        hum:EquipTool(knife)
                                        task.wait(0.2)
                                    end
                                    killAll()
                                end
                                task.wait(1.5)
                            elseif myRole == "Sheriff" or myRole == "Hero" then
                                local gun = LP.Backpack:FindFirstChild("Gun") or c:FindFirstChild("Gun") or LP.Backpack:FindFirstChild("Revolver") or c:FindFirstChild("Revolver")
                                if gun then
                                    if gun.Parent == LP.Backpack then
                                        hum:EquipTool(gun)
                                        task.wait(0.2)
                                    end
                                    killMurder()
                                end
                                task.wait(1.5)
                            else
                                -- Innocent: stay safe high up
                                local safeCF = CFrame.new(hrp.Position.X, 500, hrp.Position.Z)
                                moveTo(safeCF, S.FastAutofarmSpeed or 60)
                                
                                if not S.VoidPlatform or not S.VoidPlatform.Parent then
                                    local p = Instance.new("Part")
                                    p.Size = Vector3.new(10, 1, 10)
                                    p.Anchored = true
                                    p.CanCollide = true
                                    p.Transparency = 0.5
                                    p.Color = Color3.fromRGB(0, 255, 0)
                                    p.Position = hrp.Position - Vector3.new(0, 3, 0)
                                    p.Parent = workspace
                                    S.VoidPlatform = p
                                else
                                    S.VoidPlatform.Position = hrp.Position - Vector3.new(0, 3, 0)
                                end
                                task.wait(0.5)
                            end
                        end
                    else
                        if S.VoidPlatform then
                            pcall(function() S.VoidPlatform:Destroy() end)
                            S.VoidPlatform = nil
                        end
                        task.wait(1)
                    end
                end)
            else
                if S.VoidPlatform then
                    pcall(function() S.VoidPlatform:Destroy() end)
                    S.VoidPlatform = nil
                end
            end
            task.wait(0.05)
        end
    end)

    -- Auto Evade Murderer loop
    local originalCFrame = nil
    local evading = false
    local evadePlatform = nil
    task.spawn(function()
        while S.Gui and S.Gui.Parent do
            if S.AutoEvade and isRoundActive() then
                pcall(function()
                    local c = LP.Character
                    local hrp = c and c:FindFirstChild("HumanoidRootPart")
                    local hum = c and c:FindFirstChildOfClass("Humanoid")
                    local myRole = getRole(LP)
                    
                    if hrp and hum and hum.Health > 0 and myRole ~= "Murderer" then
                        local mHrp = nil
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= LP and p.Character and getRole(p) == "Murderer" then
                                local mh = p.Character:FindFirstChildOfClass("Humanoid")
                                local mhPart = p.Character:FindFirstChild("HumanoidRootPart")
                                if mh and mh.Health > 0 and mhPart then
                                    mHrp = mhPart
                                    break
                                end
                            end
                        end
                        
                        if mHrp then
                            local checkDist = (mHrp.Position - (evading and originalCFrame and originalCFrame.Position or hrp.Position)).Magnitude
                            if not evading and checkDist < (S.AutoEvadeRange or 25) then
                                evading = true
                                originalCFrame = hrp.CFrame
                                
                                local targetCF = hrp.CFrame + Vector3.new(0, 250, 0)
                                hrp.CFrame = targetCF
                                
                                if not evadePlatform or not evadePlatform.Parent then
                                    local p = Instance.new("Part")
                                    p.Size = Vector3.new(12, 1, 12)
                                    p.Anchored = true
                                    p.CanCollide = true
                                    p.Transparency = 0.5
                                    p.Color = Color3.fromRGB(255, 0, 0)
                                    p.Position = targetCF.Position - Vector3.new(0, 3, 0)
                                    p.Parent = workspace
                                    evadePlatform = p
                                else
                                    evadePlatform.Position = targetCF.Position - Vector3.new(0, 3, 0)
                                end
                                Notify("Auto Evade", "Murderer too close! Evaded to ceiling.", 3)
                            elseif evading then
                                local origMDist = (mHrp.Position - originalCFrame.Position).Magnitude
                                if origMDist > (S.AutoEvadeRange or 25) + 12 then
                                    evading = false
                                    hrp.CFrame = originalCFrame
                                    originalCFrame = nil
                                    if evadePlatform then
                                        pcall(function() evadePlatform:Destroy() end)
                                        evadePlatform = nil
                                    end
                                    Notify("Auto Evade", "Safe to return.", 3)
                                end
                            end
                        elseif evading then
                            evading = false
                            hrp.CFrame = originalCFrame
                            originalCFrame = nil
                            if evadePlatform then
                                pcall(function() evadePlatform:Destroy() end)
                                evadePlatform = nil
                            end
                        end
                    end
                end)
            elseif evading then
                evading = false
                originalCFrame = nil
                if evadePlatform then
                    pcall(function() evadePlatform:Destroy() end)
                    evadePlatform = nil
                end
            end
            task.wait(0.1)
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
    local data = { controls = {}, hud = {}, binds = {} }
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
        local sec = mkSection(PConfig, "Configs", 1)
        local warn = Instance.new("TextLabel")
        warn.Parent = sec; warn.LayoutOrder = 1; warn.BackgroundTransparency = 1
        warn.Size = UDim2.new(1, 0, 0, 46); warn.Font = F; warn.TextSize = 13
        warn.TextColor3 = T.Tx2; warn.TextWrapped = true
        warn.TextXAlignment = Enum.TextXAlignment.Left
        warn.Text = "This executor has no file API (writefile/readfile), so configs cannot be saved."
    else
        local sec1 = mkSection(PConfig, "Configs", 1)
        local nameBox = Instance.new("TextBox")
        nameBox.Parent = sec1; nameBox.LayoutOrder = 1
        nameBox.Size = UDim2.new(1, 0, 0, 30); nameBox.BackgroundColor3 = T.Elev
        nameBox.BorderSizePixel = 0; nameBox.Font = F; nameBox.TextSize = 13
        nameBox.TextColor3 = T.Tx; nameBox.PlaceholderText = "config name..."
        nameBox.PlaceholderColor3 = T.Tx4; nameBox.Text = ""
        nameBox.ClearTextOnFocus = false; nameBox.TextXAlignment = Enum.TextXAlignment.Left
        Corner(nameBox, 6); Stroke(nameBox, T.Bd2, 1, 0.4); Pad(nameBox, 0, 0, 8, 8)
        local list = Instance.new("ScrollingFrame")
        list.Parent = sec1; list.LayoutOrder = 2
        list.Size = UDim2.new(1, 0, 0, 120); list.BackgroundColor3 = T.Card
        list.BorderSizePixel = 0; list.CanvasSize = UDim2.new(0, 0, 0, 0)
        list.AutomaticCanvasSize = Enum.AutomaticSize.Y; list.ScrollBarThickness = 3
        list.ScrollBarImageColor3 = T.Tx3
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
                b.BackgroundColor3 = T.Elev; b.BorderSizePixel = 0; b.AutoButtonColor = false
                b.Font = F; b.TextSize = 13; b.TextColor3 = T.Tx
                b.Text = "  " .. nm; b.TextXAlignment = Enum.TextXAlignment.Left
                Corner(b, 6)
                b.MouseButton1Click:Connect(function()
                    selected = nm; nameBox.Text = nm
                    for _, cb in pairs(list:GetChildren()) do if cb:IsA("TextButton") then cb.BackgroundColor3 = T.Elev end end
                    b.BackgroundColor3 = T.ActiveBg
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
        local sec2 = mkSection(PConfig, "Auto", 2)
        mkToggle(sec2, "Auto Save", true, function(v) S.AutoSaveCfg = v end, 1)
        local info = Instance.new("TextLabel")
        info.Parent = sec2; info.LayoutOrder = 2; info.BackgroundTransparency = 1
        info.Size = UDim2.new(1, 0, 0, 46); info.Font = F; info.TextSize = 12
        info.TextColor3 = T.Tx4; info.TextWrapped = true
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.Text = "Auto Save keeps your current settings + HUD layout and restores them automatically on next launch."
    end
end
if FILE_OK then
    task.spawn(function()
        task.wait(1)
        pcall(function() loadConfig("_autoload") end)
    end)
    task.spawn(function()
        while S.Gui and S.Gui.Parent do
            task.wait(5)
            if S.AutoSaveCfg then pcall(function() saveConfig("_autoload") end) end
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
        row.BackgroundColor3 = T.Elev
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
        lbl.TextColor3 = T.Tx
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.Text = mainText
        for i, b in ipairs(buttons) do
            local btn = Instance.new("TextButton")
            btn.Parent = row
            btn.AnchorPoint = Vector2.new(1, 0.5)
            btn.Position = UDim2.new(1, -6 - (n - i) * 30, 0.5, 0)
            btn.Size = UDim2.fromOffset(26, 26)
            btn.BackgroundColor3 = T.Card
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            btn.Font = FM
            btn.TextSize = 14
            btn.Text = b.text
            btn.TextColor3 = b.color or T.Tx
            Corner(btn, 6)
            local base = T.Card
            btn.MouseEnter:Connect(function() btn.BackgroundColor3 = T.Hover end)
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
        sc.BackgroundColor3 = T.Card
        sc.BorderSizePixel = 0
        sc.CanvasSize = UDim2.new(0, 0, 0, 0)
        sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sc.ScrollBarThickness = 3
        sc.ScrollBarImageColor3 = T.Tx3
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
    local secCur = mkSection(PServers, "Current Server", 1)
    local idBox = Instance.new("TextBox")
    idBox.Parent = secCur
    idBox.LayoutOrder = 1
    idBox.Size = UDim2.new(1, 0, 0, 30)
    idBox.BackgroundColor3 = T.Elev
    idBox.BorderSizePixel = 0
    idBox.Font = F
    idBox.TextSize = 12
    idBox.TextColor3 = T.Tx
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
    curInfo.TextColor3 = T.Tx3
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
    local secAdd = mkSection(PServers, "Add Server", 2)
    local addId = Instance.new("TextBox")
    addId.Parent = secAdd
    addId.LayoutOrder = 1
    addId.Size = UDim2.new(1, 0, 0, 30)
    addId.BackgroundColor3 = T.Elev
    addId.BorderSizePixel = 0
    addId.Font = F
    addId.TextSize = 12
    addId.TextColor3 = T.Tx
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
    addName.BackgroundColor3 = T.Elev
    addName.BorderSizePixel = 0
    addName.Font = F
    addName.TextSize = 12
    addName.TextColor3 = T.Tx
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
    local secSaved = mkSection(PServers, "Saved Servers", 3)
    local savedScroll = mkScroll(secSaved, 1, 168)
    local savedEmpty = Instance.new("TextLabel")
    savedEmpty.Parent = secSaved
    savedEmpty.LayoutOrder = 2
    savedEmpty.BackgroundTransparency = 1
    savedEmpty.Size = UDim2.new(1, 0, 0, 18)
    savedEmpty.Font = F
    savedEmpty.TextSize = 12
    savedEmpty.TextColor3 = T.Tx4
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
    local secRecent = mkSection(PServers, "Recent Servers", 4)
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
    local secBrowse = mkSection(PServers, "Browse Public Servers", 5)
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
    ln.BackgroundColor3 = T.Tx3
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
    hl.DepthMode = S.ChamsVisibleCheck and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = adornee
    return hl
end
task.spawn(function()
    local notified = false
    while S.Gui and S.Gui.Parent do
        local now = tick()
        if now - LastRemoteFetch >= 0.3 then
            LastRemoteFetch = now
            local rem = game:GetService("ReplicatedStorage"):FindFirstChild("GetPlayerData", true)
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
                        local msg = "Murder: "..fm
                        if fs then msg = msg.." | Sheriff: "..fs end
                        Notify("Roles", msg, 5)
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)
getRole = function(player)
    local cached = RoleCache[player.Name]
    -- Murderer keeps the knife all round, so the server cache is reliable for them
    if cached == "Murderer" then return "Murderer" end
    local c, bp = player.Character, player:FindFirstChild("Backpack")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    local alive = hum and hum.Health > 0
    local hk, hg = false, false
    local function chk(ct) if not ct then return end
        for _, i in pairs(ct:GetChildren()) do if i:IsA("Tool") then
            if i.Name == "Knife" or i:FindFirstChild("KnifeServer") then hk = true
            elseif i.Name == "Gun" or i.Name == "Revolver" then hg = true end
        end end
    end
    chk(c)
    chk(bp)
    if hk then return "Murderer" end
    -- Sheriff / Hero (only meaningful while alive, so a dead ex-holder never lingers).
    -- The server role (RoleCache) is authoritative AND arrives as soon as roles are
    -- assigned - so the Sheriff shows up immediately instead of only after they've
    -- physically received the gun tool (that lag is what made them "appear late").
    -- Gun possession is a backup for the brief window before the data poll catches up.
    if alive then
        -- Sheriff: PREDICTED from the server role the moment roles are assigned — shown BEFORE the
        -- round timer hands out the gun (no gun-possession requirement), so the cham appears early.
        -- Only one server Sheriff, and death clears it via the alive check, so it never lingers.
        -- BUT: once a Hero exists (Sheriff died & the dropped gun was grabbed), the Sheriff role is
        -- defunct — never report anyone as Sheriff after that (requested: "if there's a Hero, no Sheriff").
        if cached == "Sheriff" and not HeroPresent then OriginalSheriff = player; return "Sheriff" end
        -- Hero: an innocent holding the DROPPED gun. Must CURRENTLY hold it (hand/backpack) so that
        -- ex-heroes who have since dropped it don't pile up (that was the "several heroes" bug).
        if hg then
            if cached == "Hero" then return "Hero" end
            -- A Hero already exists this round, so any current gun holder is a Hero, never a Sheriff.
            if HeroPresent then return "Hero" end
            -- No server role yet but holding a gun: first holder = Sheriff (backup for the predict
            -- window), later pickups = Hero.
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
        if S.KnifeAura and firetouchinterest then
            pcall(function()
                local c = LP.Character
                local myHrp = c and c:FindFirstChild("HumanoidRootPart")
                local range = S.KnifeAuraRange or 15

                -- Collect every knife we can hit with: { handle = Part, origin = Vector3, tool = knifeToolOrNil }
                local sources = {}
                local heldKnife = c and c:FindFirstChild("Knife")
                local heldHandle = heldKnife and heldKnife:FindFirstChild("Handle")
                if heldKnife and heldHandle and myHrp then
                    table.insert(sources, { handle = heldHandle, origin = myHrp.Position, tool = heldKnife })
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
                                for _, v in pairs(player.Character:GetDescendants()) do
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
            if fpsLbl and fpsLbl.Parent then
                fpsLbl.Text = tostring(curFPS)
                fpsLbl.TextColor3 = curFPS >= 30 and T.White or T.Tx2
            end
        end
        local myRole = getRole(LP)
        StatusRole.Text = "ROLE  "..string.upper(myRole)
        StatusRole.TextColor3 = RoleShade[myRole] or T.Tx3
        pcall(function()
            local perf = game:GetService("Stats"):FindFirstChild("PerformanceStats")
            if perf then local ps = perf:FindFirstChild("Ping")
                if ps then StatusPing.Text = "PING  "..math.floor(ps:GetValue()).."ms" end
            end
        end)
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
        if S.NoClip then local c = LP.Character; if c then
            for _, pt in pairs(c:GetDescendants()) do if pt:IsA("BasePart") then pt.CanCollide = false end end end end
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
            if S.ChamsAll then
                if not ch:FindFirstChild("AllChams") then createHighlight(ch, Color3.fromRGB(255,255,255), "AllChams") end
            else local x = ch:FindFirstChild("AllChams"); if x then x:Destroy() end end
            -- Wall Detect: one AlwaysOnTop highlight per player (always visible through walls),
            -- coloured by ROLE (Murderer red, Sheriff blue, Hero yellow, Innocent green). A
            -- line-of-sight raycast from the camera to the player decides BRIGHTNESS every frame:
            -- clear ray = full-bright role colour (exposed / peeking); wall in the way = the same
            -- colour darkened toward black (behind cover). Re-evaluated each frame, so stepping out
            -- from behind a wall snaps it straight back to bright.
            -- (A per-part two-highlight Occluded+AlwaysOnTop version was tried but on this engine the
            -- AlwaysOnTop layer always draws over the Occluded one, so visible parts stayed dark and
            -- never reverted -- Roblox has no "occluded-only" DepthMode to do true per-part.)
            if S.WallDetectChams then
                -- clean up any leftovers from the old two-highlight version
                local ov = ch:FindFirstChild("WallDetVis"); if ov then ov:Destroy() end
                local oh = ch:FindFirstChild("WallDetHid"); if oh then oh:Destroy() end
                local base
                if role == "Murderer" then base = Color3.fromRGB(255, 45, 45)
                elseif role == "Sheriff" then base = Color3.fromRGB(50, 120, 255)
                elseif role == "Hero" then base = Color3.fromRGB(255, 225, 60)
                else base = Color3.fromRGB(70, 235, 110) end
                local hl = ch:FindFirstChild("WallDetect")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "WallDetect"
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.OutlineTransparency = 0
                    hl.Adornee = ch
                    hl.Parent = ch
                end
                local cam = workspace.CurrentCamera
                local part = ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
                local occluded = false
                if cam and part then
                    local origin = cam.CFrame.Position
                    local rp = RaycastParams.new()
                    rp.FilterType = Enum.RaycastFilterType.Exclude
                    rp.FilterDescendantsInstances = { ch, LP.Character }
                    rp.IgnoreWater = true
                    local res = workspace:Raycast(origin, part.Position - origin, rp)
                    occluded = res ~= nil
                end
                if occluded then
                    hl.FillColor = base:Lerp(Color3.new(0, 0, 0), 0.62)   -- behind a wall: darkened
                    hl.OutlineColor = base:Lerp(Color3.new(0, 0, 0), 0.3)
                    hl.FillTransparency = 0.25
                else
                    hl.FillColor = base                                    -- visible: full role colour
                    hl.OutlineColor = base
                    hl.FillTransparency = 0.5
                end
            else
                local a = ch:FindFirstChild("WallDetVis"); if a then a:Destroy() end
                local b = ch:FindFirstChild("WallDetHid"); if b then b:Destroy() end
                local d = ch:FindFirstChild("WallDetect"); if d then d:Destroy() end
            end
            -- Live-apply Chams Opacity / Visible Only to highlights that already exist, so the
            -- sliders take effect immediately instead of only on the next role change.
            for _, x in ipairs(ch:GetChildren()) do
                if x:IsA("Highlight") and string.find(x.Name, "Chams", 1, true) then
                    x.FillTransparency = 1 - (S.ChamsOpacity or 50) / 100
                    x.DepthMode = S.ChamsVisibleCheck and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
                end
            end
        end end
        local gd = workspace:FindFirstChild("GunDrop") or workspace:FindFirstChild("GunDrop", true)
        if gd then
            if S.AutoGrabGun then local n = tick(); if not S.LastGrab or n - S.LastGrab > 1 then S.LastGrab = n; grabGun() end end
            if S.GunChams then
                createCham(gd, Color3.fromRGB(255, 128, 0), "GunDropChams")
            else
                removeCham(gd, "GunDropChams")
            end
        end
        for _, v in pairs(workspace:GetChildren()) do
            if v.Name == "Knife" or v.Name == "NormalKnife" or v.Name == "ThrowingKnife" then
                if S.KnifeChams then
                    createCham(v, Color3.fromRGB(255, 0, 0), "KnifeChams")
                else
                    removeCham(v, "KnifeChams")
                end
            end
        end
    end)
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
tc(RunService.RenderStepped:Connect(function()
    local espOn = S.NameESP or S.DistanceESP or S.RoleESP or S.HealthESP or S.BoxESP or S.TracerESP or S.HeadDot
    if not espOn then
        -- Hide any objects we already made and skip creating new ones
        for _, o in pairs(ESPObjects) do
            o.box.Visible = false; o.hbBack.Visible = false; o.tracer.Visible = false; o.dot.Visible = false; o.bill.Enabled = false
        end
        return
    end
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
                pcall(function() role = getRole(plr) end)
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
    UIS.MouseIconEnabled = not S.HideRealCursor
    
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
    if processed then return end
    if S.ClickTP and input.KeyCode == Enum.KeyCode.E then
        local c = LP.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local mouse = LP:GetMouse()
        if hrp and mouse and mouse.Hit then
            hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            Notify("Click TP", "Teleported", 1.5)
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
                pingLbl.Text = ping .. " ms"
            end
            if S.HUD_Coords then
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local p = hrp.Position
                    coordLbl.Text = string.format("X  %d\nY  %d\nZ  %d", p.X, p.Y, p.Z)
                end
            end
            if S.HUD_Time then timeLbl.Text = os.date("%H:%M:%S") end
            if S.HUD_Players then
                playersLbl.Text = #Players:GetPlayers() .. " / " .. Players.MaxPlayers .. " players"
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
                watermarkLbl.Text = string.format(
                    '<b>MM2</b>%s<font color="#d0d0d0">%s</font>%s<font color="%s">%d ms</font>%s<font color="%s">%d fps</font>%s<font color="#b78bff">%s</font>',
                    sep, LP.Name, sep, pcol, wping, sep, fcol, curFPS, sep, sess)
            end
            if S.HUD_Speed then
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local sp = 0
                if hrp then local v = hrp.AssemblyLinearVelocity; sp = math.floor(Vector3.new(v.X, 0, v.Z).Magnitude) end
                speedLbl.Text = sp .. " sps"
            end
            if S.HUD_Session then
                local el = os.time() - scriptStart
                sessionLbl.Text = string.format("%02d:%02d:%02d", math.floor(el/3600), math.floor((el%3600)/60), el%60)
            end
        end)
        task.wait(0.25)
    end
end)


task.spawn(function() while S.Gui and S.Gui.Parent do
    if S.HUD_Roles and hRoles.content and hRoles.content.Parent then
        for _, ch in pairs(hRoles.content:GetChildren()) do if ch:IsA("TextLabel") then ch:Destroy() end end
        local o = 0
        for _, p in pairs(Players:GetPlayers()) do o = o + 1; local r = getRole(p)
            local l = Instance.new("TextLabel"); l.Name = p.Name; l.LayoutOrder = o; l.BackgroundTransparency = 1
            l.Size = UDim2.new(1,0,0,20); l.Font = (r == "Murderer") and FM or F; l.TextSize = 15
            l.TextColor3 = RoleShade[r] or T.Tx3
            l.TextXAlignment = Enum.TextXAlignment.Left; l.Text = p.Name.."  -  "..r; l.ZIndex = 851
            l.TextTruncate = Enum.TextTruncate.AtEnd; l.Parent = hRoles.content
        end
        hRoles.frame.Size = UDim2.new(hRoles.frame.Size.X.Scale, hRoles.frame.Size.X.Offset, 0, 32 + (o * 22))
    end
    if S.HUD_Keybinds and hBinds.content and hBinds.content.Parent then
        for _, ch in pairs(hBinds.content:GetChildren()) do if ch:IsA("TextLabel") then ch:Destroy() end end
        local o = 0
        for _, e in ipairs(AllBinds) do if e.bindKey then o = o + 1
            local l = Instance.new("TextLabel"); l.LayoutOrder = o; l.BackgroundTransparency = 1
            l.Size = UDim2.new(1,0,0,20); l.Font = F; l.TextSize = 15; l.TextColor3 = T.Tx
            l.TextXAlignment = Enum.TextXAlignment.Left; l.Text = "[ "..e.bindKey.Name.." ]  "..e.label
            l.TextTruncate = Enum.TextTruncate.AtEnd; l.ZIndex = 852; l.Parent = hBinds.content
        end end
        if o == 0 then local l = Instance.new("TextLabel"); l.BackgroundTransparency = 1
            l.Size = UDim2.new(1,0,0,20); l.Font = F; l.TextSize = 15; l.TextColor3 = T.Tx3
            l.TextXAlignment = Enum.TextXAlignment.Left; l.Text = "No binds set"; l.ZIndex = 852; l.Parent = hBinds.content end
        hBinds.frame.Size = UDim2.new(hBinds.frame.Size.X.Scale, hBinds.frame.Size.X.Offset, 0, 32 + (math.max(o, 1) * 22))
    end
    if S.HUD_GunStatus and gunLbl and gunLbl.Parent then
        local gd = workspace:FindFirstChild("GunDrop") or workspace:FindFirstChild("GunDrop", true)
        local c = LP.Character; local bp = LP:FindFirstChild("Backpack"); local hg = false
        if (c and (c:FindFirstChild("Gun") or c:FindFirstChild("Revolver"))) or (bp and (bp:FindFirstChild("Gun") or bp:FindFirstChild("Revolver"))) then hg = true end
        local lines = {"Role: "..getRole(LP)}
        table.insert(lines, hg and "Gun: IN HAND" or gd and "Gun: DROPPED" or "Gun: N/A")
        local sn = "?"
        for _, p in pairs(Players:GetPlayers()) do local r = getRole(p); if r == "Sheriff" or r == "Hero" then sn = p.Name; break end end
        table.insert(lines, "Sheriff: "..sn)
        gunLbl.Text = table.concat(lines, "\n")
    end
    task.wait(0.5) end end)
do
    Main.Visible = false
    local L = Instance.new("Frame")
    L.Parent = SG
    L.AnchorPoint = Vector2.new(0.5, 0.5)
    L.Position = UDim2.new(0.5, 0, 0.5, 0)
    L.Size = UDim2.fromOffset(360, 180)
    L.BackgroundColor3 = T.BG
    L.BorderSizePixel = 0
    L.ZIndex = 500
    L.ClipsDescendants = true
    Corner(L, 14)
    Stroke(L, T.Bd2, 1, 0.2)
    Shadow(L, 0.3)
    Grad(L, Color3.fromRGB(12, 12, 12), Color3.fromRGB(3, 3, 3), 90)
    local la = Instance.new("Frame")
    la.Parent = L
    la.Size = UDim2.new(1, 0, 0, 1)
    la.BackgroundColor3 = T.White
    la.BackgroundTransparency = 0.55
    la.BorderSizePixel = 0
    la.ZIndex = 501
    local lt = Instance.new("TextLabel")
    lt.Parent = L
    lt.BackgroundTransparency = 1
    lt.Position = UDim2.new(0, 0, 0.12, 0)
    lt.Size = UDim2.new(1, 0, 0.22, 0)
    lt.Font = FB
    lt.Text = "MM2"
    lt.TextColor3 = T.White
    lt.TextScaled = true
    lt.ZIndex = 501
    Grad(lt, T.White, Color3.fromRGB(100, 100, 100), 90)
    local ls = Instance.new("TextLabel")
    ls.Parent = L
    ls.BackgroundTransparency = 1
    ls.Position = UDim2.new(0, 0, 0.40, 0)
    ls.Size = UDim2.new(1, 0, 0.1, 0)
    ls.Font = F
    ls.Text = "init..."
    ls.TextColor3 = T.Tx3
    ls.TextScaled = true
    ls.ZIndex = 501
    local lbb = Instance.new("Frame")
    lbb.Parent = L
    lbb.AnchorPoint = Vector2.new(0.5, 0.5)
    lbb.Position = UDim2.new(0.5, 0, 0.65, 0)
    lbb.Size = UDim2.new(0.72, 0, 0, 5)
    lbb.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    lbb.BorderSizePixel = 0
    lbb.ZIndex = 501
    Corner(lbb, 8)
    local lbf = Instance.new("Frame")
    lbf.Parent = lbb
    lbf.Size = UDim2.new(0, 0, 1, 0)
    lbf.BackgroundColor3 = T.White
    lbf.BorderSizePixel = 0
    lbf.ZIndex = 502
    Corner(lbf, 8)
    local lp = Instance.new("TextLabel")
    lp.Parent = L
    lp.BackgroundTransparency = 1
    lp.Position = UDim2.new(0, 0, 0.76, 0)
    lp.Size = UDim2.new(1, 0, 0.12, 0)
    lp.Font = FM
    lp.Text = "0%"
    lp.TextColor3 = T.Tx3
    lp.TextScaled = true
    lp.ZIndex = 501
    task.spawn(function()
        local stages = {
            {0.18, "connecting modules"},
            {0.38, "loading role tracker"},
            {0.56, "building interface"},
            {0.74, "initializing HUD"},
            {0.90, "linking events"},
            {1.00, "ready"},
        }
        local cur = 0
        for _, st in ipairs(stages) do
            ls.Text = st[2]
            TweenService:Create(lbf, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                Size = UDim2.new(st[1], 0, 1, 0)
            }):Play()
            local tgt = math.floor(st[1]*100)
            while cur < tgt do
                cur = cur + 1
                lp.Text = cur.."%"
                task.wait(0.004)
            end
            task.wait(0.08)
        end
        task.wait(0.15)
        for _, o in ipairs(L:GetDescendants()) do
            if o:IsA("TextLabel") then
                TweenService:Create(o, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
            elseif o:IsA("Frame") then
                TweenService:Create(o, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
            elseif o:IsA("UIStroke") then
                TweenService:Create(o, TweenInfo.new(0.2), { Transparency = 1 }):Play()
            end
        end
        TweenService:Create(L, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
        task.wait(0.22)
        L:Destroy()
        Main.Visible = true
        local fw, fh = expandedSize.X.Offset, expandedSize.Y.Offset
        Main.Size = UDim2.fromOffset(math.floor(fw*0.88), math.floor(fh*0.88))
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = expandedSize
        }):Play()
        SFX.Ready()
        pcall(function() rebuildCrosshair() end)
        Notify("MM2", "LCtrl = menu | RMB = bind", 4)
    end)
    -- ============ SOCIAL & HUD (KILL FEED & AUTO GG) ============
    local killFeedFrame = Instance.new("Frame")
    killFeedFrame.Name = "MM2_KillFeed"
    killFeedFrame.Parent = SG
    killFeedFrame.Position = UDim2.new(1, -260, 0, 80)
    killFeedFrame.Size = UDim2.new(0, 240, 0, 300)
    killFeedFrame.BackgroundTransparency = 1
    killFeedFrame.ZIndex = 800
    
    local killFeedLayout = Instance.new("UIListLayout")
    killFeedLayout.Parent = killFeedFrame
    killFeedLayout.SortOrder = Enum.SortOrder.LayoutOrder
    killFeedLayout.Padding = UDim.new(0, 4)
    
    local function addKillFeed(msg, color)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 24)
        card.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        card.BackgroundTransparency = 0.3
        card.BorderSizePixel = 0
        card.ZIndex = 801
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = card
        
        local txt = Instance.new("TextLabel")
        txt.Parent = card
        txt.Size = UDim2.new(1, -8, 1, 0)
        txt.Position = UDim2.new(0, 4, 0, 0)
        txt.BackgroundTransparency = 1
        txt.Font = Enum.Font.SourceSansSemibold
        txt.TextSize = 13
        txt.TextColor3 = color or Color3.new(1, 1, 1)
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.Text = msg
        txt.ZIndex = 802
        
        card.Parent = killFeedFrame
        
        task.spawn(function()
            task.wait(4.5)
            TweenService:Create(card, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(txt, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
            task.wait(0.5)
            card:Destroy()
        end)
    end
    
    local function setupPlayerDeathTrack(p)
        local function connectChar(char)
            local hum = char:WaitForChild("Humanoid", 5)
            if hum then
                hum.Died:Connect(function()
                    if S.KillFeed and isRoundActive() then
                        local r = getRole(p)
                        local msg = ""
                        local color = Color3.fromRGB(255, 255, 255)
                        
                        if r == "Murderer" then
                            msg = "☠ [Murderer] " .. p.Name .. " was eliminated!"
                            color = Color3.fromRGB(255, 50, 50)
                        elseif r == "Sheriff" or r == "Hero" then
                            msg = "🔫 [" .. r .. "] " .. p.Name .. " was killed!"
                            color = Color3.fromRGB(50, 100, 255)
                        else
                            msg = "👤 [Innocent] " .. p.Name .. " died."
                            color = Color3.fromRGB(200, 200, 200)
                        end
                        
                        addKillFeed(msg, color)
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
            hrp.CFrame = hrp.CFrame + escapeDir * 18
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
print("[MM2]: Loaded.")
