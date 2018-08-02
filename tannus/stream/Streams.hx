package tannus.stream;

import tannus.ds.dict.DictKey;
import tannus.ds.Pair;
import tannus.ds.Delta;
import tannus.ds.Lazy;
import tannus.ds.Ref;
import tannus.io.Signal;
import tannus.io.VoidSignal;

import tannus.async.Future;
import tannus.async.Promise;
import tannus.async.Result;
import tannus.async.AsyncError;
//import tannus.async.Broker;
import tannus.stream.Stream;

import tannus.math.TMath.*;
import tannus.math.IterRange;
import tannus.math.Random;

import haxe.ds.Option;
import haxe.ds.Either;
import haxe.Constraints.Function;
import haxe.extern.EitherType;

import Slambda.fn;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.ds.IteratorTools;
using tannus.FunctionTools;
using tannus.async.Result;
using tannus.async.OptionTools;
using tannus.async.Asyncs;
using tannus.stream.Tools;

class Streams { }
