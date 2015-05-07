package tannus.concurrent.js;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class WorkerBuildTools {
	/**
	  * The build-macro for JS_Worker
	  */
	public static macro function linkToGutClass():Array<Field> {
		var fields = Context.getBuildFields();
		var klass = Context.parse(cref, Context.currentPos());
		
		var newField = {
			name: 'GutClass',
			doc: null,
			meta: [],
			access: [AStatic, APublic],
			kind: FVar(macro : Class<tannus.concurrent.js.JSWorker<Dynamic, Dynamic>>, klass),
			pos: Context.currentPos()
		};

		fields.push(newField);

		return fields;
	}

#if macro

	/* Assign [cref] with an Initialization Macro */
	public static function classReference(ref : String) {
		cref = ref;
	}

	/* Class Reference, Expressed as String */
	public static var cref : String;
#end
}
