module qrcode.utils;

// converter datatype
alias void* iconv_t;

// allocate a converter between charsets fromcode and tocode
extern (C) iconv_t iconv_open(char* tocode, char* fromcode);

// convert inbuf to outbuf and set inbytesleft to unused input and
// outbuf to unused output and return number of non-reversable
// conversions or -1 on error.
extern (C) size_t iconv(iconv_t cd, void** inbuf, size_t* inbytesleft,
        void** outbuf, size_t* outbytesleft);

// close converter
extern (C) int iconv_close(iconv_t cd);

///编码转换
string iconv_charset(string inbuf, string tocode, string fromcode)
{
    return "";
}
/// '1' to 1
int charToInt(char c)
{
    c -= '0';
    return c <= 9 ? c : -1;
}
