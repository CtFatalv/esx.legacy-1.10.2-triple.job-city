ESX = exports["es_extended"]:getSharedObject()

Citizen.CreateThread(function()
	nightclub = AddBlipForCoord(129.246, -1299.363, 29.501)
	SetBlipSprite(nightclub, 121)
    SetBlipDisplay(nightclub, 4)
	SetBlipColour(nightclub, 27)
	SetBlipScale(nightclub, 0.7)
    SetBlipAsShortRange(nightclub, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Nightclub")
	EndTextCommandSetBlipName(nightclub)
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