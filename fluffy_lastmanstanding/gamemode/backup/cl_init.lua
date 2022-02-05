include( 'shared.lua' )


// Clientside only stuff goes here

--Hide player names when looking at other people
function GM:HUDDrawTargetID()
	return false
end

include( 'shared.lua' )

net.Receive( "PLAYERACTION", function( len, pl )
	local Action = net.ReadString()
	local client = LocalPlayer()
	print("Recieved action "..Action.." for "..client:Nick())
	RunConsoleCommand("act", Action)
end )