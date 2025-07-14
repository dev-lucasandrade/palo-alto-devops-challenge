#!/bin/bash
yum update -y
yum install -y htop vim wget curl git

# Install AWS CLI v2
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Configure timezone
timedatectl set-timezone UTC

# Create a banner
cat > /etc/motd << EOF
===============================================
    ${project_name} - ${environment} Environment
    Bastion Host
===============================================
This is a bastion host for secure access to
private resources in the ${project_name} environment.

Use this host to access:
- ECS containers in private subnets
- Database instances
- Other private resources

Security Notice:
- All sessions are logged
- Access is monitored
- Follow security guidelines

===============================================
EOF

# Configure SSH settings for better security
sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 300/' /etc/ssh/sshd_config
sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 2/' /etc/ssh/sshd_config
systemctl restart sshd

# Create useful aliases
cat >> /home/ec2-user/.bashrc << 'EOF'
alias ll='ls -la'
alias la='ls -la'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
EOF

# Set proper permissions
chown ec2-user:ec2-user /home/ec2-user/.bashrc

# Log setup completion
echo "Bastion host ${project_name}-${environment} setup completed at $(date)" >> /var/log/bastion-setup.log
