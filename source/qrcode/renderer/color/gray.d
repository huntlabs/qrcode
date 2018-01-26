module qrcode.renderer.color.gray;

import qrcode.renderer.color.colorinterface;
import qrcode.renderer.color.rgb;
import qrcode.renderer.color.cmyk;
import std.conv;

/**
* Gray color.
*/
class Gray : ColorInterface
{
	/**
	* Gray value.
	*
	* @var integer
	*/
    protected int gray;
	/**
	* Creates a new gray color.
	*
	* A low gray value means black, while a high value means white.
	*
	* @param integer $gray
	*/
	this(int _gray)
	{
		if (_gray < 0 || _gray > 100) {
            throw new Exception("Gray must be between 0 and 100");
        }
        this.gray = _gray;
	}

	/**
	* Returns the gray value.
	*
	* @return integer
	*/
    public int getGray()
    {
        return this.gray;
    }
    /**
	* toRgb(): defined by ColorInterface.
	*
	* @see    ColorInterface::toRgb()
	* @return Rgb
	*/
    public Rgb toRgb()
    {
        return new Rgb(to!int(this.gray * 2.55), to!int(this.gray * 2.55), to!int(this.gray * 2.55));
    }
    /**
	* toCmyk(): defined by ColorInterface.
	*
	* @see    ColorInterface::toCmyk()
	* @return Cmyk
	*/
    public Cmyk toCmyk()
    {
        return new Cmyk(0, 0, 0, 100 - this.gray);
    }
    /**
	* toGray(): defined by ColorInterface.
	*
	* @see    ColorInterface::toGray()
	* @return Gray
	*/
    public Gray toGray()
    {
        return this;
    }

	public override string toString(){
		return super.toString();
	}
}