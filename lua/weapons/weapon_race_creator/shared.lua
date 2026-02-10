include( "sracing_config.lua" )
include( "sracing_interface.lua" )
include( "sracing_lang.lua" )

SWEP.PrintName = "Race Creator"
SWEP.Author	= "D3G"
SWEP.Instructions = ""
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom	= false

SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Category = "Street Racing"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
	self:SetHoldType("normal")
end

if SERVER then return end

local function CheckWeapon( weapon )
	if(!IsValid(LocalPlayer():GetActiveWeapon())) then return false end
	if(LocalPlayer():GetActiveWeapon():GetClass()!=weapon) then return false end
	return true
end

local function DrawMeetPoint(pos)
	local dist = LocalPlayer():GetPos():DistToSqr(pos)/4000
	if(dist>4000) then return end
	//render.DrawWireframeSphere( pos, sRacing.editedRace.meetsize, sRacing.editedRace.meetsize/5, sRacing.editedRace.meetsize/5, Color(255,255,255), true ) 
	cam.Start3D2D(pos+Vector(0,0,1), Angle(0,0,0), 2 )
	surface.SetDrawColor( Color(sRacing.editedRace.themecolor.r,sRacing.editedRace.themecolor.g,sRacing.editedRace.themecolor.b, 235))
	surface.SetMaterial(sRacing.MeetCircleMat)
	surface.DrawTexturedRect( -sRacing.editedRace.meetsize/2, -sRacing.editedRace.meetsize/2, sRacing.editedRace.meetsize, sRacing.editedRace.meetsize )
	cam.End3D2D()

	cam.Start3D2D(pos+Vector(0,0,130), Angle(0, (LocalPlayer():GetViewEntity():GetPos() - (pos+Vector(0,0,100))):Angle().y+90, 90), 0.5 )
	surface.SetMaterial(sRacing.CheckerboardMat)
	surface.SetDrawColor( Color(20,20,20) )
	surface.DrawTexturedRect( -28, -59, 54, 40 )
	surface.SetDrawColor( sRacing.editedRace.themecolor )
	surface.DrawTexturedRect( -27, -58, 54, 40 )

	draw.SimpleTextOutlined( sRacing.editedRace.name, "sRacing.WorldFont", 0,  0, sRacing.editedRace.themecolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 
	draw.SimpleTextOutlined( srConfig.Lang[srConfig.Language].mainprize..": "..sRacing.editedRace.winreward..srConfig.Lang[srConfig.Language].currency, "sRacing.ToolFont", 0,  ScrH()/24, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 
	cam.End3D2D()
end

local function DrawCarSpawn(pos)
	local dist = LocalPlayer():GetPos():DistToSqr(pos)/4000
	if(dist>4000) then return end
	cam.Start3D2D( pos+Vector(0,0,1), Angle(0,sRacing.editedRace.carstartsrot,0), 0.5 )
	surface.SetDrawColor( Color(sRacing.editedRace.themecolor.r,sRacing.editedRace.themecolor.g,sRacing.editedRace.themecolor.b, 235) )
	surface.SetMaterial(sRacing.CarBoxMat)
	surface.DrawTexturedRect( -220, -120, 440, 240 )
	cam.End3D2D()
	cam.Start3D2D( pos+Vector(0,0,1), Angle(0,sRacing.editedRace.carstartsrot+90,0), 0.5 )
	draw.SimpleText( string.upper(srConfig.Lang[srConfig.Language].front), "sRacing.WorldFont", 0,  -180, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) 
	draw.SimpleText( string.upper(srConfig.Lang[srConfig.Language].rear), "sRacing.WorldFont", 0,  180, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) 
	cam.End3D2D()
end

function PointOnCircle( ang, radius, offX, offY )
	ang = math.rad( ang )
	local x = math.cos( ang ) * radius + offX
	local y = math.sin( ang ) * radius + offY
	return x, y
end

local function DrawCheckpoint(pos, num, type)

	local dist = LocalPlayer():GetPos():DistToSqr(pos)/4000
	if(dist>4000) then return end

	if(type==0) then		
		cam.Start3D2D(pos, Angle(0, (LocalPlayer():GetViewEntity():GetPos() - (pos+Vector(0,0,100))):Angle().y+90, 90), 0.5 )
		surface.SetDrawColor(Color(sRacing.editedRace.themecolor.r,sRacing.editedRace.themecolor.g,sRacing.editedRace.themecolor.b,200))
		surface.SetMaterial(sRacing.CheckCircleMat)
		surface.DrawTexturedRect( -sRacing.editedRace.checksize*2, -sRacing.editedRace.checksize*2, sRacing.editedRace.checksize*4, sRacing.editedRace.checksize*4 )

		local interval = 360 / (sRacing.editedRace.checksize/16)+5
		local centerX, centerY = 0, 0
		local radius = sRacing.editedRace.checksize*1.8

		for degrees = 1, 360, interval do 
			local currotation = degrees+CurTime()*5%360
			local x, y = PointOnCircle( currotation, radius, centerX, centerY )
			surface.SetMaterial(sRacing.CheckArrowMat)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRectRotated( x, y, 40, 100, -currotation+0 )
		end
		cam.End3D2D()

		cam.Start3D2D(pos+Vector(0,0,sRacing.editedRace.checksize*0.65), Angle(0, (LocalPlayer():GetPos() - (pos+Vector(0,0,100))):Angle().y+90, 90), 0.5 )
		draw.SimpleTextOutlined( string.upper(srConfig.Lang[srConfig.Language].checkpoint), "sRacing.WorldFontLarge", 0,  -2, sRacing.editedRace.themecolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20))
		if(num>0) then
			draw.SimpleTextOutlined( num.."/"..#sRacing.editedRace.checkpoints, "sRacing.WorldFont", 0,  ScrH()/20+6, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 
		end
		
		cam.End3D2D()
	end

	if(type==1) then
		local distmul = math.Clamp(sRacing.editedRace.checksize*0.8*(math.Clamp(LocalPlayer():GetPos():DistToSqr(pos)/(sRacing.editedRace.checksize*sRacing.editedRace.checksize*16),0,sRacing.editedRace.checksize*4)), sRacing.editedRace.checksize*0.4, sRacing.editedRace.checksize*0.8)

		cam.Start3D2D(pos+Vector(0,0,distmul), Angle(0, (LocalPlayer():GetViewEntity():GetPos() - (pos+Vector(0,0,100))):Angle().y+90, 90), 0.5 )
		draw.SimpleTextOutlined( string.upper(srConfig.Lang[srConfig.Language].checkpoint), "sRacing.WorldFontLarge", 0,  -2, sRacing.editedRace.themecolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20))
		if(num>0) then
			draw.SimpleTextOutlined( num.."/"..#sRacing.editedRace.checkpoints, "sRacing.WorldFont", 0,  ScrH()/20+6, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 
		else
			draw.SimpleTextOutlined( "-/-", "sRacing.WorldFont", 0,  ScrH()/20+6, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 
		end
		surface.SetDrawColor(20, 20, 20)
		surface.SetDrawColor(255, 255, 255, 155)
		surface.DrawRect( -2, 104, 4, sRacing.editedRace.checksize*2+distmul) 
		surface.DrawRect( -12, 100, 24, 4) 
		surface.DrawRect( -12, sRacing.editedRace.checksize*2+distmul+100, 24, 4) 
		cam.End3D2D()
	end

	if(type==2) then
		cam.Start3D2D(pos+Vector(0,0,sRacing.editedRace.checksize*0.75), Angle(0, (LocalPlayer():GetViewEntity():GetPos() - (pos+Vector(0,0,100))):Angle().y+90, 90), 0.5 )
		draw.SimpleTextOutlined( string.upper(srConfig.Lang[srConfig.Language].check), "sRacing.WorldFontLarge", 0,  -2, sRacing.editedRace.themecolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20))
		if(num>0) then
			draw.SimpleTextOutlined( num.."/"..#sRacing.editedRace.checkpoints, "sRacing.WorldFont", 0,  ScrH()/20+6, sRacing.editedRace.themecolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 
		else
			draw.SimpleTextOutlined( "-/-", "sRacing.WorldFont", 0,  ScrH()/20+6, sRacing.editedRace.themecolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 
		end
		surface.SetMaterial(sRacing.RightArrowMat)
		surface.SetDrawColor(sRacing.editedRace.themecolor)
		surface.DrawTexturedRectRotated(0,110,50,50,-90)

		cam.End3D2D()
	end
end

local function DrawPreviewPoint(pos,ang)
	if(!IsValid(sRacing.editedRace.previewmodel)) then
		sRacing.editedRace.previewmodel = ClientsideModel( "models/maxofs2d/camera.mdl", RENDERGROUP_OPAQUE )
	end

	sRacing.editedRace.previewmodel:SetPos(sRacing.editedRace.previewpoint.position+Vector(0,0,5))
	sRacing.editedRace.previewmodel:SetAngles(sRacing.editedRace.previewpoint.angles)
	sRacing.editedRace.previewmodel:SetModelScale( 3 ) 
	sRacing.editedRace.previewmodel:SetMaterial( "models/wireframe" ) 

	sRacing.editedRace.previewmodel:SetColor(sRacing.editedRace.themecolor)

	sRacing.editedRace.previewmodel:Remove()
end

local function DrawIndicators()
	if(LocalPlayer():InVehicle()) then return end
	tr = util.TraceLine( {
		start = LocalPlayer():GetShootPos(),
		endpos = LocalPlayer():GetShootPos() + LocalPlayer():EyeAngles():Forward() * 500,
		filter = function(ent) if (ent:GetClass() == "world") then return true end end
	} )
	
	if(sRacing.CurSelect==1) then
		DrawCheckpoint(tr.HitPos,0,sRacing.editedRace.checktype)
	end
	if(sRacing.CurSelect==2) then
		DrawCarSpawn(tr.HitPos)
	end
	if(sRacing.CurSelect==3) then
		DrawMeetPoint(tr.HitPos)
	end
	if(sRacing.CurSelect==4) then return end
	render.DrawWireframeSphere( tr.HitPos, 5, 8, 8, Color(sRacing.editedRace.themecolor.r,sRacing.editedRace.themecolor.g,sRacing.editedRace.themecolor.b,100), true ) 
end

local function DrawEditorPoints()
	if(LocalPlayer():InVehicle()) then return end
	// Draw during the edition process
	if(sRacing.editedRace.startpoint[1]!=nil) then
		DrawMeetPoint(Vector(sRacing.editedRace.startpoint[1]))
	end

	if(sRacing.editedRace.previewpoint.position!=nil) then
		DrawPreviewPoint(Vector(sRacing.editedRace.previewpoint.position), Angle(sRacing.editedRace.previewpoint.angles))
	end

	for k,v in pairs(sRacing.editedRace.carstarts) do
		DrawCarSpawn(Vector(v))
	end

	for k,v in pairs(sRacing.editedRace.checkpoints) do
		DrawCheckpoint(Vector(v), k, sRacing.editedRace.checktype)
	end
end

hook.Add( "PostDrawTranslucentRenderables", "sRacing.DrawIndicator", function()
	if(!CheckWeapon( "weapon_race_creator" )) then return end
	DrawIndicators()
	DrawEditorPoints()
end)

hook.Add( "Think", "sRacing.DrawConfigInterface", function()
	if(LocalPlayer():InVehicle()) then return end
	if(LocalPlayer():IsTyping()) then return end
	if(!CheckWeapon( "weapon_race_creator" )) then
		if(IsValid(srCreationMenu)) then srCreationMenu:Remove() end
		return end

		if(input.IsKeyDown( srConfig.ToggleMenuKey )) then
			sRacing.DrawConfigInterface()
			sRacing.menuCurSelect = sRacing.menuCurSelect
		end
end)


function SWEP:DrawHUD()
	if(LocalPlayer():InVehicle()) then return end
	surface.SetDrawColor(Color(20,20,20,255))		
	surface.DrawRect( ScrW()/2-ScrH()/6, ScrH()/4*3, ScrH()/3, ScrH()/16 ) 	
	surface.SetDrawColor(Color(70,70,70,255))
	surface.DrawRect( ScrW()/2-ScrH()/6+1, ScrH()/4*3+1, ScrH()/3-2, ScrH()/16-2 ) 	
	surface.SetDrawColor(Color(45,45,45,255))
	surface.DrawRect( ScrW()/2-ScrH()/6+2, ScrH()/4*3+2, ScrH()/3-4, ScrH()/16-4 ) 

	surface.SetDrawColor(Color(sRacing.editedRace.themecolor.r,sRacing.editedRace.themecolor.g,sRacing.editedRace.themecolor.b,70))	
	surface.DrawRect( ScrW()/2-ScrH()/6+2, ScrH()/4*3+2, ScrH()/18-4, ScrH()/16-4 ) 
	surface.DrawRect( ScrW()/2+ScrH()/6+2-ScrH()/18, ScrH()/4*3+2, ScrH()/18-4, ScrH()/16-4 ) 

	surface.SetDrawColor(Color(255,255,255,120))	
	surface.SetMaterial( sRacing.LeftArrowMat ) 
	surface.DrawTexturedRect( ScrW()/2-ScrH()/6+2, ScrH()/4*3+7, ScrH()/18-4, ScrH()/16-14 ) 
	surface.SetMaterial( sRacing.RightArrowMat ) 
	surface.DrawTexturedRect( ScrW()/2+ScrH()/6+2-ScrH()/18, ScrH()/4*3+7, ScrH()/18-4, ScrH()/16-14 ) 

	draw.SimpleText( sRacing.toolList[sRacing.CurSelect].name, "sRacing.ToolFont", ScrW()/2,  ScrH()/4*3+ScrH()/32-2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) 
	draw.SimpleTextOutlined( string.upper(srConfig.Lang[srConfig.Language].curplacing), "sRacing.InputFont", ScrW()/2,  ScrH()/4*3-ScrH()/128-2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 
	draw.SimpleTextOutlined( "["..string.upper(input.GetKeyName(srConfig.ToggleMenuKey)).."] "..srConfig.Lang[srConfig.Language].openmenu.."   ".."[LMB]".." "..srConfig.Lang[srConfig.Language].create.."   ".."[RMB]".." "..srConfig.Lang[srConfig.Language].toggletool.."   ".."[R]".." "..srConfig.Lang[srConfig.Language].remove, "sRacing.InputFont", ScrW()/2,  ScrH()/4*3+ScrH()/16+ScrH()/128, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 

	surface.SetMaterial( sRacing.toolList[sRacing.CurSelect].icon ) 
	surface.DrawTexturedRect( ScrW()/2-ScrH()/44, ScrH()/4*3+2-ScrH()/14, ScrH()/22, ScrH()/22 ) 

	local amt

	if(table.Count(sRacing.editedRace[sRacing.toolList[sRacing.CurSelect].value])==0) then
		amt = string.upper(srConfig.Lang[srConfig.Language].noneplaced)
	else
		if(sRacing.toolList[sRacing.CurSelect].value=="startpoint" or sRacing.toolList[sRacing.CurSelect].value=="previewpoint") then
			amt = string.upper(srConfig.Lang[srConfig.Language].alreadyexists)
		else
			amt = #sRacing.editedRace[sRacing.toolList[sRacing.CurSelect].value].." "..string.upper(srConfig.Lang[srConfig.Language].placed)
		end
	end

	draw.SimpleTextOutlined( amt, "sRacing.SelectFont", ScrW()/2,  ScrH()/4*3+2+ScrH()/11, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(20,20,20)) 
end

local function ChangeCurSelection(selection)
	if(selection>#sRacing.toolList) then
		sRacing.CurSelect = 1
		return 
	end
	sRacing.CurSelect = selection
end

local CanInteract = true

local function ResetInteractTimer()
	CanInteract = false
	timer.Simple(0.1, function()
		CanInteract = true
	end)
end

local function CreatePoint(type)
	if(sRacing.CurSelect==4) then
		sRacing.editedRace.previewpoint["position"] = LocalPlayer():EyePos()
		sRacing.editedRace.previewpoint["angles"] = LocalPlayer():EyeAngles()
		LocalPlayer():ChatPrint( srConfig.Lang[srConfig.Language].prevcreated )
	end
	if(sRacing.CurSelect==3) then
		sRacing.editedRace.startpoint = { tr.HitPos }
		LocalPlayer():ChatPrint( srConfig.Lang[srConfig.Language].meetcreated )
	end
	if(sRacing.CurSelect==2) then
		if(#sRacing.editedRace.carstarts<32) then
			table.insert( sRacing.editedRace.carstarts, tr.HitPos ) 
		else
			LocalPlayer():ChatPrint( srConfig.Lang[srConfig.Language].maxspawns )
		end
	end
	if(sRacing.CurSelect==1) then
		if(#sRacing.editedRace.checkpoints<128) then
			table.insert( sRacing.editedRace.checkpoints, tr.HitPos ) 
		else
			LocalPlayer():ChatPrint( srConfig.Lang[srConfig.Language].maxchecks )
		end
	end
end

local function RemovePoint(type)
	if(table.Count(sRacing.editedRace[sRacing.toolList[type].value])==0) then return end

	table.remove(sRacing.editedRace[sRacing.toolList[type].value])
	if(type==1) then
		LocalPlayer():ChatPrint( srConfig.Lang[srConfig.Language].checkpoint.." #"..(#sRacing.editedRace[sRacing.toolList[type].value]+1).." has been removed." )
	end
	if(type==2) then
		LocalPlayer():ChatPrint( srConfig.Lang[srConfig.Language].carspawn.." #"..(#sRacing.editedRace[sRacing.toolList[type].value]+1).." has been removed." )
	end
	if(type==3) then
		LocalPlayer():ChatPrint( srConfig.Lang[srConfig.Language].meetpointremoved )
	end
	if(type==4) then
		LocalPlayer():ChatPrint( srConfig.Lang[srConfig.Language].previewremoved )
		sRacing.editedRace[sRacing.toolList[type].value] = {}
		sRacing.editedRace.previewmodel:Remove()
	end
end

function SWEP:PrimaryAttack()
	if(!CanInteract) then return end
	surface.PlaySound( "weapons/smg1/switch_burst.wav" )

	CreatePoint(sRacing.CurSelect)

	ResetInteractTimer()
end

function SWEP:SecondaryAttack()
	if(!CanInteract) then return end
	surface.PlaySound( "weapons/smg1/switch_single.wav" )

	ChangeCurSelection(sRacing.CurSelect+1)

	ResetInteractTimer()
end

function SWEP:Reload()
	if(!CanInteract) then return end
	surface.PlaySound( "weapons/smg1/switch_burst.wav" )
	RemovePoint(sRacing.CurSelect)
	ResetInteractTimer()
end