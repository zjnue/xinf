package xinfinity.graphics;

import xinf.geom.Rectangle;
import xinfony.style.Border;
import xinfony.style.Pad;

class Box extends Group {
    public function new() {
        super();
    }

    private function _renderGraphics() :Void {
        var border:Border = style.border;
        var padding:Pad = style.padding;
            
        var b:Float = border.thickness.px();
        
        var x:Float = 0;
        var y:Float = 0;
        var w:Float = x+style.width.px()+b+b+padding.left.px()+padding.right.px();   // w,h are not really width/height here,
        var h:Float = y+style.height.px()+b+b+padding.top.px()+padding.bottom.px();  // but right,bottom!
        
      // background
        var c = style.background;
        GL.Color4f( c.r/0xff, c.g/0xff, c.b/0xff, c.a/0xff );
        GL.Begin( GL.QUADS );
            GL.Vertex3f( x-.5, y-.5, 0. );
            GL.Vertex3f( w+.5, y-.5, 0. );
            GL.Vertex3f( w+.5, h+.5, 0. );
            GL.Vertex3f( x-.5, h+.5, 0. );
        GL.End();
        
      // border
        if( border.thickness.value > 0 ) {
            GL.LineWidth( border.thickness.value );
            var c = border.color;
            GL.Color4f( c.r/0xff, c.g/0xff, c.b/0xff, c.a/0xff );
            GL.Begin( GL.LINE_STRIP );
                GL.Vertex3f( x, y, 0. );
                GL.Vertex3f( w, y, 0. );
                GL.Vertex3f( w, h, 0. );
                GL.Vertex3f( x, h, 0. );
                GL.Vertex3f( x, y, 0. );
            GL.End();
            GL.PointSize( border.thickness.value );
            GL.Begin( GL.POINTS );
                GL.Vertex3f( w, y, 0. );
                GL.Vertex3f( w, h, 0. );
                GL.Vertex3f( x, h, 0. );
                GL.Vertex3f( x, y, 0. );
            GL.End();
        }
    }
    
    private function _render() :Void {
        _renderGraphics();
        super._render();
    }

    private function _renderSimple() :Void {
        var w = style.width.px();
        var h = style.height.px();

      //  background
        GL.Begin( GL.QUADS );
            GL.Vertex3f( w , 0., 0. );
            GL.Vertex3f( w , h , 0. );
            GL.Vertex3f( 0., h , 0. );
            GL.Vertex3f( 0., 0., 0. );
        GL.End();
    }
}
