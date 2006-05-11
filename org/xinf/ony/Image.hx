package org.xinf.ony;

import org.xinf.style.Color;
import org.xinf.style.Style;

class Image extends Pane {

    public function new( name:String ) {
        super(name);
    }

    #if neko
    private function createPrimitive() : org.xinf.inity.Object {
        return new org.xinf.inity.Bitmap( org.xinf.inity.BitmapData.newFromFile(name) );
    }
    #end
    
    private function draw() {
        #if flash
            var b = style.border.thickness.px();
            var padding = style.padding;
            var w:Int = Math.floor( style.width.px() +b+b+padding.left.px()+padding.right.px() );
            var h:Int = Math.floor( style.height.px() +b+b+padding.top.px()+padding.bottom.px() );
            
            untyped {
            _e.clear();
            _e.beginFill( style.background.toInt(),  50 );
            if( b > 0 ) {
                _e.lineStyle( b, style.border.color.toInt(), style.border.color.a*100, true, "", "", "", 0 );
            }
            _e.moveTo( 0, 0 );
            _e.lineTo( w, 0 );
            _e.lineTo( w, h );
            _e.lineTo( 0, h );
            _e.lineTo( 0, 0 );
            _e.endFill();
            }
        #else neko
            _e.changed();
        #end
    }
}