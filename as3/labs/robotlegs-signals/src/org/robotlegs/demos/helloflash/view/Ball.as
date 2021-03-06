/*
 * Copyright (c) 2009 the original author or authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package org.robotlegs.demos.helloflash.view
{
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import org.robotlegs.demos.helloflash.model.SomeVO;
	
	public class Ball extends Sprite
	{
		protected var color:uint;
		protected var radius:Number = 10;
		
		public function Ball(someVO:SomeVO)
		{
			alpha = 0.75;
			useHandCursor = true;
			buttonMode = true;
			draw();
			
			var tf:TextField;
			addChild(tf = new TextField);
			tf.text = String(someVO.someValue);
			tf.autoSize = "left";
			tf.selectable = false;
			tf.x = 10;
		}
		
		public function poke():void
		{
			radius++;
			color = Math.random() * uint.MAX_VALUE;
			draw();
		}
		
		public function draw():void
		{
			graphics.clear();
			graphics.beginFill(color);
			graphics.drawCircle(0, 0, radius);
		}
	
	}
}