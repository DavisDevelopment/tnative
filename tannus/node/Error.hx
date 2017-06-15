package tannus.node;

@:native('Error')
extern class Error {
    function new(message : String):Void;

    public var code : String;
    public var message : String;
    public var stack : String;

    public var syscall : Null<String>;
}
