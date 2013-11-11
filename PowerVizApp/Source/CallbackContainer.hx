

/**
Makes multiple callbacks easier to handle.
Callbacks must be simple (of the form function():Void ).
**/
class CallbackContainer {
	
	private var mCallbacks : Array<Void->Void>;
	
	public function new() {
		mCallbacks = new Array<Void->Void>();
	}
	
	public function addCallback(func:Void->Void) {
		mCallbacks.push(func);
	}
	
	public function invoke() {
		for(f in mCallbacks) {
			f();
		}
	}
	
}