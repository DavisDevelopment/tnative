package tannus.graphics;

import tannus.geom.*;
import tannus.graphics.PathStyleAlteration;

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

	//- Stroke the last Stack of operations
	StrokePath;
}
