/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.utils
{
	/**
	 * An interface for colors that may be represented by differing colorspaces.
	 * 
	 * @author Josh Tynjala
	 */
	public interface IColor
	{
		/**
		 * Converts the IColor object to a standard RGB uint color value.
		 */
		function touint():uint;
		
		/**
		 * Copies the values of the IColor object into a new instance.
		 */
		function clone():IColor;
	}
}