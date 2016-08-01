package tannus.msg;

interface Modem<In, Out> {
	function encode(input : In):Out;
	function decode(output : Out):In;
}
