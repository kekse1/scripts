// 
// Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
// https://kekse.biz/ https://github.com/kekse1/scripts/
// v0.4.3
// 
// Just a tiny function to *really* clone objects (etc.); .. with all types, not only JSON supported ones
// or so (sometimes the web referes to just `JSON.parse(JSON.stringify({}))`);
// 
// If you really start with an own `Map` instance (2nd parameter), you can even define to replace any
// occurence of some object with your own values. Functions are also cloned, if not native ones or
// `_function` argument is `false` (including all of their members, if any additional are defined under 'em).
//
// If an object got an own `.clone()` function, it will be used; and the same for the well-known `.cloneNode()`
// function of any `Node` in the browser.
//

//
const DEFAULT_CLONE_FUNCTION = false;

//
Reflect.defineProperty(Reflect, 'clone', { value: (_object, _map = null, _function = DEFAULT_CLONE_FUNCTION, ... _clone_args) => {
	if(!_map) _map = new Map(); else if(_map.has(_object)) return _map.get(_object); else if(!Reflect.isExtensible(_object)) return _object;
	else if(typeof _object === 'undefined' || _object === null) return _object; const keys = Reflect.ownKeys(_object);
	var cloneFunc; if(typeof _object.clone === 'function') cloneFunc = _object.clone.bind(_object, ... _clone_args); else if(typeof _object.cloneNode === 'function')
		cloneFunc = _object.cloneNode.bind(_object, true, ... _clone_args); else cloneFunc = null; if(cloneFunc === null && !Reflect.isExtensible(_object)) {
			_map.set(_object, _object); return _object; } const isArray = (cloneFunc !== null ? -1 : (Array.isArray(_object) ?
			_object.length : -1)); var result; if(cloneFunc !== null) { result = cloneFunc(); _map.set(_object, result); return result; }
	else if(isArray > -1) { result = new Array(isArray); for(var i = 0; i < _object.length; ++i) { keys.remove(i.toString()); result[i] = Reflect.clone(_object[i], _map, _function,
		... _clone_args); keys.remove('length'); }} else if(typeof _object === 'function') { if(Function.isNative(_object) || !_function) result = _object;
			else try { eval('result = ' + _object.toString()); } catch(_error) { result = _object; } keys.remove('length', 'name', 'arguments', 'caller', 'prototype'); }
	else if(Object.isNull(_object)) result = Object.create(null); else try { result = Object.create(Reflect.getPrototypeOf(_object)); }
	catch(_error) { result = {}; } _map.set(_object, result); _map.set(result, result); var desc; for(var i = 0; i < keys.length; ++i) {
		try { desc = Reflect.getOwnPropertyDescriptor(_object, keys[i]);
			if('value' in desc) { desc.value = Reflect.clone(desc.value, _map, _function, ... _clone_args); delete desc.get; delete desc.set; }
			else {	if(typeof desc.get === 'function') desc.get = Reflect.clone(desc.get, _map, _function, ... _clone_args); else delete desc.get;
				if(typeof desc.set === 'function') desc.set = Reflect.clone(desc.set, _map, _function, ... _clone_args); else delete desc.set; }
		} catch(_err) { desc = { value: _object[keys[i]] }; } Reflect.defineProperty(result, keys[i], desc); } return result; }});

Reflect.defineProperty(Object, 'clone', { value: Reflect.clone });

//
Reflect.defineProperty(Function, 'isNative', { value: (... _args) => {
	if(_args.length === 0) return null;
	else for(var i = 0; i < _args.length; ++i) if(typeof _args[i] !== 'function') return false;
	else if(!_args[i].toString().endsWith(Function.isNative.compareString)) return false; return true;
}});

Function.isNative.compareString = '() { [native code] }';

//
Reflect.defineProperty(Object, 'isNull', { value: (... _args) => {
	if(_args.length === 0) return null;
	else for(var i = 0; i < _args.length; ++i) {
		if(typeof _args[i] !== 'object' || _args[i] === null) return false;
		else if(Reflect.getPrototypeOf(_args[i]) !== null) return false; }
	return true;
}});

//
