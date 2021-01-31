////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// WindowTests
////////////////////////////////////////////////////////////////////////////////////////////////////

// Tests native windows and 2D render target support.
class WindowTests implements IUnitTest
{
	// for all tests
	NativeWindow    window = null;
	IRenderTarget2D rt     = null;

	void run()
	{
		if(System:isGraphicalOS() == false)
		{
			//Log:log(String<u8>("WindowTests - Cannot run tests, OS is not graphical or using headless mode."));
			return; // can't test
		}

		window = NativeWindow:createWindow(false, ColorFormat:RGBA8, Rectangle2D<i32>(0, 0, 100, 100), false, true);
		window.resize(400, 400);
		window.setTitle("Pronto-Core-Tests WindowTests");
		window.setVisible(true);

		rt = window.getRenderTarget();
		if(rt == null)
		{
			test(false);
			return;
		}

		testRendering();

		window.setVisible(false);
		window.destroy();
	}

	void testRendering()
	{
		u32 rtWidth  = rt.getWidth();
		u32 rtHeight = rt.getHeight();

		test(rtWidth != 0 && rtHeight != 0);

		ImageRGBA img = rt.getImageRGBA(); // this will be the size of the window area
		test(img != null);

		img.clear(ColorRGBA(150, 200, 250, 255));

		rt.beginFrame();
		rt.drawImage(img, 0, 0);
		rt.endFrame();

		ImageRGBA img2 = rt.getImageRGBA();
		test(img2 != null);

		ByteArray pngData = img2.encodePNG();
		//FileSystem:writeFile(String<u8>("testRendering_screenshot.png"), pngData);

		/*
		f64 endTime = System:getTime() + 10000;
		while(System:getTime() < endTime)
		{
			breath(1);
		}*/
	}
}