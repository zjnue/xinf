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

import xinf.ul.Widget;
import xinf.erno.Runtime;
import xinf.event.KeyboardEvent;
import xinf.event.FrameEvent;

import xinf.erno.Color;
import xinf.erno.Renderer;
import xinf.erno.DrawingInstruction;
import xinf.ony.Object;
import xinf.ony.Root;

/**
	Focus Rectangle Class
**/
class FocusRectangle extends Object {
	private static var color:Color = new Color().fromRGBInt(0xff0000);
	
	public function focusOn( target:Widget ) :Void {
		if( target!=null ) {
			position = target.localToGlobal( { x:0, y:0 } );
			size = target.size; //localToGlobal( target.size );
		} else {
			position = null;
			size = null;
		}
		scheduleRedraw();
	}

	public function drawContents( g:Renderer ) :Void {
		if( size != null ) {
			var th=2;
			g.draw( SetStroke( color, th ) );
			g.draw( SetFill( null ) );
			g.draw( Rect( position.x-1, position.y-1, size.x+(th+1), size.y+(th+1) ) );
		}
	}
}


/**
	Keyboard Focus manager singleton
**/
class FocusManager {
	private static var widgets:Array<Widget>;
	private static var currentFocus:Int;
	
	private static var timer:Dynamic;
	private static var counter:Int;
	private static var repeat:KeyboardEvent;
	
	private static var focusRect:FocusRectangle;
	
	public static function setup() :Void {
		if( widgets==null ) {
			widgets = new Array<Widget>();
			currentFocus=-1;
			Runtime.addEventListener( KeyboardEvent.KEY_DOWN, handleKeyboardEvent );
			Runtime.addEventListener( KeyboardEvent.KEY_UP, handleKeyboardEvent );
			focusRect = new FocusRectangle();
			Root.root.attach( focusRect );
		}
	}
	
	public static function register( w:Widget, ?index:Int ) :Void {
		setup();
		if( index != null ) {
			widgets.insert( index, w );
		} else {
			widgets.push(w);
			index=widgets.length-1;
		}
		if( currentFocus==-1 ) next();
	}

	public static function unregister( w:Widget ) :Bool {
		setup();
		return widgets.remove(w);
	}

	public static function next() :Void {
		if( widgets==null ) return;
		if( currentFocus >= 0 ) widgets[currentFocus].blur();
		currentFocus++;
		if( currentFocus >= widgets.length ) currentFocus=0;
		if( currentFocus >= 0 ) {
			if( !widgets[currentFocus].focus() ) next();
		}
		focusRect.focusOn(widgets[currentFocus]);
	}

	public static function previous() :Void {
		if( widgets==null ) return;
		if( currentFocus >= 0 ) widgets[currentFocus].blur();
		currentFocus--;
		if( currentFocus < 0 ) currentFocus=widgets.length-1;
		if( currentFocus >= 0 ) {
			if( !widgets[currentFocus].focus() ) previous();
		}
		focusRect.focusOn(widgets[currentFocus]);
	}
	
	public static function setFocus( widget:Widget ) :Void {
		for( i in 0...widgets.length ) {
			if( widgets[i] == widget ) {
				if( i != currentFocus ) {
					if( currentFocus >= 0 ) widgets[currentFocus].blur();
					currentFocus=i;
					widget.focus();
				}
				focusRect.focusOn(widget);
				return;
			}
		}
	}
	
	public static function handleKeyboardEvent( e:KeyboardEvent ) :Void {
		#if flash9
		#else true
		/* key repeat */
		if( e.type == KeyboardEvent.KEY_DOWN ) {
			repeat = e;
			if( timer == null ) {
				counter = 0;
				timer = function( e:FrameEvent ) {
					counter++;
					if( counter > 8 && counter%2 == 0 ) {
						handleKeyboardEvent( repeat );
					}
				}
				Runtime.addEventListener( FrameEvent.ENTER_FRAME, timer );
			}
		} else if( e.type == KeyboardEvent.KEY_UP ) {
			Runtime.removeEventListener( FrameEvent.ENTER_FRAME, timer );
			timer = null;
		}
		#end
		
		if( widgets==null ) return;
		
		if( e.type == KeyboardEvent.KEY_DOWN && e.key == "tab" ) {
			if( e.shiftMod ) previous();
			else next();
			return;
		}
		
		if( currentFocus >= 0 ) {
			widgets[currentFocus].dispatchEvent(e);
		}
	}
}