/*  Copyright (c) the Xinf contributors.
	see http://xinf.org/copyright for license. */

package openvg;

class DLLLoader {
	public static var loaded:Hash<Bool>;

	public static function getHaxelibPath() :String {
		switch( neko.Sys.systemName() ) {
			case "Windows":
				var haxepath = neko.Sys.getEnv("HAXEPATH");
				if( haxepath==null ) {
					throw "HAXEPATH environment variable not defined, please install haXe";
				}
				return haxepath+"\\lib\\";
				
			default:
				var config = neko.Sys.getEnv("HOME")+"/.haxelib";
				try {
					return neko.io.File.getContent(config);
				} catch( e : Dynamic ) {
					try {
						return neko.io.File.getContent("/etc/.haxelib");
					} catch( e : Dynamic )
						throw "haxelib seems not to be correctly installed. run 'haxelib setup'";
				}
		}
		return null;
	}

	public static function getXinfLibPath() :String {
		var pathSep = "/";
		if( neko.Sys.systemName()=="Windows" ) pathSep = "\\";
		var libPath = getHaxelibPath()+pathSep+"openvg";
		var version = neko.io.File.getContent( libPath+pathSep+".current" );
		version = version.split(".").join(",");
		libPath += pathSep+version+pathSep+"ndll"+pathSep+neko.Sys.systemName();
		return libPath;
	}

	public static function addToEnvironment( name:String, separator:String, value:String ) {
		var cur = neko.Sys.getEnv(name);
		if( cur==null || cur.length==0 )
			cur = value;
		else
			cur = value+separator+cur;
			
		neko.Sys.putEnv( name, cur );
		trace("Environment: "+name+" now: "+cur );
	}
	
	public static function checkEnvironment( name:String, separator:String, value:String ) {
		var value = StringTools.replace( StringTools.replace( value, "//", "/" ), "\\\\", "\\" );
	
		var cur = neko.Sys.getEnv(name);
		if( cur!=null ) {
			var a = cur.split(separator);
			for( i in a ) {
				if( i==value ) return;
			}
		}
		
		addToEnvironment(name,separator,value);
	}

	public static function addLibToPath( lib:String ) :Void {
		if( loaded==null ) loaded = new Hash<Bool>();
		if( loaded.get(lib) ) return;

		var libPath = getXinfLibPath();

		switch( neko.Sys.systemName() ) {
			case "Windows":
				checkEnvironment("PATH",";",libPath);
			case "Mac":
				checkEnvironment("DYLD_LIBRARY_PATH",":",libPath);
			default:
		}
		
		loaded.set( lib, true );
	}
}
