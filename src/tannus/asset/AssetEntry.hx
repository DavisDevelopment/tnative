package tannus.asset;

import tannus.io.ByteArray;
import tannus.io.Getter;
import tannus.asset.AssetType;

typedef AssetEntry = {
	//- The type of Asset [this] is
	var type : AssetType;

	//- The path to [this] Asset
	var src : String;

	//- The name of [this] Asset
	var name : String;

	//- The contents of [this] Asset, expressed as a Pointer to a ByteArray (&Byte[])
	@:optional
	var data : Getter<ByteArray>;
};
