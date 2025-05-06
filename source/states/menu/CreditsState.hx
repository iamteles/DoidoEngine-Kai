package states.menu;

import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import backend.game.GameData.MusicBeatState;
import backend.song.Highscore;
import backend.song.Highscore.ScoreData;
import backend.song.SongData;
import objects.menu.AlphabetMenu;
import objects.hud.HealthIcon;
import states.*;
import states.editors.ChartingState;
import subStates.menu.DeleteScoreSubState;
import flixel.addons.display.FlxBackdrop;

using StringTools;

typedef CreditData = {
	var name:String;
    var icon:String;
    var info:String;
	var link:Null<String>;
	var color:Null<FlxColor>;
}
class CreditsState extends MusicBeatState
{
	var creditList:Array<CreditData> = [];
    
	function addCredit(name:String, icon:String, info:String, ?link:Null<String>, ?color:Null<FlxColor>)
	{
		creditList.push({
            name: name,
            icon: icon,
            color: color,
            info: info,
			link: link,
        });
	}

	static var curSelected:Int = 0;

	var bg:FlxSprite;
	var bgTween:FlxTween;
	var grpItems:FlxGroup;
	var infoTxtFocus:AlphabetMenu;
	var infoTxt:FlxText;

	public static var doido:Bool = false;

	override function create()
	{
		super.create();
		CoolUtil.playMusic("freakyMenu");

		DiscordIO.changePresence("Credits - Thanks!!");

		bg = new FlxSprite().loadGraphic(Paths.image('menu/backgrounds/menuDesat'));
		bg.scale.set(1.2,1.2); bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		grpItems = new FlxGroup();
		add(grpItems);

		infoTxt = new FlxText(0, 0, FlxG.width * 0.6, 'balls');
		infoTxt.setFormat(Main.gFont, 24, 0xFFFFFFFF, CENTER);
        infoTxt.setBorderStyle(OUTLINE, 0xFF000000, 1.5);
        add(infoTxt);

		final specialPeople = 'Anakim, ArturYoshi, BeastlyChip♧, Bnyu, Evandro, NxtVithor, Pi3tr0, Raphalitos, ZieroSama';
		final specialCoders = 'Crowplexus, Gazozoz, Joalor64GH, soushimiya';
		// yes, this implies coders aren't people
		// :D
		
		if(!doido) {
			addCredit('teles', 					'doido/teles', 	 	"Placeholder for mod / engine credits",	'https://www.youtube.com/@telesfnf');
			addCredit('Doido Engine ~ Kai', 	'doido', 	  	"Press ACCEPT to see engine credits",	'_DOIDO', 0xFFFFFFFF);
		}
		else {
			addCredit('DiogoTV', 			'diogotv', 	  "Doido Engine's Owner and Main Coder", 							'https://bsky.app/profile/diogotv.bsky.social');
			addCredit('teles', 				'teles', 	  "Doido Engine's Additional Coder\nKAI fork Owner and Main Coder",				'https://youtube.com/@telesfnf');
			addCredit('GoldenFoxy',			'anna', 	  "Main designer of Doido Engine's chart editor",					'https://bsky.app/profile/goldenfoxy.bsky.social');
			addCredit('JulianoBeta', 		'juyko', 	  "Composed Doido Engine's offset menu music",			'https://www.youtube.com/@prodjuyko');
			addCredit('crowplexus',			'crowplexus', "Creator of HScript Iris",							'https://github.com/crowplexus/hscript-iris');
			addCredit('yoisabo',			'yoisabo',	  "Chart Editor's Event Icons Artist",					'https://bsky.app/profile/yoisabo.bsky.social');
			addCredit('cocopuffs',			'coco',	 	  "Mobile Button Artist",								'https://x.com/cocopuffswow');
			addCredit('doubleonikoo', 		'nikoo', 	  "didn't really do much but i already made this icon so you can stay... for now\n-DiogoTV",	'https://bsky.app/profile/doubleonikoo.bsky.social');
			addCredit('Github Contributors','github', 	  'Thank you\n${specialCoders}!!', 		'https://github.com/DoidoTeam/FNF-Doido-Engine/graphs/contributors');
			addCredit('Special Thanks', 	'heart', 	  'Thank you\n${specialPeople}!!', "https://youtu.be/Fo7L8p1I_Hw");
			addCredit('MOD', 		'mod', 	  	  "Press ACCEPT to return to mod credits",	'_MOD');
		}
		
		for(i in 0...creditList.length)
		{
			var credit = creditList[i];

			var item = new AlphabetMenu(0, 0, credit.name, false);
			item.align = CENTER;
			item.updateHitbox();
			grpItems.add(item);

			var iconName:String = 'credits/';
			if(doido)
				iconName += 'doido/';
			iconName += credit.icon;

			var icon = new FlxSprite();
			icon.loadGraphic(Paths.image(iconName));
			grpItems.add(icon);

			// big ears
			if(credit.icon == "anna")
				icon.offset.y = 30;
			if(credit.icon == "tagaki" || credit.icon == "doido" || credit.icon == "br")
				icon.offset.x = -10;

			item.icon = icon;
			item.ID = i;
			icon.ID = i;

			item.spaceX = 0;
			item.spaceY = 200;
			item.xTo = (FlxG.width / 2) - (icon.width / 2);
			item.focusY = i - curSelected;
			item.updatePos();
		}
		changeSelection();

		#if TOUCH_CONTROLS
		createPad("back");
		#end
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, creditList.length - 1);

		var color:FlxColor = 0xFF696969;
		
		for(rawItem in grpItems.members)
		{
			if(Std.isOfType(rawItem, AlphabetMenu))
			{
				var item = cast(rawItem, AlphabetMenu);
				item.focusY = item.ID - curSelected;

				item.alpha = 0.4;
				if(item.ID == curSelected) {
					infoTxtFocus = item;
					item.alpha = 1;

					if(creditList[curSelected].color != null)
						color = creditList[curSelected].color;
					else
						color = CoolUtil.dominantColor(item.icon);
				}
			}
		}

		infoTxt.text = creditList[curSelected].info;
		infoTxt.screenCenter(X);
		
		if(bgTween != null) bgTween.cancel();
		bgTween = FlxTween.color(bg, 0.4, bg.color, color);

		if(change != 0)
			FlxG.sound.play(Paths.sound("menu/scroll"));
	}

	function goBack() {
		if(doido)
			switchCreds()
		else
			Main.switchState(new states.DebugState());
	}

	function switchCreds() {
		doido = !doido;
		Main.resetState();
		curSelected = 0;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(Controls.justPressed(UI_UP))
			changeSelection(-1);
		if(Controls.justPressed(UI_DOWN))
			changeSelection(1);

		if(Controls.justPressed(BACK))
			goBack();

		if(Controls.justPressed(ACCEPT))
		{
			var daCredit = creditList[curSelected].link;
			if(daCredit != null) {
				if(daCredit == "_DOIDO" || daCredit == "_MOD")
					switchCreds();
				else
					CoolUtil.openURL(daCredit);
			}
		}
		
		infoTxt.y = infoTxtFocus.y + infoTxtFocus.height + 48;
		for(rawItem in grpItems.members)
		{
			if(Std.isOfType(rawItem, AlphabetMenu))
			{
				var item = cast(rawItem, AlphabetMenu);
				item.icon.x = item.x + (item.width / 2);
				item.icon.y = item.y - item.icon.height / 6;
				item.icon.alpha = item.alpha;
			}
		}
	}
}