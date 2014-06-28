if myHero.charName ~= "Riven" then return end

local version = "0.47"
local SCRIPT_NAME = "Riven"
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

local _Q3=_PASIVE+1
local _RQ=_PASIVE+2
local _RQ3=_PASIVE+3
local _RW=_PASIVE+4
local SPELL_DATA = { [_Q  ] = { skillshotType = SKILLSHOT_CONE,		range = 260, speed = 780, width = 50, delay=0.25},--Q1,Q2
					 [_Q3 ] = { skillshotType = SKILLSHOT_CONE, 	range = 300, speed = 565, width = 50, delay=0.40},--Q3
					 [_RQ ] = { skillshotType = SKILLSHOT_CONE,		range = 325, speed = 780, width = 50, delay=0.25},--R Q1,Q2
					 [_RQ3] = { skillshotType = SKILLSHOT_CONE,		range = 400, speed = 565, width = 50, delay=0.40},--R Q3
					 [_W  ] = { skillshotType = nil, 				range = 250},
					 [_RW ] = { skillshotType = nil, 				range = 270},--RW
					 [_E  ] = { skillshotType = SKILLSHOT_LINEAR,	range = 325, speed = 1235, width = 100, delay=0.25},
					 [_R  ] = { skillshotType = SKILLSHOT_CONE, 	range = 900, speed = 2000, width = 45*0.5  , delay=0.25},
}


local menu
local IM
local Q_Sequence=0
local R_ON=false
local R_ON_FLAG=false
local Target
local HYDRA
local TIAMAT
local AnimationCancel={
	[1]=function() myHero:MoveTo(mousePos.x,mousePos.z) end, --"Move"
	[2]=function() SendChat('/l') end, --"Laugh"
	[3]=function() SendChat('/d') end, --"Dance"
	[4]=function() SendChat('/l') end, --"Laugh"
	[5]=function() SendChat('/t') end, --"Taunt"
	[6]=function() SendChat('/j') end, --"joke"
	[7]=function() end,
}
local Q,Q3,RQ,RQ3
local W,RW
local E
local R
function OnLoad()
	VP = VPrediction()	
	SOWi = FTER_SOW(VP)	
	STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC)
	--Q
		Q  = Spell(_Q,SPELL_DATA[_Q  ].range)
		Q3 = Spell(_Q,SPELL_DATA[_Q3 ].range)
		RQ = Spell(_Q,SPELL_DATA[_RQ ].range)
		RQ3= Spell(_Q,SPELL_DATA[_RQ3].range)
			Q:SetSkillshot(VP, SPELL_DATA[_Q].skillshotType, SPELL_DATA[_Q].width,   SPELL_DATA[_Q].delay,   SPELL_DATA[_Q].speed) 		Q:SetAOE(true)
		   Q3:SetSkillshot(VP, SPELL_DATA[_Q3].skillshotType,  SPELL_DATA[_Q3].width, SPELL_DATA[_Q3].delay, SPELL_DATA[_Q3].speed) 	Q3:SetAOE(true)
		   RQ:SetSkillshot(VP, SPELL_DATA[_RQ].skillshotType,  SPELL_DATA[_RQ].width, SPELL_DATA[_RQ].delay, SPELL_DATA[_RQ].speed) 	RQ:SetAOE(true)
		  RQ3:SetSkillshot(VP, SPELL_DATA[_RQ3].skillshotType, SPELL_DATA[_RQ].width, SPELL_DATA[_RQ3].delay, SPELL_DATA[_RQ3].speed) 	RQ3:SetAOE(true)
	--W
		W  = Spell(_W,SPELL_DATA[_W].range)
		RW = Spell(_W,SPELL_DATA[_RW].range)
	--E
		E = Spell(_E,SPELL_DATA[_E].range)
			E:SetSkillshot(VP, SPELL_DATA[_E].skillshotType,SPELL_DATA[_E].delay, SPELL_DATA[_E].width, SPELL_DATA[_E].speed)
	--R
		R = Spell(_R,SPELL_DATA[_R].range) 
			R:SetSkillshot(VP, SPELL_DATA[_R].skillshotType,SPELL_DATA[_R].delay, SPELL_DATA[_R].width, SPELL_DATA[_R].speed)
			R:SetAOE(true)
	
	menu = scriptConfig('Riven', 'Riven')
	
	--OW
	menu:addSubMenu("Orbwalking", "Orbwalking")
		SOWi:LoadToMenu(menu.Orbwalking)
	--TS
	menu:addSubMenu("Target selector", "STS")
		STS:AddToMenu(menu.STS)	
	--SKILLS
	menu:addSubMenu("Q","Q")
		menu.Q:addParam("cast","CAST@Q",SCRIPT_PARAM_ONKEYDOWN,false,string.byte("A")) menu.Q:permaShow("cast")
		menu.Q:addParam("ks","use Q for killsteal",SCRIPT_PARAM_ONOFF,true)		
		menu.Q:addParam("farm","use Q for farm",SCRIPT_PARAM_ONOFF,true)
		menu.Q:addParam("aaCombo","use Q After AA combo",SCRIPT_PARAM_ONOFF,true)
		menu.Q:addParam("aaFarm","use Q After AA farm",SCRIPT_PARAM_ONOFF,true)
			SOWi:RegisterAfterAttackCallback(function(target,mode)				
				if Q:IsReady() and ((menu.combo and menu.Q.aaCombo) or (menu.farm and menu.Q.aaFarm)) then
					if target.type==myHero.type then
						CAST_Q(target)
					else
						Q:Cast(mousePos.x,mousePos.z)
					end
				elseif menu.combo and not W:IsReady() and not E:IsReady() then
					IM:CAST_OFFENSIVE_AD(target,true)
				end
			end)
		menu.Q:addParam("q0", "Q1 AA reset Delay", SCRIPT_PARAM_SLICE, 0.25, 0.1,0.5,2)
		menu.Q:addParam("q1", "Q2 AA reset Delay", SCRIPT_PARAM_SLICE, 0.25, 0.1,0.5,2)
		menu.Q:addParam("q2", "Q3 AA reset Delay", SCRIPT_PARAM_SLICE, 0.25, 0.1,0.5,2)
		menu.Q:addParam("default","Set Default Delay",SCRIPT_PARAM_ONOFF,false)AddTickCallback(function()
			if menu.Q.default then
				menu.Q.default=false
				menu.Q.q1,menu.Q.q2,menu.Q.q3=0.25,0.25,0.25
			end
		end)
		
		
		menu.Q:addParam("gap0","gapclose with Q1",SCRIPT_PARAM_ONOFF,false)		
		menu.Q:addParam("rangegap0", "Q1 gapclose range", SCRIPT_PARAM_SLICE, 300, 0, 500)
		menu.Q:addParam("gap1","gapclose with Q2",SCRIPT_PARAM_ONOFF,false)		
		menu.Q:addParam("rangegap1", "Q2 gapclose range", SCRIPT_PARAM_SLICE, 300, 0, 500)
		menu.Q:addParam("gap2","gapclose with Q3",SCRIPT_PARAM_ONOFF,false)		
		menu.Q:addParam("rangegap2", "Q3 gapclose range", SCRIPT_PARAM_SLICE, 300, 0, 500)
	menu:addSubMenu("W","W")
		menu.W:addParam("ks","use W for killsteal",SCRIPT_PARAM_ONOFF,true)
		menu.W:addParam("tiamat","use W after tiamat",SCRIPT_PARAM_ONOFF,true)
	menu:addSubMenu("E","E")
		menu.E:addParam("cast","cast E to Target",SCRIPT_PARAM_ONKEYDOWN,false,string.byte("A")) menu.E:permaShow("cast")
		menu.E:addParam("tiamat","use timat after E",SCRIPT_PARAM_ONOFF,true)
		menu.E:addParam("ult","activate R after E(when killlable)",SCRIPT_PARAM_ONOFF,true)
	menu:addSubMenu("R","R")
		menu.R:addParam("ks","use R for killsteal",SCRIPT_PARAM_ONOFF,true)
		menu.R:addParam("auto","auto activate R",SCRIPT_PARAM_ONOFF,true)
		menu.R:addParam("wait","^ wait E Cast  ",SCRIPT_PARAM_ONOFF,true)
		menu.R:addParam("ws","use second R",SCRIPT_PARAM_ONOFF,true)
		menu.R:addParam("cast","cast 2nd R to Target",SCRIPT_PARAM_ONKEYDOWN,false,string.byte("T"))
		
	--CANCELER
	menu:addParam("cancel", "Animation Cancel Method", SCRIPT_PARAM_LIST, 1, { "Move","Laugh","Dance","Taunt","joke","Nothing" })
		AddProcessSpellCallback(function(unit, spell)
				if not unit.isMe then return end
				
				
				if menu.combo or menu.farm then
					if spell.name == 'RivenTriCleave' then -- _Q
						DelayAction(function() SOWi:resetAA() end, menu.Q["q"..Q_Sequence])
						AnimationCancel[menu.cancel]()
					elseif spell.name == 'RivenMartyr' then -- _W				
						 AnimationCancel[menu.cancel]()
					elseif spell.name == 'RivenFeint'  then -- _E	
						--OnLy To OnTick Target
						if ValidTarget(R_ON_FLAG_TARGET,300) and R_ON_FLAG and R:IsReady() then --AUTOMATIC R
							CAST_R1()
						end
						if ValidTarget(Target) and W:IsReady() and CAST_W(Target)==SPELLSTATE_TRIGGERED then												
							IM:CAST_OFFENSIVE_AD(Target,true)
						end
						AnimationCancel[menu.cancel]()
					elseif spell.name == 'RivenFengShuiEngine' then -- _R first cast				
						AnimationCancel[menu.cancel]()
					end
				end
			end)
	
	--ITEMS
	menu:addSubMenu("Items","Items")
		IM=ITEM_MANAGER(menu.Items,STS) HYDRA=IM.HYDRA TIAMAT=IM.TIAMAT
	--DRAWING
	menu:addSubMenu("Drawings", "Drawings")
		local DManager = DrawManager()
		DManager:CreateCircle(myHero, SPELL_DATA[_Q].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"Q range", true, true, true)
		DManager:CreateCircle(myHero, SPELL_DATA[_W].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"W range", true, true, true)
		DManager:CreateCircle(myHero, SPELL_DATA[_E].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"E range", true, true, true)
		DManager:CreateCircle(myHero, SPELL_DATA[_R].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"R range", true, true, true)
		
	menu:addParam('combo', 'combo', SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C")) 	menu:permaShow('combo')
	menu:addParam('farm',  'farm', SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))		menu:permaShow('farm')
	menu:addParam('flee',  'flee', SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))		menu:permaShow('flee')
	
	AddTickCallback(OnTick2)
end
function OnTick2()

	if menu.flee then
		myHero:MoveTo(mousePos.x,mousePos.z)
		if Q:IsReady() then
			Q:Cast(mousePos.x,mousePos.z)
		end
		if E:IsReady() then
			E:Cast(mousePos.x,mousePos.z)
		end
		return
	end
	--KS
	for _, enemy in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) then
			local Qd=Riven_GetDmg(_Q, enemy, false)
			local Wd=Riven_GetDmg(_W, enemy, false)
			local Rd=Riven_GetDmg(_R, enemy, true)
			--W
			if W:IsReady() and W:IsInRange(enemy) and Wd > enemy.health and CAST_W(enemy)==SPELLSTATE_TRIGGERED then				
				goto continue
			end
			--Q
			if Q:IsReady() and Q:IsInRange(enemy) and Qd > enemy.health and CAST_Q(enemy)==SPELLSTATE_TRIGGERED then					
				goto continue
			end
			--R
			if R:IsReady() and R:IsInRange(enemy) and Rd > enemy.health then--never turn on R to ks with R
				if menu.R.ks and R_ON then
					CAST_R2(enemy)
				else
					PrintAlert_T("RKS",enemy.charName.." R2 Killable",3,255,255,255,0)
				end
			end
		end
		::continue::
	end
	
	--SET TARGET	
	Target = STS:GetTarget(1200) 
	if not Target or not ValidTarget(Target) then return end	


	if menu.R.auto then--not menu.R.wait and menu.R.auto then
		if ValidTarget(R_ON_FLAG_TARGET,500) and R_ON_FLAG and R:IsReady() then --activate R
			CAST_R1()
		end			
	end
	
	
	--Combo
	if menu.combo then
	
		--R
		if (Q_Sequence==0 and Q:IsReady()) and (R_ON==false and R:IsReady()) and (GetComboDmg(Target,false) < Target.health) and (GetComboDmg(Target,true) > Target.health) then
			PrintAlert_T("RCOMBO"..Target.charName,Target.charName.." R COMBO KILLABLE",3,255,255,255,0)
			if menu.R.wait and menu.R.auto then
				R_ON_FLAG=true
				R_ON_FLAG_TARGET=Target
			elseif menu.R.auto then			
				R_ON_FLAG=true
				R_ON_FLAG_TARGET=Target
				CAST_R1()
			end
		end
		--E
		if E:IsReady() and not SOWi:InRange(Target) then
			CAST_E(Target)
		end
		--W
		if W:IsReady() then
			CAST_W(Target)
		end
		--Q
		if not SOWi:InRange(Target) or menu.Q.cast or (not SOWi:CanAttack() and SOWi.Attack_Completed==true) then
			if not CAST_Q(Target) then--Q failed for distance				
				GAPCLOSE_Q(Target)
			end
		end
	end
end 
local P_Stack=0
local P_BuffName="rivenpassiveaaboost"
local Q_BuffName="RivenTriCleave" 
local R_BuffName='RivenFengShuiEngine'
function OnGainBuff(unit,buff)
	if unit.isMe then
		if buff.name==P_BuffName then
			P_Stack=1
		elseif buff.name==Q_BuffName then 
			Q_Sequence=1
		elseif buff.name==R_BuffName then
			R_ON_FLAG=false
			R_ON=true
		end
	end 
end
function OnLoseBuff(unit,buff)
	if unit.isMe then
		if buff.name==P_BuffName then
			P_Stack=0
		elseif buff.name=="RivenTriCleave" then 
			Q_Sequence=0	
		elseif buff.name==R_BuffName then	
			R_ON=false
		end
	end
end
function OnUpdateBuff(unit,buff)
	if unit.isMe then
		if buff.name=="RivenTriCleave" then 
			Q_Sequence=2
		elseif buff.name==P_BuffName then
			P_Stack=buff.stack
		end
	end
end
function GAPCLOSE_Q(target)
	local range = menu.Q["rangegap"..Q_Sequence]
	local rangeSqr = range*range
	if menu.Q["gap"..Q_Sequence] and GetDistanceSqr(Target)<=rangeSqr then
		CastSpell(_Q,target.x,target.z)
	end	
end
function CAST_Q(target)--COMBO Q	
	if R_ON then
		if Q_Sequence==2 and RQ3:IsInRange(target) then	--3rd Q
			return RQ3:Cast(target.x,target.z)==SPELLSTATE_TRIGGERED
		elseif RQ:IsInRange(target) then
			return RQ:Cast(target.x,target.z)==SPELLSTATE_TRIGGERED
		end
	else
		if Q_Sequence==2 and Q3:IsInRange(target) then	--3rd Q
			return Q3:Cast(target.x,target.z)==SPELLSTATE_TRIGGERED
		elseif Q:IsInRange(target) then
			return Q:Cast(target.x,target.z)==SPELLSTATE_TRIGGERED
		end
	end
end
function CAST_W(target)--COMBO W
	if W:IsInRange(target) then
		return W:Cast()
	elseif R_ON and RW:IsInRange(target) then
		return RW:Cast()
	end
end
function CAST_E(target)--COMBO E
	if E:Cast(target)==SPELLSTATE_TRIGGERED then
		return
	elseif menu.E.cast then --manual GAP CLOSE
		E:Cast(target.x,target.z)
	end
end

function CAST_R1()
	if not R_ON then
	--	print("R1 on CAST_R1")
		CastSpell(_R)
	end
end

function CAST_R2(target)
	if R_ON then
		--print("R2")
		R:Cast(target)
	else
		--print("R1 on CAST_R2")
		CastSpell(_R)
	end
end

--[[
██████╗                ██████╗     █████╗     ██╗          ██████╗
██╔══██╗              ██╔════╝    ██╔══██╗    ██║         ██╔════╝
██║  ██║    █████╗    ██║         ███████║    ██║         ██║     
██║  ██║    ╚════╝    ██║         ██╔══██║    ██║         ██║     
██████╔╝              ╚██████╗    ██║  ██║    ███████╗    ╚██████╗
╚═════╝                ╚═════╝    ╚═╝  ╚═╝    ╚══════╝     ╚═════╝
                                                                  
--]]
function Riven_GetDmg(slot,target,useR)
	local ad,bad	
	if useR then		
		bad = myHero.addDamage*(1.2)
		ad = myHero.totalDamage+bad
	else		
		ad = myHero.totalDamage
		bad= myHero.addDamage
	end
	
	local DAMAGEs={	
		[_PASIVE] = function() return ((20+5*math.floor(myHero.level/3))*0.01*ad) end,
		[_Q		] = function() return 20*myHero:GetSpellData(_Q).level-10+(.05*myHero:GetSpellData(_Q).level+.35)*ad end,--xstrike (3 strikes)
		[_W		] = function() return 30*myHero:GetSpellData(_W).level+20+bad end,
		[_R		] = function()
			local hpercent=target.health/target.maxHealth
			if hpercent<=0.25 then
				return 120*myHero:GetSpellData(_R).level+120+1.8*bad
			else
				return (40*myHero:GetSpellData(_R).level+40+0.6*bad) * (hpercent)*(-2.67) + 3.67
			end
		end
	}	
	if slot==_AA then
		return myHero:CalcDamage(target,ad)
	else
		return myHero:CalcDamage(target,DAMAGEs[slot]())
	end
end
function GetComboDmg(target,useR)
	local count = 0
	local totalDmg = 0
	
	if Q_Sequence==0 and myHero:CanUseSpell(_Q) == READY then
		count = count + 3
		totalDmg = totalDmg + (Riven_GetDmg(_Q,target,useR)+Riven_GetDmg(_AA,target,useR)) * 3
	end

	if myHero:CanUseSpell(_W) == READY then
		count = count + 1
		totalDmg = totalDmg + Riven_GetDmg(_W,target,useR)
	end

	if myHero:CanUseSpell(_E) == READY then
		count = count + 1
	end

	if useR then
		count = count + 2
		totalDmg = totalDmg + Riven_GetDmg(_R,target,useR)
	end

	totalDmg = totalDmg + Riven_GetDmg(_PASIVE,target,useR)  * count
	return totalDmg
end
function OnDraw()
	--DrawText("R_ON:"..tostring(R_ON).." R_ON_FLAG:"..tostring(R_ON_FLAG),18,500 ,500 ,ARGB(255,0,255,0))		
end
local Alert_Texts={}
function PrintAlert_T(id,text,duration,r,g,b)
	if Alert_Texts[id] then
		if Alert_Texts[id]<os.clock() then --used before
			PrintAlert(text,duration,r,g,b)
			Alert_Texts[id]=os.clock()+10
		end
	else
		PrintAlert(text,duration,r,g,b)
		Alert_Texts[id]=os.clock()+10
	end	
end
function FTER_SOW:BonusDamage(minion) 
	if P_Stack>0 then 		
		return Riven_GetDmg(_PASIVE,minion,false)-5 --
	end
	return 0
end
--[[
██████╗               ██╗    ███╗   ██╗    ██████╗     ██╗     ██████╗     █████╗     ████████╗     ██████╗     ██████╗ 
██╔══██╗              ██║    ████╗  ██║    ██╔══██╗    ██║    ██╔════╝    ██╔══██╗    ╚══██╔══╝    ██╔═══██╗    ██╔══██╗
██║  ██║    █████╗    ██║    ██╔██╗ ██║    ██║  ██║    ██║    ██║         ███████║       ██║       ██║   ██║    ██████╔╝
██║  ██║    ╚════╝    ██║    ██║╚██╗██║    ██║  ██║    ██║    ██║         ██╔══██║       ██║       ██║   ██║    ██╔══██╗
██████╔╝              ██║    ██║ ╚████║    ██████╔╝    ██║    ╚██████╗    ██║  ██║       ██║       ╚██████╔╝    ██║  ██║
╚═════╝               ╚═╝    ╚═╝  ╚═══╝    ╚═════╝     ╚═╝     ╚═════╝    ╚═╝  ╚═╝       ╚═╝        ╚═════╝     ╚═╝  ╚═╝
                                                                                                                        
--]]

function Damage_OnLoad()
	AddTickCallback(Damage_OnTick)
	AddDrawCallback(Damage_OnDraw)
end AddLoadCallback(Damage_OnLoad)
local Damage_cached={}
local Damage_NextTick=0
function Damage_OnTick()
    if os.clock() > Damage_NextTick then
		Damage_NextTick=os.clock()+0.2
        for i, enemy in ipairs(GetEnemyHeroes()) do
            if ValidTarget(enemy) then                
				Damage_cached[enemy.hash] = GetComboDmg(enemy,false)
            end
        end
    end
end

function Damage_OnDraw()
    for i, enemy in ipairs(GetEnemyHeroes()) do
        if ValidTarget(enemy) then
            Damage_DrawIndicator(enemy)
        end
    end
end

function Damage_DrawIndicator(enemy)

    local damage = Damage_cached[enemy.hash] or 0
    local SPos, EPos = GetEnemyHPBarPos(enemy)

    -- Validate data
    if not SPos then return end

    local barwidth = EPos.x - SPos.x
    local Position = SPos.x + math.max(0, (enemy.health - damage) / enemy.maxHealth) * barwidth

    DrawText("|", 16, math.floor(Position), math.floor(SPos.y + 8), ARGB(255,0,255,0))
    DrawText("HP: "..math.floor(enemy.health - damage), 13, math.floor(SPos.x), math.floor(SPos.y), (enemy.health - damage) > 0 and ARGB(255, 0, 255, 0) or  ARGB(255, 255, 0, 0))

end
