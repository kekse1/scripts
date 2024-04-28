/*
 * Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
 * https://kekse.biz/ https://github.com/kekse1/scripts/
 * v0.5.0
 */

//
const DEFAULT_ENCODING = 'utf8';
const DEFAULT_ATTRIBS = [ 'href', 'src' ];
const DEFAULT_SCHEME = [ 'http:', 'https:' ];
const DEFAULT_UNIQUE = true;
const DEFAULT_THROW = true;

//
class Links
{
	constructor(... _args)
	{
		var source = undefined;
		var unique = null;
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

		if(unique !== null)
		{
			this._unique = unique;
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
		//this.emit('finish', this.links, this);
		this.fin = true;
		return this.links;
	}
	
	extract(_data)
	{
		var result = this.onData(_data);
		if(_data !== null) result = this.finish();
		return result;
	}

	push(_value)
	{
		if(!_value) return false; _value = encodeURI(_value);
		if(this.unique && this.links.includes(_value)) return false;
		
		try
		{
			_value = new URL(_value, this.source);
			
			if(this.scheme.length > 0)
			{
				if(!this.scheme.includes(_value.protocol))
					return false;
			}
			
			_value = _value.href;
			
			if(this.unique && this.links.includes(_value))
				return false;
		}
		catch(_err) {}

		this.links.push(_value);
		return true;
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
