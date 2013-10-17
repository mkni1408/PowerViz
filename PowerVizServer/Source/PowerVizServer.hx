
import DataBaseInterface;


import Api;

class PowerVizServer {

	public static function main() {
	
		//Setup Remoting:
		var ctx = new haxe.remoting.Context();
		ctx.addObject("Api",new Api());
		if( haxe.remoting.HttpConnection.handleRequest(ctx) )
			return;
			
		// handle normal request
		Sys.println("This is a remoting server!");
		
	}
	
}


