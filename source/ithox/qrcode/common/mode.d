module ithox.qrcode.common.mode;
import ithox.qrcode.common.qrcodeversion;

///Enum representing various modes in which data can be encoded to bits.
class Mode{
	/**#@+
	* Mode enumants.
	*/
    enum int  TERMINATOR           = 0x0;
    enum int NUMERIC              = 0x1;
    enum int ALPHANUMERIC         = 0x2;
    enum int STRUCTURED_APPEND    = 0x3;
    enum int BYTE                 = 0x4;
    enum int ECI                  = 0x7;
    enum int KANJI                = 0x8;
    enum int FNC1_FIRST_POSITION  = 0x5;
    enum int FNC1_SECOND_POSITION = 0x9;
    enum int HANZI                = 0xd;
    /**#@-*/

	private{
		int _mode;
	}

	this(int m)
	{

		this._mode = m;
	}
	public @property int mode(){return this._mode;}
	public @property void mode(int _m){ this._mode = _m;}
	/**
	* Character count bits for each version.
	*
	* @var array
	*/
    protected static int[][] characterCountBitsForVersions = [
		TERMINATOR           : [0, 0, 0],
		NUMERIC              : [10, 12, 14],
		ALPHANUMERIC         : [9, 11, 13],
		STRUCTURED_APPEND    : [0, 0, 0],
		BYTE                 : [8, 16, 16],
		ECI                  : [0, 0, 0],
		KANJI                : [8, 10, 12],
		FNC1_FIRST_POSITION  : [0, 0, 0],
		FNC1_SECOND_POSITION : [0, 0, 0],
		HANZI                : [8, 10, 12],
	];


	/**
	* Gets the number of bits used in a specific QR code version.
	*
	* @param  Version $version
	* @return integer
	*/
    public int getCharacterCountBits(QrCodeVersion _version)
    {
        int number = _version.VersionNumber;
		int offset =0;
        if (number <= 9) {
            offset = 0;
        } else if (number <= 26) {
            offset = 1;
        } else {
            offset = 2;
        }
        return characterCountBitsForVersions[this._mode][offset];
    }
}