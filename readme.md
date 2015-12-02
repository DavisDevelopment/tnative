
## TNative - Tannus v2.0
#### *Comprehensive toolkit for writing Applications in Haxe 3.2*

The aim of TNative is to provide the tools a developer will need to write applications in Haxe.  Currently, TNative has a focus on non-graphical desktop applications,
but I plan to write a `graphics` package which will at least target JavaScript and Flash in the near future.

---

### Roadmap:

- Unify Network access across _*all*_ relevant targets

### Features / Done

- Create Url type (`tannus.http.Url`) for extracting and manipulating data from url Strings
- Create UrlPattern type (`tannus.http.UrlPattern`) for describing/validating Urls
- Create GlobStar type (`tannus.sys.GlobStar`) for validating Paths
- Create QueryString type (`tannus.ds.QueryString`) for encoding/decoding http query strings
- Create Mime type (`tannus.sys.Mime`) for working with MIME-type Strings
- Create Mimes class (`tannus.sys.Mimes`) for getting MIME-types from extension-names and vice verse
- Unify FileSystem access across _*all*_ relevant targets
  + FileSystem class - `tannus.sys.FileSystem`
  + File type - `tannus.sys.File`
  + Directory type - `tannus.sys.Directory`
- Unify working with SubProcesses across _*all*_ relevant targets
- Create Path type (`tannus.sys.Path`) for analyzing and manipulating fileystem paths
- Create Promise (`tannus.ds.Promise`) system similar to that found in JavaScript
- Create ByteArray type (`tannus.io.ByteArray`) which can unify with _most_ binary data types
  + haxe.io.Bytes
  + flash.utils.ByteArray
  + js.html.UInt8Array
  + Node.js Buffer type
  + java.NativeArray<java.lang.Byte>
  + python.Bytearray
  + python.Bytes
- Create intuitive Pointer type (`tannus.io.Ptr`)
- Create Object type (`tannus.ds.Object`) for treating anonymous structures like Maps
- Create Signal system (`tannus.io.Signal` and `tannus.io.Signal2`)
- Create EventDispatcher class (`tannus.io.EventDispatcher`)
