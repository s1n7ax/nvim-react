return {

	-- runs before / after each render
	BEFORE_RENDER = 'BEFORE_RENDER',
	AFTER_RENDER = 'AFTER_RENDER',

	-- runs before / after each re-render
	-- following will not be executed in the first render of the effect
	BEFORE_RE_RENDER = 'BEFORE_RE_RENDER',
	AFTER_RE_RENDER = 'AFTER_RE_RENDER',

	-- runs before / after only once at the first render
	BEFORE_INIT_RENDER = 'BEFORE_INIT_RENDER',
	AFTER_INIT_RENDER = 'AFTER_INIT_RENDER',
}
