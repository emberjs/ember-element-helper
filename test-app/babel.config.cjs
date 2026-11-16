const {
  babelCompatSupport,
  templateCompatSupport,
} = require('@embroider/compat/babel');

module.exports = {
  plugins: [
    [
      'babel-plugin-ember-template-compilation',
      {
        transforms: [...templateCompatSupport()],
      },
    ],
    [
      'module:decorator-transforms',
      {
        runtime: {
          import: require.resolve('decorator-transforms/runtime-esm'),
        },
      },
    ],
    ...babelCompatSupport(),
  ],

  generatorOpts: {
    compact: false,
  },
};
