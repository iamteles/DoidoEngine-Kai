package backend.song;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
}
typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	
	// psych suport
	var ?sectionBeats:Float;
}
typedef EventSong = {
	// [0] = section // [1] = strumTime // [2] events
	var songEvents:Array<Dynamic>;
}
typedef FunkyWeek = {
	var songs:Array<Array<String>>;
	var ?weekFile:String;
	var ?weekName:String;
	var ?chars:Array<String>;
	var ?freeplayOnly:Bool;
	var ?freeplayUnlock:String;
	var ?storyModeOnly:Bool;
	var ?diffs:Array<String>;
}

class SongData
{
	public static var defaultDiffs:Array<String> = ['normal'];
	public static var savedWeeks:Map<String, Bool> = [];
	public static var weeks:Array<FunkyWeek> = [
		/*{
			songs: [
				['bopeebo', 	'dad'],
				['fresh', 		'dad'],
				['dadbattle', 	'dad'],
			],
			weekFile: 'week1',
			weekName: 'daddy dearest',
			chars: ['dad', 'bf', 'gf'],
			diffs: ['easy', 'normal', 'hard', 'erect', 'nightmare'],
		},*/
		{
			songs: [
				["useless",			"dad"]
			],
			freeplayOnly: true,
		},
	];

	public static function load()
	{
		if(FlxG.save.data.weeks == null)
		{
			for(fWeek in weeks) {
				var week:String = fWeek.weekFile;
				savedWeeks.set(week, false);
			}

			FlxG.save.data.weeks = savedWeeks;
		}

		if(weeks.length != Lambda.count(FlxG.save.data.weeks)) {
			savedWeeks = FlxG.save.data.weeks;
			
			for(fWeek in weeks) {
				var week:String = fWeek.weekFile;
				trace("try week " + week);
				if(savedWeeks.get(week) == null) {
					savedWeeks.set(week, false);
					trace("set week " + week);
				}
			}

			FlxG.save.data.weeks = savedWeeks;
		}

		savedWeeks = FlxG.save.data.weeks;
		save();
	}

	public static function save()
	{
		FlxG.save.data.weeks = savedWeeks;
		FlxG.save.flush();
	}

	public static function unlockAll()
	{
		for(key => values in savedWeeks)
			savedWeeks[key] = true;

		save();
	}

	inline public static function getWeek(index:Int):FunkyWeek
	{
		var week = weeks[index];
		if(week == null)
			week = {songs: []};
		if(week.weekFile == null)
			week.weekFile = '$index';
		if(week.weekName == null)
			week.weekName = '';
		if(week.chars == null)
			week.chars = ['', '', ''];
		if(week.freeplayOnly == null)
			week.freeplayOnly = false;
		if(week.storyModeOnly == null)
			week.storyModeOnly = false;
		if(week.diffs == null)
			week.diffs = defaultDiffs;
		return week;
	}

	// fallback song. if you plan on removing -debug you should consider changing this to a song that does exist
	inline public static function defaultSong():SwagSong
	{
		return
		{
			song: "useless",
			notes: [],
			bpm: 100,
			needsVoices: true,
			speed: 1.0,

			player1: "bf",
			player2: "face",
		};
	}

	inline public static function defaultSection():SwagSection
	{
		return
		{
			sectionNotes: [],
			lengthInSteps: 16,
			mustHitSection: true,
			bpm: 100,
			changeBPM: false,
		};
	}
	inline public static function defaultSongEvents():EventSong
		return {songEvents: []};

	// [0] = section // [1] = strumTime // [2] events
	inline public static function defaultEventNote():Array<Dynamic>
		return [0, 0, []];
	inline public static function defaultEvent():Array<Dynamic>
		return ["name", "value1", "value2", "value3"];

	inline public static function loadFromJson(jsonInput:String, ?diff:String = "normal"):SwagSong
	{		
		Logs.print('Chart Loaded: ' + '$jsonInput/$diff');

		if(!Paths.fileExists('songs/$jsonInput/chart/$diff.json'))
			diff = "normal";
		
		var daSong:SwagSong = cast Paths.json('songs/$jsonInput/chart/$diff').song;
		
		// no need for SONG.song.toLowerCase() every time
		// the game auto-lowercases it now
		daSong.song = daSong.song.toLowerCase();
		if(daSong.song.contains(' '))
			daSong.song = daSong.song.replace(' ', '-');
		
		// formatting it
		daSong = formatSong(daSong);
		
		return daSong;
	}

	inline public static function loadEventsJson(jsonInput:String, diff:String = "normal"):EventSong
	{
		var formatPath = 'events-$diff';

		function checkFile():Bool {
			return Paths.fileExists('songs/$jsonInput/chart/$formatPath.json');
		}
		if(!checkFile())
			formatPath = 'events';
		if(!checkFile()) {
			Logs.print('No Events Loaded');
			return {songEvents: []};
		}

		Logs.print('Events Loaded: ' + '$jsonInput/chart/$formatPath');

		var daEvents:EventSong = cast Paths.json('songs/$jsonInput/chart/$formatPath');
		return daEvents;
	}
	
	// Removes duplicated notes from a chart.
	inline public static function formatSong(SONG:SwagSong):SwagSong
	{
		// cleaning multiple notes at the same place
		var removed:Int = 0;
		for(section in SONG.notes)
		{
			if(!Std.isOfType(section.lengthInSteps, Int))
			{
				var steps:Int = 16;
				if(section.sectionBeats != null)
					steps = Math.floor(section.sectionBeats * 4);
				
				section.lengthInSteps = steps;
			}
			
			for(songNotes in section.sectionNotes)
			{
				for(doubleNotes in section.sectionNotes)
				{
					if(songNotes 	!= doubleNotes
					&& songNotes[0] == doubleNotes[0]
					&& songNotes[1] == doubleNotes[1])
					{
						section.sectionNotes.remove(doubleNotes);
						removed++;
					}
				}
			}
		}
		if(removed > 0)
			Logs.print('removed $removed duplicated notes');
		
		return SONG;
	}
}