
/**
**/
class Config {

	public static var instance(get,null) : Config;
	static function get_instance() : Config {
		if(instance==null)
			instance = new Config();
		return instance;
	}
	
	public var serverUrl(default, null) : String;
	public var sleepTime(default,default):Int;
	public var historyInterval(default,default):Int;
	
	public function new() {
	
		serverUrl = "http://78.47.92.222/pvsdev/"; //Dev version of server.
		sleepTime = 1;
		historyInterval = 15;
	}	

}
