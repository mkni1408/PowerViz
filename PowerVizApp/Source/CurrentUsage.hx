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
import flash.text.TextField;





class CurrentUsage extends Sprite{

	private var speedometer:Speedometer;
	private var powerOrigin:PowerOrigin;
	private var seismoGraph:SeismoGraph;
	private var mTitle : TextField;

	function new(){
	
		super();

		//this.graphics.lineStyle(6,0x000000);

		//draw frame
		this.graphics.drawRect(0, 0, Lib.stage.stageWidth, Lib.stage.stageHeight);

		speedometer = new Speedometer();
		powerOrigin = new PowerOrigin();
		seismoGraph = new SeismoGraph();
		mTitle = new TextField();
        mTitle.mouseEnabled=false;
        mTitle.text = "Forbrug nu ";
        mTitle.setTextFormat(FontSupply.instance.getTitleFormat());
        mTitle.selectable = false;

        this.graphics.lineStyle(2,0x000000);
		this.graphics.moveTo(0,(Lib.stage.stageHeight/2)+15);
		this.graphics.lineTo((Lib.stage.stageWidth),(Lib.stage.stageHeight/2)+15);
		this.graphics.beginFill(0x000000,1);

		addChild(mTitle);
		addChild(powerOrigin);
		addChild(seismoGraph);
		addChild(speedometer);//SHOULD BE LAST FOR THE SETTINGSVIEW TO WORK PROPERLY
		mTitle.width = 200;

		mTitle.y = 0;
		mTitle.x = (Lib.stage.stageWidth/2)-(mTitle.width/2);

		powerOrigin.y = 40;
		speedometer.y = 40;

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
