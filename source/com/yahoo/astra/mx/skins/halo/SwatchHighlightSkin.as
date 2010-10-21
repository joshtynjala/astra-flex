/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.skins.halo
{
	import mx.skins.RectangularBorder;
	import mx.styles.StyleProxy;
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;

	/**
	 * The skin for the SwatchPicker highlight.
	 * 
	 * @see com.yahoo.astra.mx.controls.SwatchPicker
	 * 
	 * @author Josh Tynjala
	 */ 
	public class SwatchHighlightSkin extends RectangularBorder
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function SwatchHighlightSkin()
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
			
			var borderColor:uint = this.getStyle("swatchHighlightColor");
			var borderThickness:Number = this.getStyle("borderThickness");
			
			this.graphics.clear();
			
			this.drawFill(-borderThickness, -borderThickness, unscaledWidth + 2 * borderThickness, borderThickness, borderColor, 1);
			this.drawFill(-borderThickness, 0, borderThickness, unscaledHeight, borderColor, 1);
			this.drawFill(unscaledWidth, 0, borderThickness, unscaledHeight, borderColor, 1);
			this.drawFill(-borderThickness, unscaledHeight, unscaledWidth + 2 * borderThickness, borderThickness, borderColor, 1);
		}
	
	    /**
	     * @private
	     * Draws a line-like fill for a border.
	     */    
	    protected function drawFill(xPosition:Number, yPosition:Number, width:Number, height:Number, fillColor:Number, fillAlpha:Number):void
	    {
	        this.graphics.moveTo(xPosition, yPosition);
	        this.graphics.beginFill(fillColor, fillAlpha);
	        this.graphics.lineTo(xPosition + width, yPosition);
	        this.graphics.lineTo(xPosition + width, height + yPosition);
	        this.graphics.lineTo(xPosition, height + yPosition);
	        this.graphics.lineTo(xPosition, yPosition);
	        this.graphics.endFill();
	    }
	}
}