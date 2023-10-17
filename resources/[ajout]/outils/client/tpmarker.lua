function admin_tp_marker()
	local WaypointHandle = GetFirstBlipInfoId(8)

	if DoesBlipExist(WaypointHandle) then
		local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)

		for height = 1, 1000 do
			SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

			local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)

			if foundGround then
				SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

				break
			end

			Citizen.Wait(0)
		end
	end
end

Citizen.CreateThread(function()
	while true do
		plyPed = PlayerPedId()
		if IsControlPressed(1, 21) and IsControlJustReleased(1, 38) and GetLastInputMethod(2) and not isDead then
			PlayerData = ESX.GetPlayerData()
			admin_tp_marker()
		end
		Citizen.Wait(0)
	end
end)