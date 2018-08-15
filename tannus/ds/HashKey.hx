package tannus.ds;

class HashKey {
    static var counter:Int = 0;

    public static inline function next():Int {
        return counter++;
    }
}
