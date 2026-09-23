# Firewall (firewalld) — default zone + LAN ports for LocalSend and Steam game transfers


ZONE := "public"

# Set the default zone to public
_firewall-public:
    sudo firewall-cmd --set-default-zone {{ZONE}}
    sudo firewall-cmd --reload
    firewall-cmd --get-default-zone

# Open LocalSend ports (TCP+UDP 53317) in the public zone
_firewall-localsend:
    sudo firewall-cmd --permanent --zone={{ZONE}} --add-port=53317/tcp
    sudo firewall-cmd --permanent --zone={{ZONE}} --add-port=53317/udp
    sudo firewall-cmd --reload

# Open Steam local network game transfer ports (TCP 27040, UDP 27031-27036)
_firewall-steam-lan:
    sudo firewall-cmd --permanent --zone={{ZONE}} --add-service=steam-lan-transfer
    sudo firewall-cmd --reload

# Show default zone and what's open in the public zone
show-firewall:
    firewall-cmd --get-default-zone
    firewall-cmd --zone={{ZONE}} --list-all

# Full LAN setup: public default zone + LocalSend + Steam LAN transfer
setup-firewall: _firewall-public _firewall-localsend _firewall-steam-lan
    firewall-cmd --zone={{ZONE}} --list-all
