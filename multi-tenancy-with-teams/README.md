# Multi-Tenancy with Teams

This example solution demonstrates how multiple teams can be configured in a multi-tenant cluster. This example provisions:
- An admin team which has administrative access to the cluster
- Red team which has access to the cluster, but is restricted to the `red` namespace
- Blue teams which have access to the cluster, but are restricted to their respective `blue-one` and `blue-two` namespaces

## Prerequisites:

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

To provision this example:

```sh
terraform init
terraform apply
```

Enter `yes` at command prompt to apply

## Validate

Using the output provided, enter the `admin` team update kubeconfig command first to see the access that `admin` members receive:

1. Run `update-kubeconfig` command:

```sh
aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME> --role-arn <ADMIN_ROLE_ARN>
```

2. Test by listing all the pods running currently. The CoreDNS pod should reach a status of `Running` after approximately 60 seconds:

```sh
kubectl get pods -A

# Output should look like below
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
kube-system   aws-node-7lbn7             1/1     Running   0          6m50s
kube-system   aws-node-tzpxb             1/1     Running   0          6m35s
kube-system   coredns-799c5565b4-46vxg   1/1     Running   0          12m
kube-system   coredns-799c5565b4-rdpl5   1/1     Running   0          12m
kube-system   kube-proxy-fwlx8           1/1     Running   0          7m39s
kube-system   kube-proxy-nnss5           1/1     Running   0          7m40s
```

3. Switch to the `red` team permissions by running the `update-kubeconfig` command again, this time with the `red` team role:

```sh
aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME> --role-arn <RED_TEAM_ROLE_ARN>
```

4. The `red` team will have access to list nodes and namespaces:
```sh
kubectl get nodes

# Output should look like below
NAME                                        STATUS   ROLES    AGE     VERSION
ip-10-0-24-76.us-west-2.compute.internal    Ready    <none>   9m27s   v1.24.9-eks-49d8fe8
ip-10-0-37-237.us-west-2.compute.internal   Ready    <none>   9m26s   v1.24.9-eks-49d8fe8
```

5. The `red` team will have access to get/list/watch resources in the `red` namespace:

```sh
kubectl get networkpolicy red -n red -oyaml

# Output should look like below
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  annotations:
    team: red
  creationTimestamp: "2023-02-05T17:57:20Z"
  generation: 1
  labels:
    team: red
  name: red
  namespace: red
  resourceVersion: "988"
  uid: b0c3f1aa-5446-4a43-8206-734ef97817f6
spec:
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: default
    - ipBlock:
        cidr: 10.0.0.0/8
        except:
        - 10.0.0.0/24
        - 10.0.1.0/24
    ports:
    - port: http
      protocol: TCP
    - port: 53
      protocol: TCP
    - port: 53
      protocol: UDP
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
status: {}
```

5. The `red` team will NOT have access to get/list/watch resources in the `blue-one` namespace:

```sh
kubectl get pods -n blue-one

# Output should look like below
Error from server (Forbidden): pods is forbidden: User "red-team" cannot list resource "pods" in API group "" in the namespace "blue-one"
```

## Destroy

To teardown and remove the resources created in this example:

```sh
terraform destroy -auto-approve
```
