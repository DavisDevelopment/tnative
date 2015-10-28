package tannus.node;

@:jsRequire('querystring')
extern class QueryString {
	static function stringify(o:Dynamic, ?sep:String, ?eq:String, ?opts:Dynamic):String;
	static function parse(str:String, ?sep:String, ?eq:String, ?opts:Dynamic):Dynamic;
}
