package tannus.ds.tuples;

abstract Tup3<A, B, C> (Array<Dynamic>) {
    public inline function new(a:A, b:B, c:C):Void {
        this = (untyped [a,b,c]);
    }
    public var _0(get, set):A;
    private inline function get__0():A return (untyped this[0]);
    private inline function set__0(v : A):A return (untyped this[0] = v);
    
    public var _1(get, set):B;
    private inline function get__1():B return (untyped this[1]);
    private inline function set__1(v : B):B return (untyped this[1] = v);
    
    public var _2(get, set):C;
    private inline function get__2():C return (untyped this[2]);
    private inline function set__2(v : C):C return (untyped this[2] = v);
    
}