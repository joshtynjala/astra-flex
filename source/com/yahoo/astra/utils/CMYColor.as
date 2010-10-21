/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.utils
{
	/**
	 * Represents a value in the CMY color space.
	 */
	public class CMYColor implements IColor
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
	
		/**
		 * A constant representing the cyan component of the CMY colorspace.
		 */
		public static const CYAN:String = "cyan";
		
		/**
		 * A constant representing the magenta component of the CMY colorspace.
		 */
		public static const MAGENTA:String = "magenta";
		
		/**
		 * A constant representing the yellow component of the CMY colorspace.
		 */
		public static const YELLOW:String = "yellow";
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 * 
		 * @param cyan			the initial cyan value
		 * @param magenta		the initial magenta value
		 * @param yellow		the initial yellow value
		 */
		public function CMYColor(cyan:Number = 0, magenta:Number = 0, yellow:Number = 0)
		{
			super();
			this.cyan = cyan;
			this.magenta = magenta;
			this.yellow = yellow;
		}
			
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * @private
		 * Storage for the cyan property.
		 */
		private var _cyan:Number;
		
		/**
		 * Represents the cyan component of a value in the CMY color space.
		 */
		public function get cyan():Number
		{
			return this._cyan;
		}
		
		/**
		 * @private
		 */
		public function set cyan(value:Number):void
		{
			this._cyan = value;
		}
		
		/**
		 * @private
		 * Storage for the magenta property.
		 */
		private var _magenta:Number;
		
		/**
		 * Represents the magenta component of a value in the CMY color space.
		 */
		public function get magenta():Number
		{
			return this._magenta;
		}
		
		/**
		 * @private
		 */
		public function set magenta(value:Number):void
		{
			this._magenta = value;
		}
		
		/**
		 * @private
		 * Storage for the yellow property.
		 */
		private var _yellow:Number;
		
		/**
		 * Represents the yellow component of a value in the CMY color space.
		 */
		public function get yellow():Number
		{
			return this._yellow;
		}
		
		/**
		 * @private
		 */
		public function set yellow(value:Number):void
		{
			this._yellow = value;
		}
			
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		public function toString():String
		{
			return "{ cyan: " + this.cyan + ", magenta: " + this.magenta + ", yellow: " + this.yellow + " }";
		}
		
		/**
		 * @inheritDoc
		 */
		public function touint():uint
		{
			return ColorUtil.CMYTouint(this);
		}
		
		/**
		 * @inheritDoc
		 */
		public function clone():IColor
		{
			return new CMYColor(this.cyan, this.magenta, this.yellow);
		}
		
	}
}