module bindbc.zstandard.config;

// TODO: Add version checking.
enum ZSTDSupport{
	noLibrary,
	badLibrary,
	ZSTD1_3_7	=	1_03_07,
}