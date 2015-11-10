module ithox.qrcode.renderer.text.plain;

import ithox.qrcode.renderer.rendererinterface;
import ithox.qrcode.encoder.qrcode;
import ithox.qrcode.renderer.rendererinterface;
import ithox.qrcode.renderer.color.colorinterface;

/**
* Plaintext renderer.
*/
class Plain : RendererInterface
{
	/**
	* Margin around the QR code, also known as quiet zone.
	*
	* @var integer
	*/
    protected int margin = 1;
    /**
	* Char used for full block.
	*
	* UTF-8 FULL BLOCK (U+2588)
	*
	* @var  string
	* @link http://www.fileformat.info/info/unicode/char/2588/index.htm
	*/
    protected string fullBlock = "\xE2\x96\x88";
    /**
	* Char used for empty space
	*
	* @var string
	*/
    protected string emptyBlock = " ";

	/**
	* Set char used as full block (occupied space, "black").
	*
	* @param string fullBlock
	*/
    public void setFullBlock(string fullBlock)
    {
        this.fullBlock = fullBlock;
    }
    /**
	* Get char used as full block (occupied space, "black").
	*
	* @return string
	*/
    public string getFullBlock()
    {
        return this.fullBlock;
    }
    /**
	* Set char used as empty block (empty space, "white").
	*
	* @param string emptyBlock
	*/
    public void setEmptyBlock(string emptyBlock)
    {
        this.emptyBlock = emptyBlock;
    }
    /**
	* Get char used as empty block (empty space, "white").
	*
	* @return string
	*/
    public string getEmptyBlock()
    {
        return this.emptyBlock;
    }
    /**
	* Sets the margin around the QR code.
	*
	* @param  integer margin
	* @return AbstractRenderer
	* @throws Exception\InvalidArgumentException
	*/
    public RendererInterface setMargin(int margin)
    {
        if (margin < 0) {
            throw new Exception("Margin must be equal to greater than 0");
        }
        this.margin = margin;
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
	* render(): defined by RendererInterface.
	*
	* @see    RendererInterface::render()
	* @param  QrCode qrCode
	* @return string
	*/
    public string render(QrCode qrCode)
    {
		import std.array;
        Appender!string result = appender!string();
        auto matrix = qrCode.matrix();
        auto width  = matrix.width();
        // Top margin
        for (auto x = 0; x < this.margin; x++) {
            //result .= str_repeat(this.emptyBlock, width + 2 * this.margin)."\n";
			result.put(replicate(this.emptyBlock, width + 2 * this.margin));
			result.put("\n");
        }
        // Body
        auto array = matrix.getArray();
        foreach (row ; array) {
            //result .= str_repeat(this.emptyBlock, this.margin); // left margin
			result.put(replicate(this.emptyBlock, this.margin));
            foreach (_byte ; row) {
                //result .= byte ? this.fullBlock : this.emptyBlock;
				result.put(_byte ? this.fullBlock : this.emptyBlock);
            }
            //result .= str_repeat(this.emptyBlock, this.margin); // right margin
			result.put(replicate(this.emptyBlock, this.margin));
           // result .= "\n";
			result.put("\n");
        }
        // Bottom margin
        for (auto x = 0; x < this.margin; x++) {
			// result .= str_repeat(this.emptyBlock, width + 2 * this.margin)."\n";
			result.put(replicate(this.emptyBlock, width + 2 * this.margin));
			result.put("\n");
        }
        return result.data;
    }

	public void initRender(){};
	public void addColor(string id, ColorInterface color){}
	public void drawBackground(string colorId){}
	public void drawBlock(int x, int y, string colorId){}
	public string getByteStream(){
		return string.init;
	}
}