package com.sndbar.events
{
import flash.events.Event;

/**
 * The PlayerEvent class defines events throwsn by the
 * AudioPlayer class.
 */
public class PlayerEvent extends Event
{
	//-------------------------------------------------------------------------
	//
	//	Constants
	//
	//-------------------------------------------------------------------------
	
	public static const PLAYER_ERROR:String 		= "playerError";
	public static const SOUND_COMPLETE:String 		= "soundComplete";
	public static const PLAYER_MODE_CHANGED:String 	= "modeChanged";
	
	//-------------------------------------------------------------------------
	//
	//	Variables
	//
	//-------------------------------------------------------------------------
	public var text:String;
	public var playerMode:String;
	
	//-------------------------------------------------------------------------
	//
	//  Constructor
	//
	//-------------------------------------------------------------------------
	
	public function PlayerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
	{
		super(type, bubbles, cancelable);
	}
	
}
}