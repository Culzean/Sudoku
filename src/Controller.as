package  {
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.EventDispatcher;
	import flash.display.SimpleButton;
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.getTimer;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class Controller {

		private var spectator:OldManBob;

		private var mainDis:Display;
		private var gameBoard:SodBoard;
		private var gameTiles:SodTiles;
		private var currentSolution:SodTiles;
		private var solver:Solver;
		private var loader:FileIO;
		private var sounds:SoundManager;
		private var _stage:Object;
		
		private var inPlay:Boolean = false;
		private var comp:Boolean = false;
		private var titleFormat:TextFormat = new TextFormat();
		private var gameTitle:TextField = new TextField();
		
		private var levelLoad:Timer = new Timer(1000);
		private var clock:Date = new Date();
		
		private var buttons:Array = new Array();
		private const NO_BUTTONS = 5;
		
		private var solutions:Array = new Array();
		private var puzzles:Array = new Array();
		private var curFile:Object;
		
		private var levelsLoaded:int = 0;
		private var levelIndex:int = 0;
		
		public function Controller(stage:Object, disRef:Display) {
			
			mainDis = disRef;
			_stage = stage;
			loader = new FileIO();
			gameTiles  = new SodTiles();
			currentSolution = new SodTiles();
			gameBoard = new SodBoard( mainDis.getSodWidth(), mainDis.getSodWidth(), mainDis, gameTiles );
			trace("what width: " + mainDis.getSodWidth());
			
			loader.loadFile("/sites/default/files/input_0.json");
			sounds = SoundManager.getInstance();
			sounds.loadSounds();
			//sounds.playSound("tile2.wav");
			
			//wait for image to load
			levelLoad.addEventListener(TimerEvent.TIMER, CreateGame);
			//addEvent listeners
			stage.addEventListener(Event.ENTER_FRAME, Update);
			stage.addEventListener(Event.REMOVED_FROM_STAGE, TidyUp);
			_stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			levelLoad.start();
		}
		
		public function CreateGame(event:TimerEvent):void
		{
			levelLoad.stop();
			levelLoad.removeEventListener(TimerEvent.TIMER, CreateGame);
			trace("start to build level");
			curFile = loader.getArrayObject(levelIndex);
			levelsLoaded = curFile.header;
			
			gameTiles.assignArray(curFile.tiles);
			currentSolution.assignArray( curFile.tiles );
			puzzles.push(gameTiles);
			solutions.push(currentSolution);
			
			solver = new Solver(currentSolution);
			gameBoard.createBoard( gameTiles);
			mainDis.placeBoard(gameBoard);
			createButtons();
			currentSolution.assignArray(curFile.tiles);

			solver.findSolution( clock.getMilliseconds() );
			gameTitle.text = curFile.title;
			
			inPlay = true;
		}
		
		private function showSol():void
		{
			trace("please tell " + gameBoard.getBoard().getComp() );
			inPlay = false;
			if( !gameBoard.getBoard().getComp() )//breaking rules for only near friends!
			{
				currentSolution = solutions[levelIndex];
				gameBoard.changeBoard(currentSolution);
				gameBoard.swapBoard(currentSolution);
				//loader.saveFile(currentSolution.getArray(), curFile.title);
			}
			else
			{
				gameBoard.changeBoard(gameTiles);
				gameBoard.swapBoard(gameTiles);
			}
			inPlay = true;
		}
		
		private function nextLevel( newIndex:int ):void
		{
			inPlay = false;
			comp = false;
			mainDis.setColor(comp);
			if(newIndex >= levelsLoaded)
				newIndex = 0;
			else if(newIndex < 0)
				{
					if(puzzles.length == levelsLoaded)
						newIndex = levelsLoaded -1;
					else
						newIndex = 0;
				}
				//Force a traversal through all the levels before alloing backtrackign
				//through puzzles.
				//puzzles array does not sort solutions
			levelIndex = newIndex;
			trace("how many levelS?!!! " + levelIndex);
			if(loader.getArrayObject(levelIndex) ==null)
				{
					//wait for load to complete
					levelLoad.addEventListener(TimerEvent.TIMER, loadFile);
					levelLoad.start();
				}
			else{
				updateFile();
				inPlay = true;
			}
		}
		
		private function updateFile():void
		{
			trace("Tell " + levelIndex);
			curFile = loader.getArrayObject(levelIndex);
			
			if(puzzles.length < levelsLoaded)
				{
					var temp:SodTiles = new SodTiles();
					var sol:SodTiles = new SodTiles();
					temp.assignArray(curFile.tiles);
					sol.assignArray(curFile.tiles);
					puzzles.push(temp);
					solver.setSolution(sol);
					solver.findSolution(clock.getMilliseconds())
					solutions.push(solver.getSolution());
					gameTiles = puzzles[levelIndex];
					currentSolution = solutions[levelIndex];
				}
				else
				{
					currentSolution = solutions[levelIndex];
					gameTiles = puzzles[levelIndex];
				}
			
			trace("place new tiles " + gameTiles.readVal(80));
			
			
			gameBoard.swapBoard(gameTiles);
			gameBoard.changeBoard(gameTiles);
			gameTitle.text = curFile.title;			
		}
		
		private function loadFile(event:TimerEvent):void
		{
			if(loader.getArrayObject(levelIndex) ==null)
				levelLoad.reset();
			else
				{
					levelLoad.stop();
					trace("will change the game board now!");
					levelLoad.removeEventListener(TimerEvent.TIMER, loadFile);
					updateFile();
					inPlay = true;
				}
		}
		
		private function Update(event:Event):void{
			if(inPlay)
			{
				spectator.update();
				spectator.setFollow(gameBoard.getTileInHand());
					
				for(var i:int = 0; i< NO_BUTTONS;  ++i)
				{
					if(buttons[i].getAction())
					{
						buttons[i].setAction(false);
						buttonAction(i);
					}
				}
				mainDis.update();
				if(gameBoard.update(  ) )
					{
						comp = solver.TestSolution( gameTiles );
						trace("A test! " + comp);
						mainDis.setColor(comp);
						spectator.win.visible = comp;
						placeHelp();
					}

			}
		}
		
		private function buttonAction(index:int):void
		{
			switch(buttons[index].getText()){
				
				case"Next":
					nextLevel( levelIndex + 1 );
				break;
	
				case"Prev":
					nextLevel( levelIndex - 1 );
				break;
				
				case"Undo":
					gameBoard.Undo();
					placeHelp();
				break;
				
				case"Solve":
					showSol();
				break;
				
				case"Help":
					gameBoard.setHelp(!gameBoard.getHelp());
					if(gameBoard.getHelp())
						placeHelp();
					else
						gameBoard.clearHelp();
				break;
				default:
						trace("button action cannot be resolved. Button: " + index);
				break;
			}
		}
		
		private function createButtons():void
		{			
			titleFormat.size = 22;
			titleFormat.bold = true;
			spectator = new OldManBob();
			
			for(var i:int = 0; i< NO_BUTTONS;  ++i)
			{
				var temp:SodButton = new SodButton(30,30);
				buttons.push(temp);
				mainDis.addChild(buttons[i]);
			}
			buttons[0].setText("Solve");
			buttons[0].setPos(100,340);
			buttons[1].setText("Prev");
			buttons[1].setPos(60,510);
			buttons[2].setText("Next");
			buttons[2].setPos(640,510);
			buttons[3].setText("Help");
			buttons[3].setPos(40,420);
			buttons[4].setText("Undo");
			buttons[4].setPos(180,420);
			
			
			gameTitle.defaultTextFormat = titleFormat;
			gameTitle.text = "Title"
			gameTitle.width = 200;
			
			mainDis.addChild(gameTitle);
			mainDis.addChild(spectator);
			spectator.x = 160;
			spectator.y = 180;			
			mainDis.setChildIndex(gameTitle, 2);
		}
		
		private function placeHelp():void
		{
			gameBoard.clearHelp();

			if(gameBoard.getHelp())
			{
				var game:Array = solver.getCrntState();
				var errors:Array = solver.findErrors( gameTiles );
								
				for(var i:int = 0; i< game.length; ++i)
				{
					if(i >= gameTiles.COL_WIDTH)
					{
						
						if(i >= gameTiles.COL_WIDTH * 2)
						{//this is a square
						var startX:int = ( i -  gameTiles.COL_WIDTH * 2) / 3;
						startX *= 3;
						var startY:int = ( i -  gameTiles.COL_WIDTH * 2) % 3;
						startY *= 3
							if(!errors[i])
							gameBoard.placeSquare( startX, startY,
												  startX + 2, startY + 2, mainDis.WRONG_COLOR);
						}
						else
						{//this is a col
						if(game[i])
							gameBoard.placeSquare( 0, (i-gameTiles.COL_WIDTH), gameTiles.COL_WIDTH -1, (i-gameTiles.COL_WIDTH), mainDis.CORT_COLOR);
						if(!errors[i])
							gameBoard.placeSquare( 0, (i-gameTiles.COL_WIDTH), gameTiles.COL_WIDTH -1, (i-gameTiles.COL_WIDTH), mainDis.WRONG_COLOR);
						}
					}
					else
					{//this is a row
						if(game[i])
							gameBoard.placeSquare( i, 0, i, gameTiles.COL_WIDTH -1, mainDis.CORT_COLOR);
						if(!errors[i])
							gameBoard.placeSquare( i, 0, i, gameTiles.COL_WIDTH -1, mainDis.WRONG_COLOR);
					}
				}//end for
				
				for(var i:int = 0; i< gameTiles.length() ; ++i)
				{
					if( gameTiles.getTile(i).getInitial() )
					{
						var tempRow:int = i / gameTiles.COL_WIDTH;
						var tempCol:int = i % gameTiles.COL_WIDTH;
						gameBoard.placeSquare( tempRow, tempCol , tempRow , tempCol , mainDis.BLANK_COLOR);
					}
				}
			}
		}
		
		private function onMouseDown(event:MouseEvent):void{
			//trace("on click : " + event.stageX + "  " + event.stageY);
			gameBoard.mouseDown(event);
		}
		
		private function onMouseUp(event:MouseEvent):void{
			for(var i:int = 0; i< NO_BUTTONS;  ++i)
				buttons[i].resetState(event);
		}
		
		private function onMouseMove(event:MouseEvent):void{
			if(inPlay)
			{
				gameBoard.mouseMove(event);
				spectator.mouseMove(event);
			}
		}
		
		private function TidyUp(event:Event):void{
			_stage.removeEventListener(Event.ENTER_FRAME, Update);
			_stage.removeEventListener(Event.REMOVED_FROM_STAGE, TidyUp);
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			for(var i:int = 0; i< NO_BUTTONS;  ++i)
				mainDis.removeChild( buttons[i] );
		}

	}
	
}
