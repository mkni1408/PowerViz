

class ColorUtils {

	//Interpolates a color from min to max, controlled by value.
	//Value goes from 0.0 (pure min color) to 1.0 (pure max color).
	public static function interpolateColorInt(min:Int, max:Int, value:Float) : Int {
	
		var minRGB = RGB.fromInt(min);
		var maxRGB = RGB.fromInt(max);
		var r : RGB = interpolateColorRGB(minRGB, maxRGB, value);
		return r.toInt();		
	}
	
	public static function interpolateColorRGB(min:RGB, max:RGB, value:Float) : RGB {
		var out = new RGB();
		out.R = min.R + ((max.R - min.R) * value);
		out.G = min.G + ((max.G - min.G) * value);
		out.B = min.B + ((max.B - min.B) * value);
		return out;
	}

}

class RGB {

	public var R:Float;
	public var G:Float;
	public var B:Float;
	
	public function new() {
		R = 1;
		G = 1;
		B = 1;
	}
	
	public static function fromInt(int:Int) : RGB {
		var n : RGB = new RGB();
		n.setFromInt(int);
		return n;		
	}
	
	public function setFromInt(int:Int) {
		R = ((int >> 16) & 255) / 255;
		G = ((int >> 8) & 255) / 255;
		B = (int & 255) / 255;
	}
	
	public function toInt() : Int {
		return (Math.round(R * 255) << 16) | (Math.round(G * 255) << 8) | Math.round(B * 255);
	}
}


