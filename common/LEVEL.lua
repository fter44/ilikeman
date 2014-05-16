--LEVEL UP
class "LEVEL"
function LEVEL:__init()
	self.AtLevelUP = {}
	self.OnLevelUP = {}
	self.Level = 0
	self.lasttick=0
	AddTickCallback(function() self:OnTick() end)
end
function LEVEL:RegisterAtLevelUPCallback(level,fn)
	if self.AtLevelUP[level]==nil then
		self.AtLevelUP[level]={fn}
	else
		table.insert(self.AtLevelUP[level], fn)
	end
	
	return self
end
function LEVEL:RegisterOnLevelUPCallback(fn)
	table.insert(self.OnLevelUP, fn)
	return self
end
function LEVEL:OnTick()
	if os.clock-self.lasttick<0.5 then return end
	
	if self.Level~=myHero.level then --LEVEL UP!
		self.Level=myHero.level
		if self.AtLevelUP[self.Level] then
			for _,fn in pairs(self.AtLevelUP[self.Level]) do
				fn()
			end
		end
		for _,fn in pairs(self.OnLevelUP) do
			fn(self.Level)
		end
	end
end