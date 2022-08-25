ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)



RegisterNetEvent("DaDrugSeller:notifyCops")
AddEventHandler("DaDrugSeller:notifyCops", function(spot)

	local xPlayers = ESX.GetPlayers()

	for i=1, #xPlayers, 1 do
		local xForPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xForPlayer.job.name == "police" then
			TriggerClientEvent("DaDrugSeller:AddDispatch", xPlayers[i], spot.x, spot.y, spot.z)
		end
	end
end)



ESX.RegisterServerCallback('DaDrugSeller:checkForExecute', function(source, cb)
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    local retval = false

	local selectedItem = nil

	local ErrorMessage = ""


	local cops = 0
	local xPlayers = ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
 		local xPlayerTemp = ESX.GetPlayerFromId(xPlayers[i])
 		if xPlayerTemp.job.name == 'police' then
			cops = cops + 1
		end
	end

	
	local DrugsAvailable = {}

	if cops >= Config.CopsRequiredToSell then 

		if xPlayer ~= nil then 
			if #Config.DrugDefinition > 0 then
				for i=1, #Config.DrugDefinition do
					if xPlayer.getInventoryItem(Config.DrugDefinition[i].name).count > 0 then
						table.insert(DrugsAvailable, Config.DrugDefinition[i]) 
						retval = true
					end
				end
			else
				ErrorMessage = "config_error"
			end
		else
			ErrorMessage = "server_error"
		end 
	else
		ErrorMessage = "toless_cops_in_duty"
	end 

    cb(retval, DrugsAvailable, ErrorMessage)
end)




RegisterNetEvent("DaDrugSeller:notifyCops")
AddEventHandler("DaDrugSeller:notifyCops", function(x,y,z)

	local xPlayers = ESX.GetPlayers()

	for i=1, #xPlayers, 1 do
		local xForPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xForPlayer.job.name == "police" then
			TriggerClientEvent("DaDrugSeller:AddDispatch", xPlayers[i], x, y, z)
		end
	end
end)
RegisterNetEvent("DaDrugSeller:sellDrugs")
AddEventHandler("DaDrugSeller:sellDrugs", function(amount, item)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	assert(xPlayer ~= nil, "xPlayer could not be found")


	local amountInInv = xPlayer.getInventoryItem(item.name).count
	local sellingsprice = math.random (item.priceMin, item.priceMax)

	local amountToSell = amount

	if amountInInv < amountToSell then
		amountToSell = amountInInv
	end 

	for i=1, #Config.DrugDefinition do
		local moneyGot = sellingsprice * amountToSell
		xPlayer.removeInventoryItem(item.name, amountToSell)
		xPlayer.addAccountMoney(Config.MoneyType, moneyGot)
		TriggerClientEvent('DaDrugSeller:notify', _source, Translations[Config.Locale].you_have_sold .. ' '..amountToSell..' ' .. item.label .. Translations[Config.Locale]["for"] .. moneyGot .. '$')
	end
end)