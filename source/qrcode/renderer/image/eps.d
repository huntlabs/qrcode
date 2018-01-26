module qrcode.renderer.image.eps;

import qrcode.renderer.image.abstractrender;
import qrcode.renderer.color.colorinterface;
import qrcode.renderer.color.cmyk;
import qrcode.renderer.color.rgb;
import qrcode.renderer.color.gray;

import std.format, std.conv;

/**
* EPS backend.
*/
class Eps : AbstractRenderer
{
	/**
	* EPS string.
	*
	* @var string
	*/
    protected string eps;
    /**
	* Colors used for drawing.
	*
	* @var array
	*/
    protected ColorInterface[string] colors ;

    /**
	* Current color.
	*
	* @var string
	*/
    protected string currentColor;

	/**
	* init(): defined by RendererInterface.
	*
	* @see    ImageRendererInterface::init()
	* @return void
	*/
    public override void initRender()
    {
        this.eps = "%!PS-Adobe-3.0 EPSF-3.0\n"
			~ "%%BoundingBox: 0 0 " ~ to!string(this.finalWidth) ~ " " ~ to!string(this.finalHeight) ~ "\n"
				~ "/F { rectfill } def\n";
    }

	/**
	* addColor(): defined by RendererInterface.
	*
	* @see    ImageRendererInterface::addColor()
	* @param  string         id
	* @param  ColorInterface color
	* @return void
	*/
    public override void addColor(string id, ColorInterface color)
    {
        if (
            typeid(color) != typeid(Rgb)
            && typeid(color) != typeid(Cmyk)
            && typeid(color) !=  typeid(Gray)
			) {
				color = color.toCmyk();
			}
        this.colors[id] = color;
    }

	/**
	* drawBackground(): defined by RendererInterface.
	*
	* @see    ImageRendererInterface::drawBackground()
	* @param  string $colorId
	* @return void
	*/
    public override void drawBackground(string colorId)
    {
        this.setColor(colorId);
        this.eps ~= "0 0 " ~ to!string(this.finalWidth) ~ " " ~ to!string(this.finalHeight) ~ " F\n";
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
        this.setColor(colorId);
        //this.eps ~= x  " " . (this.finalHeight - y) . " " . this.blockSize . " " . this.blockSize . " F\n";
		this.eps ~= format("%s %s %s %s F\n", x, this.finalHeight - y, this.blockSize, this.blockSize);
    }


    /**
	* getByteStream(): defined by RendererInterface.
	*
	* @see    ImageRendererInterface::getByteStream()
	* @return string
	*/
    public override string getByteStream()
    {
        return this.eps;
    }

	/**
	* Sets color to use.
	*
	* @param  string colorId
	* @return void
	*/
    protected void setColor(string colorId)
    {
        if (colorId != this.currentColor) 
		{
            auto color = colorId in this.colors;
			if(color is null)
			{
				throw new Exception("Color id is not set "~colorId);
			}
            if (typeid(*color) == typeid(Rgb)) {
				auto tmp = cast(Rgb)(*color);
                this.eps ~= format(
									"%F %F %F setrgbcolor\n",
									tmp.getRed() / 100,
									tmp.getGreen() / 100,
									tmp.getBlue() / 100
									);
            } else if (typeid(*color) == typeid(Cmyk)) {
				auto tmp = cast(Cmyk)(*color);
                this.eps ~= format(
									"%F %F %F %F setcmykcolor\n",
									tmp.getCyan() / 100,
									tmp.getMagenta() / 100,
									tmp.getYellow() / 100,
									tmp.getBlack() / 100
									);
            } else if (typeid(*color) == typeid(Gray)) {
				auto tmp = cast(Gray)(*color);
                this.eps ~= format(
									"%F setgray\n",
									tmp.getGray() / 100
									);
            }
            this.currentColor = colorId;
        }
    }
}