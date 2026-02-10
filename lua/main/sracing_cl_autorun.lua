if SERVER then return end

include( "sracing_lang.lua" )

local function DrawMeetPoint(race)
	if(LocalPlayer():GetPos():DistToSqr(race.startpoint[1])>9000000) then return end
	local distmul = math.Clamp(1-(LocalPlayer():GetPos():DistToSqr(race.startpoint[1]))/9000000,0,1)
	distmul = math.Clamp(distmul*2,0,1)
	if(distmul<0.01) then return end
	cam.Start3D2D(race.startpoint[1]+Vector(0,0,1), Angle(0,0,0), 2 )
	surface.SetDrawColor( race.themecolor.r,race.themecolor.g,race.themecolor.b, 175*distmul )
	surface.SetMaterial(sRacing.MeetCircleMat)
	surface.DrawTexturedRect( -race.meetsize/2, -race.meetsize/2, race.meetsize, race.meetsize )
	cam.End3D2D()

	cam.Start3D2D(race.startpoint[1]+Vector(0,0,130), Angle(0, (LocalPlayer():GetViewEntity():GetPos() - (race.startpoint[1]+Vector(0,0,100))):Angle().y+90, 90), 0.5 )
	surface.SetMaterial(sRacing.CheckerboardMat)
	surface.SetDrawColor( 20,20,20, 255*distmul )
	surface.DrawTexturedRect( -28, -59, 54, 40 )
	surface.SetDrawColor( race.themecolor.r,race.themecolor.g,race.themecolor.b,255*distmul)
	surface.DrawTexturedRect( -27, -58, 54, 40 )

	draw.SimpleTextOutlined( race.name, "sRacing.WorldFont", 0,  0, Color(race.themecolor.r,race.themecolor.g,race.themecolor.b,255*distmul), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20,255*distmul)) 
	if(race.lobbymode==0 || race.lobbymode==1) then
		text = srConfig.Lang[srConfig.Language].mainprize..": "..race.winreward..srConfig.Lang[srConfig.Language].currency
	else
		text = srConfig.Lang[srConfig.Language].oncd
	end

	draw.SimpleTextOutlined( string.upper(text), "sRacing.ToolFont", 0,  ScrH()/24, Color(255,255,255,255*distmul), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20,255*distmul)) 

	cam.End3D2D()
end

local function DrawCheckpoint(race, num, cmul)
	if(LocalPlayer():GetNWString( "current_race", "" )=="" or !LocalPlayer():InVehicle()) then return end
	local fakenum = num
	if(num>#race.checkpoints) then
		if(sRacing.currentRace.playerlist[LocalPlayer():EntIndex()].lap<race.laps) then
			num=num%(#race.checkpoints)
		else return end
	end

	local curcheck = fakenum+(#race.checkpoints)*sRacing.currentRace.playerlist[LocalPlayer():EntIndex()].lap
	local maxcheck = (#race.checkpoints)*race.laps

	if(curcheck>maxcheck) then return end

	if(race.checktype==0) then		
		cam.Start3D2D(Vector(race.checkpoints[num]), Angle(0, (LocalPlayer():GetViewEntity():GetPos() - (Vector(race.checkpoints[num])+Vector(0,0,100))):Angle().y+90, 90), 0.5 )
		surface.SetDrawColor(race.themecolor.r,race.themecolor.g,race.themecolor.b,200*cmul)
		surface.SetMaterial(sRacing.CheckCircleMat)
		surface.DrawTexturedRect( -race.checksize*2, -race.checksize*2, race.checksize*4, race.checksize*4 )

		local interval = 360 / (race.checksize/16)+5
		local centerX, centerY = 0, 0
		local radius = race.checksize*1.8

		for degrees = 1, 360, interval do 
			local currotation = degrees+CurTime()*5%360
			local x, y = PointOnCircle( currotation, radius, centerX, centerY )
			surface.SetMaterial(sRacing.CheckArrowMat)
			surface.SetDrawColor(255, 255, 255,255*cmul)
			surface.DrawTexturedRectRotated( x, y, 40, 100, -currotation+0 ) 
		end
		cam.End3D2D()

		local checktext = string.upper(srConfig.Lang[srConfig.Language].checkpoint)
		if(curcheck==maxcheck) then checktext = string.upper(srConfig.Lang[srConfig.Language].finish) end
		cam.Start3D2D(Vector(race.checkpoints[num])+Vector(0,0,race.checksize*0.65), Angle(0, (LocalPlayer():GetPos() - (Vector(race.checkpoints[num])+Vector(0,0,100))):Angle().y+90, 90), 0.5 )
		draw.SimpleTextOutlined( checktext, "sRacing.WorldFontLarge", 0,  -2, Color(race.themecolor.r,race.themecolor.g,race.themecolor.b,255*cmul), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20,255*cmul))

		cam.End3D2D()
	end

	if(race.checktype==1) then
		local distmul
		if(cmul==1) then distmul = math.Clamp(race.checksize*0.8*(math.Clamp(LocalPlayer():GetPos():DistToSqr(Vector(race.checkpoints[num]))/(race.checksize*race.checksize*16),0,race.checksize*16)), race.checksize*0.4, race.checksize*0.8)
		else distmul = race.checksize*0.8 end
		cam.Start3D2D(Vector(race.checkpoints[num])+Vector(0,0,distmul), Angle(0, (LocalPlayer():GetViewEntity():GetPos() - (Vector(race.checkpoints[num])+Vector(0,0,100))):Angle().y+90, 90), 0.5 )

		local checktext = string.upper(srConfig.Lang[srConfig.Language].checkpoint)
		if(curcheck==maxcheck) then checktext = string.upper(srConfig.Lang[srConfig.Language].finish) end

		draw.SimpleTextOutlined( checktext, "sRacing.WorldFontLarge", 0,  -2, Color(race.themecolor.r,race.themecolor.g,race.themecolor.b,255*cmul), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20,255*cmul))
		if(num>0) then
			draw.SimpleTextOutlined( curcheck.."/"..maxcheck, "sRacing.WorldFont", 0,  ScrH()/20+6, Color(255,255,255,255*cmul), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1,  Color(20,20,20,255*cmul)) 
		else
			draw.SimpleTextOutlined( "-/-", "sRacing.WorldFont", 0,  ScrH()/20+6, Color(255,255,255,255*cmul), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1,  Color(20,20,20,255*cmul)) 
		end
		surface.SetDrawColor(255, 255, 255, 155*cmul)
		surface.DrawRect( -2, 104, 4, race.checksize*2+distmul) 
		surface.DrawRect( -12, 100, 24, 4) 
		surface.DrawRect( -12, race.checksize*2+distmul+100, 24, 4) 
		cam.End3D2D()
	end

	if(race.checktype==2) then 
		local checktext = string.upper(srConfig.Lang[srConfig.Language].check)
		if(curcheck==maxcheck) then checktext = string.upper(srConfig.Lang[srConfig.Language].finish) end
		cam.Start3D2D(Vector(race.checkpoints[num])+Vector(0,0,race.checksize*0.65), Angle(0, (LocalPlayer():GetViewEntity():GetPos() - (Vector(race.checkpoints[num])+Vector(0,0,100))):Angle().y+90, 90), 0.5 )
		draw.SimpleTextOutlined( checktext, "sRacing.WorldFontLarge", 0,  -2, Color(race.themecolor.r,race.themecolor.g,race.themecolor.b,255*cmul), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20))
		if(num>0) then
			draw.SimpleTextOutlined( num.."/"..#race.checkpoints, "sRacing.WorldFont", 0,  ScrH()/20+6, Color(race.themecolor.r,race.themecolor.g,race.themecolor.b,255*cmul), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20,255*cmul)) 
		else
			draw.SimpleTextOutlined( "-/-", "sRacing.WorldFont", 0,  ScrH()/20+6, Color(race.themecolor.r,race.themecolor.g,race.themecolor.b,255*cmul), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 
		end
		surface.SetMaterial(sRacing.RightArrowMat)
		surface.SetDrawColor(race.themecolor.r,race.themecolor.g,race.themecolor.b,255*cmul)
		surface.DrawTexturedRectRotated(0,110,50,50,-90)
		cam.End3D2D()
	end
	
end

local function GetRaceInfo(racename)
	for k,v in pairs(sRacing.races) do
		if(v.name==racename) then
			return v
		end
	end
end

hook.Add( "PostDrawTranslucentRenderables", "sRacing.DrawCheckpoints", function()
	// Draw meet points
	if(LocalPlayer():GetNWString( "current_race", "" )=="") then
		for k,v in pairs(sRacing.races) do
			DrawMeetPoint(v)
		end
	end

	// Draw current race checkpoints
	if(LocalPlayer():GetNWString( "current_race", "" )=="") then return end
	local currentrace = GetRaceInfo(LocalPlayer():GetNWString( "current_race", "" ))

	DrawCheckpoint(currentrace, sRacing.currentRace.playerlist[LocalPlayer():EntIndex()].checkpoint+3, 0.1)
	DrawCheckpoint(currentrace, sRacing.currentRace.playerlist[LocalPlayer():EntIndex()].checkpoint+2, 0.5)
	DrawCheckpoint(currentrace, sRacing.currentRace.playerlist[LocalPlayer():EntIndex()].checkpoint+1, 1)
end)

hook.Add( "HUDPaint", "sRacing.MeetPointsHUD", function()
	if(LocalPlayer():GetNWString( "current_race", "" )!="") then return end
	if(!LocalPlayer():InVehicle()) then return end
	for k,v in pairs(sRacing.races) do
		if(LocalPlayer():GetPos():DistToSqr(v.startpoint[1])<=v.meetsize*v.meetsize) then
			draw.SimpleTextOutlined( string.upper(v.name), "sRacing.ToolFont", ScrW()/2, ScrH()/2+ScrH()/11-4, v.themecolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 
			draw.SimpleTextOutlined( string.upper(srConfig.Lang[srConfig.Language].presstoshow1).." ["..string.upper(input.GetKeyName(srConfig.RaceInfoKey)).."] "..string.upper(srConfig.Lang[srConfig.Language].presstoshow2), "sRacing.SelectFont", ScrW()/2, ScrH()/2+ScrH()/12+ScrH()/32, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 
		end
	end
end )

hook.Add( "Think", "sRacing.MeetPointsThink", function(ply)
	if(LocalPlayer():GetNWString( "current_race", "" )!="" or !LocalPlayer():InVehicle()) then return end
	if(LocalPlayer():IsTyping()) then return end
	for k,v in pairs(sRacing.races) do
		if(LocalPlayer():GetPos():DistToSqr(v.startpoint[1])<=v.meetsize*v.meetsize) then
			if(input.IsKeyDown( srConfig.RaceInfoKey ) ) then
				if(!LocalPlayer():InVehicle() or LocalPlayer():Health()<=0) then return end
				sRacing.OpenRaceMenu(v)
			end
		end
	end
end)

hook.Add( "Think", "sRacing.DisableMenus", function(ply)
	if(LocalPlayer():Health()<=0) then
		if(IsValid(sRacing.CreationMenu)) then
			sRacing.CreationMenu:Remove()
			sRacing.StopMusic()
		end
	end

	if(!LocalPlayer():InVehicle() or LocalPlayer():Health()<=0) then
		if(IsValid(sRacing.RaceInfoMenu)) then
			sRacing.RaceInfoMenu:Remove() 
			sRacing.StopMusic()
		end
	end
end)

local function SortScoreboardTab(tab, maxchecks) 
	table.sort( tab, function( a, b )
		if(a[4]==nil and b[4]==nil) then
			return a[2]+a[3]*maxchecks > b[2]+b[3]*maxchecks 
		end
	end )
	table.sort( tab, function( a, b )
		local cur_race = LocalPlayer():GetNWString( "current_race", "" )
		if(cur_race=="") then return end
		cur_race = sRacing.races[cur_race]
		if(a[2]+a[3]*maxchecks == b[2]+b[3]*maxchecks ) then
			return Entity(a[1]):GetPos():DistToSqr(Vector(cur_race.checkpoints[(a[2]+1)>maxchecks and 0 or (a[2]+1)])) < Entity(b[1]):GetPos():DistToSqr(Vector(cur_race.checkpoints[(b[2]+1)>maxchecks and 0 or (b[2]+1)]))
		end
	end )
	return tab 
end

local function DrawScoreboard(race)
	if(IsValid(sRacing.Scoreboard)) then return end 

	sRacing.Scoreboard = vgui.Create( "DScrollPanel")
	sRacing.Scoreboard:SetSize(ScrH()/4,(table.Count(sRacing.currentRace.Scoreboard)+1)*ScrH()/48)
	sRacing.Scoreboard:SetPos(ScrH()/48,ScrH()/5)
	sRacing.Scoreboard.Paint = function( self, w, h )
		SortScoreboardTab(sRacing.currentRace.Scoreboard, #race.checkpoints)
		for k, v in pairs(sRacing.currentRace.Scoreboard) do
			local time = ""

			local curcolor = (Entity(v[1])==LocalPlayer() and race.themecolor or Color(215,215,215))

			if(v[5]!=nil) then
				local curtime = string.FormattedTime( race.maxduration-v[5] )
				if(string.len(curtime.m)==1) then curtime.m = ("0"..curtime.m) end
				if(string.len(curtime.s)==1) then curtime.s = ("0"..curtime.s) end
				time = curtime.m..":"..curtime.s
			end

			surface.SetDrawColor(35,35,35,k%2 and 165 or 125)
			surface.DrawRect(0,k*ScrH()/48-1,w,ScrH()/48+1)
			if(time!="") then
				surface.SetDrawColor(175,175,175,k%2 and 15 or 10)
				surface.DrawRect(0,k*ScrH()/48-1,w,ScrH()/48+1)
			end

			surface.SetDrawColor(30,30,30)	
			surface.DrawRect(0,k*ScrH()/48-1,w,1)	
			surface.DrawRect(0,k*ScrH()/48+ScrH()/48-1,w,1)

			surface.SetDrawColor(curcolor)
			surface.DrawRect(0,k*ScrH()/48-1,4,ScrH()/48+1)
			draw.SimpleTextOutlined(k..". "..string.upper(IsValid(Entity(v[1])) and Entity(v[1]):Nick() or srConfig.Lang[srConfig.Language].playerdisconnected), "sRacing.InputFont", 12,  ScrH()/48*k-1+ScrH()/96, curcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 
			draw.SimpleTextOutlined(time, "sRacing.InputFont", w-12,  ScrH()/48*k-1+ScrH()/96, Color(215,215,215), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 	
		end
	end

	local SelfInfo = vgui.Create( "DScrollPanel", sRacing.Scoreboard )
	SelfInfo:SetSize(ScrH()/4,ScrH()/48+2)
	SelfInfo:SetPos(0,0)
	SelfInfo.Paint = function( self, w, h )
		local time = ""
		if(LocalPlayer():InVehicle() and LocalPlayer():GetNWString( "current_race", "" )!="") then
			local curtime = string.FormattedTime( race.maxduration - sRacing.currentRace.ongoingtime )
			if(string.len(curtime.m)==1) then curtime.m = ("0"..curtime.m) end
			if(string.len(curtime.s)==1) then curtime.s = ("0"..curtime.s) end
			time = curtime.m..":"..curtime.s
		end

		surface.SetDrawColor(35,35,35,225)
		surface.DrawRect(0,0,w,h)
		surface.SetDrawColor(race.themecolor)
		surface.DrawRect(0,h-2,w,2)
		draw.SimpleTextOutlined(string.upper(srConfig.Lang[srConfig.Language].time)..": "..time.."  "..(race.allowbet and (string.upper(srConfig.Lang[srConfig.Language].totalbet)..": "..race.totalbet..srConfig.Lang[srConfig.Language].currency) or ""), "sRacing.InputFont", w/2,  h/2-1, Color(215,215,215), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 
	end
	sRacing.Scoreboard:SizeToContentsX()

end

net.Receive( "sRacing.StartRace", function( len )
	if(LocalPlayer():GetNWString( "current_race", "" )=="") then return end
	local urls = sRacing.races[LocalPlayer():GetNWString( "current_race", "" )].musicurls

	sRacing.currentRace.Scoreboard = {}
	for k,v in pairs(sRacing.currentRace.playerlist) do
		table.insert(sRacing.currentRace.Scoreboard,{ k, v.checkpoint, v.lap })
	end
	sRacing.currentRace.FinishPos = 1

	DrawScoreboard(sRacing.races[LocalPlayer():GetNWString( "current_race", "" )])

	if(table.IsEmpty(urls)) then urls = srConfig.DefaultMusicTable end
	print(urls)
	sRacing.StartMusic(urls) 
end)

local function ShowText(text1, text2, duration, fadetime, color)
	if(IsValid(sRacing.ScreenHugeText)) then sRacing.ScreenHugeText:Remove() end
	timer.Remove( "srTextRemoveTimer" ) 

	sRacing.ScreenHugeText = vgui.Create( "DPanel" )
	sRacing.ScreenHugeText:SetSize(ScrH(), ScrH())
	sRacing.ScreenHugeText:SetPos(ScrW()/2-sRacing.ScreenHugeText:GetWide()/2, ScrH()/5-sRacing.ScreenHugeText:GetTall()/2)
	sRacing.ScreenHugeText.Paint = function( self, w, h ) 
		draw.SimpleTextOutlined( text1, "sRacing.HugeFont", w/2,  h/2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(20,20,20)) 
		draw.SimpleTextOutlined( text2, "sRacing.ToolFont", w/2,  h/2+ScrH()/1080*64, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(20,20,20)) 
	end

	sRacing.ScreenHugeText:AlphaTo( 0, fadetime, duration-fadetime ) 

	timer.Create( "srTextRemoveTimer", duration, 1, function()
		if(IsValid(sRacing.ScreenHugeText)) then sRacing.ScreenHugeText:Remove() end
	end )
end

net.Receive( "sRacing.FailRace", function( len )
	local textid = net.ReadUInt(4)
	if(LocalPlayer():GetNWString( "current_race", "" )=="") then return end
	local race =  sRacing.races[LocalPlayer():GetNWString( "current_race", "" )]
	local text = ""
	if(textid==0) then text = srConfig.Lang[srConfig.Language].outoftime end
	if(textid==1) then text = srConfig.Lang[srConfig.Language].leftvehicle end
	if(textid==2) then text = srConfig.Lang[srConfig.Language].racedeath end
	if(textid==3) then text = srConfig.Lang[srConfig.Language].busted.."!" end

	ShowText(string.upper(srConfig.Lang[srConfig.Language].racefailed), text, 5, 1, race.themecolor)
	timer.Create("sRacing.MusicFade", 4, 1, function()
		if(IsValid(sRacing.MusicChan)) then sRacing.StopMusic() end
	end)
end)

net.Receive( "sRacing.BustPlayer", function( len )
	local plyid = net.ReadUInt(8)
	ShowText(string.upper(srConfig.Lang[srConfig.Language].captured), Entity(plyid):Nick().." "..srConfig.Lang[srConfig.Language].beenarrested..srConfig.BustedPay..srConfig.Lang[srConfig.Language].currency, 4, 1, srConfig.ThemeColor)
end)

local function ScoreCheckpoint(ply)
	net.Start( "sRacing.CheckpointPass" )
	net.SendToServer()
end

net.Receive( "sRacing.CheckpointPass", function( len )
	local ply = net.ReadUInt( 7 )
	local ply_info = net.ReadTable()

	sRacing.currentRace.playerlist[ply] = ply_info

	local race =  sRacing.races[LocalPlayer():GetNWString( "current_race", "" )]
	
	if(sRacing.currentRace.Scoreboard==nil) then return end
	for k,v in pairs(sRacing.currentRace.Scoreboard) do
		if(v[1]==ply) then
			v[2]=ply_info.checkpoint
			v[3]=ply_info.lap 
		end
		if(race && v[3]==race.laps) then 
			if(v[4]==nil) then
				v[4]=sRacing.currentRace.FinishPos 
				sRacing.currentRace.FinishPos = sRacing.currentRace.FinishPos + 1
				v[5]=sRacing.currentRace.ongoingtime
			end
		end
	end

	if(ply==LocalPlayer():EntIndex()) then
		local fakenum = sRacing.currentRace.playerlist[LocalPlayer():EntIndex()].checkpoint
		local curcheck = fakenum+(#race.checkpoints)*sRacing.currentRace.playerlist[LocalPlayer():EntIndex()].lap
		ShowText("#"..curcheck, string.upper(srConfig.Lang[srConfig.Language].checkscore), 1, 0.5, race.themecolor)
		surface.PlaySound( "race_sounds/checkpoint.wav" )
		sRacing.aCheckRequest = true
	end
end)

net.Receive( "sRacing.ACheckpointPass", function( len )
	sRacing.aCheckRequest = true
end)

net.Receive( "sRacing.UpdateRaceMode", function( len )
	local racename = net.ReadString()
	local mode = net.ReadUInt( 4 )
	sRacing.races[racename].lobbymode = mode
end)

net.Receive( "sRacing.UpdateTotalBet", function( len )
	local racename = net.ReadString()
	local bet = net.ReadUInt( 25 )
	sRacing.races[racename].totalbet = bet
end)

net.Receive( "sRacing.FinishRace", function( len )
	local position = net.ReadUInt( 7 )
	local reward = net.ReadUInt( 32 )

	-- Validate data received
	if !position or position < 1 then
		print("[sRacing] Client: Invalid position received: " .. tostring(position))
		position = 1
	end

	if !reward or reward < 0 then
		print("[sRacing] Client: Invalid reward received: " .. tostring(reward))
		reward = 0
	end

	local raceName = LocalPlayer():GetNWString( "current_race", "" )
	if raceName == "" then
		print("[sRacing] Client: Received finish message but not in a race")
		return
	end

	local race = sRacing.races[raceName]
	if !race then
		print("[sRacing] Client: Race '" .. raceName .. "' not found")
		-- Use default theme color if race not found
		race = { themecolor = Color(255, 255, 255) }
	end

	-- Show finish message
	local finishText = string.upper(srConfig.Lang[srConfig.Language].finish or "FINISH") .. "!"
	local positionText = string.upper(srConfig.Lang[srConfig.Language].yourpos or "POSITION") .. ": " .. position
	local rewardText = string.upper(srConfig.Lang[srConfig.Language].reward or "REWARD") .. ": " .. reward .. (srConfig.Lang[srConfig.Language].currency or "$")
	local fullText = positionText .. " " .. rewardText

	ShowText(finishText, fullText, 5, 2, race.themecolor or Color(255, 255, 255))

	-- Also show in chat as backup
	chat.AddText(Color(0, 255, 0), "[Street Racing] ", Color(255, 255, 255), "Race finished! Position: " .. position .. " | Reward: $" .. reward)

	-- Play finish sound
	surface.PlaySound("race_sounds/checkpoint.wav")

	-- Fade music
	timer.Create("sRacing.MusicFade", 2, 1, function()
		if(IsValid(sRacing.MusicChan)) then sRacing.StopMusic() end
	end)

	-- Remove scoreboard
	if(IsValid(sRacing.Scoreboard)) then sRacing.Scoreboard:Remove() end

	print("[sRacing] Client: Race finished - Position: " .. position .. ", Reward: $" .. reward)
end)

net.Receive( "sRacing.UpdateRaceTime", function( len )
	local time = net.ReadUInt( 16 )
	sRacing.currentRace.ongoingtime = time


	// Draw countdown
	if(LocalPlayer():GetNWString( "current_race", "" )=="") then return end
	local race = sRacing.races[LocalPlayer():GetNWString( "current_race", "" )]
	if(time<=3 && race.lobbymode==1) then
		local text = time
		if(time==0 && race.lobbymode==1) then  
			text = string.upper(srConfig.Lang[srConfig.Language].go)
			timer.Remove( "sRacing.MusicFade" ) 
		end
		ShowText(text, string.upper(srConfig.Lang[srConfig.Language].getready).."!", 2, 0.8 , sRacing.races[LocalPlayer():GetNWString( "current_race", "" )].themecolor)
		if(time!=0) then
			surface.PlaySound( "race_sounds/countdown.wav" )
		else
			surface.PlaySound( "race_sounds/countdown_finish.wav" )
		end
	end

end)

hook.Add( "Think", "sRacing.RaceControl", function(ply)
	if(LocalPlayer():GetNWString( "current_race", "" )=="" or !LocalPlayer():InVehicle()) then
		if(IsValid(sRacing.Scoreboard)) then 
			sRacing.Scoreboard:Remove() 
			sRacing.currentRace.Scoreboard = nil 
			sRacing.currentRace.FinishPos = nil 
		end
		if(!sRacing.aCheckRequest) then sRacing.aCheckRequest = true end
		return 
	end

	local race = sRacing.races[LocalPlayer():GetNWString( "current_race", "" )]
	if(race.lobbymode==2) then
		if(LocalPlayer():GetPos():DistToSqr(race.checkpoints[sRacing.currentRace.playerlist[LocalPlayer():EntIndex()].checkpoint+1])<=race.checksize*race.checksize*4) then
			if(sRacing.aCheckRequest) then
				sRacing.aCheckRequest = false
				ScoreCheckpoint(ply)
			end
		end
	end
end)

hook.Add( "HUDPaint", "sRacing.DrawPlayerNames", function()
	if(LocalPlayer():GetNWString( "current_race", "" )=="" or !LocalPlayer():InVehicle()) then return end
	local racename = LocalPlayer():GetNWString( "current_race", "" )
	local race = GetRaceInfo(racename)

	if(sRacing.currentRace.Scoreboard==nil) then return end
	for k,v in pairs(sRacing.currentRace.Scoreboard) do
		local ply = Entity(v[1])
		if!(!IsValid(ply) or sRacing.IsPolice(ply) or !ply:InVehicle() or v[4]!=nil or race.lobbymode!=2 ) then //or ply == LocalPlayer()
			local dist = LocalPlayer():GetPos():DistToSqr(ply:GetPos())/3000
			if(dist<3000) then		
				local distmul = math.Clamp(1-(dist)/3000*3,0,1)
				distmul = math.Clamp(distmul*2,0,1)
				local screeninfo = (ply:GetPos()+Vector(0,0,50)):ToScreen()

				surface.SetDrawColor(35,35,35,225*distmul)	
				surface.DrawRect( screeninfo.x-ScrH()/16, screeninfo.y-ScrH()/84, ScrH()/8, ScrH()/42 )

				surface.SetDrawColor(race.themecolor.r,race.themecolor.g,race.themecolor.b,255*distmul)	
				surface.DrawRect( screeninfo.x-ScrH()/16+2, screeninfo.y-ScrH()/84+2, ScrH()/42-4, ScrH()/42-4 )
				draw.SimpleTextOutlined( k, "sRacing.InputFont", screeninfo.x-ScrH()/20-1,  screeninfo.y-2, Color(255,255,255,255*distmul), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20,255*distmul)) 
				draw.SimpleTextOutlined( string.sub( string.upper(ply:Nick()), 1, 14), "sRacing.InputFont", screeninfo.x+ScrH()/128,  screeninfo.y-2, Color(255,255,255,255*distmul), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20,255*distmul)) 
			end
		end
	end
end)

hook.Add( "HUDPaint", "sRacing.DrawPoliceTags", function()
	if(LocalPlayer():GetNWString( "current_race", "" )=="" or !LocalPlayer():InVehicle() or !sRacing.IsWanted(LocalPlayer())) then return end
	local racename = LocalPlayer():GetNWString( "current_race", "" )
	local race = GetRaceInfo(racename)
	for k,v in pairs(player.GetAll()) do
		if(sRacing.IsPolice(v) && v:InVehicle()) then
			local dist = LocalPlayer():GetPos():DistToSqr(v:GetPos())/2000
			if(dist<2000) then
				local distmul = math.Clamp(1-(dist)/2000*3,0,1)
				distmul = math.Clamp(distmul*2,0,1)
				local screeninfo = (v:GetPos()+Vector(0,0,50)):ToScreen()

				
				surface.SetDrawColor(race.themecolor.r,race.themecolor.g,race.themecolor.b,255*distmul)
				surface.SetMaterial(sRacing.ShieldMat)
				surface.DrawTexturedRect( screeninfo.x-ScrH()/64+2, screeninfo.y-ScrH()/64+2, ScrH()/32-4, ScrH()/32-4 )	
				draw.SimpleTextOutlined( string.sub(string.upper(v:Nick()),1,14), "sRacing.InputFont", screeninfo.x, screeninfo.y-1, Color(215,215,215,255*distmul ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20,255*distmul)) 
			end
		end
	end
end)

hook.Add( "HUDPaint", "sRacing.DrawWantedTags", function()
	if(!LocalPlayer():InVehicle() or !sRacing.IsPolice(LocalPlayer()) or LocalPlayer():GetNWString( "current_race", "" )!="") then return end
	for k,v in pairs(player.GetAll()) do
		if(v:InVehicle() && sRacing.IsWanted(v) && v:GetNWString( "current_race", "" )!="") then
			local dist = LocalPlayer():GetPos():DistToSqr(v:GetPos())
			if(dist<4000000) then
				local racename = v:GetNWString( "current_race", "" )
				local race = GetRaceInfo(racename)
				local distmul = math.Clamp(1-(dist)/4000000*3,0,1)
				distmul = math.Clamp(distmul*2,0,1)
				local screeninfo = (v:GetPos()+Vector(0,0,50)):ToScreen()

				surface.SetDrawColor(race.themecolor.r,race.themecolor.g,race.themecolor.b,255*distmul)
				surface.SetMaterial(sRacing.HandcuffMat)
				surface.DrawTexturedRect( screeninfo.x-ScrH()/64+2, screeninfo.y-ScrH()/64+2-ScrH()/128, ScrH()/32-4, ScrH()/32-4 )	
				draw.SimpleTextOutlined( string.sub(string.upper(v:Nick()),1,14), "sRacing.InputFont", screeninfo.x, screeninfo.y+ScrH()/128, Color(215,215,215,255*distmul ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20,255*distmul)) 
				if(dist<160000) then
					draw.SimpleTextOutlined( srConfig.Lang[srConfig.Language].catching, "sRacing.InputFont", screeninfo.x, screeninfo.y+ScrH()/48, Color(race.themecolor.r,race.themecolor.g,race.themecolor.b,255*distmul ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20,255*distmul)) 
				end
			end
		end
	end
end)


hook.Add( "HUDPaint", "sRacing.DrawStartingRaces", function()
	if(LocalPlayer():GetNWString( "current_race", "" )!="" or !LocalPlayer():InVehicle() ) then return end
	for k,v in pairs(sRacing.races) do
		if(sRacing.IsPolice(LocalPlayer()) and v.autowanted) then continue end
		if(v.lobbymode==1) then
			local dist = LocalPlayer():GetPos():DistToSqr(v.startpoint[1])
			if(dist>100000 && dist<25000000) then
				local distmul = math.Clamp(1-dist/25000000,0,1)
				if(dist<250000) then distmul = math.Clamp((dist-100000)/250000,0,1) end

				distmul = math.Clamp(distmul*2,0,1)
				local screeninfo = (v.startpoint[1]+Vector(0,0,50)):ToScreen()
				surface.SetDrawColor(35,35,35,195*distmul)	
				surface.DrawRect( screeninfo.x-ScrH()/18, screeninfo.y-ScrH()/128, ScrH()/9, ScrH()/64)
				surface.SetDrawColor(35,35,35,255*distmul)	
				surface.DrawOutlinedRect( screeninfo.x-ScrH()/18, screeninfo.y-ScrH()/128, ScrH()/9, ScrH()/64)

				draw.SimpleTextOutlined( string.upper(srConfig.Lang[srConfig.Language].abtostart), "sRacing.TinyFont", screeninfo.x, screeninfo.y, Color( 255, 255, 255, 255*distmul ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20,255*distmul)) 
				draw.SimpleTextOutlined( string.upper(v.name), "sRacing.InputFont", screeninfo.x, screeninfo.y-ScrH()/96, Color( v.themecolor.r,v.themecolor.g,v.themecolor.b,255*distmul ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20,255*distmul)) 
			end
		end
	end
end)

net.Receive( "sRacing.UpdateBustedTime", function( len )
	sRacing.BustedBar = net.ReadUInt(8)
end)

local col = 0
local h = {}
local smooth = 0
hook.Add( "HUDPaint", "sRacing.DrawRaceHud", function()
	if(LocalPlayer():GetNWString( "current_race", "" )=="" or !LocalPlayer():InVehicle()) then return end
	local race = sRacing.races[LocalPlayer():GetNWString( "current_race", "" )]
	if(race.lobbymode==4) then return end

	local time = string.FormattedTime( sRacing.currentRace.ongoingtime )
	if(string.len(time.m)==1) then time.m = ("0"..time.m) end
	if(string.len(time.s)==1) then time.s = ("0"..time.s) end

	if(sRacing.IsWanted(LocalPlayer())) then
		surface.SetDrawColor(35,35,35,215)	
		surface.DrawRect( ScrW()/2-ScrH()/16-2, ScrH()/4*3-ScrH()/12-2, ScrH()/8+4, ScrH()/32+4 )
		if(!timer.Exists("sRacing.WantedToggleColor")) then
			timer.Create("sRacing.WantedToggleColor",0.3,1,function()
				if(col==1) then col=0
				else col = 1 end
			end)
		end

		surface.SetDrawColor(race.themecolor)
		if(col==1) then surface.SetMaterial(sRacing.Wanted1Mat)
		else surface.SetMaterial(sRacing.Wanted2Mat) end
		surface.DrawTexturedRect( ScrW()/2-ScrH()/16, ScrH()/4*3-ScrH()/12, ScrH()/8, ScrH()/32 )

		surface.SetDrawColor(35,35,35,215)		
		surface.DrawRect( ScrW()/2-ScrH()/10, ScrH()/4*3+ScrH()/11+1, ScrH()/5, ScrH()/64 )
		surface.SetDrawColor(race.themecolor)		
		surface.DrawRect( ScrW()/2-ScrH()/10-2, ScrH()/4*3+ScrH()/11+1, 3, ScrH()/64 )
		surface.DrawRect( ScrW()/2-ScrH()/10-1+ScrH()/5, ScrH()/4*3+ScrH()/11+1, 3, ScrH()/64 )

		surface.SetDrawColor(Color(race.themecolor.r,race.themecolor.g,race.themecolor.b,65))
		local len = (ScrH()/10-3)
		if(sRacing.BustedBar>50) then
			smooth = Lerp(0.22,smooth, (len*(sRacing.BustedBar-50))/50)
			surface.DrawRect( ScrW()/2, ScrH()/4*3+ScrH()/11+1+2, smooth, ScrH()/64-4 )
		else
			smooth = Lerp(0.22,smooth, (len*(50-sRacing.BustedBar))/50)
			surface.DrawRect( ScrW()/2-smooth+1, ScrH()/4*3+ScrH()/11+1+2, smooth, ScrH()/64-4 )
		end

		surface.SetDrawColor(225, 225, 225, 25)	
		surface.DrawRect( ScrW()/2, ScrH()/4*3+ScrH()/11+1, 2, ScrH()/64 )
		surface.DrawRect( ScrW()/2-ScrH()/15, ScrH()/4*3+ScrH()/11+1, 2, ScrH()/64 )
		surface.DrawRect( ScrW()/2+ScrH()/15, ScrH()/4*3+ScrH()/11+1, 2, ScrH()/64 )
		draw.SimpleTextOutlined( srConfig.Lang[srConfig.Language].busted, "sRacing.InputFont",  ScrW()/2+ScrH()/15, ScrH()/4*3+ScrH()/11, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(20,20,20)) 
		draw.SimpleTextOutlined( srConfig.Lang[srConfig.Language].evade, "sRacing.InputFont",  ScrW()/2-ScrH()/15, ScrH()/4*3+ScrH()/11, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(20,20,20)) 
	end

	surface.SetDrawColor(race.themecolor)
	if(IsValid(sRacing.MusicChan)) then
		local audiodata = {}
		sRacing.MusicChan:FFT(audiodata, FFT_256)
		for i=1, 63 do
			h[i] = Lerp(35*FrameTime(), h[i] or 0, math.Clamp((audiodata[i] or 0) * ScrH()/2 * sRacing.MusicChan:GetVolume() ,0,ScrH()/10))
			surface.DrawRect( ScrW()/2-ScrH()/8+((ScrH()/4)/64)*i-3, ScrH()/4*3-ScrH()/48-ScrH()/64+2-(h[i] or 0) + 1, (ScrH()/4)/64+2, (h[i] or 0) )
		end
	end


	surface.SetDrawColor(35,35,35,215)		
	surface.DrawRect( ScrW()/2-ScrH()/8, ScrH()/4*3-ScrH()/48, ScrH()/4, ScrH()/24 )
	surface.SetDrawColor(race.themecolor)	
	surface.DrawRect( ScrW()/2-ScrH()/8, ScrH()/4*3-ScrH()/48-ScrH()/64+2, ScrH()/4, ScrH()/64 )	
	surface.DrawRect( ScrW()/2-ScrH()/8, ScrH()/4*3-ScrH()/48, 4, ScrH()/24 ) 	
	surface.DrawRect( ScrW()/2-ScrH()/8+ScrH()/4-4, ScrH()/4*3-ScrH()/48, 4, ScrH()/24 ) 	
	if(race.lobbymode==0 or race.lobbymode==1) then
		if(sRacing.currentRace.ongoingtime<6) then
			if(race.lobbymode==0) then
				draw.SimpleTextOutlined( string.upper(srConfig.Lang[srConfig.Language].awmoreply), "sRacing.InputFont", ScrW()/2,  ScrH()/4*3-1-ScrH()/36, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 	
			else
				draw.SimpleTextOutlined( string.upper(srConfig.Lang[srConfig.Language].abtostart), "sRacing.InputFont", ScrW()/2,  ScrH()/4*3-1-ScrH()/36, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 
			end			
		else
			draw.SimpleTextOutlined( string.upper(srConfig.Lang[srConfig.Language].awmoreply), "sRacing.InputFont", ScrW()/2,  ScrH()/4*3-1-ScrH()/36, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 
		end
	else
		draw.SimpleTextOutlined( string.upper(srConfig.Lang[srConfig.Language].timeleft), "sRacing.InputFont", ScrW()/2,  ScrH()/4*3-1-ScrH()/36, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 
	end

	draw.SimpleTextOutlined( time.m..":"..time.s, "sRacing.ToolFont", ScrW()/2,  ScrH()/4*3-1, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20,race.lobbymode==2 and 255 or 125)) 

	local a = ScrH()/32
	surface.SetDrawColor(35,35,35,225)	
	surface.DrawRect( ScrW()/2-ScrH()/8+a/2, ScrH()/4*3+ScrH()/42+3, ScrH()/8-a*2, a )
	surface.DrawRect( ScrW()/2+a*3/2, ScrH()/4*3+ScrH()/42+3, ScrH()/8-a*2, a )
	surface.SetDrawColor(race.themecolor)	
	surface.DrawRect( ScrW()/2-ScrH()/8+a/2, ScrH()/4*3+ScrH()/42+3, ScrH()/8-a*2, 3 )
	surface.DrawRect( ScrW()/2+a*3/2, ScrH()/4*3+ScrH()/42+3, ScrH()/8-a*2, 3 )
	surface.SetDrawColor(35,35,35,75)	
	surface.DrawRect( ScrW()/2-ScrH()/8+a/2, ScrH()/4*3+ScrH()/42+3, ScrH()/8-a*2, 3 )
	surface.DrawRect( ScrW()/2+a*3/2, ScrH()/4*3+ScrH()/42+3, ScrH()/8-a*2, 3 )

	draw.SimpleTextOutlined( string.upper(srConfig.Lang[srConfig.Language].lap)..":", "sRacing.InputFont", ScrW()/2-ScrH()/8+a/2+(ScrH()/8-a*2)/2,  ScrH()/4*3+ScrH()/42+2, Color( 225, 225, 225, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 
	draw.SimpleTextOutlined( string.upper(srConfig.Lang[srConfig.Language].check)..":", "sRacing.InputFont", ScrW()/2+a*3/2+(ScrH()/8-a*2)/2,  ScrH()/4*3+ScrH()/42+2, Color( 225, 225, 225, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 

	draw.SimpleText( (sRacing.currentRace.playerlist[LocalPlayer():EntIndex()].lap+1).."|"..race.laps, "sRacing.SelectFont", ScrW()/2-ScrH()/8+a/2+(ScrH()/8-a*2)/2,  ScrH()/4*3+ScrH()/64+4+ScrH()/1080*25, Color( 225, 225, 225, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
	draw.SimpleText( (sRacing.currentRace.playerlist[LocalPlayer():EntIndex()].checkpoint+1).."|"..#race.checkpoints, "sRacing.SelectFont", ScrW()/2+a*3/2+(ScrH()/8-a*2)/2,  ScrH()/4*3+ScrH()/64+4+ScrH()/1080*25, Color( 225, 225, 225, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 

	local checkpos = race.checkpoints[sRacing.currentRace.playerlist[LocalPlayer():EntIndex()].checkpoint+1]
	local plypos = LocalPlayer():GetPos()
	local vehang = LocalPlayer():GetVehicle():GetAngles()
	local rotation = ( Vector(checkpos.x,checkpos.y,0) - Vector(plypos.x,plypos.y,0) ):Angle() - Angle(vehang.x,vehang.y+90,0)


	surface.SetDrawColor(35,35,35,225)	
	surface.DrawRect( ScrW()/2-ScrH()/32, ScrH()/4*3+ScrH()/42+3, ScrH()/16, ScrH()/16 )
	surface.SetDrawColor(race.themecolor)	
	surface.DrawRect( ScrW()/2-ScrH()/32, ScrH()/4*3+ScrH()/42+3, ScrH()/16, 3 )

	surface.SetDrawColor(225, 225, 225, 255)	
	surface.SetMaterial(sRacing.IndicatorMat)
	surface.DrawTexturedRectRotated( ScrW()/2, ScrH()/4*3+ScrH()/42+3+ScrH()/32, ScrH()/16-6, ScrH()/16-6, rotation[2] )

	surface.SetMaterial(sRacing.CarTopMat)
	surface.DrawTexturedRect( ScrW()/2-ScrH()/64, ScrH()/4*3+ScrH()/42+3+ScrH()/64, ScrH()/32, ScrH()/32 )

end )

hook.Add( "Think", "sRacing.MusicControl", function()
	if(sRacing.MusicChan!=nil and (!IsValid(sRacing.MenuSelectionPanel) and !IsValid(sRacing.RaceInfoMenu) and LocalPlayer():GetNWString( "current_race", "" )=="") and !timer.Exists("sRacing.MusicFade")) then
		sRacing.StopMusic()
		return
	end
	if(timer.Exists("sRacing.MusicFade") and IsValid(sRacing.MusicChan)) then
		sRacing.MusicChan:SetVolume(timer.TimeLeft( "sRacing.MusicFade" )/4)
	end
	if(srConfig.EnableDynMusic and IsValid(sRacing.MusicChan) and LocalPlayer():InVehicle() and LocalPlayer():GetNWString( "current_race", "" )!="") then
		local volume = math.Clamp((LocalPlayer():GetVehicle().vehiclebase!=nil and (LocalPlayer():GetVehicle().vehiclebase:GetVelocity():Length()/53) or (LocalPlayer():GetVehicle():GetVelocity():Length()/53))/16,0.2,1.3)
		sRacing.MusicChan:SetVolume(volume)
	end
end)