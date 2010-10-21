/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls.colorPickerClasses
{
	import com.yahoo.astra.mx.controls.ColorPlaneAndSliderPicker;
	import com.yahoo.astra.mx.core.yahoo_mx_internal;
	import com.yahoo.astra.utils.ColorUtil;
	import com.yahoo.astra.utils.HSBColor;
	import com.yahoo.astra.utils.RGBColor;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import mx.controls.Button;
	import mx.controls.RadioButton;
	import mx.controls.RadioButtonGroup;
	import mx.controls.TextInput;
	import mx.core.UIComponent;
	import mx.events.ColorPickerEvent;
	import mx.events.FlexEvent;
	import mx.events.ItemClickEvent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.styles.StyleProxy;
	
	use namespace yahoo_mx_internal;
	
	/**
	 * A drop-down with a ColorPlane, a ColorSlider, and a set of TextInputs
	 * representing values in the HSB and RGB colorspaces.
	 * 
	 * @see com.yahoo.astra.mx.controls.ColorPlane
	 * @see com.yahoo.astra.mx.controls.ColorSlider
	 * @see com.yahoo.astra.mx.controls.DropDownColorPicker
	 * 
	 * @author Josh Tynjala
	 */
	public class AdvancedColorPickerDropDown extends BaseColorPickerDropDown
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
		
		/**
		 * @private
		 * The default width of the viewer.
		 */
		private static const DEFAULT_VIEWER_WIDTH:Number = 50;
		
		/**
		 * @private
		 * The default height of the viewer.
		 */
		private static const DEFAULT_VIEWER_HEIGHT:Number = 60;
		
		/**
		 * @private
		 * The default width of the hex input.
		 */
		private static const DEFAULT_INPUT_WIDTH:Number = 40;
		
		/**
		 * @private
		 * The default width of the colorplane+slider.
		 */
		private static const DEFAULT_PLANE_AND_SLIDER_WIDTH:Number = 290;
		
		/**
		 * @private
		 * The default height of the colorplane+slider
		 */
		private static const DEFAULT_PLANE_AND_SLIDER_HEIGHT:Number = 250;
		
	//--------------------------------------
	//  Static Methods
	//--------------------------------------
	
		/**
		 * @private
		 * Sets the default style values for this control type.
		 */
		private static function initializeStyles():void
		{
			var styleDeclaration:CSSStyleDeclaration = StyleManager.getStyleDeclaration("AdvancedColorPickerDropDown");
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
				this.horizontalGap = 4;
				this.verticalGap = 8;
			};
			
			StyleManager.setStyleDeclaration("AdvancedColorPickerDropDown", styleDeclaration, false);
		}
		initializeStyles();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function AdvancedColorPickerDropDown()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The ColorPlaneAndSlider instance.
		 */
		protected var planeAndSlider:ColorPlaneAndSliderPicker;
		
		/**
		 * The select button.
		 */
		protected var selectButton:Button;
		
		/**
		 * The radio group for the colorspace component inputs.
		 */
		protected var componentRadioGroup:RadioButtonGroup;
		
		/**
		 * The radio for the hue component.
		 */
		protected var hueRadio:RadioButton;
		
		/**
		 * The radio for the saturation component.
		 */
		protected var saturationRadio:RadioButton;
		
		/**
		 * The radio for the brightness component.
		 */
		protected var brightnessRadio:RadioButton;
		
		/**
		 * The radio for the red component.
		 */
		protected var redRadio:RadioButton;
		
		/**
		 * The radio for the green component.
		 */
		protected var greenRadio:RadioButton;
		
		/**
		 * The radio for the blue component.
		 */
		protected var blueRadio:RadioButton;
		
		/**
		 * The textinput for the hue component.
		 */
		protected var hueInput:TextInput;
		
		/**
		 * The textinput for the saturation component.
		 */
		protected var saturationInput:TextInput;
		
		/**
		 * The textinput for the brightness component.
		 */
		protected var brightnessInput:TextInput;
		
		/**
		 * The textinput for the red component.
		 */
		protected var redInput:TextInput;
		
		/**
		 * The textinput for the green component.
		 */
		protected var greenInput:TextInput;
		
		/**
		 * The textinput for the blue component.
		 */
		protected var blueInput:TextInput;
		
		/**
		 * @inheritDoc
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
		 * The calculated width of the radios and inputs.
		 */
		protected function get radioInputWidth():Number
		{
			var horizontalGap:Number = this.getStyle("horizontalGap");
			return this.hueRadio.measuredWidth + horizontalGap + DEFAULT_INPUT_WIDTH;
		}
		
		/**
		 * @private
		 */
		protected function get radioInputHeight():Number
		{
			var verticalGap:Number = this.getStyle("verticalGap");
			return this.hueRadio.measuredHeight + this.saturationRadio.measuredHeight + this.brightnessRadio.measuredHeight +
				this.redRadio.measuredHeight + this.greenRadio.measuredHeight + this.blueRadio.measuredHeight + 6 * verticalGap;
		}
		
	//--------------------------------------
	//  Protected Functions
	//--------------------------------------
		
		/**
		 * @private
		 */
		override protected function createChildren():void
		{
			//we're overriding the default viewer
			if(!this.viewer)
			{
				this.viewer = new DividedColorViewer();
				UIComponent(this.viewer).tabEnabled = false;
				var dividedViewer:DividedColorViewer = DividedColorViewer(this.viewer);
				dividedViewer.angle = 0;
				dividedViewer.showPreview = true
				dividedViewer.styleName = new StyleProxy(this, this.viewerStyleFilter);
				this.addChild(dividedViewer);
			}
			
			super.createChildren();
			
			//put the viewer above the border
			this.setChildIndex(DisplayObject(this.viewer), this.getChildIndex(DisplayObject(this.border)) + 1);
			
			if(!this.planeAndSlider)
			{
				this.planeAndSlider = new ColorPlaneAndSliderPicker();
				this.planeAndSlider.addEventListener(ColorPickerEvent.CHANGE, planeAndSliderChangeHandler);
				this.addChild(this.planeAndSlider);
			}
			
			if(!this.selectButton)
			{
				this.selectButton = new Button();
				this.selectButton.label = "OK";
				this.selectButton.addEventListener(MouseEvent.CLICK, selectButtonClickHandler);
				this.addChild(this.selectButton);
			}
			
			if(!this.componentRadioGroup)
			{
				this.componentRadioGroup = new RadioButtonGroup();
				//we have to do this manually below
				//this.componentRadioGroup.addEventListener(Event.CHANGE, componentRadioChangeHandler);
			}
			
			if(!this.hueRadio)
			{
				this.hueRadio = new RadioButton();
				this.hueRadio.focusEnabled = false;
				this.hueRadio.group = this.componentRadioGroup;
				this.hueRadio.label = "H";
				this.hueRadio.value = HSBColor.HUE;
				this.hueRadio.selected = true;
				this.hueRadio.addEventListener(MouseEvent.CLICK, hueRadioClickHandler);
				this.addChild(this.hueRadio);
			}
			
			if(!this.saturationRadio)
			{
				this.saturationRadio = new RadioButton();
				this.saturationRadio.focusEnabled = false;
				this.saturationRadio.group = this.componentRadioGroup;
				this.saturationRadio.label = "S";
				this.saturationRadio.value = HSBColor.SATURATION;
				this.saturationRadio.addEventListener(MouseEvent.CLICK, saturationRadioClickHandler);
				this.addChild(this.saturationRadio);
			}
			
			if(!this.brightnessRadio)
			{
				this.brightnessRadio = new RadioButton();
				this.brightnessRadio.focusEnabled = false;
				this.brightnessRadio.group = this.componentRadioGroup;
				this.brightnessRadio.label = "B";
				this.brightnessRadio.value = HSBColor.BRIGHTNESS;
				this.brightnessRadio.addEventListener(MouseEvent.CLICK, brightnessRadioClickHandler);
				this.addChild(this.brightnessRadio);
			}
			
			if(!this.redRadio)
			{
				this.redRadio = new RadioButton();
				this.redRadio.focusEnabled = false;
				this.redRadio.group = this.componentRadioGroup;
				this.redRadio.label = "R";
				this.redRadio.value = RGBColor.RED;
				this.redRadio.addEventListener(MouseEvent.CLICK, redRadioClickHandler);
				this.addChild(this.redRadio);
			}
			
			if(!this.greenRadio)
			{
				this.greenRadio = new RadioButton();
				this.greenRadio.focusEnabled = false;
				this.greenRadio.group = this.componentRadioGroup;
				this.greenRadio.label = "G";
				this.greenRadio.value = RGBColor.GREEN;
				this.greenRadio.addEventListener(MouseEvent.CLICK, greenRadioClickHandler);
				this.addChild(this.greenRadio);
			}
			
			if(!this.blueRadio)
			{
				this.blueRadio = new RadioButton();
				this.blueRadio.focusEnabled = false;
				this.blueRadio.group = this.componentRadioGroup;
				this.blueRadio.label = "B";
				this.blueRadio.value = RGBColor.BLUE;
				this.blueRadio.addEventListener(MouseEvent.CLICK, blueRadioClickHandler);
				this.addChild(this.blueRadio);
			}
			
			if(!this.hueInput)
			{
				this.hueInput = new TextInput();
				this.hueInput.restrict = "0-9";
				this.hueInput.maxChars = 3;
				this.hueInput.addEventListener(Event.CHANGE, hueChangeHandler);
				this.hueInput.addEventListener(FocusEvent.FOCUS_IN, hueInputFocusInHandler);
				this.addChild(this.hueInput);
			}
			
			if(!this.saturationInput)
			{
				this.saturationInput = new TextInput();
				this.saturationInput.restrict = "0-9";
				this.saturationInput.maxChars = 3;
				this.saturationInput.addEventListener(Event.CHANGE, saturationChangeHandler);
				this.saturationInput.addEventListener(FocusEvent.FOCUS_IN, saturationInputFocusInHandler);
				this.addChild(this.saturationInput);
			}
			
			if(!this.brightnessInput)
			{
				this.brightnessInput = new TextInput();
				this.brightnessInput.restrict = "0-9";
				this.brightnessInput.maxChars = 3;
				this.brightnessInput.addEventListener(Event.CHANGE, brightnessChangeHandler);
				this.brightnessInput.addEventListener(FocusEvent.FOCUS_IN, brightnessInputFocusInHandler);
				this.addChild(this.brightnessInput);
			}
			
			if(!this.redInput)
			{
				this.redInput = new TextInput();
				this.redInput.restrict = "0-9";
				this.redInput.addEventListener(Event.CHANGE, redChangeHandler);
				this.redInput.addEventListener(FocusEvent.FOCUS_IN, redInputFocusInHandler);
				this.redInput.maxChars = 3;
				this.addChild(this.redInput);
			}
			
			if(!this.greenInput)
			{
				this.greenInput = new TextInput();
				this.greenInput.restrict = "0-9";
				this.greenInput.maxChars = 3;
				this.greenInput.addEventListener(Event.CHANGE, greenChangeHandler);
				this.greenInput.addEventListener(FocusEvent.FOCUS_IN, greenInputFocusInHandler);
				this.addChild(this.greenInput);
			}
			
			if(!this.blueInput)
			{
				this.blueInput = new TextInput();
				this.blueInput.restrict = "0-9";
				this.blueInput.maxChars = 3;
				this.blueInput.addEventListener(Event.CHANGE, blueChangeHandler);
				this.blueInput.addEventListener(FocusEvent.FOCUS_IN, blueInputFocusInHandler);
				this.addChild(this.blueInput);
			}
			
			this.selectButton.tabIndex = this.numChildren - 1;
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			this.planeAndSlider.selectedColor = this.previewColor;
			this.planeAndSlider.selectedHSBColor = this.previewHSBColor;
			this.viewer.color = this.selectedColor;
			IColorPreviewViewer(this.viewer).previewColor = this.previewColor;
			
			this.hueInput.text = int(this.previewHSBColor.hue).toString();
			this.saturationInput.text = int(this.previewHSBColor.saturation).toString();
			this.brightnessInput.text = int(this.previewHSBColor.brightness).toString();
			
			var rgb:RGBColor = ColorUtil.uintToRGB(this.previewColor);
			this.redInput.text = int(rgb.red).toString();
			this.greenInput.text = int(rgb.green).toString();
			this.blueInput.text = int(rgb.blue).toString();
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
			var horizontalGap:Number = this.getStyle("horizontalGap");
			
			var radioInputWidth:Number = this.radioInputWidth; 
			var radioInputHeight:Number = this.radioInputHeight;
			
			var topRowWidth:Number = DEFAULT_PLANE_AND_SLIDER_WIDTH + horizontalGap + Math.max(DEFAULT_VIEWER_WIDTH, radioInputWidth);
			var topRowHeight:Number = Math.max(DEFAULT_PLANE_AND_SLIDER_HEIGHT, radioInputHeight + verticalGap + DEFAULT_VIEWER_HEIGHT); 
			var bottomRowWidth:Number = this.selectButton.measuredWidth + horizontalGap + this.hexInput.measuredWidth;
			var bottomRowHeight:Number = Math.max(this.selectButton.measuredHeight, this.hexInput.measuredHeight); 
			
			this.measuredWidth = paddingLeft + paddingRight + Math.max(topRowWidth, bottomRowWidth);
			this.measuredHeight = paddingTop + paddingBottom + topRowHeight + verticalGap + bottomRowHeight;
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
			var horizontalGap:Number = this.getStyle("horizontalGap");
			
			var radioInputWidth:Number = this.radioInputWidth; 
			var radioInputHeight:Number = this.radioInputHeight;
			var rightColumnX:Number = unscaledWidth - paddingRight - Math.max(radioInputWidth, DEFAULT_VIEWER_WIDTH);
			var rightColumnWidth:Number = Math.max(radioInputWidth, DEFAULT_VIEWER_WIDTH);
			
			this.viewer.setActualSize(DEFAULT_VIEWER_WIDTH, DEFAULT_VIEWER_HEIGHT);
			this.viewer.x = rightColumnX + (rightColumnWidth - this.viewer.width) / 2;
			
			this.hexInput.setActualSize(this.hexInput.measuredWidth, this.hexInput.measuredHeight);
			this.hexInput.x = paddingLeft;
			this.hexInput.y = unscaledHeight - paddingBottom - this.hexInput.height;
			
			this.selectButton.setActualSize(this.selectButton.measuredWidth, this.selectButton.measuredHeight);
			this.selectButton.x = unscaledWidth - paddingRight - this.selectButton.width;
			this.selectButton.y = unscaledHeight - paddingBottom - this.selectButton.height;
			
			var planeWidth:Number = unscaledWidth - paddingLeft - paddingRight - horizontalGap - Math.max(this.viewer.width, radioInputWidth);
			var planeHeight:Number = unscaledHeight - paddingTop - paddingBottom - verticalGap - this.hexInput.height;
			
			this.planeAndSlider.setActualSize(planeWidth, planeHeight);
			this.planeAndSlider.x = paddingLeft;
			this.planeAndSlider.y = paddingRight;
			
			var radioX:Number = rightColumnX + (rightColumnWidth - radioInputWidth) / 2;
			var radioY:Number = this.viewer.y + this.viewer.height + verticalGap;
			
			this.hueRadio.setActualSize(this.hueRadio.measuredWidth, this.hueRadio.measuredHeight);
			this.hueRadio.x = radioX;
			this.hueRadio.y = radioY;
			this.hueInput.setActualSize(DEFAULT_INPUT_WIDTH, this.hueInput.measuredHeight);
			this.hueInput.x = this.hueRadio.x + this.hueRadio.width + horizontalGap;
			this.hueInput.y = radioY;
			radioY += this.hueRadio.height + verticalGap;
			
			this.saturationRadio.setActualSize(this.saturationRadio.measuredWidth, this.saturationRadio.measuredHeight);
			this.saturationRadio.x = radioX;
			this.saturationRadio.y = radioY;
			this.saturationInput.setActualSize(DEFAULT_INPUT_WIDTH, this.saturationInput.measuredHeight);
			this.saturationInput.x = this.saturationRadio.x + this.saturationRadio.width + horizontalGap;
			this.saturationInput.y = radioY;
			radioY += this.saturationRadio.height + verticalGap;
			
			this.brightnessRadio.setActualSize(this.brightnessRadio.measuredWidth, this.brightnessRadio.measuredHeight);
			this.brightnessRadio.x = radioX;
			this.brightnessRadio.y = radioY;
			this.brightnessInput.setActualSize(DEFAULT_INPUT_WIDTH, this.brightnessInput.measuredHeight);
			this.brightnessInput.x = this.brightnessRadio.x + this.brightnessRadio.width + horizontalGap;
			this.brightnessInput.y = radioY;
			radioY += this.brightnessRadio.height + 2 * verticalGap;
			
			this.redRadio.setActualSize(this.redRadio.measuredWidth, this.redRadio.measuredHeight);
			this.redRadio.x = radioX;
			this.redRadio.y = radioY;
			this.redInput.setActualSize(DEFAULT_INPUT_WIDTH, this.redInput.measuredHeight);
			this.redInput.x = this.redRadio.x + this.redRadio.width + horizontalGap;
			this.redInput.y = radioY;
			radioY += this.redRadio.height + verticalGap;
			
			this.greenRadio.setActualSize(this.greenRadio.measuredWidth, this.greenRadio.measuredHeight);
			this.greenRadio.x = radioX;
			this.greenRadio.y = radioY;
			this.greenInput.setActualSize(DEFAULT_INPUT_WIDTH, this.greenInput.measuredHeight);
			this.greenInput.x = this.greenRadio.x + this.greenRadio.width + horizontalGap;
			this.greenInput.y = radioY;
			radioY += this.redRadio.height + verticalGap;
			
			this.blueRadio.setActualSize(this.blueRadio.measuredWidth, this.blueRadio.measuredHeight);
			this.blueRadio.x = radioX;
			this.blueRadio.y = radioY;
			this.blueInput.setActualSize(DEFAULT_INPUT_WIDTH, this.blueInput.measuredHeight);
			this.blueInput.x = this.blueRadio.x + this.blueRadio.width + horizontalGap;
			this.blueInput.y = radioY;
			radioY += this.blueRadio.height + verticalGap;
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
	
		/**
		 * @private
		 * Refresh the preview color if the ColorPlane or the ColorSlider changes.
		 */
		protected function planeAndSliderChangeHandler(event:ColorPickerEvent):void
		{
			this.previewColor = event.color;
			this.invalidateProperties();
		}

		/**
		 * @private
		 * Focus the hue input when the matching radio receives focus.
		 */
		protected function hueRadioClickHandler(event:MouseEvent):void
		{
			this.hueInput.setFocus();
		}

		/**
		 * @private
		 * Focus the saturation input when the matching radio receives focus.
		 */
		protected function saturationRadioClickHandler(event:MouseEvent):void
		{
			this.saturationInput.setFocus();
		}

		/**
		 * @private
		 * Focus the brightness input when the matching radio receives focus.
		 */
		protected function brightnessRadioClickHandler(event:MouseEvent):void
		{
			this.brightnessInput.setFocus();
		}

		/**
		 * @private
		 * Focus the red input when the matching radio receives focus.
		 */
		protected function redRadioClickHandler(event:MouseEvent):void
		{
			this.redInput.setFocus();
		}

		/**
		 * @private
		 * Focus the green input when the matching radio receives focus.
		 */
		protected function greenRadioClickHandler(event:MouseEvent):void
		{
			this.greenInput.setFocus();
		}

		/**
		 * @private
		 * Focus the blue input when the matching radio receives focus.
		 */
		protected function blueRadioClickHandler(event:MouseEvent):void
		{
			this.blueInput.setFocus();
		}

		/**
		 * @private
		 * Select the hue radio when the matching input receives focus and
		 * update the slider component.
		 */
		protected function hueInputFocusInHandler(event:FocusEvent):void
		{
			this.hueRadio.selected = true;
			this.planeAndSlider.sliderComponent = this.hueRadio.value.toString();
		}

		/**
		 * @private
		 * Select the saturation radio when the matching input receives focus and
		 * update the slider component.
		 */
		protected function saturationInputFocusInHandler(event:FocusEvent):void
		{
			this.saturationRadio.selected = true;
			this.planeAndSlider.sliderComponent = this.saturationRadio.value.toString();
		}

		/**
		 * @private
		 * Select the brightness radio when the matching input receives focus and
		 * update the slider component.
		 */
		protected function brightnessInputFocusInHandler(event:FocusEvent):void
		{
			this.brightnessRadio.selected = true;
			this.planeAndSlider.sliderComponent = this.brightnessRadio.value.toString();
		}

		/**
		 * @private
		 * Select the red radio when the matching input receives focus and
		 * update the slider component.
		 */
		protected function redInputFocusInHandler(event:FocusEvent):void
		{
			this.redRadio.selected = true;
			this.planeAndSlider.sliderComponent = this.redRadio.value.toString();
		}

		/**
		 * @private
		 * Select the green radio when the matching input receives focus and
		 * update the slider component.
		 */
		protected function greenInputFocusInHandler(event:FocusEvent):void
		{
			this.greenRadio.selected = true;
			this.planeAndSlider.sliderComponent = this.greenRadio.value.toString();
		}

		/**
		 * @private
		 * Select the blue radio when the matching input receives focus and
		 * update the slider component.
		 */
		protected function blueInputFocusInHandler(event:FocusEvent):void
		{
			this.blueRadio.selected = true;
			this.planeAndSlider.sliderComponent = this.blueRadio.value.toString();
		}

		/**
		 * @private
		 * Update the preview color when a component input changes.
		 */
		protected function hueChangeHandler(event:Event):void
		{
			var hueValue:int = int(this.hueInput.text);
			var hsb:HSBColor = HSBColor(this.previewHSBColor.clone());
			hsb.hue = Math.min(360, hueValue);
			this.previewColor = hsb.touint();
			this.previewHSBColor = hsb;
		}

		/**
		 * @private
		 * Update the preview color when a component input changes.
		 */
		protected function saturationChangeHandler(event:Event):void
		{
			var saturationValue:int = int(this.saturationInput.text);
			var hsb:HSBColor = HSBColor(this.previewHSBColor.clone());
			hsb.saturation = Math.min(100, saturationValue);
			this.previewColor = hsb.touint();
			this.previewHSBColor = hsb;
		}

		/**
		 * @private
		 * Update the preview color when a component input changes.
		 */
		protected function brightnessChangeHandler(event:Event):void
		{
			var brightnessValue:int = int(this.brightnessInput.text);
			var hsb:HSBColor = HSBColor(this.previewHSBColor.clone());
			hsb.brightness = Math.min(100, brightnessValue);
			this.previewColor = hsb.touint();
			this.previewHSBColor = hsb;
		}

		/**
		 * @private
		 * Update the preview color when a component input changes.
		 */
		protected function redChangeHandler(event:Event):void
		{
			var redValue:int = int(this.redInput.text);
			var rgb:RGBColor = ColorUtil.uintToRGB(this.previewColor);
			rgb.red = Math.min(255, redValue);
			this.previewColor = rgb.touint();
		}

		/**
		 * @private
		 * Update the preview color when a component input changes.
		 */
		protected function greenChangeHandler(event:Event):void
		{
			var greenValue:int = int(this.greenInput.text);
			var rgb:RGBColor = ColorUtil.uintToRGB(this.previewColor);
			rgb.green = Math.min(255, greenValue);
			this.previewColor = rgb.touint();
		}

		/**
		 * @private
		 * Update the preview color when a component input changes.
		 */
		protected function blueChangeHandler(event:Event):void
		{
			var blueValue:int = int(this.blueInput.text);
			var rgb:RGBColor = ColorUtil.uintToRGB(this.previewColor);
			rgb.blue = Math.min(255, blueValue);
			this.previewColor = rgb.touint();
		}

		/**
		 * @private
		 * Update the selected color and notify listeners when the select button is clicked.
		 */
		protected function selectButtonClickHandler(event:MouseEvent):void
		{
			var hsb:HSBColor = HSBColor(this.previewHSBColor.clone());
			this.selectedColor = this.previewColor;
			this.previewHSBColor = hsb;
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, this.selectedColor));
		}
	}
}