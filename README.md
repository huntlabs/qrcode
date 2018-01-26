# dqrcode
qrcode powered by dlang

## Additional description
- it  support svg png  

## TODO
- change folder (Done)
- remove app.d (Done)
- add example (Done)
- add test case

## compile use ldc2

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
		import qrcode;
	
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
