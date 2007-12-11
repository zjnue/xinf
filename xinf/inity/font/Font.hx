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

package xinf.inity.font;

import opengl.GL;
import xinf.erno.Renderer;
import xinf.erno.FontStyle;

class Font extends xinf.support.Font {
    
    private static var fonts:Hash<Font> = new Hash<Font>();
    
    public static function getFont( ?name:String, ?weight:Int, ?slant:Int ) :Font {
        if( name==null ) name="_sans";
        if( weight==null ) weight=100;
        if( slant==null ) slant=0;
        
        var font:Font;
        font = fonts.get(name);
        if( font != null ) return font;
        
        var data:String;
        if( name=="_sans" ) { name=="sans"; }
        
        var file = ""+xinf.support.Font.findFont(name,weight,slant,12.0);
        if( file==null || file=="" ) throw("Unable to load font "+name+": "+file );

		var font;
		
		try {
			data = neko.io.File.getContent( file );
			font = new Font( data, 12 );
		} catch( e:Dynamic ) {
			trace("Couldn't load font: using bundled Vera");
			data = neko.io.File.getContent( xinf.support.DLLLoader.getXinfLibPath()+"/../vera.ttf" );
			font = new Font( data, 12 );
		}
        
        fonts.set( name, font );
        return font;
    }

    public var font:xinf.support.Font;
    private var cache:Hash<GlyphCache>;
    // later, maybe: private var outlines:GlyphCache();
	var data:String;

    public function new( data:String, size:Int ) {
		this.data = data;
        var s = Math.round(size<<24);
        super( data, s, s );
        cache = new Hash<GlyphCache>();

		// FIXME
        var c = cache.get(""+Math.round(size));
        if( c==null ) {
            c = new GlyphCache( this, Math.round(size), size<=12 );
            cache.set(""+Math.round(size),c);
		}
		trace("preload: "+this );
		for( i in 32...128 ) {
			c.get(i);
		}
		
    }
    
    public function getGlyph( character:Int, fontSize:Float ) :Glyph {
        var c = cache.get(""+Math.round(fontSize));
        
        //if( c==null ) throw("no cache for fontsize "+fontSize+": Implement OutlineCache (TODO)");
        if( c==null ) {
            c = new GlyphCache( this, Math.round(fontSize), fontSize<=12 );
            cache.set(""+Math.round(fontSize),c);
        }
        
        var g = c.get(character);
        return( g );
    }

    public function textSize( text:String, fontSize:Float ) :{x:Float,y:Float} {
        var lines=0;
        var lineHeight = Math.round(height*fontSize)/fontSize;
        var w=0.0;
        var maxW=0.0;
        for( i in 0...text.length ) {
            var c = text.charCodeAt(i);
            if( c == 10 ) { // \n
                if( w>maxW ) maxW = w;
                w=0;
                lines++;
            } else {
                var g = getGlyph(c,fontSize);
                if( g != null ) {
                    w += g.advance/fontSize;
                }
            }
        }
        if( w>maxW ) maxW=w;
        maxW*=fontSize;
        return { x:maxW, y:(lines+1)*(lineHeight*fontSize) };
    }
    
    public function renderText( text:String, fontSize:Float, style:FontStyle ) :Void {
        if( text == null ) text="[null]";
        
        var lines=0;
        var c_style=0;
        var r = { x:.0, y:.0 };
        var nextStyle:FontStyleChange = null;
        if( style!=null ) nextStyle = style[c_style];
        
        GL.pushMatrix();
        
        GL.scale( fontSize, fontSize, 1.0 );
        GL.translate( .0, ascender, .0 ); // FIXME *.9?

        GL.pushMatrix(); // for lines.

        var lineHeight = Math.round(height*fontSize)/fontSize;

        for( i in 0...text.length ) {
            if( nextStyle != null && nextStyle.pos == i ) {
                GL.color4( nextStyle.color.r, nextStyle.color.g, nextStyle.color.b, nextStyle.color.a );
                c_style++;
                nextStyle = style[c_style];
            }
            
            var c = text.charCodeAt(i);
            if( c == 10 ) { // \n
                GL.popMatrix();
                GL.pushMatrix();
                lines++;
                GL.translate( .0, lineHeight*lines, .0 );
            } else {
                var g = getGlyph(c,fontSize);
                if( g != null ) {
                    g.render(fontSize);
                }
            }
        }
        GL.popMatrix();

        GL.popMatrix();
        
        #if gldebug
            var e:Int = GL.getError();
            if( e > 0 ) {
                throw( "OpenGL Error: "+opengl.GLU.errorString(e) );
            }
        #end
    }

    public function toString() :String {
        return("[Font: "+family_name+"]");
    }
}

