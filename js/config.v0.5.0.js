/*
 * Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
 * https://kekse.biz/ https://github.com/kekse1/scripts/
 * v0.5.0
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
 *
 * AND now also with new `.extend()` function, to kinda 'chroot' into sub configs;
 * but WITH queries to the topmost config as fallback (TODO: query *every* parent
 * path, step by step, after each 'fail'!).
 *
 */

//
const DEFAULT_DELIM = '.';
const DEFAULT_FORCE = false;
const DEFAULT_ALL = true;
const DEFAULT_THROW = true;
const DEFAULT_RESET = false;

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
		if(!_path)
		{
			return '';
		}
		else if(Array.isArray(_path, true))
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
			return this._path = Configuration.normalizePath(_value, true);
		}
		else
		{
			delete this._path;
		}

		return this.path;
	}

	extend(_path_root)
	{
		if(!string(_path_root, true))
		{
			return null;
		}

		const result = new Configuration(this.parent);
		result.CONFIG = this.CONFIG;
		result.path = _path_root;
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

	getPath(_path, _string = true, _root = true)
	{
		if(Array.isArray(_path, true))
		{
			_path = _path.join(Configuration.delim);
		}

		var result;

		if(bool(_root))
		{
			result = (_root ? this.getRootPath(true) : '');
		}
		else if(string(_root, false))
		{
			result = _root;
		}
		else
		{
			result = '';
		}

		if(string(_path, false))
		{
			if(result)
			{
				result += Configuration.delim;
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

	force(_path, _root = true)
	{
		const orig = _path;

		if(!(_path = this.getPath(_path, false, _root)))
		{
			if(_root)
			{
				return this.force(this.tryRootPath(_root), false);
			}

			return this.CONFIG;
		}

		const last = _path.pop();
		var ctx = this.CONFIG;

		for(var i = 0; i < _path.length; ++i)
		{
			if(!object(ctx[_path[i]]))
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
		else if(_root)
		{
			return this.force(orig, false);
		}

		return null;
	}

	with(_path, _inverse = false, _root = true)
	{
		const orig = _path;
		
		if(!(_path = this.getPath(_path, false, _root)))
		{
			return undefined;
		}

		const cfg = this.get(_path, null, _root);

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
		
		if(_root && this.with(orig, _inverse, false) === false)
		{
			return false;
		}

		return true;
	}

	enabled(_path, _root = true)
	{
		return this.with(_path, false, _root);
	}
	
	disabled(_path, _root = true)
	{
		return this.with(_path, true, _root);
	}

	get(_path, _index = -1, _root = true)
	{
		const orig = _path;

		if(!(_path = this.getPath(_path, false, _root)))
		{
			if(_root)
			{
				return this.force(this.tryRootPath(_root), false);
			}

			return this.CONFIG;
		}

		if(!int(_index))
		{
			_index = null;
		}

		const last = _path.pop();
		var ctx = this.CONFIG;
		const result = [];
		
		for(var i = 0, j = 0; i < _path.length; ++i)
		{
			if(!object(ctx[_path[i]]))
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
		
		if(result.length === 0 && _root)
		{
			const res = this.get(orig, _index, false);

			if(res !== null)
			{
				return res;
			}
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
	
	set(_path, _value, _force = DEFAULT_FORCE, _root = true)
	{
		const orig = _path;
		
		if(!(_path = this.getPath(_path, false, _root)))
		{
			return undefined;
		}
		
		if(undef(_value))
		{
			return this.unset(_path);
		}

		const last = _path.pop();
		var ctx = this.CONFIG;

		for(var i = 0; i < _path.length; ++i)
		{
			if(!object(ctx[_path[i]]))
			{
				if(_force)
				{
					ctx = ctx[_path[i]] = {};
				}
				else if(_root)
				{
					return this.set(orig, _value, _force, false);
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
	
	has(_path, _root = true)
	{
		const orig = _path;
		
		if(!(_path = this.getPath(_path, false, _root)))
		{
			return undefined;
		}
		
		const last = _path.pop();
		var ctx = this.CONFIG;
		
		for(var i = 0; i < _path.length; ++i)
		{
			if(!object(ctx[_path[i]]))
			{
				if(_root)
				{
					return this.has(orig, false);
				}

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
		else if(_root)
		{
			return this.has(orig, false);
		}
		
		return false;
	}

	unset(_path, _root = true)
	{
		const orig = _path;
		
		if(!(_path = this.getPath(_path, false, _root)))
		{
			return undefined;
		}

		const last = _path.pop();
		var ctx = this.CONFIG;

		for(var i = 0; i < _path.length; ++i)
		{
			if(!object(ctx[_path[i]]))
			{
				if(_root)
				{
					return this.unset(orig, false);
				}

				return false;
			}
			else if(_path[i] in ctx)
			{
				ctx = ctx[_path[i]];
			}
			else if(_root)
			{
				return this.unset(orig, false);
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
		else if(_root)
		{
			return this.unset(orig, false);
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

