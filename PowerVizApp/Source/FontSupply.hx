package;

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
	private var mButtonFont : TextFormat;
	private var mSeismographFont: TextFormat;
	private var mWattFont: TextFormat;

	private var mCoordYAxisSMALLFont: TextFormat;
	private var mCoordYAxisMEDIUMFont: TextFormat;
	private var mCoordYAxisLARGEFont: TextFormat;
	
	
	private function new() {
	
		mTitleFont = new TextFormat(Assets.getFont("assets/fonts/Roboto-Thin.ttf").fontName, 30, 0x000000);
		
		mCoordAxisFont = new TextFormat(Assets.getFont("assets/fonts/Oxygen-Regular.ttf").fontName, 20, 0x000000);
		
		mButtonFont = new TextFormat(Assets.getFont("assets/fonts/Oxygen-Regular.ttf").fontName, 10, 0x000000);

		mSeismographFont = new TextFormat(Assets.getFont("assets/fonts/Oxygen-Regular.ttf").fontName, 20, 0x000000);

		mWattFont = new TextFormat(Assets.getFont("assets/fonts/Oxygen-Regular.ttf").fontName, 30, 0x000000);

		mCoordYAxisSMALLFont = new TextFormat(Assets.getFont("assets/fonts/Oxygen-Regular.ttf").fontName, 15, 0x000000);

		mCoordYAxisMEDIUMFont = new TextFormat(Assets.getFont("assets/fonts/Oxygen-Regular.ttf").fontName, 18, 0x000000);

		mCoordYAxisLARGEFont = new TextFormat(Assets.getFont("assets/fonts/Oxygen-Regular.ttf").fontName, 22, 0x000000);

	}
	
	public function getTitleFormat():TextFormat {
		return mTitleFont;
	}

	public function getButtonFormat():TextFormat {
		return mButtonFont;
	}
	
	public function getCoordAxisLabelFormat():TextFormat {
		return mCoordAxisFont;
	}

	public function getSeismographabelFormat():TextFormat {
		return mSeismographFont;
	}

	public function getWattLabelFormat():TextFormat {
		return mWattFont;
	}
	public function getCoordAxisLabelSMALLFormat():TextFormat {
		return mCoordYAxisSMALLFont;
	}
	public function getCoordAxisLabelMEDIUMFormat():TextFormat {
		return mCoordYAxisMEDIUMFont;
	}
	public function getCoordAxisLabelLARGEFormat():TextFormat {
		return mCoordYAxisLARGEFont;
	}
}
