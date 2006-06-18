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

package org.xinf.ony.js;

import org.xinf.ony.Element;

import js.Dom;

class JSEventMonitor {
    private var rootX:Int;
    private var rootY:Int;

    public function new() :Void {
        var self = this;
        js.Lib.document.onmousedown = untyped this.mouseDown;
        js.Lib.document.onmouseup   = untyped this.mouseUp;
        js.Lib.document.onmouseover = untyped this.mouseOver;
        js.Lib.document.onmouseout  = untyped this.mouseOut;
        js.Lib.document.onmousemove = untyped this.mouseMove;
        
        // Firefox mousewheel support
        // IE to be done, just use document.onmousewheel there...
        if( untyped js.Lib.window.addEventListener ) {
            untyped js.Lib.window.addEventListener('DOMMouseScroll', this.mouseWheelFF, false);
        }
    }
    
    private function mouseDown( e:js.Event ) :Bool {
        return postMouseEvent( e, org.xinf.event.Event.MOUSE_DOWN );
    }

    private function mouseUp( e:js.Event ) :Bool {
        return postMouseEvent( e, org.xinf.event.Event.MOUSE_UP );
    }

    private function mouseOver( e:js.Event ) :Bool {
        return postMouseEvent( e, org.xinf.event.Event.MOUSE_OVER );
    }

    private function mouseOut( e:js.Event ) :Bool {
        return postMouseEvent( e, org.xinf.event.Event.MOUSE_OUT );
    }

    private function mouseMove( e:js.Event ) :Bool {
        return postMouseEvent( e, org.xinf.event.Event.MOUSE_MOVE );
    }

    private function mouseWheelFF( e:js.Event ) :Bool {
        var target:Element = findTarget(e);
        if( target!=null ) {
            target.postEvent( org.xinf.event.Event.SCROLL_STEP, { delta:(untyped e.detail/3) } );
            untyped e.preventDefault();
        }
        return false;
    }

    private function findTarget( e:js.Event ) :Element {
        var targetNode:js.HtmlDom = e.target;
        var target:Element = untyped targetNode.owner;
        while( target == null && targetNode.parentNode != null ) {
            targetNode = targetNode.parentNode;
            if( targetNode != null ) target = untyped targetNode.owner;
        }
        return target;
    }
    
    private function postMouseEvent( e:js.Event, type:String ) :Bool {
        var target:Element = findTarget(e);
        if( target == null ) return true;
        
        if( rootX == null ) {
            untyped {
                var root = untyped org.xinf.ony.Root.getRoot()._p;
                rootX = root.offsetLeft;
                rootY = root.offsetTop;
            }
        }
            
        target.postEvent( type, { x:e.clientX - rootX, y:e.clientY - rootY } );
        
        untyped {
            if( e.stopPropagation ) e.stopPropagation();
        }
        
        return false;
    }
}