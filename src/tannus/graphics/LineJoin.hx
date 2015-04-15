package tannus.graphics;

/**
  * Enum of all possible Line-Join Types
  */
@:enum
abstract LineJoin (String) {
	var Bevel = 'bevel';
	var Round = 'round';
	var Miter = 'miter';
}
