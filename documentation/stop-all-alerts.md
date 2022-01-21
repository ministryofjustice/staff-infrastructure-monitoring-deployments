# Stop all alerts from alertmanager (Maintenance mode)

## Table of contents

- [Accessing the alert manager UI](#accessing-the-alert-manager-ui)
- [Creating an alert silence](#creating-an-alert-silence)

---

| :bangbang: IMPORTANT |  
|:-----|  
| Alerts and their firing frequency should be managed within the Alert Manager config.  In some special cases, i.e maintenance activity you may need to supress alerts manually. | 


### Accessing the alert manager UI

1. Connect to the cluster by following the instructions in the [main readme](../README.md).
2. Run 
```sh
kubectl get pods -n <KUBERNETES_NAMESPACE>
```

3. Copy the name of the alertmanager pod, it should look similar to:
```
mojo-<<env>>-ima-alertmanager-1abcd22e33-aa1bc
```
4. run 
```sh
kubectl port-forward YOUR_ALERTMANAGER_POD_NAME -n KUBERNETES_NAMESPACE 9093:9093
```
5. Browse to localhost:9093.

### Creating an Alert Silence

1. Click on _Silences_, click _New Silence_.
2. Populate the fields to configure and enable a silence for your desired time frame.  See below example:  
![image info](./example_alert_silence.PNG)
3. For a global silence you can use the filter `region="eu-west-2"`

| :bangbang: IMPORTANT |  
|:-----|  
| Only alerts that are *currently firing* will show up when clicking the preview alerts button. | 

