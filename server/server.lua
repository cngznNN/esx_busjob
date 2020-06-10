ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('esx:busjob_confirmPay')
AddEventHandler('esx:busjob_confirmPay', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    local identifier = xPlayer.getIdentifier()
	MySQL.Async.fetchAll('select * from users where identifier = @identifier', {['@identifier'] = identifier}, function(result)
		local busLevel = result[1].busLevel
        local pay = Config.Price
		if busLevel >= 25 and busLevel < 75 then
			pay = pay + 2500
		elseif busLevel >= 75 and busLevel < 150 then
			pay = pay + 5000
		elseif busLevel >= 150 then
			pay = pay + 7500
		end
		
		xPlayer.addMoney(pay)
		
		if busLevel < 150 then
			MySQL.Sync.execute('update users set busLevel = @busLevel where identifier = @identifier', {['@identifier'] = identifier, ['@busLevel'] = busLevel + 1})
        end
        
        TriggerClientEvent('chatMessage', xPlayer.source, _U('completejob'))
		
		busLevel = busLevel + 1
		if busLevel >= 0 and busLevel < 25 then			
			TriggerClientEvent('chatMessage', xPlayer.source, "", {255, 255, 255}, _U('job_level_msg', 25 - busLevel))
		elseif busLevel >= 25 and busLevel < 75 then
			TriggerClientEvent('chatMessage', xPlayer.source, "", {255, 255, 255}, _U('job_level_msg', 75 - busLevel))
		elseif busLevel >= 75 and busLevel < 150 then
			TriggerClientEvent('chatMessage', xPlayer.source, "", {255, 255, 255}, _U('job_level_msg', 150 - busLevel))
		end
	end)
end)