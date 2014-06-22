if myHero.charName ~= "Ahri" then return end


local version = "0.22"
local SCRIPT_NAME = "Ahri"
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
RequireI:Add("Prodiction", 		"https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/b3d142897814a97973071c0a26aab5bb63d6d014/Test/Prodiction/Prodiction.lua")
RequireI:Check()

if RequireI.downloadNeeded == true then return end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[Menu instance]]--
local menu
--[[Libaries]]--
local VP,SOWi,STS
local DLib 
local IM
--[[MAIN TARGET]]--
local Target
local Target_Circle
--[[Spells]]--
local Q,W,E,R    
--CHARMED TARGETS
local E_ON_Targets={} 
--[[SPELL DATA]]--
local SPELL_DATA = { [_Q] = { skillshotType = SKILLSHOT_LINEAR, range = 880, delay = 0.25, width = 100, speed = 1640, collision = false },
					 [_W] = { skillshotType = nil,              range = 750, collision = false },
					 [_E] = { skillshotType = SKILLSHOT_LINEAR, range = 975, delay = 0.25, width = 060, speed = 1550, collision = true },
					 [_R] = { skillshotType = nil,              range = 450, collision = false } 
}
--[[Kill Str Manager]]--
local KILLTEXTS

local MainCombo = {ItemManager:GetItem("DFG"):GetId(), _AA, _E, _W, _Q} 
function Load_Menu()
	menu = scriptConfig("Ahri", "Ahri")
	
	--SPELLS
	menu:addSubMenu("Q", "Q")
		menu.Q:addParam("ks", "KS Q", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("combo", "Q@Combo", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("harass", "Q@harass", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("farm", "Q@farm", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("laneclear", "Q@laneclear", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("jungle", "Q@jungle", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("E", "check E", SCRIPT_PARAM_ONOFF, true)
	menu:addSubMenu("W", "W") 
		menu.W:addParam("ks", "KS W", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("combo", "W@Combo", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("harass", "W@harass", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("farm", "W@farm", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("laneclear", "W@laneclear", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("jungle", "W@jungle", SCRIPT_PARAM_ONOFF, true) 
		menu.W:addParam("W", "check E", SCRIPT_PARAM_ONOFF, true)
	menu:addSubMenu("E", "E")				 
		menu.E:addParam("ks", "KS E", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("combo", "E@Combo", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("harass", "E@harass", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("farm", "E@farm", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("laneclear", "E@laneclear", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("jungle", "E@jungle", SCRIPT_PARAM_ONOFF, true) 
		menu.E:addParam("gap", "KS E", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("auto", "Auto E on immo/dash", SCRIPT_PARAM_ONOFF, true)
	menu:addSubMenu("R", "R")
		menu.R:addParam("ks", "KS R", SCRIPT_PARAM_ONOFF, true) 
		menu.R:addParam("combo", "R@Combo", SCRIPT_PARAM_ONOFF, true)
		menu.R:addParam("cast", "cast R", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('A'))
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
	menu:addSubMenu("AntiGapcloser","AG")
		AntiGapcloser(menu.AG, function(unit,data)			
			if menu.E.gap and E:IsReady() and E:IsInRange(unit) then
				CAST_E(unit)
			end
		end)
	--DRAWING
	menu:addSubMenu("Drawings", "Drawings")
		local DManager = DrawManager()
		DManager:CreateCircle(myHero, SPELL_DATA[_Q ].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"Q range", true, true, true)		
		DManager:CreateCircle(myHero, SPELL_DATA[_W ].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"W range", true, true, true)		
		DManager:CreateCircle(myHero, SPELL_DATA[_E ].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"E range", true, true, true)		
		DManager:CreateCircle(myHero, SPELL_DATA[_R ].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"R range", true, true, true)	

		DLib:AddToMenu(menu.Drawings, MainCombo)		
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
	
	
	return true
end
function SetLibrary()	
	VP = VPrediction()	SOWi = SOW(VP)	STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC) 
	
	Spell.VP=VP
	function Spell:IsInRangeAdv(target, from) 		
		return (self.range+self.VP:GetHitBox(target))^2 >= GetDistanceSqr(target, from or self.sourcePosition)
	end
	
	--Q
		Q=Spell(_Q,SPELL_DATA[_Q].range)
			Q:SetSkillshot(VP, SPELL_DATA[_Q].skillshotType, SPELL_DATA[_Q].width, SPELL_DATA[_Q].delay, SPELL_DATA[_Q].speed, SPELL_DATA[_Q].collision)
	--W
		W=Spell(_W,SPELL_DATA[_W].range)	
	--E
		E=Spell(_E,SPELL_DATA[_E].range)
			E:SetSkillshot(VP, SPELL_DATA[_E].skillshotType, SPELL_DATA[_E].width, SPELL_DATA[_E].delay, SPELL_DATA[_E].speed, SPELL_DATA[_E].collision)
	--R
		R=Spell(_R,SPELL_DATA[_R].range)
	
	DLib = DamageLib()
	DLib:RegisterDamageSource(_Q, _MAGIC, 20, 22.5, _MAGIC, _AP, 0.33, function() return Q:IsReady() end)
	DLib:RegisterDamageSource(_W, _MAGIC, 20, 22.5, _MAGIC, _AP, 0.13, function() return W:IsReady() end)
	DLib:RegisterDamageSource(_E, _MAGIC, 30, 30, _MAGIC, _AP, 0.35, function() return E:IsReady() end)
	
	
	return true
end
function OnLoad() 
	if SetLibrary() and	Load_Menu() then	
		AddTickCallback(OnTick2)
		AddDrawCallback(OnDraw2)
		Print("AHRI Loaded")
	end
end
 

function OnTick()
	KD()
	KS()

	--E on DASHes/IMMOBILES 	
	if E:IsReady() and menu.E.auto then
		for _,champ in pairs(GetEnemyHeroes()) do
			if (E:CastIfDashing(champ)==SPELLSTATE_TRIGGERED or E:CastIfImmobile(champ)==SPELLSTATE_TRIGGERED) then
				break
			end
		end
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
	

	Target = STS:GetTarget(SPELL_DATA[_R].range) or STS:GetTarget(SPELL_DATA[_W].range) or STS:GetTarget(SPELL_DATA[_Q].range) or STS:GetTarget(SPELL_DATA[_E].range)
	if not Target or not ValidTarget(Target) then return end  
	
	if menu.combo then
		COMBO(Target)
	end
	if menu.harass then 
		HARASS(Target)
	end
end

function COMBO(target) 
	-- Item
	if DLib:IsKillable(target, MainCombo) then
		IM:CAST_OFFENSIVE_AP(target)
	end

	-- E
	if menu.E.combo and E:IsReady() then 
		CAST_E(target)
	end


	-- Q
	if menu.Q.combo and Q:IsReady() and (IsMoonLighted(target) or not menu.Q.E or not E:IsReady()) then
		CAST_Q(target)
	end

	-- W
	if menu.W.combo and W:IsReady() and (IsMoonLighted(target) or not menu.W.E or not E:IsReady()) then
		CAST_W(target)
	end 

	-- R
	if (menu.R.combo or menu.R.cast) and R:IsReady() and (IsMoonLighted(target) or not menu.R.E or not R:IsReady()) then
		CAST_R(target)
	end 
end 

function HARASS(target) 

	if Q:IsReady() and menu.Q.harass then
		CAST_Q(target)
	end

	if W:IsReady() and menu.W.harass then
		CAST_W(target)
	end
	
	if E:IsReady() and menu.E.harass then
		CAST_E(target)
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
	--lib.print(os.clock())
	for _,enemy in ipairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) then
			local Qd 	= Q:IsReady() and getDmg("Q",enemy,myHero,3)--1 init 2 wayback 3 total
			local Wd 	= W:IsReady() and getDmg("W",enemy,myHero,3)
			local Ed 	= E:IsReady() and getDmg("E",enemy,myHero)
			local Rd    = R:IsReady() and (getDmg("R",enemy,myHero)*3)
			local HP 	= enemy.health 
			if Qd and HP <= Qd then
				KILLTEXTS:SET_TEXT(enemy,"Q KILL")
			elseif Wd and HP <= Wd then
				KILLTEXTS:SET_TEXT(enemy,"W KILL")
			elseif (Qd and Wd) and HP <= Qd+Wd then
				KILLTEXTS:SET_TEXT(enemy,"Q+W KILL")
			elseif (Qd and Wd) and HP <= Qd+Wd+Qd then
				KILLTEXTS:SET_TEXT(enemy,"2Q+W KILL")
			elseif (Qd and Wd and Ed) and HP <= Qd+Wd+Ed then
				KILLTEXTS:SET_TEXT(enemy,"Q+W+E KILL")
			elseif (Qd and Wd and Ed and Rd) and HP <= Qd+Wd+Ed+Rd then
				KILLTEXTS:SET_TEXT(enemy,"Q+W+E+R KILL")
			else
				local totaldmg = (Qd and Qd or 0)+(Wd and Wd or 0)+(Rd and Rd or 0)
				local remain=HP-totaldmg
				KILLTEXTS:SET_TEXT(enemy,string.format("%d",remain))
			end
		end
	end
end
local KS_nexttick=0
function KS() 	
	--if os.clock() < KS_nexttick then return end
	--KS_nexttick = os.clock()+0.2 

	for _, enemy in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) then
			local Qd 	= (Q:IsReady() and menu.Q.ks) and getDmg("Q",enemy,myHero,3)
			local Wd 	= (W:IsReady() and menu.W.ks) and getDmg("W",enemy,myHero,3) 
			local Ed    = (E:IsReady() and menu.E.ks) and getDmg("E",enemy,myHero)
			local Rd    = (R:IsReady() and (menu.R.ks or menu.R.cast)) and getDmg("R",enemy,myHero)
			local HP 	 = enemy.health
			--[[
			lib.print("----------")
			lib.print(enemy.charName) 
			lib.print("Qd : "..tostring(Qd))
			lib.print("Wd : "..tostring(Wd))
			lib.print("Ed : "..tostring(Ed))
			lib.print("Rd : "..tostring(Rd))
			lib.print("----------")
			--]]
			if (Qd) and HP <= Qd and CAST_Q(enemy) then 
			elseif (Wd) and HP <= Wd and CAST_W(enemy) then 
			elseif (Ed) and HP <= Ed and CAST_E(enemy) then  
			elseif (Qd and Ed) and HP <= Qd+Ed and CAST_E(enemy) then  
				CAST_Q(enemy) 
			elseif (Qd and Wd and Ed) and HP <= Qd+Wd+Ed and CAST_E(enemy) then  
				CAST_W(enemy)
				CAST_Q(enemy) 
			elseif (Qd and Wd and Ed and Rd) and HP <= Qd+Wd+Ed+Rd and CAST_R(enemy) then 		
				CAST_W(enemy)
				CAST_Q(enemy) 
			end
		end
	end 
end 
end 

--[[
██████╗     ██╗   ██╗    ███████╗    ███████╗
██╔══██╗    ██║   ██║    ██╔════╝    ██╔════╝
██████╔╝    ██║   ██║    █████╗      █████╗  
██╔══██╗    ██║   ██║    ██╔══╝      ██╔══╝  
██████╔╝    ╚██████╔╝    ██║         ██║     
╚═════╝      ╚═════╝     ╚═╝         ╚═╝     
                                             
--]]
do  
local E_BUFF_NAME="AhriSeduce"
function OnGainBuff(unit, buff) 
	if buff.name == E_BUFF_NAME then
		E_ON_Targets[unit.networkID]=true
	end
end
function OnLoseBuff(unit, buff) 
	if buff.name == E_BUFF_NAME then
		E_ON_Targets[unit.networkID]=false
	end
end
function IsMoonLighted(target)
	return E_ON_Targets[target.networkID]
	--return HasBuff(target, E_BUFF_NAME)
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
	return Q:Cast(target)==SPELLSTATE_TRIGGERED
end
function CAST_W(target)
	if W:IsInRangeAdv(target) then
		return W:Cast(target)==SPELLSTATE_TRIGGERED
	end
end
function CAST_E(target) 
	return E:Cast(target)==SPELLSTATE_TRIGGERED
end
function CAST_R(target)
	if R:IsInRangeAdv(target) then
		return R:Cast(mousePos.x,mousePos.z)==SPELLSTATE_TRIGGERED
	end
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
		if SOWi:ValidTarget(minion) and SOWi:GetState()==0 and not( PredictedHealth < VP:CalcDamageOfAttack(myHero, minion, {name = "Basic"}, 0) + SOWi:BonusDamage(minion) and SOWi:CanAttack()==true ) and ( 
			( Q:IsReady() and getDmg("Q",minion,myHero)>=minion.health and menu.Q.farm and CAST_Q(minion) ) or ( W:IsReady() and getDmg("W",minion,myHero)>=minion.health and menu.W.farm and CAST_W(minion) )
			--[[or (R:IsReady() and getDmg("R",minion,myHero)>=minion.health and (menu.R.farm or menu.R.cast) and CAST_R(minion) ) ]])
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
			--[[or ( R:IsReady() and getDmg("R",minion,myHero)>=minion.health and (menu.R.laneclear or menu.R.cast) and CAST_R(minion) )]] )
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
end
