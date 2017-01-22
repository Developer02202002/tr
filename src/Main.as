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
	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.loaders.Parser3DS;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	public class Main extends Sprite {
		private var camera:Camera3D;
		private var stage3d:Stage3D;
		private var scene:Object3D;
		private var controller:SimpleObjectController;
		public function Main() {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.BEST;
			camera = new Camera3D(0.1, 1000000);
			camera.view = new View(800, 600, false, 0x007FFF, 0, 4);
			//camera.view.hideLogo();
			addChild(camera.view);
			addChild(camera.diagram);
			scene = new Object3D();
			scene.addChild(camera);
			addEventListener(Event.RESIZE, function(e:Event):void {
				camera.view.width = stage.stageWidth;
				camera.view.height = stage.stageHeight;
			});
			stage3d = stage.stage3Ds[0];
			stage3d.addEventListener(Event.CONTEXT3D_CREATE, init);
			stage3d.requestContext3D();
		}
		public function init(e:Event):void {
			stage3d.removeEventListener(Event.CONTEXT3D_CREATE, init);
			this.addEventListener(Event.ENTER_FRAME, render);
			progressBar = new ProgressBar(0, 0, 320, 40);
			this.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent):void {
				progressBar.update(progress / itemsLoading);
				if (progress == itemsLoading) {
					var map:XML = configuration.map.(@name == curMap).children();
					ExternalInterface.call('alert', 'hey');
				}
			});
			/*var rectangle:Sprite = new Sprite();
			rectangle.graphics.beginFill(0xFF0000);
			rectangle.graphics.drawRect(0, 0, 100,100);
			rectangle.graphics.endFill();
			addChild(rectangle);*/
			loadMap('Serpuhov');
			camera.setPosition( -50, -300, 100);
			controller = new SimpleObjectController(stage, camera, 200);
			controller.lookAtXYZ(0, 0, 0);
			var box:Box = new Box(1, 1, 1);
			box.setMaterialToAllSurfaces(new FillMaterial(0));
			scene.addChild(box);
			uploadResources();
		}
		public function render(e:Event):void {
			controller.update();
			camera.render(stage3d);
		}
		public function uploadResources():void {//this function is NOT permanent
			for each(var res:Resource in scene.getResources(true)) {
				res.upload(stage3d.context3D);
			}
		}
		private var itemsLoading:int=0;
		private var progress:int=0;
		private var progressBar:ProgressBar;
		private var curMap:String;
		private var configuration:XML = <configuration/>;//old libs
		private var proplib:Dictionary = new Dictionary();//old lib setup
		private var assetlib:Dictionary = new Dictionary();//new lib setup
		public function initTexture(libName:String, propGroupName:String, propName:String, texName:String, data:ByteArray):void {
			itemsLoading++;
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, function(e:Event):void {
				var bmp:BitmapData = new BitmapData(loader.content.width, loader.content.height);
				bmp.draw(loader);
				proplib[libName][propGroupName][propName][1][texName] = new FillMaterial(Math.random()*0xFFFFFF);//new TextureMaterial(new BitmapTextureResource(bmp));
				progress++;
				this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
			});
			loader.loadBytes(data);
		}
		public function initProp(libName:String, propGroupName:String, propName:String, fileName:String, data:ByteArray, defTex:Boolean):void {
			itemsLoading++;
			var parser:Parser3DS = new Parser3DS();
			parser.parse(data);
			var mesh:Mesh;
			for each(var obj:Object3D in parser.objects) {
				if (obj.name == fileName) {
					mesh = obj as Mesh;
					break;
				}
			}
			proplib[libName][propGroupName][propName][0] = mesh;
			if (defTex) {//find texture name from mesh, then load it
				proplib[libName][propGroupName][propName][1]['default'] = new FillMaterial(0xFF0000);
			}
			progress++;
		}
		public function loadTARA(file:String):void {
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			var localProgress:Number;
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				progress -= localProgress;
				progress += 0.5;
				
				var tara:ByteArray = e.target.data;
				var numFiles:int = tara.readInt();
				var a:Array = new Array();
				var b:Array = new Array();
				var files:Dictionary = new Dictionary();
				for (var i:int = 0; i < numFiles; i++) {
					a.push(tara.readMultiByte(tara.readUnsignedShort(), 'us-ascii'));
					b.push(tara.readUnsignedInt());
				}
				for (i = 0; i < numFiles; i++ ) {
					var file:ByteArray = new ByteArray();
					tara.readBytes(file, 0, b[i]);
					files[a[i]] = file;
				}
				var library:XML = new XML(files['library.xml']);
				var libName:String = library.@name.toString();
				proplib[libName] = new Dictionary();
				for each(var propgroup:XML in library.children()) {
					var propGroupName:String = propgroup.@name.toString();
					proplib[libName][propGroupName] = new Dictionary();
					for each(var prop:XML in propgroup.children()) {
						var propName:String = prop.@name.toString();
						if (prop.mesh.length()) {
							proplib[libName][propGroupName][propName] = new Array(0, new Dictionary());
							var defTex:Boolean = true;
							if (prop.texture.length()) {
								defTex = false;
								for each(var tex:XML in prop.texture) {
									initTexture(libName, propGroupName, propName, tex.@name.toString(), files[tex['@diffuse-map'].toString()]);
								}
							}
							initProp(libName, propGroupName, propName, prop.mesh.@file.toString().slice(0,-4), files[prop.mesh.@file.toString()], defTex);
						} else {
							//object is a sprite
						}
					}
				}
				progress += 0.5;
				dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
			});
			loader.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent):void {
				progress -= localProgress;
				localProgress = e.bytesLoaded / e.bytesTotal / 2;
				progress += localProgress;
				dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
			});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
				progress -= localProgress;
				dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
				//report/fix error
			});
			itemsLoading++;
			loader.load(new URLRequest(file));
		}
		public function loadMap(map:String, oldConfiguration:Boolean = true):void {
			curMap = map;
			//auto-loads map.xml and config.xml in ../
			if (oldConfiguration) {
				itemsLoading+=2;
				var configLoader:URLLoader = new URLLoader();
				var mapLoader:URLLoader = new URLLoader();
				configLoader.addEventListener(Event.COMPLETE, function(e:Event):void {
					configuration.appendChild(new XML(e.target.data));
					for each(var proplib:XML in configuration.config.proplibs.children()) {
						loadTARA('../'+proplib.@url.toString());
					}
					//load turrets, hulls, and animations
					progress++;
				});
				mapLoader.addEventListener(Event.COMPLETE, function(e:Event):void {
					var map:XML = new XML(e.target.data);
					map.@name = curMap;
					configuration.appendChild(map);
					var timer:Timer = new Timer(2000);
					timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
						timer.stop();
						for each(var propXML:XML in configuration.map.(@name == curMap)['static-geometry'].prop) {
							var prop:Array = proplib[propXML['@library-name'].toString()][propXML['@group-name'].toString()][propXML.@name.toString()];
							try{if (prop[0] != null) {
								var x:Number = propXML.position.x;
								var y:Number = propXML.position.y;
								var z:Number = propXML.position.z;
								var rx:Number = 0;
								var ry:Number = 0;
								var rz:Number = 0;
								if (propXML.rotation.x.length()) rx = propXML.rotation.x;
								if (propXML.rotation.y.length()) ry = propXML.rotation.y;
								if (propXML.rotation.z.length()) rz = propXML.rotation.z;
								var mesh:Mesh = prop[0].clone();
								mesh.x = x;
								mesh.y = y;
								mesh.z = z;
								mesh.rotationX = rx;
								mesh.rotationY = ry;
								mesh.rotationZ = rz;
								if (propXML['texture-name'].length()) {
									mesh.setMaterialToAllSurfaces(prop[1][propXML['texture-name']]);
								} else {
									mesh.setMaterialToAllSurfaces(prop[1]['default']);
								}
								mesh.setMaterialToAllSurfaces(new FillMaterial(Math.random() * 0xFFFFFF));
								scene.addChild(mesh);
							}} catch(e:Error) {}
						}
						uploadResources();
					});
					timer.start();
					progress++;
				});
				configLoader.load(new URLRequest('../config.xml'));
				mapLoader.load(new URLRequest('../map.xml'));
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