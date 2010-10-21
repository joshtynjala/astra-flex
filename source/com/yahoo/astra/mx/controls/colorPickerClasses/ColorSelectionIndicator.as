/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls.colorPickerClasses
{
	import mx.skins.Border;
	import mx.utils.ColorUtil;

	/**
	 * A simple round border the indicates selection in color picker controls.
	 * 
	 * @see com.yahoo.astra.mx.controls.colorPickerClasses.SwatchPicker
	 * 
	 * @author Josh Tynjala
	 */
	public class ColorSelectionIndicator extends Border
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function ColorSelectionIndicator()
		{
			super();
		}
		
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var halfWidth:Number = unscaledWidth / 2;
			var halfHeight:Number = unscaledHeight / 2;
			var radius:Number = Math.min(halfWidth, halfHeight);
			
			var borderColor:uint = getStyle("borderColor");		
			var borderColorDrk1:uint = ColorUtil.adjustBrightness2(borderColor, -70);
			var borderColorLt1:uint = ColorUtil.adjustBrightness2(borderColor, 70);
			
			this.graphics.clear();
			this.graphics.lineStyle(0, borderColorDrk1, 1);
			this.graphics.drawCircle(halfWidth, halfHeight, radius);
			
			this.graphics.lineStyle(0, borderColorLt1, 1);
			this.graphics.drawCircle(halfWidth, halfHeight, radius - 1);
		}
	}
}