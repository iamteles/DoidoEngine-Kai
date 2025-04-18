package objects.hud;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextFormat;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import backend.song.Conductor;
import backend.song.Timings;
import states.PlayState;

class HudClass extends FlxGroup
{
	public var ratingGrp:FlxGroup;
	public var infoTxt:FlxText;
	public var timeTxt:FlxText;
	
	var botplaySin:Float = 0;
	var botplayTxt:FlxText;
	var badScoreTxt:FlxText;

	public var subtitleA:FlxText;
	public var subtitleB:FlxText;

	// health bar
	public var healthBar:HealthBar;
	
	public var health:Float = 1;

	public function new()
	{
		super();
		ratingGrp = new FlxGroup();
		add(ratingGrp);
		
		healthBar = new HealthBar();
		changeIcon(0, healthBar.icons[0].curIcon);
		add(healthBar);
		
		infoTxt = new FlxText(0, 0, 0, "hi there! i am using whatsapp");
		infoTxt.setFormat(Main.gFont, 20, 0xFFFFFFFF, CENTER);
		infoTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		add(infoTxt);
		
		timeTxt = new FlxText(0, 0, 0, "nuts / balls even");
		timeTxt.setFormat(Main.gFont, 32, 0xFFFFFFFF, CENTER);
		timeTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		timeTxt.visible = true;
		add(timeTxt);
		
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
		
		subtitleA = new FlxText(0,0,0,"");
		subtitleA.setFormat(Main.gFont, 30, 0xFFFFFFFF, CENTER);
		subtitleA.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		subtitleA.screenCenter(X);
		subtitleA.y = FlxG.height - subtitleA.height - 160;
		add(subtitleA);

		subtitleB = new FlxText(0,0,0,"");
		subtitleB.setFormat(Main.gFont, 30, 0xFFFFFFFF, CENTER);
		subtitleB.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		subtitleB.screenCenter(X);
		subtitleB.y = subtitleA.y - subtitleB.height - 2;
		add(subtitleB);

		updateHitbox();
		health = PlayState.health;
	}

	public function updateLyrics(lineA:String = "", lineB:String = "") {
		var colorMap:Map<String, FlxColor> = [
			"(Gi)" 		=> 0xFF794D6F,
			"(???)"		=> 0xFF000000
		];

		var formatA:FlxTextFormat = new FlxTextFormat(0xFFFFFFFF, false, false, FlxColor.BLACK, false);
		var formatB:FlxTextFormat = new FlxTextFormat(0xFFFFFFFF, false, false, FlxColor.BLACK, false);

		var formats:Array<FlxTextFormat> = [formatA, formatB];
		var lines:Array<String> = [lineA,lineB];

		for (line in lines) {
			var format:FlxTextFormat;

			if(line.startsWith("(")) {
				var name:String = line.split(":")[0];
				var color:FlxColor = FlxColor.WHITE;
				var outline:FlxColor = FlxColor.BLACK;

				if(name == "(???)")
					outline = FlxColor.WHITE;

				if(colorMap.exists(name))
					color = colorMap.get(name);

				format = new FlxTextFormat(color, false, false, outline, false);
			}
			else {
				format = new FlxTextFormat(0xFFFFFFFF, false, false, FlxColor.BLACK, false);
			}

			var index:Int = lines.indexOf(line);
			formats[index] = format;
		}

		var indexA:Int = lineA.indexOf(':');
		var indexB:Int = lineB.indexOf(':');

		if(indexA < 0)
			indexA = 10;
		if(indexB < 0)
			indexB = 10;

		subtitleA.addFormat(formats[0], 0, indexA);
		subtitleB.addFormat(formats[1], 0, indexB);

		subtitleA.text = lineA;
		subtitleB.text = lineB;

		subtitleA.screenCenter(X);
		subtitleA.y = FlxG.height - subtitleA.height - 160;
		subtitleB.screenCenter(X);
		subtitleB.y = subtitleA.y - subtitleB.height - 2;
	}
	public final separator:String = " | ";

	public function updateText()
	{
		infoTxt.text = "";
		
		infoTxt.text += 			'Score: '		+ Timings.score;
		infoTxt.text += separator + 'Accuracy: '	+ Timings.accuracy + "%" + ' [${Timings.getRank()}]';
		infoTxt.text += separator + 'Breaks: '		+ Timings.breaks;

		infoTxt.screenCenter(X);
	}
	
	public function updateTimeTxt()
	{
		var displayedTime:Float = Conductor.songPos;
		if(Conductor.songPos > PlayState.songLength)
			displayedTime = PlayState.songLength;
		
		timeTxt.text
		= CoolUtil.posToTimer(displayedTime)
		+ ' / '
		+ CoolUtil.posToTimer(PlayState.songLength);
		timeTxt.screenCenter(X);
	}

	public function updateHitbox(downscroll:Bool = false)
	{
		healthBar.bg.x = (FlxG.width / 2) - (healthBar.bg.width / 2);
		healthBar.bg.y = (downscroll ? 70 : FlxG.height - healthBar.bg.height - 50);
		healthBar.updatePos();
		
		updateText();
		infoTxt.screenCenter(X);
		infoTxt.y = healthBar.bg.y + healthBar.bg.height + 10;
		
		badScoreTxt.y = healthBar.bg.y - badScoreTxt.height - 4;
		
		updateTimeTxt();
		timeTxt.y = downscroll ? (FlxG.height - timeTxt.height - 8) : (8);
	}
	
	public function setAlpha(hudAlpha:Float = 1, ?tweenTime:Float = 0, ?ease:String = "cubeout")
	{
		// put the items you want to set invisible when the song starts here
		var allItems:Array<FlxSprite> = [
			infoTxt,
			timeTxt,
			healthBar.bg,
			healthBar.sideL,
			healthBar.sideR,
		];
		for(icon in healthBar.icons)
			allItems.push(icon);
		
		for(item in allItems)
		{
			if(tweenTime <= 0)
				item.alpha = hudAlpha;
			else
				FlxTween.tween(item, {alpha: hudAlpha}, tweenTime, {ease: CoolUtil.stringToEase(ease)});
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		health = FlxMath.lerp(health, PlayState.health, elapsed * 8);
		if(Math.abs(health - PlayState.health) <= 0.00001)
			health = PlayState.health;
		
		healthBar.percent = (health * 50);
		
		botplayTxt.visible = PlayState.botplay;
		badScoreTxt.visible = !PlayState.validScore;
		
		if(botplayTxt.visible)
		{
			botplaySin += elapsed * Math.PI;
			botplayTxt.alpha = 0.5 + Math.sin(botplaySin) * 0.8;
		}

		healthBar.updateIconPos();
		updateTimeTxt();
	}

	public function changeIcon(iconID:Int = 0, newIcon:String = "face")
	{
		healthBar.changeIcon(iconID, newIcon);
	}

	public function beatHit(curBeat:Int = 0)
	{
		if(curBeat % 2 == 0)
		{
			for(icon in healthBar.icons)
			{
				icon.scale.set(1.3,1.3);
				icon.updateHitbox();
				healthBar.updateIconPos();
			}
		}
	}
}