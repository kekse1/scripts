/*
 * Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
 * https://kekse.biz/ https://github.com/kekse1/scripts/
 * v0.2.4
 *
 * Using a regular `.json` file/structure. But with improved handling.
 *
 * Example given: { server: { host: 'localhost', { http: { port: 8080 } } } };
 * You can `.get('server.http.host');` and nevertheless get the `host` above it.
 *
 * It's possible to receive an array with all upper definitions, and via `_index`
 * argument to select one (-1 for the last, deepest one, e.g.). You can also FORCE
 * a concrete item without parents, see '.force()'.
 *
 * The `.with()` function is meant for e.g. { enabled: (bool) }. It checks all upper
 * occurencies, if there's at least one (false) value. So you can 'globally' disable
 * smth., even if deeper occurencies enable smth. I needed/wanted this.
 * Now w/ `.enabled()` and `.disabled()`!
 *
 * The [delim] can be changed (defaults to `DEFAULT_DELIM`). On the bottom of this
 * file I also defined my `Math.getIndex(_index, _length)`, btw.
 */

//
const DEFAULT_DELIM = '.';
const DEFAULT_FORCE = false;
const DEFAULT_ALL = true;

//
class Configuration
{
	constructor(... _args)
	{
		for(var i = 0; i < _args.length; ++i)
		{
			if(typeof _args[i] === 'string' && _args[i].length > 0)
			{
				this._delim = _args.splice(i--, 1)[0];
			}
		}
	}
	
	get delim()
	{
		if(typeof this._delim === 'string')
		{
			return this._delim;
		}
		
		return DEFAULT_DELIM;
	}
	
	set delim(_value)
	{
		if(typeof _value === 'string' && _value.length > 0)
		{
			return this._delim = _value;
		}
		
		return this.delim;
	}

	force(_path)
	{
		if(!_path)
		{
			if(typeof _path === 'string')
			{
				return this.CONFIG;
			}

			return undefined;
		}
		
		_path = _path.split(this.delim);
		const last = _path.pop();
		var ctx = this.CONFIG;

		for(var i = 0; i < _path.length; ++i)
		{
			if(typeof ctx[_path[i]] !== 'object' || ctx[_path[i]] === null)
			{
				return null;
			}
			else if(_path[i] in ctx)
			{
				ctx = ctx[_path[i]];
			}
			else
			{
				return null;
			}
		}

		if(last in ctx)
		{
			return ctx[last];
		}

		return null;
	}

	with(_path, _inverse = false)
	{
		if(!_path)
		{
			return undefined;
		}

		const cfg = this.get(_path, null);

		if(cfg.length === 0)
		{
			return null;
		}

		for(var i = 0; i < cfg.length; ++i)
		{
			if(cfg[i] === (_inverse ? true : false))
			{
				return false;
			}
		}

		return true;
	}

	enabled(_path)
	{
		return this.with(_path, false);
	}

	disabled(_path)
	{
		return this.with(_path, true);
	}

	get(_path, _index = -1)
	{
		if(!_path)
		{
			if(typeof _path === 'string')
			{
				return this.CONFIG;
			}

			return undefined;
		}
		else if(typeof _index !== 'number')
		{
			_index = null;
		}

		_path = _path.split(this.delim);
		const last = _path.pop();
		var ctx = this.CONFIG;
		const result = [];
		
		for(var i = 0, j = 0; i < _path.length; ++i)
		{
			if(typeof ctx[_path[i]] !== 'object' || ctx[_path[i]] === null)
			{
				break;
			}
			else if(last in ctx)
			{
				result[j++] = ctx[last];
			}
			
			if(_path[i] in ctx)
			{
				ctx = ctx[_path[i]];
			}
			else
			{
				break;
			}
		}

		if(last in ctx)
		{
			result.push(ctx[last]);
		}

		if(_index === null)
		{
			return result;
		}
		else if(result.length === 0)
		{
			return null;
		}

		return result[Math.getIndex(_index, result.length)];
	}
	
	set(_path, _value, _force = DEFAULT_FORCE)
	{
		if(!_path)
		{
			return undefined;
		}
		else if(typeof _value === 'undefined')
		{
			return this.unset(_path);
		}

		_path = _path.split(this.delim);
		const last = _path.pop();
		var ctx = this.CONFIG;

		for(var i = 0; i < _path.length; ++i)
		{
			if(typeof ctx[_path[i]] !== 'object' || ctx[_path[i]] === null)
			{
				if(_force)
				{
					ctx = ctx[_path[i]] = {};
				}
				else
				{
					return false;
				}
			}
			else if(_path[i] in ctx)
			{
				ctx = ctx[_path[i]];
			}
			else
			{
				ctx = ctx[_path[i]] = {};
			}
		}

		ctx[last] = _value;
		return true;
	}
	
	has(_path, _all = DEFAULT_ALL)
	{
		if(!_path)
		{
			return undefined;
		}
		else if(_all)
		{
			return this.get(_path, null).length;
		}

		_path = _path.split(this.delim);
		const last = _path.pop();
		var ctx = this.CONFIG;
		
		for(var i = 0; i < _path.length; ++i)
		{
			if(typeof ctx[_path[i]] !== 'object' || ctx[_path[i]] === null)
			{
				return false;
			}
			else if(_path[i] in ctx)
			{
				ctx = ctx[_path[i]];
			}
			else
			{
				return false;
			}
		}

		if(last in ctx)
		{
			return true;
		}

		return false;
	}

	unset(_path)
	{
		if(!_path)
		{
			return undefined;
		}

		_path = _path.split(this.delim);
		const last = _path.pop();
		var ctx = this.CONFIG;

		for(var i = 0; i < _path.length; ++i)
		{
			if(typeof ctx[_path[i]] !== 'object' || ctx[_path[i]] === null)
			{
				return false;
			}
			else if(_path[i] in ctx)
			{
				ctx = ctx[_path[i]];
			}
			else
			{
				return false;
			}
		}

		if(last in ctx)
		{
			delete ctx[last];
			return true;
		}

		return false;
	}
}

export default Configuration;

//
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

//
