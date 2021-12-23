```
---------------------
-- Git 명령어 모음 --
---------------------

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



git clone git_path
  : 코드가져오기

git checkout -t remote_path/branch_name
  : 원격 브랜치 선택하기

git branch -m branch_name change_branch_name
  : 브랜치 이름 바꾸기
git push remote_name — delete branch_name
  : 원격 브랜치 삭제하기 ( git push origin — delete gh-pages )

git pull
  : git서버에서 최신 코드 받아와 merge 하기
git fetch
  : git서버에서 최신 코드 받아오기

git reset —- hard HEAD^
  : commit한 이전 코드 취소하기
git reset —- soft HEAD^
  : 코드는 살리고 commit만 취소하기
git reset —- merge
  : merge 취소하기
git reset —- hard HEAD && git pull
  : git 코드 강제로 모두 받아오기

git stash / git stash save “description”
  : 작업코드 임시저장하고 브랜치 바꾸기
git stash pop
  : 마지막으로 임시저장한 작업코드 가져오기

git branch —- set-upstream-to=remote_path/branch_name
  : git pull no tracking info 에러해결

git rm
  : 원격 저장소와 로컬 저장소에 있는 파일을 삭제한다.
git rm --cached
  : 원격 저장소에 있는 파일을 삭제한다. 로컬 저장소에 있는 파일은 삭제하지 않는다.



출처: https://mygumi.tistory.com/103 [마이구미의 HelloWorld]

```