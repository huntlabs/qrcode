module ithox.qrcode.renderer.color.cmyk;

import ithox.qrcode.renderer.color.colorinterface;
import ithox.qrcode.renderer.color.rgb;
import ithox.qrcode.renderer.color.gray;
/**
* CMYK color.
*/
class Cmyk : ColorInterface
{
	/**
	* Cyan value.
	*
	* @var integer
	*/
    protected int cyan;
    /**
	* Magenta value.
	*
	* @var integer
	*/
    protected int magenta;
    /**
	* Yellow value.
	*
	* @var integer
	*/
    protected int yellow;
    /**
	* Black value.
	*
	* @var integer
	*/
    protected int black;

	/**
	* Creates a new CMYK color.
	*
	* @param integer cyan
	* @param integer magenta
	* @param integer yellow
	* @param integer black
	*/
    public this(int _cyan, int _magenta, int _yellow, int _black)
    {
        if (_cyan < 0 || _cyan > 100) {
            throw new Exception("Cyan must be between 0 and 100");
        }
        if (_magenta < 0 || _magenta > 100) {
            throw new Exception("Magenta must be between 0 and 100");
        }
        if (_yellow < 0 || _yellow > 100) {
            throw new Exception("Yellow must be between 0 and 100");
        }
        if (_black < 0 || _black > 100) {
            throw new Exception("Black must be between 0 and 100");
        }
        this.cyan    = _cyan;
        this.magenta = _magenta;
        this.yellow  = _yellow;
        this.black   = _black;
    }
    /**
	* Returns the cyan value.
	*
	* @return integer
	*/
    public int getCyan()
    {
        return this.cyan;
    }
    /**
	* Returns the magenta value.
	*
	* @return integer
	*/
    public int getMagenta()
    {
        return this.magenta;
    }
    /**
	* Returns the yellow value.
	*
	* @return integer
	*/
    public int getYellow()
    {
        return this.yellow;
    }
    /**
	* Returns the black value.
	*
	* @return integer
	*/
    public int getBlack()
    {
        return this.black;
    }
    /**
	* toRgb(): defined by ColorInterface.
	*
	* @see    ColorInterface::toRgb()
	* @return Rgb
	*/
    public Rgb toRgb()
    {
        auto k = this.black / 100;
        auto c = (-k * this.cyan + k * 100 + this.cyan) / 100;
        auto m = (-k * this.magenta + k * 100 + this.magenta) / 100;
        auto y = (-k * this.yellow + k * 100 + this.yellow) / 100;
        return new Rgb(
					   -c * 255 + 255,
					   -m * 255 + 255,
					   -y * 255 + 255
					   );
    }
    /**
	* toCmyk(): defined by ColorInterface.
	*
	* @see    ColorInterface::toCmyk()
	* @return Cmyk
	*/
    public Cmyk toCmyk()
    {
        return this;
    }
    /**
	* toGray(): defined by ColorInterface.
	*
	* @see    ColorInterface::toGray()
	* @return Gray
	*/
    public Gray toGray()
    {
        return this.toRgb().toGray();
    }
	public override string toString(){
		return super.toString();
	}
}