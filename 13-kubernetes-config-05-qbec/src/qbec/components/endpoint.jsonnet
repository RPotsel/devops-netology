local p = import '../params.libsonnet';
local params = p.components.ep;
[
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'external-ep',
    },
    spec: {
      selector: {
      },
      ports: [
        {
          name: 'external-ep',
          protocol: 'TCP',
          port: 443,
        },
      ],
    },
  },
  {
    apiVersion: 'v1',
    kind: 'Endpoints',
    metadata: {
      name: 'external-ep',
    },
    subsets: [
      {
        addresses: [
          {
            ip: params.ip,
          },
        ],
        ports: [
          {
            name: 'external-ep',
            port: 443,
          },
        ],
      },
    ],
  }
]
