package tannus.chrome;

@:enum
abstract WindowState (String) from String {
	var Normal = 'normal';
	var Minimized = 'minimized';
	var Maximized = 'maximized';
	var FullScreen = 'fullscreen';
	var Docked = 'docked';
}
