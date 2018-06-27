package tannus.csv;

using StringTools;
using tannus.ds.StringUtils;
using tannus.FunctionTools;

/**
  CSV format parser
 **/
class Parser {
    /* Constructor Function */
    public function new(delimiter:String, quote:String, escapedQuote:String):Void {
        this.delimiter = delimiter;
        this.quote = quote;
        this.escapedQuote = escapedQuote;
    }

    /**
      parse the given String as CSV
     **/
    public function parse(s : String):Array<Array<String>> {
        /* initialize properties */
        this.s = s;
        result = new Array();
        row = new Array();
        pos = 0;
        len = s.length;
        buffer = new StringBuf();
        
        delimiterLength = delimiter.length;
        quoteLength = quote.length;
        escapedQuoteLength = escapedQuote.length;

        /* initialize loop */
        try {
            loop();
        } 
        catch(e : Dynamic) {
            throw new thx.Error('unable to parse at pos $pos: ${Std.string(e)}');
        }

        /* finalize results */
        pushCell();
        pushRow();

        return result;
    }

    /**
      push current buffer onto row stack and reset it
     **/
    inline function pushCell() {
        row.push(buffer.toString());
        buffer = new StringBuf();
    }

    /**
      push [char] onto [buffer]
     **/
    inline function pushBuffer(char: String) {
        buffer.add(char);
    }

    /**
      push current row-stack into results
     **/
    inline function pushRow() {
        result.push(row);
        row = [];
    }

    /**
      main body of the Parser
      [TODO] reimplement this logic using a [haxe.io.Input] as data-source
     **/
    inline function loop() {
        var t: String;
        while (pos < len) {
            if (s.substring(pos, pos + quoteLength) == quote && buffer.length == 0) {
                pos += quoteLength;
                // loopWithinQuotes
                while (pos < len) {
                    if (s.substring(pos, pos + escapedQuoteLength) == escapedQuote) {
                        pushBuffer(quote);
                        pos += escapedQuoteLength;
                    } 
                    else if (s.substring(pos, pos + quoteLength) == quote) {
                        pos += quoteLength;
                        var next = s.substring(pos, pos + 1);
                        while (next == " " || (delimiter != "\t" && next == "\t")) {
                            ++pos;
                            next = s.substring(pos, pos + 1);
                        }
                        break;
                    } 
                    else {
                        pushBuffer(s.substring(pos, pos + 1));
                        ++pos;
                    }
                }
            }
            else if (s.substring(pos, pos + delimiterLength) == delimiter) {
                pushCell();
                pos += delimiterLength;
            } 
            else {
                t = s.substring(pos, pos + 2);
                if (t == '\n\r' || t == '\r\n') {
                    pos += 2;
                    pushCell();
                    pushRow();
                    continue;
                }
                t = s.substring(pos, pos + 1);
                if (t == '\n' || t == '\r') {
                    ++pos;
                    pushCell();
                    pushRow();
                    continue;
                }
                pushBuffer(s.substring(pos, pos + 1));
                ++pos;
            }
        }
    }

    /**
      obtain a substring of [s]
     **/
    inline function sub(x:Int, y:Int):String {
        return s.substring(x, y);
    }

    /**
      obtain a substring of [s], with the [startIndex] and [endIndex] values calculated relative to [pos]
     **/
    inline function posub(x:Int, y:Int):String {
        return sub(pos+x, pos+y);
    }

/* === Fields === */

    var delimiter : String;
    var quote : String;
    var escapedQuote : String;

    var result : Array<Array<String>>;
    var pos : Int;
    var len : Int;
    var delimiterLength : Int;
    var quoteLength : Int;
    var escapedQuoteLength : Int;
    var buffer : StringBuf;
    var row : Array<String>;
    var s : String;
}
