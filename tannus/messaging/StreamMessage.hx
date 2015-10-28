package tannus.messaging;

enum StreamMessage<T> {
	SData(v : T);
	SOpen;
	SClose;
}
