module ithox.qrcode.common.reedsolomoncodec;
import std.conv;

/**
* Reed-Solomon codec for 8-bit characters.
*
* Based on libfec by Phil Karn, KA9Q.
*/
class ReedSolomonCodec
{

	protected int symbolSize,blockSize,padding, firstRoot, primitive, numRoots, iPrimitive;

	protected int[] alphaTo, _indexOf, generatorPoly;
	/**
	* Creates a new reed solomon instance.
	*
	* @param  integer symbolSize
	* @param  integer gfPoly
	* @param  integer firstRoot
	* @param  integer primitive
	* @param  integer numRoots
	* @param  integer padding
	* @throws Exception\InvalidArgumentException
	* @throws Exception\RuntimeException
	*/
    public  this(int symbolSize_, int gfPoly_, int firstRoot_, int primitive_, int numRoots_, int padding_)
    {
        if (symbolSize_ < 0 || symbolSize_ > 8) {
            throw new Exception("Symbol size must be between 0 and 8");
        }
        if (firstRoot_ < 0 || firstRoot_ >= (1 << symbolSize_)) {
            throw new Exception("First root must be between 0 and " ~ to!string((1 << symbolSize_)));
        }
        if (numRoots_ < 0 || numRoots_ >= (1 << symbolSize_)) {
            throw new Exception("Num roots must be between 0 and " ~ to!string((1 << symbolSize_)));
        }
        if (padding_ < 0 || padding_ >= ((1 << symbolSize_) - 1 - numRoots_)) {
            throw new Exception("Padding must be between 0 and " ~ to!string(((1 << symbolSize_) - 1 - numRoots_)));
        }
        this.symbolSize = symbolSize_;
        this.blockSize  = (1 << symbolSize_) - 1;
        this.padding    = padding_;
        this.alphaTo    = new int[this.blockSize + 1];
		this.alphaTo[] = 0;
        this._indexOf    = new int[this.blockSize + 1];
		this._indexOf[] = 0;

        // Generate galous field lookup table
        this._indexOf[0]                = this.blockSize;
        this.alphaTo[this.blockSize] = 0;
        auto sr = 1;
        for (auto i = 0; i < this.blockSize; i++) {
            this._indexOf[sr] = i;
            this.alphaTo[i]  = sr;
            sr <<= 1;
            if (sr & (1 << symbolSize_)) {
                sr ^= gfPoly_;
            }
            sr &= this.blockSize;
        }
        if (sr != 1) {
            throw new Exception("Field generator polynomial is not primitive");
        }
        // Form RS code generator polynomial from its roots
        this.generatorPoly = new int[numRoots_ + 1 ];
		this.generatorPoly[] = 0;

        this.firstRoot     = firstRoot_;
        this.primitive     = primitive_;
        this.numRoots      = numRoots_;
        // Find prim-th root of 1, used in decoding
		auto _iPrimitive = 1;
        for ( _iPrimitive = 1; (_iPrimitive % primitive) != 0; _iPrimitive += this.blockSize)
		{}
        this.iPrimitive = to!int(iPrimitive / primitive);
        this.generatorPoly[0] = 1;
        for (auto i = 0, root = firstRoot * primitive_; i < numRoots_; i++, root += primitive_) {
            this.generatorPoly[i + 1] = 1;
			int j = 0;
            for (j =i; j > 0; j--) {
                if (this.generatorPoly[j] != 0) {
                    this.generatorPoly[j] = this.generatorPoly[j - 1] ^ this.alphaTo[this.modNn(this._indexOf[this.generatorPoly[j]] + root)];
                } else {
                    this.generatorPoly[j] = this.generatorPoly[j - 1];
                }
            }
            this.generatorPoly[j] = this.alphaTo[this.modNn(this._indexOf[this.generatorPoly[0]] + root)];
        }
        // Convert generator poly to index form for quicker encoding
        for (auto i = 0; i <= numRoots_; i++) {
            this.generatorPoly[i] = this._indexOf[this.generatorPoly[i]];
        }
    }

	/**
	* Computes x % GF_SIZE, where GF_SIZE is 2**GF_BITS - 1, without a slow
	* divide.
	*
	* @param  itneger x
	* @return integer
	*/
    protected int modNn(int x)
    {
        while (x >= this.blockSize) {
            x -= this.blockSize;
            x  = (x >> this.symbolSize) + (x & this.blockSize);
        }
        return x;
    }

	/**
	* Encodes data and writes result back into parity array.
	*
	* @param  SplFixedArray data
	* @param  SplFixedArray parity
	* @return void
	*/
    public void encode(int[] data, int[] parity)
    {
        for (auto i = 0; i < this.numRoots; i++) {
            parity[i] = 0;
        }
        auto iterations = this.blockSize - this.numRoots - this.padding;
        for (auto i = 0; i < iterations; i++) {
            auto feedback = this._indexOf[data[i] ^ parity[0]];
            if (feedback != this.blockSize) {
                // Feedback term is non-zero
                feedback = this.modNn(this.blockSize - this.generatorPoly[this.numRoots] + feedback);
                for (auto j = 1; j < this.numRoots; j++) {
                    parity[j] = parity[j] ^ this.alphaTo[this.modNn(feedback + this.generatorPoly[this.numRoots - j])];
                }
            }
            for (auto j = 0; j < this.numRoots - 1; j++) {
                parity[j] = parity[j + 1];
            }
            if (feedback != this.blockSize) {
                parity[this.numRoots - 1] = this.alphaTo[this.modNn(feedback + this.generatorPoly[0])];
            } else {
                parity[this.numRoots - 1] = 0;
            }
        }
    }

	
}