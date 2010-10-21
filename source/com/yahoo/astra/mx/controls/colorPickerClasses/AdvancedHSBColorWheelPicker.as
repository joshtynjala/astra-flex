/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
﻿package com.yahoo.astra.mx.controls.colorPickerClasses
{
	import com.yahoo.astra.animation.Animation;
	import com.yahoo.astra.mx.core.yahoo_mx_internal;
	import com.yahoo.astra.utils.ColorUtil;
	import com.yahoo.astra.utils.HSBColor;
	import com.yahoo.astra.utils.PointUtil;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.events.ColorPickerEvent;
	import mx.events.FlexEvent;
	import mx.styles.ISimpleStyleClient;
	import mx.styles.StyleProxy;

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
	 * An advanced color wheel picker representing the HSB colorspace. The
	 * center value is white, the outer edge value is black. Hue is represented
	 * by the angle. Values from the center to half radius represent change in
	 * saturation from 0 to 100 (with brightness 100). Values from half radius
	 * to the outer edge represent change in brightness from 100 to 0 (with
	 * saturation 100).
	 * 
	 * <p>Though this color picker represents a large percentage of the HSB
	 * colorspace, some values are noticeably missing. In particular, one cannot
	 * pick shades of gray.</p>
	 * 
	 * @see com.yahoo.astra.mx.controls.ColorWheelPicker
	 * 
	 * @author Josh Tynjala
	 */
	public class AdvancedHSBColorWheelPicker extends UIComponent implements IColorPicker
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function AdvancedHSBColorWheelPicker()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The color wheel.
		 */
		protected var colorWheel:IFlexDisplayObject;
		
		/**
		 * The selection indicator.
		 */
		protected var selectionIndicator:IFlexDisplayObject;
		
		/**
		 * @private
		 * Storage for the colorWheelStyleFilter property.
		 */
		private var _colorWheelStyleFilter:Object =
		{
			innerColorSize: "innerColorSize",
			outerColorSize: "outerColorSize"
		}
		
		/**
		 * @private
		 * The style filter for the color wheel.
		 */
		protected function get colorWheelStyleFilter():Object
		{
			return this._colorWheelStyleFilter;
		} 
		
		/**
		 * @private
		 * Flag that indicates whether the selection indicator has been
		 * positioned at least once.
		 */
		protected var selectionIndicatorPositionInitialized:Boolean = false;
		
		/**
		 * @private
		 * Storage for the preview color.
		 */
		private var _previewColor:uint = 0x000000;
		
		/**
		 * @private
		 * The current previewed color.
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
		 * Storage for the selectedColor property.
		 */
		private var _selectedColor:HSBColor = new HSBColor(0, 100, 100);
		
		[Bindable("valueCommit")]
		/**
		 * @inheritDoc
		 */
		public function get selectedColor():uint
		{
			return this._selectedColor.touint();
		}
		
		/**
		 * @private
		 */
		public function set selectedColor(value:uint):void
		{
			this.selectedHSBColor = ColorUtil.uintToHSB(value);
		}
		
		/**
		 * @private
		 * The currently selected HSB color. Meant for internal usage
		 * by recursive color pickers to avoid color information loss.
		 */
		yahoo_mx_internal function get selectedHSBColor():HSBColor
		{
			return this._selectedColor;
		}
		
		/**
		 * @private
		 */
		yahoo_mx_internal function set selectedHSBColor(value:HSBColor):void
		{
			this._selectedColor = value;
			this.previewColor = value.touint();
			this.invalidateProperties();
			this.invalidateDisplayList();
			this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
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
		 * Storage for the dropDownMode property.
		 */
		private var _dropDownMode:Boolean = false;
		
		[Bindable]
		/**
		 * If true, the selection indicator will automatically follow the mouse.
		 */
		public function get dropDownMode():Boolean
		{
			return this._dropDownMode;
		}
		
		/**
		 * @private
		 */
		public function set dropDownMode(value:Boolean):void
		{
			this._dropDownMode = value;
		}
		
		/**
		 * @private
		 * Flag indicating whether the mouse button is down. Used for
		 * drop down mode.
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
			
			if(!this.colorWheel)
			{
				this.colorWheel = new HSBColorWheel2();
				if(this.colorWheel is ISimpleStyleClient)
				{
					ISimpleStyleClient(this.colorWheel).styleName = new StyleProxy(this, this.colorWheelStyleFilter);
				}
				this.colorWheel.addEventListener(MouseEvent.MOUSE_DOWN, colorWheelMouseDownHandler);
				this.colorWheel.addEventListener(MouseEvent.ROLL_OVER, colorWheelRollOverHandler);
				this.colorWheel.addEventListener(MouseEvent.ROLL_OUT, colorWheelRollOutHandler);
				this.addChild(DisplayObject(this.colorWheel));
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
			
			var selectionIndicatorSize:Number = this.getStyle("selectionIndicatorSize");
			this.measuredWidth = this.colorWheel.measuredWidth + selectionIndicatorSize;
			this.measuredHeight = this.colorWheel.measuredHeight + selectionIndicatorSize;
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			//don't call this. we'll redraw everything ourselves!
			//super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var selectionIndicatorSize:Number = this.getStyle("selectionIndicatorSize");
			
			this.colorWheel.move(selectionIndicatorSize / 2, selectionIndicatorSize / 2);
			this.colorWheel.setActualSize(unscaledWidth - selectionIndicatorSize, unscaledHeight - selectionIndicatorSize);
			
			this.selectionIndicator.setActualSize(selectionIndicatorSize, selectionIndicatorSize);
			
			if(!this.dropDownMode || !this.selectionIndicatorPositionInitialized)
			{
				this.positionSelectionFromColor(this.selectedHSBColor);
			}
		}
		
		/**
		 * @private
		 * Determines the position of the selection indicator based on a color
		 * value.
		 */
		protected function positionSelectionFromColor(color:HSBColor):void
		{
			var innerColorSize:Number = this.getStyle("innerColorSize");
			var outerColorSize:Number = this.getStyle("outerColorSize");
			
			var center:Point = new Point(unscaledWidth / 2, unscaledHeight / 2);
			var radius:Number = Math.min(this.colorWheel.width, this.colorWheel.height) / 2;
			radius -= (innerColorSize + outerColorSize);
			var halfRadius:Number = radius / 2;
			
			var degrees:Number = color.hue;
			var distance:Number = 0;
			
			var colorFound:Boolean = false;
			if(color.brightness == 100)
			{
				distance = color.saturation * halfRadius / 100;
				colorFound = true;
			}
			else if(color.brightness == 0 || color.saturation == 100)
			{
				distance = (100 - color.brightness) * halfRadius / 100;
				distance += halfRadius;
				colorFound = true;
			}
			distance += innerColorSize;
			
			var position:Point = center.clone();
			//if color found and not white
			if(colorFound)
			{
				if(color.touint() == 0x000000)
				{
					position = Point.polar(distance + outerColorSize / 2, degrees * Math.PI / 180).add(center);
				}
				else if(color.touint() != 0xffffff)
				{
					position = Point.polar(distance, degrees * Math.PI / 180).add(center);
				}
			}
			position.x -= this.selectionIndicator.width / 2;
			position.y -= this.selectionIndicator.height / 2;
			
			if(!this.selectionIndicatorPositionInitialized)
			{
				this.selectionIndicator.x = position.x;
				this.selectionIndicator.y = position.y;
				this.selectionIndicatorPositionInitialized = true;
			}
			else Animation.create(this.selectionIndicator, 150, {x: position.x, y: position.y});
		}
		
		/**
		 * @private
		 * Determines the color at a specific position.
		 */
		protected function getColorFromPosition(position:Point):HSBColor
		{
			var innerColorSize:Number = this.getStyle("innerColorSize");
			var outerColorSize:Number = this.getStyle("outerColorSize");
			var center:Point = new Point(this.colorWheel.width / 2, this.colorWheel.height / 2);
			var radius:Number = Math.min(center.x, center.y);
			
			var distance:Number = Point.distance(position, center);
			distance = Math.min(distance, radius);
			var degrees:Number = -PointUtil.angle(position, center) * 180 / Math.PI;
			
			if(degrees < 0) degrees += 360;
			degrees = 360 - degrees;
			
			radius -= (innerColorSize + outerColorSize);
			distance -= innerColorSize;
			
			var color:HSBColor = new HSBColor(degrees, 0, 0);
			var halfRadius:Number = radius / 2;
			if(distance <= halfRadius)
			{
				color.saturation = Math.max(0, Math.min(100, 100 * distance / halfRadius));
				color.brightness = 100;
			}
			else
			{
				distance -= halfRadius;
				color.saturation = 100;
				color.brightness = Math.max(0, Math.min(100, 100 * (halfRadius - distance) / halfRadius));
			}
			
			return color;
		}
		
		/**
		 * @private
		 * Handles rollover events from the color wheel.
		 */
		protected function colorWheelRollOverHandler(event:MouseEvent):void
		{
			var color:HSBColor = this.getColorFromPosition(new Point(this.colorWheel.mouseX, this.colorWheel.mouseY));
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OVER, false, false, -1, color.touint()));
			
			//because we're already listening if dropDownMode == true
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler, false, 0, true);
		}
		
		/**
		 * @private
		 * Handles rollout events from the color wheel.
		 */
		protected function colorWheelRollOutHandler(event:MouseEvent):void
		{
			if(!this.mouseButtonDown)
			{
				//if we aren't dragging, we can stop listening for movement
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
			}
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OUT));
			
				
			if(this.dropDownMode)
			{
				this.previewColor = this.selectedHSBColor.touint();
				this.positionSelectionFromColor(this.selectedHSBColor);
			}
		}
		
		/**
		 * @private
		 * Handles mouse down events from the color wheel. Updates selectedColor
		 * if live dragging is enabled.
		 */
		protected function colorWheelMouseDownHandler(event:MouseEvent):void
		{
			var color:HSBColor = this.getColorFromPosition(new Point(this.colorWheel.mouseX, this.colorWheel.mouseY));
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OVER, false, false, -1, color.touint()));
			
			this.mouseButtonDown = true;
			
			if(this.liveDragging)
			{
				this.selectedHSBColor = color;
				this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, this.selectedColor)); 
			}
			
			this.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler, false, 0, true);
		}
		
		/**
		 * @private
		 * Handles mouse move events from the color wheel. Updates selectedColor
		 * if live dragging is enabled.
		 */
		protected function stageMouseMoveHandler(event:MouseEvent):void
		{
			var color:HSBColor = this.getColorFromPosition(new Point(this.colorWheel.mouseX, this.colorWheel.mouseY));
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OVER, false, false, -1, color.touint()));
			
			//if we're dragging the selection indicator
			if(this.mouseButtonDown)
			{
				this.selectedHSBColor = color;
				if(this.liveDragging)
				{
					this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, this.selectedColor));
				}
			}
				
			if(this.dropDownMode)
			{
				this.previewColor = color.touint();
				this.positionSelectionFromColor(color);
			}
		}
		
		/**
		 * @private
		 * Updates the selected color. Only handled when the user releases the mouse button after pressing it down over the color wheel.
		 */
		protected function stageMouseUpHandler(event:MouseEvent):void
		{
			this.mouseButtonDown = false;
			
			if(!this.colorWheel.hitTestPoint(this.stage.mouseX, this.stage.mouseY))
			{
				//if we're outside the bounds of the color wheel, we need to stop listening to movement
				//because we don't stop listening if the mouse button is down on rollout
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
			}
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
			
			var color:HSBColor = this.getColorFromPosition(new Point(this.colorWheel.mouseX, this.colorWheel.mouseY));
			this.selectedHSBColor = color;
			
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, this.selectedColor)); 
		}
	}
}