
# Helm Lab: Creating Your First Helm Chart

Welcome to the Helm lab! In this exercise, you will learn how to create a Helm chart for a simple web application using NGINX. The chart will template out Deployment and Service resources.

## Prerequisites

Before starting, ensure you have:
- Helm installed on your system.
- Access to the sample Kubernetes manifests in the provided Git repository.

## Objective

Convert the Deployment and Service YAML files into a Helm chart with templates.

## Instructions

1. **Create a Helm Chart**
   - Create a Helm chart named `webapp-nginx` in the directory using the following command:
     ```bash
     helm create webapp-nginx
     ```
   - This will generate the necessary chart directory structure.

2. **Move Definition Files**
   - Copy the Deployment and Service YAML files from the provided repository into the `templates` directory of your chart:
     ```
     webapp-nginx/templates/
     ```

3. **Template Resource Names**
   - Modify the Deployment and Service definitions to use templated names. Replace hardcoded names with the following format:
     ```
     {{ .Release.Name }}-nginx
     ```

4. **Update Chart Metadata**
   - Set version number to 0.1.1. 
   - Set appVersion to 1.16.0.
   <details>
   
   - Open the `Chart.yaml` file and update the following:
     - `apiVersion: v2`
     - `name: webapp-nginx`
     - `version: 0.1.1`
     - `appVersion: 1.16.0`
  </details>

5. **Set Image in `values.yaml` to `nginx:1.16.0`**
   <details>
   
    - Open the `values.yaml` file and ensure it includes the following entry:
     ```yaml
     image: nginx:1.16.0
     ```
  </details>


6. **Use Image Variable**
   - Update the Deployment template to use the `image` variable from `values.yaml`.

   <details>

    ```yaml
    containers:
      - name: nginx
        image: {{ .Values.image }}
    ```
   </details>


7. **Clean Up Unused Files**
   - Remove any unused YAML or text files from the `templates` directory to keep your chart clean and concise.

## Validation
- Install the chart in a Kubernetes cluster to verify functionality:
  ```bash
  helm install my-release /root/webapp-nginx
  ```

---

## YAML Files

### Chart.yaml
<details>
<summary>Click to view Chart.yaml</summary>

```yaml
apiVersion: v2
name: webapp-nginx
description: A Helm chart for deploying a simple NGINX application
version: 0.1.1
appVersion: 1.16.0
```

</details>

### values.yaml
<details>
<summary>Click to view values.yaml</summary>

```yaml
# Default values for webapp-nginx.
image: nginx:1.16.0
```

</details>

### templates/deployment.yaml
<details>
<summary>Click to view deployment.yaml</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: {{ .Values.image }}
          ports:
            - containerPort: 80
```

</details>

### templates/service.yaml
<details>
<summary>Click to view service.yaml</summary>

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-nginx
spec:
  type: ClusterIP
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

</details>

---

Congratulations! You've successfully created your first Helm chart.
