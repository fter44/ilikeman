local UTILS="UTIL"
local CHAMPS="CHAMPION"
local CHAMP_SUP="CHAMP_SUPPORT"
local ORBWALKER="ORBWALKER"
local MMAPLUGIN="MMA_PLUGIN"
local TEMP="TEMP"
local THIS_PATH=BOL_PATH.."Scripts\\THIS\\"
function FileName(s)
  return string.sub(s,1,s:find'.lua'-1)
end
local util_scripts
local champ_scripts
local support_scripts
local orbwalker_scripts
local mmaplugin_scripts
local temp_scripts
function Print(str)	print("<font color=\"#6699ff\"><b>FTER44:</b></font> <font color=\"#FFFFFF\">"..str..".</font>") end
function OnLoad()
	Utils_PATH = BOL_PATH.."Scripts\\"..UTILS
	Champions_PATH = BOL_PATH.."Scripts\\"..CHAMPS.."\\"..myHero.charName
	ChampSupports_PATH = BOL_PATH.."Scripts\\"..CHAMP_SUP
	OrbWalker_PATH = BOL_PATH.."Scripts\\"..ORBWALKER
	MMAplugin_PATH = BOL_PATH.."Scripts\\"..MMAPLUGIN
	Temp_PATH	   = BOL_PATH.."Scripts\\"..TEMP
	
	Utils_PATH2 = UTILS.."//"
	Champions_PATH2 = CHAMPS.."//"..myHero.charName.."//"
	ChampSupports_PATH2 = CHAMP_SUP.."//"
	OrbWalker_PATH2 = ORBWALKER.."//"
	MMAplugin_PATH2 = MMAPLUGIN.."//"
	Temp_PATH2		= TEMP.."//"

	Print("Simple Script Loader : "..myHero.charName)
	if	true then			
		Menu = scriptConfig("Script Loader", "ScriptLoader")		
	--Setting SCRIPTS ON OFF--
		--UTILS--
		_,util_scripts = ScanDirectory(Utils_PATH)
		Menu:addSubMenu("UTILS","utils")	
		for index,script in pairs(util_scripts) do			
			Menu.utils:addParam(string.gsub(script,"[^%a%d]",""),"   "..script,SCRIPT_PARAM_ONOFF,false,false)
		end		
		--CHAMPIONS--
		_,champ_scripts = ScanDirectory(Champions_PATH)
		Menu:addSubMenu("CHAMPION","Champion"..myHero.charName)		
		for index,script in pairs(champ_scripts) do			
			Menu["Champion"..myHero.charName]:addParam(string.gsub(script,"[^%a%d]",""),"   "..script,SCRIPT_PARAM_ONOFF,false,false)
		end Menu["Champion"..myHero.charName]:addParam("iseries","   iseries",SCRIPT_PARAM_ONOFF,false,false)
		--CHAMPION SUPPORTS--
		_,support_scripts = ScanDirectory(ChampSupports_PATH)
		Menu:addSubMenu("CHAMP_SUPPORT","Support"..myHero.charName)		
		for index,script in pairs(support_scripts) do	
			Menu["Support"..myHero.charName]:addParam(string.gsub(script,"[^%a%d]",""),"   "..script,SCRIPT_PARAM_ONOFF,false,false)
		end
		--Orb Walkers-
		_,orbwalker_scripts = ScanDirectory(OrbWalker_PATH)		
		Menu:addSubMenu("ORBWALKER","OrbWalker"..myHero.charName)
		for index,script in pairs(orbwalker_scripts) do		
			Menu["OrbWalker"..myHero.charName]:addParam(string.gsub(script,"[^%a%d]",""),"   "..script,SCRIPT_PARAM_ONOFF,false,false)
		end
		--MMA_Plguins--		
		_,mmaplugin_scripts = ScanDirectory(MMAplugin_PATH)		
		Menu:addSubMenu("MMA PLUGIN","MMA_Plugin"..myHero.charName)
		for index,script in pairs(mmaplugin_scripts) do		
			Menu["MMA_Plugin"..myHero.charName]:addParam(string.gsub(script,"[^%a%d]",""),"   "..script,SCRIPT_PARAM_ONOFF,false,false)
		end	
		--TEMP--
		_,temp_scripts = ScanDirectory(Temp_PATH)		
		Menu:addSubMenu("TEMP","TEMP")
		for index,script in pairs(temp_scripts) do		
			Menu["TEMP"]:addParam(string.gsub(script,"[^%a%d]",""),"   "..script,SCRIPT_PARAM_ONOFF,false,false)
		end	
		
		
		Menu:addParam("loadutil","Enable UTIL",SCRIPT_PARAM_ONOFF,true,false)	 
		Menu:addParam("loadchamp","Enable CHAMP",SCRIPT_PARAM_ONOFF,true,false)	
		Menu:addParam("loadsup","Enable CHAMP_SUP",SCRIPT_PARAM_ONOFF,true,false)
		Menu:addParam("loadorbw","Enable ORB_W",SCRIPT_PARAM_ONOFF,true,false)
		Menu:addParam("loadmmap","Enable MMAPLUGIN",SCRIPT_PARAM_ONOFF,true,false)
		Menu:addParam("loadtemp","Enable TEMPs",SCRIPT_PARAM_ONOFF,true,false)
		
		
	--Load Scripts--		
		--UTILS--
		if Menu.loadutil then
			for index,script in pairs(util_scripts) do		
				if	Menu.utils[string.gsub(script,"[^%a%d]","")] then
					script = FileName(script)..".lua"
					LoadScript(Utils_PATH2..script)
				end
			end		
		end
		--Orb Walkers- "OrbWalker"..myHero.charName			
		if Menu.loadorbw then
			for index,script in pairs(orbwalker_scripts) do
				if	Menu["OrbWalker"..myHero.charName][string.gsub(script,"[^%a%d]","")] then				
					script = FileName(script)..".lua"
					LoadScript(OrbWalker_PATH2..script)
				end
			end		
		end
		--CHAMPIONS--
		if  Menu.loadchamp then
			for index,script in pairs(champ_scripts) do
				if	Menu["Champion"..myHero.charName][string.gsub(script,"[^%a%d]","")] then				
					script = FileName(script)..".lua"
					LoadScript(Champions_PATH2..script)
				end
			end if	Menu["Champion"..myHero.charName].iseries then				
					LoadScript("iSeriesAIO-Release.lua")
				end
		end
		--CHAMPION SUPPORTS--
		if Menu.loadsup then
			for index,script in pairs(support_scripts) do
				if	Menu["Support"..myHero.charName][string.gsub(script,"[^%a%d]","")] then				
					script = FileName(script)..".lua"
					LoadScript(ChampSupports_PATH2..script)
				end
			end
		end
		--MMA_Plguins--
		if Menu.loadmmap then	
			for index,script in pairs(mmaplugin_scripts) do
				if	Menu["MMA_Plugin"..myHero.charName][string.gsub(script,"[^%a%d]","")] then					
					script = FileName(script)..".lua"
					LoadScript(MMAplugin_PATH2..script)
				end
			end
		end	
		--Temps--
		if Menu.loadtemp then	
			for index,script in pairs(temp_scripts) do
				if	Menu["TEMP"][string.gsub(script,"[^%a%d]","")] then					
					script = FileName(script)..".lua"
					LoadScript(Temp_PATH2..script)
				end
			end
		end	
	end	
end
