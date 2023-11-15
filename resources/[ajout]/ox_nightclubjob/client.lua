ESX = exports["es_extended"]:getSharedObject()

local PlayerData              = {}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

Blip = {
    Pos     = { x = 129.246, y = -1299.363, z = 29.501 },
    Sprite  = 121,
    Display = 4,
    Scale   = 0.7,
    Colour  = 27,
  },

Citizen.CreateThread(function()
	nightclub = AddBlipForCoord(129.246, -1299.363, 29.501)
	SetBlipSprite(nightclub, 121)
    SetBlipDisplay(nightclub, 4)
	SetBlipColour(nightclub, 27)
	SetBlipScale(nightclub, 0.7)
    SetBlipAsShortRange(nightclub, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Nightclub")
end)

exports.ox_target:addBoxZone({
    coords =  vector3(96.04, -1293.05, 29.07),
    size = vec3(0.5, 0.25, 0.05),
    rotation = 118,
    debug = false,
    options = {
        {
            name = 'Gestion',
            event = 'esx_nightclubjob:bossnightclub',
            icon = 'fa-solid fa-computer',
            label = 'Gestion',
            distance = 1.5,
        }
    }
})

AddEventHandler('esx_nightclubjob:bossnightclub', function()
    if ESX.PlayerData.job and ESX.PlayerData.job.name == 'nightclub' then
    TriggerEvent('esx_society:openBossMenu', 'nightclub', function(data, menu)
    end, {wash = false})
    end
end)