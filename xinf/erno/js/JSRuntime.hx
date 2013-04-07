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
			defaultRoot.style.left = "0px";
			defaultRoot.style.top = "0px";
			defaultRoot.style.width = "900px";
			defaultRoot.style.height = "900px";
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