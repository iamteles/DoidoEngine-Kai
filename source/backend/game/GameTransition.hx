package backend.game;

import flixel.FlxSprite;
import flixel.util.FlxGradient;
import flixel.tweens.FlxTween;
import backend.game.GameData.MusicBeatSubState;

/*
	Transition between states.

	Usage: When changing between states, you can choose which transition will play.
	Main.switchState(new states.menu.MainMenuState(), "base");
*/

class GameTransition extends MusicBeatSubState
{	
	var fadeOut:Bool = false;
	var transition:String = 'base';
	
	// Callback at the end of the transition
	public var finishCallback:Void->Void;

	// Sprites used in transitions
	var sprBlack:FlxSprite;
	
	public function new(fadeOut:Bool = true, transition:String = 'base')
	{
		super();
		this.fadeOut = fadeOut;
		this.transition = transition;

		switch(transition) {
			default:
				sprBlack = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
				sprBlack.screenCenter();
				add(sprBlack);
				
				sprBlack.alpha = (fadeOut ? 1 : 0);
				FlxTween.tween(sprBlack, {alpha: fadeOut ? 0 : 1}, 0.32, {
					onComplete: function(twn:FlxTween)
					{
						endTransition();
					}
				});
		}
	}

	function endTransition()
	{
		if(finishCallback != null)
			finishCallback();
		else
			close();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		this.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		switch(transition) {
			default:
				// do nothing
		}
	}
}