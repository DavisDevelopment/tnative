package tannus.geom;

import tannus.geom.Point;
import tannus.geom.Line;
import tannus.geom.Vertices;
import tannus.geom.Shape;
import tannus.geom.HitMask;

import tannus.ds.IntRange;
import tannus.math.TMath in N;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class Path {
	/* Constructor Function */
	public function new():Void {
		commands = new Array();
	}

/* === Instance Methods === */

	/* add a vertex */
	public inline function vertex(x:Float, y:Float):Void {
		addPoint(new Point(x, y));
	}

	/* add a single vertex */
	public inline function addPoint(p : Point):Void {
		cmd(PCPoint( p ));
	}

	/* draw a line */
	public inline function line(start:Point, end:Point):Void {
		addLine(new Line(start, end));
	}

	public inline function addLine(line : Line):Void {
		cmd(PCLine( line ));
	}

	public inline function arc(center:Point, radius:Float, start_angle:Angle, end_angle:Angle, counterClockwise:Bool=false):Void {
		addArc(new Arc(center, radius, start_angle, end_angle, counterClockwise));
	}

	public inline function addArc(arc : Arc):Void {
		cmd(PCArc( arc ));
	}

	public inline function bezier(ctrl1:Point, ctrl2:Point, goal:Point):Void {
		addBezier(new Bezier(new Point(), ctrl1, ctrl2, goal));
	}

	public inline function addBezier(b : Bezier):Void {
		cmd(PCBezier( b ));
	}

	public function addPath(sub : Path):Void {
		if (sub != this) {
			cmd(PCSub( sub ));
		}
	}

	public inline function add(component : PathComponent):Void {
		component.addToPath( this );
	}

	/* add a command to the list */
	private inline function cmd(c : PathCommand):Void commands.push( c );

	/**
	  * Create and return a Vertices object from the given Command
	  */
	private function commandVertices(c:PathCommand, cursor:Null<Point>, ?precision:Int):Vertices {
		switch ( c ) {
			case PCPoint( point ):
				_verts.push( point );

			case PCLine( line ):
				return new Vertices([line.start, line.end]);

			case PCArc( arc ):
				if (cursor != null) {
					arc.pos.copyFrom( cursor );
				}
				return arc.calculateVertices( precision );

			case PCBezier( bezier ):
				if (cursor != null) {
					bezier.start.copyFrom( cursor );
				}
				return bezier.getPoints( precision );

			case PCSub( sub ):
				return sub.calculateVertices( precision );
		}

		return _verts;
	}

	/**
	  * compute the vertex-array described by [this] path
	  */
	public function calculateVertices(?precision : Int):Vertices {
		_verts = new Vertices();
		for (cmd in commands) {
			var curs:Null<Point> = _verts[_verts.length - 1];
			var cmd_verts = commandVertices(cmd, curs, precision);
			if (cmd_verts != _verts) {
				_verts.append( cmd_verts );
			}
		}
		return _verts;
	}

/* === Instance Fields === */
	
	private var _verts : Null<Vertices> = null;
	private var commands : Array<PathCommand>;
}

enum PathCommand {
	PCPoint(pt : Point);
	PCLine(line : Line);
	PCArc(arc : Arc);
	PCBezier(bez : Bezier);
	PCSub(path : Path);
}
