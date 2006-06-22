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

package tests.primitives;

class Text extends TestCase {
    var testElement:xinf.ony.Text;
    public function new( parent:xinf.ony.Element ) :Void {
        super( parent, .999 );

        testElement = new xinf.ony.Text( "test", this );
        testElement.setBackgroundColor( new xinf.ony.Color().fromRGBInt( 0x333333 ) );
        testElement.setTextColor( new xinf.ony.Color().fromRGBInt( 0xeeeeee ) );
        testElement.bounds.setPosition(10,10);
        testElement.setFontSize( 10 );
        testElement.text = "the quick brown fox\nindeed\njumps over the lazy dog";

        var t = new xinf.ony.Text("glyph", this );
        t.setTextColor( new xinf.ony.Color().fromRGBInt( 0x0000ff ) );
        t.bounds.setPosition( 10, 50 );
        t.setFontSize( 64 );
        t.text = "a";
        screenshotFrame1();
    }
}
