/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.skins.halo
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	
	import mx.skins.Border;
	import mx.skins.halo.HaloColors;
	import mx.styles.StyleManager;
	import mx.utils.ColorUtil;
	
	/**
	 * The skin for all the states of the button in a drop down.
	 * 
	 * @author Josh Tynjala
	 */
	public class DropDownViewerSkin extends Border
	{
	
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
	
		/**
		 * @private
		 */
		private static var derivedStylesCache:Object = {};
		
	//--------------------------------------
	//  Static Methods
	//--------------------------------------
	
		/**
		 *  @private
		 *  Several colors used for drawing are calculated from the base colors
		 *  of the component (themeColor, borderColor and fillColors).
		 *  Since these calculations can be a bit expensive,
		 *  we calculate once per color set and cache the results.
		 */
		private static function calcDerivedStyles(themeColor:uint, borderColor:uint,
										  fillColor0:uint, fillColor1:uint):Object
		{
			var key:String = HaloColors.getCacheKey(themeColor, borderColor,
													fillColor0, fillColor1);
			
			if (!derivedStylesCache[key])
			{
				var o:Object = derivedStylesCache[key] = {};
				
				// Cross-component styles.
				HaloColors.addHaloColors(o, themeColor, fillColor0, fillColor1);
			}
			
			return derivedStylesCache[key];
		}
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function DropDownViewerSkin()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	    
	    /**
	     * @private
	     */    
	    override public function get measuredWidth():Number
	    {
	        return 22;
	    }
	    
	    /**
	     * @private
	     */        
	    override public function get measuredHeight():Number
	    {
	        return 22;
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
	
			// User-defined styles.
			var arrowColor:uint = this.getStyle("iconColor");
			var borderColor:uint = this.getStyle("borderColor");
			var cornerRadius:Number = this.getStyle("cornerRadius");
			var dropdownBorderColor:Number = this.getStyle("dropdownBorderColor");
			var fillAlphas:Array = this.getStyle("fillAlphas");
			var fillColors:Array = this.getStyle("fillColors");
			
			//TODO: when dropping Flex 3 support, change to this.styleManager
			StyleManager.getColorNames(fillColors);
			var highlightAlphas:Array = this.getStyle("highlightAlphas");		
			var themeColor:uint = this.getStyle("themeColor");
				
			// The dropdownBorderColor is currently only used
			// when displaying an error state.
			if(!isNaN(dropdownBorderColor))
			{
				borderColor = dropdownBorderColor;
			}
			
			// Derivative Styles
			var derStyles:Object = calcDerivedStyles(themeColor, borderColor, fillColors[0], fillColors[1]);
			
			var borderColorDrk1:Number = ColorUtil.adjustBrightness2(borderColor, -50);
			
			var themeColorDrk1:Number = ColorUtil.adjustBrightness2(themeColor, -25);
			
			var cornerRadius1:Number = Math.max(cornerRadius - 1, 0);
			var cr:Object = { tl: cornerRadius, tr: cornerRadius, bl: cornerRadius, br: cornerRadius };
			var cr1:Object = { tl: cornerRadius1, tr: cornerRadius1, bl: cornerRadius1, br: cornerRadius1 };
			
			this.graphics.clear();
			
			// Draw the border and fill.
			switch(this.name)
			{
				case "upSkin":
				{
	   				var upFillColors:Array = [ fillColors[0], fillColors[1] ];
	   				var upFillAlphas:Array = [ fillAlphas[0], fillAlphas[1] ];
				
					// border
					this.drawRoundRect(
						0, 0, unscaledWidth, unscaledHeight, cr,
						[ borderColor, borderColorDrk1 ], 1,
						verticalGradientMatrix(0, 0, unscaledWidth, unscaledHeight),
						GradientType.LINEAR, null, 
						{ x: 1, y: 1, w: unscaledWidth - 2, h: unscaledHeight - 2, r: cr1 });
	
					// button fill
					this.drawRoundRect(
						1, 1, unscaledWidth - 2, unscaledHeight - 2, cr1,
						upFillColors, upFillAlphas,
						verticalGradientMatrix(1, 1, unscaledWidth - 2, unscaledHeight - 2));
						
					// top highlight
					this.drawRoundRect(
						1, 1, unscaledWidth - 2, (unscaledHeight - 2) / 2, 
						{ tl: cornerRadius1, tr: cornerRadius1, bl: 0, br: 0 },
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
						verticalGradientMatrix(1, 1, unscaledWidth - 2, (unscaledHeight - 2) / 2)); 
	
					// line
					this.drawRoundRect(unscaledWidth - 22, 4, 1, unscaledHeight - 8, 0, borderColor, 1);
					this.drawRoundRect(unscaledWidth - 21, 4, 1, unscaledHeight - 8, 0, 0xFFFFFF, 0.2); 
					
					break;
				}
				
				case "overSkin":
				{
					var overFillColors:Array;
					if (fillColors.length > 2)
					{
						overFillColors = [ fillColors[2], fillColors[3] ];
					}
					else
					{
						overFillColors = [ fillColors[0], fillColors[1] ];
					}
	
					var overFillAlphas:Array;
					if (fillAlphas.length > 2)
					{
						overFillAlphas = [ fillAlphas[2], fillAlphas[3] ];
					}
	  				else
	  				{
						overFillAlphas = [ fillAlphas[0], fillAlphas[1] ];
	  				}
	
					// border
					this.drawRoundRect(
						0, 0, unscaledWidth, unscaledHeight, cr,
						[ themeColor, themeColorDrk1 ], 1,
						verticalGradientMatrix(0, 0, unscaledWidth, unscaledHeight),
						GradientType.LINEAR, null, 
						{ x: 1, y: 1, w: unscaledWidth - 2, h: unscaledHeight - 2, r: cr1 }); 
						
					// button fill
					this.drawRoundRect(
						1, 1, unscaledWidth - 2, unscaledHeight - 2, cr1,
						overFillColors, overFillAlphas,
						this.verticalGradientMatrix(1, 1, unscaledWidth - 2, unscaledHeight - 2));
						
					// top highlight
					this.drawRoundRect(
						1, 1, unscaledWidth - 2, (unscaledHeight - 2) / 2, 
						{ tl: cornerRadius1, tr: cornerRadius1, bl: 0, br: 0 },
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
						verticalGradientMatrix(0, 0, unscaledWidth - 2, (unscaledHeight - 2) / 2));
	
	
					
					// line
					this.drawRoundRect(
						unscaledWidth - 22, 4, 1, unscaledHeight - 8, 0,
						derStyles.themeColDrk2,1);
					this.drawRoundRect(
						unscaledWidth - 21, 4, 1, unscaledHeight - 8, 0,
						0xFFFFFF, 0.2); 
					
					break;
				}
				
				case "downSkin":
				{
					// border
					this.drawRoundRect(
						0, 0, unscaledWidth, unscaledHeight, cr,
						[ themeColor, themeColorDrk1 ], 1,
						verticalGradientMatrix(0, 0, unscaledWidth, unscaledHeight));
					
					// button fill
					this.drawRoundRect(
						1, 1, unscaledWidth - 2, unscaledHeight - 2, cr1,
						[ derStyles.fillColorPress1, derStyles.fillColorPress2 ], 1,
						verticalGradientMatrix(1, 1, unscaledWidth - 2, unscaledHeight - 2));
					
					// top highlight
					this.drawRoundRect(
						1, 1, unscaledWidth - 2, (unscaledHeight - 2) / 2, 
						{ tl: cornerRadius1, tr: cornerRadius1, bl: 0, br: 0 },
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
						verticalGradientMatrix(1, 1, unscaledWidth - 2, (unscaledHeight - 2) / 2)); 
	
					
					// line
					this.drawRoundRect(unscaledWidth - 22, 4, 1, unscaledHeight - 8, 0, themeColorDrk1, 1); 
					this.drawRoundRect(unscaledWidth - 21, 4, 1, unscaledHeight - 8, 0, 0xFFFFFF, 0.2); 
	
					break;
				}
				
				case "disabledSkin":
				{
	   				var disFillColors:Array = [ fillColors[0], fillColors[1] ];
	   				
					var disFillAlphas:Array = [ Math.max(0, fillAlphas[0] - 0.15),
												Math.max(0, fillAlphas[1] - 0.15) ];
	
					// border
					this.drawRoundRect(
						0, 0, unscaledWidth, unscaledHeight, cr,
						[ borderColor, borderColorDrk1 ], 0.5,
						verticalGradientMatrix(0, 0, unscaledWidth, unscaledHeight ),
						GradientType.LINEAR, null, 
						{ x: 1, y: 1, w: unscaledWidth - 2, h: unscaledHeight - 2, r: cr1 });
	
					
					// button fill
					this.drawRoundRect(
						1, 1, unscaledWidth - 2, unscaledHeight - 2, cr1,
						disFillColors, disFillAlphas,
						verticalGradientMatrix(0, 0, unscaledWidth - 2, unscaledHeight - 2)); 
					
					// line
					this.drawRoundRect(
						unscaledWidth - 22, 4, 1, unscaledHeight - 8, 0,
						0x999999, 0.5); 
					
					arrowColor = getStyle("disabledIconColor");
					
					break;
				}
			}
			
			// Draw the triangle.
			this.graphics.beginFill(arrowColor);
			this.graphics.moveTo(unscaledWidth - 11.5, unscaledHeight / 2 + 3);
			this.graphics.lineTo(unscaledWidth - 15, unscaledHeight / 2 - 2);
			this.graphics.lineTo(unscaledWidth - 8, unscaledHeight / 2 - 2);
			this.graphics.lineTo(unscaledWidth - 11.5, unscaledHeight / 2 + 3);
			this.graphics.endFill();
		}
	}

}
