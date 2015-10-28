package tannus.internal;

import tannus.sys.Path;
import tannus.internal.BuildFlag;

enum BuildComponent {
	/* Set 'main' Class */
	BCMain(cref : String);

	/* Compile with a given target */
	BCTarget(t:String, dest:String);

	/* Add [dir] to the class-path */
	BCClassPath(dir : Path);

	/* Use a haxelib Library */
	BCLib(libname:String, version:Null<String>);

	/* -D [name] Compiler Flag */
	BCDef(name : String);

	/* Add a Names Resource */
	BCResource(f:Path, alias:Null<String>);

	/* Generate XML Type Data */
	BCXmlDocs(f : Path);

	/* Run the Specified Command after a successful compilation */
	BCCommand(cmd : String);

	/* Set the Compiler's Dead Code Policy */
	BCDeadCode(policy : DeadCodePolicy);

	/* Remap a package to another one */
	BCRemap(fpack:String, tpack:String);

	/* Call Some Macro Method before anything else is typed */
	BCMacro(macode : String);

	/* Adds any one of the many double-dashed '--*' Compiler flags */
	BCCompFlag(flag : BuildFlag);

	/* Add Debug Data to the Application */
	BCDebug;

	/* Turn on Verbose Mode */
	BCVerbose;

	/* Prompt on Error */
	BCPrompt;

	/* Start a new Build Operation */
	BCNext;

	/* Have the Compiler Actually Execute the Program */
	BCExec;
}

enum DeadCodePolicy {
	/* Do Not Eliminate Any Dead Code */
	None;

	/* Eliminate Dead Code From the STD */
	Std;

	/* Eliminate ALL Dead Code */
	All;
}
