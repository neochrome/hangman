import resolve from 'rollup-plugin-node-resolve';
import livereload from 'rollup-plugin-livereload';

const isWatching = process.env['WATCHING'] === '1';

let plugins = [];
if (isWatching) { plugins.push(livereload()); }
plugins.push(resolve({ module: true, browser: true }));

export default {
	input: './lib/es6/src/app.js',
	output: {
		file: './public/app.js',
		format: 'iife',
		name: 'app',
	},
	plugins,
};
