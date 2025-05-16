# Run the following commands to create the role and attach permissions to it

## Create the role

```bash
aws iam create-role \
  --role-name DenyUntaggedResourcesRole \
  --assume-role-policy-document file://role-trust-policy.json
```

## Attach permissions policy

```bash
aws iam put-role-policy \
  --role-name DenyUntaggedResourcesRole \
  --policy-name BucketCreateWithTagEnforcementPolicy \
  --policy-document file://role-permissions-policy.json
```

## Allow the user to which the role will be attached to assume it

```bash
aws iam put-user-policy \
  --user-name devops-user \
  --policy-name AllowAssumeDenyUntaggedResourcesRole \
  --policy-document file://assume-role-policy.json
```
