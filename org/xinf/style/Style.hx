package org.xinf.style;

import org.xinf.value.Value;
import Reflect;

class SimpleProperty<T> extends Value<T> {
    public static function initGetterSetter( class_proto:Class, _prop_name:String ) :Void {
        var prop_name = _prop_name;
        Reflect.setField(class_proto.prototype, "get_"+prop_name, function() {
                var othis:PropertySet = untyped this;
                var f:ValueBase = othis.get(prop_name);
                if( f != null ) return f.get();
                return null;
            });
        Reflect.setField(class_proto.prototype, "set_"+prop_name, function(v:Dynamic) {
                var othis:PropertySet = untyped this;
                var f:ValueBase = othis.get(prop_name);
                if( f == null ) {
                    f = Properties.create(prop_name);
                    othis.set(prop_name,f);
                }
                return f.set(v);
            });
    }
}

class FloatProperty extends SimpleProperty<Float> {
    public static function create() :ValueBase {
        return( new FloatProperty() );
    }
    public static function setFromString( name:String, s:String, ctx:PropertySet ) :Void {
        var v = new FloatProperty();
        v.set( Std.parseFloat(s) );
        ctx.set(name,v);
    }
}
class ColorProperty extends SimpleProperty<Color> {
    public static function create() :ValueBase {
        return( new ColorProperty() );
    }
    public static function setFromString( name:String, s:String, ctx:PropertySet ) :Void {
        var v = new ColorProperty();
        v.set( Color.fromString(s) );
        ctx.set(name,v);
    }
}

class AggregateProperty {
    public static function initGetterSetter( class_proto:Class, _prop_name:String ) :Void {
        var prop_name = _prop_name;
        var get = _get;
        var set = _set;
        Reflect.setField(class_proto.prototype, "get_"+prop_name, function() {
                var othis:PropertySet = untyped this;
                var f:ValueBase = othis.get(prop_name);
                if( f != null ) return f.get();
                return null;
            });
        Reflect.setField(class_proto.prototype, "set_"+prop_name, function(v:Dynamic) {
                var othis:PropertySet = untyped this;
                var f:ValueBase = othis.get(prop_name);
                if( f == null ) {
                    f = Properties.create(prop_name);
                    othis.set(prop_name,f);
                }
                return f.set(v);
            });
    }
    
    public static function _get() :String {
        throw("Generic AggregateProperty::_get():String must be overwritten");
        return null;
    }
    public static function _set( s:String ) :Void {
        throw("Generic AggregateProperty::_set():String must be overwritten");
    }
    public static function setFromString( name:String, s:String, ctx:PropertySet ) :Void {
//        throw("NYI");
    }
}

class RectangleAggregateProperty extends AggregateProperty {
    public static function _get() :String {
        return("[RectangleAggregateProperty]");
    }
    public static function _set( s:String ) :Void {
        trace("[RectangleAggregateProperty _set: "+s+"]");
    }
    public static function setFromString( name:String, s:String, ctx:PropertySet ) :Void {
//        throw("NYI");
    }
}

class PropertyDefinition {
    public var class_proto:Class;
    
    public function new( cl:Dynamic ) :Void {
        class_proto = cl;
    }
    
    private function findClassStaticFunction( name ) {
        // TODO
    }
    
    public function setFromString( name:String, s:String, ctx:PropertySet ) :Void {
        try {
            untyped class_proto.setFromString(name,s,ctx);
        } catch(e:Dynamic) {
            throw("Property class '"+class_proto.__name__.join(".")+"' has no function setFromString: "+e);
        }
    }
    
    public function create() :ValueBase {
        var p:ValueBase;
        try {
            p = untyped class_proto.create();
        } catch(e:Dynamic) {
            return null;
        }
        return p;
    }

    public function initGetterSetter( into_class:Class, prop_name:String ) :Void {
        // find static initGetterSetter in property class or parent.
        
        var cl:Class = class_proto;
        while( cl != null && untyped cl.initGetterSetter == null ) {
            cl = cl.__super__;
        }
        if( cl == null ) throw("Property class '"+class_proto.__name__.join(".")+"' has no function initGetterSetter()");
        untyped cl.initGetterSetter(into_class,prop_name);
    }
}

    
class Properties {
    public static var definitions:Hash<PropertyDefinition>;
    public static function __init__():Void {
        var defs = new Hash<PropertyDefinition>();

        defs.set( "width", new PropertyDefinition( 
                FloatProperty
            ) );
        defs.set( "height", new PropertyDefinition( 
                FloatProperty
            ) );

        defs.set( "alpha", new PropertyDefinition( 
                FloatProperty
            ) );
        defs.set( "backgroundColor", new PropertyDefinition( 
                ColorProperty
            ) );
        defs.set( "color", new PropertyDefinition( 
                ColorProperty
            ) );
            
        defs.set( "paddingLeft", new PropertyDefinition( 
                FloatProperty
            ) );
        defs.set( "paddingRight", new PropertyDefinition( 
                FloatProperty
            ) );
        defs.set( "paddingTop", new PropertyDefinition( 
                FloatProperty
            ) );
        defs.set( "paddingBottom", new PropertyDefinition( 
                FloatProperty
            ) );

        defs.set( "padding", new PropertyDefinition( 
                RectangleAggregateProperty
            ) );
        
        definitions = defs;
    }
    
    public static function create( name:String ) : ValueBase {
        var def:PropertyDefinition = definitions.get(name);
        if( def==null ) throw("no PropertyDefinition for '"+name+"'");
        
        var p:ValueBase = def.create();
        return p;
    }
    
    public static function convertPropertyName( name:String ) :String {
        var a:Array<String> = name.split("-");
        var r:String = a[0];
        for( i in 1...a.length ) {
            r+=a[i].substr(0,1).toUpperCase();
            r+=a[i].substr(1,a[i].length);
        }
        return r;
    }
    
    public static function setFromString( name:String, s:String, ctx:PropertySet ) :Void {
        var def:PropertyDefinition = definitions.get(name);
        if( def==null ) throw("no PropertyDefinition for '"+name+"' (createFromString: "+s+")");
        
        def.setFromString( name, s, ctx );
    }
}

class PropertySet extends Hash<ValueBase> {
    public function fromString( str:String ) :Void {
        for( _attribute in str.split(";") ) {
            var a = StringTools.trim(_attribute).split(":");
            if( a.length == 2 ) {
                var name = Properties.convertPropertyName(StringTools.trim(a[0]));
                var value = StringTools.trim(a[1]);
                
                Properties.setFromString( name, value, this );
            }
        }
    }
    public static function newFromString( str:String ) :PropertySet {
        var v = new PropertySet();
        v.fromString(str);
        return v;
    }
    
    public function getLink( name:String ) :Dynamic {
        var p:ValueBase = get(name);
        if( p == null ) {
            p = Properties.create( name );
            if( p == null ) throw("Property '"+name+"' cannot be linked.");
            set(name,p.identity());
        }
        return p;
    }
}


class Style extends PropertySet {
    // common style properties are mapped as haxe properties
    public property height(dynamic,dynamic):Float;
    public property width(dynamic,dynamic):Float;

    public property alpha(dynamic,dynamic):Float;
    public property color(dynamic,dynamic):Color;    
    public property backgroundColor(dynamic,dynamic):Color;    

    public property paddingLeft(dynamic,dynamic):Float;
    public property paddingTop(dynamic,dynamic):Float;
    public property paddingRight(dynamic,dynamic):Float;
    public property paddingBottom(dynamic,dynamic):Float;

    public property padding(dynamic,dynamic):String;

    // aggregate properties also
//    public property background(dynamic,dynamic):String;
    
    
    public static function __init__() :Void {
        trace("init Style");
        
        initProperties( Style, Properties.definitions.keys() );
    }
    public static function initProperties( cl:Dynamic, props:Iterator<String> ) :Void {
        var class_proto:Class = cl;
        for( prop_name in props ) {
            var def:PropertyDefinition = Properties.definitions.get(prop_name);
            if( def == null ) throw("no PropertyDefinition for '"+prop_name+"'");
            
            def.initGetterSetter( class_proto, prop_name );
        }        
    }
}
