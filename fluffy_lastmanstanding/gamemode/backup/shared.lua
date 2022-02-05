DeriveGamemode("fluffy_mg_base")
GM.Name = "Last Man Standing"
GM.Author = "Captain SemiColon"
GM.HelpText = [[
    Try not to fall to your demise!
    Use the weapons you are given to try to knock other players off their podiums
    
    Be the last player alive to win the round!
]]

GM.TeamBased = false -- Is the gamemode FFA or Teams?
GM.Elimination = true
GM.WinBySurvival = true
GM.ThirdpersonEnabled = false

GM.RoundNumber = 8
GM.RoundTime = 500
GM.RoundType = "timed"
GM.GameTime = (GM.RoundNumber * GM.RoundTime) + 100
GM.HUDStyle = HUD_STYLE_CLOCK_ALIVE

GM.SafeTime = 3

ReEquipTime = 11
StripPlayerTime = 10
function GM:Initialize()
end


Weapons = {}
-- STANDARD WEAPONS

Weapons[1] = { weapon_name = "weapon_pistol", ammo_type = "Pistol", ammo_count = 5, nice_name = "Pistol" }
Weapons[2] = { weapon_name = "weapon_smg1", ammo_type = "SMG1", ammo_count = 20, nice_name = "Submachine Gun - Standard" }
--Weapons[3] = { weapon_name = "weapon_frag", ammo_type = "Grenade", ammo_count = 1 , nice_name = "Grenade" } --Grenade is pretty impossible
Weapons[4] = { weapon_name = "weapon_crossbow", ammo_type = "XBowBolt", ammo_count = 1 , nice_name = "Crossbow" }
Weapons[5] = { weapon_name = "weapon_rpg", ammo_type = "RPG_Round", ammo_count = 1 , nice_name = "RPG" }
Weapons[6] = { weapon_name = "weapon_357", ammo_type = "357", ammo_count = 1 , nice_name = "Revolver" }
Weapons[7] = { weapon_name = "weapon_shotgun", ammo_type = "Buckshot", ammo_count = 2 , nice_name = "Shotgun" }
Weapons[8] = { weapon_name = "weapon_ar2", ammo_type = "AR2", ammo_count = 10 , nice_name = "AR2 - Standard Fire" }

-- ALT FIRE WEAPONS
Weapons[9] = { weapon_name = "weapon_ar2", ammo_type = "AR2AltFire", ammo_count = 1 , nice_name = "AR2 - Alt Fire (Plasma Ball)" }
Weapons[10] = { weapon_name = "weapon_smg1", ammo_type = "SMG1_Grenade", ammo_count = 1, nice_name = "Submachine Gun - Alt Fire (Grenade)" }

--Prop Based Weapons
Weapons[11] = { weapon_name = "lms_chair", ammo_type = "none", ammo_count = 0 , nice_name = "Chair Throwing Pistol" }
Weapons[12] = { weapon_name = "lms_melon", ammo_type = "none", ammo_count = 0 , nice_name = "Melon Launcher" }
Weapons[13] = { weapon_name = "lms_crowbar", ammo_type = "none", ammo_count = 0 , nice_name = "Crowbar Launcher" }
Weapons[14] = { weapon_name = "lms_small_prop", ammo_type = "none", ammo_count = 0 , nice_name = "Random Small Props Launcher" }
Weapons[15] = { weapon_name = "lms_large_prop", ammo_type = "none", ammo_count = 0 , nice_name = "Random Big Props Launcher" }


LastWeapon = false


