package tannus.html;

import js.html.Blob;

interface Blobable {
	function toBlob(callback:Blob->Void, ?type:String):Void;
}
