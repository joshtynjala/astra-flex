/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls
{
	import com.yahoo.astra.mx.controls.inputClasses.BaseMultiFieldInput;
	import com.yahoo.astra.mx.events.TimeInputEvent;
	import com.yahoo.astra.utils.StringUtil;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.ui.Keyboard;
	
	import mx.core.EdgeMetrics;
	import mx.core.IBorder;
	import mx.core.UITextField;
	import mx.events.FlexEvent;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 *  Dispatched when text in the TimeInput control changes
	 *  through user input.
	 *  This event does not occur if you use data binding or 
	 *  ActionScript code to change the text.
	 *
	 *  <p>Even though the default value of the <code>Event.bubbles</code> property 
	 *  is <code>true</code>, this control dispatches the event with 
	 *  the <code>Event.bubbles</code> property set to <code>false</code>.</p>
	 *
	 *  @eventType flash.events.Event.CHANGE
	 */
	[Event(name="change", type="flash.events.Event")]
		
	//--------------------------------------
	//  Styles
	//--------------------------------------

	/**
	 * If true, the hours value will always be displayed with two digits.
	 * 
	 * @default true
	 */
	[Style(name="displayTwoDigitHoursValue", type="Boolean", inherit="no")]

	/**
	 * If true, the seconds value will be displayed.
	 * 
	 * @default true
	 */
	[Style(name="showSeconds", type="Boolean", inherit="no")]

	/**
	 * If true, and the useTwelveHourFormat style is also true, the AM or PM
	 * string will be displayed.
	 * 
	 * @default true
	 */
	[Style(name="showAMPM", type="Boolean", inherit="no")]

	/**
	 * If true, the hours display will accept values from 1-12 only. If false,
	 * time will be displayed and edited in 24 hour format. In that case, the AM
	 * and PM value will be ignored.
	 * 
	 * @default true
	 */
	[Style(name="useTwelveHourFormat", type="Boolean", inherit="no")]

	/**
	 * The String displayed for the AM value.
	 * 
	 * @default AM
	 */
	[Style(name="AMText", type="String", inherit="no")]

	/**
	 * The String displayed for the PM value.
	 * 
	 * @default PM
	 */
	[Style(name="PMText", type="String", inherit="no")]
	
	//--------------------------------------
	//  Other Metadata
	//--------------------------------------
	[AccessibilityClass(implementation="com.yahoo.astra.mx.accessibility.TimeInputAccImpl")]
	
	[DefaultBindingProperty(source="value", destination="value")]
	
	/**
	 * An input control for time values. Includes fields for hours, minutes, and seconds.
	 * 
	 * @author Josh Tynjala
	 */
	public class TimeInput extends BaseMultiFieldInput
	{
		
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function TimeInput()
		{
			super();
			this.fieldCount = 4;
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * @private
		 * The UITextFields for the ":" separators.
		 */
		protected var separators:Array = [];

		[Bindable("valueCommit")]
		/**
		 * The string value that will be displayed by the control.
		 */
		public function get text():String
		{
			return textFields[0].text + ":" + textFields[1].text + ":" + textFields[2].text + " " + textFields[3].text;
		}
		
		/**
		 * @private
		 * Storage for the value property.
		 */
		private var _value:Date = new Date();
		
		[Bindable("valueCommit")]
		/**
		 * The date value that will be displayed by the control.
		 */
		public function get value():Date
		{
			return this._value;
		}
		
		/**
		 * @private
		 */
		public function set value(time:Date):void
		{
			this._value = time;
			this.invalidateProperties();
			this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
		
		/**
		 * @private
		 * The width of a two-digit number. Used in measurement calculations and
		 * positioning.
		 */
		private var _numberWidth:Number = 0;
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			
			if(!styleProp || styleProp.indexOf("font") >= 0 || styleProp.indexOf("text") >= 0)
			{
				//we have to do this even if we have explicit dimensions
				//because positioning relies on the size of two characters
				var tempTextField:UITextField = new UITextField();
				tempTextField.styleName = this;
				tempTextField.ignorePadding = true;
				tempTextField.text = "00";
				
				//figured invalidation and validation would be enough
				//but we have to add and remove the UITextField too!
				this.addChild(tempTextField);
				
				this._numberWidth = tempTextField.measuredWidth;
				this.removeChild(tempTextField);
				
				this.invalidateSize();
				this.invalidateDisplayList();
			}
			
			if(!styleProp || styleProp == "showSeconds" || styleProp == "showAMPM" || styleProp == "displayTwoDigitHoursValue"
				|| styleProp == "useTwelveHourFormat" || styleProp == "AMText" || styleProp == "PMText")
			{
				this.invalidateProperties();
				this.invalidateSize();
				this.invalidateDisplayList();
			}
		}
		
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			for(var i:int = 0; i < 2; i++)
			{
				var separatorField:UITextField = new UITextField();
				separatorField.styleName = this;
				separatorField.ignorePadding = true;
				separatorField.selectable = false;
				separatorField.enabled = this.enabled;
				separatorField.text = ":";
				this.addChild(separatorField);
				this.separators.push(separatorField);
			}
			
			//update the input fields
			var hoursField:UITextField = UITextField(this.textFields[0]);
			hoursField.styleName = this;
			hoursField.ignorePadding = true;
			hoursField.maxChars = 2;
			hoursField.restrict = "0-9";
			hoursField.addEventListener(FocusEvent.FOCUS_IN, hoursFocusInHandler);
			hoursField.addEventListener(FocusEvent.FOCUS_OUT, hoursFocusOutHandler);
			hoursField.addEventListener(TextEvent.TEXT_INPUT, hoursTextInputHandler);
			
			var minutesField:UITextField = UITextField(this.textFields[1]);
			minutesField.styleName = this;
			minutesField.ignorePadding = true;
			minutesField.maxChars = 2;
			minutesField.restrict = "0-9";
			minutesField.addEventListener(FocusEvent.FOCUS_IN, minutesFocusInHandler);
			minutesField.addEventListener(FocusEvent.FOCUS_OUT, minutesFocusOutHandler);
			minutesField.addEventListener(TextEvent.TEXT_INPUT, minutesAndSecondsTextInputHandler);
			
			var secondsField:UITextField = UITextField(this.textFields[2]);
			secondsField.styleName = this;
			secondsField.ignorePadding = true;
			secondsField.maxChars = 2;
			secondsField.restrict = "0-9";
			secondsField.addEventListener(FocusEvent.FOCUS_IN, secondsFocusInHandler);
			secondsField.addEventListener(FocusEvent.FOCUS_OUT, secondsFocusOutHandler);
			secondsField.addEventListener(TextEvent.TEXT_INPUT, minutesAndSecondsTextInputHandler);
			
			var AMPMField:UITextField = UITextField(this.textFields[3]);
			AMPMField.addEventListener(KeyboardEvent.KEY_DOWN, AMPMKeyDownHandler);
			AMPMField.addEventListener(FocusEvent.FOCUS_IN, ampmFocusInHandler);
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			var useTwelveHourFormat:Boolean = this.getStyle("useTwelveHourFormat");
			var displayTwoDigitHoursValue:Boolean = this.getStyle("displayTwoDigitHoursValue");
			var showSeconds:Boolean = this.getStyle("showSeconds");
			var showAMPM:Boolean = this.getStyle("showAMPM");
			
			var separatorCount:int = this.separators.length;
			for(var i:int = 0; i < separatorCount; i++)
			{
				var separator:UITextField = UITextField(this.separators[i]);
				separator.enabled = this.enabled;
				
				if(i == 1)
				{
					separator.visible = showSeconds;
				}
			}
			
			super.commitProperties();
			
			var hours:Number = this.value.getHours();
			if(useTwelveHourFormat)
			{
				if(hours == 0) hours = 12;
				else if(hours > 12) hours -= 12;
			} 
			var hoursValue:String = hours.toString();
			if(displayTwoDigitHoursValue)
			{
				hoursValue = StringUtil.padFront(hoursValue, 2, "0");
			}
			var hoursField:UITextField = UITextField(this.textFields[0]);
			hoursField.text = hoursValue;
			
			var minutesField:UITextField = UITextField(this.textFields[1]);
			minutesField.text = StringUtil.padFront(this.value.getMinutes().toString(), 2, "0");
			
			var secondsField:UITextField = UITextField(this.textFields[2]);
			secondsField.text = StringUtil.padFront(this.value.getSeconds().toString(), 2, "0");
			secondsField.visible = showSeconds;
			
			var AMPMField:UITextField = UITextField(this.textFields[3]);
			if(this.value.getHours() < 12)
			{
				AMPMField.text = this.getStyle("AMText");
			} 
			else AMPMField.text = this.getStyle("PMText");
			AMPMField.visible = useTwelveHourFormat && showAMPM;
		}
		
		/**
		 * @private
		 */
		override protected function measure():void
		{
			super.measure();
			
			var useTwelveHourFormat:Boolean = this.getStyle("useTwelveHourFormat");
			var showSeconds:Boolean = this.getStyle("showSeconds");
			var showAMPM:Boolean = this.getStyle("showAMPM");
			
			if(this.border)
			{
				var metrics:EdgeMetrics = this.border is IBorder ? IBorder(this.border).borderMetrics : EdgeMetrics.EMPTY;
				this.measuredWidth = metrics.left + metrics.right;
				this.measuredHeight = metrics.top + metrics.bottom;
			}
			
			var separatorCount:int = this.separators.length;
			for(var i:int = 0; i < separatorCount; i++)
			{
				var separator:UITextField = UITextField(this.separators[i]);
				if(i == 0 || (i == 1 && showSeconds))
				{
					this.measuredWidth += separator.measuredWidth;
				}
			}
			
			//hours and minutes are always displayed
			this.measuredWidth += this._numberWidth * 2;
			this.measuredHeight += UITextField(this.textFields[0]).measuredHeight;
			
			if(showSeconds)
			{
				//add seconds if needed
				var secondsField:UITextField = UITextField(this.textFields[2]);
				this.measuredWidth += this._numberWidth;
			}
			if(useTwelveHourFormat && showAMPM)
			{
				//add am/pm if needed
				var AMPMField:UITextField = UITextField(this.textFields[3]);
				this.measuredWidth += AMPMField.measuredWidth;
			}
			
			//since we don't want the text being cut off, the min width and height are the same as the regular values.
			this.measuredMinWidth = this.measuredWidth;
			this.measuredMinHeight = this.measuredHeight;
			
		}
		
		/**
		 * @private
		 * Overrides default layout algorithm to include the separator fields. 
		 */
		override protected function layoutTextFields():void
		{
			var showSeconds:Boolean = this.getStyle("showSeconds");
			
			var metrics:EdgeMetrics = this.border is IBorder ? IBorder(this.border).borderMetrics : EdgeMetrics.EMPTY;
			var tfHeight:Number = Math.max(0, unscaledHeight - metrics.top - metrics.bottom);
			
			var xPosition:Number = metrics.left;
			var yPosition:Number = metrics.top;
			
			var hoursField:UITextField = UITextField(this.textFields[0]);
			hoursField.x = xPosition;
			hoursField.y = yPosition;
			hoursField.setActualSize(Math.min(Math.max(0, unscaledWidth - metrics.right - xPosition), this._numberWidth), tfHeight);
			xPosition += hoursField.width;
			
			var separatorField:UITextField = UITextField(this.separators[0]);
			separatorField.x = xPosition;
			separatorField.y = yPosition;
			separatorField.setActualSize(Math.min(Math.max(0, unscaledWidth - metrics.right - separatorField.x), separatorField.measuredWidth), tfHeight);
			xPosition += separatorField.measuredWidth;
			
			var minutesField:UITextField = UITextField(this.textFields[1]);
			minutesField.x = xPosition;
			minutesField.y = yPosition;
			minutesField.setActualSize(Math.min(Math.max(0, unscaledWidth - metrics.right - xPosition), this._numberWidth), tfHeight);
			xPosition += minutesField.width;
			
			if(showSeconds)
			{
				separatorField = UITextField(this.separators[1]);
				separatorField.x = xPosition;
				separatorField.y = yPosition;
				separatorField.setActualSize(Math.min(Math.max(0, unscaledWidth - metrics.right - separatorField.x), separatorField.measuredWidth), tfHeight);
				xPosition += separatorField.measuredWidth;
				
				var secondsField:UITextField = UITextField(this.textFields[2]);
				secondsField.x = xPosition;
				secondsField.y = yPosition;
				secondsField.setActualSize(Math.min(Math.max(0, unscaledWidth - metrics.right - xPosition), this._numberWidth), tfHeight);
				xPosition += secondsField.width;
			}
			
			var AMPMField:UITextField = UITextField(this.textFields[3]);
			AMPMField.x = xPosition;
			AMPMField.y = yPosition;
			AMPMField.setActualSize(Math.min(Math.max(0, unscaledWidth - metrics.right - xPosition), AMPMField.measuredWidth), tfHeight);
		}
		
		/**
		 * @private
		 */
		override protected function focusNextTextField(textField:UITextField):void
		{
			var useTwelveHourFormat:Boolean = this.getStyle("useTwelveHourFormat");
			var showSeconds:Boolean = this.getStyle("showSeconds");
			var showAMPM:Boolean = this.getStyle("showAMPM");
			var index:int = this.textFields.indexOf(textField);
			
			if(index == 1 && !showSeconds)
			{
				//if we aren't showing seconds, but we're showing AM/PM, switch
				//to the AMPMField. otherwise, ignore the request.
				if(showAMPM)
				{
					this.callLater(UITextField(this.textFields[3]).setFocus);
				}
				return;
			}
			else if(index == 2 && (!useTwelveHourFormat || !showAMPM))
			{
				//if we're not showing the AMPMField, ignore the request.
				return;
			}
			
			//force the focus to stay on the AMPMField
			if(index == 3)
			{
				//be sure to keep it selected and the scroll at index 0
				this.callLater(function():void
					{
						textField.setSelection(0, textField.length);
						textField.scrollH = 0;
					});
				return;
			}
			
			super.focusNextTextField(textField);
		}
		
		/**
		 * @private
		 */
		override protected function focusPreviousTextField(textField:UITextField):void
		{
			var useTwelveHourFormat:Boolean = this.getStyle("useTwelveHourFormat");
			var showSeconds:Boolean = this.getStyle("showSeconds");
			var showAMPM:Boolean = this.getStyle("showAMPM");
			var index:int = this.textFields.indexOf(textField);
			
			if(index == 3 && !showSeconds)
			{
				//if we aren't showing seconds, switch the to minutes field
				this.callLater(UITextField(this.textFields[1]).setFocus);
				return;
			}
			
			super.focusPreviousTextField(textField);
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
		
		/**
		 * @private
		 * Validates hours input.
		 */
		protected function hoursTextInputHandler(event:TextEvent):void
		{
			var useTwelveHourFormat:Boolean = this.getStyle("useTwelveHourFormat");
			var textField:UITextField = UITextField(event.target);
			
			var text:String = textField.text;
			text = text.substr(0, textField.selectionBeginIndex) + event.text + text.substr(textField.selectionEndIndex);
			var value:int = int(text);
			if((useTwelveHourFormat && value > 12) || value > 23)
			{
				//if a value is greater than the number of possible hours, we don't want it!
				event.preventDefault();
			}
		}
		
		/**
		 * @private
		 * Informs listeners when the hours field receives focus.
		 */
		protected function hoursFocusInHandler(event:FocusEvent):void
		{
			this.dispatchEvent(new TimeInputEvent(TimeInputEvent.HOURS_FOCUS_IN));
		}
	
		/**
		 * @private
		 * Handles changes to the hours UITextField. Updates the dataProvider.
		 */
		protected function hoursFocusOutHandler(event:Event):void
		{
			var useTwelveHourFormat:Boolean = this.getStyle("useTwelveHourFormat");
			
			var hoursField:UITextField = UITextField(event.target);
			
			var hours:Number = 0;
			if(hoursField.length > 0)
			{
				hours = int(hoursField.text);
			}
			
			//if pm, adjust the hours to fit in 24 hour format
			if(useTwelveHourFormat)
			{
				hours = Math.min(hours, 12);
				var currentHours:Number = this.value.getHours();
				if(currentHours >= 12) //pm
				{
					if(hours != 12 && hours != 0)
					{
						//we want to keep pm
						hours += 12;
					}
				}
				else if(hours == 12)
				{
					hours = 0;
				}
			}
			else hours = Math.min(hours, 23);
			
			this.value.setHours(hours);
			this.invalidateProperties();
			this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * @private
		 * Validates minutes and seconds input.
		 */
		protected function minutesAndSecondsTextInputHandler(event:TextEvent):void
		{
			var textField:UITextField = UITextField(event.target);
			
			var text:String = textField.text;
			text = text.substr(0, textField.selectionBeginIndex) + event.text + text.substr(textField.selectionEndIndex);
			var value:int = int(text);
			if(value > 59)
			{
				//if a value is greater than 59, we don't want it!
				event.preventDefault();
			}
		}
		
		/**
		 * @private
		 * Informs listeners when the minutes field receives focus.
		 */
		protected function minutesFocusInHandler(event:FocusEvent):void
		{
			this.dispatchEvent(new TimeInputEvent(TimeInputEvent.MINUTES_FOCUS_IN));
		}
		
		/**
		 * @private
		 * Handles changes to the minutes UITextField. Updates the dataProvider.
		 */
		protected function minutesFocusOutHandler(event:FocusEvent):void
		{
			var minutesField:UITextField = UITextField(event.target);
			
			var minutes:Number = 0;
			if(minutesField.length > 0)
			{
				minutes = int(minutesField.text);
			}
			//validate
			minutes = Math.min(minutes, 59);
			
			this.value.setMinutes(minutes);
			this.invalidateProperties();
			this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * @private
		 * Informs listeners when the seconds field receives focus.
		 */
		protected function secondsFocusInHandler(event:FocusEvent):void
		{
			this.dispatchEvent(new TimeInputEvent(TimeInputEvent.SECONDS_FOCUS_IN));
		}
		
		/**
		 * @private
		 * Handles changes to the seconds UITextField. Updates the dataProvider.
		 */
		protected function secondsFocusOutHandler(event:FocusEvent):void
		{
			var secondsField:UITextField = UITextField(event.target);
			
			var seconds:Number = 0;
			if(secondsField.length > 0)
			{
				seconds = int(secondsField.text);
			}
			//validate
			seconds = Math.min(seconds, 59);
			
			this.value.setSeconds(seconds);
			this.invalidateProperties();
			this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * @private
		 * Ensures that the ampm field selects on focus and informs listeners
		 * when it becomes focued.
		 */
		protected function ampmFocusInHandler(event:FocusEvent):void
		{
			var textField:UITextField = UITextField(event.target);
			this.callLater(textField.setSelection, [0, textField.length]);
			this.dispatchEvent(new TimeInputEvent(TimeInputEvent.AMPM_FOCUS_IN));
		}
		
		/**
		 * @private
		 * Validates input in the AMPM field. Also ensures that the text stays selected.
		 */
		protected function AMPMKeyDownHandler(event:KeyboardEvent):void
		{
			var value:Date = new Date(this.value.valueOf());
			var hours:Number = value.getHours();
			if(event.charCode == String("a").charCodeAt(0) && hours >= 12)
			{
				value.setHours(hours - 12);
			}
			else if(event.charCode == String("p").charCodeAt(0) && hours < 12)
			{
				value.setHours(hours + 12);
			}
			else if(event.keyCode == Keyboard.UP || event.keyCode == Keyboard.DOWN)
			{
				//if the user presses up or down, make sure the focus stays in place.
				var textField:UITextField = UITextField(event.target);
				this.callLater(textField.setSelection, [0, textField.length]);
			}
			this.value = value;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
	
	//--------------------------------------------------------------------------
	//
	//  Accessibility
	//
	//--------------------------------------------------------------------------		

		
		/**
		 * @inheritDoc
		 */	
		public static var createAccessibilityImplementation:Function;
		
 		/**
		 * @inheritDoc
		 */
		 override protected function initializeAccessibility():void
		{
		     if (TimeInput.createAccessibilityImplementation!=null)
		          TimeInput.createAccessibilityImplementation(this);
		} 
	}
}