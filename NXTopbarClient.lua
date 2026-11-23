local Players=game:GetService("Players")
local TS=game:GetService("TweenService")
local Lighting=game:GetService("Lighting")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local SoundService=game:GetService("SoundService")
local RS=game:GetService("ReplicatedStorage")
local HS=game:GetService("HttpService")
local LocS=game:GetService("LocalizationService")
local plr=Players.LocalPlayer
local gui=script.Parent
local M=require(gui:WaitForChild("NXUI"))
local new,text=M.new,M.text

------------------------------------------------------------------ ICON PNG
-- Upload tiap PNG di folder icons/ ke Roblox (Creator Hub > Assets > Decal/Image),
-- lalu isi ID-nya di sini. Kalau masih 0, otomatis pakai emoji lama.
local ICON_ID={
	SETTING=74362367347649, MUSIK=111168729360634, PEMAIN=107151944904052, SHOP=106726742060365, TARI=108895560112294,
	STICKER=135468070457331, SKY=117269734118535, FREECAM=94590846432599, SERVER=0,
}
local function iconImage(key,parent,props)
	local id=ICON_ID[key]
	if not id or id==0 then return nil end
	props=props or {}
	props.BackgroundTransparency=1
	props.Image="rbxassetid://"..id
	props.ScaleType=Enum.ScaleType.Fit
	return new("ImageLabel",props,parent)
end

------------------------------------------------------------------ setting
local S={lang="AUTO",gfx="HD",partikel=true,bayangan=true,hide=false,vol=0.5,shuffle=false,loop=false}
do local t0=os.clock()
	while not plr:GetAttribute("NXSettingLoaded") and os.clock()-t0<6 do task.wait(.2) end
	local raw=plr:GetAttribute("NXSetting")
	if raw and raw~="" then local ok,d=pcall(HS.JSONDecode,HS,raw)
		if ok and type(d)=="table" then for k,v in pairs(d) do if S[k]~=nil and type(v)==type(S[k]) then S[k]=v end end end end
end
local remFolder=RS:WaitForChild("NXRemote",10)
local remote=remFolder and remFolder:FindFirstChild("SimpanSetting")
local queued=false
local function save() if queued or not remote then return end queued=true
	task.delay(1.5,function() queued=false remote:FireServer(S) end) end

------------------------------------------------------------------ bahasa
local LANG={
	ID={menu={"SETTING","MUSIK","PEMAIN","SHOP","TARI","STICKER","SKY","FREECAM","SERVER"},
		settings="SETTINGS",sec_lang="BAHASA / LANGUAGE",auto="OTOMATIS",ind="INDONESIA",eng="ENGLISH",
		note_lang="Otomatis mengikuti bahasa Roblox kamu. Pilihanmu tersimpan.",
		sec_gfx="GRAFIS",gfx_HD="HD: semua efek, bayangan, lampu hias, dan efek layar menyala. Paling bagus.",
		gfx_MEDIUM="MEDIUM: bayangan dan partikel menyala, efek layar dimatikan. Seimbang.",
		gfx_LOW="LOW: tanpa bayangan, partikel, efek layar, dan lampu hias. Paling ringan untuk HP.",
		sec_view="TAMPILAN",fx="Efek Partikel",fx_d="Nyalakan/matikan efek partikel (VFX)",
		sh="Bayangan",sh_d="Bayangan dari matahari dan objek",hide="Sembunyikan Pemain Lain",hide_d="Pemain lain tidak terlihat di layarmu",
		music="MUSIK",empty="Playlist masih kosong.\nIsi ReplicatedStorage.NXPlaylist dengan ID lagumu.",all="SEMUA",nosong="Belum ada lagu",
		vol="VOL",players="PEMAIN",soon="Segera hadir",online="ONLINE",sky="LANGIT",server="SERVER",
		pagi="Pagi",siang="Siang",sore="Sore",malam="Malam",srv_p="Pemain",srv_age="Umur server",srv_ping="Ping",rejoin="Rejoin server",menit="menit"},
	EN={menu={"SETTINGS","MUSIC","PLAYERS","SHOP","DANCE","STICKER","SKY","FREECAM","SERVER"},
		settings="SETTINGS",sec_lang="BAHASA / LANGUAGE",auto="AUTO",ind="INDONESIA",eng="ENGLISH",
		note_lang="Auto follows your Roblox language. Your choice is saved.",
		sec_gfx="GRAPHICS",gfx_HD="HD: all effects, shadows, decorative lights and screen effects on. Best looking.",
		gfx_MEDIUM="MEDIUM: shadows and particles on, screen effects off. Balanced.",
		gfx_LOW="LOW: no shadows, particles, screen effects or decorative lights. Lightest for phones.",
		sec_view="DISPLAY",fx="Particle Effects",fx_d="Turn particle effects (VFX) on/off",
		sh="Shadows",sh_d="Shadows from the sun and objects",hide="Hide Other Players",hide_d="Other players are invisible on your screen",
		music="MUSIC",empty="The playlist is empty.\nFill ReplicatedStorage.NXPlaylist with your song IDs.",all="ALL",nosong="No song yet",
		vol="VOL",players="PLAYERS",soon="Coming soon",online="ONLINE",sky="SKY",server="SERVER",
		pagi="Morning",siang="Noon",sore="Evening",malam="Night",srv_p="Players",srv_age="Server age",srv_ping="Ping",rejoin="Rejoin server",menit="min"},
}
local function lang() if S.lang=="AUTO" then return string.lower(LocS.RobloxLocaleId or ""):sub(1,2)=="id" and "ID" or "EN" end return S.lang end
local function T(k) return LANG[lang()][k] or LANG.ID[k] or k end
local langListeners={}
local function onLang(fn) table.insert(langListeners,fn) end
local function fireLang() for _,fn in ipairs(langListeners) do task.spawn(fn) end end

------------------------------------------------------------------ grafis
local FX={ParticleEmitter=true,Beam=true,Trail=true,Smoke=true,Fire=true,Sparkles=true}
local LIGHT={PointLight=true,SpotLight=true,SurfaceLight=true}
local orig=setmetatable({},{__mode="k"})
local function wanted(o)
	local c=o.ClassName
	if FX[c] then return S.partikel and S.gfx~="LOW" end
	if LIGHT[c] then return S.gfx~="LOW" end
	if o:IsA("PostEffect") and o.Parent==Lighting then return S.gfx=="HD" end
	return nil end
local function applyObj(o)
	local w=wanted(o) if w==nil then return end
	if orig[o]==nil then orig[o]=o.Enabled end
	o.Enabled= w and orig[o] or false end
local function applyGfx()
	Lighting.GlobalShadows= S.bayangan and S.gfx~="LOW"
	for _,root in ipairs({workspace,Lighting}) do
		local n=0 for _,o in ipairs(root:GetDescendants()) do applyObj(o) n+=1 if n%3000==0 then task.wait() end end end end
workspace.DescendantAdded:Connect(function(o) if FX[o.ClassName] or LIGHT[o.ClassName] then task.defer(applyObj,o) end end)

local function applyHide()
	for _,o in ipairs(Players:GetPlayers()) do if o~=plr and o.Character then
		for _,d in ipairs(o.Character:GetDescendants()) do
			if d:IsA("BasePart") or d:IsA("Decal") then d.LocalTransparencyModifier= S.hide and 1 or 0 end end end end end
local function hookChar(o) o.CharacterAdded:Connect(function() task.wait(1) if S.hide then applyHide() end end) end
for _,o in ipairs(Players:GetPlayers()) do if o~=plr then hookChar(o) end end
Players.PlayerAdded:Connect(hookChar)

------------------------------------------------------------------ topbar
local root=new("Frame",{Name="Root",BackgroundTransparency=1,AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,6),Size=UDim2.fromOffset(700,190)},gui)
local scale=new("UIScale",{},root)
local function rescale() scale.Scale=math.clamp(workspace.CurrentCamera.ViewportSize.X/780,.5,1) end
local function rescale2() rescale() M.panelTop=math.floor(136*scale.Scale) end
rescale2() workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(rescale2)

local bar=new("Frame",{Name="MenuBar",AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,0),Size=UDim2.fromOffset(640,70),BorderSizePixel=0},root)
M.darkFill(bar,Color3.fromRGB(44,38,46),M.DARK) M.corner(bar,35) M.stroke(bar,3)
local innerBar=new("Frame",{BackgroundTransparency=1,Position=UDim2.fromOffset(5,5),Size=UDim2.new(1,-10,1,-10)},bar) M.corner(innerBar,30) M.stroke(innerBar,1,.55)
local btnRow=new("Frame",{Name="Buttons",BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},bar)
new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Center,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},btnRow)
local endGems={M.gem(root,26,UDim2.new(.5,-322,0,35)),M.gem(root,26,UDim2.new(.5,322,0,35))}

local ICON={"⚙️","🎵","🏆","🛍️","💃","😄","☁️","🎥","📍"}
local KEYS={"SETTING","MUSIK","PEMAIN","SHOP","TARI","STICKER","SKY","FREECAM","SERVER"}
local menuLabels={}
local function makeBtn(i)
	local b=new("TextButton",{Name=KEYS[i],LayoutOrder=i*2,Size=UDim2.fromOffset(62,62),BackgroundTransparency=1,Text="",AutoButtonColor=false},btnRow)
	-- icon PNG (tanpa ring) atau fallback emoji + ring
	local target
	local img=iconImage(KEYS[i],b,{Name="Icon",AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,0),Size=UDim2.fromOffset(52,44)})
	if img then target=img
	else
		local ring=new("Frame",{Size=UDim2.fromOffset(38,38),AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,4),BorderSizePixel=0},b)
		M.darkFill(ring,Color3.fromRGB(58,48,52),Color3.fromRGB(18,14,18)) M.corner(ring) M.stroke(ring,2)
		text(ring,ICON[i],21,M.BODY,Color3.new(1,1,1),{Size=UDim2.fromScale(1,1)})
		target=ring
	end
	local t=M.goldText(text(b,"",10,M.BODY,nil,{Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,1,-15)}))
	menuLabels[i]=t
	local us=new("UIScale",{},target)
	b.MouseEnter:Connect(function() TS:Create(us,TweenInfo.new(.12),{Scale=1.15}):Play() end)
	b.MouseLeave:Connect(function() TS:Create(us,TweenInfo.new(.12),{Scale=1}):Play() end)
	if i==1 then local sep=new("Frame",{Size=UDim2.fromOffset(2,40),BorderSizePixel=0,LayoutOrder=3},btnRow) M.goldFill(sep) end
	return b end
local function renderMenu() local L=T("menu") for i,t in ipairs(menuLabels) do t.Text=L[i] end end

local clock=new("Frame",{Name="Clock",AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,80),Size=UDim2.fromOffset(260,36),BorderSizePixel=0},root)
M.darkFill(clock,Color3.fromRGB(44,38,46),M.DARK) M.corner(clock) M.stroke(clock,2)
local cg={M.gem(clock,14,UDim2.new(0,0,.5,0)),M.gem(clock,14,UDim2.new(1,0,.5,0))}
local jam=M.goldText(text(clock,"00:00",22,M.TITLE,nil,{Size=UDim2.new(0,70,1,0),Position=UDim2.fromOffset(16,0)}))
local dot=new("Frame",{Size=UDim2.fromOffset(6,6),Position=UDim2.new(0,90,.5,-3),BackgroundColor3=M.GOLD,BorderSizePixel=0},clock)
local tgl=text(clock,"",11,M.BODY,M.CREAM,{Size=UDim2.new(1,-110,1,0),Position=UDim2.fromOffset(102,0),TextXAlignment=Enum.TextXAlignment.Left})
local HARI={ID={"MINGGU","SENIN","SELASA","RABU","KAMIS","JUMAT","SABTU"},EN={"SUNDAY","MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY","SATURDAY"}}
local BULAN={ID={"JANUARI","FEBRUARI","MARET","APRIL","MEI","JUNI","JULI","AGUSTUS","SEPTEMBER","OKTOBER","NOVEMBER","DESEMBER"},
	EN={"JANUARY","FEBRUARY","MARCH","APRIL","MAY","JUNE","JULY","AUGUST","SEPTEMBER","OCTOBER","NOVEMBER","DECEMBER"}}
task.spawn(function() while gui.Parent do local d=os.date("*t") local l=lang()
	jam.Text=string.format("%02d:%02d",d.hour,d.min) tgl.Text=string.format("%s, %d %s %d",HARI[l][d.wday],d.day,BULAN[l][d.month],d.year)
	dot.Visible=not dot.Visible task.wait(1) end end)

local tog=new("TextButton",{Name="Toggle",AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,122),Size=UDim2.fromOffset(56,22),Text="",AutoButtonColor=false},root)
M.darkFill(tog,Color3.fromRGB(44,38,46),M.DARK) M.corner(tog) M.stroke(tog,2)
local chev=new("Frame",{BackgroundTransparency=1,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(16,10)},tog)
for _,sgn in ipairs({-1,1}) do local l=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,sgn*4,.5,0),Size=UDim2.fromOffset(11,2.5),Rotation=sgn*35,BorderSizePixel=0,BackgroundColor3=M.GOLD},chev) M.corner(l) end

-- pil "sedang diputar"
local np=new("TextButton",{Name="NowPlaying",AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,150),Size=UDim2.fromOffset(230,34),Text="",AutoButtonColor=false,BorderSizePixel=0},root)
M.darkFill(np,Color3.fromRGB(30,26,30),M.DARK) M.corner(np) M.stroke(np,1.5)
local npIc=new("Frame",{Size=UDim2.fromOffset(26,26),Position=UDim2.fromOffset(4,4),BorderSizePixel=0},np)
if not iconImage("MUSIK",np,{Name="Icon",Position=UDim2.fromOffset(2,0),Size=UDim2.fromOffset(32,34)}) then
	M.goldFill(npIc) M.corner(npIc)
	text(npIc,"🎵",14,M.BODY,Color3.new(1,1,1),{Size=UDim2.fromScale(1,1)})
else npIc:Destroy() end
local npT=text(np,"",13,M.BODY,M.CREAM,{Position=UDim2.fromOffset(38,0),Size=UDim2.new(1,-80,1,0),TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
local npDots=text(np,"• • • •",10,M.BODY,M.GOLD,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,0),Size=UDim2.fromOffset(36,34)})

local open=true
local panels={} local openP=nil
local function closeAll() if openP then openP.api.hide() openP=nil end end
local function setOpen(v) open=v chev.Rotation=v and 0 or 180
	local ti=TweenInfo.new(.25,Enum.EasingStyle.Quad)
	TS:Create(bar,ti,{Position=v and UDim2.new(.5,0,0,0) or UDim2.new(.5,0,0,-95)}):Play()
	TS:Create(clock,ti,{Position=v and UDim2.new(.5,0,0,80) or UDim2.new(.5,0,0,0)}):Play()
	TS:Create(tog,ti,{Position=v and UDim2.new(.5,0,0,122) or UDim2.new(.5,0,0,42)}):Play()
	TS:Create(np,ti,{Position=v and UDim2.new(.5,0,0,150) or UDim2.new(.5,0,0,70)}):Play()
	for _,g in ipairs(endGems) do g.Visible=v end
	if not v then closeAll() end end
tog.MouseButton1Click:Connect(function() setOpen(not open) end)

local function register(key,title,w,h,refresh)
	local p,body,api=M.panel(gui,title,w,h)
	local rec={p=p,body=body,api=api,refresh=refresh}
	api.close.MouseButton1Click:Connect(function() api.hide() if openP==rec then openP=nil end end)
	panels[key]=rec return rec end
local function toggleP(key)
	local rec=panels[key] if not rec then return end
	if openP==rec then rec.api.hide() openP=nil return end
	closeAll() if rec.refresh then rec.refresh() end rec.api.show() openP=rec end

local function card(body,txt,order,cb)
	local b,_,bg,gr=M.btn(body,{Size=UDim2.new(1,-4,0,38),LayoutOrder=order or 0,Text=txt,TextSize=14,ZIndex=4})
	gr.Color=M.darkSeq(Color3.fromRGB(46,40,48),Color3.fromRGB(22,19,24)) M.corner(bg,10) M.stroke(bg,1.5,.2)
	if not cb then b.Active=false end
	if cb then b.MouseButton1Click:Connect(function() cb(b) end) end return b end

------------------------------------------------------------------ SETTINGS
local setRec=register("SETTING","SETTINGS",460,580)
local function buildSettings()
	local b=setRec.body M.clear(b) setRec.api.title.Text=T("settings")
	M.section(b,T("sec_lang"),1)
	local _,setLang=M.pillRow(b,{{"AUTO",T("auto")},{"ID",T("ind")},{"EN",T("eng")}},2,function(k)
		S.lang=k save() renderMenu() fireLang() buildSettings() end)
	setLang(S.lang) M.note(b,T("note_lang"),3)
	M.section(b,T("sec_gfx"),4)
	local gnote
	local _,setG=M.pillRow(b,{{"HD","HD"},{"MEDIUM","MEDIUM"},{"LOW","LOW"}},5,function(k)
		S.gfx=k save() applyGfx() buildSettings() end)
	setG(S.gfx) gnote=M.note(b,T("gfx_"..S.gfx),6)
	M.section(b,T("sec_view"),7)
	M.toggle(b,T("fx")..' <font color="#F0C45C">(F)</font>',T("fx_d"),8,S.partikel,function(v) S.partikel=v save() applyGfx() end)
	M.toggle(b,T("sh"),T("sh_d"),9,S.bayangan,function(v) S.bayangan=v save() applyGfx() end)
	M.toggle(b,T("hide"),T("hide_d"),10,S.hide,function(v) S.hide=v save() applyHide() end)
end
setRec.refresh=buildSettings
UIS.InputBegan:Connect(function(i,gp) if gp then return end
	if i.KeyCode==Enum.KeyCode.F then S.partikel=not S.partikel save() applyGfx() if openP==setRec then buildSettings() end end end)

------------------------------------------------------------------ MUSIK
local okPl,PLAYLIST=pcall(function() return require(RS:WaitForChild("NXPlaylist",10)) end)
if not okPl or type(PLAYLIST)~="table" then PLAYLIST={} end
local songs={} for _,s in ipairs(PLAYLIST) do if type(s)=="table" and tonumber(s.id) and tonumber(s.id)>0 then
	table.insert(songs,{judul=tostring(s.judul or "Lagu"),id=tonumber(s.id),kategori=string.upper(tostring(s.kategori or "LAINNYA"))}) end end
local cats={"*"} do local seen={} for _,s in ipairs(songs) do if not seen[s.kategori] then seen[s.kategori]=true table.insert(cats,s.kategori) end end end

local snd=new("Sound",{Name="NXMusik",Volume=S.vol,Looped=false},SoundService)
local cur=0 local filter="*" local playing=false

local musRec=register("MUSIK","MUSIK",640,330)
local mp=musRec.p musRec.body.Visible=false
-- kiri
local L=new("Frame",{BackgroundTransparency=1,Position=UDim2.fromOffset(24,74),Size=UDim2.fromOffset(250,236),ZIndex=3},mp)
local cover=new("Frame",{Size=UDim2.fromOffset(66,66),BorderSizePixel=0,ZIndex=4},L)
if not iconImage("MUSIK",cover,{Size=UDim2.fromScale(1,1),ZIndex=5}) then
	M.goldFill(cover) M.corner(cover,12) M.plainStroke(cover,2,M.GOLD2)
	text(cover,"🎵",32,M.BODY,Color3.new(1,1,1),{Size=UDim2.fromScale(1,1),ZIndex=5})
else cover.BackgroundTransparency=1 end
local mTitle=text(L,"",17,M.BODY,M.CREAM,{Position=UDim2.fromOffset(78,6),Size=UDim2.fromOffset(172,24),TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=4})
local mSub=text(L,"",12,M.BODY,M.GOLD,{Position=UDim2.fromOffset(78,34),Size=UDim2.fromOffset(172,18),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4})
local progBar,progApi=M.slider(L,{Position=UDim2.fromOffset(4,90),Size=UDim2.new(1,-8,0,6)},function(v,drag) if snd.TimeLength>0 and not drag then snd.TimePosition=v*snd.TimeLength end end)
local tA=text(L,"00:00",11,Enum.Font.Gotham,M.DIM,{Position=UDim2.fromOffset(0,102),Size=UDim2.fromOffset(60,14),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4})
local tB=text(L,"00:00",11,Enum.Font.Gotham,M.DIM,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,102),Size=UDim2.fromOffset(60,14),TextXAlignment=Enum.TextXAlignment.Right,ZIndex=4})
local ctrl=new("Frame",{BackgroundTransparency=1,Position=UDim2.fromOffset(0,124),Size=UDim2.new(1,0,0,60),ZIndex=4},L)
new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Center,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},ctrl)
local function cbtn(txt,sz,order,gold)
	local b,lab,bg=M.btn(ctrl,{Size=UDim2.fromOffset(sz,sz),Text=txt,TextSize=math.floor(sz*.42),TextColor3=gold and M.DARK or M.GOLD,LayoutOrder=order,ZIndex=5},gold and "gold" or nil)
	M.corner(bg) M.stroke(bg,2) return b,lab end
local bShuf,lShuf=cbtn("🔀",38,1) local bPrev=cbtn("⏮",42,2) local bPlay,lPlay=cbtn("▶",58,3,true) local bNext=cbtn("⏭",42,4) local bLoop,lLoop=cbtn("🔁",38,5)
text(L,T("vol"),12,M.BODY,M.GOLD,{Position=UDim2.fromOffset(0,198),Size=UDim2.fromOffset(34,24),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4})
local function smallBtn(txt,x) local b,_,bg=M.btn(L,{Position=UDim2.fromOffset(x,198),Size=UDim2.fromOffset(24,24),Text=txt,TextSize=16,TextColor3=M.GOLD,ZIndex=5})
	M.corner(bg) M.stroke(bg,1.5) return b end
local vMinus=smallBtn("-",36)
local volBar,volApi=M.slider(L,{Position=UDim2.fromOffset(70,208),Size=UDim2.fromOffset(110,5)},function(v) S.vol=v snd.Volume=v save() end)
local vPlus=smallBtn("+",188)
local vPct=text(L,"",12,M.BODY,M.CREAM,{Position=UDim2.fromOffset(216,198),Size=UDim2.fromOffset(40,24),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4})
local div=new("Frame",{Position=UDim2.fromOffset(290,80),Size=UDim2.fromOffset(2,226),BorderSizePixel=0,BackgroundTransparency=.4,ZIndex=3},mp) M.goldFill(div)
-- kanan
local Rt=new("Frame",{BackgroundTransparency=1,Position=UDim2.fromOffset(306,74),Size=UDim2.new(1,-328,0,236),ZIndex=3},mp)
local catBar=new("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,34),ScrollBarThickness=0,AutomaticCanvasSize=Enum.AutomaticSize.X,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.X,ZIndex=4},Rt)
new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,6),VerticalAlignment=Enum.VerticalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder},catBar)
new("UIPadding",{PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,2)},catBar)
local songList=new("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.fromOffset(0,42),Size=UDim2.new(1,0,1,-42),ScrollBarThickness=4,ScrollBarImageColor3=M.GOLD,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ZIndex=4},Rt)
new("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},songList)
new("UIPadding",{PaddingRight=UDim.new(0,8)},songList)

local function fmt(t) t=math.max(0,math.floor(t or 0)) return string.format("%02d:%02d",t//60,t%60) end
local catApis={}
local renderList
local playIndex
local function renderCats()
	M.clear(catBar) catApis={}
	for i,c in ipairs(cats) do
		local label= c=="*" and T("all") or c
		local b,api=M.pill(catBar,label,{Size=UDim2.fromOffset(math.max(64,#label*8+26),28),TextSize=11,LayoutOrder=i})
		api.set(c==filter) catApis[c]=api
		b.MouseButton1Click:Connect(function() filter=c for k,a in pairs(catApis) do a.set(k==filter) end renderList() end) end end
function renderList()
	M.clear(songList)
	if #songs==0 then text(songList,T("empty"),13,M.BODY,M.DIM,{Size=UDim2.new(1,0,0,60),TextWrapped=true,ZIndex=5}) return end
	for i,s in ipairs(songs) do if filter=="*" or s.kategori==filter then
		local sel=i==cur
		local r=new("TextButton",{Size=UDim2.new(1,0,0,30),Text="",AutoButtonColor=false,BorderSizePixel=0,LayoutOrder=i,ZIndex=5,
			BackgroundColor3=sel and M.GOLD or Color3.new(0,0,0),BackgroundTransparency=sel and .78 or 1},songList) M.corner(r,8)
		text(r,string.format("%02d",i),12,Enum.Font.Gotham,M.DIM,{Position=UDim2.fromOffset(10,0),Size=UDim2.new(0,26,1,0),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6})
		text(r,s.judul,14,sel and M.BODY or Enum.Font.GothamMedium,sel and M.GOLD or M.CREAM,{Position=UDim2.fromOffset(42,0),Size=UDim2.new(1,-50,1,0),TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=6})
		r.MouseButton1Click:Connect(function() playIndex(i) end) end end end

local function renderNow()
	local s=songs[cur]
	mTitle.Text= s and s.judul or T("nosong")
	mSub.Text= s and string.format("%s  -  %02d/%02d",s.kategori,cur,#songs) or (#songs.." lagu")
	npT.Text= s and s.judul or T("nosong")
	lPlay.Text= playing and "⏸" or "▶"
	lShuf.TextTransparency= S.shuffle and 0 or .6
	lLoop.TextTransparency= S.loop and 0 or .6
	volApi.set(S.vol) vPct.Text=math.floor(S.vol*100+.5).."%"
end
function playIndex(i)
	if #songs==0 then return end
	cur=((i-1)%#songs)+1
	snd:Stop() snd.SoundId="rbxassetid://"..songs[cur].id snd.TimePosition=0 snd:Play() playing=true
	renderNow() if musRec.p.Visible then renderList() end end
local function step(d)
	if #songs==0 then return end
	if S.shuffle and #songs>1 then local n repeat n=math.random(1,#songs) until n~=cur playIndex(n) else playIndex(cur+d) end end
bPlay.MouseButton1Click:Connect(function()
	if #songs==0 then return end
	if cur==0 then playIndex(1) return end
	if playing then snd:Pause() playing=false else snd:Resume() playing=true end renderNow() end)
bNext.MouseButton1Click:Connect(function() step(1) end)
bPrev.MouseButton1Click:Connect(function() if snd.TimePosition>3 then snd.TimePosition=0 else step(-1) end end)
bShuf.MouseButton1Click:Connect(function() S.shuffle=not S.shuffle save() renderNow() end)
bLoop.MouseButton1Click:Connect(function() S.loop=not S.loop save() renderNow() end)
vMinus.MouseButton1Click:Connect(function() S.vol=math.clamp(math.floor(S.vol*10+.5)/10-.1,0,1) snd.Volume=S.vol save() renderNow() end)
vPlus.MouseButton1Click:Connect(function() S.vol=math.clamp(math.floor(S.vol*10+.5)/10+.1,0,1) snd.Volume=S.vol save() renderNow() end)
snd.Ended:Connect(function() if S.loop then snd.TimePosition=0 snd:Play() else step(1) end end)
np.MouseButton1Click:Connect(function() toggleP("MUSIK") end)
musRec.refresh=function() musRec.api.title.Text=T("music") renderCats() renderList() renderNow() end
task.spawn(function() local k=0 while gui.Parent do task.wait(.25) k+=1
	if snd.TimeLength>0 and not progApi.dragging() then progApi.set(snd.TimePosition/snd.TimeLength) end
	tA.Text=fmt(snd.TimePosition) tB.Text=fmt(snd.TimeLength)
	if k%2==0 then npDots.Text= playing and ({"• • • •","• •   •","•   • •","  • • •"})[k//2%4+1] or "• • • •" end end end)
renderNow()
if #songs>0 then task.delay(2,function() if cur==0 then playIndex(S.shuffle and math.random(1,#songs) or 1) end end) end

------------------------------------------------------------------ panel lain
local pemRec=register("PEMAIN","PEMAIN",440,480,nil)
pemRec.refresh=function() local b=pemRec.body M.clear(b) pemRec.api.title.Text=T("players")
	card(b,#Players:GetPlayers().." "..T("online"),0)
	for i,o in ipairs(Players:GetPlayers()) do card(b,o.DisplayName.."  (@"..o.Name..")",i) end end
local skyRec=register("SKY","SKY",420,400,nil)
skyRec.refresh=function() local b=skyRec.body M.clear(b) skyRec.api.title.Text=T("sky")
	for i,t in ipairs({{"pagi",7},{"siang",13},{"sore",17.5},{"malam",0}}) do card(b,T(t[1]),i,function() Lighting.ClockTime=t[2] end) end end
local srvRec=register("SERVER","SERVER",420,380,nil)
srvRec.refresh=function() local b=srvRec.body M.clear(b) srvRec.api.title.Text=T("server")
	card(b,T("srv_p")..": "..#Players:GetPlayers().." / "..Players.MaxPlayers,1)
	card(b,T("srv_age")..": "..math.floor(workspace.DistributedGameTime/60).." "..T("menit"),2)
	card(b,T("srv_ping")..": "..math.floor(plr:GetNetworkPing()*1000).." ms",3)
	card(b,T("rejoin"),4,function() game:GetService("TeleportService"):Teleport(game.PlaceId,plr) end) end
for _,k in ipairs({"SHOP","TARI","STICKER"}) do local r=register(k,k,420,300,nil)
	r.refresh=function() M.clear(r.body) card(r.body,T("soon"),1) end end

------------------------------------------------------------------ freecam
local freecam=false local fcConn local camPos local yaw,pitch=0,0
local function setFreecam(v) freecam=v local cam=workspace.CurrentCamera
	local hum=plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
	if v then closeAll() cam.CameraType=Enum.CameraType.Scriptable camPos=cam.CFrame.Position local _,y=cam.CFrame:ToOrientation() yaw=y pitch=0
		if hum then hum:SetAttribute("NXWalk",hum.WalkSpeed) hum.WalkSpeed=0 end
		fcConn=RunService.RenderStepped:Connect(function(dt)
			if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then UIS.MouseBehavior=Enum.MouseBehavior.LockCurrentPosition
				local d=UIS:GetMouseDelta() yaw-=d.X*0.004 pitch=math.clamp(pitch-d.Y*0.004,-1.4,1.4) else UIS.MouseBehavior=Enum.MouseBehavior.Default end
			local rot=CFrame.fromOrientation(pitch,yaw,0) local mv=Vector3.zero
			if UIS:IsKeyDown(Enum.KeyCode.W) then mv+=Vector3.new(0,0,-1) end if UIS:IsKeyDown(Enum.KeyCode.S) then mv+=Vector3.new(0,0,1) end
			if UIS:IsKeyDown(Enum.KeyCode.A) then mv+=Vector3.new(-1,0,0) end if UIS:IsKeyDown(Enum.KeyCode.D) then mv+=Vector3.new(1,0,0) end
			if UIS:IsKeyDown(Enum.KeyCode.E) then mv+=Vector3.new(0,1,0) end if UIS:IsKeyDown(Enum.KeyCode.Q) then mv+=Vector3.new(0,-1,0) end
			camPos+=rot:VectorToWorldSpace(mv)*dt*40 cam.CFrame=CFrame.new(camPos)*rot end)
	else if fcConn then fcConn:Disconnect() fcConn=nil end UIS.MouseBehavior=Enum.MouseBehavior.Default cam.CameraType=Enum.CameraType.Custom
		if hum then hum.WalkSpeed=hum:GetAttribute("NXWalk") or 16 end end end

------------------------------------------------------------------ tombol menu
for i,k in ipairs(KEYS) do local btn=makeBtn(i)
	btn.MouseButton1Click:Connect(function() if k=="FREECAM" then setFreecam(not freecam) else toggleP(k) end end) end
renderMenu()
onLang(function() renderNow() if openP and openP.refresh then openP.refresh() end end)
task.spawn(applyGfx)
if S.hide then applyHide() end
