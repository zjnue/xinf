package org.xinf.inity;

import org.xinf.event.EventDispatcher;
import org.xinf.event.Event;

// TODO: if this remains the only reference to org.xinf.ony, 
// style stuff should probably be moved to org.xinf.style
import org.xinf.style.Style;

class Object {
    private var _displayList:Int;
    private var _displayListSimple:Int;
    private var _changed:Bool;
    
    public var transform:org.xinf.geom.Matrix;
    public var owner:EventDispatcher;
    public var style:Style;
    
    
    /* ------------------------------------------------------
       Object API
       ------------------------------------------------------ */
    
    public function new() {
        transform = new org.xinf.geom.Matrix();
        _displayList = _displayListSimple = null;
        style = Style.DEFAULT;
        changed();
    }
    
    public function changed() {
        _changed = true;
        changedObjects.push(this);
    }
    private static var changedObjects:Array<Object> = new Array<Object>();
    public static function cacheChanged() {
        var o:Object;
        while( (o=changedObjects.shift()) != null ) {
            o._cache();
        }
    }

    public function dispatchEvent( e:Event ) {
        if( owner == null ) throw("Object "+this+" has no owner.");
        owner.dispatchEvent(e);
    }

    /* ------------------------------------------------------
       Rendering
       ------------------------------------------------------ */
    
    // cache the object as a displaylist, regard transform.
    public function _cache() :Void {
        if( _changed ) {
            if( style != null ) { // FIXME. maybe do this somewhere else?
                transform.tx = style.x.px();
                transform.ty = style.y.px();
            }
        
            if( _displayList == null ) {
                _displayList = GL.GenLists(1);
            }
            GL.NewList( _displayList, GL.COMPILE );
            GL.PushMatrix();
                GL.MultMatrixf( transform._v );
                _render();
            GL.PopMatrix();
            GL.EndList();
            
            // cache simplified (maybe not do this if they are the same? FIXME)
            if( _displayListSimple == null ) {
                _displayListSimple = GL.GenLists(1);
            }
            GL.NewList( _displayListSimple, GL.COMPILE );
            GL.PushMatrix();
                GL.MultMatrixf( transform._v );
                _renderSimple();
            GL.PopMatrix();
            GL.EndList();
            
            _changed = false;
        }
    }
    
    // children overwrite this to render their actual contents
    private function _render() :Void {
    }
    
    // children can overwrite this to render a simplified version used for hittest
    private function _renderSimple() :Void {
        // default
        _render();
    }
    
    // external interface (called from where?)
    public function render() :Void {
        GL.CallList( _displayList );
    }
    public function renderSimple() :Void {
        GL.CallList( _displayListSimple );
    }
    
    
    public function toString() :String {
        return( "<"+ Reflect.getClass(this).__name__.join(".") + " #" + _displayList + ">" );
    }
}