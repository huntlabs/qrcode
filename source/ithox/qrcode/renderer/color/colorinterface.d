module ithox.qrcode.renderer.color.colorinterface;

import ithox.qrcode.renderer.color.rgb;
import ithox.qrcode.renderer.color.gray;
import ithox.qrcode.renderer.color.cmyk;

/**
* Color interface.
*/
interface ColorInterface
{
	/**
	* Converts the color to RGB.
	*
	* @return Rgb
	*/
    public Rgb toRgb();
    /**
	* Converts the color to CMYK.
	*
	* @return Cmyk
	*/
    public Cmyk toCmyk();
    /**
	* Converts the color to gray.
	*
	* @return Gray
	*/
    public Gray toGray();
	public string toString();
}