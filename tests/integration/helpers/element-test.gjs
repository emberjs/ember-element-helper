import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  click,
  render,
  resetOnerror,
  settled,
  setupOnerror,
} from '@ember/test-helpers';
import { helper } from '@ember/component/helper';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { precompileTemplate } from '@ember/template-compilation';
import { tracked } from '@glimmer/tracking';

import {
  appEmberSatisfies,
  importSync,
  macroCondition,
} from '@embroider/macros';

import { element } from '#src/index.ts';

class State {
  @tracked tagName;

  constructor(tagName) {
    this.tagName = tagName;
  }
}

const ElementReceiver = <template>
  {{#let @tag as |Tag|}}
    <Tag id="content" ...attributes>{{yield}}</Tag>
  {{/let}}
</template>;

module('Integration | Helper | element', function (hooks) {
  setupRenderingTest(hooks);

  hooks.afterEach(() => resetOnerror());

  function expectError(assert, message) {
    assert.expect(1);
    setupOnerror((error) => assert.strictEqual(error.message, message));
  }

  test('it renders a tag with the given tag name', async function (assert) {
    await render(
      <template>
        {{#let (element "h1") as |Tag|}}
          <Tag id="content">hello world!</Tag>
        {{/let}}
      </template>,
    );

    assert.dom('h1#content').hasText('hello world!');
  });

  test('it does not render any tags when passed an empty string', async function (assert) {
    await render(
      <template>
        <div id="root">
          {{#let (element "") as |Tag|}}
            <Tag id="content">hello world!</Tag>
          {{/let}}
        </div>
      </template>,
    );

    assert.strictEqual(
      this.element.querySelector('#root').innerHTML.trim(),
      'hello world!',
    );
  });

  if (macroCondition(appEmberSatisfies('>=7.1.0'))) {
    test('it is the native helper', function (assert) {
      assert.strictEqual(element, importSync('@ember/helper').element);
    });

    test('it renders no `ember-view` class and no `id`', async function (assert) {
      await render(
        <template>
          {{#let (element "h1") as |Tag|}}
            <Tag>hello world!</Tag>
          {{/let}}
        </template>,
      );

      assert.dom('h1').doesNotHaveAttribute('class').doesNotHaveAttribute('id');
    });

    for (const [label, value] of [
      ['null', null],
      ['undefined', undefined],
    ]) {
      test(`it throws when passed ${label}`, async function (assert) {
        expectError(
          assert,
          'Assertion Failed: The argument passed to the `element` helper must be a string',
        );

        await render(
          <template>
            <div>
              {{#let (element value) as |Tag|}}
                <Tag id="content">hello world!</Tag>
              {{/let}}
            </div>
          </template>,
        );
      });
    }
  } else {
    test('it is the classic helper', async function (assert) {
      await render(
        <template>
          {{#let (element "h1") as |Tag|}}
            <Tag>hello world!</Tag>
          {{/let}}
        </template>,
      );

      assert.dom('h1').hasClass('ember-view').hasAttribute('id');
    });

    for (const [label, value] of [
      ['null', null],
      ['undefined', undefined],
    ]) {
      test(`it does not render anything when passed ${label}`, async function (assert) {
        await render(
          <template>
            <div id="root">
              {{#let (element value) as |Tag|}}
                <Tag id="content">hello world!</Tag>
              {{/let}}
            </div>
          </template>,
        );

        assert.strictEqual(
          this.element.querySelector('#root').innerHTML.trim(),
          '<!---->',
        );
      });
    }
  }

  test('it resolves from the registry in a loose mode template', async function (assert) {
    this.owner.register('helper:element', element);

    await render(
      precompileTemplate(
        `{{#let (element "h1") as |Tag|}}<Tag id="content">hello world!</Tag>{{/let}}`,
        { strictMode: false },
      ),
    );

    assert.dom('h1#content').hasText('hello world!');
  });

  test('it works with element modifiers', async function (assert) {
    let clicked = 0;
    const didClick = () => clicked++;

    await render(
      <template>
        {{#let (element "button") as |Tag|}}
          <Tag type="button" id="action" {{on "click" didClick}}>hello world!</Tag>
        {{/let}}
      </template>,
    );

    assert
      .dom('button#action')
      .hasAttribute('type', 'button')
      .hasText('hello world!');
    assert.strictEqual(clicked, 0, 'never clicked');

    await click('button#action');

    assert.strictEqual(clicked, 1, 'clicked once');

    await click('button#action');

    assert.strictEqual(clicked, 2, 'clicked twice');
  });

  test('it can be rendered multiple times', async function (assert) {
    await render(
      <template>
        {{#let (element "h1") as |Tag|}}
          <Tag id="content-1">hello</Tag>
          <Tag id="content-2">world</Tag>
          <Tag id="content-3">!!!!!</Tag>
        {{/let}}
      </template>,
    );

    assert.dom('h1#content-1').hasText('hello');
    assert.dom('h1#content-2').hasText('world');
    assert.dom('h1#content-3').hasText('!!!!!');
  });

  test('it can be passed to the component helper', async function (assert) {
    await render(
      <template>
        {{#let (component (element "h1")) as |Tag|}}
          <Tag id="content-1">hello</Tag>
        {{/let}}

        {{#let (element "h2") as |h2|}}
          {{#let h2 as |Tag|}}
            <Tag id="content-2">world</Tag>
          {{/let}}
        {{/let}}

        {{#let (element "h3") as |h3|}}
          {{#let (component h3) as |Tag|}}
            <Tag id="content-3">!!!!!</Tag>
          {{/let}}
        {{/let}}
      </template>,
    );

    assert.dom('h1#content-1').hasText('hello');
    assert.dom('h2#content-2').hasText('world');
    assert.dom('h3#content-3').hasText('!!!!!');
  });

  test('it renders when the tag name changes', async function (assert) {
    let count = 0;
    const counter = helper(() => ++count);
    const state = new State('h1');

    await render(
      <template>
        <div id="root">
          {{#let (element state.tagName) as |Tag|}}
            <Tag id="content">rendered {{counter}} time(s)</Tag>
          {{/let}}
        </div>
      </template>,
    );

    assert.dom('h1#content').hasText('rendered 1 time(s)');
    assert.dom('h2#content').doesNotExist();
    assert.dom('h3#content').doesNotExist();

    state.tagName = 'h2';
    await settled();

    assert.dom('h1#content').doesNotExist();
    assert.dom('h2#content').hasText('rendered 2 time(s)');
    assert.dom('h3#content').doesNotExist();

    state.tagName = 'h2';
    await settled();

    assert.dom('h1#content').doesNotExist();
    assert.dom('h2#content').hasText('rendered 2 time(s)');
    assert.dom('h3#content').doesNotExist();

    state.tagName = 'h3';
    await settled();

    assert.dom('h1#content').doesNotExist();
    assert.dom('h2#content').doesNotExist();
    assert.dom('h3#content').hasText('rendered 3 time(s)');

    state.tagName = '';
    await settled();

    assert.dom('h1#content').doesNotExist();
    assert.dom('h2#content').doesNotExist();
    assert.dom('h3#content').doesNotExist();

    assert.strictEqual(
      this.element.querySelector('#root').innerHTML.trim(),
      'rendered 4 time(s)',
    );

    state.tagName = 'h1';
    await settled();

    assert.dom('h1#content').hasText('rendered 5 time(s)');
    assert.dom('h2#content').doesNotExist();
    assert.dom('h3#content').doesNotExist();
  });

  test('it can be passed as argument and works with ...attributes', async function (assert) {
    const state = new State('p');

    await render(
      <template>
        <ElementReceiver
          @tag={{element state.tagName}}
          class="extra"
        >Test</ElementReceiver>
      </template>,
    );

    assert.dom('p#content').hasText('Test').hasClass('extra');

    state.tagName = 'div';
    await settled();

    assert.dom('div#content').hasText('Test').hasClass('extra');

    state.tagName = '';
    await settled();

    assert.strictEqual(this.element.innerText.trim(), 'Test');

    state.tagName = 'p';
    await settled();

    assert.dom('p#content').hasText('Test').hasClass('extra');
  });

  module('invalid usages', function () {
    test('it requires at least one argument', async function (assert) {
      expectError(
        assert,
        'Assertion Failed: The `element` helper takes a single positional argument',
      );

      await render(
        <template>
          <div>
            {{#let (element) as |Tag|}}
              <Tag id="content">hello world!</Tag>
            {{/let}}
          </div>
        </template>,
      );
    });

    test('it requires no more than one argument', async function (assert) {
      expectError(
        assert,
        'Assertion Failed: The `element` helper takes a single positional argument',
      );

      await render(
        <template>
          <div>
            {{#let (element "h1" "h2") as |Tag|}}
              <Tag id="content">hello world!</Tag>
            {{/let}}
          </div>
        </template>,
      );
    });

    test('it does not take any named arguments', async function (assert) {
      expectError(
        assert,
        'Assertion Failed: The `element` helper does not take any named arguments',
      );

      await render(
        <template>
          <div>
            {{#let (element "h1" id="content") as |Tag|}}
              <Tag id="content">hello world!</Tag>
            {{/let}}
          </div>
        </template>,
      );
    });

    test('it throws when passed a number', async function (assert) {
      expectError(
        assert,
        'Assertion Failed: The argument passed to the `element` helper must be a string (you passed `123`)',
      );

      await render(
        <template>
          <div>
            {{#let (element 123) as |Tag|}}
              <Tag id="content">hello world!</Tag>
            {{/let}}
          </div>
        </template>,
      );
    });

    test('it throws when passed a boolean', async function (assert) {
      expectError(
        assert,
        'Assertion Failed: The argument passed to the `element` helper must be a string (you passed `false`)',
      );

      await render(
        <template>
          <div>
            {{#let (element false) as |Tag|}}
              <Tag id="content">hello world!</Tag>
            {{/let}}
          </div>
        </template>,
      );
    });

    test('it throws when passed an object', async function (assert) {
      expectError(
        assert,
        'Assertion Failed: The argument passed to the `element` helper must be a string',
      );

      await render(
        <template>
          <div>
            {{#let (element (hash)) as |Tag|}}
              <Tag id="content">hello world!</Tag>
            {{/let}}
          </div>
        </template>,
      );
    });
  });
});
