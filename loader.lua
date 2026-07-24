-- INERTIA loader — pick a game, it runs.
-- One black theme, game icons, nothing else. The mobile build is chosen
-- automatically on touch-only devices, so there is no switch to get wrong.

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

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
	BG = Color3.fromRGB(0, 0, 0),
	Card = Color3.fromRGB(11, 11, 12),
	Elev = Color3.fromRGB(18, 18, 20),
	Hover = Color3.fromRGB(28, 28, 31),
	Border = Color3.fromRGB(34, 34, 37),
	White = Color3.fromRGB(255, 255, 255),
	Text = Color3.fromRGB(233, 233, 235),
	Dim = Color3.fromRGB(112, 112, 117),
	Good = Color3.fromRGB(120, 210, 150),
	Bad = Color3.fromRGB(226, 96, 96),
}

local function corner(object, radius)
	local value = Instance.new("UICorner")
	value.CornerRadius = UDim.new(0, radius or 8)
	value.Parent = object
	return value
end
local function stroke(object, transparency)
	local value = Instance.new("UIStroke")
	value.Color = T.Border
	value.Thickness = 1
	value.Transparency = transparency or 0.4
	value.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	value.Parent = object
	return value
end
local function text(parent, value, size, color, font)
	local label = Instance.new("TextLabel")
	label.Parent = parent
	label.BackgroundTransparency = 1
	label.Text = value or ""
	label.TextSize = size or 12
	label.TextColor3 = color or T.Text
	label.Font = font or Enum.Font.Gotham
	return label
end

-- Touch-only (phone / tablet) gets the button-driven build automatically.
local MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local REPO = "https://raw.githubusercontent.com/Yanderov/lib/refs/heads/main/"

local Games = {
	{ name = "Murder Mystery 2", icon = 142823291, file = "mm2" },
	{ name = "Demonology", icon = 6735515785, file = "demonology" },
	{ name = "Pressure", icon = 12411473842, file = "pressure" },
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
Main.Position = UDim2.new(0.5, 0, 0.5, 10)
Main.Size = UDim2.fromOffset(462, 250)
Main.BackgroundColor3 = T.BG
Main.BorderSizePixel = 0
Main.Active = true
corner(Main, 14)
stroke(Main, 0.24)

local Scale = Instance.new("UIScale")
Scale.Scale = 0.94
Scale.Parent = Main

local Header = Instance.new("Frame")
Header.Parent = Main
Header.Size = UDim2.new(1, 0, 0, 44)
Header.BackgroundTransparency = 1
Header.Active = true

local Brand = text(Header, "INERTIA", 14, T.White, Enum.Font.GothamBold)
Brand.Position = UDim2.fromOffset(18, 0)
Brand.Size = UDim2.fromOffset(120, 44)
Brand.TextXAlignment = Enum.TextXAlignment.Left

local Close = Instance.new("TextButton")
Close.Parent = Header
Close.AnchorPoint = Vector2.new(1, 0.5)
Close.Position = UDim2.new(1, -14, 0.5, 0)
Close.Size = UDim2.fromOffset(26, 26)
Close.BackgroundColor3 = T.Elev
Close.BorderSizePixel = 0
Close.AutoButtonColor = false
Close.Text = "×"
Close.TextColor3 = T.Dim
Close.TextSize = 18
Close.Font = Enum.Font.GothamMedium
corner(Close, 7)
stroke(Close, 0.46)

local Status = text(Main, MOBILE and "mobile build" or "", 9, T.Dim, Enum.Font.Gotham)
Status.AnchorPoint = Vector2.new(0.5, 1)
Status.Position = UDim2.new(0.5, 0, 1, -10)
Status.Size = UDim2.new(1, -32, 0, 14)
Status.TextXAlignment = Enum.TextXAlignment.Center

local Row = Instance.new("Frame")
Row.Parent = Main
Row.Position = UDim2.fromOffset(16, 48)
Row.Size = UDim2.new(1, -32, 0, 158)
Row.BackgroundTransparency = 1
local Grid = Instance.new("UIListLayout")
Grid.Parent = Row
Grid.FillDirection = Enum.FillDirection.Horizontal
Grid.SortOrder = Enum.SortOrder.LayoutOrder
Grid.Padding = UDim.new(0, 11)

local busy = false

local function closeWindow()
	if not ScreenGui.Parent then return end
	TweenService:Create(Scale, TweenInfo.new(0.16), { Scale = 0.95 }):Play()
	TweenService:Create(Main, TweenInfo.new(0.16), { BackgroundTransparency = 1 }):Play()
	task.delay(0.18, function() if ScreenGui.Parent then ScreenGui:Destroy() end end)
end

local function launch(entry, tile, label)
	if busy then return end
	busy = true
	label.Text = "..."
	Status.Text = "starting " .. entry.name
	Status.TextColor3 = T.Text
	task.defer(function()
		local url = REPO .. entry.file .. (MOBILE and "_mobile" or "") .. ".lua"
		local ok, source = pcall(function() return game:HttpGet(url) end)
		if not ok or type(source) ~= "string" or #source == 0 then
			busy = false
			label.Text = entry.name
			Status.Text = "download failed"
			Status.TextColor3 = T.Bad
			warn("INERTIA loader: " .. tostring(source))
			return
		end
		local ran, err = pcall(function() loadstring(source)() end)
		if not ran then
			busy = false
			label.Text = entry.name
			Status.Text = "execution failed"
			Status.TextColor3 = T.Bad
			warn("INERTIA loader: " .. tostring(err))
			return
		end
		Status.Text = entry.name .. " started"
		Status.TextColor3 = T.Good
		task.wait(0.3)
		closeWindow()
	end)
end

for index, entry in ipairs(Games) do
	local tile = Instance.new("TextButton")
	tile.Name = entry.name
	tile.Parent = Row
	tile.LayoutOrder = index
	tile.Size = UDim2.fromOffset(136, 158)
	tile.BackgroundColor3 = T.Card
	tile.BorderSizePixel = 0
	tile.AutoButtonColor = false
	tile.Text = ""
	corner(tile, 12)
	local tileStroke = stroke(tile, 0.42)

	local icon = Instance.new("ImageLabel")
	icon.Parent = tile
	icon.Position = UDim2.fromOffset(11, 11)
	icon.Size = UDim2.fromOffset(114, 114)
	icon.BackgroundColor3 = T.Elev
	icon.BorderSizePixel = 0
	icon.Image = "rbxthumb://type=GameIcon&id=" .. tostring(entry.icon) .. "&w=420&h=420"
	icon.ScaleType = Enum.ScaleType.Crop
	corner(icon, 10)
	stroke(icon, 0.5)

	local name = text(tile, entry.name, 11, T.Text, Enum.Font.GothamMedium)
	name.Position = UDim2.fromOffset(8, 128)
	name.Size = UDim2.new(1, -16, 0, 20)
	name.TextXAlignment = Enum.TextXAlignment.Center
	name.TextTruncate = Enum.TextTruncate.AtEnd

	tile.MouseEnter:Connect(function()
		TweenService:Create(tile, TweenInfo.new(0.13), { BackgroundColor3 = T.Hover }):Play()
		TweenService:Create(tileStroke, TweenInfo.new(0.13), { Color = T.White, Transparency = 0.24 }):Play()
	end)
	tile.MouseLeave:Connect(function()
		TweenService:Create(tile, TweenInfo.new(0.13), { BackgroundColor3 = T.Card }):Play()
		TweenService:Create(tileStroke, TweenInfo.new(0.13), { Color = T.Border, Transparency = 0.42 }):Play()
	end)
	tile.MouseButton1Click:Connect(function() launch(entry, tile, name) end)
end

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
	TweenService:Create(Close, TweenInfo.new(0.12), { BackgroundColor3 = T.Elev, TextColor3 = T.Dim }):Play()
end)
Close.MouseButton1Click:Connect(closeWindow)

TweenService:Create(Scale, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
	Position = UDim2.fromScale(0.5, 0.5),
}):Play()
