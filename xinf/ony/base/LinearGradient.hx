/*  Copyright (c) the Xinf contributors.
    see http://xinf.org/copyright for license. */
	
package xinf.ony.base;

import xinf.geom.Transform;
import xinf.geom.Translate;
import xinf.geom.Matrix;
import xinf.geom.Types;
import xinf.type.Paint;
import xinf.ony.PaintProvider;
import xinf.ony.base.Gradient;
import xinf.traits.TraitDefinition;
import xinf.traits.FloatTrait;

class LinearGradient extends Gradient, implements PaintProvider {

	static var TRAITS = {
		x1:new FloatTrait(),
		y1:new FloatTrait(),
		x2:new FloatTrait(1),
		y2:new FloatTrait(1),
	};
	
    public var x1(get_x1,set_x1):Float;
    function get_x1() :Float { return getTrait("x1",Float); }
    function set_x1( v:Float ) :Float { return setTrait("x1",v); }

    public var y1(get_y1,set_y1):Float;
    function get_y1() :Float { return getTrait("y1",Float); }
    function set_y1( v:Float ) :Float { return setTrait("y1",v); }

    public var x2(get_x2,set_x2):Float;
    function get_x2() :Float { return getTrait("x2",Float); }
    function set_x2( v:Float ) :Float { return setTrait("x2",v); }

    public var y2(get_y2,set_y2):Float;
    function get_y2() :Float { return getTrait("y2",Float); }
    function set_y2( v:Float ) :Float { return setTrait("y2",v); }

	public function getPaint( target:Element ) :Paint {	
		var p1 = {x:x1,y:y1};
		var p2 = {x:x2,y:y2};

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
			p1 = m.apply(p1);
			p2 = m.apply(p2);
		}

		return PLinearGradient(stops,p1.x,p1.y,p2.x,p2.y,spreadMethod);
	}
	
}
