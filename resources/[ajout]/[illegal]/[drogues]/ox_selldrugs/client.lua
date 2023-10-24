ESX = exports["es_extended"]:getSharedObject()
PlayerData = {}
npc = {}
cooldown = false
cops = 0
blips = {}

-- Création polyzone
	local Zone = PolyZone:Create({
  vector2(-2220.8608398438, -439.56546020508),
  vector2(-2410.4204101562, 319.03659057618),
  vector2(-2332.07421875, 532.0151977539),
  vector2(-374.66, 1293.09),
  vector2(1715.5300292968, 1325.201538086),
  vector2(1760.9155273438, -1273.7103271484),
  vector2(1910.3436279296, -1352.4432373046),
  vector2(1629.648071289, -2690.7348632812),
  vector2(1402.6340332032, -3405.7231445312),
  vector2(-1171.8603515625, -3614.078125),
  vector2(-2174.0354003906, -3102.8061523438),
  vector2(-1409.8012695312, -1955.2064208984),
  vector2(-1838.9934082032, -1321.506225586)
}, {
  name="Zone",
	debugPoly = false,
	--minZ = 30.07371520996,
	--maxZ = 31.074838638306
})

-- Condition entrée et sortie de zone
Zone:onPlayerInOut(function (isPointInside)
    if isPointInside then
        id = GetPlayerServerId(PlayerId())
        Player(id).state:set('selldrugs', true, true)
    else
        id = GetPlayerServerId(PlayerId())
        Player(id).state:set('selldrugs', false, true)
    end
end)

Citizen.CreateThread(function()
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(5000)
	end

	PlayerData = ESX.GetPlayerData()
	ESX.Streaming.RequestStreamedTextureDict('DIA_CLIFFORD')

	ESX.PlayAnim = function(dict, anim, speed, time, flag)
		ESX.Streaming.RequestAnimDict(dict, function()
			TaskPlayAnim(PlayerPedId(), dict, anim, speed, speed, time, flag, 1, false, false, false)
		end)
	end

	ESX.PlayAnimOnPed = function(ped, dict, anim, speed, time, flag)
		ESX.Streaming.RequestAnimDict(dict, function()
			TaskPlayAnim(ped, dict, anim, speed, speed, time, flag, 1, false, false, false)
		end)
	end

	ESX.Game.MakeEntityFaceEntity = function(entity1, entity2)
		local p1 = GetEntityCoords(entity1, true)
		local p2 = GetEntityCoords(entity2, true)
	
		local dx = p2.x - p1.x
		local dy = p2.y - p1.y
	
		local heading = GetHeadingFromVector_2d(dx, dy)
		SetEntityHeading( entity1, heading )
	end
end)

next_ped = function(drugToSell)
if  Player(id).state.selldrugs then
if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
	ESX.ShowNotification("Impossible depuis un véhicule!", "error", 3000)
else
	if cooldown then
		--ESX.ShowAdvancedNotification(Config.notify.title, '', Config.notify.cooldown, 'DIA_CLIFFORD', 1)
		return
	end

	cooldown = true

	TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_STAND_MOBILE", 0, true)
	--ESX.ShowAdvancedNotification(Config.notify.title, '', Config.notify.searching .. drugToSell.label, 'DIA_CLIFFORD', 1)
	Wait(math.random(5000, 10000))
	--ESX.PlayAnim('amb@world_human_drug_dealer_hard@male@base', 'base', 8.0, -1, 1)
	ClearPedTasks(PlayerPedId()) 
	npc.hash = GetHashKey(Config.pedlist[math.random(1, #Config.pedlist)])
	ESX.Streaming.RequestModel(npc.hash)
	npc.coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 45.0, 5.0)
	retval, npc.z = GetGroundZFor_3dCoord(npc.coords.x, npc.coords.y, npc.coords.z, 0)

	if retval == false then
		cooldown = false
		--ESX.ShowAdvancedNotification(Config.notify.title, '', Config.notify.abort, 'DIA_CLIFFORD', 1)
		ClearPedTasks(PlayerPedId())
		return
	end

	npc.zone = GetLabelText(GetNameOfZone(npc.coords))
	drugToSell.zone = npc.zone
	npc.ped = CreatePed(5, npc.hash, npc.coords.x, npc.coords.y, npc.z, 0.0, true, true)
	PlaceObjectOnGroundProperly(npc.ped)
	SetEntityAsMissionEntity(npc.ped)
	
	if IsEntityDead(npc.ped) or GetEntityCoords(npc.ped) == vector3(0.0, 0.0, 0.0) then
		--ESX.ShowAdvancedNotification(Config.notify.title, '', Config.notify.notfound, 'DIA_CLIFFORD', 1)
        return
	end
	
	--ESX.ShowAdvancedNotification(Config.notify.title, Config.notify.approach, Config.notify.found .. npc.zone, 'DIA_CLIFFORD', 1)
	TaskGoToEntity(npc.ped, PlayerPedId(), 60000, 4.0, 2.0, 0, 0)
    local options = {
        {
            name = 'Vente de drogues',
            event = 'selldrugsselldrugs',
            icon = 'fas fa-capsules',
            label = 'Vente de drogues',
            distance = 0.9,
        },
    }label = 'Vente de drogues',
    exports.ox_target:addLocalEntity(npc.ped, options)

    end
	else
	ESX.ShowNotification("Vous ne pouvez pas téléphoner dans cette zone!", "error", 3000)
	end
end

AddEventHandler('selldrugsselldrugs', function(drugToSell, price)
	if npc ~= nil and npc.ped ~= nil then
		SetPedAsNoLongerNeeded(npc.ped)
	end

	cops = 0
	ESX.TriggerServerCallback('selldrugsgetPoliceCount', function(_cops)
		cops = _cops
	end)

	Wait(500)

	if cops < Config.requiredCops then
		--ESX.ShowAdvancedNotification(Config.notify.title, '', Config.notify.cops, 'DIA_CLIFFORD', 1)
		return
	end

	if cops == 0 then
		drugToSell.price = 50
	elseif cops >= 1 and cops <= 2 then
		drugToSell.price = 100
	elseif cops >= 3 and cops <= 4 then
		drugToSell.price = 200
	elseif cops >= 5 and cops <= 6 then
		drugToSell.price = 250
	elseif cops >= 7 then
		drugToSell.price = 300
	end
		canSell = true
		while npc.ped ~= nil and npc.ped ~= 0 and not IsEntityDead(npc.ped) do
			Wait(0)
			npc.coords = GetEntityCoords(npc.ped)
			--ESX.Game.Utils.DrawText3D(npc.coords, (Config.notify.client):format(drugToSell.count, drugToSell.label), 0.5)
			distance = Vdist2(GetEntityCoords(PlayerPedId()), npc.coords)
			
			if distance <= 2.0 then
				--ESX.ShowHelpNotification(Config.notify.press)
				--if IsControlJustPressed(0, 38) and canSell then
					canSell = false
					reject = math.random(1, 10)

					if reject <= 3 then
						--ESX.ShowAdvancedNotification(Config.notify.title, '', Config.notify.reject, 'DIA_CLIFFORD', 1)
						PlayAmbientSpeech1(npc.ped, 'GENERIC_HI', 'SPEECH_PARAMS_STANDARD')
						drugToSell.coords = GetEntityCoords(PlayerPedId())
						TriggerServerEvent('selldrugsnotifycops', drugToSell)
						SetPedAsNoLongerNeeded(npc.ped)
						if Config.npcFightOnReject then
							TaskCombatPed(npc.ped, PlayerPedId(), 0, 16)
						end
						npc = {}
						return
					end

					if IsPedInAnyVehicle(PlayerPedId(), false) then
						--ESX.ShowAdvancedNotification(Config.notify.title, Config.notify.vehicle, '', 'DIA_CLIFFORD', 1)
						return
					end

					TriggerServerEvent('selldrugspay', drugToSell)
					ESX.Game.MakeEntityFaceEntity(PlayerPedId(), npc.ped)
					ESX.Game.MakeEntityFaceEntity(npc.ped, PlayerPedId())
					SetPedTalk(npc.ped)
					PlayAmbientSpeech1(npc.ped, 'GENERIC_HI', 'SPEECH_PARAMS_STANDARD')
					obj = CreateObject(GetHashKey('prop_weed_bottle'), 0, 0, 0, true)
					AttachEntityToEntity(obj, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
					obj2 = CreateObject(GetHashKey('hei_prop_heist_cash_pile'), 0, 0, 0, true)
					AttachEntityToEntity(obj2, npc.ped, GetPedBoneIndex(npc.ped,  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
					ESX.PlayAnim('mp_common', 'givetake1_a', 8.0, -1, 0)
					ESX.PlayAnimOnPed(npc.ped, 'mp_common', 'givetake1_a', 8.0, -1, 0)
					Wait(1000)
					AttachEntityToEntity(obj2, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
					AttachEntityToEntity(obj, npc.ped, GetPedBoneIndex(npc.ped,  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
					Wait(1000)
					DeleteEntity(obj)
					DeleteEntity(obj2)
					PlayAmbientSpeech1(npc.ped, 'GENERIC_THANKS', 'SPEECH_PARAMS_STANDARD')
					SetPedAsNoLongerNeeded(npc.ped)
			        --ESX.ShowAdvancedNotification(Config.notify.title, '', (Config.notify.sold):format(drugToSell.count, drugToSell.label, drugToSell.price), 'DIA_CLIFFORD', 1)
					npc = {}
				--end
			end
		end
end)

CreateThread(function()
	while true do
		Wait(20000)
		if cooldown then
			cooldown = false
		end
	end
end)

RegisterNetEvent('selldrugsfindClient')
AddEventHandler('selldrugsfindClient', next_ped)

RegisterNetEvent('selldrugsnotifyPolice')
AddEventHandler('selldrugsnotifyPolice', function(coords)
    local player = ESX.GetPlayerData()
    if player.job.name == "police" then
	--if PlayerData.job ~= nil and PlayerData.job.name == 'police' then
	--if PlayerData.job.name == 'police' then
		street = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
		street2 = GetStreetNameFromHashKey(street)
--		ESX.ShowAdvancedNotification(Config.notify.police_notify_title, Config.notify.police_notify_subtitle, street2, "CHAR_CALL911", 1)
		PlaySoundFrontend(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset", 0)

		blip = AddBlipForCoord(coords)
		SetBlipSprite(blip,  403)
		SetBlipColour(blip,  1)
		SetBlipAlpha(blip, 250)
		SetBlipScale(blip, 1.2)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Vente de Drogues')
		EndTextCommandSetBlipName(blip)
		table.insert(blips, blip)
		Wait(50000)
		for i in pairs(blips) do
			RemoveBlip(blips[i])
			blips[i] = nil
		end
	end
end)