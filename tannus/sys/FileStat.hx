package tannus.sys;

typedef FileStat = {
	/**
	  * The size (in byte length) of this file
	  */
	var size : Int;

	/**
	  * The last modification time for the file
	  */
	var mtime : Date;

	/**
	  * The date on which the file was created
	  */
	var ctime : Date;
}
