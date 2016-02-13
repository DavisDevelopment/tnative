package tannus.ds;

interface Stateful<T> {
	/* get the State of the object */
	function getState() : T;

	/* set the State of the object */
	function setState(state : T) : Void;
}
