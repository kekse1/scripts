//
// Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
// https://kekse.biz/ https://github.com/kekse1/scripts/
// v2.0.0
//
// The problem is described below. My solution extends the `Reflect` class, and also
// sets two global functions, like:
//
// # `[Reflect.]is()`: concrete/last class/instance name (returns String/Boolean)
// # `[Reflect.]was()`: List of all class names, including super's (returns Array/Boolean)
//
// Either you call them just with an object/item, to show their names,
// or you define one or many strings, to compare them with your params
// (which will result a Boolean type, not a String or an Array of Strings).
//
// The problem was: depending on your JavaScript *environment*, which also changes
// e.g. when using <iframe> or so, the base classes are being initialized/declared/..
// not only once, but multiple times, depending on your environments.
//
// In this case a regular `instanceof` won't match, since there are other references,
// etc.. so check your items (instances, mostly) this way, maybe defining at least one
// string to be checked (as name of the class).
//

//
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
	if(_args.length === 0) return result; for(var i = 0; i < result.length; ++i)
		if(_args.includes(result[i])) return true; return false;
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

Reflect.defineProperty(Object, 'isNull', { value: (_item) => {
	if(typeof _item !== 'object' || _item === null) return false;
	else if(Reflect.getPrototypeOf(_item) !== null) return false;
	return true; }});

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
