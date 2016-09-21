package com.sndbar.utils
{
import com.sndbar.events.ID3Event;
import com.sndbar.vo.TrackVO;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.media.Sound;
import flash.media.SoundLoaderContext;
import flash.net.URLRequest;

//-----------------------------------------------------------------------------
//
//  Events
//
//-----------------------------------------------------------------------------

/**
 *  Dispatched when the ID3DataReader instance has completed reading the ID3 
 *  data from the file.
 * 
 *  @eventType com.sndbar.events.ID3Event.DATA_READY
 */
[Event(name="dataReady", type="com.sndbar.events.ID3Event")]

/**
 *  Dispatched when the ID3DataReader instance encounters some error condition
 * 
 *  @eventType com.sndbar.events.ID3Event.ID3_ERROR
 */
[Event(name="id3Error", type="com.sndbar.events.ID3Event")]

/**
 * The ID3DataReader class is used to read the ID3 tag information from an 
 * MP3 file and dispatches an ID3DataReadyEvent event. If no ID3 tag 
 * information was read, the ID3DataReadyEvent event is thrown with a TrackVo
 * having the track name as the file name.
 */
public class ID3DataReader extends EventDispatcher
{
	
	//-------------------------------------------------------------------------
	//
	//	Variables
	//
	//-------------------------------------------------------------------------
	/**
	 * @private
	 * The file will be loaded into this variable
	 */
	private var sound:Sound;
	
	/**
	 * @private
	 */
	private var trackVO:TrackVO;
	
	//-------------------------------------------------------------------------
	//
	//	Constructor
	//
	//-------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ID3DataReader(file:File)
	{
		if(file)
		{
			var context:SoundLoaderContext = new SoundLoaderContext(500, false);
			
			// Remove the file extension from the track title
			var fileName:String = file.name;
			var pos:int = fileName.lastIndexOf(file.extension);
			if(pos > 0)
				fileName = fileName.substring(0, pos - 1); 
			
			// Create the trackVo
			trackVO = new TrackVO();
			trackVO.title = fileName;
			trackVO.trackUrl = file.nativePath;
			
			sound = new Sound(new URLRequest(file.nativePath), context);
			sound.addEventListener(Event.ID3, onID3);
			sound.addEventListener(Event.COMPLETE, onSoundLoadComplete);
			sound.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}
	}
	
	/**
	 * This is the handler function when an IOError has occured on the
	 * sound object.
	 */
	private function onIOError(event:IOErrorEvent):void
	{
		removeSoundEventListeners();
		var errorEvent:ID3Event = new ID3Event(ID3Event.ID3_ERROR);
 		errorEvent.message = event.toString();
 		dispatchEvent(errorEvent);
	}
	
	/**
	 * This function will be called when the sound has been loaded completely
	 * so that we can read the duration of the file.
	 */
	private function onSoundLoadComplete(ev:Event):void
	{
		removeSoundEventListeners();		
 		try
 		{
 			var trackLength:Number = ev.target.length/1000;
 			trackVO.duration = trackLength;
 			var id3Event:ID3Event = new ID3Event(ID3Event.DATA_READY);
 			id3Event.trackVO = trackVO;
 			dispatchEvent(id3Event);
 		}
 		catch(e:Error)
 		{
 			var errorEvent:ID3Event = new ID3Event(ID3Event.ID3_ERROR);
 			errorEvent.message = e.message;
 			dispatchEvent(errorEvent);
 		}
 	}
	
	/**
	 * The handler that will be called when the ID3 information
	 * about the loaded file is available.
	 */
	private function onID3(event:Event):void
	{
		if(sound.id3.album)
			trackVO.album = sound.id3.album;
		if(sound.id3.artist)
			trackVO.artist = sound.id3.artist;
		if(sound.id3.songName)
			trackVO.title = sound.id3.songName;
		if(sound.id3.genre)
			trackVO.genre = sound.id3.genre;
	}
	
	/**
	 * This function will remove event listeners on the sound object.
	 */
	private function removeSoundEventListeners():void
	{
		if(sound)
		{
			sound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			sound.removeEventListener(Event.ID3, onID3);
			sound.removeEventListener(Event.COMPLETE, onSoundLoadComplete);
			sound = null;
		}
	}
}

}