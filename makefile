# build:
# 	docker build --tag stephenhouser/urlwatch .

#
# URLWatch & MQTT - Webpage changes to MQTT
#
# Include my secrets from a protected place
include ~/.ssh/container-secrets.txt

# Basic container setup
VM_NAME=$(shell /usr/bin/awk '/container_name: / {print $$2;}' docker-compose.yaml)

# Show the container and its volumes
default:
	docker-compose ps

test:
	docker run -it --rm ${VM_NAME} /bin/sh

# Build the container's image
build:
	docker-compose build --compress --force-rm --pull

# Make (and start) the container
run: container

container: build
	docker-compose up -d

# Start an already existing container that has been stopped
start:
	docker-compose start

# Attach to a running contiainer with sh
attach:
	docker exec -it ${VM_NAME} /bin/sh

# Attach to a running container's console
console:
	tmux attach-session -t ${VM_NAME} \
	|| tmux new-session -s ${VM_NAME} docker attach ${VM_NAME}

# Stop a running container
stop:
	docker-compose stop

# Update a container's image; stop, pull new image, and restart
update: clean
	-docker-compose pull ${DOCKER_IMAGE}
	make container 

# Delete container's volume (DANGER)
clean-volume:
	docker-compose down -v

# Delete a container (WARNNING)
clean: stop
	docker-compose down

# Delete a container and it's volumes (DANGER)
distclean: clean clean-volume
