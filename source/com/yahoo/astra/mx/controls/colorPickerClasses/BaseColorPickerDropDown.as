/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls.colorPickerClasses
{
	import com.yahoo.astra.mx.skins.halo.ColorViewerSimpleSkin;
	
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.events.ColorPickerEvent;
	import mx.events.FlexEvent;
	import mx.managers.IFocusManagerContainer;
	import mx.skins.halo.SwatchPanelSkin;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.ISimpleStyleClient;
	import mx.styles.StyleManager;
	import mx.styles.StyleProxy;
	
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
	 * Dispatched when the user rolls the mouse out of a color.
	 *
	 * @eventType mx.events.ColorPickerEvent.ITEM_ROLL_OUT
	 */
	[Event(name="itemRollOut", type="mx.events.ColorPickerEvent")]
	
	/**
	 * Dispatched when the user rolls the mouse over a color.
	 *
	 * @eventType mx.events.ColorPickerEvent.ITEM_ROLL_OVER
	 */
	[Event(name="itemRollOver", type="mx.events.ColorPickerEvent")]
	
	/**
	 * An abstract class for drop-downs used by the DropDownColorPicker.
	 * Automatically contains a HexColorInput and an IColorViewer (initialized
	 * as a DefaultColorViewer. Both of these controls may be overridden in
	 * subclasses.
	 * 
	 * @see com.yahoo.astra.mx.controls.DropDownColorPicker
	 * @see com.yahoo.astra.mx.controls.colorPickerClasses.HexColorInput
	 * @see com.yahoo.astra.mx.controls.colorPickerClasses.IColorViewer
	 * @see com.yahoo.astra.mx.controls.colorPickerClasses.DefaultColorViewer
	 * 
	 * @author Josh Tynjala
	 */
	public class BaseColorPickerDropDown extends UIComponent implements IColorPicker, IFocusManagerContainer
	{
		
	//--------------------------------------
	//  Static Methods
	//--------------------------------------
	
		/**
		 * @private
		 * Sets the default style values for this control type.
		 */
		private static function initializeStyles():void
		{
			var styleDeclaration:CSSStyleDeclaration = StyleManager.getStyleDeclaration("BaseColorPickerDropDown");
			if(!styleDeclaration)
			{
				styleDeclaration = new CSSStyleDeclaration();
			}
			
			styleDeclaration.defaultFactory = function():void
			{
				this.backgroundColor = 0xe5e6e7;
				this.borderColor = 0xa5a9aE;
				this.borderSkin = SwatchPanelSkin;
				this.fontSize = 11;
				this.highlightColor = 0xffffff;
				this.paddingLeft = 5;
				this.paddingTop = 5;
				this.paddingRight = 5;
				this.paddingBottom = 5;
				this.shadowColor = 0x4d555e;
				this.showColorViewer = true;
				this.showColorInput = true;
				this.verticalGap = 4;
				this.horizontalGap = 4;
				this.previewWidth = 45;
				this.previewHeight = 22;
				this.previewSkin = ColorViewerSimpleSkin;
			};
			
			StyleManager.setStyleDeclaration("BaseColorPickerDropDown", styleDeclaration, false);
		}
		initializeStyles();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		/**
		 * Constructor.
		 */
		public function BaseColorPickerDropDown()
		{
			super();
			this.tabChildren = true;
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The border object.
		 */
		protected var border:IFlexDisplayObject;
		
		/**
		 * The viewer for the currently selected/previewed color.
		 */
		protected var viewer:IColorViewer;
		
		/**
		 * The text input control for hex color values.
		 */
		protected var hexInput:HexColorInput;
		
		/**
		 * @private
		 * Storage for the viewerStyleFilter property.
		 */
		private var _viewerStyleFilter:Object =
		{
			"previewSkin" : "skin"
		}
		
		/**
		 * @private
		 * The style filter for the viewer control.
		 */
		protected function get viewerStyleFilter():Object
		{
			return this._viewerStyleFilter;
		}
		
		/**
		 * @private
		 * Flag indicating the the selected color has changed.
		 */
		protected var selectedColorChanged:Boolean = false;
		
		/**
		 * @private
		 * Storage for the selectedColor property.
		 */
		private var _selectedColor:uint;
		
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
				this.selectedColorChanged = true;
				this.invalidateProperties();
        		this.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			}
			this.previewColor = value;
		}
		
		/**
		 * @private
		 * Storage for the previewColor property.
		 */
		private var _previewColor:uint = 0x000000;
		
		/**
		 * @inheritDoc
		 */
		protected function get previewColor():uint
		{
			return this._previewColor;
		}
		
		/**
		 * @private
		 */
		protected function set previewColor(value:uint):void
		{
			if(this._previewColor != value)
			{
				this._previewColor = value;
				this.invalidateProperties();
			}
		}
		
		/**
		 * @private
		 * Used for measurement and positioning.
		 */
		protected var yPositionOffset:Number = 0;
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		override public function setFocus():void
	    {	
			var showColorInput:Boolean = this.getStyle("showColorInput");
	        if(showColorInput)
	        {
	            this.hexInput.setFocus();
	        }
	        else super.setFocus();
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
			
			if(!this.border)
			{
				var borderSkin:Class = this.getStyle("borderSkin") as Class;
				if(borderSkin)
				{
					this.border = new borderSkin();
					this.border.name = "swatchPanelBorder";
					if(this.border is ISimpleStyleClient)
					{
						ISimpleStyleClient(this.border).styleName = this;
					}
					this.addChild(DisplayObject(this.border));
				} 
			}
			
			if(!this.viewer)
			{
				this.viewer = new DefaultColorViewer();
				UIComponent(this.viewer).tabEnabled = false;
				if(this.viewer is ISimpleStyleClient)
				{
					ISimpleStyleClient(this.viewer).styleName = new StyleProxy(this, this.viewerStyleFilter);
				}
				this.addChild(DisplayObject(this.viewer));
			}
			
			if(!this.hexInput)
			{
				this.hexInput = new HexColorInput();
				this.hexInput.addEventListener(ColorPickerEvent.CHANGE, colorInputChangeHandler);
				this.hexInput.addEventListener(KeyboardEvent.KEY_DOWN, colorInputKeyDownHandler);
				this.addChild(this.hexInput);
			}
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			this.viewer.visible = this.getStyle("showColorViewer");
			this.hexInput.visible = this.getStyle("showColorInput");
			this.viewer.color = this.hexInput.selectedColor = this.previewColor;
			
			this.selectedColorChanged = false;
		}
		
		/**
		 * @private
		 */
		override protected function measure():void
		{
			super.measure();
			
			var paddingLeft:Number = this.getStyle("paddingLeft");
			var paddingRight:Number = this.getStyle("paddingRight");
			var paddingTop:Number = this.getStyle("paddingTop");
			var paddingBottom:Number = this.getStyle("paddingBottom");
			var verticalGap:Number = this.getStyle("verticalGap");
			var horizontalGap:Number = this.getStyle("horizontalGap");
			
            var previewWidth:Number = getStyle("previewWidth");
            var previewHeight:Number = getStyle("previewHeight");
			var showColorViewer:Boolean = this.getStyle("showColorViewer");
			var showColorInput:Boolean = this.getStyle("showColorInput");
			
			this.measuredWidth = paddingLeft + paddingRight;
			this.measuredHeight = paddingTop + paddingBottom;
			
			var extraControlsWidth:Number = 0;
			var extraControlsHeight:Number = 0;
			if(showColorViewer)
			{
				extraControlsWidth += previewWidth;
				extraControlsHeight = Math.max(extraControlsHeight, previewHeight);
			}
			
			if(showColorInput)
			{
				extraControlsWidth += this.hexInput.measuredWidth;
				extraControlsHeight = Math.max(extraControlsHeight, this.hexInput.measuredHeight);
			}
			
			if(showColorViewer && showColorInput)
			{
				extraControlsWidth += horizontalGap;
			}
			
			this.measuredWidth += extraControlsWidth;
			this.measuredHeight += extraControlsHeight;
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			this.border.setActualSize(unscaledWidth, unscaledHeight);
			
			var paddingLeft:Number = this.getStyle("paddingLeft");
			var paddingTop:Number = this.getStyle("paddingTop");
			var horizontalGap:Number = this.getStyle("horizontalGap");
			var verticalGap:Number = this.getStyle("verticalGap");
			
            var previewWidth:Number = getStyle("previewWidth");
            var previewHeight:Number = getStyle("previewHeight");
			var showColorViewer:Boolean = this.getStyle("showColorViewer");
			var showColorInput:Boolean = this.getStyle("showColorInput");
			
			this.yPositionOffset = 0;
			
			var xPosition:Number = paddingLeft;
			if(showColorViewer)
			{
				this.viewer.setActualSize(previewWidth, previewHeight);
				this.viewer.x = xPosition;
				this.viewer.y = paddingTop;
				xPosition += this.viewer.width + horizontalGap;
				this.yPositionOffset = Math.max(this.yPositionOffset, this.viewer.height);
			}
			
			if(showColorInput)
			{
				this.hexInput.setActualSize(this.hexInput.measuredWidth, this.hexInput.measuredHeight);
				this.hexInput.x = xPosition;
				this.hexInput.y = paddingTop;
				xPosition += this.hexInput.width;
				this.yPositionOffset = Math.max(this.yPositionOffset, this.hexInput.height);
			}
			
			this.yPositionOffset += paddingTop + verticalGap;
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
		
		/**
		 * @private
		 * If the color input is updated, update the preview color.
		 */
		protected function colorInputChangeHandler(event:ColorPickerEvent):void
		{
			this.previewColor = event.color;
		}
		
		/**
		 * @private
		 * If enter is pressed in the color input, change the selected color.
		 * Notify listeners.
		 */
		protected function colorInputKeyDownHandler(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.ENTER)
			{
				this.selectedColor = this.hexInput.selectedColor;
				this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ENTER, false, false, -1, this.selectedColor));
				this.dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, false, false, -1, this.selectedColor));
			}
		}
	}
}