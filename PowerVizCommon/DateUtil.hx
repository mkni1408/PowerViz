

class DateUtil {

	//Returns true if the two time objects are in the same time interval.
	static public function isInSameInterval(one:Date, two:Date, intervalMinutes:Int) {
		var from:Date = intervalStart(one, intervalMinutes);
		var to:Date =  Date.fromTime(from.getTime() + (intervalMinutes*60*1000));
		if(two.getTime()>= from.getTime() && two.getTime() < to.getTime())
			return true;
		return false;
	}
	
	//Returns the start of the interval that 'time' is in.
	static public function intervalStart(time:Date, intervalMinutes:Int) : Date {
		return new Date(time.getFullYear(), time.getMonth(), time.getDate(), time.getHours(), 
										Math.floor(time.getMinutes()/intervalMinutes)*intervalMinutes, 0);
	}
	
	static public function intervalEnd(time:Date, intervalMinutes:Int) : Date {
		return Date.fromTime(intervalStart(time, intervalMinutes).getTime() + (intervalMinutes*60*1000));
	}

}
