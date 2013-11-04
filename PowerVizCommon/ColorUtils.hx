package;

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
	
	/*Returns an Int color based on a hex string.
	the hex string should be in the form 0xFF00FF*/
	public static function hexStringToInt(s:String) : Int {
		return  Std.parseInt(s);
	}
	
	
	//Tone goes from 0 to 1.
	public static function colorTone(color:Int, tone:Float) : Int {
		var hsv = HSV.fromRGBInt(color);
		var s:Float = 1 - tone;
		if(s<0)
			s=0;
		if(s>1)
			s=1;
		hsv.S = s;
		return hsv.toRGBInt();
	}

}

class RGB {

	public var R:Float;
	public var G:Float;
	public var B:Float;
	
	public function new(?_r:Float, ?_g:Float, ?_b:Float) {
		R = _r!=null ? _r : 1;
		G = _g!=null ? _g : 1;
		B = _b!=null ? _b : 1;
	}
	
	public static function fromInt(int:Int) : RGB {
		var n : RGB = new RGB();
		n.setFromInt(int);
		return n;		
	}
	
	public static function fromHexString(s:String) : RGB {
		return fromInt(Std.parseInt(s));
	}
	
	public function setFromInt(int:Null<Int>) {
		if(int==null) {
			R = G = B = 0;
			return;
		}
		R = ((int >> 16) & 255) / 255;
		G = ((int >> 8) & 255) / 255;
		B = (int & 255) / 255;
	}
	
	public function toInt() : Int {
		return (Math.round(R * 255) << 16) | (Math.round(G * 255) << 8) | Math.round(B * 255);
	}
	
	public function toString() : String {
		return "r:" + R + ", g:" + G + ", b:" + B;
	
	}
	
	public function toHexString() : String {
		return "0x" + StringTools.hex(toInt(), 6);
	}
	
	public function toHSV() : HSV {
	
		var out:HSV = new HSV();
		var delta:Float = 0;
		
		var min:Float = R < G ? R : G;
		min = min < B ? min : B;
		
		var max:Float = R > G ? R : G;
		max = max > B ? max : B;
		
		out.V = max;
		delta = max - min;
		if(max > 0) {
			out.S = (delta / max);
		}
		else {
			out.S = 0;
			out.H = 0;
			return out;
		}
		
		if(R >= max) {
			out.H = (G - B) / delta;
		}
		else if(G >= max) {
			out.H = 2.0 + (B - R) / delta;
		}
		else {
			out.H = 4.0 + (R - G) / delta;
		}
		
		out.H *= 60.0;
		
		if(out.H < 0)
			out.H += 360;
			
		return out;

	}
	
}


class HSV {

	public var H(default,set):Float; //0-360.
	public var S(default,set):Float; //0-1
	public var V(default,set):Float; //0-1
	
	public function new(?_h:Float, ?_s:Float, ?_v:Float) {
		H = _h!=null ? _h : 1;
		S = _s!=null ? _s : 1;
		V = _v!=null ? _v : 1;
	}	
	
	function set_H(h:Float) : Float {
		H = h; 
		while(H<0)
			H += 360;
		while(H>360)
			H -= 360;
		return H;
	}
	
	function set_S(s:Float) : Float {
		S = s;
		if(S<0)
			S = 0;
		if(S>1)
			S = 1;
		return S;
	}
	
	function set_V(v:Float) : Float {
		V = v;
		if(V<0)
			V = 0;
		if(V>1)
			V = 1;
		return V;
	}
	
	public static function fromRGBInt(int:Int) : HSV {
		return fromRGB(RGB.fromInt(int));
	}
	
	public static function fromRGB(rgb:RGB) : HSV {
		return rgb.toHSV();
	}
	
	public function toRGB() : RGB {
	
		var hh:Float;
		var p:Float;
		var q:Float;
		var t:Float;
		var ff:Float;
		
		var i:Int;
		
		var out = new RGB();
		
		if(S <= 0) {
			return new RGB(V,V,V);
		}
		
		hh = H;
		if(hh >= 360.0)
			hh = 0.0;
		
		hh /= 60;
		i = Std.int(hh);
		ff = hh - i;
		p = V * (1.0 - S);
		q = V * (1.0 - (S * ff));
		t = V * (1.0 -  (S * (1.0 - ff)));
		
		switch(i) {
			case 0:
				out.R = V;
				out.G = t;
				out.B = p;
			case 1:
				out.R = q;
				out.G = V;
				out.B = p;
			case 2:
				out.R = p;
				out.G = V;
				out.B = t;
			case 3:
				out.R = p;
				out.G = q;
				out.B = V;
			case 4:
				out.R = t;
				out.G = p;
				out.B = V;
			case 5:
				out.R = V;
				out.G = p;
				out.B = q;
			default:
				out.R = V;
				out.G = p;
				out.B = q;
		}
		
		return out;
			
	}
	
	public function toRGBInt() : Int {
		return toRGB().toInt();
	}
	
	public function toString() : String {
		return "h:" + H + ", s:" + S + ", v:" + V;
	}
	
}

/*
 typedef struct {
    double r;       // percent
    double g;       // percent
    double b;       // percent
} rgb;

    typedef struct {
    double h;       // angle in degrees
    double s;       // percent
    double v;       // percent
} hsv;

    static hsv      rgb2hsv(rgb in);
    static rgb      hsv2rgb(hsv in);

hsv rgb2hsv(rgb in)
{
    hsv         out;
    double      min, max, delta;

    min = in.r < in.g ? in.r : in.g;
    min = min  < in.b ? min  : in.b;

    max = in.r > in.g ? in.r : in.g;
    max = max  > in.b ? max  : in.b;

    out.v = max;                                // v
    delta = max - min;
    if( max > 0.0 ) {
        out.s = (delta / max);                  // s
    } else {
        // r = g = b = 0                        // s = 0, v is undefined
        out.s = 0.0;
        out.h = NAN;                            // its now undefined
        return out;
    }
    if( in.r >= max )                           // > is bogus, just keeps compilor happy
        out.h = ( in.g - in.b ) / delta;        // between yellow & magenta
    else
    if( in.g >= max )
        out.h = 2.0 + ( in.b - in.r ) / delta;  // between cyan & yellow
    else
        out.h = 4.0 + ( in.r - in.g ) / delta;  // between magenta & cyan

    out.h *= 60.0;                              // degrees

    if( out.h < 0.0 )
        out.h += 360.0;

    return out;
}


rgb hsv2rgb(hsv in)
{
    double      hh, p, q, t, ff;
    long        i;
    rgb         out;

    if(in.s <= 0.0) {       // < is bogus, just shuts up warnings
        out.r = in.v;
        out.g = in.v;
        out.b = in.v;
        return out;
    }
    hh = in.h;
    if(hh >= 360.0) hh = 0.0;
    hh /= 60.0;
    i = (long)hh;
    ff = hh - i;
    p = in.v * (1.0 - in.s);
    q = in.v * (1.0 - (in.s * ff));
    t = in.v * (1.0 - (in.s * (1.0 - ff)));

    switch(i) {
    case 0:
        out.r = in.v;
        out.g = t;
        out.b = p;
        break;
    case 1:
        out.r = q;
        out.g = in.v;
        out.b = p;
        break;
    case 2:
        out.r = p;
        out.g = in.v;
        out.b = t;
        break;

    case 3:
        out.r = p;
        out.g = q;
        out.b = in.v;
        break;
    case 4:
        out.r = t;
        out.g = p;
        out.b = in.v;
        break;
    case 5:
    default:
        out.r = in.v;
        out.g = p;
        out.b = q;
        break;
    }
    return out;     
}
*/


