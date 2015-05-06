package tannus.graphics;

import tannus.graphics.Color;
import tannus.graphics.GraphicsBrush;
import tannus.graphics.LineCap;
import tannus.graphics.LineJoin;

/**
  * Enum of possible alterations to the current Path Styling
  */
enum PathStyleAlteration {
	//- Set the line-thickness to [width]
	LineWidth(width : Float);

	//- Set the line-color to [col]
	LineBrush(brush : GraphicsBrush);

	//- Set the fill-color to [brush]
	FillBrush(brush : GraphicsBrush);

	//- Set the line-cap to [cap]
	LineCap(cap : LineCap);

	//- Set the line-join to [jon]
	LineJoin(jon : LineJoin);
}
