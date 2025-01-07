package doido.objects.note;

import flixel.FlxSprite;
import flixel.math.FlxPoint;

class StrumNote extends FlxSprite
{
	public function new()
	{
		super();
	}

	public var strumData:Int = 0;
	public var assetModifier:String = "default";

	// use these to modchart
	public var strumSize:Float = 1.0;
	public var scaleOffset:FlxPoint = new FlxPoint(0,0);
	public var initialPos:FlxPoint = new FlxPoint(0,0);
	
	public var strumAngle:Float = 0;
	
	public function reloadStrum(strumData:Int, ?assetModifier:String = "default"):StrumNote
	{
		this.strumData = strumData;
		this.assetModifier = assetModifier;
		strumSize = 1.0;

		var direction = CoolUtil.getDirection(strumData);

		antialiasing = FlxSprite.defaultAntialiasing;
		isPixelSprite = false;

		switch(assetModifier)
		{
			default:
				strumSize = 0.7;
				frames = Paths.getSparrowAtlas("notes/base/strums");

				animation.addByPrefix("static",  'strum $direction static',  24, false);
				animation.addByPrefix("pressed", 'strum $direction pressed', 12, false);
				animation.addByPrefix("confirm", 'strum $direction confirm', 24, false);
		}
		playAnim("static"); // once to get the scale offset

		scale.set(strumSize, strumSize);
		updateHitbox();
		scaleOffset.set(offset.x, offset.y);

		playAnim("static"); // twice to use the scale offset

		return this;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		updateOffset();
	}
	
	public function playAnim(animName:String, force:Bool = false)
	{
		animation.play(animName, force);
		updateOffset();
	}
	
	public function updateOffset()
	{
		updateHitbox();
		offset.x += frameWidth * scale.x / 2;
		offset.y += frameHeight* scale.y / 2;
	}
}