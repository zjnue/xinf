package xinf.ony.base;
import xinf.ony.base.Implementation;

import xinf.xml.Binding;
import xinf.xml.Instantiator;

import xinf.traits.TraitDefinition;
import xinf.traits.FloatTrait;
import xinf.traits.StringTrait;
import xinf.traits.LengthTrait;

import xinf.style.StyleSheet;
import xinf.ony.URL;
import xinf.type.Length;

class Document extends GroupImpl {

	static var TRAITS = {
		x:new FloatTrait(),
		y:new FloatTrait(),
		width:new LengthTrait(),
		height:new LengthTrait(),
	}

    public var x(get_x,set_x):Float;
    function get_x() :Float { return getTrait("x",Float); }
    function set_x( v:Float ) :Float { retransform(); return setTrait("x",v); }
	
    public var y(get_y,set_y):Float;
    function get_y() :Float { return getTrait("y",Float); }
    function set_y( v:Float ) :Float { retransform(); return setTrait("y",v); }

	public var width(get_width,set_width):Float;
    function get_width() :Float { return getTrait("width",Length).value; }
    function set_width( v:Float ) :Float { setTrait("width",new Length(v)); return v; }
	
    public var height(get_height,set_height):Float;
    function get_height() :Float { return getTrait("height",Length).value; }
    function set_height( v:Float ) :Float { setTrait("height",new Length(v)); return v; }

    public var styleSheet(default,null):StyleSheet;
    public var elementsById(default,null):Hash<ElementImpl>;
	
	public function new( ?traits:Dynamic ) :Void {
        super( traits );
 		document = this;
        styleSheet = new StyleSheet();
        elementsById = new Hash<ElementImpl>();
    }

    public function getElementById( id:String ) :ElementImpl {
        var r = elementsById.get(id);
        if( r==null ) throw("No such Element #"+id );
        return r;
    }

	public function getTypedElementById<T>( id:String, cl:Class<T> ) :T {
        var r = getElementById( id );
		if( !Std.is( r, cl ) ) throw("Element #"+id+" is not of class "+Type.getClassName(cl)+" (but instead "+Type.getClassName(Type.getClass(r))+")" );
        return cast(r);
    }
	
	public function getElementByURI( uri:String ) :ElementImpl {
		var u = uri.split("#");
		if( u.length!=2 ) throw("invalid URI, or URI doesn't include fragment identifier: "+uri );
		if( u[0] != "" ) throw("full URIs are not yet supported");
		var id = u[1];
		return getElementById( id );
	}
	
	public function getTypedElementByURI<T>( uri:String, cl:Class<T> ) :T {
        var r = getElementByURI( uri );
		if( !Std.is( r, cl ) ) throw("Element "+uri+" is not of class "+Type.getClassName(cl)+" (but instead "+Type.getClassName(Type.getClass(r))+")" );
        return cast(r);
	}

    override public function fromXml( xml:Xml ) :Void {
        super.fromXml(xml);

		// for now...
        if( xml.exists("viewBox") ) {
            var vb = xml.get("viewBox").split(" ");
            if( vb.length != 4 ) {
                throw("illegal/unsupported viewBox: "+vb );
            }
            width = Std.parseInt( vb[2] );
            height = Std.parseInt( vb[3] );
        }
    }

    public function unmarshal( xml:Xml, ?parent:Group ) :ElementImpl {
        var r = binding.instantiate( xml );
        if( r==null ) return null;
        
        r.document = this; // FIXME | why?
        r.fromXml( xml );

		if( r.id!=null ) {
            elementsById.set( r.id, r );
        }
		
        if( parent!=null ) parent.attach(r);
		
        return r;
    }

    override public function attachedTo( p:Group ) :Void {
        super.attachedTo(p);
        document=this;
    }

    public static function overrideBinding( nodeName:String, cl:Class<ElementImpl> ) :Void {
        binding.add( nodeName, cl );
    }
    
    public static function addInstantiator( i:Instantiator<ElementImpl> ) :Void {
        binding.addInstantiator( i );
    }

	public static function instantiate( data:String, ?onLoad:DocumentImpl->Void, ?parent:DocumentImpl ) :DocumentImpl {
        var doc = new DocumentImpl(parent);
		var xml = Xml.parse(data);
		doc.fromXml( xml.firstElement() );
		doc.onLoad();
		if( onLoad!=null ) onLoad( doc );
		return doc;
	}
	
    public static function load( url_s:String, ?onLoad:DocumentImpl->Void ) :DocumentImpl {
        var doc = new DocumentImpl();
        var url = new URL(url_s);
        doc.base = url.pathString();
        url.fetch( function(data) {
                var xml = Xml.parse(data);
                doc.fromXml( xml.firstElement() );
				doc.onLoad();
                if( onLoad!=null ) onLoad( doc );
            }, function( error ) {
                throw(error);
            } );
        return doc;
    }
	
	static var binding:Binding<ElementImpl>;
}