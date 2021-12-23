import json
import requests
import sys
import subprocess

# Creates the pull request for the head_branch against the base_branch
def create_pull_request(project_name, repo_name, title, description, head_branch, base_branch, git_token):
    git_pulls_api = "https://api.github.com/repos/{0}/{1}/pulls".format(
        project_name,
        repo_name)
    
    headers = {
        "Authorization": "token {0}".format(git_token),
        "Content-Type": "application/json",
        "Accept": "application/vnd.github.v3+json"}

    payload = {
        "title": title,
        "body": description,
        "head": head_branch,
        "base": base_branch,
    }

    r = requests.post(
        git_pulls_api,
        headers=headers,
        data=json.dumps(payload))

    if not r.ok:
        print("Request Failed: {0}".format(r.text))

git_project = "rpbit"
git_repo = "devops-netology"
git_project_branch = "main"
git_develop_branch = "develop"
git_token = input("Введите токен: ")

git_PR_descript = "Testing the pull request API for Python homework"
git_commit_msg = "[04-script-02-py] Add new feature"

if len(sys.argv) == 2:
    git_PR_title = sys.argv[1]
else:
    git_PR_title = "Add new feature"

cmd = f"git branch {git_develop_branch} && git checkout develop && " + \
    f"git add . && git commit -m \"{git_commit_msg}\" && " + \
    f"git push -u origin {git_develop_branch}"

results = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, \
    stderr=subprocess.PIPE, encoding='utf-8')
if results.returncode != 0:
    print(f"Git data error: {results.stderr}")
    exit(1)

create_pull_request(
    git_project, # Ваш проект
    git_repo, # Имя репозитория
    git_PR_title, # Заголовок пул-реквеста
    git_PR_descript, # Описание пул-реквеста
    git_develop_branch, # Ветка вашего проекта
    git_project_branch, # Ветка исходного проекта
    git_token, # Токен для авторизации на Github
)