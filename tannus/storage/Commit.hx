package tannus.storage;

enum Commit {
	Create(key:String, value:Dynamic);
	Delete(key : String);
	Change(key:String, prev:Dynamic, next:Dynamic);
}
