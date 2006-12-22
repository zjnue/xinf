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

package xinf.erno;

/**
    The Keys class provides a single global function ([get]) to 
    convert a runtime-specific numeric key code to a
    xinferno-standard key string.
    <br/>
    "Well-known" Keys are:
    <ul>
        <li>backspace</li>
        <li>tab</li>
        <li>escape</li>
        <li>space</li>
        <li>page up</li>
        <li>page down</li>
        <li>left</li>
        <li>up</li>
        <li>right</li>
        <li>down</li>
    </ul>
**/
class Keys {
    
    private static var keys:IntHash<String>;
    
    private static function __init__() :Void {
        keys = new IntHash<String>();
        
        keys.set(8,"backspace");
        keys.set(9,"tab");
        keys.set(27,"escape");
        keys.set(32,"space");
        
        #if neko
            keys.set(opengl.GLUT.KEY_PAGE_UP,"page up");
            keys.set(opengl.GLUT.KEY_PAGE_DOWN,"page down");
            keys.set(opengl.GLUT.KEY_LEFT,"left");
            keys.set(opengl.GLUT.KEY_UP,"up");
            keys.set(opengl.GLUT.KEY_RIGHT,"right");
            keys.set(opengl.GLUT.KEY_DOWN,"down");
        #else true
            keys.set(33,"page up");
            keys.set(34,"page down");
            keys.set(37,"left");
            keys.set(38,"up");
            keys.set(39,"right");
            keys.set(40,"down");
        #end
    }
    
    public static function get( code:Int ) :String {
        return( keys.get(code) );
    }
    
}
