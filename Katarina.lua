if myHero.charName ~= "Katarina" then return end



local version = "0.25"
local SCRIPT_NAME = "Katarina"
local AUTOUPDATE = true
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"
if FileExist(SOURCELIB_PATH) then
	require("SourceLib")
else
	DOWNLOADING_SOURCELIB = true
	DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() print("Required libraries downloaded successfully, please reload") end)
end

if DOWNLOADING_SOURCELIB then print("Downloading required libraries, please wait...") return end

if AUTOUPDATE then
	 SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/fter44/ilikeman/master/"..SCRIPT_NAME..".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/fter44/ilikeman/master/VersionFiles/"..SCRIPT_NAME..".version"):CheckUpdate()
end

local RequireI = Require("SourceLib")
RequireI:Add("VPrediction", 	"https://raw.github.com/fter44/ilikeman/master/common/VPrediction.lua")
RequireI:Add("FTER_SOW", 		"https://raw.github.com/fter44/ilikeman/master/common/FTER_SOW.lua")
RequireI:Add("DRAW_POS_MANAGER","https://raw.github.com/fter44/ilikeman/master/common/DRAW_POS_MANAGER.lua")
RequireI:Add("ITEM_MANAGER", 	"https://raw.github.com/fter44/ilikeman/master/common/ITEM_MANAGER.lua")
RequireI:Add("LEVEL", 			"https://raw.github.com/fter44/ilikeman/master/common/LEVEL.lua")
RequireI:Check()
if RequireI.downloadNeeded == true then return end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[Menu instance]]--
local menu
--[[Libaries]]--
local VP,SOWi,STS
--[[MAIN TARGET]]--
local Target
local Target_Circle
--[[Spells]]--
local Q,W,E,R
--[[ULT]]--
local R_ON=false
local KS_R_STOP=false
--[[SPELL]]--
local SPELL_DATA={
	[_Q] =	{range = 625},
	[_W] =	{range = 375+5},
	[_E] =	{range = 650},
	[_R] =	{range = 510},
}
--[[Kill Str Manager]]--
local KILLTEXTS
--[[
██╗    ███╗   ██╗    ██╗    ████████╗
██║    ████╗  ██║    ██║    ╚══██╔══╝
██║    ██╔██╗ ██║    ██║       ██║   
██║    ██║╚██╗██║    ██║       ██║   
██║    ██║ ╚████║    ██║       ██║   
╚═╝    ╚═╝  ╚═══╝    ╚═╝       ╚═╝   
                                     
--]]
do
function Load_Menu()
	menu = scriptConfig("Katarina", "Katarina")
	
	--SPELLS
	menu:addSubMenu("Q", "Q")	
		menu.Q:addParam("ks", "KS Q", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("combo", "Q@Combo", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("harass", "Q@harass", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("farm", "Q@farm", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("laneclear", "Q@laneclear", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("jungle", "Q@jungle", SCRIPT_PARAM_ONOFF, true)
	menu:addSubMenu("W", "W") 
		menu.W:addParam("ks", "KS W", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("combo", "W@Combo", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("harass", "W@harass", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("farm", "W@farm", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("laneclear", "W@laneclear", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("jungle", "W@jungle", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("Q", "Cast FterQ", SCRIPT_PARAM_ONOFF, true)
	menu:addSubMenu("E", "E")				
		menu.E:addParam("ks", "KS E", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("combo", "E@Combo", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("harass", "E@harass", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("farm", "E@farm", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("laneclear", "E@laneclear", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("jungle", "E@jungle", SCRIPT_PARAM_ONOFF, true)
	--	menu.E:addParam("gap", "Flee from Gapcloser", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("Q", "Cast FterQ", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("cast", "Manual Cast",SCRIPT_PARAM_ONKEYDOWN,false,string.byte("A"))
	menu:addSubMenu("R", "R")		
		menu.R:addParam("ks", "KS R", SCRIPT_PARAM_ONOFF, true)
		menu.R:addParam("combo", "R@Combo", SCRIPT_PARAM_ONOFF, true)
		menu.R:addParam("Q", "DONT USE BEFORE Q", SCRIPT_PARAM_ONOFF, true)
		menu.R:addParam("W", "DONT USE BEFORE W", SCRIPT_PARAM_ONOFF, true)
		menu.R:addParam("E", "DONT USE BEFORE Q", SCRIPT_PARAM_ONOFF, true)
		menu.R:addParam("stop", "Stop  - KSable", SCRIPT_PARAM_ONOFF, true)
		menu.R:addParam("stop2", "Stop - No enemy near", SCRIPT_PARAM_ONOFF, true)
	--OW
	menu:addSubMenu("Orbwalker", "SOW")
		SOWi:LoadToMenu(menu.SOW)	
	--TS
	menu:addSubMenu("Target selector", "STS")
		STS:AddToMenu(menu.STS)	
	
	--ITEMS
	menu:addSubMenu("Items","Items")
		IM=ITEM_MANAGER(menu.Items,STS)
		
	--AntiGapcloser
	--[[
	menu:addSubMenu("AntiGapcloser","AG")
		AntiGapcloser(menu.AG, function(unit,data)			
			if menu.E.gap and E:IsReady() and E:IsInRange(unit) then
				E:Cast(unit)
			end
		end)	
		]]
	--DRAWING
	menu:addSubMenu("Drawings", "Drawings")
		local DManager = DrawManager()
		DManager:CreateCircle(myHero, SPELL_DATA[_Q ].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"Q range", true, true, true)		
		DManager:CreateCircle(myHero, SPELL_DATA[_W ].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"W range", true, true, true)		
		DManager:CreateCircle(myHero, SPELL_DATA[_E ].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"E range", true, true, true)		
		DManager:CreateCircle(myHero, SPELL_DATA[_R ].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"R range", true, true, true)	
		menu.Drawings:addSubMenu("KillTexts","KillTexts")
			KILLTEXTS=TEXTPOS_HPBAR(menu.Drawings.KillTexts,18,0,30)	
		Target_Circle=_Circle(myHero,200):AddToMenu(menu.Drawings, "Target Circle", true, true, true)
	--EXTRA
	menu:addSubMenu("Extra menu", "Extras")
		menu.Extras:addParam("Debug", "Debug", SCRIPT_PARAM_ONOFF, false)				
	--KEY
	menu:addParam("combo", "combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('C'))		menu:permaShow("combo")
	menu:addParam("harass", "harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('X')) 		menu:permaShow("harass")
	menu:addParam("farm", "farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('Z'))			menu:permaShow("farm")
	menu:addParam("laneclear", "laneclear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('V'))menu:permaShow("laneclear")
	menu:addParam("jungle", "jungle", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('V'))		menu:permaShow("jungle")
end
function SetLibrary()	
	VP = VPrediction()	SOWi = SOW(VP)	STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC) 
	
	function SOW:BonusDamage(minion) --MARK MAGIC DAMAGE: 15 / 30 / 45 / 60 / 75 (+ 15% AP)
		local BONUS=0
		if IsQBuffed then
			BONUS = myHero:CalcMagicDamage(minion, myHero:GetSpellData(_Q).level*15 + 0.15*myHero.ap   )
		end
		return BONUS
	end	
	Spell.VP=VP
	function Spell:IsInRangeAdv(target, from)--fter44		
		return (self.range+self.VP:GetHitBox(target))^2 >= GetDistanceSqr(target, from or self.sourcePosition)
	end
	
	
	Q=Spell(_Q,SPELL_DATA[_Q].range)
	W=Spell(_W,SPELL_DATA[_W].range)
	E=Spell(_E,SPELL_DATA[_E].range)
	R=Spell(_R,SPELL_DATA[_R].range)
	
end
function OnLoad()
	SetLibrary()
	Load_Menu()
	
	AddTickCallback(OnTick2)
	AddDrawCallback(OnDraw2)
end
end


function OnTick2()
	KD()
	KS()

	
	if menu.R.stop2 and R_ON and CountEnemyHeroInRange(SPELL_DATA[_R].range+100)==0 then
		Print("R STOP - no enemies near")
		R_ON=false
	end
	if R_ON then
		return
	end
	
	if menu.farm then
		FARM()
	end
	
	if menu.laneclear then
		LANECLEAR()
	end
	
	if menu.jungle then
		JUNGLE()
	end
	

	Target = STS:GetTarget(SPELL_DATA[_E].range) or STS:GetTarget(SPELL_DATA[_Q].range) or STS:GetTarget(SPELL_DATA[_W].range)
	if not Target or not ValidTarget(Target) then return end
	
	
	if menu.combo then		
		if Q:IsReady() and menu.Q.combo then
			CAST_Q(Target)
		end
		if W:IsReady() and menu.W.combo then
			CAST_W(Target)
		end
		if E:IsReady() and (menu.E.combo or menu.E.cast) then
			CAST_E(Target)
		end
		if R:IsReady() and menu.R.combo then
			CAST_R(Target,2)
		end
		
		return
	end
	if menu.harass then 
		
		if Q:IsReady() and menu.Q.harass then
			CAST_Q(Target)
		end
		if W:IsReady() and menu.W.harass then
			CAST_W(Target)
		end
		if E:IsReady() and (menu.E.harass or menu.E.cast) then
			CAST_E(Target)
		end
		
		return 
	end
end
--[[
██████╗     ██████╗      █████╗         ██╗    ██╗
██╔══██╗    ██╔══██╗    ██╔══██╗        ██║    ██║
██║  ██║    ██████╔╝    ███████║        ██║ █╗ ██║
██║  ██║    ██╔══██╗    ██╔══██║        ██║███╗██║
██████╔╝    ██║  ██║    ██║  ██║        ╚███╔███╔╝
╚═════╝     ╚═╝  ╚═╝    ╚═╝  ╚═╝         ╚══╝╚══╝ 
                                                  
--]]
function OnDraw2()
	if ValidTarget(Target) then
		Target_Circle.position=Target
		Target_Circle:Draw()
	end
	
	if menu.Extras.Debug then
		DrawText('R_ON ' .. tostring(R_ON), 25, 350, 350, ARGB(255,0,255,0))
	end
end
--[[
 ▄████▄      ▄▄▄           ██████    ▄▄▄█████▓
▒██▀ ▀█     ▒████▄       ▒██    ▒    ▓  ██▒ ▓▒
▒▓█    ▄    ▒██  ▀█▄     ░ ▓██▄      ▒ ▓██░ ▒░
▒▓▓▄ ▄██▒   ░██▄▄▄▄██      ▒   ██▒   ░ ▓██▓ ░ 
▒ ▓███▀ ░    ▓█   ▓██▒   ▒██████▒▒     ▒██▒ ░ 
░ ░▒ ▒  ░    ▒▒   ▓▒█░   ▒ ▒▓▒ ▒ ░     ▒ ░░   
  ░  ▒        ▒   ▒▒ ░   ░ ░▒  ░ ░       ░    
░             ░   ▒      ░  ░  ░       ░      
░ ░               ░  ░         ░              
░                                             
--]] 
do
function CAST_Q(target)	
	if Q:IsInRangeAdv(target) then
		return Q:Cast(target)==SPELLSTATE_TRIGGERED
	end
end
function CAST_W(target,force)	
	--[[local pos = VP:GetPredictedPos(target, SPELL_DATA[_W].delay, SPELL_DATA[_W].speed, myHero)	
	if (force or not menu.W.Q or not Q:IsReady()) and W:IsInRange(pos) then--for Q mark
		return W:Cast()==SPELLSTATE_TRIGGERED
	end]]	
	if (force or not menu.W.Q or not Q:IsReady()) and W:IsInRange(target) then--for Q mark
		return W:Cast()==SPELLSTATE_TRIGGERED
	end
end
function CAST_E(target,force)
	if (force or not menu.E.Q or not Q:IsReady()) and E:IsInRangeAdv(target) then--for Q mark
		return E:Cast(target)==SPELLSTATE_TRIGGERED
	end
end
function CAST_R(target,time) --full hit time==2.5
	if (Q:IsReady() and menu.R.Q) or (W:IsReady() and menu.R.W) or (E:IsReady() and menu.R.E) then --Do not cast R if Q,W,E is Ready
		return
	end
	time=time or 0
	if time==0 or GET_R_HIT(target)>time then
		return R:Cast()==SPELLSTATE_TRIGGERED
	end
end
function GET_R_HIT(target)	
	local Range = R.range+VP:GetHitBox(target)
	local Distance = GetDistance(target)
	if Range>Distance then
		local Hit_Time=(Range-Distance)/target.ms
		return Hit_Time/0.25 --Full cast is( 2.5s : 10hit) == (0.25s : 1 hit)
	end
	
	return 0
end
function GET_R_REAL_DAMAGE(target,hit)
	return getDmg("R",target,myHero)*( hit or GET_R_HIT(target) )
end
end
--[[
██╗  ██╗    ██╗    ██╗         ██╗     
██║ ██╔╝    ██║    ██║         ██║     
█████╔╝     ██║    ██║         ██║     
██╔═██╗     ██║    ██║         ██║     
██║  ██╗    ██║    ███████╗    ███████╗
╚═╝  ╚═╝    ╚═╝    ╚══════╝    ╚══════╝
                                       
--]]
do
local KD_nexttick=0
function KD()
	if os.clock() < KD_nexttick then return end
	KD_nexttick = os.clock()+0.2
	
	for _,enemy in pairs(GetEnemyHeroes()) do
		if not ValidTarget(enemy) then return end
		local Q_MARK = Q:IsReady() and getDmg("Q", enemy, myHero, 2)
		local Qd 	 = Q:IsReady() and getDmg("Q",enemy,myHero)
		local Wd 	 = W:IsReady() and getDmg("W",enemy,myHero)
		local Ed 	 = E:IsReady() and getDmg("E",enemy,myHero)
		local Rd     = R:IsReady() and GET_R_REAL_DAMAGE(enemy)
		local HP 	 = enemy.health
		if Qd and HP <= Qd then
			KILLTEXTS:SET_TEXT(enemy,"Q KILL")
		elseif Wd and HP <= Wd then
			KILLTEXTS:SET_TEXT(enemy,"W KILL")
		elseif Ed and HP <= Ed then		
			KILLTEXTS:SET_TEXT(enemy,"E KILL")
		elseif Rd and HP <= Rd then
			KILLTEXTS:SET_TEXT(enemy,"R KILL")
		elseif (Qd and Wd) and HP <= Qd+Wd then
			KILLTEXTS:SET_TEXT(enemy,"Q+W KILL")
		elseif (Qd and Ed) and HP <= Qd+Ed then
			KILLTEXTS:SET_TEXT(enemy,"Q+E KILL")
		elseif (Wd and Ed) and HP <= Wd+Ed then
			KILLTEXTS:SET_TEXT(enemy,"W+E KILL")
		elseif (Qd and Wd and Ed and Rd) and HP <= Q_MARK+Qd+Wd+Ed then
			KILLTEXTS:SET_TEXT(enemy,"Q+W+E KILL")
		elseif (Qd and Wd and Ed and Rd) and HP <= Q_MARK+Qd+Wd+Ed+Rd then
			KILLTEXTS:SET_TEXT(enemy,"Q+W+E+R KILL")
		else
			local totaldmg = (Qd and (Qd+Q_MARK) or 0)+(Wd and Wd or 0)+(Ed and Ed or 0)+(Rd and Rd or 0)
			local remain=HP-totaldmg
			KILLTEXTS:SET_TEXT(enemy,string.format("%d",remain))
		end
		
	end
end
local KS_nexttick=0
function KS() 	
	if os.clock() < KS_nexttick then return end
	KS_nexttick = os.clock()+0.2
	
	if R_ON==true then
		if menu.R.stop then
			KS_R_STOP=true
		else
			return
		end
	end

	for _, enemy in pairs(GetEnemyHeroes()) do
		if not ValidTarget(enemy) then return end
		
		local Q_MARK = (Q:IsReady() and menu.Q.ks) and getDmg("Q", enemy, myHero, 2)
		local Qd 	 = (Q:IsReady() and menu.Q.ks) and getDmg("Q",enemy,myHero)
		local Wd 	 = (W:IsReady() and menu.W.ks) and getDmg("W",enemy,myHero)
		local Ed 	 = (E:IsReady() and (menu.E.ks or menu.E.cast)) and getDmg("E",enemy,myHero)
		local Rd     = (R:IsReady() and menu.R.ks) and GET_R_REAL_DAMAGE(enemy)
		local HP 	 = enemy.health
		--[[
		lib.print("----------")
		lib.print(enemy.charName)
		lib.print("Q_MARK : "..tostring(Q_MARK))
		lib.print("Qd : "..tostring(Qd))
		lib.print("Wd : "..tostring(Wd))
		lib.print("Ed : "..tostring(Ed))
		lib.print("Rd : "..tostring(Rd))
		lib.print("----------")
		--]]
		if (Qd) and HP <= Qd and CAST_Q(enemy) then
			--lib.print("#1")
			goto continue
		elseif (Wd) and HP <= Wd and CAST_W(enemy,true) then
			--lib.print("#2")
			goto continue
		elseif (Ed) and HP <= Ed and CAST_E(enemy,true) then
			--lib.print("#3")
			goto continue			
		elseif (Qd and Wd) and HP <= Qd+Wd and CAST_W(enemy,true) then
			--lib.print("#4")
			goto continue
		elseif (Qd and Ed) and HP <= Qd+Ed and CAST_E(enemy,true) then 
			--lib.print("#5")
			goto continue
		elseif (Wd and Ed) and HP <= Wd+Ed and CAST_W(enemy,true) then 
			--lib.print("#6")
			goto continue
		elseif (Q_MARK and Wd and Ed) and HP <= Q_MARK+Qd+Wd+Ed and CAST_E(enemy,true) then 
			--lib.print("#7")
			CAST_Q(enemy)
			goto continue
		elseif (Rd) and HP <= Rd and CAST_R(enemy) then 
			--lib.print("#8")
			goto continue
		elseif (Q_MARK and Wd and Ed and Rd) and HP<=Q_MARK+Qd+Wd+Ed+Rd and CAST_E(enemy,true) then 
			--lib.print("#9")
			CAST_Q(enemy)
			CAST_W(enemy,true)
		end
		::continue::
	end
	
	
	
	if R_ON==true then
		if menu.R.stop then
			KS_R_STOP=false
		end
	end
end 
end
 
--[[
██╗   ██╗    ██╗         ████████╗
██║   ██║    ██║         ╚══██╔══╝
██║   ██║    ██║            ██║   
██║   ██║    ██║            ██║   
╚██████╔╝    ███████╗       ██║   
 ╚═════╝     ╚══════╝       ╚═╝   
                                  
--]] 
do
function OnSendPacket(p)
	if R_ON then
		if (p.header == Packet.headers.S_MOVE) then
			p:Block()
		elseif (p.header == Packet.headers.S_CAST and (Packet(p):get('spellId') ~= SUMMONER_1 and Packet(p):get('spellId') ~= SUMMONER_2)) then
			if KS_R_STOP==false then				
				p:Block()
				return
			else
				Print("R STOP - KS")
				return
			end
		end
	end
end
local R_BUFF_NAME="katarinarsound"
function OnGainBuff(unit, buff)
	if unit.isMe and buff.name == R_BUFF_NAME then
		R_ON =  true
	end
end
function OnLoseBuff(unit, buff)
	if unit.isMe and buff.name == R_BUFF_NAME then
		R_ON =  false
	end
end
local R_NAME="KatarinaR"
function OnProcessSpell(unit,spell)
	if unit.isMe then
		if spell.name==R_NAME then
			R_ON = true			
		end
	end
end 
function OnAnimation(unit, animationName)
	if unit == myHero then
		if animationName == "Spell4" then 
			R_ON = true
		else
			R_ON = false
		end
	end
end
function OnWndMsg(msg, key)
	if msg == WM_RBUTTONDOWN and R_ON then
		R_ON=false
	end
end
end
--[[
 ██████╗     ██████╗     ██╗   ██╗        ███████╗    ███████╗
██╔═══██╗    ██╔══██╗    ██║   ██║        ██╔════╝    ██╔════╝
██║   ██║    ██████╔╝    ██║   ██║        █████╗      █████╗  
██║▄▄ ██║    ██╔══██╗    ██║   ██║        ██╔══╝      ██╔══╝  
╚██████╔╝    ██████╔╝    ╚██████╔╝        ██║         ██║     
 ╚══▀▀═╝     ╚═════╝      ╚═════╝         ╚═╝         ╚═╝     
                                                              
--]]
do
local Q_BUFF_NAME=""
function IsQBuffed(target)
	return HasBuff(target, Q_BUFF_NAME)
end
end
--[[
███╗   ███╗    ██╗    ███████╗     ██████╗
████╗ ████║    ██║    ██╔════╝    ██╔════╝
██╔████╔██║    ██║    ███████╗    ██║     
██║╚██╔╝██║    ██║    ╚════██║    ██║     
██║ ╚═╝ ██║    ██║    ███████║    ╚██████╗
╚═╝     ╚═╝    ╚═╝    ╚══════╝     ╚═════╝                                          
--]]
do
function Print(str)	print("<font color=\"#6699ff\"><b>FTER44:</b></font> <font color=\"#FFFFFF\">"..str..".</font>") end


function FARM()
	SOWi.EnemyMinions:update()
	for _, minion in ipairs(SOWi.EnemyMinions.objects) do	
		local time = SOWi:WindUpTime(true) + GetDistance(minion.visionPos, myHero.visionPos) / SOWi.ProjectileSpeed - 0.07
		local PredictedHealth = SOWi.VP:GetPredictedHealth(minion, time, GetSave("SOW").FarmDelay / 1000)
		if SOWi:ValidTarget(minion) and not( PredictedHealth < VP:CalcDamageOfAttack(myHero, minion, {name = "Basic"}, 0) + SOWi:BonusDamage(minion) and SOWi:CanAttack()==true ) and ( 
			( Q:IsReady() and getDmg("Q",minion,myHero)>=minion.health and menu.Q.farm and CAST_Q(minion) ) or ( W:IsReady() and getDmg("W",minion,myHero)>=minion.health and menu.W.farm and CAST_W(minion) )
			or ( E:IsReady() and getDmg("E",minion,myHero)>=minion.health and menu.E.farm and CAST_E(minion) ) )
			then
			break
		end
	end
end
function LANECLEAR()
	SOWi.EnemyMinions:update()
	for _, minion in ipairs(SOWi.EnemyMinions.objects) do	
		local time = SOWi:WindUpTime(true) + GetDistance(minion.visionPos, myHero.visionPos) / SOWi.ProjectileSpeed - 0.07
		local PredictedHealth = SOWi.VP:GetPredictedHealth(minion, time, GetSave("SOW").FarmDelay / 1000)
		if not( SOWi:ValidTarget(minion) and PredictedHealth < VP:CalcDamageOfAttack(myHero, minion, {name = "Basic"}, 0) + SOWi:BonusDamage(minion) and SOWi:CanAttack()==true ) and ( 
			( Q:IsReady() and getDmg("Q",minion,myHero)>=minion.health and menu.Q.laneclear and CAST_Q(minion) ) or ( W:IsReady() and getDmg("W",minion,myHero)>=minion.health and menu.W.laneclear and CAST_W(minion) )
			or ( E:IsReady() and getDmg("E",minion,myHero)>=minion.health and menu.E.laneclear and CAST_E(minion) ) )
			then
			break
		end
	end
end
function JUNGLE()
	target = SOWi.JungleMinions.objects[1]
	if ValidTarget(target) then
		if menu.Q.jungle then
			CAST_Q(target)
		end
		if menu.W.jungle then
			CAST_W(target)
		end
		if menu.E.jungle then
			CAST_E(target)
		end
	end
end
function CountEnemyHeroInRange(range)
    local rangeSqr = range*range
    local enemyInRange = 0
    for _,e in pairs(GetEnemyHeroes()) do
        if ValidTarget(e) and GetDistanceSqr(e) <= rangeSqr then
            enemyInRange = enemyInRange + 1
        end
    end
    return enemyInRange	
end
end
