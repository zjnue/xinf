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

package xinf.inity.gst;

import xinf.ony.erno.Object;
import xinf.erno.ImageData;
import xinf.erno.Renderer;
import xinf.event.ImageLoadEvent;

class Video extends Object {
    public var img:ImageData;
	
    public var x(default,set_x):Float;
    public var y(default,set_y):Float;
    public var width(default,set_width):Float;
    public var height(default,set_height):Float;

    public function new( img:ImageData ) :Void {
        super();
        this.img = img;
        img.addEventListener( ImageLoadEvent.FRAME_AVAILABLE, frameAvailable );
//            img = new xinf.inity.gst.VideoSource(launch,w,h);
    }
    
    private function frameAvailable( e:ImageLoadEvent ) :Void {
        scheduleRedraw();
    }
    
    public function drawContents( g:Renderer ) :Void {
        g.image( img, {x:0.,y:0.,w:1.*img.width,h:1.*img.height}, {x:position.x,y:position.y,w:size.x,h:size.y} );
    }
}