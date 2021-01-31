////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

String<u8> fstests_getOuputDir()
{
	String<u8> dirPath = FileSystem:getSpecialDirectory(FileSystem:DIRECTORY_APPHOME);
	dirPath.append(String<u8>("testout/"));
	return dirPath;
}

class HexEncodeDecodeTests implements IUnitTest
{
	void run()
	{
		ByteArray fileA(8, 8);
		for(u64 b=0; b<fileA.size(); b++)
			fileA.data[b] = 100 + b;

		String<u8> base16Str = FileSystem:encodeBytesToHex(fileA);
		ByteArray  fileB     = FileSystem:decodeBytesFromHex(base16Str);

		test(fileB != null);
		test(fileA.size() == fileB.size());
		test(fileA.compare(fileB) == true);
	}
}

class PkgEmbeddedFilesTests implements IUnitTest
{
	void run()
	{
		// We embedded files in pronto-core-tests
		u8[] fileContents = HVM:getPackageFile("XMLTestDataLarge.xml");
		test(fileContents != null);
		test(fileContents.length() > 1024);

		// Test we ask for file that doesn't exist.
		u8[] fileContents2 = HVM:getPackageFile("NotARealFile.xml");
		test(fileContents2 == null);

		// We embedded files in pronto-core which means we have to specify package name
		u8[] fileContents3 = HVM:getPackageFile("CertificateAuthorityCerts.txt", "pronto_core");
		test(fileContents3 != null);
		test(fileContents3.length() > 1024);

		// Test we ask for file that doesn't exist in a different package.
		u8[] fileContents4 = HVM:getPackageFile("NotARealFile.xml", "pronto_core");
		test(fileContents4 == null);

		// Test we ask for file that no package exists for
		u8[] fileContents4 = HVM:getPackageFile("NotARealFile.xml", "not_a_real_pkg_name");
		test(fileContents4 == null);
	}
}

class Base64EncodeDecodeTests implements IUnitTest
{
	void run()
	{
		ByteArray fileA(8, 8);
		for(u64 b=0; b<fileA.size(); b++)
			fileA.data[b] = 100 + b;

		String<u8> base64Str = FileSystem:encodeBytesToBase64(fileA); 

		test(base64Str != null);
		test(base64Str.compare("ZGVmZ2hpams=") == true); // should be ZGVmZ2hpams=

		ByteArray fileB = FileSystem:decodeBytesFromBase64(base64Str);

		test(fileB != null);
		test(fileA.size() == fileB.size());
		test(fileA.compare(fileB) == true);
	}
}

class FileSystemParentDirTests implements IUnitTest
{
	void run()
	{
		String<u8> filepath = String<u8>("parentA/parentB/note.txt");
		test(FileSystem:getParentDirectory(filepath).compare("parentA/parentB/") == true);
	}
}

class FileSystemFilenameTests implements IUnitTest
{
	void run()
	{
		String<u8> filepath      = String<u8>("input\\CodeGenerator.h");
		String<u8> filename      = FileSystem:getFilename(filepath, false);
		String<u8> filenameNoExt = FileSystem:getFilename(filepath, true);
		test(filename.compare("CodeGenerator.h") == true);
		test(filenameNoExt.compare("CodeGenerator") == true);
	}
}

class FileSystemReadWriteTests implements IUnitTest
{
	void run()
	{
		// output dir
		FileInfo dirInfo = FileSystem:getFileInfo(fstests_getOuputDir());
		if(dirInfo.exists == false)
		{
			FileSystem:createDirectory(fstests_getOuputDir());
			dirInfo = FileSystem:getFileInfo(fstests_getOuputDir());
			test(dirInfo.exists == true);
			test(FileSystem:exists(fstests_getOuputDir()) == true); // alternate way to check, just shortform
		}

		test(dirInfo.directory == true);

		// write
		ByteArray file = ByteArray(8, 0);
		file.writeU32(88);
		file.writeI32(-99);

		String<u8> filepath = fstests_getOuputDir();
		filepath.append("file.bin");

		test(FileSystem:writeFile(filepath, file) == true);

		FileInfo fileInfo = FileSystem:getFileInfo(filepath);
		test(fileInfo.exists == true);
		test(fileInfo.fileSize == 8);

		filepath = null;

		String<u8> dirpath = fstests_getOuputDir();
		dirpath.append("new/");

		test(FileSystem:createDirectory(dirpath) == true);

		FileInfo dirInfo2 = FileSystem:getFileInfo(dirpath);
		test(dirInfo2.exists == true);
		test(dirInfo2.directory == true);

		// read
		ByteArray file2 = ByteArray();

		String<u8> filepath2 = fstests_getOuputDir();
		filepath2.append("file.bin");

		test(FileSystem:readFile(filepath2, file2) == true);
		file2.setIndex(0);
		test(file2.readU32() == 88);
		file2.setIndex(4);
		test(file2.readI32() == -99);

		// delete
		String<u8> filepath3 = fstests_getOuputDir();
		filepath3.append("file.bin");

		test(FileSystem:deleteFile(filepath3) == true);
		
		FileInfo fileInfo = FileSystem:getFileInfo(filepath3);
		test(fileInfo.exists == false);
	}
}