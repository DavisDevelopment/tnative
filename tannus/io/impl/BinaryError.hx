package tannus.io.impl;

enum BinaryError {
	Overflow;
	OutOfBounds;
	Custom(error : Dynamic);
}
