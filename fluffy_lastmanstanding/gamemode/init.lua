AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


local TimeWhenNeedToReEquipPlayer = 0
local TimeWhenNeedToStripPlayer = 0

--Give them the next weapon when we can
function ReEquipPlayer()
	WeaponData = GetNextWeapon()
	local msg = '???'
	if WeaponData.ammo_type ~= "none" then
		msg =  WeaponData.nice_name.." with "..WeaponData.ammo_count.." bullets"
	else
		msg = WeaponData.nice_name
	end
	GAMEMODE:CountdownAnnouncement(5, msg, "top", "ambient/alarms/klaxon1.wav", "ambient/alarms/warningbell1.wav")
	TimeWhenNeedToReEquipPlayer = math.Round(CurTime() + ReEquipTime + 5, 0);
	TimeWhenNeedToStripPlayer = math.Round(CurTime() + StripPlayerTime + 5, 0);
	timer.Simple(5, function()
		for k, v in pairs(player.GetAll()) do
		if  v:Alive() then
				--Give them their crosshair back
				v:CrosshairEnable()
				if(WeaponData.ammo_type ~= 'none') then
					v:Give(WeaponData.weapon_name, true)
					--Remove the default amount of ammo and give them what they need
					v:GiveAmmo(WeaponData.ammo_count, WeaponData.ammo_type)
				else 
					v:Give(WeaponData.weapon_name, false)
				end
			end
		end
	end)
end

function StripPlayer()
	for k, v in pairs(player.GetAll()) do
		if  v:Alive() then
			v:CrosshairDisable()
			--v:DropWeapon()
			v:StripWeapons()
		end
	end
end

function GetNextWeapon()
	print("Getting next weapon")
	--We want to randomise the weapons the playerrs will get so lets do it here
	local NextWeapon = table.Random(Weapons)
	-- A sanity check to ensure we dont get an infinite loop
	local count = 0
	--Dont get the same weapon 2 in a row (or more as I was getting with RPG)
	while NextWeapon.weapon_name == LastWeapon do
		--Try again
		print("Retrying get next weapon")
		NextWeapon = table.Random(Weapons)
		if count > 3 then
			print("INF LOOP DETECTED. Getting last Next Weapon")
			return NextWeapon
		end
		count = count + 1
	end
	LastWeapon = NextWeapon.weapon_name
	return NextWeapon
end

-- Credit damage to players for Kills due to gravity and the
hook.Add("EntityTakeDamage", "CreditPitfallKills", function(ply, dmginfo)
    if not ply:IsPlayer() then return end

    if dmginfo:GetAttacker():GetClass() == "trigger_hurt" and ply.LastKnockback and (CurTime() - ply.KnockbackTime) < 5 then
        local attacker = ply.LastKnockback
        dmginfo:SetAttacker(attacker)
    end
end)

-- Handle player death
-- Tracking kills is difficult
function GM:DoPlayerDeath(ply, attacker, dmginfo)
    -- Always make the ragdoll
    ply:CreateRagdoll()
    -- Do not count deaths unless in round
    if not GAMEMODE:InRound() then return end
    ply:AddDeaths(1)
    GAMEMODE:AddStatPoints(ply, "Deaths", 1)

    -- Award an point to the attacker (if there is one)
    if IsValid(attacker) and attacker:IsPlayer() then
        attacker:AddFrags(1)
        attacker:AddStatPoints("Kills", 1)
    end
end

-- We need to give the player a random weapon
hook.Add("PreRoundStart", "PreRoundStart", function()
   --Set the time when we need guns to NOW so when the round does start we all get guns
	TimeWhenNeedToReEquipPlayer = CurTime();
  
end)
--Awful. This should be removed
function PlayerPlaySound(sound)
	for k, v in pairs(player.GetAll()) do
		v:ConCommand("play "..sound)
	end
end

--Not strictly a round handle but it is handled during a round
function roundHandle()
	-- If we are not in a round then dont worry too much
 	if not GAMEMODE:InRound() then return end
 	if TimeWhenNeedToReEquipPlayer > 0 and CurTime() > TimeWhenNeedToReEquipPlayer then
 		print("Round Handle ReEquip Called")
	 	ReEquipPlayer()
 	end

 	if TimeWhenNeedToStripPlayer > 0 and CurTime() > TimeWhenNeedToStripPlayer then
 		PlayerPlaySound("plats/elevbell1.wav")
 		TimeWhenNeedToStripPlayer = 0 
 		print("Round Handle Strip Called")
 		StripPlayer()
 		CountDownBeingShown = false
 	end
 	--If we get here then we are doomed
 	if TimeWhenNeedToReEquipPlayer-CurTime() < -5 then
 		print("Impassed reached. Invalid times for next round. Aborting and starting clock again")
 		TimeWhenNeedToReEquipPlayer = CurTime() + 10;
 		TimeWhenNeedToStripPlayer = 0 
 		CountDownBeingShown = false
 	end

end

timer.Create("roundHandle", 1, 0, roundHandle)

hook.Add("PlayerSpawn", "SetSpeeds", function(ply)
	ply:SetWalkSpeed(0.01) --if set to 0 people can move full speed
    ply:SetRunSpeed(0.01)
    ply:SetJumpPower(200)
    ply:StripWeapons()
    ply:CrosshairDisable()
end)

hook.Add("PreRoundStart", "PreRoundStart", function()
	TimeWhenNeedToReEquipPlayer = math.Round( CurTime() + 5, 0);
	TimeWhenNeedToStripPlayer = 0 

	local round = GAMEMODE:GetRoundNumber()

    -- End the game if enough rounds have been played
    if round > GAMEMODE.RoundNumber then
        GAMEMODE:EndGame()
        return
    end

end)


function GM:HandlePlayerDeath(ply, attacker, dmginfo)
    if attacker == ply then return end -- Suicides aren't important
    if IsEntity(attacker) then 
    	print( attacker:GetOwner():Nick().. ' killed '..ply:Nick())
        attacker:GetOwner():AddFrags(1)
    else
    	print(ply:Nick().. ' was killed mysteriously')
    end
end 