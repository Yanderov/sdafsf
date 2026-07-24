-- INERTIA loader — script library shell.
-- Dark themes, live theme / language / scale switching, saved config, player card,
-- executor readout, and one-click launch of each game's payload (desktop or mobile build).

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

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

----------------------------------------------------------------------
-- Config (persists theme / language / scale / build between launches)
----------------------------------------------------------------------
local CONFIG_FILE = "InertiaLoader.json"
local FILE_OK = (typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function")

local Config = { Theme = "Void", Language = "EN", Scale = 1, Mobile = false }

local function saveConfig()
	if not FILE_OK then return end
	pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(Config)) end)
end

local function loadConfig()
	if not FILE_OK then return end
	pcall(function()
		if not isfile(CONFIG_FILE) then return end
		local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
		if type(data) ~= "table" then return end
		for key, value in pairs(data) do
			if Config[key] ~= nil and type(value) == type(Config[key]) then Config[key] = value end
		end
	end)
end
loadConfig()

----------------------------------------------------------------------
-- Themes — every preset stays near-black; only the tint of the greys moves.
----------------------------------------------------------------------
local ThemeOrder = { "Void", "Carbon", "Midnight", "Ember", "Moss" }
local Themes = {
	Void = {
		BG = Color3.fromRGB(0, 0, 0), Sidebar = Color3.fromRGB(5, 5, 6), Card = Color3.fromRGB(10, 10, 11),
		Elev = Color3.fromRGB(16, 16, 18), Hover = Color3.fromRGB(24, 24, 26), Active = Color3.fromRGB(34, 34, 37),
		Border = Color3.fromRGB(32, 32, 35), Accent = Color3.fromRGB(236, 236, 238),
	},
	Carbon = {
		BG = Color3.fromRGB(9, 9, 10), Sidebar = Color3.fromRGB(13, 13, 15), Card = Color3.fromRGB(18, 18, 20),
		Elev = Color3.fromRGB(25, 25, 28), Hover = Color3.fromRGB(34, 34, 38), Active = Color3.fromRGB(45, 45, 49),
		Border = Color3.fromRGB(42, 42, 46), Accent = Color3.fromRGB(228, 228, 232),
	},
	Midnight = {
		BG = Color3.fromRGB(4, 6, 12), Sidebar = Color3.fromRGB(7, 10, 18), Card = Color3.fromRGB(11, 15, 26),
		Elev = Color3.fromRGB(17, 22, 36), Hover = Color3.fromRGB(24, 31, 48), Active = Color3.fromRGB(33, 42, 63),
		Border = Color3.fromRGB(30, 38, 58), Accent = Color3.fromRGB(150, 190, 255),
	},
	Ember = {
		BG = Color3.fromRGB(10, 4, 4), Sidebar = Color3.fromRGB(15, 6, 6), Card = Color3.fromRGB(22, 9, 9),
		Elev = Color3.fromRGB(31, 13, 13), Hover = Color3.fromRGB(43, 18, 18), Active = Color3.fromRGB(56, 24, 24),
		Border = Color3.fromRGB(52, 22, 22), Accent = Color3.fromRGB(255, 138, 110),
	},
	Moss = {
		BG = Color3.fromRGB(4, 9, 6), Sidebar = Color3.fromRGB(6, 13, 9), Card = Color3.fromRGB(10, 19, 13),
		Elev = Color3.fromRGB(15, 27, 19), Hover = Color3.fromRGB(21, 37, 26), Active = Color3.fromRGB(29, 48, 34),
		Border = Color3.fromRGB(27, 45, 32), Accent = Color3.fromRGB(150, 235, 175),
	},
}

local T = {}
local function loadTheme(name)
	local preset = Themes[name] or Themes.Void
	for key, value in pairs(preset) do T[key] = value end
	T.White = Color3.fromRGB(255, 255, 255)
	T.Text = T.White:Lerp(T.Card, 0.08)
	T.Muted = T.White:Lerp(T.Card, 0.38)
	T.Dim = T.White:Lerp(T.Card, 0.58)
	T.Success = Color3.fromRGB(120, 210, 150)
	T.Danger = Color3.fromRGB(226, 96, 96)
end
loadTheme(Config.Theme)

----------------------------------------------------------------------
-- Language
----------------------------------------------------------------------
local LangOrder = { "EN", "RU" }
local Strings = {
	EN = {
		subtitle = "SCRIPT LIBRARY", library = "Library", settings = "Settings",
		pageTitle = "Script library", pageSub = "Pick an experience to load its tools.",
		launch = "LAUNCH", starting = "STARTING...", retry = "RETRY",
		ready = "READY", downloadFail = "Download failed", execFail = "Execution failed",
		started = "started", quick = "QUICK STATUS", scripts = "SCRIPTS", state = "STATE",
		executor = "EXECUTOR", theme = "Theme", language = "Language", size = "Size",
		build = "Build", desktop = "Desktop", mobile = "Mobile", hint = "drag header to move",
	},
	RU = {
		subtitle = "БИБЛИОТЕКА", library = "Библиотека", settings = "Настройки",
		pageTitle = "Библиотека скриптов", pageSub = "Выбери игру, чтобы загрузить её функции.",
		launch = "ЗАПУСК", starting = "ЗАПУСК...", retry = "ЕЩЁ РАЗ",
		ready = "ГОТОВ", downloadFail = "Ошибка загрузки", execFail = "Ошибка запуска",
		started = "запущен", quick = "СТАТУС", scripts = "СКРИПТОВ", state = "СОСТОЯНИЕ",
		executor = "ЭКЗЕКУТОР", theme = "Тема", language = "Язык", size = "Размер",
		build = "Сборка", desktop = "ПК", mobile = "Мобайл", hint = "тяни за шапку",
	},
}
local function L(key)
	local pack = Strings[Config.Language] or Strings.EN
	return pack[key] or Strings.EN[key] or key
end

----------------------------------------------------------------------
-- Theme / text registries so switching recolors live
----------------------------------------------------------------------
local ColorReg, TextReg = {}, {}
local function reg(object, property, role)
	table.insert(ColorReg, { obj = object, prop = property, role = role })
	pcall(function() object[property] = T[role] end)
	return object
end
local function regText(object, key, upper)
	table.insert(TextReg, { obj = object, key = key, upper = upper })
	object.Text = upper and string.upper(L(key)) or L(key)
	return object
end

local function corner(object, radius)
	local value = Instance.new("UICorner")
	value.CornerRadius = UDim.new(0, radius or 8)
	value.Parent = object
	return value
end
local function stroke(object, role, transparency)
	local value = Instance.new("UIStroke")
	value.Thickness = 1
	value.Transparency = transparency or 0.35
	value.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	value.Parent = object
	reg(value, "Color", role or "Border")
	return value
end
local function text(parent, value, size, role, font)
	local label = Instance.new("TextLabel")
	label.Parent = parent
	label.BackgroundTransparency = 1
	label.Text = value or ""
	label.TextSize = size or 12
	label.Font = font or Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	reg(label, "TextColor3", role or "Text")
	return label
end

local executorName = "Unknown"
pcall(function()
	if identifyexecutor then executorName = tostring(identifyexecutor())
	elseif getexecutorname then executorName = tostring(getexecutorname()) end
end)

----------------------------------------------------------------------
-- Shell
----------------------------------------------------------------------
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
Main.Position = UDim2.new(0.5, 0, 0.5, 12)
Main.Size = UDim2.fromOffset(770, 580)
Main.BackgroundTransparency = 0.04
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = true
reg(Main, "BackgroundColor3", "BG")
corner(Main, 14)
stroke(Main, "Border", 0.22)

local RootScale = Instance.new("UIScale")
RootScale.Scale = Config.Scale
RootScale.Parent = Main
local OpenScale = Instance.new("UIScale")
OpenScale.Scale = 0.93
OpenScale.Parent = Main

local AccentLine = Instance.new("Frame")
AccentLine.Parent = Main
AccentLine.Position = UDim2.fromOffset(14, 0)
AccentLine.Size = UDim2.new(1, -28, 0, 1)
AccentLine.BorderSizePixel = 0
reg(AccentLine, "BackgroundColor3", "Accent")

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = Main
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundTransparency = 1
Header.Active = true

local Brand = text(Header, "INERTIA", 15, "White", Enum.Font.GothamBold)
Brand.Position = UDim2.fromOffset(18, 9)
Brand.Size = UDim2.fromOffset(200, 18)
local BrandSub = regText(text(Header, "", 9, "Dim", Enum.Font.GothamMedium), "subtitle", true)
BrandSub.Position = UDim2.fromOffset(18, 27)
BrandSub.Size = UDim2.fromOffset(220, 14)

local Close = Instance.new("TextButton")
Close.Parent = Header
Close.AnchorPoint = Vector2.new(1, 0.5)
Close.Position = UDim2.new(1, -14, 0.5, 0)
Close.Size = UDim2.fromOffset(27, 27)
Close.BorderSizePixel = 0
Close.AutoButtonColor = false
Close.Text = "×"
Close.TextSize = 19
Close.Font = Enum.Font.GothamMedium
reg(Close, "BackgroundColor3", "Elev")
reg(Close, "TextColor3", "Muted")
corner(Close, 8)
stroke(Close, "Border", 0.44)

----------------------------------------------------------------------
-- Sidebar: player card, nav, executor
----------------------------------------------------------------------
local Sidebar = Instance.new("Frame")
Sidebar.Parent = Main
Sidebar.Position = UDim2.fromOffset(9, 50)
Sidebar.Size = UDim2.new(0, 168, 1, -84)
Sidebar.BackgroundTransparency = 0.05
Sidebar.BorderSizePixel = 0
reg(Sidebar, "BackgroundColor3", "Sidebar")
corner(Sidebar, 11)
stroke(Sidebar, "Border", 0.36)

local Profile = Instance.new("Frame")
Profile.Parent = Sidebar
Profile.Position = UDim2.fromOffset(9, 9)
Profile.Size = UDim2.new(1, -18, 0, 62)
Profile.BackgroundTransparency = 0.06
Profile.BorderSizePixel = 0
reg(Profile, "BackgroundColor3", "Card")
corner(Profile, 10)
stroke(Profile, "Border", 0.44)

local Avatar = Instance.new("ImageLabel")
Avatar.Parent = Profile
Avatar.Position = UDim2.fromOffset(9, 11)
Avatar.Size = UDim2.fromOffset(40, 40)
Avatar.BorderSizePixel = 0
Avatar.ScaleType = Enum.ScaleType.Crop
reg(Avatar, "BackgroundColor3", "Elev")
if LocalPlayer then
	Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
end
corner(Avatar, 20)
stroke(Avatar, "Border", 0.5)

local ProfileTitle = text(Profile, LocalPlayer and LocalPlayer.DisplayName or "Player", 12, "Text", Enum.Font.GothamMedium)
ProfileTitle.Position = UDim2.fromOffset(57, 12)
ProfileTitle.Size = UDim2.new(1, -66, 0, 17)
ProfileTitle.TextTruncate = Enum.TextTruncate.AtEnd
local ProfileSub = text(Profile, LocalPlayer and ("@" .. LocalPlayer.Name) or "local", 9, "Dim", Enum.Font.Gotham)
ProfileSub.Position = UDim2.fromOffset(57, 31)
ProfileSub.Size = UDim2.new(1, -66, 0, 15)
ProfileSub.TextTruncate = Enum.TextTruncate.AtEnd

local navButtons = {}
local activeTab = "library"
local switchTab

local function mkNav(key, order)
	local button = Instance.new("TextButton")
	button.Parent = Sidebar
	button.Position = UDim2.fromOffset(9, 80 + (order - 1) * 38)
	button.Size = UDim2.new(1, -18, 0, 34)
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Text = ""
	corner(button, 9)
	local mark = Instance.new("Frame")
	mark.Parent = button
	mark.Position = UDim2.new(0, 0, 0.5, -9)
	mark.Size = UDim2.fromOffset(3, 18)
	mark.BorderSizePixel = 0
	reg(mark, "BackgroundColor3", "Accent")
	corner(mark, 2)
	local label = regText(text(button, "", 12, "Text", Enum.Font.GothamMedium), key)
	label.Position = UDim2.fromOffset(14, 0)
	label.Size = UDim2.new(1, -20, 1, 0)
	button.MouseButton1Click:Connect(function() switchTab(key) end)
	navButtons[key] = { button = button, mark = mark, label = label }
	return button
end
mkNav("library", 1)
mkNav("settings", 2)

local function refreshNav()
	for key, entry in pairs(navButtons) do
		local on = (key == activeTab)
		entry.button.BackgroundColor3 = on and T.Elev or T.Sidebar
		entry.button.BackgroundTransparency = on and 0 or 1
		entry.label.TextColor3 = on and T.White or T.Muted
		entry.mark.Visible = on
	end
end

local Session = Instance.new("Frame")
Session.Parent = Sidebar
Session.AnchorPoint = Vector2.new(0, 1)
Session.Position = UDim2.new(0, 9, 1, -9)
Session.Size = UDim2.new(1, -18, 0, 84)
Session.BackgroundTransparency = 0.06
Session.BorderSizePixel = 0
reg(Session, "BackgroundColor3", "Card")
corner(Session, 10)
stroke(Session, "Border", 0.44)
local SessionTitle = regText(text(Session, "", 9, "Dim", Enum.Font.GothamBold), "quick", true)
SessionTitle.Position = UDim2.fromOffset(10, 8)
SessionTitle.Size = UDim2.new(1, -20, 0, 14)
local SessionText = text(Session, "", 9, "Muted", Enum.Font.GothamMedium)
SessionText.Position = UDim2.fromOffset(10, 26)
SessionText.Size = UDim2.new(1, -20, 0, 50)
SessionText.TextYAlignment = Enum.TextYAlignment.Top
SessionText.LineHeight = 1.4

----------------------------------------------------------------------
-- Content
----------------------------------------------------------------------
local Content = Instance.new("Frame")
Content.Parent = Main
Content.Position = UDim2.fromOffset(189, 50)
Content.Size = UDim2.new(1, -198, 1, -84)
Content.BackgroundTransparency = 1

local PageTitle = regText(text(Content, "", 17, "White", Enum.Font.GothamBold), "pageTitle")
PageTitle.Position = UDim2.fromOffset(6, 2)
PageTitle.Size = UDim2.new(1, -12, 0, 24)
local PageSub = regText(text(Content, "", 10, "Dim", Enum.Font.Gotham), "pageSub")
PageSub.Position = UDim2.fromOffset(6, 26)
PageSub.Size = UDim2.new(1, -12, 0, 18)

local LibraryPage = Instance.new("ScrollingFrame")
LibraryPage.Parent = Content
LibraryPage.Position = UDim2.fromOffset(6, 54)
LibraryPage.Size = UDim2.new(1, -12, 1, -60)
LibraryPage.BackgroundTransparency = 1
LibraryPage.BorderSizePixel = 0
LibraryPage.ScrollBarThickness = 3
LibraryPage.CanvasSize = UDim2.new()
LibraryPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
LibraryPage.ScrollingDirection = Enum.ScrollingDirection.Y
reg(LibraryPage, "ScrollBarImageColor3", "Border")
local CardLayout = Instance.new("UIListLayout")
CardLayout.Parent = LibraryPage
CardLayout.SortOrder = Enum.SortOrder.LayoutOrder
CardLayout.Padding = UDim.new(0, 10)

local SettingsPage = Instance.new("Frame")
SettingsPage.Parent = Content
SettingsPage.Position = UDim2.fromOffset(6, 54)
SettingsPage.Size = UDim2.new(1, -12, 1, -60)
SettingsPage.BackgroundTransparency = 1
SettingsPage.Visible = false
local SettingsLayout = Instance.new("UIListLayout")
SettingsLayout.Parent = SettingsPage
SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
SettingsLayout.Padding = UDim.new(0, 10)

local StatusBar = Instance.new("Frame")
StatusBar.Parent = Main
StatusBar.AnchorPoint = Vector2.new(0, 1)
StatusBar.Position = UDim2.new(0, 0, 1, 0)
StatusBar.Size = UDim2.new(1, 0, 0, 28)
StatusBar.BorderSizePixel = 0
reg(StatusBar, "BackgroundColor3", "Sidebar")
corner(StatusBar, 13)
local Status = text(StatusBar, "", 9, "Muted", Enum.Font.GothamMedium)
Status.Position = UDim2.fromOffset(15, 0)
Status.Size = UDim2.new(1, -30, 1, 0)
local Hint = regText(text(StatusBar, "", 9, "Dim", Enum.Font.Gotham), "hint")
Hint.AnchorPoint = Vector2.new(1, 0)
Hint.Position = UDim2.new(1, -15, 0, 0)
Hint.Size = UDim2.fromOffset(260, 28)
Hint.TextXAlignment = Enum.TextXAlignment.Right

local busy = false
local statusKey, statusRole = "ready", "Muted"
local function setStatus(key, role, raw)
	statusKey, statusRole = key, role or "Muted"
	Status.Text = raw or string.upper(L(key))
	Status.TextColor3 = T[statusRole] or T.Muted
end

----------------------------------------------------------------------
-- Settings rows
----------------------------------------------------------------------
local function mkSettingRow(order, labelKey, valueText)
	local row = Instance.new("Frame")
	row.Parent = SettingsPage
	row.LayoutOrder = order
	row.Size = UDim2.new(1, 0, 0, 52)
	row.BackgroundTransparency = 0.06
	row.BorderSizePixel = 0
	reg(row, "BackgroundColor3", "Card")
	corner(row, 10)
	stroke(row, "Border", 0.44)
	local label = regText(text(row, "", 12, "Text", Enum.Font.GothamMedium), labelKey)
	label.Position = UDim2.fromOffset(14, 0)
	label.Size = UDim2.new(1, -160, 1, 0)
	local button = Instance.new("TextButton")
	button.Parent = row
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -12, 0.5, 0)
	button.Size = UDim2.fromOffset(128, 30)
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Font = Enum.Font.GothamMedium
	button.TextSize = 11
	button.Text = valueText
	reg(button, "BackgroundColor3", "Elev")
	reg(button, "TextColor3", "Text")
	corner(button, 8)
	stroke(button, "Border", 0.48)
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), { BackgroundColor3 = T.Hover }):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), { BackgroundColor3 = T.Elev }):Play()
	end)
	return button
end

local applyTheme, applyLanguage
local themeButton = mkSettingRow(1, "theme", Config.Theme)
local langButton = mkSettingRow(2, "language", Config.Language)
local sizeButton = mkSettingRow(3, "size", math.floor(Config.Scale * 100 + 0.5) .. "%")
local buildButton = mkSettingRow(4, "build", Config.Mobile and L("mobile") or L("desktop"))

local ExecRow = Instance.new("Frame")
ExecRow.Parent = SettingsPage
ExecRow.LayoutOrder = 5
ExecRow.Size = UDim2.new(1, 0, 0, 52)
ExecRow.BackgroundTransparency = 0.06
ExecRow.BorderSizePixel = 0
reg(ExecRow, "BackgroundColor3", "Card")
corner(ExecRow, 10)
stroke(ExecRow, "Border", 0.44)
local ExecLabel = regText(text(ExecRow, "", 12, "Text", Enum.Font.GothamMedium), "executor")
ExecLabel.Position = UDim2.fromOffset(14, 0)
ExecLabel.Size = UDim2.new(1, -180, 1, 0)
local ExecValue = text(ExecRow, executorName, 11, "Muted", Enum.Font.GothamMedium)
ExecValue.AnchorPoint = Vector2.new(1, 0.5)
ExecValue.Position = UDim2.new(1, -14, 0.5, 0)
ExecValue.Size = UDim2.fromOffset(170, 30)
ExecValue.TextXAlignment = Enum.TextXAlignment.Right
ExecValue.TextTruncate = Enum.TextTruncate.AtEnd

----------------------------------------------------------------------
-- Game cards
----------------------------------------------------------------------
local REPO = "https://raw.githubusercontent.com/Yanderov/lib/refs/heads/main/"
local Games = {
	{ name = "Murder Mystery 2", icon = 142823291, file = "mm2", desc = { EN = "Role tools, interface and utility suite for MM2.", RU = "Роли, интерфейс и утилиты для MM2." } },
	{ name = "Demonology", icon = 6735515785, file = "demonology", desc = { EN = "Evidence tracking and interface suite for Demonology.", RU = "Улики, призраки и интерфейс для Demonology." } },
	{ name = "Pressure", icon = 12411473842, file = "pressure", desc = { EN = "Oxygen, movement and interface suite for Pressure.", RU = "Кислород, движение и интерфейс для Pressure." } },
}

local cardRefs = {}

local function launch(entry, button)
	if busy then return end
	busy = true
	button.Text = L("starting")
	button.BackgroundColor3 = T.Active
	setStatus(nil, "Accent", string.upper(L("starting") .. " " .. entry.name))
	task.defer(function()
		local url = REPO .. entry.file .. (Config.Mobile and "_mobile" or "") .. ".lua"
		local fetched, source = pcall(function() return game:HttpGet(url) end)
		if not fetched or type(source) ~= "string" or #source == 0 then
			busy = false
			button.Text = L("retry")
			button.BackgroundColor3 = T.Accent
			setStatus("downloadFail", "Danger")
			warn("INERTIA loader: " .. tostring(source))
			return
		end
		local ok, err = pcall(function() loadstring(source)() end)
		if not ok then
			busy = false
			button.Text = L("retry")
			button.BackgroundColor3 = T.Accent
			setStatus("execFail", "Danger")
			warn("INERTIA loader: " .. tostring(err))
			return
		end
		setStatus(nil, "Success", string.upper(entry.name .. " " .. L("started")))
		task.wait(0.35)
		if ScreenGui.Parent then
			TweenService:Create(OpenScale, TweenInfo.new(0.16), { Scale = 0.94 }):Play()
			TweenService:Create(Main, TweenInfo.new(0.16), { BackgroundTransparency = 1 }):Play()
			task.delay(0.18, function() if ScreenGui.Parent then ScreenGui:Destroy() end end)
		end
	end)
end

local function createGameCard(order, entry)
	local Card = Instance.new("Frame")
	Card.Name = entry.name
	Card.Parent = LibraryPage
	Card.LayoutOrder = order
	Card.Size = UDim2.new(1, -4, 0, 132)
	Card.BackgroundTransparency = 0.06
	Card.BorderSizePixel = 0
	Card.ClipsDescendants = true
	reg(Card, "BackgroundColor3", "Card")
	corner(Card, 12)
	local cardStroke = stroke(Card, "Border", 0.42)

	local Image = Instance.new("ImageLabel")
	Image.Parent = Card
	Image.Position = UDim2.fromOffset(11, 11)
	Image.Size = UDim2.fromOffset(110, 110)
	Image.BorderSizePixel = 0
	Image.Image = "rbxthumb://type=GameIcon&id=" .. tostring(entry.icon) .. "&w=420&h=420"
	Image.ScaleType = Enum.ScaleType.Crop
	reg(Image, "BackgroundColor3", "Elev")
	corner(Image, 10)
	stroke(Image, "Border", 0.5)

	local Title = text(Card, entry.name, 14, "White", Enum.Font.GothamBold)
	Title.Position = UDim2.fromOffset(134, 17)
	Title.Size = UDim2.new(1, -148, 0, 21)
	Title.TextTruncate = Enum.TextTruncate.AtEnd

	local Description = text(Card, entry.desc[Config.Language] or entry.desc.EN, 10, "Muted", Enum.Font.Gotham)
	Description.Position = UDim2.fromOffset(134, 42)
	Description.Size = UDim2.new(1, -148, 0, 34)
	Description.TextWrapped = true
	Description.TextYAlignment = Enum.TextYAlignment.Top

	local Badge = Instance.new("TextLabel")
	Badge.Parent = Card
	Badge.Position = UDim2.fromOffset(134, 88)
	Badge.Size = UDim2.fromOffset(86, 22)
	Badge.BorderSizePixel = 0
	Badge.Font = Enum.Font.GothamMedium
	Badge.TextSize = 9
	Badge.Text = Config.Mobile and string.upper(L("mobile")) or string.upper(L("desktop"))
	reg(Badge, "BackgroundColor3", "Elev")
	reg(Badge, "TextColor3", "Muted")
	corner(Badge, 6)
	stroke(Badge, "Border", 0.5)

	local Launch = Instance.new("TextButton")
	Launch.Parent = Card
	Launch.AnchorPoint = Vector2.new(1, 0)
	Launch.Position = UDim2.new(1, -13, 0, 86)
	Launch.Size = UDim2.fromOffset(116, 28)
	Launch.BorderSizePixel = 0
	Launch.AutoButtonColor = false
	Launch.Font = Enum.Font.GothamBold
	Launch.TextSize = 10
	Launch.Text = L("launch")
	reg(Launch, "BackgroundColor3", "Accent")
	reg(Launch, "TextColor3", "BG")
	corner(Launch, 8)

	Card.MouseEnter:Connect(function()
		TweenService:Create(Card, TweenInfo.new(0.14), { BackgroundColor3 = T.Hover }):Play()
		TweenService:Create(cardStroke, TweenInfo.new(0.14), { Color = T.Accent, Transparency = 0.2 }):Play()
	end)
	Card.MouseLeave:Connect(function()
		TweenService:Create(Card, TweenInfo.new(0.14), { BackgroundColor3 = T.Card }):Play()
		TweenService:Create(cardStroke, TweenInfo.new(0.14), { Color = T.Border, Transparency = 0.42 }):Play()
	end)
	Launch.MouseEnter:Connect(function()
		if not busy then TweenService:Create(Launch, TweenInfo.new(0.12), { BackgroundColor3 = T.White }):Play() end
	end)
	Launch.MouseLeave:Connect(function()
		if not busy then TweenService:Create(Launch, TweenInfo.new(0.12), { BackgroundColor3 = T.Accent }):Play() end
	end)
	Launch.MouseButton1Click:Connect(function() launch(entry, Launch) end)

	table.insert(cardRefs, { entry = entry, desc = Description, badge = Badge, launch = Launch })
end

for index, entry in ipairs(Games) do createGameCard(index, entry) end

----------------------------------------------------------------------
-- Apply / refresh
----------------------------------------------------------------------
local function refreshSession()
	SessionText.Text = L("scripts") .. "   " .. tostring(#Games)
		.. "\n" .. L("state") .. "   " .. L("ready")
		.. "\n" .. L("build") .. "   " .. (Config.Mobile and L("mobile") or L("desktop"))
end

applyTheme = function(name)
	Config.Theme = name
	loadTheme(name)
	for _, item in ipairs(ColorReg) do
		pcall(function() item.obj[item.prop] = T[item.role] end)
	end
	themeButton.Text = Config.Theme
	refreshNav()
	setStatus(statusKey or "ready", statusRole)
	saveConfig()
end

applyLanguage = function(code)
	Config.Language = code
	for _, item in ipairs(TextReg) do
		pcall(function()
			item.obj.Text = item.upper and string.upper(L(item.key)) or L(item.key)
		end)
	end
	for _, ref in ipairs(cardRefs) do
		ref.desc.Text = ref.entry.desc[Config.Language] or ref.entry.desc.EN
		ref.badge.Text = Config.Mobile and string.upper(L("mobile")) or string.upper(L("desktop"))
		if not busy then ref.launch.Text = L("launch") end
	end
	langButton.Text = Config.Language
	buildButton.Text = Config.Mobile and L("mobile") or L("desktop")
	refreshSession()
	setStatus(statusKey or "ready", statusRole)
	saveConfig()
end

switchTab = function(key)
	activeTab = key
	LibraryPage.Visible = (key == "library")
	SettingsPage.Visible = (key == "settings")
	PageTitle.Text = (key == "settings") and L("settings") or L("pageTitle")
	refreshNav()
end

local function cycle(list, current)
	for index, value in ipairs(list) do
		if value == current then return list[(index % #list) + 1] end
	end
	return list[1]
end

themeButton.MouseButton1Click:Connect(function() applyTheme(cycle(ThemeOrder, Config.Theme)) end)
langButton.MouseButton1Click:Connect(function() applyLanguage(cycle(LangOrder, Config.Language)) end)
sizeButton.MouseButton1Click:Connect(function()
	local steps = { 0.85, 0.925, 1, 1.075, 1.15 }
	local nextScale = steps[1]
	for index, value in ipairs(steps) do
		if math.abs(value - Config.Scale) < 0.01 then nextScale = steps[(index % #steps) + 1] break end
	end
	Config.Scale = nextScale
	RootScale.Scale = nextScale
	sizeButton.Text = math.floor(nextScale * 100 + 0.5) .. "%"
	saveConfig()
end)
buildButton.MouseButton1Click:Connect(function()
	Config.Mobile = not Config.Mobile
	buildButton.Text = Config.Mobile and L("mobile") or L("desktop")
	for _, ref in ipairs(cardRefs) do
		ref.badge.Text = Config.Mobile and string.upper(L("mobile")) or string.upper(L("desktop"))
	end
	refreshSession()
	saveConfig()
end)

----------------------------------------------------------------------
-- Drag + close
----------------------------------------------------------------------
do
	local dragging, startPointer, startPosition
	Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; startPointer = input.Position; startPosition = Main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - startPointer
			Main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
		end
	end)
end

Close.MouseEnter:Connect(function()
	TweenService:Create(Close, TweenInfo.new(0.12), { BackgroundColor3 = T.Hover, TextColor3 = T.White }):Play()
end)
Close.MouseLeave:Connect(function()
	TweenService:Create(Close, TweenInfo.new(0.12), { BackgroundColor3 = T.Elev, TextColor3 = T.Muted }):Play()
end)
Close.MouseButton1Click:Connect(function()
	if not ScreenGui.Parent then return end
	TweenService:Create(OpenScale, TweenInfo.new(0.16), { Scale = 0.94 }):Play()
	TweenService:Create(Main, TweenInfo.new(0.16), { BackgroundTransparency = 1 }):Play()
	task.delay(0.18, function() if ScreenGui.Parent then ScreenGui:Destroy() end end)
end)

----------------------------------------------------------------------
-- Boot
----------------------------------------------------------------------
applyLanguage(Config.Language)
applyTheme(Config.Theme)
switchTab("library")
refreshSession()
setStatus("ready", "Muted")

TweenService:Create(OpenScale, TweenInfo.new(0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
	Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 0.04,
}):Play()
