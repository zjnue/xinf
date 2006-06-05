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

package org.xinf.ony;

import org.xinf.geom.Point;
import org.xinf.event.Event;

/**
    Text is an Element that displays Text. Handling of the font style is not yet finalized. The Text is not editable.
**/
class Text extends Pane {
    /**
        The actual text that will be displayed. 
        Setting the text with autoSize set to true will trigger a SIZE_CHANGED event on the Element's bounds.
    **/
    public var text( getText, setText ) :String;

    /**
        If autoSize is set to true, the Element's bounds rectangle will automatically be set to enclose the
        contained text. If false, it will always be the size you specified, with text content probably overflowing.
    **/
    public var autoSize( default, default ) :Bool;

    private var textColor:org.xinf.ony.Color;

    private var _t
        #if neko
            :org.xinf.inity.Text
        #else js
            :js.HtmlDom
        #else flash
            :flash.TextField
        #end
        ;

    /**
        Constructor. Initializes to autoSize=true; text content will be empty.
    **/    
    public function new( name:String, parent:Element ) {
        super(name,parent);
        autoSize = true;
    }
    
    private function createPrimitive() :Dynamic {
        _t =
            #if neko
                new org.xinf.inity.Text()
            #else js
                js.Lib.document.createElement("div")
            #else true
                null
            #end
            ;

        #if js
            _t.style.cursor = "default";
            _t.style.overflow = "hidden";
            _t.style.whiteSpace = "nowrap";
            _t.style.background="#f00";
        #else flash
            if( parent == null ) throw( "Flash runtime needs a parent on creation" );
            var e = parent._p.createEmptyMovieClip(name,parent._p.getNextHighestDepth());
            
            e.createTextField("_"+name, e.getNextHighestDepth(), 0, 0, 0, 0 );
            _t = Reflect.field( e, "_"+name );
            
            _t.autoSize = true;
            
            var format:flash.TextFormat = new flash.TextFormat();
            format.size = 12;
            format.font = "Bitstream Vera Sans";
            _t.setNewTextFormat( format );
            
            return e;         
        #end
        
        return _t;
    }
    
    private function setText( t:String ) :String {
        #if neko
            _t.text = t;
        #else js
            while( _t.firstChild != null ) _t.removeChild( _t.firstChild );
            var ta = t.split("\n");
            _t.appendChild( untyped js.Lib.document.createTextNode( ta.shift() ) );
            var ct = ta.shift();
            while( ct != null ) {
                _t.appendChild( js.Lib.document.createElement("br") );
                _t.appendChild( untyped js.Lib.document.createTextNode( ct ) );
                ct = ta.shift();
            }
        #else flash
            _t.text = t;
        #end
        
        if( autoSize ) calcSize();
        return getText();
    }
    private function getText() :String {
        #if neko
            return _t.text;
        #else js
            return untyped _t.innerHTML.split("<br/>").join("\n");
        #else flash
            return _t.text;
        #end
    }
    
    private function calcSize() :Void {
        var s:Point;
        #if neko
            s = _t.getTextExtends();
        #else js
            s = new Point(untyped _t.offsetWidth, untyped _t.offsetHeight);
        #else flash
            s = new Point( _t._width, _t._height );
        #end
        
        #if js
        #else true
            bounds.setSize( Math.round(s.x), Math.round(s.y) );
        #end
    }

    public function setTextColor( c:org.xinf.ony.Color ) :Void {
        textColor = c;
        
        #if neko
            _p.fgColor = textColor;
            _p.changed();
        #else js
            _p.style.color = textColor.toRGBString();
        #else flash
            _t.textColor = textColor.toRGBInt();
        #end
    }
}
