/* 
   xinf is not flash.
   Copyright (c) 2006, Daniel Fischer.
 
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.
                                                                            
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU        
   Lesser General Public License or the LICENSE file for more details.
*/

package xinf.ul;

import xinf.erno.Renderer;

#if neko
import xinf.event.Event;
import xinf.event.KeyboardEvent;
import xinf.event.MouseEvent;
import xinf.geom.Types;
import xinf.erno.Color;
import xinf.erno.FontStyle;
import xinf.erno.Renderer;
import xinf.inity.font.Font;
import xinf.inity.GLRenderer;

/**
    single-line text input element (xinfinity only)
    
    TODO:
      * double-click selects word
      * dragging out of bounds should scroll onEnterFrame.
**/

class LineEdit extends Widget {
    
    private var sel :{ from:Int, to:Int };
    public var text :String;
    
    private var font :Font;
    private var xOffset :Float;

    public function new() :Void {
        super();
        sel = { from:0, to:0 };
        xOffset = 0;
        text = "";
        
        addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
        addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
    }

    public function onKeyDown( e:KeyboardEvent ) :Void {
        if( e.code >= 32 && e.code < 127 ) {
            switch( e.code ) {
                case 127: // Del
                    if( sel.from==sel.to ) {
                        sel.to=sel.from+1;
                    }
                    replaceSelection("");
                default:
                    replaceSelection( Std.chr(e.code) );
            }
        } else {
            switch( e.key ) {
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
                case "home":
                    moveCursor( 0, e.shiftMod );
                case "end":
                    moveCursor( text.length, e.shiftMod );
                case "a":
                    selectAll();
                default:
                    trace("unhandled control key: "+e.key);
            }
        }
        scheduleRedraw();
    }

    private function onMouseDown( e:MouseEvent ) :Void {
        var p = globalToLocal( {x:1.*e.x, y:1.*e.y } );
        p.x += (xOffset-(style.padding.l+style.border.l));
        moveCursor( findIndex(p), false ); // FIXME e.shiftMod );
        new Drag<Float>( e, dragSelect, null, e.x );
    }
    
    public function dragSelect( x:Float, y:Float, marker:Float ) {
        var p = globalToLocal( {x:x+marker, y:y } );
        p.x += (xOffset-(style.padding.l+style.border.l));
        moveCursor( findIndex(p), true );
    }
    
    public function selectAll() :Void {
        sel.from=0; sel.to=text.length;
        scheduleRedraw();
    }
    
    public function moveCursor( to:Int, extendSelection:Bool ) :Void {
        sel.to=to; 
        if( sel.to < 0 ) sel.to=0;
        else if( sel.to > text.length ) sel.to=text.length;
        if( !extendSelection ) sel.from=sel.to;
        scheduleRedraw();
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
        var u = t.substr(0,sel.from);
        u += str;
        u += t.substr(sel.to, t.length-sel.to);
        sel.to=sel.from=sel.from+str.length;
        text=u;
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

    public function findIndex( p:TPoint ) :Int {
        var format = getStyleTextFormat();
        var font = format.font;
        if( font==null ) throw("Font unknown as yet");
        var fontSize:Float = format.size;
        
        var x:Float=0;
        var i:Int=0;
        var g;
        while( x < p.x && i<text.length ) {
            g = font.getGlyph(text.charCodeAt(i),fontSize);
            if( g != null ) {
                x += Math.round((g.advance*fontSize));
            }
            i++;
        }
        if( g != null ) 
            if( p.x <= x-(Math.round(g.advance*fontSize)/2) ) i--;
            
        return i;
    }

    public function drawContents( g:Renderer ) :Void {
        super.drawContents(g); 

        var format = getStyleTextFormat();
        var selStart = format.textSize( text.substr(0,sel.from) ).x;
        var selEnd = selStart + 
                            if( sel.from>sel.to )
                                -format.textSize( text.substr(sel.to,sel.from-sel.to) ).x;
                            else
                                format.textSize( text.substr(sel.from,sel.to-sel.from) ).x;
        var textSize = format.textSize( text );

        
        // "ScrollIntoView" - FIXME you can do better, no?
        var c=selEnd-(xOffset-(style.padding.l));
        var d=10;
        if( c < d ) {
            xOffset += c-d;
        }
        if( c > size.x-d ) {
            xOffset += c - (size.x-d);
        }
        if( xOffset != 0 && (textSize.x-xOffset) < size.x-d ) {
            if( textSize.x < size.x-d ) {
                xOffset=0;
            } else {
                xOffset -= ((size.x-d) - (textSize.x-xOffset));
            }
        }
        if( xOffset<0 ) xOffset=0;
        
        
        var fgColor:Color = style.get("textColor",Color.BLACK);
        var selBgColor:Color = style.get("selectBackground",Color.BLACK);
        var selFgColor:Color = style.get("selectColor",Color.WHITE);
        var focus = hasStyleClass(":focus");
        
            //g.clipRect( size.x-2, size.y-2 ); FIXME: crop with a Crop?!
            
            var xofs=-(xOffset-(style.padding.l+style.border.l));
            var yofs=style.padding.t+style.border.t;

            // draw selection background/caret
            if( focus ) {
                
                var x=selStart-1.5; var y=-.5; 
                var w=selEnd-.5; var h=Math.ceil(textSize.y+.5)-.5;

                g.setStroke( 0,0,0,0,0 );
                if( selEnd != selStart ) {
                    g.setFill( selBgColor.r, selBgColor.g, selBgColor.b, selBgColor.a );
                } else {
                    // just caret
                    g.setFill( fgColor.r, fgColor.g, fgColor.b, fgColor.a );
                }
                g.rect( xofs+x, yofs+y, w-x,h-y );
            }
            
            
            // setup styles for selection foreground
            var styles = new FontStyle();
            if( focus && sel.from != sel.to ) {
                styles.push( { pos:Math.round(Math.min(sel.to,sel.from)), color:selFgColor } );
                styles.push( { pos:Math.round(Math.max(sel.to,sel.from)), color:fgColor } );
            }
            
            g.setFill( fgColor.r, fgColor.g, fgColor.b, fgColor.a );
            g.text( xofs, yofs, text, format ); // FIXME, styles );
            
    }
}

#else flash

class LineEdit extends Widget {
    public var text(get_text,set_text) :String;
    private var _t:flash.text.TextField;

    private function get_text() :String {
        return _t.text;
    }
    
    private function set_text(t:String) :String {
        _t.text = t;
        return t;
    }

    public function new() :Void {
        super();
        _t = new flash.text.TextField();
        _t.type = "input";

        var format:flash.text.TextFormat = _t.getTextFormat();
        format.font = style.get("fontFamily","_sans");
        format.size = style.get("fontSize",10);
        format.color = style.color.toRGBInt();
        format.leftMargin = 0;
        _t.setTextFormat(format);
    }

    public function drawContents( g:Renderer ) :Void {
        super.drawContents(g);
        g.native(_t);
    }
    
}

#else js 

import js.Dom;

class LineEdit extends Widget {
    public var text(get_text,set_text) :String;
    private var _t:js.FormElement;

    private function get_text() :String {
        return _t.value;
    }
    
    private function set_text(t:String) :String {
        _t.value = t;
        return t;
    }

    public function new() :Void {
        super();
        _t = cast( js.Lib.document.createElement("input") );
        _t.style.overflow = "hidden";
        _t.style.whiteSpace = "nowrap";
        _t.style.fontFamily = style.get("fontFamily","Arial");
        _t.style.fontSize = style.get("fontSize",10);
        // FIXME: bold/italic
        _t.style.paddingTop = 2;
        _t.style.paddingBottom = 2;
        _t.style.paddingLeft = 2;
        _t.style.paddingRight = 2;
        _t.style.lineHeight = "110%";
        _t.style.background = "#f00"; //"transparent";
        _t.style.border = "none";
        _t.style.position="absolute";
        //_t.style.top = "-10";
    }

    override public function resize( x:Float, y:Float ) :Void {
        super.resize(x,y);
        _t.style.width = ""+Math.round(size.x);
        _t.style.height = ""+Math.round(size.y);
    }

/*
    override public function focus() :Bool {
        if( super.focus() ) {
            _t.focus();
            return true;
        }
        return false;
    }

    override public function blur() :Void {
        super.blur();
        _t.blur();
    }
*/
    public function drawContents( g:Renderer ) :Void {
        super.drawContents(g);
        g.native(_t);
        
        if( FocusManager.isFocussed(this) ) {
            _t.focus();
        } else {
            _t.blur();
        }
    }
}
#end