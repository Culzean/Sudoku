package  {
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.net.URLLoader;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.display.LoaderInfo;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	import flash.events.MouseEvent;
	import flash.display.Shape;
	import flash.display.*;
	
	public class SodBoard extends Sprite{
		
		private var helpBoard1:Sprite;
		private var helpBoard2:Sprite;
		private var boardWidth:int;
		private var boardHeight:int;
		private var tileWidth:int;
		private var tileIndnt:int;
		private var playerWidth:int;
		private var playerHeight:int;
		private const playerRatio:Number = 0.88;
		
		private var boardBitData:BitmapData;
		private var boardBitmap:Bitmap;
		private var tilesBitData:BitmapData;
		private var tilesBitmap:Bitmap;
		private var playerBitmap:Bitmap;
		private var playerBitData:BitmapData;
		private var tilesLoader:Loader;
		private var scrBitmap:Display;
		private var grid:Shape;
		
		private var gameCounters:Array = new Array();
		private var tileCount:int = 0;

		private var currentGame:SodTiles;
		private var holdTile:int = -1;//if -1 no tile
		private var handTile:Tile = new Tile(-1,-1,0);
		private var _mouseX:int;
		private var _mouseY:int;
		private var swapCol:int;
		private var swapRow:int;
		private var makeSwap:Boolean = false;
		private var showHelp:Boolean = false;
		
		private var sndManager:SoundManager;

		public function SodBoard(iwidth:int, iheight:int, disRef:Display, gameRef:SodTiles) {
			scrBitmap = disRef;
			boardWidth = iwidth;
			boardHeight = iheight;
			currentGame = gameRef;
			loadImage();
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded(event:Event):void{
			scrBitmap.addChild(boardBitmap);
			scrBitmap.addChild(playerBitmap);
			this.addChild(helpBoard1);
			this.addChild(helpBoard2);
			scrBitmap.setChildIndex(boardBitmap, 1);
			scrBitmap.setChildIndex(playerBitmap, 1);
			boardBitData.fillRect(boardBitData.rect, 0x00FFFFFF);
			sndManager = SoundManager.getInstance();
			trace("board placed");
		}
		
		public function changeBoard(updateGame:SodTiles):void
		{
			currentGame = updateGame;
		}
		
		public function getBoard():SodTiles		{			return currentGame;		}
		
		public function Undo():void
		{
			var temp:Tile = currentGame.undo();
			if(temp != null)
				this.selectImage(temp);
		}
		
		public function update():Boolean
		{
			boardBitData.fillRect(boardBitData.rect, 0x00FFFFFF);
			//playerBitData.fillRect(boardBitData.rect, 0x00FFFF00);
			for(var col:int =0, endCol:int = currentGame.COL_WIDTH; col<endCol; ++col)
			{
				for(var row:int=0, endRow:int = currentGame.COL_WIDTH; row<endRow; ++row)
				{
					blitTile(boardBitData, currentGame.getVal(col,row));
				}
			}
			if(holdTile > -1)
			{
				//draw this tile at mouse Pos
				blitTile( scrBitmap.getEffectsBitData() ,handTile );
				if(showHelp)
					{
						helpBoard1.visible = true;
						this.setChildIndex(helpBoard1, 0);
					}
			}
			else
			{
				this.setChildIndex(helpBoard2, 0);
				helpBoard1.visible = false;
			}
			if(holdTile > -1 && makeSwap == true)
			{
				sndManager.playSound();
				currentGame.swapTile(swapCol, swapRow, holdTile);
					//if(check){
				var tempTile:Tile = currentGame.getVal(swapCol, swapRow);
				this.selectImage(tempTile);
				trace("one more event: " + tempTile.getNumb());
				//reset var
				makeSwap = false;
				holdTile = -1;
				swapRow = -1; swapCol = -1;
					//}
				return true;
			}
			return false;
		}
		
		public function clearHelp():void
		{
			while(helpBoard1.numChildren > 0)
				{
					this.helpBoard1.removeChildAt(0);
				}
			while(helpBoard2.numChildren > 0)
				{
					this.helpBoard2.removeChildAt(0);
				}
		}
		
		public function swapBoard(refGame:SodTiles):void
		{
			this.clearHelp();
				
			for(var col:int =0, endCol:int = refGame.COL_WIDTH; col<endCol; ++col)
			{
				for(var row:int=0, endRow:int = refGame.COL_WIDTH; row<endRow; ++row)
				{
					var tile:Tile = refGame.getVal(col,row);
					selectImage(tile);
					if(tile.getInitial())
					{
						placeSquare(row,col,row,col, scrBitmap.BLANK_COLOR);
					}
				}
			}
		}
		
		public function createBoard(currentGame:SodTiles):void
		{
			//no boarder?
			tileWidth = boardWidth / currentGame.COL_WIDTH;
			tileIndnt = tileWidth * 0.36;
			trace("And the tile is this long? " + tileWidth);
			boardBitData = new BitmapData(boardWidth,boardWidth,false, 0);
			boardBitmap = new Bitmap(boardBitData);
			helpBoard1 = new Sprite();
			helpBoard2 = new Sprite();
			
			this.x = boardWidth * 0.75;
			this.y = boardWidth * 0.1; 
			boardBitmap.x = boardWidth * 0.75;
			boardBitmap.y = boardWidth * 0.1;
			
			for(var col:int =0, endCol:int = currentGame.COL_WIDTH; col<endCol; ++col)
			{
				for(var row:int=0, endRow:int = currentGame.COL_WIDTH; row<endRow; ++row)
				{
					var tile:Tile = currentGame.getVal(col,row);
					++tileCount;
					selectImage(tile);
					if(tile.getInitial())
						placeSquare(row,col,row,col, scrBitmap.BLANK_COLOR);
				}
			}
			//create the player's rack of placement numbers
			//and place this object on the screen
			playerHeight = tileWidth * playerRatio;
			playerWidth = (boardWidth + tileWidth) * playerRatio;
			
			playerBitData = new BitmapData( playerWidth, playerHeight, false, 0);
			
			playerRack();
			playerBitmap.x = boardWidth * 0.45;
			playerBitmap.y = boardWidth * 1.2;
			
			this.selectImage(handTile);
			
			this.drawGrid();
			trace("tile placement complete");
		}
		
		private function loadImage():void
		{
			tilesLoader = new Loader();
			tilesLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoadedHandler);
			tilesLoader.load(new URLRequest("/sites/default/files/SodNumbs_0.png"));
		}
		
		private function imageLoadedHandler(event:Event)
		{
			//tilesBitData = event.target.content.bitmapData;
			tilesBitData = Bitmap(LoaderInfo(event.target).content).bitmapData;
			tilesBitmap = new Bitmap(tilesBitData);
			trace("Image Loaded, width height: " + tilesBitmap.width + "  " + tilesBitmap.height);
		}
		
		private function selectImage(tile:Tile):void
		{
			var imageX:int;
			var imageY:int;
			var tileVal = tile.getNumb();
			if(tileVal == 0)
			{
				//pick a random y, a random x greater than 2 * tilewidth
				//origin is top left
				imageX = Math.random() * ( tilesBitmap.width - tileWidth );
				imageY = (Math.random() * ( tilesBitmap.height - ( tileWidth * 3 ) ));
			}else if(tileVal > 7){
				//check the number, greater than 7 increase y
				imageX = ( (tileVal - 7) * tileWidth);//not usign the left edge
				imageY = tilesBitmap.height - (tileWidth * 2);
			}else{
				imageX = (tileVal * tileWidth) + tileWidth;//not usign the left edge
				imageY = tilesBitmap.height - tileWidth;
			}
			
			//tidy up the selection
			imageX = ( imageX - (imageX % tileWidth) );
			imageY = ( imageY - (imageY % tileWidth) );
			
			tile.setImageX(imageX);
			tile.setImageY(imageY);
		}
		
		private function playerRack():void
		{
			var matrix:Matrix = new Matrix();
			matrix.scale(playerRatio,playerRatio);
			var tempBitData:BitmapData = new BitmapData( (tileWidth * 10), tileWidth, false, 0);
			
			for(var i:int = 0; i<10; ++i)
			{
				var tile:Tile = new Tile(i,0,(i));
				this.selectImage(tile);
				blitTile( tempBitData, tile );
			}
			
			playerBitData.draw(tempBitData, matrix, null, null, null, true);
			playerBitmap = new Bitmap( playerBitData );
		}
		
		private function blitTile(destBitData:BitmapData, tile:Tile)
		{
			//local board coordniates for tile
			var xPos:int;
			var yPos:int;
			if(tile.getCol() == -1)
			{
				//or outside the board area. no snap!
				xPos = _mouseX - this.tileIndnt;
				yPos = _mouseY - this.tileIndnt;
			}else{
				xPos = tileWidth * tile.getCol();
				yPos = tileWidth * tile.getRow();
			}
			
			var rect:Rectangle = new Rectangle(tile.getImageX(), tile.getImageY(), tileWidth, tileWidth);
			var point:Point = new Point(xPos,yPos);
			
			//copy the tile image onto the board imagedata
			//image coords inn rect and dest coords in point
			destBitData.copyPixels(tilesBitData, rect, point, null, null, true);
		}
		
		private function drawGrid():void
		{
			grid = new Shape();
			grid.graphics.lineStyle(5, 0x000000, 1, false, LineScaleMode.VERTICAL,
                               CapsStyle.NONE, JointStyle.MITER, 2);
			//draw rows
			for(var i:int = 0; i < 10; ++i)
			{
				if( (i % 3) == 0)
				{
					grid.graphics.lineStyle(5, 0x000000, 1, false, LineScaleMode.VERTICAL,
                               CapsStyle.NONE, JointStyle.MITER, 5);
				}else
					grid.graphics.lineStyle(2, 0x000000, 1, false, LineScaleMode.VERTICAL,
                               CapsStyle.NONE, JointStyle.MITER, 1);
					
				grid.graphics.moveTo(0, (i * tileWidth) );
				grid.graphics.lineTo(boardBitmap.width, (i * tileWidth) );
			}
			//draw cols
			for(var i:int = 0; i < 10; ++i)
			{
				if( (i % 3) == 0)
				{
					grid.graphics.lineStyle(5, 0x000000, 1, false, LineScaleMode.VERTICAL,
                               CapsStyle.NONE, JointStyle.MITER, 5);
				}else
					grid.graphics.lineStyle(2, 0x000000, 1, false, LineScaleMode.VERTICAL,
                               CapsStyle.NONE, JointStyle.MITER, 2);
					
				grid.graphics.moveTo( (i * tileWidth), 0 );
				grid.graphics.lineTo( (i * tileWidth), boardBitmap.height );
			}
			scrBitmap.addChild(grid);
			scrBitmap.setChildIndex(grid, scrBitmap.numChildren - 2);
			grid.x = boardBitmap.x;
			grid.y = boardBitmap.y;
		}

		public function mouseDown(event:MouseEvent):void{
			//check if mouse click is on player rack
			
			if(holdTile >-1 ){//we have a tile in hand
				 //drop tile either way
				if( colTest( event.stageX, event.stageY, boardBitmap ) )
				{
					//find tile!
					makeSwap = true;
					var distX:int = ( event.stageX - boardBitmap.x );
					var distY:int = ( event.stageY - boardBitmap.y );
					swapRow = int (distY / tileWidth);
					swapCol = int (distX / tileWidth);
					trace("what col, row: " + swapCol + "  " + swapRow);
				}
				else{
					holdTile = -1;//tile has been dropped somewhere
					makeSwap = false;
				}
			}else
			{//we are searching for a new tile
				makeSwap = false;
				//sndManager.playSound();
			}
			
			if( colTest( event.stageX, event.stageY, playerBitmap ) )
				{
					
					var distX:int = ( event.stageX - playerBitmap.x );
					holdTile = (distX / (tileWidth * playerRatio));
					handTile.setNumb(holdTile);
					this.selectImage(handTile);
					trace("what tile: " + holdTile + "  " + handTile.getCol());
				}
		}
		
		
		
		private function mouseUp(event:MouseEvent):Boolean{
			//if player holds tile
			//and if mouseUp is over the board
			//then find which tile this is over
			var distX:int = ( event.stageX - boardBitmap.x );
			if( distX > 0 && distX < playerBitmap.width ){
				var distY:int = ( event.stageY - playerBitmap.y );
				if( distY > 0 && distY < playerBitmap.height )
				{
					holdTile = distX / (tileWidth * playerRatio);
					trace("what tile: " + holdTile);
					return true;
				}
			}
			
			holdTile = -1;
			return false;
		}
		
		public function mouseMove(event:MouseEvent):void{
			_mouseX = event.stageX;
			_mouseY = event.stageY;
		}
		
		private function colTest( pX:int, pY:int, bitmap:Bitmap ):Boolean{
			
		var distX:int = ( pX - bitmap.x );
			if( distX > 0 && distX < bitmap.width ){
				var distY:int = ( pY - bitmap.y );
				if( distY > 0 && distY < bitmap.height )
				{
					return true;
				}else
					return false;
			}else
				return false;
		}
		
		public function getTileInHand():Boolean
		{
			if(holdTile > -1)
				return true;
			else
				return false;
		}
		
		public function placeSquare( startRow:int, startCol:int, endRow:int, endCol:int, color:uint ):Sprite
		{
			var image:Sprite = new Sprite();
			var startX:int = startCol * tileWidth;
			var startY:int = startRow * tileWidth;
			var endX:int = (endCol * tileWidth) + tileWidth;
			var endY:int = (endRow * tileWidth) + tileWidth;
			image.graphics.beginFill(color, 0.5);
			image.graphics.drawRect(startX,startY,(endX - startX),(endY -startY));
			image.graphics.endFill();
			if(color == scrBitmap.BLANK_COLOR)
				this.helpBoard1.addChild(image);
			else
				this.helpBoard2.addChild(image);
			return image;
		}
		
		public function setHelp( val:Boolean ):void			{	this.showHelp = val;	}
		
		public function getHelp():Boolean					{	return this.showHelp;	}

	}
	
}
