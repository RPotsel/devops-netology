// global
local ns = 'prod';
local pullPolicy = 'IfNotPresent';

// Postgres
local db_version = '13-alpine';
local db_port = 5432;
local db_mem = '265Mi';
local db_cpu = '250m';
local db_user = 'postgres';
local db_pass = 'postgres';
local db_url = 'postgres-db-cip';

// Backend
local backend_version = '0.1';
local backend_url = 'backend-cip';
local backend_port = 9000;

// Frontend
local frontend_version = '0.1';
local frontend_url = 'frontend-lb';
local frontend_port = 80;

[
  // Persistent Volume
  {
    apiVersion: 'v1',
    kind: 'PersistentVolume',
    metadata: {
      name: 'pv',
      namespace: ns,
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
      namespace: ns,
      labels: {
        app: 'postgres-db',
      },
    },
    spec: {
      serviceName: 'postgres-db-service',
      replicas: 1,
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
              image: 'postgres:' + db_version,
              imagePullPolicy: pullPolicy,
              ports: [
                {
                  name: 'postgres',
                  containerPort: db_port,
                  protocol: 'TCP',
                  // Resource Limits
                },
              ],
              resources: {
                requests: {
                  memory: db_mem,
                  cpu: db_cpu,
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
                  value: db_user,
                },
                {
                  name: 'POSTGRES_PASSWORD',
                  value: db_pass,
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
            volumeName: 'pv-production',  //
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
      name: db_url,
      namespace: ns,
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
          port: db_port,
          targetPort: db_port,
        },
      ],
    },
  },
  // Backend
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'backend',
      namespace: ns,
      labels: {
        app: 'backend',
      },
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'backend',
        },
      },
      replicas: 1,
      template: {
        metadata: {
          labels: {
            app: 'backend',
          },
        },
        spec: {
          initContainers: [
            {
              name: 'wait-postgres',
              image: 'postgres:13-alpine',
              imagePullPolicy: pullPolicy,
              command: [
                'sh',
                '-ec',
                |||
                  until (pg_isready -h %s -p %s -U %s); do
                    echo 'Wait postgres service'
                    sleep 1
                  done
                ||| % [db_url, db_port, db_user]
              ],
            },
          ],
          containers: [
            {
              image: 'rpot/13-01-backend:' + backend_version,
              imagePullPolicy: pullPolicy,
              name: 'backend',
              env: [
                {
                  name: 'DATABASE_URL',
                  value: 'postgres://' + db_user + ':' + db_pass + '@' + db_url + ':' + db_port + '/news',  //
                },
              ],
            },
          ],
        },
      },
    },
  },
  // Backend service
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: backend_url,
      namespace: ns,
      labels: {
        app: 'backend',
      },
    },
    spec: {
      selector: {
        app: 'backend',
      },
      type: 'ClusterIP',
      ports: [
        {
          name: 'backend',
          protocol: 'TCP',
          port: backend_port,
          targetPort: backend_port,
        },
      ],
    },
  },
  // Frontend
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'frontend',
      namespace: ns,
      labels: {
        app: 'frontend',
      },
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'frontend',
        },
      },
      replicas: 1,
      template: {
        metadata: {
          labels: {
            app: 'frontend',
          },
        },
        spec: {
          initContainers: [
            {
              name: 'wait-backend',
              image: 'praqma/network-multitool:alpine-extra',
              imagePullPolicy: pullPolicy,
              command: [
                '/bin/sh',
                '-ec',
              ],
              args: [
                'while [ $(curl -ksw %{http_code}' + ' %s:%s/api/news/ -o /dev/null) -ne 200 ]; do sleep 5; echo "Waiting for backend service."; done' % [backend_url, backend_port],
              ],
            },
          ],
          containers: [
            {
              image: 'rpot/13-01-frontend:' + frontend_version,
              imagePullPolicy: pullPolicy,
              name: 'frontend',
              env: [
                {
                  name: 'BASE_URL',
                  value: 'http://%s:%s' % [backend_url, backend_port],
                },
              ],
            },
          ],
        },
      },
    },
  },
  // Fontend service
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: frontend_url,
      namespace: ns,
      labels: {
        app: 'frontend',
      },
    },
    spec: {
      selector: {
        app: 'frontend',
      },
      type: 'LoadBalancer',
      ports: [
        {
          name: 'frontend',
          protocol: 'TCP',
          port: frontend_port,
          targetPort: frontend_port,
        },
      ],
    },
  }
]