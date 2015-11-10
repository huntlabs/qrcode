module ithox.qrcode.qrcodewriter;

import ithox.qrcode.renderer.rendererinterface;

import ithox.qrcode.encoder.encoder;
import ithox.qrcode.common.errorcorrectionlevel;

/**
* QR code writer.
*/
class QrCodeWriter
{
	/**
	* Renderer instance.
	*
	* @var RendererInterface
	*/
    protected RendererInterface renderer;

	this(RendererInterface irender)
	{
		this.renderer = irender;
	}

	/**
	* Sets the renderer used to create a byte stream.
	*
	* @param  RendererInterface $renderer
	* @return Writer
	*/
    public QrCodeWriter setRenderer(RendererInterface renderer)
    {
        this.renderer = renderer;
        return this;
    }
    /**
	* Gets the renderer used to create a byte stream.
	*
	* @return RendererInterface
	*/
    public RendererInterface getRenderer()
    {
        return this.renderer;
    }

	/**
	* Writes QR code and returns it as string.
	*
	* Content is a string which *should* be encoded in UTF-8, in case there are
	* non ASCII-characters present.
	*
	* @param  string  $content
	* @param  string  $encoding
	* @param  integer $ecLevel
	* @return string
	* @throws Exception\InvalidArgumentException
	*/
    public string writeString(string content, string encoding = Encoder.DEFAULT_BYTE_MODE_ECODING, ErrorCorrectionLevel ecLevel = ErrorCorrectionLevel.L) 
	{
		if (content.length == 0) {
			throw new Exception("Found empty contents");
		}
		auto qrCode = Encoder.encode(content, ecLevel, encoding);
		return this.getRenderer().render(qrCode);
	}

	/**
	* Writes QR code to a file.
	*
	* @see    Writer::writeString()
	* @param  string  $content
	* @param  string  $filename
	* @param  string  $encoding
	* @param  integer $ecLevel
	* @return void
	*/
    public void writeFile(string content, string filename, string encoding = Encoder.DEFAULT_BYTE_MODE_ECODING,ErrorCorrectionLevel ecLevel = ErrorCorrectionLevel.L) 
	{
		import std.file;
		write(filename, this.writeString(content, encoding,ecLevel));
		//file_put_contents($filename, $this->writeString($content, $encoding, $ecLevel));
	}
}