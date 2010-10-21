/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.utils
{
	/**
	 * Represents a value in the HSB (also known as HSV) color space.
	 */
	public class HSBColor implements IColor
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
	
		/**
		 * A constant representing the hue component of the HSB colorspace.
		 */
		public static const HUE:String = "hue";
		
		/**
		 * A constant representing the saturation component of the HSB colorspace.
		 */
		public static const SATURATION:String = "saturation";
		
		/**
		 * A constant representing the brightness component of the HSB colorspace.
		 */
		public static const BRIGHTNESS:String = "brightness";
			
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 * 
		 * @param hue			the initial hue value
		 * @param saturation	the initial saturation value
		 * @param brightness	the initial brightness value
		 */
		public function HSBColor(hue:Number = 0, saturation:Number = 0, brightness:Number = 0)
		{
			this.hue = hue;
			this.saturation = saturation;
			this.brightness = brightness;
		}
			
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * @private
		 * Storage for the hue property.
		 */
		private var _hue:Number;
		
		/**
		 * Represents the hue component of a value in the HSB color space.
		 */
		public function get hue():Number
		{
			return this._hue;
		}
		
		/**
		 * @private
		 */
		public function set hue(value:Number):void
		{
			this._hue = value;
		}
		
		/**
		 * @private
		 * Storage for the saturation property.
		 */
		private var _saturation:Number;
		
		/**
		 * Represents the saturation component of a value in the HSB color space.
		 */
		public function get saturation():Number
		{
			return this._saturation;
		}
		
		/**
		 * @private
		 */
		public function set saturation(value:Number):void
		{
			this._saturation = value;
		}
		
		/**
		 * @private
		 * Storage for the brightness property.
		 */
		private var _brightness:Number;
		
		/**
		 * Represents the brightness component of a value in the HSB color space.
		 */
		public function get brightness():Number
		{
			return this._brightness;
		}
		
		/**
		 * @private
		 */
		public function set brightness(value:Number):void
		{
			this._brightness = value;
		}
			
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		public function toString():String
		{
			return "{ hue: " + this.hue + ", saturation: " + this.saturation + ", brightness: " + this.brightness + " }";
		}
		
		/**
		 * @inheritDoc
		 */
		public function touint():uint
		{
			return ColorUtil.HSBTouint(this);
		}
		
		/**
		 * @inheritDoc
		 */
		public function clone():IColor
		{
			return new HSBColor(this.hue, this.saturation, this.brightness);
		}
	}
}