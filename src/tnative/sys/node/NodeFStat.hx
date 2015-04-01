package tnative.sys.node;

@:jsRequire('fs', 'Stats')
extern class NodeFStat {
	public function isFile():Bool;
	public function isDirectory():Bool;

	public var size : Int;
	public var mtime : Dynamic;
	public var ctime : Dynamic;
}
