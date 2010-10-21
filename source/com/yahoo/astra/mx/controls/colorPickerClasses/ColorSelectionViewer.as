/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls.colorPickerClasses
{
	import mx.core.UIComponent;
	import com.yahoo.astra.mx.controls.colorPickerClasses.IColorViewer;
	import mx.styles.StyleManager;
	import mx.styles.CSSStyleDeclaration;

	/**
	 * An advanced color selection indicators that also displays a color.
	 * 
	 * @author Josh Tynjala
	 */
	public class ColorSelectionViewer extends UIComponent implements IColorViewer
	{
		
	//--------------------------------------
	//  Static Methods
	//--------------------------------------
	
		/**
		 * @private
		 * Sets the default style values for controls of this type.
		 */
		private static function initializeStyles():void
		{
			var styleDeclaration:CSSStyleDeclaration = StyleManager.getStyleDeclaration("ColorSelectionViewer");
			if(!styleDeclaration)
			{
				styleDeclaration = new CSSStyleDeclaration();
			}
			
			styleDeclaration.defaultFactory = function():void
			{
				this.borderColor = 0x000000;
				this.borderThickness = 2;
			};
			
			StyleManager.setStyleDeclaration("ColorSelectionViewer", styleDeclaration, false);
		}
		initializeStyles();
		
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