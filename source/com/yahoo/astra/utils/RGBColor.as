/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.utils
{
	/**
	 * Represents a value in the standard 24-bit RGB color space.
	 * 
	 * @author Josh Tynjala
	 */
	public class RGBColor implements IColor
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
	
		/**
		 * @private
		 * An error message that is thrown when an input color value is not in the range of 0 - 255
		 */
		private static const COLOR_RANGE_ERROR_MESSAGE:String = "RGB color component must be an integer between 0 and 255.";
		
		/**
		 * A constant representing the red component of the RGB colorspace.
		 */
		public static const RED:String = "red";
		
		/**
		 * A constant representing the green component of the RGB colorspace.
		 */
		public static const GREEN:String = "green";
		
		/**
		 * A constant representing the blue component of the RGB colorspace.
		 */
		public static const BLUE:String = "blue";
			
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 * 
		 * @param red		the initial red value
		 * @param green		the initial green value
		 * @param blue		the initial blue value
		 */
		public function RGBColor(red:int = 0, green:int = 0, blue:int = 0)
		{
			this.red = red;
			this.green = green;
			this.blue = blue;
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * @private
		 * Storage for the red property.
		 */
		private var _red:int;
		
		/**
		 * Represents the red component of a value in the 24-bit RGB color space.
		 * Possible values include all integers in the range 0 to 255.
		 */
		public function get red():int
		{
			return this._red;
		}
		
		/**
		 * @private
		 */
		public function set red(value:int):void
		{
			if(value < 0 || value > 255)
			{
				throw new RangeError(COLOR_RANGE_ERROR_MESSAGE);
			}
			
			this._red = value;
		}
		
		/**
		 * @private
		 * Storage for the green property.
		 */
		private var _green:int;
		
		/**
		 * Represents the green component of a value in the 24-bit RGB color space.
		 * Possible values include all integers in the range 0 to 255.
		 */
		public function get green():int
		{
			return this._green;
		}
		
		/**
		 * @private
		 */
		public function set green(value:int):void
		{
			if(value < 0 || value > 255)
			{
				throw new RangeError(COLOR_RANGE_ERROR_MESSAGE);
			}
			
			this._green = value;
		}
		
		/**
		 * @private
		 * Storage for the blue property.
		 */
		private var _blue:int;
		
		
		/**
		 * Represents the blue component of a value in the 24-bit RGB color space.
		 * Possible values include all integers in the range 0 to 255.
		 */
		public function get blue():int
		{
			return this._blue;
		}
		
		/**
		 * @private
		 */
		public function set blue(value:int):void
		{
			if(value < 0 || value > 255)
			{
				throw new RangeError(COLOR_RANGE_ERROR_MESSAGE);
			}
			
			this._blue = value;
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		public function toString():String
		{
			return "{ red: " + this.red + ", green: " + this.green + ", blue: " + this.blue + " }";
		}
		
		/**
		 * @inheritDoc
		 */
		public function touint():uint
		{
			return ColorUtil.RGBTouint(this);
		}
		
		/**
		 * @inheritDoc
		 */
		public function clone():IColor
		{
			return new RGBColor(this.red, this.green, this.blue);
		}
	}
}