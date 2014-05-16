local version = "0.1"
local TESTVERSION = false
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/fter44/ilikeman/master/common/ITEM_MANAGER.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = LIB_PATH.."ITEM_MANAGER.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>ITEM_MANAGER:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/fter44/ilikeman/master/VersionFiles/ITEM_MANAGER.version")
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


--MANAGE BUY_ITEM,REMOVE_ITEM
class "ITEM_MANAGER"--{
local ITEM_MANAGER_OFFENSIVE_AD_TARGET = {
	--[1042]={name='Dagger'}, --test purpose
	--[2003]={name='Health Potion'},--test purpose
	[3153]={rangeSqr = 500*500, name="BRK[AD]"},--AD 몰왕검	
	[3144]={rangeSqr = 450*450, name="BWC[AD]"},--AD 빌지워터	
	--[3146]={rangeSqr = 700*700, name="HXG[AD]"},--AP AD
	--[3184]={rangeSqr = 350*350, name="ENT[AD]"},--AD NOT SR
}
local ITEM_MANAGER_OFFENSIVE_AP_TARGET = {
	[3128]={rangeSqr = 750*750, name="DFG[AP]" },
	[3146]={rangeSqr = 700*700, name="HXG[AP]" },--AP AD
	--[3180]={rangeSqr = 525*525, name="ODYNVEIL[AP]"}, NOT SR
	--[3188]={rangeSqr = 750*750, name="BLACKFIRE[AP]"}, NOT SR
}
local ITEM_MANAGER_OFFENSIVE_AD_NONTARGET = {	
	[3131]={range = 200*200,name="DVN[AD]"},	--AD CRITICAL 신성의검	
	[3074]={rangeSqr = 350*350,name="HYDRA[AD]" },		--AD
	[3077]={rangeSqr = 350*350,name="TIAMAT[AD]" },		--AD	
	[3142]={rangeSqr = 350*350,name="YGB[AD]" },		--AD요우무
}
local ITEM_MANAGER_OFFENSIVE_AP_NONTARGET = {
}
function ITEM_MANAGER:__init(menu,STS,disable)
	self.OFFENSIVE_AD_TARGET={} --[id]=slot
	self.OFFENSIVE_AD_NONTARGET={}
	self.OFFENSIVE_AP_TARGET={}
	self.OFFENSIVE_AP_NONTARGET={}
	self.STS=STS
	self.lasttick=0
	if not disable then
		AddTickCallback(function() self:OnTick_CHECK() end)	
		AddTickCallback(function() self:OnTick_CAST() end)
	end
	if menu then
		self:LoadToMenu(menu,STS,disable)
		self.menu=menu
	end
end
function ITEM_MANAGER:LoadToMenu(menu,STS,disable)
	assert(STS~=nil,"SET [#2:STS] VALUE")
	self.STS=STS
	if self.menu then   --menu already registered
		return 
	end
	self.menu=menu
	menu:addSubMenu("OFFENSIVES","OFFENSIVES")
	menu:addSubMenu("DEFENSIVES","DEVENSIVES")
	menu:addParam("forceAO","FORCE ALL Offs",SCRIPT_PARAM_ONKEYTOGGLE, false, 48) menu:permaShow("forceAO")
	menu:addParam("disableforceAO","Auto Disable ^ after", SCRIPT_PARAM_SLICE, 60, 0, 120)
	if not disable then
		menu:addParam("castOffAD","CAST OFFENSIVE AD",SCRIPT_PARAM_ONKEYDOWN,false,32)
		menu:addParam("castOffAP","CAST OFFENSIVE AP",SCRIPT_PARAM_ONKEYDOWN,false,32)
	end
	return self
end
function ITEM_MANAGER:OnTick_CHECK() --CHECK BUY,REMOVE ITEMS  && Disable Auto Disable "force all offensiveS"
	assert(self.menu~=nil, "Register ITEM_MANAGER:menu by :LoadMenu(menu)")
	if os.clock()-self.lasttick<0.5 then return end
	
	--AUTO DISABLE FORCE ALL OFFENSIVES after X seocnds
	if self.menu.forceAO==true then
		if not self.forceAO then			
			DelayAction(function() self.forceAO=false self.menu.forceAO=false	end,self.menu.disableforceAO)
			self.forceAO=true
			--self.force_tick=os.clock()
			--self.forceAO=true
		else		
			--if os.clock()-self.force_tick>self.menu.disableforceAO then
			--	self.forceAO=false
			--	self.menu.forceAO=false
			--end
		end
	end
	
	--CHECK ITEMS
		--AD TARGET
	for id,info in pairs(ITEM_MANAGER_OFFENSIVE_AD_TARGET) do
		if self.OFFENSIVE_AD_TARGET[id]==nil then --not yet have
			if GetInventoryHaveItem(id) then  -- now have item
				self.OFFENSIVE_AD_TARGET[id] = GetInventorySlotItem(id)				
				if self.menu.OFFENSIVES[tostring(id)]==nil then
					self.menu.OFFENSIVES:addParam(tostring(id),info.name,SCRIPT_PARAM_ONOFF,true)					
				end
				Color_Print_I("ITEM_MANAGER","PINK",info.name.." added state:"..tostring(self.menu.OFFENSIVES[tostring(id)]))
				
			end
		else -- have before
			if not GetInventoryHaveItem(id) then  -- now dont have item
				self.OFFENSIVE_AD_TARGET[id] = nil				
				Color_Print_I("ITEM_MANAGER","PINK",info.name.." removed")
				
				self.menu.OFFENSIVES:removeParam(tostring(id))
			end
		end
	end
		-- AD NonTarget_Items
	for id,info in pairs(ITEM_MANAGER_OFFENSIVE_AD_NONTARGET) do
		if self.OFFENSIVE_AD_NONTARGET[id]==nil then --not yet have
			if GetInventoryHaveItem(id) then -- now have item
				self.OFFENSIVE_AD_NONTARGET[id]= GetInventorySlotItem(id)
				if self.menu.OFFENSIVES[tostring(id)]==nil then
					self.menu.OFFENSIVES:addParam(tostring(id),info.name,SCRIPT_PARAM_ONOFF,true)
				end				
				Color_Print_I("ITEM_MANAGER","PINK",info.name.." added state:"..tostring(self.menu.OFFENSIVES[tostring(id)]))
			end 
		else -- have before
			if not GetInventoryHaveItem(id) then -- now dont have item
				self.OFFENSIVE_AD_NONTARGET[id] = nil				
				Color_Print_I("ITEM_MANAGER","PINK",info.name.." removed")				
				
				self.menu.OFFENSIVES:removeParam(tostring(id))
			end 
		end
	end
		--AP TARGET
	for id,info in pairs(ITEM_MANAGER_OFFENSIVE_AP_TARGET) do
		if self.OFFENSIVE_AP_TARGET[id]==nil then --not yet have
			if GetInventoryHaveItem(id) then-- now have item
				self.OFFENSIVE_AP_TARGET[id] = GetInventorySlotItem(id)
				if self.menu.OFFENSIVES[tostring(id)]==nil then
					self.menu.OFFENSIVES:addParam(tostring(id),info.name,SCRIPT_PARAM_ONOFF,true)
				end				
				Color_Print_I("ITEM_MANAGER","PINK",info.name.." added state:"..tostring(self.menu.OFFENSIVES[tostring(id)]))
			end 
		else -- have before
			if not GetInventoryHaveItem(id) then -- now dont have item
				self.OFFENSIVE_AP_TARGET[id] = nil 
				Color_Print_I("ITEM_MANAGER","PINK",info.name.." removed")
				
				self.menu.OFFENSIVES:removeParam(tostring(id))
			end 
		end
	end
	--for _,i in pairs(ITEM_MANAGER_OFFENSIVE_AP_NONTARGET) do -- AD NonTarget_Items
	--end
	--for _,i in pairs(ITEM_MANAGER_OFFENSIVE_AP_NONTARGET) do -- DEFFENSIVE_ITEMS
	--end
end
function ITEM_MANAGER:OnTick_CAST()
	--TARGET
	local target=self.STS:GetTarget(750)
	if not ValidTarget(target) then return end	
	--CAST
	if self.menu.castOffAD then
		self:CAST_OFFENSIVE_AD(target)
	end
	if self.menu.castOffAP then
		self:CAST_OFFENSIVE_AP(target)
	end
end
function ITEM_MANAGER:CAST_OFFENSIVE_AD(unit,force)
	for id,slot in pairs(self.OFFENSIVE_AD_TARGET) do
		if (self.menu.OFFENSIVES[tostring(id)] or sef.menu.forceAO or force) and (player:CanUseSpell(slot) == READY) and GetDistanceSqr(unit) <=ITEM_MANAGER_OFFENSIVE_AD_TARGET[id].rangeSqr then
			CastSpell(slot,unit)
		end
	end
	for id,slot in pairs(self.OFFENSIVE_AD_NONTARGET) do
		if (self.menu.OFFENSIVES[tostring(id)] or sef.menu.forceAO or force) and (player:CanUseSpell(slot) == READY) and GetDistanceSqr(unit) <= ITEM_MANAGER_OFFENSIVE_AD_NONTARGET[id].rangeSqr then
			CastSpell(slot,unit)
		end
	end
end
function ITEM_MANAGER:CAST_OFFENSIVE_AP(unit,force)
	for id,slot in pairs(self.OFFENSIVE_AP_TARGET) do
		if (self.menu.OFFENSIVES[tostring(id)] or sef.menu.forceAO or force) and (player:CanUseSpell(slot) == READY) and GetDistanceSqr(unit) <= ITEM_MANAGER_OFFENSIVE_AP_TARGET[id].rangeSqr then
			CastSpell(slot,unit)
		end
	end
end


local print_colors={
	["CYAN"]="#67FECC",
	["PURPLE"]="#9A68FD",
	["RED"]="#9B0911",
	["PINK"]="#FD68A6",
	["BLACK"]="#000018",
	["BLUE"]="#0000FF",
	["WHITE"]="#FFFFFF",
	["YELLOW"]="#FFFF00",
}
function Color_Print_I(title,color,msg)
	print('<font color="'..print_colors[color]..'"><b>'..title..':</b></font><font color=\"#FFFFFF\">'..msg..".</font>")
end
function Color_Print_II(msg,color)
	print('<font color="'..print_colors[color]..'"><b>'..msg..':</b></font>')
end

