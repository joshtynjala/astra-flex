/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls
{
	import com.yahoo.astra.mx.controls.colorPickerClasses.ColorPlane;
	import com.yahoo.astra.mx.controls.colorPickerClasses.ColorSlider;
	import com.yahoo.astra.mx.controls.colorPickerClasses.IColorPicker;
	import com.yahoo.astra.mx.core.yahoo_mx_internal;
	import com.yahoo.astra.utils.CMYColor;
	import com.yahoo.astra.utils.ColorSpace;
	import com.yahoo.astra.utils.ColorUtil;
	import com.yahoo.astra.utils.HSBColor;
	import com.yahoo.astra.utils.RGBColor;
	
	import mx.core.UIComponent;
	import mx.events.ColorPickerEvent;
	import mx.events.FlexEvent;
	import mx.managers.IFocusManagerComponent;
	
	use namespace yahoo_mx_internal;
	
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
	 * ColorPlane and ColorSlider controls combined to represent a full colorspace.
	 * 
	 * @see com.yahoo.astra.mx.controls.colorPickerClasses.ColorPlane
	 * @see com.yahoo.astra.mx.controls.colorPickerClasses.ColorSlider
	 * 
	 * @author Josh Tynjala
	 */
	public class ColorPlaneAndSliderPicker extends UIComponent implements IColorPicker, IFocusManagerComponent
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
		
		/**
		 * @private
		 * The default size of the ColorPlane.
		 */
		private static const DEFAULT_PLANE_SIZE:Number = 180;
		
		/**
		 * @private
		 * The default width of the ColorSlider.
		 */
		private static const DEFAULT_SLIDER_WIDTH:Number = 40;
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function ColorPlaneAndSliderPicker()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The color plane subcomponent.
		 */
		protected var plane:ColorPlane;
		
		/**
		 * The color slider subcomponent.
		 */
		protected var slider:ColorSlider;
		
		/**
		 * @private
		 * Flag indicated that the selected color has changed.
		 */
		protected var selectedColorChanged:Boolean = false;
		
		/**
		 * @private
		 * Storage for the selectedColor property.
		 */
		private var _selectedColor:uint;
		
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
				this._selectedHSBColor = ColorUtil.uintToHSB(this._selectedColor);
				this._selectedCMYColor = ColorUtil.uintToCMY(this._selectedColor);
				this.selectedColorChanged = true;
				this.invalidateProperties();
        		this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			}
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
		private var _selectedCMYColor:CMYColor = new CMYColor(100, 100, 100);
		
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
		 * Flag indicating that the colorspace component has changed for
		 * the slider.
		 */
		protected var sliderComponentChanged:Boolean = false;
		
		/**
		 * @private
		 * Storage for the sliderComponent property.
		 */
		private var _sliderComponent:String = HSBColor.HUE;
		
		[Bindable]
		/**
		 * The colorspace component that will be displayed by the slider.
		 * 
		 * @see com.yahoo.astra.utils.ColorSpace
		 * @see com.yahoo.astra.utils.RGBColor
		 * @see com.yahoo.astra.utils.HSBColor
		 * @see com.yahoo.astra.utils.CMYColor
		 */
		public function get sliderComponent():String
		{
			return this._sliderComponent;
		}
		
		/**
		 * @private
		 */
		public function set sliderComponent(value:String):void
		{
			if(!value) value = HSBColor.HUE;
			if(this._sliderComponent != value)
			{
				this._sliderComponent = value;
				this.sliderComponentChanged = true;
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
			
			if(!this.plane)
			{
				this.plane = new ColorPlane();
				this.plane.liveDragging = true;
				this.plane.externalComponent = HSBColor.HUE;
				this.plane.addEventListener(ColorPickerEvent.CHANGE, planeChangeHandler);
				this.addChild(this.plane);
			}
			
			if(!this.slider)
			{
				this.slider = new ColorSlider();
				this.slider.direction = "vertical";
				this.slider.liveDragging = true;
				this.slider.component = HSBColor.HUE;
				this.slider.addEventListener(ColorPickerEvent.CHANGE, sliderChangeHandler);
				this.addChild(this.slider);
			}
		}
		/**
		 * @private
		 */
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(this.sliderComponentChanged)
			{
				//set the colorspace and component for the slider and plane
				switch(this.sliderComponent)
				{
					case HSBColor.HUE:
					case HSBColor.BRIGHTNESS:
					case HSBColor.SATURATION:
						this.slider.colorSpace = ColorSpace.HSB;
						break;
					case RGBColor.RED:
					case RGBColor.GREEN:
					case RGBColor.BLUE:
						this.slider.colorSpace = ColorSpace.RGB;
						break;
					case CMYColor.CYAN:
					case CMYColor.MAGENTA:
					case CMYColor.YELLOW:
						this.slider.colorSpace = ColorSpace.CMY;
						break;
					//cmyk unsupported by ColorPlane
					default:
						throw new Error("Can't determine compatible color space from : " + this.sliderComponent);
				}
				this.slider.component = this.sliderComponent;
				this.plane.externalComponent = this.sliderComponent;
				this.sliderComponentChanged = false;
			}
			
			//as always, hue seems to give us a special case
			if(this.slider.component == HSBColor.HUE)
			{
				var sliderColor:HSBColor = new HSBColor(this.selectedHSBColor.hue, 100, 100);
				this.slider.selectedColor = sliderColor.touint();
				this.slider.selectedHSBColor = sliderColor;
			}
			else
			{
				this.slider.selectedColor = this.selectedColor;
				this.slider.selectedHSBColor = this.selectedHSBColor;
				this.slider.selectedCMYColor = this.selectedCMYColor;
			}
			
			//refresh the selected colors
			this.plane.selectedColor = this.selectedColor;
			this.plane.selectedHSBColor = this.selectedHSBColor;
			this.plane.selectedCMYColor = this.selectedCMYColor;
		}
		
		/**
		 * @private
		 */
		override protected function measure():void
		{
			super.measure();
			
			var horizontalGap:Number = this.getStyle("horizontalGap");
			
			this.measuredWidth = DEFAULT_PLANE_SIZE;
			this.measuredHeight = DEFAULT_PLANE_SIZE;
			
			this.measuredWidth += horizontalGap + DEFAULT_SLIDER_WIDTH;
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var horizontalGap:Number = this.getStyle("horizontalGap");
			
			var planeWidth:Number = unscaledWidth - horizontalGap - DEFAULT_SLIDER_WIDTH;
			var planeHeight:Number = unscaledHeight;
			
			this.plane.setActualSize(planeWidth, planeHeight);
			
			this.slider.setActualSize(DEFAULT_SLIDER_WIDTH, planeHeight);
			this.slider.x = unscaledWidth - this.slider.width;
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
	
		/**
		 * @private
		 * Update the selected color based on slider changes. Notify listeners.
		 */
		protected function sliderChangeHandler(event:ColorPickerEvent):void
		{
			this.plane.externalValue = this.slider.selectedValue;
			this.selectedColor = this.plane.selectedColor;
			this._selectedHSBColor = this.plane.selectedHSBColor;
			this._selectedCMYColor = this.plane.selectedCMYColor;
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, this.selectedColor));
		}
		
		/**
		 * @private
		 * Update the selected color based on plane changes. Notify listeners.
		 */
		protected function planeChangeHandler(event:ColorPickerEvent):void
		{
			this.selectedColor = event.color;
			this._selectedHSBColor = this.plane.selectedHSBColor;
			this._selectedCMYColor = this.plane.selectedCMYColor;
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, this.selectedColor));
		}
	}
}