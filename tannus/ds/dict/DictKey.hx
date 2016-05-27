package tannus.ds.dict;

import haxe.extern.EitherType;
//import haxe.CallStack

typedef DictKey = EitherType<Int, EitherType<String, EitherType<EnumValue, tannus.ds.Comparable<Dynamic>>>>;
