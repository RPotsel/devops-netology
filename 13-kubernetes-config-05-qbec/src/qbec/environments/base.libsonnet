// this file has the baseline default parameters
{
  components: { // required
    global: {
      pullPolicy: 'IfNotPresent',
    },
    db: {
      version: '13-alpine',
      vol_id: 'def',
      port: 5432,
      mem: '265Mi',
      cpu: '250m',
      user: 'postgres',
      pass: 'postgres',
      url: 'postgres-db-cip',
    },
    backend: {
      version: '0.1',
      url: 'backend-cip',
      port: 9000,
      replicas: 1,
    },
    frontend: {
      version: '0.1',
      url: 'frontend-lb',
      port: 80,
      replicas: 1,
    },
    ep: {
      ip: '13.248.207.97',
    },
  },
}
