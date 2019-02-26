if onServer() then

package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

require ("galaxy")
require ("randomext")
require ("stringutility")

-- <dcc title="require event balancer">
require("dcc-event-balance/main")
-- </dcc>

local Placer = require("placer")
local AsyncPirateGenerator = require ("asyncpirategenerator")
local UpgradeGenerator = require ("upgradegenerator")
local TurretGenerator = require ("turretgenerator")


local ships = {}
local reward = 0
local reputation = 0

local participants = {}

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace PirateAttack
PirateAttack = {}
PirateAttack.attackersGenerated = false


function PirateAttack.secure()
    return {reward = reward, reputation = reputation, ships = ships}
end

function PirateAttack.restore(data)
    ships = data.ships
    reputation = data.reputation
    reward = data.reward
end

function PirateAttack.initialize()

    -- no pirate attacks at the very edge of the galaxy
    local x, y = Sector():getCoordinates()
    if length(vec2(x, y)) > 560 then
        print ("Too far out for pirate attacks.")
        terminate()
        return
    end

    if Sector():getValue("neutral_zone") then
        print ("No pirate attacks in neutral zones.")
        terminate()
        return
    end

    -- <dcc title="determine if the event should be skipped">
    if EventBalance.ShouldSkipEvent({script="pirates-being-annoying"}) then
        print("[EB] pirate event skipped")
        terminate()
        return
    end
    -- </dcc>

    ships = {}
    participants = {}
    reward = 0
    reputation = 0

    local scaling = Sector().numPlayers
    if scaling == 0 then
        terminate()
        return
    end

    if scaling == 1 then
        local player = Sector():getPlayers()
        local hx, hy = player:getHomeSectorCoordinates()
        if hx == x and hy == y and player.playtime < 30 * 60 then
            print ("Player's playtime is below 30 minutes (%is), cancelling pirate attack.", player.playtime)
            terminate()
            return
        end
    end

    -- create attacking ships
    local dir = normalize(vec3(getFloat(-1, 1), getFloat(-1, 1), getFloat(-1, 1)))
    local up = vec3(0, 1, 0)
    local right = normalize(cross(dir, up))
    local pos = dir * 1000

    local attackType = getInt(1, 4)

    local distance = 50

    local generator = AsyncPirateGenerator(PirateAttack, PirateAttack.onPiratesGenerated)
    generator:startBatch()

    if attackType == 1 then
        reward = 2.0

        generator:createScaledRaider(MatrixLookUpPosition(-dir, up, pos))
        generator:createScaledBandit(MatrixLookUpPosition(-dir, up, pos + right * distance))
        generator:createScaledBandit(MatrixLookUpPosition(-dir, up, pos + right * -distance))

    elseif attackType == 2 then
        reward = 1.5

        generator:createScaledPirate(MatrixLookUpPosition(-dir, up, pos))
        generator:createScaledBandit(MatrixLookUpPosition(-dir, up, pos + right * distance))
        generator:createScaledBandit(MatrixLookUpPosition(-dir, up, pos + right * -distance))

    elseif attackType == 3 then
        reward = 1.5

        generator:createScaledPirate(MatrixLookUpPosition(-dir, up, pos))
        generator:createScaledPirate(MatrixLookUpPosition(-dir, up, pos + right * distance))
        generator:createScaledPirate(MatrixLookUpPosition(-dir, up, pos + right * -distance))
    else
        reward = 1.0

        generator:createScaledBandit(MatrixLookUpPosition(-dir, up, pos))
        generator:createScaledBandit(MatrixLookUpPosition(-dir, up, pos + right * distance))
        generator:createScaledBandit(MatrixLookUpPosition(-dir, up, pos + right * -distance))
        generator:createScaledOutlaw(MatrixLookUpPosition(-dir, up, pos + right * -distance * 2.0))
        generator:createScaledOutlaw(MatrixLookUpPosition(-dir, up, pos + right * distance * 2.0))
    end

    generator:endBatch()

    reputation = reward * 2000
    reward = reward * 4500 * Balancing_GetSectorRichnessFactor(Sector():getCoordinates())

    Sector():broadcastChatMessage("Server"%_t, 2, "Pirates are attacking the sector!"%_t)
end

function PirateAttack.getUpdateInterval()
    -- <dcc title="increase event delay">
    return 15 * EventBalance.PauseMultiplier
    -- </dcc>
end

function PirateAttack.onPiratesGenerated(generated)

    for _, ship in pairs(generated) do
        if valid(ship) then -- this check is necessary because ships could get destroyed before this callback is executed
            ships[ship.index.string] = true
            ship:registerCallback("onDestroyed", "onShipDestroyed")
        end
    end

    -- resolve intersections between generated ships
    Placer.resolveIntersections(generated)

    PirateAttack.attackersGenerated = true
end

function PirateAttack.update(timeStep)

    if not PirateAttack.attackersGenerated then return end

    -- check if all ships are still there
    -- ships might have changed sector or deleted in another way, which doesn't trigger destruction callback
    local sector = Sector()
    for id, _ in pairs(ships) do
        local pirate = sector:getEntity(id)
        if pirate == nil then
            ships[id] = nil
        end
    end

    -- if not -> end event
    if tablelength(ships) == 0 then
        PirateAttack.endEvent()
    end
end

function PirateAttack.onShipDestroyed(shipIndex)

    ships[shipIndex.string] = nil

    local ship = Entity(shipIndex)
    local damagers = {ship:getDamageContributors()}
    for _, damager in pairs(damagers) do
        if not Faction(damager).isAIFaction then
            participants[damager] = damager
        end
    end

    -- if they're all destroyed, the event ends
    if tablelength(ships) == 0 then
        PirateAttack.endEvent()
    end
end


function PirateAttack.endEvent()

    local faction = Galaxy():getLocalFaction(Sector():getCoordinates())
    if faction then

        local messages =
        {
            "Thank you for defeating those pirates. You have our endless gratitude."%_t,
            "We thank you for taking care of those ships. We transferred a reward to your account."%_t,
            "Thank you for taking care of those pirates. We transferred a reward to your account."%_t,
        }

        -- give payment to players/alliances who participated
        for _, participant in pairs(participants) do
            local participantFaction = Faction(participant)

            participantFaction:sendChatMessage(faction.name, 0, getRandomEntry(messages))
            participantFaction:receive("Received %1% credits for defeating a pirate attack."%_T, reward)
            Galaxy():changeFactionRelations(participantFaction, faction, reputation)

            local x, y = Sector():getCoordinates()
            local object

            if random():getFloat() < 0.5 then
                object = InventoryTurret(TurretGenerator.generate(x, y, 0, Rarity(RarityType.Uncommon)))
            else
                UpgradeGenerator.initialize(random():createSeed())
                object = UpgradeGenerator.generateSystem(Rarity(RarityType.Uncommon))
            end

            if object then participantFaction:getInventory():add(object) end
        end
    end

    terminate()
end

end
