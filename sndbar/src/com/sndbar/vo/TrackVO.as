package com.sndbar.vo
{
	public class TrackVO
	{
		private var _title:String;
		private var _artist:String;
		private var _album:String;
		private var _trackUrl:String;
		private var _albumArtUrl:String;
		private var _duration:Number;
		private var _genre:String;
		
		public function set title(value:String):void{
			_title = value;
		}		
		public function get title():String{
			return _title;
		}
		
		public function set artist(value:String):void{
			_artist = value;
		}		
		public function get artist():String{
			return _artist;
		}
		
		public function set album(value:String):void{
			_album = value;
		}		
		public function get album():String{
			return _album;
		}
		
		public function set albumArtUrl(value:String):void{
			_albumArtUrl = value;
		}		
		public function get albumArtUrl():String{
			return _albumArtUrl;
		}
		
		public function set trackUrl(value:String):void{
			_trackUrl = value;
		}		
		public function get trackUrl():String{
			return _trackUrl;
		}
		
		public function set genre(value:String):void{
			_genre = value;
		}		
		public function get genre():String{
			return _genre;
		}
		
		public function set duration(value:Number):void{
			_duration = value;
		}		
		public function get duration():Number{
			return _duration;
		}
	}
}