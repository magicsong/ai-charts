# AI Charts

AI Charts is a collection of Helm Charts for installing and managing mainstream AI applications on Kubernetes.

## Currently Supported Applications

### Dify

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

## Contributing

Pull requests and issues are welcome to help improve this project.

## License

This project is licensed under the [Apache License 2.0](LICENSE).