# ember-element-helper

[![Build Status](https://github.com/tildeio/ember-element-helper/actions/workflows/ci.yml/badge.svg)](https://github.com/tildeio/ember-element-helper/actions/workflows/ci.yml)

Dynamic element helper for Glimmer templates.

This addon provides a ~~polyfill~~ high fidelity reference implementation of
[RFC #389](https://github.com/emberjs/rfcs/pull/389), including the proposed
amendments in [RFC PR #620](https://github.com/emberjs/rfcs/pull/620).

Please note that while [RFC #389](https://github.com/emberjs/rfcs/pull/389)
has been approved, it has not been implemented in Ember.js yet. As such, the
feature is still subject to change based on implementation feedback.

When this feature is implemented in Ember.js, we will release a 1.0 version of
this addon as a true polyfill for the feature, allowing the feature to be used
on older Ember.js versions and be completely inert on newer versions where the
official implementation is available.

## Compatibility

* Ember.js v3.28 or above
* Ember CLI v3.28 or above
* Node.js v12 or above

## Limitations

This implementation has the following known limitations:

* By default, an auto-generated `id` attribute will be added to the element
  (e.g. `id="ember123"`). It is possible to override this by providing an
  `id` attribute when invoking the component (e.g. `<Tag id="my-id" />`).
  However, it is not possible to remove the `id` attribute completely. The
  proposed helper will not have this behavior, as such this should not be
  relied upon (e.g. in CSS and `qunit-dom` selectors).

* The element will have an `ember-view` class (i.e. `class="ember-view"`).
  This is in addition and merged with the class attribute provided when
  invoking the component (e.g. `<Tag class="my-class" />` will result in
  something like `<div class="ember-view my-class" />`). It is not possible
  to remove the `ember-view` class. The proposed helper will not have this
  behavior, as such this should not be relied upon (e.g. in CSS and `qunit-dom`
  selectors).

* In Ember versions before 3.11, modifiers cannot be passed to the element,
  even when addons such as the [modifier manager](https://github.com/ember-polyfills/ember-modifier-manager-polyfill)
  and [on modifier](https://github.com/buschtoens/ember-on-modifier) polyfills
  are used. Doing so requires [RFC #435](https://github.com/emberjs/rfcs/blob/master/text/0435-modifier-splattributes.md)
  which is first available on Ember 3.11. This is an Ember.js limitation,
  unrelated to this addon.

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

### Glint 1 usage in `.hbs` templates

With Glint 1, to use a typed `(element)` helper in `.hbs` templates, import
the addon's Glint template registry and extend your app's registry declaration
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
