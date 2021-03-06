/*  Copyright (c) the Xinf contributors.
	see http://xinf.org/copyright for license. */
	
package xinf.geom;

import xinf.geom.Types;

class SkewX implements Transform {
	var a:Float;
	
	public function new( a:Float ) {
		this.a = a;
	}
	
	public function getTranslation() {
		return { x:.0, y:.0 };
	}
	public function getScale() {
		return { x:.0, y:.0 };
	}
	public function getMatrix() {
		return { a:1., b:0., c:Math.tan(a), d:1., tx:0., ty:0. };
	}
	
	public function apply( p:TPoint ) :TPoint {
		return new Matrix( getMatrix() ).apply(p);
	}
	public function applyInverse( p:TPoint ) :TPoint {
		return new Matrix( getMatrix() ).applyInverse(p);
	}

	public function interpolateWith( p:Transform, f:Float ) :Transform {
		if( Std.is(p,Identity) ) return new SkewX(a*(1-f));
		if( !Std.is(p,SkewX) ) return this;
		var q:SkewX = cast(p);
		return( new SkewX( a + ((q.a-a)*f) ) );
	}

	public function distanceTo( p:Transform ) :Float {
		if( Std.is(p,Identity) || !Std.is(p,SkewX) ) 
			return Math.abs(a);
		var q:SkewX = cast(p);
		return( Math.abs(q.a-a) );
	}

	public function isIdentity() :Bool {
		return( a==0 );
	}
	
	public function add( t:Transform ) :Transform {
		if( t.isIdentity() ) return this;
		if( Std.is(t,SkewX) ) {
			return new SkewX( a+untyped t.a );
		}
		return new Concatenate(this,t);
	}

	public function toString() {
		return("skewX("+(a*TransformParser.R2D)+")");
	}
}
