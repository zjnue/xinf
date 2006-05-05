package xinfinity.graphics;

class Stage extends Group {
    public static var EXACT_FIT:String = "exactFit";
    public static var NO_BORDER:String = "noBorder";
    public static var NO_SCALE:String = "noScale";
    public static var SHOW_ALL:String = "showAll";
    public var scaleMode : String;

    public function new( w:Int, h:Int ) {
        super();
        scaleMode = NO_SCALE;
    }

    public function resize( w:Int, h:Int ) {
        var x:Float = 1.0;
        var y:Float = 1.0;
        
        if( scaleMode == NO_SCALE ) {
            x = y = 1.0;
            trace("Stage Scale event should trigger, FIXME");
        } else if( scaleMode == EXACT_FIT ) {
            x = (w/width);
            y = (h/height);
        } else if( scaleMode == NO_BORDER ) {
            x = y = Math.max( w/width, h/height );
        } else if( scaleMode == SHOW_ALL ) {
            x = y = Math.min( w/width, h/height );
        } else {
            trace("unknown StageScaleMode '"+scaleMode+"'");
        }
        
        transform.setIdentity();
        transform.translate( -1, 1 );
        transform.scale( (2.0/w)*x, (-2.0/h)*y );
    }
}
