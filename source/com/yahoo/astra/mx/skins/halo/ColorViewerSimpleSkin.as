/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.skins.halo
{
	import mx.skins.RectangularBorder;
	
	/**
	 * A simple skin for a color viewer.
	 * 
	 * @author Josh Tynjala
	 */
	public class ColorViewerSimpleSkin extends RectangularBorder
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function ColorViewerSimpleSkin()
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
    
            this.graphics.clear();
            this.drawBorder(0, 0, unscaledWidth, unscaledHeight, 0x999999, 0xffffff, 1, 1.0);
		}
	
	    /**
	     * @private
	     * Draws a border.
	     */    
	    protected function drawBorder(xPosition:Number, yPosition:Number, width:Number, height:Number, color1:Number, color2:Number, size:Number, fillAlpha:Number):void
	    {
	        // border line on the left side
	        this.drawFill(xPosition, yPosition, size, height, color1, fillAlpha);
	
	        // border line on the top side
	        this.drawFill(xPosition, yPosition, width, size, color1, fillAlpha);
	
	        // border line on the right side
	        this.drawFill(xPosition + (width - size), yPosition, size, height, color2, fillAlpha);
	
	        // border line on the bottom side
	        this.drawFill(xPosition, yPosition + (height - size), width, size, color2, fillAlpha);
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