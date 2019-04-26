/*
	bindbc/zstandard/zstd.d

	Translates al dynamic and most static functions from zstd.h

	Licensed under the Boost Software License

	2018 - Laszlo Szeremi
*/

module bindbc.zstandard.zstd;

enum ZSTD_MAGICNUMBER = 0xFD2FB528;   /* v0.8+ */
enum ZSTD_MAGIC_DICTIONARY = 0xEC30A437;   /* v0.7+ */
enum ZSTD_MAGIC_SKIPPABLE_START = 0x184D2A50U;
enum ZSTD_BLOCKSIZELOG_MAX = 17;
enum ZSTD_BLOCKSIZE_MAX = (1<<ZSTD_BLOCKSIZELOG_MAX);   /* define, for static allocation */

enum ZSTD_nextInputType_e { 
	ZSTDnit_frameHeader, 
	ZSTDnit_blockHeader, 
	ZSTDnit_block,
	ZSTDnit_lastBlock, 
	ZSTDnit_checksum, 
	ZSTDnit_skippableFrame 
}
version(zstd1_04){
	enum ZSTD_EndDirective{
		ZSTD_e_continue=0,
		ZSTD_e_flush=1,
		ZSTD_e_end=2
	}
}
///Note: Not yet available in 1.3 versions with dynamic linking.
enum ZSTD_strategy{ 
	ZSTD_fast=1, 
	ZSTD_dfast=2, 
	ZSTD_greedy=3, 
	ZSTD_lazy=4, 
	ZSTD_lazy2=5, 
	ZSTD_btlazy2=6, 
	ZSTD_btopt=7, 
	ZSTD_btultra=8, 
	ZSTD_btultra2=9
}
///Note: Not yet available in 1.3 versions with dynamic linking.
enum ZSTD_cParameter{

  /* compression parameters
	 * Note: When compressing with a ZSTD_CDict these parameters are superseded
	 * by the parameters used to construct the ZSTD_CDict. See ZSTD_CCtx_refCDict()
	 * for more info (superseded-by-cdict). */
	ZSTD_c_compressionLevel=100, /* Update all compression parameters according to pre-defined cLevel table
	                          * Default level is ZSTD_CLEVEL_DEFAULT==3.
	                          * Special: value 0 means default, which is controlled by ZSTD_CLEVEL_DEFAULT.
	                          * Note 1 : it's possible to pass a negative compression level.
	                          * Note 2 : setting a level sets all default values of other compression parameters */
	ZSTD_c_windowLog=101,    /* Maximum allowed back-reference distance, expressed as power of 2.
	                          * Must be clamped between ZSTD_WINDOWLOG_MIN and ZSTD_WINDOWLOG_MAX.
	                          * Special: value 0 means "use default windowLog".
	                          * Note: Using a windowLog greater than ZSTD_WINDOWLOG_LIMIT_DEFAULT
	                          *       requires explicitly allowing such window size at decompression stage if using streaming. */
	ZSTD_c_hashLog=102,      /* Size of the initial probe table, as a power of 2.
	                          * Resulting memory usage is (1 << (hashLog+2)).
	                          * Must be clamped between ZSTD_HASHLOG_MIN and ZSTD_HASHLOG_MAX.
	                          * Larger tables improve compression ratio of strategies <= dFast,
	                          * and improve speed of strategies > dFast.
	                          * Special: value 0 means "use default hashLog". */
	ZSTD_c_chainLog=103,     /* Size of the multi-probe search table, as a power of 2.
	                          * Resulting memory usage is (1 << (chainLog+2)).
	                          * Must be clamped between ZSTD_CHAINLOG_MIN and ZSTD_CHAINLOG_MAX.
	                          * Larger tables result in better and slower compression.
	                          * This parameter is useless when using "fast" strategy.
	                          * It's still useful when using "dfast" strategy,
	                          * in which case it defines a secondary probe table.
	                          * Special: value 0 means "use default chainLog". */
	ZSTD_c_searchLog=104,    /* Number of search attempts, as a power of 2.
	                          * More attempts result in better and slower compression.
	                          * This parameter is useless when using "fast" and "dFast" strategies.
	                          * Special: value 0 means "use default searchLog". */
	ZSTD_c_minMatch=105,     /* Minimum size of searched matches.
	                          * Note that Zstandard can still find matches of smaller size,
	                          * it just tweaks its search algorithm to look for this size and larger.
	                          * Larger values increase compression and decompression speed, but decrease ratio.
	                          * Must be clamped between ZSTD_MINMATCH_MIN and ZSTD_MINMATCH_MAX.
	                          * Note that currently, for all strategies < btopt, effective minimum is 4.
	                          *                    , for all strategies > fast, effective maximum is 6.
	                          * Special: value 0 means "use default minMatchLength". */
	ZSTD_c_targetLength=106, /* Impact of this field depends on strategy.
	                          * For strategies btopt, btultra & btultra2:
	                          *     Length of Match considered "good enough" to stop search.
	                          *     Larger values make compression stronger, and slower.
	                          * For strategy fast:
	                          *     Distance between match sampling.
	                          *     Larger values make compression faster, and weaker.
	                          * Special: value 0 means "use default targetLength". */
	ZSTD_c_strategy=107,     /* See ZSTD_strategy enum definition.
	                          * The higher the value of selected strategy, the more complex it is,
	                          * resulting in stronger and slower compression.
	                          * Special: value 0 means "use default strategy". */

	/* LDM mode parameters */
	ZSTD_c_enableLongDistanceMatching=160, /* Enable long distance matching.
	                                 * This parameter is designed to improve compression ratio
	                                 * for large inputs, by finding large matches at long distance.
	                                 * It increases memory usage and window size.
	                                 * Note: enabling this parameter increases default ZSTD_c_windowLog to 128 MB
	                                 * except when expressly set to a different value. */
	ZSTD_c_ldmHashLog=161,   /* Size of the table for long distance matching, as a power of 2.
	                          * Larger values increase memory usage and compression ratio,
	                          * but decrease compression speed.
	                          * Must be clamped between ZSTD_HASHLOG_MIN and ZSTD_HASHLOG_MAX
	                          * default: windowlog - 7.
	                          * Special: value 0 means "automatically determine hashlog". */
	ZSTD_c_ldmMinMatch=162,  /* Minimum match size for long distance matcher.
	                          * Larger/too small values usually decrease compression ratio.
	                          * Must be clamped between ZSTD_LDM_MINMATCH_MIN and ZSTD_LDM_MINMATCH_MAX.
	                          * Special: value 0 means "use default value" (default: 64). */
	ZSTD_c_ldmBucketSizeLog=163, /* Log size of each bucket in the LDM hash table for collision resolution.
	                          * Larger values improve collision resolution but decrease compression speed.
	                          * The maximum value is ZSTD_LDM_BUCKETSIZELOG_MAX.
	                          * Special: value 0 means "use default value" (default: 3). */
	ZSTD_c_ldmHashRateLog=164, /* Frequency of inserting/looking up entries into the LDM hash table.
	                          * Must be clamped between 0 and (ZSTD_WINDOWLOG_MAX - ZSTD_HASHLOG_MIN).
	                          * Default is MAX(0, (windowLog - ldmHashLog)), optimizing hash table usage.
	                          * Larger values improve compression speed.
	                          * Deviating far from default value will likely result in a compression ratio decrease.
	                          * Special: value 0 means "automatically determine hashRateLog". */

	/* frame parameters */
	ZSTD_c_contentSizeFlag=200, /* Content size will be written into frame header _whenever known_ (default:1)
	                          * Content size must be known at the beginning of compression.
	                          * This is automatically the case when using ZSTD_compress2(),
	                          * For streaming variants, content size must be provided with ZSTD_CCtx_setPledgedSrcSize() */
	ZSTD_c_checksumFlag=201, /* A 32-bits checksum of content is written at end of frame (default:0) */
	ZSTD_c_dictIDFlag=202,   /* When applicable, dictionary's ID is written into frame header (default:1) */

	/* multi-threading parameters */
	/* These parameters are only useful if multi-threading is enabled (compiled with build macro ZSTD_MULTITHREAD).
	 * They return an error otherwise. */
	ZSTD_c_nbWorkers=400,    /* Select how many threads will be spawned to compress in parallel.
	                          * When nbWorkers >= 1, triggers asynchronous mode when used with ZSTD_compressStream*() :
	                          * ZSTD_compressStream*() consumes input and flush output if possible, but immediately gives back control to caller,
	                          * while compression work is performed in parallel, within worker threads.
	                          * (note : a strong exception to this rule is when first invocation of ZSTD_compressStream2() sets ZSTD_e_end :
	                          *  in which case, ZSTD_compressStream2() delegates to ZSTD_compress2(), which is always a blocking call).
	                          * More workers improve speed, but also increase memory usage.
	                          * Default value is `0`, aka "single-threaded mode" : no worker is spawned, compression is performed inside Caller's thread, all invocations are blocking */
	ZSTD_c_jobSize=401,      /* Size of a compression job. This value is enforced only when nbWorkers >= 1.
	                          * Each compression job is completed in parallel, so this value can indirectly impact the nb of active threads.
	                          * 0 means default, which is dynamically determined based on compression parameters.
	                          * Job size must be a minimum of overlap size, or 1 MB, whichever is largest.
	                          * The minimum size is automatically and transparently enforced */
	ZSTD_c_overlapLog=402,   /* Control the overlap size, as a fraction of window size.
	                          * The overlap size is an amount of data reloaded from previous job at the beginning of a new job.
	                          * It helps preserve compression ratio, while each job is compressed in parallel.
	                          * This value is enforced only when nbWorkers >= 1.
	                          * Larger values increase compression ratio, but decrease speed.
	                          * Possible values range from 0 to 9 :
	                          * - 0 means "default" : value will be determined by the library, depending on strategy
	                          * - 1 means "no overlap"
	                          * - 9 means "full overlap", using a full window size.
	                          * Each intermediate rank increases/decreases load size by a factor 2 :
	                          * 9: full window;  8: w/2;  7: w/4;  6: w/8;  5:w/16;  4: w/32;  3:w/64;  2:w/128;  1:no overlap;  0:default
	                          * default value varies between 6 and 9, depending on strategy */

	/* note : additional experimental parameters are also available
	 * within the experimental section of the API.
	 * At the time of this writing, they include :
	 * ZSTD_c_rsyncable
	 * ZSTD_c_format
	 * ZSTD_c_forceMaxWindow
	 * ZSTD_c_forceAttachDict
	 * ZSTD_c_literalCompressionMode
	 * Because they are not stable, it's necessary to define ZSTD_STATIC_LINKING_ONLY to access them.
	 * note : never ever use experimentalParam? names directly;
	 *        also, the enums values themselves are unstable and can still change.
	 */
	ZSTD_c_experimentalParam1=500,
	ZSTD_c_experimentalParam2=10,
	ZSTD_c_experimentalParam3=1000,
	ZSTD_c_experimentalParam4=1001,
	ZSTD_c_experimentalParam5=1002,
}
///NOTE: 1.4 only
enum ZSTD_ResetDirective{
	ZSTD_reset_session_only = 1,
	ZSTD_reset_parameters = 2,
	ZSTD_reset_session_and_parameters = 3
} 
struct ZSTD_bounds{
    size_t error;
    int lowerBound;
    int upperBound;
}
enum ZSTD_CONTENTSIZE_UNKNOWN = 0UL-1;
enum ZSTD_CONTENTSIZE_ERROR = 0UL-2;
struct ZSTD_CCtx_s{}
struct ZSTD_DCtx_s{}
struct ZSTD_CDict_s{}
struct ZSTD_DDict_s{}
alias ZSTD_CCtx = ZSTD_CCtx_s;
alias ZSTD_DCtx = ZSTD_DCtx_s;
alias ZSTD_CDict = ZSTD_CDict_s;
alias ZSTD_DDict = ZSTD_DDict_s;
struct ZSTD_inBuffer_s {
  const(void)* src;    /**< start of input buffer */
  size_t size;        /**< size of input buffer */
  size_t pos;         /**< position where reading stopped. Will be updated. Necessarily 0 <= pos <= size */
}
alias ZSTD_inBuffer = ZSTD_inBuffer_s;
struct ZSTD_outBuffer_s {
  void*  dst;         /**< start of output buffer */
  size_t size;        /**< size of output buffer */
  size_t pos;         /**< position where writing stopped. Will be updated. Necessarily 0 <= pos <= size */
}
alias ZSTD_outBuffer = ZSTD_outBuffer_s;
alias ZSTD_CStream = ZSTD_CCtx;
alias ZSTD_DStream = ZSTD_DCtx;

/**
 * Helper function, found in the original API as a precompiler macro.
 */
@nogc nothrow size_t ZSTD_COMPRESSBOUND(size_t srcSize){
	return ((srcSize) + ((srcSize)>>8) + (((srcSize) < (128<<10)) ? (((128<<10) - (srcSize)) >> 11) /* margin, from 64 to 0 */ : 0));
}

version(BindZSTD_Static){
extern(C) @nogc nothrow:
	uint ZSTD_versionNumber();
	const(char)* ZSTD_versionString();
	size_t ZSTD_compress(void* dst, size_t dstCapacity, const(void)* src, size_t srcSize, int compressionLevel);
	size_t ZSTD_decompress(void* dst, size_t dstCapacity, const(void)* src, size_t compressedSize);
	ulong ZSTD_getFrameContentSize(const(void)* src, size_t srcSize);
	ulong ZSTD_getDecompressedSize(const(void)* src, size_t srcSize);
	size_t ZSTD_compressBound(size_t srcSize);
	uint ZSTD_isError(size_t code);         
	const(char)* ZSTD_getErrorName(size_t code);    
	int ZSTD_maxCLevel();              
	ZSTD_CCtx* ZSTD_createCCtx();
	size_t ZSTD_freeCCtx(ZSTD_CCtx* cctx);
	size_t ZSTD_compressCCtx(ZSTD_CCtx* ctx, void* dst, size_t dstCapacity, const(void)* src, size_t srcSize, 
			int compressionLevel);
	ZSTD_DCtx* ZSTD_createDCtx();
	size_t ZSTD_freeDCtx(ZSTD_DCtx* dctx);
	size_t ZSTD_decompressDCtx(ZSTD_DCtx* ctx, void* dst, size_t dstCapacity, const(void)* src, size_t srcSize);
	size_t ZSTD_compress_usingDict(ZSTD_CCtx* ctx, void* dst, size_t dstCapacity, const(void)* src, size_t srcSize,
            const(void)* dict,size_t dictSize, int compressionLevel);
	size_t ZSTD_decompress_usingDict(ZSTD_DCtx* dctx, void* dst, size_t dstCapacity, const(void)* src, size_t srcSize,
			const(void)* dict,size_t dictSize);
	ZSTD_CDict* ZSTD_createCDict(const(void)* dictBuffer, size_t dictSize, int compressionLevel);
	size_t ZSTD_freeCDict(ZSTD_CDict* CDict);
	size_t ZSTD_compress_usingCDict(ZSTD_CCtx* cctx, void* dst, size_t dstCapacity, const(void)* src, size_t srcSize,
			const(ZSTD_CDict)* cdict);
	ZSTD_DDict* ZSTD_createDDict(const(void)* dictBuffer, size_t dictSize);
	size_t ZSTD_freeDDict(ZSTD_DDict* ddict);
	size_t ZSTD_decompress_usingDDict(ZSTD_DCtx* dctx, void* dst, size_t dstCapacity, const(void)* src, size_t srcSize,
			const(ZSTD_DDict)* ddict);
	ZSTD_CStream* ZSTD_createCStream();
	size_t ZSTD_freeCStream(ZSTD_CStream* zcs);
	size_t ZSTD_initCStream(ZSTD_CStream* zcs, int compressionLevel);
	size_t ZSTD_compressStream(ZSTD_CStream* zcs, ZSTD_outBuffer* output, ZSTD_inBuffer* input);
	size_t ZSTD_flushStream(ZSTD_CStream* zcs, ZSTD_outBuffer* output);
	size_t ZSTD_endStream(ZSTD_CStream* zcs, ZSTD_outBuffer* output);
	size_t ZSTD_CStreamInSize();
	size_t ZSTD_CStreamOutSize();
	ZSTD_DStream* ZSTD_createDStream();
	size_t ZSTD_freeDStream(ZSTD_DStream* zds);
	size_t ZSTD_initDStream(ZSTD_DStream* zds);
	size_t ZSTD_decompressStream(ZSTD_DStream* zds, ZSTD_outBuffer* output, ZSTD_inBuffer* input);
	size_t ZSTD_DStreamInSize();
	size_t ZSTD_DStreamOutSize();
	version(zstd1_04){
		size_t ZSTD_compressStream2(ZSTD_CCtx* cctx, ZSTD_outBuffer* output, ZSTD_inBuffer* input, ZSTD_EndDirective endOp);

		ZSTD_bounds ZSTD_cParam_getBounds(ZSTD_cParameter cParam);
		size_t ZSTD_CCtx_setParameter(ZSTD_CCtx* cctx, ZSTD_cParameter param, int value);
		size_t ZSTD_CCtx_setPledgedSrcSize(ZSTD_CCtx* cctx, ulong pledgedSrcSize);
		size_t ZSTD_CCtx_reset(ZSTD_CCtx* cctx, ZSTD_ResetDirective reset);
		size_t ZSTD_compress2( ZSTD_CCtx* cctx, void* dst, size_t dstCapacity, const(void)* src, size_t srcSize);
		uint ZSTD_getDictID_fromDict(const(void)* dict, size_t dictSize);
		uint ZSTD_getDictID_fromDDict(const(ZSTD_DDict)* ddict);
		size_t ZSTD_CCtx_loadDictionary(ZSTD_CCtx* cctx, const(void)* dict, size_t dictSize);
		size_t ZSTD_DCtx_reset(ZSTD_DCtx* dctx, ZSTD_ResetDirective reset);
		size_t ZSTD_CCtx_refCDict(ZSTD_CCtx* cctx, const(ZSTD_CDict)* cdict);
		size_t ZSTD_CCtx_refPrefix(ZSTD_CCtx* cctx, const(void*) prefix, size_t prefixSize);
		size_t ZSTD_DCtx_loadDictionary(ZSTD_DCtx* dctx, const(void)* dict, size_t dictSize);
		size_t ZSTD_DCtx_refDDict(ZSTD_DCtx* dctx, const(ZSTD_DDict)* ddict);
		size_t ZSTD_DCtx_refPrefix(ZSTD_DCtx* dctx, const(void)* prefix, size_t prefixSize);
		size_t ZSTD_sizeof_CCtx(const ZSTD_CCtx* cctx);
		size_t ZSTD_sizeof_DCtx(const ZSTD_DCtx* dctx);
		size_t ZSTD_sizeof_CStream(const ZSTD_CStream* zcs);
		size_t ZSTD_sizeof_DStream(const ZSTD_DStream* zds);
		size_t ZSTD_sizeof_CDict(const ZSTD_CDict* cdict);
		size_t ZSTD_sizeof_DDict(const ZSTD_DDict* ddict);
	}

	//static linkage only functions begin here
	int ZSTD_minCLevel();
	enum ZSTD_WINDOWLOG_MAX_32 = 30;
	enum ZSTD_WINDOWLOG_MAX_64 = 31;
	enum ZSTD_WINDOWLOG_MAX = (cast(uint)size_t.sizeof == 4 ? ZSTD_WINDOWLOG_MAX_32 : ZSTD_WINDOWLOG_MAX_64);
	enum ZSTD_WINDOWLOG_MIN = 10;
	enum ZSTD_HASHLOG_MAX = ((ZSTD_WINDOWLOG_MAX < 30) ? ZSTD_WINDOWLOG_MAX : 30);
	enum ZSTD_HASHLOG_MIN = 6;
	enum ZSTD_CHAINLOG_MAX_32 = 29;
	enum ZSTD_CHAINLOG_MAX_64 = 30;
	enum ZSTD_CHAINLOG_MAX = (cast(uint)size_t.sizeof == 4 ? ZSTD_CHAINLOG_MAX_32 : ZSTD_CHAINLOG_MAX_64);
	enum ZSTD_CHAINLOG_MIN = ZSTD_HASHLOG_MIN;
	enum ZSTD_HASHLOG3_MAX = 17;
	enum ZSTD_SEARCHLOG_MAX = (ZSTD_WINDOWLOG_MAX-1);
	enum ZSTD_SEARCHLOG_MIN = 1;
	enum ZSTD_SEARCHLENGTH_MAX = 7;   /* only for ZSTD_fast, other strategies are limited to 6 */
	enum ZSTD_SEARCHLENGTH_MIN = 3;   /* only for ZSTD_btopt, other strategies are limited to 4 */
	enum ZSTD_TARGETLENGTH_MAX = ZSTD_BLOCKSIZE_MAX;
	enum ZSTD_TARGETLENGTH_MIN = 0;   /* note : comparing this constant to an unsigned results in a tautological test */
	enum ZSTD_LDM_MINMATCH_MAX = 4096;
	enum ZSTD_LDM_MINMATCH_MIN = 4;
	enum ZSTD_LDM_BUCKETSIZELOG_MAX = 8;
	enum ZSTD_FRAMEHEADERSIZE_PREFIX = 5;   /* minimum input size to know frame header size */
	enum ZSTD_FRAMEHEADERSIZE_MIN = 6;
	enum ZSTD_FRAMEHEADERSIZE_MAX = 18;   /* for static allocation */
	static const size_t ZSTD_frameHeaderSize_prefix = ZSTD_FRAMEHEADERSIZE_PREFIX;
	static const size_t ZSTD_frameHeaderSize_min = ZSTD_FRAMEHEADERSIZE_MIN;
	static const size_t ZSTD_frameHeaderSize_max = ZSTD_FRAMEHEADERSIZE_MAX;
	static const size_t ZSTD_skippableHeaderSize = 8;  /* magic number + skippable frame length */
	
	struct ZSTD_compressionParameters{
	    uint windowLog;      /**< largest match distance : larger == more compression, more memory needed during decompression */
	    uint chainLog;       /**< fully searched segment : larger == more compression, slower, more memory (useless for fast) */
	    uint hashLog;        /**< dispatch table : larger == faster, more memory */
	    uint searchLog;      /**< nb of searches : larger == more compression, slower */
	    uint searchLength;   /**< match length searched : larger == faster decompression, sometimes less compression */
	    uint targetLength;   /**< acceptable match size for optimal parser (only) : larger == more compression, slower */
	    ZSTD_strategy strategy;
	} 
	struct ZSTD_frameParameters{
    	uint contentSizeFlag; /**< 1: content size will be in frame header (when known) */
    	uint checksumFlag;    /**< 1: generate a 32-bits checksum at end of frame, for error detection */
    	uint noDictIDFlag;    /**< 1: no dictID will be saved into frame header (if dictionary compression) */
	} 
	struct ZSTD_parameters{
	    ZSTD_compressionParameters cParams;
    	ZSTD_frameParameters fParams;
	}
	struct ZSTD_CCtx_params_s{

	}
	alias ZSTD_CCtx_params = ZSTD_CCtx_params_s;
	enum ZSTD_dictContentType_e {
    	ZSTD_dct_auto=0,      /* dictionary is "full" when starting with ZSTD_MAGIC_DICTIONARY, otherwise it is "rawContent" */
    	ZSTD_dct_rawContent,  /* ensures dictionary is always loaded as rawContent, even if it starts with ZSTD_MAGIC_DICTIONARY */
    	ZSTD_dct_fullDict     /* refuses to load a dictionary if it does not respect Zstandard's specification */
	}
	enum ZSTD_dictLoadMethod_e {
	    ZSTD_dlm_byCopy = 0, /**< Copy dictionary content internally */
	    ZSTD_dlm_byRef,      /**< Reference dictionary content -- the dictionary buffer must outlive its users. */
	}
	size_t ZSTD_findFrameCompressedSize(const(void)* src, size_t srcSize);
	ulong ZSTD_findDecompressedSize(const(void)* src, size_t srcSize);
	size_t ZSTD_frameHeaderSize(const(void)* src, size_t srcSize);
	//size_t ZSTD_sizeof_CCtx(const(ZSTD_CCtx)* cctx);
	//size_t ZSTD_sizeof_DCtx(const(ZSTD_DCtx)* dctx);
	//size_t ZSTD_sizeof_CStream(const(ZSTD_CStream)* zcs);
	//size_t ZSTD_sizeof_DStream(const(ZSTD_DStream)* zds);
	//size_t ZSTD_sizeof_CDict(const(ZSTD_CDict)* cdict);
	//size_t ZSTD_sizeof_DDict(const(ZSTD_DDict)* ddict);
	size_t ZSTD_estimateCCtxSize(int compressionLevel);
	size_t ZSTD_estimateCCtxSize_usingCParams(ZSTD_compressionParameters cParams);
	size_t ZSTD_estimateCCtxSize_usingCCtxParams(const(ZSTD_CCtx_params)* params);
	size_t ZSTD_estimateDCtxSize();
	size_t ZSTD_estimateCStreamSize(int compressionLevel);
	size_t ZSTD_estimateCStreamSize_usingCParams(ZSTD_compressionParameters cParams);
	size_t ZSTD_estimateCStreamSize_usingCCtxParams(const(ZSTD_CCtx_params)* params);
	size_t ZSTD_estimateDStreamSize(size_t windowSize);
	size_t ZSTD_estimateDStreamSize_fromFrame(const(void)* src, size_t srcSize);
	size_t ZSTD_estimateCDictSize(size_t dictSize, int compressionLevel);
	size_t ZSTD_estimateCDictSize_advanced(size_t dictSize, ZSTD_compressionParameters cParams, ZSTD_dictLoadMethod_e dictLoadMethod);
	size_t ZSTD_estimateDDictSize(size_t dictSize, ZSTD_dictLoadMethod_e dictLoadMethod);
	ZSTD_CCtx* ZSTD_initStaticCCtx(void* workspace, size_t workspaceSize);
	ZSTD_CStream* ZSTD_initStaticCStream(void* workspace, size_t workspaceSize);
	ZSTD_DCtx*    ZSTD_initStaticDCtx(void* workspace, size_t workspaceSize);
	ZSTD_DStream* ZSTD_initStaticDStream(void* workspace, size_t workspaceSize);
	const(ZSTD_CDict)* ZSTD_initStaticCDict(void* workspace, size_t workspaceSize, const(void)* dict, size_t dictSize, 
			ZSTD_dictLoadMethod_e dictLoadMethod, ZSTD_dictContentType_e dictContentType, ZSTD_compressionParameters cParams);
	const(ZSTD_DDict)* ZSTD_initStaticDDict(void* workspace, size_t workspaceSize, const (void)* dict, size_t dictSize,
			ZSTD_dictLoadMethod_e dictLoadMethod, ZSTD_dictContentType_e dictContentType);
	alias ZSTD_allocFunction = void* function(void* opaque, size_t size);
	alias ZSTD_freeFunction = void function(void* opaque, void* address);
	struct ZSTD_customMem { 
		ZSTD_allocFunction customAlloc; 
		ZSTD_freeFunction customFree; 
		void* opaque; 
	} 
	static const ZSTD_customMem ZSTD_defaultCMem = ZSTD_customMem(null, null, null);
	ZSTD_CCtx*    ZSTD_createCCtx_advanced(ZSTD_customMem customMem);
	ZSTD_CStream* ZSTD_createCStream_advanced(ZSTD_customMem customMem);
	ZSTD_DCtx*    ZSTD_createDCtx_advanced(ZSTD_customMem customMem);
	ZSTD_DStream* ZSTD_createDStream_advanced(ZSTD_customMem customMem);
	ZSTD_CDict* ZSTD_createCDict_advanced(const(void)* dict, size_t dictSize, ZSTD_dictLoadMethod_e dictLoadMethod,
			ZSTD_dictContentType_e dictContentType, ZSTD_compressionParameters cParams, ZSTD_customMem customMem);
	ZSTD_DDict* ZSTD_createDDict_advanced(const(void)* dict, size_t dictSize, ZSTD_dictLoadMethod_e dictLoadMethod,
			ZSTD_dictContentType_e dictContentType, ZSTD_customMem customMem);
	ZSTD_CDict* ZSTD_createCDict_byReference(const(void)* dictBuffer, size_t dictSize, int compressionLevel);
	ZSTD_compressionParameters ZSTD_getCParams(int compressionLevel, ulong estimatedSrcSize, size_t dictSize);
	ZSTD_parameters ZSTD_getParams(int compressionLevel, ulong estimatedSrcSize, size_t dictSize);
	size_t ZSTD_checkCParams(ZSTD_compressionParameters params);
	ZSTD_compressionParameters ZSTD_adjustCParams(ZSTD_compressionParameters cPar, ulong srcSize, size_t dictSize);
	size_t ZSTD_compress_advanced (ZSTD_CCtx* cctx, void* dst, size_t dstCapacity, const(void)* src, size_t srcSize,
			const(void)* dict, size_t dictSize, ZSTD_parameters params);
	size_t ZSTD_compress_usingCDict_advanced(ZSTD_CCtx* cctx, void* dst, size_t dstCapacity, const(void)* src, size_t srcSize,
			const(ZSTD_CDict)* cdict, ZSTD_frameParameters fParams);
	uint ZSTD_isFrame(const(void)* buffer, size_t size);
	ZSTD_DDict* ZSTD_createDDict_byReference(const(void)* dictBuffer, size_t dictSize);
	//uint ZSTD_getDictID_fromDict(const(void)* dict, size_t dictSize);
	//uint ZSTD_getDictID_fromDDict(const(ZSTD_DDict)* ddict);
	uint ZSTD_getDictID_fromFrame(const(void)* src, size_t srcSize);
	size_t ZSTD_initCStream_srcSize(ZSTD_CStream* zcs, int compressionLevel, ulong pledgedSrcSize);  
	size_t ZSTD_initCStream_usingDict(ZSTD_CStream* zcs, const(void)* dict, size_t dictSize, int compressionLevel);
	size_t ZSTD_initCStream_advanced(ZSTD_CStream* zcs, const(void)* dict, size_t dictSize, ZSTD_parameters params, 
			ulong pledgedSrcSize);
	size_t ZSTD_initCStream_usingCDict(ZSTD_CStream* zcs, const(ZSTD_CDict)* cdict);
	size_t ZSTD_initCStream_usingCDict_advanced(ZSTD_CStream* zcs, const(ZSTD_CDict)* cdict, ZSTD_frameParameters fParams, 
			ulong pledgedSrcSize);
	size_t ZSTD_resetCStream(ZSTD_CStream* zcs, ulong pledgedSrcSize);
	struct ZSTD_frameProgression{
		ulong ingested;   /* nb input bytes read and buffered */
		ulong consumed;   /* nb input bytes actually compressed */
		ulong produced;   /* nb of compressed bytes generated and buffered */
		ulong flushed;    /* nb of compressed bytes flushed : not provided; can be tracked from caller side */
		uint currentJobID;         /* MT only : latest started job nb */
		uint nbActiveWorkers;      /* MT only : nb of workers actively compressing at probe time */
	}
	ZSTD_frameProgression ZSTD_getFrameProgression(const(ZSTD_CCtx)* cctx);
	size_t ZSTD_toFlushNow(ZSTD_CCtx* cctx);
	enum ZSTD_DStreamParameter_e{ 
		DStream_p_maxWindowSize 
	}
	size_t ZSTD_setDStreamParameter(ZSTD_DStream* zds, ZSTD_DStreamParameter_e paramType, uint paramValue);   /* obsolete : this API will be removed in a future version */
	size_t ZSTD_initDStream_usingDict(ZSTD_DStream* zds, const(void)* dict, size_t dictSize); /**< note: no dictionary will be used if dict == NULL or dictSize < 8 */
	size_t ZSTD_initDStream_usingDDict(ZSTD_DStream* zds, const(ZSTD_DDict)* ddict);  /**< note : ddict is referenced, it must outlive decompression session */
	size_t ZSTD_resetDStream(ZSTD_DStream* zds);  /**< re-use decompression parameters from previous init; saves dictionary loading */
	size_t ZSTD_compressBegin(ZSTD_CCtx* cctx, int compressionLevel);
	size_t ZSTD_compressBegin_usingDict(ZSTD_CCtx* cctx, const(void)* dict, size_t dictSize, int compressionLevel);
	size_t ZSTD_compressBegin_advanced(ZSTD_CCtx* cctx, const(void)* dict, size_t dictSize, ZSTD_parameters params, 
			ulong pledgedSrcSize); /**< pledgedSrcSize : If srcSize is not known at init time, use ZSTD_CONTENTSIZE_UNKNOWN */
	size_t ZSTD_compressBegin_usingCDict(ZSTD_CCtx* cctx, const ZSTD_CDict* cdict); /**< note: fails if cdict==NULL */
	size_t ZSTD_compressBegin_usingCDict_advanced(const(ZSTD_CCtx)* cctx, const ZSTD_CDict* cdict, const ZSTD_frameParameters 
			fParams, const ulong pledgedSrcSize);   /* compression parameters are already set within cdict. pledgedSrcSize must be correct. If srcSize is not known, use macro ZSTD_CONTENTSIZE_UNKNOWN */
	size_t ZSTD_copyCCtx(ZSTD_CCtx* cctx, const ZSTD_CCtx* preparedCCtx, ulong pledgedSrcSize); /**<  note: if pledgedSrcSize is not known, use ZSTD_CONTENTSIZE_UNKNOWN */
	size_t ZSTD_compressContinue(ZSTD_CCtx* cctx, void* dst, size_t dstCapacity, const(void)* src, size_t srcSize);
	size_t ZSTD_compressEnd(ZSTD_CCtx* cctx, void* dst, size_t dstCapacity, const(void)* src, size_t srcSize);
	enum ZSTD_frameType_e { ZSTD_frame, ZSTD_skippableFrame }
	struct ZSTD_frameHeader{
		ulong frameContentSize; /* if == ZSTD_CONTENTSIZE_UNKNOWN, it means this field is not available. 0 means "empty" */
		ulong windowSize;       /* can be very large, up to <= frameContentSize */
		uint blockSizeMax;
		ZSTD_frameType_e frameType;          /* if == ZSTD_skippableFrame, frameContentSize is the size of skippable content */
		uint headerSize;
		uint dictID;
		uint checksumFlag;
	}
	size_t ZSTD_getFrameHeader(ZSTD_frameHeader* zfhPtr, const(void)* src, size_t srcSize);   /**< doesn't consume input */
	size_t ZSTD_decodingBufferSize_min(ulong windowSize, ulong frameContentSize);  /**< when frame content size is not known, pass in frameContentSize == ZSTD_CONTENTSIZE_UNKNOWN */
	size_t ZSTD_decompressBegin(ZSTD_DCtx* dctx);
	size_t ZSTD_decompressBegin_usingDict(ZSTD_DCtx* dctx, const(void)* dict, size_t dictSize);
	size_t ZSTD_decompressBegin_usingDDict(ZSTD_DCtx* dctx, const(ZSTD_DDict)* ddict);
	size_t ZSTD_nextSrcSizeToDecompress(ZSTD_DCtx* dctx);
	size_t ZSTD_decompressContinue(ZSTD_DCtx* dctx, void* dst, size_t dstCapacity, const(void)* src, size_t srcSize);
	void ZSTD_copyDCtx(ZSTD_DCtx* dctx, const(ZSTD_DCtx)* preparedDCtx);
	enum ZSTD_nextInputType_e{ 
		ZSTDnit_frameHeader, 
		ZSTDnit_blockHeader, 
		ZSTDnit_block, 
		ZSTDnit_lastBlock, 
		ZSTDnit_checksum, 
		ZSTDnit_skippableFrame 
	} 
	ZSTD_nextInputType_e ZSTD_nextInputType(ZSTD_DCtx* dctx);
	//Section under new advanced API is not supported at the moment.
}else{
	extern(C) @nogc nothrow {
		alias pZSTD_versionNumber = uint function();
		alias pZSTD_versionString = const(char)* function();
		alias pZSTD_compress = size_t function(void* dst, size_t dstCapacity, const(void)* src, size_t srcSize, 
				int compressionLevel);
		alias pZSTD_decompress = size_t function(void* dst, size_t dstCapacity, const(void)* src, size_t compressedSize);
		alias pZSTD_getFrameContentSize = ulong function(const(void)* src, size_t srcSize);
		alias pZSTD_getDecompressedSize = ulong function(const(void)* src, size_t srcSize);
		alias pZSTD_compressBound = size_t function(size_t srcSize);
		alias pZSTD_isError = uint function(size_t code);         
		alias pZSTD_getErrorName = const(char)* function(size_t code);    
		alias pZSTD_maxCLevel = int function();
		alias pZSTD_createCCtx = ZSTD_CCtx* function();
		alias pZSTD_freeCCtx = size_t function(ZSTD_CCtx* cctx);
		alias pZSTD_compressCCtx = size_t function(ZSTD_CCtx* ctx, void* dst, size_t dstCapacity, const(void)* src, 
				size_t srcSize, int compressionLevel);
		alias pZSTD_createDCtx = ZSTD_DCtx* function();
		alias pZSTD_freeDCtx = size_t function(ZSTD_DCtx* dctx);
		alias pZSTD_decompressDCtx = size_t function(ZSTD_DCtx* ctx, void* dst, size_t dstCapacity, const(void)* src, 
				size_t srcSize);
		alias pZSTD_compress_usingDict = size_t function(ZSTD_CCtx* ctx, void* dst, size_t dstCapacity, const(void)* src, 
				size_t srcSize, const(void)* dict,size_t dictSize, int compressionLevel);
		alias pZSTD_decompress_usingDict = size_t function(ZSTD_DCtx* dctx, void* dst, size_t dstCapacity, const(void)* src, 
				size_t srcSize, const(void)* dict,size_t dictSize);
		alias pZSTD_createCDict = ZSTD_CDict* function(const(void)* dictBuffer, size_t dictSize, int compressionLevel);
		alias pZSTD_freeCDict = size_t function(ZSTD_CDict* CDict);
		alias pZSTD_compress_usingCDict = size_t function(ZSTD_CCtx* cctx, void* dst, size_t dstCapacity, const(void)* src, 
				size_t srcSize, const(ZSTD_CDict)* cdict);
		alias pZSTD_createDDict = ZSTD_DDict* function(const(void)* dictBuffer, size_t dictSize);
		alias pZSTD_freeDDict = size_t function(ZSTD_DDict* ddict);
		alias pZSTD_decompress_usingDDict = size_t function(ZSTD_DCtx* dctx, void* dst, size_t dstCapacity, const(void)* src, 
				size_t srcSize,	const(ZSTD_DDict)* ddict);
		alias pZSTD_createCStream = ZSTD_CStream* function();
		alias pZSTD_freeCStream = size_t function(ZSTD_CStream* zcs);
		alias pZSTD_initCStream = size_t function(ZSTD_CStream* zcs, int compressionLevel);
		alias pZSTD_compressStream = size_t function(ZSTD_CStream* zcs, ZSTD_outBuffer* output, ZSTD_inBuffer* input);
		alias pZSTD_flushStream = size_t function(ZSTD_CStream* zcs, ZSTD_outBuffer* output);
		alias pZSTD_endStream = size_t function(ZSTD_CStream* zcs, ZSTD_outBuffer* output);
		alias pZSTD_CStreamInSize = size_t function();
		alias pZSTD_CStreamOutSize = size_t function();
		alias pZSTD_createDStream = ZSTD_DStream* function();
		alias pZSTD_freeDStream = size_t function(ZSTD_DStream* zds);
		alias pZSTD_initDStream = size_t function(ZSTD_DStream* zds);
		alias pZSTD_decompressStream = size_t function(ZSTD_DStream* zds, ZSTD_outBuffer* output, ZSTD_inBuffer* input);
		alias pZSTD_DStreamInSize = size_t function();
		alias pZSTD_DStreamOutSize = size_t function();
		version(zstd1_04){
			alias pZSTD_compressStream2 = size_t function(STD_CCtx* cctx, ZSTD_outBuffer* output, ZSTD_inBuffer* input, 
					ZSTD_EndDirective endOp);

			alias pZSTD_cParam_getBounds = ZSTD_bounds function(ZSTD_cParameter cParam);
			alias pZSTD_CCtx_setParameter = size_t function(ZSTD_CCtx* cctx, ZSTD_cParameter param, int value);
			alias pZSTD_CCtx_setPledgedSrcSize = size_t function(ZSTD_CCtx* cctx, ulong pledgedSrcSize);
			alias pZSTD_CCtx_reset = size_t function(ZSTD_CCtx* cctx, ZSTD_ResetDirective reset);
			alias pZSTD_compress2 = size_t function( ZSTD_CCtx* cctx, void* dst, size_t dstCapacity, const(void)* src, size_t srcSize);
			alias pZSTD_getDictID_fromDict = uint function(const(void)* dict, size_t dictSize);
			alias pZSTD_getDictID_fromDDict = uint function(const(ZSTD_DDict)* ddict);
			alias pZSTD_CCtx_loadDictionary = size_t function(ZSTD_CCtx* cctx, const(void)* dict, size_t dictSize);
			alias pZSTD_DCtx_reset = size_t function(ZSTD_DCtx* dctx, ZSTD_ResetDirective reset);
			alias pZSTD_CCtx_refCDict = size_t function(ZSTD_CCtx* cctx, const(ZSTD_CDict)* cdict);
			alias pZSTD_CCtx_refPrefix = size_t function(ZSTD_CCtx* cctx, const(void*) prefix, size_t prefixSize);
			alias pZSTD_DCtx_loadDictionary = size_t function(ZSTD_DCtx* dctx, const(void)* dict, size_t dictSize);
			alias pZSTD_DCtx_refDDict = size_t function(ZSTD_DCtx* dctx, const(ZSTD_DDict)* ddict);
			alias pZSTD_DCtx_refPrefix = size_t function(ZSTD_DCtx* dctx, const(void)* prefix, size_t prefixSize);
			alias pZSTD_sizeof_CCtx = size_t function(const ZSTD_CCtx* cctx);
			alias pZSTD_sizeof_DCtx = size_t function(const ZSTD_DCtx* dctx);
			alias pZSTD_sizeof_CStream = size_t function(const ZSTD_CStream* zcs);
			alias pZSTD_sizeof_DStream = size_t function(const ZSTD_DStream* zds);
			alias pZSTD_sizeof_CDict = size_t function(const ZSTD_CDict* cdict);
			alias pZSTD_sizeof_DDict = size_t function(const ZSTD_DDict* ddict);
		}
	}

	__gshared {
		pZSTD_versionNumber ZSTD_versionNumber;
		pZSTD_versionString ZSTD_versionString;
		pZSTD_compress ZSTD_compress;
		pZSTD_decompress ZSTD_decompress;
		pZSTD_getFrameContentSize ZSTD_getFrameContentSize;
		pZSTD_getDecompressedSize ZSTD_getDecompressedSize;
		pZSTD_compressBound ZSTD_compressBound;
		pZSTD_isError ZSTD_isError;
		pZSTD_getErrorName ZSTD_getErrorName;
		pZSTD_maxCLevel ZSTD_maxCLevel;
		pZSTD_createCCtx ZSTD_createCCtx;
		pZSTD_freeCCtx ZSTD_freeCCtx;
		pZSTD_compressCCtx ZSTD_compressCCtx;
		pZSTD_createDCtx ZSTD_createDCtx;
		pZSTD_freeDCtx ZSTD_freeDCtx;
		pZSTD_decompressDCtx ZSTD_decompressDCtx;
		pZSTD_compress_usingDict ZSTD_compress_usingDict;
		pZSTD_decompress_usingDict ZSTD_decompress_usingDict;
		pZSTD_createCDict ZSTD_createCDict;
		pZSTD_freeCDict ZSTD_freeCDict;
		pZSTD_compress_usingCDict ZSTD_compress_usingCDict;
		pZSTD_createDDict ZSTD_createDDict;
		pZSTD_freeDDict ZSTD_freeDDict;
		pZSTD_decompress_usingDDict ZSTD_decompress_usingDDict;
		pZSTD_createCStream ZSTD_createCStream;
		pZSTD_freeCStream ZSTD_freeCStream;
		pZSTD_initCStream ZSTD_initCStream;
		pZSTD_compressStream ZSTD_compressStream;
		pZSTD_flushStream ZSTD_flushStream;
		pZSTD_endStream ZSTD_endStream;
		pZSTD_CStreamInSize ZSTD_CStreamInSize;
		pZSTD_CStreamOutSize ZSTD_CStreamOutSize;
		pZSTD_createDStream ZSTD_createDStream;
		pZSTD_freeDStream ZSTD_freeDStream;
		pZSTD_initDStream ZSTD_initDStream;
		pZSTD_decompressStream ZSTD_decompressStream;
		pZSTD_DStreamInSize ZSTD_DStreamInSize;
		pZSTD_DStreamOutSize ZSTD_DStreamOutSize;
		version(zstd1_04){
			pZSTD_compressStream2 ZSTD_compressStream2;

			pZSTD_cParam_getBounds ZSTD_cParam_getBounds;
			pZSTD_CCtx_setParameter ZSTD_CCtx_setParameter;
			pZSTD_CCtx_setPledgedSrcSize ZSTD_CCtx_setPledgedSrcSize;
			pZSTD_CCtx_reset ZSTD_CCtx_reset;
			pZSTD_compress2 ZSTD_compress2;
			pZSTD_getDictID_fromDict ZSTD_getDictID_fromDict;
			pZSTD_getDictID_fromDDict ZSTD_getDictID_fromDDict;
			pZSTD_CCtx_loadDictionary ZSTD_CCtx_loadDictionary;
			pZSTD_DCtx_reset ZSTD_DCtx_reset;
			pZSTD_CCtx_refCDict ZSTD_CCtx_refCDict;
			pZSTD_CCtx_refPrefix ZSTD_CCtx_refPrefix;
			pZSTD_DCtx_loadDictionary ZSTD_DCtx_loadDictionary;
			pZSTD_DCtx_refDDict ZSTD_DCtx_refDDict;
			pZSTD_DCtx_refPrefix ZSTD_DCtx_refPrefix;
			pZSTD_sizeof_CCtx ZSTD_sizeof_CCtx;
			pZSTD_sizeof_DCtx ZSTD_sizeof_DCtx;
			pZSTD_sizeof_CStream ZSTD_sizeof_CStream;
			pZSTD_sizeof_DStream ZSTD_sizeof_DStream;
			pZSTD_sizeof_CDict ZSTD_sizeof_CDict;
			pZSTD_sizeof_DDict ZSTD_sizeof_DDict;
		}
	}
}