package tannus.msg;

import tannus.ds.Memory in Mem;
import tannus.ds.Maybe;
import tannus.io.Signal;

class PipelineRouter {
	/* Constructor Function */
	public function new(pipeline : Pipeline):Void {
		p = pipeline;
		signals = new Map();
		awaitingReply = new Array();
	}

/* === Instance Methods === */

	/**
	  * send a Message
	  */
	public function sendMessage(m : Message<Dynamic>):Void {
		p.sendMessage( m );
	}

	public function send(action:String, data:Dynamic, ?onreply:Dynamic->Void):Void {
		var msg:Message<Dynamic> = p.createMessage();
		msg.data = data;
		msg.onReply = onreply;

		sendMessage( msg );
	}

	public inline function on<T>(action:String, handler:Message<T>->Void):Void {
		actionSignal( action ).on( handler );
	}

	/**
	  * obtain a Signal for the given action
	  */
	private function actionSignal(action : String):Signal<Message<Dynamic>> {
		var sig:Signal<Message<Dynamic>> = signals[action];
		if (sig == null) {
			sig = signals[action] = new Signal();
		}
		return sig;
	}

	/**
	  * route the given Message
	  */
	public function receive(m : Message<Dynamic>):Void {
		switch ( m.type ) {
			case Normal:
				actionSignal( m.address.action ).call( m );
			
			case Reply:
				var m2:Null<Message<Dynamic>> = awaitingReply.macfirstMatch(_.id == m.id);
				if (m2 == null) {
					trace('Message reply ignored -- could not find the sender');
				}
				else {
					m2.onReply( m.data );
					awaitingReply.remove( m2 );
				}

			case Close:
				trace('Pipeline peer has closed');
		}
	}

/* === Instance Fields === */

	public var p : Pipeline;

	private var signals : Map<String, Signal<Message<Dynamic>>>;
	private var awaitingReply : Array<Message<Dynamic>>;
}
