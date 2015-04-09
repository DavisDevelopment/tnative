package tannus.display.backend.java;

import java.lang.Runnable;

class RunnableFunction implements Runnable {
	private var f:Void->Void;

	public function new(f : Void->Void):Void {
		this.f = f;
	}

	public function run():Void {
		f();
	}
}
