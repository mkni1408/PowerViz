
import BoxModel;
import OutletModel;
import Player;
import Instruction;
import ServerInterface;

/**
XML parser - parses the XML simulation file and informs the classes that need data from the file.
**/
class XmlParser {

	private static var errFlag:Bool;

	public static function parse(filename:String) {
		
		errFlag = false;
		var sim = Xml.parse(readFile(filename)).firstElement();
		
		if(sim.nodeType == Xml.Element && sim.nodeName == "simulation") {
			BoxModel.instance.houseId = sim.get("houseId")==null ? 0 : Std.parseInt(sim.get("houseId"));
			ServerInterface.instance.configure(BoxModel.instance.houseId);
		}
		
		for(elm in sim.elements()) {
			switch(elm.nodeName) {
				case "layout":
					parseLayout(elm);
				case "time":	
					parseTimeblock(elm);
			}
		}
		
		return !errFlag;
		
	}
	
	
	private static function parseLayout(xml:Xml) {
		for(x in xml.elements()) {
			if(x.nodeName=="room")
				parseRoom(x);
		}
	}
	
	private static function parseRoom(xml:Xml) {
	
		var name_ = xml.get("name");
		var floor_ = xml.get("floor");
	
		for(x in xml.elements()) { 
			if(x.nodeName=="outlet")
				parseOutlet(x, name_!=null ? name_ : "unknown", floor_!=null ? floor_ : "unknown");
		}
	}
	
	private static function parseOutlet(xml:Xml, roomName:String, roomFloor:String) {
	
		var id_ = xml.get("id");
		var name_ = xml.get("name");
		
		if(id_==null)
			return parseError("No outlet id specified. id MUST be set.");
			
		var outlet = new OutletModel(Std.parseInt(id_), name_!=null ? name_ : "unknown", roomName, roomFloor);
		BoxModel.instance.addOutlet(outlet);
	
	}
	
	private static function parseTimeblock(xml:Xml) {
	
		var at_ = xml.get("at");
		var every_ = xml.get("every");
		var repeat_ = xml.get("repeat");
		var offset_ = xml.get("offset");
		var until_ = xml.get("until");
		var comment_ = xml.get("comment");
		
		var timeblock:Timeblock;
		
		if(at_!=null) { //Run timeblock once.
			timeblock = new Timeblock(Date.fromString(at_).getTime()/1000, 0, 1, -1, comment_);
		}
		else if(every_!=null) { //Loop timeblock.
			timeblock = new Timeblock(Date.fromString(every_).getTime()/1000,
										offset_!=null ? Date.fromString(offset_).getTime()/1000 : 0,
										repeat_!=null ? Std.parseInt(repeat_) : 0,
										until_!=null ? Date.fromString(until_).getTime()/1000 : -1, comment_);
										
										
		}
		else
			return parseError("Timeblock time not specified. Use 'at' or 'every' to indicate timing.");
		
		for(x in xml.elements()) {
			switch(x.nodeName) {
				case "load":
					parseLoadInstruction(x, timeblock);

			}
		}
		
		Player.instance.addTimeblock(timeblock);
		
	}
	
	private static function parseLoadInstruction(xml:Xml, block:Timeblock) {
	
		if(xml.nodeName!="load")
			return;
			
		var id_:String = xml.get("outlet");
		var add_:String = xml.get("add");
		var sub_:String = xml.get("sub");
		var set_:String = xml.get("set");
		var comm_:String = xml.get("comment");
		
		if(id_==null) //No id, so not possible to parse further.
			return parseError("No outlet specified in load instruction");
			
		if(add_ == null && set_ == null && sub_ == null)
			return parseError("set, add or sub not specified. At least one of them is needed.");
			
		var add = Std.parseInt(add_!=null ? add_ : "0");
		var sub = Std.parseInt(sub_!=null ? sub_ : "0");
		
			
		var inst = new LoadInstruction(	Std.parseInt(id_), 
										sub!=0 ? -sub : add,
										Std.parseInt(set_!=null ? set_ : "-1"),
										comm_!=null ? comm_ : "");
				
		block.addInstruction(inst);
	
	}
	
	
	private static function readFile(filename:String) : String {
		var data = sys.io.File.getContent(filename);
		return data;
	}
	
	private static function parseError(s:String) : Void {
		Sys.stderr().writeString("Error parsing XML file: " + s);
		errFlag = true;
	}

}


