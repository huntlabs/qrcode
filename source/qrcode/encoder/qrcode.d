module qrcode.encoder.qrcode;

import qrcode.common.errorcorrectionlevel;
import qrcode.common.mode;
import qrcode.common.qrcodeversion;
import qrcode.common.bitmatrix;
import qrcode.common.bitarray;
import qrcode.encoder.bytematrix;

/**
* QR code.
* @author donglei
*/
class QrCode
{
    /**
	* Number of possible mask patterns.
	*/
    enum NUM_MASK_PATTERNS = 8;

    protected
    {
        Mode _mode; ///Mode of the QR code.
        ErrorCorrectionLevel _errorCorrectionLevel; /// EC level of the QR code.

        QrCodeVersion _qrVersion; ///Version of the QR code.

        int _maskPattern = -1; ///Mask pattern of the QR code.

        ByteMatrix _matrix; ///Matrix of the QR code.
    }

    public @property Mode mode()
    {
        return _mode;
    }

    public @property void mode(Mode _m)
    {
        _mode = _m;
    }

    public @property ErrorCorrectionLevel errorCorrectionLevel()
    {
        return _errorCorrectionLevel;
    }

    public @property void errorCorrectionLevel(ErrorCorrectionLevel _m)
    {
        _errorCorrectionLevel = _m;
    }

    public @property QrCodeVersion qrVersion()
    {
        return _qrVersion;
    }

    public @property void qrVersion(QrCodeVersion _m)
    {
        _qrVersion = _m;
    }

    public @property int maskPattern()
    {
        return _maskPattern;
    }

    public @property void maskPattern(int _m)
    {
        _maskPattern = _m;
    }

    public @property ByteMatrix matrix()
    {
        return _matrix;
    }

    public @property void matrix(ByteMatrix _m)
    {
        _matrix = _m;
    }

    /**
	* Validates whether a mask pattern is valid.
	*
	* @param  integer $maskPattern
	* @return boolean
	*/
    public static bool isValidMaskPattern(int maskPattern)
    {
        return maskPattern > 0 && maskPattern < NUM_MASK_PATTERNS;
    }

    /**
	* Returns a string representation of the QR code.
	*
	* @return string
	*/
    public override string toString()
    {
        import std.array, std.conv;

        Appender!string result = appender!string();
        result.put("<<\n");
        result.put(" mode: ");
        result.put(this.mode.toString());
        result.put("\n");
        result.put(" ecLevel: ");
        result.put(to!string(getOrdinalErrorCorrectionLevel(this.errorCorrectionLevel)));
        result.put("\n");
        result.put(" version: ");
        result.put(this.qrVersion.toString());
        result.put("\n");
        result.put(" maskPattern: ");
        result.put(to!string(this.maskPattern));
        result.put("\n");
        if (this.matrix is null)
        {
            result.put(" matrix: null\n");
        }
        else
        {
            result.put(" matrix:\n");
            result.put(this.matrix.toString());
        }
        result.put(">>\n");
        return result.data;
    }
}
