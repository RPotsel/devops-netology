// this file has the param overrides for the default environment
local base = import './base.libsonnet';

base {
  components +: {
    db +: {
      vol_id: 'stage',
    },
    backend +: {
      replicas: 1,
    },
    frontend +: {
      replicas: 1,
    }
  }
}
