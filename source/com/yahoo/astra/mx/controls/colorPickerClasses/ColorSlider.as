/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls.colorPickerClasses
{
	import com.yahoo.astra.animation.Animation;
	import com.yahoo.astra.mx.core.yahoo_mx_internal;
	import com.yahoo.astra.utils.CMYColor;
	import com.yahoo.astra.utils.CMYKColor;
	import com.yahoo.astra.utils.ColorSpace;
	import com.yahoo.astra.utils.ColorUtil;
	import com.yahoo.astra.utils.HSBColor;
	import com.yahoo.astra.utils.RGBColor;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	import mx.controls.Button;
	import mx.core.EdgeMetrics;
	import mx.core.IFlexDisplayObject;
	import mx.core.IRectangularBorder;
	import mx.core.UIComponent;
	import mx.events.ColorPickerEvent;
	import mx.events.FlexEvent;
	import mx.skins.RectangularBorder;
	import mx.styles.ISimpleStyleClient;
	import mx.styles.StyleProxy;
	
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
	 * A slider that represents the value of one individual component in a
	 * colorspace.
	 * 
	 * @author Josh Tynjala
	 */
	public class ColorSlider extends UIComponent
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
		
		/**
		 * @private
		 * The default measured size of a color slider. 
		 */
		private static const DEFAULT_MEASURED_SIZE:Number = 36;
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function ColorSlider()
		{
			super();
			this.selectedColor = 0xff0000;
			this.addEventListener(MouseEvent.CLICK, mouseClickHandler);
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			this.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The border of the color slider.
		 */
		protected var border:IFlexDisplayObject;
		
		/**
		 * The first thumb button.
		 */
		protected var thumb1:Button;
		
		/**
		 * The second thumb button.
		 */
		protected var thumb2:Button;
		
		/**
		 * @private
		 * The class used to instantiate the thumbs.
		 */
		protected var thumbClass:Class = ColorSliderThumb;
		
		/**
		 * @private
		 * Storage for the thumbStyleFilter object.
		 */
		private var _thumbStyleFilter:Object =
		{
			"thumbSkin" : "skin"
		}
		
		/**
		 * @private
		 * The style filter for the thumb controls.
		 */
		protected function get thumbStyleFilter():Object
		{
			return this._thumbStyleFilter;
		}
		
		/**
		 * @private
		 * Flag indicating whether the thumbs have been positioned at least once.
		 */
		protected var thumbsInitialized:Boolean = false;
		
		/**
		 * @private
		 * Flag indicating whether a thumb is being dragged by the mouse.
		 */
		protected var isDraggingThumb:Boolean = false;
		
		/**
		 * @private
		 * The offset in pixels from the thumb to the mouse.
		 */
		protected var thumbMouseOffset:Number = 0;
		
		/**
		 * @private
		 * The minimum value of the slider.
		 */
		protected var minimum:Number = 0;
		
		/**
		 * @private
		 * The maximum value of the slider.
		 */
		protected var maximum:Number = 100;
		
		/**
		 * @private
		 * Storage for the selectedValue property.
		 */
		private var _selectedValue:Number = 0;
		
		/**
		 * @private
		 * The currently selected value (of the current colorspace component).
		 */
		public function get selectedValue():Number
		{
			return this._selectedValue;
		}
		
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
			this._selectedHSBColor = ColorUtil.uintToHSB(this._selectedColor);
			this._selectedCMYKColor = ColorUtil.uintToCMYK(this._selectedColor);
			this._selectedCMYColor = ColorUtil.uintToCMY(this._selectedColor);
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
			this.invalidateDisplayList();
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
			this.invalidateDisplayList();
			this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
		
		/**
		 * @private
		 * Storage for the colorSpace property.
		 */
		private var _colorSpace:String = ColorSpace.HSB;
		
		[Bindable]
		/**
		 * The color space specifies how many sliders will be displayed
		 * and which component each slider will represent.
		 * 
		 * @see com.yahoo.astra.utils.ColorSpace
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
				this.invalidateDisplayList();
			}
		}
		
		/**
		 * @private
		 * Storage for the component property.
		 */
		private var _component:String = HSBColor.HUE;
		
		[Bindable]
		/**
		 * The currently displayed and editable component of the chosen color space.
		 * 
		 * @see com.yahoo.astra.utils.ColorSpace
		 * @see com.yahoo.astra.utils.RGBColor
		 * @see com.yahoo.astra.utils.HSBColor
		 * @see com.yahoo.astra.utils.CMYColor
		 * @see com.yahoo.astra.utils.CMYKColor
		 */
		public function get component():String
		{
			return this._component;
		}
		
		/**
		 * @private
		 */
		public function set component(value:String):void
		{
			if(this._component != value)
			{
				this._component = value;
				this.invalidateProperties();
				this.invalidateDisplayList();
			}
		}
		
		/**
		 * @private
		 * Flag indicating that the direction has changed.
		 */
		protected var directionChanged:Boolean = false;
		
		/**
		 * @private
		 * Storage for the direction property.
		 */
		private var _direction:String = "horizontal";
		
    	[Inspectable(defaultValue="horizontal",enumeration="horizontal,vertical")]
		[Bindable]
		/**
		 * The direction of the slider. May be "horizontal" or "vertical".
		 */
		public function get direction():String
		{
			return this._direction;
		}
		
		/**
		 * @private
		 */
		public function set direction(value:String):void
		{
			if(this._direction != value)
			{
				this._direction = value;
				this.directionChanged = true;
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
			
			if(!this.thumb1)
			{
				this.thumb1 = new this.thumbClass();
				this.thumb1.styleName = new StyleProxy(this, thumbStyleFilter);
				this.thumb1.addEventListener(MouseEvent.MOUSE_DOWN, thumbMouseDownHandler);
				this.addChild(this.thumb1);
			}
			
			if(!this.thumb2)
			{
				this.thumb2 = new this.thumbClass();
				this.thumb2.styleName = new StyleProxy(this, thumbStyleFilter);
				this.thumb2.addEventListener(MouseEvent.MOUSE_DOWN, thumbMouseDownHandler);
				this.addChild(this.thumb2);
			}
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			switch(this.component)
			{
				case HSBColor.HUE:
					this.maximum = 360;
					break;
				case HSBColor.SATURATION:
				case HSBColor.BRIGHTNESS:
				case CMYColor.CYAN:
				case CMYColor.MAGENTA:
				case CMYColor.YELLOW:
				case CMYKColor.KEY:
					this.maximum = 100;
					break;
				case RGBColor.RED:
				case RGBColor.GREEN:
				case RGBColor.BLUE:
					this.maximum = 255;
					break;
			}
		}
		
		/**
		 * @private
		 */
		override protected function measure():void
		{
			super.measure();
			if(this.direction == "vertical")
			{
				this.measuredWidth = DEFAULT_MEASURED_SIZE;
				this.measuredHeight = DEFAULT_MEASURED_WIDTH;
			}
			else
			{
				this.measuredWidth = DEFAULT_MEASURED_WIDTH;
				this.measuredHeight = DEFAULT_MEASURED_SIZE;
			}
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			this.graphics.clear();
			
			var thumbSize:Number = this.getStyle("thumbSize");
			//keep the aspect ratio
			var oppositeSize:Number = (this.thumb1.measuredWidth / this.thumb1.measuredHeight) * thumbSize;
			
			if(this.direction == "vertical")
			{
				this.thumb1.setActualSize(oppositeSize, Math.min(thumbSize, unscaledWidth / 2));
				this.thumb1.x = this.thumb1.height;
				if(this.directionChanged)
				{
					this.thumb1.y = 0;
					this.directionChanged = false;
				}
				this.thumb1.rotation = 90;
				this.thumb1.setStyle("invertThumbDirection", false);
				
				this.thumb2.setActualSize(oppositeSize, Math.min(thumbSize, unscaledWidth / 2));
				this.thumb2.x = unscaledWidth;
				if(this.directionChanged)
				{
					this.thumb2.y = 0;
					this.directionChanged = false;
				}
				this.thumb2.rotation = 90;
				this.thumb2.setStyle("invertThumbDirection", true);
			}
			else
			{
				this.thumb1.setActualSize(oppositeSize, Math.min(thumbSize, unscaledHeight / 2));
				if(this.directionChanged)
				{
					this.thumb1.x = 0;
					this.directionChanged = false;
				}
				this.thumb1.y = 0;
				this.thumb1.rotation = 0;
				this.thumb1.setStyle("invertThumbDirection", true);
				
				this.thumb2.setActualSize(oppositeSize, Math.min(thumbSize, unscaledHeight / 2));
				if(this.directionChanged)
				{
					this.thumb2.x = 0;
					this.directionChanged = false;
				}
				this.thumb2.y = unscaledHeight - this.thumb2.height;
				this.thumb2.rotation = 0;
				this.thumb2.setStyle("invertThumbDirection", false);
			}

			this.drawGradient();
			
			this.positionThumbs();
		}
		
		/**
		 * @private
		 * Draws the gradient for the appropriate colorspace component.
		 */
		protected function drawGradient():void
		{
			var metrics:EdgeMetrics = new EdgeMetrics();
			if(this.direction == "vertical")
			{
				metrics.left = this.thumb1.width;
				metrics.right = this.thumb2.width;
			}
			else
			{
				metrics.top = this.thumb1.width;
				metrics.bottom = this.thumb2.width;
			}
			
			if(this.border)
			{
				this.border.x = metrics.left;
				this.border.y = metrics.top;
				this.border.setActualSize(unscaledWidth - metrics.left - metrics.right, unscaledHeight - metrics.top - metrics.bottom);
				if(this.border is IRectangularBorder)
				{
					var rectBorder:IRectangularBorder = IRectangularBorder(this.border);
					metrics.left += rectBorder.borderMetrics.left;
					metrics.right += rectBorder.borderMetrics.right;
					metrics.top += rectBorder.borderMetrics.top;
					metrics.bottom += rectBorder.borderMetrics.bottom;
				}
			}
			
			var gradientWidth:Number = unscaledWidth - metrics.left - metrics.right;
			var gradientHeight:Number = unscaledHeight - metrics.top - metrics.bottom;
			
			var rotation:Number = 0;
			if(this.direction == "vertical")
			{
				rotation = 90 * Math.PI / 180;
			}
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(gradientWidth, gradientHeight, rotation);
			
			var colors:Array = this.generateColors();
			
			var alphas:Array = [];
			var ratios:Array = [];
			var colorCount:int = colors.length;
			for(var i:int = 0; i < colorCount; i++)
			{
				alphas[i] = 1;
				ratios[i] = i * (255 / (colorCount - 1));
			}
			this.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
			this.graphics.drawRect(metrics.left, metrics.top, gradientWidth, gradientHeight);
			this.graphics.endFill();
		}
		
		/**
		 * @private
		 * Determines the colors required by the current colorspace component.
		 */
		protected function generateColors():Array
		{
			var colors:Array = [];
			if(this.component == HSBColor.HUE)
			{
				var interval:Number = this.maximum / 6;
				for(var i:Number = this.minimum; i <= this.maximum; i+= interval)
				{
					colors.push(this.getColorFromValue(i));
				}
			}
			else
			{
				colors = [this.getColorFromValue(this.minimum), this.getColorFromValue(this.maximum)];
			}
			
			//we want the "maximum" color on top
			if(this.direction == "vertical")
			{
				colors = colors.reverse();
			}
			return colors;
		}
		
		/**
		 * @private
		 * Positions the drag thumbs based on the selected color.
		 */
		protected function positionThumbs():void
		{
			var value:Number = 0;
			
			switch(this.colorSpace)
			{
				case ColorSpace.RGB:
					var rgb:RGBColor = ColorUtil.uintToRGB(this._selectedColor);
					value = rgb[this.component];
					break;
				case ColorSpace.HSB:
					value = this.selectedHSBColor[this.component];
					break;
				case ColorSpace.CMY:
					value = this.selectedCMYColor[this.component];
					break;
				case ColorSpace.CMYK:
					value = this.selectedCMYKColor[this.component];
					break;
				default:
					throw new Error("Invalid Color Space: " + this.colorSpace);
			}
			
			var metrics:EdgeMetrics = this.getMetrics();
			var position:Number = (value - this.minimum) / (this.maximum - this.minimum);
			if(this.direction == "vertical")
			{
				position = 1 - position;
				position = position * (unscaledHeight - metrics.top - metrics.bottom);
				
				var yPosition:Number = metrics.top - (thumb1.width / 2) + position;
				if(this.isDraggingThumb || !this.thumbsInitialized)
				{
					this.thumb1.y = this.thumb2.y = yPosition;
					this.thumbsInitialized = true;
				}
				else
				{
					Animation.create(this.thumb1, 250, {y: yPosition});
					Animation.create(this.thumb2, 250, {y: yPosition});
				}
				
			}
			else
			{
				position = position * (unscaledWidth - metrics.left - metrics.right);
				var xPosition:Number = metrics.left - (thumb1.width / 2) + position;
				if(this.isDraggingThumb || !this.thumbsInitialized)
				{
					this.thumb1.x = this.thumb2.x = xPosition;
					this.thumbsInitialized = true;
				}
				else
				{
					Animation.create(this.thumb1, 250, {x: xPosition});
					Animation.create(this.thumb2, 250, {x: xPosition});
				}
			}
			
		}
		
		/**
		 * @private
		 * Determines the edge metrics created by the thumbs.
		 */
		protected function getMetrics():EdgeMetrics
		{
			var metrics:EdgeMetrics = new EdgeMetrics();
			if(this.direction == "vertical")
			{
				metrics.left = this.thumb1.width;
				metrics.right = this.thumb2.width;
			}
			else
			{
				metrics.top = this.thumb1.width;
				metrics.bottom = this.thumb2.width;
			}
			
			if(this.border is IRectangularBorder)
			{
				var rectBorder:IRectangularBorder = IRectangularBorder(this.border);
				metrics.left += rectBorder.borderMetrics.left;
				metrics.right += rectBorder.borderMetrics.right;
				metrics.top += rectBorder.borderMetrics.top;
				metrics.bottom += rectBorder.borderMetrics.bottom;
			}
			return metrics;
		}
		
		/**
		 * @private
		 * Based on a value, determines the color.
		 */
		protected function getColorFromValue(value:Number):uint
		{
			switch(this.colorSpace)
			{
				case ColorSpace.RGB:
					var rgb:RGBColor = ColorUtil.uintToRGB(this.selectedColor);
					rgb[this.component] = value;
					return rgb.touint();
					break;
				case ColorSpace.HSB:
					var hsb:HSBColor = HSBColor(this._selectedHSBColor.clone());
					hsb[this.component] = value;
					return hsb.touint();
					break;
				case ColorSpace.CMY:
					var cmy:CMYColor = CMYColor(this._selectedCMYColor.clone());
					cmy[this.component] = value;
					return cmy.touint();
					break;
				case ColorSpace.CMYK:
					var cmyk:CMYKColor = CMYKColor(this._selectedCMYKColor.clone());
					cmyk[this.component] = value;
					return cmyk.touint();
					break;
				default:
					throw new Error("Invalid Color Space: " + this.colorSpace);
			}
		}
		
		/**
		 * @private
		 * Updates the selected color from a value for the current colorspace component.
		 */
		protected function updateColorFromValue(value:Number):void
		{
			switch(this.colorSpace)
			{
				case ColorSpace.RGB:
					var rgb:RGBColor = ColorUtil.uintToRGB(this.selectedColor);
					rgb[this.component] = value;
					this.selectedColor = rgb.touint();
					break;
				case ColorSpace.HSB:
					var hsb:HSBColor = HSBColor(this._selectedHSBColor.clone());
					hsb[this.component] = value;
					this.selectedColor = hsb.touint();
					this.selectedHSBColor = hsb;
					break;
				case ColorSpace.CMY:
					var cmy:CMYColor = CMYColor(this._selectedCMYColor.clone());
					cmy[this.component] = value;
					this.selectedColor = cmy.touint();
					this.selectedCMYColor = cmy;
					break;
				case ColorSpace.CMYK:
					var cmyk:CMYKColor = CMYKColor(this._selectedCMYKColor.clone());
					cmyk[this.component] = value;
					this.selectedColor = cmyk.touint();
					this.selectedCMYKColor = cmyk;
					break;
				default:
					throw new Error("Invalid Color Space: " + this.colorSpace);
			}
			this._selectedValue = value;
		}
		
		/**
		 * @private
		 * Determines a value from a position.
		 */
		protected function getValueFromPosition(position:Number):Number
		{	
			var metrics:EdgeMetrics = this.getMetrics();
			
			if(this.direction == "vertical")
			{ 
				position -= metrics.top;
				position = position / (unscaledHeight - metrics.top - metrics.bottom)
				position = Math.min(Math.max(position, 0), 1);
				position = 1 - position;
			}
			else
			{
				position -= metrics.left;
				position = position / (unscaledWidth - metrics.left - metrics.right)
				position = Math.min(Math.max(position, 0), 1);
			}
			
			return position * (this.maximum - this.minimum) + this.minimum;
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
		
		/**
		 * @private
		 * Refreshes the value on a mouse click.
		 */
		protected function mouseClickHandler(event:MouseEvent):void
		{
			if(event.target != this)
			{
				return;
			}
			
			var value:Number = this.minimum;
			if(this.direction == "vertical")
			{
				value = this.getValueFromPosition(this.mouseY);
			}
			else
			{
				value = this.getValueFromPosition(this.mouseX);
			}
			
			this.updateColorFromValue(value);
			//we're storing the HSB color, not a uint, so we need to pass it to the variable to save all the HSB data.
			//as a result, we need to do all the setter stuff manually
			this.invalidateDisplayList();
			this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, this.selectedColor));
		}
		
		/**
		 * @private
		 * Handles mouse moves as rollovers.
		 */
		protected function mouseMoveHandler(event:MouseEvent):void
		{
			if(event.target != this)
			{
				return;
			}
			
			var position:Number = this.mouseX;
			if(this.direction == "vertical")
			{
				position = this.mouseY;
			}
			var value:Number = this.getValueFromPosition(position);
			var color:uint = this.getColorFromValue(value);
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OVER, false, false, -1, color));
		}
		
		/**
		 * @private
		 * Handles rollouts.
		 */
		protected function mouseOutHandler(event:MouseEvent):void
		{
			if(event.target != this)
			{
				return;
			}
			
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OUT));
		}
		
		/**
		 * @private
		 * Mouse down events on the track initiate dragging.
		 */
		protected function mouseDownHandler(event:MouseEvent):void
		{
			this.isDraggingThumb = true;
			this.thumbMouseOffset = 0;
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler, false, 0, true);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler, false, 0, true);
		}
		
		/**
		 * @private
		 * Initiates thumb dragging.
		 */
		protected function thumbMouseDownHandler(event:MouseEvent):void
		{
			this.isDraggingThumb = true;
			var thumb:ColorSliderThumb = ColorSliderThumb(event.target);
			if(this.direction == "vertical")
			{
				this.thumbMouseOffset = thumb.mouseY - thumb.height / 2;
			}
			else
			{
				this.thumbMouseOffset = thumb.mouseX - thumb.width / 2;
			}
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler, false, 0, true);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler, false, 0, true);
		}
		
		/**
		 * @private
		 * Updates the value on drag.
		 */
		protected function stageMouseMoveHandler(event:MouseEvent):void
		{
			var value:Number = this.minimum;
			if(this.direction == "vertical")
			{
				value = this.getValueFromPosition(this.mouseY - this.thumbMouseOffset);
			}
			else
			{
				value = this.getValueFromPosition(this.mouseX - this.thumbMouseOffset);
			}
			this.updateColorFromValue(value);
			this.invalidateDisplayList();
			this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OVER, false, false, -1, this.selectedColor));
			
			if(this.liveDragging)
			{
				this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, this.selectedColor));
			}
		}
		
		/**
		 * @private
		 * Updates the selected color on mouse up.
		 */
		protected function stageMouseUpHandler(event:MouseEvent):void
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
			this.isDraggingThumb = false;
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, this.selectedColor));
		}
	}
}