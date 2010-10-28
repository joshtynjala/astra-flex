/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.controls.colorPickerClasses
{
	import com.yahoo.astra.mx.events.ColorRequestEvent;
	import com.yahoo.astra.mx.skins.halo.ColorViewerSkin;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.ButtonPhase;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.IFocusManagerComponent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.ISimpleStyleClient;
	import mx.styles.StyleManager;

	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
	 * Name of the class to use as the default skin for the background and border. 
	 * @default "com.yahoo.astra.mx.skins.halo.ColorViewerSkin"
	 */
	[Style(name="skin", type="Class", inherit="no", states="up, over, down, disabled")]
	
	/**
	 * Name of the class to use as the skin for the background and border
	 * when the button is not selected and the mouse is not over the control.
	 *  
	 * @default "com.yahoo.astra.mx.skins.halo.ColorViewerSkin"
	 */
	[Style(name="upSkin", type="Class", inherit="no")]
	
	/**
	 * Name of the class to use as the skin for the background and border
	 * when the button is not selected and the mouse is over the control.
	 *  
	 * @default "com.yahoo.astra.mx.skins.halo.ColorViewerSkin"
	 */
	[Style(name="overSkin", type="Class", inherit="no")]
	
	/**
	 * Name of the class to use as the skin for the background and border
	 * when the button is not selected and the mouse button is down.
	 *  
	 * @default "com.yahoo.astra.mx.skins.halo.ColorViewerSkin"
	 */
	[Style(name="downSkin", type="Class", inherit="no")]
	
	/**
	 * Name of the class to use as the skin for the background and border
	 * when the button is not selected and is disabled.
	 * 
	 * @default "com.yahoo.astra.mx.skins.halo.ColorViewerSkin"
	 */
	[Style(name="disabledSkin", type="Class", inherit="no")]

	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * Dispatched when some sort of user interaction causes
	 * the IColorRequester to need a new color.
	 * 
	 * @eventType om.yahoo.astra.mx.events.ColorRequestEvent.REQUEST_COLOR
	 */
	[Event(name="requestColor", type="com.yahoo.astra.mx.events.ColorRequestEvent")]

	/**
	 * Displays a color surrounded by a standard Flex border. Acts like a button.
	 * 
	 * @author Josh Tynjala
	 */
	public class DefaultColorViewer extends UIComponent implements IColorViewer, IFocusManagerComponent
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function DefaultColorViewer()
		{
			super();
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			this.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			this.addEventListener(MouseEvent.CLICK, clickHandler);
			this.addEventListener(FlexEvent.BUTTON_DOWN, clickHandler);
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	
		/**
		 * @private
		 * The current skin for this phase.
		 */
		protected var currentSkin:IFlexDisplayObject;
		
		/**
		 * @private
		 * Storage for the phase property.
		 */
		private var _phase:String = ButtonPhase.UP;
		
		/**
		 * @private
		 * Acts like a button with phases.
		 */
		protected function get phase():String
		{
			return this._phase;
		}
		
		/**
		 * @private
		 */
		protected function set phase(value:String):void
		{
			if(this._phase != value)
			{
				this._phase = value;
				this.invalidateDisplayList();
			}
		}
		
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
				this.invalidateProperties();
				this.invalidateDisplayList();
			}
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		override public function styleChanged(styleProp:String):void
		{
			var allStyles:Boolean = !styleProp || styleProp == "styleName";
			super.styleChanged(styleProp);
			
			if(allStyles || styleProp.toLowerCase().indexOf("skin"))
			{
				this.refreshSkin();
			}
		}
		
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
	
		/**
		 * @private
		 */
		override protected function measure():void
		{
			super.measure();
			this.measuredMinWidth = this.measuredWidth = DEFAULT_MEASURED_MIN_HEIGHT;
			this.measuredMinHeight = this.measuredHeight = DEFAULT_MEASURED_MIN_HEIGHT;
		}
		
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
			
			this.refreshSkin();
		}
		
		/**
		 * @private
		 * Determines the skin name for the current phase/state.
		 */
		protected function getStateName():String
		{
			switch(this.phase)
			{
				case ButtonPhase.UP:
					return "upSkin";
					break;
				case ButtonPhase.DOWN:
					return "downSkin";
					break;
				case ButtonPhase.OVER:
					return "overSkin";
					break;
			}
			return null;
		}
		
		/**
		 * @private
		 * Updates the current skin.
		 */
		protected function refreshSkin():void
		{
			var stateName:String = this.getStateName();
			
			var skinName:String = stateName;
			if(this.getStyle("skin") != null)
			{
				skinName = "skin";
			}
			
			if(!this.enabled)
			{
				stateName = "disabledSkin";
			}
			
			if(!this.currentSkin || this.currentSkin.name != stateName)
			{
				var child:IFlexDisplayObject = this.getChildByName(stateName) as IFlexDisplayObject;
				if(!child)
				{
					var skinClass:Class = this.getStyle(skinName);
					if(skinClass)
					{
						child = new skinClass();
						child.name = stateName;
						var styleableSkin:ISimpleStyleClient = child as ISimpleStyleClient;
						if (styleableSkin)
						{
							styleableSkin.styleName = this;
						}
						this.addChild(DisplayObject(child));
					}
				}
				else
				{
					child.visible = true;
				}
				
				if(this.currentSkin)
				{
					this.currentSkin.visible = false;
				}
				this.currentSkin = child;
			}
			
			//I don't know why these are needed, but spark skins will not work
			//with this component unless the mouse is disabled completely.
			if(this.currentSkin is InteractiveObject)
			{
				InteractiveObject(this.currentSkin).mouseEnabled = false;
			}
			if(this.currentSkin is DisplayObjectContainer)
			{
				DisplayObjectContainer(this.currentSkin).mouseChildren = false;
			}
			this.currentSkin.setActualSize(unscaledWidth, unscaledHeight);
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
		
		/**
		 * @private
		 * Sets the phase.
		 */
		protected function mouseDownHandler(event:MouseEvent):void
		{
			this.phase = ButtonPhase.DOWN;
		}
		
		/**
		 * @private
		 * Sets the phase.
		 */
		protected function mouseUpHandler(event:MouseEvent):void
		{
			this.phase = ButtonPhase.UP;
		}
		
		/**
		 * @private
		 * Sets the phase.
		 */
		protected function rollOverHandler(event:MouseEvent):void
		{
			this.phase = ButtonPhase.OVER;
		}
		
		/**
		 * @private
		 * Sets the phase.
		 */
		protected function rollOutHandler(event:MouseEvent):void
		{
			if(!event.buttonDown)
			{
				this.phase = ButtonPhase.UP;
			}
		}
		
		/**
		 * @private
		 * Requests a color when clicked.
		 */
		protected function clickHandler(event:Event):void
		{
			this.dispatchEvent(new ColorRequestEvent(ColorRequestEvent.REQUEST_COLOR, false, false, this.color));
		}
	}
}