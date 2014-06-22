--[[
██╗  ██╗     █████╗     ███████╗    ███████╗     █████╗     ██████╗     ██╗    ███╗   ██╗
██║ ██╔╝    ██╔══██╗    ██╔════╝    ██╔════╝    ██╔══██╗    ██╔══██╗    ██║    ████╗  ██║
█████╔╝     ███████║    ███████╗    ███████╗    ███████║    ██║  ██║    ██║    ██╔██╗ ██║
██╔═██╗     ██╔══██║    ╚════██║    ╚════██║    ██╔══██║    ██║  ██║    ██║    ██║╚██╗██║
██║  ██╗    ██║  ██║    ███████║    ███████║    ██║  ██║    ██████╔╝    ██║    ██║ ╚████║
╚═╝  ╚═╝    ╚═╝  ╚═╝    ╚══════╝    ╚══════╝    ╚═╝  ╚═╝    ╚═════╝     ╚═╝    ╚═╝  ╚═══╝
                                                                                         
--]]

if myHero.charName ~= "Kassadin" then return end

--Libraries
local lib_infos={
	["vPrediction" ]		= "https://raw.github.com/honda7/BoL/master/Common/VPrediction.lua",
	["FTER_SOW"]	  		= "https://raw.githubusercontent.com/fter44/ilikeman/master/common/FTER_SOW.lua",
	["ITEM_MANAGER"	]		= "https://raw.githubusercontent.com/fter44/ilikeman/master/common/ITEM_MANAGER.lua",
	["DRAW_POS_MANAGER"]  	= "https://raw.githubusercontent.com/fter44/ilikeman/master/common/DRAW_POS_MANAGER.lua",
}
local SCRIPT_NAME = "Kassadin"
local My_Version = 0.30
local My_Host = "raw.github.com"
local My_Path = "/fter44/ilikeman/master/"..SCRIPT_NAME..".lua"
local AUTOUPDATE = true
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
	 SourceUpdater(SCRIPT_NAME, My_Version, My_Host, My_Path, SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/fter44/ilikeman/master/VersionFiles/"..SCRIPT_NAME..".version"):CheckUpdate()
end
local RequireI = Require("SourceLib")

for lib_name,lib_path in pairs(lib_infos) do
	RequireI:Add(lib_name,lib_path)
end 
RequireI:Check()
if RequireI.downloadNeeded == true then return end

--Actual code starts

local VP
local SOWi
local Q,W,E,R
local DLib
local IM
local menu

local KILLTEXTS--
local SPELL_DATA = { [_Q] = { skillshotType = nil, 					range = 650},
					 [_W] = { skillshotType = nil, 					range = 300},
					 [_E] = { skillshotType = SKILLSHOT_CONE,		range = 650, width=45*0.5, delay=0.25, speed=2500	  },
					 [_R] = { skillshotType = SKILLSHOT_CIRCULAR, 	range = 700, width=300,	   delay=0.50, speed=math.huge},
}
local Estack=0 local Rstack=0
local Ecast=false

function OnLoad()
	VP = VPrediction()	
	SOWi = SOW(VP)	SPELL_DATA[_W].range=SOWi:MyRange()+50
	STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC)
	Q = Spell(_Q,SPELL_DATA[_Q].range)
	W = Spell(_W,SPELL_DATA[_W].range)
	E = Spell(_E,SPELL_DATA[_E].range) E:SetSkillshot(VP, SPELL_DATA[_E].skillshotType,SPELL_DATA[_E].delay, SPELL_DATA[_E].width, SPELL_DATA[_E].speed)
	R = Spell(_R,SPELL_DATA[_R].range) 
		R:SetSkillshot(VP, SPELL_DATA[_R].skillshotType,SPELL_DATA[_R].delay, SPELL_DATA[_R].width, SPELL_DATA[_R].speed)
		R:SetAOE(true)
	
	menu=scriptConfig("Kassadin","Kassadin")
	--OW
	menu:addSubMenu("Orbwalking", "Orbwalking")
		SOWi:LoadToMenu(menu.Orbwalking)
	--TS
	menu:addSubMenu("Target selector", "STS")
		STS:AddToMenu(menu.STS)
	--SKILLS
	menu:addSubMenu("Q","Q")
		menu.Q:addParam("ks","use Q for killsteal",SCRIPT_PARAM_ONOFF,true)		
		menu.Q:addParam("farm","use Q for farm",SCRIPT_PARAM_ONOFF,true)		
		menu.Q:addParam("harass","use Q for Harass",SCRIPT_PARAM_ONOFF,true)		
		menu.Q:addParam("auto","Q Auto harass",SCRIPT_PARAM_ONOFF,true)
		menu.Q:addParam("mana","Don't auto harass if mana < %", SCRIPT_PARAM_SLICE, 0, 0, 100)
	menu:addSubMenu("W","W")
		menu.W:addParam("before","cast before AA",SCRIPT_PARAM_ONOFF,true)
			SOWi:RegisterBeforeAttackCallback(function(t)if t.type==myHero.type and menu.W.before and W:IsReady() then W:Cast() end end)
		menu.W:addParam("after","cast after AA",SCRIPT_PARAM_ONOFF,false)
			SOWi:RegisterAfterAttackCallback(function(t)if t.type==myHero.type and menu.W.after and W:IsReady() then W:Cast() end end)
		menu.W:addParam("auto","auto use for E stack",SCRIPT_PARAM_ONOFF,true)	
	menu:addSubMenu("E","E")
		menu.E:addParam("ks","use E for killsteal",SCRIPT_PARAM_ONOFF,true)
		menu.E:addParam("farm","use E for farm",SCRIPT_PARAM_ONOFF,true)
		menu.E:addParam("harass","use E for Harass",SCRIPT_PARAM_ONOFF,true)		
		menu.E:addParam("auto","E Auto harass",SCRIPT_PARAM_ONOFF,true)
		menu.E:addParam("mana","Don't auto harass if mana < %", SCRIPT_PARAM_SLICE, 0, 0, 100)		
	menu:addSubMenu("R","R")
		menu.R:addParam("cast","cast R to Target",SCRIPT_PARAM_ONKEYDOWN,false,string.byte("A"))
		menu.R:addParam("ks","USE R KS",SCRIPT_PARAM_ONKEYTOGGLE,false,string.byte("T")) menu.R:permaShow("ks") menu.R.ks=false
		menu.R:addParam("farm","use R for farm",SCRIPT_PARAM_ONOFF,false)
		menu.R:addSubMenu("R buff time","rtime")
			local RTIME=TEXTPOS_A(menu.R.rtime,"",12,_,_,true)
			AdvancedCallback:bind("OnGainBuff",function(unit,buff)
				if unit.isMe then
					if buff.name=="RiftWalk" then
						RTIME:COUNTDOWN_START(12) Rstack=1
					elseif buff.name=="forcepulsecounter" then
						Estack=1
					elseif buff.name=="forcepulsecancast" then
						Ecast=true
					end	
				end
			end)
			AdvancedCallback:bind("OnUpdateBuff",function(unit,buff)
				if unit.isMe then
					if buff.name=="RiftWalk" then
						RTIME:COUNTDOWN_START(12) Rstack=buff.stack
					elseif buff.name=="forcepulsecounter" then
						Estack=buff.stack
					end	
				end
			end)
			AdvancedCallback:bind("OnLoseBuff",function(unit,buff)
				if unit.isMe then
					if buff.name=="RiftWalk" then
						RTIME:COUNTDOWN_END() 	Rstack=0
					elseif buff.name=="forcepulsecounter" then
						Estack=0
					elseif buff.name=="forcepulsecancast" then
						Ecast=false
					end	
				end
			end)			
		menu.R:addParam("disableKs","Auto Disable ^ after", SCRIPT_PARAM_SLICE, 60, 0, 120) local disableKs=false
		menu.R:addParam("enableAutodisable","Enable ^ Auto Disable",SCRIPT_PARAM_ONOFF,true)
			AddTickCallback(function()
				if menu.R.ks and menu.R.enableAutodisable then
					if not disableKs then
						DelayAction(function() 
							disableKs=false menu.R.ks=false	
							print("R ks disabled Automatically")
						end,menu.R.disableKs)
						disableKs=true
					end
				elseif menu.R.ks==false then
					disableKs=false
				end
			end)
	--INTERRUPTER
	menu:addSubMenu("Interrupter","Interrupter")
		Interrupter(menu.Interrupter,function(unit,data)
			if Q:IsReady() and Q:IsInRange(unit) then
				Q:Cast(unit)
			end
		end)
	--ITEMS
	menu:addSubMenu("Items","Items")
		IM=ITEM_MANAGER(menu.Items,SOWi)
	--DAMAGE
	DLib = DamageLib()
		local _PASSIVE = 10001
		local _P=_PASSIVE 
		local _T=_PASSIVE+2
		local _MA=_MAXMANA
		DLib:RegisterDamageSource(_P, _MAGIC,  0,  0, _MAGIC, _AP, 0.01)
		DLib:RegisterDamageSource(_Q, _MAGIC, 55, 25, _MAGIC, _AP, 0.70, function() return (player:CanUseSpell(_Q) == READY) end)
		DLib:RegisterDamageSource(_W, _MAGIC,  5, 35, _MAGIC, _AP, 0.70, function() return (player:CanUseSpell(_W) == READY) end)
		DLib:RegisterDamageSource(_E, _MAGIC, 55, 45, _MAGIC, _AP, 0.70, function() return (player:CanUseSpell(_E) == READY) or (player:GetSpellData(_E).currentCd==0 and Estack>=4) end)
		DLib:RegisterDamageSource(_R, _MAGIC, 30, 10, _MAGIC, _MA, 0.01, function() return (player:CanUseSpell(_R) == READY) end)--(1 stack)
		DLib:RegisterDamageSource(_T,  _TRUE,  0,  0,  _TRUE,   0,    0, _,function(target) return DLib:CalcSpellDamage(target,_R)*(Rstack+2) end )--(1 stack)
	--DRAWING
	menu:addSubMenu("Drawings", "Drawings")
		local DManager = DrawManager()
		DManager:CreateCircle(myHero, SPELL_DATA[_Q].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"Q range", true, true, true)
		DManager:CreateCircle(myHero, SPELL_DATA[_W].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"W range", true, true, true)
		DManager:CreateCircle(myHero, SPELL_DATA[_E].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"E range", true, true, true)
		DManager:CreateCircle(myHero, SPELL_DATA[_R].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"R range", true, true, true)
		DLib:AddToMenu(menu.Drawings,{_AA,_P,_Q,_W,_E,_T,_IGNITE})
		menu.Drawings:addSubMenu("KillTexts","KillTexts")
			KILLTEXTS=TEXTPOS_HPBAR(menu.Drawings.KillTexts,18,0,30)
	--KEY
	
	menu:addParam("info", "--KASSADIN--by ilikeman", SCRIPT_PARAM_INFO, "") menu:permaShow("info")
	menu:addParam("combo","combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)  menu:permaShow("combo")
	menu:addParam("harass","harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('X')) menu:permaShow("harass")
--	menu:addParam("farm","farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('V')) menu:permaShow("farm")
	
	
	
	AddTickCallback(OnTick2) AddTickCallback(KillDamage)
	AddDrawCallback(OnDraw2)
end


local is_recalling
function OnRecall(hero)	if hero.isMe then	is_recalling=true end end
function OnAbortRecall(hero)	if hero.isMe then	is_recalling=false end end
function OnFinishRecall(hero)	if hero.isMe then	is_recalling=false end end
local Target
function OnTick2()
	SOWi:EnableAttacks()
	--SMAR KS
	--KS
	for _,c in pairs(GetEnemyHeroes()) do 
		if ValidTarget(c) then
			if menu.R.ks and R:IsReady() and DLib:CalcSpellDamage(c, _R)*(2+Rstack)>=c.health and R:IsInRange(c)  then
				R:Cast(c) goto continue
			end
			if menu.Q.ks and Q:IsReady() and DLib:CalcSpellDamage(c, _Q)>=c.health and Q:IsInRange(c)  then
				Q:Cast(c) goto continue
			end
			if menu.E.ks and E:IsReady() and DLib:CalcSpellDamage(c, _E)>=c.health and E:IsInRange(c)  then
				E:Cast(c)
			end	
		end
		::continue::
	end
	
	if is_recalling then return end
	--USE W cuz its "no cost" to stack _E buff
	if W:IsReady() and menu.W.auto and not Ecast and E:GetLevel()>0 then
		W:Cast()
	end
	--SET TARGET	
	Target = STS:GetTarget(SPELL_DATA[_R].range)
	if not Target or not ValidTarget(Target) then return end	
	--CAST R
	if menu.R.cast and R:IsReady() then
		R:Cast(Target)
	end

	--COMBO
	if menu.combo then
		SOWi:DisableAttacks()
		if (player:GetSpellData(_E).totalCooldown==0 and Estack>=4) then --not enough E stack
			if Q:IsReady() and Q:IsInRange(Target) then
				Q:Cast(Target)
			end
			if W:IsReady() and not menu.W.auto then
				W:Cast()
			end
		else		
			if E:IsReady() then  --CAST FIRST TO STACK AGAIN
				E:Cast(Target)
			end
			if Q:IsReady() and Q:IsInRange(Target) then
				Q:Cast(Target)
			end
		end
		if not Q:IsReady() and not E:IsReady() and (not R:IsReady() or menu.R.cast) then
			SOWi:EnableAttacks()
		end
		return
	end
	--HARASS TARGET
	--if menu.harass then
		--Harass with Q  
		
		if (menu.Q.auto or menu.harass )and menu.Q.harass and Q:IsReady() and Q:IsInRange(Target) and (menu.Q.mana) < (myHero.mana / myHero.maxMana) * 100  then
			Q:Cast(Target)
		end
		--And E
		if (menu.E.auto or menu.harass )and menu.E.harass and E:IsReady()  and (menu.E.mana) < (myHero.mana / myHero.maxMana) * 100  then
			E:Cast(Target)
		end
	--end
	--FARM
	--if menu.farm then
		
	--end
end

local Kill_Text={}
local Kill_Combo={}
local KillDamage_lasttick=0
function KillDamage()
	--TICK LIMITTER
	if os.clock() - KillDamage_lasttick<0.1 then return end
	KillDamage_lasttick=os.clock()
	--TEXTS
	for _, enemy in pairs(GetEnemyHeroes()) do
		local Qd={DAMAGE=DLib:CalcSpellDamage(enemy,_Q),NAME="Q",SPELL=Q}
		local Wd={DAMAGE=DLib:CalcSpellDamage(enemy,_W)+DLib:CalcSpellDamage(enemy,_P)+DLib:CalcSpellDamage(enemy,_AA),NAME="W",SPELL=W}
		local Ed={DAMAGE=DLib:CalcSpellDamage(enemy,_E),NAME="E",SPELL=E}
		local Rd={DAMAGE=DLib:CalcSpellDamage(enemy,_R)*(Rstack+2),NAME="R",SPELL=R} --Rstack Consdiered Damage
		local DAMAGES
		if menu.R.ks then
			DAMAGES={Qd,Wd,Ed,Rd}		
		else
			DAMAGES={Qd,Wd,Ed}		
		end
		killstr,combo = ALL_COMBO({Qd,Wd,Ed,Rd},enemy.health)
		Kill_Text[enemy.networkID],Kill_Combo[enemy.networkID] = killstr,combo
		KILLTEXTS:SET_TEXT(enemy,killstr)
		
	end
end 
function OnDraw2()
	--CURRENT TARGET
	if ValidTarget(Target) then
		DrawCircle3D(Target.x, Target.y, Target.z, 100, 2, ARGB(175, 0, 255, 0), 25)
	end
end


--[[
██╗  ██╗    ██╗        ██╗         ██╗                 ██████╗ 
██║ ██╔╝    ██║        ██║         ██║                 ╚═══██╗
█████╔╝     ██║        ██║         ██║         		    ▄███╔╝
██╔═██╗     ██║        ██║         ██║          	 	▀▀══╝ 
██║  ██╗    ██║        ███████╗    ███████╗      		██╗   
╚═╝  ╚═╝    ╚═╝        ╚══════╝    ╚══════╝   able   	╚═╝   
                                                       
--]]

function combinations(arr, r) 
	--NO
	if r>#arr or r==0 then
		return {}
	end
	--1
	if(r == 1) then
		local return_table = {}
		for i=1,#arr do
			table.insert(return_table, {arr[i]})
		end
		return return_table
	--MORE
	else
		local return_table = {}
		local arr_new = {}
		for i=2,#arr do
			table.insert(arr_new, arr[i])
		end
		for i, val in pairs(combinations(arr_new, r-1)) do
			local curr_result = {}
			table.insert(curr_result, arr[1]);
			for j,curr_val in pairs(val) do
				table.insert(curr_result, curr_val)
			end
			table.insert(return_table, curr_result)
		end
		for i, val in pairs(combinations(arr_new, r)) do
			table.insert(return_table, val)
		end
		return return_table
	end
end

function ALL_COMBO(array,health)
	local max_damage=0
	local max_damage_str=""
	for i=1, #array, 1 do
		for i, val in pairs(combinations(array, i)) do
			local killstr=""
			local total_damage=0
			local Spells={}
			for j, combination in pairs(val) do
				total_damage=total_damage+combination.DAMAGE
				table.insert(Spells,combination.Spell)
				if(j==#val) then --last element
					killstr=killstr..combination.NAME
				else
					killstr=killstr..combination.NAME.."+"
				end
			end
			if total_damage>=health then
				killstr = killstr.." KILL",total_damage,health
				return killstr,Spells
			end
			if total_damage>max_damage then
				max_damage=total_damage
				max_damage_str=killstr.." "..math.floor(health-max_damage)
			end
		end
	end
	return ""
	--return max_damage_str
end
