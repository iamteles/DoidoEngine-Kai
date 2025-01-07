package objects;

import backend.game.GameData.MusicBeatState;
import backend.utils.DialogueUtil;
import backend.song.*;
import backend.song.SongData.EventSong;
import backend.song.SongData.SwagSong;
import backend.song.SongData.SwagSection;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import objects.*;
import objects.hud.*;
import objects.note.*;
import objects.dialogue.Dialogue;
import shaders.*;
import states.editors.*;
import states.menu.*;
import subStates.*;
import states.PlayState;

class PlayField extends FlxGroup
{
    public var strumlines:FlxTypedGroup<Strumline>;
	public var bfStrumline:Strumline;
	public var dadStrumline:Strumline;

    public var unspawnNotes:Array<Note> = [];
    var unspawnCount:Int = 0;

    var downscroll:Bool;

    public function new(unspawnNotes:Array<Note>, dad:CharGroup, boyfriend:CharGroup, noteskins:Array<String>)
    {
        super();

        downscroll = SaveData.data.get("Downscroll");
        this.unspawnNotes = unspawnNotes;

        // strumlines
		strumlines = new FlxTypedGroup();
		add(strumlines);

        dadStrumline = new Strumline(0, dad, downscroll, false, true, noteskins[0]);
		dadStrumline.ID = 0;
		strumlines.add(dadStrumline);
		
		bfStrumline = new Strumline(0, boyfriend, downscroll, true, false, noteskins[1]);
		bfStrumline.ID = 1;
		strumlines.add(bfStrumline);
		
		for(strumline in strumlines.members)
		{
			if(strumline.customData) continue;
			strumline.x = setStrumlineDefaultX()[strumline.ID];
			strumline.scrollSpeed = PlayState.SONG.speed;
			strumline.updateHitbox();
		}

        for(note in unspawnNotes)
        {
            var thisStrumline = dadStrumline;
            for(strumline in strumlines)
                if(note.strumlineID == strumline.ID)
                    thisStrumline = strumline;
            
            var noteAssetMod:String = noteskins[1];

            if(thisStrumline == dadStrumline)
                noteAssetMod = noteskins[0];
            
            note.updateData(note.songTime, note.noteData, note.noteType, noteAssetMod);
            note.reloadSprite();
            note.setSongOffset();
            
            thisStrumline.addSplash(note);
        }

        for(strumline in strumlines.members)
        {
            var strumMult:Int = (strumline.downscroll ? 1 : -1);
            for(strum in strumline.strumGroup)
            {
                strum.y += CoolUtil.noteWidth() * 0.6 * strumMult;
                strum.alpha = 0.0001;
            }
        }
    }

    public function introTween()
    {
        for(strumline in strumlines.members)
        {
            for(strum in strumline.strumGroup)
            {	
                // dad's notes spawn backwards
                var strumMult:Int = (strumline.isPlayer ? strum.strumData : 3 - strum.strumData);

                // actual tween
                FlxTween.tween(strum, {y: strum.initialPos.y, alpha: 0.9}, Conductor.crochet / 1000, {
                    ease: FlxEase.cubeOut,
                    startDelay: Conductor.crochet / 2 / 1000 * strumMult,
                });
            }
        }
    }

    public var pressed:Array<Bool> 		= [];
	public var justPressed:Array<Bool> 	= [];
	public var released:Array<Bool> 	= [];

    public var paused:Bool = false;

    override function update(elapsed:Float) {
        super.update(elapsed);

        pressed = [
			Controls.pressed(LEFT),
			Controls.pressed(DOWN),
			Controls.pressed(UP),
			Controls.pressed(RIGHT),
		];
		justPressed = [
			Controls.justPressed(LEFT),
			Controls.justPressed(DOWN),
			Controls.justPressed(UP),
			Controls.justPressed(RIGHT),
		];
		released = [
			Controls.released(LEFT),
			Controls.released(DOWN),
			Controls.released(UP),
			Controls.released(RIGHT),
		];

		// adding notes to strumlines
		if(unspawnCount < unspawnNotes.length)
        {
            var unsNote = unspawnNotes[unspawnCount];
            
            var thisStrumline = dadStrumline;
            for(strumline in strumlines)
                if(unsNote.strumlineID == strumline.ID)
                    thisStrumline = strumline;
            
            var spawnTime:Int = 3200;
            if(thisStrumline.scrollSpeed <= 1.5)
                spawnTime *= 2;
            
            if(unsNote.songTime - Conductor.songPos <= spawnTime)
            {
                unsNote.y = FlxG.height * 4;
                thisStrumline.addNote(unsNote);
                unspawnCount++;
            }
        }

        var botplay = PlayState.botplay;
        
        // strumline handler!!
        for(strumline in strumlines.members)
        {
            if(strumline.isPlayer)
                strumline.botplay = botplay;
            
            for(strum in strumline.strumGroup)
            {
                // no botplay animations
                if(strumline.isPlayer && !strumline.botplay)
                {
                    if(pressed[strum.strumData])
                    {
                        if(!["pressed", "confirm"].contains(strum.animation.curAnim.name))
                            strum.playAnim("pressed");
                    }
                    else
                        strum.playAnim("static");
                    
                    if(strum.animation.curAnim.name == "confirm")
                        PlayState.playerSinging = true;
                }
                else // how botplay handles it
                {
                    if(strum.animation.curAnim.name == "confirm"
                    && strum.animation.curAnim.finished)
                        strum.playAnim("static");
                }
            }

            updateNotes();
            
            if(justPressed.contains(true) && !strumline.botplay && strumline.isPlayer)
            {
                for(i in 0...justPressed.length)
                {
                    if(justPressed[i])
                    {
                        var possibleHitNotes:Array<Note> = []; // gets the possible ones
                        var canHitNote:Note = null;
                        
                        for(note in strumline.noteGroup)
                        {
                            var noteDiff:Float = note.noteDiff();
                            
                            var minTiming:Float = Timings.minTiming;
                            if(note.mustMiss)
                                minTiming = Timings.getTimings("good")[1];
                            
                            if(noteDiff <= minTiming && !note.missed && !note.gotHit && note.noteData == i)
                            {
                                if(note.mustMiss
                                && Conductor.songPos >= note.songTime + Timings.getTimings("sick")[1])
                                {
                                    continue;
                                }
                                
                                possibleHitNotes.push(note);
                                canHitNote = note;
                            }
                        }
                        
                        // if the note actually exists then you got it
                        if(canHitNote != null)
                        {
                            for(note in possibleHitNotes)
                            {
                                if(note.songTime < canHitNote.songTime)
                                    canHitNote = note;
                            }

                            checkNoteHit(canHitNote, strumline);
                        }
                        else // you ghost tapped lol
                        {
                           // if(!ghostTapping && startedCountdown)
                            //{
                            //    var note = new Note();
                            //    note.updateData(0, i, "none", assetModifier);
                            //    //note.reloadSprite();
                            //    onNoteMiss(note, strumline, true);
                            //}
                        }
                    }
                }
            }
        }
    }

	public function updateNotes()
    {
        for(strumline in strumlines)
        {
            for(hold in strumline.holdGroup)
            {
                if(hold.scrollSpeed != strumline.scrollSpeed)
                {
                    hold.scrollSpeed = strumline.scrollSpeed;
                    
                    hold.holdClipHeight = hold.noteCrochet * (strumline.scrollSpeed * 0.45) + 2;
                    if(!hold.isHoldEnd)
                    {
                        var holdWidth:Float = hold.frameWidth * hold.scale.x;

                        if(DevOptions.splitHolds)
                            hold.holdClipHeight *= 0.7;
                        
                        hold.setGraphicSize(
                            Math.floor(holdWidth),
                            Std.int(hold.holdClipHeight)
                        );
                    }
                    hold.updateHitbox();
                }
            }
            
            for(note in strumline.allNotes)
            {
                if(!paused)
                {
                    var despawnTime:Int = 300;
                    
                    if(Conductor.songPos >= note.songTime + Conductor.inputOffset + note.holdLength + Conductor.crochet + despawnTime)
                    {
                        if(!note.gotHit && !note.missed && !note.mustMiss && !strumline.botplay)
                            onNoteMiss(note, strumline);
                        
                        note.clipRect = null;
                        strumline.removeNote(note);
                        note.destroy();
                        continue;
                    }

                    note.setAlpha();
                }
                note.updateHitbox();
                note.offset.x += note.frameWidth * note.scale.x / 2;
                if(note.isHold)
                {
                    note.offset.y = 0;
                    note.origin.y = 0;
                }
                else
                    note.offset.y += note.frameHeight * note.scale.y / 2;
            }
        
            for(note in strumline.noteGroup)
            {
                var thisStrum = strumline.strumGroup.members[note.noteData];
                
                // follows the strum
                var offsetX = note.noteOffset.x;
                var offsetY = (note.songTime - Conductor.songPos) * (strumline.scrollSpeed * 0.45);
                
                var noteAngle:Float = (note.noteAngle + thisStrum.strumAngle);
                if(strumline.downscroll)
                    noteAngle += 180;
                
                note.angle = thisStrum.angle;
                if(!strumline.pauseNotes) {
                    CoolUtil.setNotePos(note, thisStrum, noteAngle, offsetX, offsetY);
                }
                
                // alings the hold notes
                for(hold in note.children)
                {
                    var offsetY = hold.noteCrochet * (strumline.scrollSpeed * 0.45) * hold.ID;
                    
                    hold.angle = -noteAngle;
                    CoolUtil.setNotePos(hold, note, noteAngle, offsetX, offsetY);
                }
                
                if(!paused)
                {
                    // hitting / missing notes automatically
                    if(strumline.botplay)
                    {
                        if(note.songTime - Conductor.songPos <= 0 && !note.gotHit && !note.mustMiss)
                            checkNoteHit(note, strumline);
                    }
                    else
                    {
                        if(Conductor.songPos >= note.songTime + Timings.getTimings("good")[1]
                        && !note.gotHit && !note.missed && !note.mustMiss)
                            onNoteMiss(note, strumline);
                    }
                    
                    // doesnt actually do anything
                    if (note.scrollSpeed != strumline.scrollSpeed)
                        note.scrollSpeed = strumline.scrollSpeed;
                }
            }
            
            if(!paused)
            {
                for(hold in strumline.holdGroup)
                {
                    var holdParent = hold.parentNote;
                    if(holdParent != null)
                    {
                        var thisStrum = strumline.strumGroup.members[hold.noteData];
                        
                        if(holdParent.gotHeld && !hold.missed)
                        {
                            hold.gotHeld = true;
                            hold.holdHitLength = (Conductor.songPos - hold.songTime);
                            
                            // calculating the clipping by how much you held the note
                            if(!strumline.pauseNotes)
                            {
                                var daRect = new FlxRect(0, 0,
                                    hold.frameWidth,
                                    hold.frameHeight
                                );
                                
                                var holdID:Float = hold.ID;
                                
                                if(DevOptions.splitHolds)
                                    holdID -= 0.2;

                                var minSize:Float = hold.holdHitLength - (hold.noteCrochet * holdID);
                                var maxSize:Float = hold.noteCrochet;
                                if(minSize > maxSize)
                                    minSize = maxSize;
                                
                                if(minSize > 0)
                                    daRect.y = (minSize / maxSize) * (hold.holdClipHeight / hold.scale.y);
                                
                                hold.clipRect = daRect;
                            }
                            
                            var notPressed = (!pressed[hold.noteData] && !strumline.botplay && strumline.isPlayer);
                            var holdPercent:Float = (hold.holdHitLength / holdParent.holdLength);
            
                            if(hold.isHoldEnd && !notPressed)
                                onNoteHold(hold, strumline);
                            
                            if(notPressed || holdPercent >= 1.0)
                            {
                                hold.gotReleased = true;
                                if(holdPercent > 0.3)
                                {
                                    if(hold.isHoldEnd && !hold.gotHit)
                                        onNoteHit(hold, strumline);
                                    hold.missed = false;
                                    hold.gotHit = true;
                                }
                                else
                                    onNoteMiss(hold, strumline);
                            }
                        }
                        
                        if(holdParent.missed && !hold.missed)
                            onNoteMiss(hold, strumline);
                    }
                }
            }
        }
    }

    // check if you actually hit it
	public function checkNoteHit(note:Note, strumline:Strumline)
    {
        if(!note.mustMiss)
            onNoteHit(note, strumline);
        else
            onNoteMiss(note, strumline);
    }
}