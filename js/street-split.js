#!/usr/bin/env node

/*
 * Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
 * https://kekse.biz/ https://github.com/kekse1/scripts/
 * v0.2.0
 *
 * It's merely kinda proof of concept that state parsers can be as good as regular expressions, or even better; ;-D
 * < https://www.php.de/forum/webentwicklung/php-einsteiger/1614566-stra%C3%9Fe-und-hausnummer-korrekt-trennen >
 * 
 */

const examples = [
	'',
	'Straße',
	'  Straße   133  (Berlin)  ',
	'Straße des 17. Juni 113a',
	'Straße des 17. Juni 113a-113z',
	'Straße des 17. Juni 113a - 113z',
	'Straße des 17. Juni 113 a',
	'Straße des 17. Juni 113 a-113 z',
	'Straße des 17. Juni 113/114',
	'Straße des 17. Juni 113a/114a',
	'Straße des 17. Juni 113a 2. hof hinterhaus aufgang a II'
];

const isValidChar = (_byte) => {
	if(_byte <= 32 || _byte === 127)
	{
		return true;
	}
	else if(_byte >= 48 && _byte <= 57)
	{
		return true;
	}
	else if(_byte >= 65 && _byte <= 90)
	{
		return true;
	}
	else if(_byte >= 97 && _byte <= 122)
	{
		return true;
	}

	return false;
};

const isWhiteSpace = (_byte) => {
	return (_byte <= 32 || _byte === 127);
};

const splitStreet = (_string) => {
	var nLen, open, rem, white;
	var num = [];

	for(var i = 0, j = 0; i < _string.length; ++i)
	{
		if(_string[i] !== ' ' && !isNaN(_string[i]))
		{
			nLen = 0;
			open = '';
			white = -1;

			lookLoop: for(; i < _string.length; ++i)
			{
				if(_string[i] === '.')
				{
					if(white > -1)
					{
						i = white;
						nLen -= (i - white + 1);
					}

					break;
				}
				else if(_string[i] === '-' || _string[i] === '/')
				{
					++nLen;
					open = _string[i];
				}
				else if(isValidChar(_string.charCodeAt(i)))
				{
					if(!isWhiteSpace(_string.charCodeAt(i)))
					{
						white = i;
					}

					++nLen;
				}
				else if(open)
				{
					++nLen;
				}
				else
				{
					break;
				}
			}

			if(nLen > 0)
			{
				num[j++] = [ (i - nLen), nLen ];
			}
		}
	}

	if(num.length === 0)
	{
		num = null;
	}
	else
	{
		num = num[num.length - 1];
	}

	var street = '';
	var number = '';

	for(var i = 0; i < _string.length; ++i)
	{
		if(num && i === num[0])
		{
			number = _string.substr(i, num[1]);
			i += num[1] - 1;
			num = null;
		}
		else
		{
			street += _string[i];
		}
	}

	street = trim(street);
	number = trim(number);

	if(!number)
	{
		if(street)
		{
			return [ street ];
		}

		return [];
	}

	return [ street, number ];
};

const trim = (_string) => {
	const reverse = (_string) => _string.split('').reverse().join('');
	const isTrash = (_char) => { const byte = _char.charCodeAt(0);
		return (byte <= 32 || byte === 127); };

	const proceed = (_string) => { var result = '', trash;

		for(var i = 0; i < _string.length; ++i)
		{
			trash = isTrash(_string[i]);

			if(!trash)
			{
				result += _string[i];
			}
			else if(result.length === 0 || isTrash(result[result.length - 1]))
			{
				continue;
			}
			else
			{
				result += _string[i];
			}
		}
		
		return result; };
	
	var result = proceed(_string);
	return reverse(proceed(reverse(result)));
};

//
console.dir(examples);
console.log();
for(const e of examples)
	console.dir(splitStreet(e));
