////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// FileSystem
////////////////////////////////////////////////////////////////////////////////////////////////////

// Access to the native OS file system.
//
// Note we are "extending" the built-in FileSystem class. This just means that the FileSystem class 
// basics are built-in to the language, but some helper functions live here.
class FileSystem
{
	// Special paths retrived with getSpecialDirectory(u8 dirID)
	const u8 DIRECTORY_WORKING       = 1;
	const u8 DIRECTORY_APPHOME       = 2;
	const u8 DIRECTORY_APPEXE        = 3;
	const u8 DIRECTORY_USERDESKTOP   = 4;
	const u8 DIRECTORY_USERDOCUMENTS = 5;
	const u8 DIRECTORY_USERMUSIC     = 6;
	const u8 DIRECTORY_USERPICTURES  = 7;
	const u8 DIRECTORY_USERMOVIES    = 8;
	const u8 DIRECTORY_USERDOWNLOADS = 9;

	// Get the current working path. Usually the directory where the Pronto application packages are, but varies with OS etc.
	//shared String<u8> getSpecialDirectory(u8 id);

	// Get path (directory) seperator.
	shared u8 getPathSeparator() { return Chars:FORWARD_SLASH; }

	// Get "xxx/yyy/" from "xxx/yyy/zzz/"
	shared String<u8> getParentDirectory(String<u8> filepath)
	{
		if(filepath.contains(Chars:BACK_SLASH) == false && filepath.contains(Chars:FORWARD_SLASH) == false)
			return String<u8>(""); // relative path, no parent

		i64 pathSeparator = 0;
		for(i64 i=filepath.numChars-2; i>=0; i--) //-2 because we don't care about first 
		{
			if(filepath.chars[i] == Chars:FORWARD_SLASH || filepath.chars[i] == Chars:BACK_SLASH)
			{
				pathSeparator = i;
				break;
			}
		}

		String<u8> parentPath = filepath.subString(0, pathSeparator);
		return parentPath;
	}

	// Get "img.png" from "xxx/yyy/zzz/img.png"
	shared String<u8> getFilename(String<u8> filepath, bool removeExtension)
	{
		i64 pathSeparator = 0;
		bool foundPathSeparator = false;
		for(i64 i=filepath.numChars-2; i >= 0; i--) //-2 because we don't care about first 
		{
			if(filepath.chars[i] == Chars:FORWARD_SLASH || filepath.chars[i] == Chars:BACK_SLASH)
			{
				foundPathSeparator = true;
				pathSeparator = i;
				break;
			}
		}

		String<u8> filename = String<u8>("");
		if(foundPathSeparator == true)
			filename = filepath.subString(pathSeparator+1, filepath.numChars-1);
		else
			filename = String<u8>(filepath); // no path

		if(removeExtension == true)
		{
			i64 periodIndex = filename.findPrev(Chars:PERIOD, filename.length()-1);
			if(periodIndex >= 0)
			{
				filename = filename.subString(0, periodIndex-1);
			}
		}

		// if this is a directory it might have a trailing "\"
		filename.removeAll(FileSystem:getPathSeparator());

		return filename;
	}

	// Get "png" from "img.png"
	shared String<u8> getFileExtension(String<u8> filepath)
	{
		String<u8> e = String<u8>("");
		if(filepath.length() < 1)
			return e;

		i64 extPeriodIndex = filepath.findPrev(Chars:PERIOD, filepath.length()-1);
		
		if(extPeriodIndex < 0)
			return e; //no extension

		if(extPeriodIndex >= filepath.length()-1)
			return e;

		e = filepath.subString(extPeriodIndex+1, filepath.length()-1);

		return e;
	}

	// Forward vs back slashes.
	shared String<u8> normalizePathSeparators(String<u8> filepath)
	{
		u8 pathSepChar = FileSystem:getPathSeparator();
		if(pathSepChar == Chars:FORWARD_SLASH) // UNIX (Linux, OSX, Android, iOS etc.)
			filepath.replaceAll(Chars:BACK_SLASH, FileSystem:getPathSeparator());
		else // Windows
			filepath.replaceAll(Chars:FORWARD_SLASH, FileSystem:getPathSeparator());

		return filepath;
	}

	// Replace "x.txt" with "x.img" etc.
	shared String<u8> replaceFileExtension(String<u8> filepath, String<u8> newExt)
	{
		String<u8> e = String<u8>(filepath);
		if(filepath.length() < 1)
		{
			String<u8> retStr = String<u8>(".");
			retStr.append(newExt);
			return retStr;
		}

		i64 extPeriodIndex = filepath.findPrev(Chars:PERIOD, filepath.length()-1);
		
		if(extPeriodIndex < 0)
		{
			e.append(".");
			e.append(newExt);
			return e; // no extension
		}

		if(extPeriodIndex == 0)
		{
			String<u8> retStr = String<u8>(".");
			retStr.append(newExt);
			return retStr; // just extension
		}

		e = filepath.subString(0, extPeriodIndex); //i.e. "C:\files\img."
		e.append(newExt); //i.e. "C:\files\img.png"

		return e;
	}

	// Change "xxx/yyy/img.png" to "yyy/img.png" etc.
	shared String<u8> makeFilepathRelative(String<u8> filepath, String<u8> relativeTo)
	{
		i64 index = filepath.findNext(relativeTo, 0);
		if(index < 0)
			return filepath; //can't change

		// i.e. filepath   == "C:\\dir1\\dir2\\file.png"
		// and  relativeTo == "dir2\\"
		// result will be  == "dir2\\file.png"

		String<u8> newFilepath = filepath.subString(index, filepath.length()-1);

		return newFilepath;
	}

	// Check no directories in string.
	shared bool isFilenameOnly(String<u8> filename)
	{
		if(filename.contains(Chars:BACK_SLASH) == true || filename.contains(Chars:FORWARD_SLASH) == true)
			return false;

		if(filename.countOccurrences(Chars:PERIOD) > 1)
			return false;

		CharGroup groupA = CharGroup(CharGroup:ALPHANUMERIC);
		groupA.add(Chars:SPACE);
		groupA.add(Chars:UNDERSCORE);
		groupA.add(Chars:PERIOD);
		if(filename.containsOnly(groupA) == false)
			return false;

		return true;
	}

	// List all files in a directory. Can include sub-directories files via recursive=true.
	shared ArrayList<String<u8>> listFiles(String<u8> filepath, bool recursive)
	{
		String<u8>[] files = FileSystem:listFilesArray(filepath, recursive);
		ArrayList<String<u8>> allFiles = ArrayList<String<u8>>();

		for(u64 f=0; f<files.length(); f++)
			allFiles.add(files[f]);

		return allFiles;
	}
	
	// List all files in a directory. Can include sub-directories via recursive. Filter by filename extension, i.e. "png".
	shared ArrayList<String<u8>> listFiles(String<u8> filepath, String<u8> extension, bool recursive)
	{
		String<u8> useExt = extension;
		if(useExt.beginsWith(".") == false)
		{
			useExt = String<u8>(".");
			useExt.append(extension);
		}

		String<u8>[] files = FileSystem:listFilesArray(filepath, recursive);
		ArrayList<String<u8>> filteredFiles = ArrayList<String<u8>>();

		// filter out non-matching files
		for(u64 f=0; f<files.length(); f++)
		{
			if(files[f].endsWith(useExt, true) == true)
				filteredFiles.add(files[f]);
		}

		return filteredFiles;
	}

	// List all files in a directory. Can include sub-directories via recursive. Filter by multiple filename extension, i.e. "png".
	shared ArrayList<String<u8>> listFiles(String<u8> filepath, ArrayList<String<u8>> extensions, bool recursive)
	{
		String<u8>[] files = FileSystem:listFilesArray(filepath, recursive);
		ArrayList<String<u8>> filteredFiles = ArrayList<String<u8>>();

		ArrayList<String<u8>> useExts = ArrayList<String<u8>>(); // need them to be of form ".jpg" etc. not just "jpg"
		for(u64 e=0; e<extensions.size(); e++)
		{
			String<u8> useExt = extensions[e];
			if(useExt.beginsWith(".") == false)
			{
				useExt = String<u8>(".");
				useExt.append(extensions[e]);
			}

			useExts.add(useExt);
		}

		// filter out non-matching files
		for(u64 f=0; f<files.length(); f++)
		{
			// if this file matches any extensions, add it
			for(u64 x=0; x<useExts.size(); x++)
			{
				if(files[f].endsWith(useExts[x], true) == true)
				{
					filteredFiles.add(files[f]);
					break;
				}
			}
		}

		return filteredFiles;
	}

	// List all directories.
	shared ArrayList<String<u8>> listDirectories(String<u8> filepath, bool recursive)
	{
		String<u8>[] dirs = listDirectoriesArray(filepath, recursive);
		ArrayList<String<u8>> dirsList = ArrayList<String<u8>>(dirs.length());
		for(u64 d=0; d<dirs.length(); d++)
			dirsList.add(dirs[d]);

		return dirsList;
	}

	// Check if file or directory exists.
	shared bool exists(String<u8> srcFilePath)
	{
		if(srcFilePath == null)
			return false;

		if(FileSystem:getFileInfo(srcFilePath).exists == true)
			return true;

		return false;
	}

	// Check if directory exists (and is not a file).
	shared bool isDirectory(String<u8> dirPath)
	{
		if(dirPath == null)
			return false;

		FileInfo fi = FileSystem:getFileInfo(dirPath);

		if(fi.exists == true && fi.directory == true)
			return true;

		return false;
	}

	// Check if file exists (and is not a directory).
	shared bool isFile(String<u8> filePath)
	{
		if(filePath == null)
			return false;

		FileInfo fi = FileSystem:getFileInfo(filePath);

		if(fi.exists == true && fi.directory == false)
			return true;

		return false;
	}
	
	// Copy a file from one path to another. Checks that file exists. Works by copy original into memory, write to destination, then delete original.
	shared bool copyFile(String<u8> srcFilePath, String<u8> desFilePath, bool overwriteExistingDesFile)
	{
		if(FileSystem:getFileInfo(srcFilePath).exists == false)
			return false;

		if(overwriteExistingDesFile == false && FileSystem:getFileInfo(desFilePath).exists == true)
			return true; // already there, don't overwrite

		// read file data
		ByteArray fileData = ByteArray(1024 * 128, 0);
		if(FileSystem:readFile(srcFilePath, fileData) == false)
			return false;

		// write file data
		if(FileSystem:writeFile(desFilePath, fileData) == false)
			return false;

		return true;
	}

	// Copy all files from one directory to another.
	shared bool copyFiles(String<u8> srcDirIn, String<u8> desDirIn, bool recursive, bool overwriteExistingDesFile)
	{
		String<u8> srcDir = String<u8>(srcDirIn);
		String<u8> desDir = String<u8>(desDirIn);

		if(srcDir.endsWith(Chars:BACK_SLASH) == false && srcDir.endsWith(Chars:FORWARD_SLASH) == false)
			srcDir.append(FileSystem:getPathSeparator());

		if(desDir.endsWith(Chars:BACK_SLASH) == false && desDir.endsWith(Chars:FORWARD_SLASH) == false)
			desDir.append(FileSystem:getPathSeparator());

		if(FileSystem:getFileInfo(srcDir).exists == false)
			return false;

		if(FileSystem:getFileInfo(desDir).exists == false)
			return false;

		String<u8> srcDirAbs = FileSystem:getAbsolutePath(srcDir);

		bool success = true;

		// create any directories we need
		ArrayList<String<u8>> dirList = FileSystem:listDirectories(srcDir, recursive);
		for(u64 d=0; d<dirList.size(); d++)
		{
			String<u8> childDirAbs = FileSystem:getAbsolutePath(dirList[d]);

			if(childDirAbs.beginsWith(srcDirAbs) == true)
			{
				String<u8> relChildDir = childDirAbs.subString(srcDirAbs.length(), childDirAbs.length()-1);
				String<u8> newChildDir = desDir;
				newChildDir.append(relChildDir);

				if(FileSystem:getFileInfo(newChildDir).exists == false)
				{
					if(FileSystem:createDirectory(newChildDir) == false)
					{
						success = false;
					}
				}
			}
			else
			{
				success = false;
			}
		}

		// list all files
		ArrayList<String<u8>> fileList = FileSystem:listFiles(srcDir, recursive);
		for(u64 f=0; f<fileList.size(); f++)
		{
			String<u8> childFileAbs = FileSystem:getAbsolutePath(fileList[f]);

			if(childFileAbs.beginsWith(srcDirAbs) == true)
			{
				String<u8> relChildFile = childFileAbs.subString(srcDirAbs.length(), childFileAbs.length()-1);
				String<u8> newChildFile = desDir;
				newChildFile.append(relChildFile);

				if(overwriteExistingDesFile == false && FileSystem:getFileInfo(newChildFile).exists == true)
					continue; // already there, don't overwrite

				if(FileSystem:copyFile(fileList[f], newChildFile, overwriteExistingDesFile) == false)
				{
					success = false;
				}
			}
			else
			{
				success = false;
			}
		}

		return success;
	}

	// Write whole text file.
	shared bool writeTextFile(String<u8> filepath, String<u8> contents)
	{
		return FileSystem:writeFile(filepath, contents.chars, contents.numChars);
	}

	// Write whole binary file.
	shared bool writeFile(String<u8> filepath, ByteArray contents)
	{
		return FileSystem:writeFile(filepath, contents.data, contents.numUsed);
	}

	// Write porition of binary file.
	shared bool writeFileChunk(String<u8> filepath, ByteArray contents, u64 offsetFromFileStart)
	{
		return FileSystem:writeFileChunk(filepath, contents.data, contents.numUsed, offsetFromFileStart);
	}

	// Append onto binary file.
	shared bool writeFileAppend(String<u8> filepath, ByteArray contents)
	{
		return FileSystem:writeFileAppend(filepath, contents.data, contents.numUsed);
	}

	// Read Text file - returns contents.
	shared String<u8> readTextFile(String<u8> filepath)
	{
		u64 fileSize = getFileInfo(filepath).fileSize;
		String<u8> contents = String<u8>(fileSize);
		contents.numChars = FileSystem:readFile(filepath, contents.chars);
		return contents;
	}

	// Read whole binary file. Returns null if unable to read file data.
	shared ByteArray readFile(String<u8> filepath)
	{
		ByteArray contentsOut = null;

		u64 fileSize = getFileInfo(filepath).fileSize;
		if(fileSize == 0)
			return null;

		contentsOut = ByteArray(fileSize, 0);

		u64 numBytesRead = FileSystem:readFile(filepath, contentsOut.data);
		contentsOut.numUsed = numBytesRead;

		if(numBytesRead == 0)
			contentsOut = null;

		return contentsOut;
	}

	// Read whole binary file.
	shared bool readFile(String<u8> filepath, ByteArray contentsOut)
	{
		u64 fileSize = getFileInfo(filepath).fileSize;
		if(contentsOut.getAllocatedSize() < fileSize)
			contentsOut.resize(fileSize);

		u64 numBytesRead = FileSystem:readFile(filepath, contentsOut.data);
		contentsOut.numUsed = numBytesRead;

		if(numBytesRead == 0)
			return false;

		return true;
	}

	// Read portion of binary file.
	shared bool readFileChunk(String<u8> filepath, ByteArray contentsOut, u64 offsetFromFileStart, u64 numBytes)
	{
		if(contentsOut.getAllocatedSize() < numBytes)
			contentsOut.resize(numBytes);

		u64 numRead = FileSystem:readFileChunk(filepath, contentsOut.data, offsetFromFileStart, numBytes);
		contentsOut.numUsed = numRead;

		if(numRead == 0)
			return false;

		return true;
	}

	// Move a file from one directory to another. Can be used to rename too.
	shared bool moveFile(String<u8> srcFilePath, String<u8> desFilePath, bool overwriteExistingDesFile)
	{
		if(FileSystem:copyFile(srcFilePath, desFilePath, overwriteExistingDesFile) == false)
			return false;

		if(FileSystem:deleteFile(srcFilePath) == false)
			return false;

		return true;
	}

	// Encode bytes (such as UTF8 string or a binary file) to a hex string consisting of characters 0-9 and A-F only.
	shared String<u8> encodeBytesToHex(ByteArray byteArray)
	{
		u8[] data     = byteArray.data;
		u64  numBytes = byteArray.numUsed;

		if(numBytes > data.length())
			numBytes = data.length();

		String<u8> s(numBytes * 2);

		for(u64 d=0; d<numBytes; d++)
		{
			s.append(String<u8>:formatNumberHex(data[d]));
		}

		return s;
	}

	// Decode bytes (such as UTF8 string or a binary file) from a hex string consisting of characters 0-9 and A-F only.
	shared ByteArray decodeBytesFromHex(String<u8> str)
	{
		String<u8> s(str);

		s.trimWhitespace();
		s.toUppercase(); // a becomes A

		if((s.length() % 2) != 0)
			s.append("0"); // weird, but we try our best

		u8[] data(s.length() / 2);
		for(u64 c=0; c<s.length(); c+=2)
		{
			u8 c0 = s.chars[c+0];
			u8 c1 = s.chars[c+1];

			u8 cv0 = 0;
			if(c0 >= Chars:ZERO && c0 <= Chars:NINE)
				cv0 = c0 - Chars:ZERO;
			else if(c0 >= Chars:A && c0 <= Chars:F)
				cv0 = (c0 - Chars:A) + 10;
			else
				cv0 = 0;

			u8 cv1 = 0;
			if(c1 >= Chars:ZERO && c1 <= Chars:NINE)
				cv1 = c1 - Chars:ZERO;
			else if(c1 >= Chars:A && c1 <= Chars:F)
				cv1 = (c1 - Chars:A) + 10;
			else
				cv1 = 0;

			data[c/2] = (cv0 * 16) + cv1;
		}

		return ByteArray(data);
	}

	// Encode binary data into base64 string. Encoded using the MIME standard "+" and "/" for chars 63/64. RFC 2045. AKA internet standard.
	shared String<u8> encodeBytesToBase64(ByteArray contents)
	{
		u8[64] t = FileSystem:getBase64EncodeTable();

		// short variable names
		u8[]       d = contents.data;
		String<u8> s(contents.numUsed);

		u64 curChar = 0; // start past currently used chars

		u64 numBase64Chars = Math:ceil(contents.numUsed / 3.0f) * 4;
		u64 newStrLen = s.numChars + numBase64Chars;
		s.resize(newStrLen);
		s.numChars = newStrLen;
		
		// 6 bit masks
		u32[4] masks;
		masks[0] = (0x0000003F << 18);
		masks[1] = (0x0000003F << 12);
		masks[2] = (0x0000003F << 6);
		masks[3] = 0x0000003F;

		// for every three bytes, encode as 4 chars
		u32 bits = 0;
		i64 bytesLeft = 0;
		for(u64 b=0; b<contents.numUsed; b+=3)
		{
			bytesLeft  = contents.numUsed;
			bytesLeft -= b;

			if(bytesLeft >= 3)
			{
				u32 b0 = d[b+0];
				u32 b1 = d[b+1];
				u32 b2 = d[b+2];

				bits = (b0 << 16) | (b1 << 8) | (b2);

				u32 c0 = ((masks[0] & bits) >> 18);
				u32 c1 = ((masks[1] & bits) >> 12);
				u32 c2 = ((masks[2] & bits) >> 6);
				u32 c3 = ((masks[3] & bits));

				s.chars[curChar+0] = t[c0];
				s.chars[curChar+1] = t[c1];
				s.chars[curChar+2] = t[c2];
				s.chars[curChar+3] = t[c3];
			}
			else if(bytesLeft == 2)
			{
				u32 b0 = d[b+0];
				u32 b1 = d[b+1];

				bits = (b0 << 16) | (b1 << 8) | 0;

				u32 c0 = ((masks[0] & bits) >> 18);
				u32 c1 = ((masks[1] & bits) >> 12);
				u32 c2 = ((masks[2] & bits) >> 6);

				s.chars[curChar + 0] = t[c0];
				s.chars[curChar + 1] = t[c1];
				s.chars[curChar + 2] = t[c2];
				s.chars[curChar + 3] = Chars:EQUALS;
			}
			else if(bytesLeft == 1)
			{
				u32 b0 = d[b+0];

				bits = (b0 << 16) | 0 | 0;

				u32 c0 = ((masks[0] & bits) >> 18);
				u32 c1 = ((masks[1] & bits) >> 12);

				s.chars[curChar + 0] = t[c0];
				s.chars[curChar + 1] = t[c1];
				s.chars[curChar + 2] = Chars:EQUALS;
				s.chars[curChar + 3] = Chars:EQUALS;
			}

			curChar += 4;
		}

		return s;
	}

	// Decode base64 string into binary data. Assumes MIME standard "+" and "/" for chars 63/64. RFC 2045. AKA internet standard.
	shared ByteArray decodeBytesFromBase64(String<u8> base64Data)
	{
		u8[128] t = getBase64DecodeTable(); // decode table, -1 for invalid mappings

		// make copy
		String<u8> str();
		str.chars = u8[](base64Data.length());
		str.numChars = 0;

		// remove invalid characters. NEW_LINE "\n", SPACE " " etc. are used to breakup lines and shit.
		for(u64 u=0; u<base64Data.length(); u++)
		{
			u8 ch = base64Data.chars[u];
			if(ch >= 128) // outside 't' table range and clearly invalid
				continue;
				
			if(t[ch] == 250) // covers everything that isn't base64
				continue;

			str.chars[str.numChars] = ch;
			str.numChars++;
		}

		u32 maxFileSize = Math:ceil((str.numChars * 6.0f) / 8.0f); // can't be more bytes then number of chars
		ByteArray f(maxFileSize);

		//for(u64 q=0; q<str.numChars; q++)
		//{
		//	if(str[q] >= 128)
		//		return null; // can't possibly be valid
		//}

		// each char is 6 bits, so just pack them in until we read end or pad chars ('=')
		u32 curBit  = 0;
		u32 val     = 0;
		u32 curByte = 0;
		for(u64 b=0; b<str.numChars; b+=4)
		{
			i64 numCharsLeft = str.numChars;
			numCharsLeft -= b;
			
			if(numCharsLeft < 4)
				return null; // failure, should be padded to 4 byte multiple!

			u32 b0 = t[str.chars[b+0]];
			u32 b1 = t[str.chars[b+1]];
			u32 b2 = t[str.chars[b+2]];
			u32 b3 = t[str.chars[b+3]];
			
			val = (b0 << 18) | (b1 << 12) | (b2 << 6) | (b3);

			curByte = curBit / 8;
			f.data[curByte+2] = (val & 0x000000FF);
			f.data[curByte+1] = (val & 0x0000FF00) >> 8;
			f.data[curByte+0] = (val & 0x00FF0000) >> 16;

			curBit += 24;
		}

		f.numUsed = curBit / 8;

		// ignore extra bytes via padding "=" signs
		if(str.chars[str.numChars-1] == Chars:EQUALS)
			f.numUsed--;

		if(str.chars[str.numChars - 2] == Chars:EQUALS)
			f.numUsed--;

		return f;
	}

	// Encode a data URL, using default RFC 2045 encoding.
	shared String<u8> encodeDataURL(ByteArray contents, String<u8> mimeType)
	{
		String<u8> base64Out(contents.numUsed);

		// standard identifier
		base64Out.append("data:");

		// mime info
		base64Out.append(mimeType);
		base64Out.append(";");

		// base
		base64Out.append("base64,");

		// charset encoding (we use default, so we don't put anything here)

		// data
		String<u8> base64Str = FileSystem:encodeBytesToBase64(contents);
		base64Out.append(base64Str);

		return base64Out;
	}

	// Decode data URL. Assumes RFC 2045. mimeOut can be null.
	shared ByteArray decodeDataURL(String<u8> dataURL, String<u8> mimeOut)
	{
		if(isDataURL(dataURL) == false)
			return false;

		if(mimeOut != null)
			mimeOut = FileSystem:getDataURLMIME(dataURL);

		String<u8> data64Str   = FileSystem:getDataURLData(dataURL);
		ByteArray  contentsOut = FileSystem:decodeBytesFromBase64(data64Str);

		return contentsOut;
	}

	// Decode data URL. Assumes RFC 2045.
	shared ByteArray decodeDataURL(String<u8> dataURL)
	{
		return decodeDataURL(dataURL, null);
	}

	// Check if dataURL matches expected format.
	shared bool isDataURL(String<u8> dataURL)
	{
		if(dataURL.beginsWith("data:"))
			return true;

		return false;
	}

	// Extract MIME type from data URL. Returns MIME:Unknown if we don't know.
	shared String<u8> getDataURLMIME(String<u8> dataURL)
	{
		if(dataURL.beginsWith("data:") == false) //not a data URL
			return String<u8>("");

		// parse general type
		i64 startIndex = 5;
		i64 endIndex = dataURL.findNext(Chars:FORWARD_SLASH, startIndex);
		if(endIndex == -1)
			return String<u8>("");

		String<u8> generalTypeStr = dataURL.subString(startIndex, endIndex-1);

		// parse specific type
		startIndex = endIndex + 1;
		endIndex   = dataURL.findNext(Chars:SEMI_COLON, startIndex);
		if(endIndex == -1)
			return String<u8>("");

		String<u8> specificType = dataURL.subString(startIndex, endIndex-1);

		generalTypeStr.toLowercase();
		specificType.toLowercase();

		String<u8> mimeStr = generalTypeStr;
		mimeStr.append("/");
		mimeStr.append(specificType);

		return mimeStr;
	}

	// Extract data URL encoded data portion.
	shared String<u8> getDataURLData(String<u8> dataURL)
	{
		i64 startIndex = dataURL.findNext(Chars:COMMA, 0);
		if(startIndex == -1)
			return String<u8>("");

		String<u8> dataPortionStr = dataURL.subString(startIndex + 1, dataURL.length()-1);

		return dataPortionStr;
	}

	// Generates an RFC 2045 map, from binary-to-char.
	shared u8[64] getBase64EncodeTable()
	{
		// ENCODE
		u8[64] encodeTable; // all 64 indexes are valid

		// 0 - 25 == A - Z
		for(u32 i=0; i<=25; i++)
		{
			encodeTable[i] = Chars:A + i;
		}

		// 26 - 51 == a - z
		for(u32 j=26; j<=51; j++)
		{
			encodeTable[j] = Chars:a + (j - 26);
		}

		// 0 - 9 == 52 - 61 inclusive 
		for(u32 c=52; c<=61; c++)
		{
			encodeTable[c] = Chars:ZERO + (c - 52);
		}

		// The 62/63 chars are the MIME standard "+" and "/" (RFC 2045).
		encodeTable[62] = Chars:PLUS;
		encodeTable[63] = Chars:FORWARD_SLASH;

		return encodeTable;
	}

	// Generates an RFC 2045 map, from char-to-binary. 128 entries, with only 64 valid, ASCII A-Z, a-z, 0-9 and + /.
	shared u8[128] getBase64DecodeTable()
	{
		u8[128] decodeTable; // only 64 indexes are valid (ASCII A-Z, a-z, 0-9 and + /)

		// DECODE
		for(u32 x=0; x<128; x++)
			decodeTable[x] = 250; //for invalid mappings

		// A - Z == 0 - 25 inclusive 
		for(u32 i=0; i<=25; i++)
		{
			decodeTable[Chars:A + i] = i;
		}

		// a - z == 26 - 51 inclusive 
		for(u32 j=26; j<=51; j++)
		{
			decodeTable[Chars:a + (j - 26)] = j;
		}

		// 0 - 9 == 52 - 61 inclusive 
		for(u32 c=52; c<=61; c++)
		{
			decodeTable[Chars:ZERO + (c - 52)] = c;
		}

		// The 62/63 chars are the MIME standard "+" and "/" (RFC 2045).
		decodeTable[Chars:PLUS] = 62;
		decodeTable[Chars:FORWARD_SLASH] = 63;

		// = for padding char
		decodeTable[Chars:EQUALS] = 0;

		return decodeTable;
	}
}