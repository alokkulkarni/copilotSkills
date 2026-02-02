# Basic AWS Connect Instance Example

This example demonstrates deploying a minimal Amazon Connect instance with basic configuration.

## Module Structure

This example uses the modular Connect instance module. Resources are organized into focused files:
- **Instance**: Core Connect configuration (main.tf)
- **Hours of Operation**: Business hours (hours_of_operation.tf)
- **Queues**: Queue management (queues.tf)
- **Routing Profiles**: Agent routing (routing_profiles.tf)
- **Security Profiles**: Access control (security_profiles.tf)
- **Users**: User management (users.tf)

Each component can be independently managed by modifying the corresponding variables.

## Features

- Simple Connect instance deployment
- Single queue with business hours
- Basic routing profile for agents
- Security profile for agent access
- One test user

## Usage

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy the infrastructure
terraform apply

# Clean up
terraform destroy
```

## Configuration

The example creates:
- 1 Connect instance
- 1 hours of operation (weekday business hours)
- 1 queue (BasicQueue)
- 1 routing profile (BasicAgentProfile)
- 1 security profile (BasicAgentAccess)
- 1 test user

## Outputs

After deployment, you'll receive:
- Connect instance ID and ARN
- Queue ID
- Routing profile ID
- User ID
- Summary of the deployment

## Next Steps

After deployment:
1. Log in to the AWS Connect console
2. Complete the initial setup wizard if prompted
3. Test the user login credentials
4. Configure additional contact flows as needed

## Cost Considerations

Basic Connect instance costs:
- Monthly fee per user
- Usage-based charges for inbound/outbound calls
- No cost for the instance itself

See [Amazon Connect Pricing](https://aws.amazon.com/connect/pricing/) for details.
