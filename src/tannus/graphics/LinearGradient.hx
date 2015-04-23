package tannus.graphics;

import tannus.math.TMath;
import tannus.math.Percent;

import tannus.geom.Point;

import tannus.graphics.Color;

import tannus.ds.Maybe;

/**
  * Class to represent a linear color gradient
  */
class LinearGradient {
	/* Constructor Function */
	public function new(s:Point, e:Point):Void {
		start = s;
		end = e;

		stops = new Array();
	}

/* === Instance Methods === */

	/**
	  * Adds a Color Stop to [this] Gradient
	  */
	public function addColorStop(offset:Percent, color:Color):Void {
		//- Ensure that [offset] is not less than 0
		if (offset.value < 0) {
			error('Cannot create a ColorStop with an offset less than 0!');
		}

		//- Ensure that no ColorStop has already been added with an offset of [offset]
		for (stop in stops) {
			if (stop.offset.value == offset.value) {
				error('ColorStop with an offset of $offset has already been added to this LinearGradient!');
			}
		}

		stops.push(new ColorStop(offset, color));
	}

	/**
	  * Calculates the Color of [this] Gradient at the given percentage of completion
	  */
	public function getColor(prog : Percent):Color {
		var fromStop:ColorStop = getFirstColorStopLess( prog ).orDie('GradientError: Gradient does not define a starting position!');
		var toStop:ColorStop = (getFirstColorStopGreater( prog ) || fromStop);

		var fromColor:Color = fromStop.color;
		var toColor:Color = toStop.color;

		if (fromColor == toColor) {
			return fromColor;
		}

		else {
			var total:Percent = (toStop.offset.value - fromStop.offset.value);
			var weight:Percent = (prog.of( total.value ));

			var color:Color = fromColor.mix(toColor, weight);
			return color;
		}
	}

	/**
	  * Get the first ColorStop with an offset less than, or equal to [offset]
	  */
	private function getFirstColorStopLess(offset : Percent):Maybe<ColorStop> {
		for (stop in stops) {
			if (stop.offset.value <= offset.value) {
				return stop;
			}
		}

		return null;
	}

	/**
	  * Get the first ColorStop with an offset greater than [offset]
	  */
	private function getFirstColorStopGreater(offset : Percent):Maybe<ColorStop> {
		for (stop in stops) {
			if (stop.offset.value > offset.value) {
				return stop;
			}
		}

		return null;
	}

/* === Static Utility Methods === */

	/**
	  * Reports a Gradient-Related Error
	  */
	private static inline function error(msg : String):Void {
		throw 'GradientError: $msg';
	}

/* === Instance Fields === */

	public var start:Point;
	public var end:Point;

	public var stops:Array<ColorStop>;
}

/**
  * Shorthand typedef
  */
private typedef ColorStop = tannus.graphics.GraphicsColorStop;
