package  {
	
	public class Tile {

		private var col:int;
		private var row:int;
		private var numb:int;
		private var boardPos:int;
		
		private const NO_CANDS:int = 9;
		private var candIndex:int = 0;
		private var candidates:Vector.<int> = new Vector.<int>(NO_CANDS, true);
		
		private var imageX:int;
		private var imageY:int;
		private var initialTile:Boolean = false;

		public function Tile(_col:int, _row:int, _numb:int) {
			col = _col;
			row = _row;
			numb = _numb;
			boardPos = ( _row * NO_CANDS ) + _col;
			FillCandidates();
		}
		
		private function FillCandidates()
		{
			for(var i:uint = 0; i< NO_CANDS; ++i)
			{
				candidates[i] = (i+1);
				//trace(candidates[i]);
			}
		}
		
		public function setImageX(xVal:int):void	{	imageX = xVal;		}
		public function setImageY(yVal:int):void	{	imageY = yVal;		}
		
		public function getImageX():int				{	return imageX;		}
		public function getImageY():int				{	return imageY;		}
		
		public function getInitial():Boolean							{	return initialTile;	}
		public function setInitial( newVal:Boolean ):void				{	initialTile = newVal;	}
		
		public function getBoardPos():int								{	return boardPos;	}
		public function setBoardPos( newVal:int ):void					{	boardPos = newVal;	}
		
		public function getNextCand():int
		{
			//much optimization here. would like to use a linked list
			if(this.initialTile)
				return 0;
			
			if(candIndex >= candidates.length){
				//trace("no more possible numbers to play here : " + this.boardPos +  "  " +  candIndex + "  cands: "+ candidates.length);
				return -1;
			}
			else
				return candidates[candIndex];
		}
		
		public function incrCand():void			{	++candIndex;	}
		
		public function resetCand():void
		{
			//trace("reset!  " + this.getBoardPos());
			candIndex = 0;
		}
		
		public function candsRem():Boolean
		{
			var temoB:Boolean;
			if(this.initialTile)
				temoB = false;
			else if(candIndex >= NO_CANDS)
				temoB = false;
			else 
				temoB = true;
			return temoB;
		}
		
		public function getCol():int
		{
			return col;
		}
		
		public function getRow():int{
			return row;
		}
		
		public function getNumb():int{
			return numb;
		}
		public function setNumb( val:int ):void{
			numb = val;
		}

	}
	
}
