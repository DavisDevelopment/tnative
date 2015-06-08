package tannus.ui;

@:enum
abstract FontStyle (String) from String to String {
	public var Normal : String = 'normal';
	public var Italic : String = 'italic';
	public var Oblique: String = 'oblique';
}
