package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	
	
	public class OldManBob extends MovieClip {
		
		private var _mouseX:int;
		private var _mouseY:int;
		private var follow:Boolean = false;
		private var hasWon:Boolean = false;
		
		public function OldManBob() {
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			this.win.visible = false;
			trace("I'm ready to play");
		}
		
		public function update():void
		{
			var manRightEye:Point = new Point(this.rightEye.x, this.rightEye.y);
			var manRightEye_X:Number = this.localToGlobal(manRightEye).x;
			var manRightEye_Y:Number = this.localToGlobal(manRightEye).y;
			
			var manLeftEye:Point = new Point(this.leftEye.x, this.leftEye.y);
			var manLeftEye_X:Number = this.localToGlobal(manLeftEye).x;
			var manLeftEye_Y:Number = this.localToGlobal(manLeftEye).y;
			
			this.rightEye.rotation = Math.atan2(manRightEye_Y - _mouseY, manRightEye_X - _mouseX) * (180/Math.PI);
			this.leftEye.rotation = Math.atan2(manLeftEye_Y - _mouseY, manLeftEye_X - _mouseX) * (180/Math.PI);
		}
		
		public function mouseMove(event:MouseEvent):void
		{
			if(follow)
			{
				_mouseX = event.stageX;
				_mouseY = event.stageY;
			}
		}
		
		public function setWin(win:Boolean):void
		{
			hasWon = win;
			this.win.visible = true;
		}
		
		public function setFollow(val:Boolean):void
		{
			follow = val;
			this.whites.visible = follow;
			this.rightEye.visible = follow;
			this.leftEye.visible = follow;
		}
	}
	
}
