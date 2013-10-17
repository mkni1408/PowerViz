
import SensitiveData;

import DataInterface; //Import the DataInterface from PowerVizApp;

/**
This is a special purpose console application, which tests the communication layer between the client and the server.
It is used for sending and receiving test data, and should therefore not be considered a part of the server, but only used for checking that
the communication between client and server works as expected.
**/

class TestClient {

	public static function main() {
		trace("Hello");
		
		DataInterface.instance.connect("http://78.47.92.222/pvsdev/");
		DataInterface.instance.fetchOutletNames(42, onOutletNamesFetched);
		
		DataInterface.instance.fetchTimestamp(onTimestamp);
		
		trace(Date.now());
		trace(DateTools.delta(Date.now(), 3600*1000));
	}
	
	
	public static function onOutletNamesFetched(m:Map<Int, String>) : Void {
		trace(m);
	}
	
	public static function onTimestamp(f:Float) : Void {
		trace(f);
		trace(Date.now().getTime());
	}

}
