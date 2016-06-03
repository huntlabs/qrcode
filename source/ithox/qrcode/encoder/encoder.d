module ithox.qrcode.encoder.encoder;

import ithox.qrcode.common.qrcodeversion;
import ithox.qrcode.common.errorcorrectionlevel;
import ithox.qrcode.common.mode;
import ithox.qrcode.common.characterseteci;
import ithox.qrcode.common.bitarray;
import ithox.qrcode.common.reedsolomoncodec;
import ithox.qrcode.encoder.qrcode;
import ithox.qrcode.encoder.bytematrix;
import ithox.qrcode.encoder.matrixutil;
import ithox.qrcode.encoder.maskutil;
import ithox.qrcode.encoder.blockpair;
import std.stdio;


import std.string;
import std.conv;

/**
* Encoder.
*/
class Encoder
{
    /**
	* Default byte encoding.
	*/
    enum DEFAULT_BYTE_MODE_ECODING = "ISO-8859-1";

	/**
	* The original table is defined in the table 5 of JISX0510:2004 (p.19).
	*
	* @var array
	*/
    protected static int[] alphanumericTable = [
			-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  // 0x00-0x0f
			-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  // 0x10-0x1f
			36, -1, -1, -1, 37, 38, -1, -1, -1, -1, 39, 40, -1, 41, 42, 43,  // 0x20-0x2f
			0,   1,  2,  3,  4,  5,  6,  7,  8,  9, 44, -1, -1, -1, -1, -1,  // 0x30-0x3f
			-1, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,  // 0x40-0x4f
			25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, -1, -1, -1, -1, -1,  // 0x50-0x5f
	];

	/**
	* Encodes "content" with the error correction level "ecLevel".
	*
	* @param  string               content
	* @param  ErrorCorrectionLevel ecLevel
	* @param  ?                    hints
	* @return QrCode
	*/
    public static QrCode encode(string content, ErrorCorrectionLevel ecLevel, string encoding = DEFAULT_BYTE_MODE_ECODING)
    {
        // Pick an encoding mode appropriate for the content. Note that this
        // will not attempt to use multiple modes / segments even if that were
        // more efficient. Would be nice.
        auto mode = chooseMode(content, encoding);
        // This will store the header information, like mode and length, as well
        // as "header" segments like an ECI segment.
        auto headerBits = new BitArray();
        // Append ECI segment if applicable
        if (mode.mode == Mode.BYTE && encoding != DEFAULT_BYTE_MODE_ECODING) {
            auto eci = CharacterSetEci.getCharacterSetEciByName(encoding);
            //if (eci !is null) {
				appendEci(eci, headerBits);
          //  }
        }
		 // (With ECI in place,) Write the mode marker
		appendModeInfo(mode, headerBits);
	  // Collect data within the main segment, separately, to count its size
        // if needed. Don't add it to main payload yet.
        auto dataBits = new BitArray();
		  appendBytes(content, mode, dataBits, encoding);

		 // Hard part: need to know version to know how many bits length takes.
        // But need to know how many bits it takes to know version. First we
        // take a guess at version by assuming version will be the minimum, 1:
        auto provisionalBitsNeeded = headerBits.getSize()
			+ mode.getCharacterCountBits(QrCodeVersion.getVersionForNumber(1))
			+ dataBits.getSize();
		
		 auto provisionalVersion = chooseVersion(provisionalBitsNeeded, ecLevel);
	  
        // Use that guess to calculate the right version. I am still not sure
        // this works in 100% of cases.
        auto bitsNeeded = headerBits.getSize()
			+ mode.getCharacterCountBits(provisionalVersion)
			+ dataBits.getSize();
        auto _version = chooseVersion(bitsNeeded, ecLevel);

		 auto headerAndDataBits = new BitArray();
        headerAndDataBits.appendBitArray(headerBits);
		 // Find "length" of main segment and write it.
        auto numLetters = (mode.mode == Mode.BYTE ? dataBits.getSizeInBytes() : content.length);
		appendLengthInfo(cast(int)numLetters, _version, mode, headerAndDataBits);
		
        // Put data together into the overall payload.
        headerAndDataBits.appendBitArray(dataBits);
		
        auto ecBlocks     = _version.getEcBlocksForLevel(ecLevel);
        auto numDataBytes = _version.TotalCodewords() - ecBlocks.getTotalEcCodewords();
		
        // Terminate the bits properly.
	    terminateBits(numDataBytes, headerAndDataBits);
		
        // Interleave data bits with error correction code.
        auto finalBits = interleaveWithEcBytes(
												headerAndDataBits,
												_version.TotalCodewords(),
												numDataBytes,
												ecBlocks.getNumBlocks()
													);
		
        QrCode qrCode = new QrCode();
        qrCode.errorCorrectionLevel(ecLevel);
        qrCode.mode(mode);
        qrCode.qrVersion(_version);
        // Choose the mask pattern and set to "qrCode".
        auto dimension   = _version.DimensionForVersion();
        ByteMatrix matrix      = new ByteMatrix(dimension, dimension);
        auto maskPattern = chooseMaskPattern(finalBits, ecLevel, _version, matrix);

		qrCode.maskPattern(maskPattern);
        // Build the matrix and set it to "qrCode".
		MatrixUtil.buildMatrix(finalBits, ecLevel, _version, maskPattern, matrix);
		
		qrCode.matrix(matrix);
		version(ITHOX_QRCODE)
		{
			std.stdio.writeln("provisionalBitsNeeded:", provisionalBitsNeeded);
			std.stdio.writeln("provisionalVersion:", provisionalVersion);
			std.stdio.writeln("QrCodeVersion.getVersionForNumber(1):", QrCodeVersion.getVersionForNumber(1));
			std.stdio.writeln("numLetters:", numLetters);
			std.stdio.writeln("content:", content);
			std.stdio.writeln("maskPattern:", maskPattern);
		}
        return qrCode;
    }


	/**
	* Chooses the best mode for a given content.
	*
	* @param  string content
	* @param  string encoding
	* @return Mode
	*/
    protected static Mode chooseMode(string content, string encoding = string.init)
    {
        if (encoding.toUpper() == "SHIFT-JIS") {
            //return isOnlyDoubleByteKanji(content) ? new Mode(Mode.KANJI) : new Mode(Mode.BYTE);

			return  new Mode(Mode.KANJI);
        }

        auto hasNumeric      = false;
        auto hasAlphanumeric = false;

		import std.ascii;
        for (auto i = 0; i < content.length; i++) {
            auto c = content[i];
            if (isDigit(c)) {
                hasNumeric = true;
            } else if (getAlphanumericCode(c) != -1) {
                hasAlphanumeric = true;
            } else {
                return new Mode(Mode.BYTE);
            }
        }
        if (hasAlphanumeric) {
            return new Mode(Mode.ALPHANUMERIC);
        } else if (hasNumeric) {
            return new Mode(Mode.NUMERIC);
        }
        return new Mode(Mode.BYTE);
    }

	/**
	* Gets the alphanumeric code for a byte.
	*
	* @param  string|integer $code
	* @return integer
	*/
    protected static int getAlphanumericCode(int code)
    {
        if (alphanumericTable.length > code ) {
            return alphanumericTable[code];
        }
        return -1;
    }


	/**
	* Appends ECI information to a bit array.
	*
	* @param  CharacterSetEci $eci
	* @param  BitArray        $bits
	* @return void
	*/
	protected static void appendEci(CharacterSetEci eci, ref BitArray bits)
	{
		auto mode = new Mode(Mode.ECI);
		bits.appendBits(mode.mode, 4);
		bits.appendBits(eci.eci, 8);
	}

	/**
	* Appends mode information to a bit array.
	*
	* @param  Mode     $mode
	* @param  BitArray $bits
	* @return void
	*/
    protected static void appendModeInfo(Mode mode, ref BitArray bits)
    {
        bits.appendBits(mode.mode, 4);
    }

	/**
	* Appends bytes to a bit array in a specific mode.
	*
	* @param  stirng   $content
	* @param  Mode     $mode
	* @param  BitArray $bits
	* @param  string   $encoding
	* @return void
	* @throws Exception\WriterException
	*/
    protected static void appendBytes(string content, Mode mode, ref BitArray bits, string encoding)
    {
        switch (mode.mode) {
            case Mode.NUMERIC:
				appendNumericBytes(content, bits);
                break;
            case Mode.ALPHANUMERIC:
				appendAlphanumericBytes(content, bits);
                break;
            case Mode.BYTE:
				append8BitBytes(content, bits, encoding);
                break;
            case Mode.KANJI:
				appendKanjiBytes(content, bits);
                break;
            default:
                throw new Exception("Invalid mode: " ~ to!string(mode.mode));
        }
    }


	/**
	* Appends numeric bytes to a bit array.
	*
	* @param  string   content
	* @param  BitArray bits
	* @return void
	*/
    protected static void appendNumericBytes(string content, BitArray bits)
    {
		import std.conv, ithox.qrcode.utils;
		auto length = content.length;
		int i      = 0;
        while (i < length) {
            auto num1 = charToInt(content[i]);
            if (i + 2 < length) {
                // Encode three numeric letters in ten bits.
                auto num2 = charToInt(content[i + 1]);
               auto num3 = charToInt(content[i + 2]);
                bits.appendBits(num1 * 100 + num2 * 10 + num3, 10);
                i += 3;
            } else if (i + 1 < length) {
                // Encode two numeric letters in seven bits.
                auto num2 = charToInt(content[i + 1]);
                bits.appendBits(num1 * 10 + num2, 7);
                i += 2;
            } else {
                // Encode one numeric letter in four bits.
                bits.appendBits(num1, 4);
                i++;
            }
        }
    }


	/**
	* Appends alpha-numeric bytes to a bit array.
	*
	* @param  string   content
	* @param  BitArray bits
	* @return void
	*/
    protected static void appendAlphanumericBytes(string content, BitArray bits)
    {
        auto i      = 0;
		auto code1 = 0, code2 = 0, length=content.length;
        while (i < length) {
            if (-1 == (code1 = getAlphanumericCode(content[i]))) {
                throw new Exception("Invalid alphanumeric code");
            }
            if (i + 1 < length) {
                if (-1 == (code2 = getAlphanumericCode(content[i + 1]))) {
                    throw new Exception("Invalid alphanumeric code");
                }
                // Encode two alphanumeric letters in 11 bits.
                bits.appendBits(code1 * 45 + code2, 11);
                i += 2;
            } else {
                // Encode one alphanumeric letter in six bits.
                bits.appendBits(code1, 6);
                i++;
            }
        }
    }

	/**
	* Appends regular 8-bit bytes to a bit array.
	*
	* @param  string   content
	* @param  BitArray bits
	* @return void
	*/
    protected static void append8BitBytes(string content, ref BitArray bits, string encoding)
    {
     /*   if (false == (bytes = @iconv('utf-8', encoding, content))) {
            throw new Exception("Could not encode content to " ~ encoding);
        }
		*/
		version(ITHOX_QRCODE)
			std.stdio.writeln("content:----", content);
        auto length =content.length;
        for (auto i = 0; i < length; i++) {
            bits.appendBits(cast(int)(content[i]), 8, true);
        }
		
    }


	/**
	* Appends KANJI bytes to a bit array.
	*
	* @param  string   content
	* @param  BitArray bits
	* @return void
	*/
    protected static void appendKanjiBytes(string content, BitArray bits)
    {
        if (content.length % 2 > 0) {
            // We just do a simple length check here. The for loop will check
            // individual characters.
            throw new Exception("Content does not seem to be encoded in SHIFT-JIS");
        }

		int subtracted = 0;

        for (auto i = 0; i < content.length; i += 2) {
            auto byte1 = (content[i]) & 0xff;
            auto byte2 = (content[i + 1]) & 0xff;
            auto code  = (byte1 << 8) | byte2;
            if (code >= 0x8140 && code <= 0x9ffc) {
                subtracted = code - 0x8140;
            } else if (code >= 0xe040 && code <= 0xebbf) {
                subtracted = code - 0xc140;
            } else {
                throw new Exception("Invalid byte sequence");
            }
            auto encoded = ((subtracted >> 8) * 0xc0) + (subtracted & 0xff);
            bits.appendBits(encoded, 13);
        }
    }


	/**
	* Chooses the best version for the input.
	*
	* @param  integer              numInputBits
	* @param  ErrorCorrectionLevel ecLevel
	* @return Version
	* @throws Exception\WriterException
	*/
    protected static QrCodeVersion chooseVersion(BitArrayBitType numInputBits, ErrorCorrectionLevel ecLevel)
    {
        for (auto versionNum = 1; versionNum <= 40; versionNum++) {
            QrCodeVersion _version  = QrCodeVersion.getVersionForNumber(versionNum);
            auto numBytes = _version.TotalCodewords();
            auto ecBlocks   = _version.getEcBlocksForLevel(ecLevel);
            auto numEcBytes = ecBlocks.getTotalEcCodewords();
            auto numDataBytes    = numBytes - numEcBytes;
            auto totalInputBytes = to!int((numInputBits + 8) / 8);
            if (numDataBytes >= totalInputBytes) {
                return _version;
            }
        }
        throw new Exception("Data too big");
    }


	/**
	* Appends length information to a bit array.
	*
	* @param  integer  numLetters
	* @param  Version  version
	* @param  Mode     mode
	* @param  BitArray bits
	* @return void
	* @throws Exception\WriterException
	*/
    protected static void appendLengthInfo(int numLetters, QrCodeVersion _version, Mode mode, ref BitArray bits)
    {
        auto numBits = mode.getCharacterCountBits(_version);
        if (numLetters >= (1 << numBits)) {
            throw new Exception(to!string(numLetters) ~ " is bigger than " ~ to!string(((1 << numBits) - 1)));
        }
        bits.appendBits(numLetters, numBits);
    }


	/**
	* Terminates the bits in a bit array.
	*
	* @param  integer  numDataBytes
	* @param  BitArray bits
	* @throws Exception\WriterException
	*/
    protected static void terminateBits(int numDataBytes,ref  BitArray bits)
    {
        auto capacity = numDataBytes << 3;
        if (bits.getSize() > capacity) {
            throw new Exception("Data bits cannot fit in the QR code");
        }
        for (auto i = 0; i < 4 && bits.getSize() < capacity; i++) {
            bits.appendBit(false);
        }
        auto numBitsInLastByte = bits.getSize() & 0x7;
        if (numBitsInLastByte > 0) {
            for (auto i = numBitsInLastByte; i < 8; i++) {
                bits.appendBit(false);
            }
        }
       auto numPaddingBytes = numDataBytes - bits.getSizeInBytes();
        for (auto i = 0; i < numPaddingBytes; i++) {
            bits.appendBits((i & 0x1) == 0 ? 0xec : 0x11, 8);
        }
        if (bits.getSize() != capacity) {
            throw new Exception("Bits size does not equal capacity");
        }
    }


	/**
	* Interleaves data with EC bytes.
	*
	* @param  BitArray bits
	* @param  integer  numTotalBytes
	* @param  integer  numDataBytes
	* @param  integer  numRsBlocks
	* @return BitArray
	* @throws Exception\WriterException
	*/
    protected static BitArray interleaveWithEcBytes(ref BitArray bits, int numTotalBytes, int numDataBytes, int numRsBlocks)
    {
        if (bits.getSizeInBytes() != numDataBytes) {
            throw new Exception("Number of bits and data bytes does not match");
        }
        auto dataBytesOffset = 0;
        auto maxNumDataBytes = 0;
        auto maxNumEcBytes   = 0;
        BlockPair[] blocks = new BlockPair[numRsBlocks];
        for (auto i = 0; i < numRsBlocks; i++) {
            auto tmp = getNumDataBytesAndNumEcBytesForBlockId(numTotalBytes,numDataBytes,numRsBlocks,i);
			auto numDataBytesInBlock = tmp[0];
			auto numEcBytesInBlock = tmp[1];
            auto size       = numDataBytesInBlock;
            auto dataBytes  = bits.toBytes(8 * dataBytesOffset, size);
            auto ecBytes    = generateEcBytes(dataBytes, numEcBytesInBlock);
            blocks[i] = new BlockPair(dataBytes, ecBytes);
			import std.algorithm;
            maxNumDataBytes  = max(maxNumDataBytes, size);
            maxNumEcBytes    = max(maxNumEcBytes, cast(int)ecBytes.length);
            dataBytesOffset += numDataBytesInBlock;
        }
        if (numDataBytes != dataBytesOffset) {
            throw new Exception("Data bytes does not match offset");
        }
        auto result = new BitArray();
        for (auto i = 0; i < maxNumDataBytes; i++) {
            foreach (block; blocks ) {
                auto dataBytes = block.getDataBytes();
                if (i < dataBytes.length) {
                    result.appendBits(dataBytes[i], 8);
                }
            }
        }
        for (auto i = 0; i < maxNumEcBytes; i++) {
             foreach (block; blocks ) {
                auto ecBytes = block.getErrorCorrectionBytes();
                if (i < ecBytes.length) {
                    result.appendBits(ecBytes[i], 8);
                }
            }
        }
        if (numTotalBytes != result.getSizeInBytes()) {
            throw new Exception("Interleaving error: " ~ to!string(numTotalBytes) ~ " and " ~ to!string(result.getSizeInBytes()) ~ " differ");
        }
        return result;
    } 
	/**
	* Gets number of data- and EC bytes for a block ID.
	*
	* @param  integer numTotalBytes
	* @param  integer numDataBytes
	* @param  integer numRsBlocks
	* @param  integer blockId
	* @return array
	* @throws Exception\WriterException
	*/
    protected static int[] getNumDataBytesAndNumEcBytesForBlockId(int numTotalBytes,
																	int numDataBytes,
																	 int numRsBlocks,
																	 int blockId
																	 ) 
	{
		if (blockId >= numRsBlocks) {
			throw new Exception("Block ID too large");
		}
		auto numRsBlocksInGroup2   = numTotalBytes % numRsBlocks;
		auto numRsBlocksInGroup1   = numRsBlocks - numRsBlocksInGroup2;
		auto numTotalBytesInGroup1 = to!int(numTotalBytes / numRsBlocks);
		auto numTotalBytesInGroup2 = numTotalBytesInGroup1 + 1;
		auto numDataBytesInGroup1  = to!int(numDataBytes / numRsBlocks);
		auto numDataBytesInGroup2  = numDataBytesInGroup1 + 1;
		auto numEcBytesInGroup1    = numTotalBytesInGroup1 - numDataBytesInGroup1;
		auto numEcBytesInGroup2    = numTotalBytesInGroup2 - numDataBytesInGroup2;
		if (numEcBytesInGroup1 != numEcBytesInGroup2) {
			throw new Exception("EC bytes mismatch");
		}
		if (numRsBlocks != numRsBlocksInGroup1 + numRsBlocksInGroup2) {
			throw new Exception("RS blocks mismatch");
		}
		if (numTotalBytes !=
			((numDataBytesInGroup1 + numEcBytesInGroup1) * numRsBlocksInGroup1)
			+ ((numDataBytesInGroup2 + numEcBytesInGroup2) * numRsBlocksInGroup2)
			) {
				throw new Exception("Total bytes mismatch");
			}
		if (blockId < numRsBlocksInGroup1) {
			return [numDataBytesInGroup1, numEcBytesInGroup1];
		} else {
			return [numDataBytesInGroup2, numEcBytesInGroup2];
		}
	}


	/**
	* Generates EC bytes for given data.
	*
	* @param  SplFixedArray dataBytes
	* @param  integer       numEcBytesInBlock
	* @return SplFixedArray
	*/
    protected static int[] generateEcBytes(int[] dataBytes, int numEcBytesInBlock)
    {
        auto numDataBytes = cast(int)dataBytes.length;
        auto toEncode     = new int[numDataBytes + numEcBytesInBlock];
        for (auto i = 0; i < numDataBytes; i++) {
            toEncode[i] = dataBytes[i] & 0xff;
        }
        auto ecBytes = new int[numEcBytesInBlock];
        ReedSolomonCodec codec   = getCodec(numDataBytes, numEcBytesInBlock);
        codec.encode(toEncode, ecBytes);
        return ecBytes;
    }


	/**
	* Gets an RS codec and caches it.
	*
	* @param  integer numDataBytes
	* @param  integer numEcBytesInBlock
	* @return ReedSolomonCodec
	*/
    protected static ReedSolomonCodec getCodec(int numDataBytes, int numEcBytesInBlock)
    {
		return new ReedSolomonCodec(
													 8,
													 0x11d,
													 0,
													 1,
													 numEcBytesInBlock,
													 255 - numDataBytes - numEcBytesInBlock
													 );

	}
	/**
	* Chooses the best mask pattern for a matrix.
	*
	* @param  BitArray             bits
	* @param  ErrorCorrectionLevel ecLevel
	* @param  Version              version
	* @param  ByteMatrix           matrix
	* @return integer
	*/
    protected static int chooseMaskPattern(BitArray bits, ErrorCorrectionLevel ecLevel,QrCodeVersion _version,ref ByteMatrix matrix) 
	{
		auto minPenality     = int.max;
		auto bestMaskPattern = -1;
		for (auto maskPattern = 0; maskPattern < QrCode.NUM_MASK_PATTERNS; maskPattern++) {
			MatrixUtil.buildMatrix(bits, ecLevel, _version, maskPattern, matrix);
			auto penalty = calculateMaskPenalty(matrix);
			if (penalty < minPenality) {
				minPenality     = penalty;
				bestMaskPattern = maskPattern;
			}
			import std.stdio;
			//writeln(matrix);
		}
		return bestMaskPattern;
	}

	/**
	* Calculates the mask penalty for a matrix.
	*
	* @param  ByteMatrix $matrix
	* @return integer
	*/
    protected static int calculateMaskPenalty(ByteMatrix matrix)
    {
        return (
				MaskUtil.applyMaskPenaltyRule1(matrix)
				+ MaskUtil.applyMaskPenaltyRule2(matrix)
				+ MaskUtil.applyMaskPenaltyRule3(matrix)
				+ MaskUtil.applyMaskPenaltyRule4(matrix)
				);
    }
}
