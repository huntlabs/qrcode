module ithox.qrcode.renderer.image.png;

import ithox.qrcode.renderer.image.abstractrender;
import ithox.qrcode.renderer.color.colorinterface;

/**
* PNG backend.
*/
class Png : AbstractRenderer
{
	 
    /**
	* Colors used for drawing.
	*
	* @var array
	*/
    protected  ColorInterface[string] colors;

	/**
	* init(): defined by RendererInterface.
	*
	* @see    ImageRendererInterface::init()
	* @return void
	*/
    public override void  initRender()
    {
        
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
        
    }
    /**
	* getByteStream(): defined by RendererInterface.
	*
	* @see    ImageRendererInterface::getByteStream()
	* @return string
	*/
    public override string getByteStream()
    {
		return string.init;
    }
}