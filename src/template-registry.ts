import type ElementHelper from './helpers/element.ts';

export default interface EmberElementHelperRegistry {
  element: typeof ElementHelper;
}
