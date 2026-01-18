_G.FishItConfig = _G.FishItConfig or {
    ["Fishing"] = {
        ["Auto Perfect"] = false,
        ["Random Result"] = false,

        ["Auto Favorite"] = true,
        ["Auto Unfavorite"] = false,
        ["Fish Name"] = {
            "Sacred Guardian Squid", 
            "Runic Sea Crustacean", 
            "Sea Crustacean", 
            "Flatheaded Whale Shark", 
            "Fossillized Shark", 
            "Primordial Octopus", 
            "Cavern Dweller", 
            "Runic Squid", 
            "Ancient Squid",
            {Name = "Ruby", Variant = "Gemstone"},
            {Variant = "Leviathan's Rage"}, -- SUDAH DIPERBAIKI: Format dirapikan
            -- {Variant = "Leviathan's Rage"}, -- Variant Only
            -- {Tier = "Secret", Variant = "Leviathan's Rage"},  -- Tier + Variant
        },

        ["Auto Accept Trade"] = true,
        ["Auto Friend Request"] = true,
    },
    ["Auto Trade"] = {
        ["Enabled"] = true,
        ["Whitelist Username"] = {"dvn_store"},
        ["Category Fish"] = {
            "Secret", 
            "Mythic",
            -- {Tier = "Mythic", Variant = "Stone"}, -- Tier + Variant
        },
        ["Fish Name"] = {
            "Sacred Guardian Squid",
            {Name = "Ruby", Variant = "Gemstone"},
            {Variant = "Leviathan's Rage"},
            -- {Variant = "Leviathan's Rage"}, -- Variant Only
        },
        ["Item Name"] = {
            "Evolved Enchant Stone",
        },
    },
    ["Farm Coin Only"] = {
        ["Enabled"] = false, -- Farm coins only [ cant buy rod, bait, enchant, weather ]
        ["Target"] = 190000,
    },
    ["Selling"] = {
        ["Auto Sell"] = true,
        ["Auto Sell Threshold"] = "Mythic",
        ["Auto Sell Every"] = 100,
    },
    ["Doing Quest"] = {
        ["Auto Ghostfinn Rod"] = true,
        ["Auto Element Rod"] = false,
        ["Unlock Ancient Ruin"] = true,
        ["Allowed Sacrifice"] = {
            "Ghost Shark",
            "Cryoshade Glider",
            "Panther Eel",
            "Queen Crab",
            "King Crab",
            "Giant Squid",
            "Blob Shark",
            "Ghost Shark",
        },
        ["FARM_LOC_SECRET_SACRIFICE"] = "Ocean",

        ["Minimum Rod"] = "Astral Rod",
    },
    ["WebHook"] = {
        ["Link Webhook"] = "https://discord.com/api/webhooks/1422865888390021262/76qvUPwZ_nUQedBr_q42jm_7y9ddmU34ozVE2r0W4derVkPWMTJ47bvzZvxT1bZmCb_h",
        ["Auto Sending"] = true,
        ["Category"] = {"Secret"},

        ["Link Webhook Quest Complete"] = "https://discord.com/api/webhooks/1422865888390021262/76qvUPwZ_nUQedBr_q42jm_7y9ddmU34ozVE2r0W4derVkPWMTJ47bvzZvxT1bZmCb_h",
    },
    ["Weather"] = {
        ["Auto Buying"] = false,
        ["Minimum Rod"] = "Astral Rod",
        ["Weather List"] = {
            "Wind",
        },
    },
    ["Potions"] = {
        ["Auto Use"] = false,
        ["Minimum Rod"] = "Astral Rod",
    },
    ["Totems"] = {
        ["Auto Use"] = false,
        ["Minimum Rod"] = "Ghostfinn Rod",
        ["Buy List"] = {
            ["Luck Totem"] = 5,
            "Mutation Totem",
            "Shiny Totem",
        },
    },
    ["Event"] = {
        ["Start Farm"] = true,
        ["Minimum Rod"] = "Element Rod",
        ["Event List"] = {
            "Megalodon Hunt",
            "Ghost Shark Hunt",
            "Shark Hunt",
            -- ["Ancient Lochness Monster"] = true,
        },
    },
    ["Enchant"] = {
        ["Auto Enchant"] = true,
        ["Roll Enchant"] = false,
        ["Evolved Roll Enchant"] = true,
        ["Enchant List"] = {
            "SECRET Hunter",
        },
        ["Second Enchant"] = false,
        ["Allowed Sacrifice"] = {
            "Frostborn Shark",
            "Cryoshade Glider",
        },
        ["Second Enchant List"] = {
            "Reeler I",
            "Prismatic I",
            "Mutation Hunter II",
        },
        ["Minimum Rod"] = "Ghostfinn Rod",
    },
    ["Bait List"] = {
        ["Auto Buying"] = true,
        ["Buy List"] = {
            "Midnight Bait",
            "Chroma Bait",
            "Corrupt Bait",
            "Aether Bait",
        },
        ["Endgame"] = "",
    },
    ["Rod List"] = {
        ["Auto Buying"] = true,
        ["Buy List"] = {
            "Grass Rod",
            "Midnight Rod",
            "Astral Rod",
            "Ares Rod",
            "Angler Rod",
        },
         ["Location Rods"] = {
            ["Fisherman Island"] = {"Starter Rod"},
            ["Kohana Volcano"] = {"Grass Rod", "Midnight Rod"},
            ["Tropical Grove"] = {"Astral Rod"},
            ["Ancient Ruin"] = {"Ghostfin Rod", "Angler Rod", "Ares Rod"},
            ["Kohana"] = {"Element Rod"},
        },
        ["Endgame"] = "",
    },

    ["ExtremeFpsBoost"] = true,
    ["UltimatePerformance"] = true,
    ["Disable3DRender"] = true,
    ["AutoRemovePlayer"] = true,

    ["AutoReconnect"] = false,
    ["HideGUI"] = false,
    ["EXIT_MAP_IF_DISCONNECT"] = false,
}