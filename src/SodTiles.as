package  {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class SodTiles{

		private const width = 3;
		//this is a square
		public const COL_WIDTH = 9;
		
		private var boardTiles:Array = new Array();
		private var isComplete:Boolean = false;
		private var count:int;
		
		private var prevIndex:int = -1;
		private var prevVal:int = 0;
		
		private var maxTiles:int;
		
		public function SodTiles() {
			maxTiles = COL_WIDTH * COL_WIDTH;
		}
		
		public function assignArray( gameValues:Array ):void{
			count = 0;
			for(var i:int =0, end:int = gameValues.length; i< end; ++i)
			{
				var col:int = i % COL_WIDTH;
				var row:int = i / COL_WIDTH;
				boardTiles.push( new Tile( col, row, gameValues[i] ) );
				++count;
				if(gameValues[i] != 0)
				{
					//this values will not be changed
					boardTiles[i].setInitial(true);
				}
			}
		}

		public function swapTile( col:int, row:int, newFace:int ):Boolean
		{
			//how to ensure that we do not swap initial tile?
			var index:int = (row * COL_WIDTH) + col;
			prevIndex = index;
			if(newFace > -1 && newFace <= COL_WIDTH)
				{
					if(boardTiles[index].getInitial() == false)
					   {
						   prevVal = boardTiles[index].getNumb();
						   boardTiles[index].setNumb( newFace );
					   }
				}
			else
				trace("this new value is invalid");
			if(boardTiles[index].getNumb() == newFace)
				return true;
			else
				return false;
		}
		
		public function undo():Tile
		{
			//one step of undo
			var col:int;
			var row:int;
			if(prevIndex < 0)
				return null;
			else
			{
				col = prevIndex % COL_WIDTH;
				row = prevIndex / COL_WIDTH;
				this.swapTile(col,row,prevVal);
			}
			return this.getTile(prevIndex);
		}
		
		public function getArray():Array
		{
			return this.boardTiles;
		}
		
		public function length():int
		{
			return this.count;
		}
		
		public function getVal( tileCol:int, tileRow:int ):Tile
		{
			var tileIndex:int = (tileRow * COL_WIDTH) + (tileCol);
			if(tileIndex < maxTiles)
				return boardTiles[tileIndex];
			else{
				trace("requested tile out of bounds");
				return null;
			}
		}
		
		public function getTile( tileIndex:int ):Tile
		{
			if(tileIndex < maxTiles)
				return boardTiles[tileIndex];
			else
				return null;
		}
		
		public function readVal( index:int ):int
		{
			return boardTiles[index].getNumb();
		}
		
		public function setComp( newVal:Boolean )			{	isComplete = true;	}
		public function getComp():Boolean					{	return isComplete;	}

	}
	
}
