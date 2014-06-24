local lastpos={}
local lasttime={}
local next_wardtime=0	--NEXT TIME TO CAST WARD
local menu
function OnLoad()
	for _,c in pairs(GetEnemyHeroes()) do
		lastpos[ c.networkID ] = Vector(c)
	end
	menu = scriptConfig("Bush Revealer","bushrevealer")
	menu:addParam("active","active",SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	menu:addParam("always","always",SCRIPT_PARAM_ONOFF,false)
	menu:addParam("maxT","Max Time to check Enemy in Bush",SCRIPT_PARAM_SLICE, 2, 1, 10)
end
function OnTick()
	
	for _,c in pairs(GetEnemyHeroes()) do		
		if c.visible then
			lastpos [ c.networkID ] = Vector(c) 
			lasttime[ c.networkID ] = os.clock() 
		elseif not c.dead and not c.visible then
			if menu. always or menu.active then 
			
				local time=lasttime[ c.networkID ]  --last seen time
				local pos=lastpos [ c.networkID ]   --last seen pos
				local clock=os.clock()
				if time and pos and clock-time<menu.maxT and clock>next_wardtime and GetDistanceSqr(pos)<1000*1000 then
					local FoundBush = FindBush(pos.x,pos.y,pos.z,100)
					if FoundBush and GetDistanceSqr(FoundBush)<600*600 then
						local WardSlot = nil
						if GetInventorySlotItem(2045) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2045)) == READY then
							WardSlot = GetInventorySlotItem(2045)
						elseif GetInventorySlotItem(2049) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2049)) == READY then
							WardSlot = GetInventorySlotItem(2049)
						elseif myHero:CanUseSpell(ITEM_7) == READY and myHero:getItem(ITEM_7).id == 3340 or myHero:CanUseSpell(ITEM_7) == READY and myHero:getItem(ITEM_7).id == 3350 or myHero:CanUseSpell(ITEM_7) == READY and myHero:getItem(ITEM_7).id == 3361 or myHero:CanUseSpell(ITEM_7) == READY and myHero:getItem(ITEM_7).id == 3362 then
							WardSlot = ITEM_7
						elseif GetInventorySlotItem(2044) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2044)) == READY then
							WardSlot = GetInventorySlotItem(2044)
						elseif GetInventorySlotItem(2043) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2043)) == READY then
							WardSlot = GetInventorySlotItem(2043)
						end
						if WardSlot then
							CastSpell(WardSlot,FoundBush.x,FoundBush.z)
							next_wardtime=clock+0.5
							return
						end
					end
				end
			end
		end
	end
end
function OnDash(unit,dash_info)
	if unit.team~=myHero.team then
		--print("Enemy Dashed")
		lastpos[unit.networkID]= Vector(dash_info.endPos)
	end
end
function FindBush(x0, y0, z0, maxRadius, precision) --returns the nearest non-wall-position of the given position(Credits to gReY)
    
    --Convert to vector
    local vec = D3DXVECTOR3(x0, y0, z0)
    
    --If the given position it a non-wall-position return it
	--if IsWallOfGrass(vec) then
	--	print("#1")
	--	return vec 
	--end
    
    --Optional arguments
    precision = precision or 50
    maxRadius = maxRadius and math.floor(maxRadius / precision) or math.huge
    
    --Round x, z
    x0, z0 = math.round(x0 / precision) * precision, math.round(z0 / precision) * precision

    --Init vars
    local radius = 2
    
    --Check if the given position is a non-wall position
    local function checkP(x, y) 
        vec.x, vec.z = x0 + x * precision, z0 + y * precision 
        return IsWallOfGrass(vec) 
    end
    
    --Loop through incremented radius until a non-wall-position is found or maxRadius is reached
    while radius <= maxRadius do
        --A lot of crazy math (ask gReY if you don't understand it. I don't)
        if checkP(0, radius) or checkP(radius, 0) or checkP(0, -radius) or checkP(-radius, 0) then 
			--print("#2:"..radius)
            return vec 
        end
        local f, x, y = 1 - radius, 0, radius
        while x < y - 1 do
            x = x + 1
            if f < 0 then 
                f = f + 1 + 2 * x
            else 
                y, f = y - 1, f + 1 + 2 * (x - y)
            end
            if checkP(x, y) or checkP(-x, y) or checkP(x, -y) or checkP(-x, -y) or 
               checkP(y, x) or checkP(-y, x) or checkP(y, -x) or checkP(-y, -x) then 
			--	print("#3:"..radius)
                return vec 
            end
        end
        --Increment radius every iteration
        radius = radius + 1
    end
end
