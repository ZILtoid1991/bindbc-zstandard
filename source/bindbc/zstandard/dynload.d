module bindbc.zstandard.dynload;

version(BindZSTD_Static){

}else:
import bindbc.loader;
import bindbc.zstandard.zstd;
import bindbc.zstandard.config;

private{
	SharedLib lib;
	ZSTDSupport loadedVersion;
}
/**
 * Unloads the zstandard library.
 */
void unloadZSTD(){
	if(lib != invalidHandle){
		lib.unload();
	}
}
/**
 * Returns the currently loaded zstandard library version, or an error code.
 */
ZSTDSupport loadedZSTDVersion(){
	return loadedVersion;
}
/**
 * Loads the library and ties the function pointers to the library.
 */
ZSTDSupport loadZstandard(){
	version(Windows){
		const(char)[][2] libNames = [
			"libzstd.dll",
			"zstd.dll"
		];
	}else static assert(0, "bindbc-zstandard is not yet supported on this platform.");

	ZSTDSupport result;
	foreach(name; libNames){
		result = loadZstandard(name.ptr);
		if(result != ZSTDSupport.noLibrary) break;
	}
	return result;
}
ZSTDSupport loadZstandard(const(char)* libName){
	lib = load(libName);
    if(lib == invalidHandle) {
        return ZSTDSupport.noLibrary;
    }

    auto errCount = errorCount();
	loadedVersion = ZSTDSupport.badLibrary;
	lib.bindSymbol(cast(void**)&ZSTD_versionNumber, "ZSTD_versionNumber");
	lib.bindSymbol(cast(void**)&ZSTD_versionString, "ZSTD_versionString");
	lib.bindSymbol(cast(void**)&ZSTD_compress, "ZSTD_compress");
	lib.bindSymbol(cast(void**)&ZSTD_decompress, "ZSTD_decompress");
	lib.bindSymbol(cast(void**)&ZSTD_getFrameContentSize, "ZSTD_getFrameContentSize");
	lib.bindSymbol(cast(void**)&ZSTD_getDecompressedSize, "ZSTD_getDecompressedSize");
	lib.bindSymbol(cast(void**)&ZSTD_compressBound, "ZSTD_compressBound");
	lib.bindSymbol(cast(void**)&ZSTD_isError, "ZSTD_isError");
	lib.bindSymbol(cast(void**)&ZSTD_getErrorName, "ZSTD_getErrorName");
	lib.bindSymbol(cast(void**)&ZSTD_maxCLevel, "ZSTD_maxCLevel");
	lib.bindSymbol(cast(void**)&ZSTD_createCCtx, "ZSTD_createCCtx");
	lib.bindSymbol(cast(void**)&ZSTD_freeCCtx, "ZSTD_freeCCtx");
	lib.bindSymbol(cast(void**)&ZSTD_compressCCtx, "ZSTD_compressCCtx");
	lib.bindSymbol(cast(void**)&ZSTD_createDCtx, "ZSTD_createDCtx");
	lib.bindSymbol(cast(void**)&ZSTD_freeDCtx, "ZSTD_freeDCtx");
	lib.bindSymbol(cast(void**)&ZSTD_decompressDCtx, "ZSTD_decompressDCtx");
	lib.bindSymbol(cast(void**)&ZSTD_compress_usingDict, "ZSTD_compress_usingDict");
	lib.bindSymbol(cast(void**)&ZSTD_decompress_usingDict, "ZSTD_decompress_usingDict");
	lib.bindSymbol(cast(void**)&ZSTD_createCDict, "ZSTD_createCDict");
	lib.bindSymbol(cast(void**)&ZSTD_freeCDict, "ZSTD_freeCDict");
	lib.bindSymbol(cast(void**)&ZSTD_compress_usingCDict, "ZSTD_compress_usingCDict");
	lib.bindSymbol(cast(void**)&ZSTD_createDDict, "ZSTD_createDDict");
	lib.bindSymbol(cast(void**)&ZSTD_freeDDict, "ZSTD_freeDDict");
	lib.bindSymbol(cast(void**)&ZSTD_decompress_usingDDict, "ZSTD_decompress_usingDDict");
	lib.bindSymbol(cast(void**)&ZSTD_createCStream, "ZSTD_createCStream");
	lib.bindSymbol(cast(void**)&ZSTD_freeCStream, "ZSTD_freeCStream");
	lib.bindSymbol(cast(void**)&ZSTD_initCStream, "ZSTD_initCStream");
	lib.bindSymbol(cast(void**)&ZSTD_compressStream, "ZSTD_compressStream");
	lib.bindSymbol(cast(void**)&ZSTD_flushStream, "ZSTD_flushStream");
	lib.bindSymbol(cast(void**)&ZSTD_endStream, "ZSTD_endStream");
	lib.bindSymbol(cast(void**)&ZSTD_CStreamInSize, "ZSTD_CStreamInSize");
	lib.bindSymbol(cast(void**)&ZSTD_CStreamOutSize, "ZSTD_CStreamOutSize");
	lib.bindSymbol(cast(void**)&ZSTD_createDStream, "ZSTD_createDStream");
	lib.bindSymbol(cast(void**)&ZSTD_freeDStream, "ZSTD_freeDStream");
	lib.bindSymbol(cast(void**)&ZSTD_initDStream, "ZSTD_initDStream");
	lib.bindSymbol(cast(void**)&ZSTD_decompressStream, "ZSTD_decompressStream");
	lib.bindSymbol(cast(void**)&ZSTD_DStreamInSize, "ZSTD_DStreamInSize");
	lib.bindSymbol(cast(void**)&ZSTD_DStreamOutSize, "ZSTD_DStreamOutSize");
	loadedVersion = ZSTDSupport.ZSTD1_3_7;
	if(errCount != errorCount){
		return ZSTDSupport.badLibrary;
	}
	return loadedVersion;
}