function client.nastavitHracksaData(key, value)
	PlayerData[key] = value
	NaHracskaData(key, value)
end

function client.maSkupinu(group)
	if PlayerData.loaded then
		if type(group) == 'table' then
			for name, rank in pairs(group) do
				local groupRank = PlayerData.groups[name]
				if groupRank and groupRank >= (rank or 0) then
					return name, groupRank
				end
			end
		else
			local groupRank = PlayerData.groups[group]
			if groupRank then
				return group, groupRank
			end
		end
	end
end

local Utils = client.utils

local function naOdhlaseni()
	if PlayerData.loaded then
		if client.parachute then
			Utils.SmazatObjekt(client.parachute)
			client.parachute = false
		end

		TriggerEvent('ox_inventory:zavritInventar')
		PlayerData.loaded = false
		ClearInterval(client.interval)
		ClearInterval(client.tick)
		currentWeapon = Utils.Odzbrojit(currentWeapon)
	end
end

if shared.framework == 'ox' then
	RegisterNetEvent('ox:playerLogout', naOdhlaseni)
elseif shared.framework == 'esx' then
	local ESX = exports.es_extended:getSharedObject()

	ESX = {
		SetPlayerData = ESX.SetPlayerData,
		PlayerLoaded = ESX.PlayerLoaded
	}

	function client.nastavitHracksaData(key, value)
		PlayerData[key] = value
		ESX.SetPlayerData(key, value)
	end

	RegisterNetEvent('esx:onPlayerLogout', naOdhlaseni)

	AddEventHandler('esx:setPlayerData', function(key, value)
		if PlayerData.loaded and GetInvokingResource() == 'es_extended' then
			if key == 'job' then
				key = 'groups'
				value = { [value.name] = value.grade }
			end

			PlayerData[key] = value
			NaHracskaData(key, value)
		end
	end)

	RegisterNetEvent('esx_policejob:handcuff', function()
		PlayerData.cuffed = not PlayerData.cuffed
		LocalPlayer.state:set('invBusy', PlayerData.cuffed, false)
		if PlayerData.cuffed then
			currentWeapon = Utils.Odzbrojit(currentWeapon)
		end
	end)

	RegisterNetEvent('esx_policejob:unrestrain', function()
		PlayerData.cuffed = false
		LocalPlayer.state:set('invBusy', PlayerData.cuffed, false)
	end)

	if ESX.PlayerLoaded then
		TriggerServerEvent('ox_inventory:requestPlayerInventory')
	end
end
