package  {
	
	public class Solver {

		private var gameState:Array = new Array();
		private var gameErrors:Array = new Array();
		private var stateCount:int;
		
		private var startCom:int;
		private var endCom:int;
		
		private var solveStart:Number;
		private var solveStop:Number;
		private var solveTime:Number;
		private var clock:Date = new Date();
		
		private var currentSol:SodTiles;
		
		public function Solver( gameRef:SodTiles ) {
			currentSol = gameRef;
			stateCount = currentSol.COL_WIDTH * 3;
			Init();
		}
		
		private function Init():void
		{
			//start stop conditions for checking each number
			startCom = 1;
			endCom = currentSol.COL_WIDTH + 1;
			for(var i:int = 0; i< stateCount; ++i)
				gameState.push(false);
				
		}
		
		public function findSolution( solveStart:Number ):Boolean
		{
			if(!this.testValidity())
				{
					trace("This puzzle is an invalid sudoku challange!!");
					return false;
				}
			var valid:Boolean = this.solve();
			currentSol.setComp(valid);
			
			if(valid)
				{
					solveStop = clock.getMilliseconds();
					solveTime = solveStop - solveStart;
					trace("Solution found in " + ( solveTime ) + " milliseconds");
					return true;
				}
			else{
				solveTime = solveStop - solveStart;
				trace("Solver gave up after " + ( solveTime ) + " milliseconds");
				return false;
			}
				
		}
		
		private function solve( ):Boolean
		{
			var tot:int = currentSol.COL_WIDTH * currentSol.COL_WIDTH;
			var backTrack:Boolean = false;
			
			for( var i:int = 0; i< tot; ++i)
			{
				if(i < 0)
					return false; //fallen out the back of the loop
				var crntTile:Tile = currentSol.getTile(i);
				if( crntTile.getInitial() )
					{
						if(backTrack)
							i = i-2;//will increment, and step back over the initial tile
						continue;
					}
				else{
					//find a value to try
					var val:int = currentSol.getTile(i).getNextCand();
					
					if(val == -1)
					{
						//ran out of numbers to try, back up
						backTrack = true;
						currentSol.swapTile(crntTile.getCol(), crntTile.getRow(), 0);
						currentSol.getTile(i).resetCand();
					}
					else{
						if( testOnRow(crntTile.getRow(), val) && testOnCol(crntTile.getCol(), val) && testOnSqu(crntTile, val) )
						{
							currentSol.swapTile(crntTile.getCol(), crntTile.getRow(), val);
							backTrack = false;
						}
						else
						{
							if(currentSol.getTile(i).candsRem())
								{
									currentSol.getTile(i).incrCand();
									--i;
									backTrack = false;
									continue;
								}else{
									//time to start backtracking
									backTrack = true;
									currentSol.swapTile(crntTile.getCol(), crntTile.getRow(), 0);
									currentSol.getTile(i).resetCand();
								}
						}
					}
					
					if(backTrack)
						i = i-2;//push back incrment and set next loop to previous
				}
			}
			return true;
		}
		
		public function findErrors( validTiles:SodTiles ):Array
		{
			currentSol = validTiles;
			this.testValidity();
			return gameErrors;
		}
		
		private function testValidity( ):Boolean
		{
			var totTiles:int = 0;
			var totBlanks:int = 0;
			for(var i:int = 0; i< currentSol.length(); ++i)
			{
				++totTiles;
				if(currentSol.readVal(i) == 0)
					++totBlanks;
			}
			if(totTiles != (currentSol.COL_WIDTH * currentSol.COL_WIDTH) )
				return false;
				
			if( (totTiles - totBlanks) < 17)
				return false;
				
			var i:int, index:int = 0;
			for(i = 0; i< currentSol.COL_WIDTH; ++i)
			{
					gameErrors[index++] = this.validRow(i);
			}
			//check each col
			for(i = 0; i< currentSol.COL_WIDTH; ++i)
			{
					gameErrors[index++] = this.validCol(i);
			}
			//check each square
			var squareStart:int = 0;
			for(i = 0; i< currentSol.COL_WIDTH; ++i)
			{
				//gameErrors[index++] = true;
				//test on square requires work
				gameErrors[index++] = this.validSquare(squareStart);
				squareStart += 3;
				if(squareStart % 9 == 0)
					squareStart += ( currentSol.COL_WIDTH * 2 );
				
			}
			
			for(i = 0; i< gameErrors.length; ++i)
				{
					if(!gameErrors[i])
						return false;
				}
			return true;
		}
		
		private function testOnRow( row:int, numb:int ):Boolean
		{
			for( var i:int = 0 ; i < currentSol.COL_WIDTH; ++i)
			{
				if( currentSol.getVal( i, row ).getNumb() == numb)
					return false;
			}
			return true;
		}
		
		private function testOnCol( col:int, numb:int ):Boolean
		{
			for( var i:int = 0; i < currentSol.COL_WIDTH; ++i )
			{
				if( currentSol.getVal( col, i ).getNumb() == numb)
					return false;
			}
			return true;
		}
		
		private function testOnSqu( tile:Tile, numb:int ):Boolean
		{
			//find the box number
			var startCol:int = int ( tile.getCol() / 3 ) * 3;
			var startRow:int = int ( tile.getRow() / 3 ) * 3;
			for(var i:int = startRow; i < startRow+3; ++i){
				for(var j:int = startCol; j < startCol+3; ++j)
				{
					if( currentSol.getVal( j, i ).getNumb() == numb)
					return false;
				}
			}			
			return true;
		}
		
		public function TestSolution( testSol:SodTiles ):Boolean{
			currentSol = testSol;
			//check for win condition
			//check each row
			var i:int;
			var index:int = 0;
			var count:int = 0;
			this.testOnSqu(currentSol.getVal(6,5), 1);
			for(i = 0; i< testSol.COL_WIDTH; ++i)
			{
				gameState[index++] = testRow(i);
				//trace("Do we have a winner? "+ i + ": " + gameState[i]);
			}
			//check each col
			for(i = 0; i< testSol.COL_WIDTH; ++i)
			{
				gameState[index++] = testCol(i);
			}
			//cheack each box
			for(i = 0; i< testSol.COL_WIDTH; ++i)
			{
				gameState[index++] = testSquare(i);
			}
			for(i = 0; i< stateCount; ++i)
			{
				if(gameState[i])
					++count;
			}
			if(count == stateCount)
				currentSol.setComp(true);
			trace("has this puzzle been completed? " + currentSol.getComp());
			return currentSol.getComp();
		}
		
		private function validRow( rowNumb:int ):Boolean
		{
			var instCount = 0;
			var startRow:int = rowNumb * currentSol.COL_WIDTH;
			var endRow:int = startRow + currentSol.COL_WIDTH;
			for( var i:int = startCom ; i < endCom ; ++i )
			{
				instCount = 0;
				for( var j:int = startRow; j < endRow; ++j )
				{
					if( currentSol.readVal( j ) == i )
						{
							++instCount;
						}
					if(instCount > 1)
						return false;
				}
			}
			return true;
		}
		
		private function validCol( colNumb:int ):Boolean
		{
			var instCount = 0;
			var startCol:int = colNumb;
			var endCol:int = ((currentSol.COL_WIDTH * currentSol.COL_WIDTH)) -
								( currentSol.COL_WIDTH - startCol );
			for(var i:int = startCom; i < endCom; ++i)
			{
				instCount = 0;
				for(var j:int = startCol; j<= endCol; j+=currentSol.COL_WIDTH)
				{
					if( currentSol.readVal( j ) == i )
					{
						++instCount;
					}
					if(instCount > 1)
						return false;
				}
			}
			return true;
		}
		
		private function validSquare( squareStart:int ):Boolean
		{
			var instCount:int = 0;
			var crtSquare:int = squareStart;
			var endSquare:int = squareStart + (currentSol.COL_WIDTH * 2 + 3);
			for(var i:int = startCom; i < endCom; ++i)
			{
				instCount = 0;
				crtSquare = squareStart;
				while( crtSquare < endSquare ){
					if( currentSol.readVal( crtSquare ) == i )
						{
							
							++instCount;
						}
					if( ++crtSquare % 3 == 0 )
						crtSquare += 6;
					if(instCount > 1)
						return false;
				}
			}
			return true;
		}
		
		private function testRow( rowNumb:int ):Boolean
		{
			var instCount = 0;
			var startRow:int = rowNumb * currentSol.COL_WIDTH;
			var endRow:int = startRow + currentSol.COL_WIDTH;
			for( var i:int = startCom ; i < endCom ; ++i )
			{
				for( var j:int = startRow; j < endRow; ++j )
				{
					if( currentSol.readVal( j ) == i )
						{
							++instCount;
							break;
						}
				}
			}
			//so this complete?
			if(instCount == currentSol.COL_WIDTH)
			{
				trace("This row is complete!");
				return true;
			}
			else
				return false;
		}
		
		private function testCol( colNumb:int ):Boolean
		{
			var instCount = 0;
			var startCol:int = colNumb;
			var endCol:int = ((currentSol.COL_WIDTH * currentSol.COL_WIDTH)) -
								( currentSol.COL_WIDTH - startCol );
			for(var i:int = startCom; i < endCom; ++i)
			{
				for(var j:int = startCol; j<= endCol; j+=currentSol.COL_WIDTH)
				{
					if( currentSol.readVal( j ) == i )
					{
						++instCount;
						break;
					}
				}
			}
			//so this complete?
			if(instCount == currentSol.COL_WIDTH)
			{
				trace("This col is complete!");
				return true;
			}
			else
				return false;
		}
		
		private function testSquare( squareStart:int ):Boolean
		{
			var instCount:int = testStrip( squareStart, squareStart, 0 );
			//so this complete?
			if(instCount == currentSol.COL_WIDTH)
			{
				return true;
			}
			else
				return false;
		}
		
		private function testStrip( squStart:int, rowStart:int, instCount:int ):int
		{
			//recursive test for a 3 by 3 square for completeness
			if(rowStart > (squStart + ( currentSol.COL_WIDTH * 2 )) )
				return instCount;		//then we have exceded the 3 by 3 search box,
										//instCount is complete and ready to check
			
			for(var i:int = rowStart, endI:int = (rowStart+3); i<endI; ++i)
			{
				for(var j:int = startCom; j < endCom; ++j)
				{
					if( currentSol.readVal( i ) == j )
						{
							++instCount;
							break;
						}
				}
			}
			return this.testStrip( squStart, (rowStart + currentSol.COL_WIDTH), instCount );
		}
		
		public function setSolution(crt:SodTiles):void
		{
			currentSol = crt;
		}
		
		public function getSolution():SodTiles
		{
			return currentSol;
		}
		
		public function getCrntState():Array{
			return gameState;
		}
	}
	
}
