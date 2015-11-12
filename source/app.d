import std.stdio;

void main()
{
	//testQrCode();
	//testQrCodeEps();
	testQrCodePng();
}

void testQrCode()
{
	import ithox.qrcode.qrcode;

	AbstractRenderer plain = new Svg();
	plain.setWidth(250);
	plain.setHeight(250);
	//plain.setRoundDimensions(true);
	//plain.setBackgroundColor(new Rgb(255,0,255));
	//plain.setForegroundColor(new Rgb(0,0,255));
	//plain.setMargin(0);

	QrCodeWriter wr = new QrCodeWriter(plain);
	//auto xx = wr.writeString("donglei donglei", "UTF-8", ErrorCorrectionLevel.H);
	//writeln(xx);
	wr.writeFile("Hello World Powered By D", "hello-world.svg", "UTF-8", ErrorCorrectionLevel.H);
}

void testQrCodeEps()
{
	import ithox.qrcode.qrcode;

	AbstractRenderer plain = new Eps();
	plain.setWidth(250);
	plain.setHeight(250);
	plain.setRoundDimensions(true);
	plain.setBackgroundColor(new Rgb(255,0,255));
	plain.setForegroundColor(new Rgb(0,0,255));
	plain.setMargin(0);

	QrCodeWriter wr = new QrCodeWriter(plain);
	//auto xx = wr.writeString("donglei donglei", "UTF-8", ErrorCorrectionLevel.H);
	//writeln(xx);
	wr.writeFile("Hello World Powered By D", "hello-world.eps", "UTF-8", ErrorCorrectionLevel.H);
}

void testQrCodePng()
{
	import ithox.qrcode.qrcode;
	Png png = new Png();

	png.setWidth(250);
	png.setHeight(250);
	//png.setBackgroundColor(new Rgb(255,0,255));
	//png.setForegroundColor(new Rgb(0,0,255));
	png.setMargin(3);
	png.setMergeImage("./favicon.ico");
	QrCodeWriter qwr = new QrCodeWriter(png);
	qwr.writeFile("Hello World Powered By D", "hello-world.png", "UTF-8",ErrorCorrectionLevel.H);
}