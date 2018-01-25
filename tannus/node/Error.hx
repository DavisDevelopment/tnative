package tannus.node;

@:native('Error')
extern class Error {
    function new(message : String):Void;

    public var code : String;
    public var message : String;
    public var stack : String;

    public var syscall : Null<String>;
}

@:native('AssertionError')
extern class AssertionError extends Error {}

@:native('RangeError')
extern class RangeError extends Error {}

@:native('ReferenceError')
extern class ReferenceError extends Error {}

@:native('SyntaxError')
extern class SyntaxError extends Error {}

@:native('TypeError')
extern class TypeError extends Error {}

@:native('SystemError')
extern class SystemError extends Error {
    public var path: Null<String>;
    public var address: Null<String>;
    public var port: Int;
    
    public var type(get, never):SystemErrorType;
    private inline function get_type():SystemErrorType return this.code;
}

@:enum
abstract SystemErrorType (String) from String to String {
    var EACCESS = 'EACCESS';
    var EADDRINUSE = 'EADDRINUSE';
    var ECONNREFUSED = 'ECONNREFUSED';
    var ECONNRESET = 'ECONNRESET';
    var EEXIST = 'EEXIST';
    var EISDIR = 'EISDIR';
    var EMFILE = 'EMFILE';
    var ENOENT = 'ENOENT';
    var ENOTDIR = 'ENOTDIR';
    var ENOTEMPTY = 'ENOTEMPTY';
    var EPERM = 'EPERM';
    var EPIPE = 'EPIPE';
    var ETIMEDOUT = 'ETIMEDOUT';
}
