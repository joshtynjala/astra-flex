/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.utils
{
	import flash.utils.Dictionary;
	
	/**
	 * A collection of constants and methods for use with colorspaces.
	 * 
	 * @author Josh Tynjala
	 */
	public class ColorSpace
	{
		/**
		 * A constant representing the RGB colorspace.
		 * 
		 * @see com.yahoo.astra.util.RGBColor
		 */
		public static const RGB:String = "rgb";
		
		/**
		 * A constant representing the HSB colorspace.
		 * 
		 * @see com.yahoo.astra.util.HSBColor
		 */
		public static const HSB:String = "hsb";
		
		/**
		 * A constant representing the CMY colorspace.
		 * 
		 * @see com.yahoo.astra.util.CMYColor
		 */
		public static const CMY:String = "cmy";
		
		/**
		 * A constant representing the CMYK colorspace.
		 * 
		 * @see com.yahoo.astra.util.CMYKColor
		 */
		public static const CMYK:String = "cmyk";
		
		/**
		 * @private
		 * A hash where keys are IColor implementations and values are the
		 * matching string constants defined in the ColorSpace class.
		 */
		private static const strings:Dictionary = new Dictionary();
		strings[RGBColor] = RGB;
		strings[HSBColor] = HSB;
		strings[CMYColor] = CMY;
		strings[CMYKColor] = CMYK;
		
		/**
		 * @private
		 * A hash where keys are string constants for colorspaces, and values
		 * are the matching IColor implementations. 
		 */
		private static const types:Object = {rgb: RGBColor, hsb: HSBColor, cmy: CMYColor, cmyk: CMYKColor};
		
		/**
		 * Taking an IColor implementation as input, returns the string constant
		 * that represents the colorspace for the class.
		 * 
		 * @param type		the IColor implementation
		 * @return			the string constant representing the colorspace 
		 */
		public static function classToColorSpace(type:Class):String
		{
			return strings[type];
		}
		
		/**
		 * Taking a string constant for a colorspace, returns the IColor
		 * implementation for that colorspace.
		 * 
		 * @param colorSpace		the string constant
		 * @return					the IColor implementation
		 */
		public static function colorSpaceToClass(colorSpace:String):Class
		{
			return types[colorSpace]
		}
	}
}