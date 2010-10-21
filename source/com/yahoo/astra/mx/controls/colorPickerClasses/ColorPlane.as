/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls.colorPickerClasses
{
	import com.yahoo.astra.animation.Animation;
	import com.yahoo.astra.mx.core.yahoo_mx_internal;
	import com.yahoo.astra.utils.CMYColor;
	import com.yahoo.astra.utils.ColorSpace;
	import com.yahoo.astra.utils.ColorUtil;
	import com.yahoo.astra.utils.HSBColor;
	import com.yahoo.astra.utils.IColor;
	import com.yahoo.astra.utils.RGBColor;
	
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.core.EdgeMetrics;
	import mx.core.IBorder;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.events.ColorPickerEvent;
	import mx.events.FlexEvent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.ISimpleStyleClient;
	import mx.styles.StyleManager;

	use namespace yahoo_mx_internal;
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	//Flex framework styles
	include "../../styles/metadata/BorderStyles.inc"
	
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
	 * Two individual components of a colorspace represented in a
	 * two-dimensional picker.
	 * 
	 * @author Josh Tynjala
	 */
	public class ColorPlane extends UIComponent implements IColorPicker
	{
	
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
	
		/**
		 * @private
		 * The default width value of the plane.
		 */
		private static const DEFAULT_MEASURED_WIDTH:Number = 160;
		
		/**
		 * @private
		 * The default height value of the plane.
		 */
		private static const DEFAULT_MEASURED_HEIGHT:Number = 160;
	
	//--------------------------------------
	//  Static Methods
	//--------------------------------------
	
		/**
		 * @private
		 * Sets default style values for controls of this type.
		 */
		private static function initializeStyles():void
		{
			var styleDeclaration:CSSStyleDeclaration = StyleManager.getStyleDeclaration("ColorPlane");
			if(!styleDeclaration)
			{
				styleDeclaration = new CSSStyleDeclaration();
			}
			
			styleDeclaration.defaultFactory = function():void
			{
				this.selectionIndicatorSkin = ColorSelectionIndicator;
				this.selectionIndicatorSize = 10;
			};
			
			StyleManager.setStyleDeclaration("ColorPlane", styleDeclaration, false);
		}
		initializeStyles();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function ColorPlane()
		{
			super();
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The border around the color region.
		 */
		protected var border:IFlexDisplayObject;
		
		/**
		 * The selection indicator.
		 */
		protected var selectionIndicator:IFlexDisplayObject;
		
		/**
		 * @private
		 * The region in which the horizontal colorspace component is drawn.
		 */
		protected var horizontalColor:Sprite;
		
		/**
		 * @private
		 * The region in which a gradient is drawn for the horizontal color. 
		 */
		protected var horizontalGradient:Shape;
		
		/**
		 * @private
		 * The mask for the horizontal region.
		 */
		protected var horizontalAlphaMask:Shape;
		
		
		/**
		 * @private
		 * The region in which the vertical colorspace component is drawn.
		 */
		protected var verticalColor:Sprite;
		
		/**
		 * @private
		 * The region in which a gradient is drawn for the vertical color. 
		 */
		protected var verticalGradient:Shape;
		
		/**
		 * @private
		 * The mask for the vertical region.
		 */
		protected var verticalAlphaMask:Shape;
		
		/**
		 * @private
		 * Flag indicating if the selection indicator has been positioned at least once.
		 */
		protected var selectionIndicatorPositionInitialized:Boolean = false;
		
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
			this._selectedColor = value;
			if(this.colorSpace == ColorSpace.RGB)
			{
				this._externalValue = ColorUtil.uintToRGB(value)[this.externalComponent];
			}
			this._selectedHSBColor = ColorUtil.uintToHSB(this._selectedColor);
			this._selectedCMYColor = ColorUtil.uintToCMY(this._selectedColor);
			this.previewColor = this._selectedColor;
			this.invalidateDisplayList();
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
			if(this.colorSpace == ColorSpace.HSB)
			{
				this._externalValue = value[this.externalComponent];
			}
			this.invalidateDisplayList();
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
			if(this.colorSpace == ColorSpace.CMY)
			{
				this._externalValue = value[this.externalComponent];
			}
			this.invalidateDisplayList();
			this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
		
		/**
		 * @private
		 * Returns the selectedColor from the current colorspace.
		 */
		yahoo_mx_internal function get selectedColorFromColorSpace():IColor
		{
			var color:IColor;
			switch(this.colorSpace)
			{
				case ColorSpace.RGB:
					color = ColorUtil.uintToRGB(this.selectedColor);
					break;
				case ColorSpace.HSB:
					//we clone the colors because we don't want to accidently modify them!
					color = this.selectedHSBColor.clone();
					break;
				case ColorSpace.CMY:
					color = this.selectedCMYColor.clone();
					break;
				default:
					throw new Error("Invalid ColorSpace: " + this.colorSpace);
			}
			return color;
		}
		
		/**
		 * @private
		 * The current colorspace. Determined from the components.
		 */
		protected var colorSpace:String = ColorSpace.HSB;
		
		/**
		 * @private
		 * The colorspace component on the vertical range.
		 */
		protected var verticalComponent:String;
		
		/**
		 * @private
		 * The colorspace component on the horizontal stage.
		 */
		protected var horizontalComponent:String;
		
		/**
		 * @private
		 * The minimum value on the horizontal range.
		 */
		protected var horizontalMinimum:Number = 0;
		
		/**
		 * @private
		 * The maximum value on the horizontal range.
		 */
		protected var horizontalMaximum:Number = 100;
		
		/**
		 * @private
		 * The current value on the horizontal range.
		 */
		protected function get horizontalValue():Number
		{
			var color:IColor = this.selectedColorFromColorSpace;
			return color[this.horizontalComponent];
		}
		
		/**
		 * @private
		 * The minimum value on the vertical range.
		 */
		protected var verticalMinimum:Number = 0;
		
		/**
		 * @private
		 * The maximum value on the vertical range.
		 */
		protected var verticalMaximum:Number = 100;
		
		/**
		 * @private
		 * The current value on the vertical range.
		 */
		protected function get verticalValue():Number
		{
			var color:IColor = this.selectedColorFromColorSpace;
			return color[this.verticalComponent];
		}
		
		/**
		 * @private
		 * Flag indicating whether the external component has changed.
		 */
		protected var externalComponentChanged:Boolean = true;
		
		/**
		 * @private
		 * Storage for the externalComponent property.
		 */
		private var _externalComponent:String = HSBColor.HUE;
		
		[Bindable]
		/**
		 * The color plane supports colorspaces with three components, but it
		 * can only modify two components, so it is assumed that one is modified
		 * externally. The other two components are automatically determined
		 * based on the specified external component.
		 * 
		 * @see com.yahoo.astra.utils.ColorSpace
		 * @see com.yahoo.astra.utils.RGBColor
		 * @see com.yahoo.astra.utils.HSBColor
		 * @see com.yahoo.astra.utils.CMYColor
		 */
		public function get externalComponent():String
		{
			return this._externalComponent;
		}
		
		/**
		 * @private
		 */
		public function set externalComponent(value:String):void
		{
			if(!value) value = HSBColor.HUE;
			if(this._externalComponent != value)
			{
				this._externalComponent = value;
				switch(this._externalComponent)
				{
					case HSBColor.HUE:
					case HSBColor.BRIGHTNESS:
					case HSBColor.SATURATION:
						this.colorSpace = ColorSpace.HSB;
						break;
					case RGBColor.RED:
					case RGBColor.GREEN:
					case RGBColor.BLUE:
						this.colorSpace = ColorSpace.RGB;
						break;
					case CMYColor.CYAN:
					case CMYColor.MAGENTA:
					case CMYColor.YELLOW:
						this.colorSpace = ColorSpace.CMY;
						break;
					//cmyk unsupported by ColorPlane
					default:
						throw new Error("Invalid color space: " + value);
				}
				this.externalComponentChanged = true;
				this.invalidateProperties();
				this.invalidateDisplayList();
			}
		}
		
		/**
		 * @private
		 * Storage for the externalValue property.
		 */
		private var _externalValue:Number = 0;
		
		[Bindable]
		/**
		 * The value of the external colorspace component.
		 * 
		 * @see com.yahoo.astra.utils.ColorSpace
		 * @see com.yahoo.astra.utils.RGBColor
		 * @see com.yahoo.astra.utils.HSBColor
		 * @see com.yahoo.astra.utils.CMYColor
		 */
		public function get externalValue():Number
		{
			return this._externalValue;
		}
		
		/**
		 * @private
		 */
		public function set externalValue(value:Number):void
		{
			if(this._externalValue != value)
			{
				this._externalValue = value;
				this.updateExternalColorFromValue(value);
				this.invalidateProperties();
				this.invalidateDisplayList();
			}
		}
		
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
			this._liveDragging = value;
		}
		
		/**
		 * @private
		 * Storage for the previewColor property.
		 */
		private var _previewColor:uint = 0x000000;
		
		/**
		 * @private
		 * The currently previewed color.
		 */
		protected function get previewColor():uint
		{
			return this._previewColor;
		}
		
		/**
		 * @private
		 */
		protected function set previewColor(value:uint):void
		{
			if(this._previewColor != value)
			{
				this._previewColor = value;
				this.invalidateProperties();
			}
		}
		
		/**
		 * @private
		 * Flag indicating whether the mouse button is down.
		 */
		protected var mouseButtonDown:Boolean = false;
		
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
				var borderSkin:Class = this.getStyle("borderSkin");
				if(borderSkin)
				{
					this.border = new borderSkin();
					if(this.border is ISimpleStyleClient)
					{
						ISimpleStyleClient(this.border).styleName = this;
					}
					this.addChild(DisplayObject(this.border));
				}
			}
			
			if(!this.horizontalColor)
			{
				this.horizontalColor = new Sprite();
				this.horizontalColor.blendMode = BlendMode.LAYER;
				this.addChild(this.horizontalColor);
			}
			
			if(!this.horizontalGradient)
			{
				this.horizontalGradient = new Shape();
				this.horizontalColor.addChild(this.horizontalGradient);
			}
			
			if(!this.horizontalAlphaMask)
			{
				this.horizontalAlphaMask = new Shape();
				this.horizontalAlphaMask.blendMode = BlendMode.ALPHA;
				this.horizontalColor.addChild(this.horizontalAlphaMask);
			}
			
			if(!this.verticalColor)
			{
				this.verticalColor = new Sprite();
				this.verticalColor.blendMode = BlendMode.LAYER;
				this.addChild(this.verticalColor);
			}
			
			if(!this.verticalGradient)
			{
				this.verticalGradient = new Shape();
				this.verticalColor.addChild(this.verticalGradient);
			}
			
			if(!this.verticalAlphaMask)
			{
				this.verticalAlphaMask = new Shape();
				this.verticalAlphaMask.blendMode = BlendMode.ALPHA;
				this.verticalColor.addChild(this.verticalAlphaMask);
			}
			
			if(!this.selectionIndicator)
			{
				var selectionIndicatorSkin:Class = this.getStyle("selectionIndicatorSkin") as Class;
				if(selectionIndicatorSkin)
				{
					this.selectionIndicator = new selectionIndicatorSkin();
					if(this.selectionIndicator is ISimpleStyleClient)
					{
						ISimpleStyleClient(this.selectionIndicator).styleName = this;
					}
					if(this.selectionIndicator is InteractiveObject)
					{
						InteractiveObject(this.selectionIndicator).mouseEnabled = false;
					}
					this.addChild(DisplayObject(this.selectionIndicator));
				}
			}
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(this.externalComponentChanged)
			{
				//update the horizontal and vertical ranges
				switch(this.externalComponent)
				{
					case HSBColor.HUE:
						this.verticalComponent = HSBColor.BRIGHTNESS;
						this.horizontalComponent = HSBColor.SATURATION;
						break;
					case HSBColor.SATURATION:
						this.verticalComponent = HSBColor.BRIGHTNESS;
						this.horizontalComponent = HSBColor.HUE;
						break;
					case HSBColor.BRIGHTNESS:
						this.verticalComponent = HSBColor.SATURATION;
						this.horizontalComponent = HSBColor.HUE;
						break;
					case RGBColor.RED:
						this.verticalComponent = RGBColor.GREEN;
						this.horizontalComponent = RGBColor.BLUE;
						break;
					case RGBColor.GREEN:
						this.verticalComponent = RGBColor.RED;
						this.horizontalComponent = RGBColor.BLUE;
						break;
					case RGBColor.BLUE:
						this.verticalComponent = RGBColor.GREEN;
						this.horizontalComponent = RGBColor.RED;
						break;
					case CMYColor.CYAN:
						this.verticalComponent = CMYColor.MAGENTA;
						this.horizontalComponent = CMYColor.YELLOW;
						break;
					case CMYColor.MAGENTA:
						this.verticalComponent = CMYColor.CYAN;
						this.horizontalComponent = CMYColor.YELLOW;
						break;
					case CMYColor.YELLOW:
						this.verticalComponent = CMYColor.MAGENTA;
						this.horizontalComponent = CMYColor.CYAN;
						break;
				}
				this.externalComponentChanged = false;
			}
			
			this.updateComponentBounds();
			
			if(this.selectionIndicator is IColorViewer)
			{
				IColorViewer(this.selectionIndicator).color = this.previewColor;
			}
		}
		
		/**
		 * @private
		 */
		override protected function measure():void
		{
			super.measure();
			this.measuredWidth = DEFAULT_MEASURED_WIDTH;
			this.measuredHeight = DEFAULT_MEASURED_HEIGHT;
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			this.border.setActualSize(unscaledWidth, unscaledHeight);
			
			var selectionIndicatorSize:Number = this.getStyle("selectionIndicatorSize");
			this.selectionIndicator.setActualSize(selectionIndicatorSize, selectionIndicatorSize);
			
			var metrics:EdgeMetrics = this.border is IBorder ? IBorder(this.border).borderMetrics : EdgeMetrics.EMPTY;
			
			var colorWidth:Number = unscaledWidth - metrics.left - metrics.right;
			var colorHeight:Number = unscaledHeight - metrics.top - metrics.bottom;
			
			//draw the external value color
			var baseColor:uint = 0x0000000;
			if(this.colorSpace != ColorSpace.HSB)
			{
				var color:IColor;
				switch(this.colorSpace)
				{
					case ColorSpace.RGB:
						color = new RGBColor();
						break;
					case ColorSpace.CMY:
						color = new CMYColor();
						break;
				}
				color[this.externalComponent] = this.externalValue;
				baseColor = color.touint();
			}
			this.graphics.clear();
			this.graphics.beginFill(baseColor, 1);
			this.graphics.drawRect(metrics.left, metrics.top, colorWidth, colorHeight);
			this.graphics.endFill();
			
			this.refreshGradients(colorWidth, colorHeight);
			
			
			this.horizontalColor.x = this.verticalColor.x = metrics.left;
			this.horizontalColor.y = this.verticalColor.y = metrics.top;
			
			//position the selection indicator
			var position:Point = this.getSelectionIndicatorPosition();
			
			if(!this.selectionIndicatorPositionInitialized)
			{
				this.selectionIndicator.x = position.x;
				this.selectionIndicator.y = position.y;
				this.selectionIndicatorPositionInitialized = true;
			}
			else
			{
				Animation.create(this.selectionIndicator, 150, {x: position.x, y: position.y});
			}
		}
		
		/**
		 * @private
		 * Redraws the gradients and alpha masks.
		 */
		protected function refreshGradients(colorWidth:Number, colorHeight:Number):void
		{
			var hMatrix:Matrix = new Matrix();
			hMatrix.createGradientBox(colorWidth, colorHeight);
			var vMatrix:Matrix = new Matrix();
			vMatrix.createGradientBox(colorWidth, colorHeight, -90 * Math.PI / 180);
			
			var hColors:Array = this.generateHorizontalColors();
			var hAlphas:Array = [];
			var hRatios:Array = [];
			var hColorCount:int = hColors.length;
			for(var i:int = 0; i < hColorCount; i++)
			{
				hAlphas[i] = 1;
				hRatios[i] = i * (255 / (hColorCount - 1));
			}
			this.horizontalGradient.graphics.clear();
			this.horizontalGradient.graphics.beginGradientFill(GradientType.LINEAR, hColors, hAlphas, hRatios, hMatrix);
			this.horizontalGradient.graphics.drawRect(0, 0, colorWidth, colorHeight);
			this.horizontalGradient.graphics.endFill(); 
	
			//actually drawn vertically, but it is for the horizontal gradient
			this.horizontalAlphaMask.graphics.clear();
			if(this.horizontalComponent != HSBColor.HUE)
			{
				if(this.verticalComponent == HSBColor.HUE)
				{
					this.horizontalAlphaMask.graphics.beginGradientFill(GradientType.LINEAR, [0xff0000, 0xff0000], [1, 0], [0, 0xff], hMatrix);
				}
				else
				{
					this.horizontalAlphaMask.graphics.beginGradientFill(GradientType.LINEAR, [0xff0000, 0xff0000], [0, 1], [0, 0xff], vMatrix);
				}
			}
			else
			{
				this.setChildIndex(this.horizontalColor, Math.min(this.getChildIndex(this.horizontalColor), this.getChildIndex(this.verticalColor)));
				this.horizontalAlphaMask.graphics.beginFill(0xff0000, 1);
			}
			this.horizontalAlphaMask.graphics.drawRect(0, 0, colorWidth, colorHeight);
			this.horizontalAlphaMask.graphics.endFill();
			
			var vColors:Array = this.generateVerticalColors();
			var vAlphas:Array = [];
			var vRatios:Array = [];
			var vColorCount:int = vColors.length;
			for(i = 0; i < vColorCount; i++)
			{
				vAlphas[i] = 1;
				vRatios[i] = i * (255 / (vColorCount - 1));
			}
			this.verticalGradient.graphics.clear();
			this.verticalGradient.graphics.beginGradientFill(GradientType.LINEAR, vColors, vAlphas, vRatios, vMatrix);
			this.verticalGradient.graphics.drawRect(0, 0, colorWidth, colorHeight);
			this.verticalGradient.graphics.endFill(); 
	
			//actually drawn horizontally, but it is for the vertical gradient
			this.verticalAlphaMask.graphics.clear();
			if(this.verticalComponent != HSBColor.HUE)
			{
				if(this.horizontalComponent == HSBColor.HUE)
				{
					var matrix:Matrix = new Matrix();
					matrix.createGradientBox(colorWidth, colorHeight, 90 * Math.PI / 180);
					this.verticalAlphaMask.graphics.beginGradientFill(GradientType.LINEAR, [0xff0000, 0xff0000], [0, 1], [0, 0xff], matrix);
				}
				else this.verticalAlphaMask.graphics.beginGradientFill(GradientType.LINEAR, [0xff0000, 0xff0000], [0, 1], [0, 0xff], hMatrix);
			}
			else
			{
				this.setChildIndex(this.verticalColor, Math.min(this.getChildIndex(this.horizontalColor), this.getChildIndex(this.verticalColor)));
				this.verticalAlphaMask.graphics.beginFill(0xff0000, 1);
			}
			this.verticalAlphaMask.graphics.drawRect(0, 0, colorWidth, colorHeight);
			this.verticalAlphaMask.graphics.endFill();
		}
		
		/**
		 * @private
		 * Determines which colors will be drawn in the horizontal direction.
		 */
		protected function generateHorizontalColors():Array
		{
			var colors:Array = [];
			if(this.horizontalComponent == HSBColor.HUE)
			{
				var interval:Number = this.horizontalMaximum / 6;
				for(var i:Number = this.horizontalMinimum; i <= this.horizontalMaximum; i+= interval)
				{
					colors.push(this.getHorizontalColorFromValue(i, true).touint());
				}
			}
			else
			{
				colors = [this.getHorizontalColorFromValue(this.horizontalMinimum, true).touint(), this.getHorizontalColorFromValue(this.horizontalMaximum, true).touint()];
			}
			
			return colors;
		}
		
		/**
		 * @private
		 * Determines the colors that will be drawn in the vertical direction.
		 */
		protected function generateVerticalColors():Array
		{
			var colors:Array = [];
			if(this.verticalComponent == HSBColor.HUE)
			{
				var interval:Number = this.verticalMaximum / 6;
				for(var i:Number = this.verticalMinimum; i <= this.verticalMaximum; i+= interval)
				{
					colors.push(this.getVerticalColorFromValue(i, true).touint());
				}
			}
			else
			{
				colors = [this.getVerticalColorFromValue(this.verticalMinimum, true).touint(), this.getVerticalColorFromValue(this.verticalMaximum, true).touint()];
			}
			return colors;
		}
		
		/**
		 * @private
		 * Determines the minimum and maximum values for each of the horizontal
		 * and vertical ranges.
		 */
		protected function updateComponentBounds():void
		{
			switch(this.horizontalComponent)
			{
				case HSBColor.HUE:
					this.horizontalMaximum = 360;
					break;
				case HSBColor.SATURATION:
				case HSBColor.BRIGHTNESS:
				case CMYColor.CYAN:
				case CMYColor.MAGENTA:
				case CMYColor.YELLOW:
					this.horizontalMaximum = 100;
					break;
				case RGBColor.RED:
				case RGBColor.GREEN:
				case RGBColor.BLUE:
					this.horizontalMaximum = 255;
					break;
			}
			switch(this.verticalComponent)
			{
				case HSBColor.HUE:
					this.verticalMaximum = 360;
					break;
				case HSBColor.SATURATION:
				case HSBColor.BRIGHTNESS:
				case CMYColor.CYAN:
				case CMYColor.MAGENTA:
				case CMYColor.YELLOW:
					this.verticalMaximum = 100;
					break;
				case RGBColor.RED:
				case RGBColor.GREEN:
				case RGBColor.BLUE:
					this.verticalMaximum = 255;
					break;
			}
			
		}
		
		protected function getSelectionIndicatorPosition():Point
		{
			var metrics:EdgeMetrics = this.border is IBorder ? IBorder(this.border).borderMetrics : EdgeMetrics.EMPTY;
			
			var colorWidth:Number = unscaledWidth - metrics.left - metrics.right;
			var colorHeight:Number = unscaledHeight - metrics.top - metrics.bottom;
			
			var horizontalPosition:Number = (this.horizontalValue - this.horizontalMinimum) / (this.horizontalMaximum - this.horizontalMinimum) * colorWidth;
			var verticalPosition:Number = colorHeight - (this.verticalValue - this.verticalMinimum) / (this.verticalMaximum - this.verticalMinimum) * colorHeight;
			
			var xPosition:Number = metrics.left + horizontalPosition - this.selectionIndicator.width / 2;
			var yPosition:Number = metrics.right + verticalPosition - this.selectionIndicator.height / 2;
			
			return new Point(xPosition, yPosition);
		}
		
		/**
		 * @private
		 * Determines the value of the horizontal range from the position of the
		 * selection indicator.
		 */
		protected function getHorizontalValueFromPosition(position:Number):Number
		{
			var metrics:EdgeMetrics = this.border is IBorder ? IBorder(this.border).borderMetrics : EdgeMetrics.EMPTY;
			var colorWidth:Number = unscaledWidth - metrics.left - metrics.right;
			position = Math.min(Math.max(metrics.left, position), metrics.left + colorWidth) - metrics.left;
			return this.horizontalMinimum + (this.horizontalMaximum - this.horizontalMinimum) * position / colorWidth; 
		}
		
		/**
		 * @private
		 * Determines the value of the vertical range from the position of the
		 * selection indicator.
		 */
		protected function getVerticalValueFromPosition(position:Number):Number
		{
			var metrics:EdgeMetrics = this.border is IBorder ? IBorder(this.border).borderMetrics : EdgeMetrics.EMPTY;
			var colorHeight:Number = unscaledHeight - metrics.top - metrics.bottom;
			
			position = Math.min(Math.max(metrics.top, position), metrics.top + colorHeight) - metrics.top;
			
			return this.verticalMinimum + (this.verticalMaximum - this.verticalMinimum) * (colorHeight - position) / colorHeight; 
		}
		
		/**
		 * @private
		 * Determines the a color on the horizontal range from the value.
		 */
		protected function getHorizontalColorFromValue(value:Number, resetForDraw:Boolean = false):IColor
		{
			var color:IColor = this.selectedColorFromColorSpace;
			if(resetForDraw)
			{
				color[this.verticalComponent] = this.verticalMaximum;
				if(this.colorSpace == ColorSpace.HSB && this.verticalComponent == HSBColor.HUE)
				{
					color[this.horizontalComponent] = this.horizontalMinimum;
					return color;
				}
			}
			
			color[this.horizontalComponent] = value;
			
			return color;
		}
		
		/**
		 * @private
		 * Refreshes the selected color based on the horizontal value.
		 */
		protected function updateHorizontalColorFromValue(value:Number):void
		{
			var color:IColor = this.getHorizontalColorFromValue(value);
			
			//setting selectedColor first resets all the other color spaces
			this.selectedColor = color.touint();
			
			//then we want to make sure we have the correct values for the current color space
			switch(this.colorSpace)
			{
				case ColorSpace.RGB:
					//do nothing
					break;
				case ColorSpace.HSB:
					this.selectedHSBColor = HSBColor(color);
					break;
				case ColorSpace.CMY:
					this.selectedCMYColor = CMYColor(color);
					break;
				default:
					throw new Error("Invalid Color Space: " + this.colorSpace);
			}
		}
		
		/**
		 * @private
		 * Determines the a color on the vertical range from the value.
		 */
		protected function getVerticalColorFromValue(value:Number, resetForDraw:Boolean = false):IColor
		{
			var color:IColor = this.selectedColorFromColorSpace;
			if(resetForDraw)
			{
				color[this.horizontalComponent] = this.horizontalMaximum;
			
				if(this.colorSpace == ColorSpace.HSB && this.horizontalComponent == HSBColor.HUE)
				{
					color[this.verticalComponent] = this.verticalMinimum;
					return color;
				}
			}
			color[this.verticalComponent] = value;
			return color;
		}
		
		/**
		 * @private
		 * Refreshes the selected color based on the vertical value.
		 */
		protected function updateVerticalColorFromValue(value:Number):void
		{
			var color:IColor = this.getVerticalColorFromValue(value);
			
			//setting selectedColor first resets all the other color spaces
			this.selectedColor = color.touint();
			
			//then we want to make sure we have the correct values for the current color space
			switch(this.colorSpace)
			{
				case ColorSpace.RGB:
					//do nothing
					break;
				case ColorSpace.HSB:
					this.selectedHSBColor = HSBColor(color);
					break;
				case ColorSpace.CMY:
					this.selectedCMYColor = CMYColor(color);
					break;
				default:
					throw new Error("Invalid Color Space: " + this.colorSpace);
			}
		}
		
		/**
		 * @private
		 * Determines the a color from the external value.
		 */
		protected function getExternalColorFromValue(value:Number):IColor
		{
			var color:IColor = this.selectedColorFromColorSpace;
			color[this.externalComponent] = value;
			return color;
		}
		
		/**
		 * @private
		 * Refreshes the selected color based on the external value.
		 */
		protected function updateExternalColorFromValue(value:Number):void
		{
			var color:IColor = this.getExternalColorFromValue(value);
			
			//setting selectedColor first resets all the other color spaces
			this.selectedColor = color.touint();
			
			//then we want to make sure we have the correct values for the current color space
			switch(this.colorSpace)
			{
				case ColorSpace.RGB:
					//do nothing
					break;
				case ColorSpace.HSB:
					this.selectedHSBColor = HSBColor(color);
					break;
				case ColorSpace.CMY:
					this.selectedCMYColor = CMYColor(color);
					break;
				default:
					throw new Error("Invalid Color Space: " + this.colorSpace);
			}
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
		
		/**
		 * @private
		 * Listens for mouse moves to update the preview color.
		 */
		protected function rollOverHandler(event:MouseEvent):void
		{
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler, false, 0, true);
		}
		
		/**
		 * @private
		 * Ends a drag operation if the mouse button is not down.
		 */
		protected function rollOutHandler(event:MouseEvent):void
		{
			if(!this.mouseButtonDown)
			{
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
			}
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OUT));
		}
		
		/**
		 * @private
		 * Starts a drag operation.
		 */
		protected function mouseDownHandler(event:MouseEvent):void
		{
			this.mouseButtonDown = true;
			
			var horizontalValue:Number = this.getHorizontalValueFromPosition(this.mouseX);
			var verticalValue:Number = this.getVerticalValueFromPosition(this.mouseY);
			this.updateHorizontalColorFromValue(horizontalValue);
			this.updateVerticalColorFromValue(verticalValue);
			
			this.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler, false, 0, true);
		}
		
		/**
		 * @private
		 * Updates a drag operation and notifies listeners. If live dragging is true, updates
		 * the selected color.
		 */
		protected function stageMouseMoveHandler(event:MouseEvent):void
		{
			var horizontalValue:Number = this.getHorizontalValueFromPosition(this.mouseX);
			var verticalValue:Number = this.getVerticalValueFromPosition(this.mouseY);
			
			if(this.mouseButtonDown)
			{
				this.updateHorizontalColorFromValue(horizontalValue);
				this.updateVerticalColorFromValue(verticalValue);
			
				//we don't want a delay here
				var position:Point = this.getSelectionIndicatorPosition();
				this.selectionIndicator.x = position.x;
				this.selectionIndicator.y = position.y;
				
				if(this.liveDragging)
				{
					this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, this.selectedColor));
				}
			}
			else
			{
				var color:IColor = this.selectedColorFromColorSpace.clone();
				color[this.horizontalComponent] = horizontalValue;
				color[this.verticalComponent] = verticalValue;
				this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OVER, false, false, -1, color.touint()));
			}
		}
		
		/**
		 * @private
		 * Stops a drag operation.
		 */
		protected function stageMouseUpHandler(event:MouseEvent):void
		{
			this.mouseButtonDown = false; 
			if(!this.hitTestPoint(this.stage.mouseX, this.stage.mouseY))
			{
				//we need to stop listening to movement here because we don't stop listening if the mouse button was down
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
			
				this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OUT));
			}
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
			
			var horizontalValue:Number = this.getHorizontalValueFromPosition(this.mouseX);
			var verticalValue:Number = this.getVerticalValueFromPosition(this.mouseY);
			this.updateHorizontalColorFromValue(horizontalValue);
			this.updateVerticalColorFromValue(verticalValue);
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, this.selectedColor));
		}
		
	}
}