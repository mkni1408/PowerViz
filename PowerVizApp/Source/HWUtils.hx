

class HWUtils {

	public static var screenWidth(get, never) : Int;
	static function get_screenWidth() : Int {
		#if mobile
			return Std.int(flash.system.Capabilities.screenResolutionX);
		#else
			return 1066;
		#end
	}
	
	public static var screenHeight(get, never) : Int;
	static function get_screenHeight() : Int {
		#if mobile
			return Std.int(flash.system.Capabilities.screenResolutionY);
		#else
			return 600;
		#end
	}

}
