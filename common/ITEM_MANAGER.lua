--MANAGE BUY_ITEM,REMOVE_ITEM
class "ITEM_MANAGER"--{
local ITEM_MANAGER_OFFENSIVE_AD_TARGET = {
	--[1042]={name='Dagger'}, --test purpose
	--[2003]={name='Health Potion'},--test purpose
	[3153]={rangeSqr = 500*500, name="BRK[AD]"},--AD 몰왕검	
	[3144]={rangeSqr = 450*450, name="BWC[AD]"},--AD 빌지워터	
	[3146]={rangeSqr = 700*700, name="HXG[AD]"},--AP AD
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
	menu:addParam("disableforceAO","Auto Disable ^ after seconds", SCRIPT_PARAM_SLICE, 60, 0, 120)
	if not disable then
		menu:addParam("castOffAD","CAST OFFENSIVE AD",SCRIPT_PARAM_ONKEYDOWN,false,string.byte("C"))
		menu:addParam("castOffAP","CAST OFFENSIVE AP",SCRIPT_PARAM_ONKEYDOWN,false,string.byte("C"))
	end
	return self
end
function ITEM_MANAGER:OnTick_CHECK() --CHECK BUY,REMOVE ITEMS  && Disable Auto Disable "force all offensiveS"
	assert(self.menu~=nil, "Register ITEM_MANAGER:menu by :LoadMenu(menu)")
	if os.clock()-self.lasttick<0.5 then return end
	
	--AUTO DISABLE FORCE ALL OFFENSIVES after X seocnds
	if self.menu.forceAO==true then
		if self.forceAO then
			if os.clock()-self.force_tick>self.menu.disableforceAO then
				self.forceAO=false
				self.menu.forceAO=false
			end
		else		
			self.force_tick=os.clock()
			self.forceAO=true
		end
	end
	
	--CHECK ITEMS
		--AD TARGET
	for id,info in pairs(ITEM_MANAGER_OFFENSIVE_AD_TARGET) do
		if self.OFFENSIVE_AD_TARGET[id]==nil then --not yet have
			if GetInventoryHaveItem(id) then  -- now have item
				self.OFFENSIVE_AD_TARGET[id] = GetInventorySlotItem(id)				
				--if self.menu.OFFENSIVES[tostring(id)]==nil then
				self.menu.OFFENSIVES:addParam(tostring(id),info.name,SCRIPT_PARAM_ONOFF,true)					
				--end
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
				Color_Print_I("ITEM_MANAGER","PINK",info.name.." added state:"..tostring(self.menu.OFFENSIVES[tostring(id)]))
				if self.menu.OFFENSIVES[tostring(id)]==nil then
					self.menu.OFFENSIVES:addParam(tostring(id),info.name,SCRIPT_PARAM_ONOFF,true)
				end
			end 
		else -- have before
			if GetInventoryHaveItem(id) then -- now dont have item
				self.OFFENSIVE_AD_NONTARGET[id] = nil				
				Color_Print_I("ITEM_MANAGER","PINK",info.name.." removed")
			end 
		end
	end
		--AP TARGET
	for id,info in pairs(ITEM_MANAGER_OFFENSIVE_AP_TARGET) do
		if self.OFFENSIVE_AP_TARGET[id]==nil then --not yet have
			if GetInventoryHaveItem(id) then-- now have item
				self.OFFENSIVE_AP_TARGET[id] = GetInventorySlotItem(id)
				Color_Print_I("ITEM_MANAGER","PINK",info.name.." added state:"..tostring(self.menu.OFFENSIVES[tostring(id)]))
				if self.menu.OFFENSIVES[tostring(id)]==nil then
					self.menu.OFFENSIVES:addParam(tostring(id),info.name,SCRIPT_PARAM_ONOFF,true)
				end
			end 
		else -- have before
			if GetInventoryHaveItem(id) then -- now dont have item
				self.OFFENSIVE_AP_TARGET[id] = nil 
				Color_Print_I("ITEM_MANAGER","PINK",info.name.." removed")
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