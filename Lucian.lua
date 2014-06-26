if myHero.charName ~= "Lucian" then return end

local version = "0.24"
local SCRIPT_NAME = "Lucian"
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


local DEBUGTARGET
local DEBUGPOINT


local LastSpellCast=0

local _Q1,_Q2=_Q,_PASIVE+1
local SPELL_DATA = { 
	[_Q1 ] = { skillshotType = nil				 ,	range = 0550, speed = math.huge, width = 065, delay=0.35},--650 in visual
	[_Q2 ] = { skillshotType = SKILLSHOT_LINEAR	 ,	range = 1100, speed = math.huge, width = 065, delay=0.35},
	[_W  ] = { skillshotType = SKILLSHOT_LINEAR,	range = 1000, speed = 1600     , width = 055, delay=0.30},	
	[_R  ] = { skillshotType = SKILLSHOT_LINEAR  ,  range = 1400, speed = 2800     , width = 100, delay=0.00},
	
	[_E  ] = 										{ range = 0425 },
}
function OnLoad()
	Init()
	Menu()	
end


local menu
local VP
local Target
local STS
local SOWi
local Q1,Q2,W,E,R





local PASSIVE_ON=false



local R_ORBWALK_POS
local R_DIRECTION
local P_ON=false
local R_ON=false


function Init()
	VP=VPrediction()
	
	Spell.VP=VP
	function Spell:IsInRangeAdv(target, from)--fter44
		local rangeA=(self.range+self.VP:GetHitBox(target))
		return rangeA*rangeA >= _GetDistanceSqr(target, from or self.sourcePosition)
	end
	STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC)
	SOWi = SOW(VP)
		SOWi:RegisterAfterAttackCallback(AfterAttack)
	
	--Q
		Q1= Spell(_Q,SPELL_DATA[_Q1].range) 
		Q2= Spell(_Q,SPELL_DATA[_Q2].range) 		
			Q2:SetSkillshot(VP, SPELL_DATA[_Q2 ].skillshotType,SPELL_DATA[_Q2 ].width, SPELL_DATA[_Q2 ].delay, SPELL_DATA[_Q2 ].speed)
	--W
		W = Spell(_W,SPELL_DATA[_W].range)
			W:SetSkillshot(VP, SPELL_DATA[_W ].skillshotType,SPELL_DATA[_W ].width,SPELL_DATA[_W ].delay, SPELL_DATA[_W ].speed,true)--should have special logic.. it explode after hit
	--E
		E = Spell(_E,SPELL_DATA[_E].range)
	--R
		R = Spell(_R,SPELL_DATA[_R].range)
			R:SetSkillshot(VP, SPELL_DATA[_R].skillshotType, SPELL_DATA[_R].width,SPELL_DATA[_R].delay, SPELL_DATA[_R].speed)
			
	--Completed
	AddTickCallback(OnTick2)
	AddDrawCallback(OnDraw2)
	
end
function Menu()
	menu = scriptConfig("Lucian", "Lucian")	
	
	--OW
	menu:addSubMenu("Orbwalker", "Orbwalker")
		SOWi:LoadToMenu(menu.Orbwalker)			
	--TS
	menu:addSubMenu("Target selector", "STS")
		STS:AddToMenu(menu.STS)	
	--SPELLS
	menu:addSubMenu("P", "P")		
		menu.P:addParam("saveC", "consume P b4 Cast@Combo", SCRIPT_PARAM_ONOFF, true)
		menu.P:addParam("saveH", "consume P b4 Cast@Harass", SCRIPT_PARAM_ONOFF, true)
	menu:addSubMenu("Q", "Q")			
		menu.Q:addParam("cast", "Force Cast fter AA", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('S'))
		menu.Q:addParam("ks", "ks", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("combo", "combo", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("harass", "harass", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("lane", "Lane Clear", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("jungle", "Jungle Clear", SCRIPT_PARAM_ONOFF, true)
	menu:addSubMenu("W", "W")		
		menu.W:addParam("cast", "Force Cast fter AA", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('S'))		
		menu.W:addParam("ks", "ks", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("combo", "combo", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("harass", "harass", SCRIPT_PARAM_ONOFF, false)
		menu.W:addParam("lane", "Lane Clear", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("jungle", "Jungle Clear", SCRIPT_PARAM_ONOFF, true)
	menu:addSubMenu("E", "E")		
		menu.E:addParam("slow", "Cleanse Slow Debuff", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("cast", "Cast to mousePos", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('A'))
	menu:addSubMenu("R", "R")			
		menu.R:addParam("track", "Track R Target move", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('W'))
	--Extras
	menu:addSubMenu("Extras", "Extras")			
		menu.Extras:addParam("DebugQ", "Debug Q2", SCRIPT_PARAM_ONOFF, false)
		menu.Extras:addParam("DebugR", "Debug R", SCRIPT_PARAM_ONOFF, false)
		menu.Extras:addParam("SimulR", "Simulate R Fire", SCRIPT_PARAM_ONKEYDOWN, false,string.byte('K'))
	--DRAWING
	menu:addSubMenu("Drawings", "Drawings")
		local DManager = DrawManager()
		DManager:CreateCircle(myHero, SPELL_DATA[_Q1].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"Q1 range", true, true, true)
		DManager:CreateCircle(myHero, SPELL_DATA[_Q2].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"Q2 range", true, true, true)
		DManager:CreateCircle(myHero, SPELL_DATA[_W ].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"W range", true, true, true)
		DManager:CreateCircle(myHero, SPELL_DATA[_E ].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"E range", true, true, true)
		DManager:CreateCircle(myHero, SPELL_DATA[_R ].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"R range", true, true, true)			
		menu.Drawings:addSubMenu("KillTexts","KillTexts")
			KILLTEXTS=TEXTPOS_HPBAR(menu.Drawings.KillTexts,23,46,30)	
			menu.Drawings.KillTexts:addParam("hit","hit",SCRIPT_PARAM_ONOFF,true)
			menu.Drawings.KillTexts:addParam("time","time",SCRIPT_PARAM_ONOFF,true)
			
	--KEYS	
	menu:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('C'))
	menu:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('X'))
	menu:addParam("Farm", "Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('V'))
	menu:addParam("flee", "flee", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('T'))
end
function OnTick2()
	--[[
	--DEBUG Q
	if menu.Extras.DebugQ then
		DEBUGTARGET = GetTarget()
		if DEBUGTARGET then
			CAST_Q(DEBUGTARGET)
			return
		end
	end
	
	--DEBUG R TRACKING
	if menu.Extras.SimulR then
		R_DIRECTION=(Vector(mousePos) - Vector(myHero)):normalized()
		R_ON=true
	end
	]]
	
	
	KD()
	
	if R_ON and menu.R.track then
		TRACK_R(GetTarget())
		SOWi:OrbWalk()
	end
	
	--KS		
	for _, enemy in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) then		
			if menu.Q.ks and Q1:IsReady() and getDmg("Q", enemy, myHero) > enemy.health and CAST_Q(enemy) then
				goto continue
			elseif  menu.W.ks and W:IsReady() and getDmg("W", enemy, myHero) > enemy.health and W:IsInRangeAdv(enemy) then
				W:Cast(enemy)
			end
		end
		::continue::
	end	
	
	--MANUAL CAST E
	if E:IsReady() and menu.E.cast then
		E:Cast(mousePos.x,mousePos.z)
	end
	--FLEE
	if menu.flee then
		if E:IsReady() then
			E:Cast(mousePos.x,mousePos.z)
		end		
		myHero:MoveTo(mousePos.x,mousePos.z)
	end
	--SET TARGET	
	Target = STS:GetTarget(SPELL_DATA[_E].range) or STS:GetTarget(SPELL_DATA[_Q1].range) or STS:GetTarget(SPELL_DATA[_Q2].range)
	if not Target or not ValidTarget(Target) then
		SOW:ForceTarget(nil)		
		return 
	end
	
	
	if menu.Combo then
		if P_ON and menu.P.saveC then return end
		if Q1:IsReady() and menu.Q.combo then
			CAST_Q(Target)
		elseif W:IsReady() and menu.W.combo then
			W:Cast(Target) 
		end
	elseif menu.Harass then		
		if P_ON and menu.P.saveH then return end
		if Q1:IsReady() and menu.Q.harass then
			CAST_Q(Target)
		elseif W:IsReady() and menu.W.harass then
			W:Cast(Target)
		end
	else
		SOW:ForceTarget(nil)		
	end
end

--[[
 ██▓███  ▄▄▄       ██████ ██▓██▒   █▓█████ 
▓██░  ██▒████▄   ▒██    ▒▓██▓██░   █▓█   ▀ 
▓██░ ██▓▒██  ▀█▄ ░ ▓██▄  ▒██▒▓██  █▒▒███   
▒██▄█▓▒ ░██▄▄▄▄██  ▒   ██░██░ ▒██ █░▒▓█  ▄ 
▒██▒ ░  ░▓█   ▓██▒██████▒░██░  ▒▀█░ ░▒████▒
▒▓▒░ ░  ░▒▒   ▓▒█▒ ▒▓▒ ▒ ░▓    ░ ▐░ ░░ ▒░ ░
░▒ ░      ▒   ▒▒ ░ ░▒  ░ ░▒ ░  ░ ░░  ░ ░  ░
░░        ░   ▒  ░  ░  ░  ▒ ░    ░░    ░   
              ░  ░     ░  ░       ░    ░  ░
                                 ░         
--]]
do
local Lucian_SpellNames={
	["LucianQ"]=true,
	["LucianW"]=true,
	["LucianE"]=true,
	["LucianR"]=true,
}
local P_NAME='lucianpassivebuff'
local R_NAME='LucianR'
function OnProcessSpell(unit, spell)
	if unit.isMe and Lucian_SpellNames[spell.name] then
		LastSpellCast = os.clock()        
		--DelayAction(function() SOWi:resetAA() end, .25) 
	end
	
	if spell.name == 'LucianR' then
		SOWi:DisableAttacks()
		local R_ENDPOS=Vector(spell.endPos)
		R_DIRECTION = (R_ENDPOS - Vector(myHero)):normalized()
		R_ON = true
	end
end

function OnGainBuff(unit, buff)
	if unit.isMe then	
		if buff.name == P_NAME then
			P_ON = true
		elseif buff.name == R_NAME then
			R_ON = true
			SOWi:DisableAttacks()
		elseif (buff.type == 5 or buff.type == 10 or buff.type == 11) and E:IsReady() and menu.E.slow then
			E:Cast(mousePos.x,mousePos.z)
		end
	end
end

function OnLoseBuff(unit, buff)
	if unit.isMe then 
		if buff.name == P_NAME then
			P_ON = false
		elseif buff.name == R_NAME then
			print("R ENDED")
			R_ON = false
			SOWi:EnableAttacks()
			SOWi:ForceOrbWalkTo(nil)
		end
	end
end


function SOW:BonusDamage(minion)
	if P_ON then
		return myHero:CalcDamage(minion,myHero.totalDamage) --100% for minion
	end
	return 0
end

function OnAnimation(unit, animation)
end

end
--[[
 ▄████▄  ▄▄▄       ██████▄▄▄█████▓     ██████ ██▓███ ▓█████ ██▓    ██▓     ██████ 
▒██▀ ▀█ ▒████▄   ▒██    ▒▓  ██▒ ▓▒   ▒██    ▒▓██░  ██▓█   ▀▓██▒   ▓██▒   ▒██    ▒ 
▒▓█    ▄▒██  ▀█▄ ░ ▓██▄  ▒ ▓██░ ▒░   ░ ▓██▄  ▓██░ ██▓▒███  ▒██░   ▒██░   ░ ▓██▄   
▒▓▓▄ ▄██░██▄▄▄▄██  ▒   ██░ ▓██▓ ░      ▒   ██▒██▄█▓▒ ▒▓█  ▄▒██░   ▒██░     ▒   ██▒
▒ ▓███▀ ░▓█   ▓██▒██████▒▒ ▒██▒ ░    ▒██████▒▒██▒ ░  ░▒████░██████░██████▒██████▒▒
░ ░▒ ▒  ░▒▒   ▓▒█▒ ▒▓▒ ▒ ░ ▒ ░░      ▒ ▒▓▒ ▒ ▒▓▒░ ░  ░░ ▒░ ░ ▒░▓  ░ ▒░▓  ▒ ▒▓▒ ▒ ░
  ░  ▒    ▒   ▒▒ ░ ░▒  ░ ░   ░       ░ ░▒  ░ ░▒ ░     ░ ░  ░ ░ ▒  ░ ░ ▒  ░ ░▒  ░ ░
░         ░   ▒  ░  ░  ░   ░         ░  ░  ░ ░░         ░    ░ ░    ░ ░  ░  ░  ░  
░ ░           ░  ░     ░                   ░            ░  ░   ░  ░   ░  ░     ░  
░                                                                                 
--]]
do

	local EnemyMinions = minionManager(MINION_ENEMY, SPELL_DATA[_Q].range+48, myHero.visionPos, MINION_SORT_HEALTH_ASC)--48 general hitbox
	local JungleMinions = minionManager(MINION_JUNGLE, SPELL_DATA[_Q].range+48, myHero.visionPos, MINION_SORT_HEALTH_ASC)
	
			
function CAST_Q(Target,forceNoExtend)
	if Q1:IsInRange(Target) then--Q1:IsInRangeAdv(Target) then
		return Q1:Cast(Target)
	elseif Q2:IsInRange(Target) and not forceNoExtend then
		local _, hitChance, position=Q2:GetPrediction(Target)
		if hitChance and hitChance>1 then
			for _,c in pairs(GetEnemyHeroes()) do --HERO
				if IsContainPoint(myHero,c,Q2.range,Q2.width+VP:GetHitBox(Target),position) then
					return Q2:__Cast(c)
				end
			end
			EnemyMinions:update()
			for _,minion in pairs(EnemyMinions.objects) do    --MINONS
				if IsContainPoint(myHero,minion,Q2.range,Q2.width+VP:GetHitBox(Target),position) then
					return Q2:__Cast(minion)
				end
			end
			JungleMinions:update()
			for _,minion in pairs(JungleMinions.objects) do   --JUNGLES
				if IsContainPoint(myHero,minion,Q2.range,Q2.width+VP:GetHitBox(Target),position) then
					return Q2:__Cast(minion)
				end
			end
		end
	end
end
function CAST_W(Target)
	return W:Cast(Target)
end
function CAST_R(Target)	
	if R_ON then
		TRACK_R(Target)
	end
end

function TRACK_R(Target)
	if not ValidTarget(Target) then return end
	
	local K9 = Vector(myHero)
	local R_START
	_, _, R_START =  R:GetPrediction(Target)
	
	if R_START then
		local R_END = R_START - R_DIRECTION*R.range
		local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(R_START,R_END,K9)
		
		R_ORBWALK_POS=pointSegment
		SOWi:ForceOrbWalkTo({x=pointSegment.x,z=pointSegment.y}) 
	else
		SOWi:ForceOrbWalkTo(nil)
	end
end


function IsOnLine(v1, v2, v)
	local X = (v.x - v1.x) / (v2.x - v1.x)
	local Y = (v.y - v1.y) / (v2.y - v1.y)
	local Z = (v.z - v1.z) / (v2.z - v1.z)
	--print(math.abs(X-Z))
    return math.abs(X-Z)<0.1
end

--[[
local MoveFn=myHero.MoveTo
myHero.MoveTo=function(self,x,y)
	if R_ON and menu.R.track then
		local new_K9 = Vector(x,0,y)		
		local _, _, R_START =  R:GetPrediction(GetTarget())
		local R_END = R_START - R_DIRECTION*R.range
		if IsOnLine(R_START,R_END,new_K9) then			
			return MoveFn(self,x,y)
		else
			return
		end
	else		
		return MoveFn(self,x,y)
	end
end]]
function AfterAttack(target,mode)
	if ValidTarget(target) and not PASSIVE_ON then
		if (  ( target.type==myHero.type and ((menu.Q.combo and menu.Combo) or (menu.Harass and menu.Q.harass))) or (menu.Q.cast) ) and Q1:IsReady() then
			CAST_Q(target)
		elseif ((menu.W.combo and menu.Combo) or (menu.Harass and menu.W.harass) or (menu.W.cast) ) and W:IsReady() then
			CAST_W(target)
		end
	end
end
end
--[[
███╗   ███╗    ██╗    ███████╗     ██████╗    ███████╗
████╗ ████║    ██║    ██╔════╝    ██╔════╝    ██╔════╝
██╔████╔██║    ██║    ███████╗    ██║         ███████╗
██║╚██╔╝██║    ██║    ╚════██║    ██║         ╚════██║
██║ ╚═╝ ██║    ██║    ███████║    ╚██████╗    ███████║
╚═╝     ╚═╝    ╚═╝    ╚══════╝     ╚═════╝    ╚══════╝
                                                      
--]]
do
function IsContainPoint(S, E, range, width, point)  --can use for Lissandra _Q
	S = Vector(S)
	E = Vector(E)
	E = S + (E-S):normalized()*range
	local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(S, E, point)
	
	if menu.Extras.DebugQ then
		DEBUGPOINT=pointSegment
	end
	
	return isOnSegment and (point.x-pointSegment.x)^2+(point.z-pointSegment.y)^2 <= width * width
end



function OnDraw2()
	if menu.Extras.DebugQ then
		if DEBUGPOINT and DEBUGTARGET then
			DrawCircle3D(DEBUGPOINT.x, 0, DEBUGPOINT.y, SPELL_DATA[_Q2 ].width+VP:GetHitBox(DEBUGTARGET), 1,  ARGB(255,255,0,0))
		end
	end
	if R_ON and menu.Extras.DebugR then
		local K9=Vector(myHero)
		local R_POP=K9+R_DIRECTION*R.range
		DrawCircle3D(R_POP.x, 0, R_POP.z, 100, 1,  ARGB(255,255,0,0))
		if R_ORBWALK_POS then		
			DrawCircle3D(R_ORBWALK_POS.x, 0, R_ORBWALK_POS.y, 100, 1,  ARGB(255,0,0,255))
		end
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
			local HP 	= enemy.health
			
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
end
