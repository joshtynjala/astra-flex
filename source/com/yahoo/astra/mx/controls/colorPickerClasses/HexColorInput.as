/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls.colorPickerClasses
{
	import com.yahoo.astra.mx.controls.colorPickerClasses.IColorPicker;
	import com.yahoo.astra.utils.ColorUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.text.TextFieldType;
	
	import mx.core.EdgeMetrics;
	import mx.core.IBorder;
	import mx.core.IFlexDisplayObject;
	import mx.core.IInvalidating;
	import mx.core.UIComponent;
	import mx.core.UITextField;
	import mx.events.ColorPickerEvent;
	import mx.events.FlexEvent;
	import mx.managers.IFocusManagerComponent;
	import mx.skins.Border;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.ISimpleStyleClient;
	import mx.styles.StyleManager;
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	//Flex framework styles
	include "../../styles/metadata/BorderStyles.inc"
	include "../../styles/metadata/FocusStyles.inc"
	include "../../styles/metadata/PaddingStyles.inc"
	include "../../styles/metadata/TextStyles.inc"
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * Dispatched when the selected color 
	 * changes as a result of user interaction.
	 *
	 * @eventType mx.events.ColorPickerEvent.CHANGE
	 */
	[Event(name="change", type="mx.events.ColorPickerEvent")]
	
	/**
	 * An advanced TextInput variation for entering a 24-bit hexadecimal color value.
	 * 
	 * @author Josh Tynjala
	 */
	public class HexColorInput extends UIComponent implements IColorPicker, IFocusManagerComponent
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
		
		/**
		 * @private
		 * The default value for the control's width.
		 */
		private static const DEFAULT_MEASURED_WIDTH:Number = 50;
		
	//--------------------------------------
	//  Static Methods
	//--------------------------------------
	
		/**
		 * @private
		 * Set up the default styles.
		 */
		public static function initializeStyles():void
		{
			var styleDeclaration:CSSStyleDeclaration = StyleManager.getStyleDeclaration("HexColorInput");
			if(!styleDeclaration)
			{
				styleDeclaration = new CSSStyleDeclaration();
			}
			
			styleDeclaration.defaultFactory = function():void
			{
				this.backgroundColor = 0xffffff;
				//other styles are based on the framework defaults
			};
			
			StyleManager.setStyleDeclaration("HexColorInput", styleDeclaration, false);
		}
		initializeStyles();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function HexColorInput()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The internal subcontrol that draws the border and background.
		 */
		protected var border:IFlexDisplayObject;
		
		/**
		 * The textfield that handles display and input.
		 */
		protected var textField:UITextField;
		
		/**
		 * @private
		 * Storage for the selectedColor property.
		 */
		private var _selectedColor:uint = 0x000000;
		
		[Bindable("valueCommit")]
		/**
		 * @inheritDoc
		 */
		public function get selectedColor():uint
		{
			return this._selectedColor;
		}
		
		/**
		 * @private
		 */
		public function set selectedColor(value:uint):void
		{
			if(this._selectedColor != value)
			{
				this._selectedColor = value;
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
		 *  @private
		 */
		private var editableChanged:Boolean = false;
		
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
			
			if(!this.textField)
			{
				this.textField = new UITextField();
				//TODO: Change to StyleProxy
				this.textField.styleName = this;
				this.textField.multiline = false;
				this.textField.wordWrap = false;
				this.textField.ignorePadding = true;
				this.textField.maxChars = 6;
				this.textField.restrict = "0-9a-fA-F"
				this.textField.addEventListener(FocusEvent.FOCUS_IN, textFieldFocusInHandler);
				this.textField.addEventListener(Event.CHANGE, textFieldChangeHandler);
				this.addChild(this.textField);
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
				if(this.enabledChanged)
				{
					this.textField.enabled = this.enabled;
				}
				this.textField.type = this.enabled && this._editable ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
				this.textField.selectable = this.enabled;
			
				this.enabledChanged = false;
				this.editableChanged = false;
			}
			
			this.textField.text = ColorUtil.toHexString(this.selectedColor);
		}
		
		/**
		 * @private
		 */
		override protected function measure():void
		{
			this.measuredWidth = DEFAULT_MEASURED_WIDTH;
			this.measuredHeight = this.textField.measuredHeight;
			
			var metrics:EdgeMetrics = this.border is IBorder ? IBorder(this.border).borderMetrics : EdgeMetrics.EMPTY;
			this.measuredWidth += metrics.left + metrics.right;
			this.measuredHeight += metrics.top + metrics.bottom;
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			this.border.setActualSize(unscaledWidth, unscaledHeight);
			
			var metrics:EdgeMetrics = this.border is IBorder ? IBorder(this.border).borderMetrics : EdgeMetrics.EMPTY;
			
			var tfWidth:Number = unscaledWidth - metrics.left - metrics.right;
			var tfHeight:Number = unscaledHeight - metrics.top - metrics.bottom;
			
			this.textField.x = metrics.left;
			this.textField.y = metrics.top;
			this.textField.setActualSize(tfWidth, tfHeight);
		}

		/**
		 * @private
		 */
		override protected function isOurFocus(target:DisplayObject):Boolean
		{
			if(target == this.textField)
			{
				return true;
			}
		    return super.isOurFocus(target);
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
		
		/**
		 * @private
		 * When the main control receives focus, pass it to the text field.
		 */
		override protected function focusInHandler(event:FocusEvent):void
		{
			if(event.target == this)
			{
				this.textField.text = ColorUtil.toHexString(this.selectedColor);
				this.textField.setFocus();
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
			this.textField.setSelection(0, this.textField.length);
		}
		
		/**
		 * @private
		 * Update the selected color when the text field receives input.
		 */
		protected function textFieldChangeHandler(event:Event):void
		{
			//Event.CHANGE == ColorPickerEvent.CHANGE, and it bubbles too! bad bad bad, Adobe...
			event.stopImmediatePropagation();
			
			//we don't want to redraw because it screws up the input
			this._selectedColor = Number("0x" + this.textField.text);
			this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, this.selectedColor));
		}
	}
}