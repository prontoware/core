////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class ColorRGBATests implements IUnitTest
{
	void run()
	{
		ColorRGBA clrA = ColorRGBA(0, 1, 2, 3);
		test(clrA.rgba[0] == 0);
		test(clrA.rgba[1] == 1);
		test(clrA.rgba[2] == 2);
		test(clrA.rgba[3] == 3);

		ColorRGBA clrB = ColorRGBA(0, 1, 2, 3);
		test(clrA.equals(clrB) == true);
	
		clrB.set(255, 255, 255, 255);
		test(clrA.equals(clrB) == false);

		ColorRGBA clrC = clrB.clone();
		test(clrC.equals(clrB) == true);

		test(clrC[0] == 255);

		clrC.rgba[2] = 100;
		test(clrC[2] == 100);

		String<u8> clrHexStr = clrA.toHexString();
		test(clrHexStr.compare(String<u8>("00010203")) == true);

		clrHexStr.copy("0x3A0017FC"); // RRGGBBAA
		clrC.parseHexString(clrHexStr);
		test(clrC[0] == 0x3A && clrC[1] == 0x00 && clrC[2] == 0x17 && clrC[3] == 0xFC);

		u32 clrInt = clrC.getU32(); // pack bits
		test(clrInt == 0xFC17003A); // AABBGGRR format because little endian

		clrInt = 0xABCDEF00; // AABBGGRR format because little endian
		clrC.set(clrInt); // unpack bits
		test(clrC.getU32() == 0xABCDEF00); // pack bits
	}
}

class ColorRGBAfTests implements IUnitTest
{
	void run()
	{
		ColorRGBAf clrA = ColorRGBAf(0.0f, 1.0f, 0.2f, 0.3f);
		test(Math:compare(clrA.rgba[0], 0.0f) == true);
		test(Math:compare(clrA.rgba[1], 1.0f) == true);
		test(Math:compare(clrA.rgba[2], 0.2f) == true);
		test(Math:compare(clrA.rgba[3], 0.3f) == true);

		ColorRGBA clrAInt = ColorRGBA(clrA);
		test(clrAInt[0] == 0);
		test(clrAInt[1] == 255);
	}
}

class ImageRGBAInitTests implements IUnitTest
{
	void run()
	{
		ImageRGBA imgA = ImageRGBA(32, 16);
		test(imgA.width == 32);
		test(imgA.height == 16);

		ColorRGBA clrA = ColorRGBA(255, 255, 255, 255);
		imgA.clear(clrA);
		test(imgA.getPixel(0, 0) == 0xFFFFFFFF);
		test(imgA.getPixel(1, 1) == 0xFFFFFFFF); // second row

		ImageRGBA imgB = imgA.clone();
		test(imgB.getPixel(0, 0) == 0xFFFFFFFF);
		test(imgB.getPixel(1, 1) == 0xFFFFFFFF); // second row
	}
}

class ImageRGBAShapesTests implements IUnitTest
{
	void run()
	{
		ColorRGBA clrWhite = ColorRGBA(255, 255, 255, 255);
		ColorRGBA clrRed   = ColorRGBA(255, 0, 0, 255);

		ImageRGBA imgA = ImageRGBA(32, 16, clrWhite);
		test(imgA.width == 32);
		test(imgA.height == 16);
		test(imgA.getPixel(1, 0) == clrWhite.getU32());

		// draw line
		imgA.clear(clrWhite);
		imgA.drawLine(1, 1, 3, 3, 1, clrRed);
		test(imgA.getPixel(1, 1) == clrRed.getU32());

		// draw line 2 wide
		imgA.clear(clrWhite);
		imgA.drawLine(1, 1, 9, 9, 3, clrRed);
		test(imgA.getPixel(1, 1) == clrRed.getU32());

		//FileSystem:writeFile(String<u8>("ImageRGBA_drawLine_4.png"), imgA.encodePNG());

		// draw rect
		imgA.clear(clrWhite);
		imgA.drawRect(0, 0, 3, 3, 1, clrRed);
		test(imgA.getPixel(0, 1) == clrRed.getU32());

		// fill rect
		imgA.clear(clrWhite);
		imgA.fillRect(1, 1, 2, 2, clrRed);
		test(imgA.getPixel(0, 0) == clrWhite.getU32()); // top row still white
		test(imgA.getPixel(0, 1) == clrWhite.getU32()); // first column still white
		test(imgA.getPixel(1, 1) == clrRed.getU32()); // should be red inside rect
		test(imgA.getPixel(2, 2) == clrRed.getU32()); // should be red inside rect

		// draw polygon
		i32[] polyPts = i32[](6);
		polyPts[0] = 0;
		polyPts[1] = 0;
		polyPts[2] = 7;
		polyPts[3] = 0;
		polyPts[4] = 7;
		polyPts[5] = 7;
		Polygon2D<i32> poly(polyPts);

		imgA = ImageRGBA(64, 64, clrWhite);
		imgA.clear(clrWhite);
		imgA.drawPolygon(poly, 1, clrRed);
		test(imgA.getPixel(1, 0) == clrRed.getU32());

		//ByteArray pngPolyDrawFile = imgA.encodePNG();
		//FileSystem:writeFile(String<u8>("polyDraw.png"), pngPolyDrawFile);

		// fill polygon
		imgA.clear(clrWhite);
		imgA.fillPolygon(poly, clrRed);

		//ByteArray pngPolyFillFile = imgA.encodePNG();
		//FileSystem:writeFile(String<u8>("polyfill.png"), pngPolyFillFile);

		test(imgA.getPixel(1, 0) == clrRed.getU32());

		// lines
		imgA = ImageRGBA(128, 128, clrWhite);

		Line2D<i32> lineA(0, 0, 100, 100);
		imgA.drawLine(lineA, 1, ColorRGBA(0,0,0,255));

		Line2D<i32> lineB(10, 0, 10, 100);
		imgA.drawLine(lineB, 4, ColorRGBA(255,0,0,255));

		Line2D<i32> lineC(100, 0, 0, 100);
		imgA.drawLine(lineC, 4, ColorRGBA(0,255,0,255));

		Line2D<i32> lineD(0, 50, 100, 50);
		imgA.drawLine(lineD, 4, ColorRGBA(0,0,255,255));

		//FileSystem:writeFile(String<u8>("ImageRGBA_drawLine.png"), imgA.encodePNG());

		test(imgA.testPixel(0, 0, 0, 0, 0, 255) == true);
		test(imgA.testPixel(2, 2, 0, 0, 0, 255) == true);
		test(imgA.testPixel(99, 99, 0, 0, 0, 255) == true);
		test(imgA.testPixel(10, 20, 255, 0, 0, 255) == true);
		test(imgA.testPixel(11, 20, 255, 0, 0, 255) == true);
		test(imgA.testPixel(0, 50, 0, 0, 255, 255) == true);
	}
}

class ImageRGBAResizeTests implements IUnitTest
{
	void run()
	{
		ImageRGBA imgA = ImageRGBA(32, 32, ColorRGBA(255, 0, 0, 255));
		ImageRGBA imgB = imgA.resizeFast(16, 16);
		test(imgB != null);
		test(imgB.width == 16);
		test(imgB.height == 16);
		test(imgB.getPixel(0, 0) == 0xFF0000FF);

		imgA = ImageRGBA(32, 32, ColorRGBA(255, 0, 255, 255));
		imgB = imgA.resizeHQ(16, 16);
		test(imgB != null);
		test(imgB.width == 16);
		test(imgB.height == 16);
		test(imgB.getPixel(0, 0) == 0xFFFF00FF);
	}
}

class ImageRGBAIOTests implements IUnitTest
{
	void run()
	{
		// PNG encode/decode
		ImageRGBA imgA = ImageRGBA(2, 2, ColorRGBA(0, 255, 0, 255));
		ByteArray pngFile = imgA.encodePNG();
		test(pngFile != null);
		test(pngFile.size() > 4); // too small
		test(pngFile.size() < ((imgA.width * imgA.height * 4) + 1024)); // too big
		test(imgA.pixels.length() == (imgA.width * imgA.height));

		ImageRGBA imgB = ImageRGBA:decodePNG(pngFile);
		test(imgB != null);
		test(imgB.width == imgA.width);
		test(imgB.height == imgA.height);
		test(imgB.pixels != null);
		test(imgB.pixels.length() == (imgB.width * imgB.height));
		test(imgB.equals(imgA) == true);
		
		//FileSystem:writeFile(String<u8>("testA.png"), pngFile);

		// JPEG encode/decode
		ImageRGBA imgC = ImageRGBA(64, 64, ColorRGBA(0, 0, 255, 255));
		ByteArray jpegFile = imgC.encodeJPEG(100);
		test(jpegFile != null);
		test(jpegFile.size() > 4); // too small
		test(jpegFile.size() < ((imgC.width * imgC.height * 4) + 1024)); // too big

		//FileSystem:writeFile(String<u8>("testC.jpg"), jpegFile);

		ImageRGBA imgD = ImageRGBA:decodeJPEG(jpegFile);
		test(imgD != null);
		test(imgD.width == imgC.width);
		test(imgD.height == imgC.height);
		test(imgD.pixels != null);
		// Can't check for perfect because JPEG is lossy, so even a solid color can be
		// 1 or 2 bits off (and it is in this case, was manually verified once)
	}
}

class ImageRGBADrawImgTests implements IUnitTest
{
	void run()
	{
		ImageRGBA imgA = ImageRGBA(32, 32, ColorRGBA(255, 0, 0, 255));
		ImageRGBA imgB = ImageRGBA(64, 64, ColorRGBA(0, 255, 0, 255));

		imgB.drawImage(imgA, -2, -2); // tests clipping

		//FileSystem:writeFile("testImageRGBADrawImg.png", imgB.encodePNG());

		test(imgB.testPixel(0, 0, 255, 0, 0, 255) == true);
		test(imgB.testPixel(29, 29, 255, 0, 0, 255) == true);
		test(imgB.testPixel(31, 31, 0, 255, 0, 255) == true);
	}
}

class UniversalImageTests implements IUnitTest
{
	void run()
	{
		UniversalImage imgA = UniversalImage(2, 2, ColorFormat:RGBA8);
		test(imgA.width == 2);
		test(imgA.height == 2);
		test(imgA.format == ColorFormat:RGBA8);
		test(imgA.pixels != null);
		test(imgA.pixels.length() == 16); // 2 * 2 * 4

		UniversalImage imgB = imgA.convertToFormat(ColorFormat:RGBA_F32);
		test(imgB != null);
		test(imgB.width == 2);
		test(imgB.height == 2);
		test(imgB.format == ColorFormat:RGBA_F32);
		test(imgB.pixels != null);
		test(imgB.pixels.length() == 64); // 2 * 2 * 16
	}
}

class UniversalImageConversionTests implements IUnitTest
{
	void run()
	{	
		ImageRGBA imgA = ImageRGBA(2, 2, ColorRGBA(0, 0, 255, 255));

		UniversalImage imgB = imgA.createUniversalImage();
		test(imgB != null);
		test(imgB.width == 2);
		test(imgB.height == 2);
		test(imgB.format == ColorFormat:RGBA8);
		test(imgB.pixels != null);
		test(imgB.pixels.length() == 16); // 2 * 2 * 4

		UniversalImage imgC = imgB.convertToFormat(ColorFormat:RGBA_F32);
		test(imgC != null);
		test(imgC.width == 2);
		test(imgC.height == 2);
		test(imgC.format == ColorFormat:RGBA_F32);
		test(imgC.pixels != null);
		test(imgC.pixels.length() == 64); // 2 * 2 * 16
		test(Math:compare(ByteIO:readF32(imgC.pixels, 0), 0.0f) == true); // red channel of pixel 0
		test(Math:compare(ByteIO:readF32(imgC.pixels, 4), 0.0f) == true); // green channel of pixel 0
		test(Math:compare(ByteIO:readF32(imgC.pixels, 8), 1.0f) == true); // blue channel of pixel 0
		test(Math:compare(ByteIO:readF32(imgC.pixels, 12), 1.0f) == true); // alpha channel of pixel 0
		
		// Photo conversion test
		String<u8> testPhotoFilepath("photo.png");
		if(FileSystem:getFileInfo(testPhotoFilepath).exists == true)
		{
			ByteArray photoFileBytes = FileSystem:readFile(testPhotoFilepath);
			if(photoFileBytes != null)
			{
				test(photoFileBytes != null);
				ImageRGBA photoRGBA8 = ImageRGBA:decodePNG(photoFileBytes);
				test(photoRGBA8 != null);
				test(photoRGBA8.width == 128);
				test(photoRGBA8.height == 128);
				
				UniversalImage imgUniRGBA8 = imgA.createUniversalImage();
				test(imgUniRGBA8 != null);
				test(imgUniRGBA8.width == photoRGBA8.width);
				test(imgUniRGBA8.height == photoRGBA8.height);
				test(imgUniRGBA8.pixels != null);
				test(imgUniRGBA8.format == ColorFormat:RGBA8);
				test(imgUniRGBA8.pixels.length() == (photoRGBA8.width * photoRGBA8.height * 4));

				UniversalImage imgUniRGBA4 = imgUniRGBA8.convertToFormat(ColorFormat:RGBA4); // lost color info (should see gradient tones)
				test(imgUniRGBA4 != null);

				UniversalImage imgUniRGBA4_as_8 = imgUniRGBA4.convertToFormat(ColorFormat:RGBA8); // lost color info, but converted back to RGBA8 for easy comparison
				test(imgUniRGBA4_as_8 != null);

				// pixels won't be the same (well in some cases they could be) but will be within ~1/16th because RGBA4 has 16 shades and RGBA8 has 256 shades
				for(u64 y=0; y<imgUniRGBA4_as_8.height; y++)
				{
					for(u64 x=0; x<imgUniRGBA4_as_8.width; x++)
					{
						// TODO
					}
				}
			}
		}
	}
}

class FontTests implements IUnitTest
{
	void run()
	{
		// get all available fonts
		IList<FontDesc> allFonts = Font:getAvailableFonts();
		test(allFonts != null);
		test(allFonts.size() > 0);

		String<u8> allFontsStr();
		for(u32 f=0; f<allFonts.size(); f++)
			allFontsStr += allFonts[f].name + "\n";

		//if(FileSystem:writeTextFile(String<u8>("fonts.txt"), allFontsStr) == false)
		//	return 1;

		// make font glyph image map
		Font font("Arial", 16, true, false, false);

		test(font.glyphMap != null);

		test(font.fontImg != null);

		Font defFontSansSerif = Font:createDefault(16);
		test(defFontSansSerif != null);

		Font defFontSerif = Font:createDefaultSerif(16);
		test(defFontSerif != null);

		Font defFontFixed = Font:createDefaultFixed(16);
		test(defFontFixed != null);

		//FileSystem:writeFile(String<u8>("default_font_sans.png"),  defFontSansSerif.fontImg.encodePNG());
		//FileSystem:writeFile(String<u8>("default_font_serif.png"), defFontSerif.fontImg.encodePNG());
		//FileSystem:writeFile(String<u8>("default_font_fixed.png"), defFontFixed.fontImg.encodePNG());
	}
}

class ImageRGBADrawTextTests implements IUnitTest
{
	void run()
	{
		// make font glyph image map
		Font font("", 32, true, true, false);
		test(font.glyphMap != null);
		test(font.fontImg != null);

		ImageRGBA img(256, 256, ColorRGBA(0, 0, 0, 255));
		img.drawText(font, 0, 0, "This is two lines\nof text.", ColorRGBA(0, 0, 255, 255));

		//if(FileSystem:writeFile(String<u8>("testImageRGBAText.png"), img.encodePNG()) == false)
	}
}

class FPSCounterTests implements IUnitTest
{
	void run()
	{
		FPSCounter fpsCounter(2); // 2 seconds

		test(fpsCounter.getAvgFPS() <= 0.000001);

		fpsCounter.frameRendered();

		test(fpsCounter.getAvgFPS() < 0.000001); // still zero because first frame doesn't really count

		fpsCounter.frameRendered();
		Thread:sleep(100);

		test(fpsCounter.getAvgFPS() >= 1.0); // at least 1 FPS 

		for(u64 f=0; f<99; f++)
		{
			fpsCounter.frameRendered();
			Thread:sleep(10);
		}
		
		test(fpsCounter.getAvgFPS() >= 25.0); // around 100 FPS roughly, but the first frame etc. influence to less
		test(fpsCounter.getAvgFPS() < 250.0); // too much obviously

		// add a really bad frame
		Thread:sleep(500);
		fpsCounter.frameRendered();

		Thread:sleep(500);
		fpsCounter.frameRendered();

		Thread:sleep(500);
		fpsCounter.frameRendered(); // using up time for reset()

		// should have rolled over
		test(fpsCounter.prevFrameTimes.size() != 0);

		// thus 1 % worst should be like < 5 FPS now
		test(fpsCounter.getWorst1PercentAvgFPS() <= 10.0);
		test(fpsCounter.getWorst1PercentAvgFPS() >= 1.0); // um, too low
	}
}