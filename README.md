# bash-scripts
Collection of interactive bash scripts for flexible configurations, maintenance and security implementations based on user input instead of hard coded values.

## Available Scripts

### Fail2Ban setup
Interactive installation and setup of intrusion prevention software framework Fail2Ban based on user input values. Applicable for cases where Fail2Ban is already installed and where Fail2Ban is not installed yet. After user confirmation, Fail2Ban will be installed if not done so far. A user can define the port number, number of failures before an IP is banned, the time window that fail2ban will pay attention to when looking for repeated failed authentication attempts and the duration to ban a certain IP.

### IP version setup
Interactive setup and selection on applied IP version upon user requests including variable initialization for the continued application. It includes validation whether IPv6 and IPv4 is supported on the system. The setup ends with a verification step which must be confirmed by the user.

### Ping response configuration
Enabling or disabling ping responses upon user decision for IPv4 and IPv6. The applying user can decide whether to enable or disable ping responses for both IPv4 and IPv6 addresses. The process ends with a positive response if the validation has been passed successfully.

## Next steps
Where time permits, I will look to expand this collection of interactive bash scripts. 
