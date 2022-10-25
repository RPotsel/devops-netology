// this file has the param overrides for the default environment
local base = import './base.libsonnet';

base {
  components +: {
    db +: {
      vol_id: 'prod',
    },
    backend +: {
      replicas: 3,
    },
    frontend +: {
      replicas: 3,
    },
    // api.bigdatacloud.net
    endpoint +: {
      ep: '13.248.207.97',
    }
  }
}
