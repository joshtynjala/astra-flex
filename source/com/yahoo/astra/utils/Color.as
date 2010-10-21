/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.utils
{
	import flash.utils.Dictionary;
	
	/**
	 * Color creates a list of common color names with corresponding hex values. 
	 * It can be used to retrive the common color name for a numerical value.
	 * 
	 * @author Alaric Cole
	 */
	public class Color extends Object
	{
		public static const AQUA:Color = new Color( 			"aqua", 0x00FFFF );
		public static const BLACK:Color = new Color( 			"black", 0x000000 );
		public static const BLUE:Color = new Color( 			"blue", 0x0000FF );
		public static const FUCHSIA:Color = new Color( 			"fuchsia", 0xFF00FF );
		public static const GRAY:Color = new Color( 			"gray", 0x808080 );
		public static const GREEN:Color = new Color( 			"green", 0x008000 );
		public static const LIME:Color = new Color( 			"lime", 0x00FF00 );
		public static const MAROON:Color = new Color( 			"maroon", 0x800000 );
		public static const NAVY:Color = new Color( 			"navy", 0x000080 );
		public static const OLIVE:Color = new Color( 			"olive", 0x808000 );
		public static const PURPLE:Color = new Color( 			"purple", 0x800080 );
		public static const RED:Color = new Color( 				"red", 0xFF0000 );
		public static const SILVER:Color = new Color( 			"silver", 0xC0C0C0 );
		public static const TEAL:Color = new Color( 			"teal", 0x008080 );
		public static const WHITE:Color = new Color( 			"white", 0xFFFFFF );
		public static const YELLOW:Color = new Color( 			"yellow", 0xFFFF00 );
		
		//additional colors are provided
		
	/* 	public static const ALICE_BLUE:Color = new Color( 			"aliceBlue", 0xF0F8FF );
		public static const ANTIQUE_WHITE:Color = new Color( 		"antiqueWhite", 0xFAEBD7 );
		public static const AQUAMARINE:Color = new Color( 			"aquamarine", 0x7FFFD4 );
		public static const AZURE:Color = new Color( 				"azure", 0xF0FFFF );
		public static const BEIGE:Color = new Color( 				"beige", 0xF5F5DC );
		public static const BISQUE:Color = new Color( 				"bisque", 0xFFE4C4 );
		public static const BLANCHED_ALMOND:Color = new Color( 		"blanchedAlmond", 0xFFEBCD );
		public static const BLUE_VIOLET:Color = new Color( 			"blueViolet", 0x8A2BE2 );
		public static const BROWN:Color = new Color( 				"brown", 0xA52A2A );
		public static const BURLY_WOOD:Color = new Color( 			"burlyWood", 0xDEB887 );
		public static const CADET_BLUE:Color = new Color( 			"cadetBlue", 0x5F9EA0 );
		public static const CHARTREUSE:Color = new Color( 			"chartreuse", 0x7FFF00 );
		public static const CHOCOLATE:Color = new Color( 			"chocolate", 0xD2691E );
		public static const CORAL:Color = new Color( 				"coral", 0xFF7F50 );
		public static const CORNFLOWER_BLUE:Color = new Color( 		"cornflowerBlue", 0x6495ED );
		public static const CORNSILK:Color = new Color( 			"cornsilk", 0xFFF8DC );
		public static const CRIMSON:Color = new Color( 				"crimson", 0xDC143C );
		public static const CYAN:Color = new Color( 				"cyan", 0x00FFFF );
		public static const DARK_BLUE:Color = new Color( 			"darkBlue", 0x00008B );
		public static const DARK_CYAN:Color = new Color( 			"darkCyan", 0x008B8B );
		public static const DARK_GOLDEN_ROD:Color = new Color( 		"darkGoldenRod", 0xB8860B );
		public static const DARK_GRAY:Color = new Color( 			"darkGray", 0xA9A9A9 );
		public static const DARK_GREY:Color = new Color( 			"darkGrey", 0xA9A9A9 );
		public static const DARK_GREEN:Color = new Color( 			"darkGreen", 0x006400 );
		public static const DARK_KHAKI:Color = new Color( 			"darkKhaki", 0xBDB76B );
		public static const DARK_MAGENTA:Color = new Color( 		"darkMagenta", 0x8B008B );
		public static const DARK_OLIVE_GREEN:Color = new Color( 	"darkOliveGreen", 0x556B2F );
		public static const DARK_ORANGE:Color = new Color( 			"darkOrange", 0xFF8C00 );
		public static const DARK_ORCHID:Color = new Color( 			"darkOrchid", 0x9932CC );
		public static const DARK_RED:Color = new Color( 			"darkRed", 0x8B0000 );
		public static const DARK_SALMON:Color = new Color( 			"darkSalmon", 0xE9967A );
		public static const DARK_SEA_GREEN:Color = new Color( 		"darkSeaGreen", 0x8FBC8F );
		public static const DARK_SLATE_BLUE:Color = new Color( 		"darkSlateBlue", 0x483D8B );
		public static const DARK_SLATE_GRAY:Color = new Color( 		"darkSlateGray", 0x2F4F4F );
		public static const DARK_SLATE_GREY:Color = new Color( 		"darkSlateGrey", 0x2F4F4F );
		public static const DARK_TURQUOISE:Color = new Color( 		"darkTurquoise", 0x00CED1 );
		public static const DARK_VIOLET:Color = new Color( 			"darkViolet", 0x9400D3 );
		public static const DEEP_PINK:Color = new Color( 			"deepPink", 0xFF1493 );
		public static const DEEP_SKY_BLUE:Color = new Color( 		"deepSkyBlue", 0x00BFFF );
		public static const DIM_GRAY:Color = new Color( 			"dimGray", 0x696969 );
		public static const DIM_GREY:Color = new Color( 			"dimGrey", 0x696969 );
		public static const DODGER_BLUE:Color = new Color( 			"dodgerBlue", 0x1E90FF );
		public static const FIRE_BRICK:Color = new Color( 			"fireBrick", 0xB22222 );
		public static const FLORAL_WHITE:Color = new Color( 		"floralWhite", 0xFFFAF0 );
		public static const FOREST_GREEN:Color = new Color( 		"forestGreen", 0x228B22 );
		public static const GAINSBORO:Color = new Color( 			"gainsboro", 0xDCDCDC );
		public static const GHOST_WHITE:Color = new Color( 			"ghostWhite", 0xF8F8FF );
		public static const GOLD:Color = new Color( 				"gold", 0xFFD700 );
		public static const GOLDEN_ROD:Color = new Color( 			"goldenRod", 0xDAA520 );
		public static const GREY:Color = new Color( 				"grey", 0x808080 );
		public static const GREEN_YELLOW:Color = new Color( 		"greenYellow", 0xADFF2F );
		public static const HONEY_DEW:Color = new Color( 			"honeyDew", 0xF0FFF0 );
		public static const HOT_PINK:Color = new Color( 			"hotPink", 0xFF69B4 );
		public static const INDIAN_RED:Color = new Color( 			"indianRed", 0xCD5C5C );
		public static const INDIGO:Color = new Color( 				"indigo", 0x4B0082 );
		public static const IVORY:Color = new Color( 				"ivory", 0xFFFFF0 );
		public static const KHAKI:Color = new Color( 				"khaki", 0xF0E68C );
		public static const LAVENDER:Color = new Color( 			"lavender", 0xE6E6FA );
		public static const LAVENDER_BLUSH:Color = new Color( 		"lavenderBlush", 0xFFF0F5 );
		public static const LAWN_GREEN:Color = new Color( 			"lawnGreen", 0x7CFC00 );
		public static const LEMON_CHIFFON:Color = new Color( 		"lemonChiffon", 0xFFFACD );
		public static const LIGHT_BLUE:Color = new Color( 			"lightBlue", 0xADD8E6 );
		public static const LIGHT_CORAL:Color = new Color( 			"lightCoral", 0xF08080 );
		public static const LIGHT_CYAN:Color = new Color( 			"lightCyan", 0xE0FFFF );
		public static const LIGHT_GOLDEN_ROD_YELLOW:Color=new Color("lightGoldenRodYellow", 0xFAFAD2 );
		public static const LIGHT_GRAY:Color = new Color( 			"lightGray", 0xD3D3D3 );
		public static const LIGHT_GREY:Color = new Color( 			"lightGrey", 0xD3D3D3 );
		public static const LIGHT_GREEN:Color = new Color( 			"lightGreen", 0x90EE90 );
		public static const LIGHT_PINK:Color = new Color( 			"lightPink", 0xFFB6C1 );
		public static const LIGHT_SALMON:Color = new Color( 		"lightSalmon", 0xFFA07A );
		public static const LIGHT_SEA_GREEN:Color = new Color( 		"lightSeaGreen", 0x20B2AA );
		public static const LIGHT_SKY_BLUE:Color = new Color( 		"lightSkyBlue", 0x87CEFA );
		public static const LIGHT_SLATE_GRAY:Color = new Color( 	"lightSlateGray", 0x778899 );
		public static const LIGHT_SLATE_GREY:Color = new Color( 	"lightSlateGrey", 0x778899 );
		public static const LIGHT_STEEL_BLUE:Color = new Color( 	"lightSteelBlue", 0xB0C4DE );
		public static const LIGHT_YELLOW:Color = new Color( 		"lightYellow", 0xFFFFE0 );
		public static const LIME_GREEN:Color = new Color( 			"limeGreen", 0x32CD32 );
		public static const LINEN:Color = new Color( 				"linen", 0xFAF0E6 );
		public static const MAGENTA:Color = new Color( 				"magenta", 0xFF00FF );
		public static const MEDIUM_AQUA_MARINE:Color = new Color( 	"mediumAquaMarine", 0x66CDAA );
		public static const MEDIUM_BLUE:Color = new Color( 			"mediumBlue", 0x0000CD );
		public static const MEDIUM_ORCHID:Color = new Color( 		"mediumOrchid", 0xBA55D3 );
		public static const MEDIUM_PURPLE:Color = new Color( 		"mediumPurple", 0x9370D8 );
		public static const MEDIUM_SEA_GREEN:Color = new Color( 	"mediumSeaGreen", 0x3CB371 );
		public static const MEDIUM_SLATE_BLUE:Color = new Color( 	"mediumSlateBlue", 0x7B68EE );
		public static const MEDIUM_SPRING_GREEN:Color = new Color( 	"mediumSpringGreen", 0x00FA9A );
		public static const MEDIUM_TURQUOISE:Color = new Color( 	"mediumTurquoise", 0x48D1CC );
		public static const MEDIUM_VIOLET_RED:Color = new Color( 	"mediumVioletRed", 0xC71585 );
		public static const MIDNIGHT_BLUE:Color = new Color( 		"midnightBlue", 0x191970 );
		public static const MINT_CREAM:Color = new Color( 			"mintCream", 0xF5FFFA );
		public static const MISTY_ROSE:Color = new Color( 			"mistyRose", 0xFFE4E1 );
		public static const MOCCASIN:Color = new Color( 			"moccasin", 0xFFE4B5 );
		public static const NAVAJO_WHITE:Color = new Color( 		"navajoWhite", 0xFFDEAD );
		public static const OLD_LACE:Color = new Color( 			"oldLace", 0xFDF5E6 );
		public static const OLIVE_DRAB:Color = new Color( 			"oliveDrab", 0x6B8E23 );
		public static const ORANGE:Color = new Color( 				"orange", 0xFFA500 );
		public static const ORANGE_RED:Color = new Color( 			"orangeRed", 0xFF4500 );
		public static const ORCHID:Color = new Color( 				"orchid", 0xDA70D6 );
		public static const PALE_GOLDEN_ROD:Color = new Color( 		"paleGoldenRod", 0xEEE8AA );
		public static const PALE_GREEN:Color = new Color( 			"paleGreen", 0x98FB98 );
		public static const PALE_TURQUOISE:Color = new Color( 		"paleTurquoise", 0xAFEEEE );
		public static const PALE_VIOLET_RED:Color = new Color( 		"paleVioletRed", 0xD87093 );
		public static const PAPAYA_WHIP:Color = new Color( 			"papayaWhip", 0xFFEFD5 );
		public static const PEACH_PUFF:Color = new Color( 			"peachPuff", 0xFFDAB9 );
		public static const PERU:Color = new Color( 				"peru", 0xCD853F );
		public static const PINK:Color = new Color( 				"pink", 0xFFC0CB );
		public static const PLUM:Color = new Color( 				"plum", 0xDDA0DD );
		public static const POWDER_BLUE:Color = new Color( 			"powderBlue", 0xB0E0E6 );
		public static const ROSY_BROWN:Color = new Color( 			"rosyBrown", 0xBC8F8F );
		public static const ROYAL_BLUE:Color = new Color( 			"royalBlue", 0x4169E1 );
		public static const SADDLE_BROWN:Color = new Color( 		"saddleBrown", 0x8B4513 );
		public static const SALMON:Color = new Color( 				"salmon", 0xFA8072 );
		public static const SANDY_BROWN:Color = new Color( 			"sandyBrown", 0xF4A460 );
		public static const SEA_GREEN:Color = new Color( 			"seaGreen", 0x2E8B57 );
		public static const SEA_SHELL:Color = new Color( 			"seaShell", 0xFFF5EE );
		public static const SIENNA:Color = new Color( 				"sienna", 0xA0522D );
		public static const SKY_BLUE:Color = new Color( 			"skyBlue", 0x87CEEB );
		public static const SLATE_BLUE:Color = new Color( 			"slateBlue", 0x6A5ACD );
		public static const SLATE_GRAY:Color = new Color( 			"slateGray", 0x708090 );
		public static const SLATE_GREY:Color = new Color( 			"slateGrey", 0x708090 );
		public static const SNOW:Color = new Color( 				"snow", 0xFFFAFA );
		public static const SPRING_GREEN:Color = new Color( 		"springGreen", 0x00FF7F );
		public static const STEEL_BLUE:Color = new Color( 			"steelBlue", 0x4682B4 );
		public static const TAN:Color = new Color( 					"tan", 0xD2B48C );
		public static const THISTLE:Color = new Color( 				"thistle", 0xD8BFD8 );
		public static const TOMATO:Color = new Color( 				"tomato", 0xFF6347 );
		public static const TURQUOISE:Color = new Color( 			"turquoise", 0x40E0D0 );
		public static const VIOLET:Color = new Color( 				"violet", 0xEE82EE );
		public static const WHEAT:Color = new Color( 				"wheat", 0xF5DEB3 );
		public static const WHITE_SMOKE:Color = new Color( 			"whiteSmoke", 0xF5F5F5 );
		public static const YELLOW_GREEN:Color = new Color( 		"yellowGreen", 0x9ACD32 ); 
		*/

		/**
		 * @private
		 * 
		 * Storage for the name property.
		 */
		private var _name:String;
		
		/**
		 * @private
		 * 
		 * Storage for the hexValue property.
		 */
		private var _hexValue:uint;
			
		/**
		 * @private
		 * 
		 * A Dictionary of the common names.
		 */
		protected static var names:Dictionary;
		
		/**
		 * @private
		 * 
		 * A Dictionary of hexadecimal values.
		 */
		protected static var hex:Dictionary;
		
	
		/**
		 * Constructor.
		 * 
		 * @param name The string name of a color.
		 * @param hexValue The hexadecimal value of a color.
		 */
		public function Color( name:String, hexValue:uint )
		{
			if( !names ) names = new Dictionary();
			if( !hex ) hex = new Dictionary();
			
			this.name = name;
			this.hexValue = hexValue;
		}
		
		/**
		 * The common name of a color.
		 */
		public function get name():String
		{
			return _name;
		}
		
		/**
		 * @private
		 */
		public function set name( value:String ):void
		{
			_name = value;
			names[ value.toLowerCase() ] = this;
		}
		
		/**
		 * The hexadecimal value of a color.
		 */
		public function get hexValue():uint
		{
			return _hexValue;
		}
		
		/**
		 * @private
		 */
		public function set hexValue( value:uint ):void
		{
			_hexValue = value;
			hex[value] = this;
		}
		
		/**
		 * Returns the corresponding Color object from the string name.
		 * 
		 * @param name The string name of a color (case-insensitive).
		 * @return A Color object.
		 */
		public static function getColorByName( name:String ):Color
		{
			return names[ name.toLowerCase() ];
		}
		
		/**
		 * Returns the corresponding Color object from the hexadecimal value.
		 * 
		 * @param hexValue The hexadecimal value of a color.
		 * @return A Color object.
		 */
		public static function getColorByHexValue( hexValue:uint ):Color
		{
			if ( hex[ hexValue ]) 
			{
				return hex[ hexValue ];
			}
			else return null;
		}
		
		/**
		 * Returns a string value using the common color name.
		 * 
		 * @return String
		 */		
		 public function toString():String
		 { 
			return name;
		 }
	}
}