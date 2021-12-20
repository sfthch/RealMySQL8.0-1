Git ��ɾ� ����

[���� ����]

git config --global user.name ������
  - git ������ ���
git config --global user.email �̸���
  - git �̸��� ���
git config --list
  - git �������� ��ȸ
git config --global core.editor ������
  - git editor ����
  - vi�� ���� > git config --global core.editor vi
  - vscode�� ���� > git config --global core.editor "code --wait"
  p.s.) vscode�� ��ġ���� ��� code . ��ɾ�� vscode ���� ����
git config --global -e
  - git config�� ������ editor�� config ���� ����
  p.s.) vscode�� diff tool OR merge tool�� �̿��ϰ� ���� ��� config�� �߰�
git config --global alias.���ϸ�ɾ� ������ɾ�
  - ��ɾ� alias ���
  e.g.) git config --global alias.sts status == git sts

[�⺻]

git init
  - ���� ���丮�� git local repository[Working Directory]�� ����(����)
  - ls -al ��ɾ�� .git �������� ���� Ȯ��
  - rm -rf .git ��ɾ�� local repository ����
git status
  - ���� ���� Ȯ��(staged, untracked, ..)
git add ���ϸ�
  - �ش� ������ [Staging Area]�� �̵�(tracking)
git add .
  -���� ������ ��ü ������ �̵�
git commit
  - [Staging Area]�� �ִ� ������ ���������[Repository]�� Ŀ��
  - �ɼǾ��� �ش� ��ɾ �Է��� ��� editor ȣ��
git commit -m "Ŀ�Ը޼���"
  - editor ȣ����� �ٷ� Ŀ��
git commit -am "Ŀ�Ը޼���"
  - [Staging Area]�� �ø��� ���ÿ� Ŀ��(= git add .+ git commit -m "Ŀ�Ը޼���")
  - ��, 1���̶� Ŀ�Ե� ��� ��� ����
git diff
  - local repository[Working Directory]�� [Staging Area]�� ���̸� ������
git log
  - commit �α� Ȯ��

[�귣ġ]

git branch
  - �귣ġ ��� ��ȸ(���� ���� �귣ġ�� �տ� *�� ����)
git branch �귣ġ��
  - �귣ġ������ �귣ġ ����
  - ��, main �귣ġ�� 1�� �̻� commit �ؾ���
git branch checkout �귣ġ��
  - �ش� �귣ġ�� local repository[Working Directory] ����
git branch -b �귣ġ��
  - �귣ġ ���� �� checkout(= git branch �귣ġ�� + git branch checkout �귣ġ��)
git branch -d �귣ġ��
  - �귣ġ�� �귣ġ ����
git branch merge �귣ġ��
  - ���� checkout�� �귣ġ�� �귣ġ���� �귣ġ ��ħ

[�����]

git remote
  - git ���������[Repository] ��� Ȯ��
git remote -v
  - git ��������� �̸��� url ��� Ȯ��
git remote add ������̸� �����URL 
  - �����URL�� ��������Ҹ� ������̸����� �߰�
git remote rm ������̸�
  - ������̸��� ��������� ����
git pull
  - ���������[Repository]�� ������ �����ͼ�(fetch) local repository[Working Directory]�� ��ħ(merge)
git push
  - ���������[Repository]�� local repository[Working Directory]�� commit ������ �ø�
git push -u ��������Ҹ� ���ú귣ġ��
  - ���ú귣ġ���� commit ������ ��������ҷ� �ø�
  - -u �ɼ��� ����� ��� �ش� ��������ҿ� �귣ġ�� default�� �����Ǿ� git push ��ɾ �Է� ����
git fetch
  - ���������[Repository]�� ������ local repository[Working Directory]�� ������
  - git checkout ��������Ҹ�/���ú귣ġ�� OR git checkout FETCH_HEAD =������ fetch ���� Ȯ��
git clone �����URL
  - �����URL�� ��������Ҹ� �����Ͽ� �߰�(remote add ��� �ʿ����)
