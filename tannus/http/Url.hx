package tannus.http;

import tannus.ds.QueryString in Qs;
import tannus.ds.Object;
import tannus.io.RegEx;

import tannus.sys.Path;

using StringTools;
using tannus.ds.StringUtils;

@:forward
abstract Url (CUrl) from CUrl to CUrl {
	public inline function new(?s : String) this = new CUrl(s);

/* === Type Casting === */

	@:to
	public inline function toString():String return this.toString();

	@:from
	public static inline function fromString(s : String):Url return new CUrl(s);
}

@:expose('Href')
class CUrl {
	/* Constructor Function */
	public function new(?surl : String):Void {
		/* set all default values */
		protocol = null;
		hostname = null;
		pathname = null;
		search = null;
		hash = null;

		/* if [surl] was provided, parse it */
		if (surl != null) {
			//- extract the protocol (if present)
			protocol = (~/^([A-Z]+):/i.match(surl) ? surl.substring(0, surl.indexOf(':')) : '');
			if (protocol.empty())
				protocol = 'http';
			
			//- [surl], stripped of [protocol]
			var noproto:String = surl.remove(protocol+'://');
			
			//- strip the first "/" from [noproto], if "/" is the first character
			if (noproto.startsWith('/'))
				noproto = noproto.substring(1);

			//- get the hostname
			hostname = noproto.before('/');
			
			//- get the pathname
			pathname = (noproto.has('/') ? noproto.after('/') : '');
			
			//- get the search-string
			search = (pathname.has('?') ? pathname.after('?') : '');
			
			//- strip [search] (if not empty) from [pathname]
			pathname = pathname.strip('?').strip(search);

			//- (if possible) extract hashcode from the search-string
			hash = (search.has('#') ? search.after('#') : '');
			search = search.before('#');

			//- (if possible AND necessary) extract hashcode from the pathname
			if (hash.empty() && pathname.has('#')) {
				hash = pathname.after('#');
				pathname = pathname.before('#');
			}

			params = Qs.parse(search);
			try {
				hashparams = Qs.parse(hash);
			}
			catch(err : String) {
				hashparams = null;
			}
		}
	}

/* === Instance Methods === */

	/**
	  * Create a URL String from [this]
	  */
	public function toString():String {
		search = Qs.stringify(params);
		hash = (hashparams != null ? Qs.stringify(hashparams) : hash+'');
		var base:String = ('$protocol://$hostname/$pathname');
		base += (params.keys.length == 0 ? '' : '?'+search);
		base += (hash != '' ? '#'+hash : '');
		return base;
	}

	/**
	  * Creates a copy of [this]
	  */
	public function clone():Url {
		return new Url(toString());
	}

/* === Computed Instance Fields === */

	/**
	  * Get the Domain-name as an Array
	  */
	public var domain(get, set):Array<String>;
	private function get_domain() return hostname.split('.');
	private function set_domain(v:Array<String>):Array<String> {
		hostname = v.join('.');
		return domain;
	}

	/**
	  * get the pathname as a Path
	  */
	public var path(get, set):Path;
	private inline function get_path():Path {
		return new Path(pathname);
	}
	private inline function set_path(v : Path):Path {
		pathname = v;
		return path;
	}

/* === Instance Fields === */

	public var protocol : Null<String>;
	public var hostname : Null<String>;
	public var pathname : Null<String>;
	
	public var search : Null<String>;
	public var hash : Null<String>;

	public var params : Object;
	public var hashparams : Null<Object>;
}
