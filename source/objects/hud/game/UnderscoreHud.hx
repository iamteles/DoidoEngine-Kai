package objects.hud.game;

import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import backend.song.Conductor;
import backend.song.Timings;
import states.PlayState;

class UnderscoreHud extends HudClass
{
	public var infoTxt:FlxText;
	public var timeTxt:FlxText;
	public var cornerMark:FlxText;

	var botplaySin:Float = 0;
	var botplayTxt:FlxText;
	var badScoreTxt:FlxText;

	// health
	public var healthBar:HealthBar;
	public var health:Float = 1;

	public var engineDisplay:String = "DE KAI v3.4.1k";
	final timeCounter:Bool = false;

	public function new()
	{	
        super();
		healthBar = new HealthBar();
		changeIcon(0, healthBar.icons[0].curIcon);
		add(healthBar);

		infoTxt = new FlxText(0, 0, 0, '');
		infoTxt.setFormat(Main.gFont, 18, FlxColor.WHITE);
		infoTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		add(infoTxt);

		cornerMark = new FlxText(0, 0, 0, engineDisplay);
		cornerMark.setFormat(Main.gFont, 18, FlxColor.WHITE);
		cornerMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		cornerMark.setPosition(FlxG.width - (cornerMark.width + 5), 5);
		add(cornerMark);

		timeTxt = new FlxText(0, 0, 0, "nuts / balls even");
		timeTxt.setFormat(Main.gFont, 24, 0xFFFFFFFF, CENTER);
		timeTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		timeTxt.visible = true;
		if(!timeCounter)
			timeTxt.text = '- ${PlayState.SONG.song.toUpperCase()} [${PlayState.songDiff.toUpperCase()}] -';
		timeTxt.screenCenter(X);
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

		health = PlayState.health;
        updateHitbox();
	}

	private var divider:String = " • ";

	override public function updateText()
	{
		var comboDisplay:String = '';
		if(Timings.breaks == 0 && Timings.notesHit > 0)
			comboDisplay = "FC";
		else if(Timings.breaks < 10 && Timings.notesHit > 0)
			comboDisplay = "SDCB";
		else
			comboDisplay = Timings.getRank();

		infoTxt.text = 'Score: ${Timings.score}'
			+ (divider + 'Accuracy: ${Timings.accuracy}%')
			+ (divider + 'Combo Breaks: ${Timings.breaks}')
			+ (divider + 'Rank: $comboDisplay')
			+ '\n';

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

	override public function updateHitbox(downscroll:Bool = false)
	{
		healthBar.bg.x = (FlxG.width / 2) - (healthBar.bg.width / 2);
		healthBar.bg.y = (downscroll ? 70 : FlxG.height - healthBar.bg.height - 50);
		healthBar.updatePos();
		
		updateText();

        infoTxt.screenCenter(X);
        infoTxt.y = healthBar.bg.y + 30;
		
		badScoreTxt.y = healthBar.bg.y - badScoreTxt.height - 4;
		
		if(timeCounter)
			updateTimeTxt();

		timeTxt.y = downscroll ? FlxG.height - 40 : 10;
	}
	
	override public function setAlpha(hudAlpha:Float = 1, ?tweenTime:Float = 0, ?ease:String = "cubeout")
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
		
        _setAlpha(allItems, hudAlpha, tweenTime, ease);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		health = FlxMath.lerp(health, PlayState.health, elapsed * 8);
		if(Math.abs(health - PlayState.health) <= 0.00001 || PlayState.SONG.song == "da-vinci-funkin")
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

		if(timeCounter)
			updateTimeTxt();
	}

	override public function changeIcon(iconID:Int = 0, newIcon:String = "face")
	{
		healthBar.changeIcon(iconID, newIcon);
	}

	override public function beatHit(curBeat:Int = 0)
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