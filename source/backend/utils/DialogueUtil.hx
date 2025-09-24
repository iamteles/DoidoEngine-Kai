package backend.utils;

typedef DialogueData = {
	var pages:Array<DialoguePage>;
}

typedef DialoguePage = {
	// box
	var ?boxSkin:String;
	// character
	var ?char:String;
	var ?charAnim:String;
	// images
	var ?underlayAlpha:Float;
	var ?background:DialogueSprite;
	var ?foreground:DialogueSprite;
	// dialogue text
	var ?text:String;
	// text settings
	var ?textDelay:Float;
	var ?fontFamily:String;
	var ?fontScale:Float;
	var ?fontColor:Int;
	var ?fontBold:Bool;
	// text border
	var ?fontBorderType:String;
	var ?fontBorderColor:Int;
	var ?fontBorderSize:Float;
	// music and sound
	var ?music:String;
	var ?clickSfx:String;
	var ?scrollSfx:Array<String>;
	// event
	var ?events:Array<DialogueEvent>;
}

typedef DialogueSprite = {
	var name:String;
	var image:String;
	// position
	var ?x:Float;
	var ?y:Float;
	var ?screenCenter:String;
	// other sprite stuff
	var ?scale:Float;
	var ?alpha:Float;
	// flipping
	var ?flipX:Bool;
	var ?flipY:Bool;
	// animation array
	var ?animations:Array<Animation>;
}

typedef Animation = {
	var name:String;
	var prefix:String;
	var framerate:Int;
	var looped:Bool;
}

typedef DialogueEvent = {
	var name:String;
	var ?values:Array<String>;
}

class DialogueUtil
{
	public static function loadDialogue(song:String, diff:String = "normal"):DialogueData
	{
		switch(song)
		{
			default:
				if(Paths.fileExists('songs/$song/dialogue/dialogue-$diff.json'))
					return cast Paths.json('songs/$song/dialogue/dialogue-$diff');
				else if (Paths.fileExists('songs/$song/dialogue/dialogue.json'))
					return cast Paths.json('songs/$song/dialogue/dialogue');
				else
					return defaultDialogue();
		};
	}

	inline public static function defaultDialogue():DialogueData
		return{pages: []};

	// Hardcoded DialogueData
	public static function loadCode(song:String):DialogueData
	{
		return switch(song)
		{
			/*
			case 'senpai':
				{
					pages:[
						{
							boxSkin: 'school',
							fontFamily: 'vcr.otf',
							fontColor: 0xFF3F2021,
							fontScale: 0.8,
							
							fontBorderType: 'shadow',
							fontBorderColor: 0xFFD89494,
							fontBorderSize: 4,

							music: 'dialogue/lunchbox',
							clickSfx: 'dialogue/clickText',
							scrollSfx: ['dialogue/talking'],
							
							// character
							char: 'senpai',
							
							text: 'Ah, a new fair maiden has come in search of true love!'
						},
						{
							text: 'A serenade between gentlemen shall decide where her beautiful heart shall reside.'
						},
						{
							char: 'bf-pixel',
							text: 'Beep bo bop'
						}
					]
				}
			*/
			default:
				defaultDialogue();
		}
	}
}