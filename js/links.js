/*
 * Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
 * https://kekse.biz/ https://github.com/kekse1/scripts/
 * v0.8.0
 */

//
const DEFAULT_ENCODING = 'utf8';
const DEFAULT_ATTRIBS = [ 'href', 'src' ];
const DEFAULT_SCHEME = [ 'http:', 'https:' ];
const DEFAULT_UNIQUE = true;
const DEFAULT_THROW = true;
const DEFAULT_CUT_SEARCH = false;
const DEFAULT_CUT_HASH = true;
const DEFAULT_FILTER = true;
const DEFAULT_ALL = false;

//
class Links
{
	constructor(... _args)
	{
		var source = undefined;
		var scheme = null;
		var all = null;

		for(var i = 0; i < _args.length; ++i)
		{
			if(typeof _args[i] === 'boolean')
			{
				all = _args.splice(i--, 1)[0];
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

		if(all !== null)
		{
			this._all = all;
		}

		if(scheme !== null)
		{
			this._scheme = scheme;
		}

		if(typeof source === 'string')
		{
			try
			{
				source = new URL(source).href;
			}
			catch(_err)
			{
				if(DEFAULT_THROW)
				{
					throw _err;
				}
				
				source = undefined;
			}
		}

		this.source = source;
		this.links = [];
		this.reset();
	}

	get all()
	{
		var result;
		
		if(typeof this._all === 'boolean')
			result = this._all;
		else
			result = DEFAULT_ALL;
		
		if(result) return (this.scheme.length > 0);
		return false;
	}

	set all(_value)
	{
		if(typeof _value === 'boolean') return this._all = _value;
		return this.all;
	}

	get filter()
	{
		if(typeof this._filter === 'boolean') return this._filter;
		return DEFAULT_FILTER;
	}

	set filter(_value)
	{
		if(typeof _value === 'boolean') return this._filter = _value;
		return this.filter;
	}

	get cutHash()
	{
		if(typeof this._cutHash === 'boolean') return this._cutHash;
		return DEFAULT_CUT_HASH;
	}
	
	set cutHash(_value)
	{
		if(typeof _value === 'boolean') return this._cutHash = _value;
		return this.cutHash;
	}

	get cutSearch()
	{
		if(typeof this._cutSearch === 'boolean') return this._cutSearch;
		return DEFAULT_CUT_SEARCH;
	}

	set cutSearch(_value)
	{
		if(typeof _value === 'boolean') return this._cutSearch = _value;
		return DEFAULT_CUT_SEARCH;
	}

	get scheme()
	{
		if(Array.isArray(this._scheme)) return this._scheme;
		return DEFAULT_SCHEME;
	}
	
	set scheme(_value)
	{
		if(Array.isArray(_value)) return this._scheme = [ ... _value ];
		return this.scheme;
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
		this.open = '';
		this.openLink = false;
		this.openTag = false;
		this.value = null;
		this.position = 0;
		this.fin = false;
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

	finish()
	{
		if(this.open && this.value)
		{
			this.push(this.value);
		}

		//this.emit('finish', this.links, this);
		this.fin = true;
		this.value = null;
		return this.links;
	}
	
	extract(_data)
	{
		var result = this.onData(_data);
		if(_data !== null) result = this.finish();
		return result;
	}

	static tryCutSearch(_link)
	{
		const idx = _link.indexOf('?');

		if(idx === -1)
		{
			return _link;
		}

		const idx2 = _link.indexOf('#');

		if(idx2 === -1)
		{
			return _link.substr(0, idx);
		}

		return (_link.substr(0, idx) + _link.substr(idx2));
	}

	static tryCutHash(_link)
	{
		const idx = _link.indexOf('#');

		if(idx === -1)
		{
			return _link;
		}

		return _link.substr(0, idx);
	}

	push(_value)
	{
		if(!_value) return false;
		_value = encodeURI(_value.trim());

		if(this.unique && this.links.includes(_value))
			return false;
		
		try
		{
			_value = new URL(_value, this.source);
			
			if(this.scheme.length > 0)
			{
				if(!this.scheme.includes(_value.protocol))
					return false;
			}

			if(this.cutSearch)
			{
				_value.search = '';
			}

			if(this.cutHash)
			{
				_value.hash = '';
			}
			
			_value = _value.href;
		}
		catch(_error)
		{
			if(this.filter)
			{
				return false;
			}

			if(this.cutSearch)
			{
				_value = Links.tryCutSearch(_value);
			}

			if(this.cutHash)
			{
				_value = Links.tryCutHash(_value);
			}
		}
			
		if(this.unique && this.links.includes(_value))
			return false;

		this.links.push(_value);
		return true;
	}
	
	onData(_chunk)
	{
		if(_chunk === null)
		{
			return this.finish();
		}
		else if(this.value === null && this.all)
		{
			this.value = '';
		}

		const str = (typeof _chunk === 'string');
		const attribs = Links.attribs;
		var byte, char;

		const atString = (_index, _needle) => {
			return (_chunk.substr(_index, _needle.length).toLowerCase() === _needle.toLowerCase());
		};

		const atArray = (_index, _needle) => {
			var cmp = '', byte; for(var i = _index, j = 0; i < _chunk.length && j < _needle.length; ++i, ++j)
			{	if((byte = _chunk[i]) >= 65 && byte <= 90) byte += 32;//case IN-sensitive..
				cmp += String.fromCharCode(byte);	}
			return (_needle.toLowerCase() === cmp);
		};

		const at = (_index, _needle) => {
			if(_needle.length > (_chunk.length - _index)) return false;
			else if(str) return atString(_index, _needle);
			return atArray(_index, _needle);
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
			
			if(this.all)
			{
				if(this.open)
				{
					if(char === this.open)
					{
						this.open = '';
						this.push(this.value);
						this.value = '';
					}
					else
					{
						this.value += char;
					}
				}
				else for(const s of this.scheme)
				{
					if(at(i, s))
					{
						this.open = ' ';
						i += s.length - 1;
						continue chunkLoop;
					}
				}
			}
			else if(!this.openTag)
			{
				if(char === '<')
				{
					this.openTag = true;
				}
			}
			else if(this.openLink === char)
			{
				this.openLink = false;
				this.push(this.value);
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
				this.push(this.value);
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
}

export default Links;

//
