//
//		 ______  _________  ________  ________   ___  __    ___                                                      
//		|\   ___\\___   ___\\   __  \|\   ___  \|\  \|\  \ |\  \                                                     
//		\ \  \__\|___ \  \_\ \  \|\  \ \  \\ \  \ \  \/  /|\ \  \                                                    
//		 \ \  \      \ \  \ \ \   __  \ \  \\ \  \ \   ___  \ \  \                                                   
//		  \ \  \____  \ \  \ \ \  \ \  \ \  \\ \  \ \  \\ \  \ \  \                                                  
//		   \ \______\  \ \__\ \ \__\ \__\ \__\\ \__\ \__\\ \__\ \__\                                                 
//		    \|______|   \|__|  \|__|\|__|\|__| \|__|\|__| \|__|\|__|                                                 
//		                                                                                                             
//		                                                                                                             
//		                                                                                                             
//		                 ________  _______   ___       ________  ________  ________  _______   ________  ______      
//		                |\   __  \|\  ___ \ |\  \     |\   __  \|\   __  \|\   ___ \|\  ___ \ |\   ___ \|\___   \    
//		                \ \  \|\  \ \   __/|\ \  \    \ \  \|\  \ \  \|\  \ \  \_|\ \ \   __/|\ \  \_|\ \|___|\  \   
//		                 \ \   _  _\ \  \_|/_\ \  \    \ \  \\\  \ \   __  \ \  \ \\ \ \  \_|/_\ \  \ \\ \   \ \  \  
//		                  \ \  \\  \\ \  \_|\ \ \  \____\ \  \\\  \ \  \ \  \ \  \_\\ \ \  \_|\ \ \  \_\\ \  _\_\  \ 
//		                   \ \__\\ _\\ \_______\ \_______\ \_______\ \__\ \__\ \_______\ \_______\ \_______\|\______\
//		                    \|__|\|__|\|_______|\|_______|\|_______|\|__|\|__|\|_______|\|_______|\|_______|\|______|
//		                                                                                                             
//		                                                                                                             
//		                                                                                                             
//			Why are you looking at the source code? If you want to improve the game,
//			click the message button at the bottom of the page on our website.
//
//								Maybe released under GNU GPL v3?
//
package {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	public class Main extends Sprite {
		public function Main() {
			progressBar = new ProgressBar(0, 0, 320, 40);
			this.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent):void {
				progressBar.update(progress / itemsLoading);
			});
			/*var rectangle:Sprite = new Sprite();
			rectangle.graphics.beginFill(0xFF0000);
			rectangle.graphics.drawRect(0, 0, 100,100);
			rectangle.graphics.endFill();
			addChild(rectangle);*/
			loadTARA('../../library/CityBuildings.tara');
			//loadMap('');
		}
		private var itemsLoading:int;
		private var progress:Number;
		private var progressBar:ProgressBar;
		private var configuration = <configuration/>;
		public function loadTARA(file:String):void {
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			var localProgress:Number;
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				progress -= localProgress;
				progress += 0.5;
				
				var tara:ByteArray = e.target.data;
				var numFiles:int = tara.readInt();
				var fileNames:Array = new Array();
				var files:Array = new Array();
				for (var i:int = 0; i < numFiles; i++) {
					fileNames.push(tara.readMultiByte(tara.readUnsignedShort(), 'us-ascii'));
					files.push(tara.readUnsignedInt());
				}
				for (i = 0; i < numFiles; i++) {
					var file:ByteArray = new ByteArray();
					tara.readBytes(file, 0, files[i]);
					files[i] = file;
				}
				var library:XML = new XML(files[fileNames.indexOf('library.xml')]);
				ExternalInterface.call('alert', library.toString());
				//when fully parsed, add 0.5 to progress
				progress += 0.5;
				this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
			});
			loader.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent):void {
				progress -= localProgress;
				localProgress = e.bytesLoaded / e.bytesTotal / 2;
				progress += localProgress;
				this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
			});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
				progress -= localProgress;
				this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
				//report/fix error
			});
			itemsLoading++;
			loader.load(new URLRequest(file));
		}
		public function loadMap(map:String, oldConfiguration:Boolean = true):void {
			//auto-loads map.xml and config.xml in ../../
			if (oldConfiguration) {
				
			} else {
				//parse the new library format
			}
		}
	}
}
import flash.display.Sprite;
class ProgressBar {
	public var top:Sprite = new Sprite();
	public var bottom:Sprite = new Sprite();
	public function ProgressBar(x:int, y:int, w:int, h:int):void {
		setPos(x, y);
		setSize(w, h);
	}
	private function redrawTop():void {
		top.graphics.clear();
		top.graphics.beginFill(0x00FF00);
		top.graphics.drawRect(top.x, top.y, top.width, top.height);
		top.graphics.endFill();
	}
	public function setPos(x:int, y:int):void {
		top.x = x;
		bottom.x = x;
		top.y = y;
		bottom.y = y;
	}
	public function setSize(w:int, h:int):void {
		bottom.width = w;
		top.height = h;
		bottom.height = h;
		redrawTop();
		bottom.graphics.clear();
		bottom.graphics.beginFill(0x3F3F3F);
		bottom.graphics.drawRect(bottom.x, bottom.y, bottom.width, bottom.height);
		bottom.graphics.endFill();
	}
	public function update(percent:Number):void {
		top.width = bottom.width * percent;
		redrawTop();
	}
}