# Azure Three-Tier Stack

This project deploys a three-tier architecture on Microsoft Azure using Terraform. The architecture includes a DMZ (Demilitarized Zone), Web Tier, Business Tier, and Data Tier, along with supporting infrastructure such as a Bastion host and Virtual Network.

## Architecture Overview

The three-tier architecture consists of the following components:

1. **DMZ Tier**:

   - Contains NVAs (Network Virtual Appliances) for security.
   - Includes a Load Balancer for external traffic management.

2. **Web Tier**:

   - Hosts the web application.
   - Uses a Virtual Machine Scale Set (VMSS) for scalability.
   - Includes a Load Balancer for distributing traffic.

3. **Business Tier**:

   - Hosts application logic.
   - Uses a VMSS for scalability.

4. **Data Tier**:

   - Hosts the database servers.
   - Includes SQL Server VMs for primary and secondary databases.

5. **Bastion Host**:

   - Provides secure access to the virtual machines in the network.

6. **Virtual Network**:
   - Contains subnets for each tier.
   - Provides network isolation and connectivity.

## Prerequisites

- Terraform installed on your local machine.
- Azure CLI installed and authenticated.
- An Azure subscription.

## Project Structure

```
azure-three-tier-stack/
├── main.tf                # Root module for orchestrating resources
├── variables.tf           # Input variables for the root module
├── outputs.tf             # Outputs for the root module
├── modules/
│   ├── bastion/           # Bastion module
│   ├── dmz/               # DMZ module
│   ├── web_tier/          # Web Tier module
│   ├── business_tier/     # Business Tier module
│   ├── data_tier/         # Data Tier module
│   └── network/           # Virtual Network module
└── README.md              # Project documentation
```

## Usage

1. **Clone the Repository**:

   ```bash
   git clone <repository-url>
   cd azure-three-tier-stack
   ```

2. **Initialize Terraform**:

   ```bash
   terraform init
   ```

3. **Validate the Configuration**:

   ```bash
   terraform validate
   ```

4. **Plan the Deployment**:

   ```bash
   terraform plan
   ```

5. **Apply the Configuration**:

   ```bash
   terraform apply
   ```

6. **Destroy the Resources** (if needed):
   ```bash
   terraform destroy
   ```

## Variables

The project uses several input variables to customize the deployment. Below are some key variables:

- `location`: Azure region where resources will be deployed.
- `vnet_name`: Name of the Virtual Network.
- `dmz_nva_count`: Number of NVAs in the DMZ.
- `web_server_scale_set_name`: Name of the Web Tier VM Scale Set.
- `bastion_image`: Image details for the Bastion VM.

Refer to the `variables.tf` file for the complete list of variables.

## Outputs

The project provides several outputs, such as:

- Public IP of the Bastion host.
- Private IPs of the Load Balancers.
- Subnet IDs for each tier.

Refer to the `outputs.tf` file for the complete list of outputs.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## Support

If you encounter any issues, feel free to open an issue in the repository or contact the project maintainers.
