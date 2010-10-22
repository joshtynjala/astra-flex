/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls
{
	import com.yahoo.astra.mx.core.yahoo_mx_internal;
	import com.yahoo.astra.mx.events.TimeInputEvent;
	import com.yahoo.astra.mx.events.TimeStepperEvent;
	import com.yahoo.astra.utils.TimeUnit;
	
	import flash.display.DisplayObject;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.Button;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import mx.managers.IFocusManagerComponent;
	import mx.styles.StyleProxy;

	use namespace mx_internal;
	use namespace yahoo_mx_internal;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 *  Dispatched when the value of the TimeStepper control changes
	 *  as a result of user interaction.
	 *
	 *  @eventType com.yahoo.astra.mx.events.TimeStepperEvent.CHANGE
	 */
	[Event(name="change", type="com.yahoo.astra.mx.events.TimeStepperEvent")]

	//--------------------------------------
	//  Styles
	//--------------------------------------

	//Flex framework styles
	
	include "../styles/metadata/BorderStyles.inc"
	include "../styles/metadata/FocusStyles.inc"
	include "../styles/metadata/IconColorStyles.inc"
	include "../styles/metadata/LeadingStyle.inc"
	include "../styles/metadata/PaddingStyles.inc"
	include "../styles/metadata/TextStyles.inc"

	//-- TimeInput styles
	
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
	 * If true, the hours value will always be displayed with two digits.
	 * 
	 * @default false
	 */
	[Style(name="displayTwoDigitHoursValue", type="Boolean", inherit="no")]
	
	//-- stepper styles
	
	/**
	 * Name of the class to use as the default skin for the down arrow.
	 * 
	 * @default mx.skins.halo.NumericStepperDownSkin
	 */
	[Style(name="downArrowSkin", type="Class", inherit="no", states="up, over, down, disabled")]
	
	/**
	 * Name of the class to use as the skin for the Down arrow
	 * when the arrow is disabled.
	 *
	 *  @default mx.skins.halo.NumericStepperDownSkin
	 */
	[Style(name="downArrowDisabledSkin", type="Class", inherit="no")]
	
	/**
	 * Name of the class to use as the skin for the Down arrow
	 * when the arrow is enabled and a user presses the mouse button over the arrow.
	 *
	 * @default mx.skins.halo.NumericStepperDownSkin
	 */
	[Style(name="downArrowDownSkin", type="Class", inherit="no")]
	
	/**
	 * Name of the class to use as the skin for the Down arrow
	 * when the arrow is enabled and the mouse pointer is over the arrow.
	 *  
	 * @default mx.skins.halo.NumericStepperDownSkin
	 */
	[Style(name="downArrowOverSkin", type="Class", inherit="no")]
	
	/**
	 * Name of the class to use as the skin for the Down arrow
	 * when the arrow is enabled and the mouse pointer is not on the arrow.
	 * There is no default.
	 */
	[Style(name="downArrowUpSkin", type="Class", inherit="no")]
		
	/**
	 * Name of the class to use as the default skin for the up arrow.
	 *  
	 * @default mx.skins.halo.NumericStepperUpSkin
	 */
	[Style(name="upArrowSkin", type="Class", inherit="no", states="up, over, down, disabled")]
	
	/**
	 * Name of the class to use as the skin for the Up arrow
	 * when the arrow is disabled.
	 *
	 * @default mx.skins.halo.NumericStepperUpSkin
	 */
	[Style(name="upArrowDisabledSkin", type="Class", inherit="no")]
	
	/**
	 * Name of the class to use as the skin for the Up arrow
	 * when the arrow is enabled and a user presses the mouse button over the arrow.
	 *
	 * @default mx.skins.halo.NumericStepperUpSkin
	 */
	[Style(name="upArrowDownSkin", type="Class", inherit="no")]
	
	/**
	 * Name of the class to use as the skin for the Up arrow
	 * when the arrow is enabled and the mouse pointer is over the arrow.
	 *
	 * @default mx.skins.halo.NumericStepperUpSkin
	 */
	[Style(name="upArrowOverSkin", type="Class", inherit="no")]
	
	/**
	 * Name of the class to use as the skin for the Up arrow
	 * when the arrow is enabled and the mouse pointer is not on the arrow.
	 *
	 * @default mx.skins.halo.NumericStepperUpSkin
	 */
	[Style(name="upArrowUpSkin", type="Class", inherit="no")]

	//--------------------------------------
	//  Other Metadata
	//--------------------------------------


	[DefaultBindingProperty(source="value", destination="value")]
	[DefaultTriggerEvent("change")]
	
	[AccessibilityClass(implementation="com.yahoo.astra.mx.accessibility.TimeStepperAccImpl")]

	/**
	 * A stepper component for the time portion of Date values.
	 * 
	 * @author Josh Tynjala
	 */
	public class TimeStepper extends UIComponent implements IFocusManagerComponent
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
		
		private static const AMPM:String = "ampm";
		
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function TimeStepper()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The previous/decrement button.
		 */
		protected var prevButton:Button;
		
		/**
		 * The next/increment button.
		 */
		protected var nextButton:Button;
		
		/**
		 * The input field for time values.
		 */
		public var timeInput:TimeInput;
		
		/**
		 * @private
		 * The currently focused field in the TimeInput control.
		 */
		protected var focusedField:String;
		
		[Bindable("valueCommit")]
		/**
		 * The string value that will be displayed by the control.
		 */
		public function get text():String
		{
			return timeInput.text;//return textFields[0].text + ":" + textFields[1].text + ":" + textFields[2].text + " " + textFields[3].text;
		}
		
		/**
		 * @private
		 * Storage for the dataProvider property.
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
			if(this._value.valueOf() != time.valueOf())
			{
				this._value = time;
				this.invalidateProperties();
				this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			}
		}
		



		/**
		 * @private
		 * Flag that indicates that the enabled property has changed.
		 */
		protected var enabledChanged:Boolean = false;
		
		[Inspectable(category="General", enumeration="true,false", defaultValue="true")]
		/**
		 * @private
		 * Disable subcontrols when we're disabled.
		 */
		override public function set enabled(value:Boolean):void
		{
			if(value == this.enabled)
			{
				return;
			}
		
			super.enabled = value;
			this.enabledChanged = true;
		
			this.invalidateProperties();
		}
		
		/**
		 * @private
		 * Storage for the upArrowStyleFilters property.
		 */
		private var _upArrowStyleFilters:Object = 
		{
		    "cornerRadius" : "cornerRadius",        
		    "highlightAlphas" : "highlightAlphas",
		    "upArrowUpSkin" : "upArrowUpSkin",
		    "upArrowOverSkin" : "upArrowOverSkin",
		    "upArrowDownSkin" : "upArrowDownSkin",
		    "upArrowDisabledSkin" : "upArrowDisabledSkin",
		    "upArrowSkin" : "upArrowSkin",
		    "repeatDelay" : "repeatDelay",
		    "repeatInterval" : "repeatInterval"
		};
		
		/**
		 * Set of styles to pass from the TimeStepper to the up arrow.
		 * @see mx.styles.StyleProxy
		 */
		protected function get upArrowStyleFilters():Object 
		{
		    return _upArrowStyleFilters;
		}
		
		/**
		 * @private
		 * Storage for the downArrowStyleFilters property.
		 */
		private var _downArrowStyleFilters:Object = 
		{    
		    "cornerRadius" : "cornerRadius",        
		    "highlightAlphas" : "highlightAlphas",
		    "downArrowUpSkin" : "downArrowUpSkin",
		    "downArrowOverSkin" : "downArrowOverSkin",
		    "downArrowDownSkin" : "downArrowDownSkin",
		    "downArrowDisabledSkin" : "downArrowDisabledSkin",
		    "downArrowSkin" : "downArrowSkin",
		    "repeatDelay" : "repeatDelay",
		    "repeatInterval" : "repeatInterval"
		};

		/**
		 * Set of styles to pass from the TimeStepper to the down arrow.
		 * @see mx.styles.StyleProxy
		 */
		protected function get downArrowStyleFilters():Object
		{
		    return _downArrowStyleFilters;
		}
		
		//TODO: Add all filtered styles
		/**
		 * @private
		 * Storage for the timeInputStyleFilters property.
		 */
		private var _timeInputStyleFilters:Object = 
		{    
		    "useTwelveHourFormat" : "useTwelveHourFormat",     
		    "showAMPM" : "showAMPM",        
		    "showSeconds" : "showSeconds",
			"displayTwoDigitHoursValue" : "displayTwoDigitHoursValue",
		    
		    //from NumericStepper:
	        "backgroundAlpha" : "backgroundAlpha",
	        "backgroundColor" : "backgroundColor",
	        "backgroundImage" : "backgroundImage",
	        "backgroundDisabledColor" : "backgroundDisabledColor",
	        "backgroundSize" : "backgroundSize",
	        "borderAlpha" : "borderAlpha", 
	        "borderColor" : "borderColor",
	        "borderSides" : "borderSides", 
	        "borderSkin" : "borderSkin",
	        "borderStyle" : "borderStyle",
	        "borderThickness" : "borderThickness",
	        "dropShadowColor" : "dropShadowColor",
	        "dropShadowEnabled" : "dropShadowEnabled",
	        "embedFonts" : "embedFonts",
	        "focusAlpha" : "focusAlpha",
	        "focusBlendMode" : "focusBlendMode",
	        "focusRoundedCorners" : "focusRoundedCorners", 
	        "focusThickness" : "focusThickness",
	        "paddingLeft" : "paddingLeft", 
	        "paddingRight" : "paddingRight",
	        "shadowDirection" : "shadowDirection",
	        "shadowDistance" : "shadowDistance",
	        "textDecoration" : "textDecoration"
		};

		/**
		 * Set of styles to pass from the TimeStepper to the TimeInput.
		 * @see mx.styles.StyleProxy
		 */
		protected function get timeInputStyleFilters():Object
		{
		    return _timeInputStyleFilters;
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
			
			if(!this.timeInput)
			{
				this.timeInput = new TimeInput();
				
				this.timeInput.styleName = new StyleProxy(this, this.timeInputStyleFilters);
				this.timeInput.focusEnabled = false;
				this.timeInput.parentDrawsFocus = true;
				
				this.timeInput.addEventListener(FlexEvent.VALUE_COMMIT, timeInputValueCommitHandler);
				this.timeInput.addEventListener(TimeInputEvent.HOURS_FOCUS_IN, timeInputUnitFocusInHandler);
				this.timeInput.addEventListener(TimeInputEvent.MINUTES_FOCUS_IN, timeInputUnitFocusInHandler);
				this.timeInput.addEventListener(TimeInputEvent.SECONDS_FOCUS_IN, timeInputUnitFocusInHandler);
				this.timeInput.addEventListener(TimeInputEvent.AMPM_FOCUS_IN, timeInputUnitFocusInHandler);
				this.timeInput.addEventListener(FocusEvent.FOCUS_OUT, timeInputFocusOutHandler);
				this.timeInput.addEventListener(KeyboardEvent.KEY_DOWN, timeInputKeyDownHandler);
				
				this.addChild(this.timeInput);
			}
			
			if(!this.prevButton)
			{
				this.prevButton = new Button();
				
				this.prevButton.styleName = new StyleProxy(this, this.downArrowStyleFilters);
				this.prevButton.upSkinName = "downArrowUpSkin";
				this.prevButton.overSkinName = "downArrowOverSkin";
				this.prevButton.downSkinName = "downArrowDownSkin";
				this.prevButton.disabledSkinName = "downArrowDisabledSkin";
				this.prevButton.skinName = "downArrowSkin";
				this.prevButton.upIconName = "";
				this.prevButton.overIconName = "";
				this.prevButton.downIconName = "";
				this.prevButton.disabledIconName = "";
				this.prevButton.focusEnabled = false;
				this.prevButton.autoRepeat = true;
				
            	this.prevButton.addEventListener(FlexEvent.BUTTON_DOWN, prevButtonDownHandler);
				
				this.addChild(this.prevButton);
			}
			
			if(!this.nextButton)
			{
				this.nextButton = new Button();
				
				this.nextButton.styleName = new StyleProxy(this, this.upArrowStyleFilters);
				this.nextButton.upSkinName = "upArrowUpSkin";
				this.nextButton.overSkinName = "upArrowOverSkin";
				this.nextButton.downSkinName = "upArrowDownSkin";
				this.nextButton.disabledSkinName = "upArrowDisabledSkin";
				this.nextButton.skinName = "upArrowSkin";
				this.nextButton.upIconName = "";
				this.nextButton.overIconName = "";
				this.nextButton.downIconName = "";
				this.nextButton.disabledIconName = "";

				this.nextButton.focusEnabled = false;
				this.nextButton.autoRepeat = true;
				
            	this.nextButton.addEventListener(FlexEvent.BUTTON_DOWN, nextButtonDownHandler);
				
				this.addChild(this.nextButton);
			}
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
	        if(this.enabledChanged)
	        {
				this.timeInput.enabled = this.prevButton.enabled = this.nextButton.enabled = this.enabled;
				this.enabledChanged = false;
	        }
			
			this.timeInput.value = this.value;
		}
		
		/**
		 * @private
		 */
		override protected function measure():void
		{
			super.measure();
			
	        var buttonWidth:Number = Math.max(prevButton.getExplicitOrMeasuredWidth(), nextButton.getExplicitOrMeasuredWidth());
        	var buttonHeight:Number = prevButton.getExplicitOrMeasuredHeight() + nextButton.getExplicitOrMeasuredHeight();
                                  
			this.measuredWidth = this.timeInput.getExplicitOrMeasuredWidth() + buttonWidth;
			this.measuredHeight = Math.max(this.timeInput.getExplicitOrMeasuredHeight(), buttonHeight);
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			var w:Number = this.nextButton.getExplicitOrMeasuredWidth();
			var h:Number = Math.round(unscaledHeight / 2);
			var h2:Number = unscaledHeight - h;
			
			this.nextButton.x = unscaledWidth - w;
			this.nextButton.y = 0;
			this.nextButton.setActualSize(w, h2);
			
			this.prevButton.x = unscaledWidth - w;
			this.prevButton.y = unscaledHeight - h;
			this.prevButton.setActualSize(w, h);
			
			this.timeInput.setActualSize(unscaledWidth - w, unscaledHeight);
		}

		/**
		 * @private
		 */
		override protected function isOurFocus(target:DisplayObject):Boolean
		{
		    return target == this.timeInput || super.isOurFocus(target);
		}
		
		/**
		 * Increases the value of the selected field (and rotates back to the
		 * minimum value, if the maximum is reached). 
		 */
		protected function increment():void
		{
			var useTwelveHourFormat:Boolean = this.getStyle("useTwelveHourFormat");
			var value:Date = new Date(this.value.valueOf());
			switch(this.focusedField)
			{
				case TimeUnit.MINUTES:
					var minutes:Number = value.getMinutes();
					if(minutes == 59) minutes = 0;
					else minutes++;
					value.setMinutes(minutes);
					break;
				case TimeUnit.SECONDS:
					var seconds:Number = value.getSeconds();
					if(seconds == 59) seconds = 0;
					else seconds++;
					value.setSeconds(seconds);
					break;
				case AMPM:
					var hours:Number = value.getHours();
					if(hours >= 12) hours -= 12; //pm
					else hours += 12; //am
					value.setHours(hours);
					break;
				default: //hours
					hours = value.getHours();
					if(useTwelveHourFormat)
					{
						if(hours >= 12) //pm
						{
							if(hours == 23) hours = 12;
							else hours++;
						}
						else //am
						{
							if(hours == 11) hours = 0;
							else hours++;
						}
					}
					else
					{
						if(hours == 23) hours = 0;
						else hours++;
					}
					value.setHours(hours);
			}
			this.value = value;
		}
		
		/**
		 * Decreeases the value of the selected field (and rotates back to the
		 * maximum value, if the minimum is reached). 
		 */
		protected function decrement():void
		{
			var useTwelveHourFormat:Boolean = this.getStyle("useTwelveHourFormat");
			var value:Date = new Date(this.value.valueOf());
			switch(this.focusedField)
			{
				case TimeUnit.MINUTES:
					var minutes:Number = value.getMinutes();
					if(minutes == 0) minutes = 59;
					else minutes--;
					value.setMinutes(minutes);
					break;
				case TimeUnit.SECONDS:
					var seconds:Number = value.getSeconds();
					if(seconds == 0) seconds = 59;
					else seconds--;
					value.setSeconds(seconds);
					break;
				case AMPM:
					var hours:Number = value.getHours();
					if(hours >= 12) hours -= 12;
					else hours += 12;
					value.setHours(hours);
					break;
				default: //hours
					hours = value.getHours();
					if(useTwelveHourFormat)
					{
						if(hours >= 12) //pm
						{
							if(hours == 12) hours = 23;
							else hours--;
						}
						else //am
						{
							if(hours == 0) hours = 11;
							else hours--;
						}
					}
					else
					{
						if(hours == 0) hours = 23;
						else hours--;
					}
					value.setHours(hours);
			}
			this.value = value;
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
		
		/**
		 * @private
		 * When the main control receives focus, pass it to the first text field.
		 */
		override protected function focusInHandler(event:FocusEvent):void
		{
			if(event.target == this)
			{
				this.timeInput.setFocus();
			}
			
			if(this.focusManager)
			{
				this.focusManager.showFocus();
			}
			super.focusInHandler(event);
		}
		
		/**
		 * Handles keyboard events.
		 */
		protected function timeInputKeyDownHandler(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.UP)
			{
				this.increment();
			}
			else if(event.keyCode == Keyboard.DOWN)
			{
				this.decrement();
			}
			var stepperEvent:TimeStepperEvent = new TimeStepperEvent(TimeStepperEvent.CHANGE, false, false, this.value);
            stepperEvent.triggerEvent = event;
            this.dispatchEvent(stepperEvent);
		}
		
		/**
		 * Listens for focus events from the TimeInput and refreshes the focused
		 * field so that increment and decrement update the correct field.
		 */
		protected function timeInputUnitFocusInHandler(event:TimeInputEvent):void
		{
			switch(event.type)
			{
				case TimeInputEvent.HOURS_FOCUS_IN:
					this.focusedField = TimeUnit.HOURS;
					break;
				case TimeInputEvent.MINUTES_FOCUS_IN:
					this.focusedField = TimeUnit.MINUTES;
					break;
				case TimeInputEvent.SECONDS_FOCUS_IN:
					this.focusedField = TimeUnit.SECONDS;
					break;
				default:
					this.focusedField = AMPM;
			}
		}
		
		/**
		 * Listens for no focus from the TimeInput.
		 */
		protected function timeInputFocusOutHandler(event:FocusEvent):void
		{
			this.focusedField = null;
			var stepperEvent:TimeStepperEvent = new TimeStepperEvent(TimeStepperEvent.CHANGE, false, false, this.value);
            stepperEvent.triggerEvent = event;
            this.dispatchEvent(stepperEvent);
		}
		
		/**
		 * Handles presses of the next (increment) button.
		 */
		protected function nextButtonDownHandler(event:FlexEvent):void
		{
			this.increment();
			var stepperEvent:TimeStepperEvent = new TimeStepperEvent(TimeStepperEvent.CHANGE, false, false, this.value);
            stepperEvent.triggerEvent = event;
            this.dispatchEvent(stepperEvent);
		}
		
		/**
		 * Handles presses of the previous (decrement) button.
		 */
		protected function prevButtonDownHandler(event:FlexEvent):void
		{
			this.decrement();
			var stepperEvent:TimeStepperEvent = new TimeStepperEvent(TimeStepperEvent.CHANGE, false, false, this.value);
            stepperEvent.triggerEvent = event;
            this.dispatchEvent(stepperEvent);
		}
		
		/**
		 * Updates the selected value when the TimeInput's selected value
		 * changes.
		 */
		protected function timeInputValueCommitHandler(event:FlexEvent):void
		{
			this.value = this.timeInput.value;
		}
		
	//--------------------------------------------------------------------------
	//
	//  Accessibility
	//
	//--------------------------------------------------------------------------		

		
		/**
		 * @private
		 */	
		public static var createAccessibilityImplementation:Function;
		
 		/**
		 * @private
		 */
		override protected function initializeAccessibility():void
		{
		     if (TimeStepper.createAccessibilityImplementation!=null)
		          TimeStepper.createAccessibilityImplementation(this);
		}
	}
}