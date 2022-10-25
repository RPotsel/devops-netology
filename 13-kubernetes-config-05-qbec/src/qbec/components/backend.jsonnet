local p = import '../params.libsonnet';
local params = p.components.backend;
local db_params = p.components.db;
local global = p.components.global;

[
  // Backend
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'backend',
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
      replicas: params.replicas,
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
              imagePullPolicy: global.pullPolicy,
              command: [
                'sh',
                '-ec',
                |||
                  until (pg_isready -h %s -p %s -U %s); do
                    echo 'Wait postgres service'
                    sleep 1
                  done
                ||| % [db_params.url, db_params.port, db_params.user]
              ],
            },
          ],
          containers: [
            {
              image: 'rpot/13-01-backend:' + params.version,
              imagePullPolicy: global.pullPolicy,
              name: 'backend',
              env: [
                {
                  name: 'DATABASE_URL',
                  value: 'postgres://' + db_params.user + ':' + db_params.pass + '@' + db_params.url + ':' + db_params.port + '/news',  //
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
      name: params.url,
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
          port: params.port,
          targetPort: params.port,
        },
      ],
    },
  }
]
