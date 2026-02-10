srConfig = {}
----------------- Street Racing v1.3.3 by D3G -----------------------

-- Language ( Currently available: English, French, German, Russian )
srConfig.Language = "English"

-- Default theme color. (RGBA color format)
srConfig.ThemeColor = Color(90,180,230,255) 

-- Maximum bet per player.
srConfig.MaxBet = 100000

-- Keybinds (Check https://wiki.garrysmod.com/page/Enums/KEY for more info)
srConfig.ToggleMenuKey = KEY_G 
srConfig.RaceInfoKey = KEY_H  

-- Default size values for checkpoint and meeting point.
srConfig.CheckpointSize = 250
srConfig.MeetPointSize = 120

-- Whether or not players should stop being wanted after finishing the race.
srConfig.AutoUnwanted = true

-- Timers (in seconds)
srConfig.RaceCooldown = 120 -- Time players need to wait to start same race again
srConfig.LobbyWaitTime = 30 -- Time players have to wait until the race starts (if player amount is at least minimum)

-- Jobs globally forbidden from street racing.
srConfig.ForbiddenJobs = {"Mayor", "Police officer"}

-- Amount of money police officer gets for arresting a street racer.
srConfig.BustedPay = 2500

-- Whether or not the dynamic music should be enabled.
srConfig.EnableDynMusic = false

-- If the race music list is empty script will use this table instead. Leave {} if you don't want any music to play.
srConfig.DefaultMusicTable = {
	"https://www14.zippyshare.com/d/pMPLvui2/5499/r5VydyqhnO3G.128.mp3",
	"https://www91.zippyshare.com/d/kSzdrBe9/20452/IGARASHI%20KANTA%20-%20In%20A%20Hood%20Near%20You.mp3",
	"https://www78.zippyshare.com/d/XvwyLqzF/37616/BLOOD%20SIDE.mp3",
}