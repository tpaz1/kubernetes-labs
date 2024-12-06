
# **Prometheus & Grafana Helm Chart Customization Lab**

### **Objective**
This lab will guide you through customizing an existing Helm chart for Prometheus and Grafana. You will:
1. Enable persistence for Prometheus and Grafana.
2. Configure a custom retention period for Prometheus.
3. Add a custom Grafana dashboard.
4. Expose Grafana via a LoadBalancer.

### **Prerequisites**
- Access to a Kubernetes cluster (local or cloud-based).
- `kubectl` and `helm` installed and configured.
- Basic understanding of Helm and `values.yaml`.

---

## **Step 1: Add the Prometheus-Grafana Helm Chart**

1. Add the Helm repository:
   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo update
   ```

2. Install the Prometheus-Grafana Helm chart:
   ```bash
   helm install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
   ```
   This installs Prometheus and Grafana into a new namespace called `monitoring`.

3. Verify the installation:
   ```bash
   kubectl get pods -n monitoring
   ```
   Ensure all pods are running before proceeding.

---

## **Step 2: Enable Persistence**

1. Edit the `values.yaml` file to enable persistence for Grafana and Prometheus:
   ```yaml
   grafana:
     persistence:
       enabled: true
       size: 10Gi
     adminPassword: "admin123"

   prometheus:
     server:
       persistentVolume:
         enabled: true
         size: 20Gi
   ```

2. Upgrade the Helm release to apply changes:
   ```bash
   helm upgrade monitoring prometheus-community/kube-prometheus-stack -f values.yaml
   ```

3. Verify that persistence is enabled:
   - Check the PersistentVolumeClaims (PVCs):
     ```bash
     kubectl get pvc -n monitoring
     ```
   - You should see PVCs for both Prometheus and Grafana.

---

## **Step 3: Set a Custom Retention Period for Prometheus**

1. Modify `values.yaml` to set a custom retention period:
   ```yaml
   prometheus:
     server:
       retention: 15d
   ```

2. Reapply the changes:
   ```bash
   helm upgrade monitoring prometheus-community/kube-prometheus-stack -f values.yaml
   ```

3. Verify the retention configuration:
   - Access the Prometheus UI (default URL: `http://<Prometheus-service-IP>:9090`).
   - Check the configuration under **Status > Config**.

---

## **Step 4: Expose Grafana via a LoadBalancer**

1. Update the `values.yaml` to expose Grafana using a LoadBalancer:
   ```yaml
   grafana:
     service:
       type: LoadBalancer
   ```

2. Apply the changes:
   ```bash
   helm upgrade monitoring prometheus-community/kube-prometheus-stack -f values.yaml
   ```

3. Get the external IP of the Grafana service:
   ```bash
   kubectl get svc -n monitoring
   ```
   Note the `EXTERNAL-IP` of the Grafana service and open it in your browser.

4. Log in to Grafana using:
   - **Username**: `admin`
   - **Password**: `admin123` (set earlier in `values.yaml`).

---

## **Step 5: Add a Custom Grafana Dashboard**

1. Download a sample Grafana dashboard JSON file from [Grafana Dashboards](https://grafana.com/grafana/dashboards).

2. Add the dashboard to `values.yaml`:
   ```yaml
   grafana:
     dashboards:
       custom-dashboard:
         json: |
           <Paste the dashboard JSON here>
   ```

3. Apply the changes:
   ```bash
   helm upgrade monitoring prometheus-community/kube-prometheus-stack -f values.yaml
   ```

4. Verify the dashboard in Grafana:
   - Go to **Dashboards > Browse** and locate your new dashboard.

---

## **Summary**
In this lab, you:
- Enabled persistence for Prometheus and Grafana.
- Configured a custom retention period for Prometheus.
- Exposed Grafana via a LoadBalancer.
- Added a custom Grafana dashboard.

This hands-on lab helped you understand how to modify an existing Helm chart using `values.yaml`.

---

Feel free to reach out with questions or if you face any issues! Happy learning!
