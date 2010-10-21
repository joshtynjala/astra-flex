/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls.colorPickerClasses
{
	/**
	 * An interface representing color viewers that may also preview a new
	 * color.
	 * 
	 * @author Josh Tynjala
	 */
	public interface IColorPreviewViewer extends IColorViewer
	{
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	
		/**
		 * The color that is to be previewed.
		 */
		function get previewColor():uint;
		
		/**
		 * @private
		 */
		function set previewColor(value:uint):void;
		
		/**
		 * If true, the preview color will be displayed. If false, it will not.
		 */
		function get showPreview():Boolean;
		
		/**
		 * @private
		 */
		function set showPreview(value:Boolean):void;
	}
}