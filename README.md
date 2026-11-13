# ember-element-helper

[![Build Status](https://github.com/tildeio/ember-element-helper/actions/workflows/ci.yml/badge.svg)](https://github.com/tildeio/ember-element-helper/actions/workflows/ci.yml)

Dynamic element helper for Glimmer templates.

This addon is a polyfill for [RFC #389](https://github.com/emberjs/rfcs/pull/389),
including the proposed amendments in
[RFC PR #620](https://github.com/emberjs/rfcs/pull/620).

From ember-source 7.1, this addon re-exports the `element` helper from
`@ember/helper`. The classic implementation is not part of your build. This
needs `@embroider/macros` 1.19 or newer in your app. With an older version, the
build fails.

## Compatibility

* Ember.js v3.28 or above
* Ember CLI v3.28 or above
* Node.js v12 or above

## Behavior before and from ember-source 7.1

Before ember-source 7.1, the helper renders a classic component. From 7.1, the
native helper renders the element. The differences are:

| | Before 7.1 | From 7.1 |
|---|---|---|
| `id` attribute | An auto-generated `id` (e.g. `id="ember123"`) is added. You can override it (e.g. `<Tag id="my-id" />`), but you cannot remove it. | No `id` is added. |
| `class` attribute | An `ember-view` class is added and merged with your classes. You cannot remove it. | No class is added. |
| `null` or `undefined` tag name | Nothing is rendered. | An assertion fails in development. In production, ember-source 7.4 renders the block without a wrapping element. |

Do not rely on the auto-generated `id` or the `ember-view` class, for example
in CSS and `qunit-dom` selectors. To render nothing, put the invocation in an
`{{#if}}` block.

## Installation

```
ember install ember-element-helper
```

## Usage

```hbs
{{#let (element this.tagName) as |Tag|}}
  <Tag class="my-tag">hello world!</Tag>
{{/let}}
```

You can also pass around the result of invoking this helper into any components
that accepts "contextual components" as arguments:

```hbs
<MyComponent @tag={{element "span"}} />
```

```hbs
{{!-- in my-component.hbs --}}
{{#let @tag as |Tag|}}
  <Tag class="my-tag">hello world!</Tag>
{{/let}}

{{!-- ...or more directly... --}}
<@tag class="my-tag">hello world!</@tag>
```

### Single File Components

Using the `(element)` helper with [first class component
templates](http://emberjs.github.io/rfcs/0779-first-class-component-templates.html):

```gjs
import { element } from 'ember-element-helper';

<template>
  {{#let (element @tagName) as |Tag|}}
    <Tag class="my-tag">hello world!</Tag>
  {{/let}}
</template>
```

### Glint Usage in Classic Mode

In order to use a typed `(element)` helper in classic mode, you need to import
the addon's glint template registry and extend your app's registry declaration
as described in the [Using
Addons](https://typed-ember.gitbook.io/glint/using-glint/ember/using-addons#using-glint-enabled-addons)
documentation:

```ts
import '@glint/environment-ember-loose';
import type EmberElementHelperRegistry from 'ember-element-helper/template-registry';

declare module '@glint/environment-ember-loose/registry' {
  export default interface Registry extends EmberElementHelperRegistry, /* other addon registries */ {
    // local entries
  }
}
```

> **Note:** Glint itself is still under active development, and as such breaking changes might occur.
> Therefore, Glint support by this addon is also considered experimental, and not covered by our SemVer contract!

### Typing your Components

When your component accepts an element with the `(element)` helper, you want to
give this argument a proper type. Here is how:

```ts
import type { ElementSignature } from 'ember-element-helper';

interface YourComponentSignature<T extends string> {
  Element: HTMLSectionElement;
  Args: {
    element?: ElementSignature['Return'];
  };
}
```

When the `@element` argument influences the `Element` of your component:

```ts
import type { ElementSignature, ElementFromTagName } from 'ember-element-helper';

interface YourComponentSignature<T extends string> {
  Element: ElementFromTagName<T>;
  Args: {
    element?: ElementSignature<T>['Return'];
  };
}
```

When your component already uses an element for a given condition. When
the condition isn't met, a fallback element is used. The fallback can even be
provided from the outside. Here is the type:

```ts
import type { ElementSignature, ElementFromTagName } from 'ember-element-helper';

interface YourComponentSignature<
  T extends string = 'section'
> {
  Element: HTMLButtonElement | HTMLAnchorElement | ElementFromTagName<T>;
  Args: {
    element?: ElementSignature<T>['Return'];
  };
}
```

## Contributing

See the [Contributing](CONTRIBUTING.md) guide for details.

## License

This project is licensed under the [MIT License](LICENSE.md).
