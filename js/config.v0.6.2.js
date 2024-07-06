/*
 * Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
 * https://kekse.biz/ https://github.com/kekse1/scripts/
 * v0.6.2
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
 * New since v0.6: Stepwise traverse up *any* path, not only the chroot's!
 */

//
const DEFAULT_DELIM = '.';
const DEFAULT_FORCE = false;
const DEFAULT_ALL = true;
const DEFAULT_THROW = true;
const DEFAULT_RESET = false;
const DEFAULT_COPY = true;

//
import Quant from './quant.js';
import JSON from './json.js';
import FileSystem from '../shared/filesystem.js';

import path from 'node:path';

//
class Configuration extends Quant
{
	constructor(_parent, ... _args)
	{
		super(_parent, null, ... _args);

		this.parentConfig = null;
		this.CONFIG = Object.create(null);

		for(var i = 0; i < _args.length; ++i)
		{
			if(object(_args[i]))
			{
				this.wrap(_args.splice(i--, 1)[0]);
			}
		}
	}

	static normalizePath(_path, _string = true)
	{
		if(array(_path, true))
		{
			if(_path.length === 0)
			{
				return (_string ? '' : _path);
			}

			var p = '';

			for(var i = 0; i < _path.length; ++i)
			{
				if(string(_path[i], false))
				{
					p += _path[i] + Configuration.delim;
				}
			}

			p = p.slice(0, -Configuration.delim.length);

			if(!p)
			{
				return '';
			}

			_path = p;
		}
		else if(string(_path, true))
		{
			if(_path.length === 0)
			{
				return (_string ? '' : []);
			}
		}
		else
		{
			return (_string ? '' : null);
		}

		_path = _path.split(Configuration.delim);

		for(var i = _path.length - 1; i >= 0; --i)
		{
			if(_path[i].length === 0)
			{
				_path.splice(i, 1);
			}
		}

		if(_string)
		{
			return _path.join(Configuration.delim);
		}
		else if(_path.length === 0)
		{
			return null;
		}

		return _path;
	}

	get path()
	{
		if(string(this._path, false))
		{
			return this._path;
		}

		return this._path = '';
	}

	set path(_value)
	{
		if(string(_value, false))
		{
			return this._path = Configuration.normalizePath(
				_value, true);
		}
		else
		{
			delete this._path;
		}

		return this.path;
	}

	extend(_with)
	{
		const result = new Configuration(this.parent);
		result.CONFIG = this.CONFIG;
		result.path = _with;
		result.parentConfig = this;

		return result;
	}

	getRootPath(_string = true)
	{
		const result = [];
		var parent = this;

		do
		{
			if(string(parent.path, false))
			{
				result.unshift(parent.path);
			}

			if(parent.parentConfig)
			{
				parent = parent.parentConfig;
			}
			else
			{
				break;
			}
		}
		while(true);

		if(result.length === 0)
		{
			return (_string ? '' : []);
		}

		return Configuration.normalizePath(result, _string);
	}

	tryRootPath(_value, _string = true)
	{
		if(bool(_value))
		{
			return (_value ? this.getRootPath(_string) : '');
		}
		else if(string(_value, true))
		{
			return Configuration.normalizePath(_value, _string);
		}
		
		return '';
	}

	getPath(_path, _string = true, _with = true)
	{
		if(array(_path, true))
		{
			_path = _path.join(Configuration.delim);
		}
		else if(!string(_path, true))
		{
			return null;
		}

		var result;

		if(bool(_with))
		{
			result = (_with ? this.getRootPath(true) : '');
		}
		else if(string(_with, false))
		{
			result = _with;
		}
		else
		{
			result = '';
		}

		if(string(_path, false))
		{
			if(result)
			{
				if(result === _path)
				{
					result = '';
				}
				else
				{
					result += Configuration.delim;
				}
			}

			result += _path;
		}

		return Configuration.normalizePath(result, _string);
	}

	static get delim()
	{
		return DEFAULT_DELIM;
	}

	wrap(_object)
	{
		if(!this.CONFIG)
		{
			this.CONFIG = Object.create(null);
		}

		if(!object(_object))
		{
			return null;
		}
		
		if(was(_object, 'Configuration'))
		{
			if(!object(_object = _object.CONFIG))
			{
				return null;
			}
		}

		return Object.assign(this.CONFIG, _object);
	}

	static wrap(_object, _parent, ... _args)
	{
		return new Configuration(_parent, _object, ... _args);
	}
	
	load(... _args)
	{
		const callbacks = [];
		var reset = DEFAULT_RESET;

		for(var i = 0; i < _args.length; ++i)
		{
			if(func(_args[i]))
			{
				callbacks.push(_args.splice(i--, 1)[0]);
			}
			else if(bool(_args[i]))
			{
				reset = _args.splice(i--, 1)[0];
			}
		}
		
		const callback = (_config, _data) => {
			if(reset)
			{
				this.CONFIG = null;
			}

			this.wrap(_config);
			
			for(const cb of callbacks)
			{
				cb(this, _config, _data, reset);
			}
		};
		
		return Configuration.load(callback, ... _args);
	}

	fallback(_path, _func, ... _args)
	{
		const orig = _path;
		_path = Configuration.normalizePath(_path, false);

		if(_path.length <= 0 || !string(_func, false))
		{
			return undefined;
		}

		const test = (_p) => {
			switch(_func)
			{
				case 'force':
					if(typeof (r = this.force(_p, false)) !== 'undefined')
						return r;
					break;
				case 'with':
					if(this.with(_p, _args[0], false) === false)
						return false;
					break;
				case 'get':
					r = this.get(_p, _args[0], false);
					if(int(_args[0]))
					{
						if(typeof r !== 'undefined')
						{
							return r;
						}
					}
					else if(r.length > 0)
					{
						return r;
					}
					break;
				case 'set':
					if(this.set(_p, _args[0], false, false) === true)
						return true;
					break;
				case 'has':
					if(this.has(_p, false))
						return true;
					break;
				case 'unset':
					if(this.unset(_p, false))
						return true;
					break;
			}
		};
		
		var p, c, r;
		
		for(var i = -1, j = 0; j < _path.length - 1; --i, ++j)
		{
			p = _path.slice(0, i).join(Configuration.delim);

			for(var k = _path.length - j; k < _path.length; ++k)
			{
				c = _path.slice(k, -1);
				
				if(c.length === 0)
				{
					c = '';
				}
				else
				{
					c = c.join(Configuration.delim) + Configuration.delim;
				}
				
				c += _path[_path.length - 1];
				c = p + Configuration.delim + c;

				if(typeof (r = test(c)) !== 'undefined')
				{
					if(DEFAULT_COPY)
					{
						return Reflect.clone(r);
					}

					return r;
				}
			}
		}
		
		switch(_func)
		{
			case 'force':
				if(this.isRootPath(_path))
				{
					if(DEFAULT_COPY)
					{
						return Reflect.clone(this.CONFIG);
					}

					return this.CONFIG;
				break;
			case 'with':
				return true;
			case 'get':
				if(!int(_args[0]))
					return [];
				break;
			case 'set':
			case 'has':
			case 'unset':
				return false;
		}

		return undefined;
	}

	isRootPath(_path)
	{
		_path = Configuration.normalizePath(_path, true);

		if(_path === '')
		{
			return true;
		}
		else if(this.getRootPath(true) === _path)
		{
			return true;
		}

		return false;
	}
	
	force(_path, _with = true)
	{
		if(!_path)
		{
			_path = '';
		}

		if(!(_path = this.getPath(_path, false, _with)))
		{
			if(_with)
			{
				return this.fallback(_path, 'force');
			}

			return undefined;
		}
		else if(!_with && this.isRootPath(_path))
		{
			if(_with)
			{
				return this.force(this.getRootPath(), false);
			}
			else if(DEFAULT_COPY)
			{
				return Reflect.clone(this.CONFIG);
			}

			return this.CONFIG;
		}

		const orig = [ ... _path ];
		const last = _path.pop();
		var ctx = this.CONFIG;

		for(var i = 0; i < _path.length; ++i)
		{
			if(Reflect.isExtensible(ctx[_path[i]]))
			{
				ctx = ctx[_path[i]];
			}
			else
			{
				ctx = undefined;
				break;
			}
		}

		if(ctx && (last in ctx))
		{
			const r = ctx[last];

			if(DEFAULT_COPY)
			{
				return Reflect.clone(r);
			}

			return r;
		}
		else if(_with)
		{
			return this.fallback(orig, 'force');
		}

		return undefined;
	}

	with(_path, _inverse = false, _with = true)
	{
		if(!(_path = this.getPath(_path, false, _with)))
		{
			if(_with)
			{
				return this.fallback(orig, 'with', _inverse);
			}
			
			return undefined;
		}

		const cfg = this.get(_path, null, _with);

		if(cfg.length === 0)
		{
			return undefined;
		}

		for(var i = 0; i < cfg.length; ++i)
		{
			if(cfg[i] === (_inverse ? true : false))
			{
				return false;
			}
		}
		
		if(_with)
		{
			return this.fallback(_path, 'with', _inverse);
		}
		
		return true;
	}

	enabled(_path, _with = true)
	{
		return this.with(_path, false, _with);
	}
	
	disabled(_path, _with = true)
	{
		return this.with(_path, true, _with);
	}

	get(_path, _index = -1, _with = true)
	{
		if(!(_path = this.getPath(_path, false, _with)))
		{
			if(_with)
			{
				return this.fallback(orig, 'get', _index);
			}
			
			return undefined;
		}

		if(!int(_index))
		{
			_index = null;
		}

		const orig = [ ... _path ];
		const last = _path.pop();
		var ctx = this.CONFIG;
		var result = [];
		
		for(var i = 0, j = 0; i < _path.length; ++i)
		{
			if(Reflect.isExtensible(ctx[_path[i]]))
			{
				ctx = ctx[_path[i]];
			}
			else
			{
				ctx = undefined;
				break;
			}
		}

		if(ctx && (last in ctx))
		{
			result.push(ctx[last]);
		}

		if(result.length === 0 && _with)
		{
			const res = this.fallback(orig, 'get', _index);

			if(typeof res !== 'undefined')
			{
				if(_index === null)
				{
					result = res;
				}
				else
				{
					result = [ res ];
				}
			}
		}

		if(_index === null)
		{
			return result;
		}
		else if(result.length === 0)
		{
			return undefined;
		}

		const item = result[Math.getIndex(_index, result.length)];

		if(DEFAULT_COPY)
		{
			return Reflect.clone(item);
		}

		return item;
	}
	
	set(_path, _value, _force = DEFAULT_FORCE, _with = true)
	{
		if(!(_path = this.getPath(_path, false, _with)))
		{
			if(_with)
			{
				const res = tryRoots();
				
				if(res === true)
				{
					return res;
				}
			}
			
			return undefined;
		}
		
		if(undef(_value))
		{
			return this.unset(_path);
		}

		const orig = [ ... _path ];
		const last = _path.pop();
		var ctx = this.CONFIG;

		for(var i = 0; i < _path.length; ++i)
		{
			if(Reflect.isExtensible(ctx[_path[i]]))
			{
				ctx = ctx[_path[i]];
			}
			else if(_path[i] in ctx)
			{
				if(_force)
				{
					ctx = ctx[_path[i]] = Object.create(null);
				}
				else if(_with)
				{
					return this.fallback(orig, 'set', _value);
				}
				
				return false;
			}
			else
			{
				ctx = ctx[_path[i]] = Object.create(null);
			}
		}

		ctx[last] = _value;
		return true;
	}
	
	has(_path, _with = true)
	{
		if(!(_path = this.getPath(_path, false, _with)))
		{
			if(_with)
			{
				return tryRoots();
			}
			
			return undefined;
		}

		const orig = [ ... _path ];		
		const last = _path.pop();
		var ctx = this.CONFIG;
		
		for(var i = 0; i < _path.length; ++i)
		{
			if(Reflect.isExtensible(ctx[_path[i]]))
			{
				ctx = ctx[_path[i]];
			}
			else
			{
				ctx = undefined;
				break;
			}
		}

		if(ctx && (last in ctx))
		{
			return true;
		}
		else if(_with)
		{
			return this.fallback(orig, 'has');
		}
		
		return false;
	}

	unset(_path, _with = true)
	{
		if(!(_path = this.getPath(_path, false, _with)))
		{
			if(_with)
			{
				return tryRoots();
			}
			
			return undefined;
		}

		const orig = [ ... _path ];
		const last = _path.pop();
		var ctx = this.CONFIG;

		for(var i = 0; i < _path.length; ++i)
		{
			if(Reflect.isExtensible(ctx[_path[i]]))
			{
				ctx = ctx[_path[i]];
			}
			else
			{
				ctx = undefined;
				break;
			}
		}

		if(ctx && (last in ctx))
		{
			delete ctx[last];
			return true;
		}
		else if(_with)
		{
			return this.fallback(orig, 'unset');
		}

		return false;
	}

	static load(... _args)
	{
		const callbacks = [];
		var p = null;

		for(var i = 0; i < _args.length; ++i)
		{
			if(string(_args[i], false))
			{
				p = _args.splice(i--, 1)[0];
			}
			else if(func(_args[i]))
			{
				callbacks.push(_args.splice(i--, 1)[0]);
			}
		}

		if(p === null)
		{
			throw new Error('Missing path for `config.json`');
		}
		else if(path.extname(p) === '')
		{
			p += '.json';
		}
		
		p = FileSystem.exists.file(p, (_exists) => {
			if(!_exists)
			{
				console.error('Configuration file doesn\'t exist (as file): `' + p + '`');
				process.exit(127);
			}

			return this.path = JSON.read(p, (_result, _data, _error) => {
				if(_error) throw _error;
				for(const cb of callbacks) cb(_result, _data);
			}, true);
		});
	}
}

export default Configuration;

//

