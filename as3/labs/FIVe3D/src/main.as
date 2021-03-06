package
{
	import com.greensock.TweenLite;
	import com.sleepydesign.components.DialogBalloon;
	import com.sleepydesign.data.DataProxy;
	import com.sleepydesign.display.DrawUtil;
	import com.sleepydesign.display.SDSprite;
	import com.sleepydesign.events.MouseUIEvent;
	import com.sleepydesign.net.LoaderUtil;
	import com.sleepydesign.skins.Preloader;
	import com.sleepydesign.ui.MouseUI;
	import com.sleepydesign.utils.StringUtil;
	import com.sleepydesign.utils.XMLUtil;
	
	import data.CandleData;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.net.URLVariables;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	
	import net.badimon.five3D.display.Bitmap3D;
	import net.badimon.five3D.display.Particles;
	import net.badimon.five3D.display.Sprite2D;
	import net.badimon.five3D.display.Sprite3D;
	import net.badimon.five3D.templates.Five3DTemplate;

	/*
	   TODO:
	   
	   /1. create fake dot data array (1000 x 1000 = 1,000,000)
	   /2. read data and write to map as set pixel (10,000-100,000)
	   /3. add view controller move/pan/rotate
	   /4. add click to view msg (getPixel)
5. create candle with perlin noise flame (BitmapSprite Clip?)
	   /6. add button and move to prefer angle view for place candle
	   /7. add dialog to get user input (name, msg)
	   /8. send data to server (time, x, y, name, msg)
	\9. add blur/glow effect
10. add LOD setpixel <-> copypixel
	   /11. add gradient mask
	   /12. continue load queue 1,000 per request
	   /13. doing data proxy, get/set while send
	   /14. particle clipping
	
	 */
	[SWF(width="1132",height="654",frameRate="30",backgroundColor="#000000")]
	public class main extends Five3DTemplate
	{
		// const
		private const SCREEN_WIDTH:int = 1132;
		private const SCREEN_HEIGHT:int = 654;
		
		private const DEFAULT_ANGLE:int = 60;
		
		private const DEFAULT_X:int = 0;
		private const DEFAULT_Y:int = -80;
		private const DEFAULT_Z:int = 0;
		
		private var USE_EFFECT:Boolean = false;
		private const EFFECT_TIMEOUT_NUM:int = 30;
		
		private const IDLE_DELAY:int = 3;

		private const HIT_ARGB:uint = 202020;//"17170";
		
		private const SPRITE_SCALE:Number = .1;
		private const USER_SPRITE_SCALE:Number = .25;

		private const _matrix:Matrix = new Matrix(1, 0, 0, 1, SCREEN_WIDTH * .5, SCREEN_HEIGHT * .5);
		private const _point:Point = new Point(0, 0);

		// assets
		[Embed(source="assets/ThaiMap.swf",symbol="ThaiMap")]
		private var ThaiMapSWF:Class;
		private var _mapSprite:Sprite = new ThaiMapSWF() as Sprite;

		[Embed(source="assets/ThaiMap.swf",symbol="CandleButton")]
		private var CandleButton:Class;
		private var _candleButton:Sprite = new CandleButton() as Sprite;

		[Embed(source="assets/ThaiMap.swf",symbol="CandleClip")]
		private var CandleClip:Class;
		private var _candleClip:Sprite = new CandleClip() as Sprite;
		
		[Embed(source="assets/ThaiMap.swf",symbol="ForeGroundClip")]
		private var ForeGroundClip:Class;
		private var _foreGroundClip:Sprite = new ForeGroundClip as Sprite;
		
		[Embed(source="assets/ThaiMap.swf",symbol="LightClip")]
		private var LightClip:Class;
		private var _lightClip:MovieClip;// = new LightClip as MovieClip;

		// loader
		private var _loader:Preloader;

		// data
		private var _xmlData:XML;
		private var _candles:Array;
		private var _dropPoint:Point = new Point();

		// canvas
		private var _canvas3D:Sprite3D;
		private var _candleCanvas3D:Sprite3D;
		private var _ballonCanvas3D:Sprite3D;
		private var _candleBitmap3D:Bitmap3D;
		private var _mapBitmap3D:Bitmap3D;
		private var _mapBitmapData:BitmapData;

		// effect
		private var _effectLayer:Sprite;
		private var _effectBitmapData:BitmapData;
		private var _blurFilter:BlurFilter = new BlurFilter(4, 4, 1);
		private var _colorMatrixFilter:ColorMatrixFilter = new ColorMatrixFilter([1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0.9, 0]);

		// status
		private var _status:String;
		private var _transformDirty:Boolean = false;
		private var _dirtyNum:int = 0;

		// UI
		private var _hitArea:Sprite;
		
		// layer
		private var systemLayer:SDSprite = new SDSprite();
		
		// modal
		private var submitPage:SDSprite;
		
		override protected function onInit():void
		{
			debug = false;
			
			visible = false;
			alpha = 0;
			//show();

			addChild(systemLayer);
			LoaderUtil.loaderClip = new Preloader(systemLayer, 1132, 654);

			// get external config
			LoaderUtil.loadXML("config.xml", function(event:Event):void
			{
				if(event.type!="complete")return;
				_xmlData = event.target.data;
				
				USE_EFFECT = (XMLUtil.getXMLById(_xmlData, "USE_EFFECT").@value=="true");
				IDLE_TIME = 30*int(StringUtil.getDefaultIfNull(XMLUtil.getXMLById(_xmlData, "IDLE_TIME").@value, "3"));
				
				getData(XMLUtil.getXMLById(_xmlData, "GET_CANDLES").@src);
			});
		}

		private function getData(uri:String, isReload:Boolean=false):void
		{
			trace(" ! getData : " + uri);
			//status = "preload";
			
			LoaderUtil.loadVars(uri, function(event:Event):void
			{
				if(event.type!="complete")return;
				var _candleList:Array = String(event.target.data.candles).split(";");
				setupData(_candleList);
				
				if(!isReload)
				{
					//status = "init";
	
					setupCanvas();
					setupView();
					setupUI();
					addChild(systemLayer);
	
					status = "intro";
	
					start();
				}else{
					setupCandles();
				}
				
				// next page?
				if(event.target.data.next)
				{
					// delay abit
					trace(" ! delay : " + event.target.data.delay);
					TweenLite.to(systemLayer, int(event.target.data.delay) || 10, {onComplete: function reloadData():void
					{
						getData(uri.split("?")[0] + "?page=" + event.target.data.next, true);
						//getData("serverside/getCandles2.php", true);
					}});
				}
			});
		} 
		
		private var candleDict:Dictionary = new Dictionary(true);
		
		private function setupData(candleList:Array):void
		{
			// dispose
			disposeBalloon();
			
			if(_candles)
			{
				var _oldLength:int = _candles.length;
				var _sprite2D:Sprite2D;
				while(_oldLength--)
				{
					_sprite2D = Candle(_candles[_oldLength]).sprite2D;
					if(_sprite2D)
						_candleCanvas3D.removeChild(_sprite2D);
				}
			}
			
			_candles = [];
				
			var totalPoint:int = candleList.length;
			for (var i:int = 0; i < totalPoint; i++)
			{
				var _candleData:* = candleList[i].split(",");
				
				// dup?
				var _id:String = String(_candleData[0]);
				var _candle:Candle;
				if(!candleDict[_id])
				{
					// new
					_candle = new Candle(_candleData[0], int(_candleData[1]), int(_candleData[2]));
					// cache
					candleDict[_id] = _candle;
				}else{
					// restore
					_candle = candleDict[_id];
					if(_candle.sprite2D)
						_candleCanvas3D.addChild(_sprite2D);
				}
				
				// add
				_candles.push(_candle);
			}
		}
		
		private function setupCandles():void
		{
			// candles
			var _candlesBitmapData:BitmapData = new BitmapData(_mapSprite.width, _mapSprite.height, true, 0x00000000);

			// data -> BitmapData
			var i:int = _candles.length;
			var _candle:Candle;
			_candlesBitmapData.lock();
			
			var _candleBitmapData:BitmapData = new BitmapData(_candleClip.width*SPRITE_SCALE, _candleClip.height*SPRITE_SCALE, true, 0x000000);
			_candleBitmapData.draw(_candleClip, new Matrix(SPRITE_SCALE, 0, 0, SPRITE_SCALE, _candleBitmapData.width/2, _candleBitmapData.height));

			while (i--)
			{
				_candle = Candle(_candles[i]);
				if (_mapBitmapData.getPixel32(_candle.x, _candle.y) > 0)
				{
					// particle
					_candlesBitmapData.setPixel32(_candle.x, _candle.y, 0xFFFFCC00 + 0x00003300 * Math.random());
					
					// sprite2D
					var _sprite2D:Sprite2D = new Sprite2D();
					_sprite2D.scaled = false;
					_sprite2D.name = "candle_"+_candle.id;
					_sprite2D.x = _candle.x - _mapBitmapData.width/2;
					_sprite2D.y = _candle.y - _mapBitmapData.height/2;
					_sprite2D.graphics.beginBitmapFill(_candleBitmapData, new Matrix(1,0,0,1,-_candleBitmapData.width/2, -_candleBitmapData.height));
					_sprite2D.graphics.drawRect(-_candleBitmapData.width/2, -_candleBitmapData.height, _candleBitmapData.width, _candleBitmapData.height);
					_sprite2D.graphics.endFill();
					_sprite2D.cacheAsBitmap = true;
					_sprite2D.clipRect = new Rectangle(-1132, -654, 1132*2, 654*2);
					_sprite2D.buttonMode = true;
					_sprite2D.useHandCursor = true;
					_candle.sprite2D = _sprite2D;
					
					_lightClip = new LightClip as MovieClip;
					_lightClip.y = -10;
					_lightClip.gotoAndPlay(int(Math.random()*_lightClip.totalFrames));
					_lightClip.cacheAsBitmap = true;
					_lightClip.mouseEnabled = false;
					_sprite2D.addChild(_lightClip);
					
					_candleCanvas3D.addChild(_sprite2D);
				}
			}
			_candlesBitmapData.unlock();
		}
	
		private function setupCanvas():void
		{
			_canvas3D = new Sprite3D();
			_scene.addChild(_canvas3D);
			_canvas3D.singleSided = true;
			_canvas3D.mouseEnabled = false;

			_candleCanvas3D = new Sprite3D();
			_candleCanvas3D.singleSided = true;
			_candleCanvas3D.mouseEnabled = false;
			
			_ballonCanvas3D = new Sprite3D();
			_ballonCanvas3D.singleSided = true;
			_ballonCanvas3D.mouseEnabled = false;

			// map
			_mapBitmapData = new BitmapData(_mapSprite.width, _mapSprite.height, true, 0x000000);
			_mapBitmapData.draw(_mapSprite);

			_mapBitmap3D = new Bitmap3D(_mapBitmapData, true, 10, 10);
			_mapBitmap3D.x = -_mapBitmapData.width/2;
			_mapBitmap3D.y = -_mapBitmapData.height/2;
			_mapBitmap3D.singleSided = true;
			_canvas3D.addChild(_mapBitmap3D);
			//TODO:TEST
			_mapBitmap3D.clipRect = new Rectangle(-1132, -654, 1132*2, 654*2);

			setupCandles();

			_canvas3D.addChild(_candleCanvas3D);
			_canvas3D.addChild(_ballonCanvas3D);
			
			// -------------------------------------------------------------
			// try setPixel
			
			//var particles:Particles = new Particles(particlesBitmapData = new BitmapData(SCREEN_WIDTH, SCREEN_WIDTH));
			//_canvas3D.addChild(particles);
			
			/*
			i = candles.length;
			while (i--)
			{
				
			}
			*/
			
			_foreGroundClip.mouseChildren = false;
			_foreGroundClip.mouseEnabled = false;
			addChild(_foreGroundClip);
			
			addChild(stats);
			addChild(debugText);
		}
		
		private var particlesBitmapData:BitmapData;
		private var particles:Particles;
		
		private function setupView():void
		{
			_canvas3D.x = -50;
			_canvas3D.y = 0;
			_canvas3D.z = 830;
			
			_canvas3D.rotationX = 0;
			_canvas3D.rotationY = 0;
			_canvas3D.rotationZ = 0;
		}

		public function show():void
		{
			TweenLite.to(this, 0.5, {autoAlpha: 1});
		}

		public function hide():void
		{
			TweenLite.to(this, 0.5, {autoAlpha: 0});
		}

		private function setupUI():void
		{
			var _ccMouse:MouseUI = new MouseUI(stage);
			_ccMouse.addEventListener(MouseUIEvent.MOUSE_DRAG, onDrag);
			_ccMouse.addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);

			_candleButton.x = 1036;
			_candleButton.y = 590;
			_candleButton.buttonMode = true;
			addChild(_candleButton);

			/*
			   // add bound
			   var _boundArea:Sprite = DrawUtil.drawRect(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 0xFF0000, .5);
			   _boundArea.x = SCREEN_WIDTH/2 - _boundArea.width/2;
			   _boundArea.y = SCREEN_HEIGHT/2 - _boundArea.height/2;
	
			   //_boundArea.blendMode = BlendMode.ERASE;
			   addChild(_boundArea);
			 */
		}

		private function onCandleButtonClick(event:MouseEvent):void
		{
			status = "drag";
		}

		private function onCandleDrop(event:MouseEvent):void
		{
			trace("onCandleDrop");

			_dropPoint.x = int(_mapBitmap3D.mouseX);
			_dropPoint.y = int(_mapBitmap3D.mouseY);

			// drop-in map?
			//var _ARGB:Object = BitmapTool.getARGB(_mapBitmap3D.bitmapData.getPixel32(_dropPoint.x, _dropPoint.y));
			//var _ARGBString:String = String(_ARGB.r) + String(_ARGB.g) + String(_ARGB.b);
			
			var _ARGB:int = _mapBitmap3D.bitmapData.getPixel32(_dropPoint.x, _dropPoint.y)
			
			// debug
			title = _dropPoint.toString() + " | " + _ARGB;

			// only hit area
			//if (_ARGBString != HIT_ARGB)
			//	return;

			//if (_candleBitmap3D.bitmapData.getPixel32(_dropPoint.x, _dropPoint.y) <= 0x000000)
			if (_ARGB < 0 )
			{
				status = "drop";
			//}else if(_hitArea.hitTestPoint(mouseX, mouseY)){
			//	status = "drag";
			}
			else
			{
				status = "drop-out";
			}
		}

		private function onExploreClick(event:Event):void
		{
			trace(event.target, event.currentTarget,event);
			// it's candle
			if(event.target is Sprite2D && String(event.target.name).indexOf("candle_")==0)
				setupOtherBalloon(event.target as Sprite2D);
		}
		
		private function set status(value:String):void
		{
			trace(" ! Status : " + value);
			Mouse.show();
			_status = value;
			switch (_status)
			{
				case "preload":
					break;
				case "init":
					break;
				case "intro":
					// fade in
					TweenLite.to(this, 1, {autoAlpha: 1, onComplete: function():void
					{
						// go idle
						TweenLite.to(_canvas3D, 1, {x:DEFAULT_X, y:DEFAULT_Y, z:DEFAULT_Z, rotationX: -DEFAULT_ANGLE, rotationY: 0, rotationZ: 0});
						status = "idle";
					}});
					break;
				case "idle":
					// go default angle
					//TweenLite.to(_canvas3D, 1, {x:DEFAULT_X, y:DEFAULT_Y, z:DEFAULT_Z, rotationX: -DEFAULT_ANGLE, rotationY: 0, rotationZ: 0});
					
					// wait for drag, explore
					var onExplore:Function;
					stage.addEventListener(MouseEvent.MOUSE_DOWN, onExplore = function():void
						{
							stage.removeEventListener(MouseEvent.MOUSE_DOWN, onExplore);
							
							// move cam to defined position
							TweenLite.to(_canvas3D, 1, {x:DEFAULT_X, y:DEFAULT_Y, z:DEFAULT_Z, rotationX: -DEFAULT_ANGLE, rotationY: 0, rotationZ: 0, onComplete: function():void
							{
								// go explore
								status = "explore";
							}});
						});
					
					// wait for candle click
					_candleButton.removeEventListener(MouseEvent.CLICK, onCandleButtonClick);
					_candleButton.addEventListener(MouseEvent.CLICK, onCandleButtonClick);
					break;
				case "explore":
					// click to view
					stage.addEventListener(MouseEvent.MOUSE_DOWN, onExploreClick);
					break;
				case "drag":
					Mouse.hide();
					// no more click
					_candleButton.removeEventListener(MouseEvent.CLICK, onCandleButtonClick);
					
					// draging in bound
					TweenLite.to(_candleButton, 0.25, {autoAlpha: 0.25});
					TweenLite.to(_candleClip, 0.25, {autoAlpha: 1});

					addChild(_candleClip);
					_candleClip.startDrag(true);

					// wait for drop
					stage.addEventListener(MouseEvent.MOUSE_DOWN, onCandleDrop);
					break;
				case "drop":
					// drop
					_candleClip.stopDrag();
					stage.removeEventListener(MouseEvent.MOUSE_DOWN, onCandleDrop);
					
					// get id
					var _id:String = new Date().valueOf() as String;

					// get position
					var candleData:CandleData = new CandleData(_id, _dropPoint.x, _dropPoint.y);

					// wait for text input
					status = "input";
					
					// wait for candle click
					TweenLite.to(_candleButton, 0.25, {autoAlpha: 1});
					_candleButton.addEventListener(MouseEvent.CLICK, onCandleButtonClick);			
					break;
				case "drop-out":
					// drop
					_candleClip.stopDrag();
					stage.removeEventListener(MouseEvent.MOUSE_DOWN, onCandleDrop);
					
					TweenLite.to(_candleClip, 0.25, {autoAlpha: 0, onComplete: function():void
					{
						_candleClip.parent.removeChild(_candleClip);
						
						// go explore
						status = "explore";
					}});
					
					// wait for candle click
					TweenLite.to(_candleButton, 0.25, {autoAlpha: 1});
					_candleButton.addEventListener(MouseEvent.CLICK, onCandleButtonClick);
					break;
				case "input":
					// add data
					DataProxy.addData("$CANDLE_TIME", new Date().valueOf());
					DataProxy.addData("$CANDLE_X", _dropPoint.x);
					DataProxy.addData("$CANDLE_Y", _dropPoint.y);

					// wait for server response
					LoaderUtil.load("SubmitPage.swf", function(event:Event):void
					{
						if(event.type=="complete")
						{
							submitPage = event.target["content"] as SDSprite;
							submitPage.alpha = 0;
							submitPage.visible = false;
							addChild(submitPage);
							
							// show
							TweenLite.to(submitPage, 0.5, {autoAlpha: 1});
							TweenLite.to(_candleClip, 0.25, {autoAlpha: 0, onComplete: function():void
							{
								_candleClip.parent.removeChild(_candleClip);
							}});
							
							// hide
							submitPage.addEventListener(Event.CLOSE, function(event:Event):void
							{
								status = "view";
							});
						}
					});
					break;
				case "view":
					// view msg
					setupUserBalloon();
					
					// go idle
					TweenLite.to(_candleClip, 1, {autoAlpha: 0, onComplete: function():void
					{
						status = "explore";
					}});
					break;
			}
		}
		
		private var _sprite2D:Sprite2D;
		private function setupUserBalloon():void
		{
			// msg
			var _baloon:DialogBalloon = new DialogBalloon
			(
				DataProxy.getDataByID("$CANDLE_MSG") + "<br/>" + DataProxy.getDataByID("$CANDLE_EMAIL"),
				new TextFormat("Tahoma", 12, 0xF4B800), 0x000000, 0xFFFFFF,4,8
			);
			_sprite2D = new Sprite2D();
			_baloon.y = -50;
			_baloon.alpha = 0;
			_baloon.visible = false;
			//_sprite2D.addChild(_baloon);
			_sprite2D.cacheAsBitmap = true;
			_sprite2D.x = _dropPoint.x-_mapBitmap3D.bitmapData.width/2;
			_sprite2D.y = _dropPoint.y-_mapBitmap3D.bitmapData.height/2;

			// candle
			var _candleBitmapData:BitmapData = new BitmapData(_candleClip.width*USER_SPRITE_SCALE, _candleClip.height*USER_SPRITE_SCALE, true, 0x000000);
			_candleBitmapData.draw(_candleClip, new Matrix(USER_SPRITE_SCALE, 0, 0, USER_SPRITE_SCALE, _candleBitmapData.width/2, _candleBitmapData.height));

			_sprite2D.graphics.beginBitmapFill(_candleBitmapData, new Matrix(1,0,0,1,-_candleBitmapData.width/2, -_candleBitmapData.height));
			_sprite2D.graphics.drawRect(-_candleBitmapData.width/2, -_candleBitmapData.height, _candleBitmapData.width, _candleBitmapData.height);
			_sprite2D.graphics.endFill();
			
			_lightClip = new LightClip as MovieClip;
			_lightClip.y = -17;
			_lightClip.gotoAndPlay(int(Math.random()*_lightClip.totalFrames));
			_lightClip.cacheAsBitmap = true;
			_lightClip.mouseEnabled = false;
			_sprite2D.addChild(_lightClip);
			
			_sprite2D.visible = false;
			_sprite2D.alpha = 0;
			
			TweenLite.to(_baloon, 1, {autoAlpha: 1, y:-30});
			TweenLite.to(_sprite2D, 1, {autoAlpha: 1});
					
			_candleCanvas3D.addChild(_sprite2D);
			
			var _balloon2D:Sprite2D = new Sprite2D();
			_balloon2D.addChild(_baloon);
			_balloon2D.x = _sprite2D.x;
			_balloon2D.y = _sprite2D.y;
			_balloon2D.scaled = false;
			_balloon2D.cacheAsBitmap = true;
			_balloon2D.mouseEnabled = false;
			_ballonCanvas3D.addChild(_balloon2D);
		}
		
		private var _lastBalloon:DialogBalloon;
		
		private function disposeBalloon():void
		{
			if(!_lastBalloon)return;
			
			var __lastBalloon:DialogBalloon = _lastBalloon;
			TweenLite.to(__lastBalloon, 1, {autoAlpha: 0, onComplete: function():void
			{
				var _balloon2D:Sprite2D = __lastBalloon.parent as Sprite2D;
				__lastBalloon.destroy();
				if(_balloon2D)
					_ballonCanvas3D.removeChild(_balloon2D);
			}});
		}
		
		private function setupOtherBalloon(_sprite2D:Sprite2D):void
		{
			// destroy
			if(_lastBalloon)
				disposeBalloon();
			
			// msg
			var _baloon:DialogBalloon = new DialogBalloon(
				"loading...",
				new TextFormat("Tahoma", 12, 0xF4B800), 0x000000, 0xFFFFFF,4,8
			);
			_baloon.y = -20;
			_baloon.filters = [new GlowFilter(0xFFCC00, .75,6,6,1)];
			
			var _balloon2D:Sprite2D = new Sprite2D();
			_balloon2D.addChild(_baloon);
			_balloon2D.x = _sprite2D.x;
			_balloon2D.y = _sprite2D.y;
			_balloon2D.scaled = false;
			_balloon2D.cacheAsBitmap = true;
			_balloon2D.mouseEnabled = false;
			_ballonCanvas3D.addChild(_balloon2D);
			
			// load msg
			LoaderUtil.requestVars(XMLUtil.getXMLById(_xmlData, "GET_CANDLE").@src, new URLVariables("id="+_sprite2D.name), function(event:Event):void
			{
				if(event.type=="complete")
				{
					_baloon.htmlText = event.target.data.msg + "<br/>" + event.target.data.email;
				}
			});
			
			_lastBalloon = _baloon;
		}
		
		private function dragHandler(event:Event):void
		{
			if (_candleClip)
				_candleClip.stopDrag();
		}

		public function destroy():void
		{
			if (_candleButton)
				_candleButton.removeEventListener(MouseEvent.CLICK, onCandleButtonClick);

			if (_candleClip)
				removeChild(_candleClip);
		}

		override protected function setupLayer():void
		{
			// guide
			if (parent && parent==stage)
				addChild(LoaderUtil.loadAsset("../src/assets/bg.png"));

			// add hitArea
			_hitArea = DrawUtil.drawRect(SCREEN_WIDTH, SCREEN_HEIGHT, 0x000000);
			_hitArea.blendMode = BlendMode.ERASE;
			addChild(_hitArea);
			
			_effectBitmapData = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, true, 0x000000);
			var _effectBitmap:Bitmap = new Bitmap(_effectBitmapData, PixelSnapping.NEVER, false);
			addChild(_effectBitmap);
		}
		
		private function onDrag(event:MouseUIEvent):void
		{
			if(_status=="explore" || _status=="drag")
			{
				_canvas3D.x += event.data.dx;
				_canvas3D.z += event.data.dy * Math.sin(90 - _canvas3D.rotationX);
				_canvas3D.y += event.data.dy;
	
				setDirty();
			}
		}

		private function onWheel(event:MouseEvent):void
		{
			if(_status=="explore" || _status=="drag")
			{
				var _x:Number = _canvas3D.x;
				var _y:Number = _canvas3D.y;
				var _z:Number = _canvas3D.z;
	
				_y = _y + 5 * event.delta * Math.sin(DEFAULT_ANGLE);
				_z = _z + 5 * event.delta * Math.cos(DEFAULT_ANGLE);
	
				if(_z<-320)
				{
					_z = _canvas3D.z;
					_y = _canvas3D.y;
				}
				
				_canvas3D.setPosition(_x, _y, _z);
				setDirty();
			}
		}

		private function setDirty():void
		{
			_dirtyNum = 0;
			_transformDirty = true;
		}

		override protected function onPreRender():void
		{
			if (_status == "idle" && _canvas3D)
			{
				_canvas3D.rotationZ++;
				setDirty();
			}
			
			// move mouse?
			if(mouseX==_mouseX && mouseY==_mouseY)
			{
				// break limit?
				if(idleNum<IDLE_TIME)
				{
					// count down
					idleNum++;
				}else{
					//reset
					idleNum = 0;
					
					// idle activate if in explore mode
					if(_status=="explore")
						status = "idle";
				}
			}
			
			// mem last position
			_mouseX = mouseX;
			_mouseY = mouseY;
		}
		
		private var _mouseX:Number = 0;
		private var _mouseY:Number = 0;
		private var idleNum:int = 0;
		private var IDLE_TIME:int = 3;
		override protected function onPostRender():void
		{
			if (_transformDirty)
			{
				if (USE_EFFECT)
				{
					_effectBitmapData.lock();
					_effectBitmapData.draw(_candleCanvas3D, _matrix);
					_effectBitmapData.applyFilter(_effectBitmapData, _effectBitmapData.rect, _point, _blurFilter);
					_effectBitmapData.applyFilter(_effectBitmapData, _effectBitmapData.rect, _point, _colorMatrixFilter);
					_effectBitmapData.unlock();
				}

				if (_dirtyNum++ > EFFECT_TIMEOUT_NUM)
				{
					_transformDirty = false;
					_dirtyNum = 0;
				}
			}
		}
	}
}