package tannus.events;

import tannus.internal.CompileTime in Ct;
import tannus.ds.Object;

@:enum
abstract Key (Int) from Int to Int {
/* === Constructs === */
    var CapsLock = 20;
    var NumpadDot = 110;
    var NumpadForwardSlash = 111;
    var Command = 91;
    var ForwardSlash = 191;
    var Enter = 13;
    var Shift = 16;
    var Space = 32;
    var PageUp = 33;
    var Backspace = 8;
    var Tab = 9;
    var NumpadPlus = 107;
    var Dot = 190;
    var OpenBracket = 219;
    var Home = 36;
    var Left = 37;
    var Equals = 187;
    var Apostrophe = 222;
    var Right = 39;
    var CloseBracket = 221;
    var NumLock = 144;
    var BackSlash = 220;
    var PageDown = 34;
    var End = 35;
    var Minus = 189;
    var SemiColon = 186;
    var Down = 40;
    var Esc = 27;
    var Comma = 188;
    var Delete = 46;
    var NumpadAsterisk = 106;
    var BackTick = 192;
    var Ctrl = 17;
    var Insert = 45;
    var ScrollLock = 145;
    var NumpadMinus = 109;
    var Up = 38;
    var Alt = 18;
    var LetterA = 65;
    var LetterB = 66;
    var LetterC = 67;
    var LetterD = 68;
    var LetterE = 69;
    var LetterF = 70;
    var LetterG = 71;
    var LetterH = 72;
    var LetterI = 73;
    var LetterJ = 74;
    var LetterK = 75;
    var LetterL = 76;
    var LetterM = 77;
    var LetterN = 78;
    var LetterO = 79;
    var LetterP = 80;
    var LetterQ = 81;
    var LetterR = 82;
    var LetterS = 83;
    var LetterT = 84;
    var LetterU = 85;
    var LetterV = 86;
    var LetterW = 87;
    var LetterX = 88;
    var LetterY = 89;
    var LetterZ = 90;

/* === Fields === */

    public var name(get, never):String;
    private inline function get_name() return nameof(this);

/* === Methods === */

    //- Data from which key-names are pulled
    private static var raw:Object = {{};/*haxe.Json.parse(Ct.readFile('assets/keycodes.json'));*/};
    
    /**
      * Obtain the 'name' of a Key as a String
      */
    public static function nameof(key : Key):Null<String> {
	for (pair in raw.pairs()) {
		if (pair.value == key)
			return pair.name;
	}
	return null;
    }
}
