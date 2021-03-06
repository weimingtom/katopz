package com.sleepydesign.components
{
	import com.greensock.TweenLite;
	
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;

	public class SDButton extends SDComponent
	{
		private var _back:Shape;
		private var _face:Shape;
		private var _label:SDLabel;
		private var _labelText:String = "";
		private var _over:Boolean = false;
		private var _down:Boolean = false;
		private var _selected:Boolean = false;
		private var _toggle:Boolean = false;

		public function SDButton(text:String = "", style:ISDStyle = null)
		{
			super(style);

			_labelText = text;

			_back = new Shape();
			addChild(_back);

			_label = new SDLabel(_labelText);
			addChild(_label);

			_label.autoSize = TextFormatAlign.CENTER

			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			addEventListener(MouseEvent.ROLL_OVER, onMouseOver, false, 0, true);

			buttonMode = true;
			useHandCursor = true;
			setSize(48, 18);
		}

		override public function draw():void
		{
			_label.autoSize = TextFormatAlign.CENTER;
			_label.text = _labelText;
			if (_label.width > _width - 4)
			{
				_label.autoSize = "none";
				_label.width = _width - 4;
			}
			else
			{
				_label.autoSize = TextFormatAlign.CENTER;
			}
			_label.draw();
			_label.x = _width / 2 - _label.width / 2;

			if (_width < _label.width + 4)
				setSize(_label.width + 4, _height);

			_back.graphics.clear();
			_back.graphics.lineStyle(_style.BORDER_THICK, _style.BORDER_COLOR, _style.BORDER_ALPHA, true);
			_back.graphics.beginFill(_style.BUTTON_COLOR, _style.BUTTON_ALPHA);
			_back.graphics.drawRoundRect(0, 0, _width, _height, _style.SIZE * .75, _style.SIZE * .75);
			_back.graphics.endFill();

			super.draw();
		}

		protected function onMouseOver(event:MouseEvent):void
		{
			_over = true;
			TweenLite.to(_back, .25, _style.BUTTON_OVER_TWEEN);
			addEventListener(MouseEvent.ROLL_OUT, onMouseOut, false, 0, true);
		}

		protected function onMouseOut(event:MouseEvent):void
		{
			removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);

			// destroyed?
			if (!_style)
				return;

			_over = false;
			if (!_down)
			{
				TweenLite.to(_back, .25, _style.BUTTON_UP_TWEEN);
			}
			else
			{
				TweenLite.to(_back, .25, _style.BUTTON_DOWN_TWEEN);
			}
		}

		protected function onMouseDown(event:MouseEvent):void
		{
			_down = true;
			TweenLite.to(_back, .1, _style.BUTTON_DOWN_TWEEN);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
		}

		protected function onMouseUp(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			if (_toggle && _over)
			{
				_selected = !_selected;
			}
			_down = _selected;
			if (_over)
			{
				TweenLite.to(_back, .1, _style.BUTTON_OVER_TWEEN);
			}
			else
			{
				TweenLite.to(_back, .1, _style.BUTTON_UP_TWEEN);
			}
		}

		public function set label(str:String):void
		{
			_labelText = str;
			draw();
		}

		public function get label():String
		{
			return _labelText;
		}

		public function set selected(value:Boolean):void
		{
			if (!_toggle)
				return;

			_selected = value;
			_down = _selected;
		}

		public function get selected():Boolean
		{
			return _selected;
		}

		public function set toggle(value:Boolean):void
		{
			_toggle = value;
		}

		public function get toggle():Boolean
		{
			return _toggle;
		}
	}
}