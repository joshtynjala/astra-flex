/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.accessibility
{

import com.yahoo.astra.accessibility.EventTypes;
import com.yahoo.astra.accessibility.ObjectRoles;
import com.yahoo.astra.accessibility.ObjectStates;
import com.yahoo.astra.mx.controls.DropDownColorPicker;
import com.yahoo.astra.mx.controls.colorPickerClasses.SwatchPickerDropDown;
import com.yahoo.astra.utils.Color;
import com.yahoo.astra.utils.ColorUtil;

import flash.accessibility.Accessibility;
import flash.events.Event;

import mx.accessibility.ComboBaseAccImpl;
import mx.core.UIComponent;
import mx.events.DropdownEvent;

	/**
	 * The DropDownColorPickerAccImpl class is used to make a DropDownColorPicker component accessible.
	 * 
	 * <p>A DropDownColorPickerAccImpl reports the role <code>ROLE_SYSTEM_COMBOBOX</code> to a screen 
	 * reader. </p>
	 * 
	 * @author Alaric Cole
     *
	 */	
public class DropDownColorPickerAccImpl extends ComboBaseAccImpl
{
	
	/**
	 *  @private
	 *  Static variable triggering the hookAccessibility() method.
	 *  This is used for initializing DropDownColorPickerAccImpl class to hook its
	 *  createAccessibilityImplementation() method to DropDownColorPicker class 
	 *  before it gets called from UIComponent.
	 */
	private static var accessibilityHooked:Boolean = hookAccessibility();

	/**
	 *  @private
	 *  Static method for swapping the createAccessibilityImplementation()
	 *  method of DropDownColorPicker withthe DropDownColorPickerAccImpl class.
	 */
	private static function hookAccessibility():Boolean
	{
		DropDownColorPicker.createAccessibilityImplementation = createAccessibilityImplementation;

		return true;
	}
	

	/**
	 *  @private
	 *  Method for creating the Accessibility class.
	 *  This method is called from UIComponent.
	 */
	public static function createAccessibilityImplementation(component:UIComponent):void
	{
		component.accessibilityImplementation = new DropDownColorPickerAccImpl(component);
	}

	/**
	 *  Method call for enabling accessibility for a component.
	 *  This method is required for the compiler to activate
	 *  the accessibility classes for a component.
	 */
	public static function enableAccessibility():void
	{
		//
	}

	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
		
	/**
	 *  Constructor.
	 *
	 *  @param master The UIComponent instance that this AccImpl instance
	 *  is making accessible.
	 */
	
	public function DropDownColorPickerAccImpl(master:UIComponent)
	{
		super(master);
		DropDownColorPicker(master).addEventListener(DropdownEvent.OPEN, openHandler);
		DropDownColorPicker(master).addEventListener(DropdownEvent.CLOSE, closeHandler);
		role = ObjectRoles.ROLE_SYSTEM_COMBOBOX
	}
	
	private function openHandler(event:Event):void
	{
		DropDownColorPicker(master).picker.addEventListener("change",  dropdown_changeHandler);
	}
	private function closeHandler(event:Event):void
	{
		DropDownColorPicker(master).picker.removeEventListener("change",  dropdown_changeHandler);
	}
	
	private function dropdown_changeHandler(event:Event):void
	{
		master.dispatchEvent(new Event("dropdownChanged"));
	} 
	

	/**
	 *  @inheritDoc
	 */
	override protected function getName(childID:uint):String
	{
		var colorPicker:DropDownColorPicker = DropDownColorPicker(master);
		var str:String;
		if (childID == 0 || childID > 0xFFFFFF)
		{
			return hexToColorString(colorPicker.selectedColor);
		}
	
		else return childID.toString();
	
	}


	
	/**
	 *  @inheritDoc
	 */
	override public function get_accState(childID:uint):uint
	{
		var accState:uint = getState(childID);
		
		if (childID > 0)
		{
			accState |= ObjectStates.STATE_SYSTEM_SELECTABLE;
		
			accState |= ObjectStates.STATE_SYSTEM_SELECTED | ObjectStates.STATE_SYSTEM_FOCUSED;
		}

		return accState;
	}

	/**
	 *  @inheritDoc
	 */
	override public function get_accValue(childID:uint):String
	{
		 if (DropDownColorPicker(master).showingDropdown)
		{
			return DropDownColorPicker(master).picker ? 
				SwatchPickerDropDown(DropDownColorPicker(master).picker).swatchPicker.selectedColor.toString(16) :
				null;
		} 
		else
			return hexToColorString( DropDownColorPicker(master).selectedColor );
	}
	
	/**
	 *  @inheritDoc
	 */
	override public function getChildIDArray():Array
	{
		var childIDs:Array = [1];
		 if (DropDownColorPicker(master).picker)
		{
			var n:uint= SwatchPickerDropDown(DropDownColorPicker(master).picker).colorList.length;
			for (var i:int = 0; i < n; i++)
			{
				childIDs[i] = i + 1;
			}
		}  
		return childIDs;
	}

	/**
	* inheritDoc
	*/
	override public function get_accDefaultAction(childID:uint):String
	{
		if(childID == 0){
			return "Open";
		}
			return "Change Color";
	}
	
	/**
	 *  @inheritDoc
	 */
	override protected function get eventsToHandle():Array
	{
		return super.eventsToHandle.concat([ "change", "valueCommit", "open", "close", "itemRollOver", "itemRollOut"]);
	}

	/**
	 *  @inheritDoc
	 */
	override protected function eventHandler(event:Event):void
	{
		switch (event.type)
		{
			case "dropdownChanged":
			{
				Accessibility.sendEvent(master, DropDownColorPicker(master).picker.selectedColor , EventTypes.EVENT_OBJECT_SELECTION);
				Accessibility.sendEvent(master, DropDownColorPicker(master).picker.selectedColor,
								EventTypes.EVENT_OBJECT_VALUECHANGE, true)
			}
			
			case "change":
			{
				Accessibility.sendEvent(master, 0, EventTypes.EVENT_OBJECT_SELECTION);
				Accessibility.sendEvent(master, 0, EventTypes.EVENT_OBJECT_VALUECHANGE, true)
				
			}

			 case "valueCommit":
			{
				Accessibility.sendEvent(master, 0, EventTypes.EVENT_OBJECT_VALUECHANGE);
				break;
			} 
			
			case "open":
			{
				Accessibility.sendEvent(master, 0, EventTypes.EVENT_OBJECT_SELECTION);
				Accessibility.sendEvent(master, 0, EventTypes.EVENT_OBJECT_VALUECHANGE, true)
				break;
			}
			
			case "close":
			{
				Accessibility.sendEvent(master, 0, EventTypes.EVENT_OBJECT_SELECTION, true);
				Accessibility.sendEvent(master, 0, EventTypes.EVENT_OBJECT_VALUECHANGE, true)
				break;
			}
 		    /*case "itemRollOver":
			{
				Accessibility.sendEvent(master, 0, EventTypes.EVENT_OBJECT_FOCUS);								
				Accessibility.sendEvent(master, 0, EventTypes.EVENT_OBJECT_SELECTION);
				Accessibility.sendEvent(master, 0, EventTypes.EVENT_OBJECT_VALUECHANGE);
				//Accessibility.sendEvent(master, 0, EventTypes.EVENT_OBJECT_VALUECHANGE, true);
				//Accessibility.updateProperties();
				break;
			}  
			 case "itemRollOut":
			{
				Accessibility.sendEvent(master, 1, EventTypes.EVENT_OBJECT_FOCUS);								
				Accessibility.sendEvent(master, 1, EventTypes.EVENT_OBJECT_SELECTION);
				Accessibility.sendEvent(master, DropDownColorPicker(master).picker.selectedColor, EventTypes.EVENT_OBJECT_VALUECHANGE, true);
				//Accessibility.updateProperties();
				break;
			} */	 	
		}
	}
	
	/**
	 *  @private
	 *  Forces screen readers read color properly. A common color name will be announced if possible.
	 */
	private function hexToColorString(hexColor:uint = 0xFFFFFF):String
	{
		var colorString:String = "color";
		
		if (Color.getColorByHexValue(hexColor) ) colorString += " " + Color.getColorByHexValue(hexColor).name;
		
		//improving text-to-speech by inserting punctuation
		 colorString += ". " + improvedColorString(ColorUtil.toHexString(hexColor));
		 
		 return colorString;
		
	}
	
	/**
	 *  @private
	 *  formats string color to add a space between each digit (hexit?).
	 *  Makes screen readers read color properly.
	 */
	private function improvedColorString(color:String):String
	{
		var hexString:String = "";
		var n:int = color.length;
		
		for (var i:uint = 0; i < n; i++)
			hexString += color.charAt(i) + " ";
		
		return hexString;
	}
}

}
