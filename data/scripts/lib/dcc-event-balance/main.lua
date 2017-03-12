--------------------------------------------------------------------------------
-- EVENT BALANCING LIB ---------------------------------------------------------
--------------------------------------------------------------------------------
-- darkconsole <darkcee.legit@gmail.com> ---------------------------------------

--------------------------------------------------------------------------------
-- STOCK FILE MODIFICATIONS ----------------------------------------------------
--------------------------------------------------------------------------------

-- player\eventscheduler.lua
-- + require event balancer
-- + increase event delay
-- + disable multiple players speeding up events
-- + determine if event should be skipped

-- events\pirateattack.lua
-- + require event balancer
-- + determine if event should be skipped

--------------------------------------------------------------------------------
-- MOD CONFIG ------------------------------------------------------------------
--------------------------------------------------------------------------------

EventBalance = {
	PauseMultiplier = 8,     -- mutiplier for delay between events
	SkipWindow      = 33.0,  -- percentage of sector volume to skip.
	SkipChance      = 4      -- flat chance to skip. 1 = 0%, 2 = 50%, 3 = 66%, 4 = 75%, etc.
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

require("galaxy")

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function EventBalance.GetSectorShipInfo(Coord)
-- @argv vec2 SectorCoords
-- @return [ int Count, float Volume, float VolumeAverage ]
-- find out some information about the ships in this sector.
-- Float Volume of Ships

	local Key
	local Value

	local Count = 0
	local Volume = 0
	local VolumeAverage = 0

	--------
	-- find all the ships, counting how many we have and how much total volume
	-- they take up in this sector.
	--------

	for Key,Value in pairs({Sector(Coord):getEntitiesByType(EntityType.Ship)})
	do
		Volume = Volume + Value.volume
		Count = Count + 1
	end

	--------
	-- determine the mean volume of the ships in this sector.
	--------

	VolumeAverage = Volume / Count

	--------

	return Count, Volume, VolumeAverage
end

function EventBalance.ShouldSkipEvent(Event)
-- the purpose of this method is to determine if we should skip the event that
-- tried to happen. this is based on the "power" of a sector. the more empty a
-- sector is the less likely pirates will think it worth attacking. on the flip
-- side once the sector becomes too strong pirates should think twice about
-- attempting to pillage it.

	--------
	-- passive events that won't fuck up your day are always allowed.
	--------

	if(Event.script == "spawntravellingmerchant")
	then
		return false
	end

	if(Event.script == "convoidistresssignal")
	then
		return false
	end

	--------
	-- chances that an event may be skipped
	--------

	if(EventBalance.ShouldSkipEvent_BySectorVolume(Event) == true) then
		return true
	end

	if(EventBalance.ShouldSkipEvent_ByFlatChance(Event) == true) then
		return true
	end

	--------
	--------

	return false
end

function EventBalance.ShouldSkipEvent_BySectorVolume(Event)
-- analyze the sector and decide if we should skip this event based on the
-- volume of ships within it.

	local
		ShipTotalCount,
		ShipTotalVolume,
		ShipAverageVolume
	= EventBalance.GetSectorShipInfo(Sector():getCoordinates())

	local SectorAverageVolume = Balancing_GetSectorShipVolume(Sector():getCoordinates())
	local SectorAllowedDiff = (EventBalance.SkipWindow * SectorAverageVolume) / 100

	print("---- Event Balancer: Sector Analysis (" .. Event.script .. ") ----")
	print("Number of Ships In Sector: " .. ShipTotalCount)
	print("Volume of Ships In Sector: " .. ShipTotalVolume)
	print("Sector Expected Average Volume Per Ship: " .. SectorAverageVolume)
	print("Sector Actual Average Volume Per Ship: " .. ShipAverageVolume)
	print("Sector Allowed Difference (" .. EventBalance.SkipWindow .. "%): " .. SectorAllowedDiff)

	-- @todo - 2017-03-08
	-- math

	return false
end

function EventBalance.ShouldSkipEvent_ByFlatChance(Event)
-- decide if we should skip the event based on a stupid flat chance.

	if(EventBalance.SkipChance > 0) then
		return random():getInt(1,EventBalance.SkipChance) == 1
	end
end