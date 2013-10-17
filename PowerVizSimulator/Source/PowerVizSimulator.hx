
import neko.vm.Thread;
import neko.vm.Mutex;

import TimeBlock;
import LoadInstruction;
import DataInterface;

/**
PowerVizPlayback main application file.
**/
class PowerVizSimulator {

	private static var pauseSim:Bool;
	private static var inputMutex = new Mutex();
	
	public static function main() {
		var fileName:String = "";
		var timeMult:Float = 1.0;
		var startTime:Date = Date.now();
		
		if(Sys.args().length!=2 && Sys.args().length!=3) {
			Sys.println("This program takes 2 or 3 arguments: Filename timefactor <starttime>");
			return;
		}
		Sys.println("Initializing simulator...");
		DataInterface.connect();
		
		fileName = Sys.args()[0];
		timeMult = Std.parseFloat(Sys.args()[1]);
		if(Sys.args().length == 3)
			startTime = Date.fromString(Sys.args()[2]);
	
		if(!parseFile(fileName)) {
			Sys.println("Error parsing file");
			return;
		}
		Sys.println("Done parsing script");
		
		Sys.println("Running simulation - starting at " + startTime.toString());
		runSimulation(timeMult, startTime);
		Sys.println("Done running simulation");
	}

	
	private static function parseFile(file:String) : Bool {
	
		var data = sys.io.File.getContent(file);
		if(data.length==0) {
			Sys.println("Could not read " + file);
			return false;
		}
	
		var sim = Xml.parse(data).firstElement();
		var house:Int = 0;
		if(sim.nodeType == Xml.Element && sim.nodeName=="simulation") {
			house = Std.parseInt(sim.get("house"));
		}
		
		for(e in sim) {
			if(e.nodeType == Xml.Element && e.nodeName=="time") {
				if(TimeBlock.parse(house, e)==false)
					return false;
			}
		}
	
		return true;
	}
	

	
	private static function runSimulation(multiply:Float=1, startTime:Date) {
	
		var it = Thread.create(inputThread);
		pauseSim = false;
		
		TimeBlock.startTimer();
		while(TimeBlock.isDone()==false && pauseSim==false) {
			TimeBlock.updateTimer(multiply, startTime);
			Sys.sleep(0.01);
		}
		
	}
	
	private static function inputThread() {
	
		//inputMutex.acquire();
		
		var input:String="";
		
		while(true) {
			trace("---");
			//Sys.sleep(5);
			input = Std.string(Sys.getChar(false));
			trace(input);
		}
		
	}
	
	
}


