package xinf.ony.base;

import xinf.geom.Transform;
import xinf.geom.Translate;
import xinf.geom.Matrix;
import xinf.erno.Paint;
import xinf.geom.Types;

import xinf.ony.base.Gradient;
import xinf.traits.TraitDefinition;
import xinf.traits.FloatTrait;

class RadialGradient extends Gradient {
	
	static var TRAITS:Hash<TraitDefinition>;
	static function __init__() {
		TRAITS = new Hash<TraitDefinition>();
		for( trait in [
			new FloatTrait("cx",.5),
			new FloatTrait("cy",.5),
			new FloatTrait("r", .5),
			new FloatTrait("fx",.5),
			new FloatTrait("fy",.5),
		] ) { TRAITS.set( trait.name, trait ); }
	}

    public var cx(get_cx,set_cx):Float;
    function get_cx() :Float { return getTrait("cx",Float); }
    function set_cx( v:Float ) :Float { return setTrait("cx",v); }

    public var cy(get_cy,set_cy):Float;
    function get_cy() :Float { return getTrait("cy",Float); }
    function set_cy( v:Float ) :Float { return setTrait("cy",v); }

    public var r(get_r,set_r):Float;
    function get_r() :Float { return getTrait("r",Float); }
    function set_r( v:Float ) :Float { return setTrait("r",v); }

    public var fx(get_fx,set_fx):Float;
    function get_fx() :Float { return getTrait("fx",Float); }
    function set_fx( v:Float ) :Float { return setTrait("fx",v); }

    public var fy(get_fy,set_fy):Float;
    function get_fy() :Float { return getTrait("fy",Float); }
    function set_fy( v:Float ) :Float { return setTrait("fy",v); }

	override public function getPaint( target:Element ) :Paint {	
		var center = {x:cx,y:cy};
		var focus = {x:fx,y:fy};
		var pr = {x:r,y:0.}
		var _r = r;

		var transform:Transform = null;
		
		if( gradientTransform != null ) {
			transform = gradientTransform;
		}

		if( gradientUnits == ObjectBoundingBox ) {
			var bbox = target.getBoundingBox();
			var t = new Concatenate(
							new Scale( bbox.r-bbox.l, bbox.b-bbox.t ),
							new Translate( bbox.l, bbox.t ) ).getMatrix();
			if( transform!=null ) transform = new Concatenate( transform, t );
			else transform = t;
		}

		if( transform!=null ) {
			var m = new Matrix(transform.getMatrix());
			center = m.apply(center);
			focus = m.apply(focus);
			pr = m.apply(pr);
			_r = Math.sqrt( (pr.x*pr.x)+(pr.y*pr.y) );
		}

		return PRadialGradient(stops,center.x,center.y,_r,focus.x,focus.y,spreadMethod);
	}
	
}
