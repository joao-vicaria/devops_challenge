# DevOps_Challenge

This document/repository approaches my path through the challenge propose by [Ilia](https://ilia.digital/en/).
The challenge can be consulted [here](challenge_description/DevOps_Engineer_-_Case_Study.pdf).

## Fist of all

I read the entire documentation attached at [challenge doc](challenge_description/DevOps_Engineer_-_Case_Study.pdf) and I studied tools and concepts like:
 - [twelve-factor app](https://12factor.net/)
 - [nameko utilization](https://blog.geekhunter.com.br/python-microservices/)
 - [Miniconda](https://docs.conda.io/projects/conda/en/latest/user-guide/concepts/environments.html)

NOTE: I changed the format of that topic because the list of tools and concepts was growing while I was going deep in the challenge :D.

## Hands ON

### Exercise 01 - [Challenge](challenge_description/DevOps_Engineer_-_Case_Study.pdf)

I'm creating the setup for nameko, I'm just following the HowTo from the [gitlab README](https://gitlab.com/devprodexp/nameko-devexp/-/blob/main/README-DevEnv.md).

NOTES about pre-requisites:

    1 - I fell more confortable using PyCharm instead VSCode.
    2 - I used chocolatey instead brew, It was already installed on my computer.

#### **nameko-devexp clone**

Run command `git clone https://gitlab.com/devprodexp/nameko-devexp.git` 

![nameko-devexp clone](images/nameko-devexp_clone.md.png)

#### **'jq' Instalation** 

Run command `brew install jq` or `choco install jq`

![jq_install](images/choco_jq_install.png)

#### **Conda Environment Instalation** 

Open Anaconda Prompt.

On Linux I needed run this command to active the environment: `source <home_miniconda3>/etc/profile.d/conda.sh`

Run command `conda env create -f environment_dev.yml`

Returned an error because my conda was seted to python version 3.11

![conda-env_install](images/conda-env_error01.png)

The error was about installation of the package _fuzzyset_, I found on Google, the _fuzzyset_ package is in package _bzt_ in the dependency section at [environment_dev.yml](nameko-devexp/environment_dev.yml). So I updated the _bzt_ package version. The problem was solved and the Conda environment was created.

![bzt_version_updated](images/bzt_version_update.yml.png)

Environment Created.

![conda_env_created](images/conda_env_created.png)

#### **Conda Environment Activation** 

Run command `conda activate nameko-devex`

![conda_env_activate](images/conda_env_activate.png)

#### **Start Service Locally** 

To start backend nameko-devexp services run script in nameko-devexp `./dev_run_backingsvcs.sh`

![backendservices_running_locally](images/locally_backendservices_running.png)

NOTE: Because of startup services scripts I changed the environment to a Linux OS, before I was using Microsoft Windows 10. I executed all past steps described in this document, and everything ran the same. 

Continuing on Linux...

To start nameko services run script in nameko-devexp `./dev_run.sh gateway.service orders.service products.service`

![services_running_locally](images/locally_services_running.png)

To run smoke test execute the command `./test/nex-smoketest.sh local`

![nameko-devex_smoketest](images/nameko-devexp_smoketest.png)

To run unit test execute the command `./dev_pytest.sh`

![nameko-devex_smoketest](images/nameko-devexp_unittest.png)

To run in debug mode execute the command `DEBUG=1 ./dev_run.sh gateway.service orders.service products.service`

![nameko-devex_debugmode](images/nameko-devexp_debugmode.png)

To run in performance test execute the command `./test/nex-bzt.sh local`

Link to Result: https://a.blazemeter.com/app/?public-token=Gwi6BuZsx0hG4QN67MPt67sUUIuCZF8EkTe1APHu4OjCrXQsik#reports/r-ext-6551458e4d227555680051/summary

[Performance Test Result Artifacts](performanceTestResult)

![nameko-devex_perftest](images/nameko-devexp_perftest.png)

Running FastAPI integration with nameko in that case we don't need run gateway.service, it is replaced by gateapi, command: `FASTAPI=X ./dev_run.sh orders.service products.service`

![nameko-devex_fastapi](images/nameko-devexp_FastAPI_Integration.png)

Swagger WebAccess running FastAPI.

![nameko-devex_fastapi-webaccess](images/nameko-devexp_FastAPI_WebAccess.png)
