module ithox.qrcode.common.qrcodeversion;

import ithox.qrcode.common.ecblocks;
import ithox.qrcode.common.errorcorrectionlevel;
import ithox.qrcode.common.bitmatrix;

import std.conv;

class QrCodeVersion
{
    ///int[]
    enum int[] versionDecodeInfo = [
            0x07c94, 0x085bc, 0x09a99, 0x0a4d3, 0x0bbf6, 0x0c762, 0x0d847, 0x0e60d,
            0x0f928, 0x10b78, 0x1145d, 0x12a17, 0x13532, 0x149a6, 0x15683, 0x168c9, 0x177ec,
            0x18ec4, 0x191e1, 0x1afab, 0x1b08e, 0x1cc1a, 0x1d33f, 0x1ed75, 0x1f250, 0x209d5,
            0x216f0, 0x228ba, 0x2379f, 0x24b0b, 0x2542e, 0x26a64, 0x27541, 0x28c69
        ];

    protected int versionNumber, totalCodewords;

    protected int[] alignmentPatternCenters;
    protected EcBlocks[] errorCorrectionBlocks;

    protected static QrCodeVersion[string] versions;

    this(int vn, int[] aps, EcBlocks[] ecbs)
    {
        versionNumber = vn;
        alignmentPatternCenters = aps;
        errorCorrectionBlocks = ecbs;
        totalCodewords = 0;
        auto ecCodewords = ecbs[0].getEcCodewordsPerBlock();
        foreach (ecb; ecbs[0].getEcBlocks())
        {
            totalCodewords += ecb.count * (ecb.dataCodewords + ecCodewords);
        }
    }

    ///gets the version number.
    public @property int VersionNumber()
    {
        return this.versionNumber;
    }
    /**
	* Gets the alignment pattern centers.
	*
	* @return SplFixedArray
	*/
    public @property int[] AlignmentPatternCenters()
    {
        return alignmentPatternCenters;
    }

    ///Gets the total number of codewords.
    public @property int TotalCodewords()
    {
        return this.totalCodewords;
    }

    /**
	* Gets the dimension for the current version.
	*
	* @return integer
	*/
    public @property int DimensionForVersion()
    {
        return 17 + 4 * this.versionNumber;
    }

    /**
	* Gets the number of EC blocks for a specific EC level.
	*
	* @param  ErrorCorrectionLevel $ecLevel
	* @return EcBlocks
	*/
    public EcBlocks getEcBlocksForLevel(ErrorCorrectionLevel ecLevel)
    {
        return this.errorCorrectionBlocks[getOrdinalErrorCorrectionLevel(ecLevel)];
    }

    /**
	* Gets a provisional version number for a specific dimension.
	*
	* @param  integer $dimension
	* @return Version
	* @throws Exception\InvalidArgumentException
	*/
    public static QrCodeVersion getProvisionalVersionForDimension(int dimension)
    {
        if (dimension % 4 != 1)
        {
            throw new Exception("Dimension is not 1 mod 4");
        }
        return getVersionForNumber((dimension - 17) >> 2);
    }

    /**
	* Gets a version instance for a specific version number.
	*
	* @param  integer $versionNumber
	* @return QrCodeVersion
	* @throws Exception\InvalidArgumentException
	*/
    public static QrCodeVersion getVersionForNumber(int versionNumber)
    {
        if (versionNumber < 1 || versionNumber > 40)
        {
            throw new Exception("Version number must be between 1 and 40");
        }
        auto p = to!string(versionNumber) in versions;
        if (p)
        {
            return *p;
        }
        else
        {
            return buildVersion(versionNumber);
        }

    }

    /**
	* Build and cache a specific version.
	*
	* See ISO 18004:2006 6.5.1 Table 9.
	*
	* @param  integer versionNumber
	* @return void
	*/
    protected static QrCodeVersion buildVersion(int versionNumber)
    {
        int[] patterns;
        EcBlocks[] ecBlocks;
        final switch (versionNumber)
        {
        case 1:
            patterns = [];
            ecBlocks = [new EcBlocks(7, new EcBlock(1, 19)), new EcBlocks(10,
                    new EcBlock(1, 16)), new EcBlocks(13, new EcBlock(1, 13)),
                new EcBlocks(17, new EcBlock(1, 9)),];
            break;
        case 2:
            patterns = [6, 18];
            ecBlocks = [new EcBlocks(10, new EcBlock(1, 34)), new EcBlocks(16,
                    new EcBlock(1, 28)), new EcBlocks(22, new EcBlock(1, 22)),
                new EcBlocks(28, new EcBlock(1, 16)),];
            break;
        case 3:
            patterns = [6, 22];
            ecBlocks = [new EcBlocks(15, new EcBlock(1, 55)), new EcBlocks(26,
                    new EcBlock(1, 44)), new EcBlocks(18, new EcBlock(2, 17)),
                new EcBlocks(22, new EcBlock(2, 13)),];
            break;
        case 4:
            patterns = [6, 26];
            ecBlocks = [new EcBlocks(20, new EcBlock(1, 80)), new EcBlocks(18,
                    new EcBlock(2, 32)), new EcBlocks(26, new EcBlock(3, 24)),
                new EcBlocks(16, new EcBlock(4, 9)),];
            break;
        case 5:
            patterns = [6, 30];
            ecBlocks = [new EcBlocks(26, new EcBlock(1, 108)), new EcBlocks(24,
                    new EcBlock(2, 43)), new EcBlocks(18, new EcBlock(2, 15),
                    new EcBlock(2, 16)), new EcBlocks(22, new EcBlock(2, 11), new EcBlock(2, 12)),];
            break;
        case 6:
            patterns = [6, 34];
            ecBlocks = [new EcBlocks(18, new EcBlock(2, 68)), new EcBlocks(16,
                    new EcBlock(4, 27)), new EcBlocks(24, new EcBlock(4, 19)),
                new EcBlocks(28, new EcBlock(4, 15)),];
            break;
        case 7:
            patterns = [6, 22, 38];
            ecBlocks = [new EcBlocks(20, new EcBlock(2, 78)), new EcBlocks(18,
                    new EcBlock(4, 31)), new EcBlocks(18, new EcBlock(2, 14),
                    new EcBlock(4, 15)), new EcBlocks(26, new EcBlock(4, 13)),];
            break;
        case 8:
            patterns = [6, 24, 42];
            ecBlocks = [new EcBlocks(24, new EcBlock(2, 97)), new EcBlocks(22,
                    new EcBlock(2, 38), new EcBlock(2, 39)), new EcBlocks(22, new EcBlock(4,
                    18), new EcBlock(2, 19)), new EcBlocks(26, new EcBlock(4,
                    14), new EcBlock(2, 15)),];
            break;
        case 9:
            patterns = [6, 26, 46];
            ecBlocks = [new EcBlocks(30, new EcBlock(2, 116)), new EcBlocks(22,
                    new EcBlock(3, 36), new EcBlock(2, 37)), new EcBlocks(20, new EcBlock(4,
                    16), new EcBlock(4, 17)), new EcBlocks(24, new EcBlock(4,
                    12), new EcBlock(4, 13)),];
            break;
        case 10:
            patterns = [6, 28, 50];
            ecBlocks = [new EcBlocks(18, new EcBlock(2, 68), new EcBlock(2, 69)),
                new EcBlocks(26, new EcBlock(4, 43), new EcBlock(1, 44)), new EcBlocks(24,
                        new EcBlock(6, 19), new EcBlock(2, 20)), new EcBlocks(28,
                        new EcBlock(6, 15), new EcBlock(2, 16)),];
            break;
        case 11:
            patterns = [6, 30, 54];
            ecBlocks = [new EcBlocks(20, new EcBlock(4, 81)), new EcBlocks(30,
                    new EcBlock(1, 50), new EcBlock(4, 51)), new EcBlocks(28, new EcBlock(4,
                    22), new EcBlock(4, 23)), new EcBlocks(24, new EcBlock(3,
                    12), new EcBlock(8, 13)),];
            break;
        case 12:
            patterns = [6, 32, 58];
            ecBlocks = [new EcBlocks(24, new EcBlock(2, 92), new EcBlock(2, 93)),
                new EcBlocks(22, new EcBlock(6, 36), new EcBlock(2, 37)), new EcBlocks(26,
                        new EcBlock(4, 20), new EcBlock(6, 21)), new EcBlocks(28,
                        new EcBlock(7, 14), new EcBlock(4, 15)),];
            break;
        case 13:
            patterns = [6, 34, 62];
            ecBlocks = [new EcBlocks(26, new EcBlock(4, 107)), new EcBlocks(22,
                    new EcBlock(8, 37), new EcBlock(1, 38)), new EcBlocks(24, new EcBlock(8,
                    20), new EcBlock(4, 21)), new EcBlocks(22, new EcBlock(12,
                    11), new EcBlock(4, 12)),];
            break;
        case 14:
            patterns = [6, 26, 46, 66];
            ecBlocks = [new EcBlocks(30, new EcBlock(3, 115), new EcBlock(1,
                    116)), new EcBlocks(24, new EcBlock(4, 40), new EcBlock(5,
                    41)), new EcBlocks(20, new EcBlock(11, 16), new EcBlock(5,
                    17)), new EcBlocks(24, new EcBlock(11, 12), new EcBlock(5, 13)),];
            break;
        case 15:
            patterns = [6, 26, 48, 70];
            ecBlocks = [new EcBlocks(22, new EcBlock(5, 87), new EcBlock(1, 88)),
                new EcBlocks(24, new EcBlock(5, 41), new EcBlock(5, 42)), new EcBlocks(30,
                        new EcBlock(5, 24), new EcBlock(7, 25)), new EcBlocks(24,
                        new EcBlock(11, 12), new EcBlock(7, 13)),];
            break;
        case 16:
            patterns = [6, 26, 50, 74];
            ecBlocks = [new EcBlocks(24, new EcBlock(5, 98), new EcBlock(1, 99)),
                new EcBlocks(28, new EcBlock(7, 45), new EcBlock(3, 46)), new EcBlocks(24,
                        new EcBlock(15, 19), new EcBlock(2, 20)), new EcBlocks(30,
                        new EcBlock(3, 15), new EcBlock(13, 16)),];
            break;
        case 17:
            patterns = [6, 30, 54, 78];
            ecBlocks = [new EcBlocks(28, new EcBlock(1, 107), new EcBlock(5,
                    108)), new EcBlocks(28, new EcBlock(10, 46), new EcBlock(1,
                    47)), new EcBlocks(28, new EcBlock(1, 22), new EcBlock(15,
                    23)), new EcBlocks(28, new EcBlock(2, 14), new EcBlock(17, 15)),];
            break;
        case 18:
            patterns = [6, 30, 56, 82];
            ecBlocks = [new EcBlocks(30, new EcBlock(5, 120), new EcBlock(1,
                    121)), new EcBlocks(26, new EcBlock(9, 43), new EcBlock(4,
                    44)), new EcBlocks(28, new EcBlock(17, 22), new EcBlock(1,
                    23)), new EcBlocks(28, new EcBlock(2, 14), new EcBlock(19, 15)),];
            break;
        case 19:
            patterns = [6, 30, 58, 86];
            ecBlocks = [new EcBlocks(28, new EcBlock(3, 113), new EcBlock(4,
                    114)), new EcBlocks(26, new EcBlock(3, 44), new EcBlock(11,
                    45)), new EcBlocks(26, new EcBlock(17, 21), new EcBlock(4,
                    22)), new EcBlocks(26, new EcBlock(9, 13), new EcBlock(16, 14)),];
            break;
        case 20:
            patterns = [6, 34, 62, 90];
            ecBlocks = [new EcBlocks(28, new EcBlock(3, 107), new EcBlock(5,
                    108)), new EcBlocks(26, new EcBlock(3, 41), new EcBlock(13,
                    42)), new EcBlocks(30, new EcBlock(15, 24), new EcBlock(5,
                    25)), new EcBlocks(28, new EcBlock(15, 15), new EcBlock(10, 16)),];
            break;
        case 21:
            patterns = [6, 28, 50, 72, 94];
            ecBlocks = [new EcBlocks(28, new EcBlock(4, 116), new EcBlock(4,
                    117)), new EcBlocks(26, new EcBlock(17, 42)), new EcBlocks(28,
                    new EcBlock(17, 22), new EcBlock(6, 23)), new EcBlocks(30,
                    new EcBlock(19, 16), new EcBlock(6, 17)),];
            break;
        case 22:
            patterns = [6, 26, 50, 74, 98];
            ecBlocks = [new EcBlocks(28, new EcBlock(2, 111), new EcBlock(7,
                    112)), new EcBlocks(28, new EcBlock(17, 46)), new EcBlocks(30,
                    new EcBlock(7, 24), new EcBlock(16, 25)), new EcBlocks(24,
                    new EcBlock(34, 13)),];
            break;
        case 23:
            patterns = [6, 30, 54, 78, 102];
            ecBlocks = [new EcBlocks(30, new EcBlock(4, 121), new EcBlock(5,
                    122)), new EcBlocks(28, new EcBlock(4, 47), new EcBlock(14,
                    48)), new EcBlocks(30, new EcBlock(11, 24), new EcBlock(14,
                    25)), new EcBlocks(30, new EcBlock(16, 15), new EcBlock(14, 16)),];
            break;
        case 24:
            patterns = [6, 28, 54, 80, 106];
            ecBlocks = [new EcBlocks(30, new EcBlock(6, 117), new EcBlock(4,
                    118)), new EcBlocks(28, new EcBlock(6, 45), new EcBlock(14,
                    46)), new EcBlocks(30, new EcBlock(11, 24), new EcBlock(16,
                    25)), new EcBlocks(30, new EcBlock(30, 16), new EcBlock(2, 17)),];
            break;
        case 25:
            patterns = [6, 32, 58, 84, 110];
            ecBlocks = [new EcBlocks(26, new EcBlock(8, 106), new EcBlock(4,
                    107)), new EcBlocks(28, new EcBlock(8, 47), new EcBlock(13,
                    48)), new EcBlocks(30, new EcBlock(7, 24), new EcBlock(22,
                    25)), new EcBlocks(30, new EcBlock(22, 15), new EcBlock(13, 16)),];
            break;
        case 26:
            patterns = [6, 30, 58, 86, 114];
            ecBlocks = [new EcBlocks(28, new EcBlock(10, 114), new EcBlock(2,
                    115)), new EcBlocks(28, new EcBlock(19, 46), new EcBlock(4,
                    47)), new EcBlocks(28, new EcBlock(28, 22), new EcBlock(6,
                    23)), new EcBlocks(30, new EcBlock(33, 16), new EcBlock(4, 17)),];
            break;
        case 27:
            patterns = [6, 34, 62, 90, 118];
            ecBlocks = [new EcBlocks(30, new EcBlock(8, 122), new EcBlock(4,
                    123)), new EcBlocks(28, new EcBlock(22, 45), new EcBlock(3,
                    46)), new EcBlocks(30, new EcBlock(8, 23), new EcBlock(26,
                    24)), new EcBlocks(30, new EcBlock(12, 15), new EcBlock(28, 16)),];
            break;
        case 28:
            patterns = [6, 26, 50, 74, 98, 122];
            ecBlocks = [new EcBlocks(30, new EcBlock(3, 117), new EcBlock(10,
                    118)), new EcBlocks(28, new EcBlock(3, 45), new EcBlock(23,
                    46)), new EcBlocks(30, new EcBlock(4, 24), new EcBlock(31,
                    25)), new EcBlocks(30, new EcBlock(11, 15), new EcBlock(31, 16)),];
            break;
        case 29:
            patterns = [6, 30, 54, 78, 102, 126];
            ecBlocks = [new EcBlocks(30, new EcBlock(7, 116), new EcBlock(7,
                    117)), new EcBlocks(28, new EcBlock(21, 45), new EcBlock(7,
                    46)), new EcBlocks(30, new EcBlock(1, 23), new EcBlock(37,
                    24)), new EcBlocks(30, new EcBlock(19, 15), new EcBlock(26, 16)),];
            break;
        case 30:
            patterns = [6, 26, 52, 78, 104, 130];
            ecBlocks = [new EcBlocks(30, new EcBlock(5, 115), new EcBlock(10,
                    116)), new EcBlocks(28, new EcBlock(19, 47), new EcBlock(10,
                    48)), new EcBlocks(30, new EcBlock(15, 24), new EcBlock(25,
                    25)), new EcBlocks(30, new EcBlock(23, 15), new EcBlock(25, 16)),];
            break;
        case 31:
            patterns = [6, 30, 56, 82, 108, 134];
            ecBlocks = [new EcBlocks(30, new EcBlock(13, 115), new EcBlock(3,
                    116)), new EcBlocks(28, new EcBlock(2, 46), new EcBlock(29,
                    47)), new EcBlocks(30, new EcBlock(42, 24), new EcBlock(1,
                    25)), new EcBlocks(30, new EcBlock(23, 15), new EcBlock(28, 16)),];
            break;
        case 32:
            patterns = [6, 34, 60, 86, 112, 138];
            ecBlocks = [new EcBlocks(30, new EcBlock(17, 115)), new EcBlocks(28,
                    new EcBlock(10, 46), new EcBlock(23, 47)), new EcBlocks(30, new EcBlock(10,
                    24), new EcBlock(35, 25)), new EcBlocks(30, new EcBlock(19,
                    15), new EcBlock(35, 16)),];
            break;
        case 33:
            patterns = [6, 30, 58, 86, 114, 142];
            ecBlocks = [new EcBlocks(30, new EcBlock(17, 115), new EcBlock(1,
                    116)), new EcBlocks(28, new EcBlock(14, 46), new EcBlock(21,
                    47)), new EcBlocks(30, new EcBlock(29, 24), new EcBlock(19,
                    25)), new EcBlocks(30, new EcBlock(11, 15), new EcBlock(46, 16)),];
            break;
        case 34:
            patterns = [6, 34, 62, 90, 118, 146];
            ecBlocks = [new EcBlocks(30, new EcBlock(13, 115), new EcBlock(6,
                    116)), new EcBlocks(28, new EcBlock(14, 46), new EcBlock(23,
                    47)), new EcBlocks(30, new EcBlock(44, 24), new EcBlock(7,
                    25)), new EcBlocks(30, new EcBlock(59, 16), new EcBlock(1, 17)),];
            break;
        case 35:
            patterns = [6, 30, 54, 78, 102, 126, 150];
            ecBlocks = [new EcBlocks(30, new EcBlock(12, 121), new EcBlock(7,
                    122)), new EcBlocks(28, new EcBlock(12, 47), new EcBlock(26,
                    48)), new EcBlocks(30, new EcBlock(39, 24), new EcBlock(14,
                    25)), new EcBlocks(30, new EcBlock(22, 15), new EcBlock(41, 16)),];
            break;
        case 36:
            patterns = [6, 24, 50, 76, 102, 128, 154];
            ecBlocks = [new EcBlocks(30, new EcBlock(6, 121), new EcBlock(14,
                    122)), new EcBlocks(28, new EcBlock(6, 47), new EcBlock(34,
                    48)), new EcBlocks(30, new EcBlock(46, 24), new EcBlock(10,
                    25)), new EcBlocks(30, new EcBlock(2, 15), new EcBlock(64, 16)),];
            break;
        case 37:
            patterns = [6, 28, 54, 80, 106, 132, 158];
            ecBlocks = [new EcBlocks(30, new EcBlock(17, 122), new EcBlock(4,
                    123)), new EcBlocks(28, new EcBlock(29, 46), new EcBlock(14,
                    47)), new EcBlocks(30, new EcBlock(49, 24), new EcBlock(10,
                    25)), new EcBlocks(30, new EcBlock(24, 15), new EcBlock(46, 16)),];
            break;
        case 38:
            patterns = [6, 32, 58, 84, 110, 136, 162];
            ecBlocks = [new EcBlocks(30, new EcBlock(4, 122), new EcBlock(18,
                    123)), new EcBlocks(28, new EcBlock(13, 46), new EcBlock(32,
                    47)), new EcBlocks(30, new EcBlock(48, 24), new EcBlock(14,
                    25)), new EcBlocks(30, new EcBlock(42, 15), new EcBlock(32, 16)),];
            break;
        case 39:
            patterns = [6, 26, 54, 82, 110, 138, 166];
            ecBlocks = [new EcBlocks(30, new EcBlock(20, 117), new EcBlock(4,
                    118)), new EcBlocks(28, new EcBlock(40, 47), new EcBlock(7,
                    48)), new EcBlocks(30, new EcBlock(43, 24), new EcBlock(22,
                    25)), new EcBlocks(30, new EcBlock(10, 15), new EcBlock(67, 16)),];
            break;
        case 40:
            patterns = [6, 30, 58, 86, 114, 142, 170];
            ecBlocks = [new EcBlocks(30, new EcBlock(19, 118), new EcBlock(6,
                    119)), new EcBlocks(28, new EcBlock(18, 47), new EcBlock(31,
                    48)), new EcBlocks(30, new EcBlock(34, 24), new EcBlock(34,
                    25)), new EcBlocks(30, new EcBlock(20, 15), new EcBlock(61, 16)),];
            break;
        }
        auto c = new QrCodeVersion(versionNumber, patterns, ecBlocks);
        versions[to!string(versionNumber)] = c;
        return c;
    }

    /**
	* Decodes version information from an integer and returns the version.
	*
	* @param  integer $versionBits
	* @return Version|null
	*/
    public static QrCodeVersion decodeVersionInformation(int versionBits)
    {
        auto bestDifference = int.max;
        auto bestVersion = 0;
        foreach (int i, targetVersion; versionDecodeInfo)
        {
            if (targetVersion == versionBits)
            {
                return getVersionForNumber(i + 7);
            }
            import ithox.qrcode.common.formatinformation;

            auto bitsDifference = FormatInformation.numBitsDiffering(versionBits, targetVersion);
            if (bitsDifference < bestDifference)
            {
                bestVersion = i + 7;
                bestDifference = bitsDifference;
            }
        }
        if (bestDifference <= 3)
        {
            return getVersionForNumber(bestVersion);
        }
        return null;
    }

    /**
	* Builds the function pattern for the current version.
	*
	* @return BitMatrix
	*/
    public BitMatrix buildFunctionPattern()
    {
        auto dimension = this.DimensionForVersion;
        auto bitMatrix = new BitMatrix(dimension);
        // Top left finder pattern + separator + format
        bitMatrix.setRegion(0, 0, 9, 9);
        // Top right finder pattern + separator + format
        bitMatrix.setRegion(dimension - 8, 0, 8, 9);
        // Bottom left finder pattern + separator + format
        bitMatrix.setRegion(0, dimension - 8, 9, 8);
        // Alignment patterns
        auto max = this.alignmentPatternCenters.length;
        for (auto x = 0; x < max; x++)
        {
            auto i = this.alignmentPatternCenters[x] - 2;
            for (auto y = 0; y < max; y++)
            {
                if ((x == 0 && (y == 0 || y == max - 1)) || (x == max - 1 && y == 0))
                {
                    // No alignment patterns near the three finder paterns
                    continue;
                }
                bitMatrix.setRegion(this.alignmentPatternCenters[y] - 2, i, 5, 5);
            }
        }
        // Vertical timing pattern
        bitMatrix.setRegion(6, 9, 1, dimension - 17);
        // Horizontal timing pattern
        bitMatrix.setRegion(9, 6, dimension - 17, 1);
        if (this.versionNumber > 6)
        {
            // Version info, top right
            bitMatrix.setRegion(dimension - 11, 0, 3, 6);
            // Version info, bottom left
            bitMatrix.setRegion(0, dimension - 11, 6, 3);
        }
        return bitMatrix;
    }

    /**
	* Returns a string representation for the version.
	*
	* @return string
	*/
    public override string toString()
    {
        import std.conv;

        return to!string(this.versionNumber);
    }
}
