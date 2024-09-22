#!/usr/bin/env node

/*
 * Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
 * https://kekse.biz/ https://github.com/kekse1/scripts/
 * v0.2.0
 */

/*
 * With this script, you can calculate and convert between offsets and
 * lines with columns, or count them, etc. Without any parameter it'll
 * show you the whole countings, and with another parameter combination
 * you can even get to know how many columns a specific line has. ETC.
 *
 *	Syntax: offset [ <file> ] <offset/line> [ <column> ]
 *
 * The optional file path can be anywhere in your command line,
 * but if you define both integer parameters, their order counts.
 *
 * Here are the allowed parameter constellations, again:
 *
 * (a) = null
 * (b) = null
 *	.. shows how many offsets, columns and lines are counted in total.
 * (a) = int > 0
 * (b) = int > 0
 * 	.. displays an offset to line/column comb.
 * (a) = int > 0
 * (b) = null
 *	.. as offset param, this will show you a line/column to it.
 * (a) = int > 0
 * (b) = int = 0
 *	.. displays how many columns your specific line has.
 */ 
 
//
import path from 'node:path';
import fs from 'node:fs';

//
var line = 0, column = 0, offset = 0;

const readFile = (_path, _a, _b) => {
	//
	const printResult = () => {
		//
		if(offset === 0)
		{
			line = column = 0;
		}
		
		//
		if(_path !== '-')
		{
			console.log(' Path: ' + _path);
			console.log(' File: ' + path.basename(_path));
		}
		
		if(_a === null && _b === null)
		{
			console.log('Bytes: ' + offset);
			console.log('Lines: ' + line);
			return;
		}
	};

	//
	const stream = fs.createReadStream(_path, {
		flags: 'r', encoding: 'utf8', autoClose: true, emitClose: true });
		
	if(_path === '/dev/stdin')
	{
		_path = '-';
	}
	else
	{
		_path = fs.realpathSync(_path, { encoding: 'utf8' });
	}

	//
	stream.once('end', () => {
		printResult();
	});

	stream.on('data', (_chunk) => {
		for(var i = 0; i < _chunk.length; ++i)
		{
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
				
				column = 0;
				++line;
			}
			else if(_chunk[i] === '\r')
			{
				if(_chunk[i + 1] === '\n')
				{
					++offset;
					++i;
				}
				
				column = 0;
				++line;
			}
			else
			{
				++column;
			}
		}
	});

};

//
const getArguments = (_vector = process.argv, _start = 2) => {
	var file = '-', a = null, b = null;

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
		else if(file === '-')
		{
			file = _vector.splice(i--, 1)[0];
		}
		else
		{
			console.error('Already defined a file path, so you got to many parameters.');
			process.exit(2);
		}
	}
	
	return checkArguments(file, a, b);
};

const checkArguments = (_file, _a, _b) => {
	//
	if(_file === '-')
	{
		_file = '/dev/stdin';
	}

	//
	const invalid = (_code = 1) => {
		console.error('Invalid parameters defined.');
		console.info('JFYI: Look at the top of this script for more info.');
		return process.exit(_code);
	};
	
	//
	if(_a === null && _b !== null)
	{
		return invalid();
	}
	else if(_a === 0)
	{
		return invalid();
	}

	//
	return [ _file, _a, _b ];
};

//
readFile(... getArguments());

//
