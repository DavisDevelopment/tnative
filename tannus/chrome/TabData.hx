package tannus.chrome;

typedef TabData = {};

typedef TabCreateData = {
	?windowId : Int,
	?index : Int,
	?url : String,
	?active : Bool,
	?pinned : Bool,
	?openerTabId : Int
};

typedef TabUpdateData = {
	> TabCreateData,
	?highlighted : Bool,
	?muted : Bool
};
