package tannus.asset;

import tannus.asset.AssetEntry;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.Signal;

/**
  * Utility Wrapper around AssetEntry
  */
@:forward(name, src, type)
abstract Asset (AssetEntry) from AssetEntry {
	/* Constructor Function */
	public inline function new(entry : AssetEntry):Void {
		this = entry;
	}

	/**
	  * Reference to [this] as an AssetEntry
	  */
	public var entry(get, never):AssetEntry;
	private inline function get_entry():AssetEntry {
		return this;
	}

	/**
	  * [this] Asset's Data
	  */
	public var data(get, never):ByteArray;
	private inline function get_data():ByteArray {
		/* Only Attempt to get the data, if [this] is a Binary Asset */
		switch (this.type) {
			case Data:
				return this.data;

			default:
				throw 'AssetError: Cannot get binary data of ${this.type} Asset!';
		}
	}
}
