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
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.ISimpleStyleClient;
	import mx.styles.StyleManager;
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
	 * Two individual components of the HSB colorspace represented in a
	 * two-dimensional picker.
	 * 
	 * @see com.yahoo.astra.utils.HSBColor
	 * @author Josh Tynjala
	 */
	public class ColorWheelPicker extends UIComponent implements IColorPicker
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function ColorWheelPicker()
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
			centerColorRadius: "centerColorRadius"
		}
		
		/**
		 * @private
		 * The style filter for the colorWheel contro.
		 */
		protected function get colorWheelStyleFilter():Object
		{
			return this._colorWheelStyleFilter;
		} 
		
		/**
		 * @private
		 * Flag indicating if the selection indicator has been positioned
		 * at least once.
		 */
		protected var selectionIndicatorPositionInitialized:Boolean = false;
		
		/**
		 * @private
		 */
		private var _previewColor:uint = 0x000000;
		
		/**
		 * @private
		 * The preview color.
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
		 * Storage for the externalComponent property.
		 */
		private var _externalComponent:String = HSBColor.BRIGHTNESS;
		
		[Bindable]
		/**
		 * The color wheel supports the HSB colorspace, which has three
		 * components, but it can only modify two components, so it is assumed
		 * that one is modified externally. The other two components are
		 * automatically determined based on the specified external component.
		 * 
		 * @see com.yahoo.astra.utils.HSBColor
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
			if(!value) value = HSBColor.BRIGHTNESS;
			this._externalComponent = value;
			this.invalidateProperties();
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
		 * Flag indicating if the mouse button is down or not.
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
				this.colorWheel = new HSBColorWheel();
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
			
			var hsbColorWheel:HSBColorWheel = HSBColorWheel(this.colorWheel);
			hsbColorWheel.externalComponent = this.externalComponent;
			switch(this.externalComponent)
			{
				case HSBColor.BRIGHTNESS:
					hsbColorWheel.externalValue = this._selectedColor.brightness;
					break;
				case HSBColor.SATURATION:
					hsbColorWheel.externalValue = this._selectedColor.saturation;
					break;
			}
			
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
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var selectionIndicatorSize:Number = this.getStyle("selectionIndicatorSize");
			
			this.colorWheel.move(selectionIndicatorSize / 2, selectionIndicatorSize / 2);
			this.colorWheel.setActualSize(unscaledWidth - selectionIndicatorSize, unscaledHeight - selectionIndicatorSize);
			
			this.selectionIndicator.setActualSize(selectionIndicatorSize, selectionIndicatorSize);
			
			this.positionSelectionFromColor(this._selectedColor);
		}
		
		/**
		 * @private
		 * Using a color, position the selection indicator.
		 */
		protected function positionSelectionFromColor(color:HSBColor):void
		{
			var centerColorRadius:Number = this.getStyle("centerColorRadius");
			
			var center:Point = new Point(unscaledWidth / 2, unscaledHeight / 2);
			var radius:Number = Math.min(this.colorWheel.width, this.colorWheel.height) / 2;
			radius -= centerColorRadius;
			
			var degrees:Number = color.hue;
			var distance:Number = 0;
			switch(this.externalComponent)
			{
				case HSBColor.BRIGHTNESS:
					distance = color.saturation * radius / 100;
					break;
				case HSBColor.SATURATION:
					distance = color.brightness * radius / 100;
					break;
			}
			
			distance += centerColorRadius;
			
			var position:Point = center.clone();
			if((this.externalComponent == HSBColor.BRIGHTNESS && color.saturation != 0) ||
				(this.externalComponent == HSBColor.SATURATION && color.brightness != 0))
			{
				position = center.add(Point.polar(distance, degrees * Math.PI / 180));
			}
			//center it
			position.x -= this.selectionIndicator.width / 2;
			position.y -= this.selectionIndicator.height / 2;
			
			if(this.dropDownMode || !this.selectionIndicatorPositionInitialized)
			{
				this.selectionIndicator.x = position.x;
				this.selectionIndicator.y = position.y;
				this.selectionIndicatorPositionInitialized = true;
			}
			else Animation.create(this.selectionIndicator, 150, {x: position.x, y: position.y});
		}
		
		/**
		 * @private
		 * Determine the color at the specified position.
		 */
		protected function getColorFromPosition(position:Point):HSBColor
		{
			var centerColorRadius:Number = this.getStyle("centerColorRadius");
			
			var center:Point = new Point(this.colorWheel.width / 2, this.colorWheel.height / 2);
			var radius:Number = Math.min(center.x, center.y);
			
			var distance:Number = Point.distance(position, center);
			distance = Math.min(distance, radius);
			var degrees:Number = -PointUtil.angle(position, center) * 180 / Math.PI;
			
			if(degrees < 0) degrees += 360;
			degrees = 360 - degrees;
			
			radius -= centerColorRadius;
			distance -= centerColorRadius;
			
			var color:HSBColor = new HSBColor(degrees, 0, 0);
			switch(this.externalComponent)
			{
				case HSBColor.SATURATION:
					color.saturation = this.selectedHSBColor.saturation;
					color.brightness = Math.max(0, Math.min(100, 100 * distance / radius));
					break;
				case HSBColor.BRIGHTNESS:
					color.saturation = Math.max(0, Math.min(100, 100 * distance / radius));
					color.brightness = this.selectedHSBColor.brightness;
					break;
			}
			
			return color;
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
		
		/**
		 * @private
		 * When the mouse is over the color wheel, listen for move events from the stage.
		 */
		protected function colorWheelRollOverHandler(event:MouseEvent):void
		{
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler, false, 0, true);
		}
		
		/**
		 * @private
		 * Stop listening to move events if the mouse button is up on rollout.
		 */
		protected function colorWheelRollOutHandler(event:MouseEvent):void
		{
			if(!this.mouseButtonDown)
			{
				//if we aren't dragging, we can stop listening for movement
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
			}
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OUT));
		}
		
		/**
		 * @private
		 * Select a color if required and begin a drag operation. 
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
		 * Select a color if liveDragging is active.
		 */
		protected function stageMouseMoveHandler(event:MouseEvent):void
		{
			var color:HSBColor = this.getColorFromPosition(new Point(this.colorWheel.mouseX, this.colorWheel.mouseY));
			if(this.mouseButtonDown)
			{
				this.selectedHSBColor = color;
				
				if(this.liveDragging)
				{
					this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, this.selectedColor));
				}
				this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OVER, false, false, -1, this.selectedColor));
			}
			else
			{
				this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OVER, false, false, -1, color.touint()));
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
				//we need to stop listening to movement here because we don't stop listening if the mouse button was down
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
			}
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
			
			var color:HSBColor = this.getColorFromPosition(new Point(this.colorWheel.mouseX, this.colorWheel.mouseY));
			this.selectedHSBColor = color;
			
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, this.selectedColor)); 
		}
	}
}