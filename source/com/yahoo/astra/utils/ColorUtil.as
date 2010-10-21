/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.utils
{
	/**
	 * Utility functions for working with color values.
	 * 
	 * @see com.yahoo.astra.utils.IColor
	 */
	public class ColorUtil
	{
		/**
		 * Determines if white (0xfffff) or black (0x000000) is a better color
		 * to display over the specified color value. Use case: Text color over
		 * a background color. 
		 * 
		 * @param value		the input color value
		 * @return			black or white (0x000000 or 0xffffff).
		 */
		public static function whiteOrBlack(value:uint):uint
		{
			var rgb:RGBColor = ColorUtil.uintToRGB(value);
			var lightnessWeight:Number = (rgb.red * 0.3 + rgb.green * 0.59 + rgb.blue * 0.11); // BK Found the algo on the I-Net
			return lightnessWeight > 0x96 ? 0x000000 : 0xffffff;
		}
		
		/**
		 * Converts a uint color value to a hex string.
		 * 
		 * <p>Format: XXXXXX, where X is a value between 0-F.</p>
		 * 
		 * @param value		the uint to convert
		 * @return			the converted value as a hex string
		 */
		public static function toHexString(value:uint):String
		{
			var hexString:String = "";
			for(var i:int = 0; i < 24; i+= 4)
			{
				var color:uint = value;
				color = color >> i;
				hexString = (color & 0xf).toString(16) + hexString;
			}
			return hexString;
		}
		
		/**
		 * Converts an RGB color value to the HSB colorspace.
		 * 
		 * @param rgb		the input RGB value
		 * @return			the value converted to HSB
		 */
		public static function RGBToHSB(rgb:RGBColor):HSBColor
		{
			//normalize all to the range 0 - 1
			var red:Number = rgb.red / 0xff;
			var green:Number = rgb.green / 0xff;
			var blue:Number = rgb.blue / 0xff;
			
			var max:Number = Math.max(red, green, blue);
			var min:Number = Math.min(red, green, blue);
			var delta:Number = max - min;
			
			var hue:Number = 0;
			var saturation:Number = 0;
			var brightness:Number = max;
			
			if(delta != 0)
			{
				if(brightness != 0)
				{
					saturation = delta / max;
				}
				
				var tempR:Number = (max - red) / delta;
				var tempG:Number = (max - green) / delta;
				var tempB:Number = (max - blue) / delta;

				switch(max)
				{
					case red:
						hue = tempB - tempG;
						break;
					case green:
						hue = 2 + tempR - tempB;
						break;
					case blue:
						hue = 4 + tempG - tempR;
						break;
				}
				hue /= 6;
			}
			if(hue < 0) hue++;
			if(hue > 1) hue--;
			
			//update hue to 0 - 360, saturation and brightness to 0 - 100
			return new HSBColor(hue * 360, saturation * 100, brightness * 100);
		}
		
		/**
		 * Converts an HSB color value to the RGB colorspace.
		 * 
		 * @param hsb		the input HSB value
		 * @return			the value converted to RGB
		 */
		public static function HSBToRGB(hsb:HSBColor):RGBColor
		{
			//normalize all to 0 - 1
			var hue:Number = hsb.hue / 360;
			if(hue == 1) hue = 0;
			var saturation:Number = hsb.saturation / 100;
			var brightness:Number = hsb.brightness / 100;
			
			if(saturation == 0)
			{
				//gray
				return new RGBColor(brightness * 0xff, brightness * 0xff, brightness * 0xff);
			}
			
			var red:Number = 0;
			var green:Number = 0;
			var blue:Number = 0;
			
			var h:Number = hue * 6;
			var i:Number = Math.floor(h);
			var f:Number = h - i;
			var p:Number = brightness * (1 - saturation);
			var q:Number = brightness * (1 - f * saturation);
			//skip r and s because they could cause confusion with red and saturation
			var t:Number = brightness * (1 - (1 - f) * saturation);
			
			switch(i)
			{
				case 0:
					red = brightness;
					green = t;
					blue = p;
					break;
				case 1:
					red = q;
					green = brightness;
					blue = p;
					break;
				case 2:
					red = p;
					green = brightness
					blue = t;
					break;
				case 3:
					red = p
					green = q;
					blue = brightness;
					break;
				case 4:
					red = t;
					green = p;
					blue = brightness;
					break;
				case 5:
					red = brightness;
					green = p;
					blue = q;
					break;
			}
			
			//normalize all to range between 0 - 255
			red = Math.round(red * 0xff);
			green = Math.round(green * 0xff);
			blue = Math.round(blue * 0xff);
			
			return new RGBColor(red, green, blue);
		}
		
		/**
		 * Converts a uint color value to the RGB colorspace.
		 * 
		 * @param color		the input uint color value
		 * @return			the value converted to RGB
		 */
		public static function uintToRGB(color:uint):RGBColor
		{
			var red:Number = (color >> 16) & 0xff;
			var green:Number = (color >> 8) & 0xff;
			var blue:Number = color & 0xff;
			return new RGBColor(red, green, blue);
		}
		
		/**
		 * Converts an RGB color value to a standard uint color value.
		 * 
		 * @param rgb		the input RGB value
		 * @return			the value converted to uint
		 */
		public static function RGBTouint(rgb:RGBColor):uint
		{
			return (rgb.red << 16) + (rgb.green << 8) + rgb.blue;
		}
		
		/**
		 * Converts a uint color value to the HSB colorspace.
		 * 
		 * @param color		the input uinnt color value
		 * @return			the value converted to HSB
		 */
		public static function uintToHSB(color:uint):HSBColor
		{
			var rgb:RGBColor = uintToRGB(color);
			return ColorUtil.RGBToHSB(rgb);
		}
		
		/**
		 * Converts an HSB color value to a standard uint color value.
		 * 
		 * @param hsb		the input HSB value
		 * @return			the value converted to uint
		 */
		public static function HSBTouint(hsb:HSBColor):uint
		{
			var rgb:RGBColor = HSBToRGB(hsb);
			return ColorUtil.RGBTouint(rgb);
		}
		
		/**
		 * Converts an RGB color value to the CMY colorspace.
		 * 
		 * @param rgb		the input RGB value
		 * @return			the value converted to CMY
		 */
		public static function RGBToCMY(rgb:RGBColor):CMYColor
		{
			var cyan:Number = 1 - (rgb.red / 0xff);
			var magenta:Number = 1 - (rgb.green / 0xff);
			var yellow:Number = 1 - (rgb.blue / 0xff);
			return new CMYColor(cyan * 100, magenta * 100, yellow * 100);
		}
		
		/**
		 * Converts an CMY color value to the RGB colorspace.
		 * 
		 * @param cmy		the input CMY value
		 * @return			the value converted to RGB
		 */
		public static function CMYToRGB(cmy:CMYColor):RGBColor
		{
			var cyan:Number = cmy.cyan / 100;
			var magenta:Number = cmy.magenta / 100;
			var yellow:Number = cmy.yellow / 100;
			
			var red:Number = (1 - cyan) * 0xff;
			var green:Number = (1 - magenta) * 0xff;
			var blue:Number = (1 - yellow) * 0xff;
			
			return new RGBColor(red, green, blue);
		}
		
		/**
		 * Converts an CMY color value to the CMYK colorspace.
		 * 
		 * <p>(Note: In practice, color values in the CMYK colorspace
		 * must be calculated based on environmental information. This
		 * algorithm provides, at best, nothing more than an approximation.)</p>
		 * 
		 * @param cmy		the input CMY value
		 * @return			the value converted to CMYK
		 */
		public static function CMYToCMYK(cmy:CMYColor):CMYKColor
		{
			var cyan:Number = cmy.cyan / 100;
			var magenta:Number = cmy.magenta / 100;
			var yellow:Number = cmy.yellow / 100;
			
			var key:Number = Math.min(cyan, magenta, yellow, 1);
			if(key == 1)
			{
				return new CMYKColor(0, 0, 0, 100);
			}
			
			cyan = (cyan - key) / (1 - key);
			magenta = (magenta - key) / (1 - key);
			yellow = (yellow - key) / (1 - key);
			
			return new CMYKColor(cyan * 100, magenta * 100, yellow * 100, key * 100);
		}
		
		/**
		 * Converts an CMYK color value to the CMY colorspace.
		 * 
		 * <p>(Note: In practice, color values in the CMYK colorspace
		 * must be calculated based on environmental information. This
		 * algorithm provides, at best, nothing more than an approximation.)</p>
		 * 
		 * @param cmyk		the input CMYK value
		 * @return			the value converted to CMY
		 */
		public static function CMYKToCMY(cmyk:CMYKColor):CMYColor
		{
			var cyan:Number = cmyk.cyan / 100;
			var magenta:Number = cmyk.magenta / 100;
			var yellow:Number = cmyk.yellow / 100;
			var key:Number = cmyk.key / 100;
			
			cyan = cyan * (1 - key) + key;
			magenta = magenta * (1 - key) + key;
			yellow = yellow * (1 - key) + key;
			
			return new CMYColor(cyan * 100, magenta * 100, yellow * 100);
		}
		
		/**
		 * Converts an RGB color value to the CMYK colorspace.
		 * 
		 * <p>(Note: In practice, color values in the CMYK colorspace
		 * must be calculated based on environmental information. This
		 * algorithm provides, at best, nothing more than an approximation.)</p>
		 * 
		 * @param rgb		the input RGB value
		 * @return			the value converted to CMYK
		 */
		public static function RGBToCMYK(rgb:RGBColor):CMYKColor
		{
			var cmy:CMYColor = ColorUtil.RGBToCMY(rgb);
			return ColorUtil.CMYToCMYK(cmy);
		}
		
		/**
		 * Converts an CMYK color value to the RGB colorspace.
		 * 
		 * <p>(Note: In practice, color values in the CMYK colorspace
		 * must be calculated based on environmental information. This
		 * algorithm provides, at best, nothing more than an approximation.)</p>
		 * 
		 * @param cmyk		the input CMYK value
		 * @return			the value converted to RGB
		 */
		public static function CMYKToRGB(cmyk:CMYKColor):RGBColor
		{
			var cmy:CMYColor = ColorUtil.CMYKToCMY(cmyk);
			return ColorUtil.CMYToRGB(cmy);
		}
		
		/**
		 * Converts an uint color value to the CMY colorspace.
		 * 
		 * @param color		the input uint color value
		 * @return			the value converted to CMY
		 */
		public static function uintToCMY(color:uint):CMYColor
		{
			var rgb:RGBColor = ColorUtil.uintToRGB(color); 
			return ColorUtil.RGBToCMY(rgb);
		}
		
		/**
		 * Converts an CMY color value to a standard uint color value.
		 * 
		 * @param cmy		the input CMY value
		 * @return			the value converted to uint
		 */
		public static function CMYTouint(cmy:CMYColor):uint
		{
			var rgb:RGBColor = ColorUtil.CMYToRGB(cmy);
			return ColorUtil.RGBTouint(rgb);
		}
		
		/**
		 * Converts a uint color value to the CMYK colorspace.
		 * 
		 * <p>(Note: In practice, color values in the CMYK colorspace
		 * must be calculated based on environmental information. This
		 * algorithm provides, at best, nothing more than an approximation.)</p>
		 * 
		 * @param color		the input uint color value
		 * @return			the value converted to CMYK
		 */
		public static function uintToCMYK(color:uint):CMYKColor
		{
			var rgb:RGBColor = ColorUtil.uintToRGB(color); 
			return ColorUtil.RGBToCMYK(rgb);
		}
		
		/**
		 * Converts an CMYK color value to a standard uint color value.
		 * 
		 * <p>(Note: In practice, color values in the CMYK colorspace
		 * must be calculated based on environmental information. This
		 * algorithm provides, at best, nothing more than an approximation.)</p>
		 * 
		 * @param cmyk		the input CMYK value
		 * @return			the value converted to uint
		 */
		public static function CMYKTouint(cmyk:CMYKColor):uint
		{
			var rgb:RGBColor = ColorUtil.CMYKToRGB(cmyk);
			return ColorUtil.RGBTouint(rgb);
		}
		
		/**
		 * Converts an HSB color value to the CMYcolorspace.
		 * 
		 * @param hsb		the input HSB value
		 * @return			the value converted to CMY
		 */
		public static function HSBToCMY(hsb:HSBColor):CMYColor
		{
			var rgb:RGBColor = ColorUtil.HSBToRGB(hsb);
			return ColorUtil.RGBToCMY(rgb);
		}
		
		/**
		 * Converts an CMY color value to the HSB colorspace.
		 * 
		 * @param cmy		the input CMY value
		 * @return			the value converted to HSB
		 */
		public static function CMYToHSB(cmy:CMYColor):HSBColor
		{
			var rgb:RGBColor = ColorUtil.CMYToRGB(cmy);
			return ColorUtil.RGBToHSB(rgb);
		}
		
		/**
		 * Converts an HSB color value to the CMYK colorspace.
		 * 
		 * <p>(Note: In practice, color values in the CMYK colorspace
		 * must be calculated based on environmental information. This
		 * algorithm provides, at best, nothing more than an approximation.)</p>
		 * 
		 * @param hsb		the input HSB value
		 * @return			the value converted to CMYK
		 */
		public static function HSBToCMYK(hsb:HSBColor):CMYKColor
		{
			var rgb:RGBColor = ColorUtil.HSBToRGB(hsb);
			return ColorUtil.RGBToCMYK(rgb);
		}
		
		/**
		 * Converts an CMYK color value to the HSB colorspace.
		 * 
		 * <p>(Note: In practice, color values in the CMYK colorspace
		 * must be calculated based on environmental information. This
		 * algorithm provides, at best, nothing more than an approximation.)</p>
		 * 
		 * @param cmyk		the input CMYK value
		 * @return			the value converted to HSB
		 */
		public static function CMYKToHSB(cmyk:CMYKColor):HSBColor
		{
			var rgb:RGBColor = ColorUtil.CMYKToRGB(cmyk);
			return ColorUtil.RGBToHSB(rgb);
		}
	}
}