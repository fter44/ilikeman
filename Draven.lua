if myHero.charName ~= "Draven" then return end

local version = "0.13"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/fter44/ilikeman/master/common/Draven.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = LIB_PATH.."Draven.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>Draven:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/fter44/ilikeman/master/VersionFiles/Draven.version".."?rand="..math.random(1,10000))
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				AutoupdaterMsg("New version available"..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end




require 'VPrediction'
require 'SOW'
require "SourceLib"
require "Prodiction"
require "DRAW_POS_MANAGER"
require "ITEM_MANAGER"


--[[Menu instance]]--
local menu
--[[Libaries]]--
local VP,SOWi,STS
--[[Spells]]--
local Q,W,E,R
--[[Q BUFF]]--
local Q_BUFF=false
local Q_STACK=0
local Q_BUFF_NAME="dravenspinningattack"
local Q_RETICLES={}
local W_AS_BUFF=false
local W_AS_BUFF_NAME="dravenfurybuff"
local W_MS_BUFF=false
local W_MS_BUFF_NAME="DravenFury"
local R_BUFF_NAME="dravenrdoublecast"

--[[Kill Str Manager]]--
local KILLTEXTS
function OnGainBuff(unit,buff)
	if unit.isMe then
		--print("GAIN "..buff.name)
		if buff.name==Q_BUFF_NAME then
			Q_BUFF=true Q_STACK=1 
		elseif buff.name==W_AS_BUFF_NAME then
			W_AS_BUFF=true
		elseif buff.name==W_MS_BUFF_NAME then
			W_MS_BUFF=true
		end 
	end
end
function OnLoseBuff(unit,buff)
	if unit.isMe then	
		--print("LOSE "..buff.name)
		if buff.name==Q_BUFF_NAME then 
			Q_BUFF=false	Q_STACK=0 			
		elseif buff.name==W_AS_BUFF_NAME then
			W_AS_BUFF=false
		elseif buff.name==W_MS_BUFF_NAME then
			W_MS_BUFF=false
		end 
	end
end
function OnUpdateBuff(unit,buff) if unit.isMe then	if buff.name==Q_BUFF_NAME then Q_BUFF=true	Q_STACK=buff.stack end end end
function SetLibrary()	
	VP = VPrediction()	SOWi = SOW(VP)	STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC) 
	
	SOWi:RegisterBeforeAttackCallback(function(t)
		if Q:IsReady() and Q_STACK==0 and ((menu.combo and menu.Q.combo)or(menu.harass and menu.Q.harass)or(menu.farm and menu.Q.farm)or(menu.laneclear and menu.Q.laneclear)) then
			Q:Cast()
		end
	end)
	function SOW:BonusDamage(minion)
		local BONUS=0
		if Q_STACK>0 then
			BONUS = myHero:CalcDamage(minion, myHero.totalDamage) * (0.3 + (0.10 * myHero:GetSpellData(_Q).level))
		end
		return BONUS
	end
end
function Print(str)	print("<font color=\"#6699ff\"><b>FTER44:</b></font> <font color=\"#FFFFFF\">"..str..".</font>") end

local SPELL_DATA = {
	[_Q] = { range = 550},
	[_W] = { range = 400},
	[_E] = { range = 01050, skillshotType = SKILLSHOT_LINEAR, width = 130, delay = 0.25,  speed = 1600, collision = false },		
	[_R] = { range = 99999, skillshotType = SKILLSHOT_LINEAR, width = 160, delay = 0.50,  speed = 2000, collision = false },
}
function SetSpells()	
	Q = Spell(_Q,SPELL_DATA[_Q].range) 	
	W = Spell(_W,SPELL_DATA[_Q].range) 	
	E = Spell(_E,SPELL_DATA[_E].range)
		E:SetSkillshot(VP, SPELL_DATA[_E ].skillshotType, SPELL_DATA[_E ].width,SPELL_DATA[_E ].delay, SPELL_DATA[_E ].speed)
	R = Spell(_R,SPELL_DATA[_R].range)
		R:SetSkillshot(VP, SPELL_DATA[_R ].skillshotType, SPELL_DATA[_R ].width,SPELL_DATA[_R ].delay, SPELL_DATA[_R ].speed)
end
function Load_Menu()
	menu = scriptConfig("Draven", "Draven")
	
	--SPELLS
	menu:addSubMenu("Q", "Q")	
		menu.Q:addParam("combo", "Q@Combo", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("harass", "Q@harass", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("farm", "Q@farm", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("laneclear", "Q@laneclear", SCRIPT_PARAM_ONOFF, true)
	menu:addSubMenu("W", "W")		
		menu.W:addParam("cast", "Cast W@Target", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('A'))
		menu.W:addParam("combo", "Auto W@Combo", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("harass", "Auto W@harass", SCRIPT_PARAM_ONOFF, true)
	menu:addSubMenu("E", "E")				
		menu.E:addParam("ks", "KS E", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("combo", "Auto E@Combo", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("harass", "Auto E@harass", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("auto", "Auto E Immobile/DASHES", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("gap", "Auto E GAPCLOSER", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("interrupt", "Auto E Interrupt", SCRIPT_PARAM_ONOFF, true)
		menu.E:addParam("min", "Min E Range", SCRIPT_PARAM_SLICE, 500, 0, 700, 0) --prevent orbwalker interrupt
		menu.E:addParam("cast", "Manual Cast", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
	menu:addSubMenu("R", "R")		
		menu.R:addParam("ks", "KS R", SCRIPT_PARAM_ONOFF, true)
		menu.R:addParam("min", "Min R Range", SCRIPT_PARAM_SLICE, 700, 0, 1800, 0)	
		menu.R:addParam("max", "Max R Range", SCRIPT_PARAM_SLICE, 1700, 0, 3500, 0)
		menu.R:addParam("cast","Manual Cast R@KS Target",SCRIPT_PARAM_ONKEYDOWN,false,string.byte("T"))
	
	menu:addSubMenu("Q Reticle", "QR")	
		menu.QR:addParam("mode","Orbwalk Mode",SCRIPT_PARAM_LIST,1,{"Closest to Mouse","Closest to My Hero"})
		menu.QR:addParam("Radius","Q<->Mouse Range",SCRIPT_PARAM_SLICE,500,100,1000)
		menu.QR:addParam("Radius2","Q<->My Hero Range",SCRIPT_PARAM_SLICE,50,0,100) --Should be Real Q reticle radius
		
	--OW
	menu:addSubMenu("Orbwalker", "SOW")
		SOWi:LoadToMenu(menu.SOW)	
	--TS
	menu:addSubMenu("Target selector", "STS")
		STS:AddToMenu(menu.STS)	
	--INTERRUPTER
	menu:addSubMenu("Interrupter","Interrupter")
		Interrupter(menu.Interrupter,function(unit,data)
			if menu.E.interrupt and E:IsReady() and E:IsInRange(unit) then
				E:Cast(unit)
			end
		end)
	--AntiGapcloser
	menu:addSubMenu("AntiGapcloser","AG")
		AntiGapcloser(menu.AG, function(unit,data)			
			if menu.E.gap and E:IsReady() and E:IsInRange(unit) then
				E:Cast(unit)
			end
		end)
	
	--DRAWING
	menu:addSubMenu("Drawings", "Drawings")
		local DManager = DrawManager()
		DManager:CreateCircle(myHero, SPELL_DATA[_E ].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"E range", true, true, true)		
		menu.Drawings:addParam("Reticle", "Highlight Reticle", SCRIPT_PARAM_ONOFF, true)
		menu.Drawings:addParam("CatchRadius", "Draw Catch Radius(Mouse)", SCRIPT_PARAM_ONOFF, true)
		menu.Drawings:addParam("OrbWalkPos", "Highlight Orbwalk Position", SCRIPT_PARAM_ONOFF, true)		
		menu.Drawings:addSubMenu("KillTexts","KillTexts")
			KILLTEXTS=TEXTPOS_HPBAR(menu.Drawings.KillTexts,23,46,30)	
	--EXTRA
	menu:addSubMenu("Extra menu", "Extras")
		menu.Extras:addParam("Debug", "Debug", SCRIPT_PARAM_ONOFF, false)				
	menu:addParam("combo", "combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('C'))		menu:permaShow("combo")
	menu:addParam("harass", "harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('X')) 		menu:permaShow("harass")
	menu:addParam("farm", "farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('Z'))		menu:permaShow("farm")
	menu:addParam("laneclear", "laneclear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('V')) 		menu:permaShow("laneclear")
end
function OnLoad()
	SetLibrary()
	SetSpells()
	Load_Menu()
	
	
	AddDrawCallback(OnDraw2)
	AddTickCallback(OnTick2)	
	
	Print("DRAVEN LOADED")
end
function OrbWalk2Q_Reticle(force,useW)--consider current speed if not force-d
	--[[Q RETICLES]]--
	local Q_Closest2H
	local Q_Closest2M
	for i,reticle in pairs(Q_RETICLES) do
		if not reticle.obj.valid then
			Q_RETICLES[i]=nil
		end
	end	
	if #Q_RETICLES>0 then
		if menu.QR.mode==1 then
			--table.sort(Q_RETICLES,DIST_ASC_Mouse) --By Mouse
			--Q_Closest2M = Q_RETICLES[1]
			local closes_distance=math.huge
			local closest_index=math.huge
			for i,reticle in pairs(Q_RETICLES) do
				local distance=GetDistanceSqr(reticle.obj,mousePos)
				if distance<closes_distance then
					closest_index=i
					closes_distance=distance
				end
				Q_Closest2M=Q_RETICLES[closest_index]
			end
		elseif menu.QR.mode==2 then		
			--table.sort(Q_RETICLES,DIST_ASC_MyHero) --By Hero
			--Q_Closest2H = Q_RETICLES[1]			
			local closes_distance=math.huge
			local closest_index=math.huge
			for i,reticle in pairs(Q_RETICLES) do
				local distance=GetDistanceSqr(reticle.obj)
				if distance<closes_distance then
					closest_index=i
					closes_distance=distance
				end
				Q_Closest2H=Q_RETICLES[closest_index]
			end
		end
	end
	if menu.QR.mode==1 then
		if Q_Closest2M then
			local QM = GetDistance(Q_Closest2M.obj, mousePos)
			local QH = GetDistance(Q_Closest2M.obj, myHero)-VP:GetHitBox(myHero)
			local CanReach = os.clock() + QH/myHero.ms < Q_Closest2M.expire
			local QM_S = menu.QR.Radius -- Menu Setted Value : Q reticle <-> Mouse
 			local QH_S = menu.QR.Radius2 -- Menu Setted Value : Q reticle <-> MyHero
			if ( force or CanReach) and QM < QM_S and QH > QH_S then	
				Debug_OrbWalkPos = Q_Closest2M.obj
				SOWi:ForceOrbWalkTo({x=Q_Closest2M.obj.x,z=Q_Closest2M.obj.z})
			else
				Debug_OrbWalkPos = nil
				SOWi:ForceOrbWalkTo(nil)	
			end
		else
			Debug_OrbWalkPos = nil
			SOWi:ForceOrbWalkTo(nil)
		end
	elseif menu.QR.mode==2 then
		if Q_Closest2H then			
			local QH = GetDistance(Q_Closest2H.obj, myHero)-VP:GetHitBox(myHero)
			local CanReach = os.clock() + QH/myHero.ms < Q_Closest2H.expire
			if CanReach==false and useW==true then
				W:Cast()
				CanReach=true
			end
			local QH_S = menu.QR.Radius2 -- Menu Setted Value : Q reticle <-> MyHero
			if ( force or CanReach) and QH > QH_S then
				Debug_OrbWalkPos = Q_Closest2H.obj
				SOWi:ForceOrbWalkTo({x=Q_Closest2H.obj.x,z=Q_Closest2H.obj.z})
			else
				Debug_OrbWalkPos = nil
				SOWi:ForceOrbWalkTo(nil)	
			end
		else
			Debug_OrbWalkPos = nil
			SOWi:ForceOrbWalkTo(nil)
		end
	else
		Debug_OrbWalkPos = nil
		SOWi:ForceOrbWalkTo(nil)
	end
	
end

function OnTick2()
	KD()
	--KS		
	for _, enemy in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) then		
			if R:IsReady() and getDmg("R", enemy, myHero) > enemy.health then
				if menu.R.ks then
					CAST_R(enemy)
					goto continue
				else
					PrintAlert_T(enemy,enemy.charName.." R KILLABLE",1,0,0,255)
				end
				R_KS_Target=enemy
			end
			
			if menu.E.ks and E:IsReady() and getDmg("E", enemy, myHero) > enemy.health then
				CAST_E(enemy,menu.E.cast)
			end
		end
		::continue::
	end		
	--MANUAL CAST
		--R
	if ValidTarget(R_KS_Target) and R:IsReady() and menu.R.cast then
		CAST_R(R_KS_Target,true)
	end
		--E					
		ETarget = STS:GetTarget(SPELL_DATA[_E].range)
		if menu.E.cast and E:IsReady() and ValidTarget(ETarget) then
			CAST_E(ETarget,true)
		end
		
		RTarget = STS:GetTarget(SPELL_DATA[_R].range)
		if menu.R.cast and R:IsReady() and ValidTarget(RTarget) then
			CAST_R(RTarget,true)
		end
	
	
	--E on DASHes/IMMOBILES 	
	if E:IsReady() and menu.E.auto then
		for _,champ in pairs(GetEnemyHeroes()) do
			if (E:CastIfDashing(champ)==SPELLSTATE_TRIGGERED or E:CastIfImmobile(champ)==SPELLSTATE_TRIGGERED) then
				break
			end
		end
	end
	
   	if menu.combo or menu.harass or menu.farm or menu.laneclear or menu.jungle then
		OrbWalk2Q_Reticle(false,false)
	else
		Debug_OrbWalkPos = nil
		SOWi:ForceOrbWalkTo(nil)
   	end

	if menu.combo then
		local Target = SOWi:GetTarget(true) --TARGET IN AA RANGE
		if not ValidTarget(Target) then return end
		--[[
		if menu.Q.combo and Q:IsReady() and Q_STACK<1 then
			Q:Cast()
		end	]]	
		if W:IsReady() and ( (menu.W.combo and ( W_AS_BUFF==false or not W:IsInRange(Target) )) or menu.W.cast) then
			W:Cast()
		end
		if menu.E.combo then
			CAST_E(Target)
		end
	elseif menu.harass then	
		local Target = SOWi:GetTarget(true) --TARGET IN AA RANGE
		if not ValidTarget(Target) then return end
		--[[
		if menu.Q.harass and Q_STACK<1 then
			Q:Cast()
		end	]]	
		if W:IsReady() and ( (menu.W.harass and ( W_AS_BUFF==false or not W:IsInRange(Target) )) or menu.W.cast)  then
			W:Cast()
		end
		if menu.E.harass then
			CAST_E(Target)
		end
	end
end

function OnDraw2()
	if menu.Drawings.Reticle then
		for _,Reticle in pairs(Q_RETICLES) do
			local obj=Reticle.obj
			DrawCircle3D(obj.x,obj.y,obj.z,menu.QR.Radius2,2,ARGB(255,255,255,255),20)
		end
	end
	
	if menu.Drawings.CatchRadius then
		DrawCircle3D(mousePos.x,mousePos.y,mousePos.z,menu.QR.Radius,2,ARGB(255,255,255,255),20)
	end
	
	if menu.Drawings.OrbWalkPos and Debug_OrbWalkPos then
		DrawCircle3D(Debug_OrbWalkPos.x,Debug_OrbWalkPos.y,Debug_OrbWalkPos.z,200,2,ARGB(255,0,0,255),20)
	end
end


local Q_OBJ_NAME="Draven_Q_reticle_self.troy"
local R_OBJ_NAME="Draven_R_cas.troy"
function OnCreateObj(obj)
    if obj.name == Q_OBJ_NAME then
		table.insert(Q_RETICLES,{obj = obj,create = os.clock() , expire = os.clock()+1.30 })
    end
end
--[[
function OnDeleteObj(obj)
	if obj.name == Q_OBJ_NAME then
		for i,reticle in pairs(Q_RETICLES) do
			if reticle.obj==obj then
				print(os.clock() - reticle.create )
			end
		end
	end
end]]


function CAST_W()--mana manage
	
end

function CAST_E(target,forceD)
	if forceD or _GetDistanceSqr(target) > menu.E.min*menu.E.min then
		return E:Cast(target)==SPELLSTATE_TRIGGERED
	end
end

function CAST_R(target,forceD)	
	R.minTargetsAoe=1
	if not R_BUFF and (forceD or (_GetDistanceSqr(target) > menu.R.min*menu.R.min and _GetDistanceSqr(target) < menu.R.max*menu.R.max)) then
		return R:Cast(target)==SPELLSTATE_TRIGGERED
	else
		return
	end
end




local Alert_Texts={}
function PrintAlert_T(target,text,duration,r,g,b)
	if Alert_Texts[target] then
		if Alert_Texts[target]<os.clock() then --used before
			PrintAlert(text,duration,r,g,b)	
			DelayAction(PingClient,  0.3, {target.x, target.z})
			DelayAction(PingClient,  0.6, {target.x, target.z})
			DelayAction(PingClient,  0.9, {target.x, target.z})
		end
	else
		PrintAlert(text,duration,r,g,b)
		DelayAction(PingClient,  0.3, {target.x, target.z})
		DelayAction(PingClient,  0.6, {target.x, target.z})
		DelayAction(PingClient,  0.9, {target.x, target.z})
	end	
	
	Alert_Texts[target]=os.clock()+10
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
