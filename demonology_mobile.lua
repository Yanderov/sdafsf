-- DEMONOLOGY — MOBILE BUILD (generated, do not edit by hand).
-- Identical source to demonology/demonology.txt with the build flag forced on.
-- Regenerate after ANY edit to the source:   .\build_mobile.ps1
_G.INERTIA_MOBILE = true
--=====================================================================
--// DEMONOLOGY - evidence tracker & automation (shared INERTIA UI)
--=====================================================================
local RS = game:GetService("RunService")
local PS = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local plr = PS.LocalPlayer
local MenuKeybind = Enum.KeyCode.Insert

--=====================================================================
--// BUILD MODE (PC / MOBILE)
--=====================================================================
-- The launcher's PC/MOBILE switch sets _G.INERTIA_MOBILE before running this
-- file, and that flag always wins: auto-detect alone is wrong on tablets with a
-- keyboard, on emulators and on touchscreen PCs.  Without a launcher we fall
-- back to "touch, no keyboard".
local MOBILE = _G.INERTIA_MOBILE
if MOBILE == nil then MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled end
MOBILE = MOBILE == true

-- Every measurement that has to differ between a mouse pointer and a fingertip
-- lives here, so the layout code below stays ONE code path instead of two
-- parallel UIs.  Touch targets follow the 44px minimum.  Window sizes are Scale
-- based on mobile (see relayout), never fixed pixels.
local M = MOBILE and {
	rowH = 48, rowFont = 15, rowGap = 10,
	trackW = 54, trackH = 30, knob = 24,
	sliderH = 70, barH = 12, grab = 22,
	btnH = 50, cycleW = 132, cycleH = 36,
	titleH = 62, navH = 68, navItemW = 92,
	sectionPad = 12,
} or {
	rowH = 36, rowFont = 14, rowGap = 8,
	trackW = 46, trackH = 24, knob = 18,
	sliderH = 48, barH = 6, grab = 16,
	btnH = 38, cycleW = 130, cycleH = 26,
	titleH = 48, navH = 34, navItemW = 0,
	sectionPad = 16,
}

local function Events()
	return ReplicatedStorage:WaitForChild("Events")
end

-- Forward Declarations
local Main
local cleanESP
local makeElementDraggable
local mouseUnlockToggle

-- Shared State
local S = {
	Connections = {},
	CheckSpeed = 1,
	LightsOn = false,
	EscapeHunt = false,
	AutoHide = false,
	AutoSpiritBox = false,
	PlayersEsp = false,
	ItemEsp = false,
	EvidenceEsp = false,
	FuseEsp = false,
	ExitEsp = false,
	DoorEsp = false,
	HidingEsp = false,
	InteractableEsp = false,
	Ready = false,
	GhostEspOn = false,
	HuntsCount = 0,
	UITheme = "Default",
	UITextScale = 1,
	HUDScale = 1,
	NotificationPosition = "Top Center",
}
local hudLocked = false
local MouseUnlocked = false
local FlySpeed = 50
local Flying = false
local WalkSpeedEnabled = false
local TargetSpeed = 16

local function tc(conn)
	table.insert(S.Connections, conn)
	return conn
end

local THEMES = {
	Default = {
		BG=Color3.fromRGB(3,3,3), Sidebar=Color3.fromRGB(4,4,4), Card=Color3.fromRGB(8,8,8), Elev=Color3.fromRGB(13,13,13),
		Hover=Color3.fromRGB(19,19,19), ActiveBg=Color3.fromRGB(26,26,26), Bd=Color3.fromRGB(20,20,20), Bd2=Color3.fromRGB(40,40,40),
		White=Color3.fromRGB(255,255,255), Tx=Color3.fromRGB(238,238,236), Tx2=Color3.fromRGB(214,213,210), Tx3=Color3.fromRGB(180,179,175), Tx4=Color3.fromRGB(154,153,149),
		Accent=Color3.fromRGB(216,215,211), Glow=Color3.fromRGB(145,144,141), TgOff=Color3.fromRGB(29,29,29), TgOn=Color3.fromRGB(176,176,174),
		KnobOff=Color3.fromRGB(137,136,133), KnobOn=Color3.fromRGB(250,249,246), AccentSoft=Color3.fromRGB(72,72,71),
	},
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
	local source = THEMES[name] or THEMES.Default
	for key in pairs(T) do T[key] = nil end
	for key, value in pairs(source) do T[key] = value end
	T.TgOff = source.TgOff or T.Bd2:Lerp(T.Card, 0.35)
	T.TgOn = source.TgOn or T.Accent
	T.KnobOff = source.KnobOff or T.Tx2
	T.KnobOn = source.KnobOn or T.White
	T.AccentSoft = source.AccentSoft or T.Accent:Lerp(T.Card, 0.68)
	T.Good = T.Accent
	T.Bad = Color3.fromRGB(255, 92, 92)
	T.Warn = Color3.fromRGB(255, 192, 88)
	return THEMES[name] and name or "Default"
end
S.UITheme = loadPalette(S.UITheme)
local F  = Enum.Font.Gotham
local FM = Enum.Font.GothamMedium
local FB = Enum.Font.GothamBold

-- UI Helpers
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
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
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
	p.PaddingTop = UDim.new(0, t or 0)
	p.PaddingBottom = UDim.new(0, b or 0)
	p.PaddingLeft = UDim.new(0, l or 0)
	p.PaddingRight = UDim.new(0, r or 0)
	p.Parent = i
	return p
end
local function Shadow(i, transparency)
	local s = Instance.new("UIStroke")
	s.Color = T.Bd2
	s.Thickness = 2
	s.Transparency = transparency or 0.6
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	s.Parent = i
	return s
end

-- Lucide navigation icons (ISC): https://github.com/lucide-icons/lucide
local NAV_ICON_DATA = {
	["search-check"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAADEElEQVRoge2ZO09UQRiGvyHQAPVqIiZy+Q9rwg8wgQoLkEukgc5G/R2gNlATNRCDBV6IFrK1v0A7aCjcUsNmicBjceYkh29n9lx2zgph32SK2Z153/ebM2cu3xHpoYebDdMpATAkIg9EZEpERkXkji0iIse2HIrIvoh8McY0OtUMAqAKvAcaZEfD9qn+T+NjwE4O0z7sAGPdNr8KnAYwH+MUWO2G8X7glcfEGXAAPAUmgXFg2JZx+9sz2+bMw/ES6C/T/AeHaBNYAyo5uCq2T9PBt1dKEHZ0NGrASAecI5ZD40VI7/Gc19gABgJwDwCbDv6VEN7j1Ua/sBtByC/r6CBOgdEQxHqpPAgx8g6dAcd02u6U9L4ibNLBnM+gN0Lri118syPaLZNYC+jXp7muNHeLEg1x+XjwlxxLZRveWaBuy4zj/wqX94kTYLCI0EM99wOYXwLOE5x1Tzv9LrQEqtHn+G1K1T8VMZ0wtSQiWx4tjY+qPp3WwUWql7DvGYSd8Ji/EJEnni5a614R0Z/qMY572s0k5vSsy7yaNtj6UhvtCdX+R5EA/iiSYU+7us9YEfO237Dq8zvNb6jDU5+IbAFx3TVtlo0xbwLp+ZFjCs06RtmF1JFPcOaeQq6X+FjVb7s6GmPeiciyRKPrQ96Rv5XipQWuAA5V3bulW2O+IIpMG611lKNvBApsZI6XNvO0UTw1pZ26kblI9FHijAxHCWAO+GXLXAHdMEcJS3Z9D3OWrKrIyj5O3yXkcdqS6gtNjetyobHEpV8pAQN8UxphrpRWwHWp3wzxJOzIa/MQ6lKfEOpmWuUCeBTSf5zY2nOINYlWjryJrXXcia0Y58B8GUG4ngREa3eNKH04SXSeiVOLE/a357aNL7V4UXoQNpAykrsrwDzu4/dCGUGMAtsBzG+TWG2Aha4FYQWrwC7Rlp8VJ7aPc5NqE8Siz0eIT0yDEn1impboDuv6xHQkIp9F5GvaJyY74q+l9UL02BjztlO/XQGw6HkSLXfvKwtPEM580pUFGRNiVxqkpCR76OGm4x9F0gpf3g8C9gAAAABJRU5ErkJggg==",
	["ghost"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAACW0lEQVRoge2YvW7UQBSF76BsQ0KbJluQ5CGCxAMghYqVUJpFNOQB4AV4ggRoQk1FCij4EaIKNU9BhYRpkCCsdkXYL8XOSvZlxju2xx4h+UiW1vaZc+6xrsczK9IjLUwsIWBdRG6JyL6IbIvIlj1ERL7a44uIfBCRj8aYSSzvRgD2gNfAhHBM7Ji9lIXvAKcVivbhFNjpuvhDYBah+CVmwGEXha8BzzxFXABnwEPgJrALbNhj1157ZDkXHo2nwFqbxb91mE6BI2CzgtamHTN16L1pJYR9OhqfgGEDzaHV0HgSs/Zlz2ucAIMI2gPguUP/QYzal7ONfmFPoogXfXSIGbAdQ1hPlWcxnrzDZ+Bop5dNRW8owSkNej7Ab8i/L3b9jx2Lr2UeRxHr9XkeK89XdYXWKS4P/lBhqqwLFlNs/jvxG7haR2ike7+Fen3e+l244+NeKdHZV+fv45QXhHfq/LaPWBZAT2Gfa5dTHdrruo9YFmBLnX9zkWyrZcB34O6qygL52YpaVgP4pfpww8PLcpwfQNlDCeKzWADm8dOnV2ZWKNgYc15WWEw4vK5VFlFPgBJeGy0U7O/dE+tBxpho++cQhPqX9uv/gD5AavQBUqMPkBp9gNToA6RGHyA1KgcADuxyOAMed8WrDNd6HBgDf9WtsWNsY17ofiA4gMcMe22cGxeFFxogeEMjInPxt9xcRO7b3y8i8Qr3fBuaKgGSIuaObC4i9+wx75BXDY7ebK3fA3hRXuKCWYlpbF7tANkqsxw3P5cfRODpEPqfuqAAoxCztqDCjrr27xGKS3Ij99QOg5VTAAAAAElFTkSuQmCC",
	["workflow"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAABQElEQVRoge2YPbLCMAyEZSpShHuRQ3EB+vc4Dy3HoQjdUmAYY/JnBVliRl+XjKXszjiONkSO44wCoANwBtBjnj6u7bR1E4AGwGmB6DH+ATSaBtaIf5nQEt99QfyT+tsJj32ccgTQLqhr49qUcw3NuZD8hZ0Vn9S2WW0vqZWIKAyIwNuCED7WTLG2vpSNZPMauAFt3IA2bkCbIQO39KL0QzbVS4IhA5fs+rB0lCCiw0wvefDdYW5f3UA08bvjdDTQ4BFKuPxBM9AkRjiRUmfbLCVXXVirn7E5BmApYzMN2DkUSg3AWsZmGLCVsRkGRDN2cV6NTbbJrV0I4TqxXjRjc6ZR1qxkBqx8KRnPW1U/1pR9LFoxwJ6VTBhImpeMBiIGRP+aPQW8PdDAKWSKGgZEM3YNA56xEzxjcw14xnYcZ5g7XVGu8/zX9zgAAAAASUVORK5CYII=",
	["scan-eye"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAACsElEQVRoge2Zz2oUQRDGa8TLRvcSFKK+QPYS/HORqJAoKK6XkCcwGh9CD3kBbxsweQkNmJPejB4ke8lLGIgR1E1gAwn5eZgK6e3tmenZ6f2H88HCzkzVV18ttTXV3SIlSpRIBFAHtoA23dgDFgPEWFQuG22NXe+FtAKsO0i7kgiQgEu8jTWgkofUR/wgEwBY8yWs+4qnvyXkQnY5EdedibdAtajQvACqGtvElo+j/YcduHhDS9XS0rZtIocTHQZR1GUzSGTpuTBYOeFxMRSRltpjEXkgIndF5LqIXNHHv0RkV0S+i8hXEfkcRdFBqNi2kA542NeI2+6BZydBbdeBWmg9dl9O7PPAJLAKnOQQbuNEOSaL6jEdzvpyYp8H7gG7BYTb+AHM9qonF4Bl4DhByDbwGpgDbhCPJBX9PqfPthN8j4GXhQVmiH+REPwjMJODZ0Z9XFjql/hnwKkV7C+wUIBzQTlMnNLLBJoR6BqwbwXaA6YDcE/TPQv9BKZCaD8L8sEKcAjcTLG/RNxdWvppABMp9reU08T7UOLvOOp0OUP8jsNnJyOJVw6f2yES2LBIvwCJ85H+8klYTfGLlNvERogE/likDzPsWykJtDJ8H1n2v7P0jf0wl4nAJdRI8etbCY33n1jJ87bRCeLWOfw2qgGmiF8uJsbnRaaBxneUMAIuOeoUYJP8w9xmAtfzvog3gqeN003gDTBP9zg9r8+aCb5hxmn8FjSzxIuQUAi3oCHfkrJB8SVlg8BLyg542NeIN1/zLOpb6lN4UR9sYwu4LCJPROS+nG+rXNXH+3K+rfJNRD5FUXToyZuqp9yZGzZcCRyZFwx5c9e6dWTbuBJoWtcrw0hCY65Yt21tTsdRPuB46ks6vkdMSloh7tOjksA78hzyGeSjcMzqVzYlSvyn+AemqJB9pScXYgAAAABJRU5ErkJggg==",
	["footprints"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAAD5klEQVRoge2Yu29cRRTGvzGvGNgYCUEAIx5FOkMDEsYBFCEgJA1EiIY/gVDwEG0qWgoKCBiQUiNAbihSIeKYxgaEQgMSoYp4RMiRhTDEsX8Ud9ea/XbuzL3GuwtSvmrP3O+cOWde38xKV/A/AjAHnASWgVXgIrACvA5MjTu/WgD7gSXyOAfMjDvXAQCHuyPdBOeBW8ed8zaAWeDvhsn3MD/uvCVJwL7uiMa4BLwHPABcB9wIHAM2I84f/Bf2A/CBJX8BOFDDnTfui6PO1xOasVG9DDya4R+yAhZGmW8qoQ8tobcK/GnjfzOqXFPJXA+sRclsAHcUfCatgIsF/hSVdqxQnXCrVNpyEpj7twUctWRONfC5wXzWM9wZKs3IYQnY3yTfiUSbb9TPGsTxs3+1Jvl9kk5JurcQb07SMnC41HGqgIfMbrKefbQu1PDekJRdjhGmJC0Ank8fUgXcbfYPDTp72OyzTqDShheipi1JL0nqSNoj6UFJ85I2Is61kj6ljbpTiVWMqxv4nDGf1xKcY8ZJKjZwgEpzYrzfpoB1c+4U+H6EAtyX4C0Y56lMzMfo16FNai6KqSX0u9nTuQIkPWf2OUnfJXj3mJ3iSJJCCKclvR01TUh6uZBHBeBbG6knCvxF479Zw/Mb7WQh7jSVBvWwlvJJzYCfIL5B405u1+CxW3eN2NOg722EEM5L+jxq6kg65LxUkK/MHnCK8IykENm/SfqyhuvacEsmbg+uQQOXyVQBX5g9S/31+KjZH4cQNmu4PrNNlNY1aNYJqQLOSLoc2VdJOugk4CZJj1vzR5lkXBtql2aE782+ywkDBYQQ1iQtWnNqIz8tKdaIX1QVX4evzX4yw+3BT8TbGvhIwKuJs72E7FMSuN/4W5RvuXvN50/n1J0EK40q7YfPmuOspJ8iO2hQQxyuQT4jtQX8WAicgi+RPoQQ0OAR+3wh5p1mNy7g50Lgnfp4AY8AuXXtG33glpssIISwlWjrQ8It+wrrYkmVVmyHVaUldXANco3Kq2EbpIpOcDYlfWLNriWStq/f/hZwjaqHHzFtv2fiHjTXSymhBJ413gaw13m7NgMtsCjp18i+RpWmOFx7Frsa1Qxk3gVAx77VPuJrYvsfYU3wSipWbgaWzT7eTbwj6XiBW0JOsevQTpuAIy1Gp/jvgcWe2cEMNP0zoK+jdxsEPrGDuDfvoIDU0V3saBI4kQn6DoWXVU3cCQ+U4GS/t+3wCHCaamOvd3+3WjZtE2xaQPtp2SV4Uq7upe89jEMHdhXjLOCv2MB0JseNMc4ChqkzwwdD1JmRgSHpzMjAkHRm5GAIOnMFo8I/gRRKTmfTyMsAAAAASUVORK5CYII=",
	["map-pin"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAADzUlEQVRoge2ZuWsVURTGzzMLIQkICmI0TRJRglopRkyRRnFBcSlU0FIt4ob+AdooBCEujTZWLtFCCxdERGMnWGiaB4oBRUHraBZeFvlZzJ0wOXPvfXnz7str/GCKO/Od73xn3p27PZH/qC5yoYSAJhHZLiK7RKRNRFaaS0Tkp7m+icgLEXmZy+UmQuUuC0AX8BiYYP6YMDFd1TTeDjwswbQLD4H2hTZ/HJgMYD7GJHB8IYzXAjccJmaAQeAc0A10AM3m6jD3zhvOjEPjOlBbSfNPLUkLQD+wrAStZSamYNF7UpEizNvReAu0lqHZajQ0roX0Hvd5jZtAXQDtOuCWRf9YCO/xaKM/2JtBxOfm0UVMAm0hhPVQORjizVvy1Fm604NyRTcrwQJF+jzQAvQBeWDKXHlzr6VIbCvpDzv7ZEc0WybR7+HmgJPAGG6MGY5zCQNcVTGPsppvYu7yYBrHUGnM68Q+XHUVQTTEJueJcaAxSwEHVNJBD/dkCeZj9Hr03iru/iwF3FYi5x28FtLd5j3QAzSYq8fcS2IUxzdBNGMncTtLAW+USLeD12cxX2Ph1ViK6HNodive6ywFfFYiHQ5eXvF6PJo9ipt38FYp3qcsBYwqkWYHb0rxGjyaDYo75eA1K94fl+YiTw31ql3wcEND59JeZuErYES1XavNL6rtm3j0Mx3ryqW9zMJXwHfVXufgPVftKzg+YhG5UiQ2xvoiXmbhK2BItTc7eDdEZDzR3iQi71DDqIi8M89ijJlYG3Qu7aU4gIN6JMA9ewabyIhm9U+KezBLAY2kJ6gNnqSlLCX6PS9jo+KOkmUpYcTuKzHXTx4X0Ut6+NVmel3mjY7ec9/LZN6I7VFiY8DyIjHlLKeXk/7Vd5dTQB0wrASD78YS+fSubJhyN0/AYSU6A6wO5DmZZw3p45ZDIYQXAUNK+BXgG4Kz5HilcgwFywHsJI0zQcQj/bMW/Z2h9OMkenNfANYG0F1Heh9c3mbekWgp8EslygOLy9BcTHo5/gtYEtJ7MqGtK70GnKtFj1Y90RGNxo5KeE8mth0x3sEzOVk0csBdi871SnqPk9cCzyzJL5WgcdkS/xTLKrYiINoxfbSYODGP2BOWuA84dnwVA7AC+KGMzAB7PTH7gL8q5gdFlhgVA7Ae+G0p4oiFe5T0TPsbcG2UFgbANqJTO41TCc5py/NpYGs1vc8COGLpGgAXgIuW+9ZfqaoA9jO/P/4myXJUuBAw3WncY34c2FZtn14QHQuOWMyPAFuq7W9eADqBAeCruQaAzmr7+o9K4B/zGryOBIgdTQAAAABJRU5ErkJggg==",
	["wrench"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAAC8ElEQVRoge2YQUgUURjH/yNSEERFhBSBKGkIRUEXkY5SkAVCZYLHBK+Bh64ldAvqEhRBUGR0C6JbBoJSFlFdhBLyVEknEy2SXH8d5m1Mn29mR93dmYX9wx5mvv+87/fevLfveyPVla2CaiYDOiT1SDouqV3SPhdalDQjaUrS9SAI5qvJlSggAHqBV6TTF2BP1tySJKAFmEgJHtVI1uwCTgI/SoAWYu6Pp83TUCH4HklPJe0woRVJ9ySdltQmaaukIU8T3yrBlUpAG7DkGdVRoNl4+z1voQAczQq+AZjywF8BAuONg+/PBN5B9Xnghz2+/ME7sA8GamyzIw8cAR4B48AIlfqLBQ4ZqJ9Ai/F0rhPe19mvwK5KdOCySXTf45ncJHxR1yrRgScmyXkTbzRAG4UHGCt6y7kPtJvr5yX83tyuU6NxcaeD6+BKJ2AuMkILMZ7EKRQz8gVgyNwrf7EHfI8kWIzxxC7iBPh+1k6/inTgo0m+P8YXB2r17+0AB0xsutheOdfArLnu8ZmCIHgsaUDSauS25ViVNOC80to5PxP34Gb01lyfiTPGdKIoCy9JZ41nckOESQJumtf8G9hS4plOwoVdcL9JoNN4moE/pu2OcsP75vUC0Jjy+Uafl/A0N2ranaoGfAG4UIa2r3oWd285uIsJKlJVupEf9sBPYIrDqsG7aZK4JpyvFXjhgZ/HFIfVhO8jXBNFDQJ7I/GdzvOAsIq1WgZOZAWfVJgtupFN0hJwKo/wafQGsEViTcC/J5xSJTfaVCsaf4nr2zFL+W9JWpJ0TFKrws8uK5LmJX2S9FrSsyAIplUulWnkszmw1+Hr8BtQrcN31zL8NmC2JuEd0KWahXdQDw3QYIwvf/AO7F0EaA5P3Z1beAc3FoFaBppMPL/wkgTcMHAvgSbC09HFXMNLEtDFWi3z/yfDfMIXBdzxwNYGvCQB24HbCfCfge6sOaPyngeALknnJB2WtFvStMIvb3eDIPhVPby68q+/skEi4gAI/58AAAAASUVORK5CYII=",
	["panels-top-left"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAAA8klEQVRoge2ZQQ6DIBREsenOy9XzuPcYchp3vZBupgvbhP5iUKMMpvN2mk+cFz6SgHNCiEUANAAGACPyM76/3ewJXgPwhNBLeAD1FgHPzRul39I2pZJuJ8x9F9Jhy/QdBOY27kyWYc1Au2Czhw+y1CbLaGuqyCB8FVTVT01OUnlueeMcjwTYSIDNPVVg/wKlcfkZkACb5BpI7cRn79ypNXj5GZAAGwmwkQAbCbCRABsJsJEAGwmwiQlM4QP7cNe8mmxNTOBpnlvW8bpzrjWvbbbowJIvOB5r7T07aYR1V0yf6QPQsxMH9NjTxrjqNasQf8QLDxQVmh4AoMEAAAAASUVORK5CYII=",
}
local NAV_ICON_CACHE = {}

local function decodeNavIcon(data)
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

local function MakeNavIcon(parent, kind)
	local data = NAV_ICON_DATA[kind]
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
		local ok = pcall(writefile, path, decodeNavIcon(data))
		if not ok then return nil end
	end
	local asset = NAV_ICON_CACHE[kind]
	if not asset then
		local ok, result = pcall(getter, path)
		if not ok or type(result) ~= "string" then return nil end
		asset = result
		NAV_ICON_CACHE[kind] = asset
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


-- Root GUI Setup
local SG = Instance.new("ScreenGui")
SG.Name = "Demonology"
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.ResetOnSpawn = false
SG.DisplayOrder = 2147483647
SG.IgnoreGuiInset = false
pcall(function() SG.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets end)

if RS:IsStudio() then
	SG.Parent = plr:WaitForChild("PlayerGui")
else
	local ok = pcall(function()
		SG.Parent = (gethui and gethui()) or (syn and syn.protect_gui and syn.protect_gui(SG)) or game:GetService("CoreGui")
	end)
	if not ok then
		SG.Parent = game:GetService("CoreGui")
	end
end
S.Gui = SG

-- Toast Notification System
local NHost = Instance.new("Frame")
NHost.Name = "Notifs"
NHost.Parent = SG
NHost.AnchorPoint = Vector2.new(0.5, 0)
NHost.BackgroundTransparency = 1
NHost.BorderSizePixel = 0
NHost.Position = MOBILE and UDim2.new(0.5, 0, 0.08, 0) or UDim2.new(0.5, 0, 0.04, 0)
NHost.Size = MOBILE and UDim2.new(0, 260, 0, 240) or UDim2.new(0, 360, 0, 240)
NHost.ZIndex = 900
local nLayout = Instance.new("UIListLayout")
nLayout.Parent = NHost
nLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
nLayout.SortOrder = Enum.SortOrder.LayoutOrder
nLayout.Padding = UDim.new(0, 8)

local refreshSB
local openAppearance
local UIStyle = {
	BackgroundRoles = { "BG", "Sidebar", "Card", "Elev", "Hover", "ActiveBg", "Bd", "Bd2", "Tx3", "Tx4", "TgOff", "TgOn", "KnobOff", "KnobOn", "Accent", "White" },
	TextRoles = { "White", "Tx", "Tx2", "Tx3", "Tx4", "Accent", "Good", "Bad", "Warn" },
	StrokeRoles = { "Bd", "Bd2", "Accent", "White", "Tx", "Tx2", "Tx3", "Good", "Bad", "Warn" },
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
	for _, object in ipairs(SG:GetDescendants()) do
		if object:IsA("GuiObject") and not object:GetAttribute("StaticThemeColor") then self:ReplaceColor(object, "BackgroundColor3", oldPalette, self.BackgroundRoles) end
		if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
			self:ReplaceColor(object, "TextColor3", oldPalette, self.TextRoles)
			if object:IsA("TextBox") then self:ReplaceColor(object, "PlaceholderColor3", oldPalette, self.TextRoles) end
		elseif (object:IsA("ImageLabel") or object:IsA("ImageButton")) and not object:GetAttribute("StaticThemeColor") then
			self:ReplaceColor(object, "ImageColor3", oldPalette, self.TextRoles)
		elseif object:IsA("ScrollingFrame") then
			self:ReplaceColor(object, "ScrollBarImageColor3", oldPalette, self.TextRoles)
		elseif object:IsA("UIStroke") then
			self:ReplaceColor(object, "Color", oldPalette, self.StrokeRoles)
		elseif object:IsA("UIGradient") and object.Parent and object.Parent:IsA("GuiObject") then
			if object.Name == "HUDHeaderGradient" then
				object.Color = ColorSequence.new(T.White:Lerp(T.Accent, 0.14), T.White:Lerp(T.Card, 0.06))
			elseif object.Name == "QuickStatusGradient" then
				object.Color = ColorSequence.new(T.White:Lerp(T.Accent, 0.16), T.White:Lerp(T.Elev, 0.08))
			elseif object.Name == "DynamicIslandGradient" then
				object.Color = ColorSequence.new(T.White:Lerp(T.Accent, 0.14), T.White:Lerp(T.Card, 0.08))
			else
				object.Color = ColorSequence.new(T.White:Lerp(T.Accent, 0.12), T.White:Lerp(T.Elev, 0.08))
			end
		end
	end
	if refreshSB then pcall(refreshSB) end
	if S._refreshAppearance then pcall(S._refreshAppearance) end
end

function UIStyle:ApplyTextScale(scale)
	S.UITextScale = math.clamp(tonumber(scale) or 1, 0.88, 1.18)
	for _, object in ipairs(SG:GetDescendants()) do
		if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
			local original = object:GetAttribute("DemonologyOriginalTextSize")
			if not original then
				original = object.TextSize
				pcall(function() object:SetAttribute("DemonologyOriginalTextSize", original) end)
			end
			object.TextSize = math.clamp(math.floor(original * S.UITextScale + 0.5), 8, 28)
		end
	end
	if S._refreshAppearance then pcall(S._refreshAppearance) end
end

function UIStyle:ApplyHUDScale(scale)
	S.HUDScale = math.clamp(tonumber(scale) or 1, 0.8, 1.3)
	for _, object in ipairs(SG:GetDescendants()) do
		if object:IsA("GuiObject") and object:GetAttribute("ScalableHUD") == true then
			local scaler = object:FindFirstChild("HUDUserScale")
			if not scaler then
				scaler = Instance.new("UIScale")
				scaler.Name = "HUDUserScale"
				scaler.Parent = object
			end
			scaler.Scale = S.HUDScale
		end
	end
	if S._refreshAppearance then pcall(S._refreshAppearance) end
end

UIStyle.NotificationPositions = {
	["Top Left"] = true, ["Top Center"] = true, ["Top Right"] = true,
	["Bottom Left"] = true, ["Bottom Center"] = true, ["Bottom Right"] = true,
}
function UIStyle:PlaceNotifications(value)
	S.NotificationPosition = self.NotificationPositions[value] and value or "Top Center"
	local top = S.NotificationPosition:sub(1, 3) == "Top"
	local left = S.NotificationPosition:sub(-4) == "Left"
	local right = S.NotificationPosition:sub(-5) == "Right"
	local x = left and 0 or (right and 1 or 0.5)
	local y = top and 0 or 1
	NHost.AnchorPoint = Vector2.new(x, y)
	NHost.Position = UDim2.new(x, left and 20 or (right and -20 or 0), y, top and 20 or -74)
	nLayout.HorizontalAlignment = left and Enum.HorizontalAlignment.Left or (right and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Center)
	nLayout.VerticalAlignment = top and Enum.VerticalAlignment.Top or Enum.VerticalAlignment.Bottom
	if S._refreshAppearance then pcall(S._refreshAppearance) end
end
UIStyle:PlaceNotifications(S.NotificationPosition)

local NOrder, ActiveN = 0, {}
local TONE_COLOR = {
	success = Color3.fromRGB(88, 220, 132),
	warn = Color3.fromRGB(255, 202, 72),
	danger = Color3.fromRGB(255, 78, 78),
}
local function Notify(title, msg, tone, dur)
	if not NHost or not NHost.Parent then return end
	NOrder = NOrder + 1
	dur = dur or 2.8
	local toneName = tone or "info"
	local accent = TONE_COLOR[toneName] or (toneName == "muted" and T.Tx3 or T.Accent)

	local toast = Instance.new("Frame")
	toast.Name = "N"
	toast.Parent = NHost
	toast.BackgroundColor3 = T.Card
	toast.BorderSizePixel = 0
	toast.ClipsDescendants = true
	toast.LayoutOrder = NOrder
	toast.Size = UDim2.new(0.86, 0, 0, 0)
	toast.ZIndex = 901
	Corner(toast, 12)
	local tst = Stroke(toast, T.Bd2, 1, 0.5)
	Shadow(toast, 0.5)
	Grad(toast, T.White:Lerp(T.Accent, 0.12), T.White:Lerp(T.Elev, 0.08), 90)

	local sc = Instance.new("UIScale")
	sc.Scale = MOBILE and 0.75 or 0.9
	sc.Parent = toast

	local strip = Instance.new("Frame")
	strip.Parent = toast
	strip.BackgroundColor3 = accent
	strip.BorderSizePixel = 0
	strip.Position = UDim2.new(0, 0, 0, 7)
	strip.Size = UDim2.new(0, 3, 1, -14)
	strip.ZIndex = 902
	Corner(strip, 4)

	local tt = Instance.new("TextLabel")
	tt.Parent = toast
	tt.BackgroundTransparency = 1
	tt.Font = FB
	tt.Position = UDim2.new(0, 16, 0, 8)
	tt.Size = UDim2.new(1, -30, 0, 18)
	tt.Text = tostring(title or "")
	tt.TextColor3 = T.White
	tt.TextSize = 14
	tt.TextTransparency = 1
	tt.TextTruncate = Enum.TextTruncate.AtEnd
	tt.TextXAlignment = Enum.TextXAlignment.Left
	tt.ZIndex = 902

	local bt = Instance.new("TextLabel")
	bt.Parent = toast
	bt.BackgroundTransparency = 1
	bt.Font = F
	bt.Position = UDim2.new(0, 16, 0, 26)
	bt.Size = UDim2.new(1, -30, 0, 17)
	bt.Text = tostring(msg or "")
	bt.TextColor3 = T.Tx2
	bt.TextSize = 13
	bt.TextTransparency = 1
	bt.TextWrapped = true
	bt.TextXAlignment = Enum.TextXAlignment.Left
	bt.ZIndex = 902

	table.insert(ActiveN, toast)
	if #ActiveN > 4 then
		local old = table.remove(ActiveN, 1)
		if old and old.Parent then old:Destroy() end
	end

	TweenService:Create(toast, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 0, MOBILE and 58 or 52)
	}):Play()
	TweenService:Create(sc, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	TweenService:Create(tt, TweenInfo.new(0.14), { TextTransparency = 0 }):Play()
	TweenService:Create(bt, TweenInfo.new(0.18), { TextTransparency = 0 }):Play()

	task.delay(dur, function()
		if not toast.Parent then return end
		TweenService:Create(tt, TweenInfo.new(0.18), { TextTransparency = 1 }):Play()
		TweenService:Create(bt, TweenInfo.new(0.18), { TextTransparency = 1 }):Play()
		TweenService:Create(tst, TweenInfo.new(0.18), { Transparency = 1 }):Play()
		TweenService:Create(toast, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1,
			Size = UDim2.new(0.86, 0, 0, 0)
		}):Play()
		task.wait(0.24)
		for i, v in ipairs(ActiveN) do
			if v == toast then table.remove(ActiveN, i); break end
		end
		if toast.Parent then toast:Destroy() end
	end)
end
local function NotifyToggle(label, enabled)
	Notify(label, enabled and "Enabled" or "Disabled", enabled and "success" or "muted", 1.8)
end

-- Main Window Shell Setup.  WW/WH is the DESKTOP design size; the mobile build
-- never uses a pixel size — expandedSize is Scale-based and recomputed by
-- relayout() on every viewport/orientation change.
local WW, WH = 900, 580
local expandedSize = MOBILE and UDim2.fromScale(0.92, 0.84) or UDim2.fromOffset(WW, WH)
Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = SG
Main.Active = true
Main.BackgroundColor3 = T.BG
Main.BorderSizePixel = 0
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.Size = UDim2.fromOffset(0, 0)
Main.ClipsDescendants = true
Main.Visible = false
Corner(Main, MOBILE and 18 or 14)
local mainSt = Stroke(Main, T.Bd, 1, 0.1)
Shadow(Main, 0.15)
Grad(Main, T.White:Lerp(T.Accent, 0.10), T.White:Lerp(T.Elev, 0.06), 90)
if MOBILE then
	-- Upper bound only: on a tablet the sheet stops growing instead of turning
	-- into a stretched desktop window.
	local limit = Instance.new("UISizeConstraint")
	limit.MaxSize = Vector2.new(560, 940)
	limit.MinSize = Vector2.new(260, 300)
	limit.Parent = Main
end

local TBar = Instance.new("Frame")
TBar.Name = "TBar"
TBar.Parent = Main
TBar.ZIndex = 500
TBar.ZIndex = 500
TBar.Active = true
TBar.BackgroundTransparency = 1
TBar.Size = UDim2.new(1, 0, 0, M.titleH)
TBar.Position = UDim2.new(0, 0, 0, 0)

local TIcon = Instance.new("Frame")
TIcon.Parent = TBar
TIcon.BackgroundColor3 = T.Accent
TIcon.BorderSizePixel = 0
TIcon.Position = UDim2.new(0, 18, 0.5, -6)
TIcon.Size = UDim2.new(0, 3, 0, 12)
Corner(TIcon, 2)

local TTitle = Instance.new("TextLabel")
TTitle.Parent = TBar
TTitle.BackgroundTransparency = 1
TTitle.Position = UDim2.new(0, 30, 0, 0)
TTitle.Size = UDim2.new(0, 220, 1, 0)
TTitle.Font = FB
TTitle.Text = "Demonology"
TTitle.TextColor3 = T.White
TTitle.TextSize = 19
TTitle.TextXAlignment = Enum.TextXAlignment.Left

local function mkWinBtn(txt, xOff)
	local b = Instance.new("TextButton")
	b.Parent = TBar
	b.AnchorPoint = Vector2.new(1, 0.5)
	b.Position = UDim2.new(1, xOff, 0.5, 0)
	b.Size = MOBILE and UDim2.new(0, 40, 0, 40) or UDim2.new(0, 30, 0, 26)
	b.BackgroundColor3 = T.Elev
	b.BorderSizePixel = 0
	b.Font = FB
	b.TextSize = MOBILE and 17 or 14
	b.Text = txt
	b.TextColor3 = T.Tx2
	b.AutoButtonColor = false
	Corner(b, 7)
	Stroke(b, T.Bd, 1, 0.4)
	b.MouseEnter:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.12), { BackgroundColor3 = T.Hover }):Play()
		b.TextColor3 = T.White
	end)
	b.MouseLeave:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.12), { BackgroundColor3 = T.Elev }):Play()
		b.TextColor3 = T.Tx2
	end)
	return b
end
local CloseBtn = mkWinBtn("X", MOBILE and -14 or -12)
-- Desktop: minimize.  Mobile: minimize is pointless on a sheet you close
-- outright, so the slot becomes the Interface button — the profile card that
-- opened it lives in the desktop sidebar, which mobile drops.
local SetBtn = mkWinBtn("\u{2699}", MOBILE and -106 or -70)
SetBtn.Visible = MOBILE
local MinBtn = mkWinBtn("-", MOBILE and -60 or -46)

-- Drag Utility
makeElementDraggable = function(frame, handle)
	handle = handle or frame
	local dragging, dragInput, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and frame.Active then
			if frame == Main or string.find(frame.Name, "Watermark") or string.find(frame.Name, "Settings") or (not hudLocked) then
				dragging = true
				dragStart = input.Position
				startPos = frame.Position
				local conn
				conn = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
						conn:Disconnect()
						if S._RequestAutoSave then S._RequestAutoSave() end
					end
				end)
			end
		end
	end)
	handle.InputChanged:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and frame.Active then
			dragInput = input
		end
	end)
	tc(game:GetService("RunService").RenderStepped:Connect(function()
		if dragging and dragInput then
			local delta = dragInput.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end))
end

makeElementDraggable(Main, TBar)

-- Navigation.  Desktop = vertical sidebar.  Mobile = bottom tab bar, the layout
-- every phone app uses, horizontally scrollable so the tab count can grow past
-- what fits.  Same instance, different axis: one set of tab buttons downstream.
local SB = Instance.new("ScrollingFrame")
SB.Name = "Sidebar"
SB.Parent = Main
SB.BackgroundColor3 = T.Sidebar
SB.BorderSizePixel = 0
SB.CanvasSize = UDim2.new(0, 0, 0, 0)
SB.ScrollBarImageColor3 = T.Tx3
SB.ScrollBarImageTransparency = 0.5
if MOBILE then
	SB.AnchorPoint = Vector2.new(0.5, 1)
	SB.Position = UDim2.new(0.5, 0, 1, -8)
	SB.Size = UDim2.new(1, -16, 0, M.navH)
	SB.AutomaticCanvasSize = Enum.AutomaticSize.X
	SB.ScrollingDirection = Enum.ScrollingDirection.X
	SB.ScrollBarThickness = 0
else
	SB.Position = UDim2.new(0, 8, 0, M.titleH)
	SB.Size = UDim2.new(0, 144, 1, -56)
	SB.AutomaticCanvasSize = Enum.AutomaticSize.Y
	SB.ScrollBarThickness = 2
end
Corner(SB, MOBILE and 16 or 10)
Stroke(SB, T.Bd2, 1, 0.32)
local SBLine = Instance.new("Frame")
SBLine.Parent = Main
SBLine.BackgroundColor3 = T.Bd
SBLine.BackgroundTransparency = 0.3
SBLine.BorderSizePixel = 0
SBLine.Position = UDim2.new(0, 157, 0, 56)
SBLine.Size = UDim2.new(0, 1, 1, -72)
SBLine.Visible = not MOBILE
local SBLayout = Instance.new("UIListLayout")
SBLayout.Parent = SB
SBLayout.SortOrder = Enum.SortOrder.LayoutOrder
SBLayout.FillDirection = MOBILE and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
-- Centering is for the mobile strip only; the desktop list must stay top-aligned
-- or the profile card and tabs drift to the middle of the sidebar.
SBLayout.VerticalAlignment = MOBILE and Enum.VerticalAlignment.Center or Enum.VerticalAlignment.Top
SBLayout.Padding = UDim.new(0, MOBILE and 6 or 5)
Pad(SB, MOBILE and 6 or 8, MOBILE and 6 or 8, 8, 8)

-- The profile card is desktop sidebar furniture: a bottom tab bar has room for
-- tabs and nothing else, so mobile reaches Interface settings through the
-- header gear instead.
if not MOBILE then
local ProfileButton = Instance.new("TextButton")
ProfileButton.Name = "Profile"; ProfileButton.Parent = SB; ProfileButton.LayoutOrder = -100
ProfileButton.Size = UDim2.new(1, 0, 0, 54); ProfileButton.BackgroundColor3 = T.Card
ProfileButton.BorderSizePixel = 0; ProfileButton.AutoButtonColor = false; ProfileButton.Text = ""
Corner(ProfileButton, 10); Stroke(ProfileButton, T.Bd2, 1, 0.35); Shadow(ProfileButton, 0.45)
local ProfileAvatar = Instance.new("ImageLabel")
ProfileAvatar.Name = "Avatar"; ProfileAvatar.Parent = ProfileButton
ProfileAvatar.Position = UDim2.new(0, 8, 0.5, -17); ProfileAvatar.Size = UDim2.fromOffset(34, 34)
ProfileAvatar.BackgroundTransparency = 1; ProfileAvatar.BorderSizePixel = 0
ProfileAvatar.Image = "rbxasset://textures/ui/Guidetool/PlayerIcon.png"
ProfileAvatar.ImageColor3 = Color3.fromRGB(254, 254, 254); ProfileAvatar.ScaleType = Enum.ScaleType.Crop
ProfileAvatar:SetAttribute("StaticThemeColor", true)
Corner(ProfileAvatar, 9999); Stroke(ProfileAvatar, T.Bd2, 1, 0.4)
task.spawn(function()
	local ok, image = pcall(function()
		return PS:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
	end)
	if ok and type(image) == "string" and image ~= "" and ProfileAvatar.Parent then
		ProfileAvatar.Image = image
	end
end)
local ProfileTitle = Instance.new("TextLabel")
ProfileTitle.Parent = ProfileButton; ProfileTitle.BackgroundTransparency = 1
ProfileTitle.Position = UDim2.new(0, 49, 0.5, -13); ProfileTitle.Size = UDim2.new(1, -56, 0, 15)
ProfileTitle.Font = FM; ProfileTitle.TextSize = 12; ProfileTitle.TextColor3 = T.Tx
ProfileTitle.TextXAlignment = Enum.TextXAlignment.Left; ProfileTitle.TextTruncate = Enum.TextTruncate.AtEnd
ProfileTitle.Text = plr.DisplayName
local ProfileSub = Instance.new("TextLabel")
ProfileSub.Parent = ProfileButton; ProfileSub.BackgroundTransparency = 1
ProfileSub.Position = UDim2.new(0, 49, 0.5, 2); ProfileSub.Size = UDim2.new(1, -56, 0, 11)
ProfileSub.Font = F; ProfileSub.TextSize = 10; ProfileSub.TextColor3 = T.Tx3
ProfileSub.TextXAlignment = Enum.TextXAlignment.Left; ProfileSub.TextTruncate = Enum.TextTruncate.AtEnd
ProfileSub.Text = "@" .. tostring(plr.Name)
ProfileButton.MouseEnter:Connect(function() TweenService:Create(ProfileButton, TweenInfo.new(0.14), { BackgroundColor3 = T.Hover }):Play() end)
ProfileButton.MouseLeave:Connect(function() TweenService:Create(ProfileButton, TweenInfo.new(0.14), { BackgroundColor3 = T.Card }):Play() end)
ProfileButton.MouseButton1Click:Connect(function() if openAppearance then openAppearance() end end)
end

local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Name = "Content"
ContentArea.Parent = Main
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
-- Mobile gets the full width (no sidebar to clear); the tab bar below navigates.
ContentArea.Position = MOBILE and UDim2.new(0, 6, 0, M.titleH) or UDim2.new(0, 164, 0, 48)
ContentArea.Size = MOBILE and UDim2.new(1, -12, 1, -(M.titleH + M.navH + 8)) or UDim2.new(1, -172, 1, -48)
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentArea.ScrollBarThickness = MOBILE and 0 or 3
ContentArea.ScrollBarImageColor3 = T.Tx3
ContentArea.ScrollBarImageTransparency = 0.4

local Pages = {}
local SBItems = {}
local activePage

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
	l.Parent = sf
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding = UDim.new(0, MOBILE and 14 or 14)
	Pad(sf, MOBILE and 8 or 10, MOBILE and 20 or 14, MOBILE and 6 or 8, MOBILE and 6 or 10)
	Pages[name] = sf
	return sf
end

local function mkSBItem(name, iconKind, page, order)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Parent = SB
	btn.LayoutOrder = order
	-- Offset height, not Scale: inside a ScrollingFrame a Scale height measures
	-- the frame, not the padded content box, so a Scale=1 pill would overflow
	-- the tab bar by exactly the padding and drag the canvas with it.
	btn.Size = MOBILE and UDim2.new(0, M.navItemW, 0, M.navH - 12) or UDim2.new(1, 0, 0, 34)
	btn.AutoButtonColor = false
	btn.BackgroundTransparency = 1
	btn.BorderSizePixel = 0
	btn.Text = ""
	Corner(btn, MOBILE and 12 or 9)
	local bar = Instance.new("Frame")
	bar.Parent = btn
	-- Active marker: a left rail on desktop, an underline on a mobile pill.
	bar.Size = MOBILE and UDim2.new(0, 22, 0, 3) or UDim2.new(0, 3, 0, 20)
	bar.Position = MOBILE and UDim2.new(0.5, -11, 1, -6) or UDim2.new(0, 0, 0.5, -10)
	bar.BackgroundColor3 = T.Accent
	bar.BorderSizePixel = 0
	bar.Visible = false
	Corner(bar, 2)
	-- Mobile: text-only pills.  The nav icons are a fixed embedded set, so any
	-- tab without one would render icon-less next to its neighbours; a uniform
	-- text strip has no such hole.
	local icon = not MOBILE and MakeNavIcon(btn, iconKind) or nil
	local label = Instance.new("TextLabel")
	label.Parent = btn
	label.BackgroundTransparency = 1
	label.Position = MOBILE and UDim2.new(0, 3, 0, 0) or UDim2.new(0, icon and 36 or 13, 0, 0)
	label.Size = MOBILE and UDim2.new(1, -6, 1, -6) or UDim2.new(1, icon and -42 or -20, 1, 0)
	label.Font = F
	label.TextSize = MOBILE and 13 or 13
	label.TextColor3 = T.Tx2
	label.TextXAlignment = MOBILE and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
	label.TextWrapped = MOBILE
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Text = name
	local item = { btn = btn, bar = bar, icon = icon, label = label, page = page }
	btn.MouseButton1Click:Connect(function()
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
	table.insert(SBItems, item)
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

mkPage("Evidence")
mkPage("Ghost & Hunt")
mkPage("Automation")
mkPage("ESP")
mkPage("Movement")
mkPage("Teleport")
mkPage("Misc")
mkPage("HUD")
Pages["Evidence"].Visible = true
activePage = Pages["Evidence"]
mkSBItem("Evidence", "search-check", Pages["Evidence"], 1)
mkSBItem("Ghost & Hunt", "ghost", Pages["Ghost & Hunt"], 2)
mkSBItem("Automation", "workflow", Pages["Automation"], 3)
mkSBItem("ESP", "scan-eye", Pages["ESP"], 4)
mkSBItem("Movement", "footprints", Pages["Movement"], 5)
mkSBItem("Teleport", "map-pin", Pages["Teleport"], 6)
mkSBItem("Misc", "wrench", Pages["Misc"], 7)
mkSBItem("HUD", "panels-top-left", Pages["HUD"], 8)
-- Floating buttons are a touch feature, so the tab that manages them only
-- exists on the mobile build.
if MOBILE then
	mkPage("Buttons")
	mkSBItem("Buttons", "grid", Pages["Buttons"], 9)
end
do
	local card = Instance.new("Frame")
	card.Name = "QuickStatus"; card.Parent = SB; card.LayoutOrder = 100
	card.Size = UDim2.new(1, 0, 0, 94); card.BackgroundColor3 = T.Card; card.BorderSizePixel = 0
	Corner(card, 9); Stroke(card, T.Bd2, 1, 0.28)
	local quickGradient = Grad(card, T.White:Lerp(T.Accent, 0.16), T.White:Lerp(T.Elev, 0.08), 90)
	quickGradient.Name = "QuickStatusGradient"
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
	local roundValue = statusRow("ROUND", 1)
	local huntsValue = statusRow("HUNTS", 2)
	local networkValue = statusRow("PING", 3)
	task.spawn(function()
		while card.Parent do
			local ping = math.floor((plr:GetNetworkPing() or 0) * 1000 + 0.5)
			roundValue.Text = S.Ready and "ACTIVE" or "WAITING"
			roundValue.TextColor3 = S.Ready and T.Accent or T.Tx3
			stateDot.BackgroundColor3 = S.Ready and T.Accent or T.Tx4
			stateDot.BackgroundTransparency = S.Ready and 0 or 0.45
			huntsValue.Text = tostring(S.HuntsCount or 0)
			networkValue.Text = tostring(ping) .. " ms"
			task.wait(0.75)
		end
	end)
end
refreshSB()

-- Section & Control Builders
local ConfigControls = {}
openAppearance = (function()
	local panel = Instance.new("Frame")
	panel.Name = "AppearanceSettings"; panel.Parent = SG
	panel.AnchorPoint = Vector2.new(0.5, 0.5); panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromOffset(320, 456); panel.BackgroundColor3 = T.Card; panel.BorderSizePixel = 0
	panel.Visible = false; panel.ZIndex = 1500
	Corner(panel, 12); Stroke(panel, T.Bd2, 1, 0.18)
	Grad(panel, T.White:Lerp(T.Accent, 0.10), T.White:Lerp(T.Elev, 0.06), 90)
	local scale = Instance.new("UIScale"); scale.Parent = panel
	local title = Instance.new("TextLabel")
	title.Parent = panel; title.BackgroundTransparency = 1; title.Position = UDim2.fromOffset(16, 12)
	title.Size = UDim2.new(1, -58, 0, 24); title.Font = FB; title.TextSize = 15; title.TextColor3 = T.White
	title.TextXAlignment = Enum.TextXAlignment.Left; title.Text = "INTERFACE"
	local subtitle = Instance.new("TextLabel")
	subtitle.Parent = panel; subtitle.BackgroundTransparency = 1; subtitle.Position = UDim2.fromOffset(16, 34)
	subtitle.Size = UDim2.new(1, -32, 0, 18); subtitle.Font = F; subtitle.TextSize = 10; subtitle.TextColor3 = T.Tx3
	subtitle.TextXAlignment = Enum.TextXAlignment.Left; subtitle.Text = "Theme, HUD scale, readability and notifications"
	local close = Instance.new("TextButton")
	close.Parent = panel; close.AnchorPoint = Vector2.new(1, 0); close.Position = UDim2.new(1, -12, 0, 12)
	close.Size = UDim2.fromOffset(26, 26); close.BackgroundColor3 = T.Elev; close.BorderSizePixel = 0
	close.AutoButtonColor = false; close.Font = FM; close.TextSize = 18; close.TextColor3 = T.Tx2; close.Text = "×"; close.ZIndex = 1502
	Corner(close, 7); Stroke(close, T.Bd2, 1, 0.4)
	local body = Instance.new("Frame")
	body.Parent = panel; body.BackgroundTransparency = 1; body.Position = UDim2.fromOffset(14, 62); body.Size = UDim2.new(1, -28, 1, -76)
	local layout = Instance.new("UIListLayout"); layout.Parent = body; layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0, 8)
	local choiceRefreshers = {}

	local function makeChoice(labelText, values, getValue, onValue, order, display)
		local row = Instance.new("Frame")
		row.Parent = body; row.LayoutOrder = order; row.Size = UDim2.new(1, 0, 0, 52); row.BackgroundColor3 = T.BG; row.BorderSizePixel = 0
		Corner(row, 9); Stroke(row, T.Bd2, 1, 0.42)
		local label = Instance.new("TextLabel")
		label.Parent = row; label.BackgroundTransparency = 1; label.Position = UDim2.fromOffset(10, 5); label.Size = UDim2.new(1, -20, 0, 17)
		label.Font = F; label.TextSize = 10; label.TextColor3 = T.Tx3; label.TextXAlignment = Enum.TextXAlignment.Left; label.Text = labelText
		local button = Instance.new("TextButton")
		button.Parent = row; button.Position = UDim2.fromOffset(8, 24); button.Size = UDim2.new(1, -16, 0, 22)
		button.BackgroundColor3 = T.Elev; button.BorderSizePixel = 0; button.AutoButtonColor = false
		button.Font = FM; button.TextSize = 11; button.TextColor3 = T.Tx; Corner(button, 6)
		local function refresh() local value = getValue(); button.Text = display and display(value) or tostring(value) end
		button.MouseButton1Click:Connect(function()
			local current = getValue(); local index = table.find(values, current) or 1
			onValue(values[index % #values + 1]); refresh()
			if S._RequestAutoSave then S._RequestAutoSave() end
		end)
		refresh()
		table.insert(choiceRefreshers, refresh)
	end
	makeChoice("TEXT SIZE", { 0.88, 1, 1.18 }, function() return S.UITextScale end, function(value) UIStyle:ApplyTextScale(value) end, 1, function(value)
		return value == 0.88 and "Small" or (value == 1.18 and "Large" or "Normal")
	end)
	makeChoice("HUD SIZE", { 0.8, 0.9, 1, 1.15, 1.3 }, function() return S.HUDScale end, function(value)
		UIStyle:ApplyHUDScale(value)
	end, 2, function(value) return tostring(math.floor(value * 100 + 0.5)) .. "%" end)
	makeChoice("NOTIFICATION POSITION", { "Top Center", "Top Right", "Bottom Right", "Bottom Center", "Bottom Left", "Top Left" }, function()
		return S.NotificationPosition
	end, function(value) UIStyle:PlaceNotifications(value) end, 3)

	local themeCard = Instance.new("Frame")
	themeCard.Parent = body; themeCard.LayoutOrder = 4; themeCard.Size = UDim2.new(1, 0, 0, 150)
	themeCard.BackgroundColor3 = T.BG; themeCard.BorderSizePixel = 0; Corner(themeCard, 9); Stroke(themeCard, T.Bd2, 1, 0.42)
	local themeTitle = Instance.new("TextLabel")
	themeTitle.Parent = themeCard; themeTitle.BackgroundTransparency = 1; themeTitle.Position = UDim2.fromOffset(10, 5)
	themeTitle.Size = UDim2.new(1, -20, 0, 17); themeTitle.Font = F; themeTitle.TextSize = 10; themeTitle.TextColor3 = T.Tx3
	themeTitle.TextXAlignment = Enum.TextXAlignment.Left; themeTitle.Text = "THEME"
	local gridHost = Instance.new("Frame")
	gridHost.Parent = themeCard; gridHost.BackgroundTransparency = 1; gridHost.Position = UDim2.fromOffset(8, 26); gridHost.Size = UDim2.new(1, -16, 1, -34)
	local grid = Instance.new("UIGridLayout")
	grid.Parent = gridHost; grid.CellSize = UDim2.new(0.5, -3, 0, 20); grid.CellPadding = UDim2.fromOffset(6, 4)
	grid.FillDirectionMaxCells = 2; grid.SortOrder = Enum.SortOrder.LayoutOrder
	local themeButtons, themeNames = {}, { "Default", "Graphite", "Ocean", "Forest", "Wine", "Violet", "Ember", "Amber", "Rose" }
	local function refreshThemes()
		for name, button in pairs(themeButtons) do
			local selected = name == S.UITheme
			button.BackgroundColor3 = selected and T.ActiveBg or T.Elev; button.TextColor3 = selected and T.White or T.Tx2
		end
	end
	for index, name in ipairs(themeNames) do
		local button = Instance.new("TextButton")
		button.Parent = gridHost; button.LayoutOrder = index; button.AutoButtonColor = false
		button.BackgroundColor3 = T.Elev; button.BorderSizePixel = 0; button.Font = FM; button.TextSize = 10; button.TextColor3 = T.Tx2; button.Text = name
		Corner(button, 6); Stroke(button, T.Bd2, 1, 0.48)
		local dot = Instance.new("Frame")
		dot.Parent = button; dot.AnchorPoint = Vector2.new(1, 0.5); dot.Position = UDim2.new(1, -7, 0.5, 0)
		dot.Size = UDim2.fromOffset(7, 7); dot.BackgroundColor3 = THEMES[name].Accent; dot.BorderSizePixel = 0; Corner(dot, 99)
		dot:SetAttribute("StaticThemeColor", true)
		themeButtons[name] = button
		button.MouseButton1Click:Connect(function()
			UIStyle:ApplyTheme(name); refreshThemes()
			if S._RequestAutoSave then S._RequestAutoSave() end
		end)
	end
	refreshThemes()
	S._refreshAppearance = function()
		refreshThemes()
		for _, refresh in ipairs(choiceRefreshers) do refresh() end
	end
	local executor = Instance.new("TextLabel")
	executor.Parent = body; executor.LayoutOrder = 5; executor.Size = UDim2.new(1, 0, 0, 28)
	executor.BackgroundColor3 = T.BG; executor.BorderSizePixel = 0; executor.Font = F; executor.TextSize = 10; executor.TextColor3 = T.Tx2
	executor.TextXAlignment = Enum.TextXAlignment.Left
	local executorName = "Unknown executor"; pcall(function() if identifyexecutor then executorName = tostring(identifyexecutor()) end end)
	executor.Text = "   EXECUTOR   " .. executorName; Corner(executor, 8); Stroke(executor, T.Bd2, 1, 0.44)
	for _, object in ipairs(panel:GetDescendants()) do if object:IsA("GuiObject") then object.ZIndex = math.max(object.ZIndex, 1501) end end

	makeElementDraggable(panel, title)
	local opened = false
	local function setOpen(value)
		opened = value
		if value then
			panel.Visible = true; scale.Scale = 0.92; panel.BackgroundTransparency = 0.08
			TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
			TweenService:Create(panel, TweenInfo.new(0.16), { BackgroundTransparency = 0 }):Play()
		else
			TweenService:Create(scale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.94 }):Play()
			task.delay(0.15, function() if not opened then panel.Visible = false end end)
		end
	end
	close.MouseButton1Click:Connect(function() setOpen(false) end)

	table.insert(ConfigControls, { id = "UI/Theme", get = function() return S.UITheme end, set = function(value) UIStyle:ApplyTheme(value) end })
	table.insert(ConfigControls, { id = "UI/TextScale", get = function() return S.UITextScale end, set = function(value) UIStyle:ApplyTextScale(value) end })
	table.insert(ConfigControls, { id = "UI/HUDScale", get = function() return S.HUDScale end, set = function(value) UIStyle:ApplyHUDScale(value) end })
	table.insert(ConfigControls, { id = "UI/NotificationPosition", get = function() return S.NotificationPosition end, set = function(value) UIStyle:PlaceNotifications(value) end })
	return function() setOpen(not opened) end
end)()
local function cfgId(parent, label)
	local card = parent.Parent
	local page = card and card.Parent
	return (page and page.Name or "?") .. "/" .. (card and card.Name or "?") .. "/" .. label
end

local BindReg = {}
local PendingBind = nil
tc(UIS.InputBegan:Connect(function(input, processed)
	if PendingBind then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			local e = PendingBind
			PendingBind = nil
			local cancel = input.KeyCode == MenuKeybind
				or input.KeyCode == Enum.KeyCode.Escape
				or input.KeyCode == Enum.KeyCode.Backspace
				or input.KeyCode == Enum.KeyCode.Delete
			if e.bindKey then BindReg[e.bindKey] = nil end
			if cancel then
				e.bindKey = nil
				Notify("Bind Cleared", e.label, "muted", 2)
			else
				e.bindKey = input.KeyCode
				BindReg[input.KeyCode] = e
				Notify("Bind Set", e.label .. "  >  " .. input.KeyCode.Name, "info", 2.5)
			end
			e.updateVisuals()
			if S._RequestAutoSave then S._RequestAutoSave() end
		end
		return
	end
	if MOBILE then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		local typing = false
		pcall(function() typing = (UIS:GetFocusedTextBox() ~= nil) end)
		if not typing and input.KeyCode ~= MenuKeybind then
			local e = BindReg[input.KeyCode]
			if e and e.trigger then pcall(e.trigger) end
		end
	end
end))

--=====================================================================
--// FLOATING BUTTONS (mobile build only)
--=====================================================================
-- One draggable on-screen button per function, spawned from the "BTN" chip on
-- the function's row or from the Buttons tab.  Tap = fire the same trigger the
-- desktop keybind fires; drag = move it; the position is saved as SCALE, so a
-- layout survives a re-inject, a rotation and a different phone.
--
-- Controls register themselves through S._floatRegister, which is the same
-- callback the keybind entry already carries — nothing is declared twice and
-- the two builds cannot drift apart.
local FloatReg = {}
local FloatPos = {}
do
	local FloatHost = Instance.new("Frame")
	FloatHost.Name = "FloatingButtons"
	FloatHost.Parent = SG
	FloatHost.BackgroundTransparency = 1
	FloatHost.Size = UDim2.fromScale(1, 1)
	-- ZIndex 0 puts the whole subtree UNDER the menu: an open menu must never be
	-- covered by the buttons it spawned.
	FloatHost.ZIndex = 0
	FloatHost.Visible = MOBILE

	local Buttons = {}
	local spawnIndex = 0

	local function buttonSize()
		local camera = workspace.CurrentCamera
		local vp = camera and camera.ViewportSize
		local base = vp and math.min(vp.X, vp.Y) or 400
		return math.clamp(math.floor(base * 0.15), 54, 82)
	end

	S._floatRegister = function(id, label, trigger, isActive)
		FloatReg[id] = { label = label, trigger = trigger, isActive = isActive, paintChips = {} }
		return id
	end

	local function repaintChips(id)
		local entry = FloatReg[id]
		if not entry then return end
		for _, paint in ipairs(entry.paintChips) do pcall(paint) end
	end

	S._floatIsOn = function(id) return Buttons[id] ~= nil end

	local function paintState(id)
		local button = Buttons[id]
		if not button then return end
		local entry = FloatReg[id]
		local active = false
		if entry and entry.isActive then
			local ok, value = pcall(entry.isActive)
			active = ok and value == true
		end
		if button.lastActive == active then return end
		button.lastActive = active
		TweenService:Create(button.frame, TweenInfo.new(0.16), {
			BackgroundColor3 = active and T.ActiveBg or T.Card,
		}):Play()
		TweenService:Create(button.stroke, TweenInfo.new(0.16), {
			Color = active and T.Accent or T.Bd2,
			Transparency = active and 0.05 or 0.3,
		}):Play()
		button.dot.BackgroundColor3 = active and T.Accent or T.Tx4
		button.dot.BackgroundTransparency = active and 0 or 0.4
		button.label.TextColor3 = active and T.White or T.Tx2
	end

	local function createButton(id)
		local entry = FloatReg[id]
		if not entry or Buttons[id] then return end
		local size = buttonSize()

		local saved = FloatPos[id]
		if type(saved) ~= "table" or type(saved.x) ~= "number" or type(saved.y) ~= "number" then
			-- Fresh buttons stack down the left edge instead of landing on top of
			-- each other; the user drags them wherever they want.
			spawnIndex = spawnIndex + 1
			saved = { x = 0.08, y = math.min(0.22 + (spawnIndex - 1) * 0.12, 0.9) }
			FloatPos[id] = saved
		end

		local frame = Instance.new("TextButton")
		frame.Name = "Float_" .. id
		frame.Parent = FloatHost
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(math.clamp(saved.x, 0.03, 0.97), math.clamp(saved.y, 0.05, 0.95))
		frame.Size = UDim2.fromOffset(size, size)
		frame.BackgroundColor3 = T.Card
		frame.BackgroundTransparency = 0.08
		frame.BorderSizePixel = 0
		frame.AutoButtonColor = false
		frame.Text = ""
		frame.Active = true
		Corner(frame, math.floor(size * 0.3))
		local stroke = Stroke(frame, T.Bd2, 1, 0.3)
		Shadow(frame, 0.55)
		Grad(frame, T.White:Lerp(T.Accent, 0.1), T.White:Lerp(T.Elev, 0.06), 90)

		local dot = Instance.new("Frame")
		dot.Parent = frame
		dot.AnchorPoint = Vector2.new(0.5, 0)
		dot.Position = UDim2.new(0.5, 0, 0, 9)
		dot.Size = UDim2.fromOffset(7, 7)
		dot.BackgroundColor3 = T.Tx4
		dot.BorderSizePixel = 0
		Corner(dot, 99)

		local label = Instance.new("TextLabel")
		label.Parent = frame
		label.BackgroundTransparency = 1
		label.Position = UDim2.new(0, 4, 0, 20)
		label.Size = UDim2.new(1, -8, 1, -26)
		label.Font = FM
		label.TextSize = size <= 60 and 11 or 12
		label.TextColor3 = T.Tx2
		label.TextWrapped = true
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.TextYAlignment = Enum.TextYAlignment.Center
		label.Text = string.upper(tostring(entry.label or id))

		local scale = Instance.new("UIScale")
		scale.Parent = frame
		scale.Scale = 0.6
		TweenService:Create(scale, TweenInfo.new(0.24, Enum.EasingStyle.Back), { Scale = 1 }):Play()

		local record = { frame = frame, stroke = stroke, dot = dot, label = label, scale = scale }
		Buttons[id] = record

		-- Drag vs tap: anything under 8px of travel is a tap.  Without the
		-- threshold every tap that wobbles a pixel would move the button and
		-- never fire, which is the usual "my button does nothing" bug on touch.
		local pressPos, dragging, moveConn, endConn
		local function finish()
			if moveConn then moveConn:Disconnect(); moveConn = nil end
			if endConn then endConn:Disconnect(); endConn = nil end
			if not dragging then
				local current = FloatReg[id]
				if current and current.trigger then pcall(current.trigger) end
				TweenService:Create(scale, TweenInfo.new(0.09), { Scale = 0.9 }):Play()
				task.delay(0.09, function()
					if frame.Parent then
						TweenService:Create(scale, TweenInfo.new(0.14, Enum.EasingStyle.Back), { Scale = 1 }):Play()
					end
				end)
				task.defer(function() paintState(id) end)
			else
				local camera = workspace.CurrentCamera
				local vp = camera and camera.ViewportSize
				if vp and vp.X > 0 and vp.Y > 0 then
					local centre = frame.AbsolutePosition + frame.AbsoluteSize / 2
					FloatPos[id] = {
						x = math.clamp(centre.X / vp.X, 0.03, 0.97),
						y = math.clamp(centre.Y / vp.Y, 0.05, 0.95),
					}
					if S._RequestAutoSave then S._RequestAutoSave() end
				end
			end
			pressPos, dragging = nil, false
		end

		tc(frame.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Touch
				and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			-- A second finger landing on the same button would otherwise orphan
			-- the first press's connections, leaking one per multi-touch.
			if moveConn then moveConn:Disconnect(); moveConn = nil end
			if endConn then endConn:Disconnect(); endConn = nil end
			pressPos, dragging = input.Position, false
			local startCentre = frame.AbsolutePosition + frame.AbsoluteSize / 2
			moveConn = UIS.InputChanged:Connect(function(moved)
				if not pressPos then return end
				if moved.UserInputType ~= Enum.UserInputType.Touch
					and moved.UserInputType ~= Enum.UserInputType.MouseMovement then return end
				local delta = moved.Position - pressPos
				if not dragging and (math.abs(delta.X) > 8 or math.abs(delta.Y) > 8) then dragging = true end
				if dragging then
					local camera = workspace.CurrentCamera
					local vp = camera and camera.ViewportSize
					if not vp or vp.X <= 0 or vp.Y <= 0 then return end
					frame.Position = UDim2.fromScale(
						math.clamp((startCentre.X + delta.X) / vp.X, 0.03, 0.97),
						math.clamp((startCentre.Y + delta.Y) / vp.Y, 0.05, 0.95)
					)
				end
			end)
			endConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then finish() end
			end)
		end))

		record.lastActive = nil
		paintState(id)
	end

	local function destroyButton(id)
		local button = Buttons[id]
		if not button then return end
		Buttons[id] = nil
		TweenService:Create(button.scale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.5 }):Play()
		TweenService:Create(button.frame, TweenInfo.new(0.14), { BackgroundTransparency = 1 }):Play()
		task.delay(0.16, function() if button.frame.Parent then button.frame:Destroy() end end)
	end

	S._floatSet = function(id, on)
		if not MOBILE then return end
		-- The menu button is permanent: on a device with no keyboard, removing it
		-- would leave no way to reopen the hub.
		if id == "ui:menu" and not on then return end
		if on then
			createButton(id)
		else
			destroyButton(id)
			FloatPos[id] = nil
			if S._RequestAutoSave then S._RequestAutoSave() end
		end
		repaintChips(id)
		if S._refreshFloatTab then pcall(S._refreshFloatTab) end
	end

	S._floatToggle = function(id) S._floatSet(id, not S._floatIsOn(id)) end

	-- Config restore hands us the whole saved layout at once.
	S._floatApplyMap = function(map)
		if not MOBILE then return end
		local keepMenu = FloatPos["ui:menu"]
		for id in pairs(Buttons) do destroyButton(id) end
		FloatPos = {}
		if type(map) == "table" then
			for id, pos in pairs(map) do
				if type(pos) == "table" and FloatReg[id] then
					FloatPos[id] = { x = tonumber(pos.x) or 0.08, y = tonumber(pos.y) or 0.3 }
					createButton(id)
				end
			end
		end
		-- A config saved before the menu button existed must not strand the user
		-- without a way back into the hub.
		if FloatReg["ui:menu"] then
			if not FloatPos["ui:menu"] then FloatPos["ui:menu"] = keepMenu end
			createButton("ui:menu")
		end
		for id in pairs(FloatReg) do repaintChips(id) end
		if S._refreshFloatTab then pcall(S._refreshFloatTab) end
	end
	S._floatGetMap = function() return FloatPos end
	S._floatClearAll = function()
		for id in pairs(Buttons) do S._floatSet(id, false) end
	end

	-- The chip that sits at the right edge of a control row on mobile.
	S._floatChip = function(parent, id, rightOffset)
		local chip = Instance.new("TextButton")
		chip.Name = "Float_" .. id
		chip.Parent = parent
		chip.AnchorPoint = Vector2.new(1, 0.5)
		chip.Position = UDim2.new(1, rightOffset, 0.5, 0)
		chip.Size = UDim2.fromOffset(46, 30)
		chip.BackgroundColor3 = T.Elev
		chip.BorderSizePixel = 0
		chip.AutoButtonColor = false
		chip.Font = FM
		chip.TextSize = 11
		chip.TextColor3 = T.Tx2
		chip.Text = "BTN"
		chip.ZIndex = 3
		Corner(chip, 8)
		local chipStroke = Stroke(chip, T.Bd2, 1, 0.42)
		local function paint()
			local on = S._floatIsOn(id)
			chip.BackgroundColor3 = on and T.ActiveBg or T.Elev
			chip.TextColor3 = on and T.White or T.Tx2
			chipStroke.Color = on and T.Accent or T.Bd2
			chipStroke.Transparency = on and 0.15 or 0.42
		end
		local entry = FloatReg[id]
		if entry then table.insert(entry.paintChips, paint) end
		chip.MouseButton1Click:Connect(function() S._floatToggle(id); paint() end)
		paint()
		return chip
	end

	-- Active-state dots: a cheap poll over the handful of live buttons rather
	-- than a per-frame loop over the whole registry.
	if MOBILE then
		task.spawn(function()
			while FloatHost.Parent do
				for id in pairs(Buttons) do paintState(id) end
				task.wait(0.35)
			end
		end)
		tc(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			local size = buttonSize()
			for _, button in pairs(Buttons) do
				button.frame.Size = UDim2.fromOffset(size, size)
				button.label.TextSize = size <= 60 and 11 or 12
			end
		end))
	end
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
	Corner(card, 12)
	Stroke(card, T.Bd, 1, 0.3)
	Grad(card, T.White:Lerp(T.Accent, 0.08), T.White:Lerp(T.Elev, 0.05), 90)
	local inner = Instance.new("Frame")
	inner.Name = "Inner"
	inner.Parent = card
	inner.BackgroundTransparency = 1
	inner.Size = UDim2.new(1, 0, 0, 0)
	inner.AutomaticSize = Enum.AutomaticSize.Y
	Pad(inner, MOBILE and 12 or 14, M.sectionPad, M.sectionPad, M.sectionPad)
	local layout = Instance.new("UIListLayout")
	layout.Parent = inner
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, M.rowGap)
	local hdrRow = Instance.new("Frame")
	hdrRow.Parent = inner
	hdrRow.LayoutOrder = 0
	hdrRow.BackgroundTransparency = 1
	hdrRow.Size = UDim2.new(1, 0, 0, 22)
	local tick = Instance.new("Frame")
	tick.Parent = hdrRow
	tick.BorderSizePixel = 0
	tick.BackgroundColor3 = T.Accent
	tick.Position = UDim2.new(0, 0, 0.5, -5)
	tick.Size = UDim2.new(0, 3, 0, 12)
	Corner(tick, 2)
	local hdr = Instance.new("TextLabel")
	hdr.Parent = hdrRow
	hdr.BackgroundTransparency = 1
	hdr.Position = UDim2.new(0, 12, 0, 0)
	hdr.Size = UDim2.new(1, -12, 1, 0)
	hdr.Font = FB
	hdr.TextSize = 13
	hdr.TextColor3 = T.Tx3
	hdr.TextXAlignment = Enum.TextXAlignment.Left
	hdr.Text = string.upper(title)
	return inner
end

local function mkStat(parent, label, order)
	local row = Instance.new("Frame")
	row.Name = label
	row.Parent = parent
	row.LayoutOrder = order
	row.Size = UDim2.new(1, 0, 0, 26)
	row.BackgroundTransparency = 1
	local lbl = Instance.new("TextLabel")
	lbl.Parent = row
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.new(0, 4, 0, 0)
	lbl.Size = UDim2.new(0.45, 0, 1, 0)
	lbl.Font = F
	lbl.TextSize = 14
	lbl.TextColor3 = T.Tx2
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = label
	local val = Instance.new("TextLabel")
	val.Parent = row
	val.BackgroundTransparency = 1
	val.Position = UDim2.new(0.45, 0, 0, 0)
	val.Size = UDim2.new(0.55, -4, 1, 0)
	val.Font = FM
	val.TextSize = 14
	val.TextColor3 = T.White
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.TextTruncate = Enum.TextTruncate.AtEnd
	val.Text = "--"
	local api = {}
	function api.set(text, color)
		val.Text = tostring(text)
		val.TextColor3 = color or T.White
	end
	return api
end

local function mkEvidenceRow(parent, label, order)
	local row = Instance.new("Frame")
	row.Name = label
	row.Parent = parent
	row.LayoutOrder = order
	row.Size = UDim2.new(1, 0, 0, 36)
	row.BackgroundColor3 = T.Elev
	row.BackgroundTransparency = 1
	row.BorderSizePixel = 0
	Corner(row, 8)
	local dot = Instance.new("Frame")
	dot.Parent = row
	dot.AnchorPoint = Vector2.new(0, 0.5)
	dot.Position = UDim2.new(0, 10, 0.5, 0)
	dot.Size = UDim2.new(0, 8, 0, 8)
	dot.BackgroundColor3 = T.Tx4
	Corner(dot, 4)
	local lbl = Instance.new("TextLabel")
	lbl.Parent = row
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.new(0, 28, 0, 0)
	lbl.Size = UDim2.new(0.55, -28, 1, 0)
	lbl.Font = F
	lbl.TextSize = 14
	lbl.TextColor3 = T.Tx2
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = label
	local badge = Instance.new("TextLabel")
	badge.Parent = row
	badge.AnchorPoint = Vector2.new(1, 0.5)
	badge.Position = UDim2.new(1, -10, 0.5, 0)
	badge.Size = UDim2.new(0, 0, 0, 22)
	badge.AutomaticSize = Enum.AutomaticSize.X
	badge.BackgroundColor3 = T.TgOff
	badge.BorderSizePixel = 0
	badge.Font = FM
	badge.TextSize = 13
	badge.TextColor3 = T.Tx2
	badge.Text = "--"
	Corner(badge, 6)
	Pad(badge, 0, 0, 10, 10)
	local api = {}
	function api.set(text, found)
		badge.Text = tostring(text)
		if found then
			row.BackgroundTransparency = 0.55
			dot.BackgroundColor3 = T.Good
			badge.BackgroundColor3 = T.Card
			badge.TextColor3 = T.Good
			lbl.TextColor3 = T.Tx
		else
			row.BackgroundTransparency = 1
			dot.BackgroundColor3 = T.Tx4
			badge.BackgroundColor3 = T.TgOff
			badge.TextColor3 = T.Tx2
			lbl.TextColor3 = T.Tx2
		end
	end
	return api
end

local function mkToggle(parent, label, default, callback, order, noPersistState, defaultBind)
	local row = Instance.new("Frame")
	row.Name = label
	row.Parent = parent
	row.LayoutOrder = order
	row.Size = UDim2.new(1, 0, 0, M.rowH)
	row.BackgroundTransparency = 1
	row.BorderSizePixel = 0
	row.Active = true
	Corner(row, 7)
	local lbl = Instance.new("TextLabel")
	lbl.Parent = row
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.new(0, 8, 0, 0)
	-- Reserve the switch plus the chip beside it, whichever build we're on.
	lbl.Size = UDim2.new(1, -(M.trackW + (MOBILE and 74 or 58)), 1, 0)
	lbl.Font = F
	lbl.TextSize = M.rowFont
	lbl.TextColor3 = T.Tx2
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	lbl.Text = label
	local badge = Instance.new("TextLabel")
	badge.Parent = row
	badge.AnchorPoint = Vector2.new(1, 0.5)
	badge.Position = UDim2.new(1, -60, 0.5, 0)
	badge.Size = UDim2.new(0, 0, 0, 18)
	badge.AutomaticSize = Enum.AutomaticSize.X
	badge.BackgroundColor3 = T.Elev
	badge.BorderSizePixel = 0
	badge.Font = FM
	badge.TextSize = 11
	badge.TextColor3 = T.Tx2
	badge.Text = ""
	badge.Visible = false
	Corner(badge, 4)
	Stroke(badge, T.Bd2, 1, 0.5)
	Pad(badge, 0, 0, 7, 7)
	local knobInset = math.floor((M.trackH - M.knob) / 2)
	local track = Instance.new("TextButton")
	track.Parent = row
	track.AnchorPoint = Vector2.new(1, 0.5)
	track.Position = UDim2.new(1, -8, 0.5, 0)
	track.Size = UDim2.new(0, M.trackW, 0, M.trackH)
	track.BackgroundColor3 = T.TgOff
	track.BorderSizePixel = 0
	track.Text = ""
	track.AutoButtonColor = false
	Corner(track, math.floor(M.trackH / 2))
	local trackSt = Stroke(track, T.Bd2, 1, 0.6)
	local knob = Instance.new("Frame")
	knob.Parent = track
	knob.Size = UDim2.new(0, M.knob, 0, M.knob)
	knob.Position = UDim2.new(0, knobInset, 0.5, -math.floor(M.knob / 2))
	knob.BackgroundColor3 = T.KnobOff
	knob.BorderSizePixel = 0
	Corner(knob, math.floor(M.knob / 2))
	local state = default and true or false
	local function setVis(on, anim)
		local tCol = on and T.TgOn or T.TgOff
		local kCol = on and T.KnobOn or T.KnobOff
		local kPos = on
			and UDim2.new(1, -(M.knob + knobInset), 0.5, -math.floor(M.knob / 2))
			or UDim2.new(0, knobInset, 0.5, -math.floor(M.knob / 2))
		lbl.TextColor3 = on and T.Tx or T.Tx2
		trackSt.Transparency = on and 1 or 0.6
		if anim then
			TweenService:Create(track, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundColor3 = tCol }):Play()
			TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = kPos, BackgroundColor3 = kCol
			}):Play()
		else
			track.BackgroundColor3 = tCol
			knob.Position = kPos
			knob.BackgroundColor3 = kCol
		end
	end
	setVis(state, false)
	local api = { }
	function api.get() return state end
	function api.set(v, silent)
		state = v and true or false
		setVis(state, true)
		if not silent then pcall(callback, state) end
	end
	local function toggle()
		state = not state
		setVis(state, true)
		callback(state)
		if S._RequestAutoSave then S._RequestAutoSave() end
	end
	track.MouseButton1Click:Connect(function()
		if not PendingBind then toggle() end
	end)
	row.MouseEnter:Connect(function()
		TweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 0.5 }):Play()
		row.BackgroundColor3 = T.Hover
	end)
	row.MouseLeave:Connect(function()
		TweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play()
	end)

	-- Keybinds are a DESKTOP-only control surface; on mobile the same trigger is
	-- reached through a floating on-screen button instead, registered here so
	-- both builds share one definition of "what this control does".
	local entry = { label = label, bindKey = not MOBILE and defaultBind or nil, trigger = toggle }
	if defaultBind and not MOBILE then
		BindReg[defaultBind] = entry
	end
	function entry.updateVisuals()
		if entry.bindKey and not MOBILE then
			badge.Text = entry.bindKey.Name
			badge.Visible = true
		else
			badge.Visible = false
		end
	end
	entry.updateVisuals()
	if MOBILE then
		local floatId = "toggle:" .. cfgId(parent, label)
		S._floatRegister(floatId, label, toggle, function() return state end)
		S._floatChip(row, floatId, -(M.trackW + 16))
	else
		tc(UIS.InputBegan:Connect(function(i)
			if i.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
			local pos, size = row.AbsolutePosition, row.AbsoluteSize
			local mx, my = i.Position.X, i.Position.Y
			if mx >= pos.X and mx <= pos.X + size.X and my >= pos.Y and my <= pos.Y + size.Y then
				PendingBind = entry
				badge.Text = "..."
				badge.Visible = true
			end
		end))
	end

	if not noPersistState then
		table.insert(ConfigControls, {
			id = cfgId(parent, label),
			get = function() return state end,
			set = function(v) api.set(v, false) end,
		})
	end
	table.insert(ConfigControls, {
		id = cfgId(parent, label) .. "#bind",
		get = function() return entry.bindKey and entry.bindKey.Name or nil end,
		set = function(v)
			if type(v) == "string" then
				local kc = Enum.KeyCode[v]
				if kc and kc ~= MenuKeybind then
					entry.bindKey = kc
					BindReg[kc] = entry
					entry.updateVisuals()
				end
			end
		end,
	})
	return api
end

local function mkAction(parent, label, callback, order)
	local btn = Instance.new("TextButton")
	btn.Name = label
	btn.Parent = parent
	btn.LayoutOrder = order
	btn.Size = UDim2.new(1, 0, 0, M.btnH)
	btn.AutoButtonColor = false
	btn.BackgroundColor3 = T.Elev
	btn.BorderSizePixel = 0
	btn.Font = FM
	btn.TextSize = M.rowFont
	btn.TextColor3 = T.Tx
	btn.Text = label
	btn.TextTruncate = Enum.TextTruncate.AtEnd
	Corner(btn, 8)
	local bst = Stroke(btn, T.Bd2, 1, 0.4)

	local entry = { label = label, bindKey = nil, trigger = callback }
	function entry.updateVisuals()
		btn.Text = label .. ((entry.bindKey and not MOBILE) and ("   [ " .. entry.bindKey.Name .. " ]") or "")
	end
	entry.updateVisuals()

	btn.MouseButton1Click:Connect(function()
		if not PendingBind then callback() end
	end)
	if MOBILE then
		-- No right click on a touch screen: the row's chip spawns the on-screen
		-- button for this action instead of asking for a key.
		local floatId = "action:" .. cfgId(parent, label)
		S._floatRegister(floatId, label, callback, nil)
		S._floatChip(btn, floatId, -8)
		Pad(btn, 0, 0, 12, 62)
		btn.TextXAlignment = Enum.TextXAlignment.Left
	else
		btn.MouseButton2Click:Connect(function()
			PendingBind = entry
			btn.Text = label .. "   [ ... ]"
		end)
	end
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = T.Hover }):Play()
		TweenService:Create(bst, TweenInfo.new(0.12), { Transparency = 0.1 }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = T.Elev }):Play()
		TweenService:Create(bst, TweenInfo.new(0.12), { Transparency = 0.4 }):Play()
		entry.updateVisuals()
	end)

	table.insert(ConfigControls, {
		id = cfgId(parent, label) .. "#bind",
		get = function() return entry.bindKey and entry.bindKey.Name or nil end,
		set = function(v)
			if type(v) == "string" then
				local kc = Enum.KeyCode[v]
				if kc and kc ~= MenuKeybind then
					entry.bindKey = kc
					BindReg[kc] = entry
					entry.updateVisuals()
				end
			end
		end,
	})
	return btn
end

local function mkSlider(parent, label, min, max, def, callback, order)
	local frame = Instance.new("Frame")
	frame.Name = label
	frame.Parent = parent
	frame.LayoutOrder = order
	frame.Size = UDim2.new(1, 0, 0, M.sliderH)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	local lbl = Instance.new("TextLabel")
	lbl.Parent = frame
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.new(0, 4, 0, 0)
	lbl.Size = UDim2.new(0.6, 0, 0, MOBILE and 24 or 20)
	lbl.Font = F
	lbl.TextSize = MOBILE and 15 or 13
	lbl.TextColor3 = T.Tx2
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = label
	local vlbl = Instance.new("TextLabel")
	vlbl.Parent = frame
	vlbl.BackgroundTransparency = 1
	vlbl.AnchorPoint = Vector2.new(1, 0)
	vlbl.Position = UDim2.new(1, -4, 0, 0)
	vlbl.Size = UDim2.new(0.35, 0, 0, MOBILE and 24 or 20)
	vlbl.Font = FM
	vlbl.TextSize = MOBILE and 15 or 14
	vlbl.TextColor3 = T.White
	vlbl.TextXAlignment = Enum.TextXAlignment.Right
	local bar = Instance.new("Frame")
	bar.Parent = frame
	bar.AnchorPoint = Vector2.new(0.5, 0)
	bar.Position = UDim2.new(0.5, 0, 0, MOBILE and 40 or 28)
	bar.Size = UDim2.new(1, -12, 0, M.barH)
	bar.BackgroundColor3 = T.TgOff
	bar.BorderSizePixel = 0
	bar.Active = true
	Corner(bar, math.floor(M.barH / 2))
	local fill = Instance.new("Frame")
	fill.Parent = bar
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = T.Accent
	fill.BorderSizePixel = 0
	Corner(fill, math.floor(M.barH / 2))
	local handle = Instance.new("Frame")
	handle.Parent = bar
	handle.AnchorPoint = Vector2.new(0.5, 0.5)
	handle.Position = UDim2.new(0, 0, 0.5, 0)
	handle.Size = UDim2.new(0, M.grab, 0, M.grab)
	handle.BackgroundColor3 = T.White
	handle.BorderSizePixel = 0
	Corner(handle, math.floor(M.grab / 2))
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
			if S._RequestAutoSave then S._RequestAutoSave() end
		end
	end
	-- Touch counts as a drag here.  Matching only MouseButton1/MouseMovement (as
	-- this did) makes every slider dead on a phone — you could see the bar but
	-- never move it.  Freezing the page scroll for the drag is the other half:
	-- a touch drag inside a ScrollingFrame scrolls the page as well.
	frame.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
			or i.UserInputType == Enum.UserInputType.Touch then
			active = true
			ContentArea.ScrollingEnabled = false
			fromMouse(i)
		end
	end)
	tc(UIS.InputChanged:Connect(function(i)
		if active and (i.UserInputType == Enum.UserInputType.MouseMovement
			or i.UserInputType == Enum.UserInputType.Touch) then
			fromMouse(i)
		end
	end))
	tc(UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
			or i.UserInputType == Enum.UserInputType.Touch then
			if active then ContentArea.ScrollingEnabled = true end
			active = false
		end
	end))
	local api = { get = function() return val end }
	function api.set(v)
		v = tonumber(v)
		if not v then return end
		val = math.clamp(math.floor(v + 0.5), min, max)
		upd(val)
		pcall(callback, val)
	end
	table.insert(ConfigControls, {
		id = cfgId(parent, label),
		get = function() return val end,
		set = api.set,
	})
	return api
end

local function mkCycle(parent, label, options, labels, default, callback, order)
	local row = Instance.new("Frame")
	row.Name = label
	row.Parent = parent
	row.LayoutOrder = order
	row.Size = UDim2.new(1, 0, 0, M.rowH)
	row.BackgroundTransparency = 1
	local lbl = Instance.new("TextLabel")
	lbl.Parent = row
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.new(0, 8, 0, 0)
	lbl.Size = UDim2.new(1, -(M.cycleW + 16), 1, 0)
	lbl.Font = F
	lbl.TextSize = M.rowFont
	lbl.TextColor3 = T.Tx2
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	lbl.Text = label
	local btn = Instance.new("TextButton")
	btn.Parent = row
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.Position = UDim2.new(1, -8, 0.5, 0)
	btn.Size = UDim2.new(0, M.cycleW, 0, M.cycleH)
	btn.BackgroundColor3 = T.Elev
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Font = FM
	btn.TextSize = MOBILE and 14 or 13
	btn.TextColor3 = T.Tx
	Corner(btn, 7)
	Stroke(btn, T.Bd2, 1, 0.4)
	local idx = 1
	for i, o in ipairs(options) do if o == default then idx = i break end end
	local function apply(fire)
		btn.Text = tostring(labels[idx] or options[idx] or "")
		if fire then
			callback(options[idx])
			if S._RequestAutoSave then S._RequestAutoSave() end
		end
	end
	apply(false)
	btn.MouseButton1Click:Connect(function()
		idx = idx % #options + 1
		apply(true)
	end)
	btn.MouseButton2Click:Connect(function()
		idx = (idx - 2) % #options + 1
		apply(true)
	end)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = T.Hover }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = T.Elev }):Play()
	end)
	local function setByValue(v)
		for i, o in ipairs(options) do
			if o == v then
				idx = i
				btn.Text = tostring(labels[idx] or options[idx] or "")
				pcall(callback, options[idx])
				return
			end
		end
	end

	local api = {}
	function api.get() return options[idx] end
	function api.set(v) setByValue(v) end
	function api.update(newOpts, newLbls)
		options = newOpts
		labels = newLbls or newOpts
		idx = math.clamp(idx, 1, #options)
		if #options == 0 then
			idx = 1
			btn.Text = "None"
		else
			btn.Text = tostring(labels[idx] or options[idx] or "")
		end
	end

	table.insert(ConfigControls, {
		id = cfgId(parent, label),
		get = function() return options[idx] end,
		set = setByValue,
	})
	return api
end

local HUDEls = {}
local function mkDragHUD(name, pos, size, z)
	local f = Instance.new("Frame")
	f.Name = "HUD_" .. name
	f.Parent = SG
	f:SetAttribute("ScalableHUD", true)
	f.Active = true
	f.Position = pos
	f.Size = size
	f.BackgroundColor3 = T.Card
	f.BackgroundTransparency = 0.01
	f.BorderSizePixel = 0
	f.Visible = false
	f.ZIndex = z or 850
	Corner(f, 11)
	Stroke(f, T.Bd2, 1, 0.22)
	Shadow(f, 0.76)
	local surfaceGradient = Grad(f, T.White:Lerp(T.Accent, 0.12), T.White:Lerp(T.Elev, 0.08), 90)
	surfaceGradient.Name = "HUDSurfaceGradient"
	local userScale = Instance.new("UIScale")
	userScale.Name = "HUDUserScale"; userScale.Scale = S.HUDScale; userScale.Parent = f
	local tb = Instance.new("Frame")
	tb.Name = "tb"
	tb.Parent = f
	tb.Active = true
	tb.BackgroundColor3 = T.Elev
	tb.BackgroundTransparency = 0.025
	tb.BorderSizePixel = 0
	tb.Size = UDim2.new(1, 0, 0, 28)
	tb.ZIndex = z + 1
	Corner(tb, 10)
	local headerGradient = Grad(tb, T.White:Lerp(T.Accent, 0.14), T.White:Lerp(T.Card, 0.06), 0)
	headerGradient.Name = "HUDHeaderGradient"
	local tbLine = Instance.new("Frame")
	tbLine.Parent = tb; tbLine.AnchorPoint = Vector2.new(0, 1); tbLine.Position = UDim2.new(0, 0, 1, 0)
	tbLine.Size = UDim2.new(1, 0, 0, 1); tbLine.BackgroundColor3 = T.Bd; tbLine.BackgroundTransparency = 0.2
	tbLine.BorderSizePixel = 0; tbLine.ZIndex = z + 1
	local tick = Instance.new("Frame")
	tick.Name = "tick"
	tick.Parent = tb
	tick.BackgroundColor3 = T.Accent
	tick.BorderSizePixel = 0
	tick.Position = UDim2.new(0, 8, 0.5, -6)
	tick.Size = UDim2.new(0, 2, 0, 12)
	tick.ZIndex = z + 2
	Corner(tick, 2)
	local tl = Instance.new("TextLabel")
	tl.Name = "tl"
	tl.Parent = tb
	tl.BackgroundTransparency = 1
	tl.Size = UDim2.new(1, -18, 1, 0)
	tl.Position = UDim2.new(0, 16, 0, 0)
	tl.Font = FB
	tl.TextSize = 13
	tl.TextColor3 = T.Tx
	tl.TextXAlignment = Enum.TextXAlignment.Left
	tl.Text = string.upper(name)
	tl.ZIndex = z + 2
	local ct = Instance.new("Frame")
	ct.Name = "C"
	ct.Parent = f
	ct.BackgroundTransparency = 1
	ct.Position = UDim2.new(0, 10, 0, 33)
	ct.Size = UDim2.new(1, -20, 1, -40)
	ct.ZIndex = z + 1
	
	makeElementDraggable(f, tb)
	HUDEls[name] = { frame = f, content = ct, setLocked = function(v) end }
	return HUDEls[name]
end

-- ESP Tags Setup
S.EspTags = {}
local function centerOffsetFor(adornee)
	if not adornee:IsA("Model") then return Vector3.new(0, 0, 0) end
	local ok, boxCF = pcall(function() return (adornee:GetBoundingBox()) end)
	if not ok or not boxCF then return Vector3.new(0, 0, 0) end
	local ok2, pivot = pcall(function() return adornee:GetPivot() end)
	if not ok2 or not pivot then return Vector3.new(0, 0, 0) end
	return boxCF.Position - pivot.Position
end

local function mkEspTag(adornee, title, color, opts)
	opts = opts or {}
	local bb = Instance.new("BillboardGui")
	bb.Name = "DemonologyEspTag"
	bb.Parent = adornee
	bb.Adornee = adornee
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.Size = opts.size or UDim2.fromOffset(118, 32)
	bb.StudsOffset = opts.offset or Vector3.new(0, 1.6, 0)
	bb.StudsOffsetWorldSpace = centerOffsetFor(adornee)

	local card = Instance.new("Frame")
	card.Parent = bb
	card.BackgroundColor3 = Color3.fromRGB(10, 8, 8)
	card.BackgroundTransparency = 0.2
	card.BorderSizePixel = 0
	card.Size = UDim2.new(1, 0, 1, 0)
	Corner(card, 8)
	Stroke(card, color, 1.2, 0.2)
	Grad(card, Color3.fromRGB(28, 28, 28), Color3.fromRGB(10, 10, 10), 90)

	local dot = Instance.new("Frame")
	dot.Parent = card
	dot.AnchorPoint = Vector2.new(0, 0.5)
	dot.Position = UDim2.new(0, 7, 0.3, 0)
	dot.Size = UDim2.new(0, 5, 0, 5)
	dot.BackgroundColor3 = color
	Corner(dot, 3)

	local tl = Instance.new("TextLabel")
	tl.Parent = card
	tl.BackgroundTransparency = 1
	tl.Position = UDim2.new(0, 16, 0, 1)
	tl.Size = UDim2.new(1, -20, 0, 14)
	tl.Font = FM
	tl.Text = title
	tl.TextColor3 = T.White
	tl.TextSize = 12
	tl.TextXAlignment = Enum.TextXAlignment.Left
	tl.TextTruncate = Enum.TextTruncate.AtEnd

	local distLbl = Instance.new("TextLabel")
	distLbl.Parent = card
	distLbl.BackgroundTransparency = 1
	distLbl.Position = UDim2.new(0, 16, 0, 16)
	distLbl.Size = UDim2.new(1, -20, 0, 13)
	distLbl.Font = F
	distLbl.Text = ""
	distLbl.TextColor3 = T.Tx2
	distLbl.TextSize = 10
	distLbl.TextXAlignment = Enum.TextXAlignment.Left

	local sc = Instance.new("UIScale")
	sc.Scale = 0.6
	sc.Parent = card
	TweenService:Create(sc, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()

	local hl = nil
	if opts.highlight ~= false then
		hl = Instance.new("Highlight")
		hl.Name = "DemonologyEspHL"
		hl.Parent = adornee
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.OutlineColor = color
		hl.FillColor = color
		hl.FillTransparency = opts.fill or 0.9
		hl.OutlineTransparency = 0
		hl.Adornee = adornee
	end

	local entry = { bb = bb, hl = hl, distLbl = distLbl, title = tl, adornee = adornee, card = card, dot = dot }
	function entry.setColor(col)
		if entry.hl then
			entry.hl.OutlineColor = col
			entry.hl.FillColor = col
		end
		if entry.card then
			local stroke = entry.card:FindFirstChildOfClass("UIStroke")
			if stroke then stroke.Color = col end
		end
		if entry.dot then
			entry.dot.BackgroundColor3 = col
		end
	end
	table.insert(S.EspTags, entry)
	return entry
end
local function destroyEspTag(entry)
	if not entry then return end
	if entry.bb then entry.bb:Destroy() end
	if entry.hl then entry.hl:Destroy() end
end

do
	local espTick = tick()
	tc(RS.Heartbeat:Connect(function()
		if tick() - espTick < 0.15 then return end
		espTick = tick()
		local char = plr.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		for i = #S.EspTags, 1, -1 do
			local e = S.EspTags[i]
			if not e.bb or not e.bb.Parent then
				table.remove(S.EspTags, i)
			elseif hrp then
				local ok, pos = pcall(function()
					return e.adornee:IsA("Model") and e.adornee:GetPivot().Position or e.adornee.Position
				end)
				if ok and pos then
					e.distLbl.Text = tostring(math.floor((hrp.Position - pos).Magnitude)) .. " studs"
				end
			end
		end
	end))
end

-- Config Persistence
do
	local CONFIG_DIR = "DemonologyConfig"
	local CONFIG_FILE = CONFIG_DIR .. "/settings.json"
	local HttpService = game:GetService("HttpService")

	local function ensureFolder()
		pcall(function()
			if isfolder and makefolder and not isfolder(CONFIG_DIR) then
				makefolder(CONFIG_DIR)
			end
		end)
	end

	table.insert(ConfigControls, {
		id = "#HUDPositions",
		get = function()
			local pos = {}
			for name, el in pairs(HUDEls) do
				local p = el.frame.Position
				pos[name] = { xs = p.X.Scale, xo = p.X.Offset, ys = p.Y.Scale, yo = p.Y.Offset }
			end
			return pos
		end,
		set = function(v)
			if type(v) ~= "table" then return end
			for name, p in pairs(v) do
				local el = HUDEls[name]
				if el and type(p) == "table" and p.xs and p.xo and p.ys and p.yo then
					local xs, xo, ys, yo = tonumber(p.xs), tonumber(p.xo), tonumber(p.ys), tonumber(p.yo)
					if xs and xo and ys and yo then
						local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
						if vp and vp.X > 0 and vp.Y > 0 then
							local fs = el.frame.AbsoluteSize
							local w = math.max(fs.X, 20)
							local hgt = math.max(fs.Y, 20)
							local anchorX = el.frame.AnchorPoint.X * w
							local anchorY = el.frame.AnchorPoint.Y * hgt
							local absX = math.clamp(vp.X * xs + xo - anchorX, -math.max(w - 20, 0), vp.X - 20)
							local absY = math.clamp(vp.Y * ys + yo - anchorY, -math.max(hgt - 20, 0), vp.Y - 20)
							xo = absX + anchorX - vp.X * xs
							yo = absY + anchorY - vp.Y * ys
						end
						el.frame.Position = UDim2.new(xs, xo, ys, yo)
					end
				end
			end
		end,
	})

	local function SaveConfig()
		if not writefile then return end
		local data = {}
		for _, c in ipairs(ConfigControls) do
			local ok, v = pcall(c.get)
			if ok and v ~= nil then data[c.id] = v end
		end
		pcall(function()
			ensureFolder()
			writefile(CONFIG_FILE, HttpService:JSONEncode(data))
		end)
	end
	S._SaveConfigNow = SaveConfig

	local saveScheduled = false
	S._RequestAutoSave = function()
		if saveScheduled then return end
		saveScheduled = true
		task.delay(1, function()
			saveScheduled = false
			SaveConfig()
		end)
	end

	S._LoadConfig = function()
		if not (readfile and isfile) then return end
		local ok, exists = pcall(isfile, CONFIG_FILE)
		if not ok or not exists then return end
		local ok2, raw = pcall(readfile, CONFIG_FILE)
		if not ok2 then return end
		local ok3, data = pcall(function() return HttpService:JSONDecode(raw) end)
		if not ok3 or type(data) ~= "table" then return end
		local restored = 0
		for _, c in ipairs(ConfigControls) do
			local v = data[c.id]
			if v ~= nil then
				local ok4 = pcall(c.set, v)
				if ok4 then restored = restored + 1 end
			end
		end
		if restored > 0 then
			Notify("Config", "Restored " .. restored .. " saved setting(s)", "info", 2.5)
		end
	end
end

-- Window Controls (Minimize / Close)
local minimized = false
SetBtn.MouseButton1Click:Connect(function() if openAppearance then openAppearance() end end)
MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		SB.Visible = false
		SBLine.Visible = false
		ContentArea.Visible = false
		TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Size = UDim2.fromOffset(Main.AbsoluteSize.X, 48)
		}):Play()
	else
		TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Size = expandedSize
		}):Play()
		task.wait(0.2)
		SB.Visible = true
		SBLine.Visible = true
		ContentArea.Visible = true
	end
end)

local function cleanupAndClose()
	pcall(function()
		local tw = TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0)
		})
		tw:Play()
		tw.Completed:Wait()
	end)

	if S._SaveConfigNow then pcall(S._SaveConfigNow) end
	if S.DisableAllExtras then pcall(S.DisableAllExtras) end
	if S.UpdateEvidenceEsp then S.EvidenceEsp = false; pcall(S.UpdateEvidenceEsp) end
	if S.UpdatePlrEsp then S.PlayersEsp = false; pcall(S.UpdatePlrEsp) end
	if S.ClearItemEsp then pcall(S.ClearItemEsp) end
	if S.DestroyGhostEsp then pcall(S.DestroyGhostEsp) end
	if S.UnmuteAllOnClose then pcall(S.UnmuteAllOnClose) end
	if S.MouseUnlockCleanup then pcall(S.MouseUnlockCleanup) end

	Lighting.Ambient = S.OldLighting.Ambient
	Lighting.OutdoorAmbient = S.OldLighting.OutdoorAmbient
	Lighting.Brightness = S.OldLighting.Brightness
	Lighting.GlobalShadows = S.OldLighting.GlobalShadows
	Lighting.FogEnd = S.OldLighting.FogEnd

	for _, conn in ipairs(S.Connections) do
		pcall(function() conn:Disconnect() end)
	end
	cleanESP()

	if S.AppliedWalkSpeed then
		task.spawn(function()
			local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = 16 end
		end)
	end

	SG:Destroy()
	getgenv()["DemonologyUI"] = nil
end
local closing = false
local function requestClose()
	if closing then return end
	closing = true
	cleanupAndClose()
end
CloseBtn.MouseButton1Click:Connect(requestClose)

-- The menu starts hidden and is toggled explicitly with Insert.
local MenuOpen = false
local menuAnimating = false
local function setMenuOpen(open)
	if menuAnimating or MenuOpen == open then return end
	menuAnimating = true
	MenuOpen = open
	if open then
		Main.Visible = true
		if not Main:FindFirstChild("MenuScale") then
			local ms = Instance.new("UIScale", Main)
			ms.Name = "MenuScale"
			ms.Scale = 0.05
		end
		Main.Size = expandedSize
		if MOBILE then
			Main.Position = S._menuHome or UDim2.fromScale(0.5, 0.5)
			if S._islandGulp then S._islandGulp(true) end
		end
		local tw = TweenService:Create(Main.MenuScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
		tw:Play()
		tw.Completed:Wait()
	else
		if MOBILE then
			-- Droplet, inwards: shrink and slide into the island, then hide.
			S._menuHome = Main.Position
			TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = S._islandPoint and S._islandPoint() or UDim2.new(0.5, 0, 0, 34)
			}):Play()
		end
		local tw = TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0)
		})
		tw:Play()
		tw.Completed:Wait()
		Main.Visible = false
		if MOBILE then
			Main.Position = S._menuHome or UDim2.fromScale(0.5, 0.5)
			if S._islandGulp then S._islandGulp(false) end
		end
		if mouseUnlockToggle then
			mouseUnlockToggle.set(false, false)
		else
			MouseUnlocked = false
		end
	end
	menuAnimating = false
end
tc(UIS.InputBegan:Connect(function(input)
	if closing then return end
	local typing = false
	pcall(function() typing = (UIS:GetFocusedTextBox() ~= nil) end)
	if typing then return end
	if input.KeyCode == MenuKeybind then
		setMenuOpen(not MenuOpen)
	end
end))

--=====================================================================
--// RESPONSIVE LAYOUT
--=====================================================================
-- Runs on every viewport change (resize, rotation, split view).  Nothing in the
-- UI may assume a screen size: the desktop window shrinks to fit a small
-- monitor, the mobile sheet re-proportions between portrait and landscape, and
-- the toast column follows the screen instead of a fixed 360px.
do
	local function relayout()
		local camera = workspace.CurrentCamera
		local vp = camera and camera.ViewportSize
		if not vp or vp.X < 1 or vp.Y < 1 then return end
		local portrait = vp.Y >= vp.X

		if MOBILE then
			if portrait then
				WW = math.floor(vp.X * 0.95)
				WH = math.min(600, math.floor(vp.Y * 0.85))
			else
				WW = math.min(640, math.floor(vp.X * 0.94))
				WH = math.min(360, math.floor(vp.Y * 0.92))
			end
			expandedSize = UDim2.fromOffset(WW, WH)
		else
			WW = math.min(900, math.floor(vp.X - 40))
			WH = math.min(580, math.floor(vp.Y - 40))
			expandedSize = UDim2.fromOffset(WW, WH)
		end
		-- Only resize a window that is actually open: writing Size while it is
		-- closed would pop the collapsed (0,0) window back onto the screen.
		if Main.Visible and not minimized then Main.Size = expandedSize end
		NHost.Size = UDim2.fromOffset(math.clamp(math.floor(vp.X * 0.4), 220, 360), 240)
	end
	relayout()
	local camera = workspace.CurrentCamera
	if camera then tc(camera:GetPropertyChangedSignal("ViewportSize"):Connect(relayout)) end
	tc(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		local newCamera = workspace.CurrentCamera
		if newCamera then
			relayout()
			tc(newCamera:GetPropertyChangedSignal("ViewportSize"):Connect(relayout))
		end
	end))
end

-- Mouse Unlock overrides
do
	local _modalBtn = Instance.new("TextButton")
	_modalBtn.Name = "InertiaModalUnlock"
	_modalBtn.BackgroundTransparency = 1
	_modalBtn.Text = ""
	_modalBtn.Size = UDim2.fromScale(0, 0)
	_modalBtn.Parent = SG
	local _lastNeed = false
	tc(RS.RenderStepped:Connect(function()
		local needsFreeMouse = Main.Visible or MouseUnlocked
		if needsFreeMouse ~= _lastNeed then
			_lastNeed = needsFreeMouse
			_modalBtn.Modal = needsFreeMouse
			if needsFreeMouse then
				UIS.MouseIconEnabled = true
			end
		end
	end))
		
	S.MouseUnlockCleanup = function()
	end
end

------------------------------------------------------------------
--// GAME LOGIC
------------------------------------------------------------------
S.OldLighting = {
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	Brightness = Lighting.Brightness,
	GlobalShadows = Lighting.GlobalShadows,
	FogEnd = Lighting.FogEnd,
}

local function CheckInventory(ItemName)
	local Hotbar = plr.PlayerGui:FindFirstChild("Hotbar")
	local Slots = Hotbar and Hotbar:FindFirstChild("Slots")
	if not Slots then return false, nil end
	for _, obj in ipairs(Slots:GetChildren()) do
		if obj:IsA("Frame") and string.find(string.lower(obj.Name), "invslot") then
			local ItemLabel = obj:FindFirstChild("ItemName")
			if ItemLabel and ItemLabel.Text == ItemName then
				return true, tonumber(obj.Name:match("%d+"))
			end
		end
	end
	return false, nil
end

local function FindItem(ItemName)
	local ItemFolder = workspace:FindFirstChild("Items")
	if not ItemFolder then return false, nil end
	for _, v in pairs(ItemFolder:GetChildren()) do
		if v:IsA("Model") and v:GetAttribute("ItemName") == ItemName then
			return true, v
		end
	end
	return false, nil
end

local function EquipItem(SlotNum)
	Events():WaitForChild("RequestItemEquip"):FireServer("InvSlot" .. tostring(SlotNum))
	return true
end

local function PickupItem(Model)
	Events():WaitForChild("RequestItemPickup"):FireServer(Model)
	return true
end

local function DropItem(SlotNum)
	Events():WaitForChild("RequestItemDrop"):FireServer("InvSlot" .. tostring(SlotNum))
	return true
end

local function ActiveItem()
	local Chara = plr.Character
	if Chara then
		for _, v in pairs(Chara:GetChildren()) do
			if v:IsA("Model") or tonumber(v.Name) then
				if v:GetAttribute("Enabled") ~= true and v:FindFirstChild("Handle") then
					Events():WaitForChild("ToggleItemState"):FireServer(v)
					break
				end
			end
		end
	end
	return true
end

local function EquipPhotoCamera()
	local hasCam, slot = CheckInventory("Photo Camera")
	if not hasCam then
		local found, model = FindItem("Photo Camera")
		if not (found and model) then return false end
		PickupItem(model)
		task.wait(0.5)
		hasCam, slot = CheckInventory("Photo Camera")
		if not hasCam then return false end
	end
	EquipItem(slot)
	task.wait(0.5)
	return true
end

local function UseHauntedMirror()
	local hasMirror, slot = CheckInventory("Haunted Mirror")
	if not hasMirror then
		local found, model = FindItem("Haunted Mirror")
		if not (found and model) then
			Notify("Haunted Mirror", "Mirror not found nearby", "warn", 2.5)
			return
		end
		PickupItem(model)
		task.wait(0.5)
		hasMirror, slot = CheckInventory("Haunted Mirror")
		if not hasMirror then
			Notify("Haunted Mirror", "Failed to pick up the mirror", "warn", 2.5)
			return
		end
	end
	EquipItem(slot)
	task.wait(0.5)
	local mirrorModel
	local Chara = plr.Character
	if Chara then
		for _, v in pairs(Chara:GetChildren()) do
			if v:IsA("Model") or tonumber(v.Name) then
				mirrorModel = v
				break
			end
		end
	end
	if not mirrorModel then
		Notify("Haunted Mirror", "Could not resolve the equipped mirror", "warn", 2.5)
		return
	end
	Events():WaitForChild("LookIntoHauntedMirror"):FireServer(mirrorModel)
	Notify("Haunted Mirror", "Looking into the mirror...", "info", 2.5)
	task.wait(3)
	Events():WaitForChild("HauntedMirrorEnded"):FireServer()
	Notify("Haunted Mirror", "Finished", "success", 2)
end

-- Sound Muters
local function makeSoundMuter(matchFn)
	local original = {}
	local on = false
	local function tryMute(inst)
		if on and inst:IsA("Sound") and original[inst] == nil then
			local ok, matched = pcall(matchFn, inst)
			if ok and matched then
				original[inst] = inst.Volume
				inst.Volume = 0
			end
		end
	end
	tc(workspace.DescendantAdded:Connect(tryMute))
	local api = {}
	function api.set(v)
		on = v
		if v then
			for _, inst in ipairs(game:GetDescendants()) do
				tryMute(inst)
			end
		else
			for snd, vol in pairs(original) do
				pcall(function() if snd and snd.Parent then snd.Volume = vol end end)
			end
			table.clear(original)
		end
	end
	return api
end
local MusicMuter = makeSoundMuter(function(snd)
	local n = string.lower(snd.Name)
	return snd:IsDescendantOf(game:GetService("SoundService"))
		or string.find(n, "music", 1, true)
		or string.find(n, "theme", 1, true)
		or string.find(n, "ambient", 1, true)
		or string.find(n, "bgm", 1, true)
end)
local GhostSoundMuter = makeSoundMuter(function(snd)
	if S.Ghost and snd:IsDescendantOf(S.Ghost) then return true end
	local n = string.lower(snd.Name)
	return string.find(n, "hunt", 1, true)
		or string.find(n, "ghost", 1, true)
		or string.find(n, "growl", 1, true)
		or string.find(n, "scream", 1, true)
		or string.find(n, "footstep", 1, true)
		or string.find(n, "scratch", 1, true)
		or string.find(n, "breath", 1, true)
end)
local AllSoundMuter = makeSoundMuter(function() return true end)
S.UnmuteAllOnClose = function()
	MusicMuter.set(false)
	GhostSoundMuter.set(false)
	AllSoundMuter.set(false)
end

-- Teleports
local function TpOutside()
	local ok, err = pcall(function()
		local pegboard = workspace:WaitForChild("Map"):WaitForChild("Rooms"):WaitForChild("Base Camp"):WaitForChild("Pegboard")
		local union = pegboard:FindFirstChild("Union")
		local char = plr.Character
		if union and char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = union.CFrame + Vector3.new(0, 3, 0)
		end
	end)
	if not ok then warn("Hunt TP failed:", err) end
end

local function isPointInRegion(part, pos)
	local rel = part.CFrame:PointToObjectSpace(pos)
	return math.abs(rel.X) <= part.Size.X / 2 and math.abs(rel.Y) <= part.Size.Y / 2 and math.abs(rel.Z) <= part.Size.Z / 2
end
local function getRoomName(pos)
	if not S.Rooms then return nil end
	for _, room in ipairs(S.Rooms:GetChildren()) do
		for _, part in ipairs(room:GetDescendants()) do
			if part:IsA("BasePart") and isPointInRegion(part, pos) then
				return room.Name
			end
		end
	end
	return nil
end
local function TpToGhost()
	if not S.Ghost then
		Notify("Not ready", "The round hasn't started yet", "warn", 2.5)
		return
	end
	local Chara = plr.Character
	if Chara then Chara:PivotTo(S.Ghost:GetPivot()) end
end

local function findNearestHidingSpot()
	local char = plr.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	local best, bestDist = nil, math.huge
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Model") or v:IsA("BasePart") then
			local n = string.lower(v.Name)
			if string.find(n, "closet", 1, true) or string.find(n, "locker", 1, true) or string.find(n, "wardrobe", 1, true) or string.find(n, "hiding", 1, true) then
				local ok, pos = pcall(function()
					return v:IsA("Model") and v:GetPivot().Position or v.Position
				end)
				if ok and pos then
					local d = (pos - hrp.Position).Magnitude
					if d < bestDist then bestDist, best = d, v end
				end
			end
		end
	end
	return best
end
local function TpToHidingSpot()
	local spot = findNearestHidingSpot()
	local char = plr.Character
	if not (spot and char) then return false end
	local ok = pcall(function()
		local cf = spot:IsA("Model") and spot:GetPivot() or spot.CFrame
		char:PivotTo(cf + Vector3.new(0, 2, 0))
	end)
	return ok
end

-- Lights & Spirit Box
local function ToggleLightNow(on)
	local map = workspace:FindFirstChild("Map")
	local Rooms = map and map:FindFirstChild("Rooms")
	local events = ReplicatedStorage:FindFirstChild("Events")
	local useLightSwitch = events and events:FindFirstChild("UseLightSwitch")
	if not (Rooms and useLightSwitch) then
		Notify("Lights", "Map is not ready yet", "warn", 2.2)
		return false
	end
	for _, Room in pairs(Rooms:GetChildren()) do
		if Room:GetAttribute("LightsOn") ~= on then
			useLightSwitch:FireServer(Room)
		end
	end
	return true
end
local function ToggleAllDaLights()
	S.LightsOn = not S.LightsOn
	ToggleLightNow(S.LightsOn)
end

local function FireSpiritBox()
	local args = {
		"Are you far away?", "Are you near?", "Where are you?", "What do you want?",
		"When did you cross over?", "Are you in the room with me?", "Do you want us to leave?",
		"When did you pass away?", "What is your goal?", "Why are you here?",
		"How long ago did you die?", "Is there a ghost here?"
	}
	Events():WaitForChild("AskSpiritBoxFromUI"):FireServer(args[math.random(1, #args)])
end
local DelaySBTick = tick()
local function UseSpiritBox()
	if not S.Ghost or not S.AutoSpiritBox then return end
	local Chara = plr.Character
	if not Chara then return end
	local hunting = S.Ghost:GetAttribute("Hunting") == true
	
	if tick() - DelaySBTick > 0.8 then
		DelaySBTick = tick()
		if hunting then
			TpOutside()
			return
		end
		
		Chara:PivotTo(S.Ghost:GetPivot() * CFrame.new(0, 0, 10))
		task.wait(0.1)
		
		local hasBox, slot = CheckInventory("Spirit Box")
		if not hasBox then
			local found, model = FindItem("Spirit Box")
			if found and model then
				PickupItem(model)
				task.wait(0.35)
				ActiveItem()
				task.wait(0.5)
				hasBox, slot = CheckInventory("Spirit Box")
				if hasBox then
					EquipItem(slot)
					task.wait(0.5)
					FireSpiritBox()
				end
			end
		else
			EquipItem(slot)
			task.wait(0.35)
			ActiveItem()
			task.wait(0.35)
			FireSpiritBox()
		end
	end
end

------------------------------------------------------------------
--// EVIDENCE CHECKS
------------------------------------------------------------------
local function TrackTemp()
	local Temp, TempRoom = 100, nil
	if not S.Rooms then return Temp, TempRoom end
	for _, room in ipairs(S.Rooms:GetChildren()) do
		local t = room:GetAttribute("Temperature")
		if t ~= nil and t < Temp then
			Temp = t
			TempRoom = room
		end
	end
	return Temp, TempRoom
end

local function CheckHandprints()
	local folder = workspace:FindFirstChild("Handprints")
	local scanRoot = folder or workspace
	for _, obj in ipairs(scanRoot:GetDescendants()) do
		if obj:IsA("BasePart") and (
			obj.Name == "Handprint1" or obj.Name == "Handprint2" or
			obj.Name == "Footprint" or obj.Name == "Footprint1"
		) then
			return true
		end
	end
	return false
end

local function CheckGhostOrb()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "GhostOrb" then
			return true
		end
	end
	return false
end

local cachedIndicators = nil
local function CheckEMF()
	if not cachedIndicators or not cachedIndicators.Parent then
		cachedIndicators = workspace:FindFirstChild("Indicators", true)
	end
	local Level = 0
	if cachedIndicators then
		for _, v in pairs(cachedIndicators:GetChildren()) do
			local Num = tonumber(v.Name)
			if v:IsA("BasePart") and v.Material == Enum.Material.Neon and Num and Num > Level then
				Level = Num
			end
		end
	end
	return Level
end

local function CheckWither()
	local ItemsFolder = workspace:FindFirstChild("Items")
	for _, obj in ipairs(ItemsFolder and ItemsFolder:GetDescendants() or {}) do
		if obj:IsA("BasePart") and obj.Name == "Petals" and obj.Color == Color3.new(0, 0, 0) then
			return true
		end
	end
	return false
end

local function CheckGhostWriting()
	local ItemsFolder = workspace:FindFirstChild("Items")
	for _, obj in ipairs(ItemsFolder and ItemsFolder:GetDescendants() or {}) do
		if obj:IsA("Decal") then
			local Model = obj:FindFirstAncestorWhichIsA("Model")
			if Model and Model:GetAttribute("ItemName") == "Spirit Book" and obj.Texture ~= "" then
				return true
			end
		end
	end
	return false
end

local function CheckSpiritBox()
	local Subtitles = plr.PlayerGui:FindFirstChild("Subtitles")
	local Holder = Subtitles and Subtitles:FindFirstChild("Holder")
	local SubLabel = Holder and Holder:FindFirstChild("TextLabel")
	return SubLabel ~= nil and #SubLabel.Text:gsub("%s+", "") >= 3
end

local EvShortNames = {
	Handprints = "Prints",
	SpiritBox = "Box",
	GhostOrb = "Orb",
	GhostWriting = "Writing",
	Laser = "Laser",
	Wither = "Wither",
	EMF = "EMF",
	Temperature = "Temp"
}
local GhostMatrix = {
	{ Name = "Aswang", Ev = {"Wither", "Temperature", "EMF"} },
	{ Name = "Banshee", Ev = {"Handprints", "GhostOrb", "Laser"} },
	{ Name = "Demon", Ev = {"Handprints", "GhostWriting", "Temperature"} },
	{ Name = "Dullahan", Ev = {"Wither", "SpiritBox", "Handprints"} },
	{ Name = "Dybbuk", Ev = {"Wither", "GhostOrb", "Laser"} },
	{ Name = "Entity", Ev = {"SpiritBox", "Handprints", "Laser"} },
	{ Name = "Ghoul", Ev = {"SpiritBox", "Temperature", "GhostOrb"} },
	{ Name = "Keres", Ev = {"Wither", "GhostWriting", "Temperature"} },
	{ Name = "Leviathan", Ev = {"GhostOrb", "GhostWriting", "Handprints"} },
	{ Name = "Nightmare", Ev = {"EMF", "SpiritBox", "GhostOrb"} },
	{ Name = "Oni", Ev = {"EMF", "Temperature", "Laser"} },
	{ Name = "Phantom", Ev = {"SpiritBox", "Handprints", "Laser"} },
	{ Name = "Ravager", Ev = {"GhostWriting", "SpiritBox", "EMF"} },
	{ Name = "Revenant", Ev = {"GhostOrb", "GhostWriting", "Temperature"} },
	{ Name = "Shadow", Ev = {"EMF", "GhostWriting", "Laser"} },
	{ Name = "Siren", Ev = {"Wither", "SpiritBox", "GhostOrb"} },
	{ Name = "Skinwalker", Ev = {"Temperature", "GhostWriting", "SpiritBox"} },
	{ Name = "Specter", Ev = {"EMF", "Temperature", "Laser"} },
	{ Name = "Spirit", Ev = {"EMF", "SpiritBox", "GhostWriting"} },
	{ Name = "The Wisp", Ev = {"GhostWriting", "Wither", "Temperature"} },
	{ Name = "Umbra", Ev = {"GhostOrb", "Laser", "Handprints"} },
	{ Name = "Vesper", Ev = {"GhostWriting", "Handprints", "Wither"} },
	{ Name = "Vex", Ev = {"EMF", "Laser", "Wither"} },
	{ Name = "Wendigo", Ev = {"GhostOrb", "GhostWriting", "Laser"} },
	{ Name = "Wraith", Ev = {"EMF", "SpiritBox", "Laser"} },
}
local FoundEvidence = {}

S.GhostLabelSets = {}
local function buildGhostMatrixList(parent, rowH, onResize)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Parent = parent
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = T.Tx3
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	local layout = Instance.new("UIListLayout")
	layout.Parent = scroll
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 3)
	local labels = {}
	for i, g in ipairs(GhostMatrix) do
		local row = Instance.new("Frame")
		row.Name = g.Name
		row.Parent = scroll
		row.LayoutOrder = i
		row.BackgroundTransparency = 1
		row.Size = UDim2.new(1, 0, 0, rowH or 18)
		local dot = Instance.new("Frame")
		dot.Name = "Dot"
		dot.Parent = row
		dot.AnchorPoint = Vector2.new(0, 0.5)
		dot.Position = UDim2.new(0, 2, 0.5, 0)
		dot.Size = UDim2.new(0, 7, 0, 7)
		dot.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		dot.BorderSizePixel = 0
		Corner(dot, 4)
		local lbl = Instance.new("TextLabel")
		lbl.Name = "Label"
		lbl.Parent = row
		lbl.Position = UDim2.new(0, 16, 0, 0)
		lbl.Size = UDim2.new(1, -16, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.RichText = true
		lbl.Font = F
		lbl.TextSize = 13
		lbl.Text = g.Name
		lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
		lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
		lbl.TextStrokeTransparency = 0.6
		lbl.TextTruncate = Enum.TextTruncate.AtEnd
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		labels[g.Name] = { label = lbl, dot = dot, row = row }
	end
	table.insert(S.GhostLabelSets, { labels = labels, onResize = onResize })
	return scroll, labels
end

------------------------------------------------------------------
--// PAGE: EVIDENCE
------------------------------------------------------------------
local StatEvidence, StatGhostInfo, GuesserLabel, EvidenceProgress
do
	local page = Pages["Evidence"]

	local prog = mkSection(page, "Evidence Progress", 1)
	local progLbl = Instance.new("TextLabel")
	progLbl.Parent = prog
	progLbl.LayoutOrder = 1
	progLbl.BackgroundTransparency = 1
	progLbl.Size = UDim2.new(1, 0, 0, 20)
	progLbl.Font = FM
	progLbl.TextSize = 15
	progLbl.TextColor3 = T.White
	progLbl.TextXAlignment = Enum.TextXAlignment.Left
	progLbl.Text = "0 / 3 evidence confirmed"
	local progBarBg = Instance.new("Frame")
	progBarBg.Parent = prog
	progBarBg.LayoutOrder = 2
	progBarBg.Size = UDim2.new(1, 0, 0, 8)
	progBarBg.BackgroundColor3 = T.TgOff
	progBarBg.BorderSizePixel = 0
	Corner(progBarBg, 4)
	local progBarFill = Instance.new("Frame")
	progBarFill.Parent = progBarBg
	progBarFill.Size = UDim2.new(0, 0, 1, 0)
	progBarFill.BackgroundColor3 = T.Accent
	progBarFill.BorderSizePixel = 0
	Corner(progBarFill, 4)
	Grad(progBarFill, Color3.fromRGB(100, 100, 100), Color3.fromRGB(255, 255, 255), 0)
	EvidenceProgress = {
		set = function(count, total)
			progLbl.Text = tostring(count) .. " / " .. tostring(total) .. " evidence confirmed"
			TweenService:Create(progBarFill, TweenInfo.new(0.25), { Size = UDim2.new(count / total, 0, 1, 0) }):Play()
		end
	}

	local live = mkSection(page, "Live Readouts", 2)
	StatEvidence = {
		Handprints = mkEvidenceRow(live, "Handprints", 1),
		SpiritBox = mkEvidenceRow(live, "Spirit Box", 2),
		GhostOrb = mkEvidenceRow(live, "Ghost Orb", 3),
		GhostWriting = mkEvidenceRow(live, "Ghost Writing", 4),
		Laser = mkEvidenceRow(live, "Laser Projector", 5),
		Wither = mkEvidenceRow(live, "Wither", 6),
		EMF = mkEvidenceRow(live, "EMF Level", 7),
		Temperature = mkEvidenceRow(live, "Temperature", 8),
	}

	local info = mkSection(page, "Ghost & Round Info", 3)
	StatGhostInfo = {
		Ghost = mkStat(info, "Ghost", 1),
		GhostRoom = mkStat(info, "Ghost's Room", 2),
		YourRoom = mkStat(info, "Your Room", 3),
		Difficulty = mkStat(info, "Difficulty", 4),
		Photos = mkStat(info, "Photos Taken", 5),
		HuntsDetected = mkStat(info, "Hunts Detected", 6),
		Round = mkStat(info, "Round Status", 7),
	}

	local guess = mkSection(page, "Ghost Guesser", 4)
	local lbl = Instance.new("TextLabel")
	lbl.Parent = guess
	lbl.LayoutOrder = 1
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, 0, 0, 34)
	lbl.Font = FM
	lbl.TextSize = 14
	lbl.TextWrapped = true
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextYAlignment = Enum.TextYAlignment.Top
	lbl.TextColor3 = T.Tx2
	lbl.Text = "Possible ghosts: no evidence yet"
	GuesserLabel = lbl

	local matrixHolder = Instance.new("Frame")
	matrixHolder.Parent = guess
	matrixHolder.LayoutOrder = 2
	matrixHolder.BackgroundTransparency = 1
	matrixHolder.Size = UDim2.new(1, 0, 0, 240)
	buildGhostMatrixList(matrixHolder, 18)

	mkAction(guess, "Reset Round Data", function()
		if S.ResetRoundState then S.ResetRoundState() end
		Notify("Evidence", "Round data reset", "info", 2)
	end, 3)
end

-- Round & Ghost Acquisiton Watcher
local lastGhostInstance = nil
task.spawn(function()
	local waited = false
	while true do
		local g = workspace:FindFirstChild("Ghost")
		local rooms = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Rooms")
		if g and rooms then
			if g ~= lastGhostInstance then
				lastGhostInstance = g
				if S.ResetRoundState then S.ResetRoundState() end
				if waited then
					Notify("Round found", "Evidence tracking is now active", "success", 3)
				end
				if S.GhostEspOn and S.RecreateGhostEsp then
					S.RecreateGhostEsp()
				end
			end
			S.Ghost = g
			S.GhostPart = g:FindFirstChildWhichIsA("BasePart")
			S.Rooms = rooms
			S.Ready = true
			waited = false
		else
			if S.Ready then
				S.Ready = false
				S.Ghost = nil
				S.GhostPart = nil
				lastGhostInstance = nil
				if S.DestroyGhostEsp then S.DestroyGhostEsp() end
				Notify("Round ended", "Waiting for the next round...", "muted", 3)
			end
			if not waited then
				waited = true
				StatGhostInfo.Round.set("waiting for round...", T.Warn)
			end
		end
		task.wait(1)
	end
end)

tc(workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("Sound") and descendant.Name == "Hunt" then
		S.HuntsCount = S.HuntsCount + 1
		local action = (S.AutoHide and "Auto-hide is running") or (S.EscapeHunt and "Auto-escape is running") or "Hide or break line of sight"
		Notify("GHOST IS HUNTING", action, "danger", 4)
		if S.AutoHide then
			if not TpToHidingSpot() and S.EscapeHunt then
				TpOutside()
			end
		elseif S.EscapeHunt then
			TpOutside()
		end
	end
end))

local ghostTag
local function CreateGhostEspInstances()
	if ghostTag then return end
	ghostTag = mkEspTag(S.Ghost, "GHOST", Color3.fromRGB(255, 255, 255), { fill = 0.75 })
end
S.DestroyGhostEsp = function()
	if ghostTag then destroyEspTag(ghostTag); ghostTag = nil end
end
S.RecreateGhostEsp = function()
	S.DestroyGhostEsp()
	if S.Ghost then CreateGhostEspInstances() end
end

-- HEARTBEAT Loop
local LowestTemp = 100
local LowestTempRoom = nil
local HighestEMFLevel = 1
local OldTick = tick()
local PlrTick = tick()
local LowEnergyWarned = false
tc(RS.Heartbeat:Connect(function()
	UseSpiritBox()
	if tick() - PlrTick > S.CheckSpeed then
		PlrTick = tick()
		if S.UpdatePlrEsp then S.UpdatePlrEsp() end
		local energy = plr:GetAttribute("Energy")
		if energy then
			if energy <= 20 and not LowEnergyWarned then
				LowEnergyWarned = true
				Notify("Low Energy", "Energy: " .. tostring(math.floor(energy)) .. "%", "warn", 3.5)
			elseif energy > 35 then
				LowEnergyWarned = false
			end
		end
	end
	if not S.Ready then return end
	if tick() - OldTick <= S.CheckSpeed then return end
	OldTick = tick()

	StatGhostInfo.Difficulty.set(tostring(workspace:GetAttribute("Difficulty") or "Unknown"))
	StatGhostInfo.Photos.set(tostring(workspace:GetAttribute("PhotosTaken") or 0) .. "/6")

	local Temp, TempRoom = TrackTemp()
	local HandprintsCheck = CheckHandprints()
	local GhostOrbCheck = CheckGhostOrb()
	local EMFLevelCheck = CheckEMF()
	local WitherCheck = CheckWither()
	local SpiritBoxCheck = CheckSpiritBox()
	local GhostWritingCheck = CheckGhostWriting()

	local GhostHunting = S.Ghost:GetAttribute("Hunting")
	if ghostTag then
		if GhostHunting then
			ghostTag.setColor(Color3.fromRGB(220, 50, 50))
			if ghostTag.title then ghostTag.title.Text = "GHOST [HUNTING]" end
		else
			ghostTag.setColor(Color3.fromRGB(255, 255, 255))
			if ghostTag.title then ghostTag.title.Text = "GHOST" end
		end
	end
	local GhostFavRoom = S.Ghost:GetAttribute("FavoriteRoom")
	local GhostCurrentRoom = S.Ghost:GetAttribute("CurrentRoom")
	local GhostAge = S.Ghost:GetAttribute("Age")
	local GhostGender = S.Ghost:GetAttribute("Gender")
	local InLaser = S.Ghost:GetAttribute("InLaser")

	if EMFLevelCheck > HighestEMFLevel then HighestEMFLevel = EMFLevelCheck end
	if Temp and Temp < LowestTemp then
		LowestTemp = Temp
		LowestTempRoom = TempRoom
	end

	if HandprintsCheck then FoundEvidence.Handprints = true end
	if GhostOrbCheck then FoundEvidence.GhostOrb = true end
	if SpiritBoxCheck then FoundEvidence.SpiritBox = true end
	if GhostWritingCheck then FoundEvidence.GhostWriting = true end
	if WitherCheck then FoundEvidence.Wither = true end
	if InLaser then FoundEvidence.Laser = true end
	if HighestEMFLevel >= 5 then FoundEvidence.EMF = true end
	if LowestTemp < 0 then FoundEvidence.Temperature = true end

	StatEvidence.Handprints.set(HandprintsCheck and "Yes" or "No", FoundEvidence.Handprints)
	StatEvidence.GhostOrb.set(GhostOrbCheck and "Yes" or "No", FoundEvidence.GhostOrb)
	StatEvidence.SpiritBox.set(SpiritBoxCheck and "Yes" or "No", FoundEvidence.SpiritBox)
	StatEvidence.GhostWriting.set(GhostWritingCheck and "Yes" or "No", FoundEvidence.GhostWriting)
	StatEvidence.Laser.set(InLaser and "Yes" or "No", FoundEvidence.Laser)
	StatEvidence.Wither.set(WitherCheck and "Yes" or "No", FoundEvidence.Wither)
	StatEvidence.EMF.set(tostring(HighestEMFLevel), FoundEvidence.EMF)
	if LowestTempRoom then
		StatEvidence.Temperature.set(string.format("%.1f°C (%s)", LowestTemp, LowestTempRoom.Name), FoundEvidence.Temperature)
	end
	do
		local count = 0
		for _ in pairs(FoundEvidence) do count = count + 1 end
		EvidenceProgress.set(math.min(count, 3), 3)
	end

	if GhostGender and GhostAge and GhostFavRoom then
		StatGhostInfo.Ghost.set(
			(GhostHunting and "HUNTING — " or "") .. GhostGender .. " | Age " .. tostring(GhostAge) .. " | Fav: " .. GhostFavRoom,
			GhostHunting and T.Bad or T.Tx
		)
	else
		StatGhostInfo.Ghost.set(GhostHunting and "Hunting" or "Chilling", GhostHunting and T.Bad or T.Tx)
	end
	if GhostCurrentRoom then StatGhostInfo.GhostRoom.set(GhostCurrentRoom) end
	do
		local char = plr.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			StatGhostInfo.YourRoom.set(getRoomName(hrp.Position) or "Unknown")
		end
	end
	StatGhostInfo.HuntsDetected.set(tostring(S.HuntsCount))
	StatGhostInfo.Round.set("active", T.Good)

	local matches = {}
	local statuses = {}
	for _, g in ipairs(GhostMatrix) do
		local ok = true
		for ev in pairs(FoundEvidence) do
			if not table.find(g.Ev, ev) then ok = false; break end
		end
		if ok then table.insert(matches, g.Name) end
		statuses[g.Name] = ok
	end
	if next(FoundEvidence) == nil then
		GuesserLabel.Text = "Possible ghosts: no evidence yet"
		GuesserLabel.TextColor3 = T.Tx2
	elseif #matches == 1 then
		GuesserLabel.Text = "GHOST TYPE: " .. matches[1]
		GuesserLabel.TextColor3 = T.Good
	elseif #matches == 0 then
		GuesserLabel.Text = "Possible ghosts: none match (conflicting evidence)"
		GuesserLabel.TextColor3 = T.Bad
	else
		GuesserLabel.Text = "Possible (" .. #matches .. "): " .. table.concat(matches, ", ")
		GuesserLabel.TextColor3 = T.Tx2
	end

	for _, listMeta in ipairs(S.GhostLabelSets) do
		local visibleCount = 0
		for _, g in ipairs(GhostMatrix) do
			local entry = listMeta.labels[g.Name]
			if entry then
				if statuses[g.Name] then
					entry.row.Visible = true
					visibleCount = visibleCount + 1
					local needed = {}
					for _, ev in ipairs(g.Ev) do
						if not FoundEvidence[ev] then
							table.insert(needed, EvShortNames[ev] or ev)
						end
					end
					local neededStr = ""
					if #needed == 0 then
						neededStr = " <font color='#ffffff'>[MATCH]</font>"
					else
						neededStr = " <font color='#888888'>(" .. table.concat(needed, ", ") .. ")</font>"
					end
					entry.label.Text = g.Name .. neededStr
					if #matches == 1 then
						entry.label.TextColor3 = Color3.fromRGB(255, 255, 255)
						entry.dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					else
						entry.label.TextColor3 = Color3.fromRGB(220, 220, 220)
						entry.dot.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
					end
				else
					entry.row.Visible = false
				end
			end
		end
		if listMeta.onResize then listMeta.onResize(visibleCount) end
	end
end))

S.ResetRoundState = function()
	table.clear(FoundEvidence)
	HighestEMFLevel = 1
	LowestTemp = 100
	LowestTempRoom = nil
	S.HuntsCount = 0
	for _, row in pairs(StatEvidence) do row.set("--", false) end
	GuesserLabel.Text = "Possible ghosts: no evidence yet"
	GuesserLabel.TextColor3 = T.Tx2
	EvidenceProgress.set(0, 3)
	StatGhostInfo.Ghost.set("--")
	StatGhostInfo.GhostRoom.set("--")
	StatGhostInfo.Photos.set("--")
	StatGhostInfo.HuntsDetected.set("0")
	for _, listMeta in ipairs(S.GhostLabelSets) do
		local total = 0
		for _, g in ipairs(GhostMatrix) do
			local entry = listMeta.labels[g.Name]
			if entry then
				entry.row.Visible = true
				entry.label.Text = g.Name .. " <font color='#888888'>(" .. table.concat(g.Ev, ", ") .. ")</font>"
				entry.label.TextColor3 = Color3.fromRGB(220, 220, 220)
				entry.dot.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
				total = total + 1
			end
		end
		if listMeta.onResize then listMeta.onResize(total) end
	end
	if S.DestroyGhostEsp then S.DestroyGhostEsp() end
end

do
	local watchedHandprints
	local function watchHandprints(folder)
		if watchedHandprints == folder then return end
		watchedHandprints = folder
		tc(folder.ChildAdded:Connect(function()
			if S.UpdateEvidenceEsp then S.UpdateEvidenceEsp() end
		end))
	end

	local existing = workspace:FindFirstChild("Handprints")
	if existing then watchHandprints(existing) end
	tc(workspace.ChildAdded:Connect(function(child)
		if child.Name == "Handprints" then watchHandprints(child) end
	end))
	if existing and S.UpdateEvidenceEsp then S.UpdateEvidenceEsp() end
end

------------------------------------------------------------------
--// PAGE: GHOST & HUNT
------------------------------------------------------------------
do
	local page = Pages["Ghost & Hunt"]
	local tools = mkSection(page, "Ghost Tools", 1)
	mkToggle(tools, "Ghost Cam", false, function(v)
		local Camera = workspace.CurrentCamera
		if v then
			if not S.GhostPart then
				Notify("Not ready", "The round hasn't started yet", "warn", 2.5)
				return
			end
			Camera.CameraSubject = S.GhostPart
		else
			local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
			if hum then Camera.CameraSubject = hum end
		end
		NotifyToggle("Ghost cam", v)
	end, 1)
	mkAction(tools, "Teleport To Ghost", TpToGhost, 2)
	mkToggle(tools, "Mute Music", false, function(v)
		MusicMuter.set(v)
		NotifyToggle("Mute music", v)
	end, 3)
	mkToggle(tools, "Mute Ghost Sounds", false, function(v)
		GhostSoundMuter.set(v)
		NotifyToggle("Mute ghost sounds", v)
	end, 4)
	mkToggle(tools, "Mute All Sounds", false, function(v)
		AllSoundMuter.set(v)
		NotifyToggle("Mute all sounds", v)
	end, 5)

	local hunt = mkSection(page, "Hunt Safety", 2)
	mkToggle(hunt, "Auto Hide (nearest closet)", false, function(v)
		S.AutoHide = v
		if v and S.Ghost and S.Ghost:GetAttribute("Hunting") then
			TpToHidingSpot()
		end
		NotifyToggle("Auto hide", v)
	end, 1, true)
	mkToggle(hunt, "Auto Escape Hunt (run outside)", false, function(v)
		S.EscapeHunt = v
		if v and S.Ghost and S.Ghost:GetAttribute("Hunting") then
			TpOutside()
		end
		NotifyToggle("Hunt escape", v)
	end, 2, true)
	mkAction(hunt, "Teleport To Nearest Hiding Spot", function()
		if not TpToHidingSpot() then
			Notify("Hide", "No hiding spot found nearby", "warn", 2.5)
		end
	end, 3)
	mkAction(hunt, "Teleport To Base", function()
		TpOutside()
		Notify("Teleport", "Moved to base", "info", 2.2)
	end, 4)
end

------------------------------------------------------------------
--// PAGE: AUTOMATION
------------------------------------------------------------------
do
	local page = Pages["Automation"]

	local sb = mkSection(page, "Spirit Box", 1)
	mkToggle(sb, "Auto Spirit Box", false, function(v)
		S.AutoSpiritBox = v
		if not v then
			task.wait(0.2)
			TpOutside()
		end
		NotifyToggle("Auto spirit box", v)
	end, 1, true)

	local photo = mkSection(page, "Photography", 2)
	local db2 = false
	mkAction(photo, "Take Ghost Photo", function()
		if db2 then return end
		if not EquipPhotoCamera() then return end
		if not S.Ghost then return end
		db2 = true
		local args = {
			workspace.CurrentCamera.CFrame,
			{ Stars = 3, Type = "Ghost", Object = S.Ghost, Reward = 24 }
		}
		Events():WaitForChild("TakePhotoWithCamera"):FireServer(unpack(args))
		Notify("Photo", "Ghost photo request sent", "success", 2.5)
		task.delay(1.5, function() db2 = false end)
	end, 1)

	local db3 = false
	local function AlreadyTakenCheck(obj)
		return obj:GetAttribute("Ducko355AlreadyTakenPhoto") == true
	end
	mkAction(photo, "Take 3-Star Photo", function()
		if S.Ghost and S.Ghost:GetAttribute("Hunting") == true then return end
		if db3 then return end
		if not EquipPhotoCamera() then return end
		db3 = true
		task.spawn(function()
			local Item, ItemType = nil, nil
			local ItemsFolder = workspace:FindFirstChild("Items")
			for _, v in pairs(ItemsFolder and ItemsFolder:GetChildren() or {}) do
				if v:GetAttribute("DisplayName") == "Burnt Cross" and not AlreadyTakenCheck(v) then
					v:SetAttribute("Ducko355AlreadyTakenPhoto", true)
					Item, ItemType = v, "BurntCross"
					local HRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
					if HRP then HRP.CFrame = v:GetPivot() * CFrame.new(0, 1, 0) end
					break
				end
			end
			if not Item then
				local Interactables = workspace:FindFirstChild("Interactables")
				for _, v in pairs(Interactables and Interactables:GetChildren() or {}) do
					if v:GetAttribute("PhotoRewardAvailable") == true and not AlreadyTakenCheck(v) then
						v:SetAttribute("Ducko355AlreadyTakenPhoto", true)
						Item, ItemType = v, "Interaction"
						local HRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
						if HRP then HRP.CFrame = v:GetPivot() * CFrame.new(0, 1, 0) end
						break
					end
				end
			end
			if ItemType == "BurntCross" and Item then
				Events():WaitForChild("TakePhotoWithCamera"):FireServer(workspace.CurrentCamera.CFrame, { Stars = 3, Type = "BurntCross", Object = Item, Reward = 12 })
				Notify("3-star photo", "Burnt cross photo request sent", "success", 2.5)
			elseif ItemType == "Interaction" and Item then
				Events():WaitForChild("TakePhotoWithCamera"):FireServer(workspace.CurrentCamera.CFrame, { Stars = 3, Type = "Interaction", Object = Item, Reward = 8 })
				Notify("3-star photo", "Interaction photo request sent", "success", 2.5)
			end
			task.wait(1)
			TpOutside()
			task.wait(1)
			db3 = false
		end)
	end, 2)

	local util = mkSection(page, "Utilities", 3)
	mkAction(util, "Turn On Fuse Box", function()
		Events():WaitForChild("ToggleFuseBox"):FireServer()
		Notify("Fuse box", "Toggle request sent", "info", 2.2)
	end, 1)
	mkToggle(util, "All Lights", false, function()
		ToggleAllDaLights()
		NotifyToggle("All lights", S.LightsOn)
	end, 2)

	local db = false
	mkAction(util, "Place Items Near Ghost", function()
		if db or (S.Ghost and S.Ghost:GetAttribute("Hunting") == true) then return end
		if not S.Ghost then
			Notify("Not ready", "The round hasn't started yet", "warn", 2.5)
			return
		end
		db = true
		task.spawn(function()
			Notify("Place items", "Moving items near ghost", "info", 2.8)
			TpToGhost()
			task.wait(0.1)
			EquipItem(1); task.wait(0.1); DropItem(1); task.wait(0.1)
			EquipItem(1); task.wait(0.1); DropItem(1); task.wait(0.1)
			EquipItem(1); task.wait(0.1); DropItem(1)
			task.wait(0.2)

			local found, model = FindItem("Cross")
			if found then PickupItem(model) end
			task.wait(0.35)
			found, model = FindItem("Cross")
			if found then PickupItem(model) end
			task.wait(0.35)
			found, model = FindItem("Flower Pot")
			if found then PickupItem(model) end
			task.wait(0.5)

			EquipItem(1); task.wait(0.35); ActiveItem(); task.wait(0.35); DropItem(1); task.wait(0.35)
			EquipItem(1); task.wait(0.35); ActiveItem(); task.wait(0.35); DropItem(1); task.wait(0.35)
			EquipItem(1); task.wait(0.35); ActiveItem(); task.wait(0.35); DropItem(1)
			task.wait(0.5)

			found, model = FindItem("Laser Projector")
			if found then PickupItem(model) end
			task.wait(0.35)
			found, model = FindItem("EMF Reader")
			if found then PickupItem(model) end
			task.wait(0.35)
			found, model = FindItem("Spirit Book")
			if found then PickupItem(model) end
			task.wait(0.5)

			EquipItem(1); task.wait(0.6); ActiveItem(); task.wait(0.5); DropItem(1); task.wait(0.35)
			EquipItem(1); task.wait(0.6); ActiveItem(); task.wait(0.5); DropItem(1); task.wait(0.35)
			EquipItem(1); task.wait(0.35); ActiveItem(); task.wait(0.35); DropItem(1); task.wait(0.35)

			TpOutside()
			db = false
			Notify("Place items", "Finished", "success", 2.4)
		end)
	end, 3)
	mkAction(util, "Look Into Haunted Mirror", function()
		task.spawn(UseHauntedMirror)
	end, 4)

	local speedOptions = {0, 0.1, 0.2, 0.5, 1, 1.5, 2, 5, 10}
	local speedLabels = {"0s", "0.1s", "0.2s", "0.5s", "1s", "1.5s", "2s", "5s", "10s"}
	local rate = mkSection(page, "Evidence Check Rate", 4)
	mkCycle(rate, "Check Speed", speedOptions, speedLabels, 1, function(v)
		S.CheckSpeed = v
		Notify("Check speed", tostring(v) .. "s interval", "info", 2)
	end, 1)
end

------------------------------------------------------------------
--// PAGE: ESP
------------------------------------------------------------------
do
	local page = Pages["ESP"]
	local ItemEspList = {}
	local EvidenceEspList = {}
	local FuseEspList = {}
	local DoorEspList = {}
	local HideEspList = {}
	local InteractableEspList = {}
	local RoomDoorEspList = {}
	-- Doors the player has walked through this round. Once a door is this
	-- close it's counted as passed and its tag stops rendering, so Door ESP
	-- only ever clutters the screen with what's still ahead of you.
	local PassedDoors = {}

	local function getEspRoot(inst)
		local root = inst
		local p = inst.Parent
		while p and p ~= workspace and p ~= game do
			if p:IsA("Model") then root = p end
			p = p.Parent
		end
		return root
	end

	local function destroyEspAny(x)
		if type(x) == "table" then destroyEspTag(x) else x:Destroy() end
	end

	local function UpdateEvidenceEsp()
		for _, v in pairs(EvidenceEspList) do destroyEspAny(v) end
		table.clear(EvidenceEspList)
		if not S.EvidenceEsp then return end

		local HandprintsFolder = workspace:FindFirstChild("Handprints")
		for _, obj in ipairs(HandprintsFolder and HandprintsFolder:GetDescendants() or {}) do
			if obj:IsA("BasePart") then
				local img = nil
				for _, v in pairs(obj:GetDescendants()) do
					if v:IsA("ImageLabel") then img = v:Clone() end
				end
				local bb = Instance.new("BillboardGui")
				bb.Name = "DemonologyHandprintsBil"
				bb.Parent = game:GetService("CoreGui")
				bb.AlwaysOnTop = true
				bb.Size = UDim2.new(1.6, 0, 1.6, 0)
				bb.LightInfluence = 0
				bb.Adornee = obj
				bb.StudsOffset = Vector3.new(0, 1, 0)
				if img then
					img.Parent = bb
					img.BackgroundTransparency = 1
					img.ImageTransparency = 0
					img.Size = UDim2.new(1, 0, 1, 0)
					Stroke(img, T.Warn, 1.5, 0.3)
				end
				local hl = Instance.new("Highlight")
				hl.Name = "DemonologyHandprintsHL"
				hl.Parent = obj
				hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				hl.OutlineColor = T.Warn
				hl.FillTransparency = 1
				hl.OutlineTransparency = 0
				hl.Adornee = obj
				table.insert(EvidenceEspList, bb)
				table.insert(EvidenceEspList, hl)
			end
		end

		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and obj.Name == "GhostOrb" then
				obj.Transparency = 0
				table.insert(EvidenceEspList, mkEspTag(obj, "Ghost Orb", T.White, { fill = 0.9 }))
				break
			end
		end
	end

	local function UpdateNamedEsp(on, list, words, labelText, color)
		for _, e in ipairs(list) do destroyEspTag(e) end
		table.clear(list)
		if not on then return end
		local matchedRoots = {}
		for _, v in ipairs(workspace:GetDescendants()) do
			if #list >= 60 then break end
			if v:IsA("Model") or v:IsA("BasePart") then
				local n = string.lower(v.Name)
				for _, w in ipairs(words) do
					if string.find(n, w, 1, true) then
						local root = getEspRoot(v)
						if not matchedRoots[root] then
							matchedRoots[root] = true
							table.insert(list, mkEspTag(root, labelText, color))
						end
						break
					end
				end
			end
		end
	end

	local function doorRootPosition(root)
		if root:IsA("Model") then
			local ok, piv = pcall(function() return root:GetPivot() end)
			return ok and piv.Position or nil
		elseif root:IsA("BasePart") then
			return root.Position
		end
		return nil
	end

	-- Every room door (not the special ExitDoor, which already has its own
	-- tag above) tagged as "Door" — except ones close enough that we've
	-- clearly already walked through them, which get marked passed and
	-- excluded for the rest of the round instead of cluttering the screen.
	local function UpdateRoomDoorEsp()
		for _, e in ipairs(RoomDoorEspList) do destroyEspTag(e) end
		table.clear(RoomDoorEspList)
		if not S.DoorEsp then return end
		local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
		local matchedRoots = {}
		for _, v in ipairs(workspace:GetDescendants()) do
			if #RoomDoorEspList >= 40 then break end
			if v:IsA("Model") or v:IsA("BasePart") then
				local n = string.lower(v.Name)
				if string.find(n, "door", 1, true) and not string.find(n, "exitdoor", 1, true) then
					local root = getEspRoot(v)
					if not matchedRoots[root] and not PassedDoors[root] then
						matchedRoots[root] = true
						local pos = doorRootPosition(root)
						if hrp and pos and (pos - hrp.Position).Magnitude <= 7 then
							PassedDoors[root] = true
						else
							table.insert(RoomDoorEspList, mkEspTag(root, "Door", Color3.fromRGB(130, 130, 130)))
						end
					end
				end
			end
		end
	end

	do
		local prevResetRoundState = S.ResetRoundState
		S.ResetRoundState = function()
			if prevResetRoundState then prevResetRoundState() end
			table.clear(PassedDoors)
		end
	end

	local function UpdateESP()
		-- 1. Evidence ESP
		UpdateEvidenceEsp()

		-- 2. Item ESP
		for _, e in ipairs(ItemEspList) do destroyEspTag(e) end
		table.clear(ItemEspList)
		if S.ItemEsp then
			for _, obj in pairs(workspace:GetDescendants()) do
				if obj:IsA("Model") and obj:GetAttribute("ItemName") ~= nil then
					table.insert(ItemEspList, mkEspTag(obj, obj:GetAttribute("ItemName"), Color3.fromRGB(170, 170, 170)))
				end
			end
		end

		-- 3. Places ESP
		UpdateNamedEsp(S.FuseEsp, FuseEspList, { "fuse", "breaker" }, "Fuse Box", Color3.fromRGB(160, 160, 160))
		UpdateNamedEsp(S.ExitEsp, DoorEspList, { "exitdoor" }, "Exit", Color3.fromRGB(180, 180, 180))
		UpdateRoomDoorEsp()
		UpdateNamedEsp(S.HidingEsp, HideEspList, { "closet", "locker", "wardrobe", "hiding" }, "Hide", Color3.fromRGB(140, 140, 140))

		-- 4. Interactables ESP
		UpdateNamedEsp(S.InteractableEsp, InteractableEspList, { "keyboard", "mouse", "plant", "frame", "toothbrush", "toothpaste", "doll", "tarot", "music", "mirror", "voodoo", "circle", "bone" }, "Interactable", Color3.fromRGB(120, 160, 200))
	end
	S.UpdateEvidenceEsp = UpdateEvidenceEsp
	S.UpdateESP = UpdateESP
	S.ClearItemEsp = function()
		for _, e in ipairs(ItemEspList) do destroyEspTag(e) end
		table.clear(ItemEspList)
	end

	local world = mkSection(page, "World ESP", 1)
	mkToggle(world, "Ghost ESP", false, function(v)
		S.GhostEspOn = v
		if v then
			if not S.Ghost then
				Notify("Not ready", "The round hasn't started yet", "warn", 2.5)
				return
			end
			CreateGhostEspInstances()
			ghostTag.bb.Enabled = true
			if ghostTag.hl then ghostTag.hl.Enabled = true end
		elseif ghostTag then
			ghostTag.bb.Enabled = false
			if ghostTag.hl then ghostTag.hl.Enabled = false end
		end
		NotifyToggle("Ghost ESP", v)
	end, 1)
	mkToggle(world, "Item ESP", false, function(v)
		S.ItemEsp = v
		UpdateESP()
		NotifyToggle("Item ESP", v)
	end, 2)
	mkToggle(world, "Evidence ESP (Handprints, Orb)", false, function(v)
		S.EvidenceEsp = v
		UpdateESP()
		NotifyToggle("Evidence ESP", v)
	end, 3)

	local placesToggles = mkSection(page, "Places ESP", 3)
	mkToggle(placesToggles, "Fuse Box ESP", false, function(v)
		S.FuseEsp = v
		UpdateESP()
		NotifyToggle("Fuse box ESP", v)
	end, 1)
	mkToggle(placesToggles, "Exit Door ESP", false, function(v)
		S.ExitEsp = v
		UpdateESP()
		NotifyToggle("Exit door ESP", v)
	end, 2)
	mkToggle(placesToggles, "Hiding Spot ESP", false, function(v)
		S.HidingEsp = v
		UpdateESP()
		NotifyToggle("Hiding spot ESP", v)
	end, 3)
	mkToggle(placesToggles, "Interactables ESP", false, function(v)
		S.InteractableEsp = v
		UpdateESP()
		NotifyToggle("Interactables ESP", v)
	end, 4)
	mkToggle(placesToggles, "Door ESP (hides already-passed doors)", false, function(v)
		S.DoorEsp = v
		UpdateESP()
		NotifyToggle("Door ESP", v)
	end, 5)

	task.spawn(function()
		while true do
			task.wait(2)
			if S.ItemEsp or S.EvidenceEsp or S.FuseEsp or S.ExitEsp or S.HidingEsp or S.InteractableEsp or S.DoorEsp then
				pcall(UpdateESP)
			end
		end
	end)

	local players = mkSection(page, "Players", 4)
	mkToggle(players, "Players ESP", false, function(v)
		S.PlayersEsp = v
		NotifyToggle("Players ESP", v)
	end, 1)

	local plrTags = {}
	local playerChams = {}
	local playerVisuals = {}
	local chamsOn, boxOn, tracersOn = false, false, false
	local boxStyle = "Corner"

	local function clearChams(p)
		local hl = playerChams[p]
		if hl then hl:Destroy(); playerChams[p] = nil end
	end
	local function clearVisual(p)
		local v = playerVisuals[p]
		if not v then return end
		if v.box then for _, l in ipairs(v.box) do pcall(function() l:Remove() end) end end
		if v.tracer then pcall(function() v.tracer:Remove() end) end
		playerVisuals[p] = nil
	end
	tc(PS.PlayerRemoving:Connect(function(p)
		plrTags[p] = nil
		clearChams(p)
		clearVisual(p)
	end))

	local function updateChamsFor(p)
		if p == plr then return end
		if chamsOn and p.Character then
			if not playerChams[p] or not playerChams[p].Parent then
				local hl = Instance.new("Highlight")
				hl.Name = "DemonologyChams"
				hl.FillColor = Color3.fromRGB(140, 140, 140)
				hl.OutlineColor = Color3.fromRGB(200, 200, 200)
				hl.FillTransparency = 0.55
				hl.OutlineTransparency = 0.2
				hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				hl.Adornee = p.Character
				hl.Parent = p.Character
				playerChams[p] = hl
			end
		else
			clearChams(p)
		end
	end
	mkToggle(players, "Player Chams", false, function(v)
		chamsOn = v
		for _, p in pairs(PS:GetPlayers()) do updateChamsFor(p) end
		NotifyToggle("Player chams", v)
	end, 2)

	local function makeLine(color)
		local l = Drawing.new("Line")
		l.Thickness = 1.5
		l.Color = color
		l.Visible = false
		return l
	end
	local function ensureVisual(p)
		local v = playerVisuals[p]
		if not v then v = {}; playerVisuals[p] = v end
		return v
	end
	local function getScreenBounds(char)
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local camera = workspace.CurrentCamera
		if not hrp or not camera then return nil end
		local topW = hrp.Position + Vector3.new(0, 3, 0)
		local botW = hrp.Position - Vector3.new(0, 3, 0)
		local topP, topOn = camera:WorldToViewportPoint(topW)
		local botP, botOn = camera:WorldToViewportPoint(botW)
		if topP.Z <= 0 or botP.Z <= 0 or not (topOn or botOn) then return nil end
		local h = math.abs(botP.Y - topP.Y)
		local w = h * 0.55
		local cx = (topP.X + botP.X) / 2
		return { top = topP.Y, bottom = botP.Y, left = cx - w / 2, right = cx + w / 2, cx = cx }
	end
	local function updateBoxFor(p, bounds)
		local v = ensureVisual(p)
		if not boxOn or not bounds then
			if v.box then for _, l in ipairs(v.box) do l.Visible = false end end
			return
		end
		if not v.box then
			v.box = {}
			for _ = 1, 8 do table.insert(v.box, makeLine(Color3.fromRGB(180, 180, 180))) end
		end
		local lines = v.box
		local top, bottom, left, right = bounds.top, bounds.bottom, bounds.left, bounds.right
		if boxStyle == "Full" then
			local pts = { Vector2.new(left, top), Vector2.new(right, top), Vector2.new(right, bottom), Vector2.new(left, bottom) }
			for i = 1, 4 do
				lines[i].From = pts[i]
				lines[i].To = pts[i % 4 + 1]
				lines[i].Visible = true
			end
			for i = 5, 8 do lines[i].Visible = false end
		else
			local cl = math.min(right - left, bottom - top) * 0.28
			local segs = {
				{ Vector2.new(left, top), Vector2.new(left + cl, top) },
				{ Vector2.new(left, top), Vector2.new(left, top + cl) },
				{ Vector2.new(right, top), Vector2.new(right - cl, top) },
				{ Vector2.new(right, top), Vector2.new(right, top + cl) },
				{ Vector2.new(left, bottom), Vector2.new(left + cl, bottom) },
				{ Vector2.new(left, bottom), Vector2.new(left, bottom - cl) },
				{ Vector2.new(right, bottom), Vector2.new(right - cl, bottom) },
				{ Vector2.new(right, bottom), Vector2.new(right, bottom - cl) },
			}
			for i = 1, 8 do
				lines[i].From = segs[i][1]
				lines[i].To = segs[i][2]
				lines[i].Visible = true
			end
		end
	end
	local function updateTracerFor(p, bounds)
		local v = ensureVisual(p)
		if not tracersOn or not bounds then
			if v.tracer then v.tracer.Visible = false end
			return
		end
		if not v.tracer then v.tracer = makeLine(Color3.fromRGB(150, 150, 150)) end
		local camera = workspace.CurrentCamera
		local vp = camera and camera.ViewportSize or Vector2.new(0, 0)
		v.tracer.From = Vector2.new(vp.X / 2, vp.Y)
		v.tracer.To = Vector2.new(bounds.cx, bounds.bottom)
		v.tracer.Visible = true
	end
	if Drawing then
		tc(RS.RenderStepped:Connect(function()
			if not (boxOn or tracersOn) then return end
			for _, p in pairs(PS:GetPlayers()) do
				local bounds = (p ~= plr and p.Character) and getScreenBounds(p.Character) or nil
				updateBoxFor(p, bounds)
				updateTracerFor(p, bounds)
			end
		end))
	end
	mkToggle(players, "Player Box ESP", false, function(v)
		if not Drawing then
			Notify("Player Box ESP", "This executor doesn't expose the Drawing library", "warn", 3)
			return
		end
		boxOn = v
		if not v then
			for _, vis in pairs(playerVisuals) do
				if vis.box then for _, l in ipairs(vis.box) do l.Visible = false end end
			end
		end
		NotifyToggle("Player box ESP", v)
	end, 3)
	mkCycle(players, "Box Style", { "Corner", "Full" }, { "Corner Box", "Full Box" }, "Corner", function(v)
		boxStyle = v
	end, 4)
	mkToggle(players, "Player Tracers", false, function(v)
		if not Drawing then
			Notify("Player Tracers", "This executor doesn't expose the Drawing library", "warn", 3)
			return
		end
		tracersOn = v
		if not v then
			for _, vis in pairs(playerVisuals) do
				if vis.tracer then vis.tracer.Visible = false end
			end
		end
		NotifyToggle("Player tracers", v)
	end, 5)

	local energyList = Instance.new("Frame")
	energyList.Parent = players
	energyList.LayoutOrder = 6
	energyList.BackgroundTransparency = 1
	energyList.Size = UDim2.new(1, 0, 0, 0)
	energyList.AutomaticSize = Enum.AutomaticSize.Y
	local energyLayout = Instance.new("UIListLayout")
	energyLayout.Parent = energyList
	energyLayout.SortOrder = Enum.SortOrder.LayoutOrder
	energyLayout.Padding = UDim.new(0, 2)

	local function UpdatePlrEsp()
		if S.PlayersEsp then
			for _, p in pairs(PS:GetPlayers()) do
				if p ~= plr and p.Character then
					local hrp = p.Character:FindFirstChild("HumanoidRootPart")
					if hrp then
						if p:GetAttribute("Dead") == true then
							for _, v in pairs(p.Character:GetDescendants()) do
								if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
									v.Transparency = 0
								end
							end
							if plrTags[p] then plrTags[p].title.Text = p.DisplayName .. " (Dead)" end
						end
						if not plrTags[p] or not plrTags[p].bb.Parent then
							plrTags[p] = mkEspTag(hrp, p.DisplayName, Color3.fromRGB(200, 200, 200), { fill = 0.88 })
						end
					end
				end
			end
		else
			for _, tag in pairs(plrTags) do destroyEspTag(tag) end
			table.clear(plrTags)
		end

		for _, v in pairs(energyList:GetChildren()) do
			if v:IsA("TextLabel") then v:Destroy() end
		end
		for _, p in pairs(PS:GetPlayers()) do
			if p:GetAttribute("Energy") ~= nil then
				local row = Instance.new("TextLabel")
				row.Parent = energyList
				row.BackgroundTransparency = 1
				row.Size = UDim2.new(1, 0, 0, 16)
				row.Font = F
				row.TextSize = 12
				row.TextXAlignment = Enum.TextXAlignment.Left
				row.TextColor3 = T.Tx2
				local pct = math.floor(p:GetAttribute("Energy"))
				if p.Name == p.DisplayName then
					row.Text = p.Name .. ": " .. tostring(pct) .. "%"
				else
					row.Text = p.Name .. " (" .. p.DisplayName .. "): " .. tostring(pct) .. "%"
				end
			end
		end
	end
	S.UpdatePlrEsp = UpdatePlrEsp
	cleanESP = function()
		chamsOn, boxOn, tracersOn = false, false, false
		for p in pairs(playerChams) do clearChams(p) end
		for p in pairs(playerVisuals) do clearVisual(p) end
		for _, e in ipairs(ItemEspList) do destroyEspTag(e) end
		for _, e in ipairs(FuseEspList) do destroyEspTag(e) end
		for _, e in ipairs(DoorEspList) do destroyEspTag(e) end
		for _, e in ipairs(RoomDoorEspList) do destroyEspTag(e) end
		for _, e in ipairs(HideEspList) do destroyEspTag(e) end
		for _, e in ipairs(InteractableEspList) do destroyEspTag(e) end
		table.clear(ItemEspList)
		table.clear(FuseEspList)
		table.clear(DoorEspList)
		table.clear(RoomDoorEspList)
		table.clear(HideEspList)
		table.clear(InteractableEspList)
		table.clear(PassedDoors)
		for _, v in pairs(EvidenceEspList) do destroyEspAny(v) end
		table.clear(EvidenceEspList)
	end
end

------------------------------------------------------------------
--// PAGE: MOVEMENT
------------------------------------------------------------------
do
	local page = Pages["Movement"]
	local move = mkSection(page, "Movement", 1)
	
	tc(RS.Heartbeat:Connect(function()
		if WalkSpeedEnabled and plr.Character then
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.WalkSpeed ~= TargetSpeed then
				hum.WalkSpeed = TargetSpeed
			end
		end
	end))
	
	mkSlider(move, "Walk Speed", 0, 100, 16, function(v)
		if v == 16 then
			WalkSpeedEnabled = false
			local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = 16 end
		else
			TargetSpeed = v
			WalkSpeedEnabled = true
		end
		Notify("Walk speed", tostring(v), "info", 1.6)
	end, 1)

	local Flying = false
	local flyConn = nil
	local function toggleFly(v)
		Flying = v
		if not v then
			if flyConn then flyConn:Disconnect(); flyConn = nil end
			local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				for _, child in ipairs(hrp:GetChildren()) do
					if child:IsA("BodyVelocity") or child:IsA("BodyGyro") then
						child:Destroy()
					end
				end
			end
			return
		end
		local char = plr.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end
		
		local bg = Instance.new("BodyGyro")
		bg.P = 9e4
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = hrp.CFrame
		bg.Parent = hrp
		
		local bv = Instance.new("BodyVelocity")
		bv.velocity = Vector3.new(0, 0.1, 0)
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		bv.Parent = hrp
		
		flyConn = RS.Heartbeat:Connect(function()
			if not Flying or not char.Parent or not hrp.Parent then
				toggleFly(false)
				return
			end
			local cam = workspace.CurrentCamera
			local moveDir = Vector3.new(0, 0, 0)
			if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
			if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
			
			if moveDir.Magnitude > 0 then
				bv.velocity = moveDir.Unit * FlySpeed
			else
				bv.velocity = Vector3.new(0, 0.1, 0)
			end
			bg.cframe = cam.CFrame
		end)
		tc(flyConn)
	end

	mkToggle(move, "Fly", false, function(v)
		toggleFly(v)
		NotifyToggle("Fly", v)
	end, 2)

	mkSlider(move, "Fly Speed", 10, 200, 50, function(v)
		FlySpeed = v
		Notify("Fly Speed", tostring(v), "info", 1.6)
	end, 3)

	local vis = mkSection(page, "Vision", 2)
	local noclipOn = false
	local noclipConn = RS.Stepped:Connect(function()
		if noclipOn and plr.Character then
			for _, p in ipairs(plr.Character:GetDescendants()) do
				if p:IsA("BasePart") and p.CanCollide then
					p.CanCollide = false
				end
			end
		end
	end)
	tc(noclipConn)
	mkToggle(vis, "Noclip", false, function(v)
		noclipOn = v
		NotifyToggle("Noclip", v)
	end, 1)

	local xrayOn = false
	local function ApplyXray(on)
		local map = workspace:FindFirstChild("Map")
		if not map then return end
		for _, p in ipairs(map:GetDescendants()) do
			if p:IsA("BasePart") then
				p.LocalTransparencyModifier = on and 0.6 or 0
			end
		end
	end
	mkToggle(vis, "X-Ray", false, function(v)
		xrayOn = v
		ApplyXray(v)
		NotifyToggle("X-Ray", v)
	end, 2)

	mkToggle(vis, "Full Bright", false, function(v)
		if v then
			Lighting.Ambient = Color3.new(1, 1, 1)
			Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
			Lighting.Brightness = 3
			Lighting.GlobalShadows = false
			Lighting.FogEnd = 100000
		else
			Lighting.Ambient = S.OldLighting.Ambient
			Lighting.OutdoorAmbient = S.OldLighting.OutdoorAmbient
			Lighting.Brightness = S.OldLighting.Brightness
			Lighting.GlobalShadows = S.OldLighting.GlobalShadows
			Lighting.FogEnd = S.OldLighting.FogEnd
		end
		NotifyToggle("Full bright", v)
	end, 3)

	S.DisableAllExtras = function()
		noclipOn = false
		if xrayOn then xrayOn = false; ApplyXray(false) end
	end
end

------------------------------------------------------------------
--// PAGE: TELEPORT
------------------------------------------------------------------
do
	local page = Pages["Teleport"]
	local tp = mkSection(page, "Teleports", 1)
	mkAction(tp, "Teleport To Ghost", function()
		if S.Ghost and S.Ghost:GetAttribute("Hunting") == true then return end
		TpToGhost()
		Notify("Teleport", "Moved to ghost", "info", 2.2)
	end, 1)
	mkAction(tp, "Teleport To Base", function()
		TpOutside()
		Notify("Teleport", "Moved to base", "info", 2.2)
	end, 2)
	mkAction(tp, "Teleport To Coldest Room", function()
		local _, TempRoom = TrackTemp()
		local Chara = plr.Character
		if TempRoom and Chara then
			local part = TempRoom:FindFirstChildWhichIsA("BasePart", true)
			if part then
				Chara:PivotTo(part.CFrame + Vector3.new(0, 3, 0))
				Notify("Teleport", "Moved to coldest room", "info", 2.2)
			else
				Notify("Teleport", "Coldest room part not found", "warn", 2.6)
			end
		else
			Notify("Teleport", "Coldest room not found", "warn", 2.6)
		end
	end, 3)

	local targetTp = mkSection(page, "Target Teleports", 2)
	local selectedPlayer = "None"
	local selectedItem = "None"

	local playerCycle = mkCycle(targetTp, "Select Player", {"None"}, {"None"}, "None", function(v)
		selectedPlayer = v
	end, 1)

	mkAction(targetTp, "Teleport To Player", function()
		if selectedPlayer == "None" or selectedPlayer == "No players found" then
			Notify("Teleport", "No target selected", "warn", 2.2)
			return
		end
		local target = PS:FindFirstChild(selectedPlayer)
		local char = target and target.Character
		local myChar = plr.Character
		if char and myChar then
			myChar:PivotTo(char:GetPivot())
			Notify("Teleport", "Moved to " .. selectedPlayer, "success", 2.2)
		else
			Notify("Teleport", "Player character not found", "warn", 2.5)
		end
	end, 2)

	local itemCycle = mkCycle(targetTp, "Select Item", {"None"}, {"None"}, "None", function(v)
		selectedItem = v
	end, 3)

	mkAction(targetTp, "Teleport To Item", function()
		if selectedItem == "None" or selectedItem == "No items found" then
			Notify("Teleport", "No item selected", "warn", 2.2)
			return
		end
		local itemsFolder = workspace:FindFirstChild("Items")
		if not itemsFolder then return end
		local targetItem = nil
		for _, v in pairs(itemsFolder:GetChildren()) do
			if v:IsA("Model") and v:GetAttribute("ItemName") == selectedItem then
				targetItem = v
				break
			end
		end
		local myChar = plr.Character
		if targetItem and myChar then
			myChar:PivotTo(targetItem:GetPivot() + Vector3.new(0, 2, 0))
			Notify("Teleport", "Moved to " .. selectedItem, "success", 2.2)
		else
			Notify("Teleport", "Item not found on map", "warn", 2.5)
		end
	end, 4)

	task.spawn(function()
		while true do
			task.wait(3)
			local pList = {}
			for _, p in ipairs(PS:GetPlayers()) do
				if p ~= plr then table.insert(pList, p.Name) end
			end
			if #pList == 0 then pList = {"None"} end
			playerCycle.update(pList)
			
			local iList = {}
			local itemsFolder = workspace:FindFirstChild("Items")
			if itemsFolder then
				local seen = {}
				for _, v in pairs(itemsFolder:GetChildren()) do
					if v:IsA("Model") and v:GetAttribute("ItemName") then
						local name = v:GetAttribute("ItemName")
						if not seen[name] then
							seen[name] = true
							table.insert(iList, name)
						end
					end
				end
			end
			if #iList == 0 then iList = {"None"} end
			itemCycle.update(iList)
		end
	end)
end

------------------------------------------------------------------
--// PAGE: MISC
------------------------------------------------------------------
do
	local page = Pages["Misc"]
	local util = mkSection(page, "Utility", 1)
	local antiAfkOn = true
	local afkConn = plr.Idled:Connect(function()
		if antiAfkOn then
			local vu = game:GetService("VirtualUser")
			vu:CaptureController()
			vu:ClickButton2(Vector2.new())
		end
	end)
	tc(afkConn)
	mkToggle(util, "Anti-AFK", true, function(v)
		antiAfkOn = v
		NotifyToggle("Anti-AFK", v)
	end, 1)
	mkAction(util, "Load Infinite Yield", function()
		Notify("Infinite Yield", "Loading external script", "info", 2.4)
		local ok, err = pcall(function()
			loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
		end)
		if not ok then
			Notify("Infinite Yield", "Failed to load: " .. tostring(err), "danger", 3.5)
		end
	end, 2)

	local prevDisable = S.DisableAllExtras
	S.DisableAllExtras = function()
		if prevDisable then prevDisable() end
		antiAfkOn = false
	end
end

------------------------------------------------------------------
--// PAGE: HUD
------------------------------------------------------------------
do
	local page = Pages["HUD"]
	local panels = mkSection(page, "HUD Panels", 1)

	local ghostListHud = mkDragHUD("Ghost List", UDim2.new(1, -230, 0.5, -200), UDim2.fromOffset(220, 400), 850)
	buildGhostMatrixList(ghostListHud.content, 16, function(count)
		local h = math.clamp(count * 19 + 49, 70, 400)
		TweenService:Create(ghostListHud.frame, TweenInfo.new(0.2), { Size = UDim2.fromOffset(220, h) }):Play()
	end)
	mkToggle(panels, "Ghost List HUD", false, function(v)
		ghostListHud.frame.Visible = v
		NotifyToggle("Ghost list HUD", v)
	end, 1)

	local keybindsHud = mkDragHUD("Keybinds", UDim2.new(0, 18, 0.35, 0), UDim2.fromOffset(280, 100), 851)
	local kbLbl = Instance.new("TextLabel")
	kbLbl.Parent = keybindsHud.content
	kbLbl.BackgroundTransparency = 1
	kbLbl.Size = UDim2.new(1, 0, 1, 0)
	kbLbl.Font = F
	kbLbl.TextSize = 16
	kbLbl.TextColor3 = T.Tx
	kbLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
	kbLbl.TextStrokeTransparency = 0.5
	kbLbl.TextXAlignment = Enum.TextXAlignment.Left
	kbLbl.TextYAlignment = Enum.TextYAlignment.Top
	kbLbl.TextWrapped = true
	kbLbl.LineHeight = 1.3
	kbLbl.Text = "Insert — show / hide menu"
	mkToggle(panels, "Keybinds HUD", false, function(v)
		keybindsHud.frame.Visible = v
		NotifyToggle("Keybinds HUD", v)
	end, 2)

	local fpsHud = mkDragHUD("Performance", UDim2.new(1, -178, 0, 72), UDim2.fromOffset(160, 70), 852)
	local fpsLbl = Instance.new("TextLabel")
	fpsLbl.Parent = fpsHud.content
	fpsLbl.BackgroundTransparency = 1
	fpsLbl.Size = UDim2.new(1, 0, 1, 0)
	fpsLbl.Font = FM
	fpsLbl.TextSize = 16
	fpsLbl.TextColor3 = T.White
	fpsLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
	fpsLbl.TextStrokeTransparency = 0.5
	fpsLbl.TextXAlignment = Enum.TextXAlignment.Left
	fpsLbl.Text = "FPS: --"
	mkToggle(panels, "FPS HUD", false, function(v)
		fpsHud.frame.Visible = v
		NotifyToggle("FPS HUD", v)
	end, 3)
	do
		local frames, elapsed = 0, 0
		tc(RS.RenderStepped:Connect(function(dt)
			frames = frames + 1
			elapsed = elapsed + dt
			if elapsed >= 0.5 then
				fpsLbl.Text = "FPS: " .. tostring(math.floor((frames / elapsed) + 0.5))
				frames, elapsed = 0, 0
			end
		end))
	end

	local statusHud = mkDragHUD("HUD Status", UDim2.new(1, -268, 0, 146), UDim2.fromOffset(240, 104), 853)
	local statusLbl = Instance.new("TextLabel")
	statusLbl.Parent = statusHud.content
	statusLbl.BackgroundTransparency = 1
	statusLbl.Size = UDim2.new(1, 0, 1, 0)
	statusLbl.Font = F
	statusLbl.TextSize = 14
	statusLbl.TextColor3 = T.Tx
	statusLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
	statusLbl.TextStrokeTransparency = 0.5
	statusLbl.TextXAlignment = Enum.TextXAlignment.Left
	statusLbl.TextYAlignment = Enum.TextYAlignment.Top
	statusLbl.TextWrapped = true
	statusLbl.LineHeight = 1.3
	mkToggle(panels, "Status HUD", false, function(v)
		statusHud.frame.Visible = v
		NotifyToggle("Status HUD", v)
	end, 4)
	mkToggle(panels, "Lock HUD Position", false, function(v)
		hudLocked = v
		NotifyToggle("HUD lock", v)
	end, 5)
	mouseUnlockToggle = mkToggle(panels, "Unlock Mouse", false, function(v)
		MouseUnlocked = v
		NotifyToggle("Mouse unlock", v)
	end, 6, false, Enum.KeyCode.LeftAlt)

	local radarHud = mkDragHUD("Ghost Radar", UDim2.new(0.5, -105, 1, -240), UDim2.fromOffset(210, 230), 854)
	local radarRoomLbl = Instance.new("TextLabel")
	radarRoomLbl.Parent = radarHud.content
	radarRoomLbl.Position = UDim2.new(0, 0, 0, 0)
	radarRoomLbl.Size = UDim2.new(1, 0, 0, 18)
	radarRoomLbl.BackgroundTransparency = 1
	radarRoomLbl.Font = FM
	radarRoomLbl.TextSize = 13
	radarRoomLbl.TextColor3 = T.Tx
	radarRoomLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
	radarRoomLbl.TextStrokeTransparency = 0.5
	radarRoomLbl.TextTruncate = Enum.TextTruncate.AtEnd
	radarRoomLbl.Text = "Room: --"
	local radarCircle = Instance.new("Frame")
	radarCircle.Parent = radarHud.content
	radarCircle.AnchorPoint = Vector2.new(0.5, 0)
	radarCircle.Position = UDim2.new(0.5, 0, 0, 24)
	radarCircle.Size = UDim2.new(0, 140, 0, 140)
	radarCircle.BackgroundColor3 = T.Card
	radarCircle.BackgroundTransparency = 0.15
	Corner(radarCircle, 999)
	Stroke(radarCircle, T.Bd2, 1.2, 0.2)
	local radarRing = Instance.new("Frame")
	radarRing.Parent = radarCircle
	radarRing.AnchorPoint = Vector2.new(0.5, 0.5)
	radarRing.Position = UDim2.new(0.5, 0, 0.5, 0)
	radarRing.Size = UDim2.new(0.6, 0, 0.6, 0)
	radarRing.BackgroundTransparency = 1
	Corner(radarRing, 999)
	Stroke(radarRing, T.Bd2, 1, 0.55)
	local radarMe = Instance.new("Frame")
	radarMe.Parent = radarCircle
	radarMe.AnchorPoint = Vector2.new(0.5, 0.5)
	radarMe.Position = UDim2.new(0.5, 0, 0.5, 0)
	radarMe.Size = UDim2.new(0, 8, 0, 8)
	radarMe.BackgroundColor3 = T.White
	Corner(radarMe, 4)
	local radarDot = Instance.new("Frame")
	radarDot.Parent = radarCircle
	radarDot.AnchorPoint = Vector2.new(0.5, 0.5)
	radarDot.Position = UDim2.new(0.5, 0, 0.5, 0)
	radarDot.Size = UDim2.new(0, 14, 0, 14)
	radarDot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	radarDot.Visible = false
	Corner(radarDot, 7)
	Stroke(radarDot, T.White, 1, 0.2)
	local radarDistLbl = Instance.new("TextLabel")
	radarDistLbl.Parent = radarHud.content
	radarDistLbl.AnchorPoint = Vector2.new(0.5, 1)
	radarDistLbl.Position = UDim2.new(0.5, 0, 1, 0)
	radarDistLbl.Size = UDim2.new(1, 0, 0, 16)
	radarDistLbl.BackgroundTransparency = 1
	radarDistLbl.Font = FM
	radarDistLbl.TextSize = 13
	radarDistLbl.TextColor3 = T.Tx
	radarDistLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
	radarDistLbl.TextStrokeTransparency = 0.5
	radarDistLbl.Text = "waiting..."
	mkToggle(panels, "Ghost Radar HUD", false, function(v)
		radarHud.frame.Visible = v
		NotifyToggle("Ghost radar HUD", v)
	end, 7)
	do
		local radarTick = tick()
		tc(RS.Heartbeat:Connect(function()
			if tick() - radarTick < 0.15 then return end
			radarTick = tick()
			local char = plr.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp and S.Ghost then
				local ok, rel = pcall(function()
					return hrp.CFrame:PointToObjectSpace(S.Ghost:GetPivot().Position)
				end)
				if ok then
					local dist = Vector3.new(rel.X, 0, rel.Z).Magnitude
					local scale = math.min(dist, 120) / 120 * 62
					local px, py = 0, 0
					if dist > 0.01 then
						px = (rel.X / dist) * scale
						py = (rel.Z / dist) * scale
					end
					radarDot.Visible = true
					radarDot.Position = UDim2.new(0.5, px, 0.5, py)
					radarDistLbl.Text = tostring(math.floor(dist)) .. " studs"
					radarRoomLbl.Text = "Room: " .. tostring(S.Ghost:GetAttribute("CurrentRoom") or "Unknown")
				end
			else
				radarDot.Visible = false
				radarDistLbl.Text = S.Ready and "" or "waiting for round..."
				radarRoomLbl.Text = "Room: --"
			end
		end))
	end

	do
		local statusTick = tick()
		tc(RS.Heartbeat:Connect(function()
			if tick() - statusTick < 0.5 then return end
			statusTick = tick()
			statusLbl.Text = "Menu: " .. (Main.Visible and "open" or "closed")
				.. "\nHUD: " .. (hudLocked and "locked" or "unlocked")
				.. "\nRound: " .. (S.Ready and "active" or "waiting")
		end))
	end

	-- Dynamic Island: floating top-center status bar matched to mm2's look (brand dot + label,
	-- divider, then STATE / PING / FPS / TIME). Built from raw T.* colors so UIStyle:ReplaceColor
	-- recolors it on theme switch automatically; the DynamicIslandGradient name already has a handler.
	local island = Instance.new("Frame")
	island.Name = "HUD_Watermark"
	island.Parent = SG
	local wScale = Instance.new("UIScale", island)
	wScale.Scale = 0.85
	island:SetAttribute("ScalableHUD", true)
	island.Active = true
	island.AnchorPoint = Vector2.new(0.5, 0)
	island.Position = UDim2.new(0.5, 0, 0, 12)
	island.Size = UDim2.fromOffset(382, 46)
	island.BackgroundColor3 = T.Sidebar
	island.BackgroundTransparency = 0.008
	island.BorderSizePixel = 0
	-- On by default on mobile: it is that build's only always-on HUD, and the
	-- menu animates in and out of it.
	island.Visible = MOBILE
	island.ZIndex = 864
	Corner(island, 15)
	Stroke(island, T.Bd2, 1, 0.18)
	Shadow(island, 0.82)
	local islandGrad = Grad(island, T.White:Lerp(T.Accent, 0.14), T.White:Lerp(T.Card, 0.08), 0)
	islandGrad.Name = "DynamicIslandGradient"
	local islandScale = Instance.new("UIScale")
	islandScale.Name = "HUDUserScale"; islandScale.Scale = S.HUDScale; islandScale.Parent = island
	local iDot = Instance.new("Frame")
	iDot.Parent = island
	iDot.AnchorPoint = Vector2.new(0, 0.5)
	iDot.Position = UDim2.new(0, 13, 0.5, 0)
	iDot.Size = UDim2.fromOffset(6, 6)
	iDot.BackgroundColor3 = T.Accent
	iDot.BackgroundTransparency = 0.05
	iDot.BorderSizePixel = 0
	iDot.ZIndex = 866
	Corner(iDot, 4)
	local iBrand = Instance.new("TextLabel")
	iBrand.Parent = island
	iBrand.Position = UDim2.new(0, 26, 0, 0)
	iBrand.Size = UDim2.new(0, 72, 1, 0)
	iBrand.BackgroundTransparency = 1
	iBrand.Font = FB
	iBrand.TextSize = 12
	iBrand.TextColor3 = T.White
	iBrand.TextYAlignment = Enum.TextYAlignment.Center
	iBrand.TextXAlignment = Enum.TextXAlignment.Left
	iBrand.Text = "INERTIA"
	iBrand.ZIndex = 866
	local iDiv = Instance.new("Frame")
	iDiv.Parent = island
	iDiv.Position = UDim2.new(0, 104, 0.5, -12)
	iDiv.Size = UDim2.fromOffset(1, 24)
	iDiv.BackgroundColor3 = T.Bd2
	iDiv.BackgroundTransparency = 0.28
	iDiv.BorderSizePixel = 0
	iDiv.ZIndex = 866
	local function islandMetric(x, width, caption)
		local key = Instance.new("TextLabel")
		key.Parent = island
		key.Position = UDim2.fromOffset(x, 6)
		key.Size = UDim2.fromOffset(width, 12)
		key.BackgroundTransparency = 1
		key.Font = FB
		key.TextSize = 10
		key.TextColor3 = T.Tx3
		key.TextXAlignment = Enum.TextXAlignment.Left
		key.Text = caption
		key.ZIndex = 866
		local value = Instance.new("TextLabel")
		value.Parent = island
		value.Position = UDim2.fromOffset(x, 19)
		value.Size = UDim2.fromOffset(width, 20)
		value.BackgroundTransparency = 1
		value.Font = FM
		value.TextSize = 13
		value.TextColor3 = T.Tx
		value.TextXAlignment = Enum.TextXAlignment.Left
		value.TextTruncate = Enum.TextTruncate.AtEnd
		value.Text = "--"
		value.ZIndex = 866
		return value
	end
	local iState = islandMetric(116, 80, "STATE")
	local iPing = islandMetric(201, 48, "PING")
	local iFps = islandMetric(254, 44, "FPS")
	local iTime = islandMetric(303, 60, "TIME")
	makeElementDraggable(island, island)
	HUDEls["Watermark"] = { frame = island, content = island, setLocked = function(v) end }

	local islandTapStart
	island.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			islandTapStart = input.Position
		end
	end)
	island.InputEnded:Connect(function(input)
		if islandTapStart and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = (input.Position - islandTapStart).Magnitude
			if delta < 10 then
				setMenuOpen(not MenuOpen)
			end
			islandTapStart = nil
		end
	end)

	mkToggle(panels, "Dynamic Island", MOBILE, function(v)
		island.Visible = v
		NotifyToggle("Dynamic Island", v)
	end, 8)

	-- The mobile menu animates in and out of this bar like a droplet, so the
	-- island publishes its own centre (in Scale, from the live AbsolutePosition
	-- so HUD scale and screen size are already accounted for) and a squash it
	-- plays when the window is swallowed or spat back out.
	S._islandPoint = function()
		local camera = workspace.CurrentCamera
		local vp = camera and camera.ViewportSize
		if not vp or vp.X <= 0 or vp.Y <= 0 or not island.Parent then
			return UDim2.new(0.5, 0, 0, 34)
		end
		local centre = island.AbsolutePosition + island.AbsoluteSize / 2
		return UDim2.fromScale(math.clamp(centre.X / vp.X, 0, 1), math.clamp(centre.Y / vp.Y, 0, 1))
	end
	S._islandGulp = function(outward)
		if not island.Visible then return end
		-- Read the target from S.HUDScale, not from the live UIScale: a gulp that
		-- lands mid-tween would otherwise bake in a transient value.
		local base = S.HUDScale
		TweenService:Create(islandScale, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
			Scale = base * (outward and 1.1 or 0.9),
		}):Play()
		task.delay(0.12, function()
			if island.Parent then
				TweenService:Create(islandScale, TweenInfo.new(0.22, Enum.EasingStyle.Back), { Scale = base }):Play()
			end
		end)
	end
	do
		local islandStart = os.time()
		local iframes, ielapsed, ifps = 0, 0, 0
		tc(RS.RenderStepped:Connect(function(dt)
			iframes = iframes + 1
			ielapsed = ielapsed + dt
			if ielapsed >= 0.5 then
				ifps = math.floor((iframes / ielapsed) + 0.5)
				iframes, ielapsed = 0, 0
			end
		end))
		task.spawn(function()
			while island.Parent do
				if island.Visible then
					local ping = math.floor((plr:GetNetworkPing() or 0) * 1000 + 0.5)
					iPing.Text = ping .. "ms"
					iFps.Text = tostring(ifps)
					local elapsed = os.time() - islandStart
					if elapsed >= 3600 then
						iTime.Text = string.format("%02d:%02d", math.floor(elapsed / 3600), math.floor((elapsed % 3600) / 60))
					else
						iTime.Text = string.format("%02d:%02d", math.floor(elapsed / 60), elapsed % 60)
					end
					local ready = S.Ready
					iState.Text = ready and "ACTIVE" or "WAITING"
					iState.TextColor3 = ready and T.Accent or T.Tx
					iDot.BackgroundColor3 = ready and T.Accent or T.Tx4
					iDot.BackgroundTransparency = ready and 0.05 or 0.4
				end
				task.wait(0.25)
			end
		end)
	end
end

--=====================================================================
--// TAB: BUTTONS (mobile) — the Floating Buttons manager
--=====================================================================
-- Built LAST on purpose: it lists every registered control, and that registry
-- is only complete once every other tab has finished building.
if MOBILE and Pages["Buttons"] then
	-- The menu button drives the window itself rather than a game feature, and
	-- it is the one button that cannot be removed: deleting it on a device with
	-- no keyboard would leave no way to reopen the menu at all.
	-- Menu float button removed per user request

	local secFloat = mkSection(Pages["Buttons"], "Floating Buttons", 1)

	local note = Instance.new("TextLabel")
	note.Parent = secFloat
	note.LayoutOrder = 1
	note.BackgroundTransparency = 1
	note.Size = UDim2.new(1, 0, 0, 40)
	note.Font = F
	note.TextSize = 12
	note.TextColor3 = T.Tx3
	note.TextXAlignment = Enum.TextXAlignment.Left
	note.TextWrapped = true
	note.Text = "Вынеси функцию на экран — кнопку можно перетащить пальцем, позиция сохраняется."

	local paints = {}
	local order = {}
	for id, entry in pairs(FloatReg) do
		table.insert(order, { id = id, label = tostring(entry.label or id) })
	end
	-- Menu first, then alphabetical: the one permanent button stays at the top.
	table.sort(order, function(a, b)
		if (a.id == "ui:menu") ~= (b.id == "ui:menu") then return a.id == "ui:menu" end
		return string.lower(a.label) < string.lower(b.label)
	end)

	local function mkPill(parent, text, x)
		local pill = Instance.new("TextButton")
		pill.Parent = parent
		pill.AnchorPoint = Vector2.new(1, 0.5)
		pill.Position = UDim2.new(1, x, 0.5, 0)
		pill.Size = UDim2.fromOffset(74, 32)
		pill.BackgroundColor3 = T.Elev
		pill.BorderSizePixel = 0
		pill.AutoButtonColor = false
		pill.Font = FM
		pill.TextSize = 11
		pill.TextColor3 = T.Tx2
		pill.Text = text
		pill.ZIndex = 3
		Corner(pill, 9)
		return pill, Stroke(pill, T.Bd2, 1, 0.42)
	end

	for index, item in ipairs(order) do
		local row = Instance.new("Frame")
		row.Name = item.id
		row.Parent = secFloat
		row.LayoutOrder = index + 1
		row.Size = UDim2.new(1, 0, 0, M.rowH)
		row.BackgroundTransparency = 1

		local label = Instance.new("TextLabel")
		label.Parent = row
		label.BackgroundTransparency = 1
		label.Position = UDim2.new(0, 6, 0, 0)
		label.Size = UDim2.new(1, -170, 1, 0)
		label.Font = F
		label.TextSize = M.rowFont
		label.TextColor3 = T.Tx2
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextTruncate = Enum.TextTruncate.AtEnd
		label.Text = item.label

		local enable, enableStroke = mkPill(row, "ENABLE", -82)
		local remove, removeStroke = mkPill(row, "REMOVE", -4)

		local locked = item.id == "ui:menu"
		local function paint()
			local on = S._floatIsOn(item.id)
			enable.BackgroundColor3 = on and T.ActiveBg or T.Elev
			enable.TextColor3 = on and T.White or T.Tx2
			enable.Text = on and "ON SCREEN" or "ENABLE"
			enableStroke.Color = on and T.Accent or T.Bd2
			enableStroke.Transparency = on and 0.15 or 0.42
			label.TextColor3 = on and T.Tx or T.Tx2
			remove.Visible = not locked
			remove.TextColor3 = on and T.Tx or T.Tx4
			removeStroke.Transparency = on and 0.35 or 0.6
		end
		paints[item.id] = paint
		enable.MouseButton1Click:Connect(function() S._floatSet(item.id, true) end)
		remove.MouseButton1Click:Connect(function()
			if not locked then S._floatSet(item.id, false) end
		end)
		paint()
	end

	local clearAll = mkAction(secFloat, "Remove All Buttons", function()
		if S._floatClearAll then S._floatClearAll() end
		Notify("Buttons", "All floating buttons removed", "info", 2)
	end, #order + 2)
	clearAll.Name = "RemoveAllFloating"

	S._refreshFloatTab = function()
		for _, paint in pairs(paints) do pcall(paint) end
	end

	-- Layout persistence rides the existing config system: one more entry in
	-- ConfigControls, saved and restored exactly like every toggle.
	table.insert(ConfigControls, {
		id = "#floatbuttons",
		get = function() return S._floatGetMap() end,
		set = function(v) if type(v) == "table" then S._floatApplyMap(v) end end,
	})

	-- The menu button exists from the first frame, before any config has loaded.
	S._floatSet("ui:menu", true)
end

-- Config callbacks can depend on round-only folders. Restore them away from
-- the UI thread so a missing game object can never prevent Insert from opening
-- the menu.
task.spawn(function()
	if S._LoadConfig then S._LoadConfig() end
end)

-- Auto-open Main Door
task.spawn(function()
	task.wait(30)
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v.Name == "ExitDoor" then
			if v:GetAttribute("DoorClosed") ~= false then
				Events():WaitForChild("ClientChangeDoorState"):FireServer(v:WaitForChild("Door"))
			end
			break
		end
	end
end)
