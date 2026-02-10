if CLIENT then return end

AddCSLuaFile( "sracing_config.lua" )
AddCSLuaFile( "sracing_interface.lua" )
AddCSLuaFile( "sracing_lang.lua" )

util.AddNetworkString( "sRacing.SendRaceInfo" )
util.AddNetworkString( "sRacing.RemoveRequest" )
util.AddNetworkString( "sRacing.JoinRaceRequest" )
util.AddNetworkString( "sRacing.UpdatePlayerList" )
util.AddNetworkString( "sRacing.UpdateTotalBet" )
util.AddNetworkString( "sRacing.CheckpointPass" )
util.AddNetworkString( "sRacing.ACheckpointPass" )
util.AddNetworkString( "sRacing.UpdateRaceMode" )
util.AddNetworkString( "sRacing.UpdateRaceTime" )
util.AddNetworkString( "sRacing.UpdateBustedTime" )
util.AddNetworkString( "sRacing.BustPlayer" )
util.AddNetworkString( "sRacing.StartRace" )
util.AddNetworkString( "sRacing.FinishRace" )
util.AddNetworkString( "sRacing.FailRace" )

sRacing.serverRaceList = sRacing.serverRaceList or {} 

local function FetchRaceInfo(srFile) 
	if(!file.Exists(srFile, "DATA")) then return end
	local Race = util.JSONToTable( file.Read( srFile, "DATA" )) 
	return Race
end

local function RefreshServerRaces()
	sRacing.serverRaceList = {}
	local files, folders = file.Find( "street_racing/*.txt", "DATA" )
	for k,v in pairs(files) do
		local race = FetchRaceInfo("street_racing/"..v)
		race.playerlist = {}
		race.betlist = {}
		race.lobbymode = 0
		race.ongoingtime = 0
		race.totalbet = 0
		race.FinishPos = 1
		race.carstartsd = {}
		if(race.map==game.GetMap()) then
			sRacing.serverRaceList[race.name] = race
		end
	end
end
RefreshServerRaces()
hook.Add( "Initialize", "sRacing.InitRaceList", function() 
	RefreshServerRaces()
end)

local function UpdateRaceClient(raceinfo, ply)
	if(raceinfo.map != game.GetMap()) then return end
	net.Start( "sRacing.SendRaceInfo" )
	net.WriteString( raceinfo.name or "Race" )
	net.WriteTable( raceinfo.musicurls or {} )
	net.WriteString( raceinfo.allowedcars or "" )
	net.WriteBool( raceinfo.collision )
	net.WriteUInt( raceinfo.winreward or 0, 32)
	net.WriteUInt( raceinfo.entryfee or 0, 16)
	net.WriteUInt( raceinfo.reward or 0, 32)
	net.WriteUInt( raceinfo.minplayers or 0, 7)
	net.WriteUInt( raceinfo.maxduration or 0, 16)
	net.WriteUInt( raceinfo.laps or 0, 16)
	net.WriteUInt( raceinfo.carstartsrot or 0, 16)
	net.WriteBool( raceinfo.autowanted )
	net.WriteBool( raceinfo.allowbet )
	net.WriteTable( raceinfo.checkpoints or {} )
	net.WriteTable( raceinfo.carstarts or {} )
	net.WriteTable( raceinfo.startpoint or {} )
	net.WriteTable( raceinfo.themecolor or {} )
	net.WriteUInt( raceinfo.checksize or srConfig.CheckpointSize, 16)
	net.WriteUInt( raceinfo.meetsize or srConfig.MeetPointSize, 16)
	net.WriteTable( raceinfo.previewpoint or {} )
	net.WriteString( raceinfo.creationtime or "" )
	net.WriteUInt( raceinfo.checktype or 0, 4)
	net.WriteUInt( raceinfo.lobbymode or 0, 4)
	if(IsValid(ply)) then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

local function RemoveRaceClient(name, ply)
	net.Start( "sRacing.RemoveRequest" )
	net.WriteString( name )
	if(IsValid(ply)) then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

net.Receive( "sRacing.SendRaceInfo", function( len, ply )
	//Save the race in a file
	if !sRacing.IsAdmin(ply) then ply:ChatPrint( srConfig.Lang[srConfig.Language].nopermission1 ) return end
	local Race = {}
	Race.name = net.ReadString() 
	Race.musicurls = net.ReadTable() 
	Race.allowedcars = net.ReadString()
	Race.collision = net.ReadBool()
	Race.winreward = net.ReadUInt( 32 )
	Race.entryfee = net.ReadUInt( 16 )
	Race.reward = net.ReadUInt( 32 )
	Race.minplayers = net.ReadUInt( 7 )
	Race.maxduration = net.ReadUInt( 16 )
	Race.laps = net.ReadUInt( 16 )
	Race.carstartsrot = net.ReadUInt( 16 )
	Race.autowanted = net.ReadBool()
	Race.allowbet = net.ReadBool()
	Race.checkpoints = net.ReadTable()
	Race.carstarts = net.ReadTable()
	Race.startpoint = net.ReadTable()
	Race.themecolor = net.ReadTable()
	Race.checksize = net.ReadUInt( 16 )
	Race.meetsize = net.ReadUInt( 16 )
	Race.previewpoint = net.ReadTable()
	Race.checktype = net.ReadUInt( 4 )

	local Timestamp = os.time()
	local TimeString = os.date( "%H:%M:%S - %d/%m/%Y" , Timestamp )

	Race.creationtime = TimeString
	Race.map = game.GetMap()

	local tab = util.TableToJSON( Race )
	file.CreateDir( "street_racing" )
	local idname = string.gsub(Race.name,"%W","")

	if(file.Exists( "street_racing/race_"..game.GetMap().."-"..idname..".txt", "DATA" ) ) then
		ply:ChatPrint(srConfig.Lang[srConfig.Language].overwrite1.." ("..Race.name..") "..srConfig.Lang[srConfig.Language].overwrite2)
	else
		ply:ChatPrint(srConfig.Lang[srConfig.Language].senttoserver)
	end

	file.Write( "street_racing/race_"..game.GetMap().."-"..idname..".txt", tab )

	RefreshServerRaces()

	Race.playerlist = {}
	Race.lobbymode = 0
	Race.ongoingtime = 0
	Race.FinishPos = 1
	Race.totalbet = 0

	UpdateRaceClient(Race)

end )

local function GetRaceInfo(racename)
	return sRacing.serverRaceList[racename]
end

local function UpdatePlayerChecks(race, ply)
	for k, v in pairs(race.playerlist) do
		if(race.playerlist[ply:EntIndex()]==nil) then return end
		net.Start( "sRacing.CheckpointPass" )
		net.WriteUInt(ply:EntIndex(), 7)
		net.WriteTable( race.playerlist[ply:EntIndex()] )
		net.Send(Entity(k))
	end
end

local function UpdateRacePlayers(race)
	for k, v in pairs(race.playerlist) do
		net.Start( "sRacing.UpdatePlayerList" )
		net.WriteTable( race.playerlist )
		net.Send(Entity(k))
	end
end
local function UpdateTotalBet(race)
	net.Start( "sRacing.UpdateTotalBet" )
	net.WriteString( race.name )
	net.WriteUInt( race.totalbet or 0, 25 )
	net.Broadcast()
end

local function UpdateRaceTime(race)
	for k, v in pairs(race.playerlist) do
		net.Start( "sRacing.UpdateRaceTime" )
		net.WriteUInt( race.ongoingtime, 16 )
		net.Send(Entity(k))
	end
end

local function UpdateRaceMode(race)
	net.Start( "sRacing.UpdateRaceMode" )
	net.WriteString( race.name )
	net.WriteUInt( race.lobbymode, 4 )
	net.Broadcast()
end

local function RacePlayerFinish(ply, position, reward)
	-- Validate player and ensure they're still valid
	if !IsValid(ply) then
		print("[sRacing] Warning: Attempted to finish race for invalid player")
		return
	end

	-- Validate position and reward values
	if !position or position < 1 or position > 127 then
		print("[sRacing] Warning: Invalid position value for player " .. ply:Nick() .. ": " .. tostring(position))
		position = 1
	end

	if !reward or reward < 0 or reward > 4294967295 then
		print("[sRacing] Warning: Invalid reward value for player " .. ply:Nick() .. ": " .. tostring(reward))
		reward = 0
	end

	sRacing.SetUnwanted(ply)

	-- Send finish message with error handling
	net.Start( "sRacing.FinishRace" )
	net.WriteUInt( position, 7 )
	net.WriteUInt( reward, 32 )
	net.Send(ply)

	-- Log the finish for debugging
	print("[sRacing] Player " .. ply:Nick() .. " finished race - Position: " .. position .. ", Reward: " .. reward)

	-- Send a chat message as backup notification
	ply:ChatPrint("[Street Racing] Race finished! Position: " .. position .. " | Reward: $" .. reward)
end

local function ResetCollision(vehent)
	if(vehent.sr_collision==nil) then return end
	if(simfphys && simfphys.IsCar( vehent.base )) then
		for k, v in pairs(vehent.base.Wheels) do
			v:SetCollisionGroup(vehent.sr_collision) 
		end
		vehent.base:SetCollisionGroup(vehent.sr_collision)
	else
		vehent:SetCollisionGroup(vehent.sr_collision)
	end
end

local function FinishRace(ply)
	-- Validate player
	if !IsValid(ply) then
		print("[sRacing] Error: FinishRace called with invalid player")
		return
	end

	local raceName = ply:GetNWString( "current_race", "" )
	if raceName == "" then
		print("[sRacing] Error: Player " .. ply:Nick() .. " has no current race when finishing")
		return
	end

	local race = sRacing.serverRaceList[raceName]
	if !race then
		print("[sRacing] Error: Race '" .. raceName .. "' not found for player " .. ply:Nick())
		return
	end

	-- Validate player is actually in the race
	if !race.playerlist[ply:EntIndex()] then
		print("[sRacing] Error: Player " .. ply:Nick() .. " not found in race playerlist")
		return
	end

	-- Reset vehicle collision safely
	if IsValid(ply:GetVehicle()) then
		ResetCollision(ply:GetVehicle())
		ply:GetVehicle().sr_collision = nil
	end

	-- Calculate reward and position
	local position = race.FinishPos or 1
	local reward = 0

	if position == 1 then
		reward = (race.winreward or 0) + (race.totalbet or 0)
		sRacing.AddMoney(ply, reward)
	else
		reward = race.reward or 0
		sRacing.AddMoney(ply, reward)
	end

	-- Send finish notification
	RacePlayerFinish(ply, position, reward)

	-- Clean up player data
	race.playerlist[ply:EntIndex()] = nil
	if ply.carstart then
		race.carstartsd[ply.carstart] = false
	end
	ply:SetNWString( "current_race", "" )

	-- Update race state
	race.FinishPos = (race.FinishPos or 1) + 1
	UpdateRaceMode(race)
	UpdateRacePlayers(race)

	print("[sRacing] Successfully finished race for player " .. ply:Nick() .. " in position " .. position)
end

net.Receive( "sRacing.CheckpointPass", function( len, ply )
	// Check if the player is actually in the race
	if(ply:GetNWString( "current_race", "" )=="" or !ply.sr_allowCheckSend) then return end

	local race = sRacing.serverRaceList[ply:GetNWString( "current_race", "" )]
	if(!race or !IsValid(ply)) then return end

	-- Validate player is in the race playerlist
	if !race.playerlist[ply:EntIndex()] then
		print("[sRacing] Warning: Player " .. ply:Nick() .. " not in race playerlist during checkpoint pass")
		return
	end

	local currentcheck = race.playerlist[ply:EntIndex()].checkpoint

	ply.sr_allowCheckSend = false
	timer.Create("sRacing.CheckControl"..ply:EntIndex(),0.3,1, function()
		if(IsValid(ply)) then
			ply.sr_allowCheckSend = true
			if(race.playerlist[ply:EntIndex()]!=nil) then
				net.Start( "sRacing.ACheckpointPass" )
				net.Send(ply)
			end
		end
	end)

	if(ply:GetPos():DistToSqr(race.checkpoints[(currentcheck+1)%(#race.checkpoints+1)])>race.checksize*race.checksize*4+250) then return end

	race.playerlist[ply:EntIndex()].checkpoint = currentcheck + 1

	if(currentcheck >= table.Count(race.checkpoints)-1 ) then
		race.playerlist[ply:EntIndex()].lap = race.playerlist[ply:EntIndex()].lap + 1
		race.playerlist[ply:EntIndex()].checkpoint = (race.playerlist[ply:EntIndex()].checkpoint)%(table.Count(race.checkpoints))
	end

	UpdatePlayerChecks(race, ply)

	-- Double-check player is still in race before finishing
	if race.playerlist[ply:EntIndex()] and race.playerlist[ply:EntIndex()].lap >= race.laps then
		print("[sRacing] Player " .. ply:Nick() .. " completing race - Lap: " .. race.playerlist[ply:EntIndex()].lap .. "/" .. race.laps)
		FinishRace(ply)
	end
end )

net.Receive( "sRacing.RemoveRequest", function( len, ply )
	if !sRacing.IsAdmin(ply) then ply:ChatPrint( srConfig.Lang[srConfig.Language].nopermission2 ) return end
	local race_name = net.ReadString() 

	if (#GetRaceInfo(race_name).playerlist!=0) then ply:ChatPrint( srConfig.Lang[srConfig.Language].cantremove1 ) return end

	local idname = string.gsub(race_name,"%W","")
	if(file.Exists( "street_racing/race_"..game.GetMap().."-"..idname..".txt", "DATA" ) ) then
		ply:ChatPrint(srConfig.Lang[srConfig.Language].race.." ("..race_name..") "..srConfig.Lang[srConfig.Language].racedeleted)
		file.Delete("street_racing/race_"..game.GetMap().."-"..idname..".txt")
	else
		ply:ChatPrint(srConfig.Lang[srConfig.Language].error" "..srConfig.Lang[srConfig.Language].race.." ("..race_name..") "..srConfig.Lang[srConfig.Language].doesntexist)
	end
	RemoveRaceClient(race_name)

	RefreshServerRaces()
end )

local function UnfreezeVehicle(vehicle)
	// SIMFPHYS COMPATIBILITY
	if(simfphys && simfphys.IsCar( vehicle.base ))  then
		constraint.RemoveConstraints( vehicle.base, "Weld" )
		return 
	end
	
	// SCARS
	if(vehicle.SCarGroup) then
		constraint.RemoveConstraints( vehicle.EntOwner, "Weld" )
	end

	// DEFAULT, TDM
	constraint.RemoveConstraints( vehicle, "Weld" )
	vehicle:GetPhysicsObject():EnableMotion(true)
end

local function LeaveRace(racename, ply)
	local race = GetRaceInfo(racename)
	race.playerlist[ply:EntIndex()] = nil
	if (ply.carstart!=nil) then race.carstartsd[ply.carstart] = false end
	if(race.lobbymode!=2) then
		if(race.totalbet!=nil && race.betlist[ply:EntIndex()]!=nil) then race.totalbet = race.totalbet - race.betlist[ply:EntIndex()] end
		race.betlist[ply:EntIndex()] = nil
		UpdateTotalBet(race)
	end
	UpdateRaceMode(race)
	UpdateRacePlayers(race)
	ply:SetNWString( "current_race", "" ) 
end

local function StartRace(race)
	race.lobbymode = 2
	race.ongoingtime = race.maxduration

	UpdateRaceTime(race)
	UpdateRaceMode(race)

	for k, v in pairs(race.playerlist) do
		UnfreezeVehicle(Entity(k):GetVehicle())
		sRacing.AddMoney(Entity(k), -race.entryfee)
		sRacing.AddMoney(Entity(k), -race.betlist[k])
		//Entity(k).carstart = nil
		if(race.url!="") then
			net.Start( "sRacing.StartRace" )
			net.Send(Entity(k))
		end
		if(race.autowanted) then
			sRacing.SetWanted(Entity(k), race.maxduration)
		end
	end
end

local function FailRace(ply, textid)
	net.Start( "sRacing.FailRace" )
	net.WriteUInt(textid, 4)
	net.Send(ply)
end


local function EndRace(race)
	race.lobbymode = 3
	race.ongoingtime = srConfig.RaceCooldown
	race.FinishPos = 1

	UpdateRaceTime(race)
	UpdateRaceMode(race)

	for k, v in pairs(race.playerlist) do
		FailRace(Entity(k), 0)
		Entity(k):SetNWString( "current_race", "" ) 
		race.playerlist[k] = nil
		race.betlist[k] = nil
		race.carstartsd[k] = false
	end
	race.totalbet = 0
	UpdateTotalBet(race)
end

local function UpdateLobbyTimers(race_info)
	local minplayers = math.min(race_info.minplayers,#race_info.carstarts)
	local curplayers = table.Count(race_info.playerlist)
	if(race_info.lobbymode==1) then
		if(curplayers>=minplayers) then
			if(race_info.ongoingtime>0) then
				race_info.ongoingtime = race_info.ongoingtime - 1 
				UpdateRaceTime(race_info)
			end
			if(race_info.ongoingtime==0) then 
				StartRace(race_info)
			end
		else
			race_info.lobbymode = 0
			race_info.ongoingtime = 0
			UpdateRaceMode(race_info)
			UpdateRaceTime(race_info)
		end
	end

	if(race_info.lobbymode==2) then
		if(race_info.ongoingtime>0) then 
			race_info.ongoingtime = race_info.ongoingtime - 1 
			UpdateRaceTime(race_info)
		end
		if(race_info.ongoingtime==0 or (curplayers==0)) then EndRace(race_info) end
	end

	if(race_info.lobbymode==3) then
		if(race_info.ongoingtime>0) then 
			race_info.ongoingtime = race_info.ongoingtime - 1 
			UpdateRaceTime(race_info)
		end
		if(race_info.ongoingtime==0) then 
			race_info.lobbymode = 0 
			UpdateRaceMode(race_info)
		end
	end
end

local function UpdateLobbyType(race_info)
	local minplayers = math.min(race_info.minplayers,#race_info.carstarts)
	local curplayers = table.Count(race_info.playerlist)
	if(race_info.lobbymode==0) then
		UpdateRaceTime(race_info)
		if(curplayers>=minplayers) then
			race_info.lobbymode = 1
			if(race_info.ongoingtime==0) then race_info.ongoingtime = srConfig.LobbyWaitTime end
			UpdateRaceTime(race_info)
			UpdateRaceMode(race_info)
		end
	end
	
	if(race_info.lobbymode==1) then
		if(curplayers==(#race_info.carstarts)) then
			if(race_info.ongoingtime>5) then race_info.ongoingtime = 5	 end
			UpdateRaceTime(race_info)
		end
		if(curplayers>=minplayers) then
			if(race_info.ongoingtime<=5) then race_info.ongoingtime = 5 end
			if(race_info.ongoingtime==0) then race_info.lobbymode = 2 end
			UpdateRaceMode(race_info)
		end
	end
	
	if(race_info.lobbymode==2) then
		StartRace(race_info)
	end
end

local function TeleportVehicle(veh, pos, angle, race)

	if(simfphys && simfphys.IsCar( veh.base ))  then

		for k, v in pairs(veh.base.Wheels) do
			v:SetPos(pos+Vector(0,0,30))
			v:DropToFloor() 
			if(race.collision) then	v:SetCollisionGroup(COLLISION_GROUP_VEHICLE)
			else v:SetCollisionGroup(COLLISION_GROUP_DEBRIS) end

		end

		local carheight = veh:GetPos().z
		local wheelheight = veh.base.Wheels[1]:GetPos().z or carheight
		local dif = carheight - wheelheight

		veh.base:SetPos(pos)
		veh.base:DropToFloor() 
		veh.base:SetAngles(angle)

		if(!veh.sr_collision) then veh.sr_collision = veh:GetCollisionGroup() end

		constraint.Weld(veh.base, game.GetWorld(), 0, 0)
		if(race.collision) then	veh.base:SetCollisionGroup(COLLISION_GROUP_VEHICLE)
		else veh.base:SetCollisionGroup(COLLISION_GROUP_DEBRIS) end

		return
	end

	local EntityDrag = ents.Create("prop_physics")
	EntityDrag:SetPos(veh:GetPos())
	EntityDrag:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	EntityDrag:SetNoDraw(true)
	EntityDrag:DrawShadow(false)
	EntityDrag:SetAngles(veh:GetAngles())
	EntityDrag:Spawn()
	EntityDrag:GetPhysicsObject():EnableMotion(false)
	veh:SetParent(EntityDrag)
	EntityDrag:SetPos(pos)
	veh:SetParent(nil)
	veh:GetPhysicsObject():EnableMotion(false)
	constraint.Weld(EntityDrag, veh, 0, 0, 0, true)
	EntityDrag:Remove()
	veh:SetAngles(angle)

	if(!veh.sr_collision) then veh.sr_collision = veh:GetCollisionGroup() end
	if(race.collision) then	veh:SetCollisionGroup(COLLISION_GROUP_VEHICLE)
	else veh:SetCollisionGroup(COLLISION_GROUP_DEBRIS) end
end

net.Receive( "sRacing.JoinRaceRequest", function( len, ply )
	local race_name = net.ReadString() 
	local bet_amt = net.ReadUInt(32)
	local race_info = GetRaceInfo(race_name)

	if !(race_info.lobbymode==0 or race_info.lobbymode==1) then
		ply:ChatPrint( srConfig.Lang[srConfig.Language].racebegan )
		return
	end

	if(sRacing.IsJob(ply, srConfig.ForbiddenJobs) or (race_info.autowanted && sRacing.IsPolice(ply))) then 
		ply:ChatPrint( srConfig.Lang[srConfig.Language].jobforbidden )
		return 
	end

	if(!ply:InVehicle()) then
		ply:ChatPrint( srConfig.Lang[srConfig.Language].needvehicle )
		return
	end

	if(table.Count(race_info.playerlist)>=table.Count(race_info.carstarts)) then
		ply:ChatPrint( srConfig.Lang[srConfig.Language].racefull )
		return
	end

	if(ply:GetNWString("current_race", "")!="") then
		ply:ChatPrint( srConfig.Lang[srConfig.Language].alrinrace )
		return
	end

	local allowedcars
	if(string.len(string.gsub(race_info.allowedcars," ",""))>0) then
		allowedcars = string.Split( string.gsub(race_info.allowedcars," ",""), "," )
	else
		allowedcars = -1
	end

	if( simfphys && simfphys.IsCar( ply:GetVehicle().base )) then
		if(ply:GetVehicle()!=ply:GetVehicle().base:GetDriverSeat()) then
			ply:ChatPrint( srConfig.Lang[srConfig.Language].passerr )
			return end
		end

		if(allowedcars!=-1) then
			if( simfphys && simfphys.IsCar( ply:GetVehicle().base )) then
				if(!table.HasValue(allowedcars,ply:GetVehicle().base.VehicleName)) then
					ply:ChatPrint( srConfig.Lang[srConfig.Language].wrongveh )
					return 
				end
			else
				if(!table.HasValue(allowedcars,ply:GetVehicle().VehicleName)) then
					ply:ChatPrint( srConfig.Lang[srConfig.Language].wrongveh )
					return 
				end
			end
		end

		if(ply:GetPos():DistToSqr(Vector(race_info.startpoint[1]))>(race_info.meetsize*race_info.meetsize)) then 
			ply:ChatPrint( srConfig.Lang[srConfig.Language].toofar )
			return 
		end

		if(sRacing.GetMoney(ply)<(race_info.entryfee or 0)) then
			ply:ChatPrint( srConfig.Lang[srConfig.Language].nomoney1 )
			return	
		end

		if(race_info) then
			if(sRacing.GetMoney(ply)<(race_info.entryfee or 0)+bet_amt) then
				ply:ChatPrint( srConfig.Lang[srConfig.Language].nomoney2 )
				return	
			end
		end

	//ply:ChatPrint( "You've joined the "..race_name.."!" )

	race_info.betlist[ply:EntIndex()] = bet_amt
	race_info.totalbet = race_info.totalbet + bet_amt
	UpdateTotalBet(race_info)

	race_info.playerlist[ply:EntIndex()]={
		["checkpoint"] = 0,
		["lap"] = 0
	}

	UpdateRacePlayers(race_info)

	//Adjust starting positions every time someone joins
	for k,v in ipairs(race_info.carstarts) do
		if(race_info.carstartsd[k] == true) then continue end
		TeleportVehicle(ply:GetVehicle(), Vector(race_info.carstarts[k]), Angle(0,race_info.carstartsrot+90,0), race_info)
		race_info.carstartsd[k] = true
		ply.carstart = k
		break
	end

	ply:SetNWString( "current_race", race_name )

	//Change lobby status
	UpdateLobbyType(race_info)
end )

local function PoliceVicinity(ply)
	for k,v in pairs(player.GetAll()) do
		if(v==ply or !sRacing.IsPolice(v) or !v:InVehicle()) then continue end
		local dist = ply:GetPos():DistToSqr(v:GetPos()) 
		if(dist>160000) then continue 
		else return dist end
	end
	return -1
end

local function PlayerBusted(ply)
	local arrested = false
	for k,v in pairs(player.GetAll()) do
		if(!v:InVehicle() or !sRacing.IsPolice(v)) then continue end
		local dist = ply:GetPos():DistToSqr(v:GetPos()) 
		if(dist>640000) then continue end
		if(!arrested) then 
			sRacing.JailPlayer(ply, v) 
			FailRace(ply, 3)
			arrested = true 
			ply.sr_bustedtimer = 0
		end
		sRacing.AddMoney(v, srConfig.BustedPay)
		net.Start("sRacing.BustPlayer")
		net.WriteUInt(ply:EntIndex(),8)
		net.Send(v)
	end
end

local refreshRaces = true
local refreshBusted = true
hook.Add( "Think", "sRacing.ControlRaces", function(ply)
	if (refreshRaces) then
		for k,v in pairs(sRacing.serverRaceList) do
			UpdateLobbyTimers(v)
			//print( "Race: "..v.name.." | Lobbymode: "..v.lobbymode.." | Time: "..v.ongoingtime.." | Playeramount: "..table.Count(v.carstarts))
			//PrintTable( v.carstartsd)
		end
		refreshRaces = false
		timer.Simple(1,function()
			refreshRaces = true
		end)
	end
	if (refreshBusted) then
		for k,v in pairs(player.GetAll()) do
			if(!v:InVehicle() or sRacing.IsPolice(v) or !sRacing.IsWanted(v) or v:GetNWString( "current_race", "" )=="") then continue end
			if(PoliceVicinity(v)==(-1)) then v.sr_bustedtimer = v.sr_bustedtimer - 2
			else
				local velocity = (v:GetVehicle().base!=nil and (v:GetVehicle().base:GetVelocity():Length()/53) or (v:GetVehicle():GetVelocity():Length()/53)) or 4
				if(velocity<4) then
					v.sr_bustedtimer = v.sr_bustedtimer + (4-velocity)*1.3
				else
					v.sr_bustedtimer = v.sr_bustedtimer - math.min(velocity, 10)
				end
			end
			v.sr_bustedtimer = math.Clamp(v.sr_bustedtimer,0,100)
			if(v.sr_bustedtimer==100) then
				PlayerBusted(v)
			end
			net.Start("sRacing.UpdateBustedTime")
			net.WriteUInt(math.Round(v.sr_bustedtimer,0),8)
			net.Send(v)
		end
		refreshBusted = false
		timer.Simple(0.1,function()
			refreshBusted = true
		end)
	end
end)

hook.Add( "PlayerInitialSpawn", "sRacing.LoadRacesOnSpawn", function(ply)
	for k,v in pairs(sRacing.serverRaceList) do
		UpdateRaceClient(v,ply)
	end
	ply:SetNWString( "current_race", "" ) 
	ply.sr_allowCheckSend = true
	ply.sr_bustedtimer = 0
end)


hook.Add("PlayerDeath", "sRacing.DeathLeave", function(ply)
	if(ply:GetNWString( "current_race", "" )=="") then return end
	LeaveRace(ply:GetNWString( "current_race", "" ) , ply)
	if(ply:InVehicle()) then
		if(ply:GetVehicle().sr_collision!=nil) then ResetCollision(ply:GetVehicle()) end
		ply:GetVehicle().sr_collision = nil
		UnfreezeVehicle(ply:GetVehicle())
	end
	FailRace(ply, 2)
end)


hook.Add("PlayerLeaveVehicle", "sRacing.ExitLeave", function(ply, veh)
	if(ply:GetNWString( "current_race", "" )=="" or ply.canLeaveVeh) then return end
	LeaveRace(ply:GetNWString( "current_race", "" ) , ply)
	if(veh) then
		if(veh.sr_collision!=nil) then ResetCollision(veh) end
		UnfreezeVehicle(veh)
	end
	if(ply.sr_bustedtimer==100) then return end
	FailRace(ply, 1)
end)

hook.Add("PlayerDisconnected", "sRacing.DisconnectLeave", function(ply)
	if(ply:GetNWString( "current_race", "" )=="") then return end
	if(ply:InVehicle()) then
		if(ply:GetVehicle().sr_collision!=nil) then ResetCollision(ply:GetVehicle()) end
		ply:GetVehicle().sr_collision = nil
		ply:GetVehicle():Remove()
	end
	LeaveRace(ply:GetNWString( "current_race", "" ) , ply)
end)