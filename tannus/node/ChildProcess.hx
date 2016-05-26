package tannus.node;

@:jsRequire('child_process')
extern class ChildProcess {
	static function execSync(cmd:String, ?opts:Dynamic):Buffer;
}
