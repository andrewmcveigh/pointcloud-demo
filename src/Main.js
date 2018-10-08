
exports["undefined"] = function(x) { throw new Error("undefined"); }
exports.spy = function(x) { console.log(x); return x; }
