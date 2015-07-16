package tannus.ds;

/**
  * A type of Object which is only needed for a while, and may be 'destroyed', or deleted when done
  */
interface Destructible {
	function destroy():Void;
}
