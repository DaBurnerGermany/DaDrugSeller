local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  }
  


ESX  = nil

local isInStampSpot = false
local currentSpot = nil
local playerJob = nil 
local requestedModels = {}
local npcsSpawned = {}

local availableNPCs = Config.NPCs
local isSelling = false
local DrugsAvailable = {}


local messageSent = false
local isInSpot = false
local currentSpot = nil
local currentSpotIndex = nil



local selling = false
local secondsRemaining
local sold = false
local playerHasDrugs = false
local pedIsTryingToSellDrugs = false

local Selled_CallPolice=false
local Rejected_CallPolice=false


Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	
	while ESX.GetPlayerData().job == nil do
        Citizen.Wait(100)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

Citizen.CreateThread(function()
	while true do
		if playerJob == nil and ESX ~= nil and ESX.PlayerData ~= nil and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name ~= nil and ESX.PlayerData.job.name ~= playerJob then
			playerJob = ESX.PlayerData.job.name
		end
		Citizen.Wait(1000)
	end
end)


RegisterNetEvent('DaDrugSeller:AddDispatch')
AddEventHandler('DaDrugSeller:AddDispatch', function(x,y,z)
	addDispatch(x,y,z)
end)



function addDispatch(x, y, z)
	if Config.Dispatch.Default then

		TriggerEvent("DaDrugSeller:notify", Translations[Config.Locale].dispatch_text)

		local transT = 250
		local Blip = AddBlipForCoord(x, y, z)
		SetBlipSprite(Blip,  Config.BlipSprite)
		SetBlipColour(Blip,  Config.BlipColor)
		SetBlipAlpha(Blip,  transT)
		SetBlipAsShortRange(Blip,  false)
		while transT ~= 0 do
			Wait(Config.BlipTime * 1000)
			transT = transT - 1
			SetBlipAlpha(Blip,  transT)
			if transT == 0 then
				SetBlipSprite(Blip,  2)
				return
			end
		end
	elseif Config.Dispatch.core_dispatch then 
		exports['core_dispatch']:addCall(Config.CoreDispatchCallNr, Translations[Config.Locale].dispatch_header, {{icon=fontawsomeicon, info=Translations[Config.Locale].dispatch_text }}, {x, y, z}, 'police', Config.BlipTime, Config.BlipSprite, Config.BlipColor )
	elseif Config.Dispatch.CodeSignDispatch then
		
	elseif Config.Display.Custom then 
		--here your code
	end 
end 




--[[
	place NPCs on StartUp!
]]--
Citizen.CreateThread(function()
	for key, values in pairs(availableNPCs) do

		local model = GetHashKey(values.model)

		if requestedModels[model] == nil then
			RequestModel(model)
			while not HasModelLoaded(model) do
				Wait(1)
			end
			requestedModels[model] = true
		end

		local npc = CreatePed(4, model, values.x, values.y, values.z, values.heading, false, true)
		table.insert(npcsSpawned, npc)		
		SetEntityHeading(npc, values.heading)
		FreezeEntityPosition(npc, true)
		SetEntityInvincible(npc, true)
		SetBlockingOfNonTemporaryEvents(npc, true)
		
	end
end)


RegisterNetEvent("DaDrugSeller:startSell")
AddEventHandler("DaDrugSeller:startSell",function()
	if isSelling == false then 

		print("cooldown = " .. tostring(availableNPCs[currentSpotIndex].cooldowntime))
		if availableNPCs[currentSpotIndex].cooldowntime == nil or availableNPCs[currentSpotIndex].cooldowntime == 0 then
			ESX.TriggerServerCallback('DaDrugSeller:checkForExecute', function(success, drugsininv, errormsg)
				if success then 
					StartDrugSell(drugsininv)
				else 
					if errormsg ~= "" then 
						TriggerEvent("DaDrugSeller:notify", Translations[Config.Locale][errormsg])
					else
						TriggerEvent("DaDrugSeller:notify", Translations[Config.Locale].no_more_drugs)
					end 
				end 
			end)			
		else
			TriggerEvent("DaDrugSeller:notify", Translations[Config.Locale].resell_cooldown)
		end 
	end  

	
end)


function StartDrugSell(drugsininv)

	print(tostring(drugsininv))

	local notifyCopsPercentage = math.random(1, 100)
	local NPCReject = math.random(1, 100)

	local doNotifyCops = false

	if Config.NotifyCops and notifyCopsPercentage <= Config.NotifyCopsPercent then
		doNotifyCops = true
	end 

	if doNotifyCops then 
		TriggerServerEvent("DaDrugSeller:notifyCops" , availableNPCs[currentSpotIndex])
	end 


	if NPCReject <= Config.SellerRejectPercent then
		if doNotifyCops then 
			TriggerEvent("DaDrugSeller:notify", Translations[Config.Locale].reject_called_cops)
		else
			TriggerEvent("DaDrugSeller:notify", Translations[Config.Locale].resell_cooldown)
		end 
	else 
		local ped = GetPlayerPed(-1)
		FreezeEntityPosition(ped,true)
	
		if Config.PlayAnimation then
			RequestAnimDict("amb@prop_human_bum_bin@idle_b")
			while (not HasAnimDictLoaded("amb@prop_human_bum_bin@idle_b")) do 
				Citizen.Wait(0) 
			end
			TaskPlayAnim(ped,"amb@prop_human_bum_bin@idle_b","idle_d",100.0, 200.0, 0.3, 120, 0.2, 0, 0, 0)
		end
	
		showProgressBar(Config.TimeToSell * 1000, Translations[Config.Locale].sell)
		Citizen.Wait(Config.TimeToSell * 1000)
	
		ClearPedTasksImmediately(PlayerPedId())
		FreezeEntityPosition(ped,false)		


		local amount = math.random(1,Config.MaxSellPerDeal)
		local drugToSellRandom = math.random(1, #drugsininv)

		local item = drugsininv[drugToSellRandom]

		TriggerServerEvent("DaDrugSeller:sellDrugs", amount, item)
	end

	isSelling = false
	availableNPCs[currentSpotIndex].cooldowntime = Config.TimeToResell
end 


-- show notification
Citizen.CreateThread(function()  
	while true do
		Citizen.Wait(350)
  
		isInSpot = false

		local ped = PlayerPedId()
		local playerCoords = GetEntityCoords(ped)


		if IsPedInAnyVehicle(GetPlayerPed(-1)) == false then
			if DoesEntityExist(ped)then
				if IsPedDeadOrDying(ped) == false then
					for key, spot in pairs(availableNPCs) do
						local distance = Vdist(playerCoords, spot.x, spot.y, spot.z)
			
						if distance <=  Config.SellDistanceToNPC then
							isInSpot = true
							currentSpot = availableNPCs[key]
							currentSpotIndex = key
			
							if not messageSent then
								messageSent = true
								TriggerEvent("DaDrugSeller:notify", Translations[Config.Locale].input)
							end
						
						end 
					end
				end
			end
		end


		

		if not isInSpot then
		  messageSent = false
		  currentSpot = nil
		end
	  end 
  end)


  
Citizen.CreateThread(function()

	while true do
		Citizen.Wait(1)
  
		if currentSpot then
		  local player = PlayerPedId()
			if not IsPedInAnyVehicle(player) then
			  if IsControlJustPressed(0, Keys[Config.HotKeyToSell]) then
				TriggerEvent("DaDrugSeller:startSell")


				
			  end 
			end
		end
		
	end
  
end)




RegisterNetEvent("DaDrugSeller:notify")
AddEventHandler("DaDrugSeller:notify", function(text)
	ShowNotification(text)
end)


function ShowNotification(notificationtext)
	if Config.notifications.BtwLouis then
		TriggerEvent('notifications', '#07b95e', '', notificationtext)
	elseif Config.notifications.DefaultFiveM then
		SetNotificationTextEntry('STRING')
		AddTextComponentString(notificationtext)
		return DrawNotification(false, true)
	elseif Config.notifications.Custom then
		--here your custom code...
	end
end


function showProgressBar(duration, text)
	if Config.progressBars.TigerScripts then
		exports['progressBars']:startUI(duration, text)
	elseif Config.progressBars.MyScripts then
		exports['pogressBar']:drawBar(duration, text)
	elseif Config.progressBars.Custom then
		--here your custom code...
	end 
end 





--[[
	cooldowntime --
]]--
Citizen.CreateThread(function()
	while true do
        Citizen.Wait(1000)
		
		for key,value in pairs(availableNPCs) do
			if value.cooldowntime == nil then
				value.cooldowntime = 0
			end 
			
			if value.cooldowntime > 0 then
				value.cooldowntime = v.cooldowntime - 1
			end 
		end 
	end
end)



--[[
	remove NPCs on RessourceStop!
]]--
AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  --print("not  "..tostring(resourceName))
	  return
	end
	
	for key, npc in pairs(npcsSpawned) do
		DeletePed(npc)
	end
	
	print('The resource ' .. resourceName .. ' was stopped.')
  end)