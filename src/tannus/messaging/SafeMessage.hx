package tannus.messaging;

import tannus.messaging.Message;
import tannus.messaging.MessageType;

typedef SafeMessage = {
	var id : String;
	var sender_id : String;
	var type : MessageType;
	var channel : String;
	var data : String;
};
