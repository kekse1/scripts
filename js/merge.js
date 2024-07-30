#!/usr/bin/env node

// 
// Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
// https://kekse.biz/ https://github.com/kekse1/scripts/
// v0.2.1
//
// I tried to merge multiple (.gguf) model files via `cat`,
// but the resulting file size was much bigger than the sum
// of all files together... now with this it worked.
//
// To be more flexible, we're *appending* to the output file;
// So please delete an already existing one before, if you'd
// like to create it from zero.
//

if(process.argv.length < 4)
{
	console.error('Syntax: $0 <output> <input> [ ... ]');
	process.exit(1);
}

import path from 'node:path';

for(var i = 2; i < process.argv.length; ++i)
{
	process.argv[i] = path.resolve(process.argv[i]);
	if(i > 2) console.log(process.argv[i]);
}

const input = process.argv.slice(2);
const output = input.shift();

import fs from 'node:fs';

const out = fs.createWriteStream(output, {
	encoding: null, flags: 'a' });

out.once('error', (_err) => {
	console.dir(_err.stack);
	process.exit(3); });

const proc = () => {
	if(input.length === 0)
	{
		out.end();
		console.info('done. :-)');
		process.exit();
	}

	console.log('using next stream (%d left).', input.length);

	const stream = fs.createReadStream(input.shift(), {
		encoding: null, autoClose: true, emitClose: true });

	stream.pipe(out, { end: false });
	stream.once('close', () => setTimeout(proc));
};

proc();

