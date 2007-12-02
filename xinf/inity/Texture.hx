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

package xinf.inity;

import xinf.support.Pixbuf;
import cptr.CPtr;
import opengl.GL;
import opengl.GLU;
import xinf.erno.ImageData;
import xinf.inity.ColorSpace;

/** strictly any neko ImageData is already a texture. This class manages the texture though,
  ImageData only stores some values for direct access by the GLGraphicsContext **/
  
class Texture extends ImageData {
    // texture (id), twidth, theight, width and height are already defined in ImageData.
    
    public function initialize( w:Int, h:Int, cspace:ColorSpace ) {
        width=w;
        height=h;
        
        twidth = 2; while( twidth<w ) twidth<<=1;
        theight = 2; while( theight<h ) theight<<=1;

        // generate texture id
        var t:Dynamic = CPtr.uint_alloc(1);
        GL.genTextures(1,t);
        texture = CPtr.uint_get(t,0);
        var e:Int = GL.getError();
        if( e > 0 ) { throw("could not create texture"); }
        
        /* If this happens, likely the GL context isnt initialized yet. 
            Might be the cause for white rectangles instead of glyphs in text.. */
        if( texture>1000000 ) throw("unlikely texture ID: "+texture ); 
            

        GL.pushAttrib( GL.ENABLE_BIT );
        GL.enable( GL.TEXTURE_2D );
        
        var internalFormat = switch( cspace ) {
				case RGB: GL.RGB;
				case RGBA: GL.RGBA;
				case BGR: GL.BGR;
				case BGRA: GL.BGRA;
				default: GL.RGBA;
			}
        
            GL.bindTexture( GL.TEXTURE_2D, texture ); // unneccessarryy?
            GL.texParameter( GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP );
            GL.texParameter( GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP );
            GL.texParameter( GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST );
            GL.texParameter( GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST );
            GL.texImage2D( GL.TEXTURE_2D, 0, internalFormat, twidth, theight, 0, GL.RGB, GL.UNSIGNED_BYTE, null );

        GL.popAttrib();
        
        #if gldebug
            var e:Int = GL.getError();
            if( e > 0 ) {
                throw( "OpenGL Error: "+GLU.errorString(e) );
            }
        #end
    }
    
    public function setData( data:Dynamic, pos:{x:Int,y:Int}, size:{x:Int,y:Int}, ?cspace:ColorSpace ) :Void {
        if( cspace==null ) cspace=RGBA;
    
        GL.pushAttrib( GL.ENABLE_BIT );
        GL.enable( GL.TEXTURE_2D );
        GL.bindTexture( GL.TEXTURE_2D, texture );

        if( data != null ) {
            switch( cspace ) {
                case RGB:
                    GL.texSubImageRGB( texture, pos.x, pos.y, size.x, size.y, data );
                case BGR:
                    GL.texSubImageBGR( texture, pos.x, pos.y, size.x, size.y, data );
                case RGBA:
                    GL.texSubImageRGBA( texture, pos.x, pos.y, size.x, size.y, data );
                case BGRA:
                    GL.texSubImageBGRA( texture, pos.x, pos.y, size.x, size.y, data );
                case GRAY:
                    GL.texSubImageGRAY( texture, pos.x, pos.y, size.x, size.y, data );
                default:
                    throw("unknown colorspace "+cspace );
            }
        }
        
        GL.popAttrib();

        #if gldebug
            var e:Int = GL.getError();
            if( e > 0 ) {
                throw( "OpenGL Error trying to set texture #"+texture+": "+GLU.errorString(e) );
            }
        #end
        
        frameAvailable( data );
    }

    /* FIXME: image cache will keep images FOREVER. at least provide a way to flush! */
    public static var cache:Hash<Texture> = new Hash<Texture>();
    
    public static function newByName( url:String ) :Texture {
	    try {
            var r = cache.get(url);
            if( r==null ) {
                var data:String;
                var u = url.split("://");
                if( u.length == 1 ) {
                    // local file
                    data = neko.io.File.getContent( url );
                } else {
                    switch( u[0] ) {
                        case "file":
                            data = neko.io.File.getContent( u[1] );
                        case "resource":
                            data = Std.resource(u[1]);
                        case "http":
                            data = haxe.Http.request(url);
                        default:
                            throw("unhandled protocol for image loading: "+u[0] );
                    }
                }
                if( data == null || data.length==0 ) {
                    throw("Could not load: "+url );
                }
				var p = Pixbuf.newFromCompressedData( neko.Lib.haxeToNeko(data) );
				r = newFromPixbuf( p );
                cache.set(url,r);
            }
            return r;
        } catch( e:Dynamic ) {
            throw("Error loading '"+url+": "+e );
        }
    }
    
    public static function newFromPixbuf( pixbuf:Pixbuf ) :Texture {
        var r = new Texture();
        
        var w = pixbuf.getWidth();
        var h = pixbuf.getHeight();
        var stride = pixbuf.getRowstride();
        var cs = if( pixbuf.getHasAlpha()>0 ) RGBA else RGB;
        r.initialize( w, h, cs );
        var d = pixbuf.copyPixels(); // FIXME: maybe we dont even need to copy the data, as we set it to texture right away
		r.setData( d, {x:0, y:0}, {x:w,y:h}, cs );
        return r;
    }

}
