package tannus.chrome;

import tannus.chrome.Notifications in N;
import tannus.chrome.Notifications.NotificationOptions in Options;
import tannus.chrome.Notifications.NotificationButtonDef in ButtonOptions;
import tannus.chrome.Notifications.NotificationItemDef in ItemOptions;
import tannus.chrome.Notifications.NotificationTemplateType in Style;

import tannus.ds.*;
import tannus.io.*;

using Lambda;
using tannus.ds.ArrayTools;

class Notification {
	/* Constructor Function */
	public function new(id:String, def:Options):Void {
		this.id = id;
		o = def;

		clicked = new VoidSignal();
		closed = new VoidSignal();
		buttons = new Array();

		pullOptions();
		__listen();
	}

/* === Instance Methods === */

	/* update [this] Notification */
	public function update(?cb : Bool -> Void):Void {
		if (cb == null) cb = (function(x) null);
		N.update(id, getOptions(), cb);
	}

	/* close [this] Notification */
	public function close(?cb : Bool -> Void):Void {
		if (cb == null) cb = (function(x) null);
		N.clear(id, cb);
	}

	/* read data from [o] */
	private function pullOptions():Void {
		type = o.type;
		iconUrl = o.iconUrl;
		title = o.title;
		message = o.message;
		contextMessage = o.contextMessage;
		buttonDefs = o.buttons;

		buttons = new Array();
		if (buttonDefs != null && buttonDefs.length > 0) {
			for (d in buttonDefs) {
				buttons.push(new NotificationButton(this, d));
			}
		}
	}

	/* get options */
	public function getOptions():Options {
		var keys = ['type', 'iconUrl', 'title', 'message', 'contextMessage', 'isClickable'];
		var _o:Obj = Obj.fromDynamic( this ).pluck( keys );
		var no:Options = _o.toDyn();
		no.buttons = buttonDefs.copy();
		return no;
	}

	/* handle clicking of [this] Notification */
	private function __click(e : String):Void {
		if (e == id) {
			clicked.fire();
		}
	}

	/* handle clicking of one of our buttons */
	private function __clickButton(e : ClickData):Void {
		if (e.notificationId == id) {
			var button:Null<NotificationButton> = buttons[ e.buttonIndex ];
			if (button != null) {
				button.clicked.fire();
			}
		}
	}

	/* handle [this] Notification closing */
	private function __close(e : CloseData):Void {
		if (e.notificationId == id) {
			closed.fire();
			__delete();
		}
	}

	/* listen for events */
	private function __listen():Void {
		N.onClosed.addListener( __close );
		N.onClicked.addListener( __click );
		N.onButtonClicked.addListener( __clickButton );
	}

	/* delete [this] Notification */
	private function __delete():Void {
		N.onClosed.removeListener( __close );
		N.onClicked.removeListener( __click );
		N.onButtonClicked.removeListener( __clickButton );
	}

/* === Instance Fields === */

	public var id : String;

	public var type : Style;
	public var iconUrl : String;
	public var title : String;
	public var message : String;
	public var contextMessage : Null<String>;
	public var buttonDefs : Array<ButtonOptions>;
	public var isClickable : Bool;
	
	public var imageUrl : Null<String>;
	public var items : Array<ItemOptions>;
	public var progress : Null<Int>;

	public var clicked : VoidSignal;
	public var closed : VoidSignal;
	public var buttons : Array<NotificationButton>;

	private var o : Options;
}

class NotificationButton {
	/* Constructor Function */
	public function new(n:Notification, def:ButtonOptions):Void {
		notification = n;
		title = def.title;
		iconUrl = def.iconUrl;
		clicked = new VoidSignal();
	}

/* === Instance Fields === */

	public var title : String;
	public var iconUrl : Null<String>;
	public var clicked : VoidSignal;
	public var notification : Notification;
}

private typedef ClickData = {notificationId:String, buttonIndex:Int};
private typedef CloseData = {notificationId:String, byUser:Bool};
