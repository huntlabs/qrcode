# dqrcode
qrcode powered by dlang

## Additional description
- it just support svg currently.
- png jpeg will supported in the next time

## ldc2编译

-----
	dub build --build=release --compiler=ldc2 -v -f 
-----

## example

-----

	void main()
	{
		testQrCode();
	}
	
	void testQrCode()
	{
		import ithox.qrcode.qrcode;
	
		AbstractRenderer plain = new Svg();
		plain.setWidth(250);
		plain.setHeight(250);
		plain.setRoundDimensions(true);
		plain.setBackgroundColor(new Rgb(255,0,255));
		plain.setForegroundColor(new Rgb(0,0,255));
		//plain.setMargin(0);
		QrCodeWriter wr = new QrCodeWriter(plain);
		//auto xx = wr.writeString("donglei donglei", "UTF-8", ErrorCorrectionLevel.H);
		//writeln(xx);
		wr.writeFile("Hello World Powered By D", "hello-world.svg", "UTF-8", ErrorCorrectionLevel.H);
	}

-----
