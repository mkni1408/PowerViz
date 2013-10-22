//class that defines an on off object. Has a start and stop date

class OnOffData{
	
	
	public var mStart(default,null): Date;
	public var mStop(default,null): Date;


	public function new(start:Date,stop:Date):Void{

		mStart = start;
		mStop = stop;

	}


	public function getStart():Date{


		return mStart;
	}


	public function getStop():Date{


		return mStop;
	}
}