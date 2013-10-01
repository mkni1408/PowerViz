
import haxe.remoting.HttpAsyncConnection;

//IMPORTANT NOTE: Define 'development' if compiling in development mode, so that log data is not entered into the production server.
//Use -D development on the compiler commandline to do this.

/**
Static class used for collecting and logging user behaviour data.
The logger class transfers data to the log server asynchronously.
**/


class Logger {

	#if development
		public static inline var log_server_url:String = "http://www.productionserver.com/logserver/index.php"; //URL of the PHP production logging server.
	#else
		public static inline var log_server_url:String = "http://www.developmentserver.com/logserver/index.php"; //URL of the PHP development logging server.
	#end


	public static inline var INTERNAL_EVENT:Int = 0; //Used for internal events only. 
	public static inline var USER_INTERACTION:Int = 1; //Logs an unspecified user interaction with the system. 
	public static inline var USER_SCREEN_CHANGE:Int = 2; //The screen has changed on user demand. 
	public static inline var USER_WAKEUP:Int = 3; //The system receives a "wakeup press" from a user.  
	
	
	//Used for logging data from the user interface. Additional information is sent to the logging server. 
	static public function logData(deviceID:Int, category:Int, data:String) {
		connect();
		//Call the log function on the server, with the following arguments:
		//deviceID:Int, localTime:Date, logCategory:Int, data:String.
		mConnection.LogServer.logData.call([deviceID, Date.now(), category, data], Logger.logCallback);
	}
	
	static private function logCallback() {
	}
	
	private static var mConnection : HttpAsyncConnection = null;
	
	static private function connect() {
		if(mConnection==null) {
			//Do connection stuff here...
			mConnection = haxe.remoting.HttpAsyncConnection.urlConnect(log_server_url);
			mConnection.setErrorHandler(Logger.onError);
		}
	}
	
	static private function onError(err:Dynamic) {
		trace("Logger ERROR: " + Std.string(err));
		mConnection = null;
	}

}
