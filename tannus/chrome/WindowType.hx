package tannus.chrome;

@:enum
abstract WindowType (String) {
	var Normal = 'normal';
	var Popup = 'popup';
	var Panel = 'panel';
	var DetachedPanel = 'detached_panel';
}
