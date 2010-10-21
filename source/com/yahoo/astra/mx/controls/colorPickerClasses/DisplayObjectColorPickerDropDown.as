/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls.colorPickerClasses
{
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	import mx.events.ColorPickerEvent;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * Dispatched when the selected color 
	 * changes as a result of user interaction.
	 *
	 * @eventType mx.events.ColorPickerEvent.CHANGE
	 */
	[Event(name="change", type="mx.events.ColorPickerEvent")]

	/**
	 * Dispatched when the user rolls the mouse over of a color.
	 *
	 * @eventType mx.events.ColorPickerEvent.ITEM_ROLL_OVER
	 */
	[Event(name="itemRollOver", type="mx.events.ColorPickerEvent")]
	
	/**
	 * Dispatched when the user rolls the mouse out of a color.
	 *
	 * @eventType mx.events.ColorPickerEvent.ITEM_ROLL_OUT
	 */
	[Event(name="itemRollOut", type="mx.events.ColorPickerEvent")]

	[DefaultProperty("displayObject")]
	/**
	 * A drop-down with a DisplayObject whose pixels are used for selection for the DropDownColorPicker control.
	 * 
	 * @see com.yahoo.astra.mx.controls.DropDownColorPicker
	 * 
	 * @author Josh Tynjala
	 */
	public class DisplayObjectColorPickerDropDown extends BaseColorPickerDropDown implements IColorPicker
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor
		 */
		public function DisplayObjectColorPickerDropDown()
		{
			super();
			this.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * @private
		 * For interaction that Bitmap does not provide.
		 */
		private var _bitmapWrapper:UIComponent;
		
		/**
		 * The bitmap representation of the display object that is displayed.
		 */
		protected var bitmap:Bitmap;
		
		/**
		 * @private
		 * Flag indicating that the displayObject property has changed.
		 */
		protected var displayObjectChanged:Boolean = false;
		
		/**
		 * @private
		 * Storage for the displayObject property.
		 */
		private var _displayObject:DisplayObject;
		
		/**
		 * The DisplayObject that will be displayed in this picker.
		 * The user will be able to select a pixel as the selectedColor.
		 */
		public function get displayObject():DisplayObject
		{
			return this._displayObject;
		}
		
		/**
		 * @private
		 */
		public function set displayObject(value:DisplayObject):void
		{
			if(this._displayObject != value)
			{
				this._displayObject = value;
				this.displayObjectChanged = true;
				this.invalidateProperties();
				this.invalidateSize();
				this.invalidateDisplayList();
			}
		}
		
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			//we wrap the bitmap in a UIComponent to get some mouse events
			this._bitmapWrapper = new UIComponent();
			this._bitmapWrapper.addEventListener(MouseEvent.ROLL_OVER, bitmapRollOverHandler);
			this._bitmapWrapper.addEventListener(MouseEvent.ROLL_OUT, bitmapRollOutHandler);
			this.addChild(this._bitmapWrapper);
			
			if(!this.bitmap)
			{
				this.bitmap = new Bitmap();
				this._bitmapWrapper.addChild(this.bitmap);
			}
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(this.displayObjectChanged)
			{
				if(this.bitmap.bitmapData)
				{
					//don't forget to dispose!
					this.bitmap.bitmapData.dispose();
					this.bitmap.bitmapData = null;
				}
				
				//only draw to the bitmapData if the displayObject exists and width and height are greater than zero
				if(this._displayObject && this._displayObject.width > 0 && this.displayObject.height > 0)
				{
					var data:BitmapData = new BitmapData(this._displayObject.width, this._displayObject.height, true);
					data.draw(this._displayObject);
					this.bitmap.bitmapData = data;
				}
				this.displayObjectChanged = false;
			}
		}
		
		/**
		 * @private
		 */
		override protected function measure():void
		{
			super.measure();
			
			var paddingLeft:Number = this.getStyle("paddingLeft");
			var paddingTop:Number = this.getStyle("paddingTop");
			var paddingRight:Number = this.getStyle("paddingRight");
			var paddingBottom:Number = this.getStyle("paddingBottom");
			var verticalGap:Number = this.getStyle("verticalGap");
			
			if(this.displayObject)
			{
				this.measuredWidth = Math.max(this.measuredWidth, this.displayObject.width + paddingLeft + paddingRight);
				this.measuredHeight += this.displayObject.height;
			}
			
			this.measuredMinWidth = this.measuredWidth;
			this.measuredMinHeight = this.measuredHeight;
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var paddingLeft:Number = this.getStyle("paddingLeft");
			var paddingTop:Number = this.getStyle("paddingTop");
			var paddingRight:Number = this.getStyle("paddingRight");
			var paddingBottom:Number = this.getStyle("paddingBottom");
			
			var bitmapWidth:Number = unscaledWidth - paddingLeft - paddingRight;
			var bitmapHeight:Number = unscaledHeight - this.yPositionOffset - paddingBottom;
			
			this._bitmapWrapper.x = paddingLeft;
			this._bitmapWrapper.y = this.yPositionOffset;
			this._bitmapWrapper.setActualSize(bitmapWidth, bitmapHeight);
			
			this.bitmap.width = bitmapWidth;
			this.bitmap.height = bitmapHeight;
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
		
		/**
		 * @private
		 * When the bitmap is clicked, update the selected color and notify listeners.
		 */
		protected function clickHandler(event:MouseEvent):void
		{
			if(this.bitmap && this.bitmap.hitTestPoint(this.stage.mouseX, this.stage.mouseY))
			{
				this.selectedColor = this.bitmap.bitmapData.getPixel(this.bitmap.mouseX, this.bitmap.mouseY);
				this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, this.selectedColor));
			}
		}
		
		/**
		 * @private
		 * Get rollover information for the bitmap.
		 */
		protected function bitmapRollOverHandler(event:MouseEvent):void
		{
			this.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
		}
		
		protected function mouseMoveHandler(event:MouseEvent):void
		{
			if(this.bitmap)
			{
				//only if we're in the bounds of the bitmap
				if(this.bitmap.hitTestPoint(this.stage.mouseX, this.stage.mouseY))
				{
					var color:uint = this.bitmap.bitmapData.getPixel(this.bitmap.mouseX, this.bitmap.mouseY);
					this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OUT));
					this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OVER, false, false, -1, color));
					this.previewColor = color;
				}
			}
		}
		
		/**
		 * @private
		 * Update the preview color on rollout.
		 */
		protected function bitmapRollOutHandler(event:MouseEvent):void
		{
			this.previewColor = this.selectedColor;
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OUT));
			this.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
	}
}