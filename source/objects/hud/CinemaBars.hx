package objects.hud;

import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

class CinemaBars extends FlxTypedGroup<FlxSprite>
{
    public var pos:Float = 320;
    public var speed:Float = 6;

    private var size:Array<Int> = [FlxG.width * 2, 140];

    public function new() {
        super();
        for(i in 0...2) {
            var bar = new FlxSprite().makeGraphic(size[0], size[1], 0xFF000000);
            bar.ID = i;
            add(bar);
        }
        updatePos(1);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        updatePos(elapsed * speed);
    }

    public function updatePos(lerp:Float)
    {
        var itemPos:Array<Float> = [-pos, FlxG.height - size[1] + pos];
        for(item in members)
            item.y = FlxMath.lerp(item.y, itemPos[item.ID], lerp);
    }
}