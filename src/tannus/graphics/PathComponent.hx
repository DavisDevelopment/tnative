package tannus.graphics;

import tannus.geom.*;
import tannus.graphics.PathStyleAlteration;
import tannus.graphics.GraphicsPath;

/**
  * A Component of a GraphicsPath
  */
enum PathComponent {
	//- Make some alteration to the styling of future operations
	StyleAlteration(change : PathStyleAlteration);

	//- Move the 'cursor' to some other Point
	MoveTo(position : Point);

	//- Draw a line from the current Point, to some other one
	LineTo(position : Point);

	//- Draw an arc
	Arc(arc : Arc);

	//- Draw a Rectangle
	Rectangle(rect : Rectangle);

	//- Draw an Ellipse
	Ellipse(rect : Rectangle);

	//- Draw a Triangle
	Triangle(tri : Triangle);

	SubPath(path : GraphicsPath);

	//- Stroke the last Stack of operations
	StrokePath;

	FillPath;

	ClearPath;
}
