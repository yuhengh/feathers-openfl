/*
Feathers
Copyright 2012-2014 Joshua Tynjala. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.text;
import feathers.controls.Scroller;
import feathers.utils.geom.matrixToRotation;
import feathers.utils.geom.matrixToScaleX;
import feathers.utils.geom.matrixToScaleY;
import feathers.utils.math.roundToNearest;

import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.text.TextField;

import starling.core.Starling;
import starling.utils.MatrixUtil;

/**
 * A text editor view port for the <code>TextArea</code> component that uses
 * <code>openfl.text.TextField</code>.
 *
 * @see feathers.controls.TextArea
 */
class TextFieldTextEditorViewPort extends TextFieldTextEditor implements ITextEditorViewPort
{
	/**
	 * @private
	 */
	inline private static var HELPER_MATRIX:Matrix = new Matrix();

	/**
	 * @private
	 */
	private static var HELPER_POINT:Point = new Point();

	/**
	 * Constructor.
	 */
	public function new()
	{
		super();
		this.multiline = true;
		this.wordWrap = true;
		this.resetScrollOnFocusOut = false;
	}

	/**
	 * @private
	 */
	private var _ignoreScrolling:Bool = false;

	/**
	 * @private
	 */
	private var _minVisibleWidth:Float = 0;

	/**
	 * @inheritDoc
	 */
	public var minVisibleWidth(get, set):Float;
	public function get_minVisibleWidth():Float
	{
		return this._minVisibleWidth;
	}

	/**
	 * @private
	 */
	public function set_minVisibleWidth(value:Float):Float
	{
		if(this._minVisibleWidth == value)
		{
			return;
		}
		if(value != value) //isNaN
		{
			throw new ArgumentError("minVisibleWidth cannot be Math.NaN");
		}
		this._minVisibleWidth = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}

	/**
	 * @private
	 */
	private var _maxVisibleWidth:Float = Math.POSITIVE_INFINITY;

	/**
	 * @inheritDoc
	 */
	public var maxVisibleWidth(get, set):Float;
	public function get_maxVisibleWidth():Float
	{
		return this._maxVisibleWidth;
	}

	/**
	 * @private
	 */
	public function set_maxVisibleWidth(value:Float):Float
	{
		if(this._maxVisibleWidth == value)
		{
			return;
		}
		if(value != value) //isNaN
		{
			throw new ArgumentError("maxVisibleWidth cannot be Math.NaN");
		}
		this._maxVisibleWidth = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}

	/**
	 * @private
	 */
	private var _visibleWidth:Float = Math.NaN;

	/**
	 * @inheritDoc
	 */
	public var visibleWidth(get, set):Float;
	public function get_visibleWidth():Float
	{
		return this._visibleWidth;
	}

	/**
	 * @private
	 */
	public function set_visibleWidth(value:Float):Float
	{
		if(this._visibleWidth == value ||
			(value != value && this._visibleWidth != this._visibleWidth)) //isNaN
		{
			return;
		}
		this._visibleWidth = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}

	/**
	 * @private
	 */
	private var _minVisibleHeight:Float = 0;

	/**
	 * @inheritDoc
	 */
	public var minVisibleHeight(get, set):Float;
	public function get_minVisibleHeight():Float
	{
		return this._minVisibleHeight;
	}

	/**
	 * @private
	 */
	public function set_minVisibleHeight(value:Float):Float
	{
		if(this._minVisibleHeight == value)
		{
			return;
		}
		if(value != value) //isNaN
		{
			throw new ArgumentError("minVisibleHeight cannot be Math.NaN");
		}
		this._minVisibleHeight = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}

	/**
	 * @private
	 */
	private var _maxVisibleHeight:Float = Math.POSITIVE_INFINITY;

	/**
	 * @inheritDoc
	 */
	public var maxVisibleHeight(get, set):Float;
	public function get_maxVisibleHeight():Float
	{
		return this._maxVisibleHeight;
	}

	/**
	 * @private
	 */
	public function set_maxVisibleHeight(value:Float):Float
	{
		if(this._maxVisibleHeight == value)
		{
			return;
		}
		if(value != value) //isNaN
		{
			throw new ArgumentError("maxVisibleHeight cannot be Math.NaN");
		}
		this._maxVisibleHeight = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}

	/**
	 * @private
	 */
	private var _visibleHeight:Float = Math.NaN;

	/**
	 * @inheritDoc
	 */
	public var visibleHeight(get, set):Float;
	public function get_visibleHeight():Float
	{
		return this._visibleHeight;
	}

	/**
	 * @private
	 */
	public function set_visibleHeight(value:Float):Float
	{
		if(this._visibleHeight == value ||
			(value != value && this._visibleHeight != this._visibleHeight)) //isNaN
		{
			return;
		}
		this._visibleHeight = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}

	public var contentX(get, set):Float;
	public function get_contentX():Float
	{
		return 0;
	}

	public var contentY(get, set):Float;
	public function get_contentY():Float
	{
		return 0;
	}

	/**
	 * @private
	 */
	private var _scrollStep:Int = 0;

	/**
	 * @inheritDoc
	 */
	public var horizontalScrollStep(get, set):Float;
	public function get_horizontalScrollStep():Float
	{
		return this._scrollStep;
	}

	/**
	 * @inheritDoc
	 */
	public var verticalScrollStep(get, set):Float;
	public function get_verticalScrollStep():Float
	{
		return this._scrollStep;
	}

	/**
	 * @private
	 */
	private var _horizontalScrollPosition:Float = 0;

	/**
	 * @inheritDoc
	 */
	public var horizontalScrollPosition(get, set):Float;
	public function get_horizontalScrollPosition():Float
	{
		return this._horizontalScrollPosition;
	}

	/**
	 * @private
	 */
	public function set_horizontalScrollPosition(value:Float):Float
	{
		if(this._horizontalScrollPosition == value)
		{
			return;
		}
		this._horizontalScrollPosition = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SCROLL);
		//hack because the superclass doesn't know about the scroll flag
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}

	/**
	 * @private
	 */
	private var _verticalScrollPosition:Float = 0;

	/**
	 * @inheritDoc
	 */
	public var verticalScrollPosition(get, set):Float;
	public function get_verticalScrollPosition():Float
	{
		return this._verticalScrollPosition;
	}

	/**
	 * @private
	 */
	public function set_verticalScrollPosition(value:Float):Float
	{
		if(this._verticalScrollPosition == value)
		{
			return;
		}
		this._verticalScrollPosition = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SCROLL);
		//hack because the superclass doesn't know about the scroll flag
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}

	/**
	 * @private
	 */
	override private function measure(result:Point = null):Point
	{
		if(!result)
		{
			result = new Point();
		}

		var needsWidth:Bool = this._visibleWidth != this._visibleWidth; //isNaN

		this.commitStylesAndData(this.measureTextField);

		var gutterDimensionsOffset:Float = 4;
		if(this._useGutter)
		{
			gutterDimensionsOffset = 0;
		}

		var newWidth:Float = this._visibleWidth;
		this.measureTextField.width = newWidth + gutterDimensionsOffset;
		if(needsWidth)
		{
			newWidth = this.measureTextField.width - gutterDimensionsOffset;
			if(newWidth < this._minVisibleWidth)
			{
				newWidth = this._minVisibleWidth;
			}
			else if(newWidth > this._maxVisibleWidth)
			{
				newWidth = this._maxVisibleWidth;
			}
		}
		var newHeight:Float = this.measureTextField.height - gutterDimensionsOffset;
		if(this._useGutter)
		{
			newHeight += 4;
		}

		result.x = newWidth;
		result.y = newHeight;

		return result;
	}

	/**
	 * @private
	 */
	override private function refreshSnapshotParameters():Void
	{
		var textFieldWidth:Float = this._visibleWidth;
		if(textFieldWidth != textFieldWidth) //isNaN
		{
			if(this._maxVisibleWidth < Math.POSITIVE_INFINITY)
			{
				textFieldWidth = this._maxVisibleWidth;
			}
			else
			{
				textFieldWidth = this._minVisibleWidth;
			}
		}
		var textFieldHeight:Float = this._visibleHeight;
		if(textFieldHeight != textFieldHeight) //isNaN
		{
			if(this._maxVisibleHeight < Math.POSITIVE_INFINITY)
			{
				textFieldHeight = this._maxVisibleHeight;
			}
			else
			{
				textFieldHeight = this._minVisibleHeight;
			}
		}

		this._textFieldOffsetX = 0;
		this._textFieldOffsetY = 0;
		this._textFieldClipRect.x = 0;
		this._textFieldClipRect.y = 0;

		this.getTransformationMatrix(this.stage, HELPER_MATRIX);
		var clipWidth:Float = textFieldWidth * Starling.current.contentScaleFactor * matrixToScaleX(HELPER_MATRIX);
		if(clipWidth < 0)
		{
			clipWidth = 0;
		}
		var clipHeight:Float = textFieldHeight * Starling.current.contentScaleFactor * matrixToScaleY(HELPER_MATRIX);
		if(clipHeight < 0)
		{
			clipHeight = 0;
		}
		this._textFieldClipRect.width = clipWidth;
		this._textFieldClipRect.height = clipHeight;
	}

	/**
	 * @private
	 */
	override private function refreshTextFieldSize():Void
	{
		var oldIgnoreScrolling:Bool = this._ignoreScrolling;
		var gutterDimensionsOffset:Float = 4;
		if(this._useGutter)
		{
			gutterDimensionsOffset = 0;
		}
		this._ignoreScrolling = true;
		this.textField.width = this._visibleWidth + gutterDimensionsOffset;
		var textFieldHeight:Float = this._visibleHeight + gutterDimensionsOffset;
		if(this.textField.height != textFieldHeight)
		{
			this.textField.height = textFieldHeight;
		}
		var scroller:Scroller = Scroller(this.parent);
		this.textField.scrollV = Math.round(1 + ((this.textField.maxScrollV - 1) * (this._verticalScrollPosition / scroller.maxVerticalScrollPosition)));
		this._ignoreScrolling = oldIgnoreScrolling;
	}

	/**
	 * @private
	 */
	override private function commitStylesAndData(textField:TextField):Void
	{
		super.commitStylesAndData(textField);
		if(textField == this.textField)
		{
			this._scrollStep = textField.getLineMetrics(0).height;
		}
	}

	/**
	 * @private
	 */
	override private function transformTextField():Void
	{
		if(!this.textField.visible)
		{
			return;
		}
		var nativeScaleFactor:Float = 1;
		if(Starling.current.supportHighResolutions)
		{
			nativeScaleFactor = Starling.current.nativeStage.contentsScaleFactor;
		}
		var scaleFactor:Float = Starling.current.contentScaleFactor / nativeScaleFactor;
		HELPER_POINT.x = HELPER_POINT.y = 0;
		this.getTransformationMatrix(this.stage, HELPER_MATRIX);
		MatrixUtil.transformCoords(HELPER_MATRIX, 0, 0, HELPER_POINT);
		var scaleX:Float = matrixToScaleX(HELPER_MATRIX) * scaleFactor;
		var scaleY:Float = matrixToScaleY(HELPER_MATRIX) * scaleFactor;
		var offsetX:Float = Math.round(this._horizontalScrollPosition * scaleX);
		var offsetY:Float = Math.round(this._verticalScrollPosition * scaleY);
		var starlingViewPort:Rectangle = Starling.current.viewPort;
		var gutterPositionOffset:Float = 2;
		if(this._useGutter)
		{
			gutterPositionOffset = 0;
		}
		this.textField.x = offsetX + Math.round(starlingViewPort.x + (HELPER_POINT.x * scaleFactor) - gutterPositionOffset * scaleX);
		this.textField.y = offsetY + Math.round(starlingViewPort.y + (HELPER_POINT.y * scaleFactor) - gutterPositionOffset * scaleY);
		this.textField.rotation = matrixToRotation(HELPER_MATRIX) * 180 / Math.PI;
		this.textField.scaleX = scaleX;
		this.textField.scaleY = scaleY;
	}

	/**
	 * @private
	 */
	override private function positionSnapshot():Void
	{
		if(!this.textSnapshot)
		{
			return;
		}
		this.getTransformationMatrix(this.stage, HELPER_MATRIX);
		this.textSnapshot.x = this._horizontalScrollPosition + Math.round(HELPER_MATRIX.tx) - HELPER_MATRIX.tx;
		this.textSnapshot.y = this._verticalScrollPosition + Math.round(HELPER_MATRIX.ty) - HELPER_MATRIX.ty;
	}

	/**
	 * @private
	 */
	override private function checkIfNewSnapshotIsNeeded():Void
	{
		super.checkIfNewSnapshotIsNeeded();
		this._needsNewTexture ||= this.isInvalid(FeathersControl.INVALIDATION_FLAG_SCROLL);
	}

	/**
	 * @private
	 */
	override private function textField_focusInHandler(event:FocusEvent):Void
	{
		this.textField.addEventListener(Event.SCROLL, textField_scrollHandler);
		super.textField_focusInHandler(event);
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}

	/**
	 * @private
	 */
	override private function textField_focusOutHandler(event:FocusEvent):Void
	{
		this.textField.removeEventListener(Event.SCROLL, textField_scrollHandler);
		super.textField_focusOutHandler(event);
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}

	/**
	 * @private
	 */
	private function textField_scrollHandler(event:Event):Void
	{
		//for some reason, the text field's scroll positions don't work
		//properly unless we access the values here. weird.
		var scrollH:Float = this.textField.scrollH;
		var scrollV:Float = this.textField.scrollV;
		if(this._ignoreScrolling)
		{
			return;
		}
		var scroller:Scroller = Scroller(this.parent);
		if(scroller.maxVerticalScrollPosition > 0 && this.textField.maxScrollV > 1)
		{
			var calculatedVerticalScrollPosition:Float = scroller.maxVerticalScrollPosition * (scrollV - 1) / (this.textField.maxScrollV - 1);
			scroller.verticalScrollPosition = roundToNearest(calculatedVerticalScrollPosition, this._scrollStep);
		}
	}

}
