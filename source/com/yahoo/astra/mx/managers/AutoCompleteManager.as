/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.mx.managers
{
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.net.SharedObject;
import flash.net.SharedObjectFlushStatus;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.collections.ListCollectionView;
import mx.collections.XMLListCollection;
import mx.controls.List;
import mx.controls.TextInput;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.listClasses.ListBase;
import mx.core.Application;
import mx.core.ClassFactory;
import mx.core.Container;
import mx.core.IFactory;
import mx.events.DropdownEvent;
import mx.events.FlexEvent;
import mx.events.FlexMouseEvent;
import mx.events.ListEvent;
import mx.events.MoveEvent;
import mx.events.ResizeEvent;
import mx.managers.PopUpManager;
import mx.utils.StringUtil;


//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the pop-up renderer changes.
 *
 *  @eventType flash.events.Event
 */
[Event(name="popUpRendererChanged", type="flash.events.Event")]

/**
 *  Dispatched when the <code>saveEntries()</code> method saves entries.
 *
 *  @eventType flash.events.Event
 *  @see #autoSave
 */
[Event(name="entriesSaved", type="flash.events.Event")]

/**
 *  Dispatched when the <code>dataProvider()</code> is updated internally.
 *
 *  @eventType flash.events.Event
 */
[Event(name="dataProviderUpdated", type="flash.events.Event")]

/**
 *  Dispatched when the completion box becomes visible.
 *
 *  @eventType mx.events.DropdownEvent
 */
[Event(name="open", type="mx.events.DropdownEvent")]

/**
 *  Dispatched when the completion box becomes invisible.
 *
 *  @eventType mx.events.DropdownEvent
 */
[Event(name="close", type="mx.events.DropdownEvent")]

/**
 *  Dispatched when the pop-up completion changes selection.
 *
 *  @eventType mx.events.ListEvent
 */
[Event(name="change", type="mx.events.ListEvent")]


//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultProperty("dataProvider")]


/**
 * The AutoCompleteManager manages a set of input controls, popping up
 * suggestions based on previous entries into the fields. The fields are to be set
 * by the <code>targets</code> or <code>target</code> property. These properties can
 * accept either TextInputs or containers (which hold a set of TextInputs).
 * <p>Note: Due to the way TextInput sizing works, selecting a long string of text
 * in an AutoCompleteManager's dropdown may cause the target TextInput to resize
 * to fit the new text. If you would not like this feature, ensure that each target's
 * width is explicitly set.</p>
 *
 * @author Alaric Cole
 */
public class AutoCompleteManager extends EventDispatcher
{

	//--------------------------------------------------------------------------
	//
	//  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
	public function AutoCompleteManager()
	{
	    super();
	    
	    _sharedObject = SharedObject.getLocal(sharedObjectPath, shareData?"/":null);
   
		Application.application.addEventListener(FlexEvent.APPLICATION_COMPLETE, createListenersForTargets);
        
	}

	/**
     *  @private
     * Stores an input's previous value, in case we need to revert.
     */
    private var _previousValue:String;
    
	/**
     *  @private
     * Whether we're in a key press or not.
     */
    private var _inKeyDown:Boolean = false;
    
	/**
     *  @private
     * The Shared Object instance in which to store entries.
     */
    private var _sharedObject:SharedObject;
    
	/**
	 *  @private
	 *  Whether to remove the selection for auto-fill.
	 */
	private var _removeSelection:Boolean;
	
	/**
	 *  @private
	 *  The current text in the active TextInput.
	 */
	private var _currentTypedText:String="";

 	/**
     *  @private
     * The data provider of the current dropdown.  
     */
    private var _currentCollection:ListCollectionView;
    
     /**
     *  @private
     *  The currently visible dropdown  
     */
    private var _currentDropdown:ListBase;
    
 	 /**
     *  @private
     *  A reference to the internal Lists that pop up 
     */
    private var _dropdowns:Array = [];
	
	/**
     *  @private
     *  Storage for the text inputs that have been set up with event listeners
     */
    private var _actualTargets:Array = [];
    
    //----------------------------------
    //  dataProvider
    //----------------------------------
	/**
	 *  @private
	 *  Storage for the dataProvider property.
	 */
	private var _dataProvider:ICollectionView;

    [Bindable("collectionChange")]
    
    /**
     *  The list of items to use for a custom auto-complete. Setting
     *	this property will forego use of Shared Objects/local history, instead
     * 	filtering based upon these items.
     *  You can use a simple Array of Strings, an ArrayCollection, XML, and 
     * 	other popular collections.
     * 
     *  @default null
     *  @see mx.collections.ICollectionView
     */
    public function get dataProvider():Object
    {
        return _dataProvider;
    }

    /**
     *  @private
     */
    public function set dataProvider(value:Object):void
    {
        if (value is Array)
        {
            _dataProvider = new ArrayCollection(value as Array);
        }
        else if (value is ICollectionView)
        {
            _dataProvider = ICollectionView(value);
        }
        else if (value is IList)
        {
            _dataProvider = new ListCollectionView(IList(value));
        }
        else if (value is XMLList)
        {
            _dataProvider = new XMLListCollection(value as XMLList);
        }
        else if (value is XML)
        {
            var xmlList:XMLList = new XMLList();
            xmlList += value;
            _dataProvider = new XMLListCollection(xmlList);
        }
        else
        {
            var tmp:Array = [];
            if (value != null)
                tmp.push(value);
            _dataProvider = new ArrayCollection(tmp);
        }
 
    }

	//----------------------------------
	//  filterFunction
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the filterFunction property.
	 */
	private var _filterFunction:Function = defaultFilterFunction;

	/**
	 *  A function that is used to display items that match the
	 *  function's criteria. 
	 * 
	 *  A filterFunction is expected to have the following signature:
	 *
	 *  <pre>f(element:~~, text:String):Boolean</pre>
	 *
	 *  The return value is <code>true</code> for the function if the specified item
	 *  should displayed as a suggestion. 
	 *  Whenever there is a change in text in one of the targets, this 
	 *  filterFunction is run on each item in the list of potential suggestions.
	 *  
 	 *  <p>The default implementation for the filter function works like this:<br>
 	 *  If "Ya" has been typed with or without leading or trailing whitespace, 
 	 *  it will display all the items matching 
	 *  "Ya~~" (Yahoo!, Yahoos, yahoo, yay, yawn, etc.), assuming <code>caseSensitive</code> 
	 *  is set to <code>false</code>. If <code>caseSensitive</code> is <code>true</code>, 
	 *  only items starting with a capital "Y" would be returned.</p>.
	 * 	 
	 *  @see #caseSensitive
	 */
	public function get filterFunction():Function
	{
		return _filterFunction;
	}

	/**
	 *  @private
	 */
	public function set filterFunction(value:Function):void
	{
		if(value != null)_filterFunction = value;
		
		else _filterFunction = defaultFilterFunction;
	}
    
    /**
     *  The name of the Shared Object in which to store auto-complete entries.
     * @default "AutoCompleteData"
     */
     
    public var sharedObjectPath:String = "AutoCompleteData";
    
    //----------------------------------
    //  shareData
    //----------------------------------
	
    /**
     *  @private
     *  Storage for the shareData property.
     */
    private var _shareData:Boolean = false;
    
	/**
     * Whether to share the auto-complete data with other applications
     * or keep it private to this application. TextInputs in the same domain
     * with the same id attribute will share the same entries if this is set to <code>true</code>.
     * 
     * <p>Please note that setting this to <code>true</code> will all applications in the domain
     * to access any information in the Shared Object. For instance, if a third party
     * application hosted on the same domainknows the name of the Shared Object 
     * (which is by default "AutoCompleteData"), they may be able to read and write to it.</p>
     * 
     * <p>If you choose to set this to <code>true</code>, you should consider setting the 
     * <code>sharedObjectPath</code> to a value only your applications are aware of,
     * especially a password-like value or some value returned from a server.
     * In this way, you make it difficult or impossible for a third party 
     * to access this information.</p>
     * 
     * @see #sharedObjectPath
     * @see flash.net.SharedObject
     * @default false
     */
    public function get shareData():Boolean
    {
    	return _shareData;
    }
    
    /**
     *  @private
     */
    public function set shareData(value:Boolean):void
    {
    	_shareData = value;
    	_sharedObject = SharedObject.getLocal(sharedObjectPath, value?"/":null);
    }
 		
	//----------------------------------
    //  loopSelection
    //----------------------------------
	
	[Bindable]
	/**
     *  A flag that indicates whether to loop the selection in the dropdown when
     * using the arrow keys. 
     *
     *  @default true
     */
    public var loopSelection:Boolean = false;

	//----------------------------------
    //  forceelection
    //----------------------------------
	
	[Bindable]
	/**
     *  Whether to place the most likely completion in the TextInput 
     * if no other selection is made. 
     *
     *  @default false
     */
    public var forceSelection:Boolean = false;
	
	//----------------------------------
    //  caseSensitive
    //----------------------------------
	
	[Bindable]
	/**
     *  Whether the auto complete will match based on case or not 
     *
     *  @default false
     */
    public var caseSensitive:Boolean = false;
	
	//----------------------------------
	//  autoFillEnabled
	//----------------------------------
	[Bindable]
	/**
	 *  @private
	 *  Storage for the autoFillEnabled property.
	 */
	private var _autoFillEnabled:Boolean;

	/**
	 *  Whether to complete the text in the text field
	 *  with the first item in the drop down list or not.
	 * <p>Note that autoFill will only work correctly if the text that
	 * is entered matches the <code>labelField</code> or <code>labelFunction</code>.
	 * This is because autoFill uses the textual representation of the particular field 
	 * when filling in the TextInput. </p>
	 *
	 * @default false
	 * @see labelField
	 * @see labelFunction
	 */
	public function get autoFillEnabled():Boolean
	{
		return _autoFillEnabled;
	}

	/**
	 *  @private
	 */
	public function set autoFillEnabled(value:Boolean):void
	{
		_autoFillEnabled = value;
	}

	//----------------------------------
	//  popUpEnabled
	//----------------------------------
	[Bindable]
	/**
	 *  @private
	 *  Storage for the popUpEnabled property.
	 */
	private var _popUpEnabled:Boolean = true;

	/**
	 *  Whether to pop up a list below the text input or not. 
	 * AutoCompleteManager can be used for either pop-up style
	 * auto-complete, or simply auto-fill of the most likely entry.
	 *
	 *  @default true
	 */
	public function get popUpEnabled():Boolean
	{
		return _popUpEnabled;
	}

	/**
	 *  @private
	 */
	public function set popUpEnabled(value:Boolean):void
	{
		_popUpEnabled = value;
	}

	//----------------------------------
    //  enabled
    //----------------------------------
	[Bindable]    
    /**
     *  @private
     *  Storage for the enabled property.
     */
    private var _enabled:Boolean = true;
    
    [Inspectable(category="General", defaultValue="true")]

    /** 
     *  Setting this value to <code>false</code> will stop all autocompletes
     *  from displaying and will stop new entries from being added to the local history. 
     *  
     *  @default true
     */
    public function get enabled():Boolean
    {
        return _enabled;
    }

    /**
     *  @private
     */
    public function set enabled(value:Boolean):void
    {
        if(value == _enabled) return;
        
        if(value)
        {
        	createListenersForTargets();
        }
        else
        {
        	removeListenersForTargets();
        }
        
        _enabled = value;
    }
    
    //----------------------------------
    //  autoSave
    //----------------------------------
	[Bindable]    
    /**
     *  @private
     *  Storage for the autoSave property.
     */
    private var _autoSave:Boolean = false;
    
    [Inspectable(category="General", defaultValue="true")]

    /** 
     *  Setting this value to <code>true</code> will add
     *  adding entries to the local history when a target TextInput
     *  is focused out of.
     *  
     *  @default false
     */
    public function get autoSave():Boolean
    {
        return _autoSave;
    }

    /**
     *  @private
     */
    public function set autoSave(value:Boolean):void
    {
        _autoSave = value;
    }
    
    //----------------------------------
    //  target
    //----------------------------------
	[Bindable]
    /** 
     *  The TextInput or container to watch
     */
    public function get target():Object
    {
        if (_targets.length > 0)
            return _targets[0]; 
        else
            return null;
    }
    
    /**
     *  @private
     */
    public function set target(value:Object):void
    {
        
        _targets.splice(0);
        
        if (value)
            _targets[0] = value;
        
        createListenersForTargets();
    }

    //----------------------------------
    //  targets
    //----------------------------------
 	[Bindable]   
    /**
     *  @private
     *  Storage for the targets property.
     */
    private var _targets:Array = [];
    
    /**
     *  An Array of TextInputs or containers to watch.
     *  Setting the <code>target</code> property replaces all objects
     *  in this Array. 
     *  When the <code>targets</code> property is set, the <code>target</code>
     *  property returns the first item in this Array. 
     */
    public function get targets():Array
    {
        return _targets;
    }

    /**
     *  @private
     */
    public function set targets(value:Array):void
    {
        // Strip out null values.
        var n:int = value.length;
        for (var i:int = n - 1; i > 0; i--)
        {
            if (value[i] == null) value.splice(i,1);
        }

        _targets = value;
        createListenersForTargets();
    }
    
    //----------------------------------
	//  maxRowCount
	//----------------------------------
	[Bindable]
	/**
	 * @private
	 * Storage for the maxRowCount property
	 */
	private var _maxRowCount:int = 5;
	
	/**
	 * The maximum number of rows that a pop-up autocomplete should display
	 * @default 5
	 */
	public function get maxRowCount():int
	{
		return _maxRowCount;
	}
	/**
	 * @private
	 */
	public function set maxRowCount(value:int):void
	{
		_maxRowCount = value;
	}
	
	
    //----------------------------------
    //  itemRenderer
    //----------------------------------
	[Bindable]
    /**
     *  @private
     *  Storage for the popUpRenderer property.
     */
    private var _popUpRenderer:IFactory = new ClassFactory(List);

    [Bindable("popUpRendererChanged")]

    /**
     *  The custom renderer that creates a ListBase-derived instance to use
     *  as the drop-down.
     *  @default mx.controls.List
     *
     */
    public function get popUpRenderer():IFactory
    {
        return _popUpRenderer;
    }

    /**
     *  @private
     */
    public function set popUpRenderer(value:IFactory):void
    {
        _popUpRenderer = value;
		
		//remove all previous instances of dropdowns
		_dropdowns = [];
        
   		//redo targets
        targets = targets;
        dispatchEvent(new Event("popUpRendererChanged"));
    }
    
    //----------------------------------
    //  minCharsForCompletion
    //----------------------------------
	[Bindable]
 	/**
	 *  @private
	 *  Storage for the minCharsForCompletion property
	 */
	private var _minCharsForCompletion:int = 1;
	/**
	 *  The minimum number of characters that must be typed in to display the completion list
	 * @default 1
	 */
	public function get minCharsForCompletion():int
	{
	    return _minCharsForCompletion;
	}
	/**
     *  @private
     */
	public function set minCharsForCompletion(value:int):void
	{
	    _minCharsForCompletion =  value;
	}
    
    /**
     *  The minimum disk space, in bytes, that you'd like to allow
     *  for local storage. The default size for local storage is 100 KB.
     *  If you believe you will need more than this, you can pass in a value
     *  here. This will pop up a native Flash dialog asking if the user agrees
     *  to this. While Flash will do this anyway if the local storage grows above 
     *  100 KB, setting this value in advance will prevent the dialog from popping up 
     *  every time there is a minor increase in needed size.
     * 
     *  <p>Leaving at 0 or any value less than the default 100000 (100 KB)
     *  will not have an effect.</p>
     * 
     *  <p>Note that the user can always deny this increase, or disable 
     *  local storage altogether.</p>
     *  
     * @see flash.net.SharedObject#flush()
     */
    public var minDiskSpace:int = 0;
    
    //----------------------------------
    //  public methods
    //----------------------------------
    /**
     * Adds the text value of all current targets to the local history.
     * Use this method if you have set <code>autoSave</code> to false
     * and want to manually add entries such as upon form submittal.
     */
    public function saveEntries():void
    {
    	var n:int = _actualTargets.length;
    	//check for issues with shared object size
        var problem:Boolean;
        for (var i:int = 0; i < n; i++) 
        {     
           var t:TextInput = _actualTargets[i] as TextInput;
           problem = !addEntry(t);
           
           if(problem)
           {
           		break;
           }
        }
        
        if(!problem)
        {
	        var addedEvent:Event = new Event("entriesSaved");
	        dispatchEvent(addedEvent);
        }
    }
    
    /**
     * Clears all entries in the local history (shared object).
     */
    public function removeAll():void
    {
    	
    	_sharedObject.clear();
    }
    
    //----------------------------------
    //  protected methods
    //----------------------------------
	
     /**
     *  @private
     * Helper function to determine if a specific TextInput is associated
     * with a dropdown auto-complete
     * 
     * @param t A TextInput instance
     * @return Boolean
     */
    protected function hasDropdown(t:TextInput):Boolean
    {
        for each (var o:ListBase in _dropdowns)
        {
        	if(o.owner == t)
        	{
        		return true;
        	}
        }
        return false;
    }
 	
 	/**
     *  @private
     * This sets up the event listeners and such for each target
     *
     * @param event The Event object passed, if any
     */
    protected function createListenersForTargets(event:Event = null):void 
    {
        
        //TODO: optimize 
        if(Application.application.initialized)
        {
        	removeListenersForTargets();	
        }
        
        var n:int = targets.length;
        
        for (var i:int = 0; i < n; i++) 
        {     
           if (targets[i] is TextInput) 
           {
            	var textInput:TextInput = targets[i] as TextInput;
            	_actualTargets.push(textInput);
           				
            	createListenersForTarget(textInput);
            	
           }
            
           else if (targets[i] is Container)
           {
           		var container:Container = targets[i] as Container;
           		
           		addListenersForTargetsInContainer(container);
           } 
        }
    }
    
    /**
     *  @private
     * Adds event listeners for text inputs within a container
     * 
     * @param container The Container instance to loop through
     */
    protected function addListenersForTargetsInContainer(container:Container):void 
    {
        for (var j:uint = 0; j < container.numChildren; j++)
       		{
       			var child:DisplayObject = container.getChildAt(j);
       			if(child is TextInput)
       			{
       				_actualTargets.push(child);
       				
       				createListenersForTarget(child as TextInput);
       			}
       			else if(child is Container)
       			{
       				//recursively loop through any container, finding
       				//text inputs within it
       				addListenersForTargetsInContainer(child as Container);
       			}
       		}
    }
     /**
     *  @private
     * Removes event listeners for each target
     */
    protected function removeListenersForTargets():void 
    {
        var n:int = _actualTargets.length;
        
        if (n < 1)
            return;
            
        for (var i:int; i < n; i++) 
        {
          removeListenersForTarget(_actualTargets[i] as TextInput);
        }
        _actualTargets = [];
    }
    
     /**
     *  @private
     * Removes event listeners for a target
     * 
     * @param textInput The TextInput instance
     */
    protected function removeListenersForTarget(textInput:TextInput):void
    {
    	
    	textInput.removeEventListener(Event.CHANGE, open);
    	textInput.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
    	textInput.removeEventListener(FlexEvent.VALUE_COMMIT, onFocusOut);
    }
    
     /**
     *  @private
     * Adds event listeners for a target
     * 
     * @param textInput The TextInput instance
     */
    protected function createListenersForTarget(textInput:TextInput):void
    {
    	textInput.addEventListener(Event.CHANGE, open);
    	textInput.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
    	textInput.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
    	textInput.addEventListener(ResizeEvent.RESIZE, onOwnerResized);
    	textInput.addEventListener(MoveEvent.MOVE, onOwnerMoved);
		textInput.systemManager.addEventListener(Event.RESIZE, stage_resizeHandler, false, 0, true);
    }
    
   
    /**
     * @private
     * Opens a specific dropdown for a Text Input
     * 
     * @param event The Event object passed in
     */
    protected function open(event:Event):void
	{
		 display(true, event.currentTarget as TextInput); 

 	}
	
	 /**
     * @private
     * Hides the drop-down list.
     * 
     * @param event The event which called the function
     */
    protected function close(event:Event = null):void
    {
        var dropdown:ListBase = event.currentTarget as ListBase;
        
        var textInput:TextInput = dropdown.owner as TextInput;
        
   	 	if(textInput) display(false, textInput);
			
    }
      
      
    /**
     * Opens a specific dropdown for a Text Input
     * 
     * @param target The TextInput instance to pop the dropdown from
     */
    public function openDropdownForTarget(target:TextInput):void
	{
		 if(isTarget(target)) display(true, target); 
 	}
	
	 /**
     * Hides the drop-down list.
     * 
     * @param target The TextInput instance to close the dropdown for
     */
    public function closeDropdownForTarget(target:TextInput):void
    {
         
   	 	if(isTarget(target)) display(false, target);
			
    }
     
     /**
     * Creates and returns a specific dropdown for a TextInput,
     * if it is set up as a target and one does not already exist 
     * 
     * @param textInput The TextInput instance
     * @return An instance of List
     */
    [Bindable("collectionChange")]
    public function getDropdownForTarget(textInput:TextInput):ListBase
    {
       if(isTarget(textInput))
        {
	        if (!hasDropdown(textInput) )
	        {
				var dropdown:ListBase = popUpRenderer.newInstance();
				dropdown.dataProvider = [];
				
				dropdown.visible = true;
				dropdown.focusEnabled = false;
				//using the owner property to connect the TextInput to its corresponding dropdown
				dropdown.owner = textInput;
				
				//add it to our list of dropdowns so we can find it again
				_dropdowns.push(dropdown);
				
				dropdown.wordWrap = wordWrap;
				dropdown.variableRowHeight = wordWrap;
				
				if(_labelField) dropdown.labelField = labelField;
				if(_labelFunction != null) dropdown.labelFunction = labelFunction;
				
				dropdown.cacheAsBitmap = true;
				
				dropdown.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, dropdown_mouseDownOutsideHandler);
				dropdown.addEventListener(FlexMouseEvent.MOUSE_WHEEL_OUTSIDE, dropdown_mouseWheelOutsideHandler);
				
				// the drop down should close if the user clicks on any item.
				// add a handler to detect a click in the list
				dropdown.addEventListener(ListEvent.ITEM_CLICK, dropdown_itemClickHandler);
				dropdown.addEventListener(ListEvent.CHANGE, dropdown_changeHandler);
				
	        }
	
			//if we have a dropdown for this input already, return it
			else
			{
				for each (var o:ListBase in _dropdowns)
		        {
		        	if(o.owner == textInput)
		        	{
		        		//o.width = textInput.width;
		        		return o;
		        	}
		        }
			}
			
			//resizeDropdown(dropdown);
	        return dropdown;
	    }
	    
	    else return null;
    }

    /**
     * @private
     * Determines if a TextInput instance has been set up as a target
     * 
     * @param textInput The TextInput instance
     * @return Whether the instance is a target or not
     */
    protected function isTarget(textInput:TextInput):Boolean
    {
        for each (var trgt:TextInput in targets)
	        {
	        	if(trgt == textInput)
	        	{
	        		return true;
	        	}
	        }
	        
	        return false;
	  }
	        
	/**
     *  @private
     * Shows or hides a dropdown auto-complete 
     * or creates an auto-fill for a specific TextInput
     * 
     * @param show Whether to display auto-complete
     * @param textInput The TextInput instance
     */
    protected function display(show:Boolean, textInput:TextInput):void
    { 
    	var dropdown:ListBase;

        //open it
        if (show)
        {
        	updateDataProvider(textInput);
			
			if(_currentCollection !=null)
			{
         		//Don't display an empty dropdown
	         	if(_currentCollection.length < 1 || (textInput.length < minCharsForCompletion && !_inKeyDown))  
	            {
	            	show = false;
	            }
	    
	            else 
	            {
	            	//add auto-fill
	 				if(autoFillEnabled && !_removeSelection)
					{
						
						var lbl:String = itemToLabel(_currentCollection.getItemAt(0));
						var index:Number =  lbl.toLowerCase().indexOf(textInput.text.toLowerCase());
						if(index==0)
						{
							var t:String = lbl.substr(textInput.text.length);
						   
						    var l:Number = textInput.length;
						   
						   	textInput.text = textInput.text + t;
							textInput.setSelection(textInput.length,l);
						}
							
					}
					
	            	if(popUpEnabled)
	            	{
	            		dropdown = getDropdownForTarget(textInput);
	        
        				_currentDropdown = dropdown;
	        			
	        			//pop it up
		                if(!dropdown.isPopUp)
		                { 
		                	 PopUpManager.addPopUp(dropdown, textInput);
						}
						
						resizeDropdown(dropdown);
						positionDropdown(dropdown);
						var sel:int = dropdown.selectedIndex;
        
						var pos:Number = dropdown.verticalScrollPosition;
				
				        // try to set the verticalScrollPosition one above the selected index so
				        // it looks better when the dropdown is displayed
				        pos = sel - 1;
				        pos = Math.min(Math.max(pos, 0), dropdown.maxVerticalScrollPosition);
				        
				        dropdown.verticalScrollPosition = pos;
			
				        var completionShowEvent:DropdownEvent = new DropdownEvent(DropdownEvent.OPEN);
			            dispatchEvent(completionShowEvent);
						
	            	}
	            	
	 				
				}
		 			
 			}
	        
        }
        
        //close it
         if(!show && !_inKeyDown)
         {
         	dropdown = getDropdownForTarget(textInput);
	        
	        if(dropdown.isPopUp)
	        {
	        	PopUpManager.removePopUp(dropdown);
         	
	         	var completionHideEvent:DropdownEvent = new DropdownEvent(DropdownEvent.CLOSE);
	            dispatchEvent(completionHideEvent);
	            
	            _currentDropdown = null;
	        }
	        
	        if(forceSelection )
	    	{
	    		if(!textInput.length < minCharsForCompletion && _currentCollection !=null)
				{
	         		//Don't display an empty dropdown
		         	if(!_currentCollection.length < 1)
		         	{
		         		if(textInput.text != itemToLabel(dropdown.selectedItem))
		         		{
		         		
		         			textInput.text = itemToLabel( _currentCollection.getItemAt(0) );
		         		}
		         	}
		    	}
	    	
	    	textInput.setSelection(0,textInput.text.length);
	    	}
         }
        
    }

	/**
     * @private
     * Positions the dropdown to match with its owner.
     * 
     * @param dropdown The dropdown instance
     */    
    protected function positionDropdown(dropdown:ListBase):void
    {
    	var textInput:TextInput = dropdown.owner as TextInput;
    	
    	//now size and position the dropdown
		var point:Point = new Point
    	(
    		0,
    		textInput.height + textInput.getStyle("focusThickness") + textInput.getStyle("borderThickness")
    	);
       
        point = textInput.localToGlobal(point);
    	dropdown.invalidateSize();
        // if we do not have enough space in the bottom display the dropdown
        // at the top. But if the space there is also less than required display it below.
        if (point.y + dropdown.height > textInput.screen.height &&
            point.y > dropdown.height)
        {
            // Dropdown will go below the bottom of the stage
            // and be clipped. Instead, have it grow up.
            //it seems that the height property isn't read properly after the dataprovider is set,
            //so I calculate here myself with rowCount x rowHeight
            point.y -= (textInput.height + dropdown.rowCount * dropdown.rowHeight + 
            	textInput.getStyle("focusThickness") + textInput.getStyle("borderThickness"));
        }
        

        if (dropdown.x != point.x || dropdown.y != point.y)
            dropdown.move(point.x, point.y);
    }

	/**
     * @private
     * Resizes the dropdown to match its owner.
     * 
     * @param dropdown The dropdown instance
     */    
    protected function resizeDropdown(dropdown:ListBase):void
    { 
    	var textInput:TextInput = dropdown.owner as TextInput;
    	
    	dropdown.width = textInput.width;
    }
    	
	/**
	 *  @private
	 *  Adds a specific TextInput's text to a shared object of the same name
	 * 
	 * @param textInput The TextInput instance
	 * @return Whether the entry saved successfully or not
	 */
	protected function addEntry(textInput:TextInput):Boolean
	{
        //don't save password fields yet, as we don't have a means of encrypting yet
        if(textInput.displayAsPassword) return false;
        var status:String;
        
        if (textInput.id != null && textInput.id != "" && textInput.text != null && textInput.text != "")
        {
            
			var flag:Boolean=false;
			
			var s:String;
			var t:String;
				
			if(!_sharedObject.data.hasOwnProperty(textInput.id))
        	{
        		_sharedObject.data[textInput.id] = [];
        		_sharedObject.flush(minDiskSpace);
        	}
            //No shared object has been created so far
            var savedData : Array = _sharedObject.data[textInput.id];
            if (savedData == null)
                savedData = new Array();
			
			var n:int = savedData.length;
             //Check if this entry is there in the previously saved shared object data
             for(var i:int=0; i < n; i++)
             {
             	s= savedData[i];
				t= textInput.text;
				
				if(!caseSensitive)
				{
					s = s.toLowerCase();
					t = t.toLowerCase();
				}
				
				if(s == t)
				{
					flag=true;
					break;
				}
				
             }
        	//if we've passed the test, and this entry hasn't been added before
     		if(!flag)
     			savedData.push(textInput.text);
			else return true;
			
           _sharedObject.data[textInput.id] = savedData;
           
            try
    		{
    			status = _sharedObject.flush(minDiskSpace);
    		}
    		catch(e:Error)
    		{
    			
    		}
    		
    		if(status == SharedObjectFlushStatus.FLUSHED)
    		{
    			return true;
    		}
    		else return false;
        }
        return true;
	}	
	
	/**
	 *  @private
	 *  Removes a specific TextInput's text from a shared object of the same name
	 * 
	 * @param textInput The TextInput instance
	 */
	protected function removeEntry(textInput:TextInput):void
	{
        if (textInput.id != null && textInput.id != "" && textInput.text != null && textInput.text != "")
        {
            

            var savedData : Array = _sharedObject.data[textInput.id];
            
            if (savedData != null)
            {
            	_sharedObject.data[textInput.id] = null;
	           //write the shared object in the .sol file
		       _sharedObject.flush(minDiskSpace);
            }
           
        }
	}	
	
	/**
	 *  @private
	 *  Updates the dataProvider used for showing suggestions
	 * 
	 * @param textInput The TextInput instance
	 */
	protected function updateDataProvider(textInput:TextInput):void
	{
		var dp:ListCollectionView;
		
		_previousValue = textInput.text;
		
		if(_dataProvider)
		{
			dp = ListCollectionView(dataProvider);
		}
		
		else
		{
			if(!_sharedObject.data.hasOwnProperty(textInput.id))
	        {
	        	//if(textInput.length < 0) return;
	        	
	        	_sharedObject.data[textInput.id] = [];
	        	_sharedObject.flush(minDiskSpace);
	        }
		    
		    dp = new ArrayCollection(_sharedObject.data[textInput.id] as Array);
		}
        
	      
        if(dp == null)
        {
        	return;
        }
        
        _currentCollection = dp;
        _currentTypedText = textInput.text;
        
        _currentCollection.filterFunction = templateFilterFunction;
		_currentCollection.refresh();
		
		var dropdown:ListBase = getDropdownForTarget(textInput);
		dropdown.dataProvider = _currentCollection;
		dropdown.rowCount = (_currentCollection.length > maxRowCount ? maxRowCount : _currentCollection.length);	
		
		dispatchEvent(new Event("dataProviderUpdated"));
  	}
	
	
	/**
	 *  @private
	 * @param element The item in a list that should be checked
	 */
 	protected function templateFilterFunction(element:*):Boolean 
	{
		var flag:Boolean=false;
		if(filterFunction!=null)
			flag=filterFunction(element,_currentTypedText);
		return flag;
	}


    //----------------------------------
    //  labelField
    //----------------------------------

    /**
     *  @private
     *  Storage for labelField property.
     */
    private var _labelField:String = "label";

    /**
     *  The name of the field in the dataprovider to display as the label, as well
     *  as which item is used for filtering. 
     *  You set the <code>labelField</code> property if you are using a custom 
     *  dataprovider which is an array of objects or is XML, instead of a simple
     *  array of Strings.  
     *
     * 	@see #labelFunction
     *  @default "label"
     */
    public function get labelField():String
    {
        return _labelField;
    }

    /**
     *  @private
     */
    public function set labelField(value:String):void
    {
        if(_labelField == value) return;
        
        _labelField = value;

 		for each (var l:ListBase in _dropdowns)
        {
        	l.labelField = value;
        }
    }
    
     //----------------------------------
    //  wordWrap
    //----------------------------------

    /**
     *  @private
     *  Storage for wordWrap property.
     */
    private var _wordWrap:Boolean;

    /**
     *  Whether or not to wrap the text of each item in the 
     *  pop-up completion list. 
     *
     * 	@see mx.controls.List#wordWrap
     *  @default false
     */
    public function get wordWrap():Boolean
    {
        return _wordWrap;
    }

    /**
     *  @private
     */
    public function set wordWrap(value:Boolean):void
    {
        if(_wordWrap == value) return;
        
        _wordWrap = value;

 		for each (var l:ListBase in _dropdowns)
        {
        	l.wordWrap = l.variableRowHeight = value;
        }
    }
  
 	//----------------------------------
    //  labelFunction
    //----------------------------------

    /**
     *  @private
     *  Storage for labelFunction property.
     */
    private var _labelFunction:Function;


    /**
     *  A user-supplied function to run on each item in the dataprovider,
     *  to determine the label for display as well as for filtering.
     *  
     * <p>Generally, you can use the <code>labelField</code> property to 
     * display the item that you want, instead of using a function.</p>
     *
     *  <p>This function takes a single parameter, the item in the data provider 
     *  that you wish to use, and and returns a String based on that item.</p>
     *  <pre>
     *  f(item:Object):String
     * </pre>
     *
     * @see #labelField
     *  @default null
     */
    public function get labelFunction():Function
    {
        return _labelFunction;
    }

    /**
     *  @private
     */
    public function set labelFunction(value:Function):void
    {
        if(_labelFunction == value) return;
        
        _labelFunction = value;

 		for each (var l:ListBase in _dropdowns)
        {
        	l.labelFunction = value;
        }

    }

	/**
	 *  @private
	 * 
	 * @param element The item in the list to check against
	 * @param text The current String to check against the element
	 */
	protected function defaultFilterFunction(element:*, text:String):Boolean 
	{
	    
	    var label:String = itemToLabel(element);
	    
	    var txt:String = StringUtil.trim(text);
	    
	    if(!caseSensitive)
	    {
	    	label = label.toLowerCase();
	    	txt = txt.toLowerCase();
	    }
	    
	    return (label.substring(0,txt.length) == txt); 
	    
	}
	
	  
    /**
     *  Creates a String for an item in the dataprovider, which is
     *  based on the <code>labelField</code> and <code>labelFunction</code> properties.
     *  
     *
     *  @param data Object to be rendered.
     *	@see #labelField
     *  @see #labelFunction
     *  @return The string to be displayed based on the data.
     */
    public function itemToLabel(data:Object):String
    {
        var rtn:String = " ";
        if (data == null)
            return rtn;

        if (labelFunction != null)
            return labelFunction(data);

        if (data is XML)
        {
            try
            {
                if (data[labelField].length() != 0)
                    data = data[labelField];
            }
            catch (e:Error)
            {
            }
        }
       
        else if (data is Object)
        {
            try
            {
                if (data[labelField] != null)
                    data = data[labelField];
            }
            catch(e:Error)
            {
            }
        }

        if (data is String)
            return String(data);

        try
        {
        	
            rtn = data.toString();
            return rtn
        }
        catch(e:Error)
        {
        }

        return " ";
    }

	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 *  When a TextInput is focused out of
	 * 
	 * @param event The Event object passed in
	 */
  	protected function onFocusOut(event:Event):void
  	{
  		var textInput:TextInput = event.currentTarget as TextInput;
  		if(enabled && autoSave)
  		{
  			addEntry(textInput);
  		}
  		display(false, textInput);
  	}	
  	
    /**
     *  @private
     * 
     * @param event The MouseEvent object passed in
     */
    protected function dropdown_mouseDownOutsideHandler(event:MouseEvent):void
    {
        close(event);
    }

    /**
     *  @private
     * 
     * @param event The MouseEvent object passed in
     */
    protected function dropdown_mouseWheelOutsideHandler(event:MouseEvent):void
    {
        dropdown_mouseDownOutsideHandler(event);
    }

	/**
     *  @private
     * Resize dropdown if owner is resized
     * 
     * @param event The ResizeEvent object passed in
     */
    protected function onOwnerResized(event:ResizeEvent):void
    {
         var textInput:TextInput = event.currentTarget as TextInput;
         if(_currentDropdown != null) resizeDropdown(getDropdownForTarget(textInput));
    } 
    
	/**
     * @private
     * Resize dropdown if owner is moved
     * 
     * @param event The MoveEvent object passed in
     */
    protected function onOwnerMoved(event:MoveEvent):void
    {
         var textInput:TextInput = event.currentTarget as TextInput;
         if(_currentDropdown != null) positionDropdown(getDropdownForTarget(textInput));
    } 
    
	/**
     *  @private
     * Remove the dropdowns if the app is resized
     * 
     * @param event The Event object passed in
     */
    protected function stage_resizeHandler(event:Event):void
    {
         if(_currentDropdown != null) display(false, _currentDropdown.owner as TextInput);   
    } 
    
    /**
     *  @private
     * 
     * @param event The ListEvent object passed in
     */
    protected function dropdown_itemClickHandler(event:ListEvent):void
    {
        //TODO: this gets called on change as well
        var dropdown:ListBase = event.currentTarget as ListBase;
    	var textInput:TextInput = dropdown.owner as TextInput;
        textInput.text = itemToLabel(dropdown.selectedItem);
        close(event);  
    }

    /**
     *  @private
     * 
     * @param event The Event object passed in
     */
    protected function dropdown_changeHandler(event:ListEvent):void
    {
        var dropdown:ListBase = event.currentTarget as ListBase;
    	var textInput:TextInput = dropdown.owner as TextInput;
        textInput.text = itemToLabel(dropdown.selectedItem);
        textInput.setSelection(textInput.length, textInput.length);
       // event.
        dispatchEvent(event);
  	}

    /**
     *  @private
     * 
     * @param event The KeyboardEvent object passed in
     */
 protected function keyDownHandler(event:KeyboardEvent):void
    {
		// Make sure we know we are handling a keyDown, so if the 
        // dropdown sends out a "change" event we don't close it
        _inKeyDown = true;
		
		var textInput:TextInput = event.currentTarget as TextInput;
		var dropdown:ListBase;
		
        if (event.keyCode == Keyboard.ESCAPE)
        {
            _inKeyDown = false;
            display(false, textInput);
            textInput.text = _previousValue;
            event.stopPropagation();
            
        }
        else if (event.keyCode == Keyboard.LEFT || event.keyCode == Keyboard.RIGHT || event.keyCode == Keyboard.ENTER) 
        {
        	if(_currentDropdown && _currentCollection)
        	{
        		dropdown = getDropdownForTarget(textInput);
        		var item:Object = (_currentDropdown.selectedItem) ? _currentDropdown.selectedItem : _currentCollection.getItemAt(0);
        		dropdown.selectedItem = item;
        		textInput.text = (item) ? itemToLabel(item) : _previousValue;
        	}
        	
			_inKeyDown = false;
            display(false, textInput);
            event.stopPropagation();
        }
        
       else if((event.keyCode ==  Keyboard.BACKSPACE) || (autoFillEnabled && event.keyCode == Keyboard.DELETE))
		{
			_inKeyDown = false;
			_removeSelection= true;
			
			event.stopPropagation();
		} 
			    
        else
        {
            if (event.keyCode == Keyboard.UP ||
                event.keyCode == Keyboard.DOWN ||
                event.keyCode == Keyboard.PAGE_UP ||
				event.keyCode == Keyboard.HOME ||
				event.keyCode == Keyboard.END ||
                event.keyCode == Keyboard.PAGE_DOWN)
            {
            	dropdown = getDropdownForTarget(textInput);
            	
            	//Change selection of the drop down if it's there
            	if(dropdown.isPopUp)
            	{
            		var oldIndex:int = dropdown.selectedIndex;
            
	               //Add the ability to make the selection loop at the beginning or end
	            	if(dropdown.selectedIndex == dropdown.dataProvider.length - 1 &&  event.keyCode == Keyboard.DOWN)
					{
						if(loopSelection)
						{
							dropdown.selectedIndex = -1
							textInput.text = _previousValue;
						}
						
						event.stopPropagation();
					}
	            	
					else if(dropdown.selectedIndex == 0 &&  event.keyCode == Keyboard.UP)
					{
						if(loopSelection)
						{
							dropdown.selectedIndex = -1;
							textInput.text = _previousValue;
						}
						
						event.stopPropagation();
						
					}
					else
					{
		                switch (event.keyCode) {
							case Keyboard.UP:
							case Keyboard.PAGE_UP:
								if(dropdown.selectedIndex < 0)
								{
									dropdown.selectedIndex = dropdown.dataProvider.length - 1
								}
								else dropdown.selectedIndex --;
								
								dropdown.scrollToIndex(dropdown.selectedIndex);
								
								break;
							
							case Keyboard.PAGE_DOWN:
							case Keyboard.DOWN:
								if(dropdown.selectedIndex < 0)
								{
									dropdown.selectedIndex = 0
								}
								else dropdown.selectedIndex ++;
							
								dropdown.scrollToIndex(dropdown.selectedIndex);
									
								break;
								
							case Keyboard.HOME:
								dropdown.selectedIndex = 0;
								break;
								
							case Keyboard.END:
								dropdown.selectedIndex = dropdown.dataProvider.length - 1;
								break;
							
							default:
								dropdown.selectedIndex = 0;
							
						}
						
						if(oldIndex != dropdown.selectedIndex)
						{
							var currentItemRenderer:IListItemRenderer = dropdown.itemToItemRenderer(dropdown.selectedItem);
							var currentIndex:int = dropdown.itemRendererToIndex(currentItemRenderer);
				            var listEvent:ListEvent = new ListEvent(ListEvent.CHANGE);
				            
				            listEvent.rowIndex = currentIndex;
				            
				            listEvent.itemRenderer = currentItemRenderer;
				            					
				            dropdown.dispatchEvent(listEvent);	
						
							event.stopPropagation();
						}
					}
	             
            	}
            	
            	//not popped up, so pop it up on down or up arrow
            	else
            	{
            		if (event.keyCode == Keyboard.DOWN || event.keyCode == Keyboard.UP)
            		{
            			display(true, textInput);
            		}
            	}
            	
            }
            
        	_inKeyDown = false; 
        	_removeSelection = false;
    	}
    }

}
}
