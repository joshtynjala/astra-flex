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
	 *  The skin for all the states of a thumb in a Slider.
	 *
	 *  @author Josh Tynjala
	 */
	public class SliderThumbSkin extends Border
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
		 * @private
		 * Several colors used for drawing are calculated from the base colors
		 * of the component (themeColor, borderColor and fillColors).
		 * Since these calculations can be a bit expensive,
		 * we calculate once per color set and cache the results.
		 */
		private static function calcDerivedStyles(
			themeColor:uint, borderColor:uint, fillColor0:uint, fillColor1:uint):Object
		{
			var key:String = HaloColors.getCacheKey(themeColor, borderColor, fillColor0, fillColor1);
			
			if (!derivedStylesCache[key])
			{
				var o:Object = derivedStylesCache[key] = {};
				
				// Cross-Component styles.
				HaloColors.addHaloColors(o, themeColor, fillColor0, fillColor1);
				
				// SliderThumb-unique styles.
				o.borderColorDrk1 = ColorUtil.adjustBrightness2(borderColor, -50);
			}
	
			return derivedStylesCache[key];
		}
	
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
	    /**
		 * Constructor.
		 */
		public function SliderThumbSkin()
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
			return 12;
		}
	
		/**
		 * @private
		 */
		override public function get measuredHeight():Number
		{
			return 12;
		}
			
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
	
	    /**
		 * @private
		 */
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
	
			// User-defined styles.
			var borderColor:uint = getStyle("borderColor");
			var fillAlphas:Array = getStyle("fillAlphas");
			var fillColors:Array = getStyle("fillColors");
			
			//TODO: when dropping Flex 3 support, change to this.styleManager
			StyleManager.getColorNames(fillColors);
			var themeColor:uint = getStyle("themeColor");
			
			// Derivative styles.
			var derStyles:Object = calcDerivedStyles(themeColor, borderColor,
													 fillColors[0], fillColors[1]);
	
			this.graphics.clear();
			
			switch(name)
			{
				case "upSkin":
				{				
					this.drawThumbState(w, h, 
								   [ borderColor, derStyles.borderColorDrk1 ], 
								   [ fillColors[0], fillColors[1] ], 
								   [ fillAlphas[0], fillAlphas[1] ], 
								   true,
								   true);
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
						
					this.drawThumbState(w, h, 
					               [ derStyles.themeColDrk2, derStyles.themeColDrk1 ], 
					               overFillColors, 
					               overFillAlphas, 
					               true, true);
					break;
				}
				
				case "downSkin":
				{
					this.drawThumbState(w, h, 
								   [ derStyles.themeColDrk2, derStyles.themeColDrk1 ], 
								   [ derStyles.fillColorPress1, derStyles.fillColorPress2 ],
								   [ 1.0, 1.0 ],
								   true, false);
					break;
				}
				
				case "disabledSkin":
				{
					this.drawThumbState(w, h,
								   [ borderColor, derStyles.borderColorDrk1 ],
								   [ fillColors[0], fillColors[1] ],
								   [ Math.max(0, fillAlphas[0] - 0.15), Math.max(0, fillAlphas[1] - 0.15) ],
								   false, false);
					break;
				}
			}
		}
	
	    /**
		 * @private
		 * Draws the thumb.
		 */
		protected function drawThumbState(w:Number, h:Number, borderColors:Array, fillColors:Array, fillAlphas:Array, drawBacking:Boolean, drillHole:Boolean):void
		{
			var down:Boolean = this.getStyle("invertThumbDirection");
			
			var h0:Number = down ? h : 0;
			var h1:Number = down ? h - 1 : 1;
			var h2:Number = down ? h - 2 : 2;
			var hhm2:Number = down ? 2 : h - 2;
			var hhm1:Number = down ? 1 : h - 1;
			var hh:Number = down ? 0 : h;
			
			// if we are inverting, then swap the direction of the colors
			if(down)
			{
				borderColors = [borderColors[1], borderColors[0]];
				fillColors = [fillColors[1], fillColors[0]];
				fillAlphas = [fillAlphas[1], fillAlphas[0]];	
			}
			
			// backing - for opacity
			if(drawBacking)
			{
				this.graphics.beginGradientFill(GradientType.LINEAR,
									[ 0xFFFFFF, 0xFFFFFF ],
									[ 0.6, 0.6 ], 
									[ 0, 0xFF ],
									verticalGradientMatrix(0, 0, w, h));
				this.graphics.moveTo(w / 2, h0);
				this.graphics.curveTo(w / 2, h0, w / 2 - 2, h2);
				this.graphics.lineTo(0, hhm2);
				this.graphics.curveTo(0, hhm2, 2, hh);
				this.graphics.lineTo(w - 2, hh);
				this.graphics.curveTo(w - 2, hh, w, hhm2);
				this.graphics.lineTo(w / 2 + 2, h2);
				this.graphics.curveTo(w / 2 + 2, h2, w / 2, h0);
				this.graphics.endFill();
			}
	
			// border 
			this.graphics.beginGradientFill(GradientType.LINEAR,
								borderColors,
								[ 1.0, 1.0 ], 
								[ 0, 0xFF ],
								verticalGradientMatrix(0, 0, w, h));
			this.graphics.moveTo(w / 2, h0);
			this.graphics.curveTo(w / 2, h0, w / 2 - 2, h2);
			this.graphics.lineTo(0, hhm2);
			this.graphics.curveTo(0, hhm2, 2, hh);
			this.graphics.lineTo(w - 2, hh);
			this.graphics.curveTo(w - 2, hh, w, hhm2);
			this.graphics.lineTo(w / 2 + 2, h2);
			this.graphics.curveTo(w / 2 + 2, h2, w / 2, h0);
			
			if(drillHole)
			{
				// drillhole
				this.graphics.moveTo(w / 2, h1);
				this.graphics.curveTo(w / 2, h0, w / 2 - 1, h2);
				this.graphics.lineTo(1, hhm1);
				this.graphics.curveTo(1, hhm1, 1, hhm1);
				this.graphics.lineTo(w - 1, hhm1);
				this.graphics.curveTo(w - 1, hhm1, w - 1, hhm2);
				this.graphics.lineTo(w / 2 + 1, h2);
				this.graphics.curveTo(w / 2 + 1, h2, w / 2, h1);
				this.graphics.endFill();
			}
			
			// fill
			this.graphics.beginGradientFill(GradientType.LINEAR,
								fillColors,
								fillAlphas, 
								[ 0, 0xFF ],
								verticalGradientMatrix(0, 0, w, h));
			this.graphics.moveTo(w / 2, h1);
			this.graphics.curveTo(w / 2, h0, w/2 - 1, h2);
			this.graphics.lineTo(1, hhm1);
			this.graphics.curveTo(1, hhm1, 1, hhm1);
			this.graphics.lineTo(w - 1, hhm1);
			this.graphics.curveTo(w - 1, hhm1, w - 1, hhm2);
			this.graphics.lineTo(w / 2 + 1, h2);
			this.graphics.curveTo(w / 2 + 1, h2, w / 2, h1);
			this.graphics.endFill();				
		}
		
	}
}
