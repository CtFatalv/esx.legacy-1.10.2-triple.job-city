local ox_inventory = exports.ox_inventory
local repairs = {}

if Config.useOTSkills then
    exports.OT_skills:registerSkill({
        name = 'gunsmithing',
        multiplier = 2.5,
        maxlevel = 30,
        maxReward = 20,
        maxDeduction = 20,
        label = 'Gunsmithing',
        description = 'Un maître armurier peut assembler, réparer et modifier même les armes à feu les plus rares..'
    })
end

local function fixWeapon(payload)
    if type(payload) ~= 'table' or table.type(payload) == 'empty' then return end
    TriggerClientEvent('ox_inventory:closeInventory', payload.source)
    ox_inventory:RemoveItem(payload.source, payload.fromSlot.name, 1)
    repairs[payload.source] = {}
    repairs[payload.source].slot = payload.toSlot.slot
    repairs[payload.source].name = payload.toSlot.name
    TriggerClientEvent('OT_weaponrepair:repairitem', payload.source, payload.toSlot.name)
end

RegisterNetEvent('OT_weaponrepair:startweaponrepair', function(data)
    local src = source
    local slot = ox_inventory:GetSlot(src, data.slot)
    if slot.metadata.durability < 100.0 then
    if slot and slot.name == data.name then
        local pCoords = GetEntityCoords(GetPlayerPed(src))
        if not Config.locations[data.bench].free then
            local requiredItem = Config.require[data.name] and Config.require[data.name].requireditem or Config.requireditem
            local requiredAmount = Config.require[data.name] and Config.require[data.name].requireditemamount or Config.requireditemamount
            local count = ox_inventory:Search(src, 'count', requiredItem)
            if #(pCoords - Config.locations[data.bench].coords) > 10.0 then print('Player ID:', src, 'Tentative de réparation de l\'arme loin du banc, probablement en trichant') return end
            if not count then return TriggerClientEvent('ox_lib:notify', src, {type = 'error', title = 'Etabli d\'Arme', description = 'Éléments requis manquants'}) end
            if count >= requiredAmount then
                ox_inventory:RemoveItem(src, requiredItem, requiredAmount)
                repairs[src] = {}
                repairs[src].slot = data.slot
                repairs[src].name = data.name
                TriggerClientEvent('OT_weaponrepair:repairitem', src, data.name)
            else
                TriggerClientEvent('ox_lib:notify', src, {type = 'error', title = 'Etabli d\'Arme', description = string.format('Vous n\'avez pas assez d\'argent sur vous', requiredItem)})
            end
        else
            if #(pCoords - Config.locations[data.bench].coords) > 10.0 then print('Player ID:', src, 'Essayer de réparer une arme gratuitement loin du banc, probablement en trichant') return end
            repairs[src] = {}
            repairs[src].slot = data.slot
            repairs[src].name = data.name
            TriggerClientEvent('OT_weaponrepair:repairitem', src, data.name)
        end
    elseif slot and slot.name ~= data.name then
        print('Player ID:', src, 'Tentative de réparation d\'une arme avec des données incorrectes, probablement en trichant')
    end
    else
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', title = 'Etabli d\'Arme', description = string.format('L\'arme n\'a pas besoin d\'être réparée')})
    end
end)

RegisterNetEvent('OT_weaponrepair:fixweapon', function()
    local src = source
    if repairs[src] then
        local slot = ox_inventory:GetSlot(src, repairs[src].slot)
        if slot and slot.name == repairs[src].name then
            ox_inventory:SetDurability(src, repairs[src].slot, 100)
            if Config.useOTSkills then
                exports.OT_skills:addXP(src, 'gunsmithing', Config.xpreward)
            end
            repairs[src] = nil
        elseif slot and slot.name ~= repairs[src].name then
            print('Player ID:', src, 'Tentative de réparation d\'une arme avec une incompatibilité de données, probablement en trichant')
        end
    else
        print('Player ID:', src, 'Tentative de réparation d\'une arme avec des données incorrectes, probablement en trichant')
    end
end)

lib.callback.register('openRepairBench', function(source)
    return ox_inventory:Search(source, 'slots', Weapons)
end)

local hookId = exports.ox_inventory:registerHook('swapItems', function(payload)
    if type(payload.toSlot) == 'table' and payload.fromSlot.name == Config.repairItem then
        if WeaponHashes[payload.toSlot.name] then
            if payload.toSlot.metadata.durability >= 100.0 then TriggerClientEvent('ox_lib:notify', payload.source, {position = 'top', type = 'error', description = 'L\'arme n\'a pas besoin d\'être réparée'}) return false end
            CreateThread(function() fixWeapon(payload) end)
            return false
        end
    end
    return true
end, {print = true, itemFilter = Filter})