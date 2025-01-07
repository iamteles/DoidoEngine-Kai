package doido.objects;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxAxes;
import flxanimate.FlxAnimate;
import backend.utils.CharacterUtil;
import backend.utils.CharacterUtil.*;
import doido.objects.note.Note;

using StringTools;

class Character extends FlxAnimate
{
	public var curChar:String = "bf";
	public var isPlayer:Bool = false;
	public var onEditor:Bool = false;

	public var holdTimer:Float = Math.NEGATIVE_INFINITY;
	public var holdLength:Float = 0.7;
	public var holdLoop:Int = 4;

	public var idleAnims:Array<String> = ["idle"];
	public var altIdle:String = "";
	public var altSing:String = "";

	public var quickDancer:Bool = false;
	public var specialAnim:Int = 0;

	public var curAnimFrame(get, never):Int;
	public var curAnimFinished(get, never):Bool;
	public var curDirection(get, never):String;

	// warning, only uses this
	// if the current character doesnt have game over anims
	public var deathChar:String = "bf-dead";

	public var globalOffset:FlxPoint = new FlxPoint();
	public var cameraOffset:FlxPoint = new FlxPoint();
	public var ratingsOffset:FlxPoint = new FlxPoint();
	private var scaleOffset:FlxPoint = new FlxPoint();

	// you're probably gonna use sparrow by default?
	var spriteType:SpriteType = SPARROW;

	public function new(curChar:String = "bf", isPlayer:Bool = false, onEditor:Bool = false)
	{
		super(0,0,false);
		this.onEditor = onEditor;
		this.isPlayer = isPlayer;
		this.curChar = curChar;
		
		antialiasing = FlxSprite.defaultAntialiasing;
		isPixelSprite = false;
		
		var doidoChar = CharacterUtil.defaultChar();
		switch(curChar)
		{
			case "gf":
				spriteType = ATLAS;
				doidoChar.spritesheet += 'gf/gf-spritemap';
				doidoChar.anims = [
					['sad',			'gf sad',			24, false, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]],
					['danceLeft',	'GF Dancing Beat',	24, false, [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]],
					['danceRight',	'GF Dancing Beat',	24, false, [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]],
					
					['cheer', 		'GF Cheer', 	24, false],
					['singLEFT', 	'GF left note', 24, false],
					['singRIGHT', 	'GF Right Note',24, false],
					['singUP', 		'GF Up Note', 	24, false],
					['singDOWN', 	'GF Down Note', 24, false],
				];

				idleAnims = ["danceLeft", "danceRight"];
				quickDancer = true;
				flipX = isPlayer;
			
			case "no-gf":
				doidoChar.spritesheet += 'gf/no-gf/no-gf';
				doidoChar.anims = [
					['idle', 'idle'],
				];

			default: // case "bf"
				if(!["bf", "face"].contains(curChar))
					curChar = (isPlayer ? "bf" : "face");

				if(curChar == "bf")
				{
					doidoChar.spritesheet += 'bf/BOYFRIEND';
					doidoChar.anims = [
						['idle', 			'BF idle dance', 		24, false],
						['singUP', 			'BF NOTE UP0', 			24, false],
						['singLEFT', 		'BF NOTE LEFT0', 		24, false],
						['singRIGHT', 		'BF NOTE RIGHT0', 		24, false],
						['singDOWN', 		'BF NOTE DOWN0', 		24, false],
						['singUPmiss', 		'BF NOTE UP MISS', 		24, false],
						['singLEFTmiss', 	'BF NOTE LEFT MISS', 	24, false],
						['singRIGHTmiss', 	'BF NOTE RIGHT MISS', 	24, false],
						['singDOWNmiss', 	'BF NOTE DOWN MISS', 	24, false],
						['hey', 			'BF HEY', 				24, false],
						['scared', 			'BF idle shaking', 		24, true],
					];
					
					flipX = true;
				}
				else if(curChar == "face")
				{
					spriteType = ATLAS;
					doidoChar.spritesheet += 'face';
					doidoChar.anims = [
						['idle', 			'idle-alive', 		24, false],
						['idlemiss', 		'idle-dead', 		24, false],

						['singLEFT', 		'left-alive', 		24, false],
						['singDOWN', 		'down-alive', 		24, false],
						['singUP', 			'up-alive', 		24, false],
						['singRIGHT', 		'right-alive', 		24, false],
						['singLEFTmiss', 	'left-dead', 		24, false],
						['singDOWNmiss', 	'down-dead', 		24, false],
						['singUPmiss', 		'up-dead', 			24, false],
						['singRIGHTmiss', 	'right-dead', 		24, false],
					];
				}
				this.curChar = curChar;
			
			case "bf-dead":
				doidoChar.spritesheet += 'bf/BOYFRIEND';
				doidoChar.anims = [
					['firstDeath', 		"BF dies", 			24, false],
					['deathLoop', 		"BF Dead Loop", 	24, true],
					['deathConfirm', 	"BF Dead confirm", 	24, false],
				];

				idleAnims = ['firstDeath'];
				
				flipX = true;
		}

		if(spriteType != ATLAS)
		{
			if(Paths.fileExists('images/${doidoChar.spritesheet}.txt')) {
				frames = Paths.getPackerAtlas(doidoChar.spritesheet);
				spriteType = PACKER;
			}
			else if(Paths.fileExists('images/${doidoChar.spritesheet}.json')) {
				frames = Paths.getAsepriteAtlas(doidoChar.spritesheet);
				spriteType = ASEPRITE;
			}
			else if(doidoChar.extrasheets != null) {
				frames = Paths.getMultiSparrowAtlas(doidoChar.spritesheet, doidoChar.extrasheets);
				spriteType = MULTISPARROW;
			}
			else
				frames = Paths.getSparrowAtlas(doidoChar.spritesheet);

			for(i in 0...doidoChar.anims.length)
			{
				var anim:Array<Dynamic> = doidoChar.anims[i];
				if(anim.length > 4)
					animation.addByIndices(anim[0],  anim[1], anim[4], "", anim[2], anim[3]);
				else
					animation.addByPrefix(anim[0], anim[1], anim[2], anim[3]);
			}
		}
		else
		{
			// :shushing_face:
			isAnimateAtlas = true;

			loadAtlas(Paths.getPath('images/${doidoChar.spritesheet}'));
			showPivot = false;
			for(i in 0...doidoChar.anims.length)
			{
				var dAnim:Array<Dynamic> = doidoChar.anims[i];
				if(dAnim.length > 4)
					anim.addBySymbolIndices(dAnim[0], dAnim[1], dAnim[4], dAnim[2], dAnim[3]);
				else
					anim.addBySymbol(dAnim[0], dAnim[1], dAnim[2], dAnim[3]);
			}
		}

		// adding animations to array
		for(i in 0...doidoChar.anims.length) {
			var daAnim = doidoChar.anims[i][0];
			if(animExists(daAnim) && !animList.contains(daAnim))
				animList.push(daAnim);
		}

		// prevents crashing
		for(i in 0...idleAnims.length)
		{
			if(!animList.contains(idleAnims[i]))
				idleAnims[i] = animList[0];
		}
		
		// offset gettin'
		switch(curChar)
		{
			default:
				try {
					var charData:DoidoOffsets = cast Paths.json('images/characters/_offsets/${curChar}');
					
					for(i in 0...charData.animOffsets.length)
					{
						var animData:Array<Dynamic> = charData.animOffsets[i];
						addOffset(animData[0], animData[1], animData[2]);
					}
					globalOffset.set(charData.globalOffset[0], charData.globalOffset[1]);
					cameraOffset.set(charData.cameraOffset[0], charData.cameraOffset[1]);
					ratingsOffset.set(charData.ratingsOffset[0], charData.ratingsOffset[1]);
				} catch(e) {
					Logs.print('$curChar offsets not found', WARNING);
				}
		}
		
		playAnim(idleAnims[0]);

		updateHitbox();
		scaleOffset.set(offset.x, offset.y);

		if(isPlayer)
			flipX = !flipX;

		dance();
	}

	private var curDance:Int = 0;

	public function dance(forced:Bool = false)
	{
		if(specialAnim > 0) return;

		switch(curChar)
		{
			default:
				var daIdle = idleAnims[curDance];
				if(animExists(daIdle + altIdle))
					daIdle += altIdle;
				playAnim(daIdle);
				curDance++;

				if (curDance >= idleAnims.length)
					curDance = 0;
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if(!onEditor)
		{
			if(animExists(curAnimName + '-loop') && curAnimFinished)
				playAnim(curAnimName + '-loop');
	
			if(specialAnim > 0 && specialAnim != 3 && curAnimFinished)
			{
				specialAnim = 0;
				dance();
			}
		}
	}

	public var singAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	public var absoluteAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	public function playNote(note:Note, miss:Bool = false)
	{
		var daAnim:String = singAnims[note.noteData];
		if(animExists(daAnim + 'miss') && miss)
			daAnim += 'miss';

		if(animExists(daAnim + altSing))
			daAnim += altSing;

		holdTimer = 0;
		specialAnim = 0;
		playAnim(daAnim, true);
	}

	// animation handler
	public var curAnimName:String = '';
	public var animList:Array<String> = [];
	public var animOffsets:Map<String, Array<Float>> = [];

	public function addOffset(animName:String, offX:Float = 0, offY:Float = 0):Void
		return animOffsets.set(animName, [offX, offY]);

	public function playAnim(animName:String, ?forced:Bool = false, ?reversed:Bool = false, ?frame:Int = 0)
	{
		if(!animExists(animName)) return;
		
		curAnimName = animName;
		if(spriteType != ATLAS)
			animation.play(animName, forced, reversed, frame);
		else
			anim.play(animName, forced, reversed, frame);
		
		try
		{
			var daOffset = animOffsets.get(animName);
			offset.set(daOffset[0] * scale.x, daOffset[1] * scale.y);
		}
		catch(e)
			offset.set(0,0);

		// useful for pixel notes since their offsets are not 0, 0 by default
		offset.x += scaleOffset.x;
		offset.y += scaleOffset.y;
	}

	public function invertDirections(axes:FlxAxes = NONE)
	{
		switch(axes) {
			case X:
				singAnims = ['singRIGHT', 'singDOWN', 'singUP', 'singLEFT'];
			case Y:
				singAnims = ['singLEFT', 'singUP', 'singDOWN', 'singRIGHT'];
			case XY:
				singAnims = ['singRIGHT', 'singUP', 'singDOWN', 'singLEFT'];
			default:
				singAnims = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
		}
	}

	public function pauseAnim()
	{
		if(spriteType != ATLAS)
			animation.pause();
		else
			anim.pause();
	}

	public function animExists(animName:String):Bool
	{
		if(spriteType != ATLAS)
			return animation.getByName(animName) != null;
		else
			return anim.getByName(animName) != null;
	}

	public function get_curAnimFrame():Int
	{
		if(spriteType != ATLAS)
			return animation.curAnim.curFrame;
		else
			return anim.curSymbol.curFrame;
	}

	public function get_curAnimFinished():Bool
	{
		if(spriteType != ATLAS)
			return animation.curAnim.finished;
		else
			return anim.finished;
	}

	public function get_curDirection():String
	{
		for (i in 0...singAnims.length) {
			if(curAnimName.startsWith(singAnims[i]) && !curAnimName.endsWith('miss')) {
				//trace(absoluteAnims[i]);
				return absoluteAnims[i];	
			}
		}

		return 'none';
	}
}