package objects.hud;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import backend.song.Conductor;
import states.PlayState;

enum IconChange {
    PLAYER;
    ENEMY;
}
class HudClass extends FlxGroup
{
    public var hudName:String = "";

    var separator:String = " | ";
	public var health:Float = 1;
    public var songTime:Float = 0.0;
    public var downscroll:Bool = false;

    public var subtitleA:FlxText;
	public var subtitleB:FlxText;

    public var ratingGrp:FlxGroup;

    public var alpha(default, set):Float = 1.0;
    // sprites that get affected by the alpha
    public var alphaList:Array<FlxSprite> = [];

    public function set_alpha(v:Float):Float
    {
        alpha = v;
        for(item in alphaList)
            if(item != null)
                item.alpha = alpha;
        return alpha;
    }

	public function new(hudName:String)
	{
		super();
        this.hudName = hudName;
        ratingGrp = new FlxGroup();
		health = PlayState.health;
        songTime = 0;

        subtitleA = new FlxText(0,0,0,"");
		subtitleA.setFormat(Main.gFont, 30, 0xFFFFFFFF, CENTER);
		subtitleA.setBorderStyle(OUTLINE, 0xFF000000, 2);
		subtitleA.screenCenter(X);
		subtitleA.y = FlxG.height - subtitleA.height - 160;
		add(subtitleA);

        subtitleB = new FlxText(0,0,0,"");
		subtitleB.setFormat(Main.gFont, 30, 0xFFFFFFFF, CENTER);
		subtitleB.setBorderStyle(OUTLINE, 0xFF000000, 2);
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

	public function updateInfoTxt() {}
	
	public function updateTimeTxt()
    {
		songTime = FlxMath.bound(Conductor.songPos, 0, PlayState.songLength);
	}

    public function addRating(rating:Rating)
    {
        ratingGrp.add(rating);
    }

	public function changeIcon(newIcon:String = "face", type:IconChange = ENEMY) {}

    public function stepHit(curStep:Int = 0) {}
	public function beatHit(curBeat:Int = 0) {}

    public function enableTimeTxt(enabled:Bool) {}

    public function updatePositions()
    {
        updateInfoTxt();
        updateTimeTxt();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        health = FlxMath.lerp(health, PlayState.health, elapsed * 8);
        if(Math.abs(health - PlayState.health) <= 0.00001)
            health = PlayState.health;
        updateTimeTxt();
    }
}