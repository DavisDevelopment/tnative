package tannus.utils;

#if js
	typedef ErrorImpl = tannus.utils.JavaScriptError;
#elseif python
	typedef ErrorImpl = tannus.utils.PythonError;
#else
	typedef ErrorImpl = tannus.utils.BaseError;
#end
