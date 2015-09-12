package tannus.http;

import tannus.ds.QueryString in Qs;
import tannus.ds.Object;
import tannus.io.RegEx;

using StringTools;
using tannus.ds.StringUtils;

class Url {
	/* Constructor Function */
	public function new(surl : String):Void {
		protocol = (~/([A-Z]+):/i.match(surl) ? surl.substring(0, surl.indexOf(':')+1) : null);
		var noproto:String = surl.replace(protocol+'', '');
		if (noproto.startsWith('//'))
			noproto = noproto.substring(2);
		if (protocol != null)
			protocol = protocol.slice(0, -1);
		
		hostname = noproto.substring(noproto.indexOf(':')+1, noproto.indexOf('/'));
		pathname = noproto.substring(noproto.indexOf('/')+1);
		search = (pathname.has('?') ? pathname.substring(pathname.indexOf('?')) : '');
		pathname = pathname.strip(search);
		search = (search.startsWith('?') ? search.slice(1) : search);
		hash = (search.has('#') ? search.substring(0, search.indexOf('#')) : '');
		search = search.strip(hash);
		hash = hash.slice(1);
		params = Qs.parse(search);
	}

/* === Instance Methods === */

	/**
	  * Create a URL String from [this]
	  */
	public function toString():String {
		search = Qs.stringify(params);
		var base:String = ('$protocol://$hostname/$pathname');
		base += (params.keys.length == 0 ? '' : '?'+search);
		base += (hash != '' ? '#'+hash : '');
		return base;
	}

/* === Instance Fields === */

	public var protocol : String;
	public var hostname : String;
	public var pathname : String;
	public var search : String;
	public var params : Object;
	public var hash : String;
}
