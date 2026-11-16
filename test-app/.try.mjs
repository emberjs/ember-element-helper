import addon from '../.try.mjs';

const emberCli = {
  'ember-lts-3.28': '^4.12.0',
  'ember-latest': '^7.4.0',
  'ember-beta': '^7.4.0',
  'ember-alpha': '^7.4.0',
};

export default {
  scenarios: addon.scenarios.map(({ name, npm }) => ({
    name,
    npm: {
      devDependencies: {
        'ember-source': npm.devDependencies['ember-source'],
        ...(emberCli[name] ? { 'ember-cli': emberCli[name] } : {}),
      },
    },
  })),
};
