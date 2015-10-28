package tannus.messaging;

import tannus.ds.Object;

enum ChannelMessage {
	Normal(data : Object);
	StreamOpen(data : Object);
}
