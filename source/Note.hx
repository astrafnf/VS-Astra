package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import PlayState;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;
	public static var noteScale:Float;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;
	public static var FIFTH_NOTE:Int = 4;

	public var rating:String = "shit";

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false)
	{
		swagWidth = 160 * 0.7;
		noteScale = 0.7;
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		if (inCharter)
			this.strumTime = strumTime;
		else 
			this.strumTime = Math.round(strumTime);

		if (this.strumTime < 0 )
			this.strumTime = 0;

		this.noteData = noteData;

		frames = Paths.getSparrowAtlas('NOTE_assets');

		animation.addByPrefix('greenScroll', 'green instance 1');
		animation.addByPrefix('redScroll', 'red instance 1');
		animation.addByPrefix('blueScroll', 'blue instance 1');
		animation.addByPrefix('purpleScroll', 'purple instance 1');
		animation.addByPrefix('fifthScroll', 'fifth instance 1');

		animation.addByPrefix('purpleholdend', 'pruple end hold instance 1');
		animation.addByPrefix('greenholdend', 'green hold end instance 1');
		animation.addByPrefix('redholdend', 'red hold end instance 1');
		animation.addByPrefix('blueholdend', 'blue hold end instance 1');
		animation.addByPrefix('fifthholdend', 'fifth hold end instance 1');

		animation.addByPrefix('purplehold', 'purple hold piece instance 1');
		animation.addByPrefix('greenhold', 'green hold piece instance 1');
		animation.addByPrefix('redhold', 'red hold piece instance 1');
		animation.addByPrefix('bluehold', 'blue hold piece instance 1');
		animation.addByPrefix('fifthhold', 'fifth hold piece instance 1');

		setGraphicSize(Std.int(width * noteScale));
		updateHitbox();
		antialiasing = true;

		var frameN:Array<String> = ['purple', 'blue', 'green', 'red'];
		if (PlayState.SONG.noteStyle == 'five') frameN = ['purple', 'blue', 'fifth', 'green', 'red'];

		x += swagWidth * noteData;
		animation.play(frameN[noteData] + 'Scroll');

		// trace(prevNote);

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		if (FlxG.save.data.downscroll && sustainNote) 
			flipY = true;

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			animation.play(frameN[noteData] + 'holdend');

			updateHitbox();

			x -= width / 2;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(frameN[noteData] + 'hold');

				if(FlxG.save.data.scrollSpeed != 1)
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * FlxG.save.data.scrollSpeed;
				else
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// ass
			if (isSustainNote)
			{
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
					&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
					canBeHit = true;
				else
					canBeHit = false;
			}

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
