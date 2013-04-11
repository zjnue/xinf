/*  Copyright (c) the Xinf contributors.
	see http://xinf.org/copyright for license. */
	
package xinf.erno.js;

import xinf.erno.SimpleRuntime;
import xinf.erno.Renderer;
import xinf.event.FrameEvent;

class JSRuntime extends SimpleRuntime {
	
	public static var defaultRoot:NativeContainer;
	private var frame:Int;
	private var _eventSource:JSEventSource;
	
	public function new() :Void {
		super();
		_eventSource = new JSEventSource(this);
		frame=0;
	}
	
	override public function getDefaultRoot() :NativeContainer {
		if( defaultRoot==null ) {
			defaultRoot = js.Lib.document.createElement("div");
			
			#if !no_canvas
			defaultRoot.style.overflow = "hidden";
			defaultRoot.style.position = "absolute";
			defaultRoot.style.left = ""+xinf.erno.js.JSRenderer.CANVAS_OFFSET_X+"px";
			defaultRoot.style.top = ""+xinf.erno.js.JSRenderer.CANVAS_OFFSET_Y+"px";
			defaultRoot.style.width = ""+xinf.erno.js.JSRenderer.CANVAS_WIDTH+"px";
			defaultRoot.style.height = ""+xinf.erno.js.JSRenderer.CANVAS_HEIGHT+"px";
			#end
			
			js.Lib.document.body.appendChild(defaultRoot);
		}
		return defaultRoot;
	}
	
	override public function run() :Void {
		_eventSource.rootResized(null);
		 untyped window.setInterval("xinf.erno.Runtime.getRuntime().step()",1000/25);
	   }
	   
	public function step() :Void {
		postEvent( new FrameEvent( FrameEvent.ENTER_FRAME, frame++, 0 ) ); // FIXME time
	}
	
}