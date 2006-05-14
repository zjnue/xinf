package org.xinf.ony.layout;

import org.xinf.event.Event;
import org.xinf.ony.Element;

enum Orientation {
    HORIZONTAL;
    VERTICAL;
}

class BoxLayout extends Layout {
    private var orientation:Orientation;

    public function new( _name:String, o:Orientation ) :Void {
        super(_name);
        orientation = o;
        addEventListener( Event.SIZE_CHANGED, do_relayout );
    }
    
    public function do_relayout( e:Event ) :Void {
        if( e.target == this ) return;
        relayout(); // maybe not, always "schedule" event? FIXME
    }
    
    public function relayout() :Void {
        switch( orientation ) {
            case HORIZONTAL:
                _horizontalLayout();
            case VERTICAL:
                _verticalLayout();
            default:
                throw("BoxLayout "+orientation+" not implemented");
        }
    }
    
    private function _horizontalLayout() {
        var max:Float = 0;

        // iterate once to find maximum height for alignment.
        for( child in children ) {
            var h = child.style.height.px();
            if( h > max ) max = h;
        }
        
        // iterate again to set position
        var x:Float = style.padding.left.px() + style.border.thickness.px();
        var ofs:Float = style.padding.top.px() + style.border.thickness.px();
        for( child in children ) {
            child.style.y = ofs + ((max - child.style.height.px()) * child.style.verticalAlign.factor );
            child.style.x = x;
            x += child.style.width.px();
            child.styleChanged();
        }
        
        style.setInnerSize(x-(style.padding.left.px() + style.border.thickness.px()),max);
        styleChanged();
    }
    
    private function _verticalLayout() {
        var max:Float = 0;

        // iterate once to find maximum width for alignment.
        for( child in children ) {
            var w = child.style.width.px();
            if( w > max ) max = w;
        }
        
        // iterate again to set position
        var y:Float = style.padding.top.px() + style.border.thickness.px();
        var ofs:Float = style.padding.left.px() + style.border.thickness.px();
        for( child in children ) {
            child.style.x = ofs + ((max - child.style.width.px()) * child.style.textAlign.factor );
            child.style.y = y;
            y += child.style.height.px();
            child.styleChanged();
        }
        
        style.setInnerSize(max,y-(style.padding.top.px() + style.border.thickness.px()));
        styleChanged();
    }
    
    public function addChild( child:Element ) :Void {
        super.addChild(child);
        relayout();
    }
    
    public function removeChild( child:Element ) :Void {
        super.addChild(child);
        relayout();
    }
}
