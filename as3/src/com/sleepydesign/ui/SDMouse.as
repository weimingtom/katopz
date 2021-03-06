package com.sleepydesign.ui
{
	import com.sleepydesign.core.IDestroyable;

	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import org.osflash.signals.Signal;

	public class SDMouse implements IDestroyable
	{
		private var _target:InteractiveObject;
		private var _dragTarget:*;

		private var _lastPosition:Point = new Point();

		public static var isMouseDown:Boolean = false;
		public static var distance:Number = 0;

		public var yUp:Boolean = true;

		public var mouseSignal:Signal = new Signal(MouseEvent);
		public var wheelSignal:Signal = new Signal(MouseEvent);

		public var dragSignal:Signal = new Signal(Object);
		public var dropSignal:Signal = new Signal(Object);

		public function SDMouse(target:InteractiveObject)
		{
			_target = target;
			create();
		}

		public function create():void
		{
			_target.addEventListener(MouseEvent.MOUSE_DOWN, onMouseHandler);
			_target.addEventListener(MouseEvent.MOUSE_UP, onMouseHandler);
			_target.addEventListener(MouseEvent.ROLL_OUT, onMouseHandler);
			_target.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}

		private function onMouseHandler(event:MouseEvent):void
		{
			switch (event.type)
			{
				case MouseEvent.MOUSE_DOWN:
					_target["mouseChildren"] = true;
					isMouseDown = true;
					_lastPosition.x = event.stageX;
					_lastPosition.y = event.stageY;
					_dragTarget = event.target;

					_target.addEventListener(MouseEvent.MOUSE_MOVE, onMouseHandler, false, 0, true);
					break;
				case MouseEvent.ROLL_OUT:
				case MouseEvent.MOUSE_UP:
					_target["mouseChildren"] = true;
					isMouseDown = false;
					_lastPosition.x = event.stageX;
					_lastPosition.y = event.stageY;
					_dragTarget = null;

					_target.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseHandler);
					//dispatchEvent(new SDMouseEvent(SDMouseEvent.MOUSE_DROP, {target: _dragTarget, dx: dx, dy: dy, distance: distance}, event));
					dropSignal.dispatch({target: _dragTarget, dx: dx, dy: dy, distance: distance});
					break;
				case MouseEvent.MOUSE_MOVE:
					_target["mouseChildren"] = false;
					if (isMouseDown) // && event.target == _dragTarget && event.relatedObject == null)
					{
						var dx:Number = event.stageX - _lastPosition.x;
						var dy:Number = event.stageY - _lastPosition.y;
						distance = Point.distance(new Point(event.stageX, event.stageY), _lastPosition);

						//dispatchEvent(new SDMouseEvent(SDMouseEvent.MOUSE_DRAG, {target: _dragTarget, dx: dx, dy: yUp ? -dy : dy, distance: distance}, event));
						dragSignal.dispatch({target: _dragTarget, dx: dx, dy: yUp ? -dy : dy, distance: distance});

						_lastPosition.x = event.stageX;
						_lastPosition.y = event.stageY;
					}

					/*
					   if ( isMouseDown && (isCTRL || isSHIFT || isSPACE))
					   {
					   _lastPosition.x = event.stageX;
					   _lastPosition.y = event.stageY;

					   _targetRotationY = lastRotationY - (_lastPosition.x - event.stageX) *.5;
					   _targetRotationX = lastRotationX + (_lastPosition.y - event.stageY) *.5;
					   }
					 */
					break;
			}
			//dispatchEvent(event.clone());
			mouseSignal.dispatch(event);
		}

		private function onMouseWheel(event:MouseEvent):void
		{
			//dispatchEvent(event.clone());
			wheelSignal.dispatch(event);
		}

		protected var _isDestroyed:Boolean;

		public function get destroyed():Boolean
		{
			return _isDestroyed;
		}

		public function destroy():void
		{
			_isDestroyed = true;

			/*
			_target.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseHandler);
			_target.removeEventListener(MouseEvent.MOUSE_UP, onMouseHandler);
			_target.removeEventListener(MouseEvent.MOUSE_OUT, onMouseHandler);
			_target.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);

			_target.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseHandler);
			*/

			_target = null;
			_dragTarget = null;
			_lastPosition = null;
		}
	}
}