# Makefile for convenience
.PHONY: base-image climacell-base base-notebook pangeo-notebook ml-notebook climacell-notebook
TESTDIR=/srv/test
pypi_file ?= ~/.pip/pip.conf

base-image :
	cd base-image ; \
	docker build -t pangeo/base-image:master .

climacell-base :
	cd climacell-base ; \
	docker build --no-cache -t us.gcr.io/climacell-research/climacell-base:latest --build-arg PYPI_FILE="`cat $(pypi_file)`" . ;

push-climacell-base : climacell-base
	docker push us.gcr.io/climacell-research/climacell-base:latest

base-notebook : base-image
	cd base-notebook ; \
	../update_lockfile.sh ../base-image/condarc.yml; \
	docker build -t pangeo/base-notebook:master . ; \
	docker run -w $(TESTDIR) -v $(PWD):$(TESTDIR) pangeo/base-notebook:master ./run_tests.sh base-notebook

pangeo-notebook : base-image
	cd pangeo-notebook ; \
	../update_lockfile.sh ../base-image/condarc.yml; \
	docker build -t pangeo/pangeo-notebook:master . ; \
	docker run -w $(TESTDIR) -v $(PWD):$(TESTDIR) pangeo/pangeo-notebook:master ./run_tests.sh pangeo-notebook

ml-notebook : base-image
	cd ml-notebook ; \
	../update_lockfile.sh condarc.yml; \
	docker build -t pangeo/ml-notebook:master . ; \
	docker run -w $(TESTDIR) -v $(PWD):$(TESTDIR) pangeo/ml-notebook:master ./run_tests.sh ml-notebook

climacell-notebook : climacell-base
	cd climacell-notebook ; \
	docker build -t us.gcr.io/climacell-research/climacell-notebook:latest . ; \
	docker run -w $(TESTDIR) -v $(PWD):$(TESTDIR) us.gcr.io/climacell-research/climacell-notebook:latest ./run_tests.sh climacell-notebook

climacell-notebook-gc : 
	cd climacell-notebook 
	gcloud builds submit --async --machine-type=n1-highcpu-8 --timeout=2400 --tag us.gcr.io/climacell-research/climacell-notebook:latest ;
