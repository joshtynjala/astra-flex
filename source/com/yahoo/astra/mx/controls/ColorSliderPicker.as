/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls
{
	import com.yahoo.astra.mx.controls.colorPickerClasses.ColorSlider;
	import com.yahoo.astra.mx.controls.colorPickerClasses.IColorPicker;
	import com.yahoo.astra.mx.core.yahoo_mx_internal;
	import com.yahoo.astra.utils.CMYColor;
	import com.yahoo.astra.utils.CMYKColor;
	import com.yahoo.astra.utils.ColorSpace;
	import com.yahoo.astra.utils.ColorUtil;
	import com.yahoo.astra.utils.HSBColor;
	import com.yahoo.astra.utils.RGBColor;
	
	import mx.core.UIComponent;
	import mx.events.ColorPickerEvent;
	import mx.events.FlexEvent;
	import mx.managers.IFocusManagerComponent;
	import mx.styles.StyleProxy;
	
	use namespace yahoo_mx_internal;
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
	 * The direction of the sliders, either <code>"vertical"</code> or <code>"horizontal"</code>.
	 * 
	 * @default "vertical"
	 */
	[Style(name="sliderDirection", type="String", inherit="no")]
	
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
	 * Dispatched when the user rolls the mouse out of a color.
	 *
	 * @eventType mx.events.ColorPickerEvent.ITEM_ROLL_OUT
	 */
	[Event(name="itemRollOut", type="mx.events.ColorPickerEvent")]
	
	/**
	 * Dispatched when the user rolls the mouse over a color.
	 *
	 * @eventType mx.events.ColorPickerEvent.ITEM_ROLL_OVER
	 */
	[Event(name="itemRollOver", type="mx.events.ColorPickerEvent")]
	
	/**
	 * A set of color sliders representing the components in a colorspace.
	 * 
	 * @see com.yahoo.astra.mx.controls.colorPickerClasses.ColorSlider
	 * 
	 * @author Josh Tynjala
	 */
	public class ColorSliderPicker extends UIComponent implements IColorPicker, IFocusManagerComponent
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
		
		/**
		 * @private
		 * A hash where keys are the color space constants and values are the
		 * number of components in each colorspace.
		 */
		private static const COLOR_SPACE_COMPONENT_COUNT:Object = {rgb: 3, hsb: 3, cmy: 3, cmyk: 4};
		

	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor
		 */
		public function ColorSliderPicker()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The color slider subcomponents.
		 */
		protected var sliders:Array = [];
		
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
			this._selectedColor = value;
			this._selectedHSBColor = ColorUtil.uintToHSB(this._selectedColor);
			this._selectedCMYKColor = ColorUtil.uintToCMYK(this._selectedColor);
			this._selectedCMYColor = ColorUtil.uintToCMY(this._selectedColor);
			this.invalidateProperties();
    		this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
		
		/**
		 * @private
		 * Storage for the selectedHSBColor property.
		 */
		private var _selectedHSBColor:HSBColor = new HSBColor(0, 0, 0);
		
		/**
		 * @private
		 * The currently selected HSB color. Meant for internal usage
		 * by recursive color pickers to avoid color information loss.
		 */
		yahoo_mx_internal function get selectedHSBColor():HSBColor
		{
			return this._selectedHSBColor;
		}
		
		/**
		 * @private
		 */
		yahoo_mx_internal function set selectedHSBColor(value:HSBColor):void
		{
			this._selectedHSBColor = value;
			this.invalidateProperties();
			this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
		
		/**
		 * @private
		 * Storage for the selectedCMYColor property.
		 */
		private var _selectedCMYColor:CMYColor = new CMYColor(1, 1, 1);
		
		/**
		 * @private
		 * The currently selected CMY color. Meant for internal usage
		 * by recursive color pickers to avoid color information loss.
		 */
		yahoo_mx_internal function get selectedCMYColor():CMYColor
		{
			return this._selectedCMYColor;
		}
		
		/**
		 * @private
		 */
		yahoo_mx_internal function set selectedCMYColor(value:CMYColor):void
		{
			this._selectedCMYColor = value;
			this.invalidateProperties();
			this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
		
		/**
		 * @private
		 * Storage for the selectedCMYKColor property.
		 */
		private var _selectedCMYKColor:CMYKColor = new CMYKColor(0, 0, 0, 1);
		
		/**
		 * @private
		 * The currently selected CMYK color. Meant for internal usage
		 * by recursive color pickers to avoid color information loss.
		 */
		yahoo_mx_internal function get selectedCMYKColor():CMYKColor
		{
			return this._selectedCMYKColor;
		}
		
		/**
		 * @private
		 */
		yahoo_mx_internal function set selectedCMYKColor(value:CMYKColor):void
		{
			this._selectedCMYKColor = value;
			this.invalidateProperties();
			this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
		
		/**
		 * @private
		 * Flag indicating that the color space has changed.
		 */
		protected var colorSpaceChanged:Boolean = true;
		
		/**
		 * @private
		 * Storage for the colorSpace property.
		 */
		private var _colorSpace:String = ColorSpace.RGB;
		
		[Inspectable(defaultValue="rgb",enumeration="rgb,hsb,cmy,cmyk")]
		[Bindable]
		/**
		 * The color space specifies how many sliders will be displayed
		 * and which component each slider will represent.
		 * 
		 * @see com.yahoo.astra.utils.ColorSpace
		 * @default ColorSpace.RGB
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
				this.colorSpaceChanged = true;
				this.invalidateProperties();
				this.invalidateSize();
				this.invalidateDisplayList();
			}
		}
		
		/**
		 * @private
		 * Flag indicating that the liveDragging property has changed.
		 */
		protected var liveDraggingChanged:Boolean = false;
		
		/**
		 * @private
		 * Storage for the liveDragging property.
		 */
		private var _liveDragging:Boolean = false;
		
		[Bindable]
		/**
		 * If true, the selectedColor property will update during drag
		 * operations. If false, it will only update after the mouse button
		 * is released.
		 */
		public function get liveDragging():Boolean
		{
			return this._liveDragging;
		}
		
		/**
		 * @private
		 */
		public function set liveDragging(value:Boolean):void
		{
			if(this._liveDragging == value)
			{
				return;
			}
			this._liveDragging = value;
			this.liveDraggingChanged = true;
			this.invalidateProperties();
		}
		
		/**
		 * @private
		 * Storage for the sliderStyleFilter property.
		 */
		private var _sliderStyleFilter:Object = 
		{
			
		}
		
		/**
		 * @private
		 * The style filters for the sliders
		 */
		protected function get sliderStyleFilter():Object
		{
			return this._sliderStyleFilter;
		}
    
    		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		

		/**
		 * @private
		 */
		override public function styleChanged(styleProp:String):void
		{
			var allStyles:Boolean = !styleProp;
			super.styleChanged(styleProp);
			
			if(allStyles || styleProp == "sliderDirection")
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
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(this.colorSpaceChanged)
			{
				this.refreshSliders();
				
				//pass the component to each slider
				switch(this.colorSpace)
				{
					case ColorSpace.RGB:
						this.sliders[0].component = RGBColor.RED;
						this.sliders[1].component = RGBColor.GREEN;
						this.sliders[2].component = RGBColor.BLUE;
						break;
					case ColorSpace.HSB:
						this.sliders[0].component = HSBColor.HUE;
						this.sliders[1].component = HSBColor.SATURATION;
						this.sliders[2].component = HSBColor.BRIGHTNESS;
						break;
					case ColorSpace.CMYK:
						this.sliders[3].component = CMYKColor.KEY;
					case ColorSpace.CMY:
						this.sliders[0].component = CMYColor.CYAN;
						this.sliders[1].component = CMYColor.MAGENTA;
						this.sliders[2].component = CMYColor.YELLOW;
						break;
					default:
						throw new Error("Invalid Color Space: " + this.colorSpace);
				}
				this.colorSpaceChanged = false;
			}
			
			//refresh properties
			var sliderDirection:String = this.getStyle("sliderDirection");
			var sliderCount:int = this.sliders.length;
			for(var i:int = 0; i < sliderCount; i++)
			{
				var slider:ColorSlider = ColorSlider(this.sliders[i]);
				slider.liveDragging = this.liveDragging;
				slider.colorSpace = this.colorSpace;
				slider.selectedColor = this.selectedColor;
				slider.selectedHSBColor = this.selectedHSBColor;
				slider.selectedCMYColor = this.selectedCMYColor;
				slider.selectedCMYKColor = this.selectedCMYKColor;
				slider.direction = sliderDirection;
			}
		}
		
		/**
		 * @private
		 */
		override protected function measure():void
		{
			super.measure();
			
			var sliderDirection:String = this.getStyle("sliderDirection");
			var spacing:Number = this.getStyle("spacing");
			
			var sliderCount:int = this.sliders.length;
			for(var i:int = 0; i < sliderCount; i++)
			{
				var slider:ColorSlider = ColorSlider(this.sliders[i]);
				if(sliderDirection == "vertical")
				{
					this.measuredWidth += slider.measuredWidth;
					if(i > 0) this.measuredWidth += spacing;
					this.measuredHeight = Math.max(this.measuredHeight, slider.measuredHeight);
				}
				else
				{
					this.measuredWidth = Math.max(this.measuredWidth, slider.measuredWidth);
					this.measuredHeight += slider.measuredHeight;
					if(i > 0) this.measuredHeight += spacing;
				}
			}
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var sliderDirection:String = this.getStyle("sliderDirection");
			var spacing:Number = this.getStyle("spacing");
			
			var xPosition:Number = 0;
			var yPosition:Number = 0;
			var sliderCount:int = this.sliders.length;
			for(var i:int = 0; i < sliderCount; i++)
			{
				var slider:ColorSlider = ColorSlider(this.sliders[i]);
			
				if(sliderDirection == "vertical")
				{
					sliderWidth = (unscaledWidth - (sliderCount - 1) * spacing) / sliderCount;
					sliderHeight = unscaledHeight;
					
					slider.x = xPosition;
					slider.y = 0;
					slider.setActualSize(sliderWidth, sliderHeight);
					xPosition += sliderWidth + spacing;
				}
				else
				{
					var sliderWidth:Number = unscaledWidth;
					var sliderHeight:Number = (unscaledHeight - (sliderCount - 1) * spacing) / sliderCount;
					
					slider.x = 0;
					slider.y = yPosition;
					slider.setActualSize(sliderWidth, sliderHeight);
					yPosition += sliderHeight + spacing;
				}
			}
		}
		
		/**
		 * @private
		 * Adds or removes sliders as needed.
		 */
		protected function refreshSliders():void
		{
			var sliderCount:int = COLOR_SPACE_COMPONENT_COUNT[this.colorSpace];
			var difference:int = sliderCount - this.sliders.length;
			
			if(difference > 0)
			{
				for(var i:int = 0; i < difference; i++)
				{
					var slider:ColorSlider = new ColorSlider();
					slider.liveDragging = this._liveDragging;
					slider.styleName = new StyleProxy(this, this.sliderStyleFilter);
					slider.addEventListener(ColorPickerEvent.CHANGE, sliderChangeHandler);
					slider.addEventListener(ColorPickerEvent.ITEM_ROLL_OVER, sliderRollOverHandler);
					slider.addEventListener(ColorPickerEvent.ITEM_ROLL_OUT, sliderRollOutHandler);
					this.addChild(slider);
					this.sliders.push(slider);
				}
			}
			else
			{
				difference = Math.abs(difference);
				for(i = 0; i < difference; i++)
				{
					slider = ColorSlider(this.sliders.pop());
					slider.removeEventListener(ColorPickerEvent.CHANGE, sliderChangeHandler);
					slider.removeEventListener(ColorPickerEvent.ITEM_ROLL_OVER, sliderRollOverHandler);
					slider.removeEventListener(ColorPickerEvent.ITEM_ROLL_OUT, sliderRollOutHandler);
					this.removeChild(slider);
				}
			}
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
		
		/**
		 * @private
		 * If a slider changes, update the currently selected color.
		 */
		protected function sliderChangeHandler(event:ColorPickerEvent):void
		{
			var slider:ColorSlider = ColorSlider(event.target);
			this.selectedColor = slider.selectedColor;
			this._selectedHSBColor = slider.selectedHSBColor;
			this._selectedCMYColor = slider.selectedCMYColor;
			this._selectedCMYKColor = slider.selectedCMYKColor;
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, this.sliders.indexOf(slider), this.selectedColor));
		}
		
		/**
		 * @private
		 * If a slider is being rolled over (or dragged), update the other
		 * sliders to match. Notify listeners.
		 */
		protected function sliderRollOverHandler(event:ColorPickerEvent):void
		{
			var targetSlider:ColorSlider = ColorSlider(event.target);
			var sliderCount:int = this.sliders.length;
			for(var i:int = 0; i < sliderCount; i++)
			{
				var slider:ColorSlider = ColorSlider(this.sliders[i]);
				if(slider != event.target)
				{
					slider.selectedColor = targetSlider.selectedColor;
					slider.selectedHSBColor = targetSlider.selectedHSBColor;
					slider.selectedCMYColor = targetSlider.selectedCMYColor;
					slider.selectedCMYKColor = targetSlider.selectedCMYKColor;
				}
			}
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OVER, false, false, this.sliders.indexOf(targetSlider), event.color));
		}
		
		/**
		 * @private
		 * Notify listeners of slider rollouts.
		 */
		protected function sliderRollOutHandler(event:ColorPickerEvent):void
		{
			var slider:ColorSlider = ColorSlider(event.target);
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OVER, false, false, this.sliders.indexOf(slider), this.selectedColor));
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
		     if (ColorSliderPicker.createAccessibilityImplementation!=null)
		          ColorSliderPicker.createAccessibilityImplementation(this);
		}		
		
	}
}