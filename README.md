# bindbc-zstandard
Configurable dynamic and static binding to Facebook's zstandard compression library.

Created by Laszlo Szeremi (laszloszeremi@outlook.com https://twitter.com/ziltoid1991 https://ko-fi.com/D1D45NEN https://www.patreon.com/ShapeshiftingLizard)

# Current status

* DLL works without an issue under Windows.
* Other OSes are untested, and you'll need to specify the shared object files due to my lack of knowledge on their default locations. Feel free to make a pull request in that regard.
* 1.3.7 is the version it has matched for. Very likely to work with either newer or older versions of the dynamic library, might be a few issues with the static only versions.
* Certain static-only functions haven't been linked.