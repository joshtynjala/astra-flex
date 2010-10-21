/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
﻿package com.yahoo.astra.mx.controls.colorPickerClasses
{
	import com.yahoo.astra.utils.PointUtil;
	
	import flash.geom.Point;
	
	/**
	 * Enhances the DefaultColorViewer by dividing the color display area
	 * between a selected color and a preview color. The angle of this
	 * division may be customized.
	 * 
	 * @author Josh Tynjala
	 */
	public class DividedColorViewer extends DefaultColorViewer implements IColorPreviewViewer
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor
		 */
		public function DividedColorViewer()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * @private
		 * Storage for the showPreview property.
		 */
		private var _showPreview:Boolean = false;
		
		/**
		 * @inheritDoc
		 */
		public function get showPreview():Boolean
		{
			return this._showPreview;
		}
		
		/**
		 * @private
		 */
		public function set showPreview(value:Boolean):void
		{
			if(this._showPreview != value)
			{
				this._showPreview = value;
				this.invalidateDisplayList();
			}
		}
		
		/**
		 * @private
		 * Storage for the previewColor property.
		 */
		private var _previewColor:uint = 0x000000;
		
		/**
		 * @inheritDoc
		 */
		public function get previewColor():uint
		{
			return this._previewColor;
		}
		
		/**
		 * @private
		 */
		public function set previewColor(value:uint):void
		{
			if(this._previewColor != value)
			{
				this._previewColor = value;
				this.invalidateDisplayList();
			}
		}
		
		/**
		 * @private
		 * Storage for the angle property.
		 */
		private var _angle:Number = 45;
		
		/**
		 * The angle of division, in degrees.
		 */
		public function get angle():Number
		{
			return this._angle;
		}
		
		/**
		 * @private
		 */
		public function set angle(value:Number):void
		{
			if(this._angle != value)
			{
				this._angle = value % 90;
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
			
			this.graphics.clear();
			this.graphics.beginFill(this.color);
			this.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			this.graphics.endFill();
			
			if(this.showPreview)
			{
				
				var radians:Number = this.angle * Math.PI / 180;
				
				if(angle <= 45)
				{
					var length:Number = 1 / (Math.cos(radians) / unscaledWidth);
					var position:Point = Point.polar(length, radians);
					var yOffset:Number = (unscaledHeight - position.y) / 2;
					
					this.graphics.beginFill(this.previewColor);
					this.graphics.moveTo(0, unscaledHeight - yOffset);
					this.graphics.lineTo(unscaledWidth, yOffset);
					this.graphics.lineTo(unscaledWidth, unscaledHeight);
					this.graphics.lineTo(0, unscaledHeight);
					this.graphics.lineTo(0, unscaledHeight - yOffset);
					this.graphics.endFill();
				}
				else
				{
					length = 1 / (Math.sin(radians) / unscaledHeight);
					position = Point.polar(length, radians);
					var xOffset:Number = (unscaledWidth - position.x) / 2;
					
					this.graphics.beginFill(this.previewColor);
					this.graphics.moveTo(xOffset, unscaledHeight);
					this.graphics.lineTo(unscaledWidth - xOffset, 0);
					this.graphics.lineTo(unscaledWidth, 0);
					this.graphics.lineTo(unscaledWidth, unscaledHeight);
					this.graphics.lineTo(xOffset, unscaledHeight);
				}
			}
		}
		
	}
}