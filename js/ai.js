#!/usr/bin/env node

/*
 * Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
 * https://kekse.biz/ https://github.com/kekse1/scripts/
 * v0.0.1
 *
 * => THIS IS STILL *TODO*!! doesn't work yet.
 *
 * https://lmstudio.ai/docs/local-server
 * https://platform.openai.com/docs/api-reference/chat/create
 *
 */

//
const DEFAULT_TEMPERATURE = 0.8;
const DEFAULT_MAX_TOKENS = -1;

//
const getSystemPrompt = () => {
	return 'Bitte immer in deutscher Sprache antworten.';
};

const getUserPrompt = () => {
	var result = '';

	for(var i = 2; i < process.argv.length; ++i)
	{
		result += process.argv[i] + ' ';
	}

	result = result.slice(0, -1);
	return result;
};

const getOptions = (_options) => {
	if(!_options) _options = {};
	if(!('model' in _options)) _options.model = null;//DEFAULT_MODEL;
	if(!('top_p' in _options)) _options.top_p = null;
	if(!('top_k' in _options)) _options.top_k = null;
	if(!('messages' in _options)) _options.messages = null;
	if(!('temperature' in _options)) _options.temperature = DEFAULT_TEMPERATURE;
	if(!('max_tokens' in _options)) _options.max_tokens = DEFAULT_MAX_TOKENS;
	if(!('stream' in _options)) _options.stream = true;
	if(!('stop' in _options)) _options.stop = null;
	if(!('presence_penalty' in _options)) _options.presence_penalty = null;
	if(!('frequency_penalty' in _options)) _options.frequency_penalty = null;
	if(!('logit_bias' in _options)) _options.logit_bias = null;
	if(!('repeat_penalty' in _options)) _options.repeat_penalty = null;
	if(!('seed' in _options)) _options.seed = null;
	return _options;
};

const getData = (_options) => { const result = getOptions(_options);
	if(!result.messages) result.messages = [
		{ 'role': 'system', 'content': getSystemPrompt() },
		{ 'role': 'user', 'content': getUserPrompt() } ];
	return result;
};

//
const header = {
	'Content-Type': 'application/json'
};

//
console.dir(getData());
