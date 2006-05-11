package org.xinf;

import org.xinf.style.Style;
import org.xinf.style.StyleSheet;
import org.xinf.event.Event;
import org.xinf.event.EventDispatcher;

#if neko
import org.xinf.inity.Root;
#end

class Foo extends org.xinf.ony.Text {

    public function new( name:String ) {
        super( name );
        text = "Hello, World.";
        
        addEventListener( Event.MOUSE_OVER, onMouseOver );
        addEventListener( Event.MOUSE_OUT, onMouseOut );
        addEventListener( Event.MOUSE_DOWN, onMouseDown );
        addEventListener( Event.MOUSE_UP, onMouseUp );
        
        for( event in [ Event.MOUSE_DOWN, Event.MOUSE_UP,
                        Event.MOUSE_OVER, Event.MOUSE_OUT ] ) {
            addEventListener( event, handleEvent );
        }
        
        EventDispatcher.addGlobalEventListener( Event.ENTER_FRAME, onEnterFrame );
    }

    public function onMouseOver( e:Event ) :Bool {
        trace("OVER "+this);
        addStyleClass("hover");
        return true;
    }
    public function onMouseOut( e:Event ) :Bool {
        trace("OUT "+this);
        removeStyleClass("hover");
        return true;
    }
    public function onMouseDown( e:Event ) :Bool {
        addStyleClass("push");
        return true;
    }
    public function onMouseUp( e:Event ) :Bool {
        removeStyleClass("push");
        return true;
    }
    
    public function handleEvent( e:Event ) : Bool {
        //trace("Event on "+this+": "+e.type );
        
        text = name+"\n"+e.type+"\n";
        for( cl in this.getStyleClasses() ) {
            text += cl+" ";
        }
        
        return true;
    }
    
    public function onEnterFrame( e:Event ) : Bool {
     //   x = (x+2)%204;
        return true;
    }
}

class Test {
    static function main() {
        trace("Hello");
    
        #if neko
            Root.root = new Root(320,240);
        #end

        var style = StyleSheet.newFromString("
            .Foo {
                background: #f00;
                padding: 5px;
            }

            .hover {
                background: #0f0; 
            }
            
            .push {
                background: #009;
                color: white;
            }
            
            .Image {
                width: 320px;
                height: 240px;
            }

        ");
//        trace("StyleSheet: " + style );
        
        org.xinf.style.StyledObject.globalStyle.append( style );
/*
        var i = new Image("test.png");
        i.style.x = i.style.y = 10;
  */      
                
        var box = new Foo("box1");
        box.style.x = box.style.y = 100;
        box.style.width = box.style.height = 100;
        box.styleChanged();
        
        box = new Foo("box2");
        box.style.x = 201; box.style.y = 100;
        box.styleChanged();
//        box.style.width = box.style.height = 10;
        
        #if neko
             Root.root.run();
        #end
    }
}