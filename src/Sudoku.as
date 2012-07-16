package  {
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import com.adobe.serialization.json.JSON;
	import flash.events.Event;
	
	[SWF(width="800", height="640", backgroundColor="#0000FF", frameRate="60")]
	
	public class Sudoku extends MovieClip{

		import com.adobe.utils.ArrayUtil;
		
		private const MainWidth:int = 800;
		private const MainHeight:int = 640;
		
		private var controller:Controller;
		private var mainDis:Display;

		public function Sudoku() {
			// constructor code
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function  onAdded(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded)
			mainDis = new Display(stage, MainWidth, MainHeight);
			
			controller = new Controller(stage, mainDis);
			addChild(mainDis);
			trace("YO");
		}

	}
	
}
