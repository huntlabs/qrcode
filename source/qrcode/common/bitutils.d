module qrcode.common.bitutils;

/**
* General bit utilities.
*
* All utility methods are based on 32-bit integers and also work on 64-bit
* systems.
*/
class BitUtils
{
    /**
	* Performs an unsigned right shift.
	*
	* This is the same as the unsigned right shift operator ">>>" in other
	* languages.
	*
	* @param  integer $a
	* @param  integer $b
	* @return integer
	*/
    public static ulong unsignedRightShift(ulong a, ulong b)
    {
        return (a >= 0 ? a >> b : ((a & 0x7fffffff) >> b) | (0x40000000 >> (b - 1)));
    }
    /**
	* Gets the number of trailing zeros.
	*
	* @param  integer $i
	* @return integer
	*/
    public static ulong numberOfTrailingZeros(ulong i)
    {
        import std.string, std.format, std.conv;

        auto pos = format("%032b", i).lastIndexOf('1');

        return pos == -1 ? 32 : 31 - pos;
    }
}
