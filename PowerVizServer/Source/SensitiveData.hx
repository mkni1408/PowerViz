
class SensitiveData {

	public static var instance(get,null):SensitiveData;
	static function get_instance() {
		if(instance==null)
			instance = new SensitiveData();
		return instance;
	}
	
	
	public var dbUser(default,null):String = "";
	public var dbPass(default,null):String = "";

	public var dataBase(default,null):String = "";


	
	public function new() {
		readLinf();
	}
	
	public function readLinf() {
	
		try {
	
			var rb:String = haxe.Resource.getString("linf.json");
		
			var json = haxe.Json.parse(rb);
		
			dbUser = json.dbUser!=null ? json.dbUser : "";
			dbPass = json.dbPass!=null ? json.dbPass : "";
		
			#if production
				dataBase = json.dbProd!=null ? json.dbProd : "";
			#else
				dataBase = json.dbDev!=null ? json.dbDev : "";
			#end
		
		}
		catch(e:Dynamic) {
			Sys.println("Exception in reading server info: " + Std.string(e));
		}
	
	}

	
	

}
