if myHero.charName ~= "Amumu" then return end



local version = "0.22"
local SCRIPT_NAME = "Amumu"
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
local W_ON=false 
--[[SPELL DATA]]--
local SPELL_DATA = {
					 [_Q ] = { skillshotType = SKILLSHOT_LINEAR,   range = 1100, speed = 2000,		width = 080, delay=0.25, collision=true},
					 [_W ] = { skillshotType = nil,	range = 0300},
					 [_E ] = { skillshotType = nil,	range = 0350, speed = math.huge, delay=0.25},
					 [_R ] = { skillshotType = nil, range = 0550, speed = math.huge, delay=0.25}--self circular
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
function Load_Menu()
	menu = scriptConfig("Amumu", "Amumu")
	
	--SPELLS
	menu:addSubMenu("Q", "Q")	
		menu.Q:addParam("ks", "KS Q", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("combo", "Q@Combo", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("harass", "Q@harass", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("farm", "Q@farm", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("laneclear", "Q@laneclear", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("jungle", "Q@jungle", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("cast", "Manual Cast",SCRIPT_PARAM_ONKEYDOWN,false,string.byte("A"))
	menu:addSubMenu("W", "W") 
		menu.W:addParam("mana", "Check Mana for others", SCRIPT_PARAM_ONOFF, true) 
		menu.W:addParam("Q", "mana check Q", SCRIPT_PARAM_ONOFF, true) 
		menu.W:addParam("E", "mana check E", SCRIPT_PARAM_ONOFF, true) 
		menu.W:addParam("R", "mana check R", SCRIPT_PARAM_ONOFF, true) 
		menu.W:addParam("ks", "KS W", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("combo", "W@Combo", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("harass", "W@harass", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("farm", "W@farm", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("laneclear", "W@laneclear", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("jungle", "W@jungle", SCRIPT_PARAM_ONOFF, true) 
	menu:addSubMenu("E", "E")				
		menu.E:addParam("ks", "KS E", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("combo", "E@Combo", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("harass", "E@harass", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("farm", "E@farm", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("laneclear", "E@laneclear", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("jungle", "E@jungle", SCRIPT_PARAM_ONOFF, true)  
	menu:addSubMenu("R", "R")	
		menu.R:addParam("ks", "KS R", SCRIPT_PARAM_ONOFF, false)	 
		menu.R:addParam("combo", "R@Combo", SCRIPT_PARAM_ONOFF, false) 
		menu.R:addParam("auto", "Auto R", SCRIPT_PARAM_ONOFF, true)  
		menu.R:addParam("n", "^Auto R when 'N' R-able", SCRIPT_PARAM_SLICE, 3, 1, 5)
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
			Q:SetSkillshot(VP, SPELL_DATA[_Q].skillshotType, SPELL_DATA[_Q].width, SPELL_DATA[_Q].delay, SPELL_DATA[_Q].speed, SPELL_DATA[_Q].collision)
	--W
		W=Spell(_W,SPELL_DATA[_W].range)
		if TargetHaveBuff("amumutear",myHero) then
			W_ON=true
		end
	--E
		E=Spell(_E,SPELL_DATA[_E].range)
	--R
		R=Spell(_R,SPELL_DATA[_R].range)
	return true
end
function OnLoad()
	if SetLibrary() and	Load_Menu() then	
		AddTickCallback(OnTick2)
		AddDrawCallback(OnDraw2)
		Print("AMUMU Loaded")
	end
end

function OnTick2()
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
	

	Target = STS:GetTarget(SPELL_DATA[_Q].range) or STS:GetTarget(SPELL_DATA[_E].range) or STS:GetTarget(SPELL_DATA[_R].range)
	if not Target or not ValidTarget(Target) then return end
	
	if menu.R.auto then
		CAST_R_N(menu.R.n)
	end
	
	if menu.combo then		
		if Q:IsReady() and (menu.Q.combo  or menu.Q.cast) then
			CAST_Q(Target)
		end
		if W:IsReady() and menu.W.combo then
			CAST_W(Target)
		end
		if E:IsReady() and menu.E.combo then
			CAST_E(Target)
		end
		if R:IsReady() and menu.R.combo then
			CAST_R(Target)
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
		if E:IsReady() and menu.E.harass then
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
		local str='W_ON ' .. tostring(W_ON).."\n"
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
	return Q:Cast(target)==SPELLSTATE_TRIGGERED
end

local Q_COST={80,90,100,110,120}
local E_COST={35,35,35,35,35}
local R_COST={100,150,200}
function Is_Mana_Enough(Qc,Ec,Rc)
	local mana=0
	mana = mana + (Qc and Q_COST[Q:GetLevel()] or 0)
	mana = mana + (Ec and E_COST[E:GetLevel()] or 0)
	mana = mana + (Rc and R_COST[R:GetLevel()] or 0)
	
	return myHero.mana>=mana	
end
function CAST_W(target,force)--8 mana per seec
	if W_ON then
		if not W:IsInRangeAdv(target) or (menu.W.mana and not Is_Mana_Enough(menu.W.Q,menu.W.E,menu.W.R)) then--MANA CHECK
			W:Cast()--OFF
		end
	else
		if W:IsInRangeAdv(target) and (force or (not menu.W.mana or Is_Mana_Enough(menu.W.Q,menu.W.E,menu.W.R)) )then
			W:Cast()--ON
		end
	end
end
function CAST_E(target,force)
	local pos = VP:GetPredictedPos(target, SPELL_DATA[_E].delay, SPELL_DATA[_E].speed, myHero)	
	if E:IsInRangeAdv(pos) then
		return E:Cast(target)==SPELLSTATE_TRIGGERED
	end
end
function CAST_R(target)
	local pos = VP:GetPredictedPos(target, SPELL_DATA[_R].delay, SPELL_DATA[_R].speed, myHero)	
	if R:IsInRangeAdv(pos) then		
		return R:Cast()==SPELLSTATE_TRIGGERED
	end
end 
function CAST_R_N(N)
	local hit=0
	for i, target in pairs(GetEnemyHeroes()) do
		if ValidTarget(target, 2000) then
			local Position = VP:GetPredictedPos(target, SPELL_DATA[_R].delay, SPELL_DATA[_R].speed, myHero)	
			if R:IsInRangeAdv(Position) then
				hit=hit+1
			end
		end
	end
	
	if hit>=N then	
		return R:Cast()==SPELLSTATE_TRIGGERED
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
			local Qd 	= Q:IsReady() and getDmg("Q",enemy,myHero)
			local Wd 	= W:IsReady() and getDmg("W",enemy,myHero)--1sec
			local Ed 	= E:IsReady() and getDmg("E",enemy,myHero)
			local Rd    = R:IsReady() and getDmg("R",enemy,myHero)
			local HP 	= enemy.health
			if Qd and HP <= Qd then
				KILLTEXTS:SET_TEXT(enemy,"Q KILL")
			elseif Wd and HP <= Wd then
				KILLTEXTS:SET_TEXT(enemy,"W KILL")
			elseif Ed and HP <= Ed then		
				KILLTEXTS:SET_TEXT(enemy,"E KILL") 
			elseif (Qd and Wd) and HP <= Qd+Wd then
				KILLTEXTS:SET_TEXT(enemy,"Q+W KILL")
			elseif (Qd and Ed) and HP <= Qd+Ed then
				KILLTEXTS:SET_TEXT(enemy,"Q+E KILL")
			elseif (Wd and Ed) and HP <= Wd+Ed then
				KILLTEXTS:SET_TEXT(enemy,"W+E KILL")
			elseif (Qd and Wd and Ed and Rd) and HP <= Qd+Wd+Ed then
				KILLTEXTS:SET_TEXT(enemy,"Q+W+E KILL")
			elseif (Qd and Wd ) and HP <= Qd+Wd+Qd then
				KILLTEXTS:SET_TEXT(enemy,"2Q+W KILL")
			elseif (Qd and Wd and Ed) and HP <= Qd+Qd+Wd+Ed then
				KILLTEXTS:SET_TEXT(enemy,"2Q+W+E KILL")
			elseif (Qd and Wd and Ed and Rd) and HP <= Qd+Wd+Ed+Rd then
				KILLTEXTS:SET_TEXT(enemy,"Q+W+E+R KILL")
			elseif (Qd and Wd and Ed and Rd) and HP <= Qd+Wd+Ed+Rd+Qd then
				KILLTEXTS:SET_TEXT(enemy,"2Q+W+E+R KILL")
			else
				local totaldmg = (Qd and Qd or 0)+(Wd and Wd or 0)+(Ed and Ed or 0)+(Rd and Rd or 0)
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
			local Qd 	 =(Q:IsReady() and (menu.Q.ks or menu.Q.cast) ) and getDmg("Q",enemy,myHero)
			local Wd 	 =(W:IsReady() and menu.W.ks ) and getDmg("W",enemy,myHero)
			local Ed 	 =(E:IsReady() and menu.E.ks) and getDmg("E",enemy,myHero)
			local Rd     =(R:IsReady() and menu.R.ks ) and getDmg("R",enemy,myHero)
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
				--lib.print("#1")
				goto continue
			elseif (Wd) and HP <= Wd and CAST_W(enemy) then
				--lib.print("#2")
				goto continue
			elseif (Ed) and HP <= Ed and CAST_E(enemy) then
				--lib.print("#3")
				goto continue			
			elseif (Qd and Wd) and HP <= Qd+Wd and CAST_Q(enemy) then
				--lib.print("#4")
				goto continue
			elseif (Qd and Ed) and HP <= Qd+Ed and CAST_Q(enemy,true) then 
				--lib.print("#5")
				goto continue
			elseif (Wd and Ed) and HP <= Wd+Ed and CAST_E(enemy) then 
				--lib.print("#6")
				goto continue
			elseif (Qd and Wd and Ed) and HP <= Qd+Wd+Ed and CAST_Q(enemy,true) then 
				--lib.print("#7")
				goto continue
			elseif (Qd and Wd and Ed and Rd) and HP<=Qd+Qd+Wd+Ed+Rd and CAST_Q(enemy,true) then 
				CAST_E(enemy)
			end
			::continue::
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
local W_BUFF_NAME="AuraofDespair"
function OnGainBuff(unit, buff)
	if unit.isMe and buff.name==W_BUFF_NAME then
		W_ON=true
	end
end
function OnLoseBuff(unit, buff)
	if unit.isMe and buff.name==W_BUFF_NAME then
		W_ON=false
	end
end
function OnUpdateBuff(unit, buff)
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
			( Q:IsReady() and getDmg("Q",minion,myHero)>=minion.health and menu.Q.farm and CAST_Q(minion) ) --[[or ( W:IsReady() and getDmg("W",minion,myHero)>=minion.health and menu.W.farm and CAST_W(minion) )]]
			or ( E:IsReady() and getDmg("E",minion,myHero)>=minion.health and (menu.E.farm or menu.E.cast) and CAST_E(minion) ) )
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
			( Q:IsReady() and getDmg("Q",minion,myHero)>=minion.health and menu.Q.laneclear and CAST_Q(minion) )--[[or ( W:IsReady() and getDmg("W",minion,myHero)>=minion.health and menu.W.laneclear and CAST_W(minion) )]]
			or ( E:IsReady() and getDmg("E",minion,myHero)>=minion.health and (menu.E.laneclear or menu.E.cast) and CAST_E(minion) ) )
			then
			break
		end
	end
end
function JUNGLE()
	target = SOWi.JungleMinions.objects[1]
	if ValidTarget(target) then
		if menu.Q.jungle or menu.Q.cast then
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
