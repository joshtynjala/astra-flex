/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.skins.halo
{
	import mx.skins.Border;

	/**
	 * The skin for all the states of a color viewer that indicates editability.
	 * 
	 * @author Josh Tynjala
	 */
	public class EditableColorViewerSkin extends ColorViewerSkin
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function EditableColorViewerSkin()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * @private
		 */
		protected var arrowWidth:Number = 7;
		
		/**
		 * @private
		 */
		protected var arrowHeight:Number = 5;
		
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
	
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var arrowColor:uint = this.getStyle("iconColor");
			var arrowX:Number = (unscaledWidth - arrowWidth - bevelSize);
			var arrowY:Number = (unscaledHeight - arrowHeight - bevelSize);
			    
			switch(this.name)
			{
				case "upSkin":
				case "overSkin":
					// arrow background
					this.drawFill(arrowX, arrowY, arrowWidth, arrowHeight, backgroundColor, 1.0);                                                     
					
					// arrow
					this.drawArrow(arrowX + 1.5, arrowY + 1.5, arrowWidth - 3, arrowHeight - 3, arrowColor, 1.0);
					  
					break;
				case "downSkin":
					// arrow background
					this.drawFill(arrowX, arrowY, arrowWidth, arrowHeight, backgroundColor, 1.0);
					
					// arrow
					this.drawArrow(arrowX + 1.5, arrowY + 1.5, arrowWidth - 3, arrowHeight - 3, arrowColor, 1.0);
						
					break;
				case "disabledSkin":
				
					// arrow background                
					this.drawFill(arrowX, arrowY, arrowWidth, arrowHeight, backgroundColor, 1.0);
					
					// blurred arrow        
					this.drawArrow(arrowX + 1.5, arrowY + 1.5, arrowWidth - 3, arrowHeight - 3, 0x999999, 1.0);
						
					break;
			}
		}
	
		/**
		 * @private
		 * Draws the editor arrow.
		 */	
		protected function drawArrow(x:Number, y:Number, width:Number, height:Number, color:Number, alpha:Number):void
		{
			this.graphics.moveTo(x, y);
			this.graphics.beginFill(color, alpha);
			this.graphics.lineTo(x + width, y);
			this.graphics.lineTo(x + width / 2, height + y);
			this.graphics.lineTo(x, y);
			this.graphics.endFill();
		}
	
	}
}