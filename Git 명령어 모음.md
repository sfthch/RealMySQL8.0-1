```
---------------------
-- Git 명령어 모음 --
---------------------

git config --global user.name 계정명
  - git 계정명 등록
git config --global user.email 이메일
  - git 이메일 등록

git config --global core.editor 에디터
  - git editor 변경
  - vi로 변경 > git config --global core.editor vi
  - vscode로 변경 > git config --global core.editor "code --wait"
  p.s.) vscode를 설치했을 경우 code . 명령어로 vscode 실행 가능

git config --global init.defaultBranch main
  - 로칼 저장소 default branch main으로 변경 (Git 2.28부터)

git init
  - 현재 디렉토리를 git local repository[Working Directory]로 지정(생성)
  - ls -al 명령어로 .git 숨김파일 생성 확인
  - rm -rf .git 명령어로 local repository 삭제

git diff
  - local repository[Working Directory]와 [Staging Area]의 차이를 보여줌
git status
  - 파일 상태 확인(staged, untracked, ..)

git add 파일명
  - 해당 파일을 [Staging Area]로 이동(tracking)
git add .
  - 현재 폴더의 전체 파일을 이동

git commit
  - [Staging Area]에 있는 파일을 원격저장소[Repository]로 커밋
  - 옵션없이 해당 명령어만 입력할 경우 editor 호출
git commit -m "커밋메세지"
  - editor 호출없이 바로 커밋
git commit -am "커밋메세지"
  - [Staging Area]에 올림과 동시에 커밋(= git add .+ git commit -m "커밋메세지")
  - 단, 1번이라도 커밋된 대상만 사용 가능

git log -n3
  - commit 로그 3개 확인
git log --all --decorate --oneline --graph
  - 전체 로그 현황 보기

git reset -hard
  - 바로 이전커밋으로 다시 설정하기
git reset -hard 로그커밋명
  - 과거의 커밋으로 다시 설정하기

git revert 로그커밋명
  - 과거의 커밋을 되돌리기
git revert --continue
  - 중복해결후 계속진행
git revert --no-commit 로그커밋명

git branch
  - 브랜치 목록 조회(현재 속한 브랜치는 앞에 *가 붙음)
git branch -a
git branch -all
  - 로칼과 원격의 브랜치들 확인
git branch 브랜치명
  - 브랜치명으로 브랜치 생성
git switch 브랜치명
  - 브랜치명으로 이동
git switch -c 브랜치명
  - 브랜치 생성 후 switch(= git branch 브랜치명 + git switch 브랜치명)
git branch -d 브랜치명
  - 브랜치명 브랜치 삭제
git branch -m 과거브랜치명 바꿀브랜치명
  - 브랜치명 바꾸기

git merge sub1
  - main으로 합치기 (main으로 이동후)
  - 합친후 sub1 삭제
  - git merge --abort : 중단

git switch sub1
git rebase main
  - main으로 재설정
  - git rebase --abort : 중단
  - git rebase --continue : 계속
git switch main
git merge  sub1
git branch -d sub1


git remote add realmysql 저장소URL
  - 저장소URL의 원격저장소를 저장소이름으로 추가
git branch -M main
  - 기본 브랜치명을 main으로
git push -u realmysql main
  - 기본 원격저장소 설정

git push
  - 원격저장소[Repository]에 local repository[Working Directory]의 commit 내용을 올림
  - git push --force : 로컬의 내역 강제 push
  - git push realmysql --delete sub1 : 원격브랜치 삭제

git pull
  - 원격저장소[Repository]의 내용을 가져와서(fetch) local repository[Working Directory]에 합침(merge)
  - git pull --rebase (rebase)
  - git pull --no-rebase (merge)

git clone 저장소URL
  - 저장소URL의 원격저장소를 복사하여 추가(remote add 명령 필요없음)

git fetch
  - 원격에만 적용되 내용을 로컬과 동기화
  - 원격저장소[Repository]의 내용을 local repository[Working Directory]로 가져옴
  - git checkout 원격저장소명/로컬브랜치명 OR git checkout FETCH_HEAD =가져온 fetch 내용 확인
git switch -t 원격신규브랜치명
  - 원격신규브랜치명 계속해서 원격과 로컬을 연결해서 관리


[최초 설정]

git config --global user.name 계정명
  - git 계정명 등록
git config --global user.email 이메일
  - git 이메일 등록
git config --list
  - git 설정정보 조회
git config --global core.editor 에디터
  - git editor 변경
  - vi로 변경 > git config --global core.editor vi
  - vscode로 변경 > git config --global core.editor "code --wait"
  p.s.) vscode를 설치했을 경우 code . 명령어로 vscode 실행 가능
git config --global -e
  - git config에 설정한 editor로 config 파일 열기
  p.s.) vscode를 diff tool OR merge tool로 이용하고 싶을 경우 config에 추가
git config --global alias.줄일명령어 원본명령어
  - 명령어 alias 등록
  e.g.) git config --global alias.sts status == git sts

[기본]

git --version

git init
  - 현재 디렉토리를 git local repository[Working Directory]로 지정(생성)
  - ls -al 명령어로 .git 숨김파일 생성 확인
  - rm -rf .git 명령어로 local repository 삭제
git status
  - 파일 상태 확인(staged, untracked, ..)
git add 파일명
  - 해당 파일을 [Staging Area]로 이동(tracking)
git add .
  -현재 폴더의 전체 파일을 이동
git commit
  - [Staging Area]에 있는 파일을 원격저장소[Repository]로 커밋
  - 옵션없이 해당 명령어만 입력할 경우 editor 호출
git commit -m "커밋메세지"
  - editor 호출없이 바로 커밋
git commit -am "커밋메세지"
  - [Staging Area]에 올림과 동시에 커밋(= git add .+ git commit -m "커밋메세지")
  - 단, 1번이라도 커밋된 대상만 사용 가능
git diff
  - local repository[Working Directory]와 [Staging Area]의 차이를 보여줌
git log
  - commit 로그 확인

[브랜치]

git branch
  - 브랜치 목록 조회(현재 속한 브랜치는 앞에 *가 붙음)
git branch 브랜치명
  - 브랜치명으로 브랜치 생성
  - 단, main 브랜치에 1번 이상 commit 해야함
git branch checkout 브랜치명
  - 해당 브랜치로 local repository[Working Directory] 변경
git branch -b 브랜치명
  - 브랜치 생성 후 checkout(= git branch 브랜치명 + git branch checkout 브랜치명)
git branch -d 브랜치명
  - 브랜치명 브랜치 삭제
git branch -D 브랜치명
  - 병합하지 않은 브랜치를 강제로 삭제
git branch merge 브랜치명
  - 현재 checkout된 브랜치로 브랜치명의 브랜치 합침

[깃허브]

git remote
  - git 원격저장소[Repository] 목록 확인
git remote -v
  - git 원격저장소 이름과 url 목록 확인
git remote add 저장소이름 저장소URL
  - 저장소URL의 원격저장소를 저장소이름으로 추가
git remote rm 저장소이름
  - 저장소이름의 원격저장소 제거
git pull
  - 원격저장소[Repository]의 내용을 가져와서(fetch) local repository[Working Directory]에 합침(merge)
git push
  - 원격저장소[Repository]에 local repository[Working Directory]의 commit 내용을 올림
git push -u 원격저장소명 로컬브랜치명
  - 로컬브랜치명의 commit 내용을 원격저장소로 올림
  - -u 옵션을 사용할 경우 해당 원격저장소와 브랜치가 default로 지정되어 git push 명령어만 입력 가능
git fetch
  - 원격저장소[Repository]의 내용을 local repository[Working Directory]로 가져옴
  - git checkout 원격저장소명/로컬브랜치명 OR git checkout FETCH_HEAD =가져온 fetch 내용 확인
git clone 저장소URL
  - 저장소URL의 원격저장소를 복사하여 추가(remote add 명령 필요없음)

[되돌리기]

git reset -hard 로그커밋명
  - 과거로 되돌리기

git stash
  - 임시로 변경사항 저장
git stash pop
  - 임시 저장한 내용을 가져오기
git stash list
  - 임시 저장 목록

```