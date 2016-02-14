package tannus.nw;

import tannus.sys.Path;
import tannus.http.Url;

class Shell {
	/**
	  * Open the given Url with the default browser
	  */
	public static inline function openExternal(url : Url):Void {
		CShell.openExternal(url.toString());
	}

	public static inline function openItem(path : Path):Void {
		CShell.openItem(path.toString());
	}

	public static inline function showItemInFolder(path : Path):Void {
		CShell.showItemInFolder(path.toString());
	}
}

@:jsRequire('nw.gui', 'Shell')
extern class CShell {
	static function openExternal(s : String):Void;
	static function openItem(s : String):Void;
	static function showItemInFolder(s : String):Void;
}
