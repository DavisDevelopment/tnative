package tannus.node;

import haxe.Constraints.Function;
import haxe.extern.EitherType;

import tannus.ds.Object;

@:jsRequire('http')
extern class Http {
	/* Create a new Request */
	static function request(opts:EitherType<String, Object>, ?callback:IncomingMessage->Void):ClientRequest;
}
