#!/usr/bin/env node

//
// Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
// https://kekse.biz/
// v0.2.0
//
// Helper script for my v4 project @ https://github.com/kekse1/v4/.
//
// Will generate (at least) two .json output files from the state of my
// JavaScript web/ and lib/ (w/ globals/) state. I'm using it to publish
// this index on my private website/homepage https://kekse.biz/
// (see the `Source Code` menu item).
//
// It's currently under development, so stay tuned (currently working on
// TWO projects, this night, next day, ...)! ;-)
//
// BTW: The plan was TWO .json output files.. but I'm thinking about using
// both [ stdout, stderr ] streams to relay such output to files (via shell
// `>` and `2>` stream relays). THEN there'd be no need to use my
// `console.confirm()` or so?! etc.. l8rs.
//

//
const PATH_SUB = [ 'lib', 'web' ];
const INDEX = 'index.json';
const SUMMARY = 'summary.json';

//
var PATH = '../js/';
var PATH_INDEX, PATH_SUMMARY;

//
import { ready } from '../js/lib.js';
ready(() => {

	//
	console.info('Will create .json output for JavaScript code in % directories.', PATH_SUB.length);
	console.log();

	//
	PATH = path.join(modulePath(import.meta.url).directory, PATH);

	for(var i = 0; i < PATH_SUB.length; ++i)
		PATH_SUB[i] = path.join(PATH, PATH_SUB[i]);

	PATH_INDEX = path.resolve(INDEX);
	PATH_SUMMARY = path.resolve(SUMMARY);

	//
	console.info('Using following input paths:');
	for(const sub of PATH_SUB)
		console.info(' # ' + sub.quote(`'`));
	console.log();
	console.info('Using following output paths (for .json):');
	console.info('  Index: ' + PATH_INDEX.quote(`'`));
	console.info('Summary: ' + PATH_SUMMARY.quote(`'`));
	console.log();
	console.confirm(proceed);
});

//
const proceed = (_bool, _answer) => { if(!_bool) { console.log('Goodbye!'); process.exit(); }
	var amount = (PATH_SUB.length * 2); const cb = () => { if(--amount <= 0) return handle(result); };
	const result = Object.create(null); for(const sub of PATH_SUB) fs.readdir(sub, {
		encoding: 'utf8', withFileTypes: true, recursive: true }, (_err, _files) => {
			if(_err) return error(_err); for(var i = 0; i < _files.length; ++i) {
				if(_files[i].name[0] !== '.' && _files[i].isFile() && _files[i].name.endsWith('.js')) {
					const p = path.join(_files[i].path, _files[i].name); result[p] = {
						name: _files[i].name, key: path.join(_files[i].path, _files[i].name).split(path.sep).slice(-2) };
					fs.stat(p, { bigint: false }, (_err, _stats) => {
						if(_err) return error(_err); else cb();
						result[p].size = _stats.size; }); }} cb(); }); };

const handle = (_result) => {
	var rest = Object.keys(_result).length; const cb = (_path, _full, _real) => {
		_result[_path].full = _full; _result[_path].real = _real;
		if(--rest <= 0) return finish(_result); };
	for(const p in _result) countLines(p, cb); };

const countLines = (_path, _callback) => { var full = 0, real = 0, last;
	const stream = fs.createReadStream(_path, { autoClose: true });
	stream.on('data', (_chunk) => { for(var i = 0; i < _chunk.length; ++i) {
		if(_chunk[i] === 10) { ++full; if(last !== 10) ++real; } last = _chunk[i]; }});
	stream.on('end', (... _a) => _callback(_path, full, real)); return stream; };

//
const finish = (_result) => {
	console.dir(_result);
};

//

