package backend.utils;

import flixel.util.FlxColor;

typedef DoidoOffsets = {
	var animOffsets:Array<Array<Dynamic>>;
	var globalOffset:Array<Float>;
	var cameraOffset:Array<Float>;
	var ratingsOffset:Array<Float>;
}

typedef DoidoCharacter = {
	var spritesheet:String;
	var anims:Array<Dynamic>;
	var ?extrasheets:Array<String>;
}

enum SpriteType {
	SPARROW;
	PACKER;
	ASEPRITE;
	ATLAS;
	MULTISPARROW;
}

typedef Rimlight =
{
	var ?angle:Int;
	var ?threshold:Float;

    var ?brightness:Int;
    var ?hue:Int;
    var ?contrast:Int;
    var ?saturation:Int;

    var ?color:FlxColor;
}

class CharacterUtil
{
	inline public static function defaultRim():Rimlight
	{
		return {
			angle: 90,
			threshold: 0.1,

			brightness: -12,
			hue: 0,
			contrast: -20,
			saturation: 20,

			color: 0xFF5D3CEF
		};
	}

	inline public static function defaultOffsets():DoidoOffsets
	{
		return {
			animOffsets: [
				//["idle",0,0],
			],
			globalOffset: [0,0],
			cameraOffset: [0,0],
			ratingsOffset:[0,0]
		};
	}

	inline public static function defaultChar():DoidoCharacter
	{
		return {
			spritesheet: 'characters/',
			anims: [],
		};
	}

	inline public static function formatChar(char:String):String
		return char.substring(0, char.lastIndexOf('-'));

	public static function charList():Array<String>
	{
		return [
			"face",
			"face-underscore",
			"gf",
			"bf",
			"bf-dead",
		];
	}
}