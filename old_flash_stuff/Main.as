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
//								(C) 2016. All rights reserved.
//
package {
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.physics3dintegration.PhysicalSimObject;
	import alternativa.physics3dintegration.PhysicsSprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	//import out.Component;
	public class Main extends PhysicsSprite {
		private const phi:Number = 1.61803398875;
		private const mphi:Number = 0.38196601125;
		[Embed(source = "C:\\WINDOWS\\Fonts\\BankGothic Md BT Medium.ttf", fontName = "bank", mimeType = "application/x-font", advancedAntiAliasing = "true", embedAsCFF = "false")] private const bankembed:Class;
		[Embed(source = "C:\\WINDOWS\\Fonts\\OCRAEXT.ttf", fontName = "ocraext", mimeType = "application/x-font", advancedAntiAliasing = "true", embedAsCFF = "false")] private const ocraextembed:Class;
		private var itemsToLoad:int = 0;
		private var itemsLoaded:int = 1;
		private var graphicsobjects:Vector.<DisplayObject> = new Vector.<DisplayObject>();
		private var topmost:DisplayObjectContainer = new Sprite();
		private var top:DisplayObjectContainer = new Sprite();
		private var bottom:DisplayObjectContainer = new Sprite();
		private var fullscreen:Loader = new Loader();
		private var fullscreenH:Loader = new Loader();
		private var fullscreenD:Loader = new Loader();
		private var fullscreenDH:Loader = new Loader();
		private function fullscreenIn(e:Event = null):void {
			if (contains(fullscreen)) {
				removeChild(fullscreen);
				addChild(fullscreenH);
			} else {
				removeChild(fullscreenD);
				addChild(fullscreenDH);
			}
		}
		private function fullscreenOut(e:Event = null):void {
			if (stage.displayState == StageDisplayState.NORMAL) {
				removeChild(fullscreenH);
				addChild(fullscreen);
			} else {
				removeChild(fullscreenDH);
				addChild(fullscreenD);
			}
		}
		private function fullscreenClicked(e:Event = null):void {
			if (stage.displayState == StageDisplayState.NORMAL) {
				stage.displayState = StageDisplayState.FULL_SCREEN;
				removeChild(fullscreenH);
				addChild(fullscreenD);
			} else {
				stage.displayState = StageDisplayState.NORMAL;
				removeChild(fullscreenDH);
				addChild(fullscreen);
			}
		}
		private function alignFullscreenButton(e:Event = null):void {
			fullscreen.x = stage.stageWidth - 64;
			fullscreenH.x = fullscreen.x;
			fullscreenD.x = fullscreen.x;
			fullscreenDH.x = fullscreen.x;
		}
		public function Main() {
			addChild(bottom);
			addChild(top);
			addChild(topmost);
			var background:Shape = new Shape();
			topmost.addChild(background);
			var logo:TextField = new TextField();
			logo.width = 6*72;
			logo.height = 72*2.5;//86@280,3.255813953488372
			logo.embedFonts = true;
			logo.text = '[Tanki Reloaded]';
			logo.multiline = true;
			logo.wordWrap = true;
			logo.antiAliasType = AntiAliasType.ADVANCED;
			topmost.addChild(logo);
			ChatAction(InitalizeChat);
			ChatAction(ShowMainChat);
			var resized:Function = function(e:Event = null):void {
				var pwidth:int = stage.stageWidth / Capabilities.screenDPI;
				background.graphics.clear();
				background.graphics.beginFill(0x7F7F7F,background.alpha);
				background.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
				background.graphics.endFill();
				if (pwidth > 12) {
					var logoWidth:int = stage.stageWidth - stage.stageWidth / phi;
					var logoHeight:int = logoWidth / phi /phi;
					var progHeight:int = logoHeight / 7;
					background.graphics.beginFill(0x404040, background.alpha);
					logo.x = (stage.stageWidth - logoWidth) / 2;
					logo.y = (stage.stageHeight - logoHeight - progHeight * phi) / 2;
					logo.width = logoWidth;
					logo.height = logoHeight;
					logo.defaultTextFormat = new TextFormat('bank', Math.round(logo.height/3.3), 0xFFFFFF);
					background.graphics.drawRect((stage.stageWidth - logoWidth) / 2, (stage.stageHeight - logoHeight - progHeight * phi) / 2, logoWidth, logoHeight);
					background.graphics.drawRect((stage.stageWidth - logoWidth) / 2, (stage.stageHeight - logoHeight - progHeight * phi) / 2 + logoHeight + progHeight * phi / 2, logoWidth, progHeight);
					background.graphics.endFill();
					if (itemsLoaded) {
						background.graphics.beginFill(0x007F00, background.alpha);
						background.graphics.drawRect((stage.stageWidth - logoWidth) / 2, (stage.stageHeight - logoHeight - progHeight * phi) / 2 + logoHeight + progHeight * phi / 2, logoWidth*itemsLoaded/(itemsLoaded+itemsToLoad), progHeight);
						background.graphics.endFill();
					}
				} else {
					
				}
			}
			stage.addEventListener(Event.RESIZE, resized);
			stage.dispatchEvent(new Event(Event.RESIZE));
			var cleanupstuff:Function = function():void {/*
				stage.removeEventListener(Event.RESIZE, resized);
				background.graphics.clear();
				topmost.removeChild(background);
				background = null;
				topmost.removeChild(logo);
				logo = null;
				ChatAction(OpenMainChat);*/
			}
			var loadRect:Shape = new Shape();
			var loadLogo:Loader = new Loader();
			var loadRectResize:Function = function(e:Event = null):void {
				loadRect.graphics.beginFill(0);
				loadRect.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
				loadRect.graphics.endFill();
				loadRect.graphics.beginFill(0x404040);
				loadRect.graphics.drawRect((stage.stageWidth - 400) / 2, (stage.stageHeight - 167) / 2 + 147, 400, 20);
				loadRect.graphics.endFill();
				loadRect.graphics.beginFill(0x007F00);
				loadRect.graphics.drawRect((stage.stageWidth - 400) / 2, (stage.stageHeight - 167) / 2 + 147, Math.round(400*itemsLoaded/(itemsLoaded+itemsToLoad)), 20);
				loadRect.graphics.endFill();
			}
			var loadLogoResize:Function = function(e:Event = null):void {
				loadLogo.x = (stage.stageWidth - 400) / 2;
				loadLogo.y = (stage.stageHeight - 167) / 2;
			}
			//loadRectResize();
			stage.addEventListener(Event.RESIZE, loadRectResize);
			loadLogo.addEventListener(Event.COMPLETE, loadLogoResize);
			stage.addEventListener(Event.RESIZE, loadLogoResize);
			loadLogo.load(new URLRequest('Logo.png'));
			fullscreen.load(new URLRequest('Fullscreen.png'));
			fullscreenH.load(new URLRequest('FullscreenH.png'));
			fullscreenD.load(new URLRequest('FullscreenD.png'));
			fullscreenDH.load(new URLRequest('FullscreenDH.png'));
			alignFullscreenButton();
			stage.addEventListener(Event.RESIZE, alignFullscreenButton);
			fullscreen.addEventListener(MouseEvent.MOUSE_OVER, fullscreenIn);
			fullscreenD.addEventListener(MouseEvent.MOUSE_OVER, fullscreenIn);
			fullscreenH.addEventListener(MouseEvent.MOUSE_OUT, fullscreenOut);
			fullscreenH.addEventListener(MouseEvent.CLICK, fullscreenClicked);
			fullscreenDH.addEventListener(MouseEvent.MOUSE_OUT, fullscreenOut);
			fullscreenDH.addEventListener(MouseEvent.CLICK, fullscreenClicked);
			addChild(fullscreen);
			super();
			removeChild(camera.diagram);
			camera.view.hideLogo();
			//cameraController.speed = 100;
			var configLoader:URLLoader = new URLLoader();
			var configLoaded:Function = function(e:Event):void {
				configLoader.removeEventListener(Event.COMPLETE, configLoaded);
				configLoader = null;
				config.appendChild(new XML(e.target.data));
				var loadLibrary:Function = function(lib:String):void {
					var loader:URLLoader = new URLLoader();
					var libLoaded:Function = function(e:Event):void {
						loader.removeEventListener(Event.COMPLETE, libLoaded);
						loader = null;
						config.appendChild(new XML(e.target.data.toString().replace(new RegExp(/-/gi), '')));
						itemsToLoad--;
						itemsLoaded++;
						stage.dispatchEvent(new Event(Event.RESIZE));
					}
					loader.addEventListener(Event.COMPLETE, libLoaded);
					loader.load(new URLRequest(lib));
				}
				var loadMap:Function = function(map:String):void {
					var loader:URLLoader = new URLLoader();
					var mapLoaded:Function = function(e:Event):void {
						loader.removeEventListener(Event.COMPLETE, mapLoaded);
						loader = null;
						var mapname:String = getFilenameFromUrl(map);
						mapname = mapname.substr(0, mapname.length - 4).replace('_', ' ');
						config.appendChild(new XML(e.target.data.toString().replace(new RegExp(/-/gi), '').replace('version', 'name').replace('1.0.Light', mapname).replace('1.0', mapname)));
						itemsToLoad--;
						itemsLoaded++;
						stage.dispatchEvent(new Event(Event.RESIZE));
					}
					loader.addEventListener(Event.COMPLETE, mapLoaded);
					loader.load(new URLRequest(map));
				}
				for each(var lib:XML in config.config.library) {
					itemsToLoad++;
					loadLibrary(lib.@url+'/library.xml');
				}
				for each(var map:XML in config.config.map) {
					itemsToLoad++;
					loadMap(map.@url);
				}
				var xmlLoaded:Boolean = false;
				var propsLoaded:Boolean = false;
				var timer:Timer = new Timer(500);
				var checkLoaded:Function = function(e:Event = null):void {
					if (itemsToLoad == 0) {
						if (xmlLoaded) {
							if(propsLoaded) {
								timer.stop();
								timer.removeEventListener(TimerEvent.TIMER, checkLoaded);
								timer = null;
								cleanupstuff();
								/*var runs:int = 0;
								var $timer:Timer = new Timer(4);
								var effect:Function = function(e:Event = null):void {
									if (runs == 50) {
										$timer.stop();
										$timer.removeEventListener(TimerEvent.TIMER, effect);
										$timer = null;
										stage.removeEventListener(Event.RESIZE, loadRectResize);
										loadRect = null;
										loadLogo.removeEventListener(Event.COMPLETE, loadLogoResize);
										stage.removeEventListener(Event.RESIZE, loadLogoResize);
										loadLogo = null;
										addEventListener(TREvent.START, Start);
										stage.dispatchEvent(new TREvent(TREvent.START));
									} else {
										loadRect.alpha -= .02;
										loadLogo.alpha -= .02;
										runs++;
									}
								}
								$timer.addEventListener(TimerEvent.TIMER, effect);
								$timer.start();*/
							} else {
								propsLoaded = true;
								SpawnMap('MainMap1');
							}
						} else {
							xmlLoaded = true;
							initProps();
						}itemsToLoad = 0;
					}
				}
				timer.addEventListener(TimerEvent.TIMER, checkLoaded);
				timer.start();
			}
			configLoader.addEventListener(Event.COMPLETE, configLoaded);
			configLoader.load(new URLRequest('config.xml'));
		}
		private var config:XML = <config></config>;
		//private var staticscene:Vector.<out.Component> = new Vector.<out.Component>();
		private var scene:Vector.<PhysicalSimObject> = new Vector.<PhysicalSimObject>();
		private var hullsnames:Vector.<String> = new Vector.<String>();
		private var hulls:Vector.<XML> = new Vector.<XML>();
		private var turretsnames:Vector.<String> = new Vector.<String>();
		private var turrets:Vector.<XML> = new Vector.<XML>();
		private var camosnames:Vector.<String> = new Vector.<String>();
		private var camos:Vector.<BitmapData> = new Vector.<BitmapData>();
		
		private var proptexturenames:Vector.<String> = new Vector.<String>();
		private var proptextures:Vector.<TextureMaterial> = new Vector.<TextureMaterial>();
		private var propnames:Vector.<String> = new Vector.<String>();
		private var props:Vector.<Mesh> = new Vector.<Mesh>();
		private function loadPropTexture(e:TREvent):void {
			var loader:Loader = new Loader();
			var loaded:Function = function(ev:Event = null):void {
				var tex:BitmapData = new BitmapData(loader.width, loader.height);
				tex.draw(loader);
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaded);
				loader = null;
				proptexturenames.push(e.name);
				proptextures.push(new TextureMaterial(new BitmapTextureResource(tex)));
				itemsToLoad--;
				itemsLoaded++;
				dispatchEvent(new Event(Event.RESIZE));
			}
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaded);
			loader.load(new URLRequest(e.file));
		}
		private function loadProp(e:TREvent):void {
			
		}
		private function initProps():void {
			addEventListener(TREvent.LOAD_PROP_TEXTURE, loadPropTexture);
			addEventListener(TREvent.LOAD_PROP, loadProp);
			for each(var lib:XML in config.library) {
				for each(var group:XML in lib.propgroup) {
					for each(var prop:XML in group.prop) {
						if (prop.mesh != undefined) {
							if (prop.texture != undefined) {
								for each(var tex:XML in prop.texture) {
									itemsToLoad++;
									//dispatchEvent(new TREvent(TREvent.LOAD_PROP_TEXTURE, 'library/' + lib.@name.toString().replace(' ', '') + '/' + tex.@diffusemap.toString(), new String(lib.@name+group.@name+prop.@name)));
								}
							} else {
								itemsToLoad++;
								//dispatchEvent(new TREvent(TREvent.LOAD_PROP_TEXTURE, prop.mesh.@file.toString().substr(0, prop.mesh.@file.toString().length - 3) + 'jpg',new String(lib.@name+group.@name+prop.@name)));
							}
							itemsToLoad++;
							//dispatchEvent(new TREvent(TREvent.LOAD_PROP, prop.mesh.@file, new String(lib.@name+group.@name+prop.@name)));
						} else {
							
						}
					}
				}
			}
			dispatchEvent(new Event(Event.RESIZE));
		}
		private function loadCamo(file:String):void {
			var loader:Loader = new Loader();
			var CamoLoaded:Function = function(e:Event = null):void {
				var camo:BitmapData = new BitmapData(loader.width,loader.height);
				camo.draw(loader);
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, CamoLoaded);
				camosnames.push(file);
				camos.push(camo);
				itemsToLoad--;
				LogFile(file);
			}
			var LoadError:Function = function(e:Event = null):void {
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, LoadError);
				camosnames.push(file);
				camos.push(new BitmapData(1, 1, false, 0xFF007F00));
				itemsToLoad--;
				Log('Error loading ' + file + ', replacing with blank texture.');
			}
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, CamoLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, LoadError);
			loader.load(new URLRequest(file));
		}

		private function alert(msg:String):void { ExternalInterface.call('alert', msg);}
		private static function getFilenameFromUrl(url:String):String {
			var letters:Array= [];
			var charPosition:int= url.length;
			var currentCharacter:String;
			while(currentCharacter != '/' && currentCharacter != '\\') {
				currentCharacter = url.charAt(charPosition);
				letters.push( currentCharacter);
				charPosition--;
			}
			letters = letters.reverse();
			letters.shift();
			var filename:String = letters.join('');
			return filename;
		}
		private function findInArray(str:String, arr:Vector.<String>):int {
			for(var i:int = 0; i < arr.length; i++) {if(arr[i] == str) {return i;}}
			return -1;
		}

		private function Log(text:String):void {
			ExternalInterface.call('console.log', text);
		}
		private function SpawnMap(name:String):void {
			
		}
		private function LogFile(text:String):void {
			ExternalInterface.call('console.log', 'Loaded ' + text);
		}
		private function Start(e:Event = null):void {
			removeEventListener(TREvent.START, Start);
			ExternalInterface.call('console.log', 'Tanki Reloaded Started Successfully!');
		}

		private function UpdateBattles():void {
			
		}
		private function UpdateBattleInfo():void {
			
		}
		private function JoinBattle():void {
			
		}
		private function QuitBattle():void {
			
		}
		private function MainToGarage():void {
			
		}
		private function GarageToMain():void {
			
		}
		private function BattleToGarage():void {
			
		}
		private function GarageToBattle():void {
			
		}
		private var mainchat:TextField=new TextField();
		private var mainchatinput:TextField=new TextField();
		private var mainchatbackground:Shape = new Shape();
		private var mainchatsend:Shape = new Shape();
		private var collapsechat:Shape = new Shape();
		private var expandchat:Shape = new Shape();
		private var battlechat:TextField=new TextField();
		private var battlechatinput:TextField = new TextField();
		private var chatpos:Number = 0;
		private const InitalizeChat:int = 0;
		private const OpenMainChat:int = 1;
		private const CloseMainChat:int = 2;
		private const ShowMainChat:int = 3;
		private const HideMainChat:int = 4;
		private const OpenBattleChat:int = 5;
		private const CloseBattleChat:int = 6;
		private const SendMsg:int = 5;
		private const GetMsg:int = 6;
		
		private function ChatAction(action:int, msg:String='', user1:String='', user2:String='', $private:Boolean=false):void {
			switch(action) {
				case InitalizeChat:
					stage.addEventListener(Event.RESIZE, function(e:Event = null):void {
						mainchatbackground.graphics.clear();
						mainchatbackground.graphics.beginFill(0x404040);
						mainchatbackground.graphics.drawRect(stage.stageWidth * 2 / 3, 0, stage.stageWidth / 3, stage.stageHeight);
						mainchatbackground.graphics.endFill();
						
						mainchatsend.width = (stage.stageWidth / 3 - stage.stageWidth / 3 / phi) / 2;
						mainchatsend.height = mainchatsend.width * 2 / phi / 3;
						mainchatsend.x = stage.stageWidth * 2 / 3 + stage.stageWidth / 3 / phi + mainchatsend.width;
						mainchatsend.y = stage.stageHeight-mainchatsend.height-1;
						mainchatinput.width = stage.stageWidth / 3 / phi + (stage.stageWidth / 3 - stage.stageWidth / 3 / phi)/2;
						mainchatinput.height = (stage.stageWidth / 3 - stage.stageWidth / 3 / phi)/phi/3;
						mainchatinput.x = stage.stageWidth * 2 / 3;
						mainchatinput.y = stage.stageHeight - mainchatinput.height;// mainchatsend.y;
						mainchatinput.defaultTextFormat = new TextFormat('ocraext', mainchatinput.height - 8, 0xFFFFFF);
						
						collapsechat.graphics.clear();
						collapsechat.graphics.beginFill(0xBFBFBF);
						var temp:int = (stage.stageWidth / 3 - stage.stageWidth / 3 / phi) / phi / 3;
						collapsechat.graphics.drawRect(stage.stageWidth * 2 / 3 - temp / phi / phi, temp * 2 / phi, temp * phi, temp * 2);
						collapsechat.graphics.endFill();
						collapsechat.graphics.beginFill(0x7F7F7F);
						//collapsechat.graphics.draw
						collapsechat.graphics.endFill();
					});
					mainchatinput.type = TextFieldType.INPUT;
					mainchatinput.border = true;
					mainchatinput.borderColor = 0xff00;
					mainchatinput.multiline = false;
					mainchatinput.embedFonts = true;
					break;
				case OpenMainChat:
					addChild(mainchatbackground);
					addChild(mainchat);
					addChild(collapsechat);
					addChild(mainchatinput);
					addChild(mainchatsend);
					break;
				case CloseMainChat:
					
					break;
				case ShowMainChat:
					
					break;
				case HideMainChat:
					
					break;
				case OpenBattleChat:
					
					break;
				case CloseBattleChat:
					
					break;
				case SendMsg:
					
					break;
				case GetMsg:
					
					break;
			}
		}
		private function friendAction():void {
			
		}
	}
}