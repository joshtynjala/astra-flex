/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.events
{
	import flash.events.Event;

	/**
	 * Event class for the TimeInput control
	 * 
	 * @see com.yahoo.astra.mx.controls.TimeInput
	 * 
	 * @author Josh Tynjala
	 */
	public class TimeInputEvent extends Event
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
	
		/**
		 * Constant defining the event type fired when the hours field of a
		 * TimeInput receives focus.
		 */
		public static const HOURS_FOCUS_IN:String = "hoursFocusIn";
		
		/**
		 * Constant defining the event type fired when the minutes field of a
		 * TimeInput receives focus.
		 */
		public static const MINUTES_FOCUS_IN:String = "minutesFocusIn";
		
		/**
		 * Constant defining the event type fired when the seconds field of a
		 * TimeInput receives focus.
		 */
		public static const SECONDS_FOCUS_IN:String = "secondsFocusIn";
		
		/**
		 * Constant defining the event type fired when the am/pm field of a
		 * TimeInput receives focus.
		 */
		public static const AMPM_FOCUS_IN:String = "ampmFocusIn";
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function TimeInputEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new TimeInputEvent(this.type, this.bubbles, this.cancelable);
		}
		
	}
}