//purpose of colorgenerator class is to generate "random" colors and return them 

class ColorGenerator{


	private var ColorArray:Array<Int>;
	public function new():Void{
		ColorArray = [0x800080,0x0000FF,0x008000,0xF0A804,0xFF0000,0x808080,0xff00c3,0x2a1533,0x0490ed];
	}

	public function generateColors(numberOfColors:Int):Array<Int>{
		var tempColorArray = new Array<Int>();
		for(i in 0...numberOfColors){

			tempColorArray.push(ColorArray[i]);

		}

		return tempColorArray;

	}
}