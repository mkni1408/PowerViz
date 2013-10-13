
import flash.text.TextFormat;
import openfl.Assets;

/*
The Font Supply.
This is where you get fonts.

Usage:
FontSupply.instance.getTitleFormat();
or similar function.

*/


class FontSupply {

	private static var __instance:FontSupply = null;
	public static var instance(get,never) : FontSupply;
	static function get_instance() : FontSupply {
		if(__instance==null)
			__instance = new FontSupply();
		return __instance;
	}
	
	
	private var mTitleFont : TextFormat;
	private var mCoordAxisFont : TextFormat;
	
	
	public function new() {
	
		mTitleFont = new TextFormat(Assets.getFont("assets/fonts/Oxygen-Regular.ttf").fontName, 30, 0x000000);
		mCoordAxisFont = new TextFormat(Assets.getFont("assets/fonts/Oxygen-Regular.ttf").fontName, 30, 0x000000);
	}
	
	public function getTitleFormat():TextFormat {
		return mTitleFont;
	}
	
	public function getCoordAxisLabelFormat():TextFormat {
		return mCoordAxisFont;
	}

}
