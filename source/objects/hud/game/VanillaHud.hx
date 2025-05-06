package objects.hud.game;

import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import backend.song.Conductor;
import backend.song.Timings;
import states.PlayState;

class VanillaHud extends HudClass
{
	public var infoTxt:FlxText;
	
	var botplaySin:Float = 0;
	var botplayTxt:FlxText;
	var badScoreTxt:FlxText;

	// health
	public var healthBar:HealthBar;

	public function new()
	{	
        super();
		healthBar = new HealthBar();
		changeIcon(0, healthBar.icons[0].curIcon);
		add(healthBar);
		
		infoTxt = new FlxText(0, 0, 0, "nothing");
		infoTxt.setFormat(Main.gFont, 16, FlxColor.WHITE, RIGHT);
		add(infoTxt);
		
		badScoreTxt = new FlxText(0,0,0,"SCORE WILL NOT BE SAVED");
		badScoreTxt.setFormat(Main.gFont, 26, 0xFFFF0000, CENTER);
		badScoreTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		badScoreTxt.screenCenter(X);
		badScoreTxt.visible = false;
		add(badScoreTxt);
		
		botplayTxt = new FlxText(0,0,0,"[BOTPLAY]");
		botplayTxt.setFormat(Main.gFont, 40, 0xFFFFFFFF, CENTER);
		botplayTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		botplayTxt.screenCenter();
		botplayTxt.visible = false;
		add(botplayTxt);

        updateHitbox();
	}

	override public function updateText()
	{
		infoTxt.text = 'Score: ' + Timings.score;

		infoTxt.x = healthBar.bg.x + healthBar.bg.width - 190;
		infoTxt.y = healthBar.bg.y + 30;
	}

	override public function updateHitbox(downscroll:Bool = false)
	{
		healthBar.bg.x = (FlxG.width / 2) - (healthBar.bg.width / 2);
		healthBar.bg.y = (downscroll ? 70 : FlxG.height - healthBar.bg.height - 50);
		healthBar.updatePos();
		
		updateText();
		
		badScoreTxt.y = healthBar.bg.y - badScoreTxt.height - 4;
	}
	
	override public function setAlpha(hudAlpha:Float = 1, ?tweenTime:Float = 0, ?ease:String = "cubeout")
	{
		// put the items you want to set invisible when the song starts here
		var allItems:Array<FlxSprite> = [
			infoTxt,
			healthBar.bg,
			healthBar.sideL,
			healthBar.sideR,
		];
		for(icon in healthBar.icons)
			allItems.push(icon);
		
        _setAlpha(allItems, hudAlpha, tweenTime, ease);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		healthBar.percent = (PlayState.health * 50);
		
		botplayTxt.visible = PlayState.botplay;
		badScoreTxt.visible = !PlayState.validScore;
		
		if(botplayTxt.visible)
		{
			botplaySin += elapsed * Math.PI;
			botplayTxt.alpha = 0.5 + Math.sin(botplaySin) * 0.8;
		}

		healthBar.updateIconPos();
	}

	override public function changeIcon(iconID:Int = 0, newIcon:String = "face")
	{
		healthBar.changeIcon(iconID, newIcon);
	}

	override public function beatHit(curBeat:Int = 0)
	{
		for(icon in healthBar.icons)
		{
			icon.scale.set(1.1,1.1);
			icon.updateHitbox();
			healthBar.updateIconPos();
		}
	}
}