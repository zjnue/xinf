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

package xinf.x11;

import xinf.event.Event;

class XForward extends XScreen {
    public function new( server:String, _screen:Int, parent:xinf.ony.Element ) {
        super( server, _screen, parent );

        if( !X.HaveTestExtension(display) ) {
            throw( "No XTest extension on display "+name );
        }
        
        addEventListener( Event.MOUSE_DOWN, onMouseDown );
        addEventListener( Event.MOUSE_UP, onMouseUp );
        addEventListener( Event.MOUSE_MOVE, onMouseMove );
    }

    public function onMouseDown( e:Event ) :Void {
        trace( "down" );
        X.TestFakeButtonEvent( display, 1, 1, X.CurrentTime );
    }
    public function onMouseUp( e:Event ) :Void {
        trace( "up" );
        X.TestFakeButtonEvent( display, 1, 0, X.CurrentTime );
    }
    public function onMouseMove( e:Event ) :Void {
            //FIXME: this is a very very crude globalToLocal transformation!
        var root:xinf.inity.Root = untyped xinf.ony.Root.getRoot()._p;
        X.TestFakeMotionEvent( display, screen, 
                Math.round(root.mouseX-bounds.x), 
                Math.round(root.mouseY-bounds.y), X.CurrentTime );
    }
}