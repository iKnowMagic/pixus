﻿// pixus class
// Version 0.9.1 2008-12-30
// (cc)2007-2008 codeplay
// By Jam Zhang
// jam@01media.cn

package {
	import flash.display.NativeWindow;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindowDisplayState;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	import flash.desktop.DockIcon;
	import flash.desktop.SystemTrayIcon;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.events.ScreenMouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.geom.Point;
	import flash.net.SharedObject;
	import caurina.transitions.Tweener;
	import codeplay.event.customEvent;

	public class pixus extends MovieClip {
		const MARGIN_LEFT:uint=25;
		const MARGIN_TOP:uint=150;
		const MARGIN_RIGHT:uint=60;
		const MARGIN_BOTTOM:uint=200;

		public var shell:pixusShell;
//		var options:Object=SharedObject.getLocal('preferences',pixusShell.APP_PATH).data;

		function pixus(pshell:pixusShell):void {
			shell=pshell;
			addEventListener(Event.ADDED_TO_STAGE, handleInit);
		}

		public function handleInit(event:Event):void {

			stage.scaleMode=StageScaleMode.NO_SCALE;
			stage.align=StageAlign.TOP_LEFT;
			stage.nativeWindow.minSize=new Point(210,50);
			NativeApplication.nativeApplication.addEventListener(pixusShell.EVENT_FIND_BACK,handleFindBack);

			// Default settings
			if (pixusShell.options.width==undefined) {
				pixusShell.options.width=480;
			}
			main.rulerWidth=pixusShell.options.width;
			if (pixusShell.options.height==undefined) {
				pixusShell.options.height=360;
			}
			main.rulerHeight=pixusShell.options.height;

			if (pixusShell.options.x==undefined) {
				pixusShell.options.x=120;
			}
			if (pixusShell.options.y==undefined) {
				pixusShell.options.y=80;
			}
			overlay.move(main.x=pixusShell.options.x,main.y=pixusShell.options.y);

			if (pixusShell.options.overlayMode==undefined) {
				pixusShell.options.overlayMode=false;
			}
			if (pixusShell.options.overlayMode) {
				pixusShell.options.overlayMode=false;
				toggleOverlay();
			}

			// Handles Menu And Closes The Primary Window
			NativeApplication.nativeApplication.addEventListener(customEvent.SET_WINDOW_SIZE,handleWindowSize);
			shell.stage.nativeWindow.close();
			stage.nativeWindow.maximize();
			addEventListener(KeyboardEvent.KEY_DOWN,handleKeys);

		}

		function set rulerWidth(w:int){
			main.rulerWidth=pixusShell.options.width=w;
		}

		function set rulerHeight(h:int){
			main.rulerHeight=pixusShell.options.height=h;
		}

		function startMove():void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE,handleMouse);
			stage.addEventListener(MouseEvent.MOUSE_UP,handleMouse);
			main.startDrag();
		}

		function handleKeys(event:KeyboardEvent) {
			trace('handleKeys');
		}

		function handleWindowSize(event:customEvent) {
			rulerWidth=event.data.width;
			rulerHeight=event.data.height;
		}

		// pixus handle finding back of the pixus window
		function handleFindBack(event:customEvent) {
			var w1:int=main.rulerWidth;
			var h1:int=main.rulerHeight;
			if(main.rulerWidth>stage.nativeWindow.width*.8)
				main.rulerWidth=w1=stage.nativeWindow.width*.5;
			if(main.rulerHeight>stage.nativeWindow.height*.8)
				main.rulerHeight=h1=stage.nativeWindow.height*.5;
			
			Tweener.addTween(main,{x:int((stage.nativeWindow.width-w1)*.5),time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic'});
			Tweener.addTween(main,{y:int((stage.nativeWindow.height-h1)*.5),time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic'});
			Tweener.addTween(overlay.themask.inner,{x:int((stage.nativeWindow.width-w1)*.5),time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic'});
			Tweener.addTween(overlay.themask.inner,{y:int((stage.nativeWindow.height-h1)*.5),time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic'});
		}

		function handleMouse(event:MouseEvent) {
			switch (event.type) {
				case MouseEvent.MOUSE_MOVE :
					overlay.move(main.x,main.y);
					break;
				case MouseEvent.MOUSE_UP :
					stage.removeEventListener(MouseEvent.MOUSE_MOVE,handleMouse);
					stage.removeEventListener(MouseEvent.MOUSE_UP,handleMouse);
					main.stopDrag();
					if (stage==null) {
						break;
					}
					pixusShell.options.x=main.x+stage.nativeWindow.x;// Because nativeWindow.x==-2 when maximized
					pixusShell.options.y=main.y+stage.nativeWindow.y;// Because nativeWindow.x==-4 when maximized
					break;
			}
		}

		function toggleOverlay():void {
			if (pixusShell.options.overlayMode) {
				pixusShell.options.overlayMode=overlay.visible=false;
			} else {
				pixusShell.options.overlayMode=overlay.visible=true;
			}
		}

		function syncWindowWidth(w:int):void {
			overlay.overlayWidth=w;
//			if (!pixusShell.options.overlayMode) {
//				stage.nativeWindow.width=w+MARGIN_RIGHT;
//			}
		}

		function syncWindowHeight(h:int):void {
			overlay.overlayHeight=h;
//			if (!pixusShell.options.overlayMode) {
//				stage.nativeWindow.height=h+MARGIN_BOTTOM;
//			}
		}

	}
}