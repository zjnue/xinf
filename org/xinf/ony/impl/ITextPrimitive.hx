package org.xinf.ony.impl;

import org.xinf.geom.Point;

interface ITextPrimitive implements IPrimitive {
    function setOwner( owner:org.xinf.event.EventDispatcher ) :Void;
    function applyStyle( style:org.xinf.style.Style ) :Void;
    function eventRegistered( type:String ) :Void;
    
    function setText( text:String ) :Void;
    function getTextExtends() :Point;
}
