module ithox.qrcode.utils;

// converter datatype
alias void *iconv_t;

// allocate a converter between charsets fromcode and tocode
extern (C) iconv_t iconv_open (char *tocode, char *fromcode);

// convert inbuf to outbuf and set inbytesleft to unused input and
// outbuf to unused output and return number of non-reversable
// conversions or -1 on error.
extern (C) size_t iconv (iconv_t cd, void **inbuf,
                         size_t *inbytesleft,
                         void **outbuf,
                         size_t *outbytesleft);

// close converter
extern (C) int iconv_close (iconv_t cd);

///编码转换
string iconv_charset(string inbuf, string tocode, string fromcode)
{
	return "";
}

unittest{
	import std.stdio;

	int main() {
		iconv_t cd = iconv_open("UTF-16LE","UTF-8");

		char[] str = "this is a test";
		void* inp = str;
		size_t in_len = str.length;

		wchar[256] outstr; // some giant buffer
		void* outp=outstr;
		size_t out_len = outstr.length;

		size_t res = iconv(cd,&inp,&in_len,&outp,&out_len);

		writefln(outstr[0..str.length]);
		iconv_close(cd);
		return 0;
	}

}
