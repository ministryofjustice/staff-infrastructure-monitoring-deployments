# Ministry of Justice Template Repository

## Prerequisites:

1. Build your dev infrastructure using the <REPO>
1. Export the terraform outputs in a json file
```
terraform output -json >> terraform_outputs.json
```

1. Copy that file in this repository and then run
```
export OUTPUTS=$(cat ./terraform_outputs.json)
```
