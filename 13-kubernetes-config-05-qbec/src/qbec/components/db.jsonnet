local p = import '../params.libsonnet';
local params = p.components.db;
local global = p.components.global;

[
  // Persistent Volume
  {
    apiVersion: 'v1',
    kind: 'PersistentVolume',
    metadata: {
      name: 'pv-' + params.vol_id,
    },
    spec: {
      accessModes: [
        'ReadWriteOnce',
      ],
      capacity: {
        storage: '256Mi',
      },
      hostPath: {
        path: '/data/pv',
      },
    },
  },
  // Database
  {
    // postgres StatefulSet
    apiVersion: 'apps/v1',
    kind: 'StatefulSet',
    metadata: {
      name: 'postgres-db',
      labels: {
        app: 'postgres-db',
      },
    },
    spec: {
      serviceName: 'postgres-db-service',
      selector: {
        matchLabels: {
          app: 'postgres-db',
        },
      },
      template: {
        metadata: {
          labels: {
            app: 'postgres-db',
          },
        },
        spec: {
          containers: [
            {
              name: 'postgres-db',
              image: 'postgres:' + params.version,
              imagePullPolicy: global.pullPolicy,
              ports: [
                {
                  name: 'postgres',
                  containerPort: params.port,
                  protocol: 'TCP',
                  // Resource Limits
                },
              ],
              resources: {
                requests: {
                  memory: params.mem,
                  cpu: params.cpu,
                },
                limits: {
                  memory: '512Mi',
                  cpu: '500m',
                  // Data Volume
                },
              },
              volumeMounts: [
                {
                  name: 'postgres-db-disk',
                  mountPath: '/var/lib/postgres/data',
                  // Environment variables
                },
              ],
              env: [
                {
                  name: 'POSTGRES_USER',
                  value: params.user,
                },
                {
                  name: 'POSTGRES_PASSWORD',
                  value: params.pass,
                },
                {
                  name: 'POSTGRES_DB',
                  value: 'news',
                  // Volume Claim
                },
              ],
            },
          ],
        },
      },
      volumeClaimTemplates: [
        {
          metadata: {
            name: 'postgres-db-disk',
          },
          spec: {
            accessModes: [
              'ReadWriteOnce',
            ],
            resources: {
              requests: {
                storage: '256Mi',
              },
            },
            volumeName: 'pv-' + params.vol_id,
          },
        },
      ],
    },
  },
  // postgres service
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: params.url,
      labels: {
        app: 'postgres-db',
      },
    },
    spec: {
      selector: {
        app: 'postgres-db',
      },
      type: 'ClusterIP',
      ports: [
        {
          name: 'postgres-db',
          protocol: 'TCP',
          port: params.port,
          targetPort: params.port,
        },
      ],
    },
  }
]
