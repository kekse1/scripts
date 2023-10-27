// 
// Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
// v0.2.1
// 
// Just a tiny function to *really* clone objects (etc.); .. with all types, not only JSON supported ones
// or so (sometimes the web referes to just `JSON.parse(JSON.stringify({}))`);
// 
// If you really start with an own `Map` instance (2nd parameter), you can even define to replace any
// occurence of some object with your own values.
// Functions are also cloned, if not native ones, including all of their members, if any additional exist.
//

//
Reflect.defineProperty(Reflect, 'clone', { value: (_object, _map = null) => {
	if(!_map) _map = new Map(); else if(_map.has(_object)) return _map.get(_object); else if(!Reflect.isExtensible(_object)) return _object;
	else if(typeof _object === 'undefined' || _object === null) return _object; const keys = Reflect.ownKeys(_object);
	const isArray = (Array._isArray(_object) ? _object.length : -1); var result; if(isArray > -1) { result = new Array(isArray);
	for(var i = 0; i < _object.length; ++i) result[i] = Reflect.clone(_object[i], _map); for(var i = _object.length - 1; i >= 0; --i)
	keys.remove(i.toString()); keys.remove('length'); } else if(typeof _object === 'function') { if(Function.isNative(_object))
	result = _object; else try { eval('result = ' + _object.toString()); } catch(_error) { result = _object; } keys.remove(
		'length', 'name', 'arguments', 'caller', 'prototype'); } else if(Object.isNull(_object)) result = Object.create(null);
	else try { result = Object.create(Reflect.getPrototypeOf(_object)); } catch(_error) { result = {}; }
	_map.set(_object, result); _map.set(result, result); var desc; for(var i = 0; i < keys.length; ++i) {
	try { desc = Reflect.getOwnPropertyDescriptor(_object, keys[i]); } catch(_err) { desc = { value: _object[keys[i]] }; }
		if('value' in desc) desc.value = Reflect.clone(desc.value, _map);
		else { if('get' in desc) desc.get = Reflect.clone(desc.get, _map);
			if('set' in desc) desc.set = Reflect.clone(desc.set, _map); }
	Reflect.defineProperty(result, keys[i], desc); } return result;
}});

//
//additional..
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
