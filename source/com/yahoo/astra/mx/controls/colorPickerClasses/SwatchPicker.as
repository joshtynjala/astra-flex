/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls.colorPickerClasses
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.colorPickerClasses.WebSafePalette;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.events.ColorPickerEvent;
	import mx.events.FlexEvent;
	import mx.managers.IFocusManagerComponent;
	import mx.styles.ISimpleStyleClient;
	
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
	 * Dispatched when the user rolls the mouse out of a swatch.
	 *
	 * @eventType mx.events.ColorPickerEvent.ITEM_ROLL_OUT
	 */
	[Event(name="itemRollOut", type="mx.events.ColorPickerEvent")]
	
	/**
	 * Dispatched when the user rolls the mouse over a swatch.
	 *
	 * @eventType mx.events.ColorPickerEvent.ITEM_ROLL_OVER
	 */
	[Event(name="itemRollOver", type="mx.events.ColorPickerEvent")]

	/**
	 * A grid of selectable color swatches.
	 * 
	 * @author Josh Tynjala
	 */
	public class SwatchPicker extends UIComponent implements IColorPicker, IFocusManagerComponent
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		/**
		 * Constructor.
		 */
		public function SwatchPicker()
		{
			super();
			
			//the default palette
			var palette:WebSafePalette = new WebSafePalette();
			this.colorList = palette.getList().toArray();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The skin for a selected or hightlighted swatches.
		 */
		protected var swatchHighlight:IFlexDisplayObject;
		
		/**
		 * The swatch instances.
		 */
		protected var swatches:Array = [];
		
		/**
		 * @private
		 * A cache for reusing swatches on redraw.
		 */
		protected var swatchCache:Array;
		
		/**
		 * @private
		 * Storage for the selectedColor property.
		 */
		private var _selectedColor:uint = 0x000000;
		
		[Bindable("valueCommit")]
		/**
		 * @inheritDoc
		 */
		public function get selectedColor():uint
		{
			return this._selectedColor;
		}
		
		/**
		 * @private
		 */
		public function set selectedColor(value:uint):void
		{
			if(this._selectedColor != value)
			{
				this._selectedColor = value;
				this.focusedIndex = this._colorList.indexOf(this._selectedColor);
				this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			}
		}
		
		private var _focusedIndex:int = -1;

		[Bindable(event="focusedIndexChange")]
		/**
		 * The color that is highlighted.
		 */
		public function get focusedIndex():int
		{
			return this._focusedIndex;
		}

		/**
		 * @private
		 */
		public function set focusedIndex(value:int):void
		{
			if(this._focusedIndex !== value)
			{
				if(this._focusedIndex >= 0)
				{
					this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OUT, false, false, this._focusedIndex, this._colorList[this._focusedIndex]));
				}
				this._focusedIndex = value;
				if(this._focusedIndex >= 0)
				{
					this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OVER, false, false, this._focusedIndex, this._colorList[this._focusedIndex]));
				}
				this.invalidateDisplayList();
				this.dispatchEvent(new Event("focusedIndexChange"));
			}
		}

		
		/**
		 * @private
		 * Storage for the colorList property.
		 */
		private var _colorList:Array;
		
		[Bindable]
		/**
		 * The list of colors to be displayed by swatches.
		 */
		public function get colorList():Array
		{
			return this._colorList;
		}
		
		/**
		 * @private
		 */
		public function set colorList(value:Array):void
		{
			this._colorList = value;
			this.invalidateSize();
			this.invalidateDisplayList();
		}
		
		//TODO: Add colorField and labelField
		
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			if(!this.swatchHighlight)
			{
				var swatchHighlightSkin:Class = this.getStyle("swatchHighlightSkin");
				if(swatchHighlightSkin)
				{
					this.swatchHighlight = new swatchHighlightSkin();
					if(this.swatchHighlight is ISimpleStyleClient)
					{
						ISimpleStyleClient(this.swatchHighlight).styleName = this;
					}
					this.addChild(DisplayObject(this.swatchHighlight));
				}
			}
		}
		
		/**
		 * @private
		 */
		override protected function measure():void
		{
			super.measure();
			var columnCount:int = getStyle("columnCount");
			var borderThickness:Number = getStyle("borderThickness");
			var swatchWidth:Number = getStyle("swatchWidth");
			var swatchHeight:Number = getStyle("swatchHeight");
			var horizontalGap:Number = getStyle("horizontalGap");
			var verticalGap:Number = getStyle("verticalGap");
        
        	var swatchCount:int = this._colorList.length;
        	var rowCount:int = swatchCount / columnCount;
        
			this.measuredWidth = (swatchWidth * columnCount) + horizontalGap * (columnCount - 1) + 2 * borderThickness;
			this.measuredHeight = (swatchHeight * rowCount) + verticalGap * (rowCount - 1) + 2 * borderThickness;
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var backgroundColor:uint = getStyle("backgroundColor");
			var swatchWidth:Number = getStyle("swatchWidth");
			var swatchHeight:Number = getStyle("swatchHeight");
			
			if(this.swatchHighlight)
			{
				this.swatchHighlight.setActualSize(swatchWidth, swatchHeight);
			}
			
			this.graphics.clear();
			this.graphics.beginFill(backgroundColor, 1);
			this.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			this.graphics.endFill();
			
			this.createCache();
			this.updateSwatches();
			this.clearCache();
		}
		
		/**
		 * @private
		 * Moves all the current swatches into the cache to be reused.
		 */
		protected function createCache():void
		{
			this.swatchCache = this.swatches.concat();
			this.swatches = [];
		}
		
		/**
		 * @private
		 * Updates the layout of swatches with the current colorList.
		 */
		protected function updateSwatches():void
		{
			if(!this._colorList)
			{
				return;
			}
			
			var columnCount:int = this.getStyle("columnCount");
			var horizontalGap:Number = this.getStyle("horizontalGap");
			var borderThickness:Number = this.getStyle("borderThickness");
			var swatchHeight:Number = this.getStyle("swatchHeight");
			var swatchWidth:Number = this.getStyle("swatchWidth");
			var verticalGap:Number = this.getStyle("verticalGap");
			
			var rowCount:int = this._colorList.length / columnCount;
			
			for(var i:int = 0; i < rowCount; i++)
			{
				for(var j:int = 0; j < columnCount; j++)
				{
					var index:int = (columnCount * i) + j;
					if(index >= this._colorList.length) break;
					var swatchColor:uint = this._colorList[index] as uint;
					var swatch:Sprite = this.getSwatch();
					
					var posX:Number = borderThickness + (swatchWidth * j) + (horizontalGap * j);
					var posY:Number = borderThickness + (swatchHeight * i) + (verticalGap * i);
					
					swatch.graphics.beginFill(swatchColor);
					swatch.graphics.drawRect(0, 0, swatchWidth, swatchHeight);
					swatch.graphics.endFill();
					swatch.x = posX;
					swatch.y = posY;
					this.swatches.push(swatch);
				}
			}
			
			this.highlightSwatch(this._focusedIndex);
		}
		
		/**
		 * @private
		 * Gets a swatch from the cache or creates a new swatch, if needed.
		 */
		protected function getSwatch():Sprite
		{
			if(this.swatchCache.length > 0)
			{
				return Sprite(this.swatchCache.shift());
			}
			var swatch:Sprite = new Sprite();
			swatch.addEventListener(MouseEvent.CLICK, swatchClickHandler);
			swatch.addEventListener(MouseEvent.ROLL_OVER, swatchRollOverHandler);
			swatch.addEventListener(MouseEvent.ROLL_OUT, swatchRollOutHandler);
			this.addChildAt(swatch, 0);
			return swatch;
		}
		
		/**
		 * @private
		 * Removes remaining swatches that are left unused.
		 */
		protected function clearCache():void
		{
			var cacheLength:int = this.swatchCache.length;
			for(var i:int = 0; i < cacheLength; i++)
			{
				var swatch:Shape = Shape(this.swatchCache.pop());
				swatch.removeEventListener(MouseEvent.CLICK, swatchClickHandler);
				swatch.removeEventListener(MouseEvent.ROLL_OVER, swatchRollOverHandler);
				swatch.removeEventListener(MouseEvent.ROLL_OUT, swatchRollOutHandler);
				this.removeChild(swatch);
			}
		}
		
		/**
		 * @private
		 * Puts the swatch highlight over the specified swatch.
		 */
		protected function highlightSwatch(index:int):void
		{
			if(this.swatchHighlight && index >= 0)
			{
				var swatch:Sprite = this.swatches[index] as Sprite;
				if(!swatch)
				{
					this.swatchHighlight.visible = false
					return;
				}
				this.swatchHighlight.x = swatch.x;
				this.swatchHighlight.y = swatch.y;
				this.swatchHighlight.visible = true;
			}
			else
			{
				this.swatchHighlight.visible = false;
			}
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
		
		/**
		 * @private
		 * Updates the highlight on swatch rollover and notifies listeners.
		 */
		protected function swatchRollOverHandler(event:MouseEvent):void
		{
			this.focusedIndex = this.swatches.indexOf(event.currentTarget);
		}
		
		/**
		 * @private
		 * Updates the highlight on swatch rollout and notifies listeners.
		 */
		protected function swatchRollOutHandler(event:MouseEvent):void
		{
			this.focusedIndex = -1;
		}
		
		/**
		 * @private
		 * Updates the selected color and notifies listeners of the change.
		 */
		protected function swatchClickHandler(event:MouseEvent):void
		{
			var index:int = this.swatches.indexOf(event.currentTarget);
			var color:uint = this._colorList[index];
			this.selectedColor = color;
			this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, index, color));
		}
		
		/**
		 * @private
		 * Keyboard navigation for swatch highlighting.
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			super.keyDownHandler(event);
			
			if(event.keyCode == Keyboard.ENTER)
			{
				this.selectedColor = this._colorList[this.focusedIndex];
				this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, this._focusedIndex, this._selectedColor));
				return;
			}
				
			var columnCount:int = this.getStyle("columnCount");
			var rowCount:int = this._colorList.length / columnCount;
			var currentRow:int = Math.floor(this.focusedIndex / columnCount);
			
			var index:int = 0;
			switch(event.keyCode)
			{
				case Keyboard.UP:
					index = (this._focusedIndex - columnCount < 0) ?
							   ((rowCount - 1) * columnCount + this._focusedIndex + 1) : (this._focusedIndex - columnCount);
					break;
				case Keyboard.DOWN:
					index = (this._focusedIndex + columnCount > this._colorList.length) ?
							   ((this._focusedIndex - 1) - (rowCount - 1) * columnCount) : (this._focusedIndex + columnCount);
					break;
				case Keyboard.LEFT:
					index = this._focusedIndex < 1 ? this._colorList.length - 1 : this._focusedIndex - 1;
					break;
				case Keyboard.RIGHT:
					index = this._focusedIndex >= this._colorList.length - 1 ? 0 : this._focusedIndex + 1;
					break;
				case Keyboard.PAGE_UP:
					index = this._focusedIndex - currentRow * columnCount;
					break;
				case Keyboard.PAGE_DOWN:
					index = this._focusedIndex + (rowCount - 1) * columnCount - currentRow * columnCount;
					break;
				case Keyboard.HOME:
					index = this._focusedIndex - (this._focusedIndex - currentRow * columnCount);
					break;
				case Keyboard.END:
					index = this._focusedIndex + (currentRow * columnCount - this._focusedIndex) + (columnCount - 1);
					break;
			}
			this.focusedIndex = index;
		}
	}
}