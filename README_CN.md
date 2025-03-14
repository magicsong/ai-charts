# AI Charts

AI Charts 是一个提供在 Kubernetes 上安装和管理主流 AI 应用程序的 Helm Charts 集合。

## 当前支持的应用

### Dify
> 部分代码参考了https://github.com/douban/charts/blob/master/charts/dify
[Dify](https://github.com/langgenius/dify) 是一个 LLM 应用开发平台，支持从创建原型到部署的全流程。

#### 安装 Dify

1. 添加 Helm 仓库：

```bash
helm repo add ai-charts https://magicsong.github.io/ai-charts/
helm repo update
```

2. 创建自定义 `values.yaml` 文件：

```yaml
global:
    host: "mydify.example.com"
    enableTLS: false

    image:
        # 设置为 Dify 的最新版本
        # 在这里查看版本：https://github.com/langgenius/dify/releases
        tag: "1.0.1"
    
    extraBackendEnvs:
    - name: SECRET_KEY
        value: "请生成自己的密钥"
    - name: LOG_LEVEL
        value: "INFO"
    - name: VECTOR_STORE
        value: "milvus"

ingress:
    enabled: true
    className: "nginx"
```

3. 安装 Chart：

```bash
helm install dify ai-charts/dify -f values.yaml
```

4. **必须**在安装后运行数据库迁移，否则实例将无法工作：

```bash
# 运行迁移
kubectl exec -it <dify-pod-name> -- flask db upgrade
```

#### 升级 Dify

修改 `values.yaml` 中的 `global.image.tag` 为所需版本，然后执行：

```bash
helm upgrade dify ai-charts/dify -f values.yaml
```

升级后**必须**运行数据库迁移：

```bash
kubectl exec -it <dify-pod-name> -- flask db upgrade
```

## 贡献指南

欢迎提交 Pull Request 或创建 Issue 来帮助我们改进项目。

## 许可证

本项目采用 [Apache License 2.0](LICENSE) 许可证。