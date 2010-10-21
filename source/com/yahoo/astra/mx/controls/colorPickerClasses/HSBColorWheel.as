/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
﻿package com.yahoo.astra.mx.controls.colorPickerClasses
{
	import com.yahoo.astra.utils.HSBColor;
	
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.core.UIComponent;

	/**
	 * The graphic representation of a color wheel displaying the HSB
	 * colorspace.
	 * 
	 * @see com.yahoo.astra.mx.controls.ColorWheelPicker
	 * 
	 * @author Josh Tynjala
	 */
	public class HSBColorWheel extends UIComponent
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
	
		/**
		 * @private
		 * The default value for the measurement of the radius.
		 */
		private static const DEFAULT_MEASURED_RADIUS:Number = 120;
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function HSBColorWheel()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The wheel drawing.
		 */
		protected var wheel:Sprite;
		
		/**
		 * @private
		 * The mask to ensure that the wheel is round.
		 */
		protected var wheelMask:Shape;
		
		/**
		 * @private
		 * Storage for the externalComponent property.
		 */
		private var _externalComponent:String = HSBColor.BRIGHTNESS;
		
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
			if(this._externalComponent != value)
			{
				this._externalComponent = value;
				this.invalidateDisplayList();
			}
		}
		
		/**
		 * @private
		 * Storage for the externalValue property.
		 */
		private var _externalValue:Number = 1;
		
		/**
		 * The value of the externalComponent as it would appear in an HSBColor object.
		 * 
		 * @see com.yahoo.astra.utils.HSBColor
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
				this.invalidateDisplayList();
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
			
			this.wheel = new Sprite();
			this.addChild(this.wheel);
			
			this.wheelMask = new Shape();
			this.wheel.mask = this.wheelMask;
			this.wheel.addChild(this.wheelMask);
		}
		
		/**
		 * @private
		 */
		override protected function measure():void
		{
			super.measure();
			this.measuredWidth = this.measuredHeight = DEFAULT_MEASURED_RADIUS;
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var radius:Number = Math.min(unscaledWidth, unscaledHeight) / 2;
			
			this.drawWheel(radius);
			this.wheel.x = unscaledWidth / 2;
			this.wheel.y = unscaledHeight / 2;
			
			this.wheelMask.graphics.clear();
			if(radius > 0)
			{
				this.wheelMask.graphics.lineStyle(0, 0, 0);
				this.wheelMask.graphics.beginFill(0xff00ff, 1);
				this.wheelMask.graphics.drawCircle(0, 0, radius);
				this.wheelMask.graphics.endFill();
			}
		}
		
		/**
		 * @private
		 * Draws the wheel itself.
		 */
		protected function drawWheel(radius:Number):void
		{
			this.wheel.graphics.clear();
			if(radius == 0) return;
			var centerColorRadius:Number = this.getStyle("centerColorRadius");
			var circumference:Number = 2 * Math.PI * radius;
			for(var i:Number = 0; i < circumference; i++)
			{
				var hue:Number = 360 - 360 * i / circumference;
				var color1:HSBColor;
				var color2:HSBColor;
				if(this.externalComponent == HSBColor.SATURATION)
				{
					color1 = new HSBColor(hue, Math.max(0, this.externalValue), 0);
					color2 = new HSBColor(hue, this.externalValue, 100);
				}
				else //brightness
				{
					color1 = new HSBColor(hue, 0, this.externalValue);
					color2 = new HSBColor(hue, 100, this.externalValue);
				}
				
				var radians:Number = hue * Math.PI / 180;
				
				var position:Point = Point.polar(radius, radians);
				
				var perpendicular:Number = (hue - 90) * Math.PI / 180;
				var offset:Point = Point.polar(0.5, perpendicular);
				
				var matrix:Matrix = new Matrix();
				matrix.createGradientBox(2 * radius, 2 * radius, radians, -radius, -radius);
				wheel.graphics.beginGradientFill(GradientType.RADIAL, [color1.touint(), color1.touint(), color2.touint()], [1, 1, 1], [0, 0xff * centerColorRadius / radius, 0xff], matrix, SpreadMethod.PAD, InterpolationMethod.RGB);
				wheel.graphics.moveTo(0, 0);
				wheel.graphics.lineTo(position.x - offset.x, position.y - offset.y);
				wheel.graphics.lineTo(position.x + offset.x, position.y + offset.y);
				wheel.graphics.lineTo(0, 0);
				wheel.graphics.endFill();
			}
		}
	}
}