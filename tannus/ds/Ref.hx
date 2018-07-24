package tannus.ds;

abstract Ref<T> (Array<T>) from Array<T> {
    public inline function new(value: T) {
        this = [value];
    }

    @:to
    public inline function get():T return this[0];
    public inline function set(v: T) {
        this[0] = v;
    }

    public var value(get, set): T;
    inline function get_value():T return get();
    inline function set_value(v: T):T return (this[0] = v);

    @:from
    public static inline function const<T>(v: T):Ref<T> return new Ref(v);
}
