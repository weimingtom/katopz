/*
	CASA Lib for ActionScript 3.0
	Copyright (c) 2009, Aaron Clinger & Contributors of CASA Lib
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	
	- Redistributions of source code must retain the above copyright notice,
	  this list of conditions and the following disclaimer.
	
	- Redistributions in binary form must reproduce the above copyright notice,
	  this list of conditions and the following disclaimer in the documentation
	  and/or other materials provided with the distribution.
	
	- Neither the name of the CASA Lib nor the names of its contributors
	  may be used to endorse or promote products derived from this software
	  without specific prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.
*/
package com.sleepydesign.display
{
	import com.sleepydesign.core.IDestroyable;
	import com.sleepydesign.events.IRemovableEventDispatcher;
	import com.sleepydesign.events.ListenerManager;
	import com.sleepydesign.utils.DisplayObjectUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	
	/**
		A base Sprite that implements {@link IRemovableEventDispatcher} and {@link IDestroyable}.
		
		@author Aaron Clinger
		@version 05/29/09
	*/
	public class SDSprite extends Sprite implements IRemovableEventDispatcher, IDestroyable {
		protected var _listenerManager:ListenerManager;
		protected var _isDestroyed:Boolean;
		
		
		/**
			Creates a new SDSprite.
		*/
		public function SDSprite() {
			super();
			
			this._listenerManager = ListenerManager.getManager(this);
		}
		
		/**
			@exclude
		*/
		override public function dispatchEvent(event:Event):Boolean {
			if (this.willTrigger(event.type))
				return super.dispatchEvent(event);
			
			return true;
		}
		
		/**
			@exclude
		*/
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			this._listenerManager.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
			@exclude
		*/
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			super.removeEventListener(type, listener, useCapture);
			this._listenerManager.removeEventListener(type, listener, useCapture);
		}
		
		public function removeEventsForType(type:String):void {
			this._listenerManager.removeEventsForType(type);
		}
		
		public function removeEventsForListener(listener:Function):void {
			this._listenerManager.removeEventsForListener(listener);
		}
		
		public function removeEventListeners():void {
			this._listenerManager.removeEventListeners();
		}
		
		/**
			Removes and optionally destroys children of the SDSprite.
			
			@param destroyChildren: If a child implements {@link IDestroyable} call its {@link IDestroyable#destroy destroy} method <code>true</code>, or don't destroy <code>false</code>; defaults to <code>false</code>.
			@param recursive: Call this method with the same arguments on all of the children's children (all the way down the display list) <code>true</code>, or leave the children's children <code>false</code>; defaults to <code>false</code>.
		*/
		public function removeChildren(destroyChildren:Boolean = false, recursive:Boolean = false):void {
			DisplayObjectUtil.removeChildren(this, destroyChildren, recursive);
		}
		
		/**
			Removes and optionally destroys children of the SDSprite then destroys itself.
			
			@param destroyChildren: If a child implements {@link IDestroyable} call its {@link IDestroyable#destroy destroy} method <code>true</code>, or don't destroy <code>false</code>; defaults to <code>false</code>.
			@param recursive: Call this method with the same arguments on all of the children's children (all the way down the display list) <code>true</code>, or leave the children's children <code>false</code>; defaults to <code>false</code>.
		*/
		public function removeChildrenAndDestroy(destroyChildren:Boolean = false, recursive:Boolean = false):void {
			this.removeChildren(destroyChildren, recursive);
			this.destroy();
		}
		
		public function get destroyed():Boolean {
			return this._isDestroyed;
		}
		
		/**
			{@inheritDoc}
			
			Calling <code>destroy()</code> on a SD display object also removes it from its current parent.
		*/
		public function destroy():void {
			this.removeEventListeners();
			this._listenerManager.destroy();
			
			this._isDestroyed = true;
			
			if (this.parent != null)
				this.parent.removeChild(this);
		}
	}
}