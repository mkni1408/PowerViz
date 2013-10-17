
import Instruction;

/**
Supply instruction. Instructs the server to change the supply source.
Possible sources are "coal", "wind", "water", "sun" and "nuclear".
**/
class SupplyInstruction implements Instruction {

	private var mComment:String;
	private var mSource:String;
	
	public function new() {
		mComment="";
		mSource="";
	}

	public function execute(?time:Date) {
		var timeString:String = (time!=null ? time.toString() : "??:??:??" );
		Sys.println("Setting supply to " + mSource + " (" + mComment + ") " + " at " + timeString);
		
		DataInterface.setPowerSource(mSource, (time==null ? Date.now() : time));
	}

	public static var AVAILABLE_SOURCES:Array<String> = ["coal", "wind", "water", "sun", "nuclear"];

	public static function parse(houseId:Int, xml:Xml) : SupplyInstruction {
	
		var i:SupplyInstruction = new SupplyInstruction();
	
		var source:String = xml.get("source");
		if(source == null || isSourceValid(source)==false) {
			Sys.println("Error in parsing supply instruction: '" + source + "' is not a valid source");
			return null;
		}
		i.mSource = source;
		
		var comment:String = xml.get("comment");
		if(comment != null)
			i.mComment = comment;
			
		return i;
		
	}
	
	public static function isSourceValid(source:String) : Bool {
	
		for(s in AVAILABLE_SOURCES) {
			if(s == source)
				return true;
		}
		return false;
		
	}

}
