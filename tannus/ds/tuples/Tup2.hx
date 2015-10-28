package tannus.ds.tuples;

abstract Tup2<A, B> (Array<Dynamic>) {
    public inline function new(a:A, b:B):Void {
        this = (untyped [a,b]);
    }
    public var _0(get, set):A;
    private inline function get__0():A return (untyped this[0]);
    private inline function set__0(v : A):A return (untyped this[0] = v);
    
    public var _1(get, set):B;
    private inline function get__1():B return (untyped this[1]);
    private inline function set__1(v : B):B return (untyped this[1] = v);
    
}