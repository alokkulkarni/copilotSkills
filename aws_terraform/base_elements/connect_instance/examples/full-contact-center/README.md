# Full Contact Center Example

This example demonstrates deploying a complete Amazon Connect contact center with all features including phone numbers, contact flows, multiple queues, and user management.

## Module Structure

This example leverages the modular Connect instance module where each component is managed in separate files:

| Component | Module File | Example Configuration |
|-----------|-------------|----------------------|
| Instance | main.tf | Core Connect settings |
| Hours of Operation | hours_of_operation.tf | Business & extended hours |
| Phone Numbers | phone_numbers.tf | DID & toll-free lines |
| Queues | queues.tf | Sales & Support queues |
| Routing Profiles | routing_profiles.tf | Agent & Supervisor profiles |
| Security Profiles | security_profiles.tf | Role-based permissions |
| Quick Connects | quick_connects.tf | Supervisor transfers |
| Contact Flows | contact_flows.tf | Call routing logic |
| Users | users.tf | Agents & supervisors |

### Component Management

You can independently manage each component by updating the corresponding variables. For example:
- **Add phone numbers**: Modify `phone_numbers` variable
- **Add users**: Modify `users` variable
- **Add security profiles**: Modify `security_profiles` variable
- **Update contact flows**: Modify `contact_flows` variable

## Features

- Complete Connect instance with all features enabled
- Phone number provisioning (DID and toll-free)
- Multiple queues for different departments
- Contact flows with hours of operation check
- Multiple routing profiles for different agent types
- Security profiles with granular permissions
- Admin user and multiple agent users
- Quick connects for supervisor escalation
- CloudWatch logging enabled
- Contact Lens analytics enabled

## Architecture

```
Phone Numbers → Contact Flow → Queue Selection → Agent Routing
                     ↓
                Hours Check
                     ↓
              After Hours Flow
```

## Prerequisites

- AWS account with Connect service enabled
- Available phone numbers in your target region
- Appropriate service quotas for phone numbers

## Usage

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan -var="instance_alias=my-full-contact-center"

# Deploy the infrastructure
terraform apply -var="instance_alias=my-full-contact-center"

# Clean up
terraform destroy
```

## Configuration

### Customize Variables

Edit `terraform.tfvars` or pass variables:

```hcl
instance_alias = "my-contact-center"
environment    = "production"
provision_phone_numbers = true
enable_contact_lens = true
```

### Phone Numbers

The example provisions:
- Main DID number for inbound calls
- Toll-free number for customer convenience

**Note**: Phone number availability varies by region. If provisioning fails, check AWS service quotas.

### Contact Flows

The example includes a basic contact flow that:
1. Greets the customer
2. Checks hours of operation
3. Transfers to queue if open
4. Plays after-hours message if closed

### Queues

Two queues are created:
- **Sales Queue**: For sales inquiries
- **Support Queue**: For technical support

### Users

The example creates:
- 1 Admin user (full permissions)
- 2 Sales agents
- 2 Support agents

## Outputs

After deployment, you'll receive:
- Connect instance details (ID, ARN, console URL)
- Phone numbers provisioned
- Queue IDs and ARNs
- User IDs for all created users
- Contact flow IDs
- Complete deployment summary

## Post-Deployment Steps

1. **Access the Console**
   ```
   https://<instance-alias>.my.connect.aws/
   ```

2. **Test Phone Numbers**
   - Call the main line and verify routing
   - Test after-hours message outside business hours

3. **Configure Users**
   - Set user passwords (if not using SSO)
   - Assign additional permissions as needed
   - Set up user hierarchy groups

4. **Customize Contact Flows**
   - Modify the basic flow in Connect console
   - Add IVR menus, Lex bots, or Lambda integrations
   - Test all call paths

5. **Monitor Performance**
   - Check CloudWatch logs for contact flow execution
   - Review Contact Lens analytics (if enabled)
   - Monitor queue metrics and agent performance

## Cost Estimation

Monthly costs (approximate):
- Connect instance: No charge
- User fees: $X per active user per month
- Phone numbers: $X per DID, $X per toll-free
- Usage charges: $X per minute inbound/outbound
- Contact Lens: $X per contact analyzed
- CloudWatch logs: Based on ingestion volume

See [Amazon Connect Pricing](https://aws.amazon.com/connect/pricing/) for current rates.

## Troubleshooting

### Phone Number Provisioning Fails

```
Error: Error claiming phone number
```

**Solution**: 
- Check service quotas in AWS Service Quotas console
- Verify country code is supported in your region
- Try a different phone number type (DID vs TOLL_FREE)

### Contact Flow Errors

```
Error: Invalid contact flow JSON
```

**Solution**:
- Validate JSON structure
- Ensure all referenced resources exist (queues, hours of operation)
- Test flow in Connect console before deploying via Terraform

### User Creation Fails

```
Error: User already exists
```

**Solution**:
- Use unique usernames
- Check for existing users in Connect console
- Destroy and recreate if in dev/test environment

## Security Considerations

1. **User Passwords**: Store in AWS Secrets Manager, not in code
2. **Security Profiles**: Use least privilege principle
3. **Phone Numbers**: Restrict outbound calling
4. **Contact Flow Logs**: Enable for audit and debugging
5. **IAM Roles**: Review auto-created roles and policies

## Extending This Example

### Add Lambda Integration

```hcl
lambda_functions = {
  customer_lookup = {
    function_arn = aws_lambda_function.lookup.arn
  }
}
```

### Add Lex Bot

```hcl
lex_bots = [
  {
    name       = "CustomerServiceBot"
    lex_region = "eu-west-2"
  }
]
```

### Add User Hierarchy

```hcl
users = [
  {
    username = "agent1"
    hierarchy_group_name = "Sales-Team-1"
    # ... other config
  }
]
```

## Additional Resources

- [Amazon Connect Administrator Guide](https://docs.aws.amazon.com/connect/latest/adminguide/)
- [Contact Flow Best Practices](https://docs.aws.amazon.com/connect/latest/adminguide/contact-flow-best-practices.html)
- [Terraform AWS Connect Resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_instance)

---

**Version**: 1.0.0  
**Last Updated**: 2026-02-02
