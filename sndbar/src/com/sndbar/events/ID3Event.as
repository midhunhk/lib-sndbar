package com.sndbar.events
{
import com.sndbar.vo.TrackVO;
import flash.events.Event;

/**
 * The ID3Event class defines the events thrown by the
 * ID3DataReader class.
 */
public class ID3Event extends Event
{
	//-------------------------------------------------------------------------
	//
	//	Constants
	//
	//-------------------------------------------------------------------------
	
	public static const ID3_ERROR:String = "id3Error";
	public static const DATA_READY:String = "dataReady";
	
	//-------------------------------------------------------------------------
	//
	//	Variables
	//
	//-------------------------------------------------------------------------
	
	public var trackVO:TrackVO;
	public var message:String;
	
	public function ID3Event(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
	{
		super(type, bubbles, cancelable);
	}
	
}
}