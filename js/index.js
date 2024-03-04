#!/usr/bin/env node

//
//is TODO atm./!!
//

//
// Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
// https://kekse.biz/
// v0.4.0
//
// Helper script for my v4 project @ https://github.com/kekse1/v4/.
//
// Will generate (at least) two .json output files from the state of my
// JavaScript web/ and lib/ (w/ globals/) state. I'm using it to publish
// this index on my private website/homepage https://kekse.biz/
// (see the `Source Code` menu item).
//
// The INDEX is being encoded into `stdout`, the SUMMARY into `stderr`.
// Please use a shell stream pipeline to write to two .json files, just
// like this: `./index.js >index.json 2>summary.json`.
//
// But this only holds if called this script withOUT arguments. With two
// file paths these are used, so we're using my `console.confirm()` before
// writing to any file..
//

//
const PATH_SUB = [ 'lib', 'web' ];
var PATH = '../js/';
var PATH_INDEX, PATH_SUMMARY;

const DEFAULT_MODE_DIR = 0o700;
const DEFAULT_MODE_FILE = 0o600;

//
var withFiles = (process.argv.length > 2);
var INDEX = process.argv[2];
var SUMMARY = process.argv[3];

//
import { ready } from '../js/lib.js';
ready(() => {

	//
	if(withFiles)
	{
		if(path.isValid(INDEX) && path.isValid(SUMMARY))
		{
			INDEX = path.resolve(INDEX);
			SUMMARY = path.resolve(SUMMARY);

			const dirIndex = path.dirname(INDEX);
			const dirSummary = path.dirname(SUMMARY);

			if(fs.exists(dirIndex))
			{
				if(!fs.exists.directory(dirIndex))
				{
					console.error('Path to index output file exists, but ain\'t a directory!');
					process.exit(2);
				}
			}
			else
			{
				fs.mkdirSync(dirIndex, { recursive: true, mode: DEFAULT_MODE_DIR });
			}

			if(fs.exists(dirSummary))
			{
				if(!fs.exists.directory(dirSummary))
				{
					console.error('Path to summary output file exists, but ain\'t a directory!');
					process.exit(3);
				}
			}
			else
			{
				fs.mkdirSync(dirSummary, { recursive: true, mode: DEFAULT_MODE_FILE });
			}

			if(fs.exists(INDEX))
			{
				if(!fs.exists.file(INDEX))
				{
					console.error('Index output file path exists, but ain\'t a regular file!');
					process.exit(4);
				}
			}

			if(fs.exists(SUMMARY))
			{
				if(!fs.exists.file(SUMMARY))
				{
					console.error('Summary output file path exists, but ain\'t a regular file!');
					process.exit(5);
				}
			}
		}
		else
		{
			console.error('Invalid file name(s), please correct one or both.');
			process.exit(1);
		}
	}

	//
	console.info('Creates .json output for JavaScript code of % directories.', PATH_SUB.length);
	console.log();

	//
	PATH = path.join(modulePath(import.meta.url).directory, PATH);

	for(var i = 0; i < PATH_SUB.length; ++i)
		PATH_SUB[i] = path.join(PATH, PATH_SUB[i]);

	//
	console.info('Using following input paths:');
	for(const sub of PATH_SUB)
		console.info(' # ' + sub.quote(`'`));
	console.log();

	if(withFiles)
	{
		console.info('Using following output paths (for .json code):');
		console.info('  Index: ' + INDEX.quote());
		console.info('Summary: ' + SUMMARY.quote());
		console.log();

		console.confirm(proceed, 'Do you really want to continue (and WRITE DATA to two files) [Yes|No]? ');
	}
	else proceed(null);
});

//
const proceed = (_bool = null, _answer) => { if(_bool === false) { console.log('Goodbye!'); process.exit(); }
	var amount = 0; const cb = () => { if(--amount <= 0) return handle(result); };
	const result = Object.create(null); for(const sub of PATH_SUB) fs.readdir(sub, {
		encoding: 'utf8', withFileTypes: true, recursive: true }, (_err, _files) => { if(_err) return error(_err);
			for(var i = 0; i < _files.length; ++i) { if(_files[i].name[0] !== '.' && /*_files[i].isFile() &&*/ _files[i].name.endsWith('.js')) {
				++amount; const p = path.join(_files[i].path, _files[i].name); result[p] = {
					base: path.basename(_files[i].name, '.js'),
						name: path.join(_files[i].path, _files[i].name)
							.split(path.sep).slice(-2).join(path.sep) };
				fs.stat(p, { bigint: false }, (_err, _stats) => {
					if(_err) return error(_err); else cb();
					result[p].size = Math.size.render(result[p].bytes = _stats.size).toString(); }); }}}); };

const handle = (_result) => {
	var rest = Object.keys(_result).length; const cb = (_path, _full, _real) => {
		_result[_path].full = _full; _result[_path].real = _real;
		if(--rest <= 0) return prepare(_result); };
	for(const p in _result) countLines(p, cb); };

const countLines = (_path, _callback) => { var full = 0, real = 0, last;
	const stream = fs.createReadStream(_path, { autoClose: true });
	stream.on('data', (_chunk) => { for(var i = 0; i < _chunk.length; ++i) {
		if(_chunk[i] === 10) { ++full; if(last !== 10) ++real; } last = _chunk[i]; }});
	stream.on('end', (... _a) => _callback(_path, full, real)); return stream; };

//
const prepare = (_result) => { const keys = Object.keys(_result);
	const result = new Array(keys.length); for(var i = 0; i < keys.length; ++i)
		result[i] = _result[keys[i]]; result.sort('bytes', false); return finish(result); };

const prepareSummary = (_result) => {
	//TODO/!!
	return {}; };

//
const finish = (_result) => { //index(_result); summary(_result);
console.dir(_result);
	if(!withFiles) console.debug(4, 'Success with % files!', _result.length); };

const index = (_result) => { if(!withFiles) return process.stdout.write(JSON.stringify(_result));
	//TODO/write file(s)!
};

const summary = (_result) => { if(!withFiles) return process.stderr.write(JSON.stringify(prepareSummary(_result)));
	//TODO/!!write file(s)!!
};

//

