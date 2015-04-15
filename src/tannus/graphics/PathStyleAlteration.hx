package tannus.graphics;

import tannus.graphics.Color;

/**
  * Enum of possible alterations to the current Path Styling
  */
enum PathStyleAlteration {
	//- Set the line-thickness to [width]
	LineWidth(width : Float);

	//- Set the line-color to [col]
	LineColor(col : Color);
}
