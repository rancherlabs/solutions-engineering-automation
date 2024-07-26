# Easy Install

Easy Install is a bash script project designed to quickly deploy Rancher products such as RKE, RKE2, k3s, and Rancher itself on Ubuntu OS. It also includes support for additional tools such as Helm, kubectl, and a DNS server. The script utilizes the GitHub API to fetch the latest available release for each product and provides an option to deploy the selected release.

## Features

- Easy deployment of Rancher products and supporting tools on Ubuntu OS.
- Fetches the latest available release using the GitHub API.
- Menu-driven interface for selecting the desired installation.
- Handles system type detection (AMD or ARM) and deploys the product accordingly.
- Validates the successful completion of the installation.
- Future plans to add more options, such as adding worker agents and other enhancements.

## Installation

1. Clone this repository to your local machine:

```bash
git clone https://github.com/your-username/easy-install.git
```

2. Change to the project directory:

```
cd easy-install
```

## Usage

1. Start the script:

```
./easy-install.sh
```

2. After executing the script, you will see the following menu:

```
Select the installation option:
1. Install RKE
2. Install RKE2
3. Install k3s
4. Install Rancher
5. Install Helm
6. Install kubectl
7. Install DNS server
```

3. Choose the desired installation option by entering the corresponding number.

 1.   Follow the prompts and provide the necessary arguments.

 2.   Wait for the script to complete the deployment.

 3.   Verify the successful installation.

## Requirements

  - Ubuntu OS
  - Git
  - Bash

## Contributing

Contributions are welcome! If you have any ideas, suggestions, or bug reports, please create an issue or submit a pull request.

