package  {
	
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.media.SoundChannel;
	import flash.events.Event;
	
	public class SoundManager {

		private static var manager:SoundManager = new SoundManager();

		private var soundArray:Array = new Array();
		private var sndIndex:int = 0;
		private const NO_SNDS:int = 4;
		
		private var tile1:Sound = new snd1();
		private var tile2:Sound = new snd2();
		private var tile3:Sound = new snd3();
		private var tile4:Sound = new snd4();

		private static var channel1:SoundChannel;
		private var engaged1:Boolean = false;
		
		public function SoundManager() {
			
			channel1 = new SoundChannel();
			if( manager )
			throw new Error( "SoundManager and can only be accessed through SoundManager.getInstance()" );
		}
		
		public static function getInstance():SoundManager
		{
			return manager;
		}
		
		public function loadSounds():void
		{
			soundArray.push(tile1);
			soundArray.push(tile2);
			soundArray.push(tile3);
			soundArray.push(tile4);
		}
		
		public function playSound(  ):void
		{
			var rand:int = (Math.floor(Math.random() * NO_SNDS * 1.6));
			trace("play a random track: " + rand);
			if(NO_SNDS > rand)
			{channel1 = soundArray[rand].play();
			channel1.addEventListener(Event.SOUND_COMPLETE, onChannel1Complete);
			}
		}

		
		private function onChannel1Complete(event:Event):void
		{
			channel1.stop();
			engaged1 = false;
			channel1.removeEventListener(Event.SOUND_COMPLETE, onChannel1Complete);
		}

	}
	
}
