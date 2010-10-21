/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
﻿package com.yahoo.astra.mx.controls.colorPickerClasses
{
	import com.yahoo.astra.utils.HSBColor;
	import com.yahoo.astra.utils.PointUtil;
	
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;

	/**
	 * The graphic representation of a color wheel displaying the HSB
	 * colorspace.
	 * 
	 * @see com.yahoo.astra.mx.controls.AdvancedHSBColorWheelPicker
	 * 
	 * @author Josh Tynjala
	 */
	public class HSBColorWheel2 extends UIComponent
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
	
		/**
		 * @private
		 * The default radius used for measurement.
		 */
		private static const DEFAULT_MEASURED_RADIUS:Number = 160;
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function HSBColorWheel2()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The sprite in which the wheel is drawn.
		 */
		protected var wheel:Sprite;
		
		/**
		 * @private
		 * The mask for the wheel (to make it round).
		 */
		protected var wheelMask:Shape;
		
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
			this.wheelMask.graphics.lineStyle(0, 0, 0);
			this.wheelMask.graphics.beginFill(0xff00ff, 1);
			this.wheelMask.graphics.drawCircle(0, 0, radius);
			this.wheelMask.graphics.endFill();
		}
		
		/**
		 * @private
		 * Draws the wheel based on HSB colors.
		 */
		protected function drawWheel(radius:Number):void
		{
			this.wheel.graphics.clear();
			var innerColorSize:Number = this.getStyle("innerColorSize");
			var outerColorSize:Number = this.getStyle("outerColorSize");
			var circumference:Number = 2 * Math.PI * radius;
			for(var i:Number = 0; i < circumference; i++)
			{
				var degrees:Number = 360 * i / circumference;
				var color1:HSBColor = new HSBColor(degrees, 0, 100);
				var color2:HSBColor = new HSBColor(degrees, 100, 100);
				var color3:HSBColor = new HSBColor(degrees, 100, 0);
				
				var radians:Number = degrees * Math.PI / 180;
				var perpendicular:Number = (degrees + 90) * Math.PI / 180;
				var position:Point = Point.polar(radius, radians);
				var offset:Point = Point.polar(0.5, perpendicular);
				
				var matrix:Matrix = new Matrix();
				matrix.createGradientBox(2 * radius, 2 * radius, radians, -radius, -radius);
				var innerColorSizeRatio:Number = 0xff * innerColorSize / radius;
				var outerColorSizeRatio:Number = 0xff * outerColorSize / radius;
				this.wheel.graphics.beginGradientFill(GradientType.RADIAL, [color1.touint(), color1.touint(), color2.touint(), color3.touint(), color3.touint()], [1, 1, 1, 1, 1],
					[0, innerColorSizeRatio, innerColorSizeRatio + ((0xff - outerColorSizeRatio) - innerColorSizeRatio) / 2, 0xff - outerColorSizeRatio, 0xff],
					matrix, SpreadMethod.PAD, InterpolationMethod.RGB);
				this.wheel.graphics.moveTo(0, 0);
				this.wheel.graphics.lineTo(position.x - offset.x, position.y - offset.y);
				this.wheel.graphics.lineTo(position.x + offset.x, position.y + offset.y);
				this.wheel.graphics.lineTo(0, 0);
				this.wheel.graphics.endFill();
			}
		}
	}
}