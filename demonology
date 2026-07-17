_D = function(s)
	local r = {}
	for i = 1, #s do
		r[i] = string.char(bit32.bxor(s:byte(i), 244))
	end
	return table.concat(r)
end



local _lII111IIIIllI = game:GetService(_D("\166\129\154\167\145\134\130\157\151\145"))
local _lI1lI1l1Il1I1I = game:GetService(_D("\164\152\149\141\145\134\135"))
local _1lllII11l1I = game:GetService(_D("\184\157\147\156\128\157\154\147"))
local TweenService = game:GetService(_D("\160\131\145\145\154\167\145\134\130\157\151\145"))
local _lII1I1I11 = game:GetService(_D("\161\135\145\134\189\154\132\129\128\167\145\134\130\157\151\145"))
local _lIIIl1llIlIll = game:GetService(_D("\166\145\132\152\157\151\149\128\145\144\167\128\155\134\149\147\145"))
local plr = _lI1lI1l1Il1I1I.LocalPlayer

local function _lIIIl11lllllI()
	return _lIIIl1llIlIll:WaitForChild(_D("\177\130\145\154\128\135"))
end


local _1l1l1l1Il
local _lIlll11II1llII
local _1II111II1l1Il1
local _11I1IIll11Il


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
	HidingEsp = false,
	InteractableEsp = false,
	Ready = false,
	GhostEspOn = false,
	HuntsCount = 0,
}
local hudLocked = false
local _1l1ll1I111lllll = false
local _l1IlIIII11lll = 50
local _1llIl1llIIlIl = false
local _I11lII1ll = false
local _II1Il1l1l = 16

local function _1I111I1ll(_lll1I1IlIll1l1)
	table.insert(S.Connections, _lll1I1IlIll1l1)
	return _lll1I1IlIll1l1
end


local T = {
	BG       = Color3.fromRGB(15, 15, 15),
	Sidebar  = Color3.fromRGB(10, 10, 10),
	Card     = Color3.fromRGB(22, 22, 22),
	Elev     = Color3.fromRGB(28, 28, 28),
	Hover    = Color3.fromRGB(38, 38, 38),
	ActiveBg = Color3.fromRGB(48, 48, 48),
	White    = Color3.fromRGB(255, 255, 255),
	Tx       = Color3.fromRGB(240, 240, 240),
	Tx2      = Color3.fromRGB(160, 160, 160),
	Tx3      = Color3.fromRGB(100, 100, 100),
	Tx4      = Color3.fromRGB(50, 50, 50),
	Bd       = Color3.fromRGB(30, 30, 30),
	Bd2      = Color3.fromRGB(50, 50, 50),
	TgOff    = Color3.fromRGB(30, 30, 30),
	TgOn     = Color3.fromRGB(240, 240, 240),
	KnobOff  = Color3.fromRGB(100, 100, 100),
	KnobOn   = Color3.fromRGB(15, 15, 15),
	Accent   = Color3.fromRGB(255, 255, 255),
	Good     = Color3.fromRGB(240, 240, 240),
	Bad      = Color3.fromRGB(70, 70, 70),
	Warn     = Color3.fromRGB(150, 150, 150),
}
local F  = Enum.Font.Gotham
local FM = Enum.Font.GothamMedium
local _llII1lI1I = Enum.Font.GothamBold


local function Corner(i, r)
	local c = Instance.new(_D("\161\189\183\155\134\154\145\134"))
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = i
	return c
end
local function Stroke(i, _1l1IIllIl, _I1IlI1lIIll, _l1IlIl11lIl1I1I)
	local s = Instance.new(_D("\161\189\167\128\134\155\159\145"))
	s.Color = _1l1IIllIl or T.Bd
	s.Thickness = _I1IlI1lIIll or 1
	s.Transparency = _l1IlIl11lIl1I1I or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = i
	return s
end
local function Grad(i, _IIl11IlIll1I1, _Il11l1llIl11l1, _l11Il1I1I1)
	local g = Instance.new(_D("\161\189\179\134\149\144\157\145\154\128"))
	g.Color = ColorSequence.new(_IIl11IlIll1I1, _Il11l1llIl11l1)
	g.Rotation = _l11Il1I1I1 or 90
	g.Parent = i
	return g
end
local function Pad(i, t, b, l, r)
	local p = Instance.new(_D("\161\189\164\149\144\144\157\154\147"))
	p.PaddingTop = UDim.new(0, t or 0)
	p.PaddingBottom = UDim.new(0, b or 0)
	p.PaddingLeft = UDim.new(0, l or 0)
	p.PaddingRight = UDim.new(0, r or 0)
	p.Parent = i
	return p
end
local function Shadow(i, _IlIlI11lIIII)
	local s = Instance.new(_D("\161\189\167\128\134\155\159\145"))
	s.Color = T.Bd2
	s.Thickness = 2
	s.Transparency = _IlIlI11lIIII or 0.6
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = i
	return s
end

local function mkIcon(_11II11Il11l1, _IllIII1l11)
	local box = Instance.new(_D("\178\134\149\153\145"))
	box.Parent = _11II11Il11l1
	box.BackgroundTransparency = 1
	box.Size = UDim2.fromOffset(18, 18)
	local _lIllIllll11ll = {}
	local function frame(_IIlll11III1, _Il1l1l11IIIlI, _11l111I1lll, _IlI1l1l1lI, _1lIIlI1Illlll11)
		local f = Instance.new(_D("\178\134\149\153\145"))
		f.Parent = box
		f.BorderSizePixel = 0
		f.Position = UDim2.fromOffset(_IIlll11III1, _Il1l1l11IIIlI)
		f.Size = UDim2.fromOffset(_11l111I1lll, _IlI1l1l1lI)
		f.BackgroundColor3 = T.Tx2
		if _1lIIlI1Illlll11 then Corner(f, _1lIIlI1Illlll11) end
		table.insert(_lIllIllll11ll, {f, _D("\150\147")})
		return f
	end
	local function _IllIIll1lllII(_IIlll11III1, _Il1l1l11IIIlI, _11l111I1lll, _IlI1l1l1lI)
		local f = Instance.new(_D("\178\134\149\153\145"))
		f.Parent = box
		f.BackgroundTransparency = 1
		f.Position = UDim2.fromOffset(_IIlll11III1, _Il1l1l11IIIlI)
		f.Size = UDim2.fromOffset(_11l111I1lll, _IlI1l1l1lI)
		Corner(f, 999)
		local _lIllIlI1l11 = Stroke(f, T.Tx2, 1.6, 0)
		table.insert(_lIllIllll11ll, {_lIllIlI1l11, _D("\135\128\134\155\159\145")})
		return f
	end
	local function _1II1111111(_IIlll11III1, _Il1l1l11IIIlI, _11l111I1lll, _IlI1l1l1lI, _1lIIlI1Illlll11, _l11Il1I1I1)
		local f = Instance.new(_D("\178\134\149\153\145"))
		f.Parent = box
		f.BackgroundTransparency = 1
		f.Position = UDim2.fromOffset(_IIlll11III1, _Il1l1l11IIIlI)
		f.Size = UDim2.fromOffset(_11l111I1lll, _IlI1l1l1lI)
		f.Rotation = _l11Il1I1I1 or 0
		if _1lIIlI1Illlll11 then Corner(f, _1lIIlI1Illlll11) end
		local _lIllIlI1l11 = Stroke(f, T.Tx2, 1.6, 0)
		table.insert(_lIllIllll11ll, {_lIllIlI1l11, _D("\135\128\134\155\159\145")})
		return f
	end
	if _IllIII1l11 == _D("\145\141\145") then
		_IllIIll1lllII(2, 4, 14, 9)
		frame(7, 6, 4, 5, 999)
		frame(4, 8, 2, 2, 999)
		frame(12, 8, 2, 2, 999)
	elseif _IllIII1l11 == _D("\147\156\155\135\128") then
		_1II1111111(3, 2, 12, 11, 6)
		frame(6, 6, 2, 2, 999)
		frame(10, 6, 2, 2, 999)
		frame(3, 12, 3, 3, 1)
		frame(7, 13, 3, 3, 1)
		frame(11, 12, 3, 3, 1)
	elseif _IllIII1l11 == _D("\151\134\155\135\135") then
		_IllIIll1lllII(3, 3, 12, 12)
		frame(8, 0, 2, 4, 1)
		frame(8, 14, 2, 4, 1)
		frame(0, 8, 4, 2, 1)
		frame(14, 8, 4, 2, 1)
	elseif _IllIII1l11 == _D("\135\152\157\144\145\134\135") then
		frame(2, 3, 14, 2, 1)
		frame(10, 2, 5, 5, 2)
		frame(2, 8, 14, 2, 1)
		frame(3, 7, 5, 5, 2)
		frame(2, 13, 14, 2, 1)
		frame(8, 12, 5, 5, 2)
	elseif _IllIII1l11 == _D("\144\157\149\153\155\154\144") then
		_1II1111111(4, 4, 10, 10, 2, 45)
		frame(7, 7, 4, 4, 999).Rotation = 45
	elseif _IllIII1l11 == _D("\147\134\157\144") then
		frame(1, 1, 7, 7, 2)
		frame(10, 1, 7, 7, 2)
		frame(1, 10, 7, 7, 2)
		frame(10, 10, 7, 7, 2)
	elseif _IllIII1l11 == _D("\135\156\157\145\152\144") then
		_1II1111111(3, 1, 12, 15, 3)
		frame(8, 5, 2, 6, 1)
		frame(6, 8, 6, 2, 1)
	elseif _IllIII1l11 == _D("\135\145\134\130\145\134") then
		_1II1111111(2, 2, 14, 6, 2)
		frame(4, 4, 2, 2, 999)
		_1II1111111(2, 10, 14, 6, 2)
		frame(4, 12, 2, 2, 999)
	end
	local _1ll1IIII1Il = { box = box }
	function _1ll1IIII1Il.setColor(_1l1IIllIl)
		for _, p in ipairs(_lIllIllll11ll) do
			if p[2] == _D("\150\147") then
				p[1].BackgroundColor3 = _1l1IIllIl
			else
				p[1].Color = _1l1IIllIl
			end
		end
	end
	return _1ll1IIII1Il
end


local _111lllI1I = Instance.new(_D("\167\151\134\145\145\154\179\129\157"))
_111lllI1I.Name = _D("\176\145\153\155\154\155\152\155\147\141")
_111lllI1I.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
_111lllI1I.ResetOnSpawn = false
_111lllI1I.DisplayOrder = 2147483647
_111lllI1I.IgnoreGuiInset = true

if _lII111IIIIllI:IsStudio() then
	_111lllI1I.Parent = plr:WaitForChild(_D("\164\152\149\141\145\134\179\129\157"))
else
	local _l1lI1I11Il11ll1 = pcall(function()
		_111lllI1I.Parent = (gethui and gethui()) or (syn and syn.protect_gui and syn.protect_gui(_111lllI1I)) or game:GetService(_D("\183\155\134\145\179\129\157"))
	end)
	if not _l1lI1I11Il11ll1 then
		_111lllI1I.Parent = game:GetService(_D("\183\155\134\145\179\129\157"))
	end
end
S.Gui = _111lllI1I


local _1lIIllI1lIllI = Instance.new(_D("\178\134\149\153\145"))
_1lIIllI1lIllI.Name = _D("\186\155\128\157\146\135")
_1lIIllI1lIllI.Parent = _111lllI1I
_1lIIllI1lIllI.AnchorPoint = Vector2.new(0.5, 0)
_1lIIllI1lIllI.BackgroundTransparency = 1
_1lIIllI1lIllI.BorderSizePixel = 0
_1lIIllI1lIllI.Position = UDim2.new(0.5, 0, 0.04, 0)
_1lIIllI1lIllI.Size = UDim2.new(0, 360, 0, 240)
_1lIIllI1lIllI.ZIndex = 900
local _IIlllIlIl1l1Ill = Instance.new(_D("\161\189\184\157\135\128\184\149\141\155\129\128"))
_IIlllIlIl1l1Ill.Parent = _1lIIllI1lIllI
_IIlllIlIl1l1Ill.HorizontalAlignment = Enum.HorizontalAlignment.Center
_IIlllIlIl1l1Ill.SortOrder = Enum.SortOrder.LayoutOrder
_IIlllIlIl1l1Ill.Padding = UDim.new(0, 8)

local _llIllI1IlI1l, _lIII11Il111 = 0, {}
local _lIll11lI11 = {
	info = Color3.fromRGB(180, 180, 180),
	success = Color3.fromRGB(255, 255, 255),
	warn = Color3.fromRGB(140, 140, 140),
	danger = Color3.fromRGB(80, 80, 80),
	muted = Color3.fromRGB(100, 100, 100),
}
local function _1I11lIIllII(title, _1III1IIll11, _11II1I111Ill1, _I11l1l11II)
	if not _1lIIllI1lIllI or not _1lIIllI1lIllI.Parent then return end
	_llIllI1IlI1l = _llIllI1IlI1l + 1
	_I11l1l11II = _I11l1l11II or 2.8
	local _IlIl11I1I1ll = _lIll11lI11[_11II1I111Ill1 or _D("\157\154\146\155")] or _lIll11lI11.info

	local _11lI11lIlII1 = Instance.new(_D("\178\134\149\153\145"))
	_11lI11lIlII1.Name = _D("\186")
	_11lI11lIlII1.Parent = _1lIIllI1lIllI
	_11lI11lIlII1.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	_11lI11lIlII1.BorderSizePixel = 0
	_11lI11lIlII1.ClipsDescendants = true
	_11lI11lIlII1.LayoutOrder = _llIllI1IlI1l
	_11lI11lIlII1.Size = UDim2.new(0, 310, 0, 0)
	_11lI11lIlII1.ZIndex = 901
	Corner(_11lI11lIlII1, 12)
	local _I1IIlllIll = Stroke(_11lI11lIlII1, T.Bd2, 1, 0.5)
	Shadow(_11lI11lIlII1, 0.5)
	Grad(_11lI11lIlII1, Color3.fromRGB(22, 22, 22), Color3.fromRGB(10, 10, 10), 90)

	local _lI1Ill1llI1l = Instance.new(_D("\161\189\167\151\149\152\145"))
	_lI1Ill1llI1l.Scale = 0.9
	_lI1Ill1llI1l.Parent = _11lI11lIlII1

	local _II111lI1lII = Instance.new(_D("\178\134\149\153\145"))
	_II111lI1lII.Parent = _11lI11lIlII1
	_II111lI1lII.BackgroundColor3 = _IlIl11I1I1ll
	_II111lI1lII.BorderSizePixel = 0
	_II111lI1lII.Position = UDim2.new(0, 0, 0, 7)
	_II111lI1lII.Size = UDim2.new(0, 3, 1, -14)
	_II111lI1lII.ZIndex = 902
	Corner(_II111lI1lII, 4)

	local _I111lllIl1 = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_I111lllIl1.Parent = _11lI11lIlII1
	_I111lllIl1.BackgroundTransparency = 1
	_I111lllIl1.Font = _llII1lI1I
	_I111lllIl1.Position = UDim2.new(0, 16, 0, 8)
	_I111lllIl1.Size = UDim2.new(1, -30, 0, 18)
	_I111lllIl1.Text = tostring(title or _D(""))
	_I111lllIl1.TextColor3 = T.White
	_I111lllIl1.TextSize = 14
	_I111lllIl1.TextTransparency = 1
	_I111lllIl1.TextTruncate = Enum.TextTruncate.AtEnd
	_I111lllIl1.TextXAlignment = Enum.TextXAlignment.Left
	_I111lllIl1.ZIndex = 902

	local _lIlllII1lI1Il = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_lIlllII1lI1Il.Parent = _11lI11lIlII1
	_lIlllII1lI1Il.BackgroundTransparency = 1
	_lIlllII1lI1Il.Font = F
	_lIlllII1lI1Il.Position = UDim2.new(0, 16, 0, 26)
	_lIlllII1lI1Il.Size = UDim2.new(1, -30, 0, 17)
	_lIlllII1lI1Il.Text = tostring(_1III1IIll11 or _D(""))
	_lIlllII1lI1Il.TextColor3 = T.Tx2
	_lIlllII1lI1Il.TextSize = 13
	_lIlllII1lI1Il.TextTransparency = 1
	_lIlllII1lI1Il.TextWrapped = true
	_lIlllII1lI1Il.TextXAlignment = Enum.TextXAlignment.Left
	_lIlllII1lI1Il.ZIndex = 902

	table.insert(_lIII11Il111, _11lI11lIlII1)
	if #_lIII11Il111 > 4 then
		local _IIII1llIl1 = table.remove(_lIII11Il111, 1)
		if _IIII1llIl1 and _IIII1llIl1.Parent then _IIII1llIl1:Destroy() end
	end

	TweenService:Create(_11lI11lIlII1, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 310, 0, 52)
	}):Play()
	TweenService:Create(_lI1Ill1llI1l, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	TweenService:Create(_I111lllIl1, TweenInfo.new(0.14), { TextTransparency = 0 }):Play()
	TweenService:Create(_lIlllII1lI1Il, TweenInfo.new(0.18), { TextTransparency = 0 }):Play()

	task.delay(_I11l1l11II, function()
		if not _11lI11lIlII1.Parent then return end
		TweenService:Create(_I111lllIl1, TweenInfo.new(0.18), { TextTransparency = 1 }):Play()
		TweenService:Create(_lIlllII1lI1Il, TweenInfo.new(0.18), { TextTransparency = 1 }):Play()
		TweenService:Create(_I1IIlllIll, TweenInfo.new(0.18), { Transparency = 1 }):Play()
		TweenService:Create(_11lI11lIlII1, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 310, 0, 0)
		}):Play()
		task.wait(0.24)
		for i, v in ipairs(_lIII11Il111) do
			if v == _11lI11lIlII1 then table.remove(_lIII11Il111, i); break end
		end
		if _11lI11lIlII1.Parent then _11lI11lIlII1:Destroy() end
	end)
end
local function _lll11ll1IlIll(label, _1lI1I1I1ll11l1l)
	_1I11lIIllII(label, _1lI1I1I1ll11l1l and _D("\177\154\149\150\152\145\144") or _D("\176\157\135\149\150\152\145\144"), _1lI1I1I1ll11l1l and _D("\135\129\151\151\145\135\135") or _D("\153\129\128\145\144"), 1.8)
end


local _I1I1II1ll11II, _IIII1IIlIll1 = 700, 520
local _II11ll111l1I1 = UDim2.fromOffset(_I1I1II1ll11II, _IIII1IIlIll1)
_1l1l1l1Il = Instance.new(_D("\178\134\149\153\145"))
_1l1l1l1Il.Name = _D("\185\149\157\154")
_1l1l1l1Il.Parent = _111lllI1I
_1l1l1l1Il.Active = true
_1l1l1l1Il.BackgroundColor3 = T.BG
_1l1l1l1Il.BorderSizePixel = 0
_1l1l1l1Il.Position = UDim2.new(0.5, -_I1I1II1ll11II / 2, 0.5, -_IIII1IIlIll1 / 2)
_1l1l1l1Il.Size = UDim2.fromOffset(0, 0)
_1l1l1l1Il.ClipsDescendants = true
_1l1l1l1Il.Visible = false
Corner(_1l1l1l1Il, 14)
local _lll1I1Ill = Stroke(_1l1l1l1Il, T.Bd, 1, 0.1)
Shadow(_1l1l1l1Il, 0.15)
Grad(_1l1l1l1Il, Color3.fromRGB(22, 22, 22), T.BG, 90)

local _I1IlIlllIIlI1 = Instance.new(_D("\178\134\149\153\145"))
_I1IlIlllIIlI1.Name = _D("\160\182\149\134")
_I1IlIlllIIlI1.Parent = _1l1l1l1Il
_I1IlIlllIIlI1.Active = true
_I1IlIlllIIlI1.BackgroundTransparency = 1
_I1IlIlllIIlI1.Size = UDim2.new(1, 0, 0, 48)
_I1IlIlllIIlI1.Position = UDim2.new(0, 0, 0, 0)

local _I1llI1l1lIIIll = Instance.new(_D("\178\134\149\153\145"))
_I1llI1l1lIIIll.Parent = _I1IlIlllIIlI1
_I1llI1l1lIIIll.BackgroundColor3 = T.Accent
_I1llI1l1lIIIll.BorderSizePixel = 0
_I1llI1l1lIIIll.Position = UDim2.new(0, 18, 0.5, -6)
_I1llI1l1lIIIll.Size = UDim2.new(0, 3, 0, 12)
Corner(_I1llI1l1lIIIll, 2)

local _l1l1I1lI1 = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
_l1l1I1lI1.Parent = _I1IlIlllIIlI1
_l1l1I1lI1.BackgroundTransparency = 1
_l1l1I1lI1.Position = UDim2.new(0, 30, 0, 0)
_l1l1I1lI1.Size = UDim2.new(0, 220, 1, 0)
_l1l1I1lI1.Font = _llII1lI1I
_l1l1I1lI1.Text = _D("\176\145\153\155\154\155\152\155\147\141")
_l1l1I1lI1.TextColor3 = T.White
_l1l1I1lI1.TextSize = 19
_l1l1I1lI1.TextXAlignment = Enum.TextXAlignment.Left

local function _1l1ll111II(_lII11IlIIlI111, _I1lIl11IIl11lI1)
	local b = Instance.new(_D("\160\145\140\128\182\129\128\128\155\154"))
	b.Parent = _I1IlIlllIIlI1
	b.AnchorPoint = Vector2.new(1, 0.5)
	b.Position = UDim2.new(1, _I1lIl11IIl11lI1, 0.5, 0)
	b.Size = UDim2.new(0, 30, 0, 26)
	b.BackgroundColor3 = T.Elev
	b.BorderSizePixel = 0
	b.Font = _llII1lI1I
	b.TextSize = 14
	b.Text = _lII11IlIIlI111
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
local _lIl11I111lI = _1l1ll111II(_D("\172"), -12)
local _IIll111Il = _1l1ll111II(_D("\217"), -46)


_1II111II1l1Il1 = function(frame, _Ill1lIlIIl1I)
	_Ill1lIlIIl1I = _Ill1lIlIIl1I or frame
	local _I1IIl1ll1Ill1l, _llIIIIIl111l1I, _lll1l1IIIIIl1, _11Illll1IIll
	_Ill1lIlIIl1I.InputBegan:Connect(function(_lll11lI1llIl1ll)
		if (_lll11lI1llIl1ll.UserInputType == Enum.UserInputType.MouseButton1 or _lll11lI1llIl1ll.UserInputType == Enum.UserInputType.Touch) and frame.Active then
			if frame == _1l1l1l1Il or (not hudLocked) then
				_I1IIl1ll1Ill1l = true
				_lll1l1IIIIIl1 = _lll11lI1llIl1ll.Position
				_11Illll1IIll = frame.Position
				local _lll1I1IlIll1l1
				_lll1I1IlIll1l1 = _lll11lI1llIl1ll.Changed:Connect(function()
					if _lll11lI1llIl1ll.UserInputState == Enum.UserInputState.End then
						_I1IIl1ll1Ill1l = false
						_lll1I1IlIll1l1:Disconnect()
						if S._RequestAutoSave then S._RequestAutoSave() end
					end
				end)
			end
		end
	end)
	_Ill1lIlIIl1I.InputChanged:Connect(function(_lll11lI1llIl1ll)
		if (_lll11lI1llIl1ll.UserInputType == Enum.UserInputType.MouseMovement or _lll11lI1llIl1ll.UserInputType == Enum.UserInputType.Touch) and frame.Active then
			_llIIIIIl111l1I = _lll11lI1llIl1ll
		end
	end)
	_1I111I1ll(_lII1I1I11.InputChanged:Connect(function(_lll11lI1llIl1ll)
		if _lll11lI1llIl1ll == _llIIIIIl111l1I and _I1IIl1ll1Ill1l then
			local _l111I1l1l1l11 = _lll11lI1llIl1ll.Position - _lll1l1IIIIIl1
			frame.Position = UDim2.new(_11Illll1IIll.X.Scale, _11Illll1IIll.X.Offset + _l111I1l1l1l11.X, _11Illll1IIll.Y.Scale, _11Illll1IIll.Y.Offset + _l111I1l1l1l11.Y)
		end
	end))
end

_1II111II1l1Il1(_1l1l1l1Il, _I1IlIlllIIlI1)

local _11lllIllIl1l = Instance.new(_D("\167\151\134\155\152\152\157\154\147\178\134\149\153\145"))
_11lllIllIl1l.Name = _D("\167\157\144\145\150\149\134")
_11lllIllIl1l.Parent = _1l1l1l1Il
_11lllIllIl1l.BackgroundColor3 = T.Sidebar
_11lllIllIl1l.BorderSizePixel = 0
_11lllIllIl1l.Position = UDim2.new(0, 0, 0, 48)
_11lllIllIl1l.Size = UDim2.new(0, 170, 1, -48)
_11lllIllIl1l.CanvasSize = UDim2.new(0, 0, 0, 0)
_11lllIllIl1l.AutomaticCanvasSize = Enum.AutomaticSize.Y
_11lllIllIl1l.ScrollBarThickness = 2
_11lllIllIl1l.ScrollBarImageColor3 = T.Tx3
_11lllIllIl1l.ScrollBarImageTransparency = 0.5
local _11l1IIl11I11ll = Instance.new(_D("\178\134\149\153\145"))
_11l1IIl11I11ll.Parent = _1l1l1l1Il
_11l1IIl11I11ll.BackgroundColor3 = T.Bd
_11l1IIl11I11ll.BackgroundTransparency = 0.3
_11l1IIl11I11ll.BorderSizePixel = 0
_11l1IIl11I11ll.Position = UDim2.new(0, 170, 0, 48)
_11l1IIl11I11ll.Size = UDim2.new(0, 1, 1, -48)
local _llIIII111lI = Instance.new(_D("\161\189\184\157\135\128\184\149\141\155\129\128"))
_llIIII111lI.Parent = _11lllIllIl1l
_llIIII111lI.SortOrder = Enum.SortOrder.LayoutOrder
_llIIII111lI.Padding = UDim.new(0, 5)
Pad(_11lllIllIl1l, 14, 14, 10, 10)

local _1lI1lIIl1lIIIl = Instance.new(_D("\167\151\134\155\152\152\157\154\147\178\134\149\153\145"))
_1lI1lIIl1lIIIl.Name = _D("\183\155\154\128\145\154\128")
_1lI1lIIl1lIIIl.Parent = _1l1l1l1Il
_1lI1lIIl1lIIIl.BackgroundTransparency = 1
_1lI1lIIl1lIIIl.BorderSizePixel = 0
_1lI1lIIl1lIIIl.Position = UDim2.new(0, 171, 0, 48)
_1lI1lIIl1lIIIl.Size = UDim2.new(1, -171, 1, -48)
_1lI1lIIl1lIIIl.CanvasSize = UDim2.new(0, 0, 0, 0)
_1lI1lIIl1lIIIl.AutomaticCanvasSize = Enum.AutomaticSize.Y
_1lI1lIIl1lIIIl.ScrollBarThickness = 3
_1lI1lIIl1lIIIl.ScrollBarImageColor3 = T.Tx3
_1lI1lIIl1lIIIl.ScrollBarImageTransparency = 0.4

local Pages = {}
local _11l1IllIIIll1 = {}
local activePage
local _IlI11I1I1lI1

local function _1l1l1lI11l1ll(_11l1lIIll)
	local _III1lIIll = Instance.new(_D("\178\134\149\153\145"))
	_III1lIIll.Name = _11l1lIIll
	_III1lIIll.Parent = _1lI1lIIl1lIIIl
	_III1lIIll.BackgroundTransparency = 1
	_III1lIIll.BorderSizePixel = 0
	_III1lIIll.Size = UDim2.new(1, 0, 0, 0)
	_III1lIIll.AutomaticSize = Enum.AutomaticSize.Y
	_III1lIIll.Visible = false
	local l = Instance.new(_D("\161\189\184\157\135\128\184\149\141\155\129\128"))
	l.Parent = _III1lIIll
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding = UDim.new(0, 14)
	Pad(_III1lIIll, 10, 14, 8, 10)
	Pages[_11l1lIIll] = _III1lIIll
	return _III1lIIll
end

local function _1ll11l1Ill1I(_11l1lIIll, _1Il1llI11llIl1l, page, _lIlllIl11)
	local btn = Instance.new(_D("\160\145\140\128\182\129\128\128\155\154"))
	btn.Name = _11l1lIIll
	btn.Parent = _11lllIllIl1l
	btn.LayoutOrder = _lIlllIl11
	btn.Size = UDim2.new(1, 0, 0, 42)
	btn.AutoButtonColor = false
	btn.BackgroundTransparency = 1
	btn.BorderSizePixel = 0
	btn.Text = _D("")
	Corner(btn, 9)
	local bar = Instance.new(_D("\178\134\149\153\145"))
	bar.Parent = btn
	bar.Size = UDim2.new(0, 3, 0, 20)
	bar.Position = UDim2.new(0, 0, 0.5, -10)
	bar.BackgroundColor3 = T.Accent
	bar.BorderSizePixel = 0
	bar.Visible = false
	Corner(bar, 2)
	local icon = mkIcon(btn, _1Il1llI11llIl1l)
	icon.box.Position = UDim2.new(0, 14, 0.5, -9)
	local label = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	label.Parent = btn
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 44, 0, 0)
	label.Size = UDim2.new(1, -48, 1, 0)
	label.Font = F
	label.TextSize = 15
	label.TextColor3 = T.Tx2
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = _11l1lIIll
	local _111llIIll1llI1 = { btn = btn, bar = bar, icon = icon, label = label, page = page }
	btn.MouseButton1Click:Connect(function()
		for _, pg in pairs(Pages) do
			pg.Visible = (pg == page)
		end
		activePage = page
		_IlI11I1I1lI1()
	end)
	btn.MouseEnter:Connect(function()
		if page ~= activePage then
			btn.BackgroundTransparency = 0.35
			btn.BackgroundColor3 = T.Elev
		end
	end)
	btn.MouseLeave:Connect(function()
		_IlI11I1I1lI1()
	end)
	table.insert(_11l1IllIIIll1, _111llIIll1llI1)
end

_IlI11I1I1lI1 = function()
	for _, _111llIIll1llI1 in ipairs(_11l1IllIIIll1) do
		local _lII1I11Il = (_111llIIll1llI1.page == activePage)
		_111llIIll1llI1.bar.Visible = _lII1I11Il
		_111llIIll1llI1.icon.setColor(_lII1I11Il and T.White or T.Tx3)
		_111llIIll1llI1.label.TextColor3 = _lII1I11Il and T.White or T.Tx2
		_111llIIll1llI1.label.Font = _lII1I11Il and FM or F
		_111llIIll1llI1.btn.BackgroundColor3 = T.Elev
		_111llIIll1llI1.btn.BackgroundTransparency = _lII1I11Il and 0 or 1
	end
end

_1l1l1lI11l1ll(_D("\177\130\157\144\145\154\151\145"))
_1l1l1lI11l1ll(_D("\179\156\155\135\128\212\210\212\188\129\154\128"))
_1l1l1lI11l1ll(_D("\181\129\128\155\153\149\128\157\155\154"))
_1l1l1lI11l1ll(_D("\177\167\164"))
_1l1l1lI11l1ll(_D("\185\155\130\145\153\145\154\128"))
_1l1l1lI11l1ll(_D("\160\145\152\145\132\155\134\128"))
_1l1l1lI11l1ll(_D("\185\157\135\151"))
_1l1l1lI11l1ll(_D("\188\161\176"))
Pages[_D("\177\130\157\144\145\154\151\145")].Visible = true
activePage = Pages[_D("\177\130\157\144\145\154\151\145")]
_1ll11l1Ill1I(_D("\177\130\157\144\145\154\151\145"), _D("\145\141\145"), Pages[_D("\177\130\157\144\145\154\151\145")], 1)
_1ll11l1Ill1I(_D("\179\156\155\135\128\212\210\212\188\129\154\128"), _D("\147\156\155\135\128"), Pages[_D("\179\156\155\135\128\212\210\212\188\129\154\128")], 2)
_1ll11l1Ill1I(_D("\181\129\128\155\153\149\128\157\155\154"), _D("\151\134\155\135\135"), Pages[_D("\181\129\128\155\153\149\128\157\155\154")], 3)
_1ll11l1Ill1I(_D("\177\167\164"), _D("\147\134\157\144"), Pages[_D("\177\167\164")], 4)
_1ll11l1Ill1I(_D("\185\155\130\145\153\145\154\128"), _D("\135\152\157\144\145\134\135"), Pages[_D("\185\155\130\145\153\145\154\128")], 5)
_1ll11l1Ill1I(_D("\160\145\152\145\132\155\134\128"), _D("\144\157\149\153\155\154\144"), Pages[_D("\160\145\152\145\132\155\134\128")], 6)
_1ll11l1Ill1I(_D("\185\157\135\151"), _D("\135\156\157\145\152\144"), Pages[_D("\185\157\135\151")], 7)
_1ll11l1Ill1I(_D("\188\161\176"), _D("\135\145\134\130\145\134"), Pages[_D("\188\161\176")], 8)
_IlI11I1I1lI1()


local _Il1lI1llIIIl = {}
local function _1l1l1l11IIIII(_11II11Il11l1, label)
	local card = _11II11Il11l1.Parent
	local page = card and card.Parent
	return (page and page.Name or _D("\203")) .. _D("\219") .. (card and card.Name or _D("\203")) .. _D("\219") .. label
end

local _1IlII11lIIIIl11 = {}
local _I1ll11IlIl = nil
_1I111I1ll(_lII1I1I11.InputBegan:Connect(function(_lll11lI1llIl1ll, _1IlI1I1llIl)
	if _I1ll11IlIl then
		if _lll11lI1llIl1ll.UserInputType == Enum.UserInputType.Keyboard then
			local e = _I1ll11IlIl
			_I1ll11IlIl = nil
			local _IIlI1lll1I1ll = (_lll11lI1llIl1ll.KeyCode == Enum.KeyCode.Escape or _lll11lI1llIl1ll.KeyCode == Enum.KeyCode.Backspace or _lll11lI1llIl1ll.KeyCode == Enum.KeyCode.Delete)
			if e.bindKey then _1IlII11lIIIIl11[e.bindKey] = nil end
			if _IIlI1lll1I1ll then
				e.bindKey = nil
				_1I11lIIllII(_D("\182\157\154\144\212\183\152\145\149\134\145\144"), e.label, _D("\153\129\128\145\144"), 2)
			else
				e.bindKey = _lll11lI1llIl1ll.KeyCode
				_1IlII11lIIIIl11[_lll11lI1llIl1ll.KeyCode] = e
				_1I11lIIllII(_D("\182\157\154\144\212\167\145\128"), e.label .. _D("\212\212\202\212\212") .. _lll11lI1llIl1ll.KeyCode.Name, _D("\157\154\146\155"), 2.5)
			end
			e.updateVisuals()
			if S._RequestAutoSave then S._RequestAutoSave() end
		end
		return
	end
	if _lll11lI1llIl1ll.UserInputType == Enum.UserInputType.Keyboard then
		local _1ll11l111l = false
		pcall(function() _1ll11l111l = (_lII1I1I11:GetFocusedTextBox() ~= nil) end)
		if not _1ll11l111l then
			local e = _1IlII11lIIIIl11[_lll11lI1llIl1ll.KeyCode]
			if e and e.trigger then pcall(e.trigger) end
		end
	end
end))

local function _IlIlIlIll11I1(_11II11Il11l1, title, _lIlllIl11)
	local card = Instance.new(_D("\178\134\149\153\145"))
	card.Name = title
	card.Parent = _11II11Il11l1
	card.LayoutOrder = _lIlllIl11
	card.BackgroundColor3 = T.Card
	card.BorderSizePixel = 0
	card.Size = UDim2.new(1, 0, 0, 0)
	card.AutomaticSize = Enum.AutomaticSize.Y
	Corner(card, 12)
	Stroke(card, T.Bd, 1, 0.3)
	Grad(card, Color3.fromRGB(22, 22, 22), T.Card, 90)
	local _I1IIl11lI1IllIl = Instance.new(_D("\178\134\149\153\145"))
	_I1IIl11lI1IllIl.Name = _D("\189\154\154\145\134")
	_I1IIl11lI1IllIl.Parent = card
	_I1IIl11lI1IllIl.BackgroundTransparency = 1
	_I1IIl11lI1IllIl.Size = UDim2.new(1, 0, 0, 0)
	_I1IIl11lI1IllIl.AutomaticSize = Enum.AutomaticSize.Y
	Pad(_I1IIl11lI1IllIl, 14, 16, 16, 16)
	local _I11Il11II1I = Instance.new(_D("\161\189\184\157\135\128\184\149\141\155\129\128"))
	_I11Il11II1I.Parent = _I1IIl11lI1IllIl
	_I11Il11II1I.SortOrder = Enum.SortOrder.LayoutOrder
	_I11Il11II1I.Padding = UDim.new(0, 8)
	local _lI1lI1II1I = Instance.new(_D("\178\134\149\153\145"))
	_lI1lI1II1I.Parent = _I1IIl11lI1IllIl
	_lI1lI1II1I.LayoutOrder = 0
	_lI1lI1II1I.BackgroundTransparency = 1
	_lI1lI1II1I.Size = UDim2.new(1, 0, 0, 22)
	local tick = Instance.new(_D("\178\134\149\153\145"))
	tick.Parent = _lI1lI1II1I
	tick.BorderSizePixel = 0
	tick.BackgroundColor3 = T.Accent
	tick.Position = UDim2.new(0, 0, 0.5, -5)
	tick.Size = UDim2.new(0, 3, 0, 12)
	Corner(tick, 2)
	local _lIlllII1I1ll = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_lIlllII1I1ll.Parent = _lI1lI1II1I
	_lIlllII1I1ll.BackgroundTransparency = 1
	_lIlllII1I1ll.Position = UDim2.new(0, 12, 0, 0)
	_lIlllII1I1ll.Size = UDim2.new(1, -12, 1, 0)
	_lIlllII1I1ll.Font = _llII1lI1I
	_lIlllII1I1ll.TextSize = 13
	_lIlllII1I1ll.TextColor3 = T.Tx3
	_lIlllII1I1ll.TextXAlignment = Enum.TextXAlignment.Left
	_lIlllII1I1ll.Text = string.upper(title)
	return _I1IIl11lI1IllIl
end

local function _lI1llIllI(_11II11Il11l1, label, _lIlllIl11)
	local row = Instance.new(_D("\178\134\149\153\145"))
	row.Name = label
	row.Parent = _11II11Il11l1
	row.LayoutOrder = _lIlllIl11
	row.Size = UDim2.new(1, 0, 0, 26)
	row.BackgroundTransparency = 1
	local _IllllIllI = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_IllllIllI.Parent = row
	_IllllIllI.BackgroundTransparency = 1
	_IllllIllI.Position = UDim2.new(0, 4, 0, 0)
	_IllllIllI.Size = UDim2.new(0.45, 0, 1, 0)
	_IllllIllI.Font = F
	_IllllIllI.TextSize = 14
	_IllllIllI.TextColor3 = T.Tx2
	_IllllIllI.TextXAlignment = Enum.TextXAlignment.Left
	_IllllIllI.Text = label
	local _I111I1l1l = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_I111I1l1l.Parent = row
	_I111I1l1l.BackgroundTransparency = 1
	_I111I1l1l.Position = UDim2.new(0.45, 0, 0, 0)
	_I111I1l1l.Size = UDim2.new(0.55, -4, 1, 0)
	_I111I1l1l.Font = FM
	_I111I1l1l.TextSize = 14
	_I111I1l1l.TextColor3 = T.White
	_I111I1l1l.TextXAlignment = Enum.TextXAlignment.Right
	_I111I1l1l.TextTruncate = Enum.TextTruncate.AtEnd
	_I111I1l1l.Text = _D("\217\217")
	local _1ll1IIII1Il = {}
	function _1ll1IIII1Il.set(_1llIlllIlI1I1I1, _1111I11lIIIl1l)
		_I111I1l1l.Text = tostring(_1llIlllIlI1I1I1)
		_I111I1l1l.TextColor3 = _1111I11lIIIl1l or T.White
	end
	return _1ll1IIII1Il
end

local function _l11I11llllI(_11II11Il11l1, label, _lIlllIl11)
	local row = Instance.new(_D("\178\134\149\153\145"))
	row.Name = label
	row.Parent = _11II11Il11l1
	row.LayoutOrder = _lIlllIl11
	row.Size = UDim2.new(1, 0, 0, 36)
	row.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
	row.BackgroundTransparency = 1
	row.BorderSizePixel = 0
	Corner(row, 8)
	local dot = Instance.new(_D("\178\134\149\153\145"))
	dot.Parent = row
	dot.AnchorPoint = Vector2.new(0, 0.5)
	dot.Position = UDim2.new(0, 10, 0.5, 0)
	dot.Size = UDim2.new(0, 8, 0, 8)
	dot.BackgroundColor3 = T.Tx4
	Corner(dot, 4)
	local _IllllIllI = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_IllllIllI.Parent = row
	_IllllIllI.BackgroundTransparency = 1
	_IllllIllI.Position = UDim2.new(0, 28, 0, 0)
	_IllllIllI.Size = UDim2.new(0.55, -28, 1, 0)
	_IllllIllI.Font = F
	_IllllIllI.TextSize = 14
	_IllllIllI.TextColor3 = T.Tx2
	_IllllIllI.TextXAlignment = Enum.TextXAlignment.Left
	_IllllIllI.Text = label
	local _IIIl1lIII1 = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_IIIl1lIII1.Parent = row
	_IIIl1lIII1.AnchorPoint = Vector2.new(1, 0.5)
	_IIIl1lIII1.Position = UDim2.new(1, -10, 0.5, 0)
	_IIIl1lIII1.Size = UDim2.new(0, 0, 0, 22)
	_IIIl1lIII1.AutomaticSize = Enum.AutomaticSize.X
	_IIIl1lIII1.BackgroundColor3 = T.TgOff
	_IIIl1lIII1.BorderSizePixel = 0
	_IIIl1lIII1.Font = FM
	_IIIl1lIII1.TextSize = 13
	_IIIl1lIII1.TextColor3 = T.Tx2
	_IIIl1lIII1.Text = _D("\217\217")
	Corner(_IIIl1lIII1, 6)
	Pad(_IIIl1lIII1, 0, 0, 10, 10)
	local _1ll1IIII1Il = {}
	function _1ll1IIII1Il.set(_1llIlllIlI1I1I1, _l11l1IIIIII)
		_IIIl1lIII1.Text = tostring(_1llIlllIlI1I1I1)
		if _l11l1IIIIII then
			row.BackgroundTransparency = 0.55
			dot.BackgroundColor3 = T.Good
			_IIIl1lIII1.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
			_IIIl1lIII1.TextColor3 = T.Good
			_IllllIllI.TextColor3 = T.Tx
		else
			row.BackgroundTransparency = 1
			dot.BackgroundColor3 = T.Tx4
			_IIIl1lIII1.BackgroundColor3 = T.TgOff
			_IIIl1lIII1.TextColor3 = T.Tx2
			_IllllIllI.TextColor3 = T.Tx2
		end
	end
	return _1ll1IIII1Il
end

local function _Illl1I1I1(_11II11Il11l1, label, _II1lI1llIlII, _1lIl1II11lI1, _lIlllIl11, _llI1l1II1, _IlIIllIlllll1)
	local row = Instance.new(_D("\178\134\149\153\145"))
	row.Name = label
	row.Parent = _11II11Il11l1
	row.LayoutOrder = _lIlllIl11
	row.Size = UDim2.new(1, 0, 0, 36)
	row.BackgroundTransparency = 1
	row.BorderSizePixel = 0
	row.Active = true
	Corner(row, 7)
	local _IllllIllI = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_IllllIllI.Parent = row
	_IllllIllI.BackgroundTransparency = 1
	_IllllIllI.Position = UDim2.new(0, 8, 0, 0)
	_IllllIllI.Size = UDim2.new(1, -104, 1, 0)
	_IllllIllI.Font = F
	_IllllIllI.TextSize = 14
	_IllllIllI.TextColor3 = T.Tx2
	_IllllIllI.TextXAlignment = Enum.TextXAlignment.Left
	_IllllIllI.TextTruncate = Enum.TextTruncate.AtEnd
	_IllllIllI.Text = label
	local _IIIl1lIII1 = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_IIIl1lIII1.Parent = row
	_IIIl1lIII1.AnchorPoint = Vector2.new(1, 0.5)
	_IIIl1lIII1.Position = UDim2.new(1, -60, 0.5, 0)
	_IIIl1lIII1.Size = UDim2.new(0, 0, 0, 18)
	_IIIl1lIII1.AutomaticSize = Enum.AutomaticSize.X
	_IIIl1lIII1.BackgroundColor3 = T.Elev
	_IIIl1lIII1.BorderSizePixel = 0
	_IIIl1lIII1.Font = FM
	_IIIl1lIII1.TextSize = 11
	_IIIl1lIII1.TextColor3 = T.Tx2
	_IIIl1lIII1.Text = _D("")
	_IIIl1lIII1.Visible = false
	Corner(_IIIl1lIII1, 4)
	Stroke(_IIIl1lIII1, T.Bd2, 1, 0.5)
	Pad(_IIIl1lIII1, 0, 0, 7, 7)
	local _IIIlI1lI1 = Instance.new(_D("\160\145\140\128\182\129\128\128\155\154"))
	_IIIlI1lI1.Parent = row
	_IIIlI1lI1.AnchorPoint = Vector2.new(1, 0.5)
	_IIIlI1lI1.Position = UDim2.new(1, -8, 0.5, 0)
	_IIIlI1lI1.Size = UDim2.new(0, 46, 0, 24)
	_IIIlI1lI1.BackgroundColor3 = T.TgOff
	_IIIlI1lI1.BorderSizePixel = 0
	_IIIlI1lI1.Text = _D("")
	_IIIlI1lI1.AutoButtonColor = false
	Corner(_IIIlI1lI1, 12)
	local _11l1l1l1II1I1 = Stroke(_IIIlI1lI1, T.Bd2, 1, 0.6)
	local _lII1Il1Ill = Instance.new(_D("\178\134\149\153\145"))
	_lII1Il1Ill.Parent = _IIIlI1lI1
	_lII1Il1Ill.Size = UDim2.new(0, 18, 0, 18)
	_lII1Il1Ill.Position = UDim2.new(0, 3, 0.5, -9)
	_lII1Il1Ill.BackgroundColor3 = T.KnobOff
	_lII1Il1Ill.BorderSizePixel = 0
	Corner(_lII1Il1Ill, 9)
	local _1lIIllIllll1lIl = _II1lI1llIlII and true or false
	local function _IllIlllll1lI1(_lII1I11Il, _IlllIl1lIlII1l)
		local _111I1I1l1Ill = _lII1I11Il and T.TgOn or T.TgOff
		local _l1IIlIl11Il = _lII1I11Il and T.KnobOn or T.KnobOff
		local _1l111I11lIlI = _lII1I11Il and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
		_IllllIllI.TextColor3 = _lII1I11Il and T.Tx or T.Tx2
		_11l1l1l1II1I1.Transparency = _lII1I11Il and 1 or 0.6
		if _IlllIl1lIlII1l then
			TweenService:Create(_IIIlI1lI1, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundColor3 = _111I1I1l1Ill }):Play()
			TweenService:Create(_lII1Il1Ill, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = _1l111I11lIlI, BackgroundColor3 = _l1IIlIl11Il
			}):Play()
		else
			_IIIlI1lI1.BackgroundColor3 = _111I1I1l1Ill
			_lII1Il1Ill.Position = _1l111I11lIlI
			_lII1Il1Ill.BackgroundColor3 = _l1IIlIl11Il
		end
	end
	_IllIlllll1lI1(_1lIIllIllll1lIl, false)
	local _1ll1IIII1Il = { }
	function _1ll1IIII1Il.get() return _1lIIllIllll1lIl end
	function _1ll1IIII1Il.set(v, _IIl11lIIIl)
		_1lIIllIllll1lIl = v and true or false
		_IllIlllll1lI1(_1lIIllIllll1lIl, true)
		if not _IIl11lIIIl then pcall(_1lIl1II11lI1, _1lIIllIllll1lIl) end
	end
	local function _llI111I111()
		_1lIIllIllll1lIl = not _1lIIllIllll1lIl
		_IllIlllll1lI1(_1lIIllIllll1lIl, true)
		_1lIl1II11lI1(_1lIIllIllll1lIl)
		if S._RequestAutoSave then S._RequestAutoSave() end
	end
	_IIIlI1lI1.MouseButton1Click:Connect(function()
		if not _I1ll11IlIl then _llI111I111() end
	end)
	row.MouseEnter:Connect(function()
		TweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 0.5 }):Play()
		row.BackgroundColor3 = T.Hover
	end)
	row.MouseLeave:Connect(function()
		TweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play()
	end)

	local _II1l1l1l1I = { label = label, bindKey = _IlIIllIlllll1, trigger = _llI111I111 }
	if _IlIIllIlllll1 then
		_1IlII11lIIIIl11[_IlIIllIlllll1] = _II1l1l1l1I
	end
	function _II1l1l1l1I.updateVisuals()
		if _II1l1l1l1I.bindKey then
			_IIIl1lIII1.Text = _II1l1l1l1I.bindKey.Name
			_IIIl1lIII1.Visible = true
		else
			_IIIl1lIII1.Visible = false
		end
	end
	_II1l1l1l1I.updateVisuals()
	_1I111I1ll(_lII1I1I11.InputBegan:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
		local _l1l1IIlll111Il, size = row.AbsolutePosition, row.AbsoluteSize
		local _I111l1Il1Il, _1lllIIlIIl1 = i.Position.X, i.Position.Y
		if _I111l1Il1Il >= _l1l1IIlll111Il.X and _I111l1Il1Il <= _l1l1IIlll111Il.X + size.X and _1lllIIlIIl1 >= _l1l1IIlll111Il.Y and _1lllIIlIIl1 <= _l1l1IIlll111Il.Y + size.Y then
			_I1ll11IlIl = _II1l1l1l1I
			_IIIl1lIII1.Text = _D("\218\218\218")
			_IIIl1lIII1.Visible = true
		end
	end))

	if not _llI1l1II1 then
		table.insert(_Il1lI1llIIIl, {
			id = _1l1l1l11IIIII(_11II11Il11l1, label),
			get = function() return _1lIIllIllll1lIl end,
			set = function(v) _1ll1IIII1Il.set(v, false) end,
		})
	end
	table.insert(_Il1lI1llIIIl, {
		id = _1l1l1l11IIIII(_11II11Il11l1, label) .. _D("\215\150\157\154\144"),
		get = function() return _II1l1l1l1I.bindKey and _II1l1l1l1I.bindKey.Name or nil end,
		set = function(v)
			if type(v) == _D("\135\128\134\157\154\147") then
				local _1Il1IllII = Enum.KeyCode[v]
				if _1Il1IllII then
					_II1l1l1l1I.bindKey = _1Il1IllII
					_1IlII11lIIIIl11[_1Il1IllII] = _II1l1l1l1I
					_II1l1l1l1I.updateVisuals()
				end
			end
		end,
	})
	return _1ll1IIII1Il
end

local function _Il1111lI1(_11II11Il11l1, label, _1lIl1II11lI1, _lIlllIl11)
	local btn = Instance.new(_D("\160\145\140\128\182\129\128\128\155\154"))
	btn.Name = label
	btn.Parent = _11II11Il11l1
	btn.LayoutOrder = _lIlllIl11
	btn.Size = UDim2.new(1, 0, 0, 38)
	btn.AutoButtonColor = false
	btn.BackgroundColor3 = T.Elev
	btn.BorderSizePixel = 0
	btn.Font = FM
	btn.TextSize = 14
	btn.TextColor3 = T.Tx
	btn.Text = label
	Corner(btn, 8)
	local _I11lI11III = Stroke(btn, T.Bd2, 1, 0.4)

	local _II1l1l1l1I = { label = label, bindKey = nil, trigger = _1lIl1II11lI1 }
	function _II1l1l1l1I.updateVisuals()
		btn.Text = label .. (_II1l1l1l1I.bindKey and (_D("\212\212\212\175\212") .. _II1l1l1l1I.bindKey.Name .. _D("\212\169")) or _D(""))
	end
	_II1l1l1l1I.updateVisuals()

	btn.MouseButton1Click:Connect(function()
		if not _I1ll11IlIl then _1lIl1II11lI1() end
	end)
	btn.MouseButton2Click:Connect(function()
		_I1ll11IlIl = _II1l1l1l1I
		btn.Text = label .. _D("\212\212\212\175\212\218\218\218\212\169")
	end)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = T.Hover }):Play()
		TweenService:Create(_I11lI11III, TweenInfo.new(0.12), { Transparency = 0.1 }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = T.Elev }):Play()
		TweenService:Create(_I11lI11III, TweenInfo.new(0.12), { Transparency = 0.4 }):Play()
		_II1l1l1l1I.updateVisuals()
	end)

	table.insert(_Il1lI1llIIIl, {
		id = _1l1l1l11IIIII(_11II11Il11l1, label) .. _D("\215\150\157\154\144"),
		get = function() return _II1l1l1l1I.bindKey and _II1l1l1l1I.bindKey.Name or nil end,
		set = function(v)
			if type(v) == _D("\135\128\134\157\154\147") then
				local _1Il1IllII = Enum.KeyCode[v]
				if _1Il1IllII then
					_II1l1l1l1I.bindKey = _1Il1IllII
					_1IlII11lIIIIl11[_1Il1IllII] = _II1l1l1l1I
					_II1l1l1l1I.updateVisuals()
				end
			end
		end,
	})
	return btn
end

local function _11llIIIIlIII(_11II11Il11l1, label, min, _11IIllll1, _lIl1IIlIl1l111, _1lIl1II11lI1, _lIlllIl11)
	local frame = Instance.new(_D("\178\134\149\153\145"))
	frame.Name = label
	frame.Parent = _11II11Il11l1
	frame.LayoutOrder = _lIlllIl11
	frame.Size = UDim2.new(1, 0, 0, 48)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	local _IllllIllI = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_IllllIllI.Parent = frame
	_IllllIllI.BackgroundTransparency = 1
	_IllllIllI.Position = UDim2.new(0, 4, 0, 0)
	_IllllIllI.Size = UDim2.new(0.6, 0, 0, 20)
	_IllllIllI.Font = F
	_IllllIllI.TextSize = 13
	_IllllIllI.TextColor3 = T.Tx2
	_IllllIllI.TextXAlignment = Enum.TextXAlignment.Left
	_IllllIllI.Text = label
	local _1lIIlIlllI1ll = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_1lIIlIlllI1ll.Parent = frame
	_1lIIlIlllI1ll.BackgroundTransparency = 1
	_1lIIlIlllI1ll.AnchorPoint = Vector2.new(1, 0)
	_1lIIlIlllI1ll.Position = UDim2.new(1, -4, 0, 0)
	_1lIIlIlllI1ll.Size = UDim2.new(0.35, 0, 0, 20)
	_1lIIlIlllI1ll.Font = FM
	_1lIIlIlllI1ll.TextSize = 14
	_1lIIlIlllI1ll.TextColor3 = T.White
	_1lIIlIlllI1ll.TextXAlignment = Enum.TextXAlignment.Right
	local bar = Instance.new(_D("\178\134\149\153\145"))
	bar.Parent = frame
	bar.AnchorPoint = Vector2.new(0.5, 0)
	bar.Position = UDim2.new(0.5, 0, 0, 28)
	bar.Size = UDim2.new(1, -12, 0, 6)
	bar.BackgroundColor3 = T.TgOff
	bar.BorderSizePixel = 0
	Corner(bar, 3)
	local fill = Instance.new(_D("\178\134\149\153\145"))
	fill.Parent = bar
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = T.Accent
	fill.BorderSizePixel = 0
	Corner(fill, 3)
	local _Ill1lIlIIl1I = Instance.new(_D("\178\134\149\153\145"))
	_Ill1lIlIIl1I.Parent = bar
	_Ill1lIlIIl1I.AnchorPoint = Vector2.new(0.5, 0.5)
	_Ill1lIlIIl1I.Position = UDim2.new(0, 0, 0.5, 0)
	_Ill1lIlIIl1I.Size = UDim2.new(0, 16, 0, 16)
	_Ill1lIlIIl1I.BackgroundColor3 = T.White
	_Ill1lIlIIl1I.BorderSizePixel = 0
	Corner(_Ill1lIlIIl1I, 8)
	Stroke(_Ill1lIlIIl1I, T.BG, 2, 0)
	local _I111I1l1l = _lIl1IIlIl1l111
	local function _11IIIlII1lI1I(v)
		local _I1I1I1lI11I = math.clamp((v - min) / (_11IIllll1 - min), 0, 1)
		fill.Size = UDim2.new(_I1I1I1lI11I, 0, 1, 0)
		_Ill1lIlIIl1I.Position = UDim2.new(_I1I1I1lI11I, 0, 0.5, 0)
		_1lIIlIlllI1ll.Text = tostring(v)
	end
	_11IIIlII1lI1I(_I111I1l1l)
	local _II1IIl1ll = false
	local function _IlI1I11II1(_lll11lI1llIl1ll)
		local _lll111I1lIII = bar.AbsolutePosition
		local _1l1ll11IllI1II = bar.AbsoluteSize
		local _I1I1I1lI11I = math.clamp((_lll11lI1llIl1ll.Position.X - _lll111I1lIII.X) / _1l1ll11IllI1II.X, 0, 1)
		local _IlII1lI11I = math.floor(min + (_11IIllll1 - min) * _I1I1I1lI11I + 0.5)
		if _IlII1lI11I ~= _I111I1l1l then
			_I111I1l1l = _IlII1lI11I
			_11IIIlII1lI1I(_I111I1l1l)
			_1lIl1II11lI1(_I111I1l1l)
			if S._RequestAutoSave then S._RequestAutoSave() end
		end
	end
	frame.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			_II1IIl1ll = true
			_IlI1I11II1(i)
		end
	end)
	_1I111I1ll(_lII1I1I11.InputChanged:Connect(function(i)
		if _II1IIl1ll and i.UserInputType == Enum.UserInputType.MouseMovement then
			_IlI1I11II1(i)
		end
	end))
	_1I111I1ll(_lII1I1I11.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			_II1IIl1ll = false
		end
	end))
	local _1ll1IIII1Il = { get = function() return _I111I1l1l end }
	function _1ll1IIII1Il.set(v)
		v = tonumber(v)
		if not v then return end
		_I111I1l1l = math.clamp(math.floor(v + 0.5), min, _11IIllll1)
		_11IIIlII1lI1I(_I111I1l1l)
		pcall(_1lIl1II11lI1, _I111I1l1l)
	end
	table.insert(_Il1lI1llIIIl, {
		id = _1l1l1l11IIIII(_11II11Il11l1, label),
		get = function() return _I111I1l1l end,
		set = _1ll1IIII1Il.set,
	})
	return _1ll1IIII1Il
end

local function _1lllI11IIllIllI(_11II11Il11l1, label, _IlII111ll1l1I1, labels, _II1lI1llIlII, _1lIl1II11lI1, _lIlllIl11)
	local row = Instance.new(_D("\178\134\149\153\145"))
	row.Name = label
	row.Parent = _11II11Il11l1
	row.LayoutOrder = _lIlllIl11
	row.Size = UDim2.new(1, 0, 0, 36)
	row.BackgroundTransparency = 1
	local _IllllIllI = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_IllllIllI.Parent = row
	_IllllIllI.BackgroundTransparency = 1
	_IllllIllI.Position = UDim2.new(0, 8, 0, 0)
	_IllllIllI.Size = UDim2.new(1, -146, 1, 0)
	_IllllIllI.Font = F
	_IllllIllI.TextSize = 14
	_IllllIllI.TextColor3 = T.Tx2
	_IllllIllI.TextXAlignment = Enum.TextXAlignment.Left
	_IllllIllI.Text = label
	local btn = Instance.new(_D("\160\145\140\128\182\129\128\128\155\154"))
	btn.Parent = row
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.Position = UDim2.new(1, -8, 0.5, 0)
	btn.Size = UDim2.new(0, 130, 0, 26)
	btn.BackgroundColor3 = T.Elev
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Font = FM
	btn.TextSize = 13
	btn.TextColor3 = T.Tx
	Corner(btn, 7)
	Stroke(btn, T.Bd2, 1, 0.4)
	local _1lII11l1l1lI = 1
	for i, o in ipairs(_IlII111ll1l1I1) do if o == _II1lI1llIlII then _1lII11l1l1lI = i break end end
	local function _IIll11l11lI(_1l1ll1II1llIIII)
		btn.Text = tostring(labels[_1lII11l1l1lI] or _IlII111ll1l1I1[_1lII11l1l1lI] or _D(""))
		if _1l1ll1II1llIIII then
			_1lIl1II11lI1(_IlII111ll1l1I1[_1lII11l1l1lI])
			if S._RequestAutoSave then S._RequestAutoSave() end
		end
	end
	_IIll11l11lI(false)
	btn.MouseButton1Click:Connect(function()
		_1lII11l1l1lI = _1lII11l1l1lI % #_IlII111ll1l1I1 + 1
		_IIll11l11lI(true)
	end)
	btn.MouseButton2Click:Connect(function()
		_1lII11l1l1lI = (_1lII11l1l1lI - 2) % #_IlII111ll1l1I1 + 1
		_IIll11l11lI(true)
	end)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = T.Hover }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = T.Elev }):Play()
	end)
	local function _III1IIl1l1Il1Il(v)
		for i, o in ipairs(_IlII111ll1l1I1) do
			if o == v then
				_1lII11l1l1lI = i
				btn.Text = tostring(labels[_1lII11l1l1lI] or _IlII111ll1l1I1[_1lII11l1l1lI] or _D(""))
				pcall(_1lIl1II11lI1, _IlII111ll1l1I1[_1lII11l1l1lI])
				return
			end
		end
	end

	local _1ll1IIII1Il = {}
	function _1ll1IIII1Il.get() return _IlII111ll1l1I1[_1lII11l1l1lI] end
	function _1ll1IIII1Il.set(v) _III1IIl1l1Il1Il(v) end
	function _1ll1IIII1Il.update(_IIII1II1l1I, _IlIllIl1l1I1l)
		_IlII111ll1l1I1 = _IIII1II1l1I
		labels = _IlIllIl1l1I1l or _IIII1II1l1I
		_1lII11l1l1lI = math.clamp(_1lII11l1l1lI, 1, #_IlII111ll1l1I1)
		if #_IlII111ll1l1I1 == 0 then
			_1lII11l1l1lI = 1
			btn.Text = _D("\186\155\154\145")
		else
			btn.Text = tostring(labels[_1lII11l1l1lI] or _IlII111ll1l1I1[_1lII11l1l1lI] or _D(""))
		end
	end

	table.insert(_Il1lI1llIIIl, {
		id = _1l1l1l11IIIII(_11II11Il11l1, label),
		get = function() return _IlII111ll1l1I1[_1lII11l1l1lI] end,
		set = _III1IIl1l1Il1Il,
	})
	return _1ll1IIII1Il
end

local _IlI1l1lI1IlI = {}
local function _lIIllIl1ll1l(_11l1lIIll, _l1l1IIlll111Il, size, z)
	local f = Instance.new(_D("\178\134\149\153\145"))
	f.Name = _D("\188\161\176\171") .. _11l1lIIll
	f.Parent = _111lllI1I
	f.Active = true
	f.Position = _l1l1IIlll111Il
	f.Size = size
	f.BackgroundColor3 = T.Card
	f.BackgroundTransparency = 0.05
	f.BorderSizePixel = 0
	f.Visible = false
	f.ZIndex = z or 850
	Corner(f, 12)
	Stroke(f, T.Bd2, 1, 0.35)
	Shadow(f, 0.45)
	Grad(f, Color3.fromRGB(22, 22, 22), T.Card, 90)
	local _1lIl111l1 = Instance.new(_D("\178\134\149\153\145"))
	_1lIl111l1.Parent = f
	_1lIl111l1.Active = true
	_1lIl111l1.BackgroundColor3 = T.Elev
	_1lIl111l1.BorderSizePixel = 0
	_1lIl111l1.Size = UDim2.new(1, 0, 0, 30)
	_1lIl111l1.ZIndex = z + 1
	Corner(_1lIl111l1, 10)
	local tick = Instance.new(_D("\178\134\149\153\145"))
	tick.Parent = _1lIl111l1
	tick.BackgroundColor3 = T.Accent
	tick.BorderSizePixel = 0
	tick.Position = UDim2.new(0, 10, 0.5, -6)
	tick.Size = UDim2.new(0, 3, 0, 12)
	tick.ZIndex = z + 2
	Corner(tick, 2)
	local _1ll1III11lI1I = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_1ll1III11lI1I.Parent = _1lIl111l1
	_1ll1III11lI1I.BackgroundTransparency = 1
	_1ll1III11lI1I.Size = UDim2.new(1, -20, 1, 0)
	_1ll1III11lI1I.Position = UDim2.new(0, 18, 0, 0)
	_1ll1III11lI1I.Font = _llII1lI1I
	_1ll1III11lI1I.TextSize = 13
	_1ll1III11lI1I.TextColor3 = T.Tx3
	_1ll1III11lI1I.TextXAlignment = Enum.TextXAlignment.Left
	_1ll1III11lI1I.Text = string.upper(_11l1lIIll)
	_1ll1III11lI1I.ZIndex = z + 2
	local _111IIllII1lIIl = Instance.new(_D("\178\134\149\153\145"))
	_111IIllII1lIIl.Name = _D("\183")
	_111IIllII1lIIl.Parent = f
	_111IIllII1lIIl.BackgroundTransparency = 1
	_111IIllII1lIIl.Position = UDim2.new(0, 9, 0, 34)
	_111IIllII1lIIl.Size = UDim2.new(1, -18, 1, -41)
	_111IIllII1lIIl.ZIndex = z + 1
	
	_1II111II1l1Il1(f, _1lIl111l1)
	_IlI1l1lI1IlI[_11l1lIIll] = { frame = f, content = _111IIllII1lIIl, setLocked = function(v) end }
	return _IlI1l1lI1IlI[_11l1lIIll]
end


S.EspTags = {}
local function centerOffsetFor(adornee)
	if not adornee:IsA(_D("\185\155\144\145\152")) then return Vector3.new(0, 0, 0) end
	local _l1lI1I11Il11ll1, _IlII1ll1lll = pcall(function() return (adornee:GetBoundingBox()) end)
	if not _l1lI1I11Il11ll1 or not _IlII1ll1lll then return Vector3.new(0, 0, 0) end
	local _1I11l1Il1l11I, _IIIIl1IIIIl = pcall(function() return adornee:GetPivot() end)
	if not _1I11l1Il1l11I or not _IIIIl1IIIIl then return Vector3.new(0, 0, 0) end
	return _IlII1ll1lll.Position - _IIIIl1IIIIl.Position
end

local function mkEspTag(adornee, title, _1111I11lIIIl1l, _lIll1IllIlI1lII)
	_lIll1IllIlI1lII = _lIll1IllIlI1lII or {}
	local bb = Instance.new(_D("\182\157\152\152\150\155\149\134\144\179\129\157"))
	bb.Name = _D("\176\145\153\155\154\155\152\155\147\141\177\135\132\160\149\147")
	bb.Parent = adornee
	bb.Adornee = adornee
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.Size = _lIll1IllIlI1lII.size or UDim2.fromOffset(160, 44)
	bb.StudsOffset = _lIll1IllIlI1lII.offset or Vector3.new(0, 1.6, 0)
	bb.StudsOffsetWorldSpace = centerOffsetFor(adornee)

	local card = Instance.new(_D("\178\134\149\153\145"))
	card.Parent = bb
	card.BackgroundColor3 = Color3.fromRGB(10, 8, 8)
	card.BackgroundTransparency = 0.2
	card.BorderSizePixel = 0
	card.Size = UDim2.new(1, 0, 1, 0)
	Corner(card, 8)
	Stroke(card, _1111I11lIIIl1l, 1.2, 0.2)
	Grad(card, Color3.fromRGB(28, 28, 28), Color3.fromRGB(10, 10, 10), 90)

	local dot = Instance.new(_D("\178\134\149\153\145"))
	dot.Parent = card
	dot.AnchorPoint = Vector2.new(0, 0.5)
	dot.Position = UDim2.new(0, 8, 0.28, 0)
	dot.Size = UDim2.new(0, 6, 0, 6)
	dot.BackgroundColor3 = _1111I11lIIIl1l
	Corner(dot, 3)

	local _1ll1III11lI1I = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_1ll1III11lI1I.Parent = card
	_1ll1III11lI1I.BackgroundTransparency = 1
	_1ll1III11lI1I.Position = UDim2.new(0, 20, 0, 2)
	_1ll1III11lI1I.Size = UDim2.new(1, -26, 0, 18)
	_1ll1III11lI1I.Font = FM
	_1ll1III11lI1I.Text = title
	_1ll1III11lI1I.TextColor3 = T.White
	_1ll1III11lI1I.TextSize = 14
	_1ll1III11lI1I.TextXAlignment = Enum.TextXAlignment.Left
	_1ll1III11lI1I.TextTruncate = Enum.TextTruncate.AtEnd

	local distLbl = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	distLbl.Parent = card
	distLbl.BackgroundTransparency = 1
	distLbl.Position = UDim2.new(0, 20, 0, 21)
	distLbl.Size = UDim2.new(1, -26, 0, 16)
	distLbl.Font = F
	distLbl.Text = _D("")
	distLbl.TextColor3 = T.Tx2
	distLbl.TextSize = 12
	distLbl.TextXAlignment = Enum.TextXAlignment.Left

	local _lI1Ill1llI1l = Instance.new(_D("\161\189\167\151\149\152\145"))
	_lI1Ill1llI1l.Scale = 0.6
	_lI1Ill1llI1l.Parent = card
	TweenService:Create(_lI1Ill1llI1l, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()

	local hl = nil
	if _lIll1IllIlI1lII.highlight ~= false then
		hl = Instance.new(_D("\188\157\147\156\152\157\147\156\128"))
		hl.Name = _D("\176\145\153\155\154\155\152\155\147\141\177\135\132\188\184")
		hl.Parent = adornee
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.OutlineColor = _1111I11lIIIl1l
		hl.FillColor = _1111I11lIIIl1l
		hl.FillTransparency = _lIll1IllIlI1lII.fill or 0.9
		hl.OutlineTransparency = 0
		hl.Adornee = adornee
	end

	local _II1l1l1l1I = { bb = bb, hl = hl, distLbl = distLbl, title = _1ll1III11lI1I, adornee = adornee, card = card, dot = dot }
	function _II1l1l1l1I.setColor(_1l1IIllIl)
		if _II1l1l1l1I.hl then
			_II1l1l1l1I.hl.OutlineColor = _1l1IIllIl
			_II1l1l1l1I.hl.FillColor = _1l1IIllIl
		end
		if _II1l1l1l1I.card then
			local _l1ll111I1 = _II1l1l1l1I.card:FindFirstChildOfClass(_D("\161\189\167\128\134\155\159\145"))
			if _l1ll111I1 then _l1ll111I1.Color = _1l1IIllIl end
		end
		if _II1l1l1l1I.dot then
			_II1l1l1l1I.dot.BackgroundColor3 = _1l1IIllIl
		end
	end
	table.insert(S.EspTags, _II1l1l1l1I)
	return _II1l1l1l1I
end
local function _llllIlIllII(_II1l1l1l1I)
	if not _II1l1l1l1I then return end
	if _II1l1l1l1I.bb then _II1l1l1l1I.bb:Destroy() end
	if _II1l1l1l1I.hl then _II1l1l1l1I.hl:Destroy() end
end

do
	local _111IlIIlII1I = tick()
	_1I111I1ll(_lII111IIIIllI.Heartbeat:Connect(function()
		if tick() - _111IlIIlII1I < 0.15 then return end
		_111IlIIlII1I = tick()
		local _Ill11Il11l = plr.Character
		local _1I1llIlIlI = _Ill11Il11l and _Ill11Il11l:FindFirstChild(_D("\188\129\153\149\154\155\157\144\166\155\155\128\164\149\134\128"))
		for i = #S.EspTags, 1, -1 do
			local e = S.EspTags[i]
			if not e.bb or not e.bb.Parent then
				table.remove(S.EspTags, i)
			elseif _1I1llIlIlI then
				local _l1lI1I11Il11ll1, _l1l1IIlll111Il = pcall(function()
					return e.adornee:IsA(_D("\185\155\144\145\152")) and e.adornee:GetPivot().Position or e.adornee.Position
				end)
				if _l1lI1I11Il11ll1 and _l1l1IIlll111Il then
					e.distLbl.Text = tostring(math.floor((_1I1llIlIlI.Position - _l1l1IIlll111Il).Magnitude)) .. _D("\212\135\128\129\144\135")
				end
			end
		end
	end))
end


do
	local _lII11IllI1I1l = _D("\176\145\153\155\154\155\152\155\147\141\183\155\154\146\157\147")
	local CONFIG_FILE = _lII11IllI1I1l .. _D("\219\135\145\128\128\157\154\147\135\218\158\135\155\154")
	local HttpService = game:GetService(_D("\188\128\128\132\167\145\134\130\157\151\145"))

	local function _IIlI11IllI1l()
		pcall(function()
			if isfolder and makefolder and not isfolder(_lII11IllI1I1l) then
				makefolder(_lII11IllI1I1l)
			end
		end)
	end

	local function _lI1llIlIll1lll()
		if not writefile then return end
		local _1IllIl1lll1 = {}
		for _, c in ipairs(_Il1lI1llIIIl) do
			local _l1lI1I11Il11ll1, v = pcall(c.get)
			if _l1lI1I11Il11ll1 and v ~= nil then _1IllIl1lll1[c.id] = v end
		end
		pcall(function()
			_IIlI11IllI1l()
			writefile(CONFIG_FILE, HttpService:JSONEncode(_1IllIl1lll1))
		end)
	end
	S._SaveConfigNow = _lI1llIlIll1lll

	local _111lI11llI1Il = false
	S._RequestAutoSave = function()
		if _111lI11llI1Il then return end
		_111lI11llI1Il = true
		task.delay(1, function()
			_111lI11llI1Il = false
			_lI1llIlIll1lll()
		end)
	end

	S._LoadConfig = function()
		if not (readfile and isfile) then return end
		local _l1lI1I11Il11ll1, _1ll1lII11l1I = pcall(isfile, CONFIG_FILE)
		if not _l1lI1I11Il11ll1 or not _1ll1lII11l1I then return end
		local _1I11l1Il1l11I, _11lI11l1l1 = pcall(readfile, CONFIG_FILE)
		if not _1I11l1Il1l11I then return end
		local _Illllll1l1, _1IllIl1lll1 = pcall(function() return HttpService:JSONDecode(_11lI11l1l1) end)
		if not _Illllll1l1 or type(_1IllIl1lll1) ~= _D("\128\149\150\152\145") then return end
		local _IlI1I11IIlIll = 0
		for _, c in ipairs(_Il1lI1llIIIl) do
			local v = _1IllIl1lll1[c.id]
			if v ~= nil then
				local _1lIIIlIII = pcall(c.set, v)
				if _1lIIIlIII then _IlI1I11IIlIll = _IlI1I11IIlIll + 1 end
			end
		end
		if _IlI1I11IIlIll > 0 then
			_1I11lIIllII(_D("\183\155\154\146\157\147"), _D("\166\145\135\128\155\134\145\144\212") .. _IlI1I11IIlIll .. _D("\212\135\149\130\145\144\212\135\145\128\128\157\154\147\220\135\221"), _D("\157\154\146\155"), 2.5)
		end
	end
end


local _lllIIlI1l1 = false
_IIll111Il.MouseButton1Click:Connect(function()
	_lllIIlI1l1 = not _lllIIlI1l1
	if _lllIIlI1l1 then
		_11lllIllIl1l.Visible = false
		_11l1IIl11I11ll.Visible = false
		_1lI1lIIl1lIIIl.Visible = false
		TweenService:Create(_1l1l1l1Il, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Size = UDim2.fromOffset(_1l1l1l1Il.AbsoluteSize.X, 48)
		}):Play()
	else
		TweenService:Create(_1l1l1l1Il, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Size = _II11ll111l1I1
		}):Play()
		task.wait(0.2)
		_11lllIllIl1l.Visible = true
		_11l1IIl11I11ll.Visible = true
		_1lI1lIIl1lIIIl.Visible = true
	end
end)

local function _1lIlI111I11Ill()
	pcall(function()
		local _1l1IllIlIIll = TweenService:Create(_1l1l1l1Il, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0)
		})
		_1l1IllIlIIll:Play()
		_1l1IllIlIIll.Completed:Wait()
	end)

	if S._SaveConfigNow then pcall(S._SaveConfigNow) end
	if S.DisableAllExtras then pcall(S.DisableAllExtras) end
	if S.UpdateEvidenceEsp then S.EvidenceEsp = false; pcall(S.UpdateEvidenceEsp) end
	if S.UpdatePlrEsp then S.PlayersEsp = false; pcall(S.UpdatePlrEsp) end
	if S.ClearItemEsp then pcall(S.ClearItemEsp) end
	if S.DestroyGhostEsp then pcall(S.DestroyGhostEsp) end
	if S.UnmuteAllOnClose then pcall(S.UnmuteAllOnClose) end
	if S.MouseUnlockCleanup then pcall(S.MouseUnlockCleanup) end

	_1lllII11l1I.Ambient = S.OldLighting.Ambient
	_1lllII11l1I.OutdoorAmbient = S.OldLighting.OutdoorAmbient
	_1lllII11l1I.Brightness = S.OldLighting.Brightness
	_1lllII11l1I.GlobalShadows = S.OldLighting.GlobalShadows
	_1lllII11l1I.FogEnd = S.OldLighting.FogEnd

	for _, _lll1I1IlIll1l1 in ipairs(S.Connections) do
		pcall(function() _lll1I1IlIll1l1:Disconnect() end)
	end
	_lIlll11II1llII()

	if S.AppliedWalkSpeed then
		task.spawn(function()
			local _1llIIII11IlIlI = plr.Character and plr.Character:FindFirstChildOfClass(_D("\188\129\153\149\154\155\157\144"))
			if _1llIIII11IlIlI then _1llIIII11IlIlI.WalkSpeed = 16 end
		end)
	end

	_111lllI1I:Destroy()
	getgenv()[_D("\176\145\153\155\154\155\152\155\147\141\161\189")] = nil
end
local _1lllIIllI1 = false
local function _II1l111llllIlII()
	if _1lllIIllI1 then return end
	_1lllIIllI1 = true
	_1lIlI111I11Ill()
end
_lIl11I111lI.MouseButton1Click:Connect(_II1l111llllIlII)


local _ll11lIl1lllIIl = false
local _lI11lIIIl = false
local function _11Ill111lIIl(_lIl1llIlI)
	if _lI11lIIIl or _ll11lIl1lllIIl == _lIl1llIlI then return end
	_lI11lIIIl = true
	_ll11lIl1lllIIl = _lIl1llIlI
	if _lIl1llIlI then
		_1l1l1l1Il.Visible = true
		local _1l1IllIlIIll = TweenService:Create(_1l1l1l1Il, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = _II11ll111l1I1
		})
		_1l1IllIlIIll:Play()
		_1l1IllIlIIll.Completed:Wait()
	else
		local _1l1IllIlIIll = TweenService:Create(_1l1l1l1Il, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0)
		})
		_1l1IllIlIIll:Play()
		_1l1IllIlIIll.Completed:Wait()
		_1l1l1l1Il.Visible = false
		if _11I1IIll11Il then
			_11I1IIll11Il.set(false, false)
		else
			_1l1ll1I111lllll = false
		end
	end
	_lI11lIIIl = false
end
_1I111I1ll(_lII1I1I11.InputBegan:Connect(function(_lll11lI1llIl1ll, _1IlI1I1llIl)
	if _1lllIIllI1 then return end
	local _1ll11l111l = false
	pcall(function() _1ll11l111l = (_lII1I1I11:GetFocusedTextBox() ~= nil) end)
	if _1ll11l111l then return end
	if _lll11lI1llIl1ll.KeyCode == Enum.KeyCode.RightShift then
		_11Ill111lIIl(not _ll11lIl1lllIIl)
	end
end))


do
	local _1II111IIIl1lI = nil
	local function _1llllllllll()
		local _II11IIllllll = _1l1l1l1Il.Visible or _1l1ll1I111lllll
		if _II11IIllllll then
			if _1II111IIIl1lI == nil then
				_1II111IIIl1lI = _lII1I1I11.MouseBehavior
			end
			if _lII1I1I11.MouseBehavior ~= Enum.MouseBehavior.Default then
				_lII1I1I11.MouseBehavior = Enum.MouseBehavior.Default
			end
			if not _lII1I1I11.MouseIconEnabled then
				_lII1I1I11.MouseIconEnabled = true
			end
		else
			_1II111IIIl1lI = nil
		end
	end
	_1I111I1ll(_lII111IIIIllI.RenderStepped:Connect(_1llllllllll))
	_1I111I1ll(_lII111IIIIllI.Stepped:Connect(_1llllllllll))
	_1I111I1ll(_lII111IIIIllI.Heartbeat:Connect(_1llllllllll))

	S.MouseUnlockCleanup = function()
	end
end


do
	local _Il1IlIl11Ill = Instance.new(_D("\178\134\149\153\145"))
	_Il1IlIl11Ill.Name = _D("\184\155\149\144\157\154\147\167\151\134\145\145\154")
	_Il1IlIl11Ill.Parent = _111lllI1I
	_Il1IlIl11Ill.AnchorPoint = Vector2.new(0.5, 0.5)
	_Il1IlIl11Ill.Position = UDim2.new(0.5, 0, 0.5, 0)
	_Il1IlIl11Ill.Size = UDim2.new(0, 360, 0, 180)
	_Il1IlIl11Ill.BackgroundColor3 = T.BG
	_Il1IlIl11Ill.BorderSizePixel = 0
	_Il1IlIl11Ill.ZIndex = 500
	Corner(_Il1IlIl11Ill, 14)
	Stroke(_Il1IlIl11Ill, T.Bd, 1.5, 0.1)
	Grad(_Il1IlIl11Ill, Color3.fromRGB(28, 28, 28), Color3.fromRGB(10, 10, 10), 90)

	local _l11llIlll1 = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_l11llIlll1.Parent = _Il1IlIl11Ill
	_l11llIlll1.BackgroundTransparency = 1
	_l11llIlll1.Position = UDim2.new(0, 0, 0.13, 0)
	_l11llIlll1.Size = UDim2.new(1, 0, 0.26, 0)
	_l11llIlll1.Font = _llII1lI1I
	_l11llIlll1.Text = _D("\176\177\185\187\186\187\184\187\179\173")
	_l11llIlll1.TextColor3 = T.White
	_l11llIlll1.TextScaled = true
	_l11llIlll1.ZIndex = 501

	local _1lllll1lI = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_1lllll1lI.Parent = _Il1IlIl11Ill
	_1lllll1lI.BackgroundTransparency = 1
	_1lllll1lI.Position = UDim2.new(0, 0, 0.40, 0)
	_1lllll1lI.Size = UDim2.new(1, 0, 0.13, 0)
	_1lllll1lI.Font = F
	_1lllll1lI.Text = _D("\189\154\157\128\157\149\152\157\142\157\154\147\218\218\218")
	_1lllll1lI.TextColor3 = T.Tx2
	_1lllll1lI.TextScaled = true
	_1lllll1lI.ZIndex = 501

	local _lll11l1I1l1I1 = Instance.new(_D("\178\134\149\153\145"))
	_lll11l1I1l1I1.Parent = _Il1IlIl11Ill
	_lll11l1I1l1I1.AnchorPoint = Vector2.new(0.5, 0.5)
	_lll11l1I1l1I1.Position = UDim2.new(0.5, 0, 0.70, 0)
	_lll11l1I1l1I1.Size = UDim2.new(0.8, 0, 0.055, 0)
	_lll11l1I1l1I1.BackgroundColor3 = T.Elev
	_lll11l1I1l1I1.BorderSizePixel = 0
	_lll11l1I1l1I1.ZIndex = 501
	Corner(_lll11l1I1l1I1, 10)

	local _l11I1IlI1 = Instance.new(_D("\178\134\149\153\145"))
	_l11I1IlI1.Parent = _lll11l1I1l1I1
	_l11I1IlI1.Size = UDim2.new(0, 0, 1, 0)
	_l11I1IlI1.BackgroundColor3 = T.Accent
	_l11I1IlI1.BorderSizePixel = 0
	_l11I1IlI1.ZIndex = 502
	Corner(_l11I1IlI1, 10)

	local _l1Il1l1llI1 = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_l1Il1l1llI1.Parent = _Il1IlIl11Ill
	_l1Il1l1llI1.BackgroundTransparency = 1
	_l1Il1l1llI1.Position = UDim2.new(0, 0, 0.80, 0)
	_l1Il1l1llI1.Size = UDim2.new(1, 0, 0.13, 0)
	_l1Il1l1llI1.Font = F
	_l1Il1l1llI1.Text = _D("\196\209")
	_l1Il1l1llI1.TextColor3 = T.Tx2
	_l1Il1l1llI1.TextScaled = true
	_l1Il1l1llI1.ZIndex = 501

	task.spawn(function()
		local _1lllllIllIII = {
			{ 0.20, _D("\189\154\158\145\151\128\157\154\147\212\153\155\144\129\152\145\135\218\218\218") },
			{ 0.45, _D("\184\155\149\144\157\154\147\212\145\130\157\144\145\154\151\145\212\128\134\149\151\159\145\134\218\218\218") },
			{ 0.70, _D("\182\129\157\152\144\157\154\147\212\157\154\128\145\134\146\149\151\145\218\218\218") },
			{ 0.90, _D("\183\155\154\154\145\151\128\157\154\147\212\145\130\145\154\128\135\218\218\218") },
			{ 1.00, _D("\178\157\154\149\152\157\142\157\154\147\218\218\218") },
		}
		local _1Illl11IIlII11 = 0
		for _, stage in ipairs(_1lllllIllIII) do
			_1lllll1lI.Text = stage[2]
			TweenService:Create(_l11I1IlI1, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(stage[1], 0, 1, 0)
			}):Play()
			local _1III11lI1I1I = math.floor(stage[1] * 100)
			while _1Illl11IIlII11 < _1III11lI1I1I do
				_1Illl11IIlII11 = _1Illl11IIlII11 + 1
				_l1Il1l1llI1.Text = _1Illl11IIlII11 .. _D("\209")
				task.wait(0.01)
			end
			task.wait(0.2)
		end
		task.wait(0.15)
		for _, o in ipairs(_Il1IlIl11Ill:GetDescendants()) do
			if o:IsA(_D("\160\145\140\128\184\149\150\145\152")) then
				TweenService:Create(o, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
			elseif o:IsA(_D("\178\134\149\153\145")) then
				TweenService:Create(o, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
			elseif o:IsA(_D("\161\189\167\128\134\155\159\145")) then
				TweenService:Create(o, TweenInfo.new(0.3), { Transparency = 1 }):Play()
			end
		end
		TweenService:Create(_Il1IlIl11Ill, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
		task.wait(0.32)
		_Il1IlIl11Ill:Destroy()
		_11Ill111lIIl(true)
		_1I11lIIllII(_D("\185\145\154\129\212\134\145\149\144\141"), _D("\166\157\147\156\128\212\167\156\157\146\128\212\022\116\096\212\135\156\155\131\212\219\212\156\157\144\145\212\153\145\154\129"), _D("\157\154\146\155"), 4.5)
	end)
end




S.OldLighting = {
	Ambient = _1lllII11l1I.Ambient,
	OutdoorAmbient = _1lllII11l1I.OutdoorAmbient,
	Brightness = _1lllII11l1I.Brightness,
	GlobalShadows = _1lllII11l1I.GlobalShadows,
	FogEnd = _1lllII11l1I.FogEnd,
}

local function _llllII1Illll(_IlI11lI11IIl1II)
	local _11lIl1llI1l = plr.PlayerGui:FindFirstChild(_D("\188\155\128\150\149\134"))
	local _1IlllllIlI = _11lIl1llI1l and _11lIl1llI1l:FindFirstChild(_D("\167\152\155\128\135"))
	if not _1IlllllIlI then return false, nil end
	for _, _llI1ll1Il1 in ipairs(_1IlllllIlI:GetChildren()) do
		if _llI1ll1Il1:IsA(_D("\178\134\149\153\145")) and string.find(string.lower(_llI1ll1Il1.Name), _D("\157\154\130\135\152\155\128")) then
			local _I1lIllII1I = _llI1ll1Il1:FindFirstChild(_D("\189\128\145\153\186\149\153\145"))
			if _I1lIllII1I and _I1lIllII1I.Text == _IlI11lI11IIl1II then
				return true, tonumber(_llI1ll1Il1.Name:match(_D("\209\144\223")))
			end
		end
	end
	return false, nil
end

local function _l11l1l11I(_IlI11lI11IIl1II)
	local _l1I1I11ll11 = workspace:FindFirstChild(_D("\189\128\145\153\135"))
	if not _l1I1I11ll11 then return false, nil end
	for _, v in pairs(_l1I1I11ll11:GetChildren()) do
		if v:IsA(_D("\185\155\144\145\152")) and v:GetAttribute(_D("\189\128\145\153\186\149\153\145")) == _IlI11lI11IIl1II then
			return true, v
		end
	end
	return false, nil
end

local function _I1l1I11ll1ll1(_I1111ll11lIIllI)
	_lIIIl11lllllI():WaitForChild(_D("\166\145\133\129\145\135\128\189\128\145\153\177\133\129\157\132")):FireServer(_D("\189\154\130\167\152\155\128") .. tostring(_I1111ll11lIIllI))
	return true
end

local function _l111l1IIIlIllI1(_1II11l1lIIl1)
	_lIIIl11lllllI():WaitForChild(_D("\166\145\133\129\145\135\128\189\128\145\153\164\157\151\159\129\132")):FireServer(_1II11l1lIIl1)
	return true
end

local function _1I1lllllllIIlIl(_I1111ll11lIIllI)
	_lIIIl11lllllI():WaitForChild(_D("\166\145\133\129\145\135\128\189\128\145\153\176\134\155\132")):FireServer(_D("\189\154\130\167\152\155\128") .. tostring(_I1111ll11lIIllI))
	return true
end

local function _IlIl1l1l1I()
	local _ll1I1IlllI1I = plr.Character
	if _ll1I1IlllI1I then
		for _, v in pairs(_ll1I1IlllI1I:GetChildren()) do
			if v:IsA(_D("\185\155\144\145\152")) or tonumber(v.Name) then
				if v:GetAttribute(_D("\177\154\149\150\152\145\144")) ~= true and v:FindFirstChild(_D("\188\149\154\144\152\145")) then
					_lIIIl11lllllI():WaitForChild(_D("\160\155\147\147\152\145\189\128\145\153\167\128\149\128\145")):FireServer(v)
					break
				end
			end
		end
	end
	return true
end

local function _l1III1III1I()
	local _lI1lI1l1l1II11I, _1lIIII11l1 = _llllII1Illll(_D("\164\156\155\128\155\212\183\149\153\145\134\149"))
	if not _lI1lI1l1l1II11I then
		local _l11l1IIIIII, _lllIl1IIl = _l11l1l11I(_D("\164\156\155\128\155\212\183\149\153\145\134\149"))
		if not (_l11l1IIIIII and _lllIl1IIl) then return false end
		_l111l1IIIlIllI1(_lllIl1IIl)
		task.wait(0.5)
		_lI1lI1l1l1II11I, _1lIIII11l1 = _llllII1Illll(_D("\164\156\155\128\155\212\183\149\153\145\134\149"))
		if not _lI1lI1l1l1II11I then return false end
	end
	_I1l1I11ll1ll1(_1lIIII11l1)
	task.wait(0.5)
	return true
end

local function _lIllI111I1llI1()
	local _II1ll1l11, _1lIIII11l1 = _llllII1Illll(_D("\188\149\129\154\128\145\144\212\185\157\134\134\155\134"))
	if not _II1ll1l11 then
		local _l11l1IIIIII, _lllIl1IIl = _l11l1l11I(_D("\188\149\129\154\128\145\144\212\185\157\134\134\155\134"))
		if not (_l11l1IIIIII and _lllIl1IIl) then
			_1I11lIIllII(_D("\188\149\129\154\128\145\144\212\185\157\134\134\155\134"), _D("\185\157\134\134\155\134\212\154\155\128\212\146\155\129\154\144\212\154\145\149\134\150\141"), _D("\131\149\134\154"), 2.5)
			return
		end
		_l111l1IIIlIllI1(_lllIl1IIl)
		task.wait(0.5)
		_II1ll1l11, _1lIIII11l1 = _llllII1Illll(_D("\188\149\129\154\128\145\144\212\185\157\134\134\155\134"))
		if not _II1ll1l11 then
			_1I11lIIllII(_D("\188\149\129\154\128\145\144\212\185\157\134\134\155\134"), _D("\178\149\157\152\145\144\212\128\155\212\132\157\151\159\212\129\132\212\128\156\145\212\153\157\134\134\155\134"), _D("\131\149\134\154"), 2.5)
			return
		end
	end
	_I1l1I11ll1ll1(_1lIIII11l1)
	task.wait(0.5)
	local _1IllllI1lI1
	local _ll1I1IlllI1I = plr.Character
	if _ll1I1IlllI1I then
		for _, v in pairs(_ll1I1IlllI1I:GetChildren()) do
			if v:IsA(_D("\185\155\144\145\152")) or tonumber(v.Name) then
				_1IllllI1lI1 = v
				break
			end
		end
	end
	if not _1IllllI1lI1 then
		_1I11lIIllII(_D("\188\149\129\154\128\145\144\212\185\157\134\134\155\134"), _D("\183\155\129\152\144\212\154\155\128\212\134\145\135\155\152\130\145\212\128\156\145\212\145\133\129\157\132\132\145\144\212\153\157\134\134\155\134"), _D("\131\149\134\154"), 2.5)
		return
	end
	_lIIIl11lllllI():WaitForChild(_D("\184\155\155\159\189\154\128\155\188\149\129\154\128\145\144\185\157\134\134\155\134")):FireServer(_1IllllI1lI1)
	_1I11lIIllII(_D("\188\149\129\154\128\145\144\212\185\157\134\134\155\134"), _D("\184\155\155\159\157\154\147\212\157\154\128\155\212\128\156\145\212\153\157\134\134\155\134\218\218\218"), _D("\157\154\146\155"), 2.5)
	task.wait(3)
	_lIIIl11lllllI():WaitForChild(_D("\188\149\129\154\128\145\144\185\157\134\134\155\134\177\154\144\145\144")):FireServer()
	_1I11lIIllII(_D("\188\149\129\154\128\145\144\212\185\157\134\134\155\134"), _D("\178\157\154\157\135\156\145\144"), _D("\135\129\151\151\145\135\135"), 2)
end


local function _IlIl1I11l111II(_Ill1l1I1lIl1lI1)
	local _1l111ll1I1Ill = {}
	local _lII1I11Il = false
	local function _I111IIl1IlII1(_llllIIlll1lI1)
		if _lII1I11Il and _llllIIlll1lI1:IsA(_D("\167\155\129\154\144")) and _1l111ll1I1Ill[_llllIIlll1lI1] == nil then
			local _l1lI1I11Il11ll1, _II1ll1llI1Il1II = pcall(_Ill1l1I1lIl1lI1, _llllIIlll1lI1)
			if _l1lI1I11Il11ll1 and _II1ll1llI1Il1II then
				_1l111ll1I1Ill[_llllIIlll1lI1] = _llllIIlll1lI1.Volume
				_llllIIlll1lI1.Volume = 0
			end
		end
	end
	_1I111I1ll(workspace.DescendantAdded:Connect(_I111IIl1IlII1))
	local _1ll1IIII1Il = {}
	function _1ll1IIII1Il.set(v)
		_lII1I11Il = v
		if v then
			for _, _llllIIlll1lI1 in ipairs(game:GetDescendants()) do
				_I111IIl1IlII1(_llllIIlll1lI1)
			end
		else
			for _l1lI1IIll, vol in pairs(_1l111ll1I1Ill) do
				pcall(function() if _l1lI1IIll and _l1lI1IIll.Parent then _l1lI1IIll.Volume = vol end end)
			end
			table.clear(_1l111ll1I1Ill)
		end
	end
	return _1ll1IIII1Il
end
local _1l1Ill1I1IIlll = _IlIl1I11l111II(function(_l1lI1IIll)
	local n = string.lower(_l1lI1IIll.Name)
	return _l1lI1IIll:IsDescendantOf(game:GetService(_D("\167\155\129\154\144\167\145\134\130\157\151\145")))
		or string.find(n, _D("\153\129\135\157\151"), 1, true)
		or string.find(n, _D("\128\156\145\153\145"), 1, true)
		or string.find(n, _D("\149\153\150\157\145\154\128"), 1, true)
		or string.find(n, _D("\150\147\153"), 1, true)
end)
local _1lll1llII1l1l = _IlIl1I11l111II(function(_l1lI1IIll)
	if S.Ghost and _l1lI1IIll:IsDescendantOf(S.Ghost) then return true end
	local n = string.lower(_l1lI1IIll.Name)
	return string.find(n, _D("\156\129\154\128"), 1, true)
		or string.find(n, _D("\147\156\155\135\128"), 1, true)
		or string.find(n, _D("\147\134\155\131\152"), 1, true)
		or string.find(n, _D("\135\151\134\145\149\153"), 1, true)
		or string.find(n, _D("\146\155\155\128\135\128\145\132"), 1, true)
		or string.find(n, _D("\135\151\134\149\128\151\156"), 1, true)
		or string.find(n, _D("\150\134\145\149\128\156"), 1, true)
end)
local _II111Il1lIII1 = _IlIl1I11l111II(function() return true end)
S.UnmuteAllOnClose = function()
	_1l1Ill1I1IIlll.set(false)
	_1lll1llII1l1l.set(false)
	_II111Il1lIII1.set(false)
end


local function _llI1I111l()
	local _l1lI1I11Il11ll1, _IIlII1III1Il1 = pcall(function()
		local _1l1I1IlllIl = workspace:WaitForChild(_D("\185\149\132")):WaitForChild(_D("\166\155\155\153\135")):WaitForChild(_D("\182\149\135\145\212\183\149\153\132")):WaitForChild(_D("\164\145\147\150\155\149\134\144"))
		local _1II11lIlll11I1 = _1l1I1IlllIl:FindFirstChild(_D("\161\154\157\155\154"))
		local _Ill11Il11l = plr.Character
		if _1II11lIlll11I1 and _Ill11Il11l and _Ill11Il11l:FindFirstChild(_D("\188\129\153\149\154\155\157\144\166\155\155\128\164\149\134\128")) then
			_Ill11Il11l.HumanoidRootPart.CFrame = _1II11lIlll11I1.CFrame + Vector3.new(0, 3, 0)
		end
	end)
	if not _l1lI1I11Il11ll1 then warn(_D("\188\129\154\128\212\160\164\212\146\149\157\152\145\144\206"), _IIlII1III1Il1) end
end

local function _1ll11lIll11(_111IIII1I1lIIII, _l1l1IIlll111Il)
	local _lI1IlI111l1Il = _111IIII1I1lIIII.CFrame:PointToObjectSpace(_l1l1IIlll111Il)
	return math.abs(_lI1IlI111l1Il.X) <= _111IIII1I1lIIII.Size.X / 2 and math.abs(_lI1IlI111l1Il.Y) <= _111IIII1I1lIIII.Size.Y / 2 and math.abs(_lI1IlI111l1Il.Z) <= _111IIII1I1lIIII.Size.Z / 2
end
local function _lII1l1llllIIIl1(_l1l1IIlll111Il)
	if not S.Rooms then return nil end
	for _, room in ipairs(S.Rooms:GetChildren()) do
		for _, _111IIII1I1lIIII in ipairs(room:GetDescendants()) do
			if _111IIII1I1lIIII:IsA(_D("\182\149\135\145\164\149\134\128")) and _1ll11lIll11(_111IIII1I1lIIII, _l1l1IIlll111Il) then
				return room.Name
			end
		end
	end
	return nil
end
local function _11l111II1Ill()
	if not S.Ghost then
		_1I11lIIllII(_D("\186\155\128\212\134\145\149\144\141"), _D("\160\156\145\212\134\155\129\154\144\212\156\149\135\154\211\128\212\135\128\149\134\128\145\144\212\141\145\128"), _D("\131\149\134\154"), 2.5)
		return
	end
	local _ll1I1IlllI1I = plr.Character
	if _ll1I1IlllI1I then _ll1I1IlllI1I:PivotTo(S.Ghost:GetPivot()) end
end

local function _I1I1llll11IlllI()
	local _Ill11Il11l = plr.Character
	local _1I1llIlIlI = _Ill11Il11l and _Ill11Il11l:FindFirstChild(_D("\188\129\153\149\154\155\157\144\166\155\155\128\164\149\134\128"))
	if not _1I1llIlIlI then return nil end
	local _l111III1l1ll, _l1lII11ll = nil, math.huge
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA(_D("\185\155\144\145\152")) or v:IsA(_D("\182\149\135\145\164\149\134\128")) then
			local n = string.lower(v.Name)
			if string.find(n, _D("\151\152\155\135\145\128"), 1, true) or string.find(n, _D("\152\155\151\159\145\134"), 1, true) or string.find(n, _D("\131\149\134\144\134\155\150\145"), 1, true) or string.find(n, _D("\156\157\144\157\154\147"), 1, true) then
				local _l1lI1I11Il11ll1, _l1l1IIlll111Il = pcall(function()
					return v:IsA(_D("\185\155\144\145\152")) and v:GetPivot().Position or v.Position
				end)
				if _l1lI1I11Il11ll1 and _l1l1IIlll111Il then
					local d = (_l1l1IIlll111Il - _1I1llIlIlI.Position).Magnitude
					if d < _l1lII11ll then _l1lII11ll, _l111III1l1ll = d, v end
				end
			end
		end
	end
	return _l111III1l1ll
end
local function _lllIl1llI()
	local _I111Il11I1lll = _I1I1llll11IlllI()
	local _Ill11Il11l = plr.Character
	if not (_I111Il11I1lll and _Ill11Il11l) then return false end
	local _l1lI1I11Il11ll1 = pcall(function()
		local _II1l1IIl1Il = _I111Il11I1lll:IsA(_D("\185\155\144\145\152")) and _I111Il11I1lll:GetPivot() or _I111Il11I1lll.CFrame
		_Ill11Il11l:PivotTo(_II1l1IIl1Il + Vector3.new(0, 2, 0))
	end)
	return _l1lI1I11Il11ll1
end


local function _1l111lI111l(_lII1I11Il)
	local Rooms = workspace:WaitForChild(_D("\185\149\132")):WaitForChild(_D("\166\155\155\153\135"))
	for _, Room in pairs(Rooms:GetChildren()) do
		if Room:GetAttribute(_D("\184\157\147\156\128\135\187\154")) ~= _lII1I11Il then
			_lIIIl11lllllI():WaitForChild(_D("\161\135\145\184\157\147\156\128\167\131\157\128\151\156")):FireServer(Room)
		end
	end
end
local function _1IIIlI1l111l1lI()
	S.LightsOn = not S.LightsOn
	_1l111lI111l(S.LightsOn)
end

local function _IIll1IIIll()
	local _I1l1IllIlI11l1 = {
		_D("\181\134\145\212\141\155\129\212\146\149\134\212\149\131\149\141\203"), _D("\181\134\145\212\141\155\129\212\154\145\149\134\203"), _D("\163\156\145\134\145\212\149\134\145\212\141\155\129\203"), _D("\163\156\149\128\212\144\155\212\141\155\129\212\131\149\154\128\203"),
		_D("\163\156\145\154\212\144\157\144\212\141\155\129\212\151\134\155\135\135\212\155\130\145\134\203"), _D("\181\134\145\212\141\155\129\212\157\154\212\128\156\145\212\134\155\155\153\212\131\157\128\156\212\153\145\203"), _D("\176\155\212\141\155\129\212\131\149\154\128\212\129\135\212\128\155\212\152\145\149\130\145\203"),
		_D("\163\156\145\154\212\144\157\144\212\141\155\129\212\132\149\135\135\212\149\131\149\141\203"), _D("\163\156\149\128\212\157\135\212\141\155\129\134\212\147\155\149\152\203"), _D("\163\156\141\212\149\134\145\212\141\155\129\212\156\145\134\145\203"),
		_D("\188\155\131\212\152\155\154\147\212\149\147\155\212\144\157\144\212\141\155\129\212\144\157\145\203"), _D("\189\135\212\128\156\145\134\145\212\149\212\147\156\155\135\128\212\156\145\134\145\203")
	}
	_lIIIl11lllllI():WaitForChild(_D("\181\135\159\167\132\157\134\157\128\182\155\140\178\134\155\153\161\189")):FireServer(_I1l1IllIlI11l1[math.random(1, #_I1l1IllIlI11l1)])
end
local _l1l111ll1l11lI = tick()
local function _l1III1llll1lll1()
	if not S.Ghost or not S.AutoSpiritBox then return end
	local _ll1I1IlllI1I = plr.Character
	if not _ll1I1IlllI1I then return end
	local _1I1Il111ll1Il = S.Ghost:GetAttribute(_D("\188\129\154\128\157\154\147")) == true
	
	if tick() - _l1l111ll1l11lI > 0.8 then
		_l1l111ll1l11lI = tick()
		if _1I1Il111ll1Il then
			_llI1I111l()
			return
		end
		
		_ll1I1IlllI1I:PivotTo(S.Ghost:GetPivot() * CFrame.new(0, 0, 10))
		task.wait(0.1)
		
		local _1I1IIIlI1l1lII1, _1lIIII11l1 = _llllII1Illll(_D("\167\132\157\134\157\128\212\182\155\140"))
		if not _1I1IIIlI1l1lII1 then
			local _l11l1IIIIII, _lllIl1IIl = _l11l1l11I(_D("\167\132\157\134\157\128\212\182\155\140"))
			if _l11l1IIIIII and _lllIl1IIl then
				_l111l1IIIlIllI1(_lllIl1IIl)
				task.wait(0.35)
				_IlIl1l1l1I()
				task.wait(0.5)
				_1I1IIIlI1l1lII1, _1lIIII11l1 = _llllII1Illll(_D("\167\132\157\134\157\128\212\182\155\140"))
				if _1I1IIIlI1l1lII1 then
					_I1l1I11ll1ll1(_1lIIII11l1)
					task.wait(0.5)
					_IIll1IIIll()
				end
			end
		else
			_I1l1I11ll1ll1(_1lIIII11l1)
			task.wait(0.35)
			_IlIl1l1l1I()
			task.wait(0.35)
			_IIll1IIIll()
		end
	end
end




local function _l1lIlI1Il1IIlll()
	local _ll11lll11ll1, _1llll111l1ll = 100, nil
	if not S.Rooms then return _ll11lll11ll1, _1llll111l1ll end
	for _, room in ipairs(S.Rooms:GetChildren()) do
		local t = room:GetAttribute(_D("\160\145\153\132\145\134\149\128\129\134\145"))
		if t ~= nil and t < _ll11lll11ll1 then
			_ll11lll11ll1 = t
			_1llll111l1ll = room
		end
	end
	return _ll11lll11ll1, _1llll111l1ll
end

local function _11lIlI1II1Illl()
	local _l11I11llI = workspace:FindFirstChild(_D("\188\149\154\144\132\134\157\154\128\135"))
	local _l1IllllIlIl11l = _l11I11llI or workspace
	for _, _llI1ll1Il1 in ipairs(_l1IllllIlIl11l:GetDescendants()) do
		if _llI1ll1Il1:IsA(_D("\182\149\135\145\164\149\134\128")) and (
			_llI1ll1Il1.Name == _D("\188\149\154\144\132\134\157\154\128\197") or _llI1ll1Il1.Name == _D("\188\149\154\144\132\134\157\154\128\198") or
			_llI1ll1Il1.Name == _D("\178\155\155\128\132\134\157\154\128") or _llI1ll1Il1.Name == _D("\178\155\155\128\132\134\157\154\128\197")
		) then
			return true
		end
	end
	return false
end

local function _l111lI1I11Il()
	for _, _llI1ll1Il1 in ipairs(workspace:GetDescendants()) do
		if _llI1ll1Il1:IsA(_D("\182\149\135\145\164\149\134\128")) and _llI1ll1Il1.Name == _D("\179\156\155\135\128\187\134\150") then
			return true
		end
	end
	return false
end

local _II111IlIl1I11I = nil
local function _Il1I1Il1I11ll11()
	if not _II111IlIl1I11I or not _II111IlIl1I11I.Parent then
		_II111IlIl1I11I = workspace:FindFirstChild(_D("\189\154\144\157\151\149\128\155\134\135"), true)
	end
	local _I11lI1l1lll1 = 0
	if _II111IlIl1I11I then
		for _, v in pairs(_II111IlIl1I11I:GetChildren()) do
			local _11I1III11l = tonumber(v.Name)
			if v:IsA(_D("\182\149\135\145\164\149\134\128")) and v.Material == Enum.Material.Neon and _11I1III11l and _11I1III11l > _I11lI1l1lll1 then
				_I11lI1l1lll1 = _11I1III11l
			end
		end
	end
	return _I11lI1l1lll1
end

local function _IllIIIll1()
	local _ll1l111I1I = workspace:FindFirstChild(_D("\189\128\145\153\135"))
	for _, _llI1ll1Il1 in ipairs(_ll1l111I1I and _ll1l111I1I:GetDescendants() or {}) do
		if _llI1ll1Il1:IsA(_D("\182\149\135\145\164\149\134\128")) and _llI1ll1Il1.Name == _D("\164\145\128\149\152\135") and _llI1ll1Il1.Color == Color3.new(0, 0, 0) then
			return true
		end
	end
	return false
end

local function _Il1I1IlIl()
	local _ll1l111I1I = workspace:FindFirstChild(_D("\189\128\145\153\135"))
	for _, _llI1ll1Il1 in ipairs(_ll1l111I1I and _ll1l111I1I:GetDescendants() or {}) do
		if _llI1ll1Il1:IsA(_D("\176\145\151\149\152")) then
			local _1II11l1lIIl1 = _llI1ll1Il1:FindFirstAncestorWhichIsA(_D("\185\155\144\145\152"))
			if _1II11l1lIIl1 and _1II11l1lIIl1:GetAttribute(_D("\189\128\145\153\186\149\153\145")) == _D("\167\132\157\134\157\128\212\182\155\155\159") and _llI1ll1Il1.Texture ~= _D("") then
				return true
			end
		end
	end
	return false
end

local function _1lIIl1III()
	local _111llll1I1IIIl1 = plr.PlayerGui:FindFirstChild(_D("\167\129\150\128\157\128\152\145\135"))
	local _1IIIl11Ill1 = _111llll1I1IIIl1 and _111llll1I1IIIl1:FindFirstChild(_D("\188\155\152\144\145\134"))
	local _1llIlIIIII1Il = _1IIIl11Ill1 and _1IIIl11Ill1:FindFirstChild(_D("\160\145\140\128\184\149\150\145\152"))
	return _1llIlIIIII1Il ~= nil and #_1llIlIIIII1Il.Text:gsub(_D("\209\135\223"), _D("")) >= 3
end

local _1Il111IIII = {
	Handprints = _D("\164\134\157\154\128\135"),
	SpiritBox = _D("\182\155\140"),
	GhostOrb = _D("\187\134\150"),
	GhostWriting = _D("\163\134\157\128\157\154\147"),
	Laser = _D("\184\149\135\145\134"),
	Wither = _D("\163\157\128\156\145\134"),
	EMF = _D("\177\185\178"),
	Temperature = _D("\160\145\153\132")
}
local _11III1llllIl1 = {
	{ Name = _D("\181\135\131\149\154\147"), Ev = {_D("\163\157\128\156\145\134"), _D("\160\145\153\132\145\134\149\128\129\134\145"), _D("\177\185\178")} },
	{ Name = _D("\182\149\154\135\156\145\145"), Ev = {_D("\188\149\154\144\132\134\157\154\128\135"), _D("\179\156\155\135\128\187\134\150"), _D("\184\149\135\145\134")} },
	{ Name = _D("\176\145\153\155\154"), Ev = {_D("\188\149\154\144\132\134\157\154\128\135"), _D("\179\156\155\135\128\163\134\157\128\157\154\147"), _D("\160\145\153\132\145\134\149\128\129\134\145")} },
	{ Name = _D("\176\129\152\152\149\156\149\154"), Ev = {_D("\163\157\128\156\145\134"), _D("\167\132\157\134\157\128\182\155\140"), _D("\188\149\154\144\132\134\157\154\128\135")} },
	{ Name = _D("\176\141\150\150\129\159"), Ev = {_D("\163\157\128\156\145\134"), _D("\179\156\155\135\128\187\134\150"), _D("\184\149\135\145\134")} },
	{ Name = _D("\177\154\128\157\128\141"), Ev = {_D("\167\132\157\134\157\128\182\155\140"), _D("\188\149\154\144\132\134\157\154\128\135"), _D("\184\149\135\145\134")} },
	{ Name = _D("\179\156\155\129\152"), Ev = {_D("\167\132\157\134\157\128\182\155\140"), _D("\160\145\153\132\145\134\149\128\129\134\145"), _D("\179\156\155\135\128\187\134\150")} },
	{ Name = _D("\191\145\134\145\135"), Ev = {_D("\163\157\128\156\145\134"), _D("\179\156\155\135\128\163\134\157\128\157\154\147"), _D("\160\145\153\132\145\134\149\128\129\134\145")} },
	{ Name = _D("\184\145\130\157\149\128\156\149\154"), Ev = {_D("\179\156\155\135\128\187\134\150"), _D("\179\156\155\135\128\163\134\157\128\157\154\147"), _D("\188\149\154\144\132\134\157\154\128\135")} },
	{ Name = _D("\186\157\147\156\128\153\149\134\145"), Ev = {_D("\177\185\178"), _D("\167\132\157\134\157\128\182\155\140"), _D("\179\156\155\135\128\187\134\150")} },
	{ Name = _D("\187\154\157"), Ev = {_D("\177\185\178"), _D("\160\145\153\132\145\134\149\128\129\134\145"), _D("\184\149\135\145\134")} },
	{ Name = _D("\164\156\149\154\128\155\153"), Ev = {_D("\167\132\157\134\157\128\182\155\140"), _D("\188\149\154\144\132\134\157\154\128\135"), _D("\184\149\135\145\134")} },
	{ Name = _D("\166\149\130\149\147\145\134"), Ev = {_D("\179\156\155\135\128\163\134\157\128\157\154\147"), _D("\167\132\157\134\157\128\182\155\140"), _D("\177\185\178")} },
	{ Name = _D("\166\145\130\145\154\149\154\128"), Ev = {_D("\179\156\155\135\128\187\134\150"), _D("\179\156\155\135\128\163\134\157\128\157\154\147"), _D("\160\145\153\132\145\134\149\128\129\134\145")} },
	{ Name = _D("\167\156\149\144\155\131"), Ev = {_D("\177\185\178"), _D("\179\156\155\135\128\163\134\157\128\157\154\147"), _D("\184\149\135\145\134")} },
	{ Name = _D("\167\157\134\145\154"), Ev = {_D("\163\157\128\156\145\134"), _D("\167\132\157\134\157\128\182\155\140"), _D("\179\156\155\135\128\187\134\150")} },
	{ Name = _D("\167\159\157\154\131\149\152\159\145\134"), Ev = {_D("\160\145\153\132\145\134\149\128\129\134\145"), _D("\179\156\155\135\128\163\134\157\128\157\154\147"), _D("\167\132\157\134\157\128\182\155\140")} },
	{ Name = _D("\167\132\145\151\128\145\134"), Ev = {_D("\177\185\178"), _D("\160\145\153\132\145\134\149\128\129\134\145"), _D("\184\149\135\145\134")} },
	{ Name = _D("\167\132\157\134\157\128"), Ev = {_D("\177\185\178"), _D("\167\132\157\134\157\128\182\155\140"), _D("\179\156\155\135\128\163\134\157\128\157\154\147")} },
	{ Name = _D("\160\156\145\212\163\157\135\132"), Ev = {_D("\179\156\155\135\128\163\134\157\128\157\154\147"), _D("\163\157\128\156\145\134"), _D("\160\145\153\132\145\134\149\128\129\134\145")} },
	{ Name = _D("\161\153\150\134\149"), Ev = {_D("\179\156\155\135\128\187\134\150"), _D("\184\149\135\145\134"), _D("\188\149\154\144\132\134\157\154\128\135")} },
	{ Name = _D("\162\145\135\132\145\134"), Ev = {_D("\179\156\155\135\128\163\134\157\128\157\154\147"), _D("\188\149\154\144\132\134\157\154\128\135"), _D("\163\157\128\156\145\134")} },
	{ Name = _D("\162\145\140"), Ev = {_D("\177\185\178"), _D("\184\149\135\145\134"), _D("\163\157\128\156\145\134")} },
	{ Name = _D("\163\145\154\144\157\147\155"), Ev = {_D("\179\156\155\135\128\187\134\150"), _D("\179\156\155\135\128\163\134\157\128\157\154\147"), _D("\184\149\135\145\134")} },
	{ Name = _D("\163\134\149\157\128\156"), Ev = {_D("\177\185\178"), _D("\167\132\157\134\157\128\182\155\140"), _D("\184\149\135\145\134")} },
}
local _lIIIIlII1 = {}

S.GhostLabelSets = {}
local function _lIlII1IIll(_11II11Il11l1, _1Illl1lIlI1III, onResize)
	local _1l11l11I1 = Instance.new(_D("\167\151\134\155\152\152\157\154\147\178\134\149\153\145"))
	_1l11l11I1.Parent = _11II11Il11l1
	_1l11l11I1.BackgroundTransparency = 1
	_1l11l11I1.BorderSizePixel = 0
	_1l11l11I1.Size = UDim2.new(1, 0, 1, 0)
	_1l11l11I1.ScrollBarThickness = 3
	_1l11l11I1.ScrollBarImageColor3 = T.Tx3
	_1l11l11I1.AutomaticCanvasSize = Enum.AutomaticSize.Y
	_1l11l11I1.CanvasSize = UDim2.new(0, 0, 0, 0)
	local _I11Il11II1I = Instance.new(_D("\161\189\184\157\135\128\184\149\141\155\129\128"))
	_I11Il11II1I.Parent = _1l11l11I1
	_I11Il11II1I.SortOrder = Enum.SortOrder.LayoutOrder
	_I11Il11II1I.Padding = UDim.new(0, 3)
	local labels = {}
	for i, g in ipairs(_11III1llllIl1) do
		local row = Instance.new(_D("\178\134\149\153\145"))
		row.Name = g.Name
		row.Parent = _1l11l11I1
		row.LayoutOrder = i
		row.BackgroundTransparency = 1
		row.Size = UDim2.new(1, 0, 0, _1Illl1lIlI1III or 18)
		local dot = Instance.new(_D("\178\134\149\153\145"))
		dot.Name = _D("\176\155\128")
		dot.Parent = row
		dot.AnchorPoint = Vector2.new(0, 0.5)
		dot.Position = UDim2.new(0, 2, 0.5, 0)
		dot.Size = UDim2.new(0, 7, 0, 7)
		dot.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		dot.BorderSizePixel = 0
		Corner(dot, 4)
		local _IllllIllI = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
		_IllllIllI.Name = _D("\184\149\150\145\152")
		_IllllIllI.Parent = row
		_IllllIllI.Position = UDim2.new(0, 16, 0, 0)
		_IllllIllI.Size = UDim2.new(1, -16, 1, 0)
		_IllllIllI.BackgroundTransparency = 1
		_IllllIllI.RichText = true
		_IllllIllI.Font = F
		_IllllIllI.TextSize = 13
		_IllllIllI.Text = g.Name
		_IllllIllI.TextColor3 = Color3.fromRGB(220, 220, 220)
		_IllllIllI.TextStrokeColor3 = Color3.new(0, 0, 0)
		_IllllIllI.TextStrokeTransparency = 0.6
		_IllllIllI.TextTruncate = Enum.TextTruncate.AtEnd
		_IllllIllI.TextXAlignment = Enum.TextXAlignment.Left
		labels[g.Name] = { label = _IllllIllI, dot = dot, row = row }
	end
	table.insert(S.GhostLabelSets, { labels = labels, onResize = onResize })
	return _1l11l11I1, labels
end




local _lII11l11lI1l1lI, _I1lIl11lI, _11I1IlIIIll1l1l, _llIllIIl1I1
do
	local page = Pages[_D("\177\130\157\144\145\154\151\145")]

	local _lIlIlIl1l11l1I = _IlIlIlIll11I1(page, _D("\177\130\157\144\145\154\151\145\212\164\134\155\147\134\145\135\135"), 1)
	local _IlII1ll1IlII1 = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_IlII1ll1IlII1.Parent = _lIlIlIl1l11l1I
	_IlII1ll1IlII1.LayoutOrder = 1
	_IlII1ll1IlII1.BackgroundTransparency = 1
	_IlII1ll1IlII1.Size = UDim2.new(1, 0, 0, 20)
	_IlII1ll1IlII1.Font = FM
	_IlII1ll1IlII1.TextSize = 15
	_IlII1ll1IlII1.TextColor3 = T.White
	_IlII1ll1IlII1.TextXAlignment = Enum.TextXAlignment.Left
	_IlII1ll1IlII1.Text = _D("\196\212\219\212\199\212\145\130\157\144\145\154\151\145\212\151\155\154\146\157\134\153\145\144")
	local _llIIllIl1l11II1 = Instance.new(_D("\178\134\149\153\145"))
	_llIIllIl1l11II1.Parent = _lIlIlIl1l11l1I
	_llIIllIl1l11II1.LayoutOrder = 2
	_llIIllIl1l11II1.Size = UDim2.new(1, 0, 0, 8)
	_llIIllIl1l11II1.BackgroundColor3 = T.TgOff
	_llIIllIl1l11II1.BorderSizePixel = 0
	Corner(_llIIllIl1l11II1, 4)
	local _1I1I11ll111Il = Instance.new(_D("\178\134\149\153\145"))
	_1I1I11ll111Il.Parent = _llIIllIl1l11II1
	_1I1I11ll111Il.Size = UDim2.new(0, 0, 1, 0)
	_1I1I11ll111Il.BackgroundColor3 = T.Accent
	_1I1I11ll111Il.BorderSizePixel = 0
	Corner(_1I1I11ll111Il, 4)
	Grad(_1I1I11ll111Il, Color3.fromRGB(100, 100, 100), Color3.fromRGB(255, 255, 255), 0)
	_llIllIIl1I1 = {
		set = function(_I1IIl11lI1, _1l1I1I1ll)
			_IlII1ll1IlII1.Text = tostring(_I1IIl11lI1) .. _D("\212\219\212") .. tostring(_1l1I1I1ll) .. _D("\212\145\130\157\144\145\154\151\145\212\151\155\154\146\157\134\153\145\144")
			TweenService:Create(_1I1I11ll111Il, TweenInfo.new(0.25), { Size = UDim2.new(_I1IIl11lI1 / _1l1I1I1ll, 0, 1, 0) }):Play()
		end
	}

	local _ll1l11I1I = _IlIlIlIll11I1(page, _D("\184\157\130\145\212\166\145\149\144\155\129\128\135"), 2)
	_lII11l11lI1l1lI = {
		Handprints = _l11I11llllI(_ll1l11I1I, _D("\188\149\154\144\132\134\157\154\128\135"), 1),
		SpiritBox = _l11I11llllI(_ll1l11I1I, _D("\167\132\157\134\157\128\212\182\155\140"), 2),
		GhostOrb = _l11I11llllI(_ll1l11I1I, _D("\179\156\155\135\128\212\187\134\150"), 3),
		GhostWriting = _l11I11llllI(_ll1l11I1I, _D("\179\156\155\135\128\212\163\134\157\128\157\154\147"), 4),
		Laser = _l11I11llllI(_ll1l11I1I, _D("\184\149\135\145\134\212\164\134\155\158\145\151\128\155\134"), 5),
		Wither = _l11I11llllI(_ll1l11I1I, _D("\163\157\128\156\145\134"), 6),
		EMF = _l11I11llllI(_ll1l11I1I, _D("\177\185\178\212\184\145\130\145\152"), 7),
		Temperature = _l11I11llllI(_ll1l11I1I, _D("\160\145\153\132\145\134\149\128\129\134\145"), 8),
	}

	local info = _IlIlIlIll11I1(page, _D("\179\156\155\135\128\212\210\212\166\155\129\154\144\212\189\154\146\155"), 3)
	_I1lIl11lI = {
		Ghost = _lI1llIllI(info, _D("\179\156\155\135\128"), 1),
		GhostRoom = _lI1llIllI(info, _D("\179\156\155\135\128\211\135\212\166\155\155\153"), 2),
		YourRoom = _lI1llIllI(info, _D("\173\155\129\134\212\166\155\155\153"), 3),
		Difficulty = _lI1llIllI(info, _D("\176\157\146\146\157\151\129\152\128\141"), 4),
		Photos = _lI1llIllI(info, _D("\164\156\155\128\155\135\212\160\149\159\145\154"), 5),
		HuntsDetected = _lI1llIllI(info, _D("\188\129\154\128\135\212\176\145\128\145\151\128\145\144"), 6),
		Round = _lI1llIllI(info, _D("\166\155\129\154\144\212\167\128\149\128\129\135"), 7),
	}

	local _Il1lIIIl1lIl11 = _IlIlIlIll11I1(page, _D("\179\156\155\135\128\212\179\129\145\135\135\145\134"), 4)
	local _IllllIllI = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_IllllIllI.Parent = _Il1lIIIl1lIl11
	_IllllIllI.LayoutOrder = 1
	_IllllIllI.BackgroundTransparency = 1
	_IllllIllI.Size = UDim2.new(1, 0, 0, 34)
	_IllllIllI.Font = FM
	_IllllIllI.TextSize = 14
	_IllllIllI.TextWrapped = true
	_IllllIllI.TextXAlignment = Enum.TextXAlignment.Left
	_IllllIllI.TextYAlignment = Enum.TextYAlignment.Top
	_IllllIllI.TextColor3 = T.Tx2
	_IllllIllI.Text = _D("\164\155\135\135\157\150\152\145\212\147\156\155\135\128\135\206\212\154\155\212\145\130\157\144\145\154\151\145\212\141\145\128")
	_11I1IlIIIll1l1l = _IllllIllI

	local _1Il11l11Il = Instance.new(_D("\178\134\149\153\145"))
	_1Il11l11Il.Parent = _Il1lIIIl1lIl11
	_1Il11l11Il.LayoutOrder = 2
	_1Il11l11Il.BackgroundTransparency = 1
	_1Il11l11Il.Size = UDim2.new(1, 0, 0, 240)
	_lIlII1IIll(_1Il11l11Il, 18)

	_Il1111lI1(_Il1lIIIl1lIl11, _D("\166\145\135\145\128\212\166\155\129\154\144\212\176\149\128\149"), function()
		if S.ResetRoundState then S.ResetRoundState() end
		_1I11lIIllII(_D("\177\130\157\144\145\154\151\145"), _D("\166\155\129\154\144\212\144\149\128\149\212\134\145\135\145\128"), _D("\157\154\146\155"), 2)
	end, 3)
end


local _Ill1I1IIllI = nil
task.spawn(function()
	local _1llIII11Il1l1l = false
	while true do
		local g = workspace:FindFirstChild(_D("\179\156\155\135\128"))
		local _l11lIllIIll1II = workspace:FindFirstChild(_D("\185\149\132")) and workspace.Map:FindFirstChild(_D("\166\155\155\153\135"))
		if g and _l11lIllIIll1II then
			if g ~= _Ill1I1IIllI then
				_Ill1I1IIllI = g
				if S.ResetRoundState then S.ResetRoundState() end
				if _1llIII11Il1l1l then
					_1I11lIIllII(_D("\166\155\129\154\144\212\146\155\129\154\144"), _D("\177\130\157\144\145\154\151\145\212\128\134\149\151\159\157\154\147\212\157\135\212\154\155\131\212\149\151\128\157\130\145"), _D("\135\129\151\151\145\135\135"), 3)
				end
				if S.GhostEspOn and S.RecreateGhostEsp then
					S.RecreateGhostEsp()
				end
			end
			S.Ghost = g
			S.GhostPart = g:FindFirstChildWhichIsA(_D("\182\149\135\145\164\149\134\128"))
			S.Rooms = _l11lIllIIll1II
			S.Ready = true
			_1llIII11Il1l1l = false
		else
			if S.Ready then
				S.Ready = false
				S.Ghost = nil
				S.GhostPart = nil
				_Ill1I1IIllI = nil
				if S.DestroyGhostEsp then S.DestroyGhostEsp() end
				_1I11lIIllII(_D("\166\155\129\154\144\212\145\154\144\145\144"), _D("\163\149\157\128\157\154\147\212\146\155\134\212\128\156\145\212\154\145\140\128\212\134\155\129\154\144\218\218\218"), _D("\153\129\128\145\144"), 3)
			end
			if not _1llIII11Il1l1l then
				_1llIII11Il1l1l = true
				_I1lIl11lI.Round.set(_D("\131\149\157\128\157\154\147\212\146\155\134\212\134\155\129\154\144\218\218\218"), T.Warn)
			end
		end
		task.wait(1)
	end
end)

_1I111I1ll(workspace.DescendantAdded:Connect(function(_1IIIlII11l)
	if _1IIIlII11l:IsA(_D("\167\155\129\154\144")) and _1IIIlII11l.Name == _D("\188\129\154\128") then
		S.HuntsCount = S.HuntsCount + 1
		local _IlIIl1Ill1 = (S.AutoHide and _D("\181\129\128\155\217\156\157\144\145\212\157\135\212\134\129\154\154\157\154\147")) or (S.EscapeHunt and _D("\181\129\128\155\217\145\135\151\149\132\145\212\157\135\212\134\129\154\154\157\154\147")) or _D("\188\157\144\145\212\155\134\212\150\134\145\149\159\212\152\157\154\145\212\155\146\212\135\157\147\156\128")
		_1I11lIIllII(_D("\179\188\187\167\160\212\189\167\212\188\161\186\160\189\186\179"), _IlIIl1Ill1, _D("\144\149\154\147\145\134"), 4)
		if S.AutoHide then
			if not _lllIl1llI() and S.EscapeHunt then
				_llI1I111l()
			end
		elseif S.EscapeHunt then
			_llI1I111l()
		end
	end
end))

local _ll1llI11lI1Ill
local function _11111lIII1lI()
	if _ll1llI11lI1Ill then return end
	_ll1llI11lI1Ill = mkEspTag(S.Ghost, _D("\179\188\187\167\160"), Color3.fromRGB(255, 255, 255), { fill = 0.75 })
end
S.DestroyGhostEsp = function()
	if _ll1llI11lI1Ill then _llllIlIllII(_ll1llI11lI1Ill); _ll1llI11lI1Ill = nil end
end
S.RecreateGhostEsp = function()
	S.DestroyGhostEsp()
	if S.Ghost then _11111lIII1lI() end
end


local _I11I11Ill11IlII = 100
local _IIII11llIllIl = nil
local _lIIIIlIIIlI1 = 1
local _llIIIll1llII = tick()
local _lII1ll1l11 = tick()
local _1I1l1lII111lI = false
_1I111I1ll(_lII111IIIIllI.Heartbeat:Connect(function()
	_l1III1llll1lll1()
	if tick() - _lII1ll1l11 > S.CheckSpeed then
		_lII1ll1l11 = tick()
		if S.UpdatePlrEsp then S.UpdatePlrEsp() end
		local _I1lI11I1llII1I = plr:GetAttribute(_D("\177\154\145\134\147\141"))
		if _I1lI11I1llII1I then
			if _I1lI11I1llII1I <= 20 and not _1I1l1lII111lI then
				_1I1l1lII111lI = true
				_1I11lIIllII(_D("\184\155\131\212\177\154\145\134\147\141"), _D("\177\154\145\134\147\141\206\212") .. tostring(math.floor(_I1lI11I1llII1I)) .. _D("\209"), _D("\131\149\134\154"), 3.5)
			elseif _I1lI11I1llII1I > 35 then
				_1I1l1lII111lI = false
			end
		end
	end
	if not S.Ready then return end
	if tick() - _llIIIll1llII <= S.CheckSpeed then return end
	_llIIIll1llII = tick()

	_I1lIl11lI.Difficulty.set(tostring(workspace:GetAttribute(_D("\176\157\146\146\157\151\129\152\128\141")) or _D("\161\154\159\154\155\131\154")))
	_I1lIl11lI.Photos.set(tostring(workspace:GetAttribute(_D("\164\156\155\128\155\135\160\149\159\145\154")) or 0) .. _D("\219\194"))

	local _ll11lll11ll1, _1llll111l1ll = _l1lIlI1Il1IIlll()
	local _I1lII1lIlI = _11lIlI1II1Illl()
	local _IIlIll1lIIII1l = _l111lI1I11Il()
	local _11II1I1I1l = _Il1I1Il1I11ll11()
	local _IlI1ll1ll11II11 = _IllIIIll1()
	local _11IIIl1IIII1 = _1lIIl1III()
	local _IIl1Il1II1 = _Il1I1IlIl()

	local _1ll11IIIIlI = S.Ghost:GetAttribute(_D("\188\129\154\128\157\154\147"))
	if _ll1llI11lI1Ill then
		if _1ll11IIIIlI then
			_ll1llI11lI1Ill.setColor(Color3.fromRGB(220, 50, 50))
			if _ll1llI11lI1Ill.title then _ll1llI11lI1Ill.title.Text = _D("\179\188\187\167\160\212\175\188\161\186\160\189\186\179\169") end
		else
			_ll1llI11lI1Ill.setColor(Color3.fromRGB(255, 255, 255))
			if _ll1llI11lI1Ill.title then _ll1llI11lI1Ill.title.Text = _D("\179\188\187\167\160") end
		end
	end
	local _11l111lI1IlllII = S.Ghost:GetAttribute(_D("\178\149\130\155\134\157\128\145\166\155\155\153"))
	local _ll11I11I1II1 = S.Ghost:GetAttribute(_D("\183\129\134\134\145\154\128\166\155\155\153"))
	local _1ll1IIllI11 = S.Ghost:GetAttribute(_D("\181\147\145"))
	local _llIlll1II = S.Ghost:GetAttribute(_D("\179\145\154\144\145\134"))
	local _1I1lIIIl1ll11l1 = S.Ghost:GetAttribute(_D("\189\154\184\149\135\145\134"))

	if _11II1I1I1l > _lIIIIlIIIlI1 then _lIIIIlIIIlI1 = _11II1I1I1l end
	if _ll11lll11ll1 and _ll11lll11ll1 < _I11I11Ill11IlII then
		_I11I11Ill11IlII = _ll11lll11ll1
		_IIII11llIllIl = _1llll111l1ll
	end

	if _I1lII1lIlI then _lIIIIlII1.Handprints = true end
	if _IIlIll1lIIII1l then _lIIIIlII1.GhostOrb = true end
	if _11IIIl1IIII1 then _lIIIIlII1.SpiritBox = true end
	if _IIl1Il1II1 then _lIIIIlII1.GhostWriting = true end
	if _IlI1ll1ll11II11 then _lIIIIlII1.Wither = true end
	if _1I1lIIIl1ll11l1 then _lIIIIlII1.Laser = true end
	if _lIIIIlIIIlI1 >= 5 then _lIIIIlII1.EMF = true end
	if _I11I11Ill11IlII < 0 then _lIIIIlII1.Temperature = true end

	_lII11l11lI1l1lI.Handprints.set(_I1lII1lIlI and _D("\173\145\135") or _D("\186\155"), _lIIIIlII1.Handprints)
	_lII11l11lI1l1lI.GhostOrb.set(_IIlIll1lIIII1l and _D("\173\145\135") or _D("\186\155"), _lIIIIlII1.GhostOrb)
	_lII11l11lI1l1lI.SpiritBox.set(_11IIIl1IIII1 and _D("\173\145\135") or _D("\186\155"), _lIIIIlII1.SpiritBox)
	_lII11l11lI1l1lI.GhostWriting.set(_IIl1Il1II1 and _D("\173\145\135") or _D("\186\155"), _lIIIIlII1.GhostWriting)
	_lII11l11lI1l1lI.Laser.set(_1I1lIIIl1ll11l1 and _D("\173\145\135") or _D("\186\155"), _lIIIIlII1.Laser)
	_lII11l11lI1l1lI.Wither.set(_IlI1ll1ll11II11 and _D("\173\145\135") or _D("\186\155"), _lIIIIlII1.Wither)
	_lII11l11lI1l1lI.EMF.set(tostring(_lIIIIlIIIlI1), _lIIIIlII1.EMF)
	if _IIII11llIllIl then
		_lII11l11lI1l1lI.Temperature.set(string.format(_D("\209\218\197\146\054\068\183\212\220\209\135\221"), _I11I11Ill11IlII, _IIII11llIllIl.Name), _lIIIIlII1.Temperature)
	end
	do
		local _I1IIl11lI1 = 0
		for _ in pairs(_lIIIIlII1) do _I1IIl11lI1 = _I1IIl11lI1 + 1 end
		_llIllIIl1I1.set(math.min(_I1IIl11lI1, 3), 3)
	end

	if _llIlll1II and _1ll1IIllI11 and _11l111lI1IlllII then
		_I1lIl11lI.Ghost.set(
			(_1ll11IIIIlI and _D("\188\161\186\160\189\186\179\212\022\116\096\212") or _D("")) .. _llIlll1II .. _D("\212\136\212\181\147\145\212") .. tostring(_1ll1IIllI11) .. _D("\212\136\212\178\149\130\206\212") .. _11l111lI1IlllII,
			_1ll11IIIIlI and T.Bad or T.Tx
		)
	else
		_I1lIl11lI.Ghost.set(_1ll11IIIIlI and _D("\188\129\154\128\157\154\147") or _D("\183\156\157\152\152\157\154\147"), _1ll11IIIIlI and T.Bad or T.Tx)
	end
	if _ll11I11I1II1 then _I1lIl11lI.GhostRoom.set(_ll11I11I1II1) end
	do
		local _Ill11Il11l = plr.Character
		local _1I1llIlIlI = _Ill11Il11l and _Ill11Il11l:FindFirstChild(_D("\188\129\153\149\154\155\157\144\166\155\155\128\164\149\134\128"))
		if _1I1llIlIlI then
			_I1lIl11lI.YourRoom.set(_lII1l1llllIIIl1(_1I1llIlIlI.Position) or _D("\161\154\159\154\155\131\154"))
		end
	end
	_I1lIl11lI.HuntsDetected.set(tostring(S.HuntsCount))
	_I1lIl11lI.Round.set(_D("\149\151\128\157\130\145"), T.Good)

	local _1111ll1IIllI = {}
	local _11lIl1I1ll1llI = {}
	for _, g in ipairs(_11III1llllIl1) do
		local _l1lI1I11Il11ll1 = true
		for ev in pairs(_lIIIIlII1) do
			if not table.find(g.Ev, ev) then _l1lI1I11Il11ll1 = false; break end
		end
		if _l1lI1I11Il11ll1 then table.insert(_1111ll1IIllI, g.Name) end
		_11lIl1I1ll1llI[g.Name] = _l1lI1I11Il11ll1
	end
	if next(_lIIIIlII1) == nil then
		_11I1IlIIIll1l1l.Text = _D("\164\155\135\135\157\150\152\145\212\147\156\155\135\128\135\206\212\154\155\212\145\130\157\144\145\154\151\145\212\141\145\128")
		_11I1IlIIIll1l1l.TextColor3 = T.Tx2
	elseif #_1111ll1IIllI == 1 then
		_11I1IlIIIll1l1l.Text = _D("\179\188\187\167\160\212\160\173\164\177\206\212") .. _1111ll1IIllI[1]
		_11I1IlIIIll1l1l.TextColor3 = T.Good
	elseif #_1111ll1IIllI == 0 then
		_11I1IlIIIll1l1l.Text = _D("\164\155\135\135\157\150\152\145\212\147\156\155\135\128\135\206\212\154\155\154\145\212\153\149\128\151\156\212\220\151\155\154\146\152\157\151\128\157\154\147\212\145\130\157\144\145\154\151\145\221")
		_11I1IlIIIll1l1l.TextColor3 = T.Bad
	else
		_11I1IlIIIll1l1l.Text = _D("\164\155\135\135\157\150\152\145\212\220") .. #_1111ll1IIllI .. _D("\221\206\212") .. table.concat(_1111ll1IIllI, _D("\216\212"))
		_11I1IlIIIll1l1l.TextColor3 = T.Tx2
	end

	for _, listMeta in ipairs(S.GhostLabelSets) do
		local _ll1IlIII111 = 0
		for _, g in ipairs(_11III1llllIl1) do
			local _II1l1l1l1I = listMeta.labels[g.Name]
			if _II1l1l1l1I then
				if _11lIl1I1ll1llI[g.Name] then
					_II1l1l1l1I.row.Visible = true
					_ll1IlIII111 = _ll1IlIII111 + 1
					local _11l11lIIII1l = {}
					for _, ev in ipairs(g.Ev) do
						if not _lIIIIlII1[ev] then
							table.insert(_11l11lIIII1l, _1Il111IIII[ev] or ev)
						end
					end
					local _ll111ll1l1I = _D("")
					if #_11l11lIIII1l == 0 then
						_ll111ll1l1I = _D("\212\200\146\155\154\128\212\151\155\152\155\134\201\211\215\146\146\146\146\146\146\211\202\175\185\181\160\183\188\169\200\219\146\155\154\128\202")
					else
						_ll111ll1l1I = _D("\212\200\146\155\154\128\212\151\155\152\155\134\201\211\215\204\204\204\204\204\204\211\202\220") .. table.concat(_11l11lIIII1l, _D("\216\212")) .. _D("\221\200\219\146\155\154\128\202")
					end
					_II1l1l1l1I.label.Text = g.Name .. _ll111ll1l1I
					if #_1111ll1IIllI == 1 then
						_II1l1l1l1I.label.TextColor3 = Color3.fromRGB(255, 255, 255)
						_II1l1l1l1I.dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					else
						_II1l1l1l1I.label.TextColor3 = Color3.fromRGB(220, 220, 220)
						_II1l1l1l1I.dot.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
					end
				else
					_II1l1l1l1I.row.Visible = false
				end
			end
		end
		if listMeta.onResize then listMeta.onResize(_ll1IlIII111) end
	end
end))

S.ResetRoundState = function()
	table.clear(_lIIIIlII1)
	_lIIIIlIIIlI1 = 1
	_I11I11Ill11IlII = 100
	_IIII11llIllIl = nil
	S.HuntsCount = 0
	for _, row in pairs(_lII11l11lI1l1lI) do row.set(_D("\217\217"), false) end
	_11I1IlIIIll1l1l.Text = _D("\164\155\135\135\157\150\152\145\212\147\156\155\135\128\135\206\212\154\155\212\145\130\157\144\145\154\151\145\212\141\145\128")
	_11I1IlIIIll1l1l.TextColor3 = T.Tx2
	_llIllIIl1I1.set(0, 3)
	_I1lIl11lI.Ghost.set(_D("\217\217"))
	_I1lIl11lI.GhostRoom.set(_D("\217\217"))
	_I1lIl11lI.Photos.set(_D("\217\217"))
	_I1lIl11lI.HuntsDetected.set(_D("\196"))
	for _, listMeta in ipairs(S.GhostLabelSets) do
		local _1l1I1I1ll = 0
		for _, g in ipairs(_11III1llllIl1) do
			local _II1l1l1l1I = listMeta.labels[g.Name]
			if _II1l1l1l1I then
				_II1l1l1l1I.row.Visible = true
				_II1l1l1l1I.label.Text = g.Name .. _D("\212\200\146\155\154\128\212\151\155\152\155\134\201\211\215\204\204\204\204\204\204\211\202\220") .. table.concat(g.Ev, _D("\216\212")) .. _D("\221\200\219\146\155\154\128\202")
				_II1l1l1l1I.label.TextColor3 = Color3.fromRGB(220, 220, 220)
				_II1l1l1l1I.dot.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
				_1l1I1I1ll = _1l1I1I1ll + 1
			end
		end
		if listMeta.onResize then listMeta.onResize(_1l1I1I1ll) end
	end
	if S.DestroyGhostEsp then S.DestroyGhostEsp() end
end

task.spawn(function()
	local _IlIl111IlIl = workspace:WaitForChild(_D("\188\149\154\144\132\134\157\154\128\135"))
	_1I111I1ll(_IlIl111IlIl.ChildAdded:Connect(function()
		if S.UpdateEvidenceEsp then S.UpdateEvidenceEsp() end
	end))
end)




do
	local page = Pages[_D("\179\156\155\135\128\212\210\212\188\129\154\128")]
	local _II1lIIII1IlI1 = _IlIlIlIll11I1(page, _D("\179\156\155\135\128\212\160\155\155\152\135"), 1)
	_Illl1I1I1(_II1lIIII1IlI1, _D("\179\156\155\135\128\212\183\149\153"), false, function(v)
		local _IIl111l1lllI = workspace.CurrentCamera
		if v then
			if not S.GhostPart then
				_1I11lIIllII(_D("\186\155\128\212\134\145\149\144\141"), _D("\160\156\145\212\134\155\129\154\144\212\156\149\135\154\211\128\212\135\128\149\134\128\145\144\212\141\145\128"), _D("\131\149\134\154"), 2.5)
				return
			end
			_IIl111l1lllI.CameraSubject = S.GhostPart
		else
			local _1llIIII11IlIlI = plr.Character and plr.Character:FindFirstChildOfClass(_D("\188\129\153\149\154\155\157\144"))
			if _1llIIII11IlIlI then _IIl111l1lllI.CameraSubject = _1llIIII11IlIlI end
		end
		_lll11ll1IlIll(_D("\179\156\155\135\128\212\151\149\153"), v)
	end, 1)
	_Il1111lI1(_II1lIIII1IlI1, _D("\160\145\152\145\132\155\134\128\212\160\155\212\179\156\155\135\128"), _11l111II1Ill, 2)
	_Illl1I1I1(_II1lIIII1IlI1, _D("\185\129\128\145\212\185\129\135\157\151"), false, function(v)
		_1l1Ill1I1IIlll.set(v)
		_lll11ll1IlIll(_D("\185\129\128\145\212\153\129\135\157\151"), v)
	end, 3)
	_Illl1I1I1(_II1lIIII1IlI1, _D("\185\129\128\145\212\179\156\155\135\128\212\167\155\129\154\144\135"), false, function(v)
		_1lll1llII1l1l.set(v)
		_lll11ll1IlIll(_D("\185\129\128\145\212\147\156\155\135\128\212\135\155\129\154\144\135"), v)
	end, 4)
	_Illl1I1I1(_II1lIIII1IlI1, _D("\185\129\128\145\212\181\152\152\212\167\155\129\154\144\135"), false, function(v)
		_II111Il1lIII1.set(v)
		_lll11ll1IlIll(_D("\185\129\128\145\212\149\152\152\212\135\155\129\154\144\135"), v)
	end, 5)

	local _l11I1l1111 = _IlIlIlIll11I1(page, _D("\188\129\154\128\212\167\149\146\145\128\141"), 2)
	_Illl1I1I1(_l11I1l1111, _D("\181\129\128\155\212\188\157\144\145\212\220\154\145\149\134\145\135\128\212\151\152\155\135\145\128\221"), false, function(v)
		S.AutoHide = v
		if v and S.Ghost and S.Ghost:GetAttribute(_D("\188\129\154\128\157\154\147")) then
			_lllIl1llI()
		end
		_lll11ll1IlIll(_D("\181\129\128\155\212\156\157\144\145"), v)
	end, 1, true)
	_Illl1I1I1(_l11I1l1111, _D("\181\129\128\155\212\177\135\151\149\132\145\212\188\129\154\128\212\220\134\129\154\212\155\129\128\135\157\144\145\221"), false, function(v)
		S.EscapeHunt = v
		if v and S.Ghost and S.Ghost:GetAttribute(_D("\188\129\154\128\157\154\147")) then
			_llI1I111l()
		end
		_lll11ll1IlIll(_D("\188\129\154\128\212\145\135\151\149\132\145"), v)
	end, 2, true)
	_Il1111lI1(_l11I1l1111, _D("\160\145\152\145\132\155\134\128\212\160\155\212\186\145\149\134\145\135\128\212\188\157\144\157\154\147\212\167\132\155\128"), function()
		if not _lllIl1llI() then
			_1I11lIIllII(_D("\188\157\144\145"), _D("\186\155\212\156\157\144\157\154\147\212\135\132\155\128\212\146\155\129\154\144\212\154\145\149\134\150\141"), _D("\131\149\134\154"), 2.5)
		end
	end, 3)
	_Il1111lI1(_l11I1l1111, _D("\160\145\152\145\132\155\134\128\212\160\155\212\182\149\135\145"), function()
		_llI1I111l()
		_1I11lIIllII(_D("\160\145\152\145\132\155\134\128"), _D("\185\155\130\145\144\212\128\155\212\150\149\135\145"), _D("\157\154\146\155"), 2.2)
	end, 4)
end




do
	local page = Pages[_D("\181\129\128\155\153\149\128\157\155\154")]

	local _1lI111I11I1I1I = _IlIlIlIll11I1(page, _D("\167\132\157\134\157\128\212\182\155\140"), 1)
	_Illl1I1I1(_1lI111I11I1I1I, _D("\181\129\128\155\212\167\132\157\134\157\128\212\182\155\140"), false, function(v)
		S.AutoSpiritBox = v
		if not v then
			task.wait(0.2)
			_llI1I111l()
		end
		_lll11ll1IlIll(_D("\181\129\128\155\212\135\132\157\134\157\128\212\150\155\140"), v)
	end, 1, true)

	local _IlIIlIIl1l1ll1l = _IlIlIlIll11I1(page, _D("\164\156\155\128\155\147\134\149\132\156\141"), 2)
	local _l1111l1ll = false
	_Il1111lI1(_IlIIlIIl1l1ll1l, _D("\160\149\159\145\212\179\156\155\135\128\212\164\156\155\128\155"), function()
		if _l1111l1ll then return end
		if not _l1III1III1I() then return end
		if not S.Ghost then return end
		_l1111l1ll = true
		local _I1l1IllIlI11l1 = {
			workspace.CurrentCamera.CFrame,
			{ Stars = 3, Type = _D("\179\156\155\135\128"), Object = S.Ghost, Reward = 24 }
		}
		_lIIIl11lllllI():WaitForChild(_D("\160\149\159\145\164\156\155\128\155\163\157\128\156\183\149\153\145\134\149")):FireServer(unpack(_I1l1IllIlI11l1))
		_1I11lIIllII(_D("\164\156\155\128\155"), _D("\179\156\155\135\128\212\132\156\155\128\155\212\134\145\133\129\145\135\128\212\135\145\154\128"), _D("\135\129\151\151\145\135\135"), 2.5)
		task.delay(1.5, function() _l1111l1ll = false end)
	end, 1)

	local _l1I1IllIl = false
	local function _l1l1lIIll11I(_llI1ll1Il1)
		return _llI1ll1Il1:GetAttribute(_D("\176\129\151\159\155\199\193\193\181\152\134\145\149\144\141\160\149\159\145\154\164\156\155\128\155")) == true
	end
	_Il1111lI1(_IlIIlIIl1l1ll1l, _D("\160\149\159\145\212\199\217\167\128\149\134\212\164\156\155\128\155"), function()
		if S.Ghost and S.Ghost:GetAttribute(_D("\188\129\154\128\157\154\147")) == true then return end
		if _l1I1IllIl then return end
		if not _l1III1III1I() then return end
		_l1I1IllIl = true
		task.spawn(function()
			local _l11lII1l1I11l1l, _1llIlI11Il = nil, nil
			local _ll1l111I1I = workspace:FindFirstChild(_D("\189\128\145\153\135"))
			for _, v in pairs(_ll1l111I1I and _ll1l111I1I:GetChildren() or {}) do
				if v:GetAttribute(_D("\176\157\135\132\152\149\141\186\149\153\145")) == _D("\182\129\134\154\128\212\183\134\155\135\135") and not _l1l1lIIll11I(v) then
					v:SetAttribute(_D("\176\129\151\159\155\199\193\193\181\152\134\145\149\144\141\160\149\159\145\154\164\156\155\128\155"), true)
					_l11lII1l1I11l1l, _1llIlI11Il = v, _D("\182\129\134\154\128\183\134\155\135\135")
					local _Il1lI1lII1I11 = plr.Character and plr.Character:FindFirstChild(_D("\188\129\153\149\154\155\157\144\166\155\155\128\164\149\134\128"))
					if _Il1lI1lII1I11 then _Il1lI1lII1I11.CFrame = v:GetPivot() * CFrame.new(0, 1, 0) end
					break
				end
			end
			if not _l11lII1l1I11l1l then
				local _lI11ll1II11I = workspace:FindFirstChild(_D("\189\154\128\145\134\149\151\128\149\150\152\145\135"))
				for _, v in pairs(_lI11ll1II11I and _lI11ll1II11I:GetChildren() or {}) do
					if v:GetAttribute(_D("\164\156\155\128\155\166\145\131\149\134\144\181\130\149\157\152\149\150\152\145")) == true and not _l1l1lIIll11I(v) then
						v:SetAttribute(_D("\176\129\151\159\155\199\193\193\181\152\134\145\149\144\141\160\149\159\145\154\164\156\155\128\155"), true)
						_l11lII1l1I11l1l, _1llIlI11Il = v, _D("\189\154\128\145\134\149\151\128\157\155\154")
						local _Il1lI1lII1I11 = plr.Character and plr.Character:FindFirstChild(_D("\188\129\153\149\154\155\157\144\166\155\155\128\164\149\134\128"))
						if _Il1lI1lII1I11 then _Il1lI1lII1I11.CFrame = v:GetPivot() * CFrame.new(0, 1, 0) end
						break
					end
				end
			end
			if _1llIlI11Il == _D("\182\129\134\154\128\183\134\155\135\135") and _l11lII1l1I11l1l then
				_lIIIl11lllllI():WaitForChild(_D("\160\149\159\145\164\156\155\128\155\163\157\128\156\183\149\153\145\134\149")):FireServer(workspace.CurrentCamera.CFrame, { Stars = 3, Type = _D("\182\129\134\154\128\183\134\155\135\135"), Object = _l11lII1l1I11l1l, Reward = 12 })
				_1I11lIIllII(_D("\199\217\135\128\149\134\212\132\156\155\128\155"), _D("\182\129\134\154\128\212\151\134\155\135\135\212\132\156\155\128\155\212\134\145\133\129\145\135\128\212\135\145\154\128"), _D("\135\129\151\151\145\135\135"), 2.5)
			elseif _1llIlI11Il == _D("\189\154\128\145\134\149\151\128\157\155\154") and _l11lII1l1I11l1l then
				_lIIIl11lllllI():WaitForChild(_D("\160\149\159\145\164\156\155\128\155\163\157\128\156\183\149\153\145\134\149")):FireServer(workspace.CurrentCamera.CFrame, { Stars = 3, Type = _D("\189\154\128\145\134\149\151\128\157\155\154"), Object = _l11lII1l1I11l1l, Reward = 8 })
				_1I11lIIllII(_D("\199\217\135\128\149\134\212\132\156\155\128\155"), _D("\189\154\128\145\134\149\151\128\157\155\154\212\132\156\155\128\155\212\134\145\133\129\145\135\128\212\135\145\154\128"), _D("\135\129\151\151\145\135\135"), 2.5)
			end
			task.wait(1)
			_llI1I111l()
			task.wait(1)
			_l1I1IllIl = false
		end)
	end, 2)

	local _11IIIl1I1l11IIl = _IlIlIlIll11I1(page, _D("\161\128\157\152\157\128\157\145\135"), 3)
	_Il1111lI1(_11IIIl1I1l11IIl, _D("\160\129\134\154\212\187\154\212\178\129\135\145\212\182\155\140"), function()
		_lIIIl11lllllI():WaitForChild(_D("\160\155\147\147\152\145\178\129\135\145\182\155\140")):FireServer()
		_1I11lIIllII(_D("\178\129\135\145\212\150\155\140"), _D("\160\155\147\147\152\145\212\134\145\133\129\145\135\128\212\135\145\154\128"), _D("\157\154\146\155"), 2.2)
	end, 1)
	_Illl1I1I1(_11IIIl1I1l11IIl, _D("\181\152\152\212\184\157\147\156\128\135"), false, function()
		_1IIIlI1l111l1lI()
		_lll11ll1IlIll(_D("\181\152\152\212\152\157\147\156\128\135"), S.LightsOn)
	end, 2)

	local _llIIl111l1 = false
	_Il1111lI1(_11IIIl1I1l11IIl, _D("\164\152\149\151\145\212\189\128\145\153\135\212\186\145\149\134\212\179\156\155\135\128"), function()
		if _llIIl111l1 or (S.Ghost and S.Ghost:GetAttribute(_D("\188\129\154\128\157\154\147")) == true) then return end
		if not S.Ghost then
			_1I11lIIllII(_D("\186\155\128\212\134\145\149\144\141"), _D("\160\156\145\212\134\155\129\154\144\212\156\149\135\154\211\128\212\135\128\149\134\128\145\144\212\141\145\128"), _D("\131\149\134\154"), 2.5)
			return
		end
		_llIIl111l1 = true
		task.spawn(function()
			_1I11lIIllII(_D("\164\152\149\151\145\212\157\128\145\153\135"), _D("\185\155\130\157\154\147\212\157\128\145\153\135\212\154\145\149\134\212\147\156\155\135\128"), _D("\157\154\146\155"), 2.8)
			_11l111II1Ill()
			task.wait(0.1)
			_I1l1I11ll1ll1(1); task.wait(0.1); _1I1lllllllIIlIl(1); task.wait(0.1)
			_I1l1I11ll1ll1(1); task.wait(0.1); _1I1lllllllIIlIl(1); task.wait(0.1)
			_I1l1I11ll1ll1(1); task.wait(0.1); _1I1lllllllIIlIl(1)
			task.wait(0.2)

			local _l11l1IIIIII, _lllIl1IIl = _l11l1l11I(_D("\183\134\155\135\135"))
			if _l11l1IIIIII then _l111l1IIIlIllI1(_lllIl1IIl) end
			task.wait(0.35)
			_l11l1IIIIII, _lllIl1IIl = _l11l1l11I(_D("\183\134\155\135\135"))
			if _l11l1IIIIII then _l111l1IIIlIllI1(_lllIl1IIl) end
			task.wait(0.35)
			_l11l1IIIIII, _lllIl1IIl = _l11l1l11I(_D("\178\152\155\131\145\134\212\164\155\128"))
			if _l11l1IIIIII then _l111l1IIIlIllI1(_lllIl1IIl) end
			task.wait(0.5)

			_I1l1I11ll1ll1(1); task.wait(0.35); _IlIl1l1l1I(); task.wait(0.35); _1I1lllllllIIlIl(1); task.wait(0.35)
			_I1l1I11ll1ll1(1); task.wait(0.35); _IlIl1l1l1I(); task.wait(0.35); _1I1lllllllIIlIl(1); task.wait(0.35)
			_I1l1I11ll1ll1(1); task.wait(0.35); _IlIl1l1l1I(); task.wait(0.35); _1I1lllllllIIlIl(1)
			task.wait(0.5)

			_l11l1IIIIII, _lllIl1IIl = _l11l1l11I(_D("\184\149\135\145\134\212\164\134\155\158\145\151\128\155\134"))
			if _l11l1IIIIII then _l111l1IIIlIllI1(_lllIl1IIl) end
			task.wait(0.35)
			_l11l1IIIIII, _lllIl1IIl = _l11l1l11I(_D("\177\185\178\212\166\145\149\144\145\134"))
			if _l11l1IIIIII then _l111l1IIIlIllI1(_lllIl1IIl) end
			task.wait(0.35)
			_l11l1IIIIII, _lllIl1IIl = _l11l1l11I(_D("\167\132\157\134\157\128\212\182\155\155\159"))
			if _l11l1IIIIII then _l111l1IIIlIllI1(_lllIl1IIl) end
			task.wait(0.5)

			_I1l1I11ll1ll1(1); task.wait(0.6); _IlIl1l1l1I(); task.wait(0.5); _1I1lllllllIIlIl(1); task.wait(0.35)
			_I1l1I11ll1ll1(1); task.wait(0.6); _IlIl1l1l1I(); task.wait(0.5); _1I1lllllllIIlIl(1); task.wait(0.35)
			_I1l1I11ll1ll1(1); task.wait(0.35); _IlIl1l1l1I(); task.wait(0.35); _1I1lllllllIIlIl(1); task.wait(0.35)

			_llI1I111l()
			_llIIl111l1 = false
			_1I11lIIllII(_D("\164\152\149\151\145\212\157\128\145\153\135"), _D("\178\157\154\157\135\156\145\144"), _D("\135\129\151\151\145\135\135"), 2.4)
		end)
	end, 3)
	_Il1111lI1(_11IIIl1I1l11IIl, _D("\184\155\155\159\212\189\154\128\155\212\188\149\129\154\128\145\144\212\185\157\134\134\155\134"), function()
		task.spawn(_lIllI111I1llI1)
	end, 4)

	local _1lllll111I = {0, 0.1, 0.2, 0.5, 1, 1.5, 2, 5, 10}
	local _llIlIIIlII = {_D("\196\135"), _D("\196\218\197\135"), _D("\196\218\198\135"), _D("\196\218\193\135"), _D("\197\135"), _D("\197\218\193\135"), _D("\198\135"), _D("\193\135"), _D("\197\196\135")}
	local _1Il1lIIlIlIlII1 = _IlIlIlIll11I1(page, _D("\177\130\157\144\145\154\151\145\212\183\156\145\151\159\212\166\149\128\145"), 4)
	_1lllI11IIllIllI(_1Il1lIIlIlIlII1, _D("\183\156\145\151\159\212\167\132\145\145\144"), _1lllll111I, _llIlIIIlII, 1, function(v)
		S.CheckSpeed = v
		_1I11lIIllII(_D("\183\156\145\151\159\212\135\132\145\145\144"), tostring(v) .. _D("\135\212\157\154\128\145\134\130\149\152"), _D("\157\154\146\155"), 2)
	end, 1)
end




do
	local page = Pages[_D("\177\167\164")]
	local _II1lIlI1lI = {}
	local _II11I1lIlIIlIII = {}
	local _Il1III11lIl = {}
	local _1l1lIlIl11III = {}
	local _1I1lIII111 = {}
	local _Il1lI1IIl = {}

	local function getEspRoot(_llllIIlll1lI1)
		local _ll1Il1IIlIl11I = _llllIIlll1lI1
		local p = _llllIIlll1lI1.Parent
		while p and p ~= workspace and p ~= game do
			if p:IsA(_D("\185\155\144\145\152")) then _ll1Il1IIlIl11I = p end
			p = p.Parent
		end
		return _ll1Il1IIlIl11I
	end

	local function _1lIIII1I1(x)
		if type(x) == _D("\128\149\150\152\145") then _llllIlIllII(x) else x:Destroy() end
	end

	local function UpdateEvidenceEsp()
		for _, v in pairs(_II11I1lIlIIlIII) do _1lIIII1I1(v) end
		table.clear(_II11I1lIlIIlIII)
		if not S.EvidenceEsp then return end

		local _ll1llI11ll1I = workspace:FindFirstChild(_D("\188\149\154\144\132\134\157\154\128\135"))
		for _, _llI1ll1Il1 in ipairs(_ll1llI11ll1I and _ll1llI11ll1I:GetDescendants() or {}) do
			if _llI1ll1Il1:IsA(_D("\182\149\135\145\164\149\134\128")) then
				local _111lll1Il = nil
				for _, v in pairs(_llI1ll1Il1:GetDescendants()) do
					if v:IsA(_D("\189\153\149\147\145\184\149\150\145\152")) then _111lll1Il = v:Clone() end
				end
				local bb = Instance.new(_D("\182\157\152\152\150\155\149\134\144\179\129\157"))
				bb.Name = _D("\176\145\153\155\154\155\152\155\147\141\188\149\154\144\132\134\157\154\128\135\182\157\152")
				bb.Parent = game:GetService(_D("\183\155\134\145\179\129\157"))
				bb.AlwaysOnTop = true
				bb.Size = UDim2.new(1.6, 0, 1.6, 0)
				bb.LightInfluence = 0
				bb.Adornee = _llI1ll1Il1
				bb.StudsOffset = Vector3.new(0, 1, 0)
				if _111lll1Il then
					_111lll1Il.Parent = bb
					_111lll1Il.BackgroundTransparency = 1
					_111lll1Il.ImageTransparency = 0
					_111lll1Il.Size = UDim2.new(1, 0, 1, 0)
					Stroke(_111lll1Il, T.Warn, 1.5, 0.3)
				end
				local hl = Instance.new(_D("\188\157\147\156\152\157\147\156\128"))
				hl.Name = _D("\176\145\153\155\154\155\152\155\147\141\188\149\154\144\132\134\157\154\128\135\188\184")
				hl.Parent = _llI1ll1Il1
				hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				hl.OutlineColor = T.Warn
				hl.FillTransparency = 1
				hl.OutlineTransparency = 0
				hl.Adornee = _llI1ll1Il1
				table.insert(_II11I1lIlIIlIII, bb)
				table.insert(_II11I1lIlIIlIII, hl)
			end
		end

		for _, _llI1ll1Il1 in ipairs(workspace:GetDescendants()) do
			if _llI1ll1Il1:IsA(_D("\182\149\135\145\164\149\134\128")) and _llI1ll1Il1.Name == _D("\179\156\155\135\128\187\134\150") then
				_llI1ll1Il1.Transparency = 0
				table.insert(_II11I1lIlIIlIII, mkEspTag(_llI1ll1Il1, _D("\179\156\155\135\128\212\187\134\150"), T.White, { fill = 0.9 }))
				break
			end
		end
	end

	local function UpdateNamedEsp(_lII1I11Il, _ll1I1ll1l, _1ll1I11ll, _11I11I1l11Il, _1111I11lIIIl1l)
		for _, e in ipairs(_ll1I1ll1l) do _llllIlIllII(e) end
		table.clear(_ll1I1ll1l)
		if not _lII1I11Il then return end
		local _ll11lllllII1111 = {}
		for _, v in ipairs(workspace:GetDescendants()) do
			if #_ll1I1ll1l >= 60 then break end
			if v:IsA(_D("\185\155\144\145\152")) or v:IsA(_D("\182\149\135\145\164\149\134\128")) then
				local n = string.lower(v.Name)
				for _, w in ipairs(_1ll1I11ll) do
					if string.find(n, w, 1, true) then
						local _ll1Il1IIlIl11I = getEspRoot(v)
						if not _ll11lllllII1111[_ll1Il1IIlIl11I] then
							_ll11lllllII1111[_ll1Il1IIlIl11I] = true
							table.insert(_ll1I1ll1l, mkEspTag(_ll1Il1IIlIl11I, _11I11I1l11Il, _1111I11lIIIl1l))
						end
						break
					end
				end
			end
		end
	end

	local function UpdateESP()
		
		UpdateEvidenceEsp()

		
		for _, e in ipairs(_II1lIlI1lI) do _llllIlIllII(e) end
		table.clear(_II1lIlI1lI)
		if S.ItemEsp then
			for _, _llI1ll1Il1 in pairs(workspace:GetDescendants()) do
				if _llI1ll1Il1:IsA(_D("\185\155\144\145\152")) and _llI1ll1Il1:GetAttribute(_D("\189\128\145\153\186\149\153\145")) ~= nil then
					table.insert(_II1lIlI1lI, mkEspTag(_llI1ll1Il1, _llI1ll1Il1:GetAttribute(_D("\189\128\145\153\186\149\153\145")), Color3.fromRGB(170, 170, 170)))
				end
			end
		end

		
		UpdateNamedEsp(S.FuseEsp, _Il1III11lIl, { _D("\146\129\135\145"), _D("\150\134\145\149\159\145\134") }, _D("\178\129\135\145\212\182\155\140"), Color3.fromRGB(160, 160, 160))
		UpdateNamedEsp(S.ExitEsp, _1l1lIlIl11III, { _D("\145\140\157\128\144\155\155\134") }, _D("\177\140\157\128"), Color3.fromRGB(180, 180, 180))
		UpdateNamedEsp(S.HidingEsp, _1I1lIII111, { _D("\151\152\155\135\145\128"), _D("\152\155\151\159\145\134"), _D("\131\149\134\144\134\155\150\145"), _D("\156\157\144\157\154\147") }, _D("\188\157\144\145"), Color3.fromRGB(140, 140, 140))

		
		UpdateNamedEsp(S.InteractableEsp, _Il1lI1IIl, { _D("\159\145\141\150\155\149\134\144"), _D("\153\155\129\135\145"), _D("\132\152\149\154\128"), _D("\146\134\149\153\145"), _D("\128\155\155\128\156\150\134\129\135\156"), _D("\128\155\155\128\156\132\149\135\128\145"), _D("\144\155\152\152"), _D("\128\149\134\155\128"), _D("\153\129\135\157\151"), _D("\153\157\134\134\155\134"), _D("\130\155\155\144\155\155"), _D("\151\157\134\151\152\145"), _D("\150\155\154\145") }, _D("\189\154\128\145\134\149\151\128\149\150\152\145"), Color3.fromRGB(120, 160, 200))
	end
	S.UpdateEvidenceEsp = UpdateEvidenceEsp
	S.UpdateESP = UpdateESP
	S.ClearItemEsp = function()
		for _, e in ipairs(_II1lIlI1lI) do _llllIlIllII(e) end
		table.clear(_II1lIlI1lI)
	end

	local _lIlI111lI1II = _IlIlIlIll11I1(page, _D("\163\155\134\152\144\212\177\167\164"), 1)
	_Illl1I1I1(_lIlI111lI1II, _D("\179\156\155\135\128\212\177\167\164"), false, function(v)
		S.GhostEspOn = v
		if v then
			if not S.Ghost then
				_1I11lIIllII(_D("\186\155\128\212\134\145\149\144\141"), _D("\160\156\145\212\134\155\129\154\144\212\156\149\135\154\211\128\212\135\128\149\134\128\145\144\212\141\145\128"), _D("\131\149\134\154"), 2.5)
				return
			end
			_11111lIII1lI()
			_ll1llI11lI1Ill.bb.Enabled = true
			if _ll1llI11lI1Ill.hl then _ll1llI11lI1Ill.hl.Enabled = true end
		elseif _ll1llI11lI1Ill then
			_ll1llI11lI1Ill.bb.Enabled = false
			if _ll1llI11lI1Ill.hl then _ll1llI11lI1Ill.hl.Enabled = false end
		end
		_lll11ll1IlIll(_D("\179\156\155\135\128\212\177\167\164"), v)
	end, 1)
	_Illl1I1I1(_lIlI111lI1II, _D("\189\128\145\153\212\177\167\164"), false, function(v)
		S.ItemEsp = v
		UpdateESP()
		_lll11ll1IlIll(_D("\189\128\145\153\212\177\167\164"), v)
	end, 2)
	_Illl1I1I1(_lIlI111lI1II, _D("\177\130\157\144\145\154\151\145\212\177\167\164\212\220\188\149\154\144\132\134\157\154\128\135\216\212\187\134\150\221"), false, function(v)
		S.EvidenceEsp = v
		UpdateESP()
		_lll11ll1IlIll(_D("\177\130\157\144\145\154\151\145\212\177\167\164"), v)
	end, 3)

	local _l11I1IIII1 = _IlIlIlIll11I1(page, _D("\164\152\149\151\145\135\212\177\167\164"), 3)
	_Illl1I1I1(_l11I1IIII1, _D("\178\129\135\145\212\182\155\140\212\177\167\164"), false, function(v)
		S.FuseEsp = v
		UpdateESP()
		_lll11ll1IlIll(_D("\178\129\135\145\212\150\155\140\212\177\167\164"), v)
	end, 1)
	_Illl1I1I1(_l11I1IIII1, _D("\177\140\157\128\212\176\155\155\134\212\177\167\164"), false, function(v)
		S.ExitEsp = v
		UpdateESP()
		_lll11ll1IlIll(_D("\177\140\157\128\212\144\155\155\134\212\177\167\164"), v)
	end, 2)
	_Illl1I1I1(_l11I1IIII1, _D("\188\157\144\157\154\147\212\167\132\155\128\212\177\167\164"), false, function(v)
		S.HidingEsp = v
		UpdateESP()
		_lll11ll1IlIll(_D("\188\157\144\157\154\147\212\135\132\155\128\212\177\167\164"), v)
	end, 3)
	_Illl1I1I1(_l11I1IIII1, _D("\189\154\128\145\134\149\151\128\149\150\152\145\135\212\177\167\164"), false, function(v)
		S.InteractableEsp = v
		UpdateESP()
		_lll11ll1IlIll(_D("\189\154\128\145\134\149\151\128\149\150\152\145\135\212\177\167\164"), v)
	end, 4)

	task.spawn(function()
		while true do
			task.wait(2)
			if S.ItemEsp or S.EvidenceEsp or S.FuseEsp or S.ExitEsp or S.HidingEsp or S.InteractableEsp then
				pcall(UpdateESP)
			end
		end
	end)

	local _IlI1l1ll11lIlII = _IlIlIlIll11I1(page, _D("\164\152\149\141\145\134\135"), 4)
	_Illl1I1I1(_IlI1l1ll11lIlII, _D("\164\152\149\141\145\134\135\212\177\167\164"), false, function(v)
		S.PlayersEsp = v
		_lll11ll1IlIll(_D("\164\152\149\141\145\134\135\212\177\167\164"), v)
	end, 1)

	local plrTags = {}
	local _1Ill1ll1lIlIII = {}
	local _llIl1l1llII = {}
	local _I11ll1IIIl1111, _llI11lIlIII, _1I1IIIlIIllIlll = false, false, false
	local _II1lll11lI = _D("\183\155\134\154\145\134")

	local function _IIlIlIII111lllI(p)
		local hl = _1Ill1ll1lIlIII[p]
		if hl then hl:Destroy(); _1Ill1ll1lIlIII[p] = nil end
	end
	local function _llIll1l11lII11(p)
		local v = _llIl1l1llII[p]
		if not v then return end
		if v.box then for _, l in ipairs(v.box) do pcall(function() l:Remove() end) end end
		if v.tracer then pcall(function() v.tracer:Remove() end) end
		_llIl1l1llII[p] = nil
	end
	_1I111I1ll(_lI1lI1l1Il1I1I.PlayerRemoving:Connect(function(p)
		plrTags[p] = nil
		_IIlIlIII111lllI(p)
		_llIll1l11lII11(p)
	end))

	local function _IllllIlIIl(p)
		if p == plr then return end
		if _I11ll1IIIl1111 and p.Character then
			if not _1Ill1ll1lIlIII[p] or not _1Ill1ll1lIlIII[p].Parent then
				local hl = Instance.new(_D("\188\157\147\156\152\157\147\156\128"))
				hl.Name = _D("\176\145\153\155\154\155\152\155\147\141\183\156\149\153\135")
				hl.FillColor = Color3.fromRGB(140, 140, 140)
				hl.OutlineColor = Color3.fromRGB(200, 200, 200)
				hl.FillTransparency = 0.55
				hl.OutlineTransparency = 0.2
				hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				hl.Adornee = p.Character
				hl.Parent = p.Character
				_1Ill1ll1lIlIII[p] = hl
			end
		else
			_IIlIlIII111lllI(p)
		end
	end
	_Illl1I1I1(_IlI1l1ll11lIlII, _D("\164\152\149\141\145\134\212\183\156\149\153\135"), false, function(v)
		_I11ll1IIIl1111 = v
		for _, p in pairs(_lI1lI1l1Il1I1I:GetPlayers()) do _IllllIlIIl(p) end
		_lll11ll1IlIll(_D("\164\152\149\141\145\134\212\151\156\149\153\135"), v)
	end, 2)

	local function _lIIlI11IIII1l1l(_1111I11lIIIl1l)
		local l = Drawing.new(_D("\184\157\154\145"))
		l.Thickness = 1.5
		l.Color = _1111I11lIIIl1l
		l.Visible = false
		return l
	end
	local function _11IllII1l11(p)
		local v = _llIl1l1llII[p]
		if not v then v = {}; _llIl1l1llII[p] = v end
		return v
	end
	local function _lI1I1III1II(_Ill11Il11l)
		local _1I1llIlIlI = _Ill11Il11l:FindFirstChild(_D("\188\129\153\149\154\155\157\144\166\155\155\128\164\149\134\128"))
		local _I11l1I1llIl1I = workspace.CurrentCamera
		if not _1I1llIlIlI or not _I11l1I1llIl1I then return nil end
		local _111IllIll1lI1II = _1I1llIlIlI.Position + Vector3.new(0, 3, 0)
		local _1llII1I1I = _1I1llIlIlI.Position - Vector3.new(0, 3, 0)
		local _I1I1l1I111, _lI1lIllIlllI1l = _I11l1I1llIl1I:WorldToViewportPoint(_111IllIll1lI1II)
		local _1IIllIIlI1llI1, _ll11ll11lIlIII = _I11l1I1llIl1I:WorldToViewportPoint(_1llII1I1I)
		if _I1I1l1I111.Z <= 0 or _1IIllIIlI1llI1.Z <= 0 or not (_lI1lIllIlllI1l or _ll11ll11lIlIII) then return nil end
		local h = math.abs(_1IIllIIlI1llI1.Y - _I1I1l1I111.Y)
		local w = h * 0.55
		local cx = (_I1I1l1I111.X + _1IIllIIlI1llI1.X) / 2
		return { top = _I1I1l1I111.Y, bottom = _1IIllIIlI1llI1.Y, left = cx - w / 2, right = cx + w / 2, cx = cx }
	end
	local function _IllI11111(p, _Il1ll1I1I1l)
		local v = _11IllII1l11(p)
		if not _llI11lIlIII or not _Il1ll1I1I1l then
			if v.box then for _, l in ipairs(v.box) do l.Visible = false end end
			return
		end
		if not v.box then
			v.box = {}
			for _ = 1, 8 do table.insert(v.box, _lIIlI11IIII1l1l(Color3.fromRGB(180, 180, 180))) end
		end
		local _lI1lIllll1lI11 = v.box
		local top, bottom, left, right = _Il1ll1I1I1l.top, _Il1ll1I1I1l.bottom, _Il1ll1I1I1l.left, _Il1ll1I1I1l.right
		if _II1lll11lI == _D("\178\129\152\152") then
			local _1I1l11111l1I = { Vector2.new(left, top), Vector2.new(right, top), Vector2.new(right, bottom), Vector2.new(left, bottom) }
			for i = 1, 4 do
				_lI1lIllll1lI11[i].From = _1I1l11111l1I[i]
				_lI1lIllll1lI11[i].To = _1I1l11111l1I[i % 4 + 1]
				_lI1lIllll1lI11[i].Visible = true
			end
			for i = 5, 8 do _lI1lIllll1lI11[i].Visible = false end
		else
			local _IIlIII11IlI11I = math.min(right - left, bottom - top) * 0.28
			local _III1l1lllIIIlII = {
				{ Vector2.new(left, top), Vector2.new(left + _IIlIII11IlI11I, top) },
				{ Vector2.new(left, top), Vector2.new(left, top + _IIlIII11IlI11I) },
				{ Vector2.new(right, top), Vector2.new(right - _IIlIII11IlI11I, top) },
				{ Vector2.new(right, top), Vector2.new(right, top + _IIlIII11IlI11I) },
				{ Vector2.new(left, bottom), Vector2.new(left + _IIlIII11IlI11I, bottom) },
				{ Vector2.new(left, bottom), Vector2.new(left, bottom - _IIlIII11IlI11I) },
				{ Vector2.new(right, bottom), Vector2.new(right - _IIlIII11IlI11I, bottom) },
				{ Vector2.new(right, bottom), Vector2.new(right, bottom - _IIlIII11IlI11I) },
			}
			for i = 1, 8 do
				_lI1lIllll1lI11[i].From = _III1l1lllIIIlII[i][1]
				_lI1lIllll1lI11[i].To = _III1l1lllIIIlII[i][2]
				_lI1lIllll1lI11[i].Visible = true
			end
		end
	end
	local function _Il1lIl1I1I(p, _Il1ll1I1I1l)
		local v = _11IllII1l11(p)
		if not _1I1IIIlIIllIlll or not _Il1ll1I1I1l then
			if v.tracer then v.tracer.Visible = false end
			return
		end
		if not v.tracer then v.tracer = _lIIlI11IIII1l1l(Color3.fromRGB(150, 150, 150)) end
		local _I11l1I1llIl1I = workspace.CurrentCamera
		local _1II1lllIl = _I11l1I1llIl1I and _I11l1I1llIl1I.ViewportSize or Vector2.new(0, 0)
		v.tracer.From = Vector2.new(_1II1lllIl.X / 2, _1II1lllIl.Y)
		v.tracer.To = Vector2.new(_Il1ll1I1I1l.cx, _Il1ll1I1I1l.bottom)
		v.tracer.Visible = true
	end
	if Drawing then
		_1I111I1ll(_lII111IIIIllI.RenderStepped:Connect(function()
			if not (_llI11lIlIII or _1I1IIIlIIllIlll) then return end
			for _, p in pairs(_lI1lI1l1Il1I1I:GetPlayers()) do
				local _Il1ll1I1I1l = (p ~= plr and p.Character) and _lI1I1III1II(p.Character) or nil
				_IllI11111(p, _Il1ll1I1I1l)
				_Il1lIl1I1I(p, _Il1ll1I1I1l)
			end
		end))
	end
	_Illl1I1I1(_IlI1l1ll11lIlII, _D("\164\152\149\141\145\134\212\182\155\140\212\177\167\164"), false, function(v)
		if not Drawing then
			_1I11lIIllII(_D("\164\152\149\141\145\134\212\182\155\140\212\177\167\164"), _D("\160\156\157\135\212\145\140\145\151\129\128\155\134\212\144\155\145\135\154\211\128\212\145\140\132\155\135\145\212\128\156\145\212\176\134\149\131\157\154\147\212\152\157\150\134\149\134\141"), _D("\131\149\134\154"), 3)
			return
		end
		_llI11lIlIII = v
		if not v then
			for _, _lI1lIIlIlI1ll1I in pairs(_llIl1l1llII) do
				if _lI1lIIlIlI1ll1I.box then for _, l in ipairs(_lI1lIIlIlI1ll1I.box) do l.Visible = false end end
			end
		end
		_lll11ll1IlIll(_D("\164\152\149\141\145\134\212\150\155\140\212\177\167\164"), v)
	end, 3)
	_1lllI11IIllIllI(_IlI1l1ll11lIlII, _D("\182\155\140\212\167\128\141\152\145"), { _D("\183\155\134\154\145\134"), _D("\178\129\152\152") }, { _D("\183\155\134\154\145\134\212\182\155\140"), _D("\178\129\152\152\212\182\155\140") }, _D("\183\155\134\154\145\134"), function(v)
		_II1lll11lI = v
	end, 4)
	_Illl1I1I1(_IlI1l1ll11lIlII, _D("\164\152\149\141\145\134\212\160\134\149\151\145\134\135"), false, function(v)
		if not Drawing then
			_1I11lIIllII(_D("\164\152\149\141\145\134\212\160\134\149\151\145\134\135"), _D("\160\156\157\135\212\145\140\145\151\129\128\155\134\212\144\155\145\135\154\211\128\212\145\140\132\155\135\145\212\128\156\145\212\176\134\149\131\157\154\147\212\152\157\150\134\149\134\141"), _D("\131\149\134\154"), 3)
			return
		end
		_1I1IIIlIIllIlll = v
		if not v then
			for _, _lI1lIIlIlI1ll1I in pairs(_llIl1l1llII) do
				if _lI1lIIlIlI1ll1I.tracer then _lI1lIIlIlI1ll1I.tracer.Visible = false end
			end
		end
		_lll11ll1IlIll(_D("\164\152\149\141\145\134\212\128\134\149\151\145\134\135"), v)
	end, 5)

	local _l1ll1l1II1 = Instance.new(_D("\178\134\149\153\145"))
	_l1ll1l1II1.Parent = _IlI1l1ll11lIlII
	_l1ll1l1II1.LayoutOrder = 6
	_l1ll1l1II1.BackgroundTransparency = 1
	_l1ll1l1II1.Size = UDim2.new(1, 0, 0, 0)
	_l1ll1l1II1.AutomaticSize = Enum.AutomaticSize.Y
	local _IlllI11Ill = Instance.new(_D("\161\189\184\157\135\128\184\149\141\155\129\128"))
	_IlllI11Ill.Parent = _l1ll1l1II1
	_IlllI11Ill.SortOrder = Enum.SortOrder.LayoutOrder
	_IlllI11Ill.Padding = UDim.new(0, 2)

	local function UpdatePlrEsp()
		if S.PlayersEsp then
			for _, p in pairs(_lI1lI1l1Il1I1I:GetPlayers()) do
				if p ~= plr and p.Character then
					local _1I1llIlIlI = p.Character:FindFirstChild(_D("\188\129\153\149\154\155\157\144\166\155\155\128\164\149\134\128"))
					if _1I1llIlIlI then
						if p:GetAttribute(_D("\176\145\149\144")) == true then
							for _, v in pairs(p.Character:GetDescendants()) do
								if v:IsA(_D("\182\149\135\145\164\149\134\128")) and v.Name ~= _D("\188\129\153\149\154\155\157\144\166\155\155\128\164\149\134\128") then
									v.Transparency = 0
								end
							end
							if plrTags[p] then plrTags[p].title.Text = p.DisplayName .. _D("\212\220\176\145\149\144\221") end
						end
						if not plrTags[p] or not plrTags[p].bb.Parent then
							plrTags[p] = mkEspTag(_1I1llIlIlI, p.DisplayName, Color3.fromRGB(200, 200, 200), { fill = 0.88 })
						end
					end
				end
			end
		else
			for _, tag in pairs(plrTags) do _llllIlIllII(tag) end
			table.clear(plrTags)
		end

		for _, v in pairs(_l1ll1l1II1:GetChildren()) do
			if v:IsA(_D("\160\145\140\128\184\149\150\145\152")) then v:Destroy() end
		end
		for _, p in pairs(_lI1lI1l1Il1I1I:GetPlayers()) do
			if p:GetAttribute(_D("\177\154\145\134\147\141")) ~= nil then
				local row = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
				row.Parent = _l1ll1l1II1
				row.BackgroundTransparency = 1
				row.Size = UDim2.new(1, 0, 0, 16)
				row.Font = F
				row.TextSize = 12
				row.TextXAlignment = Enum.TextXAlignment.Left
				row.TextColor3 = T.Tx2
				local _I1I1I1lI11I = math.floor(p:GetAttribute(_D("\177\154\145\134\147\141")))
				if p.Name == p.DisplayName then
					row.Text = p.Name .. _D("\206\212") .. tostring(_I1I1I1lI11I) .. _D("\209")
				else
					row.Text = p.Name .. _D("\212\220") .. p.DisplayName .. _D("\221\206\212") .. tostring(_I1I1I1lI11I) .. _D("\209")
				end
			end
		end
	end
	S.UpdatePlrEsp = UpdatePlrEsp
	_lIlll11II1llII = function()
		_I11ll1IIIl1111, _llI11lIlIII, _1I1IIIlIIllIlll = false, false, false
		for p in pairs(_1Ill1ll1lIlIII) do _IIlIlIII111lllI(p) end
		for p in pairs(_llIl1l1llII) do _llIll1l11lII11(p) end
		for _, e in ipairs(_II1lIlI1lI) do _llllIlIllII(e) end
		for _, e in ipairs(_Il1III11lIl) do _llllIlIllII(e) end
		for _, e in ipairs(_1l1lIlIl11III) do _llllIlIllII(e) end
		for _, e in ipairs(_1I1lIII111) do _llllIlIllII(e) end
		for _, e in ipairs(_Il1lI1IIl) do _llllIlIllII(e) end
		table.clear(_II1lIlI1lI)
		table.clear(_Il1III11lIl)
		table.clear(_1l1lIlIl11III)
		table.clear(_1I1lIII111)
		table.clear(_Il1lI1IIl)
		for _, v in pairs(_II11I1lIlIIlIII) do _1lIIII1I1(v) end
		table.clear(_II11I1lIlIIlIII)
	end
end




do
	local page = Pages[_D("\185\155\130\145\153\145\154\128")]
	local _lI1IlI1Ill1 = _IlIlIlIll11I1(page, _D("\185\155\130\145\153\145\154\128"), 1)
	
	_1I111I1ll(_lII111IIIIllI.Heartbeat:Connect(function()
		if _I11lII1ll and plr.Character then
			local _1llIIII11IlIlI = plr.Character:FindFirstChildOfClass(_D("\188\129\153\149\154\155\157\144"))
			if _1llIIII11IlIlI and _1llIIII11IlIlI.WalkSpeed ~= _II1Il1l1l then
				_1llIIII11IlIlI.WalkSpeed = _II1Il1l1l
			end
		end
	end))
	
	_11llIIIIlIII(_lI1IlI1Ill1, _D("\163\149\152\159\212\167\132\145\145\144"), 0, 100, 16, function(v)
		if v == 16 then
			_I11lII1ll = false
			local _1llIIII11IlIlI = plr.Character and plr.Character:FindFirstChildOfClass(_D("\188\129\153\149\154\155\157\144"))
			if _1llIIII11IlIlI then _1llIIII11IlIlI.WalkSpeed = 16 end
		else
			_II1Il1l1l = v
			_I11lII1ll = true
		end
		_1I11lIIllII(_D("\163\149\152\159\212\135\132\145\145\144"), tostring(v), _D("\157\154\146\155"), 1.6)
	end, 1)

	local _1llIl1llIIlIl = false
	local _lll1Il1I11l1l = nil
	local function _II11llI1I1(v)
		_1llIl1llIIlIl = v
		if not v then
			if _lll1Il1I11l1l then _lll1Il1I11l1l:Disconnect(); _lll1Il1I11l1l = nil end
			local _1I1llIlIlI = plr.Character and plr.Character:FindFirstChild(_D("\188\129\153\149\154\155\157\144\166\155\155\128\164\149\134\128"))
			if _1I1llIlIlI then
				for _, child in ipairs(_1I1llIlIlI:GetChildren()) do
					if child:IsA(_D("\182\155\144\141\162\145\152\155\151\157\128\141")) or child:IsA(_D("\182\155\144\141\179\141\134\155")) then
						child:Destroy()
					end
				end
			end
			return
		end
		local _Ill11Il11l = plr.Character
		local _1I1llIlIlI = _Ill11Il11l and _Ill11Il11l:FindFirstChild(_D("\188\129\153\149\154\155\157\144\166\155\155\128\164\149\134\128"))
		local _1llIIII11IlIlI = _Ill11Il11l and _Ill11Il11l:FindFirstChildOfClass(_D("\188\129\153\149\154\155\157\144"))
		if not _1I1llIlIlI or not _1llIIII11IlIlI then return end
		
		local _1l1l1IlI11lI = Instance.new(_D("\182\155\144\141\179\141\134\155"))
		_1l1l1IlI11lI.P = 9e4
		_1l1l1IlI11lI.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		_1l1l1IlI11lI.cframe = _1I1llIlIlI.CFrame
		_1l1l1IlI11lI.Parent = _1I1llIlIlI
		
		local _1lIllI11l1l11 = Instance.new(_D("\182\155\144\141\162\145\152\155\151\157\128\141"))
		_1lIllI11l1l11.velocity = Vector3.new(0, 0.1, 0)
		_1lIllI11l1l11.maxForce = Vector3.new(9e9, 9e9, 9e9)
		_1lIllI11l1l11.Parent = _1I1llIlIlI
		
		_lll1Il1I11l1l = _lII111IIIIllI.Heartbeat:Connect(function()
			if not _1llIl1llIIlIl or not _Ill11Il11l.Parent or not _1I1llIlIlI.Parent then
				_II11llI1I1(false)
				return
			end
			local _IIIlIIIl1I1 = workspace.CurrentCamera
			local _l1llIlIll = Vector3.new(0, 0, 0)
			if _lII1I1I11:IsKeyDown(Enum.KeyCode.W) then _l1llIlIll = _l1llIlIll + _IIIlIIIl1I1.CFrame.LookVector end
			if _lII1I1I11:IsKeyDown(Enum.KeyCode.S) then _l1llIlIll = _l1llIlIll - _IIIlIIIl1I1.CFrame.LookVector end
			if _lII1I1I11:IsKeyDown(Enum.KeyCode.A) then _l1llIlIll = _l1llIlIll - _IIIlIIIl1I1.CFrame.RightVector end
			if _lII1I1I11:IsKeyDown(Enum.KeyCode.D) then _l1llIlIll = _l1llIlIll + _IIIlIIIl1I1.CFrame.RightVector end
			if _lII1I1I11:IsKeyDown(Enum.KeyCode.Space) then _l1llIlIll = _l1llIlIll + Vector3.new(0, 1, 0) end
			if _lII1I1I11:IsKeyDown(Enum.KeyCode.LeftShift) then _l1llIlIll = _l1llIlIll - Vector3.new(0, 1, 0) end
			
			if _l1llIlIll.Magnitude > 0 then
				_1lIllI11l1l11.velocity = _l1llIlIll.Unit * _l1IlIIII11lll
			else
				_1lIllI11l1l11.velocity = Vector3.new(0, 0.1, 0)
			end
			_1l1l1IlI11lI.cframe = _IIIlIIIl1I1.CFrame
		end)
		_1I111I1ll(_lll1Il1I11l1l)
	end

	_Illl1I1I1(_lI1IlI1Ill1, _D("\178\152\141"), false, function(v)
		_II11llI1I1(v)
		_lll11ll1IlIll(_D("\178\152\141"), v)
	end, 2)

	_11llIIIIlIII(_lI1IlI1Ill1, _D("\178\152\141\212\167\132\145\145\144"), 10, 200, 50, function(v)
		_l1IlIIII11lll = v
		_1I11lIIllII(_D("\178\152\141\212\167\132\145\145\144"), tostring(v), _D("\157\154\146\155"), 1.6)
	end, 3)

	local _lI1lIIlIlI1ll1I = _IlIlIlIll11I1(page, _D("\162\157\135\157\155\154"), 2)
	local _lIlII1Il11III1l = false
	local _I1lII1lIl1 = _lII111IIIIllI.Stepped:Connect(function()
		if _lIlII1Il11III1l and plr.Character then
			for _, p in ipairs(plr.Character:GetDescendants()) do
				if p:IsA(_D("\182\149\135\145\164\149\134\128")) and p.CanCollide then
					p.CanCollide = false
				end
			end
		end
	end)
	_1I111I1ll(_I1lII1lIl1)
	_Illl1I1I1(_lI1lIIlIlI1ll1I, _D("\186\155\151\152\157\132"), false, function(v)
		_lIlII1Il11III1l = v
		_lll11ll1IlIll(_D("\186\155\151\152\157\132"), v)
	end, 1)

	local _1llI11ll11III = false
	local function _1ll1II1I11ll(_lII1I11Il)
		local _lIl1llIl1I11ll1 = workspace:FindFirstChild(_D("\185\149\132"))
		if not _lIl1llIl1I11ll1 then return end
		for _, p in ipairs(_lIl1llIl1I11ll1:GetDescendants()) do
			if p:IsA(_D("\182\149\135\145\164\149\134\128")) then
				p.LocalTransparencyModifier = _lII1I11Il and 0.6 or 0
			end
		end
	end
	_Illl1I1I1(_lI1lIIlIlI1ll1I, _D("\172\217\166\149\141"), false, function(v)
		_1llI11ll11III = v
		_1ll1II1I11ll(v)
		_lll11ll1IlIll(_D("\172\217\166\149\141"), v)
	end, 2)

	_Illl1I1I1(_lI1lIIlIlI1ll1I, _D("\178\129\152\152\212\182\134\157\147\156\128"), false, function(v)
		if v then
			_1lllII11l1I.Ambient = Color3.new(1, 1, 1)
			_1lllII11l1I.OutdoorAmbient = Color3.new(1, 1, 1)
			_1lllII11l1I.Brightness = 3
			_1lllII11l1I.GlobalShadows = false
			_1lllII11l1I.FogEnd = 100000
		else
			_1lllII11l1I.Ambient = S.OldLighting.Ambient
			_1lllII11l1I.OutdoorAmbient = S.OldLighting.OutdoorAmbient
			_1lllII11l1I.Brightness = S.OldLighting.Brightness
			_1lllII11l1I.GlobalShadows = S.OldLighting.GlobalShadows
			_1lllII11l1I.FogEnd = S.OldLighting.FogEnd
		end
		_lll11ll1IlIll(_D("\178\129\152\152\212\150\134\157\147\156\128"), v)
	end, 3)

	S.DisableAllExtras = function()
		_lIlII1Il11III1l = false
		if _1llI11ll11III then _1llI11ll11III = false; _1ll1II1I11ll(false) end
	end
end




do
	local page = Pages[_D("\160\145\152\145\132\155\134\128")]
	local _11IIlIIlIl1l1l = _IlIlIlIll11I1(page, _D("\160\145\152\145\132\155\134\128\135"), 1)
	_Il1111lI1(_11IIlIIlIl1l1l, _D("\160\145\152\145\132\155\134\128\212\160\155\212\179\156\155\135\128"), function()
		if S.Ghost and S.Ghost:GetAttribute(_D("\188\129\154\128\157\154\147")) == true then return end
		_11l111II1Ill()
		_1I11lIIllII(_D("\160\145\152\145\132\155\134\128"), _D("\185\155\130\145\144\212\128\155\212\147\156\155\135\128"), _D("\157\154\146\155"), 2.2)
	end, 1)
	_Il1111lI1(_11IIlIIlIl1l1l, _D("\160\145\152\145\132\155\134\128\212\160\155\212\182\149\135\145"), function()
		_llI1I111l()
		_1I11lIIllII(_D("\160\145\152\145\132\155\134\128"), _D("\185\155\130\145\144\212\128\155\212\150\149\135\145"), _D("\157\154\146\155"), 2.2)
	end, 2)
	_Il1111lI1(_11IIlIIlIl1l1l, _D("\160\145\152\145\132\155\134\128\212\160\155\212\183\155\152\144\145\135\128\212\166\155\155\153"), function()
		local _, _1llll111l1ll = _l1lIlI1Il1IIlll()
		local _ll1I1IlllI1I = plr.Character
		if _1llll111l1ll and _ll1I1IlllI1I then
			local _111IIII1I1lIIII = _1llll111l1ll:FindFirstChildWhichIsA(_D("\182\149\135\145\164\149\134\128"), true)
			if _111IIII1I1lIIII then
				_ll1I1IlllI1I:PivotTo(_111IIII1I1lIIII.CFrame + Vector3.new(0, 3, 0))
				_1I11lIIllII(_D("\160\145\152\145\132\155\134\128"), _D("\185\155\130\145\144\212\128\155\212\151\155\152\144\145\135\128\212\134\155\155\153"), _D("\157\154\146\155"), 2.2)
			else
				_1I11lIIllII(_D("\160\145\152\145\132\155\134\128"), _D("\183\155\152\144\145\135\128\212\134\155\155\153\212\132\149\134\128\212\154\155\128\212\146\155\129\154\144"), _D("\131\149\134\154"), 2.6)
			end
		else
			_1I11lIIllII(_D("\160\145\152\145\132\155\134\128"), _D("\183\155\152\144\145\135\128\212\134\155\155\153\212\154\155\128\212\146\155\129\154\144"), _D("\131\149\134\154"), 2.6)
		end
	end, 3)

	local _1IIIlI11I1ll1 = _IlIlIlIll11I1(page, _D("\160\149\134\147\145\128\212\160\145\152\145\132\155\134\128\135"), 2)
	local _111ll1l1111IlI = _D("\186\155\154\145")
	local _I11111lIIll = _D("\186\155\154\145")

	local _I1IIl1Il1IllI = _1lllI11IIllIllI(_1IIIlI11I1ll1, _D("\167\145\152\145\151\128\212\164\152\149\141\145\134"), {_D("\186\155\154\145")}, {_D("\186\155\154\145")}, _D("\186\155\154\145"), function(v)
		_111ll1l1111IlI = v
	end, 1)

	_Il1111lI1(_1IIIlI11I1ll1, _D("\160\145\152\145\132\155\134\128\212\160\155\212\164\152\149\141\145\134"), function()
		if _111ll1l1111IlI == _D("\186\155\154\145") or _111ll1l1111IlI == _D("\186\155\212\132\152\149\141\145\134\135\212\146\155\129\154\144") then
			_1I11lIIllII(_D("\160\145\152\145\132\155\134\128"), _D("\186\155\212\128\149\134\147\145\128\212\135\145\152\145\151\128\145\144"), _D("\131\149\134\154"), 2.2)
			return
		end
		local _1III11lI1I1I = _lI1lI1l1Il1I1I:FindFirstChild(_111ll1l1111IlI)
		local _Ill11Il11l = _1III11lI1I1I and _1III11lI1I1I.Character
		local _IlII11111 = plr.Character
		if _Ill11Il11l and _IlII11111 then
			_IlII11111:PivotTo(_Ill11Il11l:GetPivot())
			_1I11lIIllII(_D("\160\145\152\145\132\155\134\128"), _D("\185\155\130\145\144\212\128\155\212") .. _111ll1l1111IlI, _D("\135\129\151\151\145\135\135"), 2.2)
		else
			_1I11lIIllII(_D("\160\145\152\145\132\155\134\128"), _D("\164\152\149\141\145\134\212\151\156\149\134\149\151\128\145\134\212\154\155\128\212\146\155\129\154\144"), _D("\131\149\134\154"), 2.5)
		end
	end, 2)

	local _Il1I1111ll = _1lllI11IIllIllI(_1IIIlI11I1ll1, _D("\167\145\152\145\151\128\212\189\128\145\153"), {_D("\186\155\154\145")}, {_D("\186\155\154\145")}, _D("\186\155\154\145"), function(v)
		_I11111lIIll = v
	end, 3)

	_Il1111lI1(_1IIIlI11I1ll1, _D("\160\145\152\145\132\155\134\128\212\160\155\212\189\128\145\153"), function()
		if _I11111lIIll == _D("\186\155\154\145") or _I11111lIIll == _D("\186\155\212\157\128\145\153\135\212\146\155\129\154\144") then
			_1I11lIIllII(_D("\160\145\152\145\132\155\134\128"), _D("\186\155\212\157\128\145\153\212\135\145\152\145\151\128\145\144"), _D("\131\149\134\154"), 2.2)
			return
		end
		local _11III1II1lIlI = workspace:FindFirstChild(_D("\189\128\145\153\135"))
		if not _11III1II1lIlI then return end
		local _IIlI11llIII11 = nil
		for _, v in pairs(_11III1II1lIlI:GetChildren()) do
			if v:IsA(_D("\185\155\144\145\152")) and v:GetAttribute(_D("\189\128\145\153\186\149\153\145")) == _I11111lIIll then
				_IIlI11llIII11 = v
				break
			end
		end
		local _IlII11111 = plr.Character
		if _IIlI11llIII11 and _IlII11111 then
			_IlII11111:PivotTo(_IIlI11llIII11:GetPivot() + Vector3.new(0, 2, 0))
			_1I11lIIllII(_D("\160\145\152\145\132\155\134\128"), _D("\185\155\130\145\144\212\128\155\212") .. _I11111lIIll, _D("\135\129\151\151\145\135\135"), 2.2)
		else
			_1I11lIIllII(_D("\160\145\152\145\132\155\134\128"), _D("\189\128\145\153\212\154\155\128\212\146\155\129\154\144\212\155\154\212\153\149\132"), _D("\131\149\134\154"), 2.5)
		end
	end, 4)

	task.spawn(function()
		while true do
			task.wait(3)
			local _llIIIllIl11ll = {}
			for _, p in ipairs(_lI1lI1l1Il1I1I:GetPlayers()) do
				if p ~= plr then table.insert(_llIIIllIl11ll, p.Name) end
			end
			if #_llIIIllIl11ll == 0 then _llIIIllIl11ll = {_D("\186\155\154\145")} end
			_I1IIl1Il1IllI.update(_llIIIllIl11ll)
			
			local _1IlI1l1l1 = {}
			local _11III1II1lIlI = workspace:FindFirstChild(_D("\189\128\145\153\135"))
			if _11III1II1lIlI then
				local _l1lllI1llll = {}
				for _, v in pairs(_11III1II1lIlI:GetChildren()) do
					if v:IsA(_D("\185\155\144\145\152")) and v:GetAttribute(_D("\189\128\145\153\186\149\153\145")) then
						local _11l1lIIll = v:GetAttribute(_D("\189\128\145\153\186\149\153\145"))
						if not _l1lllI1llll[_11l1lIIll] then
							_l1lllI1llll[_11l1lIIll] = true
							table.insert(_1IlI1l1l1, _11l1lIIll)
						end
					end
				end
			end
			if #_1IlI1l1l1 == 0 then _1IlI1l1l1 = {_D("\186\155\154\145")} end
			_Il1I1111ll.update(_1IlI1l1l1)
		end
	end)
end




do
	local page = Pages[_D("\185\157\135\151")]
	local _11IIIl1I1l11IIl = _IlIlIlIll11I1(page, _D("\161\128\157\152\157\128\141"), 1)
	local _1l1lllll1I = true
	local _1ll1l1ll1lll1I = plr.Idled:Connect(function()
		if _1l1lllll1I then
			local _1I11lIl1l = game:GetService(_D("\162\157\134\128\129\149\152\161\135\145\134"))
			_1I11lIl1l:CaptureController()
			_1I11lIl1l:ClickButton2(Vector2.new())
		end
	end)
	_1I111I1ll(_1ll1l1ll1lll1I)
	_Illl1I1I1(_11IIIl1I1l11IIl, _D("\181\154\128\157\217\181\178\191"), true, function(v)
		_1l1lllll1I = v
		_lll11ll1IlIll(_D("\181\154\128\157\217\181\178\191"), v)
	end, 1)
	_Il1111lI1(_11IIIl1I1l11IIl, _D("\184\155\149\144\212\189\154\146\157\154\157\128\145\212\173\157\145\152\144"), function()
		_1I11lIIllII(_D("\189\154\146\157\154\157\128\145\212\173\157\145\152\144"), _D("\184\155\149\144\157\154\147\212\145\140\128\145\134\154\149\152\212\135\151\134\157\132\128"), _D("\157\154\146\155"), 2.4)
		local _l1lI1I11Il11ll1, _IIlII1III1Il1 = pcall(function()
			loadstring(game:HttpGet(_D("\156\128\128\132\135\206\219\219\134\149\131\218\147\157\128\156\129\150\129\135\145\134\151\155\154\128\145\154\128\218\151\155\153\219\177\144\147\145\189\173\219\157\154\146\157\154\157\128\145\141\157\145\152\144\219\153\149\135\128\145\134\219\135\155\129\134\151\145")))()
		end)
		if not _l1lI1I11Il11ll1 then
			_1I11lIIllII(_D("\189\154\146\157\154\157\128\145\212\173\157\145\152\144"), _D("\178\149\157\152\145\144\212\128\155\212\152\155\149\144\206\212") .. tostring(_IIlII1III1Il1), _D("\144\149\154\147\145\134"), 3.5)
		end
	end, 2)

	local _IIIl1llIlII1l = S.DisableAllExtras
	S.DisableAllExtras = function()
		if _IIIl1llIlII1l then _IIIl1llIlII1l() end
		_1l1lllll1I = false
	end
end




do
	local page = Pages[_D("\188\161\176")]
	local _lIl1IlI1I1 = _IlIlIlIll11I1(page, _D("\188\161\176\212\164\149\154\145\152\135"), 1)

	local _11IIII1lIl1Il1 = _lIIllIl1ll1l(_D("\179\156\155\135\128\212\184\157\135\128"), UDim2.new(1, -230, 0.5, -200), UDim2.fromOffset(220, 400), 850)
	_lIlII1IIll(_11IIII1lIl1Il1.content, 16, function(_I1IIl11lI1)
		local h = math.clamp(_I1IIl11lI1 * 19 + 49, 70, 400)
		TweenService:Create(_11IIII1lIl1Il1.frame, TweenInfo.new(0.2), { Size = UDim2.fromOffset(220, h) }):Play()
	end)
	_Illl1I1I1(_lIl1IlI1I1, _D("\179\156\155\135\128\212\184\157\135\128\212\188\161\176"), false, function(v)
		_11IIII1lIl1Il1.frame.Visible = v
		_lll11ll1IlIll(_D("\179\156\155\135\128\212\152\157\135\128\212\188\161\176"), v)
	end, 1)

	local _IlIl1I1I1III = _lIIllIl1ll1l(_D("\191\145\141\150\157\154\144\135"), UDim2.new(0, 18, 0.35, 0), UDim2.fromOffset(280, 100), 851)
	local _1l1IIII11111 = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_1l1IIII11111.Parent = _IlIl1I1I1III.content
	_1l1IIII11111.BackgroundTransparency = 1
	_1l1IIII11111.Size = UDim2.new(1, 0, 1, 0)
	_1l1IIII11111.Font = F
	_1l1IIII11111.TextSize = 16
	_1l1IIII11111.TextColor3 = T.Tx
	_1l1IIII11111.TextStrokeColor3 = Color3.new(0, 0, 0)
	_1l1IIII11111.TextStrokeTransparency = 0.5
	_1l1IIII11111.TextXAlignment = Enum.TextXAlignment.Left
	_1l1IIII11111.TextYAlignment = Enum.TextYAlignment.Top
	_1l1IIII11111.TextWrapped = true
	_1l1IIII11111.LineHeight = 1.3
	_1l1IIII11111.Text = _D("\166\157\147\156\128\212\167\156\157\146\128\212\022\116\096\212\135\156\155\131\212\219\212\156\157\144\145\212\153\145\154\129")
	_Illl1I1I1(_lIl1IlI1I1, _D("\191\145\141\150\157\154\144\135\212\188\161\176"), false, function(v)
		_IlIl1I1I1III.frame.Visible = v
		_lll11ll1IlIll(_D("\191\145\141\150\157\154\144\135\212\188\161\176"), v)
	end, 2)

	local _II1l1IIIIl1II = _lIIllIl1ll1l(_D("\164\145\134\146\155\134\153\149\154\151\145"), UDim2.new(1, -178, 0, 72), UDim2.fromOffset(160, 70), 852)
	local _lI1IIIll1l11l = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_lI1IIIll1l11l.Parent = _II1l1IIIIl1II.content
	_lI1IIIll1l11l.BackgroundTransparency = 1
	_lI1IIIll1l11l.Size = UDim2.new(1, 0, 1, 0)
	_lI1IIIll1l11l.Font = FM
	_lI1IIIll1l11l.TextSize = 16
	_lI1IIIll1l11l.TextColor3 = T.White
	_lI1IIIll1l11l.TextStrokeColor3 = Color3.new(0, 0, 0)
	_lI1IIIll1l11l.TextStrokeTransparency = 0.5
	_lI1IIIll1l11l.TextXAlignment = Enum.TextXAlignment.Left
	_lI1IIIll1l11l.Text = _D("\178\164\167\206\212\217\217")
	_Illl1I1I1(_lIl1IlI1I1, _D("\178\164\167\212\188\161\176"), false, function(v)
		_II1l1IIIIl1II.frame.Visible = v
		_lll11ll1IlIll(_D("\178\164\167\212\188\161\176"), v)
	end, 3)
	do
		local _lII1I1III1, _I111lIIIll = 0, 0
		_1I111I1ll(_lII111IIIIllI.RenderStepped:Connect(function(_1I11Il1I1lI1Ill)
			_lII1I1III1 = _lII1I1III1 + 1
			_I111lIIIll = _I111lIIIll + _1I11Il1I1lI1Ill
			if _I111lIIIll >= 0.5 then
				_lI1IIIll1l11l.Text = _D("\178\164\167\206\212") .. tostring(math.floor((_lII1I1III1 / _I111lIIIll) + 0.5))
				_lII1I1III1, _I111lIIIll = 0, 0
			end
		end))
	end

	local _Il1Ill1ll = _lIIllIl1ll1l(_D("\188\161\176\212\167\128\149\128\129\135"), UDim2.new(1, -268, 0, 146), UDim2.fromOffset(240, 104), 853)
	local _llIl1ll1l = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_llIl1ll1l.Parent = _Il1Ill1ll.content
	_llIl1ll1l.BackgroundTransparency = 1
	_llIl1ll1l.Size = UDim2.new(1, 0, 1, 0)
	_llIl1ll1l.Font = F
	_llIl1ll1l.TextSize = 14
	_llIl1ll1l.TextColor3 = T.Tx
	_llIl1ll1l.TextStrokeColor3 = Color3.new(0, 0, 0)
	_llIl1ll1l.TextStrokeTransparency = 0.5
	_llIl1ll1l.TextXAlignment = Enum.TextXAlignment.Left
	_llIl1ll1l.TextYAlignment = Enum.TextYAlignment.Top
	_llIl1ll1l.TextWrapped = true
	_llIl1ll1l.LineHeight = 1.3
	_Illl1I1I1(_lIl1IlI1I1, _D("\167\128\149\128\129\135\212\188\161\176"), false, function(v)
		_Il1Ill1ll.frame.Visible = v
		_lll11ll1IlIll(_D("\167\128\149\128\129\135\212\188\161\176"), v)
	end, 4)
	_Illl1I1I1(_lIl1IlI1I1, _D("\184\155\151\159\212\188\161\176\212\164\155\135\157\128\157\155\154"), false, function(v)
		hudLocked = v
		_lll11ll1IlIll(_D("\188\161\176\212\152\155\151\159"), v)
	end, 5)
	_11I1IIll11Il = _Illl1I1I1(_lIl1IlI1I1, _D("\161\154\152\155\151\159\212\185\155\129\135\145"), false, function(v)
		_1l1ll1I111lllll = v
		_lll11ll1IlIll(_D("\185\155\129\135\145\212\129\154\152\155\151\159"), v)
	end, 6, false, Enum.KeyCode.LeftAlt)

	local _ll1Il1llIl1Il11 = _lIIllIl1ll1l(_D("\179\156\155\135\128\212\166\149\144\149\134"), UDim2.new(0.5, -105, 1, -240), UDim2.fromOffset(210, 230), 854)
	local _11IlIll1Il = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_11IlIll1Il.Parent = _ll1Il1llIl1Il11.content
	_11IlIll1Il.Position = UDim2.new(0, 0, 0, 0)
	_11IlIll1Il.Size = UDim2.new(1, 0, 0, 18)
	_11IlIll1Il.BackgroundTransparency = 1
	_11IlIll1Il.Font = FM
	_11IlIll1Il.TextSize = 13
	_11IlIll1Il.TextColor3 = T.Tx
	_11IlIll1Il.TextStrokeColor3 = Color3.new(0, 0, 0)
	_11IlIll1Il.TextStrokeTransparency = 0.5
	_11IlIll1Il.TextTruncate = Enum.TextTruncate.AtEnd
	_11IlIll1Il.Text = _D("\166\155\155\153\206\212\217\217")
	local _IlllIIIIl1 = Instance.new(_D("\178\134\149\153\145"))
	_IlllIIIIl1.Parent = _ll1Il1llIl1Il11.content
	_IlllIIIIl1.AnchorPoint = Vector2.new(0.5, 0)
	_IlllIIIIl1.Position = UDim2.new(0.5, 0, 0, 24)
	_IlllIIIIl1.Size = UDim2.new(0, 140, 0, 140)
	_IlllIIIIl1.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	_IlllIIIIl1.BackgroundTransparency = 0.15
	Corner(_IlllIIIIl1, 999)
	Stroke(_IlllIIIIl1, T.Bd2, 1.2, 0.2)
	local _I1I1lIlIllIlI1 = Instance.new(_D("\178\134\149\153\145"))
	_I1I1lIlIllIlI1.Parent = _IlllIIIIl1
	_I1I1lIlIllIlI1.AnchorPoint = Vector2.new(0.5, 0.5)
	_I1I1lIlIllIlI1.Position = UDim2.new(0.5, 0, 0.5, 0)
	_I1I1lIlIllIlI1.Size = UDim2.new(0.6, 0, 0.6, 0)
	_I1I1lIlIllIlI1.BackgroundTransparency = 1
	Corner(_I1I1lIlIllIlI1, 999)
	Stroke(_I1I1lIlIllIlI1, T.Bd2, 1, 0.55)
	local _1lIll1l11I = Instance.new(_D("\178\134\149\153\145"))
	_1lIll1l11I.Parent = _IlllIIIIl1
	_1lIll1l11I.AnchorPoint = Vector2.new(0.5, 0.5)
	_1lIll1l11I.Position = UDim2.new(0.5, 0, 0.5, 0)
	_1lIll1l11I.Size = UDim2.new(0, 8, 0, 8)
	_1lIll1l11I.BackgroundColor3 = T.White
	Corner(_1lIll1l11I, 4)
	local _1II111lII11IlI = Instance.new(_D("\178\134\149\153\145"))
	_1II111lII11IlI.Parent = _IlllIIIIl1
	_1II111lII11IlI.AnchorPoint = Vector2.new(0.5, 0.5)
	_1II111lII11IlI.Position = UDim2.new(0.5, 0, 0.5, 0)
	_1II111lII11IlI.Size = UDim2.new(0, 14, 0, 14)
	_1II111lII11IlI.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	_1II111lII11IlI.Visible = false
	Corner(_1II111lII11IlI, 7)
	Stroke(_1II111lII11IlI, T.White, 1, 0.2)
	local _I1lIlI11IIIl = Instance.new(_D("\160\145\140\128\184\149\150\145\152"))
	_I1lIlI11IIIl.Parent = _ll1Il1llIl1Il11.content
	_I1lIlI11IIIl.AnchorPoint = Vector2.new(0.5, 1)
	_I1lIlI11IIIl.Position = UDim2.new(0.5, 0, 1, 0)
	_I1lIlI11IIIl.Size = UDim2.new(1, 0, 0, 16)
	_I1lIlI11IIIl.BackgroundTransparency = 1
	_I1lIlI11IIIl.Font = FM
	_I1lIlI11IIIl.TextSize = 13
	_I1lIlI11IIIl.TextColor3 = T.Tx
	_I1lIlI11IIIl.TextStrokeColor3 = Color3.new(0, 0, 0)
	_I1lIlI11IIIl.TextStrokeTransparency = 0.5
	_I1lIlI11IIIl.Text = _D("\131\149\157\128\157\154\147\218\218\218")
	_Illl1I1I1(_lIl1IlI1I1, _D("\179\156\155\135\128\212\166\149\144\149\134\212\188\161\176"), false, function(v)
		_ll1Il1llIl1Il11.frame.Visible = v
		_lll11ll1IlIll(_D("\179\156\155\135\128\212\134\149\144\149\134\212\188\161\176"), v)
	end, 7)
	do
		local _1II1l11Il = tick()
		_1I111I1ll(_lII111IIIIllI.Heartbeat:Connect(function()
			if tick() - _1II1l11Il < 0.15 then return end
			_1II1l11Il = tick()
			local _Ill11Il11l = plr.Character
			local _1I1llIlIlI = _Ill11Il11l and _Ill11Il11l:FindFirstChild(_D("\188\129\153\149\154\155\157\144\166\155\155\128\164\149\134\128"))
			if _1I1llIlIlI and S.Ghost then
				local _l1lI1I11Il11ll1, _lI1IlI111l1Il = pcall(function()
					return _1I1llIlIlI.CFrame:PointToObjectSpace(S.Ghost:GetPivot().Position)
				end)
				if _l1lI1I11Il11ll1 then
					local _IlI1llIlll = Vector3.new(_lI1IlI111l1Il.X, 0, _lI1IlI111l1Il.Z).Magnitude
					local _1lll1llll = math.min(_IlI1llIlll, 120) / 120 * 62
					local _IIlll11III1, _Il1l1l11IIIlI = 0, 0
					if _IlI1llIlll > 0.01 then
						_IIlll11III1 = (_lI1IlI111l1Il.X / _IlI1llIlll) * _1lll1llll
						_Il1l1l11IIIlI = (_lI1IlI111l1Il.Z / _IlI1llIlll) * _1lll1llll
					end
					_1II111lII11IlI.Visible = true
					_1II111lII11IlI.Position = UDim2.new(0.5, _IIlll11III1, 0.5, _Il1l1l11IIIlI)
					_I1lIlI11IIIl.Text = tostring(math.floor(_IlI1llIlll)) .. _D("\212\135\128\129\144\135")
					_11IlIll1Il.Text = _D("\166\155\155\153\206\212") .. tostring(S.Ghost:GetAttribute(_D("\183\129\134\134\145\154\128\166\155\155\153")) or _D("\161\154\159\154\155\131\154"))
				end
			else
				_1II111lII11IlI.Visible = false
				_I1lIlI11IIIl.Text = S.Ready and _D("") or _D("\131\149\157\128\157\154\147\212\146\155\134\212\134\155\129\154\144\218\218\218")
				_11IlIll1Il.Text = _D("\166\155\155\153\206\212\217\217")
			end
		end))
	end

	do
		local _11l1ll111lll = tick()
		_1I111I1ll(_lII111IIIIllI.Heartbeat:Connect(function()
			if tick() - _11l1ll111lll < 0.5 then return end
			_11l1ll111lll = tick()
			_llIl1ll1l.Text = _D("\185\145\154\129\206\212") .. (_1l1l1l1Il.Visible and _D("\155\132\145\154") or _D("\151\152\155\135\145\144"))
				.. _D("\254\188\161\176\206\212") .. (hudLocked and _D("\152\155\151\159\145\144") or _D("\129\154\152\155\151\159\145\144"))
				.. _D("\254\166\155\129\154\144\206\212") .. (S.Ready and _D("\149\151\128\157\130\145") or _D("\131\149\157\128\157\154\147"))
		end))
	end
end

if S._LoadConfig then S._LoadConfig() end


task.spawn(function()
	task.wait(30)
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA(_D("\185\155\144\145\152")) and v.Name == _D("\177\140\157\128\176\155\155\134") then
			if v:GetAttribute(_D("\176\155\155\134\183\152\155\135\145\144")) ~= false then
				_lIIIl11lllllI():WaitForChild(_D("\183\152\157\145\154\128\183\156\149\154\147\145\176\155\155\134\167\128\149\128\145")):FireServer(v:WaitForChild(_D("\176\155\155\134")))
			end
			break
		end
	end
end)
