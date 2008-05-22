/*  Copyright (c) the Xinf contributors.
	see http://xinf.org/copyright for license. */

package nekobind;

import haxe.rtti.Type;
import nekobind.type.TypeRep;

class HaxeImplGenerator extends Generator {
	private var globalInts:Array<String>;

	public function handleFunction( f:ClassField, args:Array<{ name:String, opt:Bool, t:Type, r:TypeRep }>, ret:TypeRep, functionSettings:Settings ) {
		var _this=this;
				
		if( f.name == "new" ) {
			// special case: new
			print("\tpublic function new() :Void { ");
			if( superClass != null ) print("super();");
			print(" }\n\n");
			return;
		}
		
		var self = !allGlobal;

		if( functionSettings.ctor=="true" ) {
			hxConstructor( f, args, ret );
			return;
		}
		if( functionSettings.isStatic ) self=false;

		var nArgs = args.length;
		if( self ) nArgs++;
		if( self || nArgs>Generator.CALL_MAX_ARGS ) {
			// load the primitive
			var n:Int = nArgs;
			if( n>Generator.CALL_MAX_ARGS ) n=1;
			print("\tprivate static var _"+f.name
				+" = neko.Lib.load(\""+settings.module+"\",\""
				+"bind_"+settings.className+"_"+f.name+"\", "+n+");\n");
			
			
			// haxe wrapper func
			print("\tpublic ");
			if( !self ) print("static ");
			print("function "+f.name+"( ");
				// function arguments
				iterateArguments( args, function( name, opt, t, r, last ) {
						_this.print( name+":"+r.asHaxe() );
						if( !last ) _this.print(", ");
					} );
			print(" ) ");
				// return value
				print( ":"+ret.asHaxe()+" " );
			print("{\n");
			
				// call the primitive
				print("\t\treturn _"+f.name+"( ");
				
				if( nArgs>Generator.CALL_MAX_ARGS ) {
					print("untyped [ ");
				} 
				// argument - self
				if( self ) {
					print( settings.nekoAbstract );
					if( args.length>0 ) print(", ");
				}
				// arguments
				iterateArguments( args, function( name, opt, t, r, last ) {
						_this.print( name );
						if( !last ) _this.print(", ");
					} );
					
				if( nArgs>Generator.CALL_MAX_ARGS ) {
					print(" ].__a ");
				} 
				
				print(" );\n");
			
			print("\t}\n\n");
		} else {
			// just loading the primitive does the trick for static funcions.
			var n:Int = args.length;
			if( n>Generator.CALL_MAX_ARGS ) n=-1;
			print("\tpublic static var "+f.name
				+" = neko.Lib.load(\""+settings.module+"\",\""
				+"bind_"+settings.className+"_"+f.name+"\", "+n+");\n");
		}
	}

	public function hxConstructor( f:ClassField, args:Array<{ name:String, opt:Bool, t:Type, r:TypeRep }>, ret:TypeRep ) {
		var _this=this;
		
		// load the primitive
		var n:Int = args.length;
		var nArgs = args.length;
		if( n>Generator.CALL_MAX_ARGS ) n=1;
		print("\tprivate static var _"+f.name
			+" = neko.Lib.load(\""+settings.module+"\",\""
			+"bind_"+settings.className+"_"+f.name+"\", "+n+");\n");
		
		// haxe wrapper func
		print("\tpublic static function "+f.name+"( ");
				// arguments
				iterateArguments( args, function( name, opt, t, r, last ) {
						_this.print( name );
						if( !last ) _this.print(", ");
					} );
		print(" ) ");
			// return value
			print( ":"+settings.className+"__impl " );
		print("{\n");
		
			// call the primitive
			print("\t\tvar self = new "+settings.className+"__impl();\n" );
			print("\t\tself."+settings.nekoAbstract+" = _"+f.name+"( ");
			
				if( nArgs>Generator.CALL_MAX_ARGS ) {
					print("untyped [ ");
				} 
				// arguments
				iterateArguments( args, function( name, opt, t, r, last ) {
						_this.print( name );
						if( !last ) _this.print(", ");
					} );
					
				if( nArgs>Generator.CALL_MAX_ARGS ) {
					print(" ].__a ");
				} 
			
			print(" );\n");
			print("\t\tif( self==null ) throw(\"Could not create "+settings.className+"\");\n");
			print("\t\treturn( self );\n");
		
		print("\t}\n\n");
	}
	
	public function hxGlobalInts( names:Array<String> ) :Void {
		var globals = CGlobalFinder.find( names, settings );
		
		for( global in globals.keys() ) {
			print("\tpublic static var "+global+":Int = "+globals.get(global)+";\n");
		}
		print("\n");
	}

	public function handleStaticVarClass( field:ClassField, className:String ) :Void {
		if( className=="Int" ) {
			globalInts.push( field.name );
		}
	}
	
	public function handleClass( e:TypeInfos, c:Class ) {
		globalInts = new Array<String>();
	
		print("/* haXe implementation class for "+e.path+" - generated by nekobind. do not edit directly */\n\n");
		
		parseSettings( settings, c.doc );
		if( settings.global == "true" ) {
			allGlobal = true;
		}
		settings.className = e.path.split(".").pop();

		// TODO: package, though maybe not

		print("/* nekobind class settings:\n   "+settings+"\n*/\n\n" );
		
		print("class "+settings.className+"__impl ");
		
		if( c.superClass != null )
			print(" extends "+c.superClass.path+" " );
		
		print( "{\n" );

			// abstract store
			if( settings.nekoAbstract!=null ) {
				print("\tprivate var "+settings.nekoAbstract+":Dynamic;\n\n");
			}

			super.handleClass( e, c );
	
			if( globalInts.length>0 )
				hxGlobalInts( globalInts );

			// export
			print("\tpublic static function __init__() :Void {\n");
			print("\t\tuntyped {\n");
				print("\t\t\t__dollar__exports."+settings.className+"__impl = "+settings.className+"__impl;\n");
			print("\t\t}\n\t}\n");
			
		print("}\n");
	}
}