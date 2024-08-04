//
// Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
// https://kekse.biz/ https://github.com/kekse1/scripts/
// v3.0.0
//
// The problem was: depending on your JavaScript *environment*, which also changes
// e.g. when using <iframe> or so, the base classes are being initialized/declared/..
// not only once, but multiple times, depending on your environments.
//
// In this case a regular `instanceof` won't match, since there are other references,
// etc.. so check your items (instances, mostly) this way, maybe defining at least one
// string to be checked (as name of the class).
//
// My solution extends the `Reflect` class, and also sets two global functions, so you
// can compare by their name(s); it's like:
//
// # `[Reflect.]is()`: concrete/last class/instance name (returns String/Boolean)
// # `[Reflect.]was()`: List of all class names, including super's (returns Array/Boolean)
//
// Either you call them just with an object/item, to show their names,
// or you define one or many strings, to compare them with your params
// (which will result a Boolean type, not a String or an Array of Strings).
//
// NEW since v2.1.0: 'was()' arguments mean logical AND.. 'is()' still OR.
//
// I'm using it for a long time now, and it really works great. No problems occured,
// and I recommend you to always use this instead of `instanceof` or smth. like it.
//

//
Reflect.defineProperty(Object, 'isNull', { value: (... _args) => {
	if(_args.length === 0) return null;
	else for(var i = 0; i < _args.length; ++i) {
		if(typeof _args[i] !== 'object' || _args[i] === null) return false;
		else if(Reflect.getPrototypeOf(_args[i]) !== null) return false; }
	return true;
}});

Reflect.defineProperty(Reflect, 'getPrototypesOf', { value: (_item) => {
	const result = []; var proto = _item; try { do {
		if(proto = Reflect.getPrototypeOf(proto)) result.push(proto); else break;
	} while(true); } catch(_err) {}; return result; }});

Reflect.defineProperty(Reflect, 'was', { value: (_item, ... _args) => {
	for(var i = _args.length - 1; i >= 0; --i)
		if(typeof _args[i] !== 'string' || _args[i].length === 0)
			_args.splice(i, 1);
	if(_args.length > 0) _args = Array.from(new Set(_args)); //my "Array.unique()" interpretation
	const result = []; const prototypes = Reflect.getPrototypesOf(_item);
	if(prototypes.length === 0) return (_args.length === 0 ? [] : false);
	var name; for(var i = 0, j = 0; i < prototypes.length; ++i)
		if(typeof (name = Reflect.is(prototypes[i])) === 'string')
			result[j++] = name;
	if(_args.length === 0) return result; for(var i = 0; i < _args.length; ++i)
		if(!result.includes(_args[i])) return false;
	return true;
}});

Reflect.defineProperty(Reflect, 'is', { value: (_item, ... _args) => {
	var className = true; for(var i = 0; i < _args.length; ++i) {
		if(typeof _args[i] === 'boolean') className = _args.splice(i--, 1)[0];
		else if(typeof _args[i] !== 'string' || _args[i].length === 0) _args.splice(i--, 1); }
	if(_args.length > 0) _args = Array.from(new Set(_args)); //my "Array.unique()" interpretation
	const tryConstructorName = () => {
		try { return _item.constructor.name; } catch(_err) { return ''; }};
	const tryClassName = () => {
		try { return _item.name; } catch(_err) { return ''; }};
	var result;
	if(typeof _item === 'undefined') result = 'undefined';
	else if(_item === null) result = 'null';
	else if(Object.isNull(_item)) result = 'Object[null]';
	else result = tryConstructorName();
	if(!result && className) result = tryClassName();
	if(!result && _args.length > 0) return false;
	else if(_args.length === 0) return result;
	return _args.includes(result);
}});

//
Reflect.defineProperty(Object, 'getPathArray', { value: (_path, _delim = '.') => {
	if(Number.isInt(_path)) return [ _path ]; else if(typeof _path !== 'string') return [];
	else _path = _path.split(_delim); for(var i = 0; i < _path.length; ++i)
	if(!isNaN(_path[i])) _path[i] = Number(_path[i]); return _path; }});
const pathItemForArray = (_item) => (typeof _item === 'number' || _item.length === 0);
const traverseObject = (_path, _value, _context = global, _null = false, _method) => {
	if(typeof _path === 'string') _path = Object.getPathArray(_path); if(!Array.isArray(_path, false)) return _context;
	if(typeof _method !== 'string') return error('Invalid % argument [ %, %, %, % ]', null, '_method', 'has', 'get', 'set', 'remove');
	else switch(_method = _method.toLowerCase()) { case 'has': case 'get': case 'set': case 'remove': break;
	default: return error('Invalid % argument [ %, %, %, % ]', null, '_method', 'has', 'get', 'set', 'remove'); }
	var obj = _context, current, next; for(var i = 0; i < _path.length - 1; ++i) { current = _path[i]; next = _path[i + 1];
	if(pathItemForArray(current)) { if(!Array._isArray(obj)) switch(_method) { case 'has': return false; case 'get': return undefined;
	case 'set': case 'remove': return false; } if(typeof current === 'number') { if(current < 0 && (current = Math.getIndex(current,
	obj.length)) === null) current = 0; if(obj.length <= current) switch(_method) { case 'has': return false; case 'get':
	return undefined; case 'remove': return false; case 'set': obj = obj[current] = (pathItemForArray(next) ? [] : (_null ? Object.create(null) : {})); }
	else obj = obj[current]; } else { if(obj.length === 0) switch(_method) { case 'has': return false; case 'get': return undefined; case 'remove': return false; }
	obj = obj[obj.length] = (pathItemForArray(next) ? [] : (_null ? Object.create(null) : {})); }} var got = true; try { if(!obj.__proto__) got = false; } catch(_err) { got = false; }
	if(!got && !Reflect.isExtensible(obj)) switch(_method) { case 'has': return false; case 'get': return undefined; case 'set': case 'remove': return false; }
	else if(current in obj) obj = obj[current]; else { switch(_method) { case 'has': return false; case 'get': return undefined; case 'remove': return false; } obj = obj[current] =
	(pathItemForArray(next) ? [] : (_null ? Object.create(null) : {})); }} _path = _path[_path.length - 1]; if(pathItemForArray(_path)) {
	if(!Array._isArray(obj)) switch(_method) { case 'has': return false; case 'get': return undefined; case 'set': case 'remove': return false; }
	if(typeof _path === 'number') { if(_path < 0 && (_path = Math.getIndex(_path, obj.length)) === null) _path = 0; if(obj.length <= _path)
	switch(_method) { case 'has': return false; case 'get': return undefined; case 'remove': return false; case 'set': obj[_path] = _value; return true; }
	switch(_method) { case 'has': return true; case 'get': return obj[_path]; case 'remove': obj.splice(_path, 1); return true; case 'set':
	obj[_path] = _value; return true; }} else switch(_method) { case 'has': return (obj.length > 0); case 'get': return obj[obj.length - 1]; case 'remove':
	if(obj.length === 0) return false; obj.pop(); return true; case 'set': obj.push(_value); return true; }} var got = true; try { if(!obj.__proto__) got = false; }
	catch(_err) { got = false; } if(!got) switch(_method) { case 'has': return false; case 'get': return undefined; case 'set': case 'remove': return false; }
	switch(_method) { case 'has': if(typeof obj[_path] === 'undefined') { try { if(!(_path in obj)) return false; } catch(_err) { return false; }} return true;
	case 'get': try { return obj[_path]; } catch(_err) { return undefined; }; break; case 'set': case 'remove': if(!Reflect.isExtensible(obj)) return false;
	} switch(_method) { case 'remove': try { return delete obj[_path]; } catch(_err) { return false; }; break; case 'set': try { obj[_path] = _value; }
	catch(_err) { return false; }} return undefined; };

Reflect.defineProperty(Object, 'has', { value: (_path, _context = global) => traverseObject(_path, undefined, _context, null, 'has') });
Reflect.defineProperty(Object, 'get', { value: (_path, _context = global) => traverseObject(_path, undefined, _context, null, 'get') });
Reflect.defineProperty(Object, 'set', { value: (_path, _value, _context = global, _null = false) => traverseObject(_path, _value, _context, _null, 'set') });
Reflect.defineProperty(Object, 'remove', { value: (_path, _context = global) => traverseObject(_path, undefined, _context, null, 'remove') });

//
if(typeof window === 'undefined')
{
	global.was = Reflect.was;
	global.is = Reflect.is;
}
else
{
	window.was = Reflect.was;
	window.is = Reflect.is;
}

//
export default { was: Reflect.was, is: Reflect.is, getPrototypesOf: Reflect.getPrototypesOf, isNull: Object.isNull };

//
