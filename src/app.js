(function (console) { "use strict";
var App = function() { };
App.main = function() {
	console.log("Hello, World!");
};
App.main();
})(typeof console != "undefined" ? console : {log:function(){}});
