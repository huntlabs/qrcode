module qrcode.renderer.rendererinterface;

import qrcode.encoder.qrcode;
import qrcode.renderer.color.colorinterface;

/**
* Renderer interface.
*/
interface RendererInterface
{
    /**
	* Renders a QR code.
	*
	* @param  QrCode $qrCode
	* @return string
	*/
    public string render(QrCode qrCode);
    public void initRender();
    public void addColor(string id, ColorInterface color);
    public void drawBackground(string colorId);
    public void drawBlock(int x, int y, string colorId);
    public string getByteStream();
}
