/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls
{
	import com.yahoo.astra.mx.controls.inputClasses.BaseMultiFieldInput;
	import com.yahoo.astra.net.IPv4Address;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	
	import mx.core.EdgeMetrics;
	import mx.core.IBorder;
	import mx.core.UITextField;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	
	use namespace mx_internal;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 *  Dispatched when text in the IPv4AddressInput control changes
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
	//  Other Metadata
	//--------------------------------------
	[AccessibilityClass(implementation="com.yahoo.astra.mx.accessibility.IPv4AddressInputAccImpl")]
	[DefaultBindingProperty(source="value", destination="value")]

	[DefaultProperty("value")]
	
	/**
	 * An advanced TextInput variation for entering an IPv4 address.
	 * 
	 * @see com.yahoo.astra.net.IPv4Address
	 * 
	 * @author Josh Tynjala
	 */
	public class IPv4AddressInput extends BaseMultiFieldInput
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function IPv4AddressInput()
		{
			super();
			this.fieldCount = 4;
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * @private
		 * The UITextFields for the "." separators.
		 */
		protected var separators:Array = [];
		
		/**
		 * @private
		 * The maximum width of a three character numeric UITextField.
		 */
		private var _numberWidth:Number = 0;
		
		/**
		 * @private
		 * The width of a "dot" UITextField.
		 */
		private var _dotWidth:Number = 0;
		
		/**
		 * @private
		 * Storage for the address property.
		 */
		private var _value:IPv4Address = new IPv4Address();
		
		[Bindable("valueCommit")]
		/**
		 * The IPv4Address object to display. Accepts IPv4Address type
		 * or any values that may be parsed by IPv4Address.
		 * 
		 * @see com.yahoo.astra.net.IPv4Address
		 */
		public function get value():Object
		{
			return this._value;
		}
		
		/**
		 * @private
		 */
		public function set value(address:Object):void
		{
			this._value = new IPv4Address();
			this._value.parse(address);
			this.invalidateProperties();
			this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		override public function styleChanged(styleProp:String):void
		{
			if(!styleProp || styleProp.indexOf("font") >= 0 || styleProp.indexOf("text") >= 0)
			{
				//we have to do this even if we have explicit dimensions
				//because positioning relies on the size of three characters
				var tempTextField:UITextField = new UITextField();
				tempTextField.styleName = this;
				tempTextField.multiline = false;
				tempTextField.wordWrap = false;
				tempTextField.ignorePadding = true;
				tempTextField.text = "255";
				
				//figured invalidation and validation would be enough
				//but we have to add and remove the UITextField too!
				this.addChild(tempTextField);
				
				this._numberWidth = tempTextField.measuredWidth;
				this.removeChild(tempTextField);
				
				tempTextField.text = ".";
				tempTextField.validateNow();
				this._dotWidth = tempTextField.measuredWidth;
				
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
			
			//create each of the "." separators
			for(var i:int = 0; i < 3; i++)
			{
				var separatorField:UITextField = new UITextField();
				separatorField.styleName = this;
				separatorField.ignorePadding = true;
				separatorField.selectable = false;
				separatorField.enabled = this.enabled;
				separatorField.text = ".";
				this.addChild(separatorField);
				this.separators.push(separatorField);
			}
			
			//update the UITextFields
			for each(var textField:UITextField in this.textFields)
			{
				textField.restrict = "0-9";
				textField.maxChars = 3;
				textField.addEventListener(FocusEvent.FOCUS_OUT, textFieldFocusOutHandler);
				textField.addEventListener(Event.CHANGE, textFieldChangeHandler);
				textField.addEventListener(TextEvent.TEXT_INPUT, textFieldTextInputHandler);
			}
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			if(this.enabledChanged)
			{
				for each(var separator:UITextField in this.separators)
				{
					separator.enabled = this.enabled;
				} 
			}
			
			super.commitProperties();
			
			var tfCount:int = this.textFields.length;
			for(var i:int = 0; i < tfCount; i++)
			{
				//display the IPv4Address byte values in the textfields.
				var textField:UITextField = UITextField(this.textFields[i]);
				textField.text = this.value.bytes[i].toString();
			}
		}
		
		/**
		 * @private
		 */
		override protected function measure():void
		{
			super.measure();
			
			if(this.border)
			{
				var metrics:EdgeMetrics = this.border is IBorder ? IBorder(this.border).borderMetrics : EdgeMetrics.EMPTY;
				this.measuredWidth = metrics.left + metrics.right;
				this.measuredHeight = metrics.top + metrics.bottom;
			}
			
			this.measuredWidth += (this._numberWidth * 4) + (this._dotWidth * 3);
			this.measuredHeight += UITextField(this.textFields[0]).measuredHeight;
			
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
			var metrics:EdgeMetrics = this.border is IBorder ? IBorder(this.border).borderMetrics : EdgeMetrics.EMPTY;
			var tfHeight:Number = Math.max(0, unscaledHeight - metrics.top - metrics.bottom);
			
			var xPosition:Number = metrics.left;
			var yPosition:Number = metrics.top;
			
			var separatorIndex:int = 0;
			
			var tfCount:int = this.textFields.length;
			for(var i:int = 0; i < tfCount; i++)
			{
				var textField:UITextField = UITextField(this.textFields[i]);
				textField.x = xPosition;
				textField.y = yPosition;
				textField.setActualSize(Math.min(Math.max(0, unscaledWidth - metrics.right - xPosition), this._numberWidth), tfHeight);
				xPosition += textField.width;
				
				if(separatorIndex < this.separators.length)
				{
					var separator:UITextField = UITextField(this.separators[separatorIndex]);
					separator.x = xPosition;
					separator.y = yPosition;
					separator.setActualSize(Math.min(Math.max(0, unscaledWidth - metrics.right - xPosition), this._dotWidth), tfHeight);
					xPosition += separator.width;
					separatorIndex++;
				}
			}
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------

		/**
		 * @private
		 * If the UITextField the text is reset to the current value when it loses focus.
		 * This can fix problems like an empty UITextField or leading zeroes.
		 */
		protected function textFieldFocusOutHandler(event:FocusEvent):void
		{
			var textField:UITextField = UITextField(event.target);
			var index:int = this.textFields.indexOf(textField);
			textField.text = this.value.bytes[index];
		}
		
		/**
		 * @private
		 * Validates input to a single field.
		 */
		protected function textFieldTextInputHandler(event:TextEvent):void
		{
			var textField:UITextField = UITextField(event.target);
			
			var text:String = textField.text;
			text = text.substr(0, textField.selectionBeginIndex) + event.text + text.substr(textField.selectionEndIndex);
			var newByteValue:int = int(text);
			if(newByteValue > 255)
			{
				//if a value is greater than 255, we don't want it!
				event.preventDefault();
			}
		}
		
		/**
		 * @private
		 * Handles input. Dispatches an Event.CHANGE event if the data changes.
		 */
		override protected function textFieldChangeHandler(event:Event):void
		{
			super.textFieldChangeHandler(event);
			
			var textField:UITextField = UITextField(event.target);
			
			var byteIndex:int = this.textFields.indexOf(textField);
			if(textField.length == 0)
			{
				//special case: if textField is empty, we assume the data is zero
				this.value.bytes[byteIndex] = 0;
				this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
				this.dispatchEvent(new Event(Event.CHANGE));
			}
			var newByteValue:int = int(textField.text);
			if(newByteValue <= 255)
			{
				this.value.bytes[byteIndex] = newByteValue;
				this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
				this.dispatchEvent(new Event(Event.CHANGE));
			}
			else
			{
				//this section should never run, but I'm keeping it here just in case
				//if we're out of range, restore the old value
				textField.text = this.value.bytes[byteIndex];
			}
			
			//useful functionality. if we've typed in three numbers,
			//it's okay to focus the next UITextField.
			if(textField.length == 3)
			{
				this.focusNextTextField(textField);
			}
		}
		
		/**
		 * @private
		 * Adds support for "." keyboard input for navigating to the next field.
		 */
		override protected function keyDownNavigationHandler(event:KeyboardEvent):void
		{
			var textField:UITextField = UITextField(event.target);
			var dot:String = ".";
			if(event.charCode == dot.charCodeAt(0) && textField.selectionBeginIndex == textField.selectionEndIndex && textField.selectionEndIndex == textField.length)
			{
				this.focusNextTextField(textField);
			}
			
			super.keyDownNavigationHandler(event);
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
		     if (IPv4AddressInput.createAccessibilityImplementation!=null)
		          IPv4AddressInput.createAccessibilityImplementation(this);
		}
	}
}