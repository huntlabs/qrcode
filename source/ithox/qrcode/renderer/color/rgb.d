module ithox.qrcode.renderer.color.rgb;

import ithox.qrcode.renderer.color.colorinterface;
import ithox.qrcode.renderer.color.gray;
import ithox.qrcode.renderer.color.cmyk;
/**
* RGB color.
*/
class Rgb : ColorInterface
{
	/**
	* Red value.
	*
	* @var integer
	*/
    protected int red;
    /**
	* Green value.
	*
	* @var integer
	*/
    protected int green;
    /**
	* Blue value.
	*
	* @var integer
	*/
    protected int blue;

	this(int r, int g, int b)
	{
		if (r < 0 || r > 255) {
            throw new Exception("Red must be between 0 and 255");
        }
        if (g < 0 || g > 255) {
            throw new Exception("Green must be between 0 and 255");
        }
        if (b < 0 || b > 255) {
            throw new Exception("Blue must be between 0 and 255");
        }
        this.red   = r;
        this.green = g;
        this.blue  = b;
	}

	/**
	* Returns the red value.
	*
	* @return integer
	*/
    public int getRed()
    {
        return this.red;
    }
    /**
	* Returns the green value.
	*
	* @return integer
	*/
    public int getGreen()
    {
        return this.green;
    }
    /**
	* Returns the blue value.
	*
	* @return integer
	*/
    public int getBlue()
    {
        return this.blue;
    }
    /**
	* Returns a hexadecimal string representation of the RGB value.
	*
	* @return string
	*/
    public override string toString()
    {
		import std.format;
        return format("%02x%02x%02x", this.red, this.green, this.blue);
    }
    /**
	* toRgb(): defined by ColorInterface.
	*
	* @see    ColorInterface::toRgb()
	* @return Rgb
	*/
    public Rgb toRgb()
    {
        return this;
    }
    /**
	* toCmyk(): defined by ColorInterface.
	*
	* @see    ColorInterface::toCmyk()
	* @return Cmyk
	*/
    public Cmyk toCmyk()
    {
		import std.algorithm;

        auto c = 1 - (this.red / 255);
        auto m = 1 - (this.green / 255);
        auto y = 1 - (this.blue / 255);
        auto k = min(c, m, y);
        return new Cmyk(
						100 * (c - k) / (1 - k),
						100 * (m - k) / (1 - k),
						100 * (y - k) / (1 - k),
						100 * k
						);
    }
    /**
	* toGray(): defined by ColorInterface.
	*
	* @see    ColorInterface::toGray()
	* @return Gray
	*/
    public Gray toGray()
    {
		import std.conv;
        return new Gray(to!int((this.red * 0.21 + this.green * 0.71 + this.blue * 0.07) / 2.55));
    }
}