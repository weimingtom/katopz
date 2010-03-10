package com.sleepydesign.templates
{
	import com.sleepydesign.display.SDSprite;
	import com.sleepydesign.net.LoaderUtil;
	import com.sleepydesign.skins.Preloader;

	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;

	[SWF(backgroundColor="0xFFFFFF", frameRate="30", width="800", height="600")]
	public class ApplicationTemplate extends SDSprite
	{
		protected var _title:String = "";
		protected var _configURI:String = "site.xml";

		protected var _xml:XML;

		protected var _systemLayer:SDSprite;
		protected var _contentLayer:SDSprite;

		// app
		protected var _stageWidth:Number = stage ? stage.stageWidth : NaN;
		protected var _stageHeight:Number = stage ? stage.stageHeight : NaN;

		protected var _customWidth:Number;
		protected var _customHeight:Number;

		public function ApplicationTemplate()
		{
			addEventListener(Event.ADDED_TO_STAGE, onStage);
		}

		protected function onStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onStage);
			initStage();
			initLayer();
			initSystem();
		}

		protected function initLayer():void
		{
			addChild(_contentLayer = new SDSprite).name = "$content";
			addChild(_systemLayer = new SDSprite).name = "$system";
		}

		protected function initStage():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
		}

		protected function initSystem():void
		{
			// skin loader
			LoaderUtil.loaderClip = new Preloader(_systemLayer, _stageWidth, _stageHeight);

			// get external config
			LoaderUtil.loadXML(_configURI, onXMLLoad);
		}

		protected function onXMLLoad(event:Event):void
		{
			if (event.type != "complete")
				return;
			_xml = new XML(event.target.data);

			onInitXML();
		}

		protected function onInitXML():void
		{
			// override me
		}

		// TODO:destroy
	}
}