/*  Copyright (c) the Xinf contributors.
	see http://xinf.org/copyright for license. */

import xinf.ony.erno.Svg;
import xinf.ony.erno.Embed;
import xinf.geom.Scale;
import xinf.xml.Document;

class FlashSvgViewer {

	public static function main() {

		var args:Dynamic = flash.Lib.current.root.loaderInfo.parameters;

		var stage = flash.Lib.current.stage;
		var menu = new flash.ui.ContextMenu();
		flash.Lib.current.contextMenu = menu;
		var aboutItem = new flash.ui.ContextMenuItem("About Xinf SVG Viewer "+xinf.Version.version+" (r"+xinf.Version.revision+")..." );
		//aboutItem.addEventListener( flash.events.ContextMenuEvent.MENU_ITEM_SELECT, function(e) {
		//		flash.Lib.getURL( new flash.net.URLRequest("http://xinf.org/trac/wiki/SvgViewer") );
		//	});
		menu.customItems.push( aboutItem );

		var bgColor = if( args.backgroundColor!=null ) Std.parseInt( args.backgroundColor ) else 0xffffff;
		var loadMessageColor = if( args.loadMessageColor!=null ) Std.parseInt( args.loadMessageColor ) else 0x333333;
		var loadMessage = if( args.loadMessage!=null ) args.loadMessage else "Loading...";
	
		var bg = new flash.display.Shape();
			bg.graphics.beginFill( bgColor );
			bg.graphics.moveTo(0,0);
			bg.graphics.lineTo(100,0);
			bg.graphics.lineTo(100,100);
			bg.graphics.lineTo(0,100);
			bg.graphics.endFill();
			flash.Lib.current.addChild( bg );
			bg.width = stage.stageWidth;
			bg.height = stage.stageHeight;
		
		var message = new flash.text.TextField();
			message.textColor=loadMessageColor;
			var format = message.getTextFormat();
			format.font = "_sans";
			message.defaultTextFormat = format;
			message.selectable = false;
			message.autoSize = flash.text.TextFieldAutoSize.NONE;
			message.wordWrap=true;
			message.mouseEnabled = false;
			message.text=loadMessage;
			message.x = message.y = 10;
			flash.Lib.current.addChild( message );
			message.width=message.stage.stageWidth-20;
			message.height=message.stage.stageHeight-20;

		var mc = new flash.display.Sprite();
		flash.Lib.current.addChild( mc );
		
		var embed = new Embed( mc );
		
		var onError = function(e:String) {
			message.text = "Could not load SVG source.\n"+e;
		};

		try {
			if( args==null || args.src==null ) {
				//throw("No document source given.");
				args = { src:"http://upload.wikimedia.org/wikipedia/commons/f/fd/Ghostscript_Tiger.svg" };
			}
			
			Document.load( args.src, function(doc:Svg) {
			
				flash.Lib.current.removeChild( message );
				
				var scale = function(?e:Dynamic) {
					// scale to stage size
					if( doc.width>0 && doc.height>0 )
						doc.transform = new Scale( mc.stage.stageWidth/doc.width,
													mc.stage.stageHeight/doc.height );
					bg.width = mc.stage.stageWidth;
					bg.height = mc.stage.stageHeight;
					message.width = mc.stage.stageWidth-20;
					message.height = mc.stage.stageHeight-20;
				};
				
				mc.stage.addEventListener( flash.events.Event.RESIZE, scale );
				scale();
				embed.appendChild( doc );
			
			}, onError, Svg );
			
			xinf.anim.TimeRoot.start();
			xinf.ony.Root.main();
		} catch(e:Dynamic) {
			onError(""+e);
		}
	}
}
