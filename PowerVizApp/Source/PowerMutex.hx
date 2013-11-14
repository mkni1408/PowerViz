#if neko
	import neko.vm.Mutex;
#elseif cpp
	import cpp.vm.Mutex;
#elseif flash
	import flash.concurrent.Mutex;
#end

/**
Wrapper class for handling Mutex' on multiple platforms.
**/
class PowerMutex {
	
	#if(neko || cpp || flash)
		private var mMutex : Mutex; //The thing being wrapped.
	#end
	
	public function new() {
		#if(neko || cpp || flash)
			mMutex = new Mutex();
		#end
	}
	
	public function acquire() {
		#if flash
			mMutex.lock();
		#elseif(cpp || neko)
			mMutex.acquire();
		#end
	}
	
	public function tryAcquire() : Bool {
		#if flash
			return mMutex.tryLock();
		#elseif(cpp || neko)
			return mMutex.tryAcquire();
		#else
			return true; //Dummy.
		#end
	}
	
	public function release() {
		#if flash
			mMutex.unlock();
		#elseif(cpp || neko)
			mMutex.release();
		#end
	}
	
}