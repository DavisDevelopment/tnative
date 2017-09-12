package tannus.ds;

import Reflect.*;
import Type.*;
  
using StringTools;
using Slambda;

class ObjectPath {
  public var path : String;
  private var a : OPStep;
  public function new(path : String):Void {
    this.path = path;
    this.a = OPLexer.run(path);
  }
  public inline function get(c : Dynamic):Dynamic {
    return a.get(c);
  }
  public inline function set(c:Dynamic, v:Dynamic):Dynamic {
    return a.set(c, v);
  }
}

class OPLexer {
  private static inline var STEPCHARS:String = './';
  private var _step:Null<OPStep>;
  private var buf:String;
  public function new() {
    _step = null;
    buf = '';
  }
  public static inline function run(s:String):Null<OPStep> {
    return new OPLexer().lexString(s);
  }
  public function lexString(s : String):Null<OPStep> {
    buf = s;
    _step = null;
    consume();
    return _step;
  }
  private function consume():Void {
    var key:String = '', escaped:Bool = false;
		for (index in 0...buf.length) {
    	var c = buf.charAt(index);
    	if (STEPCHARS.indexOf(c) != -1) {
        step( key );
        key = '';
      }
    	else {
        key += c;
      }
    }
  	if (key.length > 0) {
      step(key);
    }
  }
	private function step(k:String):Void {
    var prev = _step;
    _step = {
      name: k,
      source: prev
    };
  }
}

@:structInit
class OPStep {
  public var name : String;
  @:optional
  public var source : OPStep;
  
  public inline function get(ctx : Dynamic):Dynamic {
    return getProperty((source!=null?source.get(ctx):ctx), name);
  }
  public inline function set(c:Dynamic, v:Dynamic):Dynamic {
    setProperty((source!=null?source.defaultGet(c,{}):c), name, v);
    return get( c );
  }
  public function defaultGet(c:Dynamic, dv:Dynamic):Dynamic {
    var res = get(c);
    if (res == null) {
      return set(c, dv);
    }
    else return res;
  }
}
