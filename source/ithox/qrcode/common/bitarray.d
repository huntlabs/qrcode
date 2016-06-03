module ithox.qrcode.common.bitarray;

import ithox.qrcode.common.bitutils;

alias BitArrayBitType = long;

/**
* A simple, fast array of bits.
*/
class BitArray
{
    /**
	* Bits represented as an array of integers.
	*
	* @var SplFixedArray
	*/
    protected BitArrayBitType[] bits;
    /**
	* Size of the bit array in bits.
	*
	* @var integer
	*/
    protected BitArrayBitType size;
    /**
	* Creates a new bit array with a given size.
	*
	* @param integer size
	*/
	this(int size = 0)
    {
        this.size = size;
        this.bits = new BitArrayBitType[(this.size + 31) >> 3];
    }
    /**
	* Gets the size in bits.
	*
	* @return integer
	*/
    public BitArrayBitType getSize()
    {
        return this.size;
    }
    /**
	* Gets the size in bytes.
	*
	* @return integer
	*/
    public BitArrayBitType getSizeInBytes()
    {
        return (this.size + 7) >> 3;
    }
    /**
	* Ensures that the array has a minimum capacity.
	*
	* @param  integer size
	* @return void
	*/
    public void ensureCapacity(BitArrayBitType size)
    {
        if (size > bits.length << 5) {
            this.bits.length = (size + 31) >> 5;
        }
    }
    /**
	* Gets a specific bit.
	*
	* @param  integer i
	* @return boolean
	*/
    public bool get(long i)
    {
		return (this.bits[i >> 5L] & (1L << (i & 0x1f))) != 0;
    }
    /**
	* Sets a specific bit.
	*
	* @param  integer i
	* @return void
	*/
    public void set(int i)
    {
        this.bits[i >> 5] = this.bits[i >> 5] | 1L << (i & 0x1f);
    }
    /**
	* Flips a specific bit.
	*
	* @param  integer i
	* @return void
	*/
    public void flip(int i)
    {
        this.bits[i >> 5] ^= 1L << (i & 0x1f);
    }
    /**
	* Gets the next set bit position from a given position.
	*
	* @param  integer from
	* @return integer
	*/
    public long getNextSet(long from)
    {
        if (from >= this.size) {
            return this.size;
        }
       auto bitsOffset  = from >> 5;
        auto currentBits = this.bits[bitsOffset];
        auto bitsLength  = this.bits.length;
        currentBits &= ~((1L << (from & 0x1f)) - 1);
        while (currentBits == 0) {
            if (++bitsOffset == bitsLength) {
                return this.size;
            }
            currentBits = this.bits[bitsOffset];
        }
        auto result = (bitsOffset << 5) + BitUtils.numberOfTrailingZeros(currentBits);
        return result > this.size ? this.size : result;
    }
    /**
	* Gets the next unset bit position from a given position.
	*
	* @param  integer from
	* @return integer
	*/
    public ulong getNextUnset(int from)
    {
        if (from >= this.size) {
            return this.size;
        }
        auto bitsOffset  = from >> 5;
        auto currentBits = ~this.bits[bitsOffset];
        auto bitsLength  = this.bits.length;
        currentBits &= ~((1L << (from & 0x1f)) - 1);
        while (currentBits == 0) {
            if (++bitsOffset == bitsLength) {
                return this.size;
            }
            currentBits = ~this.bits[bitsOffset];
        }
        auto result = (bitsOffset << 5) + BitUtils.numberOfTrailingZeros(currentBits);
        return result > this.size ? this.size : result;
    }
    /**
	* Sets a bulk of bits.
	*
	* @param  integer i
	* @param  integer newBits
	* @return void
	*/
    public void setBulk(int i, BitArrayBitType newBits)
    {
        this.bits[i >> 5] = newBits;
    }
    /**
	* Sets a range of bits.
	*
	* @param  integer start
	* @param  integer end
	* @return void
	* @throws Exception\InvalidArgumentException
	*/
    public void setRange(int start, int end)
    {
        if (end < start) {
            throw new Exception("End must be greater or equal to start");
        }
        if (end == start) {
            return;
        }
        end--;
        auto firstInt = start >> 5;
        auto lastInt  = end >> 5;
		auto mask = 0;
        for (auto i = firstInt; i <= lastInt; i++) {
            auto firstBit = i > firstInt ?  0 : start & 0x1f;
            auto lastBit  = i < lastInt ? 31 : end & 0x1f;
            if (firstBit == 0 && lastBit == 31) {
                mask = 0x7fffffff;
            } else {
                mask = 0;
                for (auto j = firstBit; j < lastBit; j++) {
                    mask |= 1L << j;
                }
            }
            this.bits[i] = this.bits[i] | mask;
        }
    }
    /**
	* Clears the bit array, unsetting every bit.
	*
	* @return void
	*/
    public void clear()
    {
		this.bits[] = 0;
    }
    /**
	* Checks if a range of bits is set or not set.
	*
	* @param  integer start
	* @param  integer end
	* @param  integer value
	* @return boolean
	* @throws Exception\InvalidArgumentException
	*/
    public bool isRange(int start, int end, int value)
    {
        if (end < start) {
            throw new Exception("End must be greater or equal to start");
        }
        if (end == start) {
            return false;
        }
        end--;
        auto firstInt = start >> 5;
        auto lastInt  = end >> 5;
		auto mask = 0;
        for (auto i = firstInt; i <= lastInt; i++) {
            auto firstBit = i > firstInt ?  0 : start & 0x1f;
            auto lastBit  = i < lastInt ? 31 : end & 0x1f;
            if (firstBit == 0 && lastBit == 31) {
                mask = 0x7fffffff;
            } else {
                mask = 0;
                for (auto j = firstBit; j <= lastBit; j++) {
                    mask |= 1L << j;
                }
            }
            if ((this.bits[i] & mask) != (value ? mask : 0)) {
                return false;
            }
        }
        return true;
    }
    /**
	* Appends a bit to the array.
	*
	* @param  boolean bit
	* @return void
	*/
    public void appendBit(bool bit, bool test = false)
    {
        this.ensureCapacity(this.size + 1);
        if (bit) {
			if(test)
			{
				import std.stdio;
				//writeln("---",this.bits, " size:", this.size);
			}
            this.bits[this.size >> 5] = this.bits[this.size >> 5] | (1L << (this.size & 0x1f));
			if(test)
			{
				import std.stdio;
				//writeln(this.bits);
			}
        }
        this.size++;
    }
    /**
	* Appends a number of bits (up to 32) to the array.
	*
	* @param  integer value
	* @param  integer numBits
	* @return void
	* @throws Exception\InvalidArgumentException
	*/
    public void appendBits(int value, int numBits, bool test = false)
    {
        if (numBits < 0 || numBits > 32) {
            throw new Exception("Num bits must be between 0 and 32");
        }
        this.ensureCapacity(this.size + numBits);
        for (auto numBitsLeft = numBits; numBitsLeft > 0; numBitsLeft--) {
			if(test)
			{
				import std.stdio;
				//writeln("value:", value , " xxx:", ((value >> (numBitsLeft - 1)) & 0x01));
			}
            this.appendBit(((value >> (numBitsLeft - 1)) & 0x01) == 1, test);
        }
    }
    /**
	* Appends another bit array to this array.
	*
	* @param  BitArray other
	* @return void
	*/
    public void appendBitArray(BitArray other)
    {
        this.ensureCapacity(this.size + other.getSize());
        for (auto i = 0; i < other.getSize(); i++) {
            this.appendBit(other.get(i));
        }
    }
    /**
	* Makes an exclusive-or comparision on the current bit array.
	*
	* @param  BitArray other
	* @return void
	* @throws Exception\InvalidArgumentException
	*/
    public void xorBits(BitArray other)
    {
       auto bitsLength = this.bits.length;
        auto otherBits  = other.getBitArray();
        if (bitsLength != otherBits.length) {
            throw new Exception("Sizes don\'t match");
        }
        for (auto i = 0; i < bitsLength; i++) {
            this.bits[i] = this.bits[i] ^ otherBits[i];
        }
    }
    /**
	* Converts the bit array to a byte array.
	*
	* @param  integer bitOffset
	* @param  integer numBytes
	* @return SplFixedArray
	*/
    public int[] toBytes(int bitOffset, int numBytes)
    {
        auto bytes = new int[numBytes];
        for (auto i = 0; i < numBytes; i++) {
           auto  _byte = 0;
            for (auto j = 0; j < 8; j++) {
                if (this.get(bitOffset)) {
                    _byte |= 1L << (7 - j);
                }
                bitOffset++;
            }
            bytes[i] = _byte;
        }
        return bytes;
    }
    /**
	* Gets the internal bit array.
	*
	* @return SplFixedArray
	*/
    public BitArrayBitType[] getBitArray()
    {
        return this.bits;
    }
    /**
	* Reverses the array.
	*
	* @return void
	*/
    public void reverse()
    {
       auto newBits = new BitArrayBitType[this.bits.length];
        for (auto i = 0; i < this.size; i++) {
            if (this.get(this.size - i - 1)) {
                newBits[i >> 5] = newBits[i >> 5] | (1L << (i & 0x1f));
            }
        }
        this.bits = newBits;
    }
    /**
	* Returns a string representation of the bit array.
	*
	* @return string
	*/
    public override string toString()
    {
		import std.array;
        Appender!string result = appender!string();
        for (auto i = 0; i < this.size; i++) {
            if ((i & 0x07) == 0) {
                result.put(" ");
            }
            result.put(this.get(i) ? 'X' : '.'); 
        }
        return result.data;
    }
}