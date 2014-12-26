/*
Feathers
Copyright 2012-2014 Joshua Tynjala. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.data;
import feathers.events.CollectionEventType;

import starling.events.Event;
import starling.events.EventDispatcher;

/**
 * Dispatched when the underlying data source changes and the ui will
 * need to redraw the data.
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
 */
[Event(name="change",type="starling.events.Event")]

/**
 * Dispatched when the collection has changed drastically, such as when
 * the underlying data source is replaced completely.
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
 * @eventType feathers.events.CollectionEventType.RESET
 */
[Event(name="reset",type="starling.events.Event")]

/**
 * Dispatched when an item is added to the collection.
 *
 * <p>The properties of the event object have the following values:</p>
 * <table class="innertable">
 * <tr><th>Property</th><th>Value</th></tr>
 * <tr><td><code>bubbles</code></td><td>false</td></tr>
 * <tr><td><code>currentTarget</code></td><td>The Object that defines the
 *   event listener that handles the event. For example, if you use
 *   <code>myButton.addEventListener()</code> to register an event listener,
 *   myButton is the value of the <code>currentTarget</code>.</td></tr>
 * <tr><td><code>data</code></td><td>The index path of the item that has
 * been added. It is of type <code>Array</code> and contains objects of
 * type <code>int</code>.</td></tr>
 * <tr><td><code>target</code></td><td>The Object that dispatched the event;
 *   it is not always the Object listening for the event. Use the
 *   <code>currentTarget</code> property to always access the Object
 *   listening for the event.</td></tr>
 * </table>
 *
 * @eventType feathers.events.CollectionEventType.ADD_ITEM
 */
[Event(name="addItem",type="starling.events.Event")]

/**
 * Dispatched when an item is removed from the collection.
 *
 * <p>The properties of the event object have the following values:</p>
 * <table class="innertable">
 * <tr><th>Property</th><th>Value</th></tr>
 * <tr><td><code>bubbles</code></td><td>false</td></tr>
 * <tr><td><code>currentTarget</code></td><td>The Object that defines the
 *   event listener that handles the event. For example, if you use
 *   <code>myButton.addEventListener()</code> to register an event listener,
 *   myButton is the value of the <code>currentTarget</code>.</td></tr>
 * <tr><td><code>data</code></td><td>The index path of the item that has
 * been removed. It is of type <code>Array</code> and contains objects of
 * type <code>int</code>.</td></tr>
 * <tr><td><code>target</code></td><td>The Object that dispatched the event;
 *   it is not always the Object listening for the event. Use the
 *   <code>currentTarget</code> property to always access the Object
 *   listening for the event.</td></tr>
 * </table>
 *
 * @eventType feathers.events.CollectionEventType.REMOVE_ITEM
 */
[Event(name="removeItem",type="starling.events.Event")]

/**
 * Dispatched when an item is replaced in the collection.
 *
 * <p>The properties of the event object have the following values:</p>
 * <table class="innertable">
 * <tr><th>Property</th><th>Value</th></tr>
 * <tr><td><code>bubbles</code></td><td>false</td></tr>
 * <tr><td><code>currentTarget</code></td><td>The Object that defines the
 *   event listener that handles the event. For example, if you use
 *   <code>myButton.addEventListener()</code> to register an event listener,
 *   myButton is the value of the <code>currentTarget</code>.</td></tr>
 * <tr><td><code>data</code></td><td>The index path of the item that has
 * been re[;aced. It is of type <code>Array</code> and contains objects of
 * type <code>int</code>.</td></tr>
 * <tr><td><code>target</code></td><td>The Object that dispatched the event;
 *   it is not always the Object listening for the event. Use the
 *   <code>currentTarget</code> property to always access the Object
 *   listening for the event.</td></tr>
 * </table>
 *
 * @eventType feathers.events.CollectionEventType.REPLACE_ITEM
 */
[Event(name="replaceItem",type="starling.events.Event")]

/**
 * Dispatched when a property of an item in the collection has changed
 * and the item doesn't have its own change event or signal. This event
 * is only dispatched when the <code>updateItemAt()</code> function is
 * called on the <code>HierarchicalCollection</code>.
 *
 * <p>In general, it's better for the items themselves to dispatch events
 * or signals when their properties change.</p>
 *
 * <p>The properties of the event object have the following values:</p>
 * <table class="innertable">
 * <tr><th>Property</th><th>Value</th></tr>
 * <tr><td><code>bubbles</code></td><td>false</td></tr>
 * <tr><td><code>currentTarget</code></td><td>The Object that defines the
 *   event listener that handles the event. For example, if you use
 *   <code>myButton.addEventListener()</code> to register an event listener,
 *   myButton is the value of the <code>currentTarget</code>.</td></tr>
 * <tr><td><code>data</code></td><td>The index path of the item that has
 * been updated. It is of type <code>Array</code> and contains objects of
 * type <code>int</code>.</td></tr>
 * <tr><td><code>target</code></td><td>The Object that dispatched the event;
 *   it is not always the Object listening for the event. Use the
 *   <code>currentTarget</code> property to always access the Object
 *   listening for the event.</td></tr>
 * </table>
 *
 * @eventType feathers.events.CollectionEventType.UPDATE_ITEM
 */
[Event(name="updateItem",type="starling.events.Event")]

[DefaultProperty("data")]
/**
 * Wraps a two-dimensional data source with a common API for use with UI
 * controls that support this type of data.
 */
class HierarchicalCollection extends EventDispatcher
{
	public function HierarchicalCollection(data:Object = null)
	{
		if(!data)
		{
			//default to an array if no data is provided
			data = [];
		}
		this.data = data;
	}

	/**
	 * @private
	 */
	private var _data:Object;

	/**
	 * The data source for this collection. May be any type of data, but a
	 * <code>dataDescriptor</code> needs to be provided to translate from
	 * the data source's APIs to something that can be understood by
	 * <code>HierarchicalCollection</code>.
	 */
	public function get_data():Object
	{
		return _data;
	}

	/**
	 * @private
	 */
	public function set_data(value:Object):Void
	{
		if(this._data == value)
		{
			return;
		}
		this._data = value;
		this.dispatchEventWith(CollectionEventType.RESET);
		this.dispatchEventWith(Event.CHANGE);
	}

	/**
	 * @private
	 */
	private var _dataDescriptor:IHierarchicalCollectionDataDescriptor = new ArrayChildrenHierarchicalCollectionDataDescriptor();

	/**
	 * Describes the underlying data source by translating APIs.
	 */
	public function get_dataDescriptor():IHierarchicalCollectionDataDescriptor
	{
		return this._dataDescriptor;
	}

	/**
	 * @private
	 */
	public function set_dataDescriptor(value:IHierarchicalCollectionDataDescriptor):Void
	{
		if(this._dataDescriptor == value)
		{
			return;
		}
		this._dataDescriptor = value;
		this.dispatchEventWith(CollectionEventType.RESET);
		this.dispatchEventWith(Event.CHANGE);
	}

	/**
	 * Determines if a node from the data source is a branch.
	 */
	public function isBranch(node:Object):Bool
	{
		return this._dataDescriptor.isBranch(node);
	}

	/**
	 * The number of items at the specified location in the collection.
	 */
	public function getLength(...rest:Array):Int
	{
		rest.unshift(this._data);
		return this._dataDescriptor.getLength.apply(null, rest);
	}

	/**
	 * If an item doesn't dispatch an event or signal to indicate that it
	 * has changed, you can manually tell the collection about the change,
	 * and the collection will dispatch the <code>CollectionEventType.UPDATE_ITEM</code>
	 * event to manually notify the component that renders the data.
	 */
	public function updateItemAt(index:Int, ...rest:Array):Void
	{
		rest.unshift(index);
		this.dispatchEventWith(CollectionEventType.UPDATE_ITEM, false, rest);
	}

	/**
	 * Returns the item at the specified location in the collection.
	 */
	public function getItemAt(index:Int, ...rest:Array):Object
	{
		rest.unshift(index);
		rest.unshift(this._data);
		return this._dataDescriptor.getItemAt.apply(null, rest);
	}

	/**
	 * Determines which location the item appears at within the collection. If
	 * the item isn't in the collection, returns <code>null</code>.
	 */
	public function getItemLocation(item:Object, result:Array<int> = null):Array<int>
	{
		return this._dataDescriptor.getItemLocation(this._data, item, result);
	}

	/**
	 * Adds an item to the collection, at the specified location.
	 */
	public function addItemAt(item:Object, index:Int, ...rest:Array):Void
	{
		rest.unshift(index);
		rest.unshift(item);
		rest.unshift(this._data);
		this._dataDescriptor.addItemAt.apply(null, rest);
		this.dispatchEventWith(Event.CHANGE);
		rest.shift();
		rest.shift();
		this.dispatchEventWith(CollectionEventType.ADD_ITEM, false, rest);
	}

	/**
	 * Removes the item at the specified location from the collection and
	 * returns it.
	 */
	public function removeItemAt(index:Int, ...rest:Array):Object
	{
		rest.unshift(index);
		rest.unshift(this._data);
		var item:Object = this._dataDescriptor.removeItemAt.apply(null, rest);
		this.dispatchEventWith(Event.CHANGE);
		rest.shift();
		this.dispatchEventWith(CollectionEventType.REMOVE_ITEM, false, rest);
		return item;
	}

	/**
	 * Removes a specific item from the collection.
	 */
	public function removeItem(item:Object):Void
	{
		var location:Array<int> = this.getItemLocation(item);
		if(location)
		{
			//this is hacky. a future version probably won't use rest args.
			var locationAsArray:Array = [];
			var indexCount:Int = location.length;
			for(var i:Int = 0; i < indexCount; i++)
			{
				locationAsArray.push(location[i]);
			}
			this.removeItemAt.apply(this, locationAsArray);
		}
	}

	/**
	 * Replaces the item at the specified location with a new item.
	 */
	public function setItemAt(item:Object, index:Int, ...rest:Array):Void
	{
		rest.unshift(index);
		rest.unshift(item);
		rest.unshift(this._data);
		this._dataDescriptor.setItemAt.apply(null, rest);
		rest.shift();
		rest.shift();
		this.dispatchEventWith(CollectionEventType.REPLACE_ITEM, false, rest);
		this.dispatchEventWith(Event.CHANGE);
	}

	/**
	 * Calls a function for each group in the collection and another
	 * function for each item in a group, where each function handles any
	 * properties that require disposal on these objects. For example,
	 * display objects or textures may need to be disposed. You may pass in
	 * a value of <code>null</code> for either function if you don't have
	 * anything to dispose in one or the other.
	 *
	 * <p>The function to dispose a group is expected to have the following signature:</p>
	 * <pre>function( group:Object ):Void</pre>
	 *
	 * <p>The function to dispose an item is expected to have the following signature:</p>
	 * <pre>function( item:Object ):Void</pre>
	 *
	 * <p>In the following example, the items in the collection are disposed:</p>
	 *
	 * <listing version="3.0">
	 * collection.dispose( function( group:Object ):Void
	 * {
	 *     var content:DisplayObject = DisplayObject(group.content);
	 *     content.dispose();
	 * },
	 * function( item:Object ):Void
	 * {
	 *     var accessory:DisplayObject = DisplayObject(item.accessory);
	 *     accessory.dispose();
	 * },)</listing>
	 *
	 * @see http://doc.starling-framework.org/core/starling/display/DisplayObject.html#dispose() starling.display.DisplayObject.dispose()
	 * @see http://doc.starling-framework.org/core/starling/textures/Texture.html#dispose() starling.textures.Texture.dispose()
	 */
	public function dispose(disposeGroup:Function, disposeItem:Function):Void
	{
		var groupCount:Int = this.getLength();
		var path:Array = [];
		for(var i:Int = 0; i < groupCount; i++)
		{
			var group:Object = this.getItemAt(i);
			path[0] = i;
			this.disposeGroupInternal(group, path, disposeGroup, disposeItem);
			path.length = 0;
		}
	}

	/**
	 * @private
	 */
	private function disposeGroupInternal(group:Object, path:Array, disposeGroup:Function, disposeItem:Function):Void
	{
		if(disposeGroup != null)
		{
			disposeGroup(group);
		}

		var itemCount:Int = this.getLength.apply(this, path);
		for(var i:Int = 0; i < itemCount; i++)
		{
			path[path.length] = i;
			var item:Object = this.getItemAt.apply(this, path);
			if(this.isBranch(item))
			{
				this.disposeGroupInternal(item, path, disposeGroup, disposeItem);
			}
			else if(disposeItem != null)
			{
				disposeItem(item);
			}
			path.length--;
		}
	}
}
