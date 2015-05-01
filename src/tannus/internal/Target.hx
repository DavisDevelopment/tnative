package tannus.internal;

/**
  * Enum of all TNative Targets
  */
@:enum
abstract Target (String) {
	var Js = 'js';
	var NodeJs = 'nodejs';
	var Java = 'java';
	var Python = 'python';
	var Flash = 'flash';
	var Php = 'php';
	var Cpp = 'cpp';
	var Neko = 'neko';
}
