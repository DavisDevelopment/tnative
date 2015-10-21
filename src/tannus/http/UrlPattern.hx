package tannus.http;

import tannus.http.Url;
import tannus.sys.GlobStar in Pattern;
import tannus.sys.Path;
import tannus.nore.Selector;
import tannus.ds.Object;

using StringTools;
using tannus.ds.StringUtils;

@:forward
abstract UrlPattern (CUrlPattern) from CUrlPattern to CUrlPattern {
	@:from
	public static inline function fromString(s : String):UrlPattern {
		return new CUrlPattern(s);
	}
}

@:expose('urlpattern')
class CUrlPattern {
	/* Constructor Function */
	public function new(s : String):Void {
		if (s.has('?')) {
			var serch = s.after('?');
			trace(serch);
			s = s.before('?');
			params = new Selector(serch);
		}
		else params = null;
		u = s;
		protocol = u.protocol;
		hostname = u.hostname;
		pathname = u.pathname;
	}

/* === Instance Methods === */

	/**
	  * Test a Url against [this] Pattern
	  */
	public function test(url : Url):Bool {
		return (
			protocol.test(url.protocol) &&
			hostname.test(url.hostname) &&
			pathname.test(url.path) &&
			(params != null ? params.test(url.params) : true)
		);
	}

	/**
	  * Get the match data for a given Url
	  */
	public function match(url : Url):Object {
		if (!test(url))
			return {};
		
		var o:Object = {};
		o += hostname.match(url.hostname);
		o += pathname.match(url.path);
		
		return o;
	}

	/**
	  * Test a String of a Url against [this] Pattern
	  */
	public function testString(s : String):Bool {
		return test( s );
	}

	public function matchString(s : String):Object {
		return match(s);
	}

/* === Instance Fields === */

	private var u:Url;

	private var protocol:Pattern;
	private var hostname:Pattern;
	private var pathname:Pattern;
	private var params:Null<Selector<Dynamic>>;
}
