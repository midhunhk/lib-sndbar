package com.sndbar.events
{
import flash.events.Event;

/**
 * The TimerTickEvent will be thrown by the AudioPlayer 
 * when the timer in AudioPlayer has completed a cycle.
 */
public class TimerTickEvent extends Event
{
	//-------------------------------------------------------------------------------------
	//
	//	Constants
	//
	//-------------------------------------------------------------------------------------	
	public static const TIMER_TICK:String = "timerTick"
	
	//-------------------------------------------------------------------------------------
	//
	//  Constructor
	//
	//-------------------------------------------------------------------------------------
	public function TimerTickEvent()
	{
		super(TIMER_TICK);
	}
	
}

}