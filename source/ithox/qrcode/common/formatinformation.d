module ithox.qrcode.common.formatinformation;

import ithox.qrcode.common.errorcorrectionlevel;
import ithox.qrcode.common.bitutils;

/**
* Encapsulates a QR Code's format information, including the data mask used and
* error correction level.
*/
class FormatInformation
{
    /**
	* Mask for format information.
	*/
    enum int FORMAT_INFO_MASK_QR = 0x5412;

    /**
	* Lookup table for decoding format information.
	*
	* See ISO 18004:2006, Annex C, Table C.1
	*
	* @var array
	*/
    protected static int[][] formatInfoDecodeLookup = [
        [0x5412, 0x00
    ], [0x5125, 0x01], [
        0x5e7c, 0x02
    ], [0x5b4b, 0x03], [
        0x45f9, 0x04
    ], [0x40ce, 0x05], [
        0x4f97, 0x06
    ], [0x4aa0, 0x07], [
        0x77c4, 0x08
    ], [0x72f3, 0x09], [
        0x7daa, 0x0a
    ], [0x789d, 0x0b], [
        0x662f, 0x0c
    ], [0x6318, 0x0d], [
        0x6c41, 0x0e
    ], [0x6976, 0x0f], [
        0x1689, 0x10
    ], [0x13be, 0x11], [
        0x1ce7, 0x12
    ], [0x19d0, 0x13], [
        0x0762, 0x14
    ], [0x0255, 0x15], [
        0x0d0c, 0x16
    ], [0x083b, 0x17], [
        0x355f, 0x18
    ], [0x3068, 0x19], [
        0x3f31, 0x1a
    ], [0x3a06, 0x1b], [0x24b4, 0x1c], [0x2183, 0x1d], [0x2eda, 0x1e], [0x2bed, 0x1f],];

    /**
	* Offset i holds the number of 1 bits in the binary representation of i.
	*
	* @var array
	*/
    protected static int[] bitsSetInHalfByte = [0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4];

    /**
	* Error correction level.
	*
	* @var ErrorCorrectionLevel
	*/
    protected ErrorCorrectionLevel ecLevel;
    /**
	* Data mask.
	*
	* @var integer
	*/
    protected int dataMask;

    this(int formatInfo)
    {
        this.ecLevel = cast(ErrorCorrectionLevel)((formatInfo >> 3) & 0x3);
        this.dataMask = formatInfo & 0x7;
    }

    /**
	* Checks how many bits are different between two integers.
	*
	* @param  integer a
	* @param  integer b
	* @return integer
	*/
    public static int numBitsDiffering(int a, int b)
    {
        a ^= b;
        return (bitsSetInHalfByte[a & 0xf] + bitsSetInHalfByte[(BitUtils.unsignedRightShift(a,
                4) & 0xf)] + bitsSetInHalfByte[(BitUtils.unsignedRightShift(a,
                8) & 0xf)] + bitsSetInHalfByte[(BitUtils.unsignedRightShift(a,
                12) & 0xf)] + bitsSetInHalfByte[(BitUtils.unsignedRightShift(a,
                16) & 0xf)] + bitsSetInHalfByte[(BitUtils.unsignedRightShift(a,
                20) & 0xf)] + bitsSetInHalfByte[(BitUtils.unsignedRightShift(a,
                24) & 0xf)] + bitsSetInHalfByte[(BitUtils.unsignedRightShift(a, 28) & 0xf)]);
    }

    /**
	* Decodes format information.
	*
	* @param  integer $maskedFormatInfo1
	* @param  integer $maskedFormatInfo2
	* @return FormatInformation|null
	*/
    public static FormatInformation decodeFormatInformation(int maskedFormatInfo1,
            int maskedFormatInfo2)
    {
        auto formatInfo = doDecodeFormatInformation(maskedFormatInfo1, maskedFormatInfo2);
        if (formatInfo !is null)
        {
            return formatInfo;
        }
        // Should return null, but, some QR codes apparently do not mask this
        // info. Try again by actually masking the pattern first.
        return doDecodeFormatInformation(maskedFormatInfo1 ^ FORMAT_INFO_MASK_QR,
                maskedFormatInfo2 ^ FORMAT_INFO_MASK_QR);
    }

    /**
	* Internal method for decoding format information.
	*
	* @param  integer $maskedFormatInfo1
	* @param  integer $maskedFormatInfo2
	* @return FormatInformation|null
	*/
    protected static FormatInformation doDecodeFormatInformation(int maskedFormatInfo1,
            int maskedFormatInfo2)
    {
        int bestDifference = int.max;
        int bestFormatInfo = 0;
        foreach (decodeInfo; formatInfoDecodeLookup)
        {
            auto targetInfo = decodeInfo[0];
            if (targetInfo == maskedFormatInfo1 || targetInfo == maskedFormatInfo2)
            {
                // Found an exact match
                return new FormatInformation(decodeInfo[1]);
            }
            auto bitsDifference = numBitsDiffering(maskedFormatInfo1, targetInfo);
            if (bitsDifference < bestDifference)
            {
                bestFormatInfo = decodeInfo[1];
                bestDifference = bitsDifference;
            }
            if (maskedFormatInfo1 != maskedFormatInfo2)
            {
                // Also try the other option
                bitsDifference = numBitsDiffering(maskedFormatInfo2, targetInfo);
                if (bitsDifference < bestDifference)
                {
                    bestFormatInfo = decodeInfo[1];
                    bestDifference = bitsDifference;
                }
            }
        }
        // Hamming distance of the 32 masked codes is 7, by construction, so
        // <= 3 bits differing means we found a match.
        if (bestDifference <= 3)
        {
            return new FormatInformation(bestFormatInfo);
        }
        return null;
    }

    /**
	* Gets the error correction level.
	*
	* @return ErrorCorrectionLevel
	*/
    public ErrorCorrectionLevel getErrorCorrectionLevel()
    {
        return this.ecLevel;
    }
    /**
	* Gets the data mask.
	*
	* @return integer
	*/
    public int getDataMask()
    {
        return this.dataMask;
    }
    /**
	* Hashes the code of the EC level.
	*
	* @return integer
	*/
    public int hashCode()
    {
        return (this.ecLevel << 3) | this.dataMask;
    }
    /**
	* Verifies if this instance equals another one.
	*
	* @param  mixed $other
	* @return boolean
	*/
    public bool equals(FormatInformation other)
    {
        if (typeid(FormatInformation) != typeid(other))
        {
            return false;
        }
        return (ecLevel == other.getErrorCorrectionLevel() && dataMask == other.getDataMask());
    }
}
