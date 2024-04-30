//
// Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
// https://kekse.biz/ https://github.com/kekse1/scripts/
// v0.2.1
//
// Intersection for Arrays.
//
// Works with any data type (so no optimization like
// binary search possible here). Respects multiple
// occurences (if no (true) is in your arguments).
//
// Depends on my `MultiSet`:
// https://github.com/kekse1/scripts/blob/master/js/multiset.js
//

//
import MultiSet from './multiset.js';

//
Reflect.defineProperty(Array, 'intersection', { value: (... _args) => {
	var unique = false;
	for(var i = 0; i < _args.length; ++i) {
		if(typeof _args[i] === 'boolean')
			unique = _args.splice(i--, 1)[0];
		else if(!Array.isArray(_args[i]) || _args[i].length === 0)
			_args.splice(i--, 1); }
	if(_args.length === 0) return [];
	const result = []; const map = new Map();
	const sets = new Array(_args.length);
	for(var j = 0; j < _args.length; ++j) {
		sets[j] = new MultiSet();
		for(var i = 0; i < _args[j].length; ++i) {
			sets[j].add(_args[j][i]);
			const mapItem = (map.has(_args[j][i]) ?
				map.get(_args[j][i]) : new Set());
			mapItem.add(j);
			map.set(_args[j][i], mapItem); }}
	var min; for(const item of map) {
		if(item[1].length < _args.length) continue;
		min = null; for(var i = 0; i < _args.length; ++i) {
			if(min === null) min = sets[i].get(item[0]);
			else min = Math.min(min, sets[i].get(item[0])); }
		while(min-- > 0) result.push(item[0]); }
	if(unique) return result.unique(); return result;
}});

Reflect.defineProperty(Array.prototype, 'unique', { value: function()
{
	return Array.from(new Set(this.valueOf()));
}});

//
