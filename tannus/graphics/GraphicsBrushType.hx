package tannus.graphics;

import tannus.graphics.Color;
import tannus.graphics.LinearGradient;

/**
  * Enum of all objects and types which can be used as a Brush
  */
enum GraphicsBrushType {
	/* Solid Color Brush */
	BColor(col : Color);

	/* Linear Gradient Brush */
	BLinearGradient(grad : LinearGradient);
}
