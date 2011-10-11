/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls.colorPickerClasses
{
	
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.colorPickerClasses.WebSafePalette;
	import mx.events.ColorPickerEvent;

	/**
	 * A drop-down with a SwatchPicker for the DropDownColorPicker control.
	 * 
	 * @see com.yahoo.astra.mx.controls.SwatchPicker
	 * @see com.yahoo.astra.mx.controls.DropDownColorPicker
	 * 
	 * @author Josh Tynjala
	 */
	public class SwatchPickerDropDown extends BaseColorPickerDropDown implements IColorPicker
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function SwatchPickerDropDown()
		{
			super();
			this.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler2);
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The swatch picker control.
		 */
		public var swatchPicker:SwatchPicker;
		
		/**
		 * @private
		 * Storage for the colorList property.
		 */
		private var _colorList:Array = (new WebSafePalette()).getList().toArray();
		
		[Bindable]
		/**
		 * The list of colors that will be displayed in the SwatchPicker.
		 */
		public function get colorList():Array
		{
			return this._colorList;
		}
		
		/**
		 * @private
		 */
		public function set colorList(value:Array):void
		{
			this._colorList = value;
			this.invalidateProperties();
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
			
			if(!this.swatchPicker)
			{
				this.swatchPicker = new SwatchPicker();
				this.swatchPicker.focusEnabled = false;
				this.swatchPicker.addEventListener(ColorPickerEvent.ITEM_ROLL_OVER, swatchPickerRollOverHandler);
				this.swatchPicker.addEventListener(ColorPickerEvent.ITEM_ROLL_OUT, swatchPickerRollOutHandler);
				this.swatchPicker.addEventListener(ColorPickerEvent.CHANGE, swatchPickerChangeHandler);
				this.addChild(this.swatchPicker);
			}
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			if(this.selectedColorChanged)
			{
				this.swatchPicker.selectedColor = this.selectedColor;
			}
			
			super.commitProperties();
			
			this.swatchPicker.colorList = this.colorList;
		}
		
		/**
		 * @private
		 */
		override protected function measure():void
		{
			super.measure();
			
			var paddingLeft:Number = this.getStyle("paddingLeft");
			var paddingRight:Number = this.getStyle("paddingRight");
			var verticalGap:Number = this.getStyle("verticalGap");
			
			//we're using the existing measured values from the superclass
			this.measuredWidth = Math.max(this.measuredWidth, paddingLeft + paddingRight + this.swatchPicker.measuredWidth);
			this.measuredHeight += verticalGap + this.swatchPicker.measuredHeight;
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var paddingLeft:Number = this.getStyle("paddingLeft");
			var paddingRight:Number = this.getStyle("paddingRight");
			var paddingTop:Number = this.getStyle("paddingTop");
			var paddingBottom:Number = this.getStyle("paddingBottom");
			var verticalGap:Number = this.getStyle("verticalGap");
			var showColorViewer:Boolean = this.getStyle("showColorViewer");
			var showColorInput:Boolean = this.getStyle("showColorInput");
			
			var swatchPickerWidth:Number = unscaledWidth - paddingLeft - paddingRight;
			var swatchPickerHeight:Number = unscaledHeight - this.yPositionOffset - paddingBottom;
			this.swatchPicker.x = paddingLeft;
			this.swatchPicker.y = this.yPositionOffset;
			this.swatchPicker.setActualSize(swatchPickerWidth, swatchPickerHeight);
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
		
		/**
		 * @private
		 */
		protected function keyDownHandler2(event:KeyboardEvent):void
		{	
			if(event.target == this.swatchPicker) return;
			
			//make sure the swatch picker gets the events too!
			this.swatchPicker.dispatchEvent(event);
		}
		
		/**
		 * @private
		 * When the color input's value changes, update the SwatchPicker
		 */
		override protected function colorInputChangeHandler(event:ColorPickerEvent):void
		{
			super.colorInputChangeHandler(event);
			
			this.swatchPicker.selectedColor = event.color;
		}
		
		/**
		 * @private
		 * Update the preview color when the user rolls over a swatch.
		 */
		protected function swatchPickerRollOverHandler(event:ColorPickerEvent):void
		{
			this.previewColor = event.color;
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OVER, false, false, event.index, event.color));
		}
		
		/**
		 * @private
		 * Clear the preview color when the user rolls out of a swatch.
		 */
		protected function swatchPickerRollOutHandler(event:ColorPickerEvent):void
		{
			this.previewColor = this.selectedColor;
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OUT, false, false, event.index, event.color));
		}
		
		/**
		 * @private
		 * Update the selected color when a swatch is selected.
		 */
		protected function swatchPickerChangeHandler(event:ColorPickerEvent):void
		{
			this.selectedColor = event.color;
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, event.index, this.selectedColor));
		}
	}
}