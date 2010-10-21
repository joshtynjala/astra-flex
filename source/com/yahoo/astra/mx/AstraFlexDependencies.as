/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx
{
	import com.yahoo.astra.mx.accessibility.DropDownColorPickerAccImpl;
	import com.yahoo.astra.mx.accessibility.IPv4AddressInputAccImpl;
	import com.yahoo.astra.mx.accessibility.TimeInputAccImpl;
	import com.yahoo.astra.mx.accessibility.TimeStepperAccImpl;

	/**
	 * Some required classes aren't referenced directly in the main code.
	 * They're referenced here to make building the SWC easier.
	 * 
	 * Yes, it looks weird, but Adobe does it too.
	 *
	 * @author Josh Tynjala
	 */
	internal class AstraFlexDependencies
	{
		DropDownColorPickerAccImpl;
		IPv4AddressInputAccImpl;
		TimeInputAccImpl;
		TimeStepperAccImpl;
	}
}