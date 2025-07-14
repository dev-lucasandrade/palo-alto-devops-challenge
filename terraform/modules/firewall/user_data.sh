#!/bin/bash
yum update -y
yum install -y iptables-services httpd

# Enable IP forwarding
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p

# Configure iptables for firewall functionality
systemctl enable iptables
systemctl start iptables

# Clear existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established and related connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow SSH from anywhere (for management)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP and HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Forward HTTP/HTTPS traffic (bidirectional routing)
iptables -A FORWARD -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -p tcp --dport 443 -j ACCEPT
iptables -A FORWARD -p tcp --sport 80 -j ACCEPT
iptables -A FORWARD -p tcp --sport 443 -j ACCEPT

# NAT rules for outbound traffic
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Log dropped packets
iptables -A INPUT -j LOG --log-prefix "FIREWALL-INPUT-DROP: " --log-level 4
iptables -A FORWARD -j LOG --log-prefix "FIREWALL-FORWARD-DROP: " --log-level 4

# Save iptables rules
service iptables save

# Configure simple health check endpoint
cat > /var/www/html/health <<EOF
OK
EOF

# Start httpd for health checks
systemctl enable httpd
systemctl start httpd

# Create firewall status script
cat > /usr/local/bin/firewall-status.sh <<EOF
#!/bin/bash
echo "=== Firewall Status ==="
echo "IP Forwarding: \$(cat /proc/sys/net/ipv4/ip_forward)"
echo "Active Rules:"
iptables -L -n -v
echo "NAT Rules:"
iptables -t nat -L -n -v
EOF

chmod +x /usr/local/bin/firewall-status.sh

# Log startup completion
echo "Firewall instance ${project_name}-${environment} configured successfully" >> /var/log/firewall-setup.log
