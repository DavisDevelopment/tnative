package tannus.ds.impl;

enum AsyncIterToken<T> {
	TNext(value : T);
	TError(error : Dynamic);
	TEnd;
}
