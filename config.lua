Config = {}

Config.UseOkokTextUI = true -- true = okokTextUI (I recommend you using this since it is way more optimized than the default ShowHelpNotification) | false = ShowHelpNotification

Config.Key = 38 -- [E] Key to open the interaction, check here the keys ID: https://docs.fivem.net/docs/game-references/controls/#controls

Config.HideMinimap = true -- If true it'll hide the minimap when the Crafting menu is opened

Config.ShowBlips = false -- If true it'll show the crafting blips on the map

Config.ShowFloorBlips = true -- If true it'll show the crafting markers on the floor

Config.Crafting = {
	{
		coordinates = vector3(-809.4, 190.3, 72.5), -- coordinates of the table
		radius = 1, -- radius of the table
		maxCraftRadius = 5, -- if you are further it will stop the craft
		showBlipRadius = 50,
		blip = {blipId = 89, blipColor = 3, blipScale = 0.9, blipText = "Crafting"}, -- to get blips and colors check this: https://wiki.gtanet.work/index.php?title=Blips
		tableName = 'General', -- Title
		tableID = 'general1', -- make a different one for every table with NO spaces
		crafts = { -- What items are available for crafting and the recipe
			{
				item = 'WEAPON_ASSAULTRIFLE', -- Item id and name of the image
				amount = 1,
				successCraftPercentage = 75, -- Percentage of successful craft 0 = 0% | 50 = 50% | 100 = 100%
				isItem = false, -- if true = is item | if false = is weapon
				time = 6, -- Time to craft (in seconds)
				recipe = { -- Recipe to craft it
					{'w2_WEAPON_ASSAULTRIFLE', 1, false}, -- item/amount/if the item should be removed when crafting
					{'gunbarrel', 1, true},
					{'weaponstock', 1, true},
					{'trigger', 1, true},
					{'grip', 1, true},
					{'gunframe', 1, true},
					{'metalspring', 2, true},
				},
				job = { -- What jobs can craft this item in this workbench
					'police'
				},
			},
			{
				item = 'jewels', -- Item id and name of the image
				amount = 3,
				successCraftPercentage = 75, -- Percentage of successful craft 0 = 0% | 50 = 50% | 100 = 100%
				isItem = true, -- if true = is item | if false = is weapon
				time = 5, -- Time to craft (in seconds)
				recipe = { -- Recipe to craft it
					{'gold', 12, true}, -- item/amount/if the item should be removed when crafting
					{'diamond', 6, true},
				},
				job = { -- What jobs can craft this item in this workbench
					''
				},
			},
		},
	},
}

-------------------------- DISCORD LOGS

-- To set your Discord Webhook URL go to server.lua, line 3

Config.BotName = 'ServerName' -- Write the desired bot name

Config.ServerName = 'ServerName' -- Write your server's name

Config.IconURL = '' -- Insert your desired image link

Config.DateFormat = '%d/%m/%Y [%X]' -- To change the date format check this website - https://www.lua.org/pil/22.1.html

-- To change a webhook color you need to set the decimal value of a color, you can use this website to do that - https://www.mathsisfun.com/hexadecimal-decimal-colors.html

Config.StartCraftWebhookColor = '16127'

Config.ConcludeCraftWebhookColor = '65352'

Config.AnticheatProtectionWebhookColor = '16776960'

Config.FailWebhookColor = '16711680'