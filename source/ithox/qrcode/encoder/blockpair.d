module ithox.qrcode.encoder.blockpair;

/**
* Block pair.
*/
class BlockPair
{
    /**
	* Data bytes in the block.
	*
	* @var SplFixedArray
	*/
    protected int[] dataBytes;
    /**
	* Error correction bytes in the block.
	*
	* @var SplFixedArray
	*/
    protected int[] errorCorrectionBytes;
    /**
	* Creates a new block pair.
	*
	* @param SplFixedArray data
	* @param SplFixedArray errorCorrection
	*/
    public this(int[] data, int[] errorCorrection)
    {
        this.dataBytes = data;
        this.errorCorrectionBytes = errorCorrection;
    }
    /**
	* Gets the data bytes.
	*
	* @return SplFixedArray
	*/
    public int[] getDataBytes()
    {
        return this.dataBytes;
    }
    /**
	* Gets the error correction bytes.
	*
	* @return SplFixedArray
	*/
    public int[] getErrorCorrectionBytes()
    {
        return this.errorCorrectionBytes;
    }
}
