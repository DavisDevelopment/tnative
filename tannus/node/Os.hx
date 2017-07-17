package tannus.node;

@:jsRequire('os')
extern class Os {
    public static function type():String;
    public static function totalmem():Int;
}
