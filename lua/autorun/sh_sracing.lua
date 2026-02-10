sRacing = sRacing or {}

AddCSLuaFile("main/sracing_cl_autorun.lua")
include( "sracing_config.lua" )
include( "sracing_lang.lua" )

function sRacing.IsWanted(ply)
	return (DarkRP and ply:isWanted()) or false
end

function sRacing.IsAdmin(ply)
	return ply:IsAdmin()
end

function sRacing.IsPolice(ply)
	return (DarkRP and ply:isCP()) or false
end
if SERVER then

	function sRacing.JailPlayer(ply, arrester)  
		if !DarkRP then return end
		ply:arrest(120, arrester)
	end

	function sRacing.IsJob(ply, jobtbl)  
		if(!IsValid(ply)) then return end
		if !DarkRP then return false end
		if(table.HasValue(jobtbl, team.GetName(ply:Team()))) then
			return true
		end
		return false
	end

	local function addServerContent( path )
		local files, folders = file.Find( path .. "/*", "GAME" )
		for k, v in pairs( files ) do
			resource.AddFile( path .. "/" .. v )
		end

		for k, v in pairs( folders ) do
			addServerContent( path .. "/" .. v )
		end
	end

	function sRacing.AddMoney(ply, amt)
		if !DarkRP then return end
		ply:addMoney(amt)
	end

	function sRacing.GetMoney(ply)
		if DarkRP then return ply:getDarkRPVar("money") else return srConfig.MaxBet + 250000 end
	end

	function sRacing.SetWanted(ply, duration)
		if !DarkRP then return end
		ply:wanted(ply, srConfig.Lang[srConfig.Language].wantedreason, duration)
	end

	function sRacing.SetUnwanted(ply)
		if !DarkRP then return end
		if(!srConfig.AutoUnwanted) then return end
		ply:unWanted()
	end

	resource.AddWorkshop("1622884524")
	resource.AddFile( "resource/fonts/bfhud.ttf" )
	addServerContent( "materials/race_icons" )
	addServerContent( "sound/race_sounds" )

	include( "main/sracing_sv_autorun.lua" )
end

if CLIENT then
	function sRacing.StartMusic(urltab, num)
		if sRacing.MusicChan and sRacing.MusicChan:IsValid() then
			sRacing.MusicChan:Stop()
		end
		if(table.Count(urltab)<=0) then return end
		if(num==nil) then isrand = true num = math.random(1, table.Count(urltab)) end
		sound.PlayURL(urltab[num],"", function(chan, errId, errName) 
			if(!IsValid(chan)) then LocalPlayer():ChatPrint(srConfig.Lang[srConfig.Language].error.." "..srConfig.Lang[srConfig.Language].wronglink1.." #"..num.." "..srConfig.Lang[srConfig.Language].wronglink2) return end
			sRacing.MusicChan = chan
			sRacing.MusicChan:EnableLooping( false ) 
			timer.Create("sRacing.MusicQueue",sRacing.MusicChan:GetLength()-1,1,function()
				local nextnum = num + 1
				if(nextnum>table.Count(urltab)) then nextnum = 1 end
				if(!sRacing.MusicChan or !sRacing.MusicChan:IsValid()) then return end
				sRacing.StartMusic(urltab, nextnum)
			end)
		end)
	end 

	function sRacing.StopMusic()
		if sRacing.MusicChan and sRacing.MusicChan:IsValid() then
			print(sRacing.MusicChan)
			sRacing.MusicChan:Stop()
			timer.Remove("sRacing.MusicQueue")
		end 
	end

	surface.CreateFont( "sRacing.SelectFont", {
		font = "BFHud",
		size = ScrH()/1080*23
	})
	surface.CreateFont( "sRacing.InputFont", {
		font = "BFHud",
		size = ScrH()/1080*15
	})
	surface.CreateFont( "sRacing.TinyFont", {
		font = "BFHud",
		size = ScrH()/1080*12
	})
	surface.CreateFont( "sRacing.ToolFont", {
		font = "BFHud",
		size = ScrH()/1080*32
	})
	surface.CreateFont( "sRacing.HugeFont", {
		font = "BFHud",
		size = ScrH()/1080*128
	})
	surface.CreateFont( "sRacing.WorldFont", {
		font = "BFHud",
		size = 64
	})
	surface.CreateFont( "sRacing.WorldFontLarge", {
		font = "BFHud",
		size = 96 
	})
	
	sRacing.MusicChan = sRacing.MusicChan or nil

	sRacing.CloseButtonMat = Material("materials/race_icons/close.png", "smooth")
	sRacing.InfoMat = Material("materials/race_icons/info.png", "smooth")
	sRacing.CheckpointMat = Material("materials/race_icons/checkpoint.png", "smooth")
	sRacing.CarSpawnMat = Material("materials/race_icons/car.png", "smooth")
	sRacing.MeetPointMat = Material("materials/race_icons/start_point.png", "smooth")
	sRacing.LeftArrowMat = Material("materials/race_icons/left-arrow.png", "smooth")
	sRacing.RightArrowMat = Material("materials/race_icons/right-arrow.png", "smooth")
	sRacing.MeetCircleMat = Material("materials/race_icons/circle.png", "smooth")
	sRacing.CarBoxMat = Material("materials/race_icons/car_spawn.png", "smooth")
	sRacing.CheckerboardMat = Material("materials/race_icons/checkerboard.png", "smooth")
	sRacing.CheckCircleMat = Material("materials/race_icons/circle_large.png", "smooth")
	sRacing.RemoveMat = Material("materials/race_icons/trash_bin.png", "smooth")
	sRacing.LoadMat = Material("materials/race_icons/load.png", "smooth")
	sRacing.PreviewMat = Material("materials/race_icons/camera.png", "smooth")
	sRacing.CheckArrowMat = Material("materials/race_icons/check_arrow.png", "smooth")
	sRacing.WinPrizeMat = Material("materials/race_icons/first-prize-trophy.png", "smooth")
	sRacing.ParticipationPrizeMat = Material("materials/race_icons/trophy.png", "smooth")
	sRacing.PoliceMat = Material("materials/race_icons/police-hat.png", "smooth")
	sRacing.DistanceMat = Material("materials/race_icons/distance.png", "smooth")
	sRacing.TimerMat = Material("materials/race_icons/timer.png", "smooth")
	sRacing.CarTopMat = Material("materials/race_icons/car_top.png", "smooth")
	sRacing.IndicatorMat = Material("materials/race_icons/indicator.png", "smooth")
	sRacing.Wanted1Mat = Material("materials/race_icons/wanted1.png", "smooth")
	sRacing.Wanted2Mat = Material("materials/race_icons/wanted2.png", "smooth")
	sRacing.EntryFeeMat = Material("materials/race_icons/entry_fee.png", "smooth")
	sRacing.ShieldMat = Material("materials/race_icons/shield.png", "smooth")
	sRacing.HandcuffMat = Material("materials/race_icons/handcuffs.png", "smooth")

	sRacing.menuCurSelect = 1
	sRacing.CurSelect = 1
	sRacing.BustedBar = -50
	sRacing.aCheckRequest = true
	sRacing.currentBet = 0

	sRacing.menuList = {
		{
			["name"] = string.upper(srConfig.Lang[srConfig.Language].main)
		},
		{
			["name"] = string.upper(srConfig.Lang[srConfig.Language].theme)
		},
		{
			["name"] = string.upper(srConfig.Lang[srConfig.Language].saveload)
		}
	}

	sRacing.toolList = {
		{
			["name"] = string.upper(srConfig.Lang[srConfig.Language].checkpoints),
			["icon"] = sRacing.CheckpointMat,
			["value"] = "checkpoints"
		},
		{
			["name"] = string.upper(srConfig.Lang[srConfig.Language].carspawns),
			["icon"] = sRacing.CarSpawnMat,
			["value"] = "carstarts"
		},
		{
			["name"] = string.upper(srConfig.Lang[srConfig.Language].meetpoint),
			["icon"] = sRacing.MeetPointMat,
			["value"] = "startpoint"
		},
		{
			["name"] = string.upper(srConfig.Lang[srConfig.Language].previewpoint),
			["icon"] = sRacing.PreviewMat,
			["value"] = "previewpoint"
		}
	}

	sRacing.editedRace = {
	    //Editable through menu
	    ["name"] = "Race",
	    ["minplayers"] = 2,
	    ["winreward"] = 1000,
	    ["entryfee"] = 50,
	    ["reward"] = 100,
	    ["maxduration"] = 720,
	    ["laps"] = 1,
	    ["checktype"] = 0,
	    ["carstartsrot"] = 0,
	    ["checksize"] = srConfig.CheckpointSize,
	    ["meetsize"] = srConfig.MeetPointSize,
	    ["themecolor"] = srConfig.ThemeColor,
	    ["autowanted"] = true,
	    ["collision"] = true,
	    ["allowbet"] = true,
	    ["musicurls"] = {},
	    ["allowedcars"] = "",
	    ["LinkTextInput"] = "",
	    //Editable with tool
	    ["checkpoints"] = {},
	    ["carstarts"] = {},
	    ["startpoint"] = {},
	    ["previewpoint"] = {}
	}

	sRacing.races = sRacing.races or {} 
	sRacing.currentRace = sRacing.currentRace or {
		["playerlist"] = {},
		["ongoingtime"] = 0
	}

	include( "main/sracing_cl_autorun.lua" )
end