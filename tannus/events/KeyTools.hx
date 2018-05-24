package tannus.events;

import tannus.io.Byte;
import tannus.io.Char;

import haxe.macro.Expr;
import haxe.macro.Context;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
#if macro
using haxe.macro.ExprTools;
#end

class KeyTools {
	/**
	  * Get the 'name' of the given Key
	  */
	public static function getName(key : Key):String {
		return keyNames()[key];
	}

	/**
	  * Get the Key with the given name
	  */
	public static function getKey(name : String):Null<Key> {
		return nameKeys()[name.toLowerCase()];
	}

	/**
	  * mapping from Key to name
	  */
	public static function keyNames():Map<Key, String> {
		if (_keyNames == null) {
			_keyNames = [
				CapsLock => '<CapsLock>',
				NumpadDot => '<Numpad .>',
				NumpadForwardSlash => '<Numpad />',
				Command => 'Super',
				ForwardSlash => '/',
				Enter => 'Enter',
				Shift => 'Shift',
				Space => 'Space',
				PageUp => '<Page Up>',
				Backspace => 'Backspace',
				Tab => 'Tab',
				NumpadPlus => '<Numpad +>',
				Dot => '.',
				OpenBracket => '[',
				Home => 'Home',
				Left => 'Left',
				Equals => '=',
				Apostrophe => "'",
				Right => 'Right',
				CloseBracket => ']',
				NumLock => '<Num Lock>',
				BackSlash => '\\',
				PageDown => '<Page Down>',
				End => 'End',
				Minus => '-',
				SemiColon => ';',
				Down => 'Down',
				Esc => 'Esc',
				Comma => ',',
				Delete => 'Delete',
				NumpadAsterisk => '<Numpad *>',
				BackTick => '`',
				Ctrl => 'Ctrl',
				Insert => 'Insert',
				ScrollLock => '<Scroll Lock>',
				NumpadMinus => '<Numpad ->',
				Up => 'Up',
				Alt => 'Alt',
				LetterA => 'A',
				LetterB => 'B',
				LetterC => 'C',
				LetterD => 'D',
				LetterE => 'E',
				LetterF => 'F',
				LetterG => 'G',
				LetterH => 'H',
				LetterI => 'I',
				LetterJ => 'J',
				LetterK => 'K',
				LetterL => 'L',
				LetterM => 'M',
				LetterN => 'N',
				LetterO => 'O',
				LetterP => 'P',
				LetterQ => 'Q',
				LetterR => 'R',
				LetterS => 'S',
				LetterT => 'T',
				LetterU => 'U',
				LetterV => 'V',
				LetterW => 'W',
				LetterX => 'X',
				LetterY => 'Y',
				LetterZ => 'Z',
				Number0 => '0',
				Number1 => '1',
				Number2 => '2',
				Number3 => '3',
				Number4 => '4',
				Number5 => '5',
				Number6 => '6',
				Number7 => '7',
				Number8 => '8',
				Number9 => '9',
				Numpad0 => '<Numpad 0>',
				Numpad1 => '<Numpad 1>',
				Numpad2 => '<Numpad 2>',
				Numpad3 => '<Numpad 3>',
				Numpad4 => '<Numpad 4>',
				Numpad5 => '<Numpad 5>',
				Numpad6 => '<Numpad 6>',
				Numpad7 => '<Numpad 7>',
				Numpad8 => '<Numpad 8>',
				Numpad9 => '<Numpad 9>',
				F1 => '<F1>',
				F2 => '<F2>',
				F3 => '<F3>',
				F4 => '<F4>',
				F5 => '<F5>',
				F6 => '<F6>',
				F7 => '<F7>',
				F8 => '<F8>',
				F9 => '<F9>',
				F10 => '<F10>',
				F11 => '<F11>',
				F12 => '<F12>',
			];
		}
		return _keyNames;
	}

	public static function keyChars():Map<Key, Char> {
	    if (_keyChars == null) {
	        _keyChars = keyNames().copy();
	        inline function set(k,v) _keyChars[k] = v;
	        inline function unset(k) _keyChars.remove(k);

	        for (key in _keyChars.keys()) {
	            var v:String = _keyChars[key].toLowerCase();
	            if (v.length > 1) {
	                if (v.startsWith('<Numpad ')) {
	                    set(key, v.after('<Numpad').beforeLast('>').trim());
	                }
                    else {
                        unset( key );
                    }
	            }
	        }

	        set(Backspace, cc(8));
	        set(Tab, cc(9));
	        set(Delete, cc(226));
	        set(Space, cc(32));
	        set(Enter, cc(13));
	    }
	    return _keyChars;
	}

	public static function charKeys():Map<Char, Key> {
	    if (_charKeys == null) {
	        var kc = keyChars();
	        _charKeys = [for (key in kc.keys()) kc[key] => key];
	    }
	    return _charKeys;
	}

	/**
	  * Get a map of names to their keys
	  */
	public static function nameKeys():Map<String, Key> {
		if (_nameKeys == null) {
			_nameKeys = new Map();
			var kn = keyNames();
			for (key in kn.keys()) {
				_nameKeys[kn[ key ].toLowerCase()] = key;
			}
		}
		return _nameKeys;
	}

    static macro function cc(n: ExprOf<Int>):ExprOf<String> {
        switch ( n.expr ) {
            case EConst(CInt(Std.parseInt(_) => v)):
                return Context.parse('"\\u${v.hex(4)}"', Context.currentPos());

            case _:
                return macro String.fromCharCode(${n});
        }
        //return Context.parseInlineString('\\u' + n.toString().lpad('0', 4));
    }

/* === Static Fields === */

	/* a map of Keys to their names */
	private static var _keyNames:Null<Map<Key, String>> = null;
	private static var _nameKeys:Null<Map<String, Key>> = null;
	private static var _keyChars:Null<Map<Key, Char>> = null;
	private static var _charKeys:Null<Map<Char, Key>> = null;
}
