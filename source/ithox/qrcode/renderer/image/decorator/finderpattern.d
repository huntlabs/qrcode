module ithox.qrcode.renderer.image.decorator.finderpattern;

import ithox.qrcode.renderer.image.decorator.decoratorinterface;
import ithox.qrcode.renderer.color.colorinterface;
import ithox.qrcode.renderer.color.gray;
import ithox.qrcode.encoder.qrcode;
import ithox.qrcode.renderer.rendererinterface;

import std.conv;

/**
* Finder pattern decorator.
*/
class FinderPattern : DecoratorInterface
{

    /**
	* @var Color\ColorInterface
	*/
    protected ColorInterface innerColor;
    /**
	* @varColor\ColorInterface
	*/
    protected ColorInterface outerColor;
    /**
	* Outer position detection pattern.
	*
	* @var array
	*/
    protected static int[][] outerPositionDetectionPattern = [
		[1, 1, 1, 1, 1, 1, 1],
		[1, 0, 0, 0, 0, 0, 1],
		[1, 0, 0, 0, 0, 0, 1],
		[1, 0, 0, 0, 0, 0, 1],
		[1, 0, 0, 0, 0, 0, 1],
		[1, 0, 0, 0, 0, 0, 1],
		[1, 1, 1, 1, 1, 1, 1],
	];
	/**
	* Inner position detection pattern.
	*
	* @var array
	*/
    protected static int[][] innerPositionDetectionPattern = [
		[0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0],
		[0, 0, 1, 1, 1, 0, 0],
		[0, 0, 1, 1, 1, 0, 0],
		[0, 0, 1, 1, 1, 0, 0],
		[0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0],
	];
    /**
	* Sets outer color.
	*
	* @param  Color\ColorInterface color
	* @return FinderPattern
	*/
    public FinderPattern setOuterColor(ColorInterface color)
    {
        this.outerColor = color;
        return this;
    }
    /**
	* Gets outer color.
	*
	* @return Color\ColorInterface
	*/
    public ColorInterface getOuterColor()
    {
        if (this.outerColor is null) {
            this.outerColor = new Gray(100);
        }
        return this.outerColor;
    }
    /**
	* Sets inner color.
	*
	* @param  Color\ColorInterface color
	* @return FinderPattern
	*/
    public FinderPattern setInnerColor(ColorInterface color)
    {
        this.innerColor = color;
        return this;
    }
    /**
	* Gets inner color.
	*
	* @return Color\ColorInterface
	*/
    public ColorInterface getInnerColor()
    {
        if (this.innerColor is null) {
            this.innerColor = new Gray(0);
        }
        return this.innerColor;
    }
    /**
	* preProcess(): defined by DecoratorInterface.
	*
	* @see    DecoratorInterface::preProcess()
	* @param  QrCode            qrCode
	* @param  RendererInterface renderer
	* @param  integer           outputWidth
	* @param  integer           outputHeight
	* @param  integer           leftPadding
	* @param  integer           topPadding
	* @param  integer           multiple
	* @return void
	*/
    public void preProcess(  QrCode qrCode,  RendererInterface renderer, int outputWidth, int outputHeight, int leftPadding, int topPadding,  int multiple ) 
	{
		auto  matrix    = qrCode.matrix();
		auto positions = [
							[0, 0],
							[matrix.width() - 7, 0],
							[0, matrix.height() - 7],
						];
		foreach ( int y,  row;outerPositionDetectionPattern) {
			foreach ( int x, isSet;row) {
				foreach ( position; positions) {
					matrix.set(x + position[0], y + position[1], 0);
				}
			}
		}
	}
    /**
	* postProcess(): defined by DecoratorInterface.
	*
	* @see    DecoratorInterface::postProcess()
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
    public void postProcess(  QrCode qrCode,  RendererInterface renderer, int outputWidth, int outputHeight, int leftPadding, int topPadding,  int multiple ) 
	{
		auto matrix    = qrCode.matrix();
		auto positions = [
							[0, 0],
							[matrix.width() - 7, 0],
							[0, matrix.height() - 7],
		];
		renderer.addColor("finder-outer", this.getOuterColor());
		renderer.addColor("finder-inner", this.getInnerColor());
		foreach ( y, row;outerPositionDetectionPattern) {
			foreach ( x,isOuterSet;row) {
				auto isInnerSet = innerPositionDetectionPattern[y][x];
				if (isOuterSet) {
					foreach ( position;positions) {
						renderer.drawBlock(
										   to!int(leftPadding + x * multiple + position[0] * multiple),
											to!int(topPadding + y * multiple + position[1] * multiple),
											"finder-outer"
											);
					}
				}
				if (isInnerSet) {
					foreach ( position;positions) {
						renderer.drawBlock(
											to!int(leftPadding + x * multiple + position[0] * multiple),
											to!int(topPadding + y * multiple + position[1] * multiple),
											"finder-inner"
											);
					}
				}
			}
		}
	}
}