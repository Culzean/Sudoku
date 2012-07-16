package  {
	import flash.net.URLLoader;
	import flash.events.Event;
	import com.adobe.serialization.json.*;
	import com.adobe.utils.StringUtil;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	import flash.errors.IOError;

	//import flash.filesystem.*;
	
	public class FileIO {


		private var JsonLoader:URLLoader = new URLLoader();
		private var arrayObject:Array = new Array();
		private var levelIndex:int = 0;
		private var curFname:String;
		
		public function FileIO() {
			// constructor code			
		}
		
		public function loadFile(fname:String):void{
			curFname = fname;
			JsonLoader.addEventListener(Event.COMPLETE, fileLoaderHandler);
			JsonLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			JsonLoader.load(new URLRequest(fname));
		}
		
		private function ioErrorHandler(event:IOError):void
		{
			trace("ioErrorHandler: " + event.message + "  " + event.name + "  " + event);
		}
		
		public function getCurFile():Array
		{
			var temp:Array = arrayObject.tiles;
			if(arrayObject.tiles.length != 0)
				return temp;
			else
			{
				trace("This file may not have been loaded yet" + arrayObject);
				return null;
			}
		}
		
		public function getArrayObject(levelReq:int):Object
		{
			if(levelIndex == levelReq){
				if(arrayObject.tiles.length != 0)
					return arrayObject;
				else
				{
					trace("This file may not have been loaded yet" + arrayObject);
					return null;
				}
			}else
				{
					levelIndex = levelReq;
					JsonLoader.addEventListener(Event.COMPLETE, fileLoaderHandler);
					JsonLoader.load(new URLRequest(curFname));
					trace("please wait. Loading game");
					return null;
				}
		}
		
		private function fileLoaderHandler(event:Event):Array
		{
			JsonLoader.removeEventListener(Event.COMPLETE, fileLoaderHandler);
			//var jsonDecode:JSONDecoder = new JSONDecoder();
			var raw:String = String(event.target.data);
			var jsonData = JSON.decode(raw, false);
			
			//place contents into an array
			arrayObject.tiles = jsonData.Games[levelIndex].tiles;
			arrayObject.title = jsonData.Games[levelIndex].title;
			arrayObject.header = jsonData.Header[0];
				
			trace(("This file contains : " + jsonData.Header[0] + "  objects" ));
			trace(("This game is : " + arrayObject.title + "  " + (arrayObject.tiles[4])));
			return arrayObject;
		}
		
	/*	public function saveFile(saveObject:Array, fname:String):void
		{
			var fileStream:FileStream = new FileStream();
			var filePath:String = "app:/" + "res/" + fname + ".json";
			var dirFile:File = new File(filePath);
			var file:File = new File(dirFile.nativePath);
			
			fileStream.addEventListener(Event.COMPLETE, saveCompleteHandler);
			fileStream.openAsync(file, FileMode.WRITE);
			
			//check current no of games
			//create entries for each game
			//pplace this solution at the correct entry
			trace("another val: " + String (saveObject.title));
			fileStream.writeUTFBytes("1. " +JSON.encode(saveObject.tiles));
			fileStream.close();
		}
		
		private function saveCompleteHandler(event:Event)
		{
			trace("This file has been saved");
		}*/
		
		private function formatGame(game:Object):String
		{
			var gameString:String;
			gameString
			
			return gameString;
		}
	}
	
}
