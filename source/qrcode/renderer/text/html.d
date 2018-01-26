module qrcode.renderer.text.html;

import qrcode.encoder.qrcode;
import qrcode.renderer.text.plain;
/**
* Html renderer.
*/
class Html : Plain
{
	/**
	* HTML CSS class attribute value.
	*
	* @var string
	*/
    protected string css_class;
    /**
	* HTML CSS style definition for the code element.
	*
	* @var string
	*/
    protected string style = "font-family: monospace; line-height: 0.65em; letter-spacing: -1px";
    /**
	* Set CSS class name.
	*
	* @param string class
	*/
    public void setClass(string _class)
    {
        this.css_class = _class;
    }
    /**
	* Get CSS class name.
	*
	* @return string
	*/
    public string getClass()
    {
        return this.css_class;
    }
    /**
	* Set CSS style value.
	*
	* @param string style
	*/
    public void setStyle(string style)
    {
        this.style = style;
    }
    /**
	* Get CSS style value.
	*
	* @return string
	*/
    public string getStyle()
    {
        return this.style;
    }
    /**
	* render(): defined by RendererInterface.
	*
	* @see    RendererInterface::render()
	* @param  QrCode qrCode
	* @return string
	*/
    public override string render(QrCode qrCode)
    {
		
        auto textCode = super.render(qrCode);
        return  "<pre>" ~ textCode ~ "</pre>";
    }
}