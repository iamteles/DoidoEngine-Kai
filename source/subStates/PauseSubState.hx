package subStates;

import backend.game.GameData.MusicBeatSubState;
import backend.song.Conductor;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.sound.FlxSound;
import objects.menu.Alphabet;
import objects.menu.AlphabetMenu;
import states.*;
import subStates.options.OptionsSubState;
import flixel.math.FlxPoint;

class PauseSubState extends MusicBeatSubState
{
	var optionShit:Array<String> = [
		"resume",
		"restart song",
		"botplay",
		"photo mode",
		"options",
		"exit to menu",
	];
	
	var curSelected:Int = 0;
	
	var optionsGrp:FlxTypedGroup<AlphabetMenu>;
	var textsGrp:FlxTypedGroup<FlxText>;
	var bottomTxt:FlxText;

	var pauseSong:FlxSound;

	var onCountdown:Bool = false;

	var onPhoto:Bool = false;
	var storedZoom:Float = 1;
	var storedScrollX:Float;
	var storedScrollY:Float;

	public function new()
	{
		super();
		PlayState.instance.setScript("this", this);
		DiscordIO.changePresence("Paused - Restin' a bit");
		this.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		var banana = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(banana);

		banana.alpha = 0;
		FlxTween.tween(banana, {alpha: 0.4}, 0.1);

		if(!PlayState.startedSong)
			optionShit.remove("options");

		optionsGrp = new FlxTypedGroup<AlphabetMenu>();
		add(optionsGrp);

		for(i in 0...optionShit.length)
		{
			var newItem = new AlphabetMenu(0, 0, optionShit[i], true);
			newItem.ID = i;
			newItem.focusY = i - curSelected;

			// isn't as accurate to base game
			newItem.spaceX = 25;
			newItem.spaceY = 150; // 200

			// but it looks better
			newItem.updatePos();
			optionsGrp.add(newItem);

			newItem.x = 0;
		}
		
		textsGrp = new FlxTypedGroup<FlxText>();
		add(textsGrp);
		
		var textArray:Array<String> = [
			PlayState.SONG.song,
			//PlayState.songDiff,
			'BLUEBALLED: ' + PlayState.blueballed,
		];
		for(i in 0...textArray.length)
		{
			if(textArray[i] == "") continue;
		
			var text = new FlxText(0,0,0,textArray[i].toUpperCase());
			text.setFormat(Main.gFont, 36, 0xFFFFFFFF, RIGHT);
			text.setPosition(FlxG.width - text.width - 10, 10 + 40 * i);
			textsGrp.add(text);
			
			text.alpha = 0.00001;
			text.y -= 20;
			FlxTween.tween(text, {y: text.y + 20, alpha: 1}, 0.4, {ease: FlxEase.quadOut, startDelay: 0.2 + 0.18 * i});
		}
		
		bottomTxt = new FlxText(0,0,0,"");
		bottomTxt.setFormat(Main.gFont, 36, 0xFFFFFFFF, RIGHT);
		add(bottomTxt);

		pauseSong = new FlxSound();
		if(Conductor.songPos > 0)
		{
			@:privateAccess
			pauseSong.loadEmbedded(PlayState.instance.inst._sound, true, false);
			
			pauseSong.play(Conductor.songPos);
			pauseSong.pitch = 0.9;
			pauseSong.volume = 0;
			FlxTween.tween(pauseSong, {volume: 0.6}, 3, {startDelay: 1});
		}
		FlxG.sound.list.add(pauseSong);

		changeSelection();
	}

	function closePause()
	{
		pauseSong.stop();
		if(SaveData.data.get('Countdown on Unpause'))
			startCountdown();
		else
			close();
	}
	override function close()
	{
		pauseSong.stop();
		PlayState.paused = false;
		PlayState.instance.updateOption('Song Offset');
		PlayState.instance.callScript('onUnpause');
		PlayState.instance.setScript("this", PlayState.instance);
		super.close();
	}

	var inputDelay:Float = 0.05;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		bottomTxt.text = "";
		if(PlayState.botplay)
			bottomTxt.text += "BOTPLAY";
		
		bottomTxt.x = FlxG.width - bottomTxt.width - 10;
		bottomTxt.y = FlxG.height- bottomTxt.height- 10;

		if(inputDelay > 0)
		{
			inputDelay -= elapsed;
			return;
		}

		if(!onCountdown && !onPhoto)
		{
			if(!pauseSong.playing && Conductor.songPos >= 0)
				pauseSong.play(false, pauseSong.time);

			if(Controls.justPressed(UI_UP))
				changeSelection(-1);
			if(Controls.justPressed(UI_DOWN))
				changeSelection(1);

			if(Controls.justPressed(ACCEPT))
			{
				switch(optionShit[curSelected])
				{
					default:
						FlxG.sound.play(Paths.sound("menu/cancel"));
					
					case "resume":
						closePause();

					case "restart song":
						Main.skipStuff();
						Main.resetState();
					
					case "botplay":
						FlxG.sound.play(Paths.sound("menu/cancel"));
						PlayState.botplay = !PlayState.botplay;

					case "options":
						//Main.switchState(new states.menu.OptionsState(new LoadSongState()));
						persistentDraw = false;
						pauseSong.pause();
						this.openSubState(new OptionsSubState(PlayState.instance));

					case "exit to menu":
						//Main.switchState(new MenuState());
						persistentDraw = true;
						PlayState.sendToMenu();

					case "photo mode":
						for (i in 0...FlxG.cameras.list.length) {
							if(i != 0)
								FlxG.cameras.list[i].alpha = 0;
						}

						storedZoom = FlxG.camera.zoom;
						storedScrollX = FlxG.camera.scroll.x;
						storedScrollY = FlxG.camera.scroll.y;

						onPhoto = true;
				}
			}

			// works the same as resume
			if(Controls.justPressed(BACK))
				closePause();
		}
		else if(onPhoto) {
			var camSpeed:Float = elapsed * 400;
			var zoomSpeed:Float = elapsed * FlxG.camera.zoom;

			if(FlxG.keys.pressed.SHIFT) {
				camSpeed = elapsed * 1200;
				zoomSpeed = elapsed * FlxG.camera.zoom * 2;
			}

			if(Controls.pressed(UI_LEFT)) FlxG.camera.scroll.x -= camSpeed;
			if(Controls.pressed(UI_RIGHT)) FlxG.camera.scroll.x += camSpeed;
			if(Controls.pressed(UI_UP)) FlxG.camera.scroll.y -= camSpeed;
			if(Controls.pressed(UI_DOWN)) FlxG.camera.scroll.y += camSpeed;

			if(FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.05) FlxG.camera.zoom -= zoomSpeed;
			if(FlxG.keys.pressed.E && FlxG.camera.zoom < 2.5) FlxG.camera.zoom += zoomSpeed;

			if(Controls.justPressed(ACCEPT) || Controls.justPressed(BACK)) {
				for (i in 0...FlxG.cameras.list.length) {
					if(i != 0)
						FlxG.cameras.list[i].alpha = 1;
				}

				FlxG.camera.zoom = storedZoom;
				FlxG.camera.scroll.x = storedScrollX;
				FlxG.camera.scroll.y = storedScrollY;

				onPhoto = false;
			}
		}
		else
		{
			for(item in optionsGrp)
				item.alpha = FlxMath.lerp(item.alpha, 0, elapsed * 12);
		}
	}

	function startCountdown()
	{
		var labels:Array<String> = ["3", "2", "1", "GO"];
		var countdownTxt = new Alphabet(FlxG.width / 2, FlxG.height / 2 - 70 / 2,"",true);
		countdownTxt.align = CENTER;
		countdownTxt.updateHitbox();
		add(countdownTxt);

		var barTween:FlxTween = null;
		var cntBar = new FlxSprite().makeGraphic(180, 8, 0xFFFFFFFF);
		cntBar.screenCenter(X);
		cntBar.visible = false;
		add(cntBar);

		var loops:Int = 0;
		onCountdown = true;
		var countTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			if(loops == 4)
				close();
			else
			{
				countdownTxt.text = labels[loops];
				FlxG.sound.play(Paths.sound('menu/scroll'));

				if(!cntBar.visible)
				{
					cntBar.visible = true;
					cntBar.y = FlxG.height / 2 + 48;
				}
				cntBar.scale.x = 1.0;
				if(barTween != null)
					barTween.cancel();
				barTween = FlxTween.tween(cntBar.scale, {x: 0.0}, 0.5);
			}
			loops++;
		}, 5);
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, optionShit.length - 1);

		for(item in optionsGrp)
		{
			item.focusY = item.ID - curSelected;

			item.alpha = 0.4;
			if(item.ID == curSelected)
				item.alpha = 1;
		}

		if(change != 0)
			FlxG.sound.play(Paths.sound("menu/scroll"));
	}
}