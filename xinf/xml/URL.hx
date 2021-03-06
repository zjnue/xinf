/*  Copyright (c) the Xinf contributors.
	see http://xinf.org/copyright for license. */
	
package xinf.xml;

/**
	A URL/URI/IRI.
	
	Describes a "universal|internationalized resource locator|identifier".
	If you don't know (roughly) what that is, you're in the wrong movie.
	
	In terms of this class, a URL is built like: <br/>
	[<protocol>://<host>:<port>/<path>/<filename>]

	Fragments (#foo) and GET parameters (?foo=bar) are just part of the [filename] for now.

	$SVG linking#IRIReference$
*/
class URL {
	/** the protocol part of the URI, mostly "http" or "file" */
	public var protocol:String;
	
	/** the host part of the URI.
		if the URI describes a file:// reference,
		this is the first part of the path. */
	public var host:String;
	
	/** the port, if omitted it is automatically
		set for some protocols: 80 for http, 443 for https and 21 for ftp.
	*/
	public var port:Null<Int>;
	
	/** the path part of the URI*/
	public var path:String;
	
	/** the filename part of the URI */
	public var filename:String;

	/** create a new URL by parsing from [s] */
	public function new( s:String ) :Void {
		parse(s);
	}
	
	function parse( s:String ) :Void {
		var r:EReg = ~/([a-z]+):\/\/([a-zA-Z0-9-\.]*)(:([0-9]+))?(.*)/;
		
		if( s==null ) throw("URL is null");
		if( StringTools.startsWith( s, "data:" ) ) {
			protocol = "data";
			host=null;
			port=0;
			path=s.substr(5);
		} else if( r.match( s ) ) {
			protocol = r.matched(1);
			host = r.matched(2);
			port = Std.parseInt(r.matched(4));
			if( port==0 ) {
				switch(protocol) {
					case "http": port=80;
					case "https": port=443;
					case "ftp": port=21;
					default: port=0;
				}
			}
			path = r.matched(5);
			if( protocol=="file" ) {
				if( path!="" ) path=host+"/"+path; 
				else path=host;
				host=""; 
			}
		} else {
//			protocol="file";
			host=null;
			port=0;
			path=s;
		}
		if( path.charAt(path.length-1)!="/" ) {
			var p = path.split("/");
			filename = p.pop();
			path = p.join("/");
			if( p.length>0 ) path+="/";
		} else {
			filename="";
		}
	}
	
	/**
		Return a new URL that is the result of appending
		[rel] to this URL.
		
		Currently, this actually just appends it, leaving
		away the filename. A future	version should "compress" 
		[foo/../bar] into [bar], and also handle absolute
		URLs for rel. (TODO)
	*/
	public function getRelativeURL( rel:String ) :URL {
		var rel = new URL( rel );
		if( rel.isAbsolute() ) return rel;
		var url = new URL( this.pathString()+rel.path+rel.filename );
		return url;
	}
	
	public function isAbsolute() :Bool {
		return( path.charAt(0)=="/" || protocol=="data" );
	}

	/**
		Load the file referenced by this resource
		(potentially asynchronously), and call [onData] with the
		loaded text. If [onError] is given, it will be called in
		case of an error.
		
		On neko (Xinfinity), this also handles file:// URLs
		(by using neko.io.File.getContent).
	*/
	public function fetch( onData:String->Void, ?onError:String->Void ) {
	
		if( onError==null ) {
			var self=this;
			onError = function(e) { 
				trace("Error fetching document '"+self+"': "+e+"\n"
					+haxe.Stack.toString(haxe.Stack.exceptionStack()));
				#if neko
					neko.Sys.exit(-1);
				#end
					throw("Could not load document" );
			};
		}
		
		try {
		
		#if neko
			if( protocol=="file" || protocol==null ) {
				var data = neko.io.File.getContent( localPath() );
				onData( data );
				return;
			}
		#end

			if( protocol=="resource" ) {
				var rname = if( host!=null ) host+path+filename else path+filename;
				var data = haxe.Resource.getString( rname );
				if( data==null ) throw("Resource not found: "+rname );
				onData( data );
				return;
			}
	
			var request = new haxe.Http(toString());
			request.onError = onError;
			request.onData = onData;
			request.request(false);
		   
		} catch( e:Dynamic ) {
			if( onError!=null ) onError(e);
		}
		
	}

	public function localPath() :String {
		return path+filename;
	}
	
	/**
		Return a string representation of this URL up to but not including
		the filename part.
	*/
	public function pathString() :String {
		var h = "";
		if( protocol!=null ) {
			if( protocol=="data" ) {
				h = "data:";
			} else 
				h = protocol+"://";
		}
		if( host!=null ) {
			h = h+host;
		}
		if( port!=0 && port!=null ) {
			h = h+":"+port;
		}
		return( h+path );
	}

	static var BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	/**
		Return data, if this is a "data:" URL.
	*/
	public function getData() :String {
		if( protocol != "data" ) return null;
		
		var d = path.split(",");
		if( d.length!=2 ) throw("Unhandled data: URL: "+this );
		var format = d[0].split(";");
		if( format[format.length-1] != "base64" ) throw("data: URL of format "+format+" not understood. Can only handle base64.");
		var base64 = d[1];
//		trace("---"+base64+"---\n");
		throw("Where have all the StringTools.baseDecode gone?");
//		return( StringTools.baseDecode( base64, BASE64 ) );
throw("FIXME");
		return("");
	}
	
	/**
		Return a complete string representation of this URL.
	*/
	public function toString() :String {
		return( pathString()+filename );
	}
}
