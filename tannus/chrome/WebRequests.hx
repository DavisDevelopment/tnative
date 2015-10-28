package tannus.chrome;

import tannus.ds.Object;
import tannus.chrome.WebRequestDetails;//.BaseDetails
import tannus.chrome.WebRequestDetails in Details;

using Lambda;
using tannus.ds.ArrayTools;

class WebRequests {
	/**
	  * Listen for Request Details, before they're actually sent
	  */
	public static inline function onBeforeRequest(cb:DetailsCallback, filter:RequestFilter):Void {
		lib.onBeforeRequest.addListener(cb, filter, ['requestBody', 'blocking']);
	}

	/**
	  * Intercept a Request's Headers mid-flight
	  */
	public static inline function onBeforeSendHeaders(cb:DetailsCallback, filter:RequestFilter):Void {
		lib.onBeforeSendHeaders.addListener(cb, filter, ['requestHeaders', 'blocking']);
	}
	public static inline function onSendHeaders(cb:DetailsCallback, filter:RequestFilter):Void {
		lib.onSendHeaders.addListener(cb, filter, ['requestHeaders', 'blocking']);
	}

	/**
	  * Intercept a Request's Response Headers
	  */
	public static inline function onHeadersReceived(cb:DetailsCallback, filter:RequestFilter):Void {
		lib.onHeadersReceived.addListener(cb, filter);
	}

	/* internal reference to the underlying api */
	public static var lib(get, never):Dynamic;
	private static inline function get_lib() return untyped __js__('chrome.webRequest');
}
