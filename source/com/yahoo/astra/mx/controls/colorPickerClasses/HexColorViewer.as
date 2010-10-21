/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls.colorPickerClasses
{	
	import com.yahoo.astra.mx.skins.halo.DropDownViewerSkin;
	import com.yahoo.astra.utils.ColorUtil;
	
	import mx.core.EdgeMetrics;
	import mx.core.IBorder;
	import mx.core.UITextField;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;

	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	//Flex framework styles
	include "../../styles/metadata/TextStyles.inc"
	
	/**
	 * A color viewer that displays the hex string representation of the
	 * selected color over the actual displayed color.
	 * 
	 * @author Josh Tynjala
	 */
	public class HexColorViewer extends DefaultColorViewer implements IColorPreviewViewer
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		/**
		 * Constructor.
		 */
		public function HexColorViewer()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------

		/**
		 * The textfield used to display the hex value of the selectedColor.
		 */
		protected var textField:UITextField;
		
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
				this.invalidateProperties();
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
				this.invalidateProperties();
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
			
			if(!this.textField)
			{
				this.textField = new UITextField();
				this.textField.styleName = this;
				this.addChild(this.textField);
			}
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			if(this.showPreview)
			{
				var chromeColor:uint = ColorUtil.whiteOrBlack(this.previewColor);
				//this.setStyle("iconColor", chromeColor);
				this.setStyle("color", chromeColor);
				this.textField.text = ColorUtil.toHexString(this.previewColor);
			}
			else
			{
				chromeColor = ColorUtil.whiteOrBlack(this.color);
				//this.setStyle("iconColor", chromeColor);
				this.setStyle("color", chromeColor);
				this.textField.text = ColorUtil.toHexString(this.color);
			}
		}
		
		/**
		 * @private
		 */
		override protected function measure():void
		{
			super.measure();
			
			this.measuredWidth = DEFAULT_MEASURED_WIDTH;
			this.measuredHeight = DEFAULT_MEASURED_HEIGHT;
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{	
			var paddingLeft:Number = this.getStyle("paddingLeft");
			var paddingRight:Number = this.getStyle("paddingRight");
			var paddingTop:Number = this.getStyle("paddingTop");
			var paddingBottom:Number = this.getStyle("paddingBottom");
			
			var cornerRadius:Number = this.getStyle("cornerRadius");
			
			this.graphics.clear();
			if(this.showPreview)
			{
				this.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, cornerRadius, this.previewColor, 1);
			}
			else
			{
				this.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, cornerRadius, this.color, 1);
			}
			
			this.refreshSkin();
			
			var metrics:EdgeMetrics = this.currentSkin is IBorder ? IBorder(this.currentSkin).borderMetrics : EdgeMetrics.EMPTY;
			
			var contentWidth:Number = unscaledWidth - metrics.left - metrics.right - paddingLeft - paddingRight;
			var contentHeight:Number = unscaledHeight - metrics.top - metrics.bottom - paddingTop - paddingBottom;
			var textFieldHeight:Number = Math.min(this.textField.measuredHeight, contentHeight);
			this.textField.setActualSize(contentWidth, textFieldHeight);
			this.textField.x = paddingLeft + metrics.left;
			this.textField.y = paddingTop + metrics.top + (contentHeight - textFieldHeight) / 2;
		}
	}
}