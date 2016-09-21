package com.sndbar.player
{
import com.sndbar.events.PlayerEvent;
import com.sndbar.events.TimerTickEvent;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundMixer;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import flash.system.System;
import flash.utils.Timer;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when an error occurs inside the AudioPlayer
 *
 *  <p>This event will be thrown when a generic error occurs
 *  inside the AudioPlayer instance.</p>
 * 
 *  @eventType com.sndbar.events.PlayerEvent.PLAYER_ERROR
 */
[Event(name="playerError", type="com.sndbar.events.PlayerEvent")]

/**
 *  Dispatched when the AudioPlayer mode has changed.
 *
 *  <p>This event will be thrown when a generic error occurs
 *  inside the AudioPlayer instance.</p>
 * 
 *  @eventType com.sndbar.events.PlayerEvent.PLAYER_MODE_CHANGED
 */
[Event(name="modeChanged", type="com.sndbar.events.PlayerEvent")]

/**
 *  Dispatched when the currently playing sound completes playing.
 * 
 *  @eventType com.sndbar.events.PlayerEvent.SOUND_COMPLETE
 */
[Event(name="soundComplete", type="com.sndbar.events.PlayerEvent")]

/**
 *  Dispatched each time the timer event ticks.
 *
 *  <p>The AudioPlayer class keeps a timer for managing the playing time 
 *  of the audio being played. This event can be watcthed by a parent
 *  for updating the progress of the file being playing.</p>
 * 
 *  @eventType com.sndbar.events.TimerTickEvent.TIMER_TICK
 */
[Event(name="timerTick", type="com.sndbar.events.TimerTickEvent")]


/**
 * The AudioPlayer class can play an MP3 file, pause, stop or change the
 * colume of the playing track. 
 *
 * <p>Usage : Create an instance of the AudioPlayer class, optionally set up 
 * listeners for events thrown by the class and invoke playSoundWithFilePath() 
 * method with the path of the file to play</p>
 */
public class AudioPlayer extends EventDispatcher
{
	//-------------------------------------------------------------------------
	//
	//	Constants
	//
	//-------------------------------------------------------------------------	
	 
	public static const CORE_VERSION:String = "1.1";
		
	//-------------------------------------------------------------------------
	//
	//	Variables
	//
	//-------------------------------------------------------------------------
	
	
	/**
	 * @private
	 * The Sound Object that will play the file for us.
	 */
	protected var sound:Sound;
	
	/**
	 * @private
	 * The Sound Channel Object that can be used for setting 
	 * parameters for the Sound
	 */
	protected var soundChannel:SoundChannel;
	
	/**
	 * @private
	 * sndTransfer object is used for setting volume parameters.
	 */
	protected var sndTransform:SoundTransform;
	
	/**
	 * @private
	 * The Timer object that runs when the file is being played.
	 */
	private var trackTimer:Timer;
	
	/**
	 * @private
	 * The pausePosition is used to keep track of the position
	 * when the player was paused.
	 */
	private var pausePosition:Number;
	
	//-------------------------------------------------------------------------
	//
	//	Constructor
	//
	//-------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function AudioPlayer()
	{
		pausePosition 		= 0;
	 	sndTransform 		= new SoundTransform();
	 	currentPlayerMode 	= PlayerMode.PLAYER_STOP;
	 	trackTimer 			= new Timer(1000);
		trackTimer.addEventListener(TimerEvent.TIMER, onTimerComplete);
	}
		
	//-------------------------------------------------------------------------
	//
	//	Properties
	//
	//-------------------------------------------------------------------------

	//---------------------------------
	// currentPlayerMode
	//---------------------------------
	
	/**
	 * @private
	 * currentPlayerMode
	 */
	private var _currentPlayerMode:String;
	
	/**
	 * Returns the Current Player Mode 
	 */
	[Inspectable(category="General", enumeration="play,stop,pause", defaultValue="stop")]
	public function get currentPlayerMode():String
	{
		return this._currentPlayerMode;
	}
	
	public function set currentPlayerMode(value:String):void
	{
		this._currentPlayerMode = value;
	}
	
	//---------------------------------
	// trackLength
	//---------------------------------
	
	/**
	 * @private
	 * trackLength
	 */
	 
	private var _trackLength:int;	
	
	/**
	 * Returns the total length of the sound file
	 */
	public function get trackLength():int
	{
		return this._trackLength;
	}
	
	public function set trackLength(value:int):void
	{
		this._trackLength = value;
	}
	
	//-------------------------------------------------------------------------
	//
	//	Core Player Methods
	//
	//-------------------------------------------------------------------------
	
	/**
	 * Plays the filePath passed as parameter
	 * 
	 * <p>File Formats supported are MP3, MP4 and AAC with
	 * Flash player version 9.0 Update 3 and above.</p>
	 * 
	 * @param filePath : The path of the file to be played
	 */
	public function playSoundWithFilePath(filePath:String):void
	{
		var urlRequest:URLRequest = new URLRequest(filePath);
		sound = new Sound();
		sound.addEventListener(Event.COMPLETE, onSoundLoadComplete);
        sound.addEventListener(IOErrorEvent.IO_ERROR, onSoundIOError);
        sound.load(urlRequest);
	}
	
	/**
	 * Stops the Sound Channel and resets the pausePosition
	 */
	public function stopPlayer():void
	{
		currentPlayerMode = PlayerMode.PLAYER_STOP;
		pausePosition = 0;
		stopSoundChannel();
		var modeChangedEvent:PlayerEvent = 
 			new PlayerEvent(PlayerEvent.PLAYER_MODE_CHANGED);
 		modeChangedEvent.playerMode = currentPlayerMode;
 		dispatchEvent(modeChangedEvent);
	}
	
	/**
	 * Saves the Current Position of the file and stops the SoundChannel
	 */
	public function pausePlayer():void
	{
		currentPlayerMode = PlayerMode.PLAYER_PAUSE;
		if(soundChannel)
			pausePosition = soundChannel.position;
		stopSoundChannel();
		var modeChangedEvent:PlayerEvent = 
 			new PlayerEvent(PlayerEvent.PLAYER_MODE_CHANGED);
 		modeChangedEvent.playerMode = currentPlayerMode;
 		dispatchEvent(modeChangedEvent);
	}
	
	/**
	 * @private
	 * This method will stop the Sound Channel and all sounds
	 */
	private function stopSoundChannel():void
	{
		SoundMixer.stopAll();
		if(soundChannel && sound)
		{
			soundChannel.stop();
			sound.removeEventListener(Event.COMPLETE, onSoundLoadComplete);
   			sound.removeEventListener(IOErrorEvent.IO_ERROR, onSoundIOError);
			sound = null;
			System.gc();
		}
		if(trackTimer)
			trackTimer.stop();
	}
	
	//-------------------------------------------------------------------------
	//
	//	Event Handlers
	//
	//-------------------------------------------------------------------------
	
	/**
	 * @private 
	 * This method will be invoked once the Audio file has been 
	 * successfully loaded.
	 */
	private function onSoundLoadComplete(event:Event):void
	{
 		try
 		{
 			currentPlayerMode = PlayerMode.PLAYER_PLAY;
 			soundChannel = sound.play(pausePosition, 0, sndTransform);
 			soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
 			trackLength = event.target.length / 1000;
 			pausePosition = 0;
 			trackTimer.start();
 			var modeChangedEvent:PlayerEvent = 
 				new PlayerEvent(PlayerEvent.PLAYER_MODE_CHANGED);
 			modeChangedEvent.playerMode = currentPlayerMode;
 			dispatchEvent(modeChangedEvent);
 		}
 		catch(e:Error)
 		{
 			if(trackTimer)
 				trackTimer.stop();
 		}
 	}
 	
 	/**
 	 * @private
 	 * This method will be invoked when the file has
 	 * finished playing.
 	 */
 	private function onSoundComplete(ev:Event=null):void
 	{
 		soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
 		soundChannel.removeEventListener(IOErrorEvent.IO_ERROR, onSoundIOError);
 		var soundCompleteEvent:PlayerEvent = 
 			new PlayerEvent(PlayerEvent.SOUND_COMPLETE);
   		this.dispatchEvent( soundCompleteEvent);
 	}
 	
 	/**
 	 * @private
 	 * This method will be invoked if any error occurs
 	 * while loading the Audio File.
 	 */
 	private function onSoundIOError(event:IOErrorEvent):void
 	{
 		soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
 		soundChannel.removeEventListener(IOErrorEvent.IO_ERROR, onSoundIOError);
 		soundChannel = null;
 		var playerEvent:PlayerEvent = new PlayerEvent(PlayerEvent.PLAYER_ERROR);
 		playerEvent.text = event.text;
		this.dispatchEvent( playerEvent);
	}
	
	/**
 	 * @private
 	 * This method will be invoked when the timer completes each cycle.
 	 */
	private function onTimerComplete(evt:TimerEvent):void 
	{
    	this.dispatchEvent(new TimerTickEvent());
    }
	
	//-------------------------------------------------------------------------
	//
	//	Other Public Methods
	//
	//-------------------------------------------------------------------------
	
	/**
	 * This method can be called to explicitly reset the
	 * <code>pausePosition</code> stored for the AudioPlayer instance.
	 */
	public function resetPausePosition():void
	{
		pausePosition = 0;
	}
	
	/**
	 * This method can be called to set the pausePosition
	 */
	public function setPausePosition(value:Number):void{
		if(value >= 0)
			pausePosition = value;
	}
	
	/**
	 * This method will return the current position of the play head
	 * in seconds.
	 * 
	 * @returns int current play head position in seconds
	 */
	public function getCurrentPosition():int
	{
		if(soundChannel)
			return soundChannel.position / 1000;
		return 0;
	}
	
	/**
	 * This method can be used to set the volume parameter
	 * 
	 * <p>The value can be a number between PlayerVolume.MIN_VOLUME
	 * and PlayerVolume.MAX_VOLUME. The value will be applied only
	 * if it is inbetween this range.</p>
	 * 
	 * @param value: The volume to be assigned to the sound channel
	 */
	public function setCurrentVolume(value:Number):void
	{
		// validate the value before storing it
		if(value >= PlayerVolume.MIN_VOLUME && value <= PlayerVolume.MAX_VOLUME)
			sndTransform.volume = value;
			
		// If a file is being played, update the sound channel 
		if(soundChannel)
			soundChannel.soundTransform = sndTransform;
	}
	
	/**
	 * This method will return the current value of the volume,
	 * which will be between MAX_VOLUME and MIN_VOLUME
	 * 
	 * @returns Number current audioPlayer volume
	 */
	public function getCurrentVolume():Number
	{
		return sndTransform.volume;
	}
}

}