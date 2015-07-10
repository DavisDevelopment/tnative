package tannus.chrome;

@:enum
abstract MenuEntryType (String) from String to String {
	public var Normal : String = 'normal';
	public var Checkbox : String = 'checkbox';
	public var Radio : String = 'radio';
	public var Separator : String = 'separator';
}
