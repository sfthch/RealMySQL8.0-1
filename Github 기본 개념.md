# Github 기본 개념<br>
## 세 가지 상태<br>
#### Git은 파일을 Committed, Modified, Staged 이렇게 세 가지 상태로 관리<br>
* Committed: 데이터가 로컬 데이터베이스에 안전하게 저장됐다는 것을 의미<br>
* Modified: 수정한 파일을 아직 로컬 데이터베이스에 커밋하지 않은 것을 의미<br>
* Staged: 현재 수정한 파일을 곧 커밋할 것이라고 표시한 상태를 의미<br>
![워킹 트리, Staging Area, Git 디렉토리](https://raw.githubusercontent.com/RyanJeong/ryanjeong.github.io/master/img/gist/47867bbacce197e8e7b76f17ae7e434d/1.png)<br>
#### Git의 세 가지 상태는 Git 프로젝트의 세 가지 단계와 연결됨<br>
* Git directory: git이 프로젝트의 메타데이터와 객체 데이터베이스를 저장하는 곳으로, 다른 컴퓨터에 있는 저장소를 clone할 때 git directory가 생성됨<br>
* Working tree: 프로젝트의 특정 버전을 checkout 한 것으로, git directory 안에 압축된 데이터베이스에서 파일을 가져와서 working tree 생성<br>
* Staging area(index): Git directory에 있으며, 곧 commit할 파일에 대한 정보를 저장<br>
#### Git으로 하는 일은 기본적으로 아래와 같음<br>
* Working tree에서 파일 수정<br>
* Staging area에 파일을 올려 commit할 스냅샷을 생성하는데, 이때 모든 파일을 추가할 수도 있고 선택하여 추가할 수도 있음<br>
* Staging area에 있는 파일들을 commit해서 git directory에 영구적인 스냅샷으로 저장<br>

<br>

# Github 기본 설정<br>
## 사용자 이름과 메일 주소 설정<br>
```bash
$ git config --global user.name FIRST_NAME LAST_NAME
$ git config --global user.email MY_NAME@example.com
```
## Command 상에 출력되는 결과의 가독성을 개선하는 방법<br>
```bash
$ git config --global color.ui auto
```
## SSH Key 설정<br>
```bash
$ ssh-keygen -t rsa -C MY_NAME@example.com
# (/Users/your_user_directory/.ssh/id_rsa): ENTER
# Enter passphrase(empty for no passphrase): 비밀번호 입력
# Enter same passphrase again: 비밀번호 재입력

...
# FINGERPRINT MY_NAME@example.com
...

$ cat /Users/your_user_directory/.ssh/id_rsa.pub
```
> ![SSH Key 설정](https://raw.githubusercontent.com/RyanJeong/ryanjeong.github.io/master/img/gist/47867bbacce197e8e7b76f17ae7e434d/2.png)<br>
Settings -> SSH and GPG Keys -> New SSH Key -> Key<br>
Title 부분에는 충분히 구분할 수 있는 내용을 입력하고, Key 부분에는 콘솔에서 복사한 내용 입력<br>
```bash
# After you've set up your SSH key and added it to your GitHub account, you can test your connection.

$ ssh -T git@github.com
# Attempts to ssh to GitHub

> Hi username! You've successfully authenticated, but GitHub does not
> provide shell access.
```
## 2차 인증 설정<br>
> ![2차 인증 설정](https://raw.githubusercontent.com/RyanJeong/ryanjeong.github.io/master/img/gist/47867bbacce197e8e7b76f17ae7e434d/3.png)<br>
Settings -> Security -> Two-factor authentication:Set up two-factor authentication -> Choose between 'Set up using an app' or 'Set up using SMS'<br>

<br>

>![Recovery codes](https://raw.githubusercontent.com/RyanJeong/ryanjeong.github.io/master/img/gist/47867bbacce197e8e7b76f17ae7e434d/4.png)<br>
Recovery codes는 2FA(Two-factor authenticaion) 인증에 문제가 생길 경우 복구에 사용되므로 잘 보관할 것<br>

<br>

> ![Personal Access Token](https://raw.githubusercontent.com/RyanJeong/ryanjeong.github.io/master/img/gist/47867bbacce197e8e7b76f17ae7e434d/5.png)<br>
Settings -> Developer settings -> Personal access tokens -> Generate new token<br>
2차 인증이 완료된 후부터 Personal Access Token을 사용하여 계정에 접근해야 함<br>

<br>

> ![Personal Access Token Scopes](https://raw.githubusercontent.com/RyanJeong/ryanjeong.github.io/master/img/gist/47867bbacce197e8e7b76f17ae7e434d/6.png)<br>
Personal Access Token 생성 시 사용자가 원하는 접근 범위를 설정하여 사용<br>

## .gitignore<br>
### 프로젝트와 관련 없는 파일을 설정하여 commit 시 관련 없는 파일들은 update가 무시됨<br>

<br>

# Github 기본 명령어<br>
## git init<br>
```bash
$ git init
```
* 현재 directory에 local repo. 생성(Version 생성)<br>
## git add filename<br>
```bash
$ git add README.md
$ git add *.html
$ git add *
```
* git이 파일 상태를 추적함<br>
## git status<br>
```bash
$ git status
```
* 현재 directory에 존재하는 local repo. 상태를 조회(생성, 수정, 삭제 등)<br>
## git commit<br>
```bash
$ git commit -m "Commit Msg." # stage에 올라간 파일을 대상으로 commit함
$ git commit -am "Commit Msg."  # stage에 올라간 적이 있는 파일을 자동으로 추적하여 commit함
```
* 현재 directory에 새로운 version 생성하며, 이때 하나의 commit id는 하나의 version을 나타냄<br>
```bash
$ git commit --amend
```
* Commit Msg.를 수정하기 위해 사용하는 명령어<br>
## git log<br>
```bash
$ git log
```
* 현재 directory 내에 존재하는 모든 version의 log 출력<br>
```bash
$ git log --graph
```
* 현재 directory 내에 존재하는 모든 version의 log를 시각화하여 출력<br>
```bash
$ git log -p
```
* 현재 directory 내에 존재하는 모든 version을 대상으로 version 간 차이 출력<br>
```bash
$ git log *.c
```
* 현재 directory 내에 존재하는 모든 version 중에서 c 확장자를 가친 파일의 log 출력<br>
```bash
$ git log -p *.c
```
* 현재 directory 내에 존재하는 모든 version 중에서 c 확장자를 가친 파일들을 대상으로 파일 간 log 출력<br>
## git remote<br>
```bash
$ git remote add NAME URL
```
* Local repo.의 수정 사항을 remote repo.에 push하고자 할 때, URL을 직접 입력하기엔 번거롭고 과정 중에 잘못 입력할 위험이 있음<br>
* 따라서 remote repo.의 주소에 별명을 붙여 기록할 수 있음<br>
* git clone URL을 사용하여 remote repo.에 있는 내용을 local repo.에 가져올 경우 origin이라는 이름의 주소가 입력되어 있는데, 이 경우에는 push나 pull 명령 시 이름을 생략할 수 있음<br>
## git push<br>
```bash
$ git push REPOSITORY REFSPEC
```
* 현재 directory에서 commit된 내역들을 remote repo.(REPOSITORY에 remote repo.의 URL 주소가 저장되어 있음)의 특정 브랜치(REFSPEC)로 전송<br>
```bash
$ git push -u REPOSITORY REFSPEC
```
* -u 옵션을 사용할 경우 REPOSITORY의 REFSPEC 브랜치를 remote repo.의 REFSPEC 브랜치와 연결시킴<br>
* 만약 다음 push 또는 pull 작업을 동일한 REPOSITORY의 REFSPEC에서 수행할 경우, REFSPEC 생략 가능<br>
* **특히 REPOSITORY가 origin이고, 다음 작업 시 동일한 REPOSITORY의 동일한 REFSPEC이라면 REPOSITORY와 REFSPEC 둘 다 생략 가능**<br>
> As you push local branch with git push -u option, that local branch is linked with the remote branch automatically. The advantage is, you may use git pull without any arguments.<br>
## git diff<br>
* git add 동작을 수행하기 전에, 파일 내용을 한 번 더 검토하기 위해 사용<br>
* **가장 마지막으로 commit된 파일의 내용과 현재 수정 중인 파일의 내용을 서로 비교**<br>
```bash
$ git diff FROM_COMMIT_ID..TO_COMMIT_ID
```
* FROM_COMMIT_ID에서 TO_COMMIT_ID 사이에 발생한 변화를 출력<br>
```bash
$ git diff FROM_COMMIT_ID
```
* FROM_COMMIT_ID으로부터 가장 최신 commit 사이의 변화를 출력<br>
```bash
$ git diff HEAD@{n}
```
* 가장 최근 상태로부터 n개의 commit 전 상태와의 차이를 출력<br>
```bash
$ git diff HEAD@{n} *.c
$ git diff HEAD~n *.c
$ git diff FROM_COMMIT_ID *.c
```
* 확장자가 c인 파일을 대상으로 가장 최근 상태로부터 n개의 commit 전 상태와의 차이를 출력<br>
* **확장자가 c인 파일을 대상으로 가장 최근 상태로부터 FROM_VERSION 상태와의 차이를 출력**<br>
## git reset<br>
* 특정 시점(version)으로 상태를 되돌림(Time machine)<br>
* **local에서만 사용해야 하며, remote에 push한 상태에서는 reset을 사용할 수 없음(강제로 수행하게 할 순 있으나 문제가 발생할 수 있음)**<br>
```bash
$ git reset OPTION COMMIT_ID
$ git reset --soft COMMIT_ID
$ git reset --mixed COMMIT_ID
$ git reset --hard COMMIT_ID
```
#### 특정 시점(version)으로 상태를 되 돌리며, OPTION(soft, mixed, hard)에 따라 동작이 구분됨<br>
* soft: 돌아가려는 시점으로 이동하며, 시점 기준으로 변경된 내용들을 삭제하지 않고 보관<br>
변경된 내용들은 stage 상태에 머무르므로 다시 commit을 할 수도 있음<br>
* mixed: 돌아가려는 시점으로 이동하며, 시점 기준으로 변경된 내용들을 삭제하지 않고 보관<br>
변경된 내용들은 stage 상태에서 삭제되므로 다시 commit을 하기 위해서는 add 작업을 수행해야 함<br>
OPTION을 기재하지 않을 시 mixed 동작으로 수행함<br>
* hard: 돌아가려는 시점으로 이동하며, 시점 기준으로 변경된 내용들을 모두 삭제.<br>
```bash
$ git reset HEAD~n
$ git reset HEAD@{n}
```
* 가장 최근 상태로부터 n개의 commit 전 상태로 되돌림<br>
* **OPTION이 생략되었기 때문에 mixed 옵션이 적용됨**<br>
## git revert<br>
* reset soft, reset mixed와 비슷하게 동작하나, revert는 수정 이력을 저장한다는 차이점이 있음<br>
* **이미 remote repo.에 push를 한 경우이면서 동시에 이전 단계로 되돌려야 할 경우 사용함**<br>
```bash
$ git revert COMMIT_ID
```
* 가장 최근 상태로부터 n개의 commit 전 상태로 되돌림<br>
* **해당 commit ID의 상태로 복구하는 것이 아닌, 그 commit의 변경 내역만을 취소**<br>
```bash
$ git revert --no-commit COMMIT_ID
```
* revert 동작 수행 시 commit 메세지를 생성하지 않음<br>
```bash
$ git revert HEAD
```
* 가장 최근 commit을 바로 이전 단계로 되돌림<br>
```bash
$ git revert --no-commit HEAD~n
$ git revert --no-commit HEAD@{n}
$ git commit -m "Revert Msg."
```
* 가장 최근 상태로부터 n 단계의 commit 이전으로 되돌림<br>*
* **되돌리는 과정 중에 commit 메세지를 따로 생성하지 않으므로 commit 명령을 직접 수행하여 commit 메세지 생성**<br>
## git branch<br>
* 현재 directory에 어느 branch를 사용하여 작업 중인지 나타냄<br>
```bash
$ git branch -b BRANCH_NAME
```
* BRANCH_NAME 이름의 브랜치 생성 후 새로 생성한 BRANCH_NAME으로 브랜치 변경<br>
* **이는 git branch BRANCH_NAME, git checkout BRANCH_NAME을 하나의 명령어로 수행하는 것과 같음**<br>
```bash
$ git branch -d BRANCH_NAME
```
* BRANCH_NAME 이름의 브랜치 삭제<br>
```bash
$ git checkout -
```
* 브랜치 변경 전의 브랜치로 되돌아감<br>
```bash
$ git branch -a
```
* Local repo.에서 사용하는 브랜치 목록 뿐만 아니라 remote repo.에서 사용하는 브랜치 목록까지 모두 출력<br>
```bash
$ git checkout -b BRANCH_NAME REPOSITORY/BRANCH_NAME
```
* local repo.에 BRANCH_NAME이라는 이름의 브랜치를 생성<br>
* **Remote repo.의 BRANCH_NAME 브랜치를 local repo.의 BRANCH_NAME과 연결**<br>
## git merge<br>
![Git merge](https://raw.githubusercontent.com/RyanJeong/ryanjeong.github.io/master/img/gist/47867bbacce197e8e7b76f17ae7e434d/merge2.png)<br>
* 서로 다른 브랜치를 서로 병합하고자 할 때 사용하는 명령어<br>
* merge 명령을 수행하고자 할 경우 add 명령와 commit 명령이 선행되어야 함<br>
```bash
$ git checkout DEST_BRANCH
$ git merge OPTION SRC_BRANCH
$ git merge --ff SRC_BRANCH
$ git merge --no-ff SRC_BRANCH
$ git merge --squash SRC_BRANCH
```
#### DEST_BRANCH 브랜치에 병합하고자 할 경우, checkout 명령어를 사용하여 목적지 브랜치로 브랜치 변경<br>
* merge 명령어에서 목적지 브랜치(DEST_BRANCH)로 병합할 대상(SRC_BRANCH)를 입력<br>
* merge 명령은 세 가지 옵션 제공<br>
> ![Git merge --ff](https://raw.githubusercontent.com/RyanJeong/ryanjeong.github.io/master/img/gist/47867bbacce197e8e7b76f17ae7e434d/merge3.png)<br>
--ff: ff(fast-forward)인 경우, DEST_BRANCH의 참조 값을 SRC_BRANCH 참조 값으로 변경(즉, 같은 곳을 가리킴)<br>
만약 ff 관계가 아니라면, merge commit 생성<br>

> ![Git merge --no-ff](https://raw.githubusercontent.com/RyanJeong/ryanjeong.github.io/master/img/gist/47867bbacce197e8e7b76f17ae7e434d/merge4.png)<br>
--no-ff: 무조건 merge commit 생성<br>

> ![Git merge --squash](https://raw.githubusercontent.com/RyanJeong/ryanjeong.github.io/master/img/gist/47867bbacce197e8e7b76f17ae7e434d/merge5.png)<br>
--squash: merge 동작을 수행하되(work-tree와 index는 merge 후 상태가 됨), merge commit은 생성하지 않음<br>

#### Fast-forward 관계<br>
> ![Fast-forward](https://raw.githubusercontent.com/RyanJeong/ryanjeong.github.io/master/img/gist/47867bbacce197e8e7b76f17ae7e434d/ff1.png)<br>
Fast-forward: commit a와 commit b가 존재할 때 commit b의 history 내에 commit a의 history가 모두 포함되는 경우, 즉 commit a가 이루어진 후 commit a의 상태를 토대로 commit b가 이루어진 경우 commit a는 commit b에 fast-forward하다고 표현<br>

> ![Non fast-forward](https://raw.githubusercontent.com/RyanJeong/ryanjeong.github.io/master/img/gist/47867bbacce197e8e7b76f17ae7e434d/ff2.png)<br>
Non fast-forward: commit a와 commit b가 존재할 때, commit b의 history 내에 commit a의 history를 모두 포함하지 못한다면, 두 commit은 fast-forward 관계가 아님<br>

```bash
$ git checkout -b BRANCH_NAME
$ git push REPOSITORY BRANCH_NAME
```
* Remote repo.(REPOSITORY)에 BRANCH_NAME 이름의 브랜치를 새로 생성<br>
## git reflog<br>
* 현재 repo.에서 수행된 모든 commit log를 확인할 수 있음<br>
* **git reset 등으로 commit이 삭제되었을 경우 reflog를 활용하여 복구할 수 있음**<br>
```bash
# commit 복구하고자 할 경우, git reflog 명령으로 복구하고자 하는 commit의 commit id를 확인한 후에
$ git reset --hard COMMIT_ID

# branch 복구하고자 할 경우, git reflog 명령으로 복구하고자 하는 branch의 commit id를 확인한 후에
$ git checkout -b DELETED_BRANCH_NAME COMMIT_ID
```
## git rebase<br>
* 여러 개의 commit을 합치고자 할 때 사용<br>
```bash
$ git rebase -i HEAD~n
$ git rebase -i --root

# Commands:
# p, pick = use commit
# r, reword = use commit, but edit the commit message
# e, edit = use commit, but stop for amending
# s, squash = use commit, but meld into previous commit
# f, fixup = like "squash", but discard this commit's log message
# x, exec = run command (the rest of the line) using shell
# d, drop = remove commit
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
```
## git pull<br>
* Remote repo.로부터 변화된 파일을 받고, 병합하는 명령<br>
```bash
$ git pull REPOSITORY BRANCH_NAME
```
## git fetch<br>
* Remote repo.로부터 변화된 파일을 받는 명령<br>
```bash
$ git fetch REPOSITORY BRANCH_NAME
```
* pull 명령과 fetch 명령과의 차이는 merge 명령을 수행하는가 수행하지 않는가에 있음<br>
* **보통 fetch 명령은 변화된 내용을 한 번 더 확인하고자 할 때 사용함**<br>
```bash
$ git diff HEAD REPOSITORY/BRANCH_NAME
```
* **fetch 명령 수행 후 merge 명령을 수행한 것이 pull 명령과 같음**<br>

<br>

# Github 응용<br>
## Pull Request<br>
#### 자신이 작성한 코드를 반영시키고자 할 때 또는 코드 작성 중 다른 사람의 의견을 듣거나 토의할 때 사용한다. 아직 완료되지 않은 PR은 게시글 앞에 [WIP]를 붙이며(Work In Progress), PR을 하기 위해서는 아래와 같은 절차를 갖는다. <br>
1. 원본 repo.로부터 fork 수행(source remote repo. -> remote repo.)<br>
2. Fork 수행한 repo.를 clone(remote repo. -> local repo.)<br>
3. Clone 수행한 local repo.에 Feature branch 생성<br>
3. Feature branch를 push하여 remote repo.에 해당 branch를 추가함<br>
Local repo.에서 remote repo.로 push하면 remote repo.에 feature branch가 생성됨<br>
4. Feature branch에서 작업을 수행하고, 작업이 완료되면 commit 후 push<br>
5. 내 계정의 remote repo.에 접속하여 feature branch로 branch 변경<br>
6. Pull Request 클릭<br>
7. Merge 이후 동기화(pull) 및 feature branch 삭제<br>
Pull Request가 승인되면 Source remote repo.에 merge되며, 내 repo(local repo)로 pull한 후에, remote repo.<br>
#### 만약 내가 PR을 받는 입장이라면, merge를 하기 전에 이 요청(수정한 자료)에 문제가 없는지 확인 과정을 거쳐야 한다. 우선 수신자(나)가 송신자(상대방)의 저장소를 local로 가져온다. 그 후에 확인 과정을 거쳐 이상이 없을 시 merge를 수행한다.
```bash
# 우선 상대방의 remote repo.를 PR 상대방_ID로 저장 후 fetch
$ git remote add PR 상대방_ID git@github.com:PR 상대방_ID/REPOSITORY_NAME
$ git fetch PR 상대방_ID

# 상대방의 수정 내용을 확인하기 위해 branch 하나 생성
$ git checkout -b for_check
Switched to a new branch 'for_check'

# 새로 생성한 branch에 수정한 내용을 가져옴(merge)
$ git merge PR 상대방_ID/feature

# 확인이 끝나면, 확인 목적으로 생성한 branch 제거
$ git branch -D for_check
Deleted branch for_check

# 합칠 branch로 변경
$ git checout master
Switched to branch 'master'

# 변경한 branch에 상대방이 수정한 내용을 merge
$ git merge PR 상대방_ID/feature

# push하기 전에 마지막 내용 점검
$ git diff origin/master

$ git push
```

<br>

## Git Flow<br>
#### 브랜치 목록<br>
* master 브랜치<br>
  * master 브랜치는 소프트웨어를 언제든지 실행할 수 있는 상태의 브랜치를 나타내며, 개발자가 직접 master 브랜치의 코드를 변경하거나 commit 해서는 안 된다.
  * master 브랜치는 배포 가능한 상태까지 개발된 코드가 merge 되는 곳이기 때문에 일반적으로 merge는 배포 바로 직전에만 이루어지며, merge가 될 때 버전 태그 정보를 추가한다.<br>
* develop 브랜치<br>
  * develop 브랜치는 개발 중인 코드의 중심이 되는 브랜치를 나타내며, 개발자가 직접 develop 브랜치의 코드를 변경하거나 commit 해서는 안 된다.
  * 코드를 수정하고 싶을 때는 develop 브랜치를 중심으로 새로운 feature 브랜치를 생성해야 하며, 만들어진 feature 브랜치를 기반으로 기능 추가와 코드 수정이 이루어진다.
  * feature 브랜치에서 개발이 끝나면 develop 브랜치에 merge를 수행한다.<br>
  * **[TIP] 매번 Pull Request를 보낼 때, master 브랜치를 develop 브랜치로 수동 변경하는 것은 실수를 유발할 가능성이 있으므로, Github repository 설정에서 develop 브랜치를 기본 브랜치로 변경하는 것이 좋다.**<br>
  * **[TIP] 항상 develop 브랜치에서 새로운 feature 브랜치를 작성할 때는 develop 브랜치를 최신 상태로 유지하고 브랜치를 생성해야 한다.**<br>
* feature 브랜치<br>
  * feature 브랜치는 develop 브랜치에서 파생된 브랜치로서, 개발자는 이 브랜치에서 코드를 직접 수정하게 된다.
  * feature 브랜치의 이름은 master, develop, release, hotfix 등을 제외한 어떤 이름이든 가능하며, develop 브랜치에 병합시킬 때 --no-ff 옵션을 주어 병합된 히스토리를 기록하는 것이 좋다.<br>
  * feature 브랜치 이름은 보통 feature-* 또는 feature/* 과 같이 지정한다.<br>
* release 브랜치<br>
  * release 브랜치는 릴리즈를 준비하기 위한 브랜치이다. <br>
  * 지금까지 개발한 기능들을 develop 브랜치로부터 release 브랜치를 만들고, release 브랜치에서는 발견되는 버그들을 수정하며 릴리즈를 준비하면서 develop 브랜치에서는 다음 릴리즈를 위한 개발을 진행한다.<br>
  * release
  * 만약 릴리즈 준비가 완료되었다면 master 브랜치에 병합하며, 수정된 버그를 적용하기 위해 develop 브랜치에도 병합한다. <br>
  * release 브랜치의 이름은 보통 release-* 또는 release/* 과같이 지정한다.<br>
* hotfix 브랜치<br>
  * hotfix 브랜치는 릴리즈된 프로그램에서 발생한 버그들을 수정하기 위한 브랜치이므로, hotfix 브랜치는 master 브랜치로부터 파생되며 수정한 버그들을 적용하기 위해 master와 develop 브랜치 모두에 병합된다. <br>
  * hotfix 브랜치는 취약점이 있는 버그가 발견되어 빠른 대응이 필요한 경우, 차기 버전까지 기다릴 수 없는 경우 사용한다.<br>
  * 만약 release 브랜치가 존재한다면 release 브랜치에도 hotfix 브랜치를 병합하여 다음 릴리즈때 내용이 적용되도록 해야 한다. <br>
  * hotfix 브랜치의 이름 역시 hotfix-*, hotfix/* 과 같이 지정한다.<br>

<br>

#### Git Flow 수행 절차<br>
1. develop 브랜치에서 feature 브랜치를 생성함<br>
```bash
# develop 브랜치에서부터 시작

# git flow를 처음 시작하는 경우 1. git flow에 사용되는 브랜치들의 이름을 사용자가 직접 지정하고자 하는 경우
$ git flow init
# git flow를 처음 시작하는 경우 2. 초기 설정을 최소화하고 싶은 경우(Master, Develop 기본 생성)
$ git flow init -d
# git flow를 이미 사용 중일 경우 develop 브랜치를 최신 상태로 설정
# (다른 사람과 프로젝트를 같이 하는 경우 develop 브랜치가 변경되었을 수도 있기 때문)
$ git pull
Already up-to-date.

# 만약 '사용자 추가 기능'을 구현하고자 할 때
$ git flow feature start add-user
Switched to a new branch 'feature/add-user'

Summary of actions:
- A new branch 'feature/add-user' was created, based on 'develop'
- You are now on branch 'feature/add-user'

Now, start committing on your feature. When doen, use:
  git flow feature finish add-user

$ git branch
  develop
* feature/add-user
  master

# remote repo.에 feature/add-user 브랜치 추가
$ git push origin feature/add-user
# 이미 feature/add-user 브랜치가 remote repo.에 추가되어 있고, 다른 개발자가 해당 브랜치에서 작업중인 경우
$ git pull origin feature/add-user
```
2. feature 브랜치에서 기능 구현<br>
3. Github로 feature 브랜치에서 develop 브랜치로 Pull Request를 보냄<br>
  **이때 브랜치를 feature/add-user로 변경해주어야 하며,** Pull Request를 전송한 다음 다음과 같은 절차를 따라 코드 점검 및 수정할 것<br>
    1. 다른 개발자가 코드 리뷰를 하고 피드백<br>
    2. 피드백 기반으로 코드를 수정(자신의 feature/add-user 브랜치에서 수정할 것)<br>
    3. feature/add-user 브랜치를 push(이때 이전 Pull Request에 자동으로 추가됨)<br>
    4. 문제가 해결될 때까지 1번부터 3번까지의 과정 반복<br>
    5. 문제가 모두 해결되었다면 다른 개발자가 develop 브랜치에 merge<br>
  * **만약 다른 사람에게 코드 리뷰를 받지 않을 경우 또는 혼자 프로젝트를 진행하는 경우에는 git flow feature finish BRANCH_NAME 을 입력해도 된다. 이 명령은 아래의 절차를 거쳐 동작한다.**<br>
    1. git flow는 develop branch로 checkout<br>
    2. feature branch의 변경 내용을 자동으로 develop branch에 merge<br>
    3. 작업이 끝난 feature branch를 삭제<br>

4. 다른 개발자의 리뷰를 받고 develop 브랜치에 Pull Request를 merge함<br>
  피드백 시 다음과 같은 사항들을 중심으로 할 것(만약 이런 부분이 발견된다면, 바로 merge를 하지 말고 피드백을 주어 수정할 것<br>
    * 테스트 코드가 없거나 테스트가 실패했다.<br>
    * 코딩 규칙을 위반하고 있다.<br>
    * 코드가 더럽다(식별자가 이상하다, 메소드가 너무 길다 등.)<br>
    * 리팩토링 하면 더 좋아질 것 같다.<br>
    * 중복된 코드가 있다.<br>
5. 로컬 develop 브랜치 갱신<br>
develop 브랜치에 merge된 feature 브랜치는 필요가 없어지므로, 적절한 시점에 제거해도 됨<br>
```bash
# 1. develop 브랜치 이동
$ git checkout develop
Switched to branch 'develop'

# 2. git pull(fetch & merge) 수행
$ git pull
```

6. release 브랜치 생성<br>
```bash
# develop 브랜치로 이동
$ git checkout develop
Switched to branch 'develop'

# 최신 develop 브랜치 가져옴
$ git pull
Already up-to-date.

# release 브랜치 생성
$ git flow release start '1.0.0'
Switched to a new branch 'release/1.0.0'

Summary of actions:
- A new branch 'release/1.0.0' was created, based on 'develop'
- You are now on branch 'release/1.0.0'

Follow-up actions:
- Bump the version number now!
- Start committing last-minute fixes in preparing your release
- When done, run:
  git flow release finish '1.0.0'
```
7. 배포와 merge 수행<br>
```bash
# 모든 사항을 수정하고 commit까지 완료하였을 경우 해당 release 브랜치를 종료
$ git flow release finish '1.0.0'
Switched to branch 'master'

...
#   1. master 브랜치로 merge됨
#   2. tag 발행
#   3. develop 브랜치로 merge됨
...

Summary of actions:
- Latest objects have been fetched from 'origin'
- Release branch has been merged into 'master'
- The release was tagged '1.0.0'
- Release branch has been back-merged into 'develop'
- Release branch 'release/1.0.0' has been deleted

# 버전 태그 확인
$ git tab
1.0.0
```
8. 원격 repo. 반영<br>
```bash
# develop 브랜치 반영
$ git push origin develop

# master 브랜치 반영
$ git checkout master
$ git push origin master

# tag 정보 push
$ git push --tags
```
9. hotfix(취약점 수정)<br>
```bash
# 최신 상태 가져옴
$ git fetch origin

# 1.0.0 태그를 기반으로 1.0.1 hotfix 브랜치 생성
$ git flow hotfix start '1.0.1' '1.0.0'
Switched to a new branch 'hotfix/1.0.1'

Summary of actions:
- A new branch 'hotfix/1.0.1' was created, based on '1.0.0'
- You are now on branch 'hotfix/1.0.1'

# 해당 브랜치에서 취약점 관련 작업을 수행하면서 commit
# 수정이 완료되면 hotfix 브랜치를 remote repo.에 push 후 master 브랜치에 Pull Request 및 merge
$ git push origin hotfix/1.0.1
```
  * **만약 다른 사람에게 코드 리뷰를 받지 않을 경우 또는 혼자 프로젝트를 진행하는 경우에는 git flow hotfix finish VERSION 을 입력해도 된다. 이 명령은 'develop' 및 'master' 브랜치로 병합되며, 추가적으로 'master'의 병합 대상은 hotfix 버전으로 태그된다.**<br>

10. 태그 작성과 배포<br>
    1. 저장소로 이동하여 Releases 클릭<br>
![Git flow](https://raw.githubusercontent.com/RyanJeong/ryanjeong.github.io/master/img/gist/47867bbacce197e8e7b76f17ae7e434d/release1.png)<br>
    2. Create a new release를 클릭하여 Release 생성 페이지로 이동<br>
![Git flow](https://raw.githubusercontent.com/RyanJeong/ryanjeong.github.io/master/img/gist/47867bbacce197e8e7b76f17ae7e434d/release2.png)<br>
    3. Tag version에는 '1.0.1'을 입력하고, Target에는 hotfix 1.0.1 변경이 적용되는 master 브랜치를 지정<br>
    4. Release title과 Describe this release에는 입력하지 않아도 되지만, 필요에 따라 간단한 정보 입력<br>
![Git flow](https://raw.githubusercontent.com/RyanJeong/ryanjeong.github.io/master/img/gist/47867bbacce197e8e7b76f17ae7e434d/release3.png)<br>
    5. 필요하다면 위 사진과 같이 컴파일된 프로그램 같은 바이너리 파일을 드래그하여 같이 Release 할 수 있음<br>
    6. 작성을 완료했다면 Publish release 버튼을 눌러 태그 작성<br>
<br>

```bash
# 태그 작성한 내용을 가져옴
$ git fetch origin

$ git tag
1.0.0
1.0.1
```
11. hotfix 브랜치에서 develop 브랜치로 merge<br>
  * Github 홈페이지에서 hotfix/1.0.1로 브랜치를 변경한 후 develop 브랜치로 Pull Request를 요청<br>
  * 검토가 끝나면 merge<br>
  * **만약 hotfix 브랜치를 merge한 이후 develop 브랜치에서 문제가 발생한다면 hotfix 브랜치는 그대로 두고, develop 브랜치를 수정할 것**<br>
  * **또한 hotfix 브랜치는 master 브랜치에서 발생한 문제만 해결할 것(hotfix 이외의 내용까지 수정하게 되면 hotfix가 꼬일 위험이 있음)**<br>
  * develop 브랜치에 성공적으로 병합되었으면, hotfix 브랜치는 더 이상 필요가 없어지므로, 적절한 시기에 삭제<br>

![Git flow](https://raw.githubusercontent.com/RyanJeong/ryanjeong.github.io/master/img/gist/47867bbacce197e8e7b76f17ae7e434d/flow.png)<br>
#### 버전 번호 붙이기<br>
* 소프트웨어의 버전을 높일 때는 누구나 납득할 수 있는 형태로 버전을 올려야 함<br>
* 예를 들어, x.y.z 형태인 세 개의 숫자로 버전을 관리할 경우, 다음과 같은 규칙을 사용함<br>
1. x는 큰 기능 변경 또는 하위 호환이 불가능한 경우에 증가한다.<br>
x가 증가할 때는 y와 z를 0으로 변경한다.
2. y는 새로운 기능 추가 또는 기존 기능을 추가할 때 증가한다.<br>
y가 증가할 때는 z를 0으로 변경한다.<br>
3. z는 내부적인 변경이 있는 경우 증가한다.<br>
* 예는 아래와 같음<br>
> 1.0.0: 초기 배포<br>
1.0.1: 작은 버그 수정<br>
1.0.2: 취약점 수정<br>
1.1.0: 새로운 기능 추가<br>
2.0.0: UI 전체 변경과 새로운 기능 추가<br>
<br>

## Fork한 코드 최신 상태 유지 방법<br>
#### 원본 내용(source remote repo.)와 clone한 내용(remote repo.)의 내용은 시간이 지남에 따라 점차 차이가 발생하므로, 최신화가 필요함<br>
1. Fork한 repo.를 local로 clone<br>
이때 fork한 repo.의 주소를 target이라고 가정함<br>
2. Local repo. 에서 git fetch target 입력<br>
3. Local repo. 에서 git merge target/master를 입력<br>

<br>

## 이슈(Issue) 기반 버전 관리 워크플로우<br>
1. 새로운 이슈를 열고 이슈번호(#no)를 확인한다.<br>
2. Local repo.에 새로운 브랜치를 생성한다. 형식은 “이슈번호-설명”.<br>
(example. 78-fix_query_bugs)<br>
3. 이슈에 적어둔 목표를 해결한다. <br>
**(오직! 이슈에 적힌 내용만 작업한다. 특히 개인 프로젝트가 아닐 경우 다른 사람에게 혼동을 야기할 수 있음)**<br>
4. 테스트하여 작업이 제대로 완료됐는지 확인한다.<br>
(사용자가 수동으로 테스트할 수도 있지만, 일반적으로 Travis 또는 Jenkins을 사용함)<br>
5. 테스트 결과 이상이 없을 경우 수정 사항을 커밋하고 푸시한다.<br>
**(github이 커밋을 추적할 수 있도록 커밋 메시지 안에 이슈 번호를 적어야 한다)**<br>
6. 작업이 잘 완료됐다면 작업 브랜치를 메인 브랜치에 병합(merge)한다.<br>
7. 이슈에 모든 내용이 잘 기록됐는지 확인하고 이슈를 닫는다.<br>

출처: [github 하나로 1인 개발 워크플로우 완성하기: 실전 편](https://www.huskyhoochu.com/issue-based-version-control-201)<br>

<br>

## CI Tools<br>
#### 대표적인 CI Tool로는 Travis와 Jenkins가 있음
> **Which is better?**<br>
Thus, with the above discussion, we can get ay that Travis and Jenkins both offer wonderful features. However, small open source projects are best suited for Travis CI as it is easy to run and quick to set up. On the other hand, large enterprise is best suited to Jenkins as it offers free licensing for a private project and a wide range of customizable feature. So, we can say that both of these continuous integration tools are good in their way.<br>
* 요약하자면, 소규모 오픈소스 프로젝트엔 Travis CI가 적합하고, 대형 엔터프라이즈 프로젝트엔 Jenkins가 적합함<br>
**(Travis CI 무료 버전은 클라우드 상에 코드가 모두 공개되므로 만약 비공개 프로젝트를 진행하는 경우라면 비적합, 유료 버전을 사용할 것)**<br>

출처: [Jenkins vs Travis-CI: What is the difference?](https://www.guru99.com/jenkins-vs-travis.html#8)<br>

<br>

## Github Enterprise<br>
* 회사 내부에 소스코드를 저장할 수 있으며, 깃허브와는 독립적인 서버 운용 가능<br>
* 소스코드가 외부로 유출되는 것을 꺼린다면 내부에 github enterprise를 사용하여 private server를 운용할 것<br>
* 대표적인 무료 오픈소스 소프트웨어: GitBucket GitLab Gitrious RhodeCode 등이 있음<br>
(무료 오픈소스 소프트웨어는 20명 내외가 사용하기 적합)<br>
1. Github: Git 호스팅 서비스 선두주자 오픈소스의 본고장이라 가장 많은 사람들이 이용함.<br>
장점: 가장 많은 Integration을 지원하며 가장 많은 오픈소스 저장소를 보유하고 있음. 또한 가장 안정적인 서버 상태를 제공하며, Github Status에서 실시간으로 확인 가능.<br>
단점: 무료 플랜의 경우 Repo.를 무조건 공개해야 하며, 용량 제한이 있음. LFS(Large File Storage)는 트래픽 제한도 있음.<br>

2. Bitbucket: Git을 사용하는 사람들에게 가장 익숙할 GUI 툴인 Sourcetree를 만든 Atlassian에서 제공하는 서비스.<br>
장점: JIRA, Hipchat과 연동이 편하고, Private Repo. 무료 제공.<br>
단점: 용량 제한이 있으며, 저장소에 참여 가능한 인원을 기준으로 가격 정책을 적용.<br>

3. Gitlab: 본질은 설치형이지만, Gitlab.com에서 호스팅 서비스 또한 제공함.<br>
장점: 가장 합리적인 가격 정책. Private Repo. 무료 사용 가능하며, 인원 제한 없음. Disk space per Repo가 10GB(LFS 용량 포함). 무료지만 대부분의 필요한 기능은 다 제공하며, CI가 잘 되어 있음.<br>
단점: 서버 상태가 가끔씩 불안정함.<br>

|          | 비공개 저장소 | 멤버 제한 | 설치형 서버 | 저장소 당 용량 | LFS 지원 |
| :------: | :--------: | :-----: | :-------: | :---------: | :-----: |
| Github | 유료 | 무료 | 유료 | 1 GB | 지원(트래픽 제한) |
| Bitbucket | 무료 | 유료 | 유료 | 1 GB | 지원 |
| Gitlab | 무료 | 무료 | 무료 | 10GB(LFS 포함) | 지원 |

#### 결론: Gitlab 사용하자.<br>

<br>