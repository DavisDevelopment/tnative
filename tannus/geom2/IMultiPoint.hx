package tannus.geom2;

interface IMultiPoint<T:Float> {
    function dimensionality():Int;
    function getCoordinate(i: Int):T;
    function distanceFromIMultiPoint(other: IMultiPoint<T>):Float;
    function getRawData():Array<T>;
}
