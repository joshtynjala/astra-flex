/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.events
{
	import flash.events.Event;

	/**
	 * Events related to the TimeStepper control.
	 * 
	 * @see com.yahoo.astra.mx.controls.TimeStepper
	 * 
	 * @author Josh Tynjala
	 */
	public class TimeStepperEvent extends Event
	{
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
	
		/**
		 *  The <code>TimeStepperEvent.CHANGE</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>change</code> event.
		 *
	     *	<p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
	     *       event listener that handles the event. For example, if you use
	     *       <code>myButton.addEventListener()</code> to register an event listener,
	     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
	     *       it is not always the Object listening for the event.
	     *       Use the <code>currentTarget</code> property to always access the
	     *       Object listening for the event.</td></tr>
	     *     <tr><td><code>value</code></td><td>The value of the NumericStepper control 
	     *       when the event was dispatched.</td></tr>
		 *  </table>
		 *
	     *  @eventType change
		 */
		public static const CHANGE:String = "change";
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor
		 */
		public function TimeStepperEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, value:Date = null)
		{
			super(type, bubbles, cancelable);
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------

		/**
		 *The value of the TimeStepper control when the event was dispatched.
		 */	
		public var value:Date;
	
		/**
		 * If the value is changed in response to a user action, 
		 * this property contains a value indicating the type of input action. 
		 * The value is either <code>InteractionInputType.MOUSE</code> 
		 * or <code>InteractionInputType.KEYBOARD</code>.
		 */
		public var triggerEvent:Event;
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new TimeStepperEvent(type, bubbles, cancelable, value);
		}
	
	}
}