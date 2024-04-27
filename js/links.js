/*
 * Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
 * https://kekse.biz/ https://github.com/kekse1/scripts/
 * v0.4.2
 */

//
const DEFAULT_ENCODING = 'utf8';
const DEFAULT_ATTRIBS = [ 'href', 'src' ];
const DEFAULT_SCHEME = [ 'http:', 'https:' ];
const DEFAULT_UNIQUE = true;

//
class Links
{
	constructor(... _args)
	{
		var unique = null;
		var source = null;
		var scheme = null;

		for(var i = 0; i < _args.length; ++i)
		{
			if(typeof _args[i] === 'boolean')
			{
				unique = _args.splice(i--, 1)[0];
			}
			else if(typeof _args[i] === 'string')
			{
				source = _args.splice(i--, 1)[0];
			}
			else if(Array.isArray(_args[i]))
			{
				if(scheme === null) scheme = [];
				scheme.push(... _args.splice(i--, 1)[0]);
			}
			else if(_args[i] instanceof URL)
			{
				source = _args.splice(i--, 1)[0];
			}
		}

		if(typeof source === 'string')
		{
			source = new URL(source);
		}

		if(unique !== null)
		{
			this._unique = unique;
		}

		if(scheme !== null)
		{
			this.scheme = scheme;
		}
		else
		{
			this.scheme = DEFAULT_SCHEME;
		}

		this.source = source;
		this.links = [];
		this.reset();
	}

	static filter(_array, _scheme, _source)
	{
		if(!Array.isArray(_scheme))
		{
			_scheme = DEFAULT_SCHEME;
		}
		else if(_scheme.length === 0)
		{
			return [ ... _array ];
		}
		
		const result = [];
		var res;

		for(var i = 0, j = 0; i < _array.length; ++i)
		{
			if(res = this.url(_array[i], _source))
			{
				if(typeof res === 'string')
				{
					result[j++] = _array[i];
				}
				else if(_scheme.includes(res.protocol))
				{
					if(typeof _array[i] === 'string')
					{
						res = _array[i];//original form
					}

					result[j++] = res;
				}
			}
		}

		return result;
	}

	static url(_url_array, _source)
	{
		if(_url_array instanceof URL)
		{
			return _url_array;
		}
		else if(typeof _url_array === 'string')
		{
			if(typeof _source !== 'string' || _source.length === 0)
			{
				if(!(_source instanceof URL))
				{
					_source = undefined;
				}
			}

			try
			{
				return new URL(_url_array, _source);
			}
			catch(_error)
			{
				return _url_array;
			}
		}
		else if(!Array.isArray(_url_array))
		{
			return null;
		}

		const result = [];
		var res;
		
		for(var i = 0, j = 0; i < _url_array.length; ++i)
		{
			if(res = this.url(_url_array[i], _source))
			{
				result[j++] = res;
			}
		}

		return result;
	}

	static href(_url_array)
	{
		if(_url_array instanceof URL)
		{
			return _url_array.href;
		}
		else if(typeof _url_array === 'string')
		{
			return _url_array;
		}
		else if(!Array.isArray(_url_array))
		{
			return null;
		}

		const result = [];
		var res;

		for(var i = 0, j = 0; i < _url_array.length; i++)
		{
			if(res = this.href(_url_array[i]))
			{
				result[j++] = res;
			}
		}

		return result;
	}

	static unique(_array, _source)
	{
		const cmp = (_a, _b, _cast = !!_source) => {
			if(_cast)
			{
				if(typeof _a === 'string')
					_a = this.url(_a, _source);
				if(typeof _b === 'string')
					_b = this.url(_b, _source);
			}

			if(typeof _a === 'string')
			{
				if(typeof _b === 'string')
				{
					return (_a === _b);
				}

				return (_a === _b.href);
			}
			else if(typeof _b === 'string')
			{
				return (_a.href === _b);
			}

			return (_a.href === _b.href);
		};

		const result = [];
		var inc;

		for(var i = 0, j = 0; i < _array.length; ++i)
		{
			inc = false;

			for(const r of result)
			{
				if(cmp(_array[i], r))
				{
					inc = true;
					break;
				}
			}

			if(!inc)
			{
				result[j++] = _array[i];//original form
			}
		}

		return result;
	}

	get unique()
	{
		if(typeof this._unique === 'boolean')
		{
			return this._unique;
		}

		return DEFAULT_UNIQUE;
	}

	set unique(_value)
	{
		if(typeof _value === 'boolean')
		{
			return this._unique = _value;
		}

		return this.unique;
	}

	reset()
	{
		this.openLink = false;
		this.openTag = false;
		this.value = null;
		this.position = 0;
	}

	destroy()
	{
		this.links = [];
		this.reset();
	}

	static get attribs()
	{
		return DEFAULT_ATTRIBS;
	}

	extract(_data)
	{
		var result = this.onData(_data);
		if(_data !== null) result = this.finish();
		return result;
	}

	onData(_chunk)
	{
		if(_chunk === null)
		{
			return this.finish();
		}

		const str = (typeof _chunk === 'string');
		const attribs = Links.attribs;
		var byte, char;

		const atString = (_index, _needle) => {
			if(_needle.length > (_chunk.length - _index))
				return false;
			const cmp = _chunk.substr(_index, _needle.length).toLowerCase();
			return (cmp === _needle.toLowerCase());
		};

		const atArray = (_index, _needle) => {
			throw new Error('TODO');
		};

		const at = (_index, _needle) => {
			if(str) return atString(_index, _needle);
			return atArray(_index, _needle);
		};

		const push = (_link) => {
			if(!_link)
			{
				return false;
			}

			this.links.push(encodeURI(_link));
			return true;
		};

		chunkLoop: for(var i = 0; i < _chunk.length; ++i)
		{
			if(str) byte = _chunk.charCodeAt(i);
			else byte = _chunk[i];

			if(byte <= 32 || byte === 127)
			{
				byte = 32;
				char = ' ';
			}
			else
			{
				char = String.fromCharCode(byte);
			}
			
			if(!this.openTag)
			{
				if(char === '<')
				{
					this.openTag = true;
				}
			}
			else if(this.openLink === char)
			{
				this.openLink = false;
				push(this.value);
				this.value = null;
			}
			else if(this.value === null)
			{
				if(char === ' ')
				{
					continue;
				}
				else if(char === '>')
				{
					this.openTag = true;
				}
				else if(this.openLink)
				{
					if(char === '=')
					{
						this.value = '';
					}
				}
				else for(const a of attribs)
				{
					if(at(i, a))
					{
						this.openLink = true;
						i += a.length - 1;
						continue chunkLoop;
					}
				}
			}
			else if(this.openLink === true)
			{
				if(char === '>')
				{
					this.openTag = false;
					this.value = null;
				}
				else if(char === '"' || char === "'")
				{
					this.openLink = char;
				}
				else if(char !== ' ')
				{
					this.openLink = ' ';
					this.value += char;
				}
			}
			else if(this.openLink === ' ' && char === '>')
			{
				this.openLink = false;
				this.openTag = false;
				push(this.value);
				this.value = null;
			}
			else
			{
				this.value += char;
			}
		}

		this.position += _chunk.length;
		return this.links;
	}

	finish()
	{
		if(this.source)
		{
			this.links = Links.url(this.links, this.source);
		}

		if(this.scheme)
		{
			this.links = Lithis.schemefilter(this.links, this.scheme, this.source);
		}

		if(this.unique)
		{
			this.links = Links.unique(this.links);
		}
		
		return this.links;
	}
}

export default Links;

//
