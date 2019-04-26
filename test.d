module test;

import bindbc.zstandard;
import bindbc.loader.sharedlib;

import std.stdio;
import std.conv : to;
/*
 For testing dynamic linkage
 */

unittest{
	if(loadZstandard() == ZSTDSupport.noLibrary){
		const(ErrorInfo)[] errorlist = errors;
		foreach(e; errorlist){
			writeln(to!string(e.error));
			writeln(to!string(e.message));
		}

	}
	ubyte[] origFile, compOut, decompOut;

	File file = File("zstd.exe");
	origFile.length = cast(size_t)file.size;
	decompOut.length = cast(size_t)file.size;
	compOut.length = cast(size_t)file.size;
	file.rawRead(origFile);
	size_t outputSize = ZSTD_compress(compOut.ptr, compOut.length, origFile.ptr, origFile.length, ZSTD_maxCLevel());
	ZSTD_decompress(decompOut.ptr, decompOut.length, compOut.ptr, outputSize);
	for(int i ; i < origFile.length ; i++){
		assert(decompOut[i] == origFile[i], "Error at position " ~ to!string(i));
	}
}