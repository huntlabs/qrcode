module qrcode.encoder.bytematrix;
/**
* Byte matrix.
* author donglei
*/
class ByteMatrix
{
    /**
	* Bytes in the matrix, represented as array.
	*
	* @var SplFixedArray
	*/
    protected int[][] _bytes;
    /**
	* Width of the matrix.
	*
	* @var integer
	*/
    protected int _width;
    /**
	* Height of the matrix.
	*
	* @var integer
	*/
    protected int _height;
    /**
	* Creates a new byte matrix.
	*
	* @param  integer $width
	* @param  integer $height
	*/
    public this(int width, int height)
    {
        this._height = height;
        this._width = width;
        //this._bytes[][] = new int[height][];
        for (auto i = 0; i < height; i++)
            this._bytes ~= new int[width];

    }

    public @property int width()
    {
        return _width;
    }

    public @property void width(int _m)
    {
        _width = _m;
    }

    public @property int height()
    {
        return _height;
    }

    public @property void height(int _m)
    {
        _height = _m;
    }

    /**
	* Gets the internal representation of the matrix.
	*
	* @return SplFixedArray
	*/
    public int[][] getArray()
    {
        return this._bytes;
    }
    /**
	* Gets the byte for a specific position.
	*
	* @param  integer $x
	* @param  integer $y
	* @return integer
	*/
    public int get(int x, int y)
    {
        return this._bytes[y][x];
    }
    /**
	* Sets the byte for a specific position.
	*
	* @param  integer $x
	* @param  integer $y
	* @param  integer $value
	* @return void
	*/
    public void set(int x, int y, int value)
    {
        this._bytes[y][x] = value;
    }
    /**
	* Clears the matrix with a specific value.
	*
	* @param  integer $value
	* @return void
	*/
    public void clear(int value)
    {
        for (auto i = 0; i < height; i++)
            this._bytes[i][] = value;
    }
    /**
	* Returns a string representation of the matrix.
	*
	* @return string
	*/
    public override string toString()
    {
        import std.array;

        Appender!string result = appender!string();
        for (int y = 0; y < this._height; y++)
        {
            for (int x = 0; x < this._width; x++)
            {
                switch (this._bytes[y][x])
                {
                case 0:
                    result.put(" 0");
                    break;
                case 1:
                    result.put(" 1");
                    break;
                default:
                    result.put("  ");
                    break;
                }
            }
            result.put("\n");
        }
        return result.data;
    }
}
