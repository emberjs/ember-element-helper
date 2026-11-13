// eslint-disable-next-line ember/no-classic-components
import EmberComponent from '@ember/component';
import Helper from '@ember/component/helper';
import { assert, runInDebug } from '@ember/debug';

import type { ElementSignature } from './helpers/element.ts';

type Positional<T extends string> = ElementSignature<T>['Args']['Positional'];
type Return<T extends string> = NonNullable<ElementSignature<T>['Return']>;

function UNINITIALIZED() {}

export default class ClassicElementHelper<T extends string> extends Helper<
  ElementSignature<T>
> {
  tagName: string | (() => void) = UNINITIALIZED;
  componentClass?: Return<T>;

  compute(params: Positional<T>, hash: object) {
    assert(
      'The `element` helper takes a single positional argument',
      params.length === 1,
    );
    assert(
      'The `element` helper does not take any named arguments',
      Object.keys(hash).length === 0,
    );

    const tagName = params[0];

    if (tagName !== this.tagName) {
      this.tagName = tagName;

      if (typeof tagName === 'string') {
        this.componentClass = class DynamicElement extends EmberComponent {
          tagName = tagName;
        } as unknown as Return<T>;
      } else {
        this.componentClass = undefined;

        runInDebug(() => {
          let message =
            'The argument passed to the `element` helper must be a string';

          try {
            message += ` (you passed \`${String(tagName)}\`)`;
          } catch {
            // ignore
          }

          assert(message, tagName === undefined || tagName === null);
        });
      }
    }

    return this.componentClass;
  }
}
