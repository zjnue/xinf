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

import xinf.event.Event;
import xinf.ony.Pane;
import xinf.ony.Element;
import xinf.ony.Color;
import xinf.ul.VScrollbar;
import xinf.ul.Label;
import xinf.ul.ListModel;

/**
    Improvised ListBox element.
    
    TODO: currently, all child labels are reassigned. that could be optimized
    to reassign only the ones that need to be, and move the rest.
**/

class ListBox extends Pane {
    private var scrollbar:VScrollbar;
    private var children:Array<Label>;
    private var scrollPane:Pane;
    private var model:ListModel;
    
    private var offset:Float;
    
    private static var labelHeight:Int = 20;
    private static var hoverColor:Color = new Color().fromRGBInt( 0xdddddd );
    
    public function new( name:String, parent:Element, _model:ListModel ) :Void {
        super( name, parent );
        
        offset = 0;
        children = new Array<Label>();
        bounds.addEventListener( Event.SIZE_CHANGED, reLayout ); 
        setBackgroundColor( new Color().fromRGBInt( 0xffffff ) );
        
        scrollbar = new xinf.ul.VScrollbar( name+"_scroll", this );
        scrollbar.addEventListener( Event.SCROLLED, scroll );

        scrollPane = new Pane( name+"_pane", this );
        scrollPane.crop = true;
        
        model = _model;
        model.addChangedListener( reDo );
                
        addEventListener( Event.SCROLL_STEP, scrollStep );
        addEventListener( Event.SCROLL_LEAP, scrollLeap );

        scrollPane.addEventListener( Event.MOUSE_DOWN, entryClicked );
                
        reLayout( null );
    }

    private function reLayout( e:Event ) :Void {
        assureChildren( Math.ceil((bounds.height / labelHeight) + 1) );
        
        // set children sizes
        var w:Float = bounds.width;
        for( child in children ) {
            child.bounds.setSize( w, labelHeight );
        }
        
        // hide/show the scrollbar
        if( (model.getLength() * labelHeight) > bounds.height ) {
            scrollPane.bounds.setSize( bounds.width-scrollbar.bounds.width, bounds.height );
            scrollbar.bounds.setPosition( bounds.width-scrollbar.bounds.width, 0 );
        } else {
            scrollPane.bounds.setSize( bounds.width, bounds.height );
            scrollbar.bounds.setPosition( bounds.width, 100 );
        }

        reDo(e);
    }
    
    private function reDo( e:Event ) :Void {
        var index = Math.floor(offset/labelHeight);
        var max = model.getLength();
        var y = (index*labelHeight)-offset;
        
        for( child in children ) {
            if( index >= max ) {
                child.text = "";
            } else {
                child.text = model.getItemAt(index);
            }
            child.bounds.setPosition( 0, y );
            y+=labelHeight;
            index++;
        }
    }
    
    private function assureChildren( n:Int ) :Void {
        if( children.length < n ) {
            // add labels
            for( i in 0...(n - children.length) ) {
                var child = new Label( name+"_"+children.length, scrollPane );
                child.autoSize = false;
                if( hoverColor != null ) child.setHoverColor( hoverColor );
                children.push( child );
            }
        } else if( children.length > n ) {
            // remove labels: TODO
        }
    }
    
    private function scroll( e:Event ) :Void {
        offset = ((model.getLength() * labelHeight) - bounds.height) * e.data.value;
        reDo(null);
    }

    private function scrollStep( e:Event ) :Void {
        var factor = e.data.delta;
        scrollBy( 3 * factor * labelHeight );
    }

    private function scrollLeap( e:Event ) :Void {
        var factor = e.data.delta;
        scrollBy( bounds.height * factor );
    }
    
    private function scrollBy( pixsels:Float ) :Void {
        offset += pixsels;
        if( offset < 0 ) offset = 0;
        if( offset > ((model.getLength() * labelHeight) - bounds.height) )
            offset = ((model.getLength() * labelHeight) - bounds.height);
            
        scrollbar.setScrollPosition( offset / ((model.getLength() * labelHeight) - bounds.height) );
            
        reDo(null);
    }

    private function entryClicked( e:Event ) :Void {
        var y = globalToLocal( new xinf.geom.Point(e.data.x, e.data.y) ).y;
        var i:Int = Math.floor((y+offset)/labelHeight);
        postEvent( Event.ITEM_PICKED, { index:i } );
    }
    
}