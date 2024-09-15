//
// Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
// https://kekse.biz/ https://github.com/kekse1/scripts/
// v3.1.0
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
// UPDATE v3.1.0: Improved the 'Object.{has,get,set,remove}()' functions (and made readable).
//

//
const DEFAULT_OBJECT_SEP = '.';		// path separator/delimiter
const DEFAULT_OBJECT_NUL = true;	// when creating intermediate objects, use `Object.create(null)` (if not arrays at all)!?
const DEFAULT_OBJECT_SET_BOOL = false;	// `Object.set()` will return the set state, instead of the replaced item (if any)..

//
Reflect.defineProperty(Math, 'int', { value: (_value, _inverse = false) => {
	const a = (_value < 0); const b = (!!_inverse);
	return (((((a&&b)||!(a||b)) ? Math.floor : Math.ceil)(_value)) || 0);
}});

Reflect.defineProperty(Math, 'getIndex', { value: (_index, _length) => {
	if(_length < 1)
	{
		return null;
	}
	else if((_index %= _length) < 0)
	{
		_index = ((_length + _index) % _length);
	}
	
	return (_index || 0);
}});

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
const getPathArray = (_path, _sep = DEFAULT_OBJECT_SEP) => {
	if(typeof _path === 'number')
	{
		return [ Math.int(_path) ];
	}
	else if(Array.isArray(_path))
	{
		return _path;
	}
	else if(typeof _path !== 'string')
	{
		return null;
	}
	else if(_path.length === 0)
	{
		return null;
	}
	
	const result = [ '' ];
	
	for(var i = 0, j = 0; i < _path.length; ++i)
	{
		if(_path.at(i, _sep))
		{
			if(result[j].length > 0)
			{
				result[++j] = '';
			}
		}
		else
		{
			result[j] += _path[i];
		}
	}
	
	for(var i = 0; i < result.length; ++i)
	{
		if(result[i].length === 0)
		{
			result.splice(i--, 1);
		}
		else if(!isNaN(result[i]))
		{
			result[i] = Math.int(Number(result[i]));
		}
	}
	
	if(result.length === 0)
	{
		return null;
	}
	
	return result;
};

Reflect.defineProperty(Object, 'has', { value: (_path, _context = global, _sep = DEFAULT_OBJECT_SEP) => {
	if((_path = getPathArray(_path, _sep)) === null) return _context; var ctx = _context; var done; try
	{
		for(var i = 0; i < _path.length; ++i)
		{
			done = false;
			
			if(Array.isArray(ctx))
			{
				if(ctx.length === 0)
				{
					return false;
				}
				else if(typeof _path[i] === 'number' && _path[i] < 0)
				{
					ctx = ctx[Math.getIndex(_path[i], ctx.length)];
					done = true;
				}
			}
			
			if(!done)
			{
				if(_path[i] in ctx)
				{
					ctx = ctx[_path[i]];
				}
				else
				{
					return false;
				}
			}
		}
	}
	catch(_err)
	{
		return false;
	}
	
	return true;
}});

Reflect.defineProperty(Object, 'get', { value: (_path, _context = global, _sep = DEFAULT_OBJECT_SEP) => {
	if((_path = getPathArray(_path, _sep)) === null) return _context; var ctx = _context; var done; const last = _path.pop(); try
	{
		for(var i = 0; i < _path.length; ++i)
		{
			done = false;
			
			if(Array.isArray(ctx))
			{
				if(ctx.length === 0)
				{
					return undefined;
				}
				else if(typeof _path[i] === 'number' && _path[i] < 0)
				{
					ctx = ctx[Math.getIndex(_path[i], ctx.length)];
					done = true;
				}
			}
			
			if(!done)
			{
				if(_path[i] in ctx)
				{
					ctx = ctx[_path[i]];
				}
				else
				{
					return undefined;
				}
			}
		}
		
		if(Array.isArray(ctx))
		{
			if(ctx.length === 0)
			{
				return undefined;
			}
			else if(typeof last === 'number' && last < 0)
			{
				return ctx[Math.getIndex(last, ctx.length)];
			}
		}
		
		if(last in ctx)
		{
			return ctx[last];
		}
	}
	catch(_err)
	{
		return undefined;
	}
	
	return undefined;
}});

Reflect.defineProperty(Object, 'set', { value: (_path, _value, _context = global, _sep = DEFAULT_OBJECT_SEP, _null = DEFAULT_OBJECT_NUL) => {
	if((_path = getPathArray(_path, _sep)) === null) return _context; var ctx = _context; var last = _path.pop(); var result; try
	{
		const getNextTargetItem = (_index) => {
			if(typeof _path[_index + 1] === 'undefined')
			{
				if(typeof last === 'number')
				{
					return [];
				}
				else if(_null)
				{
					return Object.create(null);
				}
				
				return {};
			}
			else if(typeof _path[_index + 1] === 'number')
			{
				return [];
			}
			else if(_null)
			{
				return Object.create(null);
			}
			
			return {};
		};

		for(var i = 0; i < _path.length; ++i)
		{
			if(Array.isArray(ctx) && typeof _path[i] === 'number')
			{
				if(_path[i] >= ctx.length)
				{
					ctx = ctx[_path[i]] = getNextTargetItem();
				}
				else
				{
					if(_path[i] < 0)
					{
						if(ctx.length === 0)
						{
							_path[i] = 0;
						}
						else
						{
							_path[i] = Math.getIndex(_path[i], ctx.length);
						}
					}

					ctx = ctx[_path[i]];
				}
			}
			else if(_path[i] in ctx)
			{
				ctx = ctx[_path[i]];
			}
			else
			{
				ctx = ctx[_path[i]] = getNextTargetItem();
			}
		}

		//
		if(Array.isArray(ctx) && typeof last === 'number')
		{
			if(last >= ctx.length)
			{
				result = ctx[last];
				ctx[last] = _value;
			}
			else
			{
				if(last < 0)
				{
					if(ctx.length === 0)
					{
						last = 0;
					}
					else
					{
						last = Math.getIndex(last, ctx.length);
					}
				}
				
				result = ctx[last];
				ctx[last] = _value;
			}
		}
		else
		{
			result = ctx[last];
			ctx[last] = _value;
		}
	}
	catch(_err)
	{
		if(DEFAULT_OBJECT_SET_BOOL)
		{
			return false;
		}
		
		return undefined;
	}
	
	if(DEFAULT_OBJECT_SET_BOOL)
	{
		return true;
	}

	return result;
}});

Reflect.defineProperty(Object, 'remove', { value: (_path, _context = global, _sep = DEFAULT_OBJECT_SEP) => {
	if((_path = getPathArray(_path, _sep)) === null) return _context; var ctx = _context; var done; const last = _path.pop(); try
	{
		for(var i = 0; i < _path.length; ++i)
		{
			done = false;
			
			if(Array.isArray(ctx))
			{
				if(ctx.length === 0)
				{
					return undefined;
				}
				else if(typeof _path[i] === 'number' && _path[i] < 0)
				{
					ctx = ctx[Math.getIndex(_path[i], ctx.length)];
					done = true;
				}
			}
			
			if(!done)
			{
				if(_path[i] in ctx)
				{
					ctx = ctx[_path[i]];
				}
				else
				{
					return undefined;
				}
			}
		}

		if(Array.isArray(ctx))
		{
			if(ctx.length === 0)
			{
				return undefined;
			}
			else if(typeof last === 'number')
			{
				if(last < 0)
				{
					const alternative = Math.getIndex(last, ctx.length);
					return ctx.splice(alternative, 1)[0];
				}
				
				return ctx.splice(last, 1)[0];
			}
		}
		
		if(last in ctx)
		{
			const result = ctx[last];
			delete ctx[last];
			return result;
		}
	}
	catch(_err)
	{
		return undefined;
	}
	
	return undefined;
}});

//
export default { was: Reflect.was, is: Reflect.is, getPrototypesOf: Reflect.getPrototypesOf, isNull: Object.isNull,
	has: Object.has, get: Object.get, set: Object.set, remove: Object.remove };
