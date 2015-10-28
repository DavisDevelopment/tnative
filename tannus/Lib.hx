package tnative;

#if python

typedef Lib = python.Lib;

#elseif cpp

typedef Lib = cpp.Lib;

#elseif cs

typedef Lib = cs.Lib;

#end
