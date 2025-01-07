package doido.states.menu;

import backend.game.GameData.MusicBeatState;
import backend.game.GameTransition;
import doido.subStates.options.OptionsSubState;

class OptionsState extends MusicBeatState
{
    override function create()
    {
        super.create();

        var options = new OptionsSubState();
        
        openSubState(options);
        
        options.openSubState(new GameTransition(true));
    }
}