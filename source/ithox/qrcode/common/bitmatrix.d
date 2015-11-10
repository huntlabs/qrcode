module ithox.qrcode.common.bitmatrix;

import ithox.qrcode.common.bitutils;
import ithox.qrcode.common.bitarray;
/**
* Bit matrix.
*
* Represents a 2D matrix of bits. In function arguments below, and throughout
* the common module, x is the column position, and y is the row position. The
* ordering is always x, y. The origin is at the top-left.
*/
class BitMatrix
{

	private{
		int width,height,rowSize;
		BitArrayBitType[] bits;
	}

	public @property int Width(){ return this.width;}
	public @property int Height(){ return this.height;}
	public @property int RowSize(){ return this.rowSize;}
	public @property BitArrayBitType[] Bits(){ return this.bits;}
	
	this(int width)
	{
		this(width, width);
	}
	this(int width, int height)
	{
		if (width < 1 || height < 1) {
            throw new Exception("Both dimensions must be greater than zero");
        }
        this.width   = width;
        this.height  = height;
        this.rowSize = (width + 31) >> 5;
        this.bits    = new BitArrayBitType[rowSize * height];
	}

	/**
	* Gets the requested bit, where true means black.
	*
	* @param  integer $x
	* @param  integer $y
	* @return boolean
	*/
    public bool get(int x, int y)
    {
        auto offset = y * this.rowSize + (x >> 5);
        return (BitUtils.unsignedRightShift(this.bits[offset], (x & 0x1f)) & 1) != 0;
    }
    /**
	* Sets the given bit to true.
	*
	* @param  integer $x
	* @param  integer $y
	* @return void
	*/
    public void set(int x, int y)
    {
        auto offset = y * this.rowSize + (x >> 5);
        this.bits[offset] = this.bits[offset] | (1 << (x & 0x1f));
    }

	/**
	* Flips the given bit.
	*
	* @param  integer x
	* @param  integer y
	* @return void
	*/
    public void flip(int x, int y)
    {
        auto offset = y * this.rowSize + (x >> 5);
        this.bits[offset] = this.bits[offset] ^ (1 << (x & 0x1f));
    }
    /**
	* Clears all bits (set to false).
	*
	* @return void
	*/
    public void clear()
    {
        this.bits[] = 0;
    }
	/**
	* Sets a square region of the bit matrix to true.
	*
	* @param  integer left
	* @param  integer top
	* @param  integer width
	* @param  integer height
	* @return void
	*/
    public void setRegion(int left, int top, int width, int height)
    {
        if (top < 0 || left < 0) {
            throw new Exception("Left and top must be non-negative");
        }
        if (height < 1 || width < 1) {
            throw new Exception("Width and height must be at least 1");
        }
        auto right  = left + width;
        auto bottom = top + height;
        if (bottom > this.height || right > this.width) {
            throw new Exception("The region must fit inside the matrix");
        }
        for (int y = top; y < bottom; y++) {
            auto offset = y * this.rowSize;
            for (auto x = left; x < right; x++) {
                auto index = offset + (x >> 5);
                this.bits[index] = this.bits[index] | (1 << (x & 0x1f));
            }
        }
    }
    /**
	* A fast method to retrieve one row of data from the matrix as a BitArray.
	*
	* @param  integer  y
	* @param  BitArray row
	* @return BitArray
	*/
    public BitArray getRow(int y, BitArray row)
    {
        if (row is null || row.getSize() < this.width) {
            row = new BitArray(this.width);
        }
        auto offset = y * this.rowSize;
        for (auto x = 0; x < this.rowSize; x++) {
            row.setBulk(x << 5, this.bits[offset + x]);
        }
        return row;
    }
	public BitArray getRow(int y)
    {
         return getRow(y, new BitArray(this.width));
    }

	 /**
     * Sets a row of data from a BitArray.
     *
     * @param  integer  $y
     * @param  BitArray $row
     * @return void
     */
    public void setRow(int y, BitArray row)
    {
        auto bits = row.getBitArray();
        for (auto i = 0; i < this.rowSize; i++) {
            this.bits[y * this.rowSize + i] = bits[i];
        }
    }

	/**
	* This is useful in detecting the enclosing rectangle of a 'pure' barcode.
	*
	* @return SplFixedArray
	*/
    public int[] getEnclosingRectangle()
    {
        auto left   = this.width;
        auto top    = this.height;
        auto right  = -1;
        auto bottom = -1;
        for (auto y = 0; y < this.height; y++) {
            for (auto x32 = 0; x32 < this.rowSize; x32++) {
                auto _bits = this.bits[y * this.rowSize + x32];
                if (_bits != 0) {
                    if (y < top) {
                        top = y;
                    }
                    if (y > bottom) {
                        bottom = y;
                    }
                    if (x32 * 32 < left) {
                        auto bit = 0;
                        while ((_bits << (31 - bit)) == 0) {
                            bit++;
                        }
                        if ((x32 * 32 + bit) < left) {
                            left = x32 * 32 + bit;
                        }
                    }
                }
                if (x32 * 32 + 31 > right) {
                    auto bit = 31;
                    while (BitUtils.unsignedRightShift(_bits, bit) == 0) {
                        bit--;
                    }
                    if ((x32 * 32 + bit) > right) {
                        right = x32 * 32 + bit;
                    }
                }
            }
        }
        width  = right - left;
        height = bottom - top;
        if (width < 0 || height < 0) {
            return null;
        }
        return [left, top, width, height];
    }
    /**
	* Gets the most top left set bit.
	*
	* This is useful in detecting a corner of a 'pure' barcode.
	*
	* @return SplFixedArray
	*/
    public int[] getTopLeftOnBit()
    {
        auto bitsOffset = 0;
        while (bitsOffset < this.bits.length && this.bits[bitsOffset] == 0) {
            bitsOffset++;
        }
        if (bitsOffset == this.bits.length) {
            return null;
        }
		import std.conv;
        auto x = to!int(bitsOffset / this.rowSize);
        auto y = (bitsOffset % this.rowSize) << 5;
        auto _bits = this.bits[bitsOffset];
        auto bit  = 0;
        while ((_bits << (31 - bit)) == 0) {
            bit++;
        }
        x += bit;
        return [x, y];
    }
    /**
	* Gets the most bottom right set bit.
	*
	* This is useful in detecting a corner of a 'pure' barcode.
	*
	* @return SplFixedArray
	*/
    public int[] getBottomRightOnBit()
    {
        auto bitsOffset = this.bits.length - 1;
        while (bitsOffset >= 0 && this.bits[bitsOffset] == 0) {
            bitsOffset--;
        }
        if (bitsOffset < 0) {
            return null;
        }
		import std.conv;
        int x = to!int(bitsOffset / this.rowSize);
        int y = to!int((bitsOffset % this.rowSize) << 5);
        auto _bits = this.bits[bitsOffset];
        auto bit  = 0;
        while (BitUtils.unsignedRightShift(_bits, bit) == 0) {
            bit--;
        }
        x += bit;
        return [x, y];
    }
    
}