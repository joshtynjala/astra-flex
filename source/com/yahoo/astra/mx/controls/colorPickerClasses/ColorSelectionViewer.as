/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls.colorPickerClasses
{
	import mx.core.UIComponent;

	/**
	 * An advanced color selection indicators that also displays a color.
	 * 
	 * @author Josh Tynjala
	 */
	public class ColorSelectionViewer extends UIComponent implements IColorViewer
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		/**
		 * Constructor.
		 */
		public function ColorSelectionViewer()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * @private
		 * Storage for the color property.
		 */
		private var _color:uint = 0x000000;
		
		/**
		 * @inheritDoc
		 */
		public function get color():uint
		{
			return this._color;
		}
		
		/**
		 * @private
		 */
		public function set color(value:uint):void
		{
			if(this._color != value)
			{
				this._color = value;
				this.invalidateDisplayList();
			}
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
			
			var borderThickness:Number = this.getStyle("borderThickness");
			var borderColor:uint = this.getStyle("borderColor");
			
			var halfWidth:Number = unscaledWidth / 2;
			var halfHeight:Number = unscaledHeight / 2;
			var radius:Number = Math.min(halfWidth, halfHeight);
			
			this.graphics.clear();
			this.graphics.beginFill(borderColor);
			this.graphics.drawCircle(halfWidth, halfHeight, radius);
			this.graphics.endFill();
			this.graphics.beginFill(this.color)
			this.graphics.drawCircle(halfWidth, halfHeight, radius - borderThickness);
			this.graphics.endFill();
		}
		
	}
}