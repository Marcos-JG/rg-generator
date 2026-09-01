import fact from './sv/fact.json';
import ccf from './sv/ccf.json';
import ncre from './sv/ncre.json';
import ndeb from './sv/ndeb.json';
import nabn from './sv/nabn.json';
import reci from './sv/reci.json';
import fesp from './sv/fesp.json';

const configs = {
  sv: {
    '01': fact,
    '03': ccf,
    '04': nabn,
    '05': ndeb,
    '06': ncre,
    '08': reci,
    '09': fesp,
  },
  gt: {},
  cr: {},
  pa: {},
  do: {},
};

export function getConfig(country, docType) {
  return configs[country]?.[docType] || null;
}

export function getAvailableDocTypes(country) {
  return Object.keys(configs[country] || {});
}

export function getSupportedCountries() {
  return Object.keys(configs).filter((c) => Object.keys(configs[c]).length > 0);
}

export default configs;
