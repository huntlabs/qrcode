module ithox.qrcode.renderer.image.decorator.decoratorinterface;

import ithox.qrcode.encoder.qrcode;
import ithox.qrcode.renderer.rendererinterface;

/**
* Decorator interface.
*/
interface DecoratorInterface
{
    /**
	* Pre-process a QR code.
	*
	* @param  QrCode            qrCode
	* @param  RendererInterface renderer
	* @param  integer           outputWidth
	* @param  integer           outputHeight
	* @param  integer           leftPadding
	* @param  integer           topPadding
	* @param  integer           multiple
	* @return void
	*/
    public void preProcess(
							   QrCode qrCode,
							   RendererInterface renderer,
							   int outputWidth,
							   int outputHeight,
							   int leftPadding,
							   int topPadding,
							   int multiple
							   );
    /**
	* Post-process a QR code.
	*
	* @param  QrCode            qrCode
	* @param  RendererInterface renderer
	* @param  integer           outputWidth
	* @param  integer           outputHeight
	* @param  integer           leftPadding
	* @param  integer           topPadding
	* @param  integer           multiple
	* @return void
	*/
    public void postProcess(
								QrCode qrCode,
								RendererInterface renderer,
								int outputWidth,
								int outputHeight,
								int leftPadding,
								int topPadding,
								int multiple
								);
}