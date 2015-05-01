package tannus;

import tannus.io.Ptr;
import tannus.io.ByteArray;
import tannus.sys.Path;
import tannus.asset.AssetEntry;
import tannus.asset.AssetType;
import tannus.asset.Asset;
import tannus.internal.CompileTime;

import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;
using haxe.macro.ExprTools;

/**
  * Class of utility methods for working with Assets
  */
class Assets {

	/**
	  * Register a new Asset
	  */
	public static macro function register(src:String, name:String, type:String) {
		var spath:Path = src;

		switch ( type ) {
			case 'binary':
				return macro (function() {
					var _bits:tannus.ds.Maybe<tannus.io.ByteArray> = null;
					var bits:Void->ByteArray = (function() {
						if (_bits.exists) {
							return _bits;
						}
						else {
							var data:ByteArray = tannus.internal.CompileTime.readFile($v{src});
							_bits = data;
							return data;
						}
					});

					tannus.Assets._registry.set($v{name}, {
						'type' : tannus.asset.AssetType.Data,
						'src'  : $v{src},
						'name' : $v{name},
						'data' : (new tannus.io.Getter( bits ))
					});
				}());

			default:
				return macro throw 'Fuck You';
		}
	}

	/**
	  * Load an Asset by name
	  */
	public static function loadAsset(name:String):Asset {
		return _registry.get( name );
	}

/* === Static Fields === */

	public static var _registry:Map<String, AssetEntry> = {new Map();};
}
