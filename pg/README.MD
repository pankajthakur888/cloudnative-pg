# PostgreSQL Replication Check in Kubernetes

This guide provides steps to verify if **PostgreSQL replication** is working correctly in a Kubernetes environment using **CloudNativePG**.

---

## Prerequisites
- Kubernetes cluster with CloudNativePG deployed
- PostgreSQL cluster running with multiple instances
- kubectl installed and configured

---

## Step 1: Check PostgreSQL Services
To list all PostgreSQL services, run:
```sh
helm repo add cnpg https://cloudnative-pg.github.io/charts

helm upgrade --install cnpg cnpg/cloudnative-pg \
    --namespace cnpg-system --create-namespace --wait

kubectl get svc -n pg
```
Expected output:
```
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
postgressql-r    ClusterIP   10.96.5.122     <none>        5432/TCP   83s
postgressql-ro   ClusterIP   10.96.107.200   <none>        5432/TCP   83s
postgressql-rw   ClusterIP   10.96.193.197   <none>        5432/TCP   83s
```

- `postgressql-rw`: Read-Write endpoint (Primary)
- `postgressql-ro`: Read-Only endpoint (Replicas)

---

## Step 2: Check PostgreSQL Cluster Status
```sh
kubectl get cluster -n pg
```
Expected output:
```
NAME          AGE    INSTANCES   READY   STATUS                     PRIMARY
postgressql   102s   3           3       Cluster in healthy state   postgressql-1
```
Ensure that:
- `INSTANCES` matches the expected replica count
- `STATUS` is `Cluster in healthy state`
- `PRIMARY` pod is identified

---

## Step 3: Check PostgreSQL Pods
```sh
kubectl get pods -n pg
```
Expected output:
```
NAME              READY   STATUS    RESTARTS   AGE
postgressql-0     1/1     Running   0          2m
postgressql-1     1/1     Running   0          2m
postgressql-2     1/1     Running   0          2m
```
Ensure all pods are in `Running` state.

---

## Step 4: Check Replication Logs
```sh
kubectl logs postgressql-1 -n pg | grep "replication"
```
Expected output:
```
LOG:  standby "postgressql-0" has connected
LOG:  standby "postgressql-2" has connected
```

---

## Step 5: Verify Replication in PostgreSQL
Connect to the **Primary node**:
```sh
kubectl exec -it postgressql-1 -n pg -- psql -U postgres
```
Run the following SQL command:
```sql
SELECT * FROM pg_stat_replication;
```
Expected output:
```
 pid  | usename  | application_name | client_addr | state   | sync_state
------+---------+------------------+-------------+--------+------------
 1234 | replica | postgressql-0     | 10.96.5.10  | streaming | sync
 1235 | replica | postgressql-2     | 10.96.5.11  | streaming | sync
```
- **`state`** should be `streaming`
- **`sync_state`** should be `sync`

---

## Step 6: Test Replication
Create a test table on the primary:
```sql
CREATE TABLE test_replication (id SERIAL PRIMARY KEY, message TEXT);
INSERT INTO test_replication (message) VALUES ('Replication Test');
```
Check if the replica can read it:
```sh
kubectl exec -it postgressql-0 -n pg -- psql -U postgres -h postgressql-ro -c "SELECT * FROM test_replication;"
```
If the record appears, replication is working correctly.

---

## Troubleshooting
### 1. Empty `pg_stat_replication`
- Check logs: `kubectl logs postgressql-1 -n pg`
- Ensure all pods are running: `kubectl get pods -n pg`
- Restart the PostgreSQL pods if needed

### 2. Read-Only Replica Not Syncing
- Check `postgresql.conf` settings for replication
- Ensure the `postgressql-ro` service points to the correct replicas

---

## Conclusion
By following these steps, you can verify that **PostgreSQL replication** is working correctly in your **CloudNativePG** Kubernetes setup. 🚀

