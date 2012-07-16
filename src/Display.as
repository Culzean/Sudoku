package  {
	import flash.display.Sprite;
	import flashx.textLayout.formats.Float;
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.ColorTransform;
	
	public class Display extends Sprite{
	
	private var _stage:Object;
	private var screen:Sprite = new Sprite();
	 private var stageBitmapData:BitmapData
	 = new BitmapData(800,600,true,0);
	 private var stageBitmap:Bitmap
	 = new Bitmap(stageBitmapData);
	private var effectsBitData:BitmapData
	= new BitmapData(800,600,true,0);
	private var effectsBitmap:Bitmap
	= new Bitmap(effectsBitData);
	
	private var mainWidth:int;
	private var mainHeight:int;
	private const aspect:Number = 0.52895;
	private var sodWidth:int;
	private var screenColor:uint;
	private const NORM_COLOR:uint = 0xFF550033;
	private const WIN_COLOR:uint = 0xFF339955;
	public const CORT_COLOR:uint = 0xFF22AA44;
	public const WRONG_COLOR:uint = 0xFFAA3333;
	public const BLANK_COLOR:uint = 0xFF334477;
	
	private var gameBoard:SodBoard;
	
		public function Display(stage:Object, _width:int, _height:int ) {
			mainWidth = _width;
			mainHeight = _height;
			trace("urgh" + mainWidth);
			sodWidth = int (mainWidth *  aspect);
			_stage = stage;

			screenColor = NORM_COLOR;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function placeBoard(boardRef:SodBoard):void
		{
			gameBoard = boardRef;
			this.addChild(gameBoard);
		}
		
		private function init(event:Event):void
		{
			trace("@@on added!");
			this.screen.graphics.beginFill(0xFF000000,1);
			stageBitmapData.fillRect(stageBitmapData.rect, 0xFF8833AA);
			addChild(stageBitmap);
			addChild(effectsBitmap);
		}
		
		public function update():void
		{
			stageBitmapData.fillRect(stageBitmapData.rect, screenColor);
			effectsBitData.fillRect(effectsBitData.rect, 0x00000000);
		}
		
		public function getSodWidth():int{
			return sodWidth;
		}
		
		public function getBitmap():Bitmap
		{
			return stageBitmap;
		}
		
		public function getScrBitData():BitmapData{
			return stageBitmapData;
		}
		public function getEffectsBitData():BitmapData{
			return effectsBitData;
		}
		
		public function setColor(win:Boolean):void
		{
			if(win)
				screenColor = WIN_COLOR;
			else
				screenColor = NORM_COLOR;
		}

	}
	
}
