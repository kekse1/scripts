#!/usr/bin/env node

// 
// Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
// https://kekse.biz/ https://github.com/kekse1/scripts/
// v0.1.0
// 
// **Early version, so only the real basics are covered.**
// 
// 'Folds' CSS style code. Earlier I used the `fold` (Linux) command, but that didn't work that well for what
// I needed the resulting code: had to filter out CSS classes in `.html` code and `grep` for them in many
// `.css` files - since `grep` is for lines, and `cut` is too stupid, .. I couldn't find the CSS styles in
// stylesheets without newlines, etc. ..
// 

if(process.argv.length < 3) {
	console.warn('One input file parameter needs to be defined!');
	process.exit(1); }
import fs from 'node:fs'; import os from 'node:os';
const iFile = process.argv[2]; if(!iFile || !fs.existsSync(iFile)) {
	console.error(`Invalid input file '${iFile}'!`);
	process.exit(2); }
const oFile = (iFile + '.fold'); console.info(`Output file is '${oFile}'.`);

const input = fs.createReadStream(iFile, {
	encoding: 'utf8', autoClose: true, emitClose: true });
const output = fs.createWriteStream(oFile, {
	encoding: 'utf8', autoClose: true, emitClose: true });

const repeatString = (_char, _amount) => { var result = ''; if(_amount <= 0) return result;
	while(--_amount >= 0) result += _char; return result; };

var quote = '', level = 0; input.on('data', (_chunk) => { var result = '';
		const lastChar = (_index) => { if(_index === 0) return ''; return _chunk[_index - 1]; };
		const nextChar = (_index) => { if(_index < (_chunk.length - 1)) return _chunk[_index + 1]; return ''; };
	for(var i = 0; i < _chunk.length; ++i) {  if(quote) { if(_chunk[i] === quote) quote = ''; result += _chunk[i]; } else {
		if(_chunk[i] === '\r' || _chunk[i] === ' ' || _chunk[i] === '\t' || _chunk[i] === '\n') continue;
			if(_chunk[i] === '{') ++level; else if(_chunk[i] === '}') if(--level < 0) level = 0; switch(_chunk[i]) {
			case '\'': case '"': case '`': quote = _chunk[i]; result += _chunk[i]; break;
			case '{': if(level > 1) result += '{'; else { result += ('\n{\n' + repeatString('\t', level));
				while(nextChar(i) === ' ' || nextChar(i) === '\t' || nextChar(i) === '\n') { ++i; }}; break;
			case '}': result += '}'; if(level <= 1) result += '\n'; if(level === 0) result += '\n'; break;
			case ';': if(lastChar(i) !== ';') result += ';'; result += '\n';
				while(nextChar(i) === ' ' || nextChar(i) === '\t' || nextChar(i) === '\n') ++i;
				if(nextChar(i) !== '}') result += repeatString('\t', level); break;
			case ':': if(level > 0) result += ': '; break;
			default: result += _chunk[i]; break; }}} if(result) output.write(result); });
input.once('close', () => { console.info(`Wrote %d bytes to '${oFile}'.`, output.bytesWritten);
	return output.close(() => { process.exit(0); }); });
