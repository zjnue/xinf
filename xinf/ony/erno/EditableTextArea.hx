/*  Copyright (c) the Xinf contributors.
	see http://xinf.org/copyright for license. */
	
package xinf.ony.erno;

import xinf.erno.Renderer;

#if neko

import xinf.event.KeyboardEvent;
import xinf.event.MouseEvent;
import xinf.event.UIEvent;
import xinf.geom.Types;
import xinf.erno.Paint;
import xinf.ony.type.Editability;
import xinf.ony.Root;
import xinf.event.SimpleEvent;

class EditableTextArea extends TextArea {

	var sel :{ from:Int, to:Int };
	var keyboardL :Dynamic;
	var mouseL :Dynamic;

	override function set_width( v:Float ) :Float { dirty=true; return super.set_width(v); }
	override function set_height( v:Float ) :Float { dirty=true; return super.set_height(v); }

	public function new( ?traits:Dynamic ) {
		super(traits);
		sel = { from:0, to:0 };
		
		addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
	}

	override public function focus( ?focus:Bool ) {
		super.focus();
		if( focus ) {
			if( keyboardL==null ) 
				keyboardL = Root.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		} else {
			if( keyboardL!=null ) {
				Root.removeEventListener( KeyboardEvent.KEY_DOWN, keyboardL );
				keyboardL=null;
			}
		}
	}

	public function onKeyDown( e:KeyboardEvent ) :Void {
		if( editable==Editability.None ) return;
		if( !e.altMod && e.code >= 32 && e.code < 127 ) {
			switch( e.code ) {
				case 127: // Del
					if( sel.from==sel.to ) {
						sel.to=sel.from+1;
					}
					replaceSelection("");
				default:
					replaceSelection( String.fromCharCode(e.code) );
			}
		} else {
			switch( e.key ) {
				case "\n":
					postEvent( new UIEvent( UIEvent.ACTIVATE ));
					//trace("ENTER");
					//replaceSelection( "\n" );
				case "backspace":
					if( sel.to==sel.from ) sel.from=sel.to-1;
					replaceSelection("");
				case "delete":
					if( sel.to==sel.from ) sel.to=sel.from+1;
					replaceSelection("");
				case "left":
					moveCursor( 
						if( e.ctrlMod )
							findLeftWordBoundary()
						else 
							sel.to-1
						, e.shiftMod );
				case "right":
					moveCursor( 
						if( e.ctrlMod )
							findRightWordBoundary()
						else 
							sel.to+1
						, e.shiftMod );
				case "up":
					var p = getPositionOfText( sel.to );
					p.y-=lineIncrement*.5;
					moveCursor( getTextPositionAt(p), e.shiftMod );
				case "down":
					var p = getPositionOfText( sel.to );
					p.y+=lineIncrement*1.5;
					moveCursor( getTextPositionAt(p), e.shiftMod );
				case "home":
					moveCursor( 0, e.shiftMod );
				case "end":
					moveCursor( text.length, e.shiftMod );
				case "a":
					selectAll();
				default:
					replaceSelection( e.key );
//					trace("unhandled control key: "+e.key+" code "+e.code);
			}
		}
		redraw();
	}

	public function onMouseDown( e:MouseEvent ) :Void {
		var p = globalToLocal( {x:1.*e.x, y:1.*e.y } );
		p.x-=x; p.y-=y;
		var ofs = getTextPositionAt(p);
		
		if( e.shiftMod ) {
			sel.to = ofs;
			redraw();
		} else {
			moveCursor( ofs, false ); // FIXME e.shiftMod );
			{
				var movL:Dynamic=null;
				var upL:Dynamic=null;
				movL = Root.addEventListener( MouseEvent.MOUSE_MOVE, dragSelect );
				upL = Root.addEventListener( MouseEvent.MOUSE_UP, function(e) {
					Root.removeEventListener( MouseEvent.MOUSE_MOVE, movL );
					Root.removeEventListener( MouseEvent.MOUSE_UP, upL );
				});
			}
		}
	}
	
	function dragSelect( e:MouseEvent ) {
		var p = globalToLocal( {x:1.*e.x, y:1.*e.y } );
		p.x-=x; p.y-=y;
		var ofs = getTextPositionAt(p);
		sel.to = ofs;
		redraw();
	}

	public function selectAll() :Void {
		sel.from=0; sel.to=text.length;
		redraw();
	}
	
	public function moveCursor( to:Int, extendSelection:Bool ) :Void {
		if( text==null ) return;
		sel.to=to; 
		if( sel.to < 0 ) sel.to=0;
		else if( sel.to > text.length ) sel.to=text.length;
		if( !extendSelection ) sel.from=sel.to;
		redraw();
	}

	public function replaceSelection( str:String ) :Void {
		if( sel.from > sel.to ) {
			var t = sel.from;
			sel.from = sel.to;
			sel.to = t;
		}
		if( sel.from<0 ) sel.from=0;
		if( sel.to<sel.from ) sel.to=sel.from;

		var t = text;
		if( t==null ) text=str else {
			var u = t.substr(0,sel.from);
			u += str;
			u += t.substr(sel.to, t.length-sel.to);
			text=u;
		}
		sel.to=sel.from=sel.from+str.length;
		
		postEvent( new SimpleEvent( SimpleEvent.CHANGED ) );
	}

	public function findLeftWordBoundary() :Int {
		var p:Int=sel.to-1;
		while( text.charCodeAt(p)==32 ) p--;
		while( p>=0 && p<text.length && text.charCodeAt(p) != 32 ) {
			p-=1;
		}
		p++;
		return p;
	}
	
	public function findRightWordBoundary() :Int {
		var p:Int=sel.to;
		while( text.charCodeAt(p)==32 ) p++;
		while( p>=0 && p<text.length && text.charCodeAt(p) != 32 ) {
			p++;
		}
		return p;
	}

	function getPositionOfText( pos:Int ) :TPoint {
		if( lines==null || lines.length==0 ) return { x:0., y:0. };
		
		if( dirty ) {
			updateContents( text );
		}
		
		var line:Int=1;
		while( line<lines.length && lines[line].offset<=pos ) {
			line++;
		}
		line--;
		var l = lines[line];
		pos-=l.offset;
		var x = format.textSize( l.text.substr(0,pos) ).x;
		var p = { x:x, y:line*lineIncrement };
		
		return( p );
	}
	
	function getTextPositionAt( pos:TPoint ) :Int {
		if( lines==null ) return 0;
		var l = Math.floor( Math.min( lines.length, pos.y/lineIncrement ) );
		if( l<0 ) return( 0 );
		if( l>=lines.length ) return( text.length );

		var c = format.font.getCache( format.size );
		
		var offset=0;
		var line = lines[l];
		var x=0.;
		var text = line.text;
		var g=null;
		while( x<pos.x && offset<text.length ) {
			g = c.get( text.charCodeAt(offset) );
			x += g.advance;
			offset++;
		}
		if( g!=null && x-(g.advance/2) > pos.x ) offset--;
//		if( offset==text.length ) offset-=1;
		
		offset += lines[l].offset;
		
		return offset;
	}

	override public function drawContents( g:Renderer ) :Void {
		super.drawContents(g);

		g.setStroke( Paint.None, 0 );
	
	// assure we receive mouse events:
		g.setFill( SolidColor(0,0,0,0) );
		g.rect(x,y,width,height);

	// draw caret
		var p = getPositionOfText( sel.from );
		g.setFill( SolidColor(0,0,0,.33) );
		if( sel.from==sel.to ) {
			g.rect( x+p.x-1, y+p.y, 2, format.size );
		} else {
			var p2 = getPositionOfText( sel.to );
			if( p2.x<p.x ) {
				var t=p; p=p2; p2=t;
			}
			g.rect( x+p.x, y+p.y, p2.x-p.x, format.size );
		}

	}
	
}

#else

typedef EditableTextArea = TextArea;

#end
