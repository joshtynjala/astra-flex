/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.utils
{
	/**
	 * Represents a value in the CMYK color space.
	 */
	public class CMYKColor extends CMYColor
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
	
		/**
		 * A constant representing the cyan component of the CMYK colorspace.
		 */
		public static const CYAN:String = "cyan";
		
		/**
		 * A constant representing the magenta component of the CMYK colorspace.
		 */
		public static const MAGENTA:String = "magenta";
		
		/**
		 * A constant representing the yellow component of the CMYK colorspace.
		 */
		public static const YELLOW:String = "yellow";
		
		/**
		 * A constant representing the key component of the CMYK colorspace.
		 */
		public static const KEY:String = "key";
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor
		 * 
		 * @param cyan			the initial cyan value
		 * @param magenta		the initial magenta value
		 * @param yellow		the initial yellow value
		 * @param key			the initial key value
		 */
		public function CMYKColor(cyan:Number = 0, magenta:Number = 0, yellow:Number = 0, key:Number = 0)
		{
			super(cyan, magenta, yellow);
			this.key = key;
		}
			
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * @private
		 * Storage for the key property.
		 */
		private var _key:Number;
		
		/**
		 * Represents the key component of a value in the CMYK color space.
		 */
		public function get key():Number
		{
			return this._key;
		}
		
		/**
		 * @private
		 */
		public function set key(value:Number):void
		{
			this._key = value;
		}
			
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		override public function toString():String
		{
			return "{ cyan: " + this.cyan + ", magenta: " + this.magenta + ", yellow: " + this.yellow + ", key: " + this.key + " }";
		}
		
		/**
		 * @inheritDoc
		 */
		override public function touint():uint
		{
			return ColorUtil.CMYKTouint(this);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clone():IColor
		{
			return new CMYKColor(this.cyan, this.magenta, this.yellow, this.key);
		}
		
	}
}