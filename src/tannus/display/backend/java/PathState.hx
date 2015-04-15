package tannus.display.backend.java;

import tannus.display.backend.java.PathRenderer;
import tannus.ds.ActionStack;
import tannus.ds.Queue;
import tannus.ds.Maybe;
import tannus.io.Ptr;
import tannus.graphics.PathStyle;

class PathState {
	/* Constructor Function */
	public function new(?style:Maybe<PathStyle>, ?buff:Maybe<ActionStack>):Void {
		styles = style.or(new PathStyle());
		buffer = buff.or(new ActionStack());
	}

	/**
	  * Create and return a clone of [this] PathState
	  */
	public function clone():PathState {
		return new PathState(styles.clone(), buffer.clone());
	}

	
	public var styles : PathStyle;
	public var buffer : ActionStack;
}
