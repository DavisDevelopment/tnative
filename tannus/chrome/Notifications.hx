package tannus.chrome;

import tannus.ds.*;
import tannus.io.*;

using Lambda;
using tannus.ds.ArrayTools;

class Notifications {
/* === Static Methods === */

	/**
	  * Create and display a new Notification
	  */
	public static inline function createRaw(id:Null<String>, options:NotificationOptions, cb:String->Void):Void {
		lib.create(id, options, cb);
	}

	/**
	  * Create and obtain a new Notification object
	  */
	public static function create(options : NotificationOptions):Promise<Notification> {
		return Promise.create({
			createRaw(null, options, function( id ) {
				return new Notification(id, options);
			});
		});
	}

	/**
	  * update an existing Notification
	  */
	public static inline function update(id:String, options:NotificationOptions, cb:Bool->Void):Void {
		lib.update(id, options, cb);
	}

	/**
	  * delete an existing Notification
	  */
	public static inline function clear(id:String, cb:Bool->Void):Void {
		lib.clear(id, cb);
	}

	/* retrieve all Notifications */
	public static inline function getAll(cb : Array<Dynamic>->Void):Void {
		lib.getAll( cb );
	}

	/* get the permission level of the current app/extension */
	public static inline function getPermissionLevel(cb : PermissionLevel -> Void):Void {
		lib.getPermissionLevel( cb );
	}

	/* get (as a boolean) whether the current app has permission to manipulate Notifications */
	public static function getPermission(cb : Bool -> Void):Void {
		getPermissionLevel(function(pm : PermissionLevel) cb( pm ));
	}

/* === Computed Static Fields === */

	/* listen for 'onClose' events */
	public static var onClosed(get, never):NotificationCloseEvent;
	private static inline function get_onClosed():NotificationCloseEvent return lib.onClosed;

	public static var onClicked(get, never):NotificationClickEvent;
	private static inline function get_onClicked():NotificationClickEvent return lib.onClicked;

	public static var onButtonClicked(get, never):NotificationButtonClickEvent;
	private static inline function get_onButtonClicked():NotificationButtonClickEvent return lib.onButtonClicked;

/* === Static Fields === */

	/* the actual object used by [this] class */
	private static var lib(get, never):Dynamic;
	private static inline function get_lib():Dynamic return untyped __js__( 'chrome.notifications' );
}

typedef NotificationOptions = {
	?type : NotificationTemplateType,
	?iconUrl : String,
	?appIconMaskUrl : String,
	?title : String,
	?message : String,
	?contextMessage : String,
	?priority : Int,
	?eventTime : Float,
	?buttons : Array<NotificationButtonDef>,
	?imageUrl : String,
	?items : Array<NotificationItemDef>,
	?progress : Int,
	?isClickable : Bool
};

/* Object provided to define a Notification Button */
typedef NotificationButtonDef = {
	title : String,
	?iconUrl : String
};

/* Object provided to define a Notification Item */
typedef NotificationItemDef = {
	title : String,
	message : String
};

@:enum
abstract NotificationTemplateType (String) from String to String {
	var Basic = 'basic';
	var Image = 'image';
	var List = 'list';
	var Progress = 'progress';
}

@:enum
abstract PermissionLevel (String) from String to String {
	var Granted = 'granted';
	var Denied = 'denied';

	@:to
	public inline function toBool():Bool return (this == 'granted');
	@:from
	public static inline function fromBool(b : Bool):PermissionLevel {
		return (b ? Granted : Denied);
	}
}

typedef NotificationCloseEvent = ChromeEvent<{notificationId:String, byUser:Bool} -> Void>;
typedef NotificationClickEvent = ChromeEvent<String -> Void>;
typedef NotificationButtonClickEvent = ChromeEvent<{notificationId:String, buttonIndex:Int} -> Void>;
