# AI Charts

AI Charts is a collection of Helm Charts for installing and managing mainstream AI applications on Kubernetes.

## Currently Supported Applications

### Dify
> Some code was referenced from https://github.com/douban/charts/blob/master/charts/dify

[Dify](https://github.com/langgenius/dify) is an LLM application development platform that supports the entire process from creating prototypes to deployment.


#### Installing Dify

1. Add the Helm repository:

```bash
helm repo add ai-charts https://magicsong.github.io/ai-charts/
helm repo update
```

2. Create a custom `values.yaml` file:

```yaml
global:
    host: "mydify.example.com"
    enableTLS: false

    image:
        # Set to the latest version of Dify
        # Check versions here: https://github.com/langgenius/dify/releases
        tag: "1.0.1"
    
    extraBackendEnvs:
    - name: SECRET_KEY
      value: "please-generate-your-own-key"
    - name: LOG_LEVEL
      value: "INFO"
    - name: VECTOR_STORE
      value: "milvus"

ingress:
    enabled: true
    className: "nginx"
```

3. Install the chart:

```bash
helm install dify ai-charts/dify -f values.yaml
```

4. **Required** - Run database migrations after installation or the instance won't work:

```bash
# Run migrations
kubectl exec -it <dify-pod-name> -- flask db upgrade
```

#### Upgrading Dify

Modify `global.image.tag` in your `values.yaml` to the desired version, then run:

```bash
helm upgrade dify ai-charts/dify -f values.yaml
```

**Required** - Run database migrations after the upgrade:

```bash
kubectl exec -it <dify-pod-name> -- flask db upgrade
```

### Laminar

[Laminar](https://github.com/lmnr-ai/laminar) is a comprehensive AI platform with multiple components including PostgreSQL, RabbitMQ, ClickHouse, Qdrant vector database, semantic search services, and more.

#### Installing Laminar

1. Add the Helm repository:

```bash
helm repo add ai-charts https://magicsong.github.io/ai-charts/
helm repo update
```

2. Create a custom `values.yaml` file:

```yaml
# Basic configuration
frontend:
  ingress:
    enabled: true
    className: nginx
    hosts:
      - host: laminar.example.com
        paths:
          - path: /
            pathType: Prefix
  env:
    sharedSecretToken: "your-secure-token"
    nextauthUrl: "https://laminar.example.com"
    nextauthSecret: "your-nextauth-secret"
    nextPublicUrl: "https://laminar.example.com"

# Data persistence configuration
postgresql:
  auth:
    username: postgres
    password: your-secure-password
    database: laminar
  persistence:
    enabled: true
    size: 8Gi

rabbitmq:
  auth:
    username: user
    password: your-secure-password
  persistence:
    enabled: true
    size: 8Gi

clickhouse:
  auth:
    username: default
    password: your-secure-password
  persistence:
    enabled: true
    size: 10Gi

qdrant:
  persistence:
    enabled: true
    size: 8Gi

# Semantic search configuration
semanticSearchService:
  env:
    cohereApiKey: "your-cohere-api-key"
```

3. Install the chart:

```bash
helm install laminar ai-charts/laminar -f values.yaml
```

#### Customizing Laminar

Laminar supports various customization options:

- **External PostgreSQL**: Configure `postgresql.external.enabled=true` and related connection parameters
- **Resource Configuration**: Each component can be configured with standard Kubernetes resource settings
- **Persistence**: All data components (PostgreSQL, RabbitMQ, ClickHouse, Qdrant) support persistent storage
- **Ingress**: The frontend component can be exposed via Ingress

For more configuration options, please refer to the values.yaml file in the Helm Chart.

## Contributing

Pull requests and issues are welcome to help improve this project.

## License

This project is licensed under the [Apache License 2.0](LICENSE).