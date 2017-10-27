package tannus.encoding;

import haxe.extern.EitherType as Either;

import js.RegExp;
import js.html.Blob;
import js.html.File;
import js.html.FileList;
import js.html.ArrayBuffer;
import js.html.ArrayBufferView;
import js.html.DataView;
import js.html.Int8Array;
import js.html.Uint8Array;
import js.html.Uint8ClampedArray;
import js.html.Int16Array;
import js.html.Uint16Array;
import js.html.Int32Array;
import js.html.Uint32Array;
import js.html.Float32Array;
import js.html.Float64Array;
import js.html.ImageData;

//typedef StructuredCloneCompatible =  Either<Bool, Either<Float, Either<Int, Either<String, Either<Date, Either<Array<Dynamic>, Either<RegExp, Either<Blob, Either<File, Either<FileList, Either<ArrayBuffer, Either<ArrayBufferView, Either<Int8Array, Either<Uint8Array, Either<Uint8ClampedArray, Either<Int16Array, Either<Uint16Array, Either<Int32Array, Either<Uint32Array, Either<Float32Array, Either<Float64Array, ImageData>>>>>>>>>>>>>>>>>>>>>;
typedef StructuredCloneCompatible = Either<Either<Bool, Either<Float, Int>>, Either<Either<String, Either<Date, Array<Dynamic>>>, Either<Either<EReg, Either<RegExp, Blob>>, Either<Either<File, Either<FileList, ArrayBuffer>>, Either<Either<DataView, Either<Int8Array, Uint8Array>>, Either<Either<Uint8ClampedArray, Either<Int16Array, Uint16Array>>, Either<Either<Int32Array, Either<Uint32Array, Float32Array>>, Either<Float64Array, ImageData>>>>>>>>;
typedef JsonCompatible = Either<Either<Bool, Float>, Either<String, Array<Dynamic>>>;
typedef JsonIncompatible = Either<Either<EReg, Either<RegExp, Blob>>, Either<Either<File, FileList>, Either<Either<ArrayBuffer, ArrayBufferView>, Either<Either<Int8Array, Uint8Array>, Either<Either<Uint8ClampedArray, Int16Array>, Either<Either<Uint16Array, Int32Array>, Either<Either<Uint32Array, Float32Array>, Either<Float64Array, ImageData>>>>>>>>;
