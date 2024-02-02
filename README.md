# Chef Kitchen Setup for Starburst Enterprise Administration

Welcome to the Chef Kitchen setup guide tailored for Starburst Enterprise administration! This document is your gateway to utilizing a suite of Chef recipes designed to facilitate the management of Starburst Enterprise installations. These recipes simplify operations such as starting, stopping, restarting services, pushing configurations, and installations, specifically tailored for a CentOS 7 environment running in Docker. It was tested using Kitchen.

## Important Disclaimer

Please note that the code and configurations provided in this guide are **not officially supported by Starburst.** They have been developed and tested by our team to assist in the administration of Starburst Enterprise but should be used with the understanding that they are not endorsed or certified by Starburst itself. Users should proceed with caution and test in their environments accordingly.

## Environment Setup

These Chef recipes have been tested within a CentOS 7 environment utilizing Docker to ensure compatibility and seamless execution.

## Recipes Overview

Included in this setup are five key Chef recipes, each serving a specific role in the management of your Starburst Enterprise deployment:

- `start.rb`: Initiates the Starburst service.
- `stop.rb`: Halts the Starburst service.
- `restart.rb`: Restarts the Starburst service, useful for applying new configurations or updates.
- `push-configs.rb`: Deploys configuration changes to your Starburst installation.
- `install.rb`: Handles the initial installation of Starburst Enterprise.

Each recipe is designed for ease of use and can be integrated into your existing Chef Kitchen workflows, providing a robust toolkit for Starburst Enterprise administration.

## Installing Chef Workstation and Setting Up Chef Kitchen

### Prerequisites

- Ensure you have a working installation of Docker on your CentOS 7 system.
- Basic knowledge of terminal or command line usage on your respective system.

### Step 1: Install Chef Workstation

Chef Workstation includes everything you need to get started with Chef, including Chef Kitchen. To install it, follow these steps:

1. Go to the [Chef Workstation download page](https://downloads.chef.io/tools/workstation).
2. Choose the package appropriate for your system.
3. Download and install Chef Workstation using your system's package manager.

For CentOS, you can use the following commands:

```sh
curl -L https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chef-workstation
```

### Step 2: Verify Chef Workstation Installation

To ensure Chef Workstation was installed correctly, open a terminal and run:

```sh
chef -v
```

You should see the versions of Chef Workstation, Chef Infra Client, Chef InSpec, and Test Kitchen.

### Step 3: Setting Up Chef Kitchen

With Chef Workstation installed, you already have Test Kitchen. **kitchen.yml** is already setup for configuration with Docker and CENTOS7. You can use the default configuration or modify it to suit your needs.

Within this file, you can specify the recipe to be configured within:

```yaml
run_list:
  - recipe[starburst-cookbook::RECIPE_HERE]
```

### Step 4: Run Your First Test Kitchen Instance

To create and converge your Docker instance using Chef Kitchen, run:

```sh
kitchen converge
```
