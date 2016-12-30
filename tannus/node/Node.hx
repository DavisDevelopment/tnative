package tannus.node;

class Node {
/* === Class Fields === */

	// the current process
	public static var process(get, never):Process;
	private static inline function get_process():Process {
		return (untyped __js__( 'process' ));
	}
}
