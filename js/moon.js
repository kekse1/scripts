/* 
 * Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
 * https://kekse.biz/ https://github.com/kekse1/scripts/
 * v0.2.1
 * 
 * Extends the `Date` object with moon phase calculations.
 * 
 * For more `Date` extensions take a look (for docs and concrete code):
 * # https://github.com/kekse1/v4/blob/git/docs/modules/lib/date.md
 * # https://github.com/kekse1/v4/blob/git/js/lib/globals/date.js
 */

//
Reflect.defineProperty(Date, 'moonPhase', { value: (_date = new Date()) => {
{
	if(typeof _date === 'number') _date = new Date(_date);
	else if(typeof _date === 'string' && !isNaN(_date)) _date = new Date(Number(_date));
	else if(!(_date instanceof Date)) throw new Error('Invalid _date argument');
	return (Date.moonDay(_date) / SYNODIC_MONTH);
}}});

Reflect.defineProperty(Date, 'moonDay', { value: (_date = new Date()) => {
	if(typeof _date === 'number') _date = new Date(_date);
	else if(typeof _date === 'string' && !isNaN(_date)) _date = new Date(Number(_date));
	else if(!(_date instanceof Date)) throw new Error('Invalid _date argument');
	const diffInMilliSec = (_date.getTime() - KNOWN_NEW_MOON.getTime());
	const diffInDays = (diffInMilliSec / (1000 * 60 * 60 * 24));
	return (diffInDays % SYNODIC_MONTH);
}});

Reflect.defineProperty(Date.prototype, 'moonPhase', { get: function()
{
	return Date.moonPhase(this);
}});

Reflect.defineProperty(Date.prototype, 'moonDay', { get: function()
{
	return Date.moonDay(this);
}});

// 
const moonPhaseIcon = [ '🌕', '🌔', '🌓', '🌒', '🌑', '🌑', '🌘', '🌗', '🌖', '🌕' ];
Reflect.defineProperty(Date, 'moonPhaseIcon', { get: () => [ ... moonPhaseIcon  ] });

const moonPhaseText = {
	en: [
		'New Moon',
		'Waxing Crescent',
		'First Quarter',
		'Waxing Gibbous',
		'Full Moon',
		'Waning Gibbous',
		'Last Quarter',
		'Waning Crescent'
	],
	de: [
		'Neumond',
		'Zunehmender Mond',
		'Halbmond',
		'Zunehmender Dreiviertelmond',
		'Vollmond',
		'Abnehmender Dreiviertelmond',
		'Halbmond',
		'Abnehmender Mond'
	]
};

Reflect.defineProperty(Date, 'moonPhaseText', {
	get: () => [ ... moonPhaseText ],
	set: (_lang) => { if(!String.isString(_lang, false)) return [ ... moonPhaseText ];
		else if((_lang = _lang.substr(0, 2).toLowerCase()) in moonPhaseText)
			return moonPhaseText[_lang];
		return [ ... moonPhaseText ]; }});

const SYNODIC_MONTH = 29.53058867;
Reflect.defineProperty(Date, 'moonDays', { get: () => SYNODIC_MONTH });

//const KNOWN_NEW_MOON = New Date(Date.UTC(2000, 0, 6, 19, 13));//!?
const KNOWN_NEW_MOON = new Date(2000, 0, 6, 19, 13);

//
