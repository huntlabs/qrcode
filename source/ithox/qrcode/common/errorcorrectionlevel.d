module ithox.qrcode.common.errorcorrectionlevel;

enum ErrorCorrectionLevel : int{
	L = 0x1,///Level L, ~7% correction.
	M = 0x0,//Level M, ~15% correction.
	Q = 0x3, ///Level Q, ~25% correction.
	H = 0x2///Level H, ~30% correction.
}
/**
* Gets the ordinal of this enumeration constant.
*
* @return integer
*/
public int getOrdinalErrorCorrectionLevel(ErrorCorrectionLevel lev)
{
	final switch (lev) {
		case ErrorCorrectionLevel.L:
			return 0;
		case ErrorCorrectionLevel.M:
			return 1;
		case ErrorCorrectionLevel.Q:
			return 2;
		case ErrorCorrectionLevel.H:
			return 3;
	}
}