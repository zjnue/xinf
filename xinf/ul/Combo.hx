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

import xinf.ony.Element;
import xinf.style.StyleClassElement;
import xinf.ony.GeometryEvent;
import xinf.ony.MouseEvent;

/**
    Button element.
**/

class Combo<Left:StyleClassElement,Right:StyleClassElement> extends StyleClassElement {
    public var left:Left;
	public var right:Right;
	
    public function new( name:String, parent:Element) :Void {
		super( name, parent );
    }
	
	public function setLeft( l:Left ) :Void {
		left=l;
		left.addStyleClass("combo");

        // FIXME: unregister old handler
        left.bounds.addEventListener( GeometryEvent.SIZE_CHANGED, childSizeChanged );
        updateSize();
	}

	public function setRight( r:Right ) :Void {
		right=r;
		right.addStyleClass("combo");

	// FIXME: unregister old handler
        right.bounds.addEventListener( GeometryEvent.SIZE_CHANGED, childSizeChanged );
        updateSize();
	}

	/*
		FIXME: XSS needs rules by parents
	*/
	override private function onMouseOver( e:MouseEvent ) :Void {
		super.onMouseOver(e);
		left.addStyleClass(":hover");
		right.addStyleClass(":hover");
	}
	override private function onMouseOut( e:MouseEvent ) :Void {
		super.onMouseOver(e);
		left.removeStyleClass(":hover");
		right.removeStyleClass(":hover");
	}

    override public function childSizeChanged( e:GeometryEvent) :Void {
        if( autoSize ) {
            updateSize();
        }
    }

	override private function updateSize() :Void {
		if( left!=null && right!=null ) {
			right.bounds.setPosition( left.bounds.width, 0 );
		}
	}
}
