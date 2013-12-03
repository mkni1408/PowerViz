package;


/**
Class used for reading configuration from file. 
Does ONE thing: Reads the houseId froma file!
COULD be turned into a more complex configuration solution, getting configuration data from server etc.
**/
class Config {
	public static var instance(get, null):Config;
	static function get_instance() : Config {
		if(instance==null)
			instance = new Config();
		return instance;
	}
	
	public var houseId(default, null):Int;
	
	public function new() {
		readFromFile();
		houseId = 2; //TODO! Make this real!!!!
	}
	
	//Hmm... never made this work.
	private function readFromFile() {
	}
}
