function stringFromDartString(string) {
    var length = dartInstance.exports.$stringLength(string);
    var array = new Array(length);
    for (var i = 0; i < length; i++) {
        array[i] = dartInstance.exports.$stringRead(string, i);
    }
    return String.fromCharCode(...array);
}

function stringToDartString(string) {
    var length = string.length;
    var range = 0;
    for (var i = 0; i < length; i++) {
        range |= string.codePointAt(i);
    }
    if (range < 256) {
        var dartString = dartInstance.exports.$stringAllocate1(length);
        for (var i = 0; i < length; i++) {
            dartInstance.exports.$stringWrite1(dartString, i, string.codePointAt(i));
        }
        return dartString;
    } else {
        var dartString = dartInstance.exports.$stringAllocate2(length);
        for (var i = 0; i < length; i++) {
            dartInstance.exports.$stringWrite2(dartString, i, string.codePointAt(i));
        }
        return dartString;
    }
}

// Converts a JS array to a Dart List, and also recursively converts the items
// in the array.
function arrayToDartList(array, allocator, adder) {
    var length = array.length;
    var dartList = dartInstance.exports.$listAllocate();
    for (var i = 0; i < length; i++) {
        dartInstance.exports.$listAdd(dartList, array[i]);
    }
    return dartList;
}

// Converts a Dart List to a JS array. Any Dart objects will be converted, but
// this will be cheap for JSValues.
function arrayFromDartList(list, reader) {
    var length = dartInstance.exports.$listLength(list);
    var array = new Array(length);
    for (var i = 0; i < length; i++) {
        array[i] = dartInstance.exports.$listRead(list, i);
    }
    return array;
}

// Recursively converts a JS object into a Dart object.
function dartify(object) {
    if (typeof object === "string") {
        return stringToDartString(object);
    } else if (object instanceof Array) {
        return arrayToDartList(object);
    } else {
        return object;
    }
}

// Imports for printing and event loop
var dart2wasm = {
    printToConsole: function(string) {
        console.log(stringFromDartString(string))
    },
    scheduleCallback: function(milliseconds, closure) {
        setTimeout(function() {
            dartInstance.exports.$call0(closure);
        }, milliseconds);
    },
    getCurrentStackTrace: function() {
        // [Error] should be supported in most browsers.
        // A possible future optimization we could do is to just save the
        // `Error` object here, and stringify the stack trace when it is
        // actually used.
        let stackString = new Error().stack.toString();

        // We remove the last three lines of the stack trace to prevent including
        // `Error`, `getCurrentStackTrace`, and `StackTrace.current` in the
        // stack trace.
        let userStackString = stackString.split('\n').slice(3).join('\n');
        return stringToDartString(userStackString);
    },
    arrayFromDartList: arrayFromDartList,
    arrayToDartList: arrayToDartList,
    stringFromDartString: stringFromDartString,
    stringToDartString: stringToDartString,
    dartify: dartify,
    newObject: function() {
        return {};
    },
    globalThis: function() {
        return globalThis;
    },
    getProperty: function(object, name) {
        return object[name];
    },
    hasProperty: function(object, name) {
        return name in object;
    },
    setProperty: function(object, name, value) {
        return object[name] = value;
    },
    callMethodVarArgs: function(object, name, args) {
        return object[name].apply(object, args);
    },
    callConstructorVarArgs: function(object, name, args) {
        // Gets a constructor property at object[name], and apply bind to the
        // constructor. We pass `null` as the first argument to `bind.apply`
        // because this is `bind`'s unused context argument(`new` will
        // explicitly create a new context).
        var constructor = object[name];
        var factoryFunction = constructor.bind.apply(constructor, [null, ...args]);
        return new factoryFunction();
    },
    eval: function(string) {
        eval(string);
    }
};
