package tannus.events;

/**
  * Enum of the modifier keys for Mouse/Keyboard Events
  */
@:enum
abstract EventMod (String) {
	var Alt = 'alt';
	var Shift = 'shift';
	var Control = 'ctrl';
	var Meta = 'super';
}
