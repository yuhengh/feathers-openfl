/*
Feathers
Copyright 2012-2014 Joshua Tynjala. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;
import feathers.controls.popups.CalloutPopUpContentManager;
import feathers.controls.popups.IPopUpContentManager;
import feathers.controls.popups.VerticalCenteredPopUpContentManager;
import feathers.controls.renderers.IListItemRenderer;
import feathers.core.FeathersControl;
import feathers.core.IFocusDisplayObject;
import feathers.core.IToggle;
import feathers.core.PropertyProxy;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.skins.IStyleProvider;
import feathers.system.DeviceCapabilities;

import openfl.ui.Keyboard;

import starling.core.Starling;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.events.KeyboardEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

/**
 * Dispatched when the selected item changes.
 *
 * <p>The properties of the event object have the following values:</p>
 * <table class="innertable">
 * <tr><th>Property</th><th>Value</th></tr>
 * <tr><td><code>bubbles</code></td><td>false</td></tr>
 * <tr><td><code>currentTarget</code></td><td>The Object that defines the
 *   event listener that handles the event. For example, if you use
 *   <code>myButton.addEventListener()</code> to register an event listener,
 *   myButton is the value of the <code>currentTarget</code>.</td></tr>
 * <tr><td><code>data</code></td><td>null</td></tr>
 * <tr><td><code>target</code></td><td>The Object that dispatched the event;
 *   it is not always the Object listening for the event. Use the
 *   <code>currentTarget</code> property to always access the Object
 *   listening for the event.</td></tr>
 * </table>
 *
 * @eventType starling.events.Event.CHANGE
 *///[Event(name="change",type="starling.events.Event")]

/**
 * A combo-box like list control. Displayed as a button. The list appears
 * on tap as a full-screen overlay.
 *
 * <p>The following example creates a picker list, gives it a data provider,
 * tells the item renderer how to interpret the data, and listens for when
 * the selection changes:</p>
 *
 * <listing version="3.0">
 * var list:PickerList = new PickerList();
 *
 * list.dataProvider = new ListCollection(
 * [
 *     { text: "Milk", thumbnail: textureAtlas.getTexture( "milk" ) },
 *     { text: "Eggs", thumbnail: textureAtlas.getTexture( "eggs" ) },
 *     { text: "Bread", thumbnail: textureAtlas.getTexture( "bread" ) },
 *     { text: "Chicken", thumbnail: textureAtlas.getTexture( "chicken" ) },
 * ]);
 *
 * list.listProperties.itemRendererFactory = function():IListItemRenderer
 * {
 *     var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
 *     renderer.labelField = "text";
 *     renderer.iconSourceField = "thumbnail";
 *     return renderer;
 * };
 *
 * list.addEventListener( Event.CHANGE, list_changeHandler );
 *
 * this.addChild( list );</listing>
 *
 * @see http://wiki.starling-framework.org/feathers/picker-list
 */
class PickerList extends FeathersControl implements IFocusDisplayObject
{
	/**
	 * @private
	 */
	inline private static var INVALIDATION_FLAG_BUTTON_FACTORY:String = "buttonFactory";

	/**
	 * @private
	 */
	inline private static var INVALIDATION_FLAG_LIST_FACTORY:String = "listFactory";

	/**
	 * The default value added to the <code>styleNameList</code> of the button.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	inline public static var DEFAULT_CHILD_NAME_BUTTON:String = "feathers-picker-list-button";

	/**
	 * The default value added to the <code>styleNameList</code> of the pop-up
	 * list.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	inline public static var DEFAULT_CHILD_NAME_LIST:String = "feathers-picker-list-list";

	/**
	 * The default <code>IStyleProvider</code> for all <code>PickerList</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;

	/**
	 * @private
	 */
	private static function defaultButtonFactory():Button
	{
		return new Button();
	}

	/**
	 * @private
	 */
	private static function defaultListFactory():List
	{
		return new List();
	}

	/**
	 * Constructor.
	 */
	public function new()
	{
		super();
	}

	/**
	 * The default value added to the <code>styleNameList</code> of the button. This
	 * variable is <code>private</code> so that sub-classes can customize
	 * the button name in their constructors instead of using the default
	 * name defined by <code>DEFAULT_CHILD_NAME_BUTTON</code>.
	 *
	 * <p>To customize the button name without subclassing, see
	 * <code>customButtonName</code>.</p>
	 *
	 * @see #customButtonName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var buttonName:String = DEFAULT_CHILD_NAME_BUTTON;

	/**
	 * The default value added to the <code>styleNameList</code> of the pop-up list. This
	 * variable is <code>private</code> so that sub-classes can customize
	 * the list name in their constructors instead of using the default
	 * name defined by <code>DEFAULT_CHILD_NAME_LIST</code>.
	 *
	 * <p>To customize the pop-up list name without subclassing, see
	 * <code>customListName</code>.</p>
	 *
	 * @see #customListName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var listName:String = DEFAULT_CHILD_NAME_LIST;

	/**
	 * The button sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #buttonFactory
	 * @see #createButton()
	 */
	private var button:Button;

	/**
	 * The list sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #listFactory
	 * @see #createList()
	 */
	private var list:List;

	/**
	 * @private
	 */
	override private function get_defaultStyleProvider():IStyleProvider
	{
		return PickerList.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	private var _dataProvider:ListCollection;
	
	/**
	 * The collection of data displayed by the list.
	 *
	 * <p>The following example passes in a data provider and tells the item
	 * renderer how to interpret the data:</p>
	 *
	 * <listing version="3.0">
	 * list.dataProvider = new ListCollection(
	 * [
	 *     { text: "Milk", thumbnail: textureAtlas.getTexture( "milk" ) },
	 *     { text: "Eggs", thumbnail: textureAtlas.getTexture( "eggs" ) },
	 *     { text: "Bread", thumbnail: textureAtlas.getTexture( "bread" ) },
	 *     { text: "Chicken", thumbnail: textureAtlas.getTexture( "chicken" ) },
	 * ]);
	 *
	 * list.listProperties.itemRendererFactory = function():IListItemRenderer
	 * {
	 *     var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
	 *     renderer.labelField = "text";
	 *     renderer.iconSourceField = "thumbnail";
	 *     return renderer;
	 * };</listing>
	 *
	 * @default null
	 */
	public var dataProvider(get, set):ListCollection;
	public function get_dataProvider():ListCollection
	{
		return this._dataProvider;
	}
	
	/**
	 * @private
	 */
	public function set_dataProvider(value:ListCollection):ListCollection
	{
		if(this._dataProvider == value)
		{
			return;
		}
		var oldSelectedIndex:Int = this.selectedIndex;
		var oldSelectedItem:Dynamic = this.selectedItem;
		this._dataProvider = value;
		if(!this._dataProvider || this._dataProvider.length == 0)
		{
			this.selectedIndex = -1;
		}
		else
		{
			this.selectedIndex = 0;
		}
		//this ensures that Event.CHANGE will dispatch for selectedItem
		//changing, even if selectedIndex has not changed.
		if(this.selectedIndex == oldSelectedIndex && this.selectedItem != oldSelectedItem)
		{
			this.dispatchEventWith(Event.CHANGE);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}

	/**
	 * @private
	 */
	private var _ignoreSelectionChanges:Bool = false;
	
	/**
	 * @private
	 */
	private var _selectedIndex:Int = -1;
	
	/**
	 * The index of the currently selected item. Returns <code>-1</code> if
	 * no item is selected.
	 *
	 * <p>The following example selects an item by its index:</p>
	 *
	 * <listing version="3.0">
	 * list.selectedIndex = 2;</listing>
	 *
	 * <p>The following example clears the selected index:</p>
	 *
	 * <listing version="3.0">
	 * list.selectedIndex = -1;</listing>
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected index:</p>
	 *
	 * <listing version="3.0">
	 * function list_changeHandler( event:Event ):Void
	 * {
	 *     var list:PickerList = PickerList( event.currentTarget );
	 *     var index:Int = list.selectedIndex;
	 *
	 * }
	 * list.addEventListener( Event.CHANGE, list_changeHandler );</listing>
	 *
	 * @default -1
	 *
	 * @see #selectedItem
	 */
	public var selectedIndex(get, set):Int;
	public function get_selectedIndex():Int
	{
		return this._selectedIndex;
	}
	
	/**
	 * @private
	 */
	public function set_selectedIndex(value:Int):Int
	{
		if(this._selectedIndex == value)
		{
			return;
		}
		this._selectedIndex = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		this.dispatchEventWith(Event.CHANGE);
	}
	
	/**
	 * The currently selected item. Returns <code>null</code> if no item is
	 * selected.
	 *
	 * <p>The following example changes the selected item:</p>
	 *
	 * <listing version="3.0">
	 * list.selectedItem = list.dataProvider.getItemAt(0);</listing>
	 *
	 * <p>The following example clears the selected item:</p>
	 *
	 * <listing version="3.0">
	 * list.selectedItem = null;</listing>
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected item:</p>
	 *
	 * <listing version="3.0">
	 * function list_changeHandler( event:Event ):Void
	 * {
	 *     var list:PickerList = PickerList( event.currentTarget );
	 *     var item:Dynamic = list.selectedItem;
	 *
	 * }
	 * list.addEventListener( Event.CHANGE, list_changeHandler );</listing>
	 *
	 * @default null
	 *
	 * @see #selectedIndex
	 */
	public var selectedItem(get, set):Dynamic;
	public function get_selectedItem():Dynamic
	{
		if(!this._dataProvider || this._selectedIndex < 0 || this._selectedIndex >= this._dataProvider.length)
		{
			return null;
		}
		return this._dataProvider.getItemAt(this._selectedIndex);
	}
	
	/**
	 * @private
	 */
	public function set_selectedItem(value:Dynamic):Dynamic
	{
		if(!this._dataProvider)
		{
			this.selectedIndex = -1;
			return;
		}
		this.selectedIndex = this._dataProvider.getItemIndex(value);
	}

	/**
	 * @private
	 */
	private var _prompt:String;

	/**
	 * Text displayed by the button sub-component when no items are
	 * currently selected.
	 *
	 * <p>In the following example, a prompt is given to the picker list
	 * and the selected item is cleared to display the prompt:</p>
	 *
	 * <listing version="3.0">
	 * list.prompt = "Select an Item";
	 * list.selectedIndex = -1;</listing>
	 *
	 * @default null
	 */
	public var prompt(get, set):String;
	public function get_prompt():String
	{
		return this._prompt;
	}

	/**
	 * @private
	 */
	public function set_prompt(value:String):String
	{
		if(this._prompt == value)
		{
			return;
		}
		this._prompt = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
	}
	
	/**
	 * @private
	 */
	private var _labelField:String = "label";
	
	/**
	 * The field in the selected item that contains the label text to be
	 * displayed by the picker list's button control. If the selected item
	 * does not have this field, and a <code>labelFunction</code> is not
	 * defined, then the picker list will default to calling
	 * <code>toString()</code> on the selected item. To omit the
	 * label completely, define a <code>labelFunction</code> that returns an
	 * empty string.
	 *
	 * <p><strong>Important:</strong> This value only affects the selected
	 * item displayed by the picker list's button control. It will <em>not</em>
	 * affect the label text of the pop-up list's item renderers.</p>
	 *
	 * <p>In the following example, the label field is changed:</p>
	 *
	 * <listing version="3.0">
	 * list.labelField = "text";</listing>
	 *
	 * @default "label"
	 *
	 * @see #labelFunction
	 */
	public var labelField(get, set):String;
	public function get_labelField():String
	{
		return this._labelField;
	}
	
	/**
	 * @private
	 */
	public function set_labelField(value:String):String
	{
		if(this._labelField == value)
		{
			return;
		}
		this._labelField = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	/**
	 * @private
	 */
	private var _labelFunction:Dynamic;

	/**
	 * A function used to generate label text for the selected item
	 * displayed by the picker list's button control. If this
	 * function is not null, then the <code>labelField</code> will be
	 * ignored.
	 *
	 * <p><strong>Important:</strong> This value only affects the selected
	 * item displayed by the picker list's button control. It will <em>not</em>
	 * affect the label text of the pop-up list's item renderers.</p>
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Dynamic ):String</pre>
	 *
	 * <p>All of the label fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>labelFunction</code></li>
	 *     <li><code>labelField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the label field is changed:</p>
	 *
	 * <listing version="3.0">
	 * list.labelFunction = function( item:Dynamic ):String
	 * {
	 *     return item.firstName + " " + item.lastName;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #labelField
	 */
	public var labelFunction(get, set):Dynamic;
	public function get_labelFunction():Dynamic
	{
		return this._labelFunction;
	}
	
	/**
	 * @private
	 */
	public function set_labelFunction(value:Dynamic):Dynamic
	{
		this._labelFunction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	/**
	 * @private
	 */
	private var _popUpContentManager:IPopUpContentManager;
	
	/**
	 * A manager that handles the details of how to display the pop-up list.
	 *
	 * <p>In the following example, a pop-up content manager is provided:</p>
	 *
	 * <listing version="3.0">
	 * list.popUpContentManager = new CalloutPopUpContentManager();</listing>
	 *
	 * @default null
	 */
	public var popUpContentManager(get, set):IPopUpContentManager;
	public function get_popUpContentManager():IPopUpContentManager
	{
		return this._popUpContentManager;
	}
	
	/**
	 * @private
	 */
	public function set_popUpContentManager(value:IPopUpContentManager):IPopUpContentManager
	{
		if(this._popUpContentManager == value)
		{
			return;
		}
		if(Std.is(this._popUpContentManager, EventDispatcher))
		{
			var dispatcher:EventDispatcher = EventDispatcher(this._popUpContentManager);
			dispatcher.removeEventListener(Event.OPEN, popUpContentManager_openHandler);
			dispatcher.removeEventListener(Event.CLOSE, popUpContentManager_closeHandler);
		}
		this._popUpContentManager = value;
		if(Std.is(this._popUpContentManager, EventDispatcher))
		{
			dispatcher = EventDispatcher(this._popUpContentManager);
			dispatcher.addEventListener(Event.OPEN, popUpContentManager_openHandler);
			dispatcher.addEventListener(Event.CLOSE, popUpContentManager_closeHandler);
		}
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private var _typicalItemWidth:Float = Math.NaN;

	/**
	 * @private
	 */
	private var _typicalItemHeight:Float = Math.NaN;
	
	/**
	 * @private
	 */
	private var _typicalItem:Dynamic = null;
	
	/**
	 * Used to auto-size the list. If the list's width or height is Math.NaN, the
	 * list will try to automatically pick an ideal size. This item is
	 * used in that process to create a sample item renderer.
	 *
	 * <p>The following example provides a typical item:</p>
	 *
	 * <listing version="3.0">
	 * list.typicalItem = { text: "A typical item", thumbnail: texture };
	 * list.itemRendererProperties.labelField = "text";
	 * list.itemRendererProperties.iconSourceField = "thumbnail";</listing>
	 *
	 * @default null
	 */
	public var typicalItem(get, set):Dynamic;
	public function get_typicalItem():Dynamic
	{
		return this._typicalItem;
	}
	
	/**
	 * @private
	 */
	public function set_typicalItem(value:Dynamic):Dynamic
	{
		if(this._typicalItem == value)
		{
			return;
		}
		this._typicalItem = value;
		this._typicalItemWidth = Math.NaN;
		this._typicalItemHeight = Math.NaN;
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private var _buttonFactory:Dynamic;

	/**
	 * A function used to generate the picker list's button sub-component.
	 * The button must be an instance of <code>Button</code>. This factory
	 * can be used to change properties on the button when it is first
	 * created. For instance, if you are skinning Feathers components
	 * without a theme, you might use this factory to set skins and other
	 * styles on the button.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():Button</pre>
	 *
	 * <p>In the following example, a custom button factory is passed to the
	 * picker list:</p>
	 *
	 * <listing version="3.0">
	 * list.buttonFactory = function():Button
	 * {
	 *     var button:Button = new Button();
	 *     button.defaultSkin = new Image( upTexture );
	 *     button.downSkin = new Image( downTexture );
	 *     return button;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.Button
	 * @see #buttonProperties
	 */
	public var buttonFactory(get, set):Dynamic;
	public function get_buttonFactory():Dynamic
	{
		return this._buttonFactory;
	}

	/**
	 * @private
	 */
	public function set_buttonFactory(value:Dynamic):Dynamic
	{
		if(this._buttonFactory == value)
		{
			return;
		}
		this._buttonFactory = value;
		this.invalidate(INVALIDATION_FLAG_BUTTON_FACTORY);
	}

	/**
	 * @private
	 */
	private var _customButtonName:String;

	/**
	 * A name to add to the picker list's button sub-component. Typically
	 * used by a theme to provide different skins to different picker lists.
	 *
	 * <p>In the following example, a custom button name is passed to the
	 * picker list:</p>
	 *
	 * <listing version="3.0">
	 * list.customButtonName = "my-custom-button";</listing>
	 *
	 * <p>In your theme, you can target this sub-component name to provide
	 * different skins than the default style:</p>
	 *
	 * <listing version="3.0">
	 * getStyleProviderForClass( Button ).setFunctionForStyleName( "my-custom-button", setCustomButtonStyles );</listing>
	 *
	 * @default null
	 *
	 * @see #DEFAULT_CHILD_NAME_BUTTON
	 * @see feathers.core.FeathersControl#styleNameList
	 * @see #buttonFactory
	 * @see #buttonProperties
	 */
	public var customButtonName(get, set):String;
	public function get_customButtonName():String
	{
		return this._customButtonName;
	}

	/**
	 * @private
	 */
	public function set_customButtonName(value:String):String
	{
		if(this._customButtonName == value)
		{
			return;
		}
		this._customButtonName = value;
		this.invalidate(INVALIDATION_FLAG_BUTTON_FACTORY);
	}
	
	/**
	 * @private
	 */
	private var _buttonProperties:PropertyProxy;
	
	/**
	 * A set of key/value pairs to be passed down to the picker's button
	 * sub-component. It is a <code>feathers.controls.Button</code>
	 * instance that is created by <code>buttonFactory</code>.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>buttonFactory</code> function
	 * instead of using <code>buttonProperties</code> will result in better
	 * performance.</p>
	 *
	 * <p>In the following example, the button properties are passed to the
	 * picker list:</p>
	 *
	 * <listing version="3.0">
	 * list.buttonProperties.defaultSkin = new Image( upTexture );
	 * list.buttonProperties.downSkin = new Image( downTexture );</listing>
	 *
	 * @default null
	 *
	 * @see #buttonFactory
	 * @see feathers.controls.Button
	 */
	public var buttonProperties(get, set):Dynamic;
	public function get_buttonProperties():Dynamic
	{
		if(!this._buttonProperties)
		{
			this._buttonProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._buttonProperties;
	}
	
	/**
	 * @private
	 */
	public function set_buttonProperties(value:Dynamic):Dynamic
	{
		if(this._buttonProperties == value)
		{
			return;
		}
		if(!value)
		{
			value = new PropertyProxy();
		}
		if(!(Std.is(value, PropertyProxy)))
		{
			var newValue:PropertyProxy = new PropertyProxy();
			for (propertyName in value)
			{
				newValue[propertyName] = value[propertyName];
			}
			value = newValue;
		}
		if(this._buttonProperties)
		{
			this._buttonProperties.removeOnChangeCallback(childProperties_onChange);
		}
		this._buttonProperties = PropertyProxy(value);
		if(this._buttonProperties)
		{
			this._buttonProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private var _listFactory:Dynamic;

	/**
	 * A function used to generate the picker list's pop-up list
	 * sub-component. The list must be an instance of <code>List</code>.
	 * This factory can be used to change properties on the list when it is
	 * first created. For instance, if you are skinning Feathers components
	 * without a theme, you might use this factory to set skins and other
	 * styles on the list.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():List</pre>
	 *
	 * <p>In the following example, a custom list factory is passed to the
	 * picker list:</p>
	 *
	 * <listing version="3.0">
	 * list.listFactory = function():List
	 * {
	 *     var popUpList:List = new List();
	 *     popUpList.backgroundSkin = new Image( texture );
	 *     return popUpList;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.List
	 * @see #listProperties
	 */
	public var listFactory(get, set):Dynamic;
	public function get_listFactory():Dynamic
	{
		return this._listFactory;
	}

	/**
	 * @private
	 */
	public function set_listFactory(value:Dynamic):Dynamic
	{
		if(this._listFactory == value)
		{
			return;
		}
		this._listFactory = value;
		this.invalidate(INVALIDATION_FLAG_LIST_FACTORY);
	}

	/**
	 * @private
	 */
	private var _customListName:String;

	/**
	 * A name to add to the picker list's list sub-component. Typically used
	 * by a theme to provide different skins to different picker lists.
	 *
	 * <p>In the following example, a custom list name is passed to the
	 * picker list:</p>
	 *
	 * <listing version="3.0">
	 * list.customListName = "my-custom-list";</listing>
	 *
	 * <p>In your theme, you can target this sub-component name to provide
	 * different skins than the default style:</p>
	 *
	 * <listing version="3.0">
	 * getStyleProviderForClass( List ).setFunctionForStyleName( "my-custom-list", setCustomListStyles );</listing>
	 *
	 * @default null
	 *
	 * @see #DEFAULT_CHILD_NAME_LIST
	 * @see feathers.core.FeathersControl#styleNameList
	 * @see #listFactory
	 * @see #listProperties
	 */
	public var customListName(get, set):String;
	public function get_customListName():String
	{
		return this._customListName;
	}

	/**
	 * @private
	 */
	public function set_customListName(value:String):String
	{
		if(this._customListName == value)
		{
			return;
		}
		this._customListName = value;
		this.invalidate(INVALIDATION_FLAG_LIST_FACTORY);
	}
	
	/**
	 * @private
	 */
	private var _listProperties:PropertyProxy;
	
	/**
	 * A set of key/value pairs to be passed down to the picker's pop-up
	 * list sub-component. The pop-up list is a
	 * <code>feathers.controls.List</code> instance that is created by
	 * <code>listFactory</code>.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>listFactory</code> function
	 * instead of using <code>listProperties</code> will result in better
	 * performance.</p>
	 *
	 * <p>In the following example, the list properties are passed to the
	 * picker list:</p>
	 *
	 * <listing version="3.0">
	 * list.listProperties.backgroundSkin = new Image( texture );</listing>
	 *
	 * @default null
	 *
	 * @see #listFactory
	 * @see feathers.controls.List
	 */
	public var listProperties(get, set):Dynamic;
	public function get_listProperties():Dynamic
	{
		if(!this._listProperties)
		{
			this._listProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._listProperties;
	}
	
	/**
	 * @private
	 */
	public function set_listProperties(value:Dynamic):Dynamic
	{
		if(this._listProperties == value)
		{
			return;
		}
		if(!value)
		{
			value = new PropertyProxy();
		}
		if(!(Std.is(value, PropertyProxy)))
		{
			var newValue:PropertyProxy = new PropertyProxy();
			for (propertyName in value)
			{
				newValue[propertyName] = value[propertyName];
			}
			value = newValue;
		}
		if(this._listProperties)
		{
			this._listProperties.removeOnChangeCallback(childProperties_onChange);
		}
		this._listProperties = PropertyProxy(value);
		if(this._listProperties)
		{
			this._listProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private var _toggleButtonOnOpenAndClose:Bool = false;

	/**
	 * Determines if the <code>isSelected</code> property of the picker
	 * list's button sub-component is toggled when the list is opened and
	 * closed, if the class used to create the thumb implements the
	 * <code>IToggle</code> interface. Useful for skinning to provide a
	 * different appearance for the button based on whether the list is open
	 * or not.
	 *
	 * <p>In the following example, the button is toggled on open and close:</p>
	 *
	 * <listing version="3.0">
	 * list.toggleButtonOnOpenAndClose = true;</listing>
	 *
	 * @default false
	 *
	 * @see feathers.core.IToggle
	 * @see feathers.controls.ToggleButton
	 */
	public var toggleButtonOnOpenAndClose(get, set):Bool;
	public function get_toggleButtonOnOpenAndClose():Bool
	{
		return this._toggleButtonOnOpenAndClose;
	}

	/**
	 * @private
	 */
	public function set_toggleButtonOnOpenAndClose(value:Bool):Bool
	{
		if(this._toggleButtonOnOpenAndClose == value)
		{
			return;
		}
		this._toggleButtonOnOpenAndClose = value;
		if(Std.is(this.button, IToggle))
		{
			if(this._toggleButtonOnOpenAndClose && this._popUpContentManager.isOpen)
			{
				IToggle(this.button).isSelected = true;
			}
			else
			{
				IToggle(this.button).isSelected = false;
			}
		}
	}

	/**
	 * @private
	 */
	private var _isOpenListPending:Bool = false;

	/**
	 * @private
	 */
	private var _isCloseListPending:Bool = false;
	
	/**
	 * Using <code>labelField</code> and <code>labelFunction</code>,
	 * generates a label from the selected item to be displayed by the
	 * picker list's button control.
	 *
	 * <p><strong>Important:</strong> This value only affects the selected
	 * item displayed by the picker list's button control. It will <em>not</em>
	 * affect the label text of the pop-up list's item renderers.</p>
	 */
	public function itemToLabel(item:Dynamic):String
	{
		if(this._labelFunction != null)
		{
			var labelResult:Dynamic = this._labelFunction(item);
			if(Std.is(labelResult, String))
			{
				return labelResult as String;
			}
			return labelResult.toString();
		}
		else if(this._labelField != null && item && item.hasOwnProperty(this._labelField))
		{
			labelResult = item[this._labelField];
			if(Std.is(labelResult, String))
			{
				return labelResult as String;
			}
			return labelResult.toString();
		}
		else if(Std.is(item, String))
		{
			return item as String;
		}
		else if(item)
		{
			return item.toString();
		}
		return "";
	}

	/**
	 * @private
	 */
	private var _buttonHasFocus:Bool = false;

	/**
	 * @private
	 */
	private var _buttonTouchPointID:Int = -1;

	/**
	 * @private
	 */
	private var _listIsOpenOnTouchBegan:Bool = false;

	/**
	 * Opens the pop-up list, if it isn't already open.
	 */
	public function openList():Void
	{
		this._isCloseListPending = false;
		if(this._popUpContentManager.isOpen)
		{
			return;
		}
		if(!this._isValidating && this.isInvalid())
		{
			this._isOpenListPending = true;
			return;
		}
		this._isOpenListPending = false;
		this._popUpContentManager.open(this.list, this);
		this.list.scrollToDisplayIndex(this._selectedIndex);
		this.list.validate();
		if(this._focusManager)
		{
			this._focusManager.focus = this.list;
			this.stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
			this.list.addEventListener(FeathersEventType.FOCUS_OUT, list_focusOutHandler);
		}
	}

	/**
	 * Closes the pop-up list, if it is open.
	 */
	public function closeList():Void
	{
		this._isOpenListPending = false;
		if(!this._popUpContentManager.isOpen)
		{
			return;
		}
		if(!this._isValidating && this.isInvalid())
		{
			this._isCloseListPending = true;
			return;
		}
		this._isCloseListPending = false;
		this.list.validate();
		//don't clean up anything from openList() in closeList(). The list
		//may be closed by removing it from the PopUpManager, which would
		//result in closeList() never being called.
		//instead, clean up in the Event.REMOVED_FROM_STAGE listener.
		this._popUpContentManager.close();
	}
	
	/**
	 * @inheritDoc
	 */
	override public function dispose():Void
	{
		if(this.list)
		{
			this.closeList();
			this.list.dispose();
			this.list = null;
		}
		if(this._popUpContentManager)
		{
			this._popUpContentManager.dispose();
			this._popUpContentManager = null;
		}
		super.dispose();
	}

	/**
	 * @private
	 */
	override public function showFocus():Void
	{
		if(!this.button)
		{
			return;
		}
		this.button.showFocus();
	}

	/**
	 * @private
	 */
	override public function hideFocus():Void
	{
		if(!this.button)
		{
			return;
		}
		this.button.hideFocus();
	}
	
	/**
	 * @private
	 */
	override private function initialize():Void
	{
		if(!this._popUpContentManager)
		{
			if(DeviceCapabilities.isTablet(Starling.current.nativeStage))
			{
				this.popUpContentManager = new CalloutPopUpContentManager();
			}
			else
			{
				this.popUpContentManager = new VerticalCenteredPopUpContentManager();
			}
		}

	}
	
	/**
	 * @private
	 */
	override private function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var stylesInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_STYLES);
		var stateInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_STATE);
		var selectionInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SELECTED);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		var buttonFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_BUTTON_FACTORY);
		var listFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_LIST_FACTORY);

		if(buttonFactoryInvalid)
		{
			this.createButton();
		}

		if(listFactoryInvalid)
		{
			this.createList();
		}
		
		if(buttonFactoryInvalid || stylesInvalid || selectionInvalid)
		{
			//this section asks the button to auto-size again, if our
			//explicit dimensions aren't set.
			//set this before buttonProperties is used because it might
			//contain width or height changes.
			if(this.explicitWidth != this.explicitWidth) //isNaN
			{
				this.button.width = Math.NaN;
			}
			if(this.explicitHeight != this.explicitHeight) //isNaN
			{
				this.button.height = Math.NaN;
			}
		}

		if(buttonFactoryInvalid || stylesInvalid)
		{
			this._typicalItemWidth = Math.NaN;
			this._typicalItemHeight = Math.NaN;
			this.refreshButtonProperties();
		}

		if(listFactoryInvalid || stylesInvalid)
		{
			this.refreshListProperties();
		}
		
		if(listFactoryInvalid || dataInvalid)
		{
			var oldIgnoreSelectionChanges:Bool = this._ignoreSelectionChanges;
			this._ignoreSelectionChanges = true;
			this.list.dataProvider = this._dataProvider;
			this._ignoreSelectionChanges = oldIgnoreSelectionChanges;
		}
		
		if(buttonFactoryInvalid || listFactoryInvalid || stateInvalid)
		{
			this.button.isEnabled = this._isEnabled;
			this.list.isEnabled = this._isEnabled;
		}

		if(buttonFactoryInvalid || dataInvalid || selectionInvalid)
		{
			this.refreshButtonLabel();
		}
		if(listFactoryInvalid || dataInvalid || selectionInvalid)
		{
			oldIgnoreSelectionChanges = this._ignoreSelectionChanges;
			this._ignoreSelectionChanges = true;
			this.list.selectedIndex = this._selectedIndex;
			this._ignoreSelectionChanges = oldIgnoreSelectionChanges;
		}

		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;

		if(buttonFactoryInvalid || stylesInvalid || sizeInvalid || selectionInvalid)
		{
			this.layout();
		}

		this.handlePendingActions();
	}

	/**
	 * If the component's dimensions have not been set explicitly, it will
	 * measure its content and determine an ideal size for itself. If the
	 * <code>explicitWidth</code> or <code>explicitHeight</code> member
	 * variables are set, those value will be used without additional
	 * measurement. If one is set, but not the other, the dimension with the
	 * explicit value will not be measured, but the other non-explicit
	 * dimension will still need measurement.
	 *
	 * <p>Calls <code>setSizeInternal()</code> to set up the
	 * <code>actualWidth</code> and <code>actualHeight</code> member
	 * variables used for layout.</p>
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 */
	private function autoSizeIfNeeded():Bool
	{
		var needsWidth:Bool = this.explicitWidth != this.explicitWidth; //isNaN
		var needsHeight:Bool = this.explicitHeight != this.explicitHeight; //isNaN
		if(!needsWidth && !needsHeight)
		{
			return false;
		}

		var buttonWidth:Float;
		var buttonHeight:Float;
		if(this._typicalItem)
		{
			if(this._typicalItemWidth != this._typicalItemWidth || //isNaN
				this._typicalItemHeight != this._typicalItemHeight) //isNaN
			{
				var oldWidth:Float = this.button.width;
				var oldHeight:Float = this.button.height;
				this.button.width = Math.NaN;
				this.button.height = Math.NaN;
				if(this._typicalItem)
				{
					this.button.label = this.itemToLabel(this._typicalItem);
				}
				this.button.validate();
				this._typicalItemWidth = this.button.width;
				this._typicalItemHeight = this.button.height;
				this.refreshButtonLabel();
				this.button.width = oldWidth;
				this.button.height = oldHeight;
			}
			buttonWidth = this._typicalItemWidth;
			buttonHeight = this._typicalItemHeight;
		}
		else
		{
			this.button.validate();
			buttonWidth = this.button.width;
			buttonHeight = this.button.height;
		}

		var newWidth:Float = this.explicitWidth;
		var newHeight:Float = this.explicitHeight;
		if(needsWidth)
		{
			if(buttonWidth == buttonWidth) //!isNaN
			{
				newWidth = buttonWidth;
			}
			else
			{
				newWidth = 0;
			}
		}
		if(needsHeight)
		{
			if(buttonHeight == buttonHeight) //!isNaN
			{
				newHeight = buttonHeight;
			}
			else
			{
				newHeight = 0;
			}
		}

		return this.setSizeInternal(newWidth, newHeight, false);
	}

	/**
	 * Creates and adds the <code>button</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #button
	 * @see #buttonFactory
	 * @see #customButtonName
	 */
	private function createButton():Void
	{
		if(this.button)
		{
			this.button.removeFromParent(true);
			this.button = null;
		}

		var factory:Dynamic = this._buttonFactory != null ? this._buttonFactory : defaultButtonFactory;
		var buttonName:String = this._customButtonName != null ? this._customButtonName : this.buttonName;
		this.button = Button(factory());
		if(Std.is(this.button, ToggleButton))
		{
			//we'll control the value of isSelected manually
			ToggleButton(this.button).isToggle = false;
		}
		this.button.styleNameList.add(buttonName);
		this.button.addEventListener(TouchEvent.TOUCH, button_touchHandler);
		this.button.addEventListener(Event.TRIGGERED, button_triggeredHandler);
		this.addChild(this.button);
	}

	/**
	 * Creates and adds the <code>list</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #list
	 * @see #listFactory
	 * @see #customListName
	 */
	private function createList():Void
	{
		if(this.list)
		{
			this.list.removeFromParent(false);
			//disposing separately because the list may not have a parent
			this.list.dispose();
			this.list = null;
		}

		var factory:Dynamic = this._listFactory != null ? this._listFactory : defaultListFactory;
		var listName:String = this._customListName != null ? this._customListName : this.listName;
		this.list = List(factory());
		this.list.focusOwner = this;
		this.list.styleNameList.add(listName);
		this.list.addEventListener(Event.CHANGE, list_changeHandler);
		this.list.addEventListener(FeathersEventType.RENDERER_ADD, list_rendererAddHandler);
		this.list.addEventListener(FeathersEventType.RENDERER_REMOVE, list_rendererRemoveHandler);
		this.list.addEventListener(Event.REMOVED_FROM_STAGE, list_removedFromStageHandler);
	}
	
	/**
	 * @private
	 */
	private function refreshButtonLabel():Void
	{
		if(this._selectedIndex >= 0)
		{
			this.button.label = this.itemToLabel(this.selectedItem);
		}
		else
		{
			this.button.label = this._prompt;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshButtonProperties():Void
	{
		for (propertyName in this._buttonProperties)
		{
			var propertyValue:Dynamic = this._buttonProperties[propertyName];
			this.button[propertyName] = propertyValue;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshListProperties():Void
	{
		for (propertyName in this._listProperties)
		{
			var propertyValue:Dynamic = this._listProperties[propertyName];
			this.list[propertyName] = propertyValue;
		}
	}

	/**
	 * @private
	 */
	private function layout():Void
	{
		this.button.width = this.actualWidth;
		this.button.height = this.actualHeight;

		//final validation to avoid juggler next frame issues
		this.button.validate();
	}

	/**
	 * @private
	 */
	private function handlePendingActions():Void
	{
		if(this._isOpenListPending)
		{
			this.openList();
		}
		if(this._isCloseListPending)
		{
			this.closeList();
		}
	}

	/**
	 * @private
	 */
	override private function focusInHandler(event:Event):Void
	{
		super.focusInHandler(event);
		this._buttonHasFocus = true;
		this.button.dispatchEventWith(FeathersEventType.FOCUS_IN);
	}

	/**
	 * @private
	 */
	override private function focusOutHandler(event:Event):Void
	{
		if(this._buttonHasFocus)
		{
			this.button.dispatchEventWith(FeathersEventType.FOCUS_OUT);
			this._buttonHasFocus = false;
		}
		super.focusOutHandler(event);
	}

	/**
	 * @private
	 */
	private function childProperties_onChange(proxy:PropertyProxy, name:String):Void
	{
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private function button_touchHandler(event:TouchEvent):Void
	{
		if(this._buttonTouchPointID >= 0)
		{
			var touch:Touch = event.getTouch(this.button, TouchPhase.ENDED, this._buttonTouchPointID);
			if(!touch)
			{
				return;
			}
			this._buttonTouchPointID = -1;
			//the button will dispatch Event.TRIGGERED before this touch
			//listener is called, so it is safe to clear this flag.
			//we're clearing it because Event.TRIGGERED may also be
			//dispatched after keyboard input.
			this._listIsOpenOnTouchBegan = false;
		}
		else
		{
			touch = event.getTouch(this.button, TouchPhase.BEGAN);
			if(!touch)
			{
				return;
			}
			this._buttonTouchPointID = touch.id;
			this._listIsOpenOnTouchBegan = this._popUpContentManager.isOpen;
		}
	}
	
	/**
	 * @private
	 */
	private function button_triggeredHandler(event:Event):Void
	{
		if(this._focusManager && this._listIsOpenOnTouchBegan)
		{
			return;
		}
		if(this._popUpContentManager.isOpen)
		{
			this.closeList();
			return;
		}
		this.openList();
	}
	
	/**
	 * @private
	 */
	private function list_changeHandler(event:Event):Void
	{
		if(this._ignoreSelectionChanges)
		{
			return;
		}
		this.selectedIndex = this.list.selectedIndex;
	}

	/**
	 * @private
	 */
	private function list_rendererAddHandler(event:Event, renderer:IListItemRenderer):Void
	{
		renderer.addEventListener(Event.TRIGGERED, renderer_triggeredHandler);
	}

	/**
	 * @private
	 */
	private function list_rendererRemoveHandler(event:Event, renderer:IListItemRenderer):Void
	{
		renderer.removeEventListener(Event.TRIGGERED, renderer_triggeredHandler);
	}

	/**
	 * @private
	 */
	private function popUpContentManager_openHandler(event:Event):Void
	{
		if(this._toggleButtonOnOpenAndClose && this.button is IToggle)
		{
			IToggle(this.button).isSelected = true;
		}
	}

	/**
	 * @private
	 */
	private function popUpContentManager_closeHandler(event:Event):Void
	{
		if(this._toggleButtonOnOpenAndClose && this.button is IToggle)
		{
			IToggle(this.button).isSelected = false;
		}
	}

	/**
	 * @private
	 */
	private function list_removedFromStageHandler(event:Event):Void
	{
		if(this._focusManager)
		{
			this.list.stage.removeEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
			this.list.removeEventListener(FeathersEventType.FOCUS_OUT, list_focusOutHandler);
		}
	}

	/**
	 * @private
	 */
	private function list_focusOutHandler(event:Event):Void
	{
		if(!this._popUpContentManager.isOpen)
		{
			return;
		}
		this.closeList();
	}

	/**
	 * @private
	 */
	private function renderer_triggeredHandler(event:Event):Void
	{
		if(!this._isEnabled)
		{
			return;
		}
		this.closeList();
	}

	/**
	 * @private
	 */
	private function stage_keyUpHandler(event:KeyboardEvent):Void
	{
		if(!this._popUpContentManager.isOpen)
		{
			return;
		}
		if(event.keyCode == Keyboard.ENTER)
		{
			this.closeList();
		}
	}
}