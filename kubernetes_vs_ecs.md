# Talking Points
## Explain about ECS and Kubernetes
### Kubernetes
- Apa itu Pod?
- Kubernetes bisa apa aja?
- Kenapa Kubernetes?
### ECS
- ECS Task Definition vs Kubernetes Pod Specification
#### Kubernetes pod spec
```yaml
apiVersion: apps/v1
kind: Deployment # will automatically deployed
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
spec:
  containers:
  - name: main-container
    image: nginx:latest
    ports:
    - containerPort: 80
    resources:
      requests:
        memory: "128Mi"
        cpu: "250m"
      limits:
        memory: "256Mi"
        cpu: "500m"
    env:
    - name: DB_HOST
      value: "database.example.com"
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
```
then run `kubectl apply -f pod.yaml`
#### ECS Task Definition
```json
{
  "family": "my-app",
  "containerDefinitions": [
    {
      "name": "main-container",
      "image": "nginx:latest",
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "memory": 256,
      "cpu": 256,
      "essential": true,
      "environment": [
        {
          "name": "DB_HOST",
          "value": "database.example.com"
        }
      ]
    }
  ],
  "requiresCompatibilities": ["FARGATE"],
  "networkMode": "awsvpc",
  "memory": "512",
  "cpu": "256"
}
```
then run `aws ecs register-task-definition --cli-input-json file://task-definition.json`
- ECS Service vs Kubernetes Deployment
#### Kubernetes
```bash
kubectl set image deployment/my-app main-container=nginx:new-tag
```
#### ECS
```bash
aws ecs update-service --cluster your-cluster --service your-service --task-definition your-task:new-version --force-new-deployment
```
### Too Much Hassle!

Tools to ease the deployment
- Kubernetes Helm Chart
```yaml
# Chart.yaml
apiVersion: v2
name: my-app
description: A Helm chart for my application
version: 0.1.0

# values.yaml
replicaCount: 3
image:
 repository: nginx
 tag: latest
 pullPolicy: IfNotPresent
service:
 type: ClusterIP
 port: 80

# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
 name: {{ .Release.Name }}-deployment
spec:
 replicas: {{ .Values.replicaCount }}
 selector:
   matchLabels:
     app: {{ .Release.Name }}
 template:
   metadata:
     labels:
       app: {{ .Release.Name }}
   spec:
     containers:
     - name: {{ .Chart.Name }}
       image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
       ports:
       - containerPort: 80
```
then
```bash
helm upgrade my-release ./my-app
```
- AWS Copilot / AWS Proton
```yaml
# copilot/myapp/manifest.yml
name: myapp
type: Load Balanced Web Service

image:
  build: ./Dockerfile
  port: 80

cpu: 256
memory: 512
count: 3

variables:
  DB_HOST: database.example.com

environments:
  test:
    count: 1
  prod:
    count: 3
```
then
```bash
copilot deploy
```
### Why we don't use Kubernetes in ProjectSprint
- Pricier (control plane)
- The deployment experience is similar

### How can I set up one?
- Install copilot cli
- Configuration files
- `copilot app init`
- `copilot env init`
- `copilot svc init`
- Info me about
    - App names
    - Svc names
- How to access

### Microservice
- Connect through load balancers

### Monitoring
- Grafana
- Prometheus
- Provision yourself

### Caching
- Distributed Caching (EC2)
- App level caching (global variables)
