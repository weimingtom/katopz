package com.sleepydesign.components
{
	import com.sleepydesign.display.SDSprite;

	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.geom.Rectangle;

	public class SDPanel extends SDComponent
	{
		protected var _back:Shape;

		public var content:DisplayObject;

		public function SDPanel()
		{
			_back = new Shape();
			addChild(_back);

			setSize(100, 100);
			scrollRect = _back.getRect(_back.parent);
		}

		override public function addChild(child:DisplayObject):DisplayObject
		{
			content = child;
			return super.addChild(content);
		}

		override public function removeChild(child:DisplayObject):DisplayObject
		{
			return super.removeChild(content);
		}

		override public function draw():void
		{
			_back.graphics.clear();
			_back.graphics.lineStyle(SDStyle.BORDER_THICK, SDStyle.BORDER_COLOR, SDStyle.BORDER_ALPHA, true);
			_back.graphics.beginFill(SDStyle.BACKGROUND, SDStyle.BACKGROUND_ALPHA);

			_back.graphics.drawRect(0, 0, _width, _height);
			_back.graphics.endFill();

			scrollRect = _back.getRect(_back.parent);

			super.draw();
		}
	}
}