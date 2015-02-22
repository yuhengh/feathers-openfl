/*
Feathers
Copyright 2012-2014 Joshua Tynjala. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.text;
import openfl.text.TextFormatAlign;

import starling.text.BitmapFont;
import starling.text.TextField;

/**
 * Customizes a bitmap font for use by a <code>BitmapFontTextRenderer</code>.
 * 
 * @see feathers.controls.text.BitmapFontTextRenderer
 */
class BitmapFontTextFormat
{
	/**
	 * Constructor.
	 */
	public function new(font:Dynamic, size:Float = Math.NaN, color:UInt = 0xffffff, align:String = TextFormatAlign.LEFT)
	{
		if(font is String)
		{
			font = TextField.getBitmapFont(font as String);
		}
		if(!(font is BitmapFont))
		{
			throw new ArgumentError("BitmapFontTextFormat font must be a BitmapFont instance or a String representing the name of a registered bitmap font.");
		}
		this.font = BitmapFont(font);
		this.size = size;
		this.color = color;
		this.align = align;
	}

	/**
	 * The name of the font.
	 */
	public var fontName(get, set):String;
	public function get_fontName():String
	{
		return this.font ? this.font.name : null;
	}
	
	/**
	 * The BitmapFont instance to use.
	 */
	public var font:BitmapFont;
	
	/**
	 * The multiply color.
	 *
	 * @default 0xffffff
	 */
	public var color:UInt;
	
	/**
	 * The size at which to display the bitmap font. Set to <code>Math.NaN</code>
	 * to use the default size in the BitmapFont instance.
	 *
	 * @default Math.NaN
	 */
	public var size:Float;
	
	/**
	 * The number of extra pixels between characters. May be positive or
	 * negative.
	 *
	 * @default 0
	 */
	public var letterSpacing:Float = 0;

	[Inspectable(type="String",enumeration="left,center,right")]
	/**
	 * Determines the alignment of the text, either left, center, or right.
	 *
	 * @default openfl.text.TextFormatAlign.LEFT
	 */
	public var align:String = TextFormatAlign.LEFT;
	
	/**
	 * Determines if the kerning values defined in the BitmapFont instance
	 * will be used for layout.
	 *
	 * @default true
	 */
	public var isKerningEnabled:Bool = true;
}