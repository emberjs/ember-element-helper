import {
  appEmberSatisfies,
  importSync,
  macroCondition,
} from '@embroider/macros';

import type { ComponentLike } from '@glint/template';

export type ElementFromTagName<T extends string> =
  T extends keyof HTMLElementTagNameMap ? HTMLElementTagNameMap[T] : Element;

type Positional<T extends string> = [name: T];
type Return<T extends string> = ComponentLike<{
  Element: ElementFromTagName<T>;
  Blocks: { default: [] };
}>;

export interface ElementSignature<T extends string> {
  Args: {
    Positional: Positional<T>;
  };
  Return: Return<T> | undefined;
}

// The value is the native helper or a classic Helper class, so the type promises neither.
type ElementHelper = <T extends string>(
  ...positional: Positional<T>
) => ElementSignature<T>['Return'];

export default (macroCondition(appEmberSatisfies('>=7.1.0'))
  ? (importSync('@ember/helper') as { element: unknown }).element
  : (importSync('../classic-element.js') as { default: unknown })
      .default) as ElementHelper;
