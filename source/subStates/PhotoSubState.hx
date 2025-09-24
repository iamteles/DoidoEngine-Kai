package subStates;

import backend.game.MusicBeatData.MusicBeatSubState;
import backend.song.Conductor;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.sound.FlxSound;
import objects.menu.Alphabet;
import objects.menu.AlphabetMenu;
import states.*;
import subStates.options.OptionsSubState;
import flixel.math.FlxPoint;

class PhotoSubState extends MusicBeatSubState
{
	var storedZoom:Float = 1;
	var storedScrollX:Float;
	var storedScrollY:Float;

    var storedHudA:Float = 1;
    var storedStrumA:Float = 1;

    var textsGrp:FlxTypedGroup<FlxText>;
    var banana:FlxSprite;

	public function new()
	{
		super();
		PlayState.instance.setScript("this", this);
		DiscordIO.changePresence("Paused - Restin' a bit");
		this.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

        textsGrp = new FlxTypedGroup<FlxText>();

        var width:Int = 0;
        var height:Int = 0;

        var textArray:Array<String> = [
            'Arrows - Move Camera',
            'Q / E - Zoom In/Out',
            'Shift - Increase Speed',
            'Tab - Hide HUD',
            'Control - Hide Controls',
            'BACK - Exit'
		];
		for(i in 0...textArray.length)
		{
			if(textArray[i] == "") continue;
		
			var text = new FlxText(0,0,0,textArray[i]);
			text.setFormat(Main.gFont, 36, 0xFFFFFFFF, RIGHT);
			text.setPosition(25, FlxG.height - (text.height*(textArray.length - i)) - 15);
            text.setBorderStyle(OUTLINE, 0xFF000000, 1.5);
			textsGrp.add(text);

            if(text.width > width)
                width = Std.int(text.width);

            height += Std.int(text.height);
		}

		banana = new FlxSprite().makeGraphic(width + 10, height + 10, 0xFF000000);
        banana.setPosition(20, FlxG.height - height - 20);
		add(banana);

		banana.alpha = 0.4;

        add(textsGrp);

        storedZoom = FlxG.camera.zoom;
        storedScrollX = FlxG.camera.scroll.x;
        storedScrollY = FlxG.camera.scroll.y;
        
        storedHudA = PlayState.instance.camHUD.alpha;
        storedStrumA = PlayState.instance.camStrum.alpha;
	}

    override function close()
    {
        FlxG.camera.zoom = storedZoom;
        FlxG.camera.scroll.x = storedScrollX;
        FlxG.camera.scroll.y = storedScrollY;

        PlayState.instance.camHUD.alpha = storedHudA;
        PlayState.instance.camStrum.alpha = storedStrumA;
        super.close();
    }

	var inputDelay:Float = 0.05;
    var hudHidden:Bool = false;
    var ctrlHidden:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(inputDelay > 0)
		{
			inputDelay -= elapsed;
			return;
		}

        var camSpeed:Float = elapsed * 400;
        var zoomSpeed:Float = elapsed * FlxG.camera.zoom;

        if(Controls.justPressed(SHIFT)) {
            camSpeed = elapsed * 1200;
            zoomSpeed = elapsed * FlxG.camera.zoom * 2;
        }

        if(Controls.pressed(UI_LEFT)) FlxG.camera.scroll.x -= camSpeed;
        if(Controls.pressed(UI_RIGHT)) FlxG.camera.scroll.x += camSpeed;
        if(Controls.pressed(UI_UP)) FlxG.camera.scroll.y -= camSpeed;
        if(Controls.pressed(UI_DOWN)) FlxG.camera.scroll.y += camSpeed;

        if(Controls.pressed(ZOOM_OUT) && FlxG.camera.zoom > 0.05) FlxG.camera.zoom -= zoomSpeed;
        if(Controls.pressed(ZOOM_IN) && FlxG.camera.zoom < 2.5) FlxG.camera.zoom += zoomSpeed;

        if(Controls.justPressed(TEXT_LOG)) {
            if(!hudHidden) {
                PlayState.instance.camHUD.alpha = 0;
                PlayState.instance.camStrum.alpha = 0;
            }
            else {
                PlayState.instance.camHUD.alpha = storedHudA;
                PlayState.instance.camStrum.alpha = storedStrumA;
            }

            hudHidden = !hudHidden;
        }

        if(Controls.justPressed(CONTROL)) {
            if(!ctrlHidden) {
                banana.alpha = 0;
                for(text in textsGrp) {
                    text.alpha = 0;
                }
            }
            else {
                banana.alpha = 0.4;
                for(text in textsGrp) {
                    text.alpha = 1;
                }
            }

            ctrlHidden = !ctrlHidden;
        }

        if(Controls.justPressed(BACK)) {
            close();
        }
	}
}