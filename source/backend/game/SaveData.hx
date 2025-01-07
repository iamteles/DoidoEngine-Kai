package backend.game;

import flixel.FlxSprite;
import flixel.util.FlxSave;
import openfl.system.Capabilities;
import backend.song.Conductor;
import backend.song.Highscore;
import backend.native.Windows;

/*
	Save data such as options and other things.
*/

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
			"Change the game's resolution if it doesn't fit your monitor.",
			["640x360","854x480","960x540","1024x576","1152x648","1280x720","1366x768","1600x900","1920x1080", "2560x1440", "3840x2160"],
		],
		'Flashing Lights' => [
			"ON",
			SELECTOR,
			"Disable this if you have issues with Photosensitivity.",
			["ON", "REDUCED", "OFF"]
		],
		"Cutscenes" => [
			"ON",
			SELECTOR,
			"Decides if the song cutscenes should play.",
			["ON", "OFF"],
		],
		"FPS Counter" => [
			"OFF",
			SELECTOR,
			"Counter that can display debug information, such as the framerate or the memory usage.",
			["FULL", "SIMPLE", "OFF"]
		],
		'Unfocus Pause' => [
			true,
			CHECKMARK,
			"Pauses the game when the window is unfocused.",
		],
		"Countdown on Unpause" => [
			true,
			CHECKMARK,
			"When unpausing the game, this 4 beat timer will help you get back on rhythm.",
		],
		'Discord RPC' => [
			#if DISCORD_RPC
			true,
			#else
			false,
			#end
			CHECKMARK,
			"Display game information on your Discord profile.",
		],
		"Shaders" => [
			true,
			CHECKMARK,
			"Fancy graphical effects. Disable this if you get GPU related crashes."
		],
		"Low Quality" => [
			false,
			CHECKMARK,
			"Disables extra assets that might make very low end computers lag."
		],
		/*
		*
		* GAMEPLAY
		* 
		*/
		"Ghost Tapping" => [
			true,
			CHECKMARK,
			"Makes you able to press keys freely without breaking notes."
		],
		"Downscroll" => [
			false,
			CHECKMARK,
			"Decides if the notes should scroll down or up."
		],
		"FPS Cap"	=> [
			"60",
			SELECTOR,
			"How many frames can displayed in a second.",
			["30", "60", "75", "120", "144"]
		],
		'Hitsounds' => [
			"OFF",
			SELECTOR,
			"Clicking sounds whenever you hit a note.",
			["OFF", "OSU", "CD"]
		],
		'Hitsound Volume' => [
			100,
			SELECTOR,
			"The volume at which hitsounds are played.",
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
			"Smoothing on sprite scaling. Disabling this may improve performance."
		],
		"Dark Mode" => [
			true,
			CHECKMARK,
			"The theme of the Window."
		],
		/*
		*
		* MOBILE
		* 
		*/
		"Invert Swipes" => [
			"OFF",
			SELECTOR,
			"Inverts the direction of the swipes.",
			["HORIZONTAL", "VERTICAL", "BOTH", "OFF"],
		],
		"Button Opacity" => [
			5,
			SELECTOR,
			"Decides the transparency of the virtual buttons.",
			[0, 10]
		],
		"Hitbox Opacity" => [
			7,
			SELECTOR,
			"Decides the transparency of the playing Hitboxes.",
			[0, 10]
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
		else
		{
			var freeze:Null<Bool> = saveSettings.data.settings.get("Unfocus Freeze");
			if(freeze != null) {
				saveSettings.data.settings.set("Unfocus Pause", freeze);
				saveSettings.data.settings.remove("Unfocus Freeze");
			}
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

	static var lastDark:Bool = false;
	public static function update()
	{
		Main.changeFramerate(Std.parseInt(data.get("FPS Cap")));
		
		if(Main.fpsCounter != null)
			Main.fpsCounter.setVisible(data.get("FPS Counter"));

		FlxSprite.defaultAntialiasing = data.get("Antialiasing");

		FlxG.autoPause = data.get('Unfocus Pause');

		Conductor.musicOffset = data.get('Song Offset');
		Conductor.inputOffset = data.get('Input Offset');

		DiscordIO.check();

		#if windows
		if(SaveData.data.get("Dark Mode") != lastDark)
			Windows.setDarkMode(lime.app.Application.current.window.title, SaveData.data.get("Dark Mode"));

		lastDark = SaveData.data.get("Dark Mode");
		#end
	}

	public static function updateWindowSize()
	{
		#if desktop
		if(FlxG.fullscreen) return;
		var ws:Array<String> = data.get("Resolution").split("x");
        	var windowSize:Array<Int> = [Std.parseInt(ws[0]),Std.parseInt(ws[1])];
        	FlxG.stage.window.width = windowSize[0];
        	FlxG.stage.window.height= windowSize[1];
		
		// centering the window
		FlxG.stage.window.x = Math.floor(Capabilities.screenResolutionX / 2 - windowSize[0] / 2);
		FlxG.stage.window.y = Math.floor(Capabilities.screenResolutionY / 2 - (windowSize[1] + 16) / 2);
		#end
	}
}
