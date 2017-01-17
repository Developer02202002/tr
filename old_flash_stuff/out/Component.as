package out {
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.loaders.Parser3DS;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	public class Component extends Sprite {
		public var meshes:Vector.<Mesh> = new Vector.<Mesh>();
		private var toLoad:int = 0;
		private var pos:int;
		public function Component():void {}
		public function load(index:int, base:String, prop:XML, x:Number, y:Number, z:Number, rx:Number, ry:Number, rz:Number, tex:String):void {
			pos = index;
			meshes.push(new Box(1, 1, 1));
			meshes[0].setMaterialToAllSurfaces(new FillMaterial(0xff00ff));
			toLoad++;
			addMesh('library/Fort/tower_corner.3ds', x, y, z, rx, ry, rz);
		}
		private function loadMeshTexture(file:String, mesh:int):void {
			var loader:Loader = new Loader();
			var textureLoaded:Function = function(e:Event = null):void {
				var camo:BitmapData = new BitmapData(loader.width,loader.height);
				camo.draw(loader);
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, textureLoaded);
				meshes[mesh].setMaterialToAllSurfaces(new TextureMaterial(new BitmapTextureResource(camo)));
				toLoad--;
				if (!toLoad) dispatchEvent(new TREvent(TREvent.COMPONENT_LOADED, pos));
			}
			var LoadError:Function = function(e:Event = null):void {
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, LoadError);
				meshes[mesh].setMaterialToAllSurfaces(new TextureMaterial(new BitmapTextureResource(new BitmapData(1, 1, false, 0xFF007F00))));
				toLoad--;
				if (!toLoad) dispatchEvent(new TREvent(TREvent.COMPONENT_LOADED, pos));
				ExternalInterface.call('console.log','Error loading ' + file + ', replacing with blank texture.');
			}
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, textureLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, LoadError);
			loader.load(new URLRequest(file));
		}
		private function addMesh(file:String, x:Number, y:Number, z:Number, rx:Number, ry:Number, rz:Number):void {
			var loader:URLLoader = new URLLoader();
			var loaded:Function = function(e:Event):void {
				loader.removeEventListener(Event.COMPLETE, loaded);
				var parser:Parser3DS = new Parser3DS();
				parser.parse((e.target as URLLoader).data);
				for each(var object:Object3D in parser.objects) {
					var tempmesh:Mesh = object as Mesh;
					tempmesh.x = x;
					tempmesh.y = y;
					tempmesh.z = z;
					tempmesh.rotationX = rx;
					tempmesh.rotationY = ry;
					tempmesh.rotationZ = rz;
					tempmesh.setMaterialToAllSurfaces(new FillMaterial(0xFFFFFF * Math.random()));
					meshes.push(tempmesh);
					loadMeshTexture('library/Fort/tow_cor.jpg',meshes.length-1);
				}
			}
			var er:Function = function(e:Event):void {
				ExternalInterface.call('console.log', file+' not loaded');
				dispatchEvent(new TREvent(TREvent.COMPONENT_LOADED, pos));
			}
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, loaded);
			loader.addEventListener(IOErrorEvent.IO_ERROR, er);
			loader.load(new URLRequest(file));
		}
		private function addSprite(file:String,originy:Number,scale:Number):void {
			
		}
	}
}