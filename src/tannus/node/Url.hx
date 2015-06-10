package tannus.node;

import tannus.ds.Object;

class Url {
	public static function parse(url : String):UrlData {
		return cast NUrl.parse(url, true, true);
	}

	public static inline function format(ud : Dynamic) return NUrl.format(ud);
}

@:jsRequire('url')
extern class NUrl {
	/* Parse a url-string */
	static function parse(url:String, ?parseQuery:Bool, ?slashesDenoteHost:Bool):Dynamic;

	/* Stringify a url-object */
	static function format(urldata : UrlData):String;
}

typedef UrlData = {
	var href : String;
	var protocol : String;
	var slashes : Bool;
	var host : String;
	var auth : String;
	var hostname : String;
	var port : String;
	var pathname : String;
	var search : String;
	var path : String;
	var query : Object;
	var hash : String;
};
