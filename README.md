<p align="center">
    <img src="https://weclouddata.com/wp-content/uploads/2022/06/WCD-Logo.svg">
</p>

# 1. Github Actions Intro

![](image/GithubActions.png)

https://docs.github.com/en/actions

- A free tool.

- Serverless.

- Easy to setup and manage.


# 2. Basics

## Workflow
In one Github Repository, you can have multiple workflows.
```
├── .github
│   └── workflows
│       ├── deliver.yaml
│       └── run_test_on_PR.yaml
```
## Events
- Push.

- Pull_request.

- Schedule.

- Issue.

- External Event

```yaml
on:
  pull_request:
    branches:
      - develop
      - main
```

```yaml
on:
  schedule:
  # minute hour day-of-month month day-of-week
    - cron: '0 0 * * *'
    - cron: '0 5 */1 * *'
```

## Jobs
In one workflow you can have multiple jobs.

Jobs can be in parallel or in sequence.

key word: `needs`
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps: ...
  build:
    runs-on: ubuntu-latest
    needs: test
    steps: ...
```

## Steps
In one job you can have multiple steps
```yaml
jobs:
  run_tests:
    runs-on: ubuntu-latest
      - name: run bash commands
        run: |
          pwd
          ls -al
        shell: bash
```
## Actions
https://github.com/marketplace?type=actions

Actions are the building blocks that power your workflow. They are like functions in Python. You can either write your own action and reference it or simply just use an action from a public repository.

To use an action, use the key word `uses`
To provide arguments to an action: use the key word `with`
```yaml
jobs:
  run_tests:
    runs-on: ubuntu-latest
      - uses: actions/checkout@v2 #https://github.com/actions/checkout
      - name: Set up Python 3.8 
        uses: actions/setup-python@v1 # https://github.com/actions/setup-python
        with:
          python-version: 3.8
```

By default Github Action doesn't clone your repo to the Github hosted server. Therefore we have to clone it by ourselves. The easiest way to do that is using the checkout action.

Setup-python is another useful action that install the specific version of Python for us in the VM.

## Environment Variables
### Custom Environment Variables
Use the `env` key to create custom environment variables in the workflow.

You can define the environment variables that are scoped for:
- The entire workflow.
- Job level.
- Step level.

### Default Environment Variables
- GITHUB_WORKFLOW.

- GITHUB_ACTION.

- GITHUB_REPOSITORY.

- GITHUB_ACTOR.

Etc
```yaml
    steps:
      - name: Default ENV Variables
        run: |
          echo "HOME: ${HOME}"
          echo "GITHUB_WORKFLOW: ${GITHUB_WORKFLOW}" # Name of the workflow
          echo "GITHUB_ACTION: ${GITHUB_ACTION}" # Name of the action
          echo "GITHUB_ACTIONS: ${GITHUB_ACTIONS}" # Always true when running in GitHub Actions
          echo "GITHUB_ACTOR: ${GITHUB_ACTOR}" # Name of the person who triggered the workflow
          echo "GITHUB_REPOSITORY: ${GITHUB_REPOSITORY}" # Owner/Repo
```
https://docs.github.com/en/actions/learn-github-actions/environment-variables


# Expressions
https://docs.github.com/en/actions/learn-github-actions/expressions

`${{}}`  You can use expressions to programmatically set environment variables in workflow files and access contexts. An expression can be any combination of literal values, references to a context, or functions.

For example, you can use it to refer to the secret variables you stored in the Github settings.

```yaml
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Dockerhub Login
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
```

# 3. This Workshop
I prepared 3 workflows.

Two of them are here: https://github.com/davyzhang3/Example_Webpage

- run_test_on_PR.yaml runs a test when there is a pull request from developers.

- deliver.yaml runs a test, builds a docker image from the python scripts and push it to the Github repository.

- Deploy.yaml pulls the latest code to a remote server when there is a pull request to the master branch

