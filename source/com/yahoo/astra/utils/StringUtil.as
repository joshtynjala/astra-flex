/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.utils
{
	/**
	 * A collection of utility functions for the manipulation of String values.
	 * 
	 * @author Josh Tynjala
	 */
	public class StringUtil
	{
		/**
		 * Adds a set of characters to the front of a string to make it a
		 * specific length. If the string is longer or equal to the desired
		 * total length, it will be returned without changes.
		 */
		public static function padFront(input:String, totalLength:int, padCharacter:String):String
		{
			var difference:int = totalLength - input.length;
			if(difference <= 0) return input;
			
			for(var i:int = 0; i < difference; i++)
			{
				input = padCharacter + input;
			}
			return input;
		}

	}
}