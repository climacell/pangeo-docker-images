# Makefile for convenience
.PHONY: base-image base-notebook pangeo-notebook ml-notebook climacell-notebook
TESTDIR=/srv/test

base-image :
	cd base-image ; \
	docker build -t pangeo/base-image:master .

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

climacell-notebook : base-image
	cd climacell-notebook ; \
	docker build -t us.gcr.io/climacell-research/climacell-notebook:latest . ; \
	docker run -w $(TESTDIR) -v $(PWD):$(TESTDIR) us.gcr.io/climacell-research/climacell-notebook:latest ./run_tests.sh climacell-notebook

climacell-notebook-gc : 
	cd climacell-notebook 
	gcloud builds submit --async --timeout=1200 --tag us.gcr.io/climacell-research/climacell-notebook:latest ;