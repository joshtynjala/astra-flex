/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls.colorPickerClasses
{
	import com.yahoo.astra.mx.controls.ColorSliderPicker;
	import com.yahoo.astra.mx.core.yahoo_mx_internal;
	import com.yahoo.astra.utils.CMYColor;
	import com.yahoo.astra.utils.CMYKColor;
	import com.yahoo.astra.utils.ColorSpace;
	import com.yahoo.astra.utils.ColorUtil;
	import com.yahoo.astra.utils.HSBColor;
	
	import flash.events.MouseEvent;
	
	import mx.controls.Button;
	import mx.events.ColorPickerEvent;
	import mx.events.FlexEvent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	use namespace yahoo_mx_internal;
	
	/**
	 * A drop-down with a set of ColorSliders for the DropDownColorPicker control.
	 * 
	 * @see com.yahoo.astra.mx.controls.ColorSliderPicker
	 * @see com.yahoo.astra.mx.controls.DropDownColorPicker
	 * 
	 * @author Josh Tynjala
	 */
	public class ColorSliderDropDown extends BaseColorPickerDropDown
	{
		
	//--------------------------------------
	//  Static Methods
	//--------------------------------------
	
		/**
		 * @private
		 * Set the default values for controls of this type.
		 */
		private static function initializeStyles():void
		{
			var styleDeclaration:CSSStyleDeclaration = StyleManager.getStyleDeclaration("ColorSliderDropDown");
			if(!styleDeclaration)
			{
				styleDeclaration = new CSSStyleDeclaration();
			}
			
			styleDeclaration.defaultFactory = function():void
			{
				this.paddingLeft = 10;
				this.paddingRight = 10;
				this.paddingTop = 10;
				this.paddingBottom = 10;
				this.sliderDirection = "vertical";
				this.verticalGap = 10;
			};
			
			StyleManager.setStyleDeclaration("ColorSliderDropDown", styleDeclaration, false);
		}
		initializeStyles();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function ColorSliderDropDown()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The color slider picker.
		 */
		protected var colorSliders:ColorSliderPicker;
		
		/**
		 * The select button to commit the selection on the sliders.
		 */
		protected var selectButton:Button;
		
		/**
		 * @private
		 * Storage for the sliderStyleFilter property.
		 */
		private var _sliderStyleFilter:Object = 
		{
			
		}
		
		/**
		 * @private
		 * The style filter for the color sliders.
		 */
		protected function get sliderStyleFilter():Object
		{
			return this._sliderStyleFilter;
		}
		
		/**
		 * @private
		 */
		override protected function get previewColor():uint
		{
			return super.previewColor;
		}
		
		/**
		 * @private
		 */
		override protected function set previewColor(value:uint):void
		{
			super.previewColor = value;
			this._previewHSBColor = ColorUtil.uintToHSB(this.previewColor);
			this._previewCMYKColor = ColorUtil.uintToCMYK(this.previewColor);
			this._previewCMYColor = ColorUtil.uintToCMY(this.previewColor);
		}
		
		/**
		 * @private
		 * Storage for the previewHSBColor property.
		 */
		private var _previewHSBColor:HSBColor = new HSBColor(0, 0, 0);
		
		/**
		 * @private
		 * The currently previewed HSB color. Meant for internal usage
		 * by recursive color pickers to avoid color information loss.
		 */
		yahoo_mx_internal function get previewHSBColor():HSBColor
		{
			return this._previewHSBColor;
		}
		
		/**
		 * @private
		 */
		yahoo_mx_internal function set previewHSBColor(value:HSBColor):void
		{
			this._previewHSBColor = value;
			this.invalidateProperties();
			this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
		
		/**
		 * @private
		 * Storage for the previewCMYColor property.
		 */
		private var _previewCMYColor:CMYColor = new CMYColor(1, 1, 1);
		
		/**
		 * @private
		 * The currently previewed CMY color. Meant for internal usage
		 * by recursive color pickers to avoid color information loss.
		 */
		yahoo_mx_internal function get previewCMYColor():CMYColor
		{
			return this._previewCMYColor;
		}
		
		/**
		 * @private
		 */
		yahoo_mx_internal function set previewCMYColor(value:CMYColor):void
		{
			this._previewCMYColor = value;
			this.invalidateProperties();
			this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
		
		/**
		 * @private
		 * Storage for the previewCMYKColor property.
		 */
		private var _previewCMYKColor:CMYKColor = new CMYKColor(0, 0, 0, 1);
		
		/**
		 * @private
		 * The currently previewed CMYK color. Meant for internal usage
		 * by recursive color pickers to avoid color information loss.
		 */
		yahoo_mx_internal function get previewCMYKColor():CMYKColor
		{
			return this._previewCMYKColor;
		}
		
		/**
		 * @private
		 */
		yahoo_mx_internal function set previewCMYKColor(value:CMYKColor):void
		{
			this._previewCMYKColor = value;
			this.invalidateProperties();
			this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
		
		/**
		 * @private
		 * Storage for the colorSpace property.
		 */
		private var _colorSpace:String = ColorSpace.RGB;
		
		[Bindable]
		/**
		 * The color space specifies how many sliders will be displayed
		 * and which component each slider will represent.
		 */
		public function get colorSpace():String
		{
			return this._colorSpace;
		}
		
		/**
		 * @private
		 */
		public function set colorSpace(value:String):void
		{
			if(!value) value = ColorSpace.RGB;
			if(this._colorSpace != value)
			{
				this._colorSpace = value;
				this.invalidateProperties();
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
			
			if(!this.colorSliders)
			{
				this.colorSliders = new ColorSliderPicker();
				this.colorSliders.addEventListener(ColorPickerEvent.CHANGE, sliderChangeHandler);
				this.addChild(this.colorSliders);
			}
			
			if(!this.selectButton)
			{
				this.selectButton = new Button();
				this.selectButton.label = "OK";
				this.selectButton.addEventListener(MouseEvent.CLICK, saveButtonClickHandler);
				this.addChild(this.selectButton);
			}
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			this.colorSliders.colorSpace = this.colorSpace;
			this.colorSliders.selectedColor = this.previewColor;
			this.colorSliders.selectedHSBColor = this.previewHSBColor;
			this.colorSliders.selectedCMYColor = this.previewCMYColor;
			this.colorSliders.selectedCMYKColor = this.previewCMYKColor;
		}
		
		/**
		 * @private
		 */
		override protected function measure():void
		{
			super.measure();
			
			var paddingLeft:Number = this.getStyle("paddingLeft");
			var paddingRight:Number = this.getStyle("paddingRight");
			var paddingTop:Number = this.getStyle("paddingTop");
			var paddingBottom:Number = this.getStyle("paddingBottom");
			var verticalGap:Number = this.getStyle("verticalGap");
			
			this.measuredWidth = Math.max(this.measuredWidth, paddingLeft + paddingRight + this.colorSliders.measuredWidth);
			this.measuredHeight += paddingTop + paddingBottom + this.colorSliders.measuredHeight;
			this.measuredHeight += verticalGap + this.selectButton.measuredHeight;
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
			
			var sliderWidth:Number = unscaledWidth - paddingLeft - paddingRight;
			var sliderHeight:Number = unscaledHeight - this.yPositionOffset - paddingBottom - verticalGap - this.selectButton.measuredHeight;
			
			this.colorSliders.x = paddingLeft;
			this.colorSliders.y = this.yPositionOffset;
			this.colorSliders.setActualSize(sliderWidth, sliderHeight);
			
			this.selectButton.setActualSize(Math.min(unscaledWidth, this.selectButton.measuredWidth), this.selectButton.measuredHeight);
			this.selectButton.x = unscaledWidth - paddingRight - this.selectButton.width;
			this.selectButton.y = unscaledHeight - paddingBottom - this.selectButton.height;
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
		
		/**
		 * @private
		 * If the sliders change, update the preview color and notify listeners.
		 */
		protected function sliderChangeHandler(event:ColorPickerEvent):void
		{
			this.previewColor = this.colorSliders.selectedColor;
			this._previewHSBColor = this.colorSliders.selectedHSBColor;
			this._previewCMYColor = this.colorSliders.selectedCMYColor;
			this._previewCMYKColor = this.colorSliders.selectedCMYKColor;
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OVER, false, false, event.index, this.selectedColor));
		}
		
		/**
		 * @private
		 * If the save button is clicked, update the selected color.
		 */
		protected function saveButtonClickHandler(event:MouseEvent):void
		{
			this.selectedColor = this.previewColor;
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OUT));
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, this.selectedColor));
		}
		
	}
}