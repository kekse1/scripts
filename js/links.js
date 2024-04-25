/*
 * Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
 * https://kekse.biz/ https://github.com/kekse1/scripts/
 * v0.2.2
 */

//
const DEFAULT_ENCODING = 'utf8';
const DEFAULT_ATTRIBS = [ 'href', 'src' ];
const DEFAULT_FILTER = [ 'http:', 'https:' ];

//
class Links
{
	constructor(_source, ... _args)
	{
		var source = null;
		var filter = [];

		for(var i = 0; i < _args.length; ++i)
		{
			if(typeof _args[i] === 'string')
			{
				source = _args.splice(i--, 1)[0];
			}
			else if(array(_args[i]))
			{
				filter.push(... _args.splice(i--, 1)[0]);
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

		if(filter.length > 0)
		{
			this.filter = filter;
		}
		else
		{
			this.filter = null;
		}

		this.source = _source || null;
		this.links = [];
		this.reset();
	}

	static filter(_array, _filter, _source)
	{
		if(!Array.isArray(_filter) || _filter.length === 0)
		{
			_filter = DEFAULT_FILTER;
		}
		
		const result = [];
		var res;

		for(var i = 0, j = 0; i < _array.length; ++i)
		{
			if(res = this.url(_array[i], _source))
			{
				if(_filter.includes(res.protocol))
				{
					if(typeof _array[i] === 'string')
					{
						res = this.href(res);
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
			return new URL(_url_array, _source);
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

	onData(_chunk)
	{
		if(_chunk === null)
		{
			return this.finish();
		}

		const attribs = Links.attribs;
		var byte, char;

		chunkLoop: for(var i = 0; i < _chunk.length; ++i)
		{
			byte = (char = _chunk[i]).charCodeAt(0);

			if(byte < 32 || byte === 127)
			{
				byte = 32;
				char = ' ';
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

				if(this.value)
				{
					this.links.push(this.value);
				}

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
					if(_chunk.at(i, a, false))
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

				if(this.value)
				{
					this.links.push(this.value);
				}

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

		if(this.filter)
		{
			this.links = Links.filter(this.links, null, this.source);
		}
		
		return this.links;
	}
}

export default Links;

//
