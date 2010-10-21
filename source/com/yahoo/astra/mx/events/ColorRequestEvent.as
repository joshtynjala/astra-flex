/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.events
{
	import flash.events.Event;

	/**
	 * A control may request a new color value.
	 * 
	 * @see com.yahoo.astra.mx.controls.colorPickerClasses.IColorRequester
	 * 
	 * @author Josh Tynjala
	 */
	public class ColorRequestEvent extends Event
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
	
		/**
		 * Constant defining the event type fired when a IColorRequestor
		 * requests a new color.
		 */
		public static const REQUEST_COLOR:String = "requestColor";
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function ColorRequestEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, currentColor:uint = 0xFFFFFFFF)
		{
			super(type, bubbles, cancelable);
			this.currentColor = currentColor;
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The color currently displayed by the IColorViewer.
		 */
		public var currentColor:uint;
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new ColorRequestEvent(this.type, this.bubbles, this.cancelable, this.currentColor);
		}
		
	}
}