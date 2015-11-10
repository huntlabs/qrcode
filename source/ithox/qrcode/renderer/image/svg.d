module ithox.qrcode.renderer.image.svg;

import ithox.qrcode.renderer.image.abstractrender;
import ithox.qrcode.renderer.color.colorinterface;


import std.xml,std.conv, std.format;
/**
* SVG backend.
*/
class Svg : AbstractRenderer
{
	/**
	* SVG resource.
	*
	* @var Document
	*/
    protected Document svg;

	protected Element defs;
    /**
	* Colors used for drawing.
	*
	* @var array
	*/
    protected ColorInterface[string]colors;
    /**
	* Prototype IDs.
	*
	* @var array
	*/
    protected string[string] prototypeIds;

	/**
	* init(): defined by RendererInterface.
	*
	* @see    ImageRendererInterface::init()
	* @return void
	*/
    public override void initRender()
    {
		auto tag = new Tag("svg");
		tag.attr["xmlns"] = "http://www.w3.org/2000/svg";
		tag.attr["xmlns:xlink"] = "http://www.w3.org/1999/xlink";
		tag.attr["version"] = "1.1";
		tag.attr["width"] = to!string(this.finalWidth) ~ "px";
		tag.attr["height"] = to!string(this.finalHeight) ~ "px";
		tag.attr["viewBox"] = "0 0 " ~ to!string(this.finalWidth) ~ " " ~ to!string(this.finalHeight);
		this.svg = new Document(tag);
		this.defs = new Element("defs");
		//this.svg ~= element;
    }


	/**
	* addColor(): defined by RendererInterface.
	*
	* @see    ImageRendererInterface::addColor()
	* @param  string         id
	* @param  ColorInterface color
	* @return void
	* @throws Exception\InvalidArgumentException
	*/
    public override void addColor(string id, ColorInterface color)
    {
        this.colors[id] = color.toRgb();
    }
    /**
	* drawBackground(): defined by RendererInterface.
	*
	* @see    ImageRendererInterface::drawBackground()
	* @param  string colorId
	* @return void
	*/
    public override void drawBackground(string colorId)
    {
		auto rect = new Element("rect");
		rect.tag.attr["x"] = "0";
		rect.tag.attr["y"] = "0";
		rect.tag.attr["width"] = to!string(this.finalWidth);
		rect.tag.attr["height"] = to!string(this.finalHeight);
		rect.tag.attr["fill"] = "#" ~ this.colors[colorId].toString();
		this.svg ~= rect;
    }
    /**
	* drawBlock(): defined by RendererInterface.
	*
	* @see    ImageRendererInterface::drawBlock()
	* @param  integer x
	* @param  integer y
	* @param  string  colorId
	* @return void
	*/
    public override void drawBlock(int x, int y, string colorId)
    {

		auto use = new Element("use");
		use.tag.attr["x"] = to!string(x);
		use.tag.attr["y"] = to!string(y);
		use.tag.attr["xlink:href"] = this.getRectPrototypeId(colorId);
		use.tag.attr["xmlns:xmi"] = "http://www.w3.org/1999/xlink";

      
		this.svg ~= use;
    }
    /**
	* getByteStream(): defined by RendererInterface.
	*
	* @see    ImageRendererInterface::getByteStream()
	* @return string
	*/
    public override string getByteStream()
    {
		import std.string;
		this.svg ~= this.defs;
        return this.svg.toString();
    }
    /**
	* Get the prototype ID for a color.
	*
	* @param  integer colorId
	* @return string
	*/
    protected string getRectPrototypeId(string colorId)
    {
		auto p = colorId in this.prototypeIds;
		if(p)
		{
			return *p;
		}
        auto id = "r" ~ format("%X", this.prototypeIds.length);
        //srect = this.svg.defs.addChild('rect');
		auto rect = new Element("rect");
		rect.tag.attr["id"] = id;
		rect.tag.attr["width"] = to!string(this.blockSize);
		rect.tag.attr["height"] = to!string(this.blockSize);
		rect.tag.attr["fill"] =  "#" ~ this.colors[colorId].toString();
		this.defs ~= rect;
        /*rect.addAttribute('id', id);
        rect.addAttribute('width', this.blockSize);
        rect.addAttribute('height', this.blockSize);
        rect.addAttribute('fill', '#' . this.colors[colorId]);
		*/
        this.prototypeIds[colorId] = "#" ~ id;
        return this.prototypeIds[colorId];
    }
}