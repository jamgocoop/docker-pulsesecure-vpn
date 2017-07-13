# docker-pulsesecure-vpn

Dockerized pulse secure vpn connection using:

> http://www.infradead.org/openconnect/

This is only a simple implementation to simplify the connection in linux without the oficial pulse secure client. This image is similar to jamgocoop/junipervpn, but needs a patched openconnect and a different way to start it.

# How to use this image

## User/Password connect:
	
	docker run --name \
		pulsevpn \
		-e "VPN_URL=<vpn_connect_url>" \
		-e "VPN_USER=<user>" \
		-e "VPN_PASSWORD=<password>" \
		-e "OPENCONNECT_OPTIONS=<openconnect_extra_options>" \
		--privileged=true \
		-d jamgocoop/pulsesecure-vpn

## User/Password with certificate connect:
	
	docker run --name \
		pulsevpn \
		-e "VPN_URL=<vpn_connect_url>" \
		-e "VPN_USER=<user>" \
		-e "VPN_PASSWORD=<password>" \
		-e "OPENCONNECT_OPTIONS=<openconnect_extra_options>" \
		-v /full/path/<user>.pem:/root/<user>.pem:ro \
		--privileged=true \
		-d jamgocoop/pulsesecure-vpn
	
## Bad server cert:
	
If the connect server has and insecure or self signed certificate you must follow a few more steps. The openconnect option **--no-cert-check** has been removed from the current version of openconnect, so we must obtain the server's cert fingerprint and pass it to openconnect.
	
	docker run --rm -ti jamgocoop/pulsesecure-vpn openconnect <vpn_connect_url>
	
You will obtain something like:
	
```bash
POST https://example.com/pulsesecure
Connected to xxx.xxx.xxx.xxx:443
SSL negotiation with example.com
Server certificate verify failed: signer not found

Certificate from VPN server "example.com" failed verification.
Reason: signer not found
To trust this server in future, perhaps add this to your command line:
	--servercert pin-sha256:lERGk61FITjzyKHcJ89xpc6aDwtRkOPAU0jdnUqzW2s=
Enter 'yes' to accept, 'no' to abort; anything else to view:
```
	
Answer **no** and copy the printed option: `--servercert pin-sha256:lERGk61FITjzyKHcJ89xpc6aDwtRkOPAU0jdnUqzW2s=`.
	
Now you can pass the **--servertcert** option to the final docker execution to avoid the warning and user interaction.
	
	docker run --name \
		pulsevpn \
		-e "VPN_URL=<vpn_connect_url>" \
		-e "VPN_USER=<user>" \
		-e "VPN_PASSWORD=<password>" \
		-e "OPENCONNECT_OPTIONS=--servercert pin-sha256:lERGk61FITjzyKHcJ89xpc6aDwtRkOPAU0jdnUqzW2s=" \
		-v /full/path/<user>.pem:/root/<user>.pem:ro \
		--privileged=true \
		-d jamgocoop/pulsesecure-vpn

## Add routes
Once started you can route subnets from host via docker container:

    #! /bin/bash
    PULSESECURE_DOCKER_IP="$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' pulsevpn)"
    if [ -z "$PULSESECURE_DOCKER_IP" ]; then
    	echo >&2 'error: missing PULSESECURE_DOCKER_IP, is pulsevpn docker running?'
    	exit 1;
    fi
    sudo route add -net a.b.c.0 netmask 255.255.255.0 gw $PULSESECURE_DOCKER_IP
    sudo route add -net x.y.z.0 netmask 255.255.255.0 gw $PULSESECURE_DOCKER_IP
    ...
