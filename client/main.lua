-- TODO: Default veriables...
local Keys      = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}



local ESX           = nil
local ped           = PlayerPedId()
local pedCoords     = {}
local pedDuty       = false
local busVehicle    = nil
local blip          = nil
local finishMarker  = nil
local finishBlip    = nil
local finalBlip     = nil


AddEventHandler('playerSpawned', function()
    Citizen.CreateThread(function()
        while ESX == nil do
            Citizen.Wait(10)
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        end
    end)
end)

-- TODO: ESX
Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(10)
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    end
end)

-- TODO: Finish Mark
Citizen.CreateThread(function ()
    local sleep = 250
    while true do
        Citizen.Wait(sleep)

        if finishMarker ~= nil then
            sleep = 0

            for _, v in ipairs(Config.BusJob) do
                for _, _v in ipairs(v.FinishPos) do
                    DrawMarker(25, _v.x, _v.y, _v.z, 0.0, 0.0, 0.0, 
                    0.0, 0.0, 0.0, 5.0, 5.0, 5.0, 
                    255, 255, 0, 200, 
                    true, false, 2, true, nil, nil, false)

                    if Vdist(_v.x, _v.y, _v.z, pedCoords.x, pedCoords.y, pedCoords.z) < 5.0 then                
                        ShowPedHelpDialog(_U('finish_marker_msg'))

                        if IsControlPressed(0, Keys['E']) and IsPedInSpawnBus() then
                            FinishBus()
                        end
                    end
                end
            end
        else
            sleep = 500
        end
    end
end)

-- TODO: Final Mark
Citizen.CreateThread(function ()
    local sleep = 250
    while true do
        Citizen.Wait(sleep)

        if finalMarker ~= nil then
            sleep = 0

            for _, v in ipairs(Config.BusJob) do
                for _, _v in ipairs(v.FinalPos) do
                    DrawMarker(25, _v.x, _v.y, _v.z, 0.0, 0.0, 0.0, 
                    0.0, 0.0, 0.0, 5.0, 5.0, 5.0, 
                    255, 255, 0, 200, 
                    true, false, 2, true, nil, nil, false)

                    if Vdist(_v.x, _v.y, _v.z, pedCoords.x, pedCoords.y, pedCoords.z) < 5.0 then                
                        ShowPedHelpDialog(_U('final_marker_msg'))

                        if IsControlPressed(0, Keys['E']) and IsPedInSpawnBus() then
                            CompleteJob()
                        end
                    end
                end
            end
        else
            sleep = 500
        end
    end
end)

-- TODO: Duty Mark
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		for _, v in ipairs(Config.BusJob) do
			for _, _v in ipairs(v.DutyPos) do
				DrawMarker(2, _v.x, _v.y, _v.z, 0.0, 0.0, 0.0, 
				0.0, 0.0, 0.0, 1.3, 1.3, 1.3, 
				255, 255, 0, 200, 
				true, false, 2, true, nil, nil, false)

				if Vdist(_v.x, _v.y, _v.z, pedCoords.x, pedCoords.y, pedCoords.z) < 1.3 then                
					ShowPedHelpDialog(_U('duty_help_msg'))

					if IsControlPressed(0, Keys['E']) then
						ShowPedBusDutyMenu()
					end
				end
			end

			if pedDuty and not busVehicle then
				for _, _v in ipairs(v.VehicleSpawn) do
					DrawMarker(22, _v.x, _v.y, _v.z, 0.0, 0.0, 0.0, 
					0.0, 0.0, 0.0, 1.3, 1.3, 1.3, 
					255, 255, 0, 200, 
					true, false, 2, true, nil, nil, false)

					if Vdist(_v.x, _v.y, _v.z, pedCoords.x, pedCoords.y, pedCoords.z) < 1.3 then                
						ShowPedHelpDialog(_U('duty_spawn_bus_msg'))

						if IsControlPressed(0, Keys['E']) and not IsPedInBus() then
							SpawnBusForPed()
						end
					end
				end
			end
        end
    end
end)

-- TODO: Create Blip
Citizen.CreateThread(function()
    for _, v in ipairs(Config.BusJob) do
        for _, _v in ipairs(v.DutyPos) do
            blip = AddBlipForCoord(_v.x, _v.y, _v.z)
            SetBlipSprite(blip, Config.Blip['sprite'])
            SetBlipDisplay(blip, Config.Blip['display'])
            SetBlipScale(blip, Config.Blip['scale'])
            SetBlipColour(blip, Config.Blip['color'])
            SetBlipAlpha(blip, Config.Blip['alpha'])
            SetBlipAsFriendly(blip, Config.Blip['friend'])
            SetBlipAsShortRange(blip, Config.Blip['short'])
            AddTextEntry('BUSBLIP', Config.Blip['name'])
            BeginTextCommandSetBlipName('BUSBLIP')
            EndTextCommandSetBlipName(blip)
        end
    end
end)

-- TODO: optimization veriables...
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(250)
        pedCoords = GetEntityCoords(GetPlayerPed(-1)) -- TODO: pedCoords.x, pedCoords.y, pedCoords.z
    end
end)


-- TODO: Job functions...
function ShowPedBusDutyMenu()
    Citizen.Wait(120)
    ESX.UI.Menu.CloseAll()
    local _elements = {
        {label = _U('duty_menu_dutyon'), value = 'busjob_dutyon'},
        {label = _U('duty_menu_dutyoff'), value = 'busjob_dutyoff'},
    }

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'busjobdutymenu',
        {
            title = _U('duty_menu_title'),
            align = 'top-left',
            elements = _elements
        },

        function(data, menu)
            if data.current.value == 'busjob_dutyon' then
                if CheckDuty() == true then -- TODO: already duty on error
                    ESX.ShowNotification(_U('duty_menu_already_dutyon'))
                else -- TODO: duty on
                    pedDuty = true
					JobSetUniform()
                end
            elseif data.current.value == 'busjob_dutyoff' then
                if CheckDuty() == false then -- TODO: already duty on error
                    ESX.ShowNotification(_U('duty_menu_already_dutyoff'))
                else -- TODO: duty off
                    ResetDuty()
					ResetSkin()
                end
            end

            menu.close()
        end,

        -- TODO: close menu (ESC, etc...)
        function(data, menu)
            menu.close()
        end
    )
end

function SpawnBusForPed()
    Citizen.Wait(500)
    if not IsPedInBus() and not busVehicle then
        for _, v in ipairs(Config.BusJob) do
            for key, _v in ipairs(v.SpawnBus) do
                local areaVehicles = ESX.Game.GetVehiclesInArea(_v, 4.0)
                if #areaVehicles <= 0 then
                    ESX.Game.SpawnVehicle(Config.BusHash, _v, _v.h, function(vehicle)                
                        -- TODO: Check entity a vehicle?
                        if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
                            Citizen.Wait(200)
                            busVehicle = vehicle
                            TaskEnterVehicle(PlayerPedId(), vehicle, 5, -1, 2.0, 16, 0)
                            FirstDuty()             
                        end
                    end)

                    break

                elseif key == 4 then
                    ESX.ShowNotification(_U('duty_spawnbus_nolonger'))
                end
            end
        end
    end
end

function FirstDuty()
    return Config.Ped and CreatePedForBus() or FinishDuty()
end

function CreatePedForBus()
    Citizen.CreateThread(function()
        _npc = {}

        for i=1, 9, 1 do
            Citizen.Wait(50)
            local rndPedHash = RandomPedHash()
            _npc[i] = CreatePedForVehicle(busVehicle, rndPedHash, i - 1)
        end

        FinishDuty()
    end)
end

function FinishDuty()
    finishMarker = true
    Citizen.CreateThread(function()
		for _, v in ipairs(Config.BusJob) do
			for _, _v in ipairs(v.FinishPos) do
				finishBlip = AddBlipForCoord(_v.x, _v.y, _v.z)
				SetBlipSprite(finishBlip, 538)
				SetBlipDisplay(finishBlip, 2)
				SetBlipScale(finishBlip, 1.3)
				SetBlipColour(finishBlip,0)
				SetBlipAlpha(finishBlip, 255)
				SetBlipAsFriendly(finishBlip,1)
				SetBlipAsShortRange(finishBlip,0)
				AddTextEntry('FINISHBUSBLIP', _U('finish_blip'))
				BeginTextCommandSetBlipName('FINISHBUSBLIP')
				EndTextCommandSetBlipName(finishBlip)
				
				SetNewWaypoint(_v.x, _v.y)
			end
		end
	end)

    ESX.ShowNotification(_U('finish_msg'))
end

function FinishBus()
    Citizen.Wait(150)
    DisableAllControlActions(0)
    LeavePedInVehicle()
    ResetFinish()
    FinalBus()
end

function FinalBus()
	DeleteWaypoint()
    finalMarker = true
    Citizen.CreateThread(function()
		for _, v in ipairs(Config.BusJob) do
			for _, _v in ipairs(v.FinalPos) do
				finalBlip = AddBlipForCoord(_v.x, _v.y, _v.z)
				SetBlipSprite(finalBlip, 538)
				SetBlipDisplay(finalBlip, 2)
				SetBlipScale(finalBlip, 1.3)
				SetBlipColour(finalBlip,0)
				SetBlipAlpha(finalBlip, 255)
				SetBlipAsFriendly(finalBlip,1)
				SetBlipAsShortRange(finalBlip,0)
				AddTextEntry('FINALBUSBLIP', _U('final_blip'))
				BeginTextCommandSetBlipName('FINALBUSBLIP')
				EndTextCommandSetBlipName(finalBlip)
				SetNewWaypoint(_v.x, _v.y)
			end
		end
	end)

    ESX.ShowNotification(_U('final_msg'))
end

function CompleteJob()
    DeleteBus()
    ResetFinal()
    TriggerServerEvent('esx:busjob_confirmPay', GetPlayerServerId(PlayerId()))
end

function ResetFinal()
    if DoesBlipExist(finalBlip) then
        RemoveBlip(finalBlip)
    end

    finalMarker = nil
end

function DeleteBus()
    if DoesEntityExist(busVehicle) and IsEntityAVehicle(busVehicle) then
        ESX.Game.DeleteVehicle(busVehicle)
        busVehicle = nil
    end
end

function LeavePedInVehicle()
    for _, v in pairs(_npc) do
        if IsEntityAPed(v) then
            DeletePed(v)
        end
    end
end

function ResetFinish()
    if DoesBlipExist(finishBlip) then
        RemoveBlip(finishBlip)
    end

    finishMarker = nil
end

function ResetDuty()
	LeavePedInVehicle()
	DeleteBus()
    ResetFinish()
	ResetFinal()
	pedDuty = false
	
end

function CheckDuty()
    return pedDuty
end

-- TODO: Useful functions...
function ShowPedHelpDialog(text)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, 0, 1, -1)
end

function chatMsg(msg)
    TriggerEvent('chat:addMessage', {
        color = { 255, 0, 0},
        multiline = true,
        args = {"DEV: ", msg}
      })
end

function RandomPedHash()
    local randomPed = Config.PedList[math.random(1, #Config.PedList)]
    local hashPed = GetHashKey(randomPed)
    Citizen.CreateThread(function()
        RequestModel(hashPed)
        while ( not HasModelLoaded(hashPed) ) do
            Citizen.Wait( 1 )
        end
    end)

    return hashPed
end

function CreatePedForVehicle(vehicle, hash, seat)
    local npc = nil

    RequestModel(hash)

    while not HasModelLoaded(hash) do
        Citizen.Wait(5)
    end

    npc = CreatePedInsideVehicle(vehicle, 5, hash, seat, true, true)
    SetPedAlertness(npc, 0)
    SetPedAsCop(npc, false)
    SetPedAsEnemy(npc, false)
    SetPedCombatMovement(npc, 0)
    SetPedCombatAbility(npc, 0)
    SetPedCombatRange(npc, 0)
    SetPedFleeAttributes(npc, 0, 0)
    SetPedSeeingRange(npc, 0.0)
    SetPedHearingRange(npc, 0.0)
    SetPedCombatAbility(npc, 0)
    SetPedCombatAttributes(npc, 0, 0)
    SetPedCombatAttributes(npc, 1, 0)
    SetPedCombatAttributes(npc, 2, 0)
    SetPedCombatAttributes(npc, 3, 1)
    SetPedCombatAttributes(npc, 5, 0)
    SetPedCombatAttributes(npc, 20, 0)
    SetPedCombatAttributes(npc, 46, 0)
    SetPedCombatAttributes(npc, 52, 0)
    SetPedCombatAttributes(npc, 292, 0)
    SetCanAttackFriendly(npc, 0, 0)


    return npc
end

function JobSetUniform()
	TriggerEvent('skinchanger:getSkin', function(skin)
		if skin.sex == 0 then
			if Config.JobUniforms.male ~= nil then
				TriggerEvent('skinchanger:loadClothes', skin, Config.JobUniforms.male)
			else
				ESX.ShowNotification(_U('no_outfit'))
			end
		else
			if Config.JobUniforms.female ~= nil then
				TriggerEvent('skinchanger:loadClothes', skin, Config.JobUniforms.female)
			else
				ESX.ShowNotification(_U('no_outfit'))
			end
		end
	end)
end

function ResetSkin()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        TriggerEvent('skinchanger:loadSkin', skin)
    end)
end

function IsPedInSpawnBus()
	return (GetVehiclePedIsIn(PlayerPedId(), false) == busVehicle)
end

function IsPedInBus()
    return (GetVehiclePedIsIn(PlayerPedId(), false) ~= 0)
end