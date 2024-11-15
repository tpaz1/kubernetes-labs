
# Kubernetes Lab: Understanding Persistence with StatefulSets, Deployments, and Persistent Volumes

## Overview

In this lab, you will learn about Kubernetes persistence by deploying a PostgreSQL database using both **Deployments** and **StatefulSets**. You'll explore the differences in how storage is handled between these two approaches. Additionally, you will deploy a **browser-based application** (adminer) to interact with your PostgreSQL database, allowing you to see persistence in action.

### What You'll Learn
- How to use **PersistentVolume (PV)** and **PersistentVolumeClaim (PVC)**.
- Differences between **Deployments** and **StatefulSets** with respect to storage.
- How to deploy a browser-based admin interface for PostgreSQL.
- Demonstrating data persistence after pod deletion.

---

## Prerequisites

Before starting this lab, ensure you have the following:
- Access to a Kubernetes cluster (Docker Desktop is recommended for this lab).
- **kubectl** command-line tool installed and configured.
- Basic knowledge of Kubernetes concepts (Deployment, StatefulSet, PVC, and PV).

---

## Lab Structure
1. Deploy PostgreSQL using **Deployment** (with Persistent Storage).
2. Deploy PostgreSQL using **StatefulSet** (with Persistent Storage).
3. Deploy **Adminer** (a web-based database management tool).
4. Test data persistence by deleting PostgreSQL pods.

---

## Step 1: Create a Storage Class and PersistentVolumeClaim

### Storage Class

Create a file named `storage-class.yaml`:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: hostpath
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

### PersistentVolumeClaim

Create a file named `postgres-pvc.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: hostpath
```

Apply the configurations:

```bash
kubectl apply -f storage-class.yaml
kubectl apply -f postgres-pvc.yaml
```

---

## Step 2: Deploy PostgreSQL Using Deployment

Create a file named `postgres-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:15-alpine
          env:
            - name: POSTGRES_USER
              value: "admin"
            - name: POSTGRES_PASSWORD
              value: "password"
            - name: POSTGRES_DB
              value: "testdb"
          ports:
            - containerPort: 5432
          volumeMounts:
            - mountPath: /var/lib/postgresql/data
              name: hostpath
      volumes:
        - name: hostpath
          persistentVolumeClaim:
            claimName: postgres-pvc
```

Apply the configuration:

```bash
kubectl apply -f postgres-deployment.yaml
```

---

## Step 3: Deploy PostgreSQL Using StatefulSet

Create a file named `postgres-statefulset.yaml`:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres-sts
spec:
  serviceName: "postgres"
  replicas: 1
  selector:
    matchLabels:
      app: postgres-sts
  template:
    metadata:
      labels:
        app: postgres-sts
    spec:
      containers:
        - name: postgres
          image: postgres:15-alpine
          env:
            - name: POSTGRES_USER
              value: "admin"
            - name: POSTGRES_PASSWORD
              value: "password"
            - name: POSTGRES_DB
              value: "testdb"
          ports:
            - containerPort: 5432
          volumeMounts:
            - mountPath: /var/lib/postgresql/data
              name: hostpath
  volumeClaimTemplates:
    - metadata:
        name: hostpath
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi
        storageClassName: hostpath
```

Apply the configuration:

```bash
kubectl apply -f postgres-statefulset.yaml
```

---

## Step 4: Deploy Adminer (Database Management Tool)

Create a file named `adminer-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: adminer
spec:
  replicas: 1
  selector:
    matchLabels:
      app: adminer
  template:
    metadata:
      labels:
        app: adminer
    spec:
      containers:
        - name: adminer
          image: adminer:latest
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: adminer-service
spec:
  selector:
    app: adminer
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: LoadBalancer
```

Apply the configuration:

```bash
kubectl apply -f adminer-deployment.yaml
```

---

## Step 5: Access Adminer and Test Persistence

1. **Get the Adminer Service URL**:

   ```bash
   kubectl get svc adminer-service
   ```

   Open your browser and navigate to the external IP address shown.

2. **Log in to Adminer**:
   - **Server**: Enter the service name (`postgres-deployment` or `postgres-sts`).
   - **Username**: `admin`
   - **Password**: `password`
   - **Database**: `testdb`

3. **Create a Table and Insert Data**:
   - Create a table named `students`.
   - Add some rows to the table.

4. **Delete the PostgreSQL Pod**:
   - For Deployment:
     ```bash
     kubectl delete pod -l app=postgres
     ```
   - For StatefulSet:
     ```bash
     kubectl delete pod -l app=postgres-sts
     ```

5. **Check Data Persistence**:
   - After deleting the pod, log back into Adminer.
   - Verify that the data you inserted is still present, demonstrating persistence.

---

## Step 6: Cleanup (Optional)

To delete all the resources created in this lab:

```bash
kubectl delete -f postgres-deployment.yaml
kubectl delete -f postgres-statefulset.yaml
kubectl delete -f adminer-deployment.yaml
kubectl delete -f postgres-pvc.yaml
kubectl delete -f storage-class.yaml
```

---

## Conclusion

In this lab, you learned how to deploy a PostgreSQL database using both Deployments and StatefulSets with persistent storage. You also set up a browser-based interface to interact with your database and observed data persistence across pod restarts.

Feel free to experiment by scaling the StatefulSet or Deployment and observe the differences in behavior!
