package nme;


import openfl.Assets;


class AssetData {
	
	
	public static var library:Map <String, LibraryType>;
	public static var path:Map <String, String>;
	public static var type:Map <String, AssetType>;
	
	private static var initialized:Bool = false;
	
	
	public static function initialize ():Void {
		
		if (!initialized) {
			
			path = new Map<String, String> ();
			type = new Map<String, AssetType> ();
			library = new Map<String, LibraryType> ();
			
			path.set ("assets/testimg/01.png", "assets/testimg/01.png");
			type.set ("assets/testimg/01.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/testimg/02.png", "assets/testimg/02.png");
			type.set ("assets/testimg/02.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/testimg/03.png", "assets/testimg/03.png");
			type.set ("assets/testimg/03.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/testimg/04.png", "assets/testimg/04.png");
			type.set ("assets/testimg/04.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/testimg/05.png", "assets/testimg/05.png");
			type.set ("assets/testimg/05.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/testimg/06.png", "assets/testimg/06.png");
			type.set ("assets/testimg/06.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/testimg/07.png", "assets/testimg/07.png");
			type.set ("assets/testimg/07.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/testimg/08.png", "assets/testimg/08.png");
			type.set ("assets/testimg/08.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/testimg/09.png", "assets/testimg/09.png");
			type.set ("assets/testimg/09.png", Reflect.field (AssetType, "image".toUpperCase ()));
			
			
			initialized = true;
			
		}
		
	}
	
	
}