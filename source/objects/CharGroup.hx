package objects;

import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import backend.shaders.*;
import backend.utils.CharacterUtil;

class CharGroup extends FlxTypedGroup<Character>
{
    public var loadedChars:Array<String> = [];
    public var isPlayer:Bool = false;
    public var curChar:String = 'bf';
    public var char:Character;

    public var rim:DropShadowShader;
    public var riminfo:Rimlight = null;
    
    public function new(isPlayer:Bool = false, curChar:String = "bf")
    {
        super();
        this.isPlayer = isPlayer;
        this.curChar = curChar;
        addChar(curChar);
        reload();
    }

    public function setRim(?angle:Int, ?threshold:Float, ?brightness:Int, ?hue:Int, ?contrast:Int, ?saturation:Int, ?color:FlxColor)
    {
        riminfo = CharacterUtil.defaultRim();

        if(angle != null)
            riminfo.angle = angle;
        if(threshold != null)
            riminfo.threshold = threshold;

        if(brightness != null)
            riminfo.brightness = brightness;
        if(hue != null)
            riminfo.hue = hue;
        if(contrast != null)
            riminfo.contrast = contrast;
        if(saturation != null)
            riminfo.saturation = saturation;

        if(color != null)
            riminfo.color = color;

        reload();
    }

    public function addChar(charName:String)
    {
        if(!loadedChars.contains(charName))
        {
            loadedChars.push(charName);
            var char = new Character(charName, isPlayer);
            add(char);
            if(isPlayer)
                addChar(char.deathChar);
        }
    }
    
    public function setPos(x:Float = 0, y:Float = 0)
    {
        for(char in members)
        {
            char.x = x - (char.width / 2);
            char.y = y - char.height;
            char.x += char.globalOffset.x;
            char.y += char.globalOffset.y;
        }
    }

    public function reload()
    {
        if(char != null)
            char.shader = null;

        for(i in members)
        {
            if(i.curChar != curChar)
                i.alpha = 0.0001;
            else
                char = i;
        }
        
        // avoids crashing ig
        if(char == null)
        {
            curChar = members[0].curChar;
            reload();
            return;
        }
        char.alpha = 1.0;

        if(riminfo != null && SaveData.data.get("Shaders")) {
            rim = new DropShadowShader();
            rim.setAdjustColor(riminfo.brightness, riminfo.hue, riminfo.contrast, riminfo.saturation);
            rim.color = riminfo.color;
            char.shader = rim;
            rim.attachedSprite = char;

            rim.angle = riminfo.angle;
            rim.threshold = riminfo.threshold;

            char.animation.callback = function(animName : String, frameNumber : Int, frameIndex : Int) {
              rim.updateFrameInfo(char.frame);
            };
        }
    }
}