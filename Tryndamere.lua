if  myHero.charName ~= "Tryndamere" then return end

local version = "0.22"
local SCRIPT_NAME = "Tryndamere"
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
--[[MAIN TARGET]]--
local Target
local Target_Circle
--[[Spells]]--
local Q,W,E,R
--[[PASSIVE]]--
local R_ON=false 
--[[SPELL DATA]]--
local SPELL_DATA = {
	[_Q] = {range = 500},
	[_W] = {range = 850},
	[_E] = {range = 650, skillshotType = SKILLSHOT_LINEAR, speed = 0900, delay = 0.25, width = 160},
	[_R] = {range = 000}
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
	menu = scriptConfig("Tryndamere", "Tryndamere")
	
	--SPELLS
	menu:addSubMenu("Q", "Q")
		
	menu:addSubMenu("W", "W")
		menu.W:addParam("combo", "W@Combo", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("harass", "W@harass", SCRIPT_PARAM_ONOFF, false) 
	menu:addSubMenu("E", "E")				
		menu.E:addParam("extend", "extend Predited Pos", SCRIPT_PARAM_SLICE, 100, 0, 200)
		menu.E:addParam("ks", "E@KS", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("combo", "E@Combo", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("harass", "E@harass", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("farm", "E@farm", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("laneclear", "E@laneclear", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("jungle", "E@jungle", SCRIPT_PARAM_ONOFF, true)  
		menu.E:addParam("cast", "Manual Cast2Target", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
	menu:addSubMenu("R", "R")
		
	--OW
	menu:addSubMenu("Orbwalker", "SOW")
		SOWi:LoadToMenu(menu.SOW)	
	--TS
	menu:addSubMenu("Target selector", "STS")
		STS:AddToMenu(menu.STS)	 		
	--ITEMS
	menu:addSubMenu("Items","Items")
		IM=ITEM_MANAGER(menu.Items,STS)
	--DRAWING
	menu:addSubMenu("Drawings", "Drawings")
		local DManager = DrawManager()
		DManager:CreateCircle(myHero, SPELL_DATA[_Q ].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"Q range", true, true, true)		
		DManager:CreateCircle(myHero, SPELL_DATA[_W ].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"W range", true, true, true)		
		DManager:CreateCircle(myHero, SPELL_DATA[_E ].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"E range", true, true, true)
		menu.Drawings:addSubMenu("KillTexts","KillTexts")
			KILLTEXTS=TEXTPOS_HPBAR(menu.Drawings.KillTexts,23,46,30)	
			menu.Drawings.KillTexts:addParam("hit","hit",SCRIPT_PARAM_ONOFF,true)
			menu.Drawings.KillTexts:addParam("time","time",SCRIPT_PARAM_ONOFF,true)
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
	
	function SOW:BonusDamage(minion) 
		return 0
	end	
	Spell.VP=VP
	function Spell:IsInRangeAdv(target, from) 		
		return (self.range+self.VP:GetHitBox(target))^2 >= GetDistanceSqr(target, from or self.sourcePosition)
	end
	
	--Q
		Q=Spell(_Q,SPELL_DATA[_Q].range)
	--W
		W=Spell(_W,SPELL_DATA[_W].range)
	--E
		E=Spell(_E,SPELL_DATA[_E].range)
			E:SetSkillshot(VP, SPELL_DATA[_E].skillshotType, SPELL_DATA[_E].width, SPELL_DATA[_E].delay, SPELL_DATA[_E].speed)
	--R
		R=Spell(_R,SPELL_DATA[_R].range)
	return true
end
function OnLoad()
	if SetLibrary() and	Load_Menu() then	
		AddTickCallback(OnTick2)
		AddDrawCallback(OnDraw2)
		Print("TRYNDAMERE Loaded")
	end
end

end

--[[
████████╗    ██╗     ██████╗    ██╗  ██╗
╚══██╔══╝    ██║    ██╔════╝    ██║ ██╔╝
   ██║       ██║    ██║         █████╔╝ 
   ██║       ██║    ██║         ██╔═██╗ 
   ██║       ██║    ╚██████╗    ██║  ██╗
   ╚═╝       ╚═╝     ╚═════╝    ╚═╝  ╚═╝
                                        
--]]

function OnTick()	
	KD()
	KS() 	
	
	if menu.farm then
		FARM() 
	end
	
	if menu.laneclear then
		LANECLEAR() 
	end
	
	if menu.jungle then
		JUNGLE() 
	end
	

	Target = STS:GetTarget(SPELL_DATA[_W].range) or STS:GetTarget(SPELL_DATA[_E].range)
	if not Target or not ValidTarget(Target) then return end
	
	
	if menu.combo then	
		if W:IsReady() and menu.W.combo then
			CAST_W(Target)
		end
		if E:IsReady() and (menu.E.combo or menu.E.cast) then
			CAST_E(Target)
		end
		return
	end
	if menu.harass then 		
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
		local str='R_ON ' .. tostring(R_ON).."\n"
		
		if ValidTarget(Target) then
			if IsFacingBack(myHero,Target) then
				str=str.."Facing back ".."\n"
			else
				str=str.."not Facing back".."\n"
			end
			if IsFacingEach(myHero,Target) then
				str=str.."Facing each ".."\n"
			else
				str=str.."not Facing each".."\n"
			end
		end
		
		
		DrawText(str, 25, 350, 350, ARGB(255,0,255,0))
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
end
function CAST_W(target)
	if W:IsInRangeAdv(target) and IsFacingBack(myHero,target) then
		W:Cast()
	end
end 
function CAST_E(target)
	do return E:Cast(target)==SPELLSTATE_TRIGGERED end	
	local real_range=E.range + VP:GetHitBox(target)
	local _, hitChance, position = E:GetPrediction(target)	
	local positionE = position + (position - Vector(myHero):normalized() * menu.E.extend)--shot at max range
	
	if hitChance>0 and position and GetDistanceSqr(position)<=real_range*real_range then
		return E:Cast(positionE.x,positionE.z)==SPELLSTATE_TRIGGERED
	end
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
		if ValidTarget(enemy) then
			local AA 	= getDmg("AD",enemy,myHero) --critChance
			local Ed 	= E:IsReady() and getDmg("E",enemy,myHero)
			local HP 	= enemy.health - ( Ed and Ed or 0 )
			
			local hit = math.ceil( HP/AA)
			local hit_T = math.ceil( hit/myHero.attackSpeed )
			local str=""
			
			if menu.Drawings.KillTexts.hit then
				str=str..hit.." Hit\n"
			end
			if menu.Drawings.KillTexts.time then
				str=str..hit_T.." Sec\n"
			end
			KILLTEXTS:SET_TEXT(enemy,str)		
		end
	end
end
local KS_nexttick=0
function KS() 	
	--if os.clock() < KS_nexttick then return end
	--KS_nexttick = os.clock()+0.2 

	for _, enemy in pairs(GetEnemyHeroes()) do
		if not ValidTarget(enemy) then return end 
		local AA 	= getDmg("AD",enemy,myHero)
		local Ed 	= (E:IsReady() and menu.E.ks) and getDmg("E",enemy,myHero)
		local HP 	= enemy.health
		--[[
		lib.print("----------")
		lib.print(enemy.charName) 
		lib.print("Qd : "..tostring(Qd))
		lib.print("Wd : "..tostring(Wd))
		lib.print("Ed : "..tostring(Ed))
		lib.print("Rd : "..tostring(Rd))
		lib.print("----------")
		--]]
		if (Ed) and HP <= Ed and CAST_E(enemy) then
			--lib.print("#1")
			goto continue
		elseif (Ed) and HP <= Ed+AA+AA and CAST_E(enemy) then
			--lib.print("#2")
			goto continue
		end
		::continue::
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

function GetVisionVector(unit)
	if unit.visionPos then
		return Vector(unit.visionPos.x-unit.x,unit.visionPos.y-unit.y, unit.visionPos.z-unit.z)
	end
end
local Diff_Dir_angle=math.pi*(12/18) --120
function IsFaceDiffrent(a,b) -- -> <-  |  <- ->
	local visionA=GetVisionVector(a)
	local visionB=GetVisionVector(b)
	return visionA and visionB and visionA:angle(visionB)>Diff_Dir_angle
end
local Same_Dir_angle=math.pi*(1/3) --60
function IsFaceSame(a,b) --   <- <-  |   -> -> 
	local visionA=GetVisionVector(a)
	local visionB=GetVisionVector(b)
	return visionA and visionB and visionA:angle(visionB)<=Same_Dir_angle
end

function IsFacingBack(a,b) --a is face b's back   (-> ->)
	return IsFaceSame(a,b) and GetDistanceSqr(a,b)<GetDistanceSqr(a,b.visionPos)
end

function IsFacingEach(a,b) -- (-> <-)
	return IsFaceDiffrent(a,b) and GetDistanceSqr(a,b.visionPos)<GetDistanceSqr(a,b)
end

function Print(str)	print("<font color=\"#6699ff\"><b>FTER44:</b></font> <font color=\"#FFFFFF\">"..str..".</font>") end

function FARM()
	SOWi.EnemyMinions:update()
	for _, minion in ipairs(SOWi.EnemyMinions.objects) do	
		local time = SOWi:WindUpTime(true) + GetDistance(minion.visionPos, myHero.visionPos) / SOWi.ProjectileSpeed - 0.07
		local PredictedHealth = SOWi.VP:GetPredictedHealth(minion, time, GetSave("SOW").FarmDelay / 1000)
		if SOWi:ValidTarget(minion) and SOWi:GetState()==0 and not( PredictedHealth < VP:CalcDamageOfAttack(myHero, minion, {name = "Basic"}, 0) + SOWi:BonusDamage(minion) and SOWi:CanAttack()==true ) and ( 
			--[[( Q:IsReady() and getDmg("Q",minion,myHero)>=minion.health and menu.Q.farm and CAST_Q(minion) )]] --[[or ( W:IsReady() and getDmg("W",minion,myHero)>=minion.health and menu.W.farm and CAST_W(minion) )]]
			--[[or]] ( E:IsReady() and getDmg("E",minion,myHero)>=minion.health and (menu.E.farm or menu.E.cast) and CAST_E(minion) ) )
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
			--[[( Q:IsReady() and getDmg("Q",minion,myHero)>=minion.health and menu.Q.laneclear and CAST_Q(minion) )]]--[[or ( W:IsReady() and getDmg("W",minion,myHero)>=minion.health and menu.W.laneclear and CAST_W(minion) )]]
			--[[or]] ( E:IsReady() and getDmg("E",minion,myHero)>=minion.health and (menu.E.laneclear or menu.E.cast) and CAST_E(minion) ) )
			then
			break
		end
	end
end
function JUNGLE()
	target = SOWi.JungleMinions.objects[1]
	if ValidTarget(target) then
		if menu.E.jungle or menu.E.cast then
			CAST_E(target)
		end
	end
end
end




_G.GetDistanceSqr=function (p1, p2)
    if p1==nil then
		print("GetDistanceSqr Error!")
		--lib.print(debug.traceback())
		return math.huge
	end
    p2 = p2 or player
    return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end
