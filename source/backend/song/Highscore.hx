package backend.song;

typedef ScoreData = {
	var score:Float;
	var accuracy:Float;
	var breaks:Float;
}
class Highscore
{
	public static var highscoreMap:Map<String, ScoreData> = [];

	public static function addScore(song:String, newScore:ScoreData)
	{
		var oldScore:ScoreData = getScore(song);

		if(newScore.score >= oldScore.score)
			highscoreMap.set(song, newScore);
		
		save();
	}

	public static function getScore(song:String):ScoreData
	{
		if(!highscoreMap.exists(song))
			return {score: 0, accuracy: 0, breaks: 0};
		else
			return highscoreMap.get(song);
	}
	
	public static function save()
	{
		SaveData.saveProgression.data.highscoreMap = highscoreMap;
		SaveData.save();
	}

	public static function load()
	{
		if(SaveData.saveProgression.data.highscoreMap == null)
			SaveData.saveProgression.data.highscoreMap = highscoreMap;

		highscoreMap = SaveData.saveProgression.data.highscoreMap;

		save();
	}
}