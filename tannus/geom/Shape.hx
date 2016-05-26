package tannus.geom;

import tannus.geom.Vertices;

/* Interface which describes a geometric model which has vertices */
interface Shape {
	function getVertices(?precision : Int):Vertices;
}
