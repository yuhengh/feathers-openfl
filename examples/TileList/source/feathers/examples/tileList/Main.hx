package feathers.examples.tileList;
import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.controls.List;
import feathers.controls.PageIndicator;
import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.TiledRowsLayout;
import feathers.text.BitmapFontTextFormat;
import openfl.Assets;
import openfl.geom.Rectangle;

import starling.display.Image;
import starling.events.Event;
import starling.text.BitmapFont;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class Main extends LayoutGroup
{
	//[Embed(source="/../assets/images/atlas.png")]
	//inline private static var ICONS_IMAGE:Class<Dynamic>;
	inline private static var ICONS_IMAGE_FILE_NAME:String = "assets/images/atlas.png";

	//[Embed(source="/../assets/images/atlas.xml",mimeType="application/octet-stream")]
	//inline private static var ICONS_XML:Class<Dynamic>;
	inline private static var ICONS_XML_FILE_NAME:String = "assets/images/atlas.xml";

	//[Embed(source="/../assets/images/arial20.fnt",mimeType="application/octet-stream")]
	//inline private static var FONT_XML:Class<Dynamic>;
	inline private static var FONT_XML_FILE_NAME:String = "assets/images/arial20.fnt";

	public function new()
	{
		super();
		//the container will fill the whole stage and resize when the stage
		//resizes.
		this.autoSizeMode = LayoutGroup.AUTO_SIZE_MODE_STAGE;
	}

	private var _iconAtlas:TextureAtlas;
	private var _font:BitmapFont;
	private var _list:List;
	private var _pageIndicator:PageIndicator;

	override public function dispose():Void
	{
		//don't forget to clean up textures and things!
		if(this._iconAtlas != null)
		{
			this._iconAtlas.dispose();
			this._iconAtlas = null;
		}
		if(this._font != null)
		{
			this._font.dispose();
			this._font = null;
		}
		super.dispose();
	}

	override private function initialize():Void
	{
		//a nice, fluid layout
		this.layout = new AnchorLayout();

		//setting up some assets for skinning
		this._iconAtlas = new TextureAtlas(Texture.fromBitmapData(Assets.getBitmapData(ICONS_IMAGE_FILE_NAME), false), Xml.parse(Assets.getText(ICONS_XML_FILE_NAME)).firstElement());
		this._font = new BitmapFont(this._iconAtlas.getTexture("arial20_0"), Xml.parse(Assets.getText(FONT_XML_FILE_NAME)).firstElement());
		var pageIndicatorNormalSymbol:Texture = this._iconAtlas.getTexture("normal-page-symbol");
		var pageIndicatorSelectedSymbol:Texture = this._iconAtlas.getTexture("selected-page-symbol");

		//the page indicator can be used to scroll the list
		this._pageIndicator = new PageIndicator();
		this._pageIndicator.pageCount = 1;
		this._pageIndicator.normalSymbolFactory = function():Image
		{
			return new Image(pageIndicatorNormalSymbol);
		}
		this._pageIndicator.selectedSymbolFactory = function():Image
		{
			return new Image(pageIndicatorSelectedSymbol);
		}
		this._pageIndicator.direction = PageIndicator.DIRECTION_HORIZONTAL;
		this._pageIndicator.gap = 4;
		this._pageIndicator.padding = 6;

		//we listen to the change event to update the list's scroll position
		this._pageIndicator.addEventListener(Event.CHANGE, pageIndicator_changeHandler);

		//we'll position the page indicator on the bottom and stretch its
		//width to fill the container's width
		var pageIndicatorLayoutData:AnchorLayoutData = new AnchorLayoutData();
		pageIndicatorLayoutData.bottom = 0;
		pageIndicatorLayoutData.left = 0;
		pageIndicatorLayoutData.right = 0;
		this._pageIndicator.layoutData = pageIndicatorLayoutData;

		this.addChild(this._pageIndicator);

		//the data that will be displayed in the list
		var collection:ListCollection = new ListCollection(
		[
			{ label: "Facebook", texture: this._iconAtlas.getTexture("facebook") },
			{ label: "Twitter", texture: this._iconAtlas.getTexture("twitter") },
			{ label: "Google", texture: this._iconAtlas.getTexture("google") },
			{ label: "YouTube", texture: this._iconAtlas.getTexture("youtube") },
			{ label: "StumbleUpon", texture: this._iconAtlas.getTexture("stumbleupon") },
			{ label: "Yahoo", texture: this._iconAtlas.getTexture("yahoo") },
			{ label: "Tumblr", texture: this._iconAtlas.getTexture("tumblr") },
			{ label: "Blogger", texture: this._iconAtlas.getTexture("blogger") },
			{ label: "Reddit", texture: this._iconAtlas.getTexture("reddit") },
			{ label: "Flickr", texture: this._iconAtlas.getTexture("flickr") },
			{ label: "Yelp", texture: this._iconAtlas.getTexture("yelp") },
			{ label: "Vimeo", texture: this._iconAtlas.getTexture("vimeo") },
			{ label: "LinkedIn", texture: this._iconAtlas.getTexture("linkedin") },
			{ label: "Delicious", texture: this._iconAtlas.getTexture("delicious") },
			{ label: "FriendFeed", texture: this._iconAtlas.getTexture("friendfeed") },
			{ label: "MySpace", texture: this._iconAtlas.getTexture("myspace") },
			{ label: "Digg", texture: this._iconAtlas.getTexture("digg") },
			{ label: "DeviantArt", texture: this._iconAtlas.getTexture("deviantart") },
			{ label: "Picasa", texture: this._iconAtlas.getTexture("picasa") },
			{ label: "LiveJournal", texture: this._iconAtlas.getTexture("livejournal") },
			{ label: "Slashdot", texture: this._iconAtlas.getTexture("slashdot") },
			{ label: "Bebo", texture: this._iconAtlas.getTexture("bebo") },
			{ label: "Viddler", texture: this._iconAtlas.getTexture("viddler") },
			{ label: "Newsvine", texture: this._iconAtlas.getTexture("newsvine") },
			{ label: "Posterous", texture: this._iconAtlas.getTexture("posterous") },
			{ label: "Orkut", texture: this._iconAtlas.getTexture("orkut") },
		]);

		this._list = new List();
		this._list.dataProvider = collection;
		this._list.snapToPages = true;
		this._list.scrollBarDisplayMode = List.SCROLL_BAR_DISPLAY_MODE_NONE;
		this._list.horizontalScrollPolicy = List.SCROLL_POLICY_ON;
		this._list.itemRendererFactory = tileListItemRendererFactory;

		//we listen to the scroll event to update the page indicator
		this._list.addEventListener(Event.SCROLL, list_scrollHandler);

		//this is the list's layout...
		var listLayout:TiledRowsLayout = new TiledRowsLayout();
		listLayout.paging = TiledRowsLayout.PAGING_HORIZONTAL;
		listLayout.useSquareTiles = false;
		listLayout.tileHorizontalAlign = TiledRowsLayout.TILE_HORIZONTAL_ALIGN_CENTER;
		listLayout.horizontalAlign = TiledRowsLayout.HORIZONTAL_ALIGN_CENTER;
		listLayout.padding = 20;
		listLayout.gap = 20;
		this._list.layout = listLayout;

		//...while this is the layout data used by the list's parent
		var listLayoutData:AnchorLayoutData = new AnchorLayoutData();
		listLayoutData.top = 0;
		listLayoutData.right = 0;
		listLayoutData.bottom = 0;
		listLayoutData.bottomAnchorDisplayObject = this._pageIndicator;
		listLayoutData.left = 0;
		//this list fills the container's width and the remaining height
		//above the page indicator
		this._list.layoutData = listLayoutData;

		this.addChild(this._list);
	}
	
	private function tileListItemRendererFactory():IListItemRenderer
	{
		var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
		renderer.labelField = "label";
		renderer.iconSourceField = "texture";
		renderer.iconPosition = Button.ICON_POSITION_TOP;
		renderer.defaultLabelProperties.setProperty("textFormat", new BitmapFontTextFormat(this._font, Math.NaN, 0x000000));
		return renderer;
	}

	private function list_scrollHandler(event:Event):Void
	{
		this._pageIndicator.pageCount = this._list.horizontalPageCount;
		this._pageIndicator.selectedIndex = this._list.horizontalPageIndex;
	}

	private function pageIndicator_changeHandler(event:Event):Void
	{
		this._list.scrollToPageIndex(this._pageIndicator.selectedIndex, 0, this._list.pageThrowDuration);
	}
}
