package objects.hud;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class HudClass extends FlxGroup
{
	public var ratingGrp:FlxGroup;

	public var subtitleA:FlxText;
	public var subtitleB:FlxText;

	var separator:String = " | ";

	public function new()
	{
		super();
		ratingGrp = new FlxGroup();
		add(ratingGrp);
		
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
	}

	public function updateLyrics(lineA:String = "", lineB:String = "") {
		subtitleA.text = lineA;
		subtitleB.text = lineB;

		for(text in [subtitleA, subtitleB]) {
			text.scale.set(1.2 + 0.3,1.2);
		}

		subtitleA.screenCenter(X);
		subtitleA.y = FlxG.height - subtitleA.height - 160;
		subtitleB.screenCenter(X);
		subtitleB.y = subtitleA.y - subtitleB.height - 2;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		for(text in [subtitleA, subtitleB]) {
			text.scale.set(
				FlxMath.lerp(text.scale.x, 1 + 0.3, FlxG.elapsed * 6),
				FlxMath.lerp(text.scale.y, 1, FlxG.elapsed * 6)
			);
		}
	}

	function _setAlpha(items:Array<FlxSprite>, hudAlpha:Float = 1, ?tweenTime:Float = 0, ?ease:String = "cubeout") {
		for(item in items)
		{
			if(tweenTime <= 0)
				item.alpha = hudAlpha;
			else
				FlxTween.tween(item, {alpha: hudAlpha}, tweenTime, {ease: CoolUtil.stringToEase(ease)});
		}
	}

	//expand later
	public function updateText() {}
	public function updateHitbox(downscroll:Bool = false) {}
	public function setAlpha(hudAlpha:Float = 1, ?tweenTime:Float = 0, ?ease:String = "cubeout") {}
	public function beatHit(curBeat:Int = 0) {}
	public function changeIcon(iconID:Int = 0, newIcon:String = "face") {}
}