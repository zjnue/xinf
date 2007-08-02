
package xinf.ony;

import xinf.style.StyleSheet;

interface Document implements Group {

    var width(default,set_width):Int;
    var height(default,set_height):Int;

    var styleSheet(default,null):StyleSheet;
    function getElementById( id:String ) :Element;
    function getTypedElementById<T>( id:String, cl:Class<T> ) :T;
    
    function unmarshal( xml:Xml, ?parent:Group ) :Element;

}