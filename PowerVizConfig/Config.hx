
import ColorUtils;

/**
The configuration utility tool thing.
This tool makes i simpler to:
	* Configure houses and rooms.
	* View layout data.
	* Set outlet names and in particular colors, using an automatic color grading algorithm.
**/

class Config {
	public static function main() {
		new Config().run();	
	}
	
	private var mHouseId:Int;
	
	public function new() {
	}
	
	function run() {
		if(parseArgs()==false)
			printInstructions();
	}
	
	function printInstructions() {
	
		var instructions = [ 
			"PowerViz Configuration tool",
			"Usage:",
			"./Config <houseId> <command> <args>",
			"where <args> can be a list of 0 to n arguments",
			"--------------------------------------------",
			"Available commands and their arguments are:",
			"listOutlets       [no arguments]                     Displays a list of all outlets in the house.",
			"listRooms         [no arguments]                     Displays a list of all rooms in the house.",
			"setRoomColor      <roomId> <hexcolor> [autotone]     Sets the color of a room. If autotone is positive, all outlets will be colored to fit the room.",
			"deleteFutureData  <from>                             Deletes data from the specified date and onwards."
			
		];
	
		for(s in instructions)
			Sys.println(s);
	}
	
	function parseArgs() : Bool {
	
		if(Sys.args().length<2)
			return false;
	
		mHouseId = Std.parseInt(Sys.args()[0]);
		
		var cmd = Sys.args()[1];
		
		switch(cmd) {
			case "listOutlets":
				cmdListOutlets();
			case "listRooms":
				cmdListRooms();
			case "setRoomColor":
				cmdSetRoomColor(Sys.args()[2], Sys.args()[3], Sys.args()[4]);
			case "deleteFutureData":
				cmdDeleteFutureData(Sys.args()[2]);
			default:
				Sys.println("Unrecognized command: " + cmd);
				return false;
		}
		
		return true;
	}
	
	function cmdListOutlets() {
		var hd = ServerInterface.instance.getHouseDescriptor(mHouseId);
		for(outlet in hd.getAllOutlets())
			Sys.println(outlet.toString());
	}
	
	function cmdListRooms() {
		var hd = ServerInterface.instance.getHouseDescriptor(mHouseId);
		for(room in hd.getRoomArray())
			Sys.println(room.toShortString());
	}
	
	function cmdSetRoomColor(roomId:String, color:String, ?autotone:String) {
	
		//If no autotone, just set the room color.
		//If autotone is on, get all outlet ids in the room, then calculate a color for each and set the outlet color.
		
		
		//Set the room color:
		ServerInterface.instance.setRoomColor(mHouseId, Std.parseInt(roomId), color);
		
		//Prepare for the toning stuff:
		var rc = RGB.fromHexString(color); //Color for the entire room.
		var tone = rc.toHSV();
		tone.S = 1;
		tone.V = 1;
		if(autotone!=null && (autotone=="1" || autotone.toLowerCase()=="true" || autotone.toLowerCase()=="yes")) {
			var hd = ServerInterface.instance.getHouseDescriptor(mHouseId);
			for(outlet in hd.getRoom(Std.parseInt(roomId)).getOutletsArray()) {
				ServerInterface.instance.setOutletColor(mHouseId, outlet.outletId, tone.toRGB().toHexString());
				tone.S -= 0.1;
			}
		}
	}
	
	function cmdDeleteFutureData(from:String) {
		var fromDate = Date.fromString(from);
		if(fromDate==null) {
			Sys.println("Error parsing date string: " + from);
			return;
		}
		
		ServerInterface.instance.removeFutureHistoryData(mHouseId, fromDate);
	}
	
	
}



