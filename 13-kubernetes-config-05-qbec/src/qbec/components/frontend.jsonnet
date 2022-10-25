local p = import '../params.libsonnet';
local params = p.components.frontend;
local backend_params = p.components.backend;
local global = p.components.global;

// Frontend
[
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'frontend',
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
      replicas: params.replicas,
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
              imagePullPolicy: global.pullPolicy,
              command: [
                '/bin/sh',
                '-ec',
              ],
              args: [
                'while [ $(curl -ksw %{http_code}' + ' %s:%s/api/news/ -o /dev/null) -ne 200 ]; do sleep 5; echo "Waiting for backend service."; done' % [backend_params.url, backend_params.port],
              ],
            },
          ],
          containers: [
            {
              image: 'rpot/13-01-frontend:' + params.version,
              imagePullPolicy: global.pullPolicy,
              name: 'frontend',
              env: [
                {
                  name: 'BASE_URL',
                  value: 'http://%s:%s' % [backend_params.url, backend_params.port],
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
      name: params.url,
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
          port: params.port,
          targetPort: params.port,
        },
      ],
    },
  }
]
