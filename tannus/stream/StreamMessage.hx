package tannus.stream;

enum StreamMessage<T> {
    Next(value: T);
    Error(error: Dynamic);
    Done;
}

typedef JsonEncodedStreamMessage<T> = {
    type: StreamMessageType,
    ?data: Dynamic
};

@:enum
abstract StreamMessageType (Int) from Int {
    var Done = 0;
    var Next = 1;
    var Error = 2;
}
