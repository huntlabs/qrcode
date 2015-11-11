module ithox.qrcode.renderer.image.png;

import ithox.qrcode.renderer.image.abstractrender;
import ithox.qrcode.renderer.color.colorinterface;

import dmagick.Image;
import dmagick.Geometry;
import dmagick.Color;
import dmagick.DrawingContext;


import ithox.qrcode.renderer.color.colorinterface;

/**
* PNG backend.
*/
class Png : AbstractRenderer
{
	 
	protected Image image;

	protected DrawingContext draw;

    /**
	* Colors used for drawing.
	*
	* @var array
	*/
    protected  Color[string] colors;



	/**
	* init(): defined by RendererInterface.
	*
	* @see    ImageRendererInterface::init()
	* @return void
	*/
    public override void  initRender()
    {
		Geometry geo;
		geo.width = this.finalWidth;
		geo.height = this.finalHeight;

		auto ci =  this.getBackgroundColor();
        this.image = new Image(geo, this.getMagicColor(ci));
		this.draw = new DrawingContext();
    }

	private Color getMagicColor(ColorInterface ci)
	{
		import dmagick.ColorRGB;
		auto tmp = ci.toRgb();
		return new ColorRGB(tmp.getRed(), tmp.getGreen(),tmp.getBlue);
	}

	/**
	* addColor(): defined by RendererInterface.
	*
	* @see    ImageRendererInterface::addColor()
	* @param  string         $id
	* @param  ColorInterface $color
	* @return void
	* @throws Exception\RuntimeException
	*/
	public override void addColor(string id, ColorInterface color)
	{
		this.colors[id] = this.getMagicColor(color);
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

    }
    /**
	* drawBlock(): defined by RendererInterface.
	*
	* @see    ImageRendererInterface::drawBlock()
	* @param  integer $x
	* @param  integer $y
	* @param  string  $colorId
	* @return void
	*/
    public override void drawBlock(int x, int y, string colorId)
    {
        this.draw.rectangle(x,y,x+this.blockSize-1, y + this.blockSize -1);
		this.draw.fill(this.colors[colorId]);
    }
    /**
	* getByteStream(): defined by RendererInterface.
	*
	* @see    ImageRendererInterface::getByteStream()
	* @return string
	*/
    public override string getByteStream()
    {
		this.draw.draw(this.image);
		//this.image.write("xxx.png");
		return cast(string)(this.image.toBlob("png"));
		//return string.init;
    }
}