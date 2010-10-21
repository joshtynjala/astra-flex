/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.skins.halo
{
	import mx.skins.Border;
	
	/**
	 * The skin for all the states of a color viewer.
	 * 
	 * @author Josh Tynjala
	 */
	public class ColorViewerSkin extends Border
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */	
		public function ColorViewerSkin()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * @private
		 */
		protected var borderShadowColor:uint = 0x9A9B9D;
	
		/**
		 * @private
		 */
		protected var borderHighlightColor:uint = 0xFEFEFE;
		
		/**
		 * @private
		 */
		protected var backgroundColor:uint = 0xE5E6E7;
		
		/**
		 * @private
		 */
		protected var borderSize:Number = 1;
		
		/**
		 * @private
		 */
		protected var bevelSize:Number = 1;
		
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
			
			switch(this.name)
			{
				case "upSkin":
				case "overSkin":
					// invisible hit area
					this.drawFill(x, y, unscaledWidth + bevelSize, unscaledHeight + bevelSize, 0xCCCCCC, 0);
					
					// outer border
					this.drawBorder(x, y, unscaledWidth, unscaledHeight, borderHighlightColor, borderShadowColor, bevelSize, 1.0); 
					
					// background
					this.drawBorder(x + bevelSize, y + bevelSize,
					   unscaledWidth - (bevelSize * 2), unscaledHeight - (bevelSize * 2),
					   backgroundColor, backgroundColor, borderSize, 1.0);                      
					
					// inner border
					this.drawBorder(x + bevelSize + borderSize, y + bevelSize + borderSize,
					   unscaledWidth - ((bevelSize + borderSize) * 2),
					   unscaledHeight - ((bevelSize + borderSize) * 2),
					   borderShadowColor, borderHighlightColor,
					   bevelSize, 1.0); 
					break;
				case "downSkin":
					// invisible hit area
					this.drawFill(x, y, unscaledWidth, unscaledHeight, 0xCCCCCC, 0);
					
					// outer border
					this.drawBorder(x, y, unscaledWidth, unscaledHeight, borderHighlightColor, 0xCCCCCC, bevelSize, 1.0);
					
					// background
					this.drawBorder(x + bevelSize, y + bevelSize,
						unscaledWidth - 2 * bevelSize, unscaledHeight - 2 * bevelSize,
						backgroundColor, backgroundColor, borderSize, 1.0);
					
					// inner border
					this.drawBorder(x + bevelSize + borderSize, y + bevelSize + borderSize,
						unscaledWidth - 2 * (bevelSize + borderSize),
						unscaledHeight - 2 * (bevelSize + borderSize),
						borderShadowColor, borderHighlightColor,
						bevelSize, 1.0);
					break;
				case "disabledSkin":
					// For blur effect when disabled
					this.drawRoundRect(x, y, unscaledWidth, unscaledHeight, 0, 0xFFFFFF, 0.6);
					
					// invisible hit area
					this.drawFill(x, y, unscaledWidth, unscaledHeight, 0xFFFFFF, 0.25);
					
					// outer border
					this.drawBorder(x, y, unscaledWidth, unscaledHeight, borderHighlightColor, 0xCCCCCC,
						bevelSize, 1.0);
					
					// background
					this.drawBorder(x + bevelSize, y + bevelSize,
						unscaledWidth - (bevelSize * 2), unscaledHeight - (bevelSize * 2),
						backgroundColor, backgroundColor, borderSize, 1.0);
					
					// inner border        
					this.drawBorder(x + bevelSize + borderSize, y + bevelSize + borderSize,
						unscaledWidth - 2 * (bevelSize + borderSize),
						unscaledHeight - 2 * (bevelSize + borderSize),
						borderShadowColor, borderHighlightColor,
						bevelSize, 1.0);
					break;
				default:
					// invisible hit area
					this.drawFill(x, y, unscaledWidth + bevelSize, unscaledHeight + bevelSize, 0xCCCCCC, 0);
					
					// outer border
					this.drawBorder(x, y, unscaledWidth, unscaledHeight, borderHighlightColor, borderShadowColor, bevelSize, 1.0); 
		
					// background
					this.drawBorder(x + bevelSize, y + bevelSize,
					   unscaledWidth - (bevelSize * 2), unscaledHeight - (bevelSize * 2),
					   backgroundColor, backgroundColor, borderSize, 1.0);					  
					
					// inner border
					this.drawBorder(x + bevelSize + borderSize, y + bevelSize + borderSize,
					   unscaledWidth - ((bevelSize + borderSize) * 2),
					   unscaledHeight - ((bevelSize + borderSize) * 2),
					   borderShadowColor, borderHighlightColor,
					   bevelSize, 1.0);		
			}
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
