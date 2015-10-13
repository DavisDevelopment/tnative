package tannus.http;

import tannus.ds.QueryString in Qs;
import tannus.ds.Object;
import tannus.io.RegEx;

import tannus.sys.Path;

using StringTools;
using tannus.ds.StringUtils;

@:expose('Href')
class Url {
	/* Constructor Function */
	public function new(surl : String):Void {
		//- extract the protocol (if present)
		protocol = (~/([A-Z]+):/i.match(surl) ? surl.substring(0, surl.indexOf(':')+1) : '');
		
		//- [surl], stripped of [protocol]
		var noproto:String = surl.strip(protocol+'').after('//');
		protocol = protocol.before(':');
		
		//- if no protocol was provided, [protocol] is http
		if (protocol.empty())
			protocol = 'http';

		//- strip the first "/" from [noproto], if "/" is the first character
		if (noproto.startsWith('/'))
			noproto = noproto.substring(1);

		//- get the hostname
		hostname = noproto.before('/'); //noproto.substring(noproto.indexOf(':')+1, noproto.indexOf('/'));
		
		//- get the pathname
		pathname = noproto.after('/'); //noproto.substring(noproto.indexOf('/')+1);
		
		//- get the search-string
		search = (pathname.has('?') ? pathname.after('?') : '');
		
		//- strip [search] (if not empty) from [pathname]
		pathname = pathname.strip(search);

		// search = (search.startsWith('?') ? search.slice(1) : search);

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

	public var protocol : String;
	public var hostname : String;
	public var pathname : String;
	
	public var search : String;
	public var hash : String;

	public var params : Object;
	public var hashparams : Null<Object>;
}
