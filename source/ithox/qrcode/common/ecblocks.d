module ithox.qrcode.common.ecblocks;

struct EcBlock{
	int count;
	int dataCodewords;
}

class EcBlocks
{

	/**
	* Number of EC codewords per block.
	*
	* @var integer
	*/
    protected int ecCodewordsPerBlock;
    /**
	* List of EC blocks.
	*
	* @var SplFixedArray
	*/
    protected EcBlock[] ecBlocks;
    /**
	* Creates a new EC blocks instance.
	*
	* @param integer      $ecCodewordsPerBlock
	* @param EcBlock      $ecb1
	* @param EcBlock|null $ecb2
	*/
    this(int ecCodewordsPerBlock, EcBlock* ecb1, EcBlock* ecb2 )
    {
        this.ecCodewordsPerBlock = ecCodewordsPerBlock;

		this.ecBlocks = new EcBlock[2];
		this.ecBlocks[0] = *ecb1;
        this.ecBlocks[1] = *ecb2;
}

	this(int ecCodewordsPerBlock, EcBlock* ecb1 )
    {
        this.ecCodewordsPerBlock = ecCodewordsPerBlock;
		this.ecBlocks = new EcBlock[1];
		this.ecBlocks[0] = *ecb1;
		
    }
    /**
	* Gets the number of EC codewords per block.
	*
	* @return integer
	*/
    public int getEcCodewordsPerBlock()
    {
        return this.ecCodewordsPerBlock;
    }
    /**
	* Gets the total number of EC block appearances.
	*
	* @return integer
	*/
    public int getNumBlocks()
    {
        auto total = 0;
        foreach (ecBlock;this.ecBlocks ) {
            total += ecBlock.count;
        }
        return total;
    }
    /**
	* Gets the total count of EC codewords.
	*
	* @return integer
	*/
    public int getTotalEcCodewords()
    {
        return this.ecCodewordsPerBlock * this.getNumBlocks();
    }
    /**
	* Gets the EC blocks included in this collection.
	*
	* @return SplFixedArray
	*/
    public EcBlock[] getEcBlocks()
    {
        return ecBlocks;
    }
}
