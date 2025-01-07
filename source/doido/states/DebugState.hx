package doido.states;

import backend.system.Discord.DiscordIO;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import backend.game.GameData.MusicBeatState;
import doido.objects.menu.Alphabet;
import flixel.text.FlxText;

using StringTools;

class DebugState extends MusicBeatState
{
	var optionShit:Array<String> = ["freeplay", "credits", "options"];
	static var curSelected:Int = 0;

	var optionGroup:FlxTypedGroup<Alphabet>;

	override function create()
	{
		super.create();
		CoolUtil.playMusic("freakyMenu");

		//Main.setMouse(true);

		// Updating Discord Rich Presence
		DiscordIO.changePresence("In the Debug Menu...");

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(80,80,80));
		bg.screenCenter();
		add(bg);

		optionGroup = new FlxTypedGroup<Alphabet>();
		add(optionGroup);

		for(i in 0...optionShit.length)
		{
			var item = new Alphabet(0,0, "nah", false);
			item.align = CENTER;
			item.text = optionShit[i].toUpperCase();
			item.x = FlxG.width / 2;
			item.y = 50 + ((item.height + 100) * i);
			item.ID = i;
			optionGroup.add(item);
		}

		var doidoSplash:String = 'Doido Engine Kai ${FlxG.stage.application.meta.get('version')}';

		var splashTxt = new FlxText(4, 0, 0, '$doidoSplash');
		splashTxt.setFormat(Main.gFont, 18, 0xFFFFFFFF, LEFT);
		splashTxt.setBorderStyle(OUTLINE, 0xFF000000, 1.5);
		splashTxt.y = FlxG.height - splashTxt.height - 4;
		add(splashTxt);

		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(Controls.justPressed(UI_UP))
			changeSelection(-1);
		if(Controls.justPressed(UI_DOWN))
			changeSelection(1);

		if(Controls.justPressed(ACCEPT))
		{
			switch(optionShit[curSelected])
			{
				case "freeplay":
					Main.switchState(new doido.states.menu.FreeplayState());

				case "credits":
					Main.switchState(new doido.states.menu.CreditsState());
						
				case "options":
					Main.switchState(new doido.states.menu.OptionsState());
					
			}
		}
	}

	public function changeSelection(change:Int = 0)
	{
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, optionShit.length - 1);

		for(item in optionGroup.members)
		{
			var daText:String = optionShit[item.ID].toUpperCase().replace("-", " ");

			var daBold = (curSelected == item.ID);

			if(item.bold != daBold)
			{
				item.bold = daBold;
				if(daBold)
					item.text = '> ' + daText + ' <';
				else
					item.text = daText;
				item.x = FlxG.width / 2;
			}
		}
	}
}