import std.stdio;

void main()
{
	writeln("Edit source/app.d to start your project.");
	import std.format;
	import ithox.qrcode.common.bitutils;
	writeln(format("%032b", 2), "---", BitUtils.numberOfTrailingZeros(2));

	
	testQrCode();
}

void testQrCode()
{
	import ithox.qrcode.qrcode;

	AbstractRenderer plain = new Svg();
	plain.setWidth(500);
	plain.setHeight(500);
	plain.setRoundDimensions(false);
	//plain.setBackgroundColor(new Rgb(255,0,255));
	//plain.setForegroundColor(new Rgb(0,0,255));
	QrCodeWriter wr = new QrCodeWriter(plain);
	//auto xx = wr.writeString("donglei donglei", "UTF-8", ErrorCorrectionLevel.H);
	//writeln(xx);
	wr.writeFile("donglei", "1231.svg");
}