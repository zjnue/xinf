/* this file is generated with nekobind. do not modify it direcly. */

#define HEADER_IMPORTS
#include <neko.h>
#include "cptr.h"

/***********************************************************************

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
   
***********************************************************************/

#include <ft2build.h>
#include FT_FREETYPE_H

#include "cptr.h"

FT_Library ft_library;
int __ft_init = 0;

void ft_failure_2s( const char *one, const char *two ) {
    buffer b = alloc_buffer(one);
    buffer_append(b,two);
    val_throw(buffer_to_string(b));
}

void ft_failure_v( const char *one, value v ) {
    buffer b = alloc_buffer(one);
    val_buffer(b,v);
    val_throw(buffer_to_string(b));
}

DEFINE_KIND(k_ft_face);
void _font_finalize( value v ) {
    free( val_data(v) );
}


void ft_init() {
    if( !__ft_init ) {
        if( FT_Init_FreeType( &ft_library ) ) {
            failure("Could not initialize FreeType");
        }
        __ft_init = 1;
    }
}
 
value ftLoadFont( const char *filename, const char *include_glyphs, int width, int height ) {
    ft_init();

    value font = alloc_object(NULL);
    
    FT_Face *face = (FT_Face*)malloc( sizeof(FT_Face) );
    
    if( !face || FT_New_Face( ft_library, filename, 0, face ) ) {
        ft_failure_2s("FreeType does not like ",filename);
    }
    
    FT_Set_Char_Size( *face, width, height, 72, 72 );
    
    int n_glyphs = (*face)->num_glyphs;
    
    // set some global metrics/info
    alloc_field( font, val_id("file_name"), alloc_string(filename) );
    alloc_field( font, val_id("family_name"), alloc_string((*face)->family_name) );
    alloc_field( font, val_id("style_name"), alloc_string((*face)->style_name) );
    
    alloc_field( font, val_id("ascender"), alloc_int((*face)->ascender) );
    alloc_field( font, val_id("descender"), alloc_int((*face)->descender) );
    alloc_field( font, val_id("units_per_EM"), alloc_int((*face)->units_per_EM) );
    alloc_field( font, val_id("height"), alloc_int((*face)->height) );
    alloc_field( font, val_id("max_advance_width"), alloc_int((*face)->max_advance_width) );
    alloc_field( font, val_id("max_advance_height"), alloc_int((*face)->max_advance_height) );
    alloc_field( font, val_id("underline_position"), alloc_int((*face)->underline_position) );
    alloc_field( font, val_id("underline_thickness"), alloc_int((*face)->underline_thickness) );

    value __f = alloc_abstract( k_ft_face, face );
    val_gc( __f, _font_finalize );
    alloc_field( font, val_id("__f"), __f );

    return font;
}

void importGlyphPoints( FT_Vector *points, int n, value callbacks, field lineTo, field curveTo, bool cubic ) {
    value arg[4];
    int i;
	if( n==0 ) {
        val_ocall2( callbacks, lineTo, 
                    alloc_int( points[0].x ), alloc_int( points[0].y ) );
	} else if( n==1 ) {
        arg[0] = alloc_int( points[0].x );
        arg[1] = alloc_int( points[0].y );
        arg[2] = alloc_int( points[1].x );
        arg[3] = alloc_int( points[1].y );
        val_ocallN( callbacks, curveTo, arg, 4 );
	} else if( n>=2	) {
		if( cubic ) {
			fprintf(stderr,"ERROR: cubic beziers in fonts are not yet implemented.\n");
		} else {
			int x1, y1, x2, y2, midx, midy;
			for( i=0; i<n-1; i++ ) { 
				x1 = points[i].x;
				y1 = points[i].y;
				x2 = points[i+1].x;
				y2 = points[i+1].y;
				midx = x1 + ((x2-x1)/2);
				midy = y1 + ((y2-y1)/2);
                
                arg[0] = alloc_int( x1 );
                arg[1] = alloc_int( y1 );
                arg[2] = alloc_int( midx );
                arg[3] = alloc_int( midy );
                val_ocallN( callbacks, curveTo, arg, 4 );
			}
            arg[0] = alloc_int( x2 );
            arg[1] = alloc_int( y2 );
            arg[2] = alloc_int( points[n].x );
            arg[3] = alloc_int( points[n].y );
            val_ocallN( callbacks, curveTo, arg, 4 );
		}
	} else {
	}
}

value ftIterateGlyphs( value font, value callbacks ) {
    if( !val_is_object(callbacks) ) {
        ft_failure_v("not a callback function object: ", callbacks );
    }
    field endGlyph = val_id("endGlyph");
    field startContour = val_id("startContour");
    field endContour = val_id("endContour");
    field lineTo = val_id("lineTo");
    field curveTo = val_id("curveTo");
    
    if( !val_is_object(font) ) {
        ft_failure_v("not a freetype font face: ", font );
    }
    value __f = val_field( font, val_id("__f") );
    if( __f == NULL || !val_is_abstract( __f ) || !val_is_kind( __f, k_ft_face ) ) {
        ft_failure_v("not a freetype font face: ", font );
    }
    FT_Face *face = val_data( __f );

	FT_UInt glyph_index;
	FT_ULong character;
	FT_Outline *outline;

    field f_character = val_id("character");
    field f_advance = val_id("advance");
    
    character = FT_Get_First_Char( *face, &glyph_index );
    while( character != 0 ) {
        if( FT_Load_Glyph( *face, glyph_index, FT_LOAD_NO_BITMAP ) ) {
            // ignore (TODO report?)
        } else if( (*face)->glyph->format != FT_GLYPH_FORMAT_OUTLINE ) {
            // ignore (TODO)
        } else {
            outline = &((*face)->glyph->outline);
		    int start = 0, end, contour, p;
		    char control, cubic;
		    int n,i;
		    for( contour = 0; contour < outline->n_contours; contour++ ) {
			    end = outline->contours[contour];
			    n=0;

    
			    for( p = start; p<=end; p++ ) {
				    control = !(outline->tags[p] & 0x01);
				    cubic = outline->tags[p] & 0x02;

				    if( p==start ) {
                        val_ocall2( callbacks, startContour, 
                                    alloc_int( outline->points[p-n].x ),
                                    alloc_int( outline->points[p-n].y ) );
				    }

				    if( !control && n > 0 ) {
					    importGlyphPoints( &(outline->points[(p-n)+1]), n-1, callbacks, lineTo, curveTo, cubic );
					    n=1;
				    } else {
					    n++;
				    }
			    }

			    if( n ) {
				    // special case: repeat first point
				    FT_Vector points[n+1];
				    int s=(end-n)+2;
				    for( i=0; i<n-1; i++ ) {
					    points[i].x = outline->points[s+i].x;
					    points[i].y = outline->points[s+i].y;
				    }
				    points[n-1].x = outline->points[start].x;
				    points[n-1].y = outline->points[start].y;

				    importGlyphPoints( points, n-1, callbacks, lineTo, curveTo, false );
			    }

			    start = end+1;
                val_ocall0( callbacks, endContour );
		    }

            val_ocall2( callbacks, endGlyph, alloc_int( character ), alloc_int( (*face)->glyph->advance.x ) );
        }
        character = FT_Get_Next_Char( *face, character, &glyph_index );
    }
    
    return val_true;
}
DEFINE_KIND(k_FT_Vector_p);
DEFINE_KIND(k_FT_Vector_p_p);


value neko_ft_failure_2s( value v_one, value v_two ) {
	CHECK_String( v_one );
	CHECK_String( v_two );
	const char* c_one = VAL_String( v_one );
	const char* c_two = VAL_String( v_two );
	ft_failure_2s(c_one,c_two);
	return val_true;
}
DEFINE_PRIM(neko_ft_failure_2s,2);

value neko_ft_failure_v( value v_one, value v_v ) {
	CHECK_String( v_one );
	const char* c_one = VAL_String( v_one );
	value c_v = v_v;
	ft_failure_v(c_one,c_v);
	return val_true;
}
DEFINE_PRIM(neko_ft_failure_v,2);

value neko__font_finalize( value v_v ) {
	value c_v = v_v;
	_font_finalize(c_v);
	return val_true;
}
DEFINE_PRIM(neko__font_finalize,1);

value neko_ft_init( ) {
	ft_init();
	return val_true;
}
DEFINE_PRIM(neko_ft_init,0);

value neko_ftLoadFont( value v_filename, value v_include_glyphs, value v_width, value v_height ) {
	CHECK_String( v_filename );
	CHECK_String( v_include_glyphs );
	CHECK_Int( v_width );
	CHECK_Int( v_height );
	const char* c_filename = VAL_String( v_filename );
	const char* c_include_glyphs = VAL_String( v_include_glyphs );
	int c_width = VAL_Int( v_width );
	int c_height = VAL_Int( v_height );
	value c_result = ftLoadFont(c_filename,c_include_glyphs,c_width,c_height);
	return c_result;
}
DEFINE_PRIM(neko_ftLoadFont,4);

value neko_importGlyphPoints( value v_points, value v_n, value v_callbacks, value v_lineTo, value v_curveTo, value v_cubic ) {
	CHECK_KIND( v_points, k_FT_Vector_p );
	CHECK_Int( v_n );
	CHECK_Dynamic( v_lineTo );
	CHECK_Dynamic( v_curveTo );
	CHECK_Bool( v_cubic );
	FT_Vector* c_points = VAL_KIND( v_points, k_FT_Vector_p );
	int c_n = VAL_Int( v_n );
	value c_callbacks = v_callbacks;
	field c_lineTo = VAL_Dynamic( v_lineTo );
	field c_curveTo = VAL_Dynamic( v_curveTo );
	bool c_cubic = VAL_Bool( v_cubic );
	importGlyphPoints(c_points,c_n,c_callbacks,c_lineTo,c_curveTo,c_cubic);
	return val_true;
}
DEFINE_PRIM(neko_importGlyphPoints,6);

value neko_ftIterateGlyphs( value v_font, value v_callbacks ) {
	value c_font = v_font;
	value c_callbacks = v_callbacks;
	value c_result = ftIterateGlyphs(c_font,c_callbacks);
	return c_result;
}
DEFINE_PRIM(neko_ftIterateGlyphs,2);

