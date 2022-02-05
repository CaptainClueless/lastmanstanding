--TODO : HIDE PLAYER NAMES WHEN LOOKING AT OTHERS
--TODO : REMOVE CROSS HAIR COMPLETELY WHEN UNARMED
--TODO : AT THE END OF EACH ROUND SAY HOW MANY PLAYERS DIED THAT LAST ROUND
--TODO : STATE HOW MANY PLAYERS ARE LEFT SOMEWHERE
--TODO : ADD SOUNDS TO INDICATE ROUND IS ABOUT TO BEGIN
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "shared.lua" )

include( 'shared.lua' )

local WeaponData = false
util.AddNetworkString( "PLAYERACTION" )
util.AddNetworkString( "NEXTROUNDWEAPONS" )

function GM:OnPreRoundStart( num )
	if gameHasActuallyFinished then
		return -- Do nothing
	end
	
	--Get our next rounds weapons
	WeaponData = GetNextWeapon()
	--Not really required
	UTIL_StripAllPlayers()
	local roundNum = GetGlobalInt( "RoundNumber" );
	if roundNum < 2 then 
		game.CleanUpMap()
		UTIL_SpawnAllPlayers()
	end
	if GAMEMODE.RoundPreStartTime == 5 then
		--Chime down
		timer.Simple(1, function() 
			if WeaponData.ammo_type ~= "none" then
				BroadcastNextRoundWeapon("Next Round is "..WeaponData.nice_name.." with "..WeaponData.ammo_count.." bullets")
			else
				BroadcastNextRoundWeapon("Next Round is "..WeaponData.nice_name)
			end
		end )

		timer.Simple(1, function()  PlayerPlaySound("ambient/alarms/warningbell1.wav")  end )
		timer.Simple(2, function()  PlayerPlaySound("ambient/alarms/warningbell1.wav")  end )
		timer.Simple(3, function()  PlayerPlaySound("ambient/alarms/warningbell1.wav")  end )
		timer.Simple(4, function()  PlayerPlaySound("ambient/alarms/warningbell1.wav")  end )
	else 
		PlayerInfo("Waiting for other players to spawn. Round starts in 20 seconds")
		timer.Simple(10, function() 
			if WeaponData.ammo_type ~= "none" then
				BroadcastNextRoundWeapon("Next Round is "..WeaponData.nice_name.." with "..WeaponData.ammo_count.." bullets")
			else
				BroadcastNextRoundWeapon("Next Round is "..WeaponData.nice_name)
			end
		end )
		timer.Simple(12, function()  PlayerPlaySound("vo/canals/matt_goodluck.wav")  end )
		timer.Simple(15, function()  PlayerPlaySound("ambient/alarms/warningbell1.wav")  end )
		timer.Simple(16, function()  PlayerPlaySound("ambient/alarms/warningbell1.wav")  end )
		timer.Simple(17, function()  PlayerPlaySound("ambient/alarms/warningbell1.wav")  end )
		timer.Simple(18, function()  PlayerPlaySound("ambient/alarms/warningbell1.wav")  end )
		timer.Simple(19, function()  PlayerPlaySound("ambient/alarms/warningbell1.wav")  end )
	end

	

	--UTIL_FreezeAllAlivePlayers()

	print("PreRoundStart: "..num)
end

function GM:OnRoundStart()
	hasGonePastFirstRound = true
	print("Round Started")
	UTIL_UnFreezeAllPlayers()
	--Strip the players - give them all 1 bullet
	for k, v in pairs(player.GetAll()) do
		if v:Team() == TEAM_HUMAN and v:Alive() then
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
	PlayerPlaySound("ambient/alarms/klaxon1.wav")
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

function GM:RoundEnd()

	if ( !GAMEMODE:InRound() ) then 
		-- if someone uses RoundEnd incorrectly then do a trace.
		MsgN("WARNING: RoundEnd being called while gamemode not in round...")
		debug.Trace()
		return 
	end
	
	GAMEMODE:OnRoundEnd( GetGlobalInt( "RoundNumber" ) )

	self:SetInRound( false )
	
	timer.Destroy( "RoundEndTimer" )
	timer.Destroy( "CheckRoundEnd" )
	SetGlobalFloat( "RoundEndTime", -1 )
	if gameHasActuallyFinished == false then
		timer.Simple( GAMEMODE.RoundPostLength, function() GAMEMODE:PreRoundStart( GetGlobalInt( "RoundNumber" )+1 ) end )
	end
	
end


function GM:CheckRoundEnd()
	local PlayersAlive = 0
	local PlayersAlivePlayer = false
	local randValue = math.random(0,1)
	local FinishedThisRound = false

	for k, v in pairs(player.GetAll()) do
		if v:Team() == TEAM_HUMAN and v:Alive() then
			PlayersAlive = PlayersAlive + 1
			PlayersAlivePlayer = v
		end
	end
	if PlayersAlive > 1 then 
		--Just check if we have more than 1 person alive then the game is still in progress. Carry on
		gameHasActuallyFinished = false
	elseif PlayersAlive == 1 then 
		FinishedThisRound = true
		GAMEMODE:RoundEndWithResult(PlayersAlivePlayer)
		--Drop the weapon or they look a bit silly 
		PlayersAlivePlayer:DropWeapon()
		if randValue < 1 then 
			PlayerDoAction(PlayersAlivePlayer, "muscle") -- Victory Dance
		else
			PlayerDoAction(PlayersAlivePlayer, "dance") -- Victory Dance
		end
		PlayerPlaySound("vo/coast/odessa/female01/nlo_cheer03.wav")
		if LastManStandingRound == LastManStandingMaxRounds then
			gameHasActuallyFinished = true
			timer.Simple(5, function() GAMEMODE:EndOfGame( true ) end )
			return false -- We dont want to think we are done yet
		end
	else 
		--Must be 0 then
		FinishedThisRound = true
		GAMEMODE:RoundEndWithResult(1, 'Everyone Loses! What a waste of everyones time that was...')
		PlayerPlaySound("vo/npc/Barney/ba_damnit.wav")
		if LastManStandingRound == LastManStandingMaxRounds then
			gameHasActuallyFinished = true
			timer.Simple(5, function() GAMEMODE:EndOfGame( true ) end )
			return false -- We dont want to think we are done yet
		end
	end
	--If we finished a round then do an update to the internal round clock
	if(FinishedThisRound) then 
		LastManStandingRound = LastManStandingRound + 1
		hasGonePastFirstRound = false
		SetGlobalInt( "RoundNumber", 0 ) --Reset the bottom round counter too
		--Kill the players - the OnPreRoundStart will ensure we are alive again
		timer.Simple(4, function() UTIL_KillAllPlayers() end )
		return true -- Techincally we have ended
	end

	return false
end

-- Playe The Victory/Draw Sound At The End Of The Round
function GM:OnRoundEnd(round)
	print("On Round End Called")
	--Freeze the players so they cant fire again
	--UTIL_FreezeAllAlivePlayers()
	local PlayersAlive = 0
	for k, v in pairs(player.GetAll()) do
		if v:Team() == TEAM_HUMAN and v:Alive() then
			PlayersAlive = PlayersAlive + 1
			PlayersAlivePlayer = v
		end
	end
	--If we have more than 1 player alive then do a cheer for those who are alive
	if PlayersAlive > 1 then 
		for k, v in pairs(player.GetAll()) do
			v:CrosshairDisable()
			v:DropWeapon()
			PlayerDoAction(v, "cheer")
		end

		--Clear up the old weapons from the last round that have been discarded
		timer.Simple(10, function() 
			if WeaponData ~= false then 
				local OldWeapons = ents.FindByClass(WeaponData.weapon_name)
				for k,v in pairs(OldWeapons) do
					v:Ignite(5)
					v:Remove()
				end
			end
		end)

	end

	PlayerPlaySound("plats/elevbell1.wav")
	--We need to reduce the next round time for any rounds greater than the first
	GAMEMODE.RoundPreStartTime = 5 --From after the first round end
end

function PlayerDoAction(ply, seq)
	local anim = seq
	net.Start("PLAYERACTION")
    	net.WriteString(seq)
	net.Send(ply)
end

function BroadcastNextRoundWeapon(msg)
	net.Start("NEXTROUNDWEAPONS")
	net.WriteString(msg)
	net.Broadcast()
end

function PlayerPlaySound(sound)
	for k, v in pairs(player.GetAll()) do
		v:ConCommand("play "..sound)
	end
end

function PlayerInfo(message)
	for k, v in pairs(player.GetAll()) do
			v:ChatPrint(message)
	end
end

function GM:PlayerJoinTeam(ply, teamid) 
	local roundNum = GetGlobalInt( "RoundNumber" );
	--If we are not in a round then thats good - give them the team they want
	if !hasGonePastFirstRound and ply:Team() == TEAM_UNASSIGNED and (teamid == TEAM_HUMAN) then 
		ply:SetTeam(teamid)
		ply:Spawn()
	end


	if hasGonePastFirstRound and teamid == TEAM_HUMAN then
			ply:ChatPrint(""..ply:Nick()..", you've joined too late and will have to sit this one out!")
			ply:SetTeam(teamid)
			ply:KillSilent()
		return false
	end
	
	
	if ply:Team() != TEAM_SPECTATOR and teamid == TEAM_SPECTATOR then
		ply:SetTeam(TEAM_HUMAN)
		ply:KillSilent()
		ply:StripWeapons()
		--ply:ChatPrint(""..ply:Nick()..", you've joined Spectators.")
	end	
	
end

function GM:CanStartRound()
	if #team.GetPlayers( TEAM_HUMAN ) >= 2 then return true end
	return false
end


function GM:PlayerSpawn( pl ) 
	pl:CrosshairDisable()
	if pl:Team() == TEAM_HUMAN and hasGonePastFirstRound then
		pl:KillSilent()
		pl:StripWeapons()
		return 
	end	

	self.BaseClass:PlayerSpawn( pl )	
	
end
