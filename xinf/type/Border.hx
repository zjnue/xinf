/*  Copyright (c) the Xinf contributors.
    see http://xinf.org/copyright for license. */
	
package xinf.type;

class Border {
	public var l:Float;
	public var t:Float;
	public var r:Float;
	public var b:Float;
	
	public function new( l:Float, t:Float, r:Float, b:Float ) :Void {
		this.l=l; this.t=t; this.r=r; this.b=b;
	}
}