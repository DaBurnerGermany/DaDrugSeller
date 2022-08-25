Config                            = {}

Config.SellDistanceToNPC = 6.0

Config.Locale = 'en' -- your language, It would be nice if you send me your translation on fivem forum

Config.TimeToSell = 15 -- how many seconds player have to wait/stand near ped
Config.TimeToResell = 600 -- how many seconds player have to wait untill he can resell to same npc

Config.BlipTime = 25
Config.BlipSprite = 10
Config.BlipColor = 1
Config.CoreDispatchCallNr = "20-99"
Config.MoneyType = "black_money"

Config.MaxSellPerDeal = 5


Config.CopsRequiredToSell = 0
Config.NotifyCops = true
Config.NotifyCopsPercent = 100

Config.SellerRejectPercent = 35 -- auch wirkliche prozente
Config.PlayAnimation = true 

Config.HotKeyToSell = "E"



Config.DisabledJobs = {
	["police"] = true
	,["ambulance"] = true
}

Config.notifications = {
    DefaultFiveM = true
    ,BtwLouis = false
    ,Custom = false
}
Config.progressBars = {
    TigerScripts = false
    ,MyScripts = false
    ,Custom = false
}

Config.Dispatch = {
	core_dispatch = false
	,CodeSignDispatch = false
	,Default = false
	,Custom = false
}





Config.DrugDefinition={
	{
		name = 'joint'
		, label = "Joint(s)"
		, priceMin = 50
		, priceMax = 125
	}
	,{
		name = 'weed_package'
		, label = "Weed Package(s)"
		, priceMin = 50
		, priceMax = 125
	}
}


Config.NPCs = { 
	{
		model = 'a_m_y_business_03', 
		x = 990.66,   
		y = -2243.36, 
		z = 29.51, 
		heading = 264.35
	}
}



Translations = {
	["de"] = {
		['input'] = 'Drücke [E] um Drogen anzubieten.',
		['sell'] = 'Verkaufen..',
		['resell_cooldown'] = 'Du musst noch etwas warten..',
		['reject'] = 'Die Person lehnt das Angebot ab!',
		['reject_called_cops'] = 'Die Person hat die Cops gerufen! Lauf!',
		['dispatch_header'] = 'Drogenverkauf',
		['dispatch_text'] = 'Ein Bürger wurde beobachtet wie er Drogen verkauft hat!',
		['server_error'] = 'Server - Etwas ist schief gelaufen :(',
		['config_error'] = 'Server - Config fehlt :(',
		['you_have_sold'] = 'Sie verkaufen:  ',
		['no_more_drugs'] = 'Sie haben keine Drogen mehr!',
		['for'] = ' für ',
		['toless_cops_in_duty'] = 'Zu wenig Polizisten im Dienst um Drogen zu verkaufen!',
	}
	,["en"] = {
		['input'] = 'Press [E] to offer drugs.',
		['sell'] = 'Sell..',
		['resell_cooldown'] = 'You will have to wait a little longer...',
		['reject'] = 'The person rejects the offer!',
		['reject_called_cops'] = 'The person called the cops! Run!',
		['dispatch_header'] = 'Drug sale',
		['dispatch_text'] = 'A citizen was observed selling drugs!',
		['server_error'] = 'Server - Something went wrong :(',
		['config_error'] = 'Server - Config missing :(',
		['you_have_sold'] = 'You sold: ',
		['no_more_drugs'] = 'You have no more drugs!',
		['for'] = ' for ',
		['toless_cops_in_duty'] = 'Too few cops on duty to sell drugs!',
	}
}