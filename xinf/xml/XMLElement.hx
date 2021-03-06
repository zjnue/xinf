/*  Copyright (c) the Xinf contributors.
	see http://xinf.org/copyright for license. */
	
package xinf.xml;

import xinf.traits.TraitAccess;
import xinf.traits.TraitDefinition;
import xinf.traits.StringTrait;
import xinf.traits.TraitTypeException;
import xinf.traits.SpecialTraitValue;
import xinf.style.StyleParser;

import xinf.event.EventDispatcher;
import xinf.event.Event;
import xinf.event.EventKind;

/**
	An Element, like a tag in an XML document, but
	also the base class for all Xinfony 
	$xinf.ony.Element$s.
	
	Element provides the basics to implement
	$xinf.traits.TraitAccess$ and $xinf.event.EventDispatcher$.
*/
class XMLElement extends Node,
		implements TraitAccess,
		implements EventDispatcher {

	var _traits:Dynamic;
	var _ptraits:Dynamic;
	var _cache:Dynamic;
	var listeners :Hash<List<Dynamic->Void>>;
	
	static var TRAITS = {
		base:new StringTrait(),
		id:new StringTrait(),
		name:new StringTrait(),
	};

	/**
		The current base URL/URI/IRI for this element.
		Can be set to specify a different base URL,
		possibly relative to an "inherited" base.
		
		$SVG struct#XMLBaseAttribute xml:base$
	*/
	// FIXME: it's not really a style trait, but is "somehow" inherited...
	public var base(get_base,set_base):String; 
	function get_base() :String { 
		var p:XMLElement=this;
		var b:String=null;
		while( p!=null ) {
//			trace(""+this+" base "+base+" parent "+p.parentElement );
			var thisBase = p.getTrait("base",String);
			if( thisBase!=null ) b = if( b!=null ) thisBase+b else thisBase; // FIXME: actually, URL.relateTo
			p = p.parentElement;
		}
		return b; 
	} 
	function set_base( v:String ) :String { return setStyleTrait("base",v); }

	/** Standard XML unique name ("id" attribute).
	
		As there is no namespace support at the moment,
		this recognized both "id" and "xml:id", with
		(not-standard-conformantly) the later attribute 
		taking precedence.
		
		FIXME: should update the document's index when changed.
	
		$SVG struct#xmlIDAttribute xml:id$
	*/
	public var id(get_id,set_id):String;
	function get_id() :String { return getTrait("id",String); } // FIXME: maybe directly return id? as no default.. same for name
	function set_id( v:String ) :String { return setTrait("id",v); } // FIXME: update document index?

	/** textual name of the Element
		("name" attribute) **/
	public var name(get_name,set_name):String;
	function get_name() :String { return getTrait("name",String); }
	function set_name( v:String ) :String { return setTrait("name",v); }

	/**
		Create a new, empty Element.
		
		If [traits] is given, it will be set using $xinf.traits.TraitAccess.setTraitsFromObject()$.
	*/
	public function new( ?traits:Dynamic ) :Void {
		super();
		_traits = { };
		_ptraits = { };
		_cache = { }
		listeners = new Hash<List<Dynamic->Void>>();
		if( traits!=null ) setTraitsFromObject(traits);
	}

	/**
		Return the element's XML tag name.
		
		FIXME: this needs rework. currently, tagName must be
		set "manually" by deriving classes. $xinf.xml.Binding$
		could/should take care of that.
	*/
	public function getTagName() :String {
		var cl:Class<Dynamic> = Type.getClass(this);
		while( cl!=null ) {
			if( Reflect.hasField(cl,"tagName") ) return Reflect.field(cl,"tagName");
			cl = Type.getSuperClass(cl);
		}
		return null;
	}

	override public function fromXml( xml:Xml ) :Void {
		super.fromXml( xml );
		setTraitsFromXml( xml );
		if( id!=null ) {
			ownerDocument.elementsById.set(id,this);
		}
	}
	
	override public function toXml() :Xml {
		var xml = Xml.createElement( getTagName() );
		for( name in Reflect.fields(_traits) ) {
			var def = getTraitDefinition(name);
			if( def!=null ) {
				var v = def.write( Reflect.field(_traits,name) );
				if( v.length>0 ) xml.set(name,v);
			}
		}
		for( child in mChildren ) {
			var c = child.toXml();
			if( c!=null ) xml.addChild(c);
		}
		return xml;
	}
		
	/********************/
	/* Traits functions */

	public function clearTraitsCache() {
		_cache = { };
	}

	function cacheTrait<T>( name:String, v:Dynamic, type:Class<T> ) :T {
		// resolve specials and cache in _cache
		if( Std.is(v,type) ) {
		} else if( Std.is(v,SpecialTraitValue) ) {
			var v2:SpecialTraitValue = cast(v);
			v = v2.get(name,type,this);
		} else
			throw( new TraitTypeException( name, this, v, type ) );
			
		Reflect.setField(_cache,name,v);
		return v;
	}
	
	/** see $xinf.traits.TraitAccess$.getTrait */
	public function getTrait<T>( name:String, type:Dynamic, ?presentation:Bool ) :T {
		var v:T = null;
		
		if( presentation!=false ) {
			// lookup cached value
			v = Reflect.field(_cache,name);
			if( v!=null ) return v;
		
			// lookup presentation value
			v = Reflect.field(_ptraits,name);
			if( v!=null ) return v;
		}
		
		// lookup XML attribute
		if( v==null )
			v = Reflect.field(_traits,name);
		
		// default.
		if( v==null ) {
			var def = getTraitDefinition(name);
			if( def!=null ) {
				v = def.getDefault();
			}
		}

		if( v!=null ) {
			cacheTrait( name, v, type );
		}

		return v;
	}

	/** see $xinf.traits.TraitAccess::setTrait$ */
	public function setTrait<T>( name:String, value:T ) :T {
		Reflect.setField(_traits,name,value);
		Reflect.setField(_cache,name,value);
		return value;
	}

	public function setPresentationTrait( name:String, value:Dynamic ) :Dynamic {
		Reflect.setField(_ptraits,name,value);
		return value;
	}

	/** see $xinf.traits.TraitAccess::setStyleTrait$
	
		On xinf.xml.XMLElement, there is no difference
		between get/setStyleTrait and get/setTrait,
		but $xinf.style.StyledElement$ makes the
		difference. */
	public function setStyleTrait<T>( name:String, value:T ) :T {
		return setTrait(name,value);
	}

	/** see $xinf.traits.TraitAccess::getStyleTrait$ */
	public function getStyleTrait<T>( name:String, type:Dynamic, ?inherit:Bool=true, ?presentation:Bool=true ) :T {
		return getTrait(name,type,presentation);
	}

	/** see $xinf.traits.TraitAccess::setTraitFromString$ */
	public function setTraitFromString( _name:String, value:String, to:Dynamic ) :Void {
/** REMOVEME SPECIAL_TRAITS
		if( value=="inherit" ) {
			Reflect.setField( to, name, Inherit.inherit );
			return;
		}
*/		
		var name = normalizeAttributeName(_name);
		var def = getTraitDefinition(name);
		// FIXME: maybe, see if it has a setter?
//		trace("set "+name+" to (string)'"+value+"' - parsed "+def.parse(value) );
		
		if( def!=null )
			Reflect.setField( to, name, def.parse(value) );
		else
			Reflect.setField( to, name, value );
	}

	/** see $xinf.traits.TraitAccess::setTraitFromDynamic$ */
	public function setTraitFromDynamic( _name:String, value:Dynamic, to:Dynamic ) :Void {
		var name = normalizeAttributeName(_name);
		var def = getTraitDefinition(name);
		if( def!=null )
			Reflect.setField( to, name, def.fromDynamic(value) );
		else
			Reflect.setField( to, name, value );
	}
	
	/** Set the traits of this Element from the 
		dynamic object [o].  
		Uses $xinf.style.StyleParser::fromObject$,
		so the field values of [o] can be of any
		type that can be converted by the respective
		$xinf.traits.TraitDefinition$. Usually,
		this includes String and the native type
		of the Trait. 
	*/
	public function setTraitsFromObject( o:Dynamic ) {
		StyleParser.fromObject(o,this,_traits);
	}
	
	/** Set the traits of this object from the
		given Xml's attribute values.
		
		Namespaces are currently ignored.
		Internally, this uses $xinf.xml.XMLElement::setTraitFromString$.
	*/
	public function setTraitsFromXml( xml:Xml ) {
		for( field in xml.attributes() ) {
			// for now, strip namespace...
			var f2:String = field;
			var a = field.split(":");
			if( a.length>1 ) f2 = a[a.length-1];
			setTraitFromString( f2, xml.get(field), _traits );
		}
	}

	static var AttrReg = ~/[\-_:]/g;
	inline function normalizeAttributeName( _name:String ) :String {
		var r = AttrReg.replace(_name,"").toLowerCase();
//		trace("normalizeAttributeName: "+_name+" --> "+r );
		return r;
 	}	
	/** Return the TraitDefinition of the trait named [_name],
		or [null] if this Element doesn't have such a trait.
	*/
	function getTraitDefinition( _name:String ) :TraitDefinition {
		var name = normalizeAttributeName(_name);
		var cl:Class<Dynamic> = Type.getClass( this );
		var t:TraitDefinition=null;
		while( t==null && cl!=null ) {
			t = getClassTrait( cl, name );
			cl = Type.getSuperClass(cl);
		}
		return t;
	}
	
	function getClassTrait( cl, name:String ) :TraitDefinition {
		var traits:Dynamic = Reflect.field(cl,"TRAITS");
		if( traits!=null ) return Reflect.field(traits,name);
		return null;
	}
	
	/*****************************/
	/* EventDispatcher functions */

	/** see $xinf.event.EventDispatcher::addEventListener$ */
	public function addEventListener<T>( type :EventKind<T>, h :T->Void ) :T->Void {
		var t = type.toString();
		var l = listeners.get( t.toString() );
		if( l==null ) {
			l = new List<Dynamic->Void>();
			listeners.set( t, l );
		}
		l.push( h );
		return h;
	}

	/** see $xinf.event.EventDispatcher::removeEventListener$ */
	public function removeEventListener<T>( type :EventKind<T>, h :T->Void ) :Bool {
		var l:List<Dynamic->Void> = listeners.get( type.toString() );
		if( l!=null ) {
			return( l.remove(h) );
		}
		return false;
	}

	/** Convenience function to remove all listeners
		of the given [type]. 
	*/
	public function removeAllListeners<T>( type :EventKind<T> ) :Bool {
		return( listeners.remove( type.toString() ) );
	}

	/** see $xinf.event.EventDispatcher::dispatchEvent$
	
		Do not use this function directly, instead use [postEvent()].
	*/
	public function dispatchEvent<T>( e : Event<T> ) :Void {
		var l:List<Dynamic->Void> = listeners.get( e.type.toString() );
		var dispatched:Bool = false;
		
		if( l != null ) {
			for( h in l ) {
				h(e);
				dispatched=true;
			}
		}
	}

	/** see $xinf.event.EventDispatcher::postEvent$ */
	public function postEvent<T>( e : Event<T>, ?pos:haxe.PosInfos ) :Void {
		// FIXME if debug_events
		e.origin = pos;
		
		// for now, FIXME (maybe, put them thru a global queue)
		dispatchEvent(e);
	}

	public function typedChildren<T>( cl:Class<T> ) :Iterator<T> {
		var i=-1;
		var children=mChildren;
		return({
			hasNext: function () :Bool {
				var j=i+1;
				while( j<children.length && !Std.is(children[j],cl) ) j++;
				return j<children.length;
			},
			next: function() :T {
				i++;
				while( i<children.length && !Std.is(children[i],cl) ) i++;
				if( i<children.length ) return cast(children[i]);
				return null;
			}});
	}

	public function getElementByName( name:String ) :XMLElement {
		for( child in typedChildren( XMLElement ) ) {
			if( child.name == name ) return child;
		}
		throw( "no child with name '"+name+"'" );
		return null;
	}
	
	public function getTypedElementByName<T>( name:String, cl:Class<T> ) :T {
		var r = getElementByName( name );
		if( !Std.is( r, cl ) ) throw("Element '"+name+"' is not of class "+Type.getClassName(cl)+" (but instead "+Type.getClassName(Type.getClass(r))+")" );
		return cast(r);
	}


	/******************/
	/* Node functions */

	override function acquired( newChild:Node ) :Void {
		if( newChild.parentElement != null ) {
			throw("child "+newChild+" is already attached to a parent ("+newChild.parentElement+", new "+this+")");
//			newChild.parentElement.removeChild(newChild);
		}
		newChild.parentElement = this;
		super.acquired(newChild);
	}
	
	override function copyProperties( to:Dynamic ) :Void {
		super.copyProperties( to );
		
		// copy traits
		to._traits = Reflect.copy(_traits);
		if( to._traits.id!=null ) to._traits.id+="'";
		
		// copy my event listeners
		to.listeners = new Hash<List<Dynamic->Void>>();
		for( e in listeners.keys() ) {
			var v = listeners.get(e);
			var l = new List<Dynamic->Void>();
			for( i in v ) {
				l.add(i);
			}
			to.listeners.set( e, l );
		}
	}
}
