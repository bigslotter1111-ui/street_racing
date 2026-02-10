if SERVER then return end

include( "autorun/sh_sracing.lua" )
include( "sracing_lang.lua" )

local function DrawInfoBox(index, text)
	local Box = vgui.Create( "DLabel", sRacing.Summary )
	Box:SetPos(2, sRacing.SaveMenu:GetTall()/8*index)
	Box:SetSize(sRacing.SaveMenu:GetWide()-4, sRacing.SaveMenu:GetTall()/8)
	Box:SetFont("sRacing.InputFont")
	Box:SetText(text)
	Box:SizeToContentsY( 6 ) 
	Box.Paint = function( self, w, h ) 
		surface.SetDrawColor((index%2==0) and Color(40,40,40) or Color(42,42,42))
		surface.DrawRect( 0, 0, w, h ) 
	end
end

local function CreateSummary()
	sRacing.Summary = vgui.Create( "DScrollPanel", sRacing.SaveMenu )
	sRacing.Summary:Dock( FILL )

	local CarListStr = "ANY"
	if(#sRacing.editedRace.allowedcars>0) then
		CarListStr = string.gsub(sRacing.editedRace.allowedcars," ","")
		CarListStr = string.gsub(sRacing.editedRace.allowedcars,",",",\n")
	end

	DrawInfoBox(0,string.upper(srConfig.Lang[srConfig.Language].name)..": "..sRacing.editedRace.name)
	DrawInfoBox(1,string.upper(srConfig.Lang[srConfig.Language].players)..": "..math.min(sRacing.editedRace.minplayers,#sRacing.editedRace.carstarts).."-"..#sRacing.editedRace.carstarts)
	DrawInfoBox(2,string.upper(srConfig.Lang[srConfig.Language].parreward)..": "..sRacing.editedRace.reward)
	DrawInfoBox(3,string.upper(srConfig.Lang[srConfig.Language].mainprize)..": "..sRacing.editedRace.winreward)
	DrawInfoBox(4,string.upper(srConfig.Lang[srConfig.Language].checkpoints)..": "..#sRacing.editedRace.checkpoints)
	DrawInfoBox(5,string.upper(srConfig.Lang[srConfig.Language].maxdur)..": "..sRacing.editedRace.maxduration)
	DrawInfoBox(6,string.upper(srConfig.Lang[srConfig.Language].illegal)..": "..(sRacing.editedRace.autowanted and "YES" or "NO"))
	DrawInfoBox(7,string.upper(srConfig.Lang[srConfig.Language].laps)..": "..sRacing.editedRace.laps)
	DrawInfoBox(8,string.upper(srConfig.Lang[srConfig.Language].collision)..": "..(sRacing.editedRace.autowanted and "YES" or "NO"))
	DrawInfoBox(9,string.upper(srConfig.Lang[srConfig.Language].allowedcars)..": "..CarListStr)

	local sbar = sRacing.Summary:GetVBar()
	function sbar:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 20, 20, 20, 100 ) )
	end
	function sbar.btnUp:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, sRacing.editedRace.themecolor )
	end
	function sbar.btnDown:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, sRacing.editedRace.themecolor )
	end
	function sbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(sRacing.editedRace.themecolor.r,sRacing.editedRace.themecolor.g,sRacing.editedRace.themecolor.b,100) )
	end
end

local function RemoveRace(name)
	net.Start( "sRacing.RemoveRequest" )
	net.WriteString( name )
	net.SendToServer()
end

local function CreateRaceList()
	if(!IsValid(sRacing.RaceListBg)) then return end
	sRacing.RaceList = vgui.Create( "DScrollPanel", sRacing.RaceListBg )
	sRacing.RaceList:Dock( FILL )

	local i = 1
	for k,v in pairs(sRacing.races) do
		local Box = vgui.Create( "DPanel", sRacing.RaceList )
		Box:SetPos(2, sRacing.RaceListBg:GetTall()/4*(i-1)+2)
		Box:SetSize(sRacing.RaceListBg:GetWide()-4, sRacing.RaceListBg:GetTall()/4)
		Box.Paint = function( self, w, h ) 
			local playeramt = 0
			for k, v in pairs(player.GetAll()) do
				if(v:GetNWString( "current_race", "" )==v.name) then playeramt=playeramt+1 end
			end
			local racestatus = v.lobbymode
			if(racestatus==0 or racestatus==1) then racestatus = srConfig.Lang[srConfig.Language].wforply..": ".." ("..playeramt.."/"..(#v.carstarts)..")" end
			if(racestatus==2) then racestatus = srConfig.Lang[srConfig.Language].alreadybegan end
			if(racestatus==3) then racestatus = srConfig.Lang[srConfig.Language].oncd end

			surface.SetDrawColor((i%2==0) and Color(40,40,40) or Color(42,42,42))
			surface.DrawRect( 1, 1, w-2, h-2 ) 
			surface.SetDrawColor(v.themecolor)
			surface.DrawRect( 1, 1, w-2, h/4+2 )
			surface.SetDrawColor(Color(50,50,50,245))
			surface.DrawRect( 1, 1, w-2, h/4+2 )
			draw.SimpleTextOutlined( string.upper(v.name), "sRacing.InputFont", 2, 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(20,20,20) ) 
			draw.SimpleText( string.upper(srConfig.Lang[srConfig.Language].created)..": "..v.creationtime, "sRacing.InputFont", 2, Box:GetTall()/3, Color( 255, 255, 255, 125 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) 
			draw.SimpleText( string.upper(srConfig.Lang[srConfig.Language].status)..": "..racestatus, "sRacing.InputFont", 2, Box:GetTall()*2/3, Color( 255, 255, 255, 125 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) 
		end

		local DeleteButton = vgui.Create('DButton', Box)
		DeleteButton:SetText( "" )
		DeleteButton:SetTall( Box:GetTall()/4 )
		DeleteButton:SetWide( Box:GetTall()/4 )
		DeleteButton:SetPos( Box:GetWide()-DeleteButton:GetTall()*3.1, Box:GetTall()/5+2 )
		DeleteButton.Paint = function( self, w, h )
			surface.SetDrawColor(v.themecolor)
			surface.DrawRect( 0, 0, w, h )
			surface.SetDrawColor(Color(50,50,50,245))
			surface.DrawRect( 0, 0, w, h )
			surface.SetDrawColor(self:IsHovered() and Color(255,255,255,155) or Color(255,255,255,75))
			surface.SetMaterial(sRacing.RemoveMat)
			surface.DrawTexturedRect( 1, 1, w-2, h-2 )
		end
		function DeleteButton:DoClick()
			RemoveRace(v.name)
		end

		local LoadButton = vgui.Create('DButton', Box)
		LoadButton:SetText( "" )
		LoadButton:SetTall( Box:GetTall()/4 )
		LoadButton:SetWide( Box:GetTall()/4 )
		LoadButton:SetPos( Box:GetWide()-LoadButton:GetTall()*1.9, Box:GetTall()/5+2 )
		LoadButton.Paint = function( self, w, h )
			surface.SetDrawColor(v.themecolor)
			surface.DrawRect( 0, 0, w, h )
			surface.SetDrawColor(Color(50,50,50,245))
			surface.DrawRect( 0, 0, w, h )
			surface.SetDrawColor(self:IsHovered() and Color(255,255,255,155) or Color(255,255,255,75))
			surface.SetMaterial(sRacing.LoadMat)
			surface.DrawTexturedRect( 1, 1, w-2, h-2 )
		end
		function LoadButton:DoClick()
			LocalPlayer():ChatPrint( srConfig.Lang[srConfig.Language].raceloaded1.." ("..v.name..") "..srConfig.Lang[srConfig.Language].raceloaded2 )
			table.remove(sRacing.editedRace)
			sRacing.editedRace = table.Copy( v )
			sRacing.Summary:Remove()
			CreateSummary()
		end
		i=i+1

	end

	local sbar = sRacing.RaceList:GetVBar()
	function sbar:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 20, 20, 20, 100 ) )
	end
	function sbar.btnUp:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, sRacing.editedRace.themecolor )
	end
	function sbar.btnDown:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, sRacing.editedRace.themecolor )
	end
	function sbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(sRacing.editedRace.themecolor.r,sRacing.editedRace.themecolor.g,sRacing.editedRace.themecolor.b,100) )
	end
end

local function CalculateRaceDistance(checkpoints)
	local dist = 0

	for k = 1, (table.Count(checkpoints)-1) do 
		dist = dist + Vector(checkpoints[k]):Distance(checkpoints[k+1])
	end 

	return dist/53
end

local function DrawInfoEntry(n, color, text, icon)
	local Box = vgui.Create( "DPanel", sRacing.RaceInfoMenuLeft)
	Box:SetSize(sRacing.RaceInfoMenuLeft:GetWide(), sRacing.RaceInfoMenuLeft:GetTall()/7)
	Box:SetPos(0, Box:GetTall()*n)
	Box.Paint = function( self, w, h ) 
		surface.SetDrawColor(n%2==0 and Color(20,20,20,45) or Color(20,20,20,75))
		surface.DrawRect( 0, 0, w, h )
		surface.SetDrawColor(Color(color.r,color.g,color.b,155))
		surface.DrawRect( w-3, 0, 3, h )
		draw.SimpleText(text,"sRacing.InputFont",Box:GetTall(),Box:GetTall()/2,Color(255,255,255,165),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
	end
	local Icon = vgui.Create( "DPanel", Box)
	Icon:SetSize(Box:GetTall()*0.7, Box:GetTall()*0.7)
	Icon:SetPos(Box:GetTall()*0.15, Box:GetTall()*0.15)
	Icon.Paint = function( self, w, h ) 
		surface.SetDrawColor(Color(color.r,color.g,color.b,n%2==0 and 155 or 185))
		surface.SetMaterial(icon)
		surface.DrawTexturedRect( 0, 0, w, h )
	end
end

function sRacing.OpenRaceMenu(race)
	if(IsValid(sRacing.RaceInfoMenu)) then return end

	sRacing.RaceInfoMenu = vgui.Create("DFrame")
	sRacing.RaceInfoMenu:SetSize(ScrH()/2, ScrH()/3)
	sRacing.RaceInfoMenu:SetPos(ScrW()/2-sRacing.RaceInfoMenu:GetWide()/2, ScrH()/2-sRacing.RaceInfoMenu:GetTall()/2)
	sRacing.RaceInfoMenu:SetTitle("")
	sRacing.RaceInfoMenu:MakePopup()
	sRacing.RaceInfoMenu:SetVisible(true)
	sRacing.RaceInfoMenu:ShowCloseButton(false)
	sRacing.RaceInfoMenu:SetDraggable(false)
	sRacing.RaceInfoMenu.Paint = function( self, w, h ) 
		surface.SetDrawColor(Color(20,20,20,255))
		surface.DrawRect( 0, 0, w, h ) 
		surface.SetDrawColor(Color(70,70,70,255))
		surface.DrawRect( 1, 1, w-2, h-2 ) 
		surface.SetDrawColor(Color(45,45,45,255))
		surface.DrawRect( 2, 2, w-4, h-4 ) 		

		surface.SetDrawColor(Color(20,20,20,85))
		surface.DrawRect( 0, 0, w, h*0.08 ) 

		draw.SimpleTextOutlined(race.name,"sRacing.SelectFont",sRacing.RaceInfoMenu:GetWide()/2,0,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,1,Color(20,20,20))

	end	

	local RaceInfoClose = vgui.Create('DButton', sRacing.RaceInfoMenu)
	RaceInfoClose:SetText( "" )
	RaceInfoClose:SetTall( sRacing.RaceInfoMenu:GetTall()*0.07-1 )
	RaceInfoClose:SetWide( sRacing.RaceInfoMenu:GetTall()*0.07-1 )
	RaceInfoClose:SetPos( sRacing.RaceInfoMenu:GetWide()-sRacing.RaceInfoMenu:GetTall()*0.07, 2)
	RaceInfoClose.Paint = function( self, w, h )
		surface.SetDrawColor(Color(255,255,255,self:IsHovered() and 55 or 155))

		surface.SetMaterial( sRacing.CloseButtonMat ) 
		surface.DrawTexturedRect( 2, 2, w-4, h-4 ) 
		
	end
	function RaceInfoClose:DoClick()
		sRacing.RaceInfoMenu:Remove()
		sRacing.StopMusic()
	end

	local Stripe = vgui.Create( "DPanel", sRacing.RaceInfoMenu )
	Stripe:SetSize(sRacing.RaceInfoMenu:GetWide()-2, 4)
	Stripe:SetPos(1, sRacing.RaceInfoMenu:GetTall()*0.08)
	Stripe.Paint = function( self, w, h ) 
		surface.SetDrawColor(Color(20,20,20,255))
		surface.DrawRect( 0, 0, w, h ) 	
		surface.SetDrawColor(race.themecolor)
		surface.DrawRect( 0, 1, w, h-1 ) 	

	end

	local RaceInfoMain = vgui.Create( "DPanel", sRacing.RaceInfoMenu )
	RaceInfoMain:SetSize(sRacing.RaceInfoMenu:GetWide()-4, sRacing.RaceInfoMenu:GetTall()-4-sRacing.RaceInfoMenu:GetTall()*0.08-1)
	RaceInfoMain:SetPos(2, sRacing.RaceInfoMenu:GetTall()*0.08+4)
	RaceInfoMain.Paint = function( self, w, h ) 
	end

	local PreviewWindow = vgui.Create( "DPanel", RaceInfoMain )
	PreviewWindow:SetSize(RaceInfoMain:GetWide(), RaceInfoMain:GetTall())
	PreviewWindow:SetPos(0, 0)
	PreviewWindow.Paint = function( self, w, h ) 
		if(race.previewpoint.position!=nil && race.previewpoint.angles!=nil) then
			local x, y = self:LocalToScreen() 
			render.RenderView( {
				origin = race.previewpoint.position,
				angles = race.previewpoint.angles,
				x = x, y = y,
				w = w, h = h
			} )
		end
		surface.SetDrawColor(Color(45,45,45,255))
		surface.DrawRect( 0, h*0.91, w, h*0.9+1 )
	end

	local Stripe2 = vgui.Create( "DPanel", sRacing.RaceInfoMenu )
	Stripe2:SetSize(sRacing.RaceInfoMenu:GetWide()-2, 4)
	Stripe2:SetPos(1, sRacing.RaceInfoMenu:GetTall()*0.92-4)
	Stripe2.Paint = function( self, w, h ) 
		surface.SetDrawColor(Color(20,20,20,255))
		surface.DrawRect( 0, 0, w, h ) 	
		surface.SetDrawColor(race.themecolor)
		surface.DrawRect( 0, 0, w, h-1 ) 	

	end

	sRacing.RaceInfoMenuLeft = vgui.Create( "DPanel", RaceInfoMain )
	sRacing.RaceInfoMenuLeft:SetSize(RaceInfoMain:GetWide()/2.3, RaceInfoMain:GetTall()*0.92)
	sRacing.RaceInfoMenuLeft:SetPos(0, 0)
	sRacing.RaceInfoMenuLeft.Paint = function( self, w, h ) 
		surface.SetDrawColor(Color(45,45,45,200))
		surface.DrawRect( 0, 0, w, h )
	end

	local RightPart = vgui.Create( "DPanel", RaceInfoMain )
	RightPart:SetSize(RaceInfoMain:GetWide()-RaceInfoMain:GetWide()/2.2+1, RaceInfoMain:GetTall()*0.92)
	RightPart:SetPos(RaceInfoMain:GetWide()/2.2, 0)
	RightPart.Paint = function( self, w, h ) 
	end

	local racedist = math.Round(CalculateRaceDistance(race.checkpoints),1)*race.laps
	
	DrawInfoEntry(0, race.themecolor, srConfig.Lang[srConfig.Language].players..": "..math.min(race.minplayers,#race.carstarts).."-"..#race.carstarts, sRacing.CarSpawnMat)
	DrawInfoEntry(3, race.themecolor, srConfig.Lang[srConfig.Language].parreward..": "..race.reward..srConfig.Lang[srConfig.Language].currency, sRacing.ParticipationPrizeMat)
	DrawInfoEntry(2, race.themecolor, srConfig.Lang[srConfig.Language].mainprize..": "..race.winreward..srConfig.Lang[srConfig.Language].currency, sRacing.WinPrizeMat)
	DrawInfoEntry(4, race.themecolor, srConfig.Lang[srConfig.Language].distance..": "..racedist.." "..srConfig.Lang[srConfig.Language].meters, sRacing.DistanceMat)
	DrawInfoEntry(1, race.themecolor, srConfig.Lang[srConfig.Language].legal..": "..(race.autowanted and srConfig.Lang[srConfig.Language].nofull or srConfig.Lang[srConfig.Language].yesfull), sRacing.PoliceMat)
	DrawInfoEntry(5, race.themecolor, srConfig.Lang[srConfig.Language].maxdur..": "..race.maxduration.." "..srConfig.Lang[srConfig.Language].second, sRacing.TimerMat)
	DrawInfoEntry(6, race.themecolor, srConfig.Lang[srConfig.Language].fee..": "..race.entryfee..srConfig.Lang[srConfig.Language].currency, sRacing.EntryFeeMat)

	local allowedcars
	if(string.len(string.gsub(race.allowedcars," ",""))>0) then
		allowedcars = string.Split( string.gsub(race.allowedcars," ",""), "," )
	else
		allowedcars = -1
	end

	if(allowedcars!=-1) then
		local ACarsMenu = vgui.Create( "DPanel", RightPart )
		ACarsMenu:SetSize(RightPart:GetWide()*0.8, RightPart:GetTall()*0.30)
		ACarsMenu:SetPos(RightPart:GetWide()*0.1, RightPart:GetTall()*0.05)
		ACarsMenu.Paint = function( self, w, h ) 
			surface.SetDrawColor(Color(45,45,45,200))
			surface.DrawRect( 0, 0, w, h ) 	
			surface.SetDrawColor(race.themecolor)
			surface.DrawRect( 0, 0, w, ScrH()/1080*15+2 ) 	
			draw.SimpleTextOutlined(string.upper(srConfig.Lang[srConfig.Language].allowedcars)..": ","sRacing.InputFont",w/2,0,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,1,Color(20,20,20))
		end

		local ACarsScrollBg = vgui.Create( "DPanel", ACarsMenu )
		ACarsScrollBg:SetSize(ACarsMenu:GetWide(), ACarsMenu:GetTall()-ScrH()/1080*15-2)
		ACarsScrollBg:SetPos(0, ScrH()/1080*15+2)
		ACarsScrollBg.Paint = function( self, w, h ) 
		end

		local ACarsScroll = vgui.Create( "DScrollPanel", ACarsScrollBg )
		ACarsScroll:Dock( FILL )
		for i=1, table.Count(allowedcars) do
			local vehname = list.Get("Vehicles")[allowedcars[i]]
			if( simfphys and !vehname ) then
				vehname = list.Get("simfphys_vehicles")[allowedcars[i]]
			end
			if(vehname) then 
				vehname = (vehname.Name)
			else
				vehname = string.upper(srConfig.Lang[srConfig.Language].unidentified).." ("..allowedcars[i]..")"
			end
			local CarInfoBox = vgui.Create( "DPanel", ACarsScroll )
			CarInfoBox:SetSize(ACarsScrollBg:GetWide(), ScrH()/1080*15+2)
			CarInfoBox:SetPos(0, (ScrH()/1080*15+2)*(i-1))
			CarInfoBox.Paint = function( self, w, h ) 
				surface.SetDrawColor(Color(30,30,30, i%2==0 and 140 or 70))
				surface.DrawRect( 0, 0, w, h ) 
				draw.SimpleText(vehname,"sRacing.InputFont",w/2,0,Color(255,255,255,175),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			end
		end

		local sbar = ACarsScroll:GetVBar()
		function sbar:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 20, 20, 20, 100 ) )
		end
		function sbar.btnUp:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, race.themecolor )
		end
		function sbar.btnDown:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, race.themecolor )
		end
		function sbar.btnGrip:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color(race.themecolor.r,race.themecolor.g,race.themecolor.b,100) )
		end
	end

	if(race.allowbet) then
		local BetMenu = vgui.Create( "DPanel", RightPart )
		BetMenu:SetSize(RightPart:GetWide()*0.6, RightPart:GetTall()*0.3)
		BetMenu:SetPos(RightPart:GetWide()*0.2, RightPart:GetTall()*0.4)
		BetMenu.Paint = function( self, w, h ) 

			surface.SetDrawColor(Color(45,45,45,200))
			surface.DrawRect( 0, 0, w, h ) 	
			surface.SetDrawColor(race.themecolor)
			surface.DrawRect( 0, 0, w, ScrH()/1080*15+2 ) 	


			draw.SimpleTextOutlined(string.upper(srConfig.Lang[srConfig.Language].bet)..": ","sRacing.InputFont",w/2,0,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,1,Color(20,20,20))

			draw.SimpleTextOutlined(string.upper(srConfig.Lang[srConfig.Language].yourbet)..": "..sRacing.currentBet..srConfig.Lang[srConfig.Language].currency,"sRacing.InputFont",2,h/2+ScrH()/1080*4+2,Color(215,215,215),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,1,Color(20,20,20))
			draw.SimpleTextOutlined(string.upper(srConfig.Lang[srConfig.Language].totalbet)..": "..((race.totalbet or 0)+sRacing.currentBet)..srConfig.Lang[srConfig.Language].currency,"sRacing.InputFont",2,h/2+ScrH()/1080*22+2,Color(215,215,215),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,1,Color(20,20,20))

		end

		local srNumEntry = vgui.Create( "DNumberWang", BetMenu )
		srNumEntry:SetPos( 0, ScrH()/1080*15+2 )
		srNumEntry:SetSize( BetMenu:GetWide()/3, BetMenu:GetTall()/3 )
		srNumEntry:SetMinMax( 0, srConfig.MaxBet )
		srNumEntry:HideWang(true)
		srNumEntry:SetDecimals( 0 )
		srNumEntry:SetValue( sRacing.currentBet )
		srNumEntry:SetFont( "sRacing.InputFont" )

		srNumEntry.Paint = function( self )
			surface.SetDrawColor(35, 35, 35)
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
			surface.DisableClipping( false ) 
			self:DrawTextEntryText(Color(255, 255, 255, 60), Color(55, 55, 55), Color(255, 255, 255))
		end

		local srSlider = vgui.Create( "DNumSlider", BetMenu )
		srSlider:SetPos( BetMenu:GetWide()/3+3, ScrH()/1080*15+2 )
		srSlider:SetSize( BetMenu:GetWide()*2/3-4, BetMenu:GetTall()/3 )
		srSlider:SetText( "" )
		srSlider:SetMax( srConfig.MaxBet )
		srSlider:SetMin( 0 )
		srSlider:SetDecimals( 0 )
		srSlider:SetDefaultValue( sRacing.currentBet )
		srSlider:SetValue(sRacing.currentBet)
		srSlider.Label:SetMouseInputEnabled( false )
		srSlider.Slider:Dock(NODOCK)
		srSlider.Slider:SetSize(srSlider:GetWide(),srSlider:GetTall())
		srSlider.TextArea.Paint = function( self )
		end
		srSlider.Slider.Paint = function( self )
			surface.SetDrawColor(33, 33, 33)
			surface.DrawRect(0, self:GetTall()/4, 2, self:GetTall()/2)
			surface.DrawRect(self:GetWide()-4, self:GetTall()/4, 2, self:GetTall()/2)
			surface.DrawRect(0, self:GetTall()/2-1, self:GetWide()-4, 2)
		end
		srSlider.Slider.Knob.Paint = function( self )
			surface.SetDrawColor(race.themecolor)
			surface.DrawRect(self:GetTall()/4, 0, self:GetTall()/2, self:GetTall())
		end
		srSlider.OnValueChanged = function( self )
			srNumEntry:SetValue(math.Round( self:GetValue(), 0 ))
			sRacing.currentBet = math.Round( self:GetValue(), 0 )
		end	

		srNumEntry.OnValueChange = function( self )
			self:SetValue(math.Clamp(self:GetValue(),0,srConfig.MaxBet))

			if (self:GetValue() > srConfig.MaxBet or self:GetValue() < 0) then
				self:SetText(math.Clamp(self:GetValue(),0,srConfig.MaxBet))
			end

			sRacing.currentBet = math.Round( self:GetValue(), 0 )
			srSlider:SetValue(math.Round( self:GetValue(), 0 ))
		end	
	end

	local StatusMenu = vgui.Create( "DPanel", RightPart )
	StatusMenu:SetSize(RightPart:GetWide()*0.8, RightPart:GetTall()*0.2)
	StatusMenu:SetPos(RightPart:GetWide()*0.1, RightPart:GetTall()*0.68)
	StatusMenu.Paint = function( self, w, h ) 
		local playeramt = 0
		for k, v in pairs(player.GetAll()) do
			if(v:GetNWString( "current_race", "" )==race.name) then playeramt=playeramt+1 end
		end

		local racestatus = race.lobbymode
		if(racestatus==0 or racestatus==1) then racestatus = string.upper(srConfig.Lang[srConfig.Language].wforply).." ("..playeramt.."/"..(#race.carstarts)..")" end
		if(racestatus==2) then racestatus = string.upper(srConfig.Lang[srConfig.Language].alreadybegan) end
		if(racestatus==3) then racestatus = string.upper(srConfig.Lang[srConfig.Language].oncd) end

		draw.SimpleTextOutlined(string.upper(srConfig.Lang[srConfig.Language].status)..":","sRacing.SelectFont",w/2,ScrH()/1080*10,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,1,Color(20,20,20))
		draw.SimpleTextOutlined(racestatus,"sRacing.InputFont",w/2,ScrH()/1080*30+2,race.themecolor,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,1,Color(20,20,20))

	end

	local JoinButton = vgui.Create('DButton', RightPart)
	JoinButton:SetText( "" )
	JoinButton:SetSize(RightPart:GetWide()*0.4, RightPart:GetTall()*0.1)
	JoinButton:SetPos(RightPart:GetWide()*0.3, RightPart:GetTall()*0.85)
	JoinButton.Paint = function( self, w, h )
		local racestatus = race.lobbymode
		surface.SetDrawColor(race.themecolor)
		surface.DrawRect( 0, 0, w, h ) 
		surface.SetDrawColor(Color(20,20,20,(racestatus==0 or racestatus==1) and 0 or 185))
		surface.DrawRect( 0, 0, w, h ) 
		draw.SimpleText(string.upper(srConfig.Lang[srConfig.Language].join),"sRacing.SelectFont",w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	function JoinButton:DoClick()
		net.Start( "sRacing.JoinRaceRequest" )
		net.WriteString( race.name )
		net.WriteUInt( sRacing.currentBet, 32 )
		net.SendToServer()
		surface.PlaySound( "buttons/button18.wav" )
		if(IsValid(sRacing.RaceInfoMenu)) then sRacing.RaceInfoMenu:Remove() end
		sRacing.StopMusic()
		sRacing.currentBet = 0
	end

end

local function GetRaceInfo(racename)
	return sRacing.races[racename]
end

net.Receive( "sRacing.UpdatePlayerList", function( len )
	local race_players = net.ReadTable() 

	sRacing.currentRace.playerlist = race_players
end)

net.Receive( "sRacing.SendRaceInfo", function( len )
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
	Race.creationtime = net.ReadString()
	Race.checktype = net.ReadUInt( 4 )
	Race.lobbymode = net.ReadUInt( 4 )


	sRacing.races[Race.name] = Race

	if(IsValid(sRacing.RaceList)) then
		sRacing.RaceList:Remove()
		CreateRaceList()
	end


end)

net.Receive( "sRacing.RemoveRequest", function( len )
	name = net.ReadString() 

	sRacing.races[name]=nil

	if(IsValid(sRacing.RaceList)) then
		sRacing.RaceList:Remove()
		CreateRaceList()
	end
end )

local function UploadRace()
	if(#sRacing.editedRace.checkpoints<2) then LocalPlayer():ChatPrint( srConfig.Lang[srConfig.Language].need2checks ) return end
	if(#sRacing.editedRace.carstarts==0) then LocalPlayer():ChatPrint( srConfig.Lang[srConfig.Language].needcarspawn ) return end
	if(#sRacing.editedRace.startpoint==0) then LocalPlayer():ChatPrint( srConfig.Lang[srConfig.Language].needmeetpoint ) return end
	if(table.Count( sRacing.editedRace.previewpoint )==0) then LocalPlayer():ChatPrint( srConfig.Lang[srConfig.Language].needpreview ) return end
	local fixedname = string.len(string.gsub(sRacing.editedRace.name,"%W",""))
	if(fixedname<3 or fixedname>24) then LocalPlayer():ChatPrint( srConfig.Lang[srConfig.Language].fixname ) return end
	net.Start( "sRacing.SendRaceInfo" )
	net.WriteString( sRacing.editedRace.name )
	net.WriteTable( sRacing.editedRace.musicurls )
	net.WriteString( sRacing.editedRace.allowedcars )
	net.WriteBool( sRacing.editedRace.collision )
	net.WriteUInt( sRacing.editedRace.winreward, 32)
	net.WriteUInt( sRacing.editedRace.entryfee, 16)
	net.WriteUInt( sRacing.editedRace.reward, 32)
	net.WriteUInt( sRacing.editedRace.minplayers, 7)
	net.WriteUInt( sRacing.editedRace.maxduration, 16)
	net.WriteUInt( sRacing.editedRace.laps, 16)
	net.WriteUInt( sRacing.editedRace.carstartsrot, 16)
	net.WriteBool( sRacing.editedRace.autowanted )
	net.WriteBool( sRacing.editedRace.allowbet )
	net.WriteTable( sRacing.editedRace.checkpoints )
	net.WriteTable( sRacing.editedRace.carstarts )
	net.WriteTable( sRacing.editedRace.startpoint )
	net.WriteTable( sRacing.editedRace.themecolor )
	net.WriteUInt( sRacing.editedRace.checksize, 16)
	net.WriteUInt( sRacing.editedRace.meetsize, 16)
	net.WriteTable( sRacing.editedRace.previewpoint )
	net.WriteUInt( sRacing.editedRace.checktype, 4)
	net.SendToServer()
end

local function DrawSrEntry(type, x, y, desc, value, hint, min, max)
	local srEntry = vgui.Create( "DPanel", sRacing.MenuConfigPanel )
	srEntry:SetPos( x, y )
	srEntry:SetSize( sRacing.MenuConfigPanel:GetWide()/2, sRacing.MenuConfigPanel:GetTall()/5 )
	srEntry.Paint = function( self, w, h ) 
		surface.SetDrawColor(sRacing.editedRace.themecolor)
		surface.DrawRect( 0, 0, 3, h/2 ) 	
		draw.SimpleText( desc, "sRacing.SelectFont", 8, h/4, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER ) 
	end

	if(hint!=nil and hint!="") then
		local tooltip = vgui.Create( "DPanel", srEntry )
		tooltip:SetPos( srEntry:GetWide()-srEntry:GetTall()/2+1, 3 )
		tooltip:SetSize( srEntry:GetTall()/2-6, srEntry:GetTall()/2-6 )
		tooltip.Paint = function( self, w, h ) 
			surface.SetDrawColor(Color(255,255,255, tooltip:IsHovered() and 155 or 2))
			surface.SetMaterial( sRacing.InfoMat )
			surface.DrawTexturedRect( 2, 2, w-4, h-4 )
			local height = (max==nil or min==nil) and 16 or 32
			if(self:IsHovered()) then
				surface.DisableClipping( true )
				surface.SetDrawColor(Color(sRacing.editedRace.themecolor.r,sRacing.editedRace.themecolor.g,sRacing.editedRace.themecolor.b,255))
				surface.DrawRect(w+3,h/2-19, surface.GetTextSize( hint )*0.7, height )
				surface.SetDrawColor(0,0,0)
				surface.DrawOutlinedRect(w+3,h/2-19, surface.GetTextSize( hint )*0.7, height )
				draw.SimpleTextOutlined( hint, "sRacing.InputFont", w+7, h/2-12, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(20,20,20) ) 
				draw.SimpleTextOutlined( ((max==nil or min==nil) and "" or srConfig.Lang[srConfig.Language].min..": "..min.." "..srConfig.Lang[srConfig.Language].max..": "..max), "sRacing.InputFont", w+7, h-12+ScrH()/1080*4, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(20,20,20) ) 
			else
				surface.DisableClipping( false ) 
			end
		end
	end

	if(type=="TEXT") then
		local srTextEntry = vgui.Create( "DTextEntry", srEntry )
		srTextEntry:SetPos( 0, srEntry:GetTall()/2 )
		srTextEntry:SetSize( srEntry:GetWide(), srEntry:GetTall()/2 )
		srTextEntry:SetText( sRacing.editedRace[value] )
		srTextEntry:SetFont( "sRacing.InputFont" )
		srTextEntry.OnChange = function( self )
			txt = self:GetValue()
			amt = string.len(txt)
			if amt > 1024 then
				self:SetText(self.OldText)
				self:SetValue(self.OldText)
			else
				self.OldText = txt
			end
			sRacing.editedRace[value] = self:GetValue()
		end	
		srTextEntry.Paint = function( self )
			surface.SetDrawColor(35, 35, 35)
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
			surface.DisableClipping( false ) 
			self:DrawTextEntryText(Color(255, 255, 255, 60), Color(55, 55, 55), Color(255, 255, 255))
		end
	end

	if(type=="NUMERIC") then
		local srNumEntry = vgui.Create( "DNumberWang", srEntry )
		srNumEntry:SetPos( 0, srEntry:GetTall()/2 )
		srNumEntry:SetSize( srEntry:GetWide()/3, srEntry:GetTall()/2 )
		srNumEntry:SetMinMax( min, max )
		srNumEntry:HideWang(true)
		srNumEntry:SetDecimals( 0 )
		srNumEntry:SetValue( sRacing.editedRace[value] )
		srNumEntry:SetFont( "sRacing.InputFont" )

		srNumEntry.Paint = function( self )
			surface.SetDrawColor(35, 35, 35)
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
			surface.DisableClipping( false ) 
			self:DrawTextEntryText(Color(255, 255, 255, 60), Color(55, 55, 55), Color(255, 255, 255))
		end

		local srSlider = vgui.Create( "DNumSlider", srEntry )
		srSlider:SetPos( srEntry:GetWide()/3+4, srEntry:GetTall()/2 )
		srSlider:SetSize( srEntry:GetWide()*2/3-8, srEntry:GetTall()/2 )
		srSlider:SetText( "" )
		srSlider:SetMax( max )
		srSlider:SetMin( min )
		srSlider:SetDecimals( 0 )
		srSlider:SetDefaultValue( sRacing.editedRace[value] )
		srSlider:SetValue(sRacing.editedRace[value])
		srSlider.Label:SetMouseInputEnabled( false )
		srSlider.Slider:Dock(NODOCK)
		srSlider.Slider:SetSize(srSlider:GetWide(),srSlider:GetTall())
		srSlider.TextArea.Paint = function( self )
		end
		srSlider.Slider.Paint = function( self )
			surface.SetDrawColor(33, 33, 33)
			surface.DrawRect(0, self:GetTall()/4, 2, self:GetTall()/2)
			surface.DrawRect(self:GetWide()-4, self:GetTall()/4, 2, self:GetTall()/2)
			surface.DrawRect(0, self:GetTall()/2-1, self:GetWide()-4, 2)
		end
		srSlider.Slider.Knob.Paint = function( self )
			surface.SetDrawColor(sRacing.editedRace.themecolor)
			surface.DrawRect(self:GetTall()/4, 0, self:GetTall()/2, self:GetTall())
		end
		srSlider.OnValueChanged = function( self )
			srNumEntry:SetValue(math.Round( self:GetValue(), 0 ))
			sRacing.editedRace[value] = math.Round( self:GetValue(), 0 )
		end	

		srNumEntry.OnValueChange = function( self )
			self:SetValue(math.Clamp(self:GetValue(),min,max))

			if (self:GetValue() > max or self:GetValue() < min) then
				self:SetText(math.Clamp(self:GetValue(),min,max))
			end
			
			sRacing.editedRace[value] = math.Round( self:GetValue(), 0 )
			srSlider:SetValue(math.Round( self:GetValue(), 0 ))
		end	

	end

	if(type=="BOOL") then

		local srCheckEntry = vgui.Create( "DCheckBox", srEntry )
		srCheckEntry:SetPos( srEntry:GetWide()-srEntry:GetWide()/6-6, srEntry:GetTall()/1.75 )
		srCheckEntry:SetSize( srEntry:GetWide()/6, srEntry:GetTall()/3 )
		srCheckEntry:SetValue( sRacing.editedRace[value] )
		srCheckEntry:SetChecked( sRacing.editedRace[value] )
		function srCheckEntry:OnChange( val )
			if ( val ) then
				sRacing.editedRace[value] = true
			else
				sRacing.editedRace[value] = false
			end 
		end	
		srCheckEntry.Paint = function( self )
			surface.SetDrawColor(75, 75, 75, 125)
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
			surface.SetDrawColor(sRacing.editedRace.themecolor)
			if(self:GetChecked()) then
				surface.DrawRect(1, 1, self:GetWide()/2-2, self:GetTall()-2)
			else
				surface.DrawRect(1+self:GetWide()/2, 1, self:GetWide()/2-2, self:GetTall()-2)
			end
			draw.SimpleText( string.upper(srConfig.Lang[srConfig.Language].yes), "sRacing.InputFont", self:GetWide()/4, self:GetTall()/2-1, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) 
			draw.SimpleText( string.upper(srConfig.Lang[srConfig.Language].no), "sRacing.InputFont", self:GetWide()/4*3, self:GetTall()/2-1, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) 
		end
	end
end

local function DrawRaceListMenu()
	sRacing.RaceListBg = vgui.Create( "DPanel", sRacing.MenuConfigPanel )
	sRacing.RaceListBg:SetSize(sRacing.MenuConfigPanel:GetWide()/2, sRacing.MenuConfigPanel:GetTall()*0.87)
	sRacing.RaceListBg:SetPos(sRacing.MenuConfigPanel:GetWide()/2, sRacing.MenuConfigPanel:GetTall()*0.13)
	sRacing.RaceListBg.Paint = function( self, w, h ) 
		surface.SetDrawColor(Color(0,0,0,75))
		surface.DrawRect( 0, 0, w, h ) 	

		surface.SetDrawColor(Color(20,20,20,75))
		surface.DrawOutlinedRect( 0, 0, w, h ) 
	end
	CreateRaceList()

	local SaveMenuBg = vgui.Create( "DPanel", sRacing.MenuConfigPanel )
	SaveMenuBg:SetSize(sRacing.MenuConfigPanel:GetWide()/2, sRacing.MenuConfigPanel:GetTall())
	SaveMenuBg:SetPos(0, 0)
	SaveMenuBg.Paint = function( self, w, h ) 
	end

	local SaveButton = vgui.Create('DButton', SaveMenuBg)
	SaveButton:SetText( "" )
	SaveButton:SetTall( SaveMenuBg:GetTall()/10 )
	SaveButton:SetWide( SaveMenuBg:GetWide()/3 )
	SaveButton:SetPos( SaveMenuBg:GetWide()/3, SaveMenuBg:GetTall()-4-SaveButton:GetTall() )
	SaveButton.Paint = function( self, w, h )
		surface.SetDrawColor(sRacing.editedRace.themecolor)
		surface.DrawRect( 0, 0, w, h ) 
		surface.SetDrawColor(Color(0,0,0,self:IsHovered() and 90 or 150))
		surface.DrawRect( 0, 0, w, h ) 
		draw.SimpleText( string.upper(srConfig.Lang[srConfig.Language].save), "sRacing.SelectFont", SaveButton:GetWide()/2, SaveButton:GetTall()/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) 
	end
	function SaveButton:DoClick()
		UploadRace()
	end

	sRacing.SaveMenu = vgui.Create( "DPanel", SaveMenuBg )
	sRacing.SaveMenu:SetSize(SaveMenuBg:GetWide()*0.9, SaveMenuBg:GetTall()*0.65)
	sRacing.SaveMenu:SetPos(SaveMenuBg:GetWide()*0.05, SaveMenuBg:GetWide()*0.2)
	sRacing.SaveMenu.Paint = function( self, w, h ) 
		surface.SetDrawColor(Color(35,35,35))
		surface.DrawRect( 0, 0, w, h ) 
	end
	CreateSummary()
end

local function DrawMusicMixer()
	if(!IsValid(sRacing.MenuConfigPanel)) then return end

	sRacing.MusicMenuBg = vgui.Create( "DPanel", sRacing.MenuConfigPanel )
	sRacing.MusicMenuBg:SetSize(sRacing.MenuConfigPanel:GetWide()/2, sRacing.MenuConfigPanel:GetTall()*3/5)
	sRacing.MusicMenuBg:SetPos(sRacing.MenuConfigPanel:GetWide()/2, sRacing.MenuConfigPanel:GetTall()*2/5)
	sRacing.MusicMenuBg.Paint = function( self, w, h ) 
		surface.SetDrawColor(Color(35,35,35))
		surface.DrawRect( 0, 0, w, h ) 	
	end

	local MusicMenuTop = vgui.Create( "DPanel", sRacing.MusicMenuBg )
	MusicMenuTop:SetSize(sRacing.MusicMenuBg:GetWide(), sRacing.MusicMenuBg:GetTall()*1/3)
	MusicMenuTop:SetPos(0, 0)
	MusicMenuTop.Paint = function( self, w, h ) 
		surface.SetDrawColor(Color(35,35,35))
		surface.DrawRect( 0, 0, w, h ) 	
		surface.SetDrawColor(Color(45,45,45))
		surface.DrawRect( 0, 0, w, h ) 	
		surface.SetDrawColor(Color(40,40,40))
		surface.DrawRect( 0, 0, w, MusicMenuTop:GetWide()/10+6) 	
		draw.SimpleText( string.upper(srConfig.Lang[srConfig.Language].thememusic), "sRacing.SelectFont", MusicMenuTop:GetWide()/2, MusicMenuTop:GetWide()/20+3, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )  
	end

	local tooltip = vgui.Create( "DPanel", MusicMenuTop )
	tooltip:SetSize( MusicMenuTop:GetWide()/10, MusicMenuTop:GetWide()/10 )
	tooltip:SetPos( MusicMenuTop:GetWide()-tooltip:GetWide(), 3 )
	tooltip.Paint = function( self, w, h ) 
		surface.SetDrawColor(Color(255,255,255, tooltip:IsHovered() and 155 or 2))
		surface.SetMaterial( sRacing.InfoMat )
		surface.DrawTexturedRect( 2, 2, w-4, h-4 )
		if(self:IsHovered()) then
			surface.DisableClipping( true )
			surface.SetDrawColor(sRacing.editedRace.themecolor)
			surface.DrawRect(w+3,h/2-19, surface.GetTextSize( srConfig.Lang[srConfig.Language].thememusicdesc1 )*0.7, 32 )
			surface.SetDrawColor(0,0,0)
			surface.DrawOutlinedRect(w+3,h/2-19, surface.GetTextSize( srConfig.Lang[srConfig.Language].thememusicdesc1 )*0.7, 32 )
			draw.SimpleTextOutlined( srConfig.Lang[srConfig.Language].thememusicdesc1, "sRacing.InputFont", w+7, h/2-13, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(20,20,20) ) 
			draw.SimpleTextOutlined(  srConfig.Lang[srConfig.Language].thememusicdesc2, "sRacing.InputFont", w+7, h-13+ScrH()/1080*4, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(20,20,20) ) 
		else
			surface.DisableClipping( false ) 
		end
	end


	local MusicMenuBot = vgui.Create( "DPanel", sRacing.MusicMenuBg )
	MusicMenuBot:SetSize(sRacing.MusicMenuBg:GetWide(), sRacing.MusicMenuBg:GetTall()*2/3+2)
	MusicMenuBot:SetPos(0, sRacing.MusicMenuBg:GetTall()/3)
	MusicMenuBot.Paint = function( self, w, h ) 
		surface.SetDrawColor(Color(33,33,33))
		surface.DrawRect( 0, 0, w, h ) 	
		surface.SetDrawColor(Color(27,27,27))
		surface.DrawOutlinedRect( 0, 0, w, h ) 	
	end

	local LinkTextEntry = vgui.Create( "DTextEntry", MusicMenuTop )
	LinkTextEntry:SetSize( MusicMenuTop:GetWide()*2/3, MusicMenuTop:GetTall()/3 )
	LinkTextEntry:SetPos( 4, MusicMenuTop:GetTall()-LinkTextEntry:GetTall()-4 )
	LinkTextEntry:SetText( sRacing.editedRace.LinkTextInput or "" )
	LinkTextEntry:SetFont( "sRacing.InputFont" )
	LinkTextEntry.OnChange = function( self )
		txt = self:GetValue()
		amt = string.len(txt)
		if amt > 1024 then
			self:SetText(self.OldText)
			self:SetValue(self.OldText)
		else
			self.OldText = txt
		end
		sRacing.editedRace.LinkTextInput = self:GetValue()
	end	
	LinkTextEntry.Paint = function( self )
		surface.SetDrawColor(35, 35, 35)
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		surface.DisableClipping( false ) 
		self:DrawTextEntryText(Color(255, 255, 255, 60), Color(55, 55, 55), Color(255, 255, 255))
	end

	local AddLinkB = vgui.Create('DButton', MusicMenuTop)
	AddLinkB:SetText( "" )
	AddLinkB:SetPos( 8+LinkTextEntry:GetWide(), MusicMenuTop:GetTall()-LinkTextEntry:GetTall()-4 )
	AddLinkB:SetSize( MusicMenuTop:GetWide()/3*0.9-2, MusicMenuTop:GetTall()/3 )
	AddLinkB.Paint = function( self, x, y )
		surface.SetDrawColor(sRacing.editedRace.themecolor)
		surface.DrawRect( 0, 0, x, y )
		surface.SetDrawColor(Color(0,0,0,(self:IsHovered() or id == sRacing.menuCurSelect) and 90 or 150))
		surface.DrawRect( 0, 0, x, y )
		draw.SimpleText( string.upper(srConfig.Lang[srConfig.Language].add), "sRacing.SelectFont", x/2, y/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) 
	end
	function AddLinkB:DoClick()
		if(string.gsub(sRacing.editedRace.LinkTextInput," ","")=="") then return end
		table.insert(sRacing.editedRace.musicurls, sRacing.editedRace.LinkTextInput)

		sRacing.MusicMenuBg:Remove()
		DrawMusicMixer()
	end

	local MusicMenuList = vgui.Create( "DScrollPanel", MusicMenuBot )
	MusicMenuList:Dock( FILL )

	local sbar = MusicMenuList:GetVBar()
	function sbar:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 20, 20, 20, 100 ) )
	end
	function sbar.btnUp:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, sRacing.editedRace.themecolor )
	end
	function sbar.btnDown:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, sRacing.editedRace.themecolor )
	end
	function sbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(sRacing.editedRace.themecolor.r,sRacing.editedRace.themecolor.g,sRacing.editedRace.themecolor.b,100) )
	end

	for k,v in pairs(sRacing.editedRace.musicurls) do

		local Box = vgui.Create( "DPanel", MusicMenuList )
		Box:SetPos(0, (MusicMenuBot:GetTall()/4-1)*(k-1))
		Box:SetSize(MusicMenuBot:GetWide(), MusicMenuBot:GetTall()/4)
		Box:SizeToContentsY( 6 ) 
		Box.Paint = function( self, w, h ) 
			surface.SetDrawColor((k%2==0) and Color(40,40,40) or Color(43,43,43))
			surface.DrawRect( 0, 0, w, h ) 
			surface.SetDrawColor(sRacing.editedRace.themecolor)
			surface.DrawRect( 0, 0, w/8, h ) 
			surface.SetDrawColor(Color(0,0,0,k%2==0 and 180 or 140))
			surface.DrawRect( 0, 0, w/8, h ) 
			draw.SimpleText( string.upper(srConfig.Lang[srConfig.Language].url), "sRacing.InputFont",  w/16, h/2, Color( 255, 255, 255, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
			draw.SimpleText( string.upper(string.sub(v,string.len(v)-25,string.len(v))), "sRacing.InputFont",  w/4, h/2, Color( 255, 255, 255, 165 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER ) 
		end

		local DelButton = vgui.Create('DButton', Box)
		DelButton:SetText( "" )
		DelButton:SetPos( Box:GetWide()*1/8+4, Box:GetTall()*0.1 )
		DelButton:SetSize( Box:GetTall()*0.8,  Box:GetTall()*0.8 )
		DelButton.Paint = function( self, x, y )
			surface.SetDrawColor(sRacing.editedRace.themecolor)
			surface.DrawRect( 0, 0, x, y )
			surface.SetDrawColor(Color(0,0,0,(self:IsHovered() or id == sRacing.menuCurSelect) and 90 or 150))
			surface.DrawRect( 0, 0, x, y )

			surface.SetDrawColor(Color(200,200,200,200))
			surface.SetMaterial(sRacing.RemoveMat)
			surface.DrawTexturedRect( 2, 2, x-4, y-4 )
			
		end
		function DelButton:DoClick()
			table.remove(sRacing.editedRace.musicurls, k)
			sRacing.MusicMenuBg:Remove()
			DrawMusicMixer()
		end
	end

end
local menuid = 0
local function DrawInterfaceSubMenu( id )
	if id == menuid then return end
	if(IsValid(sRacing.MenuConfigPanel)) then
		sRacing.MenuConfigPanel:Remove()
	end

	sRacing.MenuConfigPanel = vgui.Create( "DPanel", sRacing.CreationMenu )
	sRacing.MenuConfigPanel:SetSize(sRacing.CreationMenu:GetWide()-4, sRacing.CreationMenu:GetTall()*0.83-1)
	sRacing.MenuConfigPanel:SetPos(2, sRacing.CreationMenu:GetTall()*0.17)
	sRacing.MenuConfigPanel.Paint = function( self, w, h ) 
		surface.SetDrawColor(Color(0,0,0,75))
		surface.DrawRect( 0, 0, w, h ) 	
		if(id==2) then
			surface.SetDrawColor(sRacing.editedRace.themecolor)
			surface.DrawRect( 0, sRacing.MenuConfigPanel:GetTall()/5, sRacing.MenuConfigPanel:GetWide()/2, 4) 
			surface.SetDrawColor(Color(46,46,46))
			surface.DrawRect( 0, sRacing.MenuConfigPanel:GetTall()/5+6, sRacing.MenuConfigPanel:GetWide()/2, sRacing.MenuConfigPanel:GetTall()*4/5-6) 

			surface.SetDrawColor(Color(39,39,39))
			surface.DrawRect( 0, sRacing.MenuConfigPanel:GetTall()/5+6, sRacing.MenuConfigPanel:GetWide()/2, sRacing.MenuConfigPanel:GetTall()/11) 

			draw.SimpleTextOutlined( string.upper(srConfig.Lang[srConfig.Language].racecolor), "sRacing.SelectFont", sRacing.MenuConfigPanel:GetWide()/4, sRacing.MenuConfigPanel:GetTall()/5+6, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(20,20,20) ) 
		end

		if(id==3) then
			surface.SetDrawColor(sRacing.editedRace.themecolor)
			surface.DrawRect( 0, sRacing.MenuConfigPanel:GetTall()*0.13-6, sRacing.MenuConfigPanel:GetWide(), 6 ) 
			surface.SetDrawColor(Color(255,255,255))
			draw.SimpleText( string.upper(srConfig.Lang[srConfig.Language].uploadedraces), "sRacing.SelectFont", sRacing.MenuConfigPanel:GetWide()/4*3, sRacing.MenuConfigPanel:GetTall()*0.05, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) 
			draw.SimpleText( string.upper(srConfig.Lang[srConfig.Language].currentrace), "sRacing.SelectFont", sRacing.MenuConfigPanel:GetWide()/4, sRacing.MenuConfigPanel:GetTall()*0.05, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) 
		end
	end

	if(id==1) then
		DrawSrEntry("BOOL", sRacing.MenuConfigPanel:GetWide()/2, sRacing.MenuConfigPanel:GetTall()/5*4, srConfig.Lang[srConfig.Language].illegal, "autowanted", srConfig.Lang[srConfig.Language].illegalhint)
		DrawSrEntry("NUMERIC", sRacing.MenuConfigPanel:GetWide()/2, sRacing.MenuConfigPanel:GetTall()/5, srConfig.Lang[srConfig.Language].laps, "laps", srConfig.Lang[srConfig.Language].laphint, 1, 50)
		DrawSrEntry("TEXT", sRacing.MenuConfigPanel:GetWide()/2, 0, srConfig.Lang[srConfig.Language].allowedcars, "allowedcars", srConfig.Lang[srConfig.Language].allowedcarshint)
		DrawSrEntry("NUMERIC", sRacing.MenuConfigPanel:GetWide()/2, sRacing.MenuConfigPanel:GetTall()/5*2, srConfig.Lang[srConfig.Language].carrotation, "carstartsrot", srConfig.Lang[srConfig.Language].caranglehint, 0, 360)
		DrawSrEntry("BOOL", sRacing.MenuConfigPanel:GetWide()/2, sRacing.MenuConfigPanel:GetTall()/5*3, srConfig.Lang[srConfig.Language].collision, "collision", srConfig.Lang[srConfig.Language].collisionhint)
		DrawSrEntry("BOOL", sRacing.MenuConfigPanel:GetWide()/2, sRacing.MenuConfigPanel:GetTall()/5*5, srConfig.Lang[srConfig.Language].allowbet, "allowbet", srConfig.Lang[srConfig.Language].bethint)

		DrawSrEntry("TEXT", 0, 0, srConfig.Lang[srConfig.Language].name, "name", srConfig.Lang[srConfig.Language].namehint)
		DrawSrEntry("NUMERIC", 0, sRacing.MenuConfigPanel:GetTall()/5, srConfig.Lang[srConfig.Language].mainprize, "winreward", srConfig.Lang[srConfig.Language].winhint, 0, 1000000)
		DrawSrEntry("NUMERIC", 0, sRacing.MenuConfigPanel:GetTall()/5*2, srConfig.Lang[srConfig.Language].parreward, "reward", srConfig.Lang[srConfig.Language].parhint, 0, 1000000)
		DrawSrEntry("NUMERIC", 0, sRacing.MenuConfigPanel:GetTall()/5*3, srConfig.Lang[srConfig.Language].minplayers, "minplayers", srConfig.Lang[srConfig.Language].minplayershint, 1, 32)
		DrawSrEntry("NUMERIC", 0, sRacing.MenuConfigPanel:GetTall()/5*4, srConfig.Lang[srConfig.Language].maxdur, "maxduration", srConfig.Lang[srConfig.Language].maxdurhint, 12, 3600)
		DrawSrEntry("NUMERIC", 0, sRacing.MenuConfigPanel:GetTall()/5*5, srConfig.Lang[srConfig.Language].fee, "entryfee", srConfig.Lang[srConfig.Language].feehint, 0, 250000) 

		if(menuid!=1) then
			local screenx,screeny = sRacing.CreationMenu:GetPos();
			local entryh = sRacing.MenuConfigPanel:GetTall()/5
			sRacing.CreationMenu:SetPos(screenx, screeny-entryh+1)
			sRacing.CreationMenu:SetTall(sRacing.CreationMenu:GetTall()+entryh)
			sRacing.MenuConfigPanel:SetSize(sRacing.CreationMenu:GetSize())
			menuid = 1
		end
	end
	if(id==2) then

		sRacing.CreationMenu:SetSize(ScrH()/2, ScrH()/3)
		sRacing.CreationMenu:SetPos(ScrW()/2-sRacing.CreationMenu:GetWide()/2, ScrH()-sRacing.CreationMenu:GetTall()-10)
		sRacing.MenuConfigPanel:SetSize(sRacing.CreationMenu:GetWide()-4, sRacing.CreationMenu:GetTall()*0.83-1)
		sRacing.MenuConfigPanel:SetPos(2, sRacing.CreationMenu:GetTall()*0.17)

		DrawMusicMixer()

		DrawSrEntry("NUMERIC", sRacing.MenuConfigPanel:GetWide()/2, 0, srConfig.Lang[srConfig.Language].meetsize, "meetsize", srConfig.Lang[srConfig.Language].meetsizehint,50,170)
		DrawSrEntry("NUMERIC", sRacing.MenuConfigPanel:GetWide()/2, sRacing.MenuConfigPanel:GetTall()*1/5, srConfig.Lang[srConfig.Language].checksize, "checksize", srConfig.Lang[srConfig.Language].checksizehint,200,400)
		DrawSrEntry("NUMERIC", 0, 0, srConfig.Lang[srConfig.Language].checktype, "checktype", srConfig.Lang[srConfig.Language].checkpointhint, 0, 2)

		local MixerFrame = vgui.Create( "DPanel", sRacing.MenuConfigPanel)
		MixerFrame:SetSize( sRacing.MenuConfigPanel:GetWide()*0.5-8, sRacing.MenuConfigPanel:GetTall()*0.6 )
		MixerFrame:SetPos(4, sRacing.MenuConfigPanel:GetTall()-MixerFrame:GetTall()*1.1)
		MixerFrame.Paint = function( self, w, h ) 

			surface.SetDrawColor(Color(40,40,40))
			surface.DrawRect( 0, 0, w, h )	
			surface.SetDrawColor(Color(30,30,30))
			surface.DrawOutlinedRect( 0, 0, w, h )	
		end

		local Mixer = vgui.Create( "DColorMixer", MixerFrame )
		Mixer:Dock( FILL )
		Mixer:SetPalette( false )
		Mixer:SetAlphaBar( false )
		Mixer:SetWangs( true )
		Mixer:SetColor( sRacing.editedRace.themecolor )

		Mixer.txtR:SetFont( "sRacing.InputFont" )
		Mixer.txtR.Paint = function( self, w, h ) 
			surface.DisableClipping( false ) 
			surface.SetDrawColor(30, 30, 30)
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
			self:DrawTextEntryText(Color(255, 255, 255, 60), Color(55, 55, 55), Color(255, 255, 255))
		end
		Mixer.txtG:SetFont( "sRacing.InputFont" )
		Mixer.txtG.Paint = function( self, w, h ) 
			surface.DisableClipping( false ) 
			surface.SetDrawColor(30, 30, 30)
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
			self:DrawTextEntryText(Color(255, 255, 255, 60), Color(55, 55, 55), Color(255, 255, 255))
		end
		Mixer.txtB:SetFont( "sRacing.InputFont" )
		Mixer.txtB.Paint = function( self, w, h ) 
			surface.DisableClipping( false ) 
			surface.SetDrawColor(30, 30, 30)
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
			self:DrawTextEntryText(Color(255, 255, 255, 60), Color(55, 55, 55), Color(255, 255, 255))
		end

		function Mixer:ValueChanged(color)
			sRacing.editedRace.themecolor = color
		end
		menuid = 2
	end

	if(id==3) then
		sRacing.CreationMenu:SetSize(ScrH()/2, ScrH()/3)
		sRacing.CreationMenu:SetPos(ScrW()/2-sRacing.CreationMenu:GetWide()/2, ScrH()-sRacing.CreationMenu:GetTall()-10)
		sRacing.MenuConfigPanel:SetSize(sRacing.CreationMenu:GetWide()-4, sRacing.CreationMenu:GetTall()*0.83-1)
		sRacing.MenuConfigPanel:SetPos(2, sRacing.CreationMenu:GetTall()*0.17)

		DrawRaceListMenu()
		menuid = 3
	end
end

local function DrawInterfaceSelectionButton( id, w, h)
	if(!IsValid(sRacing.MenuSelectionPanel)) then return end
	
	sRacing.SelectionButton = vgui.Create('DButton', sRacing.MenuSelectionPanel)
	sRacing.SelectionButton:SetText( "" )
	sRacing.SelectionButton:SetTall( h-8 )
	sRacing.SelectionButton:SetWide( w/#sRacing.menuList-2 )
	sRacing.SelectionButton:SetPos((w/#sRacing.menuList)*(id-1)+1, 4)
	sRacing.SelectionButton.Paint = function( self, x, y )
		surface.SetDrawColor(Color(0,0,0,(self:IsHovered() or id == sRacing.menuCurSelect) and 90 or 150))
		surface.DrawRect( 0, 0, x, y )
		draw.SimpleText( sRacing.menuList[id].name, "sRacing.SelectFont", x/2, y/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) 
	end
	function sRacing.SelectionButton:DoClick()
		DrawInterfaceSubMenu( id )
		sRacing.menuCurSelect = id
	end
end

function sRacing.DrawConfigInterface()
	if(IsValid(sRacing.CreationMenu)) then return end

	sRacing.StartMusic(sRacing.editedRace.musicurls)

	sRacing.CreationMenu = vgui.Create("DFrame")
	sRacing.CreationMenu:SetSize(ScrH()/2, ScrH()/3)
	sRacing.CreationMenu:SetPos(ScrW()/2-sRacing.CreationMenu:GetWide()/2, ScrH()-sRacing.CreationMenu:GetTall()-10)
	sRacing.CreationMenu:SetTitle("")
	sRacing.CreationMenu:MakePopup()
	sRacing.CreationMenu:SetVisible(true)
	sRacing.CreationMenu:ShowCloseButton(false)
	sRacing.CreationMenu:SetDraggable(false)
	sRacing.CreationMenu.Paint = function( self, w, h ) 
		surface.SetDrawColor(Color(20,20,20,255))
		surface.DrawRect( 0, 0, w, h ) 
		surface.SetDrawColor(Color(70,70,70,255))
		surface.DrawRect( 1, 1, w-2, h-2 ) 
		surface.SetDrawColor(Color(45,45,45,255))
		surface.DrawRect( 2, 2, w-4, h-4 ) 		

	end	

	local CloseButton = vgui.Create('DButton', sRacing.CreationMenu)
	CloseButton:SetText( "" )
	CloseButton:SetTall( sRacing.CreationMenu:GetTall()*0.07-1 )
	CloseButton:SetWide( sRacing.CreationMenu:GetTall()*0.07-1 )
	CloseButton:SetPos( sRacing.CreationMenu:GetWide()-sRacing.CreationMenu:GetTall()*0.07, 2)
	CloseButton.Paint = function( self, x, y )
		surface.SetDrawColor(Color(255,255,255,self:IsHovered() and 55 or 155))

		surface.SetMaterial( sRacing.CloseButtonMat ) 
		surface.DrawTexturedRect( 2, 2, x-4, y-4 ) 
		
	end
	function CloseButton:DoClick()
		sRacing.CreationMenu:Remove()
		menuid = 0
		//sRacing.StopMusic()
	end

	if(IsValid(sRacing.MenuSelectionPanel)) then return end

	sRacing.MenuSelectionPanel = vgui.Create( "DPanel", sRacing.CreationMenu )
	sRacing.MenuSelectionPanel:SetSize(sRacing.CreationMenu:GetWide()-4, sRacing.CreationMenu:GetTall()*0.10)
	sRacing.MenuSelectionPanel:SetPos(2, sRacing.CreationMenu:GetTall()*0.07)
	sRacing.MenuSelectionPanel.Paint = function( self, w, h ) 
		surface.SetDrawColor(Color(70,70,70,255))
		surface.DrawRect( 0, 0, w, h ) 	

		surface.SetDrawColor(sRacing.editedRace.themecolor)
		surface.DrawRect( 0, 2, w, h-4 ) 	
	end

	for k = 1, (#sRacing.menuList) do 
		DrawInterfaceSelectionButton(k, sRacing.CreationMenu:GetWide()-4, sRacing.CreationMenu:GetTall()*0.10)
	end 

	DrawInterfaceSubMenu( sRacing.menuCurSelect )
end