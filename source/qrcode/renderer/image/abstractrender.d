module qrcode.renderer.image.abstractrender;

import qrcode.renderer.rendererinterface;
import qrcode.encoder.qrcode;
import qrcode.renderer.color.colorinterface;
import qrcode.renderer.image.decorator.decoratorinterface;
import qrcode.renderer.color.gray;

/**
* Image renderer, supporting multiple backends.
*/
abstract class AbstractRenderer : RendererInterface
{
	/**
	* Margin around the QR code, also known as quiet zone.
	*
	* @var integer
	*/
    protected int margin = 4;
    /**
	* Requested width of the rendered image.
	*
	* @var integer
	*/
    protected int width = 0;
    /**
	* Requested height of the rendered image.
	*
	* @var integer
	*/
    protected int height = 0;
    /**
	* Whether dimensions should be rounded down.
	*
	* @var boolean
	*/
    protected bool roundDimensions = true;
    /**
	* Final width of the image.
	*
	* @var integer
	*/
    protected int finalWidth;
    /**
	* Final height of the image.
	*
	* @var integer
	*/
    protected int finalHeight;
    /**
	* Size of each individual block.
	*
	* @var integer
	*/
    protected int blockSize;
    /**
	* Background color.
	*
	* @var Color\ColorInterface
	*/
    protected ColorInterface backgroundColor;
    /**
	* Whether dimensions should be rounded down
	* 
	* @var boolean
	*/
    protected bool floorToClosestDimension;
    /**
	* Foreground color.
	*
	* @var Color\ColorInterface
	*/
    protected ColorInterface foregroundColor;
    /**
	* Decorators used on QR codes.
	*
	* @var array
	*/
    protected DecoratorInterface[] decorators;

	/**
	* Sets the margin around the QR code.
	*
	* @param  integer margin
	* @return AbstractRenderer
	* @throws Exception\InvalidArgumentException
	*/
    public AbstractRenderer setMargin(int _margin)
    {
        if (margin < 0) {
            throw new Exception("Margin must be equal to greater than 0");
        }
        this.margin =  _margin;
        return this;
    }
    /**
	* Gets the margin around the QR code.
	*
	* @return integer
	*/
    public int getMargin()
    {
        return this.margin;
    }
    /**
	* Sets the height around the renderd image.
	*
	* If the width is smaller than the matrix width plus padding, the renderer
	* will automatically use that as the width instead of the specified one.
	*
	* @param  integer width
	* @return AbstractRenderer
	*/
    public AbstractRenderer setWidth(int _width)
    {
        this.width = _width;
        return this;
    }
    /**
	* Gets the width of the rendered image.
	*
	* @return integer
	*/
    public int getWidth()
    {
        return this.width;
    }
    /**
	* Sets the height around the renderd image.
	*
	* If the height is smaller than the matrix height plus padding, the
	* renderer will automatically use that as the height instead of the
	* specified one.
	*
	* @param  integer height
	* @return AbstractRenderer
	*/
    public AbstractRenderer setHeight(int _height)
    {
        this.height = _height;
        return this;
    }
    /**
	* Gets the height around the rendered image.
	*
	* @return integer
	*/
    public int getHeight()
    {
        return this.height;
    }
    /**
	* Sets whether dimensions should be rounded down.
	*
	* @param  boolean flag
	* @return AbstractRenderer
	*/
    public AbstractRenderer setRoundDimensions(bool flag)
    {
        this.floorToClosestDimension = flag;
        return this;
    }
    /**
	* Gets whether dimensions should be rounded down.
	*
	* @return boolean
	*/
    public bool shouldRoundDimensions()
    {
        return this.floorToClosestDimension;
    }
    /**
	* Sets background color.
	*
	* @param  Color\ColorInterface color
	* @return AbstractRenderer
	*/
    public AbstractRenderer setBackgroundColor(ColorInterface color)
    {
        this.backgroundColor = color;
        return this;
    }
    /**
	* Gets background color.
	*
	* @return Color\ColorInterface
	*/
    public ColorInterface getBackgroundColor()
    {
        if (this.backgroundColor is null) {
            this.backgroundColor = new Gray(100);
        }
        return this.backgroundColor;
    }
    /**
	* Sets foreground color.
	*
	* @param  Color\ColorInterface color
	* @return AbstractRenderer
	*/
    public AbstractRenderer setForegroundColor(ColorInterface color)
    {
        this.foregroundColor = color;
        return this;
    }
    /**
	* Gets foreground color.
	*
	* @return Color\ColorInterface
	*/
    public ColorInterface getForegroundColor()
    {
        if (this.foregroundColor is null) {
            this.foregroundColor = new Gray(0);
        }
        return this.foregroundColor;
    }
    /**
	* Adds a decorator to the renderer.
	*
	* @param  DecoratorInterface decorator
	* @return AbstractRenderer
	*/
    public AbstractRenderer addDecorator(DecoratorInterface decorator)
    {
        this.decorators[] = decorator;
        return this;
    }

	/**
	* render(): defined by RendererInterface.
	*
	* @see    RendererInterface::render()
	* @param  QrCode qrCode
	* @return string
	*/
    public string render(QrCode qrCode)
    {
		import std.algorithm;
        auto input        = qrCode.matrix();
        auto inputWidth   = input.width();
        auto inputHeight  = input.height();
        auto qrWidth      = inputWidth + (this.getMargin() << 1);
        auto qrHeight     = inputHeight + (this.getMargin() << 1);
        auto outputWidth  = max(this.getWidth(), qrWidth);
        auto outputHeight = max(this.getHeight(), qrHeight);
        auto multiple     = min(outputWidth / qrWidth, outputHeight / qrHeight);
        if (this.shouldRoundDimensions()) {
            outputWidth  -= outputWidth % multiple;
            outputHeight -= outputHeight % multiple;
        }
        // Padding includes both the quiet zone and the extra white pixels to
        // accommodate the requested dimensions. For example, if input is 25x25
        // the QR will be 33x33 including the quiet zone. If the requested size
        // is 200x160, the multiple will be 4, for a QR of 132x132. These will
        // handle all the padding from 100x100 (the actual QR) up to 200x160.
        auto leftPadding = ((outputWidth - (inputWidth * multiple)) / 2);
        auto topPadding  = ((outputHeight - (inputHeight * multiple)) / 2);
        // Store calculated parameters
        this.finalWidth  = outputWidth;
        this.finalHeight = outputHeight;
        this.blockSize   = multiple;
        this.initRender();
        this.addColor("background", this.getBackgroundColor());
        this.addColor("foreground", this.getForegroundColor());
        this.drawBackground("background");
        foreach (decorator;this.decorators) {
            decorator.preProcess(
								 qrCode,
								 this,
								 outputWidth,
								 outputHeight,
								 leftPadding,
								 topPadding,
								 multiple
									 );
        }
        for (auto inputY = 0, outputY = topPadding; inputY < inputHeight; inputY++, outputY += multiple) {
            for (auto inputX = 0, outputX = leftPadding; inputX < inputWidth; inputX++, outputX += multiple) {
                if (input.get(inputX, inputY) == 1) {
                    this.drawBlock(outputX, outputY, "foreground");
                }
            }
        }
         foreach (decorator;this.decorators){
            decorator.postProcess(
								  qrCode,
								  this,
								  outputWidth,
								  outputHeight,
								  leftPadding,
								  topPadding,
								  multiple
									  );
        }
        return this.getByteStream();
    }

	public void initRender(){};
	 public void addColor(string id, ColorInterface color){}
	 public void drawBackground(string colorId){}
	 public void drawBlock(int x, int y, string colorId){}
	 public string getByteStream(){
		return string.init;
	 }
}