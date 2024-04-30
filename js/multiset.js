//
// Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
// https://kekse.biz/ https://github.com/kekse1/scripts/
// v0.2.0
//
// `MultiSet` is like a `Set`, but also counts the items
// (in their amount). It's extending a regular `Map`.
//

//
const DEFAULT_NEGATIVE = false;
const DEFAULT_FLOATING = false;
const DEFAULT_INC = 1;
const DEFAULT_DEC = 1;

//
Math.int = (_value, _inverse = false) => {
	const a = (_value < 0);
	const b = (!!_inverse);
	return (((((a&&b)||!(a||b)) ?
		Math.floor :
		Math.ceil)(_value)) || 0); };

//
class MultiSet extends Map
{
	constructor(... _args)
	{
		super(... _args);
	}

	get negative()
	{
		if(typeof this.NEGATIVE === 'boolean')
		{
			return this.NEGATIVE;
		}

		return DEFAULT_NEGATIVE;
	}

	set negative(_value)
	{
		if(typeof _value === 'boolean')
		{
			return this.NEGATIVE = _value;
		}
		else
		{
			delete this.NEGATIVE;
		}

		return this.negative;
	}

	get floating()
	{
		if(typeof this.FLOATING === 'boolean')
		{
			return this.FLOATING;
		}

		return DEFAULT_FLOATING;
	}

	set floating(_value)
	{
		if(typeof _value === 'boolean')
		{
			return this.FLOATING = _value;
		}
		else
		{
			delete this.FLOATING;
		}

		return this.floating;
	}

	set(_key, _value)
	{
		if(typeof _value === 'undefined')
		{
			if(super.has(_key))
			{
				_value = (this.get(_key) + 1);
			}
			else
			{
				_value = 1;
			}
		}
		else if(typeof _value !== 'number')
		{
			throw new Error('Invalid _value argument (no Number)');
		}

		if(_value <= 0 && !this.negative)
		{
			_value = 0;
		}
		else if((_value % 1) !== 0 && !this.floating)
		{
			_value = Math.int(_value);
		}

		super.set(_key, _value);
		return _value;
	}

	get add()
	{
		return this.increase;
	}

	get sub()
	{
		return this.decrease;
	}

	get inc()
	{
		return this.increase;
	}

	get dec()
	{
		return this.decrease;
	}

	increase(_key, _by = DEFAULT_INC)
	{
		if(typeof _by !== 'number')
		{
			_by = DEFAULT_INC;
		}

		var result;

		if(super.has(_key))
		{
			result = (super.get(_key) + _by);
		}
		else
		{
			result = _by;
		}

		if(result <= 0 && !this.negative)
		{
			result = 0;
		}
		else if((result % 1) !== 0 && !this.floating)
		{
			result = Math.int(result);
		}

		super.set(_key, result);
		return result;
	}

	decrease(_key, _by = DEFAULT_DEC)
	{
		if(typeof _by !== 'number')
		{
			_by = DEFAULT_DEC;
		}

		var result;

		if(super.has(_key))
		{
			result = (super.get(_key) - _by);
		}
		else
		{
			result = -_by;
		}

		if(result <= 0 && !this.negative)
		{
			result = 0;
		}
		else if((result % 1) !== 0 && !this.floating)
		{
			result = Math.int(result);
		}

		super.set(_key, result);
		return result;
	}

	has(_key)
	{
		if(! super.has(_key))
		{
			return 0;
		}

		return super.get(_key);
	}

	get get()
	{
		return this.has;
	}
}

export default MultiSet;

//

