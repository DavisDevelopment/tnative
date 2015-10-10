package tannus.graphics;

/**
  * Enum of all possible Line-Join Types
  */
@:enum
abstract LineJoin (String) from String to String {
	var Bevel = 'bevel';
	var Round = 'round';
	var Miter = 'miter';
}
