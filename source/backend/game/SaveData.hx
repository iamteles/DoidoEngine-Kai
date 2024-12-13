package backend.game;

import flixel.FlxSprite;
import flixel.util.FlxSave;
import openfl.system.Capabilities;
import backend.song.Conductor;
import backend.song.Highscore;

enum SettingType
{
	CHECKMARK;
	SELECTOR;
}
class SaveData
{
	public static var data:Map<String, Dynamic> = [];
	public static var displaySettings:Map<String, Dynamic> = [
		/*
		*
		* PREFERENCES
		* 
		*/
		"Resolution" => [
			"1280x720",
			SELECTOR,
			"The resolution the game will run at.",
			["640x360","854x480","960x540","1024x576","1152x648","1280x720","1366x768","1600x900","1920x1080", "2560x1440", "3840x2160"],
		],
		'Flashing Lights' => [
			"ON",
			SELECTOR,
			"Flashing lights and other effects that may cause epilepsy.",
			["ON", "REDUCED", "OFF"]
		],
		"Cutscenes" => [
			true,
			CHECKMARK,
			"Cutscenes, such as videos and dialogue.",
			["ON", "OFF"],
		],
		"FPS Counter" => [
			false,
			CHECKMARK,
			"Text that displays useful debug info, such as the current FPS or memory usage.",
		],
		'Unfocus Pause' => [
			true,
			CHECKMARK,
			"Pauses the game when the window is unfocused.",
		],
		"Countdown on Unpause" => [
			true,
			CHECKMARK,
			"Countdown when unpausing the game, to help you resume without breaking your combo.",
		],
		'Discord RPC' => [
			#if DISCORD_RPC
			true,
			#else
			false,
			#end
			CHECKMARK,
			"Displays the current game info on your discord profile.",
		],
		/*
		*
		* GAMEPLAY
		* 
		*/
		"Ghost Tapping" => [
			true,
			CHECKMARK,
			"Press keys freely without breaking your combo."
		],
		"Downscroll" => [
			false,
			CHECKMARK,
			"Makes the notes scroll down instead of up"
		],
		"FPS Cap"	=> [
			60, // 120
			SELECTOR,
			"How many frames are displayed in a second.",
			["30", "60", "120", "144"]
		],
		'Hitsounds' => [
			"OFF",
			SELECTOR,
			"Clicking sounds whenever you hit a note",
			["OFF", "OSU", "NSWITCH", "CD"]
		],
		'Hitsound Volume' => [
			100,
			SELECTOR,
			"The volume at which the hitsounds play.",
			[0, 100]
		],
		/*
		*
		* APPEARANCE
		* 
		*/
		"Antialiasing" => [
			true,
			CHECKMARK,
			"Disabling smoothing on sprites. Can improve performance."
		],
		"Low Quality" => [
			false,
			CHECKMARK,
			"Disables certain stage objects. Can improve performance."
		],
		"Shaders" => [
			true,
			CHECKMARK,
			"Fancy graphical effects. Disable this if you get GPU related crashes. Can improve performance."
		],
		/*
		*
		* EXTRA STUFF
		* 
		*/
		"Song Offset" => [
			0,
			SELECTOR,
			"no one is going to see this anyway whatever",
			[-100, 100],
		],
		"Input Offset" => [
			0,
			SELECTOR,
			"same xd",
			[-100, 100],
		],
	];
	
	public static var saveSettings:FlxSave = new FlxSave();
	public static var saveControls:FlxSave = new FlxSave();
	public static function init()
	{
		saveSettings.bind("settings"); // use these for settings
		saveControls.bind("controls"); // controls :D
		FlxG.save.bind("save-data"); // these are for other stuff, not recquiring to access the SaveData class
		
		load();
		Controls.load();
		Highscore.load();
		subStates.editors.ChartAutoSaveSubState.load(); // uhhh
		updateWindowSize();
	}
	
	public static function load()
	{
		if(saveSettings.data.volume != null)
			FlxG.sound.volume = saveSettings.data.volume;
		if(saveSettings.data.muted != null)
			FlxG.sound.muted  = saveSettings.data.muted;

		if(saveSettings.data.settings == null)
		{
			for(key => values in displaySettings)
				data[key] = values[0];
			
			saveSettings.data.settings = data;
		}
		
		if(Lambda.count(displaySettings) != Lambda.count(saveSettings.data.settings)) {
			data = saveSettings.data.settings;
			
			for(key => values in displaySettings) {
				if(data[key] == null)
					data[key] = values[0];
			}

			for(key => values in data) {
				if(displaySettings[key] == null)
					data.remove(key);
			}

			saveSettings.data.settings = data;
		}
		
		for(hitsound in Paths.readDir('sounds/hitsounds', [".ogg"], true))
			if(!displaySettings.get("Hitsounds")[3].contains(hitsound))
				displaySettings.get("Hitsounds")[3].insert(1, hitsound);
		
		data = saveSettings.data.settings;
		save();
	}
	
	public static function save()
	{
		saveSettings.data.settings = data;
		saveSettings.flush();
		update();
	}

	public static function update()
	{
		Main.changeFramerate(data.get("FPS Cap"));
		
		if(Main.fpsCounter != null)
			Main.fpsCounter.visible = data.get("FPS Counter");

		FlxSprite.defaultAntialiasing = data.get("Antialiasing");

		FlxG.autoPause = data.get('Unfocus Pause');

		Conductor.musicOffset = data.get('Song Offset');
		Conductor.inputOffset = data.get('Input Offset');

		DiscordIO.check();
	}

	public static function updateWindowSize()
	{
		if(FlxG.fullscreen) return;
		var ws:Array<String> = data.get("Resolution").split("x");
        	var windowSize:Array<Int> = [Std.parseInt(ws[0]),Std.parseInt(ws[1])];
        	FlxG.stage.window.width = windowSize[0];
        	FlxG.stage.window.height= windowSize[1];
		
		// centering the window
		FlxG.stage.window.x = Math.floor(Capabilities.screenResolutionX / 2 - windowSize[0] / 2);
		FlxG.stage.window.y = Math.floor(Capabilities.screenResolutionY / 2 - (windowSize[1] + 16) / 2);
	}
}
