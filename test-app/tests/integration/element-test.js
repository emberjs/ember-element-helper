import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { precompileTemplate } from '@ember/template-compilation';

module('Integration | consumer app | element', function (hooks) {
  setupRenderingTest(hooks);

  test('`element` resolves in a loose mode template', async function (assert) {
    await render(
      precompileTemplate(
        `{{#let (element "h1") as |Tag|}}<Tag id="content">hello world!</Tag>{{/let}}`,
        { strictMode: false },
      ),
    );

    assert.dom('h1#content').hasText('hello world!');
  });
});
