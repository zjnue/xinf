/*  Copyright (c) the Xinf contributors.
	see http://xinf.org/copyright for license. */
	
package xinf.erno.js;

import xinf.erno.Renderer;
import xinf.erno.ObjectModelRenderer;
import xinf.erno.ImageData;
import xinf.erno.TextFormat;

import js.Dom;

#if !no_canvas
import xinf.erno.Paint;
import xinf.erno.Constants;
import js.Lib;
import js.DomCanvas;
import js.CanvasRenderingContext2D;
#end

typedef Primitive = js.HtmlDom

class JSRenderer extends ObjectModelRenderer {
	#if !no_canvas
	var last		: { x:Float, y:Float };
	var first		: { x:Float, y:Float };
	
	public static inline var CANVAS_WIDTH:Int = 1600;
	public static inline var CANVAS_HEIGHT:Int = 1600;
	public static inline var CANVAS_OFFSET_X:Int = - Std.int(CANVAS_WIDTH / 4);
	public static inline var CANVAS_OFFSET_Y:Int = - Std.int(CANVAS_HEIGHT / 4);
	
	public static inline function getCanvas( p : Primitive ) : DomCanvas {
		var canvas : DomCanvas = cast p.getElementsByTagName("canvas")[0];
		if( canvas == null ) {
			canvas = cast Lib.document.createElement("canvas");
			p.appendChild(canvas);
			
			// tmp hack
			canvas.width = CANVAS_WIDTH;
			canvas.height = CANVAS_HEIGHT;
			
			var ctx = canvas.getContext("2d");
			ctx.mouseChildren = false;
			ctx.mouseEnabled = false;
		}
		return canvas;
	}
	
	public static inline function getCtx( p : Primitive ) : CanvasRenderingContext2D {
		return getCanvas(p).getContext("2d");
	}

	override public function resizeGraphicsContainer( w:Float, h:Float ) :Void {
		var canvas : DomCanvas = cast current.getElementsByTagName("canvas")[0];
		var newCanvas : DomCanvas = cast Lib.document.createElement("canvas");
		newCanvas.width = Math.round(w);
		newCanvas.height = Math.round(h);
		if( canvas == null ) {
			current.appendChild(canvas);
		} else {
			current.insertBefore(newCanvas, canvas);
			current.removeChild(canvas);
		}
	}

	override function clear( id:Int ) : Void {
		var p = lookup(id);
		var canvas = getCanvas(p);
		canvas.width = canvas.width;
	}
	#end
	
	override public function createPrimitive(id:Int) :Primitive {
		// create new object
		var o = js.Lib.document.createElement("div");
		o.style.position="absolute";
		untyped o.xinfId = id;
		return o;
	}
	
	override public function clearPrimitive( p:Primitive ) {
		p.innerHTML="";
		
		#if !no_canvas
		// FIXME
		var canvas = getCanvas(p);
		canvas.width = canvas.width; // curious, but this is documented as way to refresh canvas..
		p.appendChild(canvas);
		#end
	}
	
	override public function attachPrimitive( parent:Primitive, child:Primitive ) :Void {
		if( child.parentNode!=null ) {
			child.parentNode.removeChild(child);
		}
		parent.appendChild( child );
	}
	
	override public function setPrimitiveTransform( p:Primitive, x:Float, y:Float, a:Float, b:Float, c:Float, d:Float ) :Void {
		// FIXME (maybe): regards only translation
		p.style.left = ""+Math.round(x)+"px";
		p.style.top = ""+Math.round(y)+"px";
	}

	override public function setPrimitiveTranslation( p:Primitive, x:Float, y:Float ) :Void {
		p.style.left = ""+Math.round(x)+"px";
		p.style.top = ""+Math.round(y)+"px";
	}

	override public function clipRect( w:Float, h:Float ) {
		current.style.overflow = "hidden";
		#if !no_canvas
		// FIXME - offset overflow hack messes up lower bounds clipping...
		current.style.width = ""+Math.max(0,Math.round(w-CANVAS_OFFSET_X))+"px";
		current.style.height = ""+Math.max(0,Math.round(h-CANVAS_OFFSET_Y))+"px";
		#else
		current.style.width = ""+Math.max(0,Math.round(w))+"px";
		current.style.height = ""+Math.max(0,Math.round(h))+"px";
		#end
	}
	
	override public function rect( x:Float, y:Float, w:Float, h:Float ) {
		#if !no_canvas
		x -= CANVAS_OFFSET_X;
		y -= CANVAS_OFFSET_Y;
		
		var ctx = getCtx(current);
		applyStroke(ctx,pen.stroke,pen.width,pen.caps,pen.join,pen.miterLimit);
		applyFill(ctx,pen.fill);
		ctx.rect(x,y,w,h);
		if( pen.stroke != null )
			ctx.stroke();
		ctx.fill();
		#else
		var r = js.Lib.document.createElement("div");
		r.style.position="absolute";
		r.style.left = ""+Math.round(x)+"px";
		r.style.top = ""+Math.round(y)+"px";
		if( pen.fill != null ) {
			switch( pen.fill ) {
				case SolidColor(red,g,b,a):
					r.style.background = colorToRGBString(red,g,b);
					untyped r.style.opacity = a;
				default:
					untyped r.style.opacity = 0;
			}
		}
		if( pen.width > 0 && pen.stroke != null ) {
			switch( pen.stroke ) {
				case SolidColor(red,g,b,a):
					// FIXME: a
					r.style.border = ""+pen.width+"px solid "+colorToRGBString(red,g,b);
					r.style.width = ""+Math.round(w+1-(pen.width*2))+"px";
					r.style.height = ""+Math.round(h+1-(pen.width*2))+"px";
				default:
					r.style.border = 0;
			}
		}
		
		r.style.width = ""+Math.round(w)+"px";
		r.style.height = ""+Math.round(h)+"px";
		current.appendChild( r );
		#end
	}

	override public function roundedRect( x:Float, y:Float, w:Float, h:Float, rx:Float, ry:Float ) {
		#if !no_canvas
		x -= CANVAS_OFFSET_X;
		y -= CANVAS_OFFSET_Y;
		
		var ctx = getCtx(current);
		applyStroke(ctx,pen.stroke,pen.width,pen.caps,pen.join,pen.miterLimit);
		applyFill(ctx,pen.fill);
		
		ctx.moveTo(x + rx, y);
		ctx.lineTo(x + w - rx, y);
		ctx.quadraticCurveTo(x + w, y, x + w, y + ry);
		ctx.lineTo(x + w, y + h - ry);
		ctx.quadraticCurveTo(x + w, y + h, x + w - rx, y + h);
		ctx.lineTo(x + rx, y + h);
		ctx.quadraticCurveTo(x, y + h, x, y + h - ry);
		ctx.lineTo(x, y + ry);
		ctx.quadraticCurveTo(x, y, x + rx, y);
		
		if( pen.stroke != null )
			ctx.stroke();
		ctx.fill();
		#else
		rect( x, y, w, h );
		#end
	}
	
	override public function ellipse( x:Float, y:Float, rx:Float, ry:Float ) {
		#if !no_canvas
		x -= CANVAS_OFFSET_X;
		y -= CANVAS_OFFSET_Y;
		
		var ctx = getCtx(current);
		applyStroke(ctx,pen.stroke,pen.width,pen.caps,pen.join,pen.miterLimit);
		applyFill(ctx,pen.fill);
		
		x = x-rx;
		y = y-ry;
		var w = rx*2;
		var h = ry*2;
		
		var k = 0.5522848;
		var ox = (w / 2) * k;
		var oy = (h / 2) * k;
		var xe = x + w;
		var ye = y + h;
		var xm = x + w / 2;
		var ym = y + h / 2;
			
		ctx.moveTo( x, ym );
		ctx.bezierCurveTo( x, ym-oy, xm-ox, y, xm, y );
		ctx.bezierCurveTo( xm+ox, y, xe, ym-oy, xe, ym );
		ctx.bezierCurveTo( xe, ym+oy, xm+ox, ye, xm, ye );
		ctx.bezierCurveTo( xm-ox, ye, x, ym+oy, x, ym );
		
		if( pen.stroke != null )
			ctx.stroke();
		ctx.fill();
		#else
		rect( x-rx, y-ry, rx*2, ry*2 );
		#end
	}

	override public function text( x:Float, y:Float, text:String, format:TextFormat ) {
		#if !no_canvas
		x -= CANVAS_OFFSET_X;
		y -= CANVAS_OFFSET_Y;
		#end
		
		var r = js.Lib.document.createElement("div");
		r.style.position="absolute";
		r.style.whiteSpace="nowrap";
		r.style.cursor="default";
		if( x!=null ) r.style.left = ""+Math.round(x)+"px";
		if( y!=null ) r.style.top = ""+Math.round(y)+"px";
		
		if( pen.fill != null ) {
			switch( pen.fill ) {
				case SolidColor(red,g,b,a):
					r.style.color = colorToRGBString(red,g,b);
					untyped r.style.opacity = a;
				default:
					untyped r.style.opacity = 0;
			}
		}
		/*
		if( pen.fontFace != null ) r.style.fontFamily = if( pen.fontFace=="_sans" ) "Bitstream Vera Sans, Arial, sans-serif" else pen.fontFace;pen.fontFace;
		if( pen.fontItalic ) r.style.fontStyle = "italic";
		if( pen.fontBold ) r.style.fontWeight = "bold";
		if( pen.fontSize != null ) r.style.fontSize = ""+pen.fontSize+"px";
		*/
		format.apply(r);
		r.innerHTML=text.split("\n").join("<br/>");
		current.appendChild(r);
	}
	
	override public function image( img:ImageData, inRegion:{ x:Float, y:Float, w:Float, h:Float }, outRegion:{ x:Float, y:Float, w:Float, h:Float } ) {
		var wf = outRegion.w/inRegion.w;
		var hf = outRegion.h/inRegion.h;
		
		#if !no_canvas
		outRegion.x -= CANVAS_OFFSET_X;
		outRegion.y -= CANVAS_OFFSET_Y;
		#end

		var r:Image = cast(js.Lib.document.createElement("img"));
		r.src = img.url;
		r.style.position = "absolute";
		r.style.left = ""+Math.round(-inRegion.x*wf)+"px";
		r.style.top = ""+Math.round(-inRegion.y*hf)+"px";
		r.style.width = ""+Math.round( img.width * wf )+"px";
		r.style.height = ""+Math.round( img.height * hf )+"px";
		
		var wrap = js.Lib.document.createElement("div");
		wrap.style.position = "absolute";
		wrap.style.overflow = "hidden";
		wrap.style.left = ""+Math.round(outRegion.x)+"px";
		wrap.style.top = ""+Math.round(outRegion.y)+"px";
		wrap.style.width = ""+Math.round(outRegion.w)+"px";
		wrap.style.height = ""+Math.round(outRegion.h)+"px";
		
		wrap.appendChild(r);
		
		if( pen.fill!=null ) 
			switch( pen.fill ) {
				case SolidColor(red,g,b,a):
					untyped r.style.opacity = a;
				default:
			}
			
		current.appendChild(wrap);
	}
	
	override public function native( o:NativeObject ) {
		current.appendChild(o);
	}
	
	#if !no_canvas
	public static function applyFill( ctx:CanvasRenderingContext2D, fill:Paint ) {
		switch( fill ) {
			case None:
				// do nothing
				ctx.fillStyle = colorToRGBAString(0,0,0,0);
		
			case SolidColor(r,g,b,a):
				if( a>0 ) {
					ctx.fillStyle = colorToRGBAString(r,g,b,a);
				} else
					ctx.fillStyle = colorToRGBAString(0,0,0,0);
			/*	
			case PLinearGradient( stops, x1, y1, x2, y2, transform, spread ):
				var gr = flashGradient( stops, spread );
				var matrix = flashLinearGradient( x1,y1,x2,y2 );
				if( transform != null ) {
					var m = transform.getMatrix();
					matrix.concat( new flash.geom.Matrix( m.a,m.b,m.c,m.d,m.tx,m.ty ) );
				}
				gfx.beginGradientFill( GradientType.LINEAR, gr.colors, gr.alphas, gr.ratios, matrix, gr.spread, InterpolationMethod.RGB );
				
			case PRadialGradient( stops, cx, cy, r, fx, fy, transform, spread ):
				var gr = flashGradient( stops, spread );
				var matrix = flashRadialGradient( cx,cy,r,fx,fy );
				if( transform != null ) {
					var m = transform.getMatrix();
					matrix.concat( new flash.geom.Matrix( m.a,m.b,m.c,m.d,m.tx,m.ty ) );
				}
				var f = { x:fx-cx, y:fy-cy };
				var focalRatio = Math.sqrt( (f.x*f.x)+(f.y*f.y) )/r;
				gfx.beginGradientFill( GradientType.RADIAL, gr.colors, gr.alphas, gr.ratios, matrix, gr.spread, InterpolationMethod.RGB, focalRatio );
				*/
			default:
				throw("fill "+fill+" not implemented");
		}
	}
	
	public static function applyStroke( ctx:CanvasRenderingContext2D, stroke:Paint, width:Float, ?_caps:Int=0, ?_join:Int=0, ?miterLimit:Float=1 ) {
		if( stroke == null )
			return;
		
		// TODO: define CapsStyle class
		ctx.lineCap = switch( _caps ) {
			case Constants.CAPS_BUTT: "butt";
			case Constants.CAPS_ROUND: "round";
			case Constants.CAPS_SQUARE: "square";
			default: "butt";
		}
		
		// TODO: define JointStyle class
		ctx.lineJoin = switch( _join ) {
			case Constants.JOIN_MITER: "miter";
			case Constants.JOIN_ROUND: "round";
			case Constants.JOIN_BEVEL: "bevel";
			default: "miter";
		}
		
		ctx.miterLimit = miterLimit;
		ctx.lineWidth = width;
		
		switch( stroke ) {
			
			case None:
				trace("None");
			case SolidColor(r,g,b,a):
				ctx.strokeStyle = colorToRGBAString(r,g,b,a);
				/*
			case PLinearGradient( stops, x1, y1, x2, y2, transform, spread ):
				var gr = flashGradient( stops, spread );
				var matrix = flashLinearGradient( x1,y1,x2,y2 );
				if( transform != null ) {
					var m = transform.getMatrix();
					matrix.concat( new flash.geom.Matrix( m.a,m.b,m.c,m.d,m.tx,m.ty ) );
				}
				gfx.lineStyle( width, 0, 1., false, LineScaleMode.NORMAL, caps, join, miterLimit );
				gfx.lineGradientStyle( GradientType.LINEAR, gr.colors, gr.alphas, gr.ratios, matrix, gr.spread, InterpolationMethod.RGB );
			case PRadialGradient( stops, cx, cy, r, fx, fy, transform, spread ):
				var gr = flashGradient( stops, spread );
				var matrix = flashRadialGradient( cx,cy,r,fx,fy );
				if( transform != null ) {
					var m = transform.getMatrix();
					matrix.concat( new flash.geom.Matrix( m.a,m.b,m.c,m.d,m.tx,m.ty ) );
				}
				var f = { x:fx-cx, y:fy-cy };
				var focalRatio = Math.sqrt( (f.x*f.x)+(f.y*f.y) )/r;
				gfx.lineGradientStyle( GradientType.RADIAL, gr.colors, gr.alphas, gr.ratios, matrix, gr.spread, InterpolationMethod.RGB, focalRatio );
				*/
			default:
				throw("stroke "+stroke+" not implemented");
		}
	}
	
	override public function startShape() {
		clearPrimitive(current);
		var ctx = getCtx(current);
		applyFill(ctx,pen.fill);
	}
	
	override public function endShape() {
		var ctx = getCtx(current);
		ctx.fill();
	}
	
	override public function startPath( x:Float, y:Float) {
		#if !no_canvas
		x -= CANVAS_OFFSET_X;
		y -= CANVAS_OFFSET_Y;
		#end
		var ctx = getCtx(current);
		applyStroke(ctx,pen.stroke,pen.width,pen.caps,pen.join,pen.miterLimit);
		ctx.moveTo(x, y);
		last = { x:x, y:y };
		first = { x:x, y:y };
	}
	
	override public function endPath() {
		var ctx = getCtx(current);
		ctx.stroke();
		ctx.strokeStyle = colorToRGBString(0,0,0);
	}
	
	override public function close() {
		// FIXME
	}
	
	override public function lineTo( x:Float, y:Float ) {
		#if !no_canvas
		x -= CANVAS_OFFSET_X;
		y -= CANVAS_OFFSET_Y;
		#end
		var ctx = getCtx(current);
		ctx.lineTo(x,y);
		last = { x:x, y:y };
	}
	
	override public function quadraticTo( x1:Float, y1:Float, x:Float, y:Float ) {
		#if !no_canvas
		x -= CANVAS_OFFSET_X; x1 -= CANVAS_OFFSET_X;
		y -= CANVAS_OFFSET_Y; y1 -= CANVAS_OFFSET_Y;
		#end
		var ctx = getCtx(current);
		ctx.quadraticCurveTo( x1,y1,x,y );
		last = { x:x, y:y };
	}
	
	override public function cubicTo( x1:Float, y1:Float, x2:Float, y2:Float, x:Float, y:Float ) {
		#if !no_canvas
		x -= CANVAS_OFFSET_X; x1 -= CANVAS_OFFSET_X; x2 -= CANVAS_OFFSET_X;
		y -= CANVAS_OFFSET_Y; y1 -= CANVAS_OFFSET_Y; y2 -= CANVAS_OFFSET_Y;
		#end
		var ctx = getCtx(current);
		ctx.bezierCurveTo( x1,y1,x2,y2,x,y );
		last = { x:x, y:y };
	}
	#end
	
	public static function colorToRGBString( r:Float, g:Float, b:Float ) :String {
		return "rgb("+Math.round(r*0xff)+","+Math.round(g*0xff)+","+Math.round(b*0xff)+")";	
	}
	
	#if !no_canvas
	public static function colorToRGBAString( r:Float, g:Float, b:Float, a:Float ) :String {
		return "rgba("+Math.round(r*0xff)+","+Math.round(g*0xff)+","+Math.round(b*0xff)+","+a+")";
	}
	#end
}
