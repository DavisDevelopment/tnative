package tannus.display;

/**
  * Interface to be used by all implementations of Image
  */
interface TImage {
	/* Dimensions of the Image */
	var width(get, never):Int;
	var height(get, never):Int;
}
