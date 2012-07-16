package  {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.Sprite;
	
	public class SodButton extends Sprite{

		private var btWidth:int;
		private var btHeight:int;
		private var offSet:int;
		
		private var action:Boolean = false;
		private var clicked:Boolean = false;
		
		private var btText:TextField;
		private var textFormat:TextFormat;

		public function SodButton(xPos:int, yPos:int) 
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			this.x = xPos;		this.y = yPos;
		}
		
		private function Init():void
		{
			btWidth = 96;
			btHeight = 54;
			offSet = 10;
			textFormat = new TextFormat();
			btText = new TextField();
			textFormat.size = 15;
			textFormat.bold = true;
			btText.defaultTextFormat = textFormat;
			btText.text = "default";
			btText.x = 30;
			btText.y = 22;
			btText.width = 46;
			btText.height = 20;
			
			this.useHandCursor = true;
			this.buttonMode = true;
			this.mouseChildren = false;
			
			graphics.beginFill(0xFF33AA88,1);
			graphics.drawRect(0,0,btWidth,btHeight);
			graphics.endFill();
			
			addChild(btText);
		}
		
		public function setPos(xPos:int, yPos:int)			{	this.x = xPos;		this.y = yPos;		}	
		
		public function setText(newText:String):void		{			btText.text = newText;		}
		
		public function getText():String					{			return btText.text;		}
		
		public function getAction():Boolean					{		return action;		}
		
		public function setAction( newVal:Boolean ):void	{		action = newVal;	}
		
		private function drawOver(event:MouseEvent)
		{
			graphics.beginFill(0xFF8800,1);
			graphics.drawRect(0,0,btWidth,btHeight);
			graphics.endFill();
		}
		
		private function onClicked(event:MouseEvent)
		{
			drawWait(event);
				graphics.beginFill(0xFF0000,1);
				graphics.drawRect(offSet * 0.5,offSet * 0.5,btWidth-offSet,btHeight-offSet);
				graphics.endFill();
				action = true;

		}
		
		private function drawWait(event:MouseEvent)
		{
			graphics.beginFill(0xFF33AA88,1);
			graphics.drawRect(0,0,btWidth,btHeight);
			graphics.endFill();
		}
		public function resetState(event:MouseEvent):void
		{
			//why doesn't this reset the wait state?
			drawWait(event);
		}
		
		private function onAdded(event:Event):void
		{
			Init();
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			addEventListener(MouseEvent.CLICK, onClicked);
			addEventListener(MouseEvent.ROLL_OVER, drawOver);
			addEventListener(MouseEvent.ROLL_OUT, drawWait);
		}
		
		private function onRemoved(event:Event):void
		{
			removeChild(btText);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			removeEventListener(MouseEvent.CLICK, onClicked);
			removeEventListener(MouseEvent.ROLL_OVER, drawOver);
			removeEventListener(MouseEvent.ROLL_OUT, drawWait);
		}

	}
	
}
