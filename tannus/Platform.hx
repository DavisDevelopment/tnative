package tannus;

import tannus.internal.Target;

/**
  * Class of utility methods
  */
class Platform {
	/**
	  * Get the current target
	  */
	public static inline function currentTarget():Target {
		#if (js && node)
			return NodeJs;
		#elseif (js && !node)
			return Js;
		#elseif java
			return Java;
		#elseif (flash || as3)
			return Flash;
		#elseif cpp
			return Cpp;
		#elseif php
			return Php;
		#elseif neko
			return Neko;
		#elseif python
			return Python;
		#else
			throw 'Current target unsupported!';
		#end
	}
}
