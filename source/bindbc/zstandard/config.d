module bindbc.zstandard.config;

// TODO: Add version checking.
enum ZSTDSupport{
	noLibrary,
	badLibrary,
	ZSTD1_3	=	1_03,
	ZSTD1_4 =	1_04,
}