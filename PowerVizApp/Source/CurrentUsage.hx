package;

/*

CurrentUsage class , that inits the currentusage screen
*/

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.display.DisplayObject;
import Speedometer;
import PowerOrigin;
import SeismoGraph;
import flash.Lib;





class CurrentUsage extends Sprite{

	private var speedometer:Speedometer;
	private var powerOrigin:PowerOrigin;
	private var seismoGraph:SeismoGraph;

	function new(){
	
		super();

		this.graphics.lineStyle(6,0x000000);

		//draw frame
		this.graphics.drawRect(0, 0, Lib.stage.stageWidth, Lib.stage.stageHeight);

		speedometer = new Speedometer();
		powerOrigin = new PowerOrigin();
		seismoGraph = new SeismoGraph();


		addChild(speedometer);
		addChild(powerOrigin);
		addChild(seismoGraph);

		graphics.beginFill(0xFFFFFF,0.0);
		graphics.drawRect(0,0,Lib.stage.stageWidth,Lib.stage.stageHeight);
		graphics.endFill();
		this.mouseEnabled = false;
		this.powerOrigin.mouseEnabled = false;
		this.powerOrigin.mouseChildren = false;
		this.seismoGraph.mouseChildren = false;
		this.seismoGraph.mouseEnabled = false;
		//this.mouseChildren = false;


	}

			





}
