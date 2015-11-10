module ithox.qrcode.encoder.matrixutil;

import ithox.qrcode.common.bitarray;
import ithox.qrcode.common.qrcodeversion;
import ithox.qrcode.common.errorcorrectionlevel;
import ithox.qrcode.encoder.bytematrix;
import ithox.qrcode.encoder.maskutil;
import std.conv;
/**
* Matrix utility.
*/
class MatrixUtil
{
	/**
	* Position detection pattern.
	*
	* @var array
	*/
    protected enum positionDetectionPattern = [
        [1, 1, 1, 1, 1, 1, 1],
        [1, 0, 0, 0, 0, 0, 1],
        [1, 0, 1, 1, 1, 0, 1],
        [1, 0, 1, 1, 1, 0, 1],
        [1, 0, 1, 1, 1, 0, 1],
        [1, 0, 0, 0, 0, 0, 1],
        [1, 1, 1, 1, 1, 1, 1],
    ];

	/**
	* Position adjustment pattern.
	*
	* @var array
	*/
    protected enum positionAdjustmentPattern = [
        [1, 1, 1, 1, 1],
        [1, 0, 0, 0, 1],
        [1, 0, 1, 0, 1],
        [1, 0, 0, 0, 1],
        [1, 1, 1, 1, 1],
	];

	/**
	* Coordinates for position adjustment patterns for each version.
	*
	* @var array
	*/
    protected enum positionAdjustmentPatternCoordinateTable = [
        [-1, -1, -1, -1, -1, -1, -1], // Version 1
        [   6,   18, -1, -1, -1, -1, -1], // Version 2
        [   6,   22, -1, -1, -1, -1, -1], // Version 3
        [   6,   26, -1, -1, -1, -1, -1], // Version 4
        [   6,   30, -1, -1, -1, -1, -1], // Version 5
        [   6,   34, -1, -1, -1, -1, -1], // Version 6
        [   6,   22,   38, -1, -1, -1, -1], // Version 7
        [   6,   24,   42, -1, -1, -1, -1], // Version 8
        [   6,   26,   46, -1, -1, -1, -1], // Version 9
        [   6,   28,   50, -1, -1, -1, -1], // Version 10
        [   6,   30,   54, -1, -1, -1, -1], // Version 11
        [   6,   32,   58, -1, -1, -1, -1], // Version 12
        [   6,   34,   62, -1, -1, -1, -1], // Version 13
        [   6,   26,   46,   66, -1, -1, -1], // Version 14
        [   6,   26,   48,   70, -1, -1, -1], // Version 15
        [   6,   26,   50,   74, -1, -1, -1], // Version 16
        [   6,   30,   54,   78, -1, -1, -1], // Version 17
        [   6,   30,   56,   82, -1, -1, -1], // Version 18
        [   6,   30,   58,   86, -1, -1, -1], // Version 19
        [   6,   34,   62,   90, -1, -1, -1], // Version 20
        [   6,   28,   50,   72,   94, -1, -1], // Version 21
        [   6,   26,   50,   74,   98, -1, -1], // Version 22
        [   6,   30,   54,   78,  102, -1, -1], // Version 23
        [   6,   28,   54,   80,  106, -1, -1], // Version 24
        [   6,   32,   58,   84,  110, -1, -1], // Version 25
        [   6,   30,   58,   86,  114, -1, -1], // Version 26
        [   6,   34,   62,   90,  118, -1, -1], // Version 27
        [   6,   26,   50,   74,   98,  122, -1], // Version 28
        [   6,   30,   54,   78,  102,  126, -1], // Version 29
        [   6,   26,   52,   78,  104,  130, -1], // Version 30
        [   6,   30,   56,   82,  108,  134, -1], // Version 31
        [   6,   34,   60,   86,  112,  138, -1], // Version 32
        [   6,   30,   58,   86,  114,  142, -1], // Version 33
        [   6,   34,   62,   90,  118,  146, -1], // Version 34
        [   6,   30,   54,   78,  102,  126,  150], // Version 35
        [   6,   24,   50,   76,  102,  128,  154], // Version 36
        [   6,   28,   54,   80,  106,  132,  158], // Version 37
        [   6,   32,   58,   84,  110,  136,  162], // Version 38
        [   6,   26,   54,   82,  110,  138,  166], // Version 39
        [   6,   30,   58,   86,  114,  142,  170], // Version 40
	];

	/**
	* Type information coordinates.
	*
	* @var array
	*/
    protected enum typeInfoCoordinates = [
        [8, 0],
        [8, 1],
        [8, 2],
        [8, 3],
        [8, 4],
        [8, 5],
        [8, 7],
        [8, 8],
        [7, 8],
        [5, 8],
        [4, 8],
        [3, 8],
        [2, 8],
        [1, 8],
        [0, 8],
    ];
	/**
	* Version information polynomial.
	*
	* @var integer
	*/
    protected enum versionInfoPoly = 0x1f25;
    /**
	* Type information polynomial.
	*
	* @var integer
	*/
    protected enum typeInfoPoly = 0x537;
    /**
	* Type information mask pattern.
	*
	* @var integer
	*/
    protected enum typeInfoMaskPattern = 0x5412;


	/**
	* Clears a given matrix.
	*
	* @param  ByteMatrix $matrix
	* @return void
	*/
    public static void clearMatrix(ByteMatrix matrix)
    {
        matrix.clear(-1);
    }

	/**
	* Builds a complete matrix.
	*
	* @param  BitArray             $dataBits
	* @param  ErrorCorrectionLevel $level
	* @param  Version              $version
	* @param  integer              $maskPattern
	* @param  ByteMatrix           $matrix
	* @return void
	*/
    public static void buildMatrix(ref BitArray dataBits,ErrorCorrectionLevel level, QrCodeVersion _version, int maskPattern, ByteMatrix matrix) 
	{
		clearMatrix(matrix);
		embedBasicPatterns(_version, matrix);
		embedTypeInfo(level, maskPattern, matrix);
		maybeEmbedVersionInfo(_version, matrix);
		embedDataBits(dataBits, maskPattern, matrix);
	}
	/**
	* Embeds type information into a matrix.
	*
	* @param  ErrorCorrectionLevel level
	* @param  integer              maskPattern
	* @param  ByteMatrix           matrix
	* @return void
	*/
    protected static void embedTypeInfo(ErrorCorrectionLevel level, int maskPattern, ByteMatrix matrix)
    {
        auto typeInfoBits = new BitArray();
	    makeTypeInfoBits(level, maskPattern, typeInfoBits);
        auto typeInfoBitsSize = typeInfoBits.getSize();
        for (auto i = 0; i < typeInfoBitsSize; i++) {
            auto bit = typeInfoBits.get(typeInfoBitsSize - 1 - i);
            auto x1 = typeInfoCoordinates[i][0];
            auto y1 = typeInfoCoordinates[i][1];
            matrix.set(x1, y1, bit);
			int x2,y2;
            if (i < 8) {
                x2 = matrix.width() - i - 1;
                y2 = 8;
            } else {
                x2 = 8;
                y2 = matrix.height() - 7 + (i - 8);
            }
            matrix.set(x2, y2, bit);
        }
    }

	/**
	* Generates type information bits and appends them to a bit array.
	*
	* @param  ErrorCorrectionLevel level
	* @param  integer maskPattern
	* @param  BitArray bits
	* @return void
	* @throws Exception\RuntimeException
	*/
    protected static void makeTypeInfoBits(ErrorCorrectionLevel level, int maskPattern, BitArray bits)
    {
        auto typeInfo = (getOrdinalErrorCorrectionLevel(level) << 3) | maskPattern;
        bits.appendBits(typeInfo, 5);
        auto bchCode = calculateBchCode(typeInfo, typeInfoPoly);
        bits.appendBits(bchCode, 10);
       auto  maskBits = new BitArray();
        maskBits.appendBits(typeInfoMaskPattern, 15);
        bits.xorBits(maskBits);
        if (bits.getSize() != 15) {
            throw new Exception("Bit array resulted in invalid size: " ~ to!string( bits.getSize()));
        }
    }

	/**
	* Embeds version information if required.
	*
	* @param  Version    version
	* @param  ByteMatrix matrix
	* @return void
	*/
    protected static void maybeEmbedVersionInfo(QrCodeVersion _version, ByteMatrix matrix)
    {
        if (_version.VersionNumber < 7) {
            return;
        }
        auto versionInfoBits = new BitArray();
		makeVersionInfoBits(_version, versionInfoBits);
        auto bitIndex = 6 * 3 - 1;
        for (auto i = 0; i < 6; i++) {
            for (auto j = 0; j < 3; j++) {
               auto bit = versionInfoBits.get(bitIndex);
                bitIndex--;
                matrix.set(i, matrix.height() - 11 + j, bit);
                matrix.set(matrix.height() - 11 + j, i, bit);
            }
        }
    }

	/**
	* Generates version information bits and appends them to a bit array.
	*
	* @param  Version  version
	* @param  BitArray bits
	* @return void
	* @throws Exception\RuntimeException
	*/
    protected static void makeVersionInfoBits(QrCodeVersion _version, BitArray bits)
    {
        bits.appendBits(_version.VersionNumber(), 6);
        auto bchCode = calculateBchCode(_version.VersionNumber(), versionInfoPoly);
        bits.appendBits(bchCode, 12);
        if (bits.getSize() != 18) {
            throw new Exception("Bit array resulted in invalid size: " ~ to!string(bits.getSize()));
        }
    }


	/**
	* Calculates the BHC code for a value and a polynomial.
	*
	* @param  integer value
	* @param  integer poly
	* @return integer
	*/
    protected static int calculateBchCode(int value, int poly)
    {
        auto msbSetInPoly   = findMsbSet(poly);
        value        <<= msbSetInPoly - 1;
        while (findMsbSet(value) >= msbSetInPoly) {
            value ^= poly << (findMsbSet(value) - msbSetInPoly);
        }
        return value;
    }

	/**
	* Finds and MSB set.
	*
	* @param  integer value
	* @return integer
	*/
    protected static int findMsbSet(int value)
    {
        auto numDigits = 0;
        while (value != 0) {
            value >>= 1;
            numDigits++;
        }
        return numDigits;
    }


    /**
	* Embeds basic patterns into a matrix.
	*
	* @param  Version    version
	* @param  ByteMatrix matrix
	* @return void
	*/
    protected static void embedBasicPatterns(QrCodeVersion _version, ByteMatrix matrix)
    {
        embedPositionDetectionPatternsAndSeparators(matrix);
        embedDarkDotAtLeftBottomCorner(matrix);
        maybeEmbedPositionAdjustmentPatterns(_version, matrix);
        embedTimingPatterns(matrix);
    }

	/**
	* Embeds position detection patterns and separators into a byte matrix.
	*
	* @param  ByteMatrix matrix
	* @return void
	*/
    protected static void embedPositionDetectionPatternsAndSeparators(ByteMatrix matrix)
    {
        int pdpWidth =positionDetectionPattern[0].length;
        embedPositionDetectionPattern(0, 0, matrix);
        embedPositionDetectionPattern(matrix.width() - pdpWidth, 0, matrix);
        embedPositionDetectionPattern(0, matrix.width() - pdpWidth, matrix);
        int hspWidth = 8;
        embedHorizontalSeparationPattern(0, hspWidth - 1, matrix);
        embedHorizontalSeparationPattern(matrix.width - hspWidth, hspWidth - 1, matrix);
        embedHorizontalSeparationPattern(0, matrix.width - hspWidth, matrix);
        int vspSize = 7;
        embedVerticalSeparationPattern(vspSize, 0, matrix);
        embedVerticalSeparationPattern(matrix.height - vspSize - 1, 0, matrix);
        embedVerticalSeparationPattern(vspSize, matrix.height - vspSize, matrix);
    }

	/**
	* Embeds a single position detection pattern into a byte matrix.
	*
	* @param  integer    xStart
	* @param  integer    yStart
	* @param  ByteMatrix matrix
	* @return void
	*/
    protected static void embedPositionDetectionPattern(int xStart, int yStart, ByteMatrix matrix)
    {
        for (auto y = 0; y < 7; y++) {
            for (auto x = 0; x < 7; x++) {
                matrix.set(xStart + x, yStart + y, positionDetectionPattern[y][x]);
            }
        }
    }

	/**
	* Embeds a single horizontal separation pattern.
	*
	* @param  integer    xStart
	* @param  integer    yStart
	* @param  ByteMatrix matrix
	* @return void
	* @throws Exception\RuntimeException
	*/
    protected static void embedHorizontalSeparationPattern(int xStart, int yStart, ByteMatrix matrix)
    {
        for (int x = 0; x < 8; x++) {
            if (matrix.get(xStart + x, yStart) != -1) {
                throw new Exception("Byte already set");
            }
            matrix.set(xStart + x, yStart, 0);
        }
    }

	/**
	* Embeds a single vertical separation pattern.
	*
	* @param  integer    xStart
	* @param  integer    yStart
	* @param  ByteMatrix matrix
	* @return void
	* @throws Exception\RuntimeException
	*/
    protected static void embedVerticalSeparationPattern(int xStart, int yStart, ByteMatrix matrix)
    {
        for (int y = 0; y < 7; y++) {
            if (matrix.get(xStart, yStart + y) != -1) {
                throw new Exception("Byte already set");
            }
            matrix.set(xStart, yStart + y, 0);
        }
    }

	/**
	* Embeds a dot at the left bottom corner.
	*
	* @param  ByteMatrix matrix
	* @return void
	* @throws Exception\RuntimeException
	*/
    protected static void embedDarkDotAtLeftBottomCorner(ByteMatrix matrix)
    {
        if (matrix.get(8, matrix.height - 8) == 0) {
            throw new Exception("Byte already set to 0");
        }
        matrix.set(8, matrix.height() - 8, 1);
    }
    /**
	* Embeds position adjustment patterns if required.
	*
	* @param  Version    version
	* @param  ByteMatrix matrix
	* @return void
	*/
    protected static void maybeEmbedPositionAdjustmentPatterns(QrCodeVersion _version, ByteMatrix matrix)
    {
        if (_version.VersionNumber() < 2) {
            return;
        }
        auto index = _version.VersionNumber() - 1;
       auto coordinates    = positionAdjustmentPatternCoordinateTable[index];
        auto numCoordinates =coordinates.length;
        for (auto i = 0; i < numCoordinates; i++) {
            for (auto j = 0; j < numCoordinates; j++) {
                auto y = coordinates[i];
                auto x = coordinates[j];
                if (x == -1 || y == -1) {
                    continue;
                }
                if (matrix.get(x, y) == -1) {
					embedPositionAdjustmentPattern(x - 2, y - 2, matrix);
                }
            }
        }
    }
    /**
	* Embeds a single position adjustment pattern.
	*
	* @param  integer    xStart
	* @param  intger     yStart
	* @param  ByteMatrix matrix
	* @return void
	*/
    protected static void embedPositionAdjustmentPattern(int xStart, int yStart, ByteMatrix matrix)
    {
        for (int y = 0; y < 5; y++) {
            for (int x = 0; x < 5; x++) {
                matrix.set(xStart + x, yStart + y, positionAdjustmentPattern[y][x]);
            }
        }
    }
    /**
	* Embeds timing patterns into a matrix.
	*
	* @param  ByteMatrix matrix
	* @return void
	*/
    protected static void embedTimingPatterns(ByteMatrix matrix)
    {
        auto matrixWidth = matrix.width;
        for (auto i = 8; i < matrixWidth - 8; i++) {
            auto bit = (i + 1) % 2;
            if (matrix.get(i, 6) == -1) {
                matrix.set(i, 6, bit);
            }
            if (matrix.get(6, i) == -1) {
                matrix.set(6, i, bit);
            }
        }
    }
    /**
	* Embeds "dataBits" using "getMaskPattern".
	*
	*  For debugging purposes, it skips masking process if "getMaskPattern" is
	* -1. See 8.7 of JISX0510:2004 (p.38) for how to embed data bits.
	*
	* @param  BitArray   dataBits
	* @param  integer    maskPattern
	* @param  ByteMatrix matrix
	* @return void
	* @throws Exception\WriterException
	*/
    protected static void embedDataBits(ref BitArray dataBits, int maskPattern, ByteMatrix matrix)
    {
       int  bitIndex  = 0;
        int direction = -1;
        // Start from the right bottom cell.
        auto x = matrix.width - 1;
        auto y = matrix.height - 1;
        while (x > 0) {
            // Skip vertical timing pattern.
            if (x == 6) {
                x--;
            }
            while (y >= 0 && y < matrix.height) {
                for (int i = 0; i < 2; i++) {
                    auto xx = x - i;
                    // Skip the cell if it's not empty.
                    if (matrix.get(xx, y) != -1) {
                        continue;
                    }
					bool bit;
                    if (bitIndex < dataBits.getSize()) {
                        bit = dataBits.get(bitIndex);
                        bitIndex++;
                    } else {
                        // Padding bit. If there is no bit left, we'll fill the
                        // left cells with 0, as described in 8.4.9 of
                        // JISX0510:2004 (p. 24).
                        bit = false;
                    }
                    // Skip masking if maskPattern is -1.
                    if (maskPattern != -1 && MaskUtil.getDataMaskBit(maskPattern, xx, y)) {
                        bit = !bit;
                    }
                    matrix.set(xx, y, bit);
                }
                y += direction;
            }
            direction  = -direction;
            y         += direction;
            x         -= 2;
        }
        // All bits should be consumed
        if (bitIndex != dataBits.getSize()) {
            throw new Exception("Not all bits consumed (" ~ to!string(bitIndex) ~ " out of " ~ to!string(dataBits.getSize()) ~")");
        }
    }

}