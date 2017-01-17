package {
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	public class Button {
		private var img:Loader;
		private var hover:Loader;
		public var down:Loader;
		private var This:Sprite;
		private var isdown:Boolean = false;
		public function Button(Thisa:Sprite, Name:String, X:int, Y:int):void {
			img = new Loader();
			hover = new Loader();
			down = new Loader();
			img.x = X;
			img.y = Y;
			hover.x = X;
			hover.y = Y;
			down.x = X;
			down.y = Y;
			This = Thisa;
			img.load(new URLRequest(Name+'.png'));
			hover.load(new URLRequest(Name+'Hover.png'));
			down.load(new URLRequest(Name+'Down.png'));
			This.addChild(img);
			img.addEventListener(MouseEvent.MOUSE_OVER, MouseOver);
			This.stage.addEventListener(MouseEvent.MOUSE_UP, Reset);
			hover.addEventListener(MouseEvent.MOUSE_OUT, MouseOut);
			hover.addEventListener(MouseEvent.MOUSE_DOWN, MouseDown);
			down.addEventListener(MouseEvent.MOUSE_OUT, MouseOut);
			down.addEventListener(MouseEvent.MOUSE_UP, Reseta);
		}
		private function MouseOver(e:Event = null):void {
			if (isdown) {
				This.removeChild(img);
				This.addChild(down);
			} else {
			This.removeChild(img);
			This.addChild(hover);
			}
		}
		private function MouseOut(e:Event = null):void {
			if (isdown) {
				if(This.contains(down)) {This.removeChild(down);}
				This.addChild(img);
			} else {
			if(This.contains(hover)) {This.removeChild(hover);}
			This.addChild(img);
			}
		}
		private function MouseDown(e:Event = null):void {
			isdown = true;
			This.removeChild(hover);
			This.addChild(down);
		}
		private function Reset(e:Event):void {
			isdown = false;
		}
		private function Reseta(e:Event):void {
			var timer:Timer = new Timer(100);
			var finish:Function = function(e:Event = null):void {
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, finish);
				timer = null;
				isdown = false;
				This.removeChild(down);
				This.addChild(img);
			}
			timer.addEventListener(TimerEvent.TIMER, finish);
			timer.start();
		}
		public function Destroy():void {
			if (This.contains(img)) This.removeChild(img);
			if (This.contains(hover)) This.removeChild(hover);
			if (This.contains(down)) This.removeChild(down);
			img.removeEventListener(MouseEvent.MOUSE_OVER, MouseOver);
			This.stage.removeEventListener(MouseEvent.MOUSE_UP, Reset);
			hover.removeEventListener(MouseEvent.MOUSE_OUT, MouseOut);
			hover.removeEventListener(MouseEvent.MOUSE_DOWN, MouseDown);
			down.removeEventListener(MouseEvent.MOUSE_OUT, MouseOut);
			down.removeEventListener(MouseEvent.MOUSE_UP, Reseta);
			img = null;
			hover = null;
			down = null;
			This = null;
		}
	}
}