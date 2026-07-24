-- INERTIA launcher — pick a game, it runs.
--
-- Design rules this file follows, and the reasons they exist:
--  * One dark theme, no dividers, no status strip, no decoration that isn't a
--    game card. The old launcher's white hairline and empty side margins were
--    the whole reason it looked unfinished.
--  * Nothing is sized in fixed pixels. Every dimension is derived from the
--    viewport in fit(), so the same window works on a 5" phone, a tablet in
--    either orientation, and a 4K monitor.
--  * PC / MOBILE is a switch, not a guess. Touch detection only picks the
--    starting side; the launcher exports the choice as _G.INERTIA_MOBILE, and
--    the hub scripts build their entire interface from that flag.

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local function destroyOld(parent)
	if not parent then return end
	local old = parent:FindFirstChild("GameLoaderUI")
	if old then old:Destroy() end
end
destroyOld(CoreGui)
if LocalPlayer then destroyOld(LocalPlayer:FindFirstChildOfClass("PlayerGui")) end

local parentGui = CoreGui
pcall(function() if gethui then parentGui = gethui() end end)
if not parentGui then parentGui = LocalPlayer:WaitForChild("PlayerGui") end
destroyOld(parentGui)

local T = {
	BG = Color3.fromRGB(9, 9, 10),
	Card = Color3.fromRGB(17, 17, 19),
	Elev = Color3.fromRGB(25, 25, 28),
	Hover = Color3.fromRGB(34, 34, 38),
	Border = Color3.fromRGB(44, 44, 49),
	White = Color3.fromRGB(255, 255, 255),
	Text = Color3.fromRGB(236, 236, 238),
	Dim = Color3.fromRGB(126, 126, 133),
	Faint = Color3.fromRGB(86, 86, 92),
	Good = Color3.fromRGB(126, 214, 156),
	Bad = Color3.fromRGB(228, 100, 100),
}

local function corner(object, radius)
	local value = Instance.new("UICorner")
	value.CornerRadius = UDim.new(0, radius or 10)
	value.Parent = object
	return value
end
local function stroke(object, transparency, color)
	local value = Instance.new("UIStroke")
	value.Color = color or T.Border
	value.Thickness = 1
	value.Transparency = transparency or 0.45
	value.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	value.Parent = object
	return value
end
local function text(parent, value, size, color, font)
	local label = Instance.new("TextLabel")
	label.Parent = parent
	label.BackgroundTransparency = 1
	label.Text = value or ""
	label.TextSize = size or 13
	label.TextColor3 = color or T.Text
	label.Font = font or Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	return label
end
local function tween(object, time, props, style, dir)
	return TweenService:Create(object, TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
end

-- Touch-only devices start on the mobile build; the switch below always wins.
local MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local REPO = "https://raw.githubusercontent.com/Yanderov/lib/refs/heads/main/"

-- rbxthumb://type=GameIcon needs the UNIVERSE id, not the place id — a place id
-- silently resolves to nothing, which is why every icon used to render blank.
local Games = {
	{ name = "Murder Mystery 2", desc = "Innocent, Sheriff, Murderer", icon = 66654135, file = "mm2" },
	{ name = "Demonology", desc = "Co-op ghost hunting", icon = 2548152021, file = "demonology" },
	{ name = "Pressure", desc = "Hadal Blacksite, deep-sea horror", icon = 4367208330, file = "pressure" },
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GameLoaderUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 2147483646
pcall(function() ScreenGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets end)
ScreenGui.Parent = parentGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.52)
Main.BackgroundColor3 = T.BG
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = true
corner(Main, 16)
stroke(Main, 0.3)

local Scale = Instance.new("UIScale")
Scale.Scale = 0.92
Scale.Parent = Main

--------------------------------------------------------------------------------
-- HEADER
--------------------------------------------------------------------------------
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = Main
Header.BackgroundTransparency = 1
Header.Active = true

local Brand = text(Header, "INERTIA", 18, T.White, Enum.Font.GothamBold)
local BrandSub = text(Header, "script launcher", 11, T.Faint)

local Close = Instance.new("TextButton")
Close.Parent = Header
Close.AnchorPoint = Vector2.new(1, 0.5)
Close.BackgroundColor3 = T.Elev
Close.BorderSizePixel = 0
Close.AutoButtonColor = false
Close.Text = "×"
Close.TextColor3 = T.Dim
Close.Font = Enum.Font.GothamMedium
corner(Close, 9)
local closeStroke = stroke(Close, 0.5)

-- PC / MOBILE segmented switch. The sliding pill is the only moving part, so
-- the two labels never shift and the control reads instantly.
local Switch = Instance.new("Frame")
Switch.Parent = Header
Switch.AnchorPoint = Vector2.new(1, 0.5)
Switch.BackgroundColor3 = T.Elev
Switch.BorderSizePixel = 0
corner(Switch, 10)
stroke(Switch, 0.55)

local SwitchPill = Instance.new("Frame")
SwitchPill.Parent = Switch
SwitchPill.BackgroundColor3 = T.Hover
SwitchPill.BorderSizePixel = 0
SwitchPill.Size = UDim2.new(0.5, -4, 1, -6)
SwitchPill.Position = UDim2.new(0, 2, 0, 3)
corner(SwitchPill, 8)
stroke(SwitchPill, 0.6)

local function mkSwitchOption(label, isRight)
	local button = Instance.new("TextButton")
	button.Parent = Switch
	button.Size = UDim2.new(0.5, 0, 1, 0)
	button.Position = isRight and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
	button.BackgroundTransparency = 1
	button.AutoButtonColor = false
	button.Font = Enum.Font.GothamMedium
	button.Text = label
	button.ZIndex = 2
	return button
end
local PcOption = mkSwitchOption("PC", false)
local MobileOption = mkSwitchOption("MOBILE", true)

--------------------------------------------------------------------------------
-- GAME CARDS
--------------------------------------------------------------------------------
local List = Instance.new("ScrollingFrame")
List.Name = "Games"
List.Parent = Main
List.BackgroundTransparency = 1
List.BorderSizePixel = 0
List.CanvasSize = UDim2.new()
List.ScrollBarThickness = 0
List.ScrollingEnabled = false

local Layout = Instance.new("UIListLayout")
Layout.Parent = List
Layout.SortOrder = Enum.SortOrder.LayoutOrder

local Cards = {}
local busy = false
local setLoading

local function launch(entry)
	if busy then return end
	busy = true
	setLoading(entry, "downloading")
	task.defer(function()
		-- The build flag is what the hub reads to decide which interface to
		-- construct; set it BEFORE the chunk runs, never after.
		_G.INERTIA_MOBILE = MOBILE
		-- The time query defeats the raw.githubusercontent CDN cache (~5 min):
		-- without it, a freshly pushed fix keeps serving the previous, possibly
		-- broken file and "nothing injects" for no visible reason.
		local url = REPO .. entry.file .. (MOBILE and "_mobile" or "") .. ".lua?t=" .. tostring(os.time())
		local ok, source = pcall(function() return game:HttpGet(url) end)
		if not ok or type(source) ~= "string" or #source == 0 then
			busy = false
			setLoading(entry, "download failed", true)
			warn("INERTIA launcher: " .. tostring(source))
			return
		end
		setLoading(entry, "starting")
		-- Compile and run as separate steps.  `loadstring(source)()` collapses a
		-- compile failure into ":<line>: attempt to call a nil value" (calling
		-- the nil loadstring returned) — worthless for debugging.  Split, the
		-- real compiler message reaches the console.
		local chunk, compileError = loadstring(source)
		if type(chunk) ~= "function" then
			busy = false
			setLoading(entry, "compile failed", true)
			warn("INERTIA launcher: " .. entry.file .. " did not compile: " .. tostring(compileError))
			return
		end
		local ran, err = pcall(chunk)
		if not ran then
			busy = false
			setLoading(entry, "failed to start", true)
			warn("INERTIA launcher: " .. entry.file .. " crashed: " .. tostring(err))
			return
		end
		setLoading(entry, "ready")
		task.wait(0.35)
		if ScreenGui.Parent then
			tween(Scale, 0.18, { Scale = 0.9 }):Play()
			tween(Main, 0.18, { BackgroundTransparency = 1 }):Play()
			task.delay(0.2, function() if ScreenGui.Parent then ScreenGui:Destroy() end end)
		end
	end)
end

for index, entry in ipairs(Games) do
	local card = Instance.new("TextButton")
	card.Name = entry.name
	card.Parent = List
	card.LayoutOrder = index
	card.BackgroundColor3 = T.Card
	card.BorderSizePixel = 0
	card.AutoButtonColor = false
	card.Text = ""
	corner(card, 14)
	local cardStroke = stroke(card, 0.5)

	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Parent = card
	icon.BackgroundColor3 = T.Elev
	icon.BorderSizePixel = 0
	icon.Image = "rbxthumb://type=GameIcon&id=" .. tostring(entry.icon) .. "&w=420&h=420"
	icon.ScaleType = Enum.ScaleType.Crop
	corner(icon, 12)
	stroke(icon, 0.6)

	local name = text(card, entry.name, 14, T.Text, Enum.Font.GothamMedium)
	name.Name = "Title"
	name.TextTruncate = Enum.TextTruncate.AtEnd

	local desc = text(card, entry.desc, 11, T.Faint)
	desc.Name = "Desc"
	desc.TextTruncate = Enum.TextTruncate.AtEnd

	local play = Instance.new("TextButton")
	play.Name = "Play"
	play.Parent = card
	play.BackgroundColor3 = T.Elev
	play.BorderSizePixel = 0
	play.AutoButtonColor = false
	play.Font = Enum.Font.GothamMedium
	play.Text = "LAUNCH"
	play.TextColor3 = T.Text
	corner(play, 10)
	local playStroke = stroke(play, 0.5)

	local function hover(on)
		tween(card, 0.14, { BackgroundColor3 = on and T.Elev or T.Card }):Play()
		tween(cardStroke, 0.14, { Transparency = on and 0.25 or 0.5 }):Play()
		tween(play, 0.14, { BackgroundColor3 = on and T.White or T.Elev }):Play()
		play.TextColor3 = on and T.BG or T.Text
		tween(playStroke, 0.14, { Transparency = on and 1 or 0.5 }):Play()
	end
	card.MouseEnter:Connect(function() if not busy then hover(true) end end)
	card.MouseLeave:Connect(function() if not busy then hover(false) end end)
	play.MouseEnter:Connect(function() if not busy then hover(true) end end)
	play.MouseLeave:Connect(function() if not busy then hover(false) end end)

	card.MouseButton1Click:Connect(function() launch(entry) end)
	play.MouseButton1Click:Connect(function() launch(entry) end)

	Cards[index] = { card = card, icon = icon, name = name, desc = desc, play = play, entry = entry }
end

--------------------------------------------------------------------------------
-- LOADER OVERLAY
--------------------------------------------------------------------------------
-- Compact by design: an icon, the game name, one status word and an
-- indeterminate sweep. No log, no percentage we'd have to fake, no second
-- window — it covers the launcher rather than opening beside it.
local Overlay = Instance.new("Frame")
Overlay.Name = "Loader"
Overlay.Parent = Main
Overlay.BackgroundColor3 = T.BG
Overlay.BackgroundTransparency = 0.06
Overlay.BorderSizePixel = 0
Overlay.Size = UDim2.fromScale(1, 1)
Overlay.Visible = false
Overlay.ZIndex = 40

local OverlayIcon = Instance.new("ImageLabel")
OverlayIcon.Parent = Overlay
OverlayIcon.AnchorPoint = Vector2.new(0.5, 1)
OverlayIcon.BackgroundColor3 = T.Elev
OverlayIcon.BorderSizePixel = 0
OverlayIcon.ScaleType = Enum.ScaleType.Crop
OverlayIcon.ZIndex = 41
corner(OverlayIcon, 14)
stroke(OverlayIcon, 0.55)

local OverlayName = text(Overlay, "", 15, T.White, Enum.Font.GothamMedium)
OverlayName.AnchorPoint = Vector2.new(0.5, 0)
OverlayName.TextXAlignment = Enum.TextXAlignment.Center
OverlayName.ZIndex = 41

local OverlayStatus = text(Overlay, "", 11, T.Dim)
OverlayStatus.AnchorPoint = Vector2.new(0.5, 0)
OverlayStatus.TextXAlignment = Enum.TextXAlignment.Center
OverlayStatus.ZIndex = 41

local Track = Instance.new("Frame")
Track.Parent = Overlay
Track.AnchorPoint = Vector2.new(0.5, 0)
Track.BackgroundColor3 = T.Elev
Track.BorderSizePixel = 0
Track.ZIndex = 41
corner(Track, 99)

local Sweep = Instance.new("Frame")
Sweep.Parent = Track
Sweep.BackgroundColor3 = T.White
Sweep.BorderSizePixel = 0
Sweep.Size = UDim2.new(0.34, 0, 1, 0)
Sweep.ZIndex = 42
corner(Sweep, 99)

local sweepRunning = false
local function runSweep()
	if sweepRunning then return end
	sweepRunning = true
	task.spawn(function()
		while sweepRunning and Overlay.Visible do
			Sweep.Position = UDim2.fromScale(-0.34, 0)
			tween(Sweep, 0.85, { Position = UDim2.fromScale(1, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut):Play()
			task.wait(0.95)
		end
		sweepRunning = false
	end)
end

setLoading = function(entry, status, failed)
	Overlay.Visible = true
	OverlayIcon.Image = "rbxthumb://type=GameIcon&id=" .. tostring(entry.icon) .. "&w=420&h=420"
	OverlayName.Text = entry.name
	OverlayStatus.Text = status
	OverlayStatus.TextColor3 = failed and T.Bad or T.Dim
	Sweep.BackgroundColor3 = failed and T.Bad or T.White
	if failed then
		sweepRunning = false
		task.delay(1.8, function()
			if not busy then Overlay.Visible = false end
		end)
	else
		runSweep()
	end
end

--------------------------------------------------------------------------------
-- RESPONSIVE LAYOUT
--------------------------------------------------------------------------------
-- Every size in the UI is computed here from the current viewport, and fit()
-- re-runs on any viewport change — resize, rotation, split view. Switching
-- PC/MOBILE re-runs it too, which is what makes the switch visibly change the
-- whole layout instead of only the download URL.
local function fit()
	local camera = Workspace.CurrentCamera
	local vp = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local portrait = vp.Y >= vp.X

	local width, height
	if MOBILE then
		width = math.clamp(vp.X * (portrait and 0.92 or 0.6), 260, 460)
		height = math.clamp(vp.Y * (portrait and 0.62 or 0.88), 280, 560)
	else
		width = math.clamp(vp.X - 80, 380, 620)
		height = math.clamp(vp.Y - 80, 260, 380)
	end
	Main.Size = UDim2.fromOffset(math.floor(width), math.floor(height))

	local pad = MOBILE and 16 or 18
	local headerH = MOBILE and 58 or 54
	Header.Position = UDim2.fromOffset(pad, 0)
	Header.Size = UDim2.new(1, -pad * 2, 0, headerH)
	Brand.Position = UDim2.fromOffset(0, MOBILE and 10 or 9)
	Brand.Size = UDim2.fromOffset(160, 20)
	Brand.TextSize = MOBILE and 18 or 17
	BrandSub.Position = UDim2.fromOffset(0, MOBILE and 30 or 28)
	BrandSub.Size = UDim2.fromOffset(160, 14)

	local btn = MOBILE and 36 or 30
	Close.Position = UDim2.new(1, 0, 0.5, 0)
	Close.Size = UDim2.fromOffset(btn, btn)
	Close.TextSize = MOBILE and 22 or 19
	Switch.Position = UDim2.new(1, -(btn + 10), 0.5, 0)
	Switch.Size = UDim2.fromOffset(MOBILE and 132 or 118, btn)
	PcOption.TextSize = MOBILE and 12 or 11
	MobileOption.TextSize = MOBILE and 12 or 11

	List.Position = UDim2.fromOffset(pad, headerH)
	List.Size = UDim2.new(1, -pad * 2, 1, -(headerH + pad))
	Layout.FillDirection = MOBILE and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
	Layout.Padding = UDim.new(0, MOBILE and 10 or 12)
	List.ScrollingEnabled = MOBILE
	List.AutomaticCanvasSize = MOBILE and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
	List.ScrollingDirection = Enum.ScrollingDirection.Y

	for _, item in ipairs(Cards) do
		if MOBILE then
			-- Phone: a row per game — icon, text block, launch button. Tall tiles
			-- in a horizontal strip would each be about a thumb wide.
			local rowH = 84
			item.card.Size = UDim2.new(1, 0, 0, rowH)
			item.icon.Position = UDim2.fromOffset(12, 12)
			item.icon.Size = UDim2.fromOffset(rowH - 24, rowH - 24)
			item.name.Position = UDim2.fromOffset(rowH - 4, 18)
			item.name.Size = UDim2.new(1, -(rowH + 92), 0, 18)
			item.name.TextSize = 15
			item.desc.Position = UDim2.fromOffset(rowH - 4, 38)
			item.desc.Size = UDim2.new(1, -(rowH + 92), 0, 16)
			item.desc.TextSize = 12
			item.play.AnchorPoint = Vector2.new(1, 0.5)
			item.play.Position = UDim2.new(1, -12, 0.5, 0)
			item.play.Size = UDim2.fromOffset(78, 40)
			item.play.TextSize = 12
		else
			-- Desktop: equal-width tiles, sized by scale so three cards always
			-- fill the row exactly whatever the window width ends up being.
			item.card.Size = UDim2.new(1 / #Cards, -8, 1, 0)
			local inner = math.floor(width - pad * 2 - 8 * (#Cards - 1))
			local tileW = math.floor(inner / #Cards)
			local iconSize = math.min(tileW - 24, math.floor(height - headerH - 118))
			item.icon.Position = UDim2.new(0.5, -math.floor(iconSize / 2), 0, 12)
			item.icon.Size = UDim2.fromOffset(iconSize, iconSize)
			item.name.Position = UDim2.fromOffset(12, 20 + iconSize)
			item.name.Size = UDim2.new(1, -24, 0, 18)
			item.name.TextSize = 14
			item.desc.Position = UDim2.fromOffset(12, 38 + iconSize)
			item.desc.Size = UDim2.new(1, -24, 0, 15)
			item.desc.TextSize = 11
			item.play.AnchorPoint = Vector2.new(0.5, 1)
			item.play.Position = UDim2.new(0.5, 0, 1, -12)
			item.play.Size = UDim2.new(1, -24, 0, 32)
			item.play.TextSize = 12
		end
	end

	local overlayIcon = MOBILE and 64 or 58
	OverlayIcon.Position = UDim2.new(0.5, 0, 0.5, -14)
	OverlayIcon.Size = UDim2.fromOffset(overlayIcon, overlayIcon)
	OverlayName.Position = UDim2.new(0.5, 0, 0.5, -6)
	OverlayName.Size = UDim2.new(1, -40, 0, 20)
	OverlayStatus.Position = UDim2.new(0.5, 0, 0.5, 16)
	OverlayStatus.Size = UDim2.new(1, -40, 0, 14)
	Track.Position = UDim2.new(0.5, 0, 0.5, 40)
	Track.Size = UDim2.new(0, math.floor(math.min(width - 80, 220)), 0, 3)
end

local function refreshSwitch()
	tween(SwitchPill, 0.18, {
		Position = MOBILE and UDim2.new(0.5, 2, 0, 3) or UDim2.new(0, 2, 0, 3),
	}, Enum.EasingStyle.Back):Play()
	PcOption.TextColor3 = MOBILE and T.Faint or T.White
	MobileOption.TextColor3 = MOBILE and T.White or T.Faint
	fit()
end
PcOption.MouseButton1Click:Connect(function() if not busy then MOBILE = false; refreshSwitch() end end)
MobileOption.MouseButton1Click:Connect(function() if not busy then MOBILE = true; refreshSwitch() end end)
refreshSwitch()

do
	local camera = Workspace.CurrentCamera
	if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(fit) end
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		local newCamera = Workspace.CurrentCamera
		if newCamera then fit(); newCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit) end
	end)
end

--------------------------------------------------------------------------------
-- WINDOW
--------------------------------------------------------------------------------
local function closeWindow()
	if not ScreenGui.Parent then return end
	tween(Scale, 0.16, { Scale = 0.94 }):Play()
	tween(Main, 0.16, { BackgroundTransparency = 1 }):Play()
	task.delay(0.18, function() if ScreenGui.Parent then ScreenGui:Destroy() end end)
end
Close.MouseEnter:Connect(function()
	tween(Close, 0.12, { BackgroundColor3 = T.Hover, TextColor3 = T.White }):Play()
	tween(closeStroke, 0.12, { Transparency = 0.25 }):Play()
end)
Close.MouseLeave:Connect(function()
	tween(Close, 0.12, { BackgroundColor3 = T.Elev, TextColor3 = T.Dim }):Play()
	tween(closeStroke, 0.12, { Transparency = 0.5 }):Play()
end)
Close.MouseButton1Click:Connect(closeWindow)

do
	local dragging, startPointer, startPosition
	Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local pos = input.Position
			local function over(gui)
				local p, s = gui.AbsolutePosition, gui.AbsoluteSize
				return pos.X >= p.X and pos.X <= p.X + s.X and pos.Y >= p.Y and pos.Y <= p.Y + s.Y
			end
			-- Without this hit test a tap on the switch or the close button starts
			-- a window drag instead of pressing them.
			if over(Switch) or over(Close) then return end
			dragging = true; startPointer = input.Position; startPosition = Main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - startPointer
			Main.Position = UDim2.new(
				startPosition.X.Scale, startPosition.X.Offset + delta.X,
				startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
			)
		end
	end)
end

tween(Scale, 0.26, { Scale = 1 }, Enum.EasingStyle.Back):Play()
tween(Main, 0.22, { Position = UDim2.fromScale(0.5, 0.5) }):Play()
