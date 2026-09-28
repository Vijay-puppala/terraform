# Terraform AWS examples

Example AWS infrastructure split into logical, reusable modules and wired together per environment.

```
.
├── modules/
│   ├── network/   # VPC, subnets, IGW, NAT, route tables, security group, EC2
│   ├── s3/        # Secure S3 bucket (encryption, versioning, lifecycle, TLS-only)
│   ├── iam/       # IAM groups, users, EC2 instance profile, EKS roles
│   └── eks/       # EKS cluster, managed node group, core add-ons
└── envs/
    └── dev/       # Root module: providers, variables, module wiring
```

## Dependency flow

```
iam ──► network (EC2 instance profile)
iam ──► eks     (cluster + node roles)
network ──► eks (private subnets)
s3              (standalone)
```

## Usage

Prerequisites: Terraform >= 1.6 and AWS credentials (`aws configure` or env vars).

```sh
cd envs/dev
cp terraform.tfvars.example terraform.tfvars   # edit as needed
terraform init
terraform plan
terraform apply
```

To add an EKS cluster, set `enable_eks = true` in `terraform.tfvars` and apply again. That also creates a NAT gateway so private nodes can pull images. Once applied, run the `eks_kubeconfig_command` output to configure `kubectl`.

Tear everything down with `terraform destroy`.

## Notes

- **Cost:** EC2 `t3.micro` and S3 are cheap or free-tier. EKS (~$73/month for the control plane), its nodes and the NAT gateway (~$32/month plus data) are not, so EKS is off by default.
- **EC2 access:** there's no SSH key or port 22. Connect with SSM Session Manager: `aws ssm start-session --target <instance-id>`.
- **IAM users:** access keys and console passwords aren't created in Terraform, because they would end up in plaintext in the state. Issue them from the console or CLI.
- **State:** state is local by default. For team use, uncomment the `backend "s3"` block in `envs/dev/versions.tf`.
- **New environments:** copy `envs/dev` to `envs/prod` and change the variables.
