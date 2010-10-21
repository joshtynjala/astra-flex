/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls.inputClasses
{
	import com.yahoo.astra.mx.core.yahoo_mx_internal;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	
	import mx.core.EdgeMetrics;
	import mx.core.IBorder;
	import mx.core.IFlexDisplayObject;
	import mx.core.IInvalidating;
	import mx.core.UIComponent;
	import mx.core.UITextField;
	import mx.events.FlexEvent;
	import mx.managers.IFocusManagerComponent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.ISimpleStyleClient;
	import mx.styles.StyleManager;
	
	use namespace yahoo_mx_internal;

	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * Dispatched when the user presses the Enter key.
	 *
	 * @eventType mx.events.FlexEvent.ENTER
	 */
	[Event(name="enter", type="mx.events.FlexEvent")]

	//--------------------------------------
	//  Styles
	//--------------------------------------

	//Flex framework styles
	include "../../styles/metadata/BorderStyles.inc"
	include "../../styles/metadata/FocusStyles.inc"
	include "../../styles/metadata/PaddingStyles.inc"
	include "../../styles/metadata/TextStyles.inc"

	/**
	 * Number of pixels between the component's bottom border
	 * and the bottom edge of its content area.
	 *
	 * @default 0
	 */
	[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]
	
	/**
	 * Number of pixels between the component's top border
	 * and the top edge of its content area.
	 *  
	 * @default 0
	 */
	[Style(name="paddingTop", type="Number", format="Length", inherit="no")]

	//--------------------------------------
	//  Other Metadata
	//--------------------------------------

	[DefaultTriggerEvent("change")]

	/**
	 * Abstract base class for TextInput-like controls that have multiple input
	 * fields.
	 * 
	 * @author Josh Tynjala
	 */
	public class BaseMultiFieldInput extends UIComponent implements IFocusManagerComponent
	{
		
	//--------------------------------------
	//  Static Methods
	//--------------------------------------
	
		/**
		 * @private
		 * Sets the default style values for this control.
		 */
		public static function initializeStyles():void
		{
			var styleDeclaration:CSSStyleDeclaration = StyleManager.getStyleDeclaration("BaseMultiFieldInput");
			if(!styleDeclaration)
			{
				styleDeclaration = new CSSStyleDeclaration();
			}
			
			styleDeclaration.defaultFactory = function():void
			{
				this.backgroundColor = 0xffffff;
				this.backgroundDisabledColor = 0xdddddd;
				this.textAlign = TextFormatAlign.CENTER;
				//other styles are based on the framework defaults
			};
			
			StyleManager.setStyleDeclaration("BaseMultiFieldInput", styleDeclaration, false);
		}
		initializeStyles();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function BaseMultiFieldInput()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The number of editable fields in this control. This value must be set
		 * by a subclass before <code>createChildren()</code> is called.
		 */
		protected var fieldCount:int = 1;
		
		/**
		 * The internal subcontrol that draws the border and background.
		 */
		protected var border:IFlexDisplayObject;
    
    	/**
    	 * The internal input UITextFields.
    	 */
		protected var textFields:Array = [];
		
		/**
		 * @private
		 * Flag that indicates that the enabled property has changed.
		 */
		protected var enabledChanged:Boolean = false;
		
		[Inspectable(category="General", enumeration="true,false", defaultValue="true")]
		/**
		 * @private
		 * Disable TextField when we're disabled.
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
		
			if(this.border && this.border is IInvalidating)
			{
				IInvalidating(this.border).invalidateDisplayList();
			}
		}
		
		/**
		 * @private
		 * Storage for the editable property.
		 */
		private var _editable:Boolean = true;
		
		/**
		 * @private
		 * Flag that indicates that the editable property has changed.
		 */
		protected var editableChanged:Boolean = false;
		
		[Bindable("editableChanged")]
		[Inspectable(category="General", defaultValue="true")]
		/**
		 * Indicates whether the user is allowed to edit the text in this control.
		 * If <code>true</code>, the user can edit the text.
		 *
		 * @default true
		 * 
		 * @tiptext Specifies whether the component is editable or not
		 * @helpid 3196
		 */
		public function get editable():Boolean
		{
			return this._editable;
		}
		
		/**
		 * @private
		 */
		public function set editable(value:Boolean):void
		{
			if(value == this._editable)
			{
				return;
			}
			
			this._editable = value;
			this.editableChanged = true;
			
			this.invalidateProperties();
			
			this.dispatchEvent(new Event("editableChanged"));
		}
		
		/**
		 * @private
		 * Storage for the parentDrawsFocus property.
		 */
		private var _parentDrawsFocus:Boolean = false;
		
		/**
		 * @private
		 * If true, this control will tell the parent to draw the focus rect.
		 */
		yahoo_mx_internal function get parentDrawsFocus():Boolean
		{
			return this._parentDrawsFocus;
		}
		
		/**
		 * @private
		 */
		yahoo_mx_internal function set parentDrawsFocus(value:Boolean):void
		{
			this._parentDrawsFocus = value;
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
			
			if(!this.border)
			{
				var borderClass:Class = this.getStyle("borderSkin");
				if(borderClass)
				{
					this.border = new borderClass();
					
					if(this.border is ISimpleStyleClient)
					{
						ISimpleStyleClient(this.border).styleName = this;
					}
					
					this.addChild(DisplayObject(this.border));
				}
			}
			
			for(var i:int = 0; i < this.fieldCount; i++)
			{
				var textField:UITextField = new UITextField();
				textField.enabled = this.enabled;
	            textField.multiline = false;
	            textField.styleName = this;
	            textField.wordWrap = false;
	            textField.ignorePadding = true;
	            
				textField.addEventListener(FocusEvent.FOCUS_IN, textFieldFocusInHandler);
				textField.addEventListener(Event.SCROLL, textFieldScrollHandler);
				textField.addEventListener(KeyboardEvent.KEY_DOWN, keyDownNavigationHandler, false, 1000);
				textField.addEventListener(Event.CHANGE, textFieldChangeHandler);

				this.addChild(textField);
				this.textFields.push(textField);
			}
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(this.enabledChanged || this.editableChanged)
			{
				var tfCount:int = this.textFields.length;
				for(var i:int = 0; i < tfCount; i++)
				{
					var textField:UITextField = UITextField(this.textFields[i]);
					if(this.enabledChanged)
					{
						textField.enabled = this.enabled;
					}
					textField.type = this.enabled && this.editable ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
					textField.selectable = this.enabled;
				}
			
				this.enabledChanged = false;
				this.editableChanged = false;
			}
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			this.border.setActualSize(unscaledWidth, unscaledHeight);
			this.layoutTextFields();
		}
		
		/**
		 * @private
		 * Positions the TextFields within the content area.
		 */
		protected function layoutTextFields():void
		{
			var metrics:EdgeMetrics = this.border is IBorder ? IBorder(this.border).borderMetrics : EdgeMetrics.EMPTY;
			
			var tfHeight:Number = Math.max(0, unscaledHeight - metrics.top - metrics.bottom);
			var xPosition:Number = metrics.left;
			var tfCount:int = this.textFields.length;
			for(var i:int = 0; i < tfCount; i++)
			{
				var tf:UITextField = UITextField(this.textFields[i]);
				tf.x = xPosition;
				tf.y = metrics.top;
				
				//the sizing here means that small enough dimensions will cause some text to be cut off and inaccessible.
				//it is highly recommended never to make this control smaller than the measured dimensions
				tf.setActualSize(Math.min(Math.max(0, unscaledWidth - metrics.right - xPosition), tf.measuredWidth), tfHeight);
				xPosition += tf.measuredWidth;
			}
		}

		/**
		 * @private
		 */
		override protected function isOurFocus(target:DisplayObject):Boolean
		{
			var tfCount:int = this.textFields.length;
			for(var i:int = 0; i < tfCount; i++)
			{
				var textField:UITextField = UITextField(this.textFields[i]);
				if(target == textField)
				{
					return true;
				}
			}
		    return super.isOurFocus(target);
		}
		
		/**
		 * @private
		 * 
		 * Takes a UITextField as input and finds the next editable UITextField to focus.
		 * If the input UITextField is the last in the control, focus will not be changed.
		 * Throws an ArgumentError if the input UITextField is one of the "dot" textfields.
		 */
		protected function focusNextTextField(textField:UITextField):void
		{
			var index:int = this.textFields.indexOf(textField);
			if(index < 0) throw new ArgumentError("Invalid TextField");
			
			if(index == this.textFields.length - 1) return;
			else index++;
			
			textField = UITextField(this.textFields[index]);
			//if we call it now, the keyboard event will cause problems.
			//by calling it later, we can get the correct index and select the textfield too.
			this.callLater(textField.setFocus);
		}
		
		/**
		 * @private
		 * 
		 * Takes a UITextField as input and finds the previous editable UITextField to focus.
		 * If the input UITextField is the first in the control, focus will not be changed.
		 * Throws an ArgumentError if the input UITextField is one of the "dot" textfields.
		 */
		protected function focusPreviousTextField(textField:UITextField):void
		{
			var index:int = this.textFields.indexOf(textField);
			if(index < 0) throw new ArgumentError("Invalid TextField");
			
			if(index == 0) return;
			else index--;
			
			textField = UITextField(this.textFields[index]);
			//if we call it now, the keyboard event will cause problems.
			//by calling it later, we can get the correct index and select the textfield too.
			this.callLater(textField.setFocus);
		}
		
		/**
		 * @private
		 * Forward the drawFocus to the parent, if requested
		 */
		override public function drawFocus(isFocused:Boolean):void
		{
		    if(this.parentDrawsFocus)
		    {
		        IFocusManagerComponent(parent).drawFocus(isFocused);
		        return;
		    }
		
		    super.drawFocus(isFocused);
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
				var firstTextField:UITextField = UITextField(this.textFields[0]);
				firstTextField.setFocus();
			}
			
			if(this.editable && this.focusManager)
			{
				this.focusManager.showFocus();
			}
			super.focusInHandler(event);
		}
	
		/**
		 * @private
		 * Selects the full UITextField when it receives focus.
		 */
		protected function textFieldFocusInHandler(event:FocusEvent):void
		{
			var textField:UITextField = UITextField(event.target);
			textField.setSelection(0, textField.length);
		}
		
		/**
		 * @private
		 * Make sure the UITextFields don't scroll during typing or selection.
		 */
		protected function textFieldScrollHandler(event:Event):void
		{
			var textField:UITextField = UITextField(event.target);
			textField.scrollH = 0;
		}
		
		/**
		 * @private
		 * Special navigation between UITextFields when LEFT and RIGHT keys are pressed.
		 */
		protected function keyDownNavigationHandler(event:KeyboardEvent):void
		{
			var textField:UITextField = UITextField(event.target);
			switch(event.keyCode)
			{
				case Keyboard.RIGHT:
					if(textField.selectionEndIndex == textField.length)
					{
						this.focusNextTextField(textField);
					}
					break;
				case Keyboard.LEFT:
					if(textField.selectionBeginIndex == 0)
					{
						this.focusPreviousTextField(textField);
					}
					break;
				case Keyboard.ENTER:
					this.dispatchEvent(new FlexEvent(FlexEvent.ENTER));
					break;
			}
		}
		
		/**
		 * @private
		 * Stops TextField change events from bubbling.
		 */
		protected function textFieldChangeHandler(event:Event):void
		{
			event.stopPropagation();
		}
	}
}