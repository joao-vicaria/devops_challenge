PREFIX ?= localdev
HTMLCOV_DIR ?= htmlcov
TAG ?= dev
IMAGES := orders products gateway

EPINIO_ORG ?= good
EPINIO_SPACE ?= morning
EPINIO_APP ?= nameko-devex

install-dependencies:
	pip install -U -e "orders/.[dev]"
	pip install -U -e "products/.[dev]"
	pip install -U -e "gateway/.[dev]"

# test

coverage-html:
	coverage html -d $(HTMLCOV_DIR) --fail-under 100

coverage-report:
	coverage report -m

test:
	flake8 orders products gateway
	coverage run -m pytest gateway/test $(ARGS)
	coverage run --append -m pytest orders/test $(ARGS)
	coverage run --append -m pytest products/test $(ARGS)

coverage: test coverage-report coverage-html

# test
smoke-test:
	./test/nex-smoketest.sh http://localhost:8000

perf-test:
	./test/nex-bzt.sh http://localhost:8000

# docker

build-base:
	docker build --target base -t nameko-example-base .;
	docker build --target builder -t nameko-example-builder .;

build: build-base
	for image in $(IMAGES) ; do TAG=$(TAG) make -C $$image build-image; done

deploy-docker: build
	bash -c "trap 'make undeploy-docker' EXIT; PREFIX=${PREFIX} TAG=$(TAG) docker-compose up"

undeploy-docker:
	PREFIX=$(PREFIX) docker-compose down
	
docker-save:
	mkdir -p docker-images
	docker save -o docker-images/examples.tar $(foreach image,$(IMAGES),nameko/nameko-example-$(image):$(TAG))

docker-load:
	docker load -i docker-images/examples.tar

docker-tag:
	for image in $(IMAGES) ; do make -C $$image docker-tag; done

docker-login:
	docker login --password=$(DOCKER_PASSWORD) --username=$(DOCKER_USERNAME)

push-images:
	for image in $(IMAGES) ; do make -C $$image push-image; done

# epinio
epinio_target:
	#epinio namespace create $(EPINIO_APP)
	epinio target workspace

epinio_cs_postgres:
	epinio service create postgresql-dev $(EPINIO_APP)_devPostgres -v globalPostgresqlAuthDatabase=orders
	echo "Waiting for service to be created"
	for i in $$(seq 1 90); do \
		epinio service list | grep -i $(EPINIO_APP)_devPostgres | grep  "deployed" 2> /dev/null && break; \
			sleep 1; \
	done 

epinio_ds_postgres:
	epinio service delete $(EPINIO_APP)_devPostgres
	echo "Waiting for service to be deleted"
	for i in $$(seq 1 90); do \
		epinio service list|grep -i $(EPINIO_APP)_devPostgres | grep  "delete in progress" 2> /dev/null || break; \
			sleep 1; \
	done 

epinio_cs_rabbitmq:
	epinio service create rabbitmq-dev $(EPINIO_APP)_devRabbit
	echo "Waiting for service to be created"
	for i in $$(seq 1 90); do \
		epinio service list| grep -i $(EPINIO_APP)_devRabbit | grep  "deployed" 2> /dev/null && break; \
			sleep 1; \
	done 

epinio_ds_rabbitmq:
	epinio service delete $(EPINIO_APP)_devRabbit
	echo "Waiting for service to be deleted"
	for i in $$(seq 1 90); do \
		epinio service list|grep -i $(EPINIO_APP)_devRabbit | grep  "delete in progress" 2> /dev/null || break; \
			sleep 1; \
	done 

epinio_cs_redis:
	epinio service create redis-dev $(EPINIO_APP)_devRedis
	echo "Waiting for service to be created"
	for i in $$(seq 1 90); do \
		epinio service list|grep -i $(EPINIO_APP)_devRedis | grep  "deployed" 2> /dev/null && break; \
			sleep 1; \
	done 

epinio_ds_redis:
	epinio service delete $(EPINIO_APP)_devRedis
	echo "Waiting for service to be deleted"
	for i in $$(seq 1 90); do \
		epinio service list|grep -i $(EPINIO_APP)_devRedis | grep  "delete in progress" 2> /dev/null || break; \
			sleep 1; \
	done 

epinio_push_prepare:
	./export_vars.sh

prepareEPINIO: epinio_target epinio_cs_postgres epinio_cs_rabbitmq epinio_cs_redis

deployEPINIO:
	# create environment.yml file from environment_dev.yml file
	cat environment_dev.yml | grep -v '#dev' > environment.yml
	#epinio push -n $(EPINIO_APP)-orders -p ./orders -e DB_PASSWORD="8vKe5tZJRu" -e DB_HOST="x1e2860a294caa5e6507abe673a53-postgresql-hl.nameko.svc.cluster.local" -e RABBIT_PASSWORD="j5CyCdYePmI2einq" -e RABBIT_HOST="xc1fc144d1d2668192159dcbf4621-rabbitmq-headless.nameko.svc.cluster.local" -e RABBIT_USER="user"
	#epinio push -n $(EPINIO_APP)-products -p ./products -e RABBIT_PASSWORD="j5CyCdYePmI2einq" -e RABBIT_USER="user" -e RABBIT_HOST="xc1fc144d1d2668192159dcbf4621-rabbitmq-headless.nameko.svc.cluster.local" -e REDIS_PASSWORD="DT7BFHIBZO" -e REDIS_HOST="x9c293822a24aebee3148c60a3c24-redis-headless.nameko.svc.cluster.local"
	epinio configuration create nameko-cfg -f config_vars.txt
	epinio push -n $(EPINIO_APP) -b nameko-cfg
	#epinio service bind $(EPINIO_APP)_devPostgres $(EPINIO_APP)
	#epinio service bind $(EPINIO_APP)_devRedis $(EPINIO_APP)
	#epinio service bind $(EPINIO_APP)_devRabbit $(EPINIO_APP)
	rm environment.yml
	#epinio app restage $(EPINIO_APP)

undeployEPINIO:
	epinio target workspace
	#$(MAKE) epinio_ds_postgres
	#$(MAKE) epinio_ds_rabbitmq
	#$(MAKE) epinio_ds_redis
	epinio configuration delete nameko-cfg
	epinio app delete $(EPINIO_APP)
	#epinio namespace delete $(EPINIO_APP)
