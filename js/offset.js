#!/usr/bin/env node

// 
// TODO /
// ain't working now.. i've to finish it [when i've got the time..]!
//

/*
 * Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
 * https://kekse.biz/ https://github.com/kekse1/scripts/
 * v0.1.0
 */

/*
 * This script will calculate either an offset to your
 * line/column parameters, or it'll calculate the line
 * and column for your offset parameter.
 *
 *	Syntax: offset [ <file> ] <offset/line> [ <column> ]
 *
 * If called with a single integer(!) parameter, this will be
 * your offset, so we'll calculate a position (line and column).
 * When a second integer(!) parameter is following, these both
 * will be the line and then the column, for which we'll
 * calculate a file offset.
 *
 * Either you define a file path (doesn't matter which position),
 * or the default input will be the stdin ('-' can be set, too).
 *
 * This was originally designed for `Node.js` (https://nodejs.org/).
 * A bash shell script version *would* be available (see 'sh/offset.sh'),
 * but I didn't finished it (since I decided for this .js version..).
 */
 
//
import fs from 'node:fs';

//
var line = 1, column = 1, offset = 0;

const printResult = (_offset, _line, _column, _exit = true, _none = false) => {
	console.log((_none ? '  Bytes' : 'Offset') + ': ' + _offset);
	console.log('  Line' + (_none ? 's' : '') + ': ' + _line);
	if(!_none) console.log('Column' + (_none ? 's' : '') + ': ' + _column);
	if(_exit) process.exit(typeof _exit === 'number' ? _exit : 0);
};

const readFile = (_path, _offset_line, _column = null) => {
	const stream = fs.createReadStream(_path, {
		flags: 'r', encoding: 'utf8', autoClose: true, emitClose: true });

	stream.once('end', () => {
		if(_offset_line !== null)
		{
			if(_column === null)
			{
				if(_offset_line > offset)
				{
					console.warn('Your offset parameter exceeds limit (%d)!', offset);
					process.exit(6);
				}
			}
			else if(_offset_line > line)
			{
				console.warn('Your line parameter exceeds limit (%d)!', line);
				process.exit(7);
			}
			else if(_offset_line === line && _column > column)
			{
				console.warn('Your column parameter exceeds limit (%d), in line (%d)!', column, line);
				process.exit(8);
			}
		}
	
		printResult(offset, --line, column, true, (_offset_line === null));
	});

	stream.on('data', (_chunk) => {
		for(var i = 0; i < _chunk.length; ++i)
		{
			//
			if(_offset_line !== null)
			{
				if(_column === null)
				{
					if(offset === _offset_line)
					{
						return printResult(offset, line, column, true, false);
					}
				}
				else if(line === _offset_line && column === _column)
				{
					return printResult(offset, line, column, true, false);
				}
			}
			
			//
			++offset;

			//
			if(_chunk[i] === '\n')
			{
				if(_chunk[i + 1] === '\r')
				{
					++offset;
					++i;
				}
				
				++line;
				column = 1;
			}
			else if(_chunk[i] === '\r')
			{
				if(_chunk[i + 1] === '\n')
				{
					++offset;
					++i;
				}
				
				++line;
				column = 1;
			}
			else
			{
				++column;
			}
		}
	});

};

const checkArguments = (_vector = process.argv, _start = 2) => {
	var file, a, b;

	for(var i = _start; i < _vector.length; ++i)
	{
		if(_vector[i].length === 0)
		{
			_vector.splice(i--, 1);
		}
		else if(_vector[i] === '--')
		{
			break;
		}
		else if(!isNaN(_vector[i]))
		{
			if(typeof a !== 'number')
			{
				a = Math.floor(Number(_vector.splice(i--, 1)[0]));
			}
			else if(typeof b !== 'number')
			{
				b = Math.floor(Number(_vector.splice(i--, 1)[0]));
			}
			else
			{
				console.error('Too many integer parameters, already defined two.');
				process.exit(1);
			}
		}
		else if(typeof file !== 'string')
		{
			file = _vector.splice(i--, 1)[0];
		}
		else
		{
			console.error('Already defined a file path, so you got to many parameters.');
			process.exit(2);
		}
	}

	if(typeof a !== 'number')
	{
		a = null;
	}
	else if(a < 0)
	{
		console.error('Invalid parameter (may not be below zero)');
		process.exit(3);
	}
	
	if(typeof b !== 'number')
	{
		b = null;
	}
	else if(b < 1)
	{
		console.error('Invalid column number (starts at 0)');
		process.exit(4);
	}
	else if(a < 1)
	{
		console.error('Invalid line parameter (may not be below one)');
		process.exit(5);
	}
	
	if(typeof file !== 'string' || file === '-')
	{
		file = '/dev/stdin';
	}
	
	return [ file, a, b ];
};

//
readFile(... checkArguments());

//
