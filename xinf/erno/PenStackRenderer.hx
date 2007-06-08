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

package xinf.erno;

import xinf.erno.Renderer;
import xinf.erno.FontStyle;

/**
    A Pen structure keeps the style with which to draw graphic objects
    for a <a href="PenStackRenderer.html">PenStackRenderer</a>. There should
    be no need to use this structure, except if you implement
    your own Renderer that derives from PenStackRenderer.
**/
class Pen {
    /**
        current fill color, may be [null].
    **/
    public var fillColor:Color;
    
    /**
        current stroke color, may be [null].
    **/
    public var strokeColor:Color;

    /**
        current stroke width (thickness), may be [null] or 0 to signal no contour
        should be drawn.
    **/
    public var strokeWidth:Float;

    /**
        current font family, a comma-separated list of official font family names or
        "_sans" for the default sans-serif font (sth. like "Bitstream Vera Sans, Arial, _sans").
        The order of the given font families determines the priority with which to choose
        the font.
    **/
    public var fontFace:String;
    
    /**
        wether the current font should be italic
    **/
    public var fontItalic:Bool;
    
    /**
        wether the current font should be bold
    **/
    public var fontBold:Bool;

    /**
        the current font size, in units of the current coordinate system.
    **/
    public var fontSize:Float;
    
    /**
        constructor, initializes a new Pen structure with default values.
    **/
    public function new() :Void {
        fontFace = "_sans";
        fontSize = 11.0;
        fontItalic = fontBold = false;
    }
    
    /**
        return a new Pen structure with the same properties as this Pen.
    **/
    public function clone() :Pen {
        var p = new Pen();
        p.fillColor = fillColor;
        p.strokeColor = strokeColor;
        p.strokeWidth = strokeWidth;
        p.fontFace = fontFace;
        p.fontItalic = fontItalic;
        p.fontBold = fontBold;
        p.fontSize = fontSize;
        return p;
    }
}


/**
    A PenStackRenderer implements the <i>style part</i> of the 
    <a href="Renderer.html">Renderer</a> interface ([setFill], [setStroke] and [setFont]),
    maintaining a stack of <a href="Pen.html">Pen</a> structures.
    <p>
        Renderers deriving from this should use [pushPen] and [popPen] at the begin
        and end of an object definition. They can access the current Pen from the [pen]
        member variable.
    </p>
**/
// FIXME: does this actually have to be a stack? i dont think so...
class PenStackRenderer extends BasicRenderer {
    
    private var pen:Pen;
    private var pens:Array<Pen>;

    public function new() :Void {
        super();
        pens = new Array<Pen>();
        pen = new Pen();
    }
    
    /**
        push the current Pen onto the stack.
        Deriving classes should usually call this from their implementation of [startObject].
    **/
    public function pushPen() :Void {
        pens.push(pen);
        pen = pen.clone();
    }
    
    /**
        pop the current Pen from the stack.
        Deriving classes should usually call this from their implementation of [endObject].
    **/
    public function popPen() :Void {
        pen = pens.pop();
        if( pen==null ) throw("Pen Stack underflow");
    }
    
    /**
        the implementation of the Renderer setFill method, sets the fillColor of the
        current pen.
    **/
    public function setFill( r:Float, g:Float, b:Float, a:Float ) {
        pen.fillColor = if( a>0 ) Color.rgba(r,g,b,a) else null;
    }
    
    /**
        the implementation of the Renderer setStroke method, sets the strokeColor and
        strokeWidth of the current pen.
    **/
    public function setStroke( r:Float, g:Float, b:Float, a:Float, width:Float ) {
        pen.strokeColor = if( a>0 ) Color.rgba(r,g,b,a) else null;
        pen.strokeWidth = width;
    }
    
    /**
        the implementation of the Renderer setFont method, sets the fontFace,
        fontSlant, fontWeight and fontSize of the current pen.
    **/
    public function setFont( face:String, italic:Bool, bold:Bool, size:Float ) {
        pen.fontFace = face;
        pen.fontItalic = italic;
        pen.fontBold = bold;
        pen.fontSize = size;
    }
    
}
