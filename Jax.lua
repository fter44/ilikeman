if myHero.charName ~= "Jax" then return end





local version = "0.21"
local SCRIPT_NAME = "Jax"
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
RequireI:Add("VPrediction", 	"https://raw.github.com/fter44/ilikeman/master/common/LEVEL.lua")
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

local VP
local SOWi
local Q,W,E,R
local DLib
local IM
local SPELL_DATA = { [_Q] = { skillshotType = nil, range = 700},
					 [_W] = { skillshotType = nil, range = 450},
					 [_E] = { skillshotType = nil, range = 375},
					 [_R] = { skillshotType = nil, range = 375},
}
function OnLoad()
	VP = VPrediction()	
	SOWi = SOW(VP)
	STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC)
	Q = Spell(_Q,SPELL_DATA[_Q].range)
	W = Spell(_W,SPELL_DATA[_W].range)
	E = Spell(_E,SPELL_DATA[_E].range)
	R = Spell(_R,SPELL_DATA[_R].range)
	
	menu=scriptConfig("Jax","Jax")
	--OW
	menu:addSubMenu("Orbwalking", "Orbwalking")
		SOWi:LoadToMenu(menu.Orbwalking)
	--TS
	menu:addSubMenu("Target selector", "STS")
		STS:AddToMenu(menu.STS)
	--SKILLS
	menu:addSubMenu("Q","Q")
	--	menu.Q:addParam("ks","use Q for killsteal",SCRIPT_PARAM_ONOFF,false)
		menu.Q:addParam("use","use Combo Q",SCRIPT_PARAM_ONOFF,true)-- menu.Q:permaShow("use")
		menu.Q:addParam("cast","CAST Q TO TARGET",SCRIPT_PARAM_ONKEYDOWN, false, string.byte('Q'))
	menu:addSubMenu("W","W")
		menu.W:addParam("reset","W AAreset Combo",SCRIPT_PARAM_ONOFF,true)
		menu.W:addParam("resetT","W AAreset Tower/Inhib/Nexus",SCRIPT_PARAM_ONOFF,true)
		menu.W:addParam("resetJ","W AAreset Jungle",SCRIPT_PARAM_ONOFF,true)
		SOWi:RegisterAfterAttackCallback(function(target)
			if (menu.W.reset and menu.combo) or (menu.W.resetT and (target.type=="obj_AI_Turret" or target.type=="obj_HQ" or target.type=="obj_BarracksDampener")) or (menu.W.resetJ and target.team==TEAM_NEUTRAL) then 
				W:Cast() 
			end 
		end)
	menu:addSubMenu("E","E")
		menu.E:addParam("use","use Combo E",SCRIPT_PARAM_ONOFF,true)-- menu.E:permaShow("use")
		menu.E:addParam("AutoE","use Auto E_Explore",SCRIPT_PARAM_ONOFF,true)	--menu.E:permaShow("AutoE")
		menu.E:addParam("AutoC","use Auto E against Champ",SCRIPT_PARAM_ONOFF,true)-- menu.E:permaShow("AutoC")--Champion 
		menu.E:addParam("AutoCJ","use Auto E againstJungle",SCRIPT_PARAM_ONOFF,true)--menu.E:permaShow("AutoCJ")--Jungle
		menu.E:addParam("Disable","Auto Disable ^ At level", SCRIPT_PARAM_SLICE, 6, 1, 18)
			if myHero.level<11 then
				menu.E.AutoCJ=true
			else
				menu.E.AutoCJ=false
			end
			LEVEL():RegisterOnLevelUPCallback(	function(level) 
													if level==menu.E.Disable then
														Color_Print_I("JAX","RED","Auto-Disable AUTO E AGAINST JUNGLE")
														menu.E.AutoCJ=false 
													end
												end
					)
	menu:addSubMenu("Items","Items")
		IM=ITEM_MANAGER(menu.Items,STS)
	--DAMAGE
	--DLib = DamageLib()
	--	DLib:RegisterDamageSource(_Q, _PHYSICAL, 25, 45, _PHYSICAL, _BONUS_AD, 1.0, function() return Q:IsReady() end)
	--	DLib:RegisterDamageSource(_E, _TRUE, 25, 45, _TRUE, _AD, 0.4, function() return E:IsReady() end)
	--DRAWING
	menu:addSubMenu("Drawings", "Drawings")
		local DManager = DrawManager()
		DManager:CreateCircle(myHero, SPELL_DATA[_Q].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"Q range", true, true, true)
		DManager:CreateCircle(myHero, SPELL_DATA[_E].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"E range", true, true, true)
	--	DLib:AddToMenu(menu.Drawings,{_AA,_Q,_Q,_E,_E,_IGNITE})
	--KEY
	menu:addParam("combo","combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('C'))  menu:permaShow("combo")
	menu:addParam('farm',  'farm', SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	--menu:addParam("harass","harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('X'))
end
--E
local E_Widths = 375 
local E_Activated = false
local E_Time = 0
local E_rangeAllow = E_Widths - 15
local E_rangeToPop = E_Widths - 5
function Auto_E_Explore()
	if menu.E.AutoE and E_Activated and myHero:CanUseSpell(_E) == READY and enemyChamp then
		for i,enemy in ipairs(enemyChamp) do
			local cRange = GetDistance(myHero,enemy)
			if ValidTarget(enemy) and E_Activated and cRange <= E_rangeToPop then				
				if not cRange <= E_rangeAllow - GetDistance(enemy.minBBox, enemy.maxBBox)/2 then --Enemy Try to out of range
					CastSpell(_E) E_Activated=false
					Color_Print_I("JAX","RED","Spell(_E)-Enemy Try to out of range")
				end
				if os.clock() - E_Time >= 1.9 then --Time Expire
					CastSpell(_E) E_Activated=false
					Color_Print_I("JAX","RED","Spell(_E)-Time Expire")
				end
			end
		end
	end
end
function OnTick()
	Auto_E_Explore()--E	
	local Target = STS:GetTarget(SPELL_DATA[_Q].range)
	if not Target or not ValidTarget(Target) then return end
	
	
	
	--MANUAL CAST
	if menu.Q.cast and Q:IsReady() and Q:IsInRange(Target) then--Q
		Q:Cast(Target)
	end		
	--COMBO
	if menu.combo then
		--ITEMS
		--if menu.Items.off then --OLD METHODS
		--	UseOffensiveItems(Target)
		--end
		--AUTO CAST
		if menu.Q.use and Q:IsInRange(Target) and Q:IsReady() then--E
			Q:Cast(Target)
		end
		if menu.E.use and E:IsInRange(Target) and E:IsReady() then--E
			E:Cast()
		end
	end
	--HARASS
	--if menu.harass then		
	--end
end
--PROCESS E
function OnGainBuff(u,b)
	if u.isMe then
		if b.name=="JaxCounterStrike" then
			E_Activated = true
			E_Time = os.clock()
		end
	end
end
function OnLoseBuff(u,b)
	if u.isMe then
		if b.name=="JaxCounterStrike" then
			E_Activated = false
		end
	end
end
function OnProcessSpell(unit,spell)
	if not E_Activated and E:IsReady() and ( (menu.E.AutoC and unit.type==myHero.type)  or (menu.E.AutoCJ and unit.team==TEAM_NEUTRAL) ) and spell.target and spell.target.isMe and IsAASpell(spell) then
		CastSpell(_E)
	end
end
--Enemy
local Kill_Text={}
function KillDamage()
	for _, enemy in pairs(GetEnemyHeroes()) do
		local Qdmg=getDmg("Q",enemy,myHero)
		local Wdmg=getDmg("W",enemy,myHero)
		local AAdmg=getDmg("AD",enemy,myHero)
		local Rdmg=getDmg("R",enemy,myHero)
		if Qdmg>=enemy.health then
			Kill_Text[enemy.networkID]="Q kill"
		elseif Wdmg+AAdmg>=enemy.health then
			Kill_Text[enemy.networkID]="W+AA kill"
		elseif Qdmg+Wdmg>=enemy.health then
			Kill_Text[enemy.networkID]="Q+W kill"
		elseif Qdmg+Wdmg+AAdmg>=enemy.health then
			Kill_Text[enemy.networkID]="Q+W+AA kill"
		elseif Qdmg+Wdmg+AAdmg+Rdmg>=enemy.health  then
			Kill_Text[enemy.networkID]="Q+W+R kill"
		else
			Kill_Text[enemy.networkID]=nil
		end
	end
end TickLimiter(KillDamage,4) -- 4 time per sec




--_R(3hit) DAMAGE CALC by _PASIVE BUFF INFO
local _P_NAME="jaxrelentlessassaultas"
local _P_STACK=0
local _R_STACK=0 --1 2 3(pop) 4 5 6(pop)
local _R_ON=false

function OnDraw()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) then
			local barPos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
			local PosX = barPos.x - 35
			local PosY = barPos.y - 50			
			if Kill_Text[enemy.networkID] then
				DrawText(Kill_Text[enemy.networkID],18,PosX ,PosY ,ARGB(255,0,255,0))	
			end			
		end
	end
	--DrawText("_P:".._P_STACK.." _R:".._R_STACK.." _R_ON:"..tostring(_R_ON),18,500 ,500 ,ARGB(255,0,255,0))	
end
function OnGainBuff(unit,buff)
	if unit.isMe and buff.name==_P_NAME then
		_P_STACK=1
		_R_STACK=1
	end
end
function OnUpdateBuff(unit,buff)
	if unit.isMe and buff.name==_P_NAME and R:GetLevel()>0 then
		if _R_ON then
			_R_ON=false
			_R_STACK=-1
		end
		_P_STACK=buff.stack
		_R_STACK=_R_STACK+1
		if _R_STACK==2 then
			_R_ON=true
		end
	end
end
function OnLoseBuff(unit,buff)
	if unit.isMe and buff.name==_P_NAME  then
		_P_STACK=0
		_R_STACK=0
		_R_ON=false
	end
end

function SOW:BonusDamage(minion) 
	local BONUS=0
	if myHero:GetSpellData(_W).level > 0 and myHero:CanUseSpell(_W) == SUPRESSED then ----35*Wlvl+5+.6*ap
		BONUS = BONUS + myHero:CalcMagicDamage(minion, ((35 * myHero:GetSpellData(_W).level) + 5 ) + myHero.ap*.6 )			
	end
	if _R_ON then--RDmgM = "60*Rlvl+40+.7*ap", --every third basic attack (bonus)
		BONUS = BONUS + myHero:CalcMagicDamage(minion, ((60 * myHero:GetSpellData(_R).level) + 40 ) + myHero.ap*.7 )			
	end
	return BONUS
end
