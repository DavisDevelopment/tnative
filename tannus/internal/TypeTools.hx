package tannus.internal;

import Type;

/**
  * === Class for Determining the Type of an Object, or other various information regarding Type ===
  */
@:expose('TypeTools')
class TypeTools {
/* === Class-Level Methods === *

   	
   	/**
   	  * Determine the type of argument [o]
   	  */
   	public static function typename(o : Dynamic):String {
		var valtype:ValueType = Type.typeof( o );
		switch (valtype) {
			/* If [o] is a Boolean Value */
			case ValueType.TBool: 
				return 'Bool';

			/* If [o] is a Numeric Value */
			case ValueType.TFloat, ValueType.TInt:
				return 'Number';

			/* If [o] is Null */
			case ValueType.TNull: 
				return 'Null';

			/* If [o] is a Function */
			case ValueType.TFunction: 
				return 'Function';

			/* If [o]'s Type could not be determined */
			case ValueType.TUnknown: 
				return 'Unknown';

			/* If [o] is an instance of [klass] */
			case ValueType.TClass( klass ):
				try {
					//- The name of the class that created [o]
					var name:String = Type.getClassName( klass );
					return name;
				} catch (err : String) {
					return 'Unknown';
				}

			/* If [o] is an EnumValue of [enumer] */
			case ValueType.TEnum( enumer ):
				//- The name of [enumer]
				var enumName:String = Type.getEnumName(enumer);

				//- The names of all constructs of [enumer]
				var valueNames:Array<String> = Type.getEnumConstructs(enumer);

				//- The index of the construct that created [o]
				var index:Int = Type.enumIndex(cast o);

				//- The String which will be returned
				var results:String = '$enumName.${valueNames[index]}';

				return results;

				//- The arguments passed to the construct which created [o]
				//var args:Array<Dynamic> = Type.enumParameters(cast o);

				//- If there were no arguments
				//if (args.length == 0) {
				//	return results;
				//} 
				
				//- If there *were* arguments
				//else {
					//- The String representations of all of those arguments
					//var reps:Array<String> = [for (x in args) Std.string(x)];
					//results += ('(' + reps.join(', ') + ')');
					//return results;
				//}
			
			/* If [o] is a class, enum, etc */
			case ValueType.TObject:
				/**
				  * Attempts to get the class-name of [o],
				  * if [o] is a class, this will give a result, which we will return,
				  * however if it is not, this will throw an error, which we will catch
				  */
				try {
					var name:String = Type.getClassName(cast o);

					//- If we do, in fact, get a result, return it
					if (name != null) {
						return 'Class<$name>';
					}

					//- If we just get [null]
					else {
						//- throw an error so we'll still reach the next block
						throw 'failed!';
					}
				}

				//- If the "try" block fails
				catch (err : String) {
					/**
					  * Attempt to get the enum-name of [o]
					  * if [o] is an enum, this will yield a result, which we will return
					  * however if it is not, this will throw an error, which we will return
					  */
					try {
						var name:String = Type.getEnumName(cast o);
						
						//- if [name] isn't null, return [name]
						if (name != null) {
							return 'Enum<$name>';
						}

						//- if we just got [null]
						else {
							//- throw an error, so we'll still reach the next block
							throw 'failed!';
						}
					}

					//- this will execute if [o] isn't an enum
					catch (err : Dynamic) {
						return 'Unknown';
					}
				}
		}
	}

	/**
	  * Get a list of the names of [klass] and all parent-classes of [klass]
	  */
	public static function getClassHierarchy(klass : Class<Dynamic>):Array<String> {
		var kl:Class<Dynamic> = klass;
		var hierarchy:Array<String> = new Array();
		var name:String = Type.getClassName(kl);
		hierarchy.push( name );
		while (true) {
			try {
				kl = Type.getSuperClass( kl );
				name = Type.getClassName( kl );
				hierarchy.push( name );
			} catch (err : Dynamic) {
				break;
			}
		}

		return hierarchy;
	}

	/**
	  * Get the type-hierarchy of the type of [o]
	  */
	public static function hierarchy(o : Dynamic):Array<String> {
		if (Reflect.isObject( o )) {
			var klass:Null<Class<Dynamic>> = Type.getClass( o );
			if (klass != null) {
				return getClassHierarchy( klass );
			}
		}
		
		return [];
	}
}
