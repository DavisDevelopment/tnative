package tannus.csv;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;

class Dsv {
    /**
      parse/decode data from encoded delimiter-separated value String
     **/
    public static function decode(dsv:String, options:DsvDecodeOptions): Array<Array<String>> {
        if (null == options.quote) options.quote = '"';
        if (null == options.escapedQuote) options.escapedQuote = options.quote == '"' ? '""' : '\\${options.quote}';
        if (null == options.trimValues) options.trimValues = false;
        if (null == options.trimEmptyLines) options.trimEmptyLines = true;
        if ( options.trimEmptyLines )
            dsv = dsv.trimChars('\n\r');

        var result: Array<Array<String>> = new Array();
        dsv == "" ? [] : 
        if (dsv == '' || dsv.empty())
            //
        else
            result = new tannus.csv.Parser(options.delimiter, options.quote, options.escapedQuote).parse( dsv );

        if ( options.trimValues ) {
            for (row in result) {
                for (i in 0...row.length) {
                    row[i] = row[i].trim();
                }
            }
        }

        return result;
    }

    /**
      parse anonymous object structures from the given DSV string
     **/
    public static function decodeObjects(dsv:String, options:DsvDecodeOptions):Array<{}> {
        return arrayToObjects(decode(dsv, options));
    }

    /**
      convert 2x2 array of strings
       => string[][]
      into an array of objects
       => Anon<Any>[]
     **/
    public static function arrayToObjects(arr: Array<Array<String>>):Array<{}> {
        var columns = arr[0];
        if (null == columns)
            return [];
        
        var result = [],
        len = columns.length,
        row,
        ob;

        for (r in 1...arr.length) {
            ob = {};
            row = arr[r];
            for (i in 0...len) {
                Reflect.setField(ob, columns[i], row[i]);
            }
            result.push( ob );
        }

        return result;
    }

    public static function encode(data : Array<Array<String>>, options : DsvEncodeOptions) : String {
        if (null == options.quote) 
            options.quote = '"';
        if (null == options.escapedQuote) 
            options.escapedQuote = (options.quote == '"' ? '""' : '\\${options.quote}');
        if (null == options.newline) 
            options.newline = '\n';

        return data.map(function(row) {
            return row.map(function(cell) {
                if (requiresQuotes(cell, options.delimiter, options.quote))
                    return applyQuotes(cell, options.quote, options.escapedQuote);
                else
                    return cell;
            })
            .join( options.delimiter );
        }).join( options.newline );
    }

    public static function encodeObjects(data:Array<{}>, options:DsvEncodeOptions):String {
        return encode(objectsToArray(data, []), options);
    }

    public static function objectsToArray(objects:Array<{}>, ?columns:Array<String>):Array<Array<String>> {
        if (null == columns)
            return objectsToArray(objects, []);

        var map:Map<String, Int> = new Map(),
        result:Array<Array<String>> = [columns],
        collector,
        row;

        for (i in 0...columns.length) {
            map.set(columns[i], i);
        }

        for (object in objects) {
            collector = [];
            row = [];
            for (field in Reflect.fields( object )) {
                var index = map.get( field );
                if (null == index) {
                    collector.push( field );
                }
                else {
                    row[index] = Reflect.field(object, field);
                }
            }
            if (collector.length > 0) {
                // restarts with the new columns
                return objectsToArray(objects, columns.concat( collector ));
            }
            else {
                result.push( row );
            }
        }
        return result;
    }

    /**
      check whether [value] needs to be quoted
     **/
    static inline function requiresQuotes(value:String, delimiter:String, quote:String):Bool {
        return (value.contains(delimiter) || value.contains(quote) || value.contains('\n') || value.contains('\r'));
    }

    static inline function applyQuotes(value:String, quote:String, escapedQuote:String):String {
        value = value.replace(quote, escapedQuote);
        return '$quote$value$quote';
    }
}

typedef DsvEncodeOptions = {
    delimiter : String,
    ?quote : String,
    ?escapedQuote : String,
    ?newline : String
}

typedef DsvDecodeOptions = {
    delimiter : String,
    ?quote : String,
    ?escapedQuote : String,
    ?trimValues : Bool,
    ?trimEmptyLines : Bool
}
