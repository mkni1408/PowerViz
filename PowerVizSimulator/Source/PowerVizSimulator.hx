
import BoxModel;
import DateUtil;
import XmlParser;
import Player;
import Instruction;

/**
**/
class PowerVizSimulator {

	static var mFileName:String;
	static var mSpeed:Float;
	static var mStartTime:Date;
	
	static var mBoxTimer : SimTimer;

	public static function main() {
		if(handleArguments()==false)
			return;
		runSimulation();
	}
	
	public static function handleArguments() : Bool{
	
		var argLengths = [2, 3];
		if(Lambda.has(argLengths, Sys.args().length)==false) {
			Sys.println("Takes 2 or 3 arguments: filename speed [starttime]");
			return false;
		}
		
		mFileName = Sys.args()[0];
		mSpeed = Std.parseFloat(Sys.args()[1]);
		
		mStartTime = Sys.args().length==3 ? Date.fromString(Sys.args()[2]) : Date.now();
		
		Sys.println("Parsing simulation file...");
		return XmlParser.parse(mFileName);
	
	}
	
	public static function runSimulation() {
	
		mBoxTimer = new SimTimer((Config.instance.sleepTime * mSpeed ), 0, 0, onBoxTimer); //Timer running the BoxModel. 
		BoxModel.instance.sendOutletLayout(ServerInterface.instance.sendLayoutData); //Start by sending the layout data.
		
		ServerInterface.instance.deletePreviousData(BoxModel.instance.houseId, mStartTime);
	
		Sys.println("Running simulation...");
	
		Player.instance.run(mStartTime, mSpeed);
		SimTimer.startDate = mStartTime;
		while(true) {
			SimTimer.update(mSpeed);
			Sys.sleep(0.01);
		}
	
	}
	
	static private function onBoxTimer(count:Int, time:Date) : Void {
		BoxModel.instance.update(time, sendLoadData, sendHistData, Config.instance.historyInterval);
	}
	
	static private function sendLoadData(outletId:Int, watts:Int) {
		ServerInterface.instance.sendLoadData(BoxModel.instance.houseId, outletId, watts);
	}
	
	static private function sendHistData(outletId:Int, time:Date, watts:Int) {
		ServerInterface.instance.sendHistData(BoxModel.instance.houseId, outletId, time, watts);
	}
	

}
