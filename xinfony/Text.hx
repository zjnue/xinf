package xinfony;

class Text extends Element {
    public property text( getText, setText ) :String;
    private var _text:String;
    
    #if flash
        private var _textField:flash.TextField;
    #end
    
    public function new( name:String ) {
        super(name);
        untyped {
        #if flash
            _e.createTextField( 
                "theTextField", _clip.getNextHighestDepth(), 0, 0, 100, 100 );
            
            _textField = _e.theTextField;
            _textField.autoSize = true;
            _textField.background = true;
        #else js
//            _e.style.border = "1px solid #000000";
        #end
        }
    }
    
    #if neko
    private function createPrimitive() : xinfinity.graphics.Object {
        return new xinfinity.graphics.Box();
    }
    #end

    public function applyStyle( style:xinfony.style.Style ) {
        #if flash
            _textField.textColor = Colors.toInt( style.color );
            _textField.backgroundColor = Colors.toInt( style.backgroundColor );
            _textField.border = ( style.border > 0 );
            _textField.borderColor = Colors.toInt(style.borderColor);
        #else js
            _e.style.color = Colors.toString(style.color);
            _e.style.background = Colors.toString(style.backgroundColor);
            _e.style.border = style.border+"px solid "+Colors.toString(style.borderColor);
        #end
    }
    
    private function setText( t:String ) :String {
        _text = t;
        #if flash
            untyped _textField.text = _text;
        #else js
            untyped _e.innerHTML = _text.split("\n").join("<br/>");
        #end
        return _text;
    }
    private function getText() :String {
        return _text;
    }
}
