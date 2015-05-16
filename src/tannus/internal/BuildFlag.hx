package tannus.internal;

@:rtti
enum BuildFlag {
	/* Disable Code Optimization */
	@str('--no-opt')
	DontOptimize;

	/* Ignore All Calls to 'trace' */
	@str('--no-trace')
	DontTrace;

	/* Disables Inlining */
	@str('--no-inline')
	DontInline;
}
