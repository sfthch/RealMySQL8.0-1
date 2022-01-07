```
이번 장에서는 MySQL의 동시성에 영향을 미치는 잠금(Lock)과 트랜잭션, 트랜잭션의 격리 수준(Isolation level)을 살펴보겠다.

트랜잭션은 작업의 완전성을 보장해 주는 것이다.
즉 논리적인 작업 셋을 모두 완벽하게 처리하거나,
처리하지 못할 경우에는 원 상태로 복구해서 작업의 일부만 적용되는 현상(Parial update)이 발생하지 않게 만들어주는 기능이다.

잠금(Lock)과 트랜잭션은 서로 비슷한 개념 같지만 사실 잠금은 동시성을 제어하기 위한 기능이고
트랜잭션은 데이터의 정합성을 보장하기 위한 기능이다.
하나의 회원 정보 레코드를 여러 커넥션에서 동시에 변경하려고 하는데 잠금이 없다면 하나의 데이터를 여러 커넥션에서 동시에 변경할 수 있게 된다.
결과적으로 해당 레코드의 값은 예측할 수 없는 상태가 된다.
잠금은 여러 커넥션에서 동시에 동일한 자원(레코드나 테이블)을 요청할 경우
순서대로 한 시점에는 하나의 커넥션만 변경할 수 있게 해주는 역할을 한다.
격리 수준이라는 것은 하나의 트랜잭션 내에서 또는 여러 트랜잭션 간의 작업 내용을 어떻게 공유하고 차단할 것인지를 결정하는 레벨을 의미한다.


5.1 트랜잭션

  많은 사용자들이 데이터베이스 서버에서 트랜잭션이 개발자에게 얼마나 큰 혜택을 제공하는지를 자주 잊어버리는 것 같다.
  지금은 많이 달라졌지만 여전히 MySQL 서버에서는 MyISAM이나 MEMORY 스토리지 엔진이 더 빠르다고 생각하고
  InnoDB 스토리지 엔진은 사용하기 복잡하고 번거롭다고 생각하곤 한다.
  하지만 사실은 MyISAM이나 MEMORY 같이 트랜잭션을 지원하지 않는 스토리지 엔진의 테이블이 더 많은 고민거리를 만들어 낸다.

  이번 절에서는 트랜잭션을 지원하지 않는 MyISAM과 트랜잭션을 지원하는 InnoDB의 처리 방식 차이를 잠깐 살펴보고자 한다.
  그리고 트랜잭션을 사용할 경우 주의할 사항도 함께 살펴보겠다.

5.1.1 MySQL에서의 트랜잭션

  트랜잭션은 꼭 여러 개의 변경 작업을 수행하는 쿼리가 조합됐을 때만 의미 있는 개념은 아니다.
  트랜잭션은 하나의 논리적인 작업 셋에 하나의 쿼리가 있는 두 개 이상의 쿼리가 있는 관계없이 논리적인 작업 셋 자체가 100% 적용되거나
  (COMMIT을 실행했을 때) 아무것도 적용되지 않아야(ROLLBACK 또는 트랜잭션을 ROLLBACK시키는 오류가 발생했을 때) 함을 보장해 주는 것이다.

  간단한 예제로 트랜잭션 관점에서 InnoDB 테이블과 MyISAM 테이블의 차이를 살펴보자.

  mysql> CREATE TABLE tab_myisam ( fdpk INT NOT NULL, PRIMARY KEY (fdpk) ) ENGINE=MyISAM;
  mysql> INSERT INTO tab_myisam (fdpk) VALUES (3);

  mysql> CREATE TABLE tab_innodb ( fdpk INT NOT NULL, PRIMARY KEY (fdpk) ) ENGINE=INNODB;
  mysql> INSERT INTO tab_innodb (fdpk) VALUES (3);

  위와 같이 테스트용 테이블에 각각 레코드를 1건씩 저장한 후 AUTO-COMMIT 모드에서
  다음 쿼리 문장을 InnoDB 테이블과 MyISAM 테이블에서 각각 실행해 보자.

  // AUTO-COMMIT 활성화
  mysql> SET autocommit=ON;

  mysql> SHOW VARIABLES LIKE '%autocommit%';
         +---------------+-------+
         | Variable_name | Value |
         +---------------+-------+
         | autocommit    | ON    |
         +---------------+-------+

  mysql> INSERT INTO tab_myisam (fdpk) VALUES (1),(2),(3);
  mysql> INSERT INTO tab_innodb (fdpk) VALUES (1),(2),(3);

  두 개의 스토리지 엔진에서 결과가 어떻게 다를까? 위 쿼리 문장의 테스트 결과는 다음과 같다.

  mysql> INSERT INTO tab_myisam (fdpk) VALUES (1),(2),(3);
         ERROR 1062 (23000): Duplicate entry '3' for key 'PRIMARY'

  mysql> INSERT INTO tab_innodb (fdpk) VALUES (1),(2),(3);
         ERROR 1062 (23000): Duplicate entry '3' for key 'PRIMARY'

  mysql> SELECT * FROM tab_myisam;
         +------+
         | fdpk |
         +------+
         |    1 |
         |    2 |
         |    3 |
         +------+

  mysql> SELECT * FROM tab_innodb;
         +------+
         | fdpk |
         +------+
         |    3 |
         +------+

  두 INSERT 문장 모두 프라이머리 키 중복 오류로 쿼리가 실패했다.
  그런데 두 테이블의 레코드를 조회해 보면 MyISAM 테이블에는 오류가 발생했음에도 1'과 '2'는 INSERT된 상태로 남아 있는 것을 확인할 수 있다.
  즉, MyISAM 테이블에 INSERT 문장이 실행되면서 차례대로 '1'과 '2'를 저장하고,
  그다음에 '3'을 저장하려고 하는 순간 중복 키 오류(이미 '3'이 있기 때문)가 발생한 것이다.
  하지만 MyISAM 테이블에서 실행되는 쿼리는 이미 INSERT된 '1'과 '2'를 그대로 두고 쿼리 실행을 종료해 버린다.

  MEMORY' 스토리지 엔진을 사용하는 테이블도 MyISAM 테이블과 동일하게 작동한다.
  하지만 InnoDB는 쿼리 중 일부라도 오류가 발생하면 전체를 원 상태로 만든다는
  트랜잭션의 원칙대로 INSERT 문장을 실행하기 전 상태로 그대로 복구했다.
  MyISAM 테이블에서 발생하는 이러한 현상을 부분 업데이트(Purtial Update)라고 표현하며,
  이러한 부분 업데이트 현상은 테이블 데이터의 정합성을 맞추는데 상당히 어려운 문제를 만들어 낸다.

  어떤 사용자는 (특히 트랜잭션이 선택 사항인 MySQL의 경우) 트랜잭션을 상당히 골치 아픈 기능쯤으로 생각하지만
  트랜잭션이란 그만큼 애플리케이션 개발에서 고민해야 할 문제를 줄여주는 아주 필수적인 DBMS의 기능이라는 점을 기억해야 한다.
  부분 업데이트 현상이 발생하면 실패한 쿼리로 인해 남은 레코드를 다시 삭제하는 재처리 작업이 필요할 수 있다.
  실행하는 쿼리가 하나뿐이라면 재처리 작업은 간단할 것이다.
  하지만 2개 이상의 쿼리가 실행되는 경우라면 실패에 대한 재처리 작업은 다음 예제와 같이 상당한 고민거리가 될 것이다.

  INSERT INTO tab_a...;
  IF(_is_insert1_succeed)
  {
    INSERT INTO tab_b...;
    IF(_is_insert2_succeed)
    {
      // 처리 완료
    } ELSE
    {
      DELETE FROM tab_a WHERE ...;
      IF(_is_delete_succeed)
      {
        // 처리 실패 및 tab_a, tab_b 모두 원상 복구 완료
      } ELSE
      {
        // 해결 불가능한 심각한 상황 발생
        // 이제 어떻게 해야 하나?
        // tab_b에 INSERT는 안 되고, 하지만 tab_a에는 INSERT돼 버렸는데, 삭제는 안 되고...
      }
    }
  }

  위 애플리케이션 코드가 장난처럼 작성한 코드 같지만 트랜잭션이 지원되지 않는 MyISAM에 레코를 INSERT할 때 위와 같이 하지 않으면 방법이 없다.
  코드를 이렇게 작성하지 않았다면 부분 업데이트의 결과로 쓰레기 데이터가 테이블에 남아 있을 가능성이 있다.
  하지만 위의 코드를 트랜잭션이 지원되는 InnoDB 테이블에서 처리한다고 가정하면 다음과 같은 간단한 코드로 완벽한 구현이 가능하다.
  얼마나 깔끔한 코드로 바뀌었는가!
  비즈니스 로직 처리로 이미 IF ... ELSE ... 로 가득찬 프로그램 코드에 이런 데이터 클렌징 코드까지 넣어야 한다는 것은 정말 암담한 일일 것이다.

  try
  {
    START TRANSACTION;
    INSERT INTO tab_a ...;
    INSERT INTO tab_b ...;
    COMMIT;
  } catch(exception)
  {
    ROLLBACK;
  }

5.1.2 주의사항

  트랜잭션 또한 DBMS의 커넥션과 동일하게 꼭 필요한 최소의 코드에만 적용하는 것이 좋다.
  이는 프로그램 코드에서 트랜잭션의 범위를 최소화하라는 의미다.
  다음 내용은 사용자가 게시판에 게시물을 작성한 후 저장 버튼을 클릭했을 때 서버에서 처리하는 내용을 순서대로 정리한 것이다.
  물론 실제로는 이 내용보다 훨씬 더 복잡하고 많은 내용이 있겠지만 여기서는 설명을 단순화하기 위해 조금 간단히 나열했다.

    1) 처리 시작
       => 데이터베이스 커넥션 생성
       => 트랜잭션 시작
    2) 사용자의 로그인 여부 확인
    3) 사용자의 글쓰기 내용의 오류 여부 확인
    4) 첨부로 업로드된 파일 확인 및 저장
    5) 사용자의 입력 내용을 DBMS에 저장
    6) 정부 파일 정보를 DBMS에 저장
    7) 저장된 내용 또는 기타 정보를 DBMS에서 조회
    8) 게시물 등록에 대한 알림 메일 발송
    9) 알림 메일 발송 이력을 DBMS에 저장
       <= 트랜잭션 종료(COMMIT)
       <= 데이터베이스 커넥션 반납
   10) 처리 완료

  위 처리 절차 중에서 DBMS의 트랜잭션 처리에 좋지 않은 영향을 미치는 부분을 나눠서 살펴보자.

    - 실제로 많은 개발자가 데이터베이스의 커넥션을 생성(또는 커넥션 풀에서 가져오는)하는 코드를 1번과 2번 사이에 구현하며
      그와 동시에 START TRANSACTION 명령으로 트랜잭션을 시작한다.
      그리고 9번과 10번 사이에서 트랜잭션을 COMMIT하고 커넥션을 종료(또는 커넥션 풀로 반납)한다.
      실제로 DBMS에 데이터를 저장하는 작업(트랜잭션)은 5번부터 시작된다는 것을 알 수 있다.
      그래서 2번과 3번, 4번의 절차가 아무리 빨리 처리된다고 하더라도 DBMS의 트랜잭션에 포함시킬 필요는 없다.
      일반적으로 데이터베이스 커넥션은 개수가 제한적이어서 각 단위 프로그램이 커넥션을 소유하는 시간이 길어질수록
      사용 가능한 여유 커넥션의 개수는 줄어들 것이다.
      그리고 어느 순간에는 각 단위 프로그램에서 커넥션을 가져가기 위해 기다려야 하는 상황이 발생할 수도 있다.
    - 더 큰 위험은 8번 작업이라고 볼 수 있다.
      메일 전송이나 FTP 파일 전송 작업 또는 네트워크를 통해 원격 서버와 통신하는 등과 같은 작업은
      어떻게 해서든 DBMS의 트랜잭션 내에서 제거하는 것이 좋다.
      프로그램이 실행되는 동안 메일 서버와 통신할 수 없는 상황이 발생한다면
      웹 서버뿐 아니라 DBMS 서버까지 위험해지는 상황이 발생할 것이다.
    - 또한 이 처리 절차에는 DBMS의 작업이 크게 4개가 있다.
      사용자가 입력한 정보를 저장하는 5번과 6번 작업은 반드시 하나의 트랜잭션으로 묶어야 하며,
      7번 작업은 저장된 데이터의 단순 확인 및 조회이므로 트랜잭션에 포함할 필요는 없다.
      그리고 9번 작업은 조금 성격이 다르기 때문에 이전 트랜잭션(5번과 6번 작업)에 함께 묶지 않아도 무방해 보인다
      (물론 업무 요건에 따라 달라질 수는 있겠지만).
      이러한 작업은 별도의 트랜잭션으로 분리하는 것이 좋다.
      그리고 7번 작업은 단순 조회라고 본다면 별도로 트랜잭션을 사용하지 않아도 무방해 보인다.

  문제가 될 만한 부분 세 가지를 보완해서 위의 처리 절차를 다시 한번 설계해보자.

    1) 처리 시작
    2) 사용자의 로그인 여부 확인
    3) 사용자의 글쓰기 내용의 오류 발생 여부 확인
    4) 첨부로 업로드된 파일 확인 및 저장
       => 데이터베이스 커넥션 생성(또는 커넥션 풀에서 가져오기)
       => 트랜잭션 시작
    5) 사용자의 입력 내용을 DBMS에 저장
    6) 첨부 파일 정보를 DBMS에 저장
       <= 트랜잭션 종료(COMMIT
    7) 저장된 내용 또는 기타 정보를 DBMS에서 조회
    8) 게시물 등록에 대한 알림 메일 발송
       => 트랜잭션 시작
    9) 알림 메일 발송 이력을 DBMS에 저장
       <= 트랜잭션 종료(COMMIT)
       <= 데이터베이스 커넥션 종료(또는 커넥션 풀에 반납)
   10) 처리 완료

  앞에서 보여준 예제가 최적의 트랜잭션 설계는 아닐 수 있으며,
  구현하고자 하는 업무의 특성에 따라 크게 달라질 수 있다.
  여기서 설명하려는 바는 프로그램의 코드가 데이터베이스 커넥션을 가지고 있는 범위와
  트랜잭션이 활성화돼 있는 프로그램의 범위를 최소화해야 한다는 것이다.
  또한 프로그램의 코드에서 라인 수는 한두 줄이라고 하더라도 네트워크 작업이 있는 경우에는 반드시 트랜잭션에서 배제해야 한다.
  이런 실수로 인해 DBMS 서버가 높은 부하 상태로 빠지거나 위험한 상태에 빠지는 경우가 빈번히 발생한다.


5.2 MySQL 엔진의 잠금

  MySQL에서 사용되는 잠금은 크게 스토리지 엔진 레벨과 MySQL 엔진 레벨로 나눌 수 있다.
  MySQL 엔진은 MySQL 서버에서 스토리지 엔진을 제외한 나머지 부분으로 이해하면 되는데,
  MySQL 엔진 레벨의 잠금은 모든 스토리지 엔진에 영향을 미치지만,
  스토리지 엔진 레벨의 잠금은 스토리지 엔진 간 상호 영향을 미치지는 않는다.
  MySQL 엔진에서는 테이블 데이터 동기화를 위한 테이블 락 이외에도 테이블의 구조를 잠그는 메타데이터 락(Metadata Lock)
  그리고 사용자의 필요에 맞게 사용할 수 있는 네임드 락(Named Lock)이라는 잠금 기능도 제공한다.
  이러한 잠금의 특징과 이러한 잠금이 어떤 경우에 사용되는지 한번 살펴보자.

5.2.1 글로벌 락

  글로벌 락(GLOBAL, LOCK)은 FLUSH TABLES WITH READ LOCK 명령으로 획득할 수 있으며,
  MySQL에서 제공하는 짐금 가운데 가장 범위가 크다.
  일단 한 세션에서 글로벌 락을 획득하면 다른 세션에서 SELECT를 제외한 대부분의 DDL 문장이나 DML 문장을 실행하는 경우
  글로벌 락이 해제될 때까지 해당 문장이 대기 상태로 남는다.
  글로벌 락이 영향을 미치는 범위는 MySQL 서버 전체이며, 작업 대상 테이블이나 데이터베이스가 다르더라도 동일하게 영향을 미친다.
  여러 데이터베이스에 존재하는 MyISAM이나 MEMORY 테이블에 대해 mysqldump로 일관된 백업을 받아야 할 때는 글로벌 락을 사용해야 한다.

  주의 : 글로벌 락을 거는 FLUSH TABLES WITH READ LOCK 명령은 실행과 동시에 MySQL 서버에 존재하는 모든 테이블을 닫고 잠금을 건다.
         FLUSH TABLES WITH READ LOCK 명령이 실행되기 전에 테이블이나 레코드에 쓰기 잠금을 거는 SQL이 실행됐다면
         이 명령은 해당 테이블의 읽기 잠금을 걸기 위해 먼저 실행된 SQL과 그 트랜잭션이 완료될 때까지 기다려야 한다.
         FLUSH TABLES WITH READ LOCK 명령은 테이블에 읽기 잠금을 걸기 전에 먼저 테이블을 플러시해야 하기 때문에
         테이블에 실행 중인 모든 종류의 쿼리가 완료돼야 한다.
         그래서 장시간 SELECT 쿼리가 실행되고 있때는 FLUSH TABLES WITH READ LOCK 명령은 SELECT 쿼리가 종료될 때까지 기다려야 한다.

         장시간 실행되는 쿼리와 FLUSH TABLES WITH READ LOCK 명령이 최악의 케이스로 실행되면
         MySQL 서버의 모든 테이블에 대한 INSERT, UPDATE, DELETE 쿼리가 아주 오랜 시간 동안 실행되지 못하고 기다릴 수도 있다.
         글로벌 락은 MySQL 서버의 모든 테이블에 큰 영향을 미치기 때문에
         웹 서비스용으로 사용되는 MySQL 서버에서는 가급적 사용하지 않는 것이 좋다.
         또한 mysqldump 같은 백업 프로그램은 우리가 알지 못하는 사이에 이 명령을 내부적으로 실행하고 백업할 때도 있다.
         mysqldump를 이용해 백업을 수행한다면 mysqldump에서 사용하는 옵션에 따라
         MySQL 서버에 어떤 잠금을 걸게 되는지 자세히 확인해보는 것이 좋다.

  이미 살펴본 바와 같이 FLUSH TABLES WITH READ LOCK 명령을 이용한 글로벌 락은 MySQL 서버의 모든 변경 작업을 멈춘다.
  하지만 MySQL 서버가 업그레이드면서 MyISAM이나 MEMORY 스토리지 엔진보다는 InnoDB 스토리지 엔진의 사용이 일반화됐다.
  InnoDB 스토리지 엔진은 트랜잭션을 지원하기 때문에 일관된 데이터 상태를 위해 모든 데이터 변경 작업을 멈출 필요는 없다.
  또한 MySQL 8.0부터는 InnoDB가 기본 스토리지 엔진으로 채택되면서 조금 더 가벼운 글로벌 락의 필요성이 생겼다.
  그래서 MySQL 8.0 버전부터는 Xtrabackup이나 Enterprise Backup과 같은 백업 툴들의 안정적인 실행을 위해 백업 락이 도입됐다.

  mysql> LOCK INSTANCE FOR BACKUP;
         -- // 백업 실행
  mysql> UNLOCK INSTANCE;

  특정 세션에서 백업 락을 획득하면 모든 세션에서 다음과 같이 테이블의 스키마나 사용자의 인증 관련 정보를 변경할 수 없게 된다.

    - 데이터베이스 및 테이블 등 모든 객체 생성 및 변경, 삭제
    - REPAIR TABLE과 OPTIMIZE TABLE 명령
    - 사용자 관리 및 비밀번호 변경

  하지만 백업 락은 일반적인 테이블의 데이터 변경은 허용된다.
  일반적인 MySQL 서버의 구성은 소스 서버(Source server)와 레플리카 서버(Replica server)로 구성되는데,
  주로 백업은 레플리카 서버에서 실행된다.
  하지만 백업이 FLUSH TABLES WITH READ LOCK 명령을 이용해 글로벌 락을 획득하면 복제는 백업 시간만큼 지연될 수밖에 없다.
  레플리카 서버에서 백업을 실행하는 도중에 소스 서버에 문제가 생기면
  레플리카 서버의 데이터가 최신 상태가 될 때까지 서비스를 멈춰야 할 수도 있다.
  물론 XtralBackup이나 Enterprise Backup 툴들은 모두 복제가 진행되는 상태에서도 일관된 백업을 만들 수 있다.
  하지만 XtralBackup이나이나 Enterprise Backup 툴이 실행되는 도중에 스키마 변경이 실행되면 백업은 실패하게 된다.
  6~7시간 동안 백업이 실행되고 있는데, 갑자기 DDL 명령 하나로 인해 백업이 실패하면 다시 그만큼 시간을 들여서 백업을 실행해야 한다.
  MySQL 서버의 백업 락은 이런 목적으로 도입됐으며,
  정상적으로 복제는 실행되지만 백업의 실패를 막기 위해 DDL 명령이 실행되면 복제를 일시 중지하는 역할을 한다.

5.2.2 테이블 락

  테이블 락(Table Lock)은 개별 테이블 단위로 설정되는 잠금이며,
  명시적 또는 묵시적으로 특정 테이블의 락을 획득할 수 있다.
  명시적으로는 "LOCK TABLES table_name [ READ | WRITE ]" 명령으로 특정 테이블의 락을 획득할 수 있다.
  테이블 락은 MyISAM뿐 아니라 InnoDB 스토리지 엔진을 사용하는 테이블도 동일하게 설정할 수 있다.
  명시적으로 획득한 잠금은 UNLOCK TABLES 명령으로 잠금을 반납(해제)할 수 있다.
  명시적인 테이블 락도 특별한 상황이 아니면 애플리케이션에서 사용할 필요가 거의 없다.
  명시적으로 테이블을 잠그는 작업은 글로벌 락과 동일하게 온라인 작업에 상당한 영향을 미치기 때문이다.

  묵시적인 테이블 락은 MyISAM이나 MEMORY 테이블에 데이터를 변경하는 쿼리를 실행하면 발생한다.
  MySQL 서버가 데이터가 변경되는 테이블에 잠금을 설정하고 데이터를 변경한 후,
  즉시 잠금을 해제하는 형태로 사용된다.
  즉, 묵시적인 테이블 락은 쿼리가 실행되는 동안 자동으로 획득됐다가 쿼리가 완료된 후 자동 해제된다.
  하지만 InnoDB 테이블의 경우 스토리지 엔진 차원에서 레코드 기반의 잠금을 제공하기 때문에
  단순 데이터 변경 쿼리로 인해 묵시적인 테이블 락이 설정되지는 않는다.
  더 정확히는 InnoDB 테이블에도 테이블 락이 설정되지만 대부분의 데이터 변경(DML) 쿼리에서는 무시되고
  스키마를 변경하는 쿼리(DDL)의 경우에만 영향을 미친다.

5.2.3 네임드 락

  네임드 락(Named Lock)은 GET_LOCK() 함수를 이용해 임의의 문자열에 대해 잠금을 설정할 수 있다.
  이 잠금의 특징은 대상이 테이블이나 레코드 또는 AUTO_INCREMENT와 같은 데이터베이스 객체가 아니라는 것이다.
  네임드 락은 단순히 사용자가 지정한 문자열(String)에 대해 획득하고 반납(해제)하는 잠금이다.
  네임드 락은 자주 사용되지는 않는다.
  예를 들어, 데이터베이스 서버 1대에 5대의 웹 서버가 접속해서 서비스하는 상황에서 5대의 웹 서버가 어떤 정보를 동기화해야 하는 요건처럼
  여러 클라이언트가 상호 동기화를 처리해야 할 때 네임드 락을 이용하면 쉽게 해결할 수 있다.

  -- // "mylock"이라는 문자열에 대해 잠금을 획득한다.
  -- // 이미 잠금을 사용 중이면 2초 동안만 대기한다. (2초 이후 자동 잠금 해제 됨)
  mysql> SELECT GET_LOCK('mylock', 2);

  -- // "mylock"이라는 문자열에 대해 잠금이 설정돼 있는지 확인한다.
  mysql> SELECT IS_FREE_LOCK('mylock');

  --- // "mylock"이라는 문자열에 대해 획득했던 잠금을 반납(해제) 한다.
  mysql> SELECT RELEASE_LOCK('mylock');

  -- // 3개 함수 모두 정상적으로 락을 획득하거나 해제한 경우에는 1을,
  -- // 아니면 NULL이나 0을 반환한다.

  또한 네임드 락의 경우 많은 레코드에 대해서 복잡한 요건으로 레코드를 변경하는 트랜잭션에 유용하게 사용할 수 있다.
  배치 프로그램처럼 한꺼번에 많은 레코드를 변경하는 쿼리는 자주 데드락의 원인이 되곤 한다.
  각 프로그램의 실행 시간을 분산하거나 프로그램의 코드를 수정해서 데드락을 최소화할 수는 있지만,
  이는 간단한 방법이 아니며 완전한 해결책이 될 수도 없다.
  이러한 경우에 동일 데이터를 변경하거나 참조하는 프로그램끼리 분류해서 네임드 락을 걸고 쿼리를 실행하면 아주 간단히 해결할 수 있다.

  MySQL 8.0 버전부터는 다음과 같이 네임드 락을 중첩해서 사용할 수 있게 됐으며,
  현재 세션에서 회득한 네임드 락을 한 번에 모두 해제하는 기능도 추가됐다.

  mysql> SELECT GET_LOCK('mylock_1', 10);
  -- // mylock_1에 대한 작업 실행
  mysql> SELECT GET_LOCK('mylock_2', 10);
  -- // mylock_1과 mylock_2에 대한 작업 실행

  mysql> SELECT RELEASE_LOCK('mylock_2');
  mysql> SELECT RELEASE_LOCK('mylock_1');

  -- // mylock_1과 my lock_2를 동시에 모두 해제하고자 한다면 RELEASE_ALL_LOCKS() 함수 사용
  mysql> SELECT RELEASE_ALL_LOCKS();

5.2.4 메타데이터 락

  메타데이터 락(Metadata Lock)은 데이터베이스 객체(대표적으로 테이블이나 뷰 등)의 이름이나 구조를 변경하는 경우에 획득하는 잠금이다.
  메타데이터 락은 명시적으로 획득하거나 해제할 수 있는 것이 아니고
  "RENAME TABLE tab_a To tab_b" 같이 테이블의 이름을 변경하는 경우 자동으로 획득하는 잠금이다.
  RENAME TABLE 명령의 경우 원본 이름과 변경될 이름 두 개 모두 한꺼번에 잠금을 설정한다.
  또한 실시간으로 테이블을 바꿔야 하는 요건이 배치 프로그램에서 자주 발생하는데,
  다음 예제를 잠깐 살펴보자.

  -- // 배치 프로그램에서 별도의 임시 테이블(rank_new)에 서비스용 랭킹 데이터를 생성

  -- // 랭킹 배치가 완료되면 현재 서비스용 랭킹 테이블(rank)을 rank_backup으로 백업하고
  -- // 새로 만들어진 랭킹 테이블(rank_new)을 서비스용으로 대체하고자 하는 경우
  mysql> RENAME TABLE rank TO rank_backup, rank_new TO rank;

  위와 같이 하나의 RENAME TABLE 명령문에 두 개의 RENAME 작업을 한꺼번에 실행하면 실제 애플리케이션에서는
  "Table not found rank" 같은 상황을 발생시키지 않고 적용하는 것이 가능하다.
  하지만 이 문장을 다음과 같이 2개로 나눠서 실행하면 아주 짧은 시간이지만 rank 테이블이 존재하지 않는 순간이 생기며,
  그 순간에 실행되는 쿼리는 "Table not found rank" 오류를 발생시킨다.

  mysql> RENAME TABLE rank TO rank_backup;
  mysql> RENAME TABLE rank_new TO rank;

  때로는 메타데이터 잠금과 InnoDB의 트랜잭션을 동시에 사용해야 하는 경우도 있다.
  예를 들어, 다음과 같은 구조의 INSERT만 실행되는 로그 테이블을 가정해보자.
  이 테이블은 웹 서버의 액세스(접근) 로그를 저장만 하기 때문에 UPDATE와 DELETE가 없다.

  mysql> CREATE TABLE access_log
         ( id          BIGINT       NOT NULL AUTO_INCREMENT
         , client_ip   INT UNSIGNED
         , access_dttm TIMESTAMP
         , ...
         , PRIMARY KEY(id)
         ) ;

  그런데 어느 날 이 테이블의 구조를 변경해야 할 요건이 발생했다.
  물론 MySQL 서버의 Online DDL을 이용해서 변경할 수도 있지만 시간이 너무 오래 걸리는 경우라면
  언두 로그의 증가와 Online DDL이 실행되는 동안 누적된 Online DDL 버퍼의 크기 등 고민해야 할 문제가 많다.
  더 큰 문제는 MySQL서버의 DDL은 단일 스레드로 작동하기 때문에 상당히 많은 시간이 소모될 것이라는 점이다.
  이때는새로운 구조의 테이블을 생성하고 먼저 최근(1시간 직전 또는 하루 전)의 데이터까지는
  프라이머리 키인 id 값을 범위별로 나눠서 여러 개의 스레드로 빠르게 복사한다.

  -- // 테이블의 압축을 적용하기 위해 KEY_BLOCK_SIZE=4 옵션을 추가해 신규 테이블을 생성
  mysql> CREATE TABLE access_log_new
         ( id          BIGINT         NOT NULL AUTO_INCREMENT
         , client_ip   INT UNSIGNED
         , access_dttm TIMESTAMP
         , ...
         , PRIMARY KEY(id)
         ) KEY_BLOCK_SIZE=4
         ;

  --- // 4개의 스레드를 이용해 id 범위별로 레코드를 신규 테이블로 복사
  mysql_thread1> INSERT
                   INTO access_log_new
                 SELECT *
                   FROM access_log
                  WHERE id >= 0
                    AND id <  10000
                 ;
  mysql_thread2) INSERT
                   INTO access_log_new
                 SELECT *
                   FROM access_log
                  WHERE id >= 10000
                    AND id <  20000
                 ;
  mysql_thread3) INSERT
                   INTO access_log_new
                 SELECT *
                   FROM access_log
                  WHERE id <= 20000
                    AND id <  30000
                 ;
  mysql_thread4) INSERT
                   INTO access_log_new
                 SELECT *
                   FROM access_log
                  WHERE id >= 30000
                    AND id <  40000
                 ;

  그리고 나머지 데이터는 다음과 같이 트랜잭션과 테이블 잠금,
  RENAME TABLE 명령으로 응용 프로그램의중단 없이 실행할 수 있다.
  이때 "남은 데이터를 복사"하는 시간 동안은 테이블의 잠금으로 인해 INSERT를 할 수 없게 된다.
  그래서 가능하면 미리 아주 최근 데이터까지 복사해 둬야 잠금 시간을 최소화해서서비스에 미치는 영향을 줄일 수 있다.

  -- // 트랜잭션을 autocommit으로 실행(BEGIN이나 START TRANSACTION으로 실행하면 안 됨)
  mysql> SET autocommit=0;

  -- // 작업 대상 테이블 2개에 대해 테이블 쓰기 락을 획득
  mysql> LOCK TABLES access_log WRITE, access_log_new WRITE;

  -- // 남은 데이터를 복사
  mysql> SELECT MAX(id) as @MAX_ID
           FROM access_log
         ;
  mysql> INSERT
           INTO access_log_new
         SELECT *
           FROM access_log
          WHERE pk > @MAX_ID
         ;
  mysql> COMMIT;

  -- // 새로운 테이블로 데이터 복사가 완료되면 RENAME 명령으로 새로운 테이블을 서비스로 투입
  mysql> RENAME TABLE access_log TO access_log_old, access_log_new TO access_log;
  mysql> UNLOCK TABLES;

  // 불필요한 테이블 삭제
  mysql> DROP TALBE access_log_old;


5.3 InnoDB 스토리지 엔진 잠금

  InnoDB 스토리지 엔진은 MySQL에서 제공하는 잠금과는 별개로 스토리지 엔진 내부에서 레코드 기반의 잠금 방식을 탑재하고 있다.
  InnoDB는 레코드 기반의 잠금 방식 때문에 MyISAM보다는 훨씬 뛰어난 동시성 처리를 제공할 수 있다.
  하지만 이원화된 잠금 처리 탓에 InnoDB 스토리지 엔진에서 사용되는 잠금에 대한 정보는 MySQL 명령을 이용해 접근하기가 상당히 까다롭다.
  예전 버전의 MySQL 서버에서는 InnoDB의 잠금 정보를 진단할 수 있는 도구라고는 lock monitor
  (innodb_lock_monitor라는 이름의 InnoDB 테이블을 생성해서 InnoDB의 잠금 정보를 덤프하는 방법)와 SHOW ENGINE INNODBSTATUS 명령이 전부였다.
  하지만 이 내용도 거의 어셈블리 코드를 보는 것 같아서 이해하기가 상당히 어려웠다.

  하지만 최근 버전에서는 InnoDB의 트랜잭션과 잠금, 그리고 잠금 대기 중인 트랜잭션의 목록을 조회할 수 있는 방법이 도입됐다.
  MySQL 서버의 information_schema 데이터베이스에 존재하는 INNODB_TRX, INNODB_LOCKS, INNODB_LOCK_WAITS라는 테이블을 조인해서 조회하면
  현재 어떤 트랜잭션이 어떤 잠금을 대기하고 있고 해당 잠금을 어느 트랜잭션이 가지고 있는지 확인할 수 있으며,
  또한 장시간 잠금을 가지고 있는 클라이언트를 찾아서 종료시킬 수도 있다.
  그리고 조금씩 업그레이드되면서 InnoDB의 중요도가 높아졌고, InnoDB의 잠금에 대한 모니터링도 더 강화되면서
  Performance Schema를 이용해 InnoDB 스토리지 엔진의 내부 잠금(세마포어)에 대한 모니터링 방법도 추가됐다.

5.3.1 InnoDB 스토리지 엔진의 잠금

  InnoDB 스토리지 엔진은 레코드 기반의 잠금 기능을 제공하며,
  잠금 정보가 상당히 작은 공간으로 관리되기 때문에 레코드 락이 페이지 락으로,
  또는 테이블 락으로 레벨업되는 경우(락 에스컬레이션)는 없다.
  일반 상용 DBMS와는 조금 다르게 InnoDB 스토리지 엔진에서는 레코드 락뿐 아니라
  레코드와 레코드 사이의 간격을 잠그는 갭(GAP) 락이라는 것이 존재하는데,
  그림 5.1은 InnoDB 스토리지 엔진의 레코드 락과 레코드 간의 간격을 잠그는 갭락을 보여준다.

                                   인덱스
                                   Adamantios ] - 레코드 락 (Record Lock)
                                   Alejandro
                                 [ Anneke
  넥스트 키 락 (Next Key Lock) - [ Christan   ] - 갭락 (Gap Lock)
                                   Duangkaew
                                   Eberhardt
                                   Georgi

  그림 5.1 InnoDB 잠금의 종류(점선의 레코드는 실제 존재하지 않는 레코드를 가정한 것임)

5.3.1.1 레코드 락

  레코드 자체만을 잠그는 것을 레코드 락(Record lock, Record only lock)이라고 하며,
  다른 상용 DBMS의 레코드 락과 동일한 역할을 한다.
  한 가지 중요한 차이는 InnoDB 스토리지 엔진은 레코드 자체가 아니라 인덱스의 레코드를 잠근다는 점이다.
  인덱스가 하나도 없는 테이블이더라도 내부적으로 자동 생성된 클러스터 인덱스를 이용해 잠금을 설정한다.
  많은 사용자가 간과하는 부분이지만 레코 자체를 잠그느냐,
  아니면 인덱스를 잠그느냐는 상당히 크고 중요한 차이를 만들어 내기 때문에 다음에 다시 잠깐 예제로 다루겠다.

  InnoDB에서는 대부분 보조 인덱스를 이용한 변경 작업은 이어서 설명할 넥스트 키 락(Next keylock) 또는 갭 락(Gap lock)을 사용하지만
  프라이머리 키 또는 유니크 인덱스에 의한 변경 작업에서는 갭(Gap, 간격)에 대해서는 잠그지 않고 레코드 자체에 대해서만 락을 건다.

5.3.1.2 갭락

  다른 DBMS와의 또 다른 차이가 바로 갭락(Gap lock)이다.
  갭 락은 레코드 자체가 아니라 레코드와 바로 인접한 레코드 사이의 간격만을 잠그는 것을 의미한다.
  갭 락의 역할은 레코드와 레코드 사이의 간격에 새로운 레코드가 생성(INSERT)되는 것을 제어하는 것이다.
  갭 락은 그 자체보다는 이어서 설명할 넥스트 키 락의 일부로 자주 사용된다.

5.3.1.3 넥스트 키 락

  레코드 락과 갭 락을 합쳐 놓은 형태의 잠금을 넥스트 키 락(Next key lock)이라고 한다.
  STATEMENT 포맷의 바이너리 로그를 사용하는 MySQL 서버에서는 REPEATABLE READ 격리 수준을 사용해야 한다.
  또한 innodb_locks_unsafe_for_binlog 시스템 변수가 비활성화되면(0으로 설정되면)
  변경을 위해 검색하는 레코드에는 넥스트 키 락 방식으로 잠금이 걸린다.
  InnoDB의 갭 락이나 넥스트키 락은 바이너리 로그에 기록되는 쿼리가 레플리카 서버에서 실행될 때
  소스 서버에서 만들어 낸 결과와 동일한 결과를 만들어내도록 보장하는 것이 주목적이다.
  그런데 의외로 넥스트 키 락과 갭 락으로 인해 데드락이 발생하거나 다른 트랜잭션을 기다리게 만드는 일이 자주 발생한다.
  가능하다면 바이너리 로그 포맷을 ROW 형태로 바꿔서 넥스트 키 락이나 갭락을 줄이는 것이 좋다.

  [주의] MySQL 8.0 버전부터는 innodb_locks_unsafe_for_binlog 파라미터는 제거 되었으며,
         그 대신 transaction_isolation 를 READ-COMMITTED 로 대체 하여 사용 할 수 있습니다.

         SHOW VARIABLES LIKE '%transaction_isolation%';
         +-----------------------+-----------------+
         | Variable_name         | Value           |
         +-----------------------+-----------------+
         | transaction_isolation | REPEATABLE-READ |
         +-----------------------+-----------------+

  참고 : MySQL 5.5 버전까지는 ROW 포맷의 바이너리 로그가 도입된 지 오래되지 않아서 그다지 널리 사용되지 않았다.
         하지만 MySQL 5.7 버전과 8.0 버전으로 업그레이드 되면서 ROW 포맷의 바이너리 로그에 대한 안정성도 높아졌으며
         STATEMENT 포맷의 바이너리 로그가 가지는 단점을 많이 해결해줄 수 있기 때문에
         MySQL 8.0에서는 ROW 포맷의 바이너리 로그가 기본 설정으로 변경됐다.

5.3.1.4 자동 증가락

  MySQL에서는 자동 증가하는 숫자 값을 추출(채번)하기 위해 AUTO_INCREMENT라는 칼럼 속성을 제공한다.
  AUTO_INCREMENT 칼럼이 사용된 테이블에 동시에 여러 레코드가 INSERT되는 경우,
  저장되는 각 레코드는 중복되지 않고 저장된 순서대로 증가하는 일련번호 값을 가져야 한다.
  InnoDB 스토리지 엔진에서는 이를 위해 내부적으로 AUTO_INCREMENT 락(Auto increment lock)이라고 하는 테이블 수준의 잠금을 사용한다.

  AUTO_INCREMENT 락은 INSERT와 REPLACE 쿼리 문장과 같이 새로운 레코드를 저장하는 쿼리에서만 필요하며,
  UPDATE나 DELETE 등의 쿼리에서는 걸리지 않는다.
  InnoDB의 다른 잠금(레코드 락이나 넥스트 키락)과는 달리 AUTO_INCREMENT 락은 트랜잭션과 관계없이
  INSERT나 REPLACE 문장에서 AUTO_INCREMENT 값을 가져오는 순간만 락이 걸렸다가 즉시 해제된다.
  AUTO_INCREMENT 락은 테이블에 단 하나만 존재하기 때문에 두 개의 INSERT 쿼리가 동시에 실행되는 경우
  하나의 쿼리가 AUTO_INCREMENT 락을 걸면 나머지 쿼리는 AUTO_INCREMENT 락을 기다려야 한다
  (AUTO_INCREMENT 칼럼에 명시적으로 값을 설정하더라도 자동 증가 락을 걸게 된다).

  AUTO_INCREMENT 락을 명시적으로 획득하고 해제하는 방법은 없다.
  AUTO_INCREMENT 락은 아주 짧은 시간동안 걸렸다가 해제되는 잠금이라서 대부분의 경우 문제가 되지 않는다.
  자동 증가 락에 대한 지금까지의 설명은 MySQL 5.0 이하 버전에서 사용되던 방식이다.
  MySQL 5.1 이상부터는 innodb_autoinc_lock_mode라는 시스템 변수를 이용해 자동 증가 락의 작동 방식을 변경할 수 있다.

    SHOW VARIABLES LIKE '%innodb_autoinc_lock_mode%';
    +--------------------------+-------+
    | Variable_name            | Value |
    +--------------------------+-------+
    | innodb_autoinc_lock_mode | 2     |
    +--------------------------+-------+

    - innodb_autoinc_lock_mode=0
      MySQL 5.0과 동일한 잠금 방식으로 모든 INSERT 문장은 자동 증가 락을 사용한다.

    - innodb_autoinc_lock_mode=1
      단순히 한 건 또는 여러 건의 레코드를 INSERT하는 SQL 중에서 MySQL 서버가 INSERT되는 레코드의 건수를 정확히 예측할 수 있을 때는
      자동 증가 락(Auto increment lock)을 사용하지 않고, 훨씬 가볍고 빠른 래치(뮤텍스)를 이용해 처리한다.
      개선된 래치는 자동 증가 락과 달리 아주 짧은 시간 동안만 잠금을 걸고 필요한 자동 증가 값을 가져 오면 잠금이 해제된다.
      하지만 INSERT ... SELECT와 같이 MySQL 서버가 건수를 (쿼리를 실행하기 전)에 예측오면 즉시 잠금이 해제된다.
      예측할 수 없을 때는 MySQL 5.0에서와 같이 자동 증가 락을 사용한다.
      이때는 INSERT 문장이 완료되기 전까지는 자동 증가 락은 해제되지 않기 때문에 다른 커넥션에서는 INSERT를 실행하지 못하고 대기하게 된다.
      이렇게 대량 INSER가 수행될 때는 InnoDB 스토리지 엔진은 여러 개의 자동 증가 값을 한 번에 할당받아서 INSERT되는 레코드에 사용한다.
      그래서 대량 INSERT되는 레코드는 자동 증가 값이 누락되지 않고 연속되게 INSERT된다.
      하지만 한 번에 할당받은 자동 증가 값이 남아서 사용되지 못하면 폐기하므로 대량 INSERT 문장의 실행 이후에
      INSERT되는 레코드의 자동 증가 값은 연속되지 않고 누락된 값이 발생할 수 있다.
      이 설정에서는 최소한 하나의 INSERT 문장으로 INSERT 되는 레코드는 연속된 자동 증가 값을 가지게 된다.
      그래서 이 설정 모드를 연속 모드(Conseculive mode)라고도 한다.

    - innodb_autoinc_lock_mode=2
      innodb_autoinc_lock_mode가 2로 설정되면 InnoDB 스토리지 엔진은 절대 자동 증가 락을 걸지 않고 경량화된 래치(뮤텍스)를 사용한다.
      하지만 이 설정에서는 하나의 INSERT 문장으로 INSERT되는 레코드라고 하더라도 연속된 자동 증가 값을 보장하지는 않는다.
      그래서 이 설정 모드를 인터리빙 모드(Interleaved mode)라고도 한다.
      이 설정 모드에서는 INSERT SELECT와 같은 대량 INSERT 문장이 실행되는 중에도
      다른 커넥션에서 INSERT를 수행할 수 있으므로 동시 처리 성능이 높아진다.
      하지만 이 설정에서 작동하는 자동 증가 기능은 유니크한 값이 생성된다는 것만 보장한다.
      STATEMENT 포맷의 바이너리 로그를 사용하는 복제에서는 소스 서버와 레플리카 서버의 자동 증가 값이 달라질 수도 있기 때문에 주의해야 한다.

  더 자세한 내용은 MySQL 매뉴얼의 내용을 참조하길 바란다.
  별로 관계없는 것 같지만, 자동 증가값이 한 번 증가하면 절대 줄어들지 않는 이유가 AUTO_INCREMENT 잠금을 최소화하기 위해서다.
  설령 INSERT 쿼리가 실패했더라도 한 번 증가된 AUTO_INCREMENT 값은 다시 줄어들지 않고 그대로 남는다.

  주의 : MySQL 5.7 버전까지는 innodb_autoinc_lock_mode의 기본값이 1이었지만,
         MySQL 8.0 버전부터는 innodb_autoinc_lock_mode의 기본값이 2로 바뀌었다.
         이는 MySQL 8.0부터 바이너리 로그 포맷이 STATEMENT가 아니라 ROW 포맷이 기본값이 됐기 때문이다.
         MySQL 8.0에서 ROW 포맷이 아니라 STATEMENT 포맷의 바이너리 로그를 사용한다면
         innodb_autoinc_lock_mode를 2가 아닌 1로 변경해서 사용할 것을 권장한다.

5.3.2 인덱스와 잠금

  InnoDB의 잠금과 인덱스는 상당히 중요한 연관 관계가 있기 때문에 다시 한번 더 자세히 살펴보자.
  "레코드 락" 소개하면서 잠깐 언급했듯이 InnoDB의 잠금은 레코드를 잠그는 것이 아니라 인덱스를 그는 방식으로 처리된다.
  즉, 변경해야 할 레코드를 찾기 위해 검색한 인덱스의 레코드를 모두 락을 걸어야 한다.
  정확한 이해를 위해 다음 UPDATE 문장을 한 번 살펴보자.

  -- // 예제 데이터베이스의 employees 테이블에는 아래와 같이 first_name 칼럼만
  -- // 멤버로 담긴 ix_firstname이라는 인덱스가 준비돼 있다.
  -- //   KEY ix_firstname (first_name)
  -- // employees 테이블에서 first_name='Georgi'인 사원은 전체 253명이 있으며,
  -- // first_name='Georgi' 이고 last_name='Klassen'인 사원은 딱 1명만 있는 것을 아래 쿼리로
  -- // 확인할 수 있다.
  mysql> SELECT COUNT(*) FROM employees WHERE first_name='Georgi';
         +----------+
         | count(*) |
         +----------+
         |      253 |
         +----------+

  mysql> SELECT COUNT(*) FROM employees WHERE first_name='Georgi' AND last_name='Klassen';
         +----------+
         | count(*) |
         +----------+
         |        1 |
         +----------+

  -- // employees 테이블에서 first_name='Georgi'012 last_name='Klassen' 인 사원의
  -- // 입사 일자를 오늘로 변경하는 쿼리를 실행해보자.
  mysql> UPDATE employees SET hire_date=NOW() WHERE first_name='Georgi' AND last_name='Klassen';

  UPDATE 문장이 실행되면 1건의 레코드가 업데이트될 것이다.
  하지만 이 1건의 업데이트를 위해 몇 개의 레코드에 락을 걸어야 할까?
  이 UPDATE 문장의 조건에서 인덱스를 이용할 수 있는 조건은 first_name='Georgi' 이며,
  last_name 칼럼은 인덱스에 없기 때문에 first_name='Georgi'인 레코드 253건의 레코드가 모두 잠긴다.
  그림 5.2는 예제의 UPDATE 문장이 어떻게 변경 대상 레코드를 검색하고, 실제 변경이 수행되는지를 보여준다.
  아마 MySQL에 익숙하지 않은 사용자라면 상당히 이상하게 생각될 것이며,
  이러한 부분을 잘 모르고 개발하면 MySQL 서버를 제대로 이용하지 못할 것이다.
  또한 이러한 MySQL의 특성을 알지 못하면 "MySQL은 정말 이상한 데이터베이스군"이라고 생각하게 될 것이다.
  이 예제에서는 몇 건 안 되는 레코드만 잠그지만 UPDATE 문장을 위해 적절히 인덱스가 준비돼 있지 않다면
  각 클라이언트 간의 동시성이 상당히 떨어져서 한 세션에서 UPDATE 작업을 하는 중에는
  다른 클라이언트는 그 테이블을 업데이트하지 못하고 기다려야 하는 상황이 발생할 것이다.

  인덱스 리프 노드             테이블
  (ix_firstname)               (employees)
  first name  emp_no           emp no first name last name
  Georgi  |   10001 ---------> 10001  Georgi     Facello     -+
  Georgi  |   10909 ---------> 10909  Georgi     Atchley      |
  Georgi  |   11029 ---------> 11029  Georgi     Itzfeldt   ]-+- 변경된 레코드
  Georgi  |   11430 ---------> 11430  Georgi     Klassen      |- 잠긴 레코드실제
  Georgi  |   12157 ---------> 12157  Georgi     Barinka      |
  Georgi  |   15220 ---------> 15220  Georgi     Paniensk     |
  Georgi  |   15660 ---------> 15660  Georgi     Hartvigsen   |
  Georgi  |   15689 ---------> 15689  Georgi     Capobianchi -+
  ...     V   ...              ...    ...        ...
  Georgy      10055 ---------> 10055  Georgy     Dredge

  그림 5.2 업데이트를 위해 잠긴 레코드와 실제 업데이트된 레코드

  이 테이블에 인덱스가 하나도 없다면 어떻게 될까?
  이러한 경우에는 테이블을 풀 스캔하면서 UPDATE 작업을 하는데,
  이 과정에서 테이블에 있는 30여만 건의 모든 레코드를 잠그게 된다.
  이것이 MySQL의 방식이며, MySQL의 InnoDB에서 인덱스 설계가 중요한 이유 또한 이것이다.

5.3.3 레코드 수준의 잠금 확인 및 해제

  InnoDB 스토리지 엔진을 사용하는 테이블의 레코드 수준 잠금은 테이블 수준의 잠금보다는 조금 더 복잡하다.
  테이블 잠금에서는 잠금의 대상이 테이블 자체이므로 쉽게 문제의 원인이 발견되고 해결될 수 있다.
  하지만 레코드 수준의 잠금은 테이블의 레코드 각각에 잠금이 걸리므로 그 레코드가 자주 사용되지 않는다면
  오랜 시간 동안 잠겨진 상태로 남아 있어도 잘 발견되지 않는다.

  예전 버전의 MySQL 서버에서는 레코드 잠금에 대한 메타 정보(딕셔너리 테이블)를 제공하지 않기 때문에 더더욱 어려운 부분이다.
  하지만 MySQL 5.1부터는 레코드 잠금과 잠금 대기에 대한 조회가 가능하므로
  쿼리 하나만 실행해 보면 잠금과 잠금 대기를 바로 확인할 수 있다.
  그럼 버전별로 레코드 잠금과 잠금을 대기하는 클라이언트의 정보를 확인하는 방법을 알아보자.
  강제로 잠금을 해제하려면 KILL 명령을 이용해 MySQL 서버의 프로세스를 강제로 종료하면 된다.

  우선 다음과 같은 잠금 시나리오를 가정해보자.

  커넥션 1                커넥션 2                커넥션 3
  -------------------------------------------------------------------------
  BEGIN;
  -------------------------------------------------------------------------
  UPATE employees
    SET birth_date=NOW()
   WHERE emp_no=100001;
  -------------------------------------------------------------------------
                          UPDATE employees
                             SET hire_date=NOW()
                           WHERE emp_no=100001;
  -------------------------------------------------------------------------
                                                  UPDATE employees
                                                     SET hire_date=NOW()
                                                       , birth_ date=NOW()
                                                   WHERE emp_no=100001;
  -------------------------------------------------------------------------

  각 트랜잭션이 어떤 잠금을 기다리고 있는지,
  기다리고 있는 잠금을 어떤 트랜잭션이 가지고 있는지를쉽게 메타 정보를 통해 조회할 수 있다.
  우선 MySQL 5.1부터는 information_schema라는 DB에 INNODB_TRX라는 테이블과 INNODB_LOCKS, INNODB_LOCK_WAITS라는 테이블을 통해 확인이 가능했다.
  하지만SQL 8.0 버전부터는 information_schema의 정보들은 조금씩 제거(Deprecated)되고 있으며,
  그 대신 performance_schema의 data_locks와 data_lock_waits 테이블로 대체되고 있다.
  여기서는 performance_schema의 테이블을 이용해 잠금과 잠금 대기 순서를 확인하는 방법을 살펴보자.

  우선 아래 내용은 MySQL 서버에서 앞의 UPDATE 명령 3개가 실행된 상태의 프로세스 목록을 조회한 것이다
  (가독성을 위해서 꼭 필요한 부분만 캡처했다).
  17번 스레드는 지금 아무것도 하지 않고 있지만 트랜잭션을 시작하고 UPDATE 명령이 실행 완료된 것이다.
  하지만 아직 17번 스레드는 COMMIT을 실행하지는 않은 상태이므로 업데이트한 레코드의 잠금을 그대로 가지고 있는 상태다.
  18번 스레드가 그다음으로 UPDATE 명령을 실행했으며, 그 이후 19번 스레드에서 UPDATE 명령을 실행했다.
  그래서 프로세스 목록에서 18번과 19번 스레드는 잠금 대기로 인해 아직 UPDATE 명령을 실행 중인 것으로 표시된 것이다.

  mysql> SHOW PROCESSLIST;
         +----+------+----------+-----------------------------------------------------------+
         | Id | Time | State    | Info                                                      |
         +----+------+----------+-----------------------------------------------------------+
         | 17 |  607 |          | NULL                                                      |
         | 18 |   22 | updating | UPDATE employees SET birth_date=NOW() WHERE emp_no=100001 |
         | 19 |   21 | updating | UPDATE employees SET birth_date=NOW() WHERE emp_no=100001 |
         +----+------+----------+-----------------------------------------------------------+

  이제 performance_schema의 data_locks 테이블과 data_lock_waits 테이블을 조인해서 잠금 대기 순서를 한 번 살펴보자.
  다음 내용 또한 가독성을 위해 조금 편집한 결과다.

  mysql> SELECT r.trx_id waiting_trx_id
              , r.trx_mysql_thread_id waiting_thread
              , r.trx_query waiting_query
              , b.trx_id blocking_trx_id
              , b.trx_mysql_thread_id blocking_thread
              , b.trx_query blocking_query
           FROM performance_schema.data_lock_waits w
          INNER
           JOIN information_schema.innodb_trx b
             ON b.trx_id = w.blocking_engine_transaction_id
          INNER
           JOIN information_schema.innodb_trx r
             ON r.trx_id = w.requesting_engine_transaction_id
         ;
         +----------------+----------------+---------------------+-----------------+-----------------+--------------------+
         | waiting_trx_id | waiting_thread | waiting_query       | blocking_trx_id | blocking_thread | blocking_query     |
         +----------------+----------------+---------------------+-----------------+-----------------+--------------------+
         |          11990 |             19 | UPDATE employees .. |           11989 |              18 | UPDATE employees.. |
         |          11990 |             19 | UPDATE employees .. |           11984 |              17 | NULL               |
         |          11989 |             18 | UPDATE employees .. |           11984 |              17 | NULL               |
         +----------------+----------------+---------------------+-----------------+-----------------+--------------------+

  쿼리의 실행 결과를 보면 현재 대기 중인 스레드는 18번과 19번인 것을 알 수 있다.
  18번 스레드는 17번 스레드를 기다리고 있고,
  19번 스레드는 17번 스레드와 18번 스레드를 기다리고 있다는 것을 알 수 있다.
  이는 잠금 대기 큐의 내용을 그대로 보여주기 때문에 이렇게 표시되는 것이다.
  즉 17번 스레드가 가지고 있는 잠금을 해제하고, 18번 스레드가 그 잠금을 획득하고
  UPDATE를 완료한 후 잠금을 풀어야만 비로소 19번 스레드가 UPDATE를 실행할 수 있음을 의미한다.
  여기서 17번 스레드가 어떤 잠금을 가지고 있는지 더 상세히 확인하고 싶다면
  다음과 같이 performance_schema의 data_locks 테이블이 가진 칼럼을 모두 살펴보면 된다.

  mysql> SELECT * FROM performance_schema.data_locks\G
         ******************* 1. row ***************************
                        ENGINE: INNODB
                ENGINE_LOCK_ID: 4828335432:1157:140695376728800
         ENGINE_TRANSACTION_ID: 11984
                     THREAD_ID: 61
                      EVENT_ID: 16028
                 OBJECT_SCHEMA: employees
                   OBJECT_NAME: employees
                PARTITION_NAME: NULL
             SUBPARTITION_NAME: NULL
                    INDEX_NAME: NULL
         OBJECT_INSTANCE_BEGIN: 140695376728800
                     LOCK TYPE: TABLE
                     LOCK MODE: IX
                  LOCK_STATUS : GRANTED
                     LOCK_DATA: NULL
         ******************* 2. row ***************************
                        ENGINE: INNODB
                ENGINE_LOCK_ID: 4828335432:8:298:25:140695394434080
         ENGINE_TRANSACTION_ID: 11984
                     THREAD_ID: 61
                      EVENT_ID: 16048
                 OBJECT_SCHEMA: employees
                   OBJECT_NAME: employees
                PARTITION_NAME: NULL
             SUBPARTITION_NAME: NULL
                    INDEX_NAME: PRIMARY
         OBJECT_INSTANCE_BEGIN: 140695394434080
                     LOCK TYPE: RECORD
                     LOCK MODE: X, REC_NOT GAP
                   LOCK_STATUS: GRANTED
                     LOCK_DATA: 100001

  위의 결과를 보면 employees 테이블에 대해 IX 잠금(Intentional Exclusive)을 가지고 있으며,
  employees 테이블의 특정 레코드에 대해서 쓰기 잠금을 가지고 있다는 것을 확인할 수 있다.
  이때 REC_NOT_GAP 표시가 있으므로 레코드 잠금은 갭이 포함되지 않은 순수 레코드에 대해서만 잠금을 가지고 있음을 알 수 있다.

  만약 이 상황에서 17번 스레드가 잠금을 가진 상태에서 상당히 오랜 시간 멈춰 있다면
  다음과 같이 11번 스레드를 강제 종료하면 나머지 UPDATE 명령들이 진행되면서 잠금 경합이 끝날 것이다.

  mysql> KILL 17;


5.4 MySQL의 격리 수준

  트랜잭션의 격리 수준(isolation level)이란 여러 트랜잭션이 동시에 처리될 때
  특정 트랜잭션이 다른 트랜잭션에서 변경하거나 조회하는 데이터를 볼 수 있게 허용할지 말지를 결정하는 것이다.
  격리 수준은 크게 "READ UNCOMMITTED". "READ COMMITTED", "REPEATABLE READ"."SERIALIZABLE"의 4가지로 나뉜다.
  "DIRTY READ"라고도 하는 READ UNCOMMITTED는 일반적인 데이터베이스에서는 거의 사용하지 않고,
  SERIALIZABLE 또한 동시성이 중요한 데이터베이스에서는 거의 사용되지 않는다.
  4개의 격리 수준에서 순서대로 뒤로 갈수록 각 트랜잭션 간의 데이터 격리(고립) 정도가 높아지며,
  동시 처리 성능도 떨어지는 것이 일반적이라고 볼 수 있다.
  격리 수준이 높아질수록 MySQL 서버의 처리 성능이 많이 떨어질 것으로 생각하는 사용자가 많은데,
  사실 SERIALIZABLE 격리 수준이 아니라면 크게 성능의 개선이나 저하는 발생하지 않는다.

  데이터베이스의 격리 수준을 이야기하면 항상 함께 언급되는 세 가지 부정합의 문제점이 있다.
  이 세가지 부정합의 문제는 격리 수준의 레벨에 따라 발생할 수도 있고 발생하지 않을 수도 있다.

  +------------------+------------+---------------------+----------------------+
  |                  | DIRTY READ | NON-REPEATABLE READ | PHANTOM READ         |
  +------------------+------------+---------------------+----------------------+
  | READ UNCOMMITTED | 발생       | 발생                | 발생                 |
  | READ COMMITTED   | 없음       | 발생                | 발생                 |
  | REPEATABLE READ  | 없음       | 없음                | 발생 (InnoDB는 없음) |
  | SERIALIZABLE     | 없음       | 없음                | 없음                 |
  +------------------+------------+---------------------+----------------------+

  SQL-92 또는 SQL-99 표준에 따르면 REPEATABLE READ 격리 수준에서는 PHANTOM READ가 발생할 수 있지만,
  InnoDB에서는 독특한 특성 때문에 REPEATABLE READ 격리 수준에서도PHANTOM READ가 발생하지 않는다.
  DIRTY READ나 NON-REPEATABLE READ, PHANTOMREAD에 대한 내용은 각 격리 수준별 설명에서 소개하겠다.
  일반적인 온라인 서비스 용도의 데이터베이스는 READ COMMITTED와 REPEATABLE REAT 중 하나를 사용한다.
  오라클 같은 DBMS에서는 주로 READ COMMITTED 수준을 많이 사용하며, MySQL에서는 REPEATABLE READ를 주로 사한다.
  여기서 설명하는 SQL 예제는 모두 AUTOCOMMIT이 OFF인 상태(SET autocommit=OFF)에서만 테스트할 수 있다.

5.4.1 READ UNCOMMITTED

  READ UNCOMMITTED 격리 수준에서는 그림 5.3과 같이 각 트랜잭션에서의
  변경 내용이 COMMIT이나 ROLLBACK 여부에 상관없이 다른 트랜잭션에서 보인다.
  그림 5.3은 다른 트랜잭션이 사용자 B가 실행하는 SELECT 쿼리의 결과에 어떤 영향을 미치는지를 보여주는 예제다.

  사용자 A                                                            사용자 B
      |    BEGIN                                                          |
      +------------------->                                               |
      |                     테이블 (employees)                            |
      |                     emp_no first_naine                            |
      |    INSERT(Lara)     499999 Francesca                              |
      +-------------------> 500000 Lara                                   |
      |                     테이블 (employees)                            |
      |                     emp_no first_name  SELECT WHERE emp_no=500000 |
      |                     499999 Francesca   +--------------------------|
      |                     500000 Lara        |     결과 1건 반환        |
      |                                        +------------------------->|
      |                     테이블 (employees)                            |
      |                     emp no first name                             |
      |    COMMIT(Lara)     499999 Francesca                              |
      +-------------------> 500000 Lara                                   |
      V                                                                   V

  그림 5.3 READ UNCOMMITTED

  그림 5.3에서 사용자 A는 emp_no가 500000이고 first_name이 "Lara"인 새로운 사원을 INSERT한다.
  사용자 B가 변경된 내용을 커밋하기도 전에 사용자 B는 emp_no=500000인 사원을 검색하고 있다.
  하지만 사용자 B는 사용자 A가 INSERT한 사원의 정보를 커밋되지 않은 상태에서도 조회할 수 있다.
  그런데 문제는 사용자 A가 처리 도중 알 수 없는 문제가 발생해 INSERT된 내용을 롤백한다고 하더라도
  여전히 사용자 B는 "Lara"가 정상적인 사원이라고 생각하고 계속 처리할 것이라는 점이다.

  이처럼 어떤 트랜잭션에서 처리한 작업이 완료되지 않았는데도 다른 트랜잭션에서 볼 수 있는 현상을 더티 리드(Dirty read)라 하고,
  더티 리드가 허용되는 격리 수준이 READ UNCOMMITTED다.
  디티 리드 현상은 데이터가 나타났다가 사라졌다 하는 현상을 초래하므로 애플리케이션 개발자와 사용자를 상당히 혼란스럽게 만들 것이다.
  또한 더티 리드를 유발하는 READ UNCOMMITTED는 RDBMS 표준에서는
  트랜잭션의 격리 수준으로 인정하지 않을 정도로 정합성에 문제가 많은 격리 수준이다.
  MySQL을 사용한다면 최소한 READ COMMITTED 이상의 격리 수준을 사용할 것을 권장한다.

5.4.2 READ COMMITTED

  READ COMMITTED는 오라클 DBMS에서 기본으로 사용되는 격리 수준이며,
  온라인 서비스에서 가장 많이 선택되는 격리 수준이다.
  이 레벨에서는 위에서 언급한 더티 리드(Dirty read) 같은 현상은 발생하지 않는다.
  어떤 트랜잭션에서 데이터를 변경했더라도 COMMIT이 완료된 데이터만 다른 트랜잭션에서 조회할 수 있기 때문이다.
  그림 5.4는 READ COMMITTED 격리 수준에서 사용자 A가 변경한 내용이 사용자 B에게 어떻게 조회되는지 보여준다.

  사용자 A                                                              사용자 B
      |                                                                      |
      |                       테이블 (employees)                             |
      |                       emp_no first_naine                             |
      |                       499999 Francesca                               |
      | BEGIN                 500000 Lara                                    |
      +--------------------->                                                |
      | UPDATE                테이블 (employees)                             |
      | SET first name='Toto' emp_no first_name                              |
      +---------------------> 499999 Francesca    SELECT WHERE emp_no=500000 |
      |   변경 전         +-- 500000 Toto       +----------------------------|
      | 데이터를 언두     |     언두 로그       |                            |
      |  로그로 복사      |   emp_no first_name |                            |
      |                   +-> 500000 Lara       +--------------------------->|
      |                                           테이블이 아닌 언두 로그    |
      |                                             데이터 ('Lara') 반환     |
      |                       테이블 (employees)                             |
      |                       emp no first name                              |
      | COMMIT(Toto)          499999 Francesca                               |
      +---------------------> 500000 Toto                                    |
      V                                                                      V

  그림 5.4 READ COMMITTED

  그림 5.4에서 사용자 A는 emp_no=500000인 사원의 first_name을 "Lara"에서 "Toto"로 변경했는데,
  이때 새로운 값인 "Toto"는 employees 테이블에 즉시 기록되고 이전 값인 "Lara"는 언두 영역으로 백업 된다.
  사용자 A가 커밋을 수행하기 전에 사용자 IB가 emp_no=500000인 사원을 SELECT하면
  조회된 결과의 first_name 칼럼의 값은 "Toto"가 아니라 "Laral"로 조회된다.
  여기서 사용자 B의 SELECT 쿼리 결과는 employees 테이블이 아니라 언두 영역에 백업된 레코드에서 가져온 것이다.
  READ COMMITTED격리 수준에서는 어떤 트랜잭션에서 변경한 내용이 커밋되기 전까지는 다른 트랜잭션에서 그러한 변경내역을 조회할 수 없기 때문이다.
  최종적으로 사용자 A가 변경된 내용을 커밋하면 그때부터는 다른 트랜잭션에서도 백업된 언두 레코드(Larra")가 아니라
  새롭게 변경된 "Toto"라는 값을 참조할 수 있게 된다.

  READ COMMITTED 격리 수준에서도 "NON-REPEATABLE READ("REPEATABLE READ"가 불가능하다)라는 부정합의 문제가 있다.

  그림 5.5는 "NON-REPEATABLE READ"가 왜 발생하고 어떤 문제를 만들어낼 수 있는지 보여준다.

  사용자 A                                                                    사용자 B
      |                                                                           |
      |                       테이블 (employees)                            BEGIN |
      |                       emp_no first_naine <--------------------------------|
      |                       499999 Francesca     SELECT WHERE first_name='Toto' |
      |                       500000 Lara        +--------------------------------|
      |                                          |                      결과 없음 |
      |                                          +------------------------------->|
      | BEGIN                                                                     |
      +---------------------> 테이블 (employees)                                  |
      | UPDATE                emp_no first_name                                   |
      | SET first name='Toto' 499999 Francesca                                    |
      +---------------------> 500000 Toto                                         |
      | COMMIT(Toto)                                                              |
      +--------------------->                                                     |
      |                       테이블 (employees)   SELECT WHERE first_name='Toto' |
      |                       emp no first name  +--------------------------------|
      |                       499999 Francesca   |                  결과 1건 반환 |
      |                       500000 Toto        +------------------------------->|
      |                                                                           |
      V                                                                           V

  그림 5.5 NON REPEATABLE READ

  그림 5.5에서 처음 사용자 B가 BEGIN 명령으로 트랜잭션을 시작하고 first_name이 "Toto"인 사용자를 검색했는데,
  일치하는 결과가 없었다.
  하지만 사용자 A가 사원 번호가 500000인 사원의 이름을 Toto"로 변경하고 커밋을 실행한 후,
  사용자 B가 똑같은 SELECT 쿼리로 다시 조회하면 이번에는 결과가 1건이 조회된다.
  이는 별다른 문제가 없어 보이지만,
  사실 사용자 B가 하나의 트랜잭션 내에서 똑같은 SELECT 쿼리를 실행했을 때는
  항상 같은 결과를 가져와야 한다는 "REPEATABLE READ" 정합성에 어긋나는 것이다.

  이러한 부정합 현상은 일반적인 웹 프로그램에서는 크게 문제되지 않을 수 있지만
  하나의 트랜잭션에서 동일 데이터를 여러 번 읽고 변경하는 작업이 금전적인 처리와 연결되면 문제가 될 수도 있다.
  예를 들어, 다른 트랜잭션에서 입금과 출금 처리가 계속 진행될 때 다른 트랜잭션에서 오늘 입금된 금액의 총합을 조회한다고 가정해보자.
  그런데 "REPEATABLE READ"가 보장되지 않기 때문에 총합을 계산하는 SELECT 쿼리는 실행될 때마다 다른 결과를 가져올 것이다.
  중요한 것은 사용 중인 트랜잭션의 격리수준에 의해 실행하는 SQL 문장이 어떤 결과를 가져오게 되는지를 정확히 예측할 수 있어야 한다는 것이다.
  그리고 당연히 이를 위해서는 각 트랜잭션의 격리 수준이 어떻게 작동하는지 알아야 한다.

  가끔 사용자 중에서 트랜잭션 내에서 실행되는 SELECT 문장과 트랜잭션 없이 실행되는 SELECT 문장의 차이를 혼동하는 경우가 있다.
  READ COMMITTED 격리 수준에서는 트랜잭션 내에서 실행되는 SELECT 문장과 트랜잭션 외부에서 실행되는 SELECT 문장의 차이가 별로 없다.
  하지만 REPEATABLEREAD 격리 수준에서는 기본적으로 SELECT 쿼리 문장도 트랜잭션 범위 내에서만 작동한다.
  즉, STARTTRANSACTION(또는 BEGIN) 명령으로 트랜잭션을 시작한 상태에서 온종일 동일한 쿼리를 반복해서 실행해봐도 동일한 결과만 보게 된다
  (아무리 다른 트랜잭션에서 그 데이터를 변경하고 COMMIT을 실행한다고 하더라도 말이다).
  별로 중요하지 않은 차이처럼 보이지만 이런 문제로 데이터의 정합성이 깨지고 그로 인해 애플리케이션에 버그가 발생하면 찾아내기가 쉽지 않다.

5.4.3 REPEATABLE READ

  REPEATABLE READ는 MySQL의 InnoDB 스토리지 엔진에서 기본으로 사용되는 격리 수준이다.
  바이너리 로그를 가진 MySQL 서버에서는 최소 REPEATABLE READ 격리 수준 이상을 사용해야 한다.
  이 격리 수준에서는 READ COMMITTED 격리 수준에서 발생하는 "NON-REPEATABLE READ" 부정합이 발생하지 않는다.
  InnoDB 스토리지 엔진은 트랜잭션이 ROLLBACK될 가능성에 대비해 변경되기 전 레코드를 언두(Undo) 공간에 백업해두고 실제 레코드 값을 변경한다.
  이러한 변경 방식을 MVCC라고 하며,
  이미 앞장에서 한 번 설명한 내용이므로 잘 이해가 되지 않는다면 4.2.3절 MVCC(MultiVersion Concurrency Control)'을 다시 한번 읽어 보자.
  REPEATABLE READ는 이 MVCC를 위해 언두 영역에 백업된 이전 데이터를 이용해 동일 트랜잭션 내에서는 동일한 결과를 보여줄 수 있게 보장한다.
  사실 READ COMMITTED도 MVCC를 이용해 COMMIT되기 전의 데이터를 보여준다.
  REPEATABLE READ와 READ COMMITTED의 차이는 언두 영역에 백업된 레코드의 여러 버전 가운데 몇 번째 이전 버전까지 찾아 들어가야 하느냐에 있다.

  모든 InnoDB의 트랜잭션은 고유한 트랜잭션 번호(순차적으로 증가하는 값)를 가지며,
  언두 영역에 백업된 모든 레코드에는 변경을 발생시킨 트랜잭션의 번호가 포함돼 있다.
  그리고 언두 영역의 백업된 데이터는 InnoDB 스토리지 엔진이 불필요하다고 판단하는 시점에 주기적으로 삭제한다.
  REPEATABLEREAD 격리 수준에서는 MVCC를 보장하기 위해 실행 중인 트랜잭션 가운데 가장 오래된 트랜잭션 빈초보다
  트랜잭션 번호가 앞선 언두 영역의 데이터는 삭제할 수가 없다.
  그렇다고 가장 오래된 트랜잭션 번호 이전의 트랜잭션에 의해 변경된 모든 언두 데이터가 필요한 것은 아니다.
  더 정확하게는 특정 트랜잭션 번호의 구간 내에서 백업된 언두 데이터가 보존돼야 한다.

  그림 5.6은 REPEATABLE READ 격리 수준이 작동하는 방식을 보여준다.
  우선 이 시나리오가 실행되기 전에 employees 테이블은 번호가 6인 트랜잭션에 의해 INSERT됐다고 가정하자.
  그래서 그림 5.6에서 employees 테이블의 초기 두 레코드는 트랜잭션 번호가 6으로 표현된 것이다.
  그림 5.6의 시나리오에서는 사용자 A가 emp_no가 500000인 사원의 이름을 변경하는 과정에서
  사용자 B가 emp_no=500000인 사원을 SELECT할 때 어떤 과정을 거쳐서 처리되는지 보여준다.

  사용자 A                                                                            사용자 B
      |                                                                                   |
      |                               테이블 (employees)                BEGIN(TRX-ID: 10) |
      |                        TRX-ID emp_no first_naine <--------------------------------|
      |                           6   499999 Francesca         SELECT WHERE emp_no=500000 |
      |                           6   500000 Lara        +--------------------------------|
      |                                                  |                 결과 1건(Lara) |
      |                                                  +------------------------------->|
      | BEGIN(TRX-ID: 12)                                                                 |
      +--------------------->         테이블 (employees)                                  |
      | UPDATE                 TRX-ID emp_no first_name                                   |
      | SET first name='Toto'     6   499999 Francesca                                    |
      +--------------------->    12   500000 Toto                                         |
      |                   +-------+                                                       |
      |     변경 전       |             언두 로그                                         |
      |   데이터를 언두   |    TRX-ID emp_no first_name                                   |
      |    로그로 복사    +->     6   500000 Lara                                         |
      |                                                                                   |
      | COMMIT(TRX-ID: 12)                                                                |
      +--------------------->                                                             |
      |                               테이블 (employees)                                  |
      |                        TRX-ID emp no first name                                   |
      |                           6   499999 Francesca         SELECT WHERE emp_no=500000 |
      |                    +--   12   500000 Toto        +--------------------------------|
      |                    |            언두 로그        |                                |
      |                    |   TRX-ID emp_no first_name  |                 결과 1건(Lara) |
      |                    +->    6   500000 Lara        +------------------------------->|
      |                                                                                   |
      |                                                                                   |
      V                                                                                   V

  그림 5.6 REPEATABLE READ

  그림 5.6에서 사용자 A의 트랜잭션 번호는 12였으며 사용자 B의 트랜잭션의 번호는 10이었다.
  이때 사용자 A는 사원의 이름을 "Toto"로 변경하고 커밋을 수행했다.
  그런데 A 트랜잭션이 변경을 수행하고 커밋을 했지만,
  사용자 B가 emp_no=500000인 사원을 A 트랜잭션의 변경 전후 각각 한 번씩 SELECT했는데 결과는 항상 "Lara"라는 값을 가져온다.
  사용자 B가 BEGIN 명령으로 트랜잭션을 시작하면서 10번이라는 트랜잭션 번호를 부여받았는데,
  그때부터 사용자 B의 10번 트랜잭션 안에서 실행되는 모든 SELECT 쿼리는
  트랜잭션 번호가 10(자신의 트랜잭션 번호)보다 작은 트랜잭션 번호에서 변경한 것만 보게 된다.

  그림 5.6에서는 언두 영역에 백업된 데이터가 하나만 있는 것으로 표현했지만 사실 하나의 레코드에 대해 백업이 하나 이상 얼마든지 존재할 수 있다.
  한 사용자가 BEGIN으로 트랜잭션을 시작하고 장시간 트랜잭션을 종료하지 않으면 언두 영역이 백업된 데이터로 무한정 커질 수도 있다.
  이렇게 언두에 백업된 레코드가 많아지면 MySQL 서버의 처리 성능이 떨어질 수 있다.

  REPEATABLE READ 격리 수준에서도 다음과 같은 부정합이 발생할 수 있다.
  그림 5.7에서는 사용자 A가 employees 테이블에 INSERT를 실행하는 도중에
  사용자 B가 SELECT FOR UPDATE 723 employees 테이블을 조회했을 때 어떤 결과를 가져오는지 보여준다.


  사용자 A                                                                            사용자 B
      |                                                                                   |
      |                                                                 BEGIN(TRX-ID: 10) |
      |                                                  <--------------------------------|
      |                               테이블 (employees)       SELECT WHERE emp_no=500000 |
      |                        TRX-ID emp_no first_naine          FOR UPDATE              |
      |                           6   499999 Francesca   +--------------------------------|
      |                           6   500000 Lara        |                 결과 1건(Lara) |
      |                                                  +------------------------------->|
      | BEGIN(TRX-ID: 12)                                                                 |
      +--------------------->         테이블 (employees)                                  |
      | INSET INTO employees   TRX-ID emp_no first_name                                   |
      | (500001, 'Georgi')        6   499999 Francesca                                    |
      +--------------------->     6   500000 Lara                                         |
      |                          12   500001 Georgi                                       |
      | COMMIT(TRX-ID: 12)                                                                |
      +--------------------->                                                             |
      |                                                                                   |
      |                               테이블 (employees)       SELECT WHERE emp_no=500000 |
      |                        TRX-ID emp no first name           FOR UPDATE              |
      |                           6   499999 Francesca   +--------------------------------|
      |                           6   500000 Lara        |                                |
      |                          12   500001 Georgi      |         결과 2건(Lara, Georgi) |
      |                                                  +------------------------------->|
      |                                                                                   |
      V                                                                                   V

  그림 5.7 PHANTOM READ(PHANTOM ROWS)

  그림 5.7 에서 사용자 B는 BEGIN 명령으로 트랜잭션을 시작한 후 SELECT를 수행한다.
  그러므로 그림 5.6의 REPEATABLE READ에서 배운 것치럼 두 번의 SELECT 쿼리 결과는 똑같아야 한다.
  하지만 그림 5.7에서 사용자 B가 실행하는 두 번의 SELECT ... FOR UPDATE 쿼리 결과는 서로 다르다.
  이렇게 다른 트랜전에서 수행한 변경 작업에 의해 레코드가 보였다 안 보였다 하는 현상을 READ(또는 PHANTOM ROW)한다.
  SELECT ... FOR UPDATE 쿼리는 SELECT하는 레코드에 쓰기 잠금을 걸야 하는데, 언두 레코드에는 잠금을 걸 수 없다.
  그래서 SELECT ... FOR UPDATE나 SELECT ... LOCK IN SHAKE MODE로 조회되는 레코드는
  언두 영역의 변경 전 데이터를 가져오는 것이 아니라 레코드의 값을 가져오게 되는 것이다.

5.4.4 SERIALIZABLE

  SELECT 가장 단순한 격리 수준이면서 동시에 가장 엄격한 격리 수준이다.
  그만큼 동시 처리 성능도 다른 트랜잭션 격리 수준보다 떨어진다.
  InnoDB 테이블에서 기본적으로 순수한 SELECT 작업(INSERT 또는 CREATE TABLE ... AS SELECT ...가 아닌)은
  아무런 레코드 잠금도 설정하지 않고 실행된다.
  InnoDB 매뉴얼에서 자주 나타나는 "Non-locking consistent read(잠금이 필요 없는 일관된 읽기)"라는 말이 이를 의미하는 것이다.
  하지만 트랜잭션의 격리 수준이 SERIALIZABLE로 설정되면 읽기 작업도 공유 잠금(읽기 잠금)을 획득해야만 하며,
  동시에 다른 트랜잭션은 그러한 레코드를 변경하지 못하게 된다.
  즉, 한 트랜잭션에서 읽고 쓰는 레코드를 다른 트랜잭션에서는 절대 접근할 수 없는 것이다.
  SERIALIZABLE 격리 수준에서는 일반적인 DBMS에서 일어나는 "PHANTOM READ" 라는 문제가 발생하지 않는다.
  하지만 InnoDB 스토리지 엔진에서는 갭 락과 넥스트 키 락 덕분에 REPEATABLEREAD 격리 수준에서도
  이미 "PHANTOM READ"가 발생하지 않기 때문에 굳이 SERIALIZABLE을 사용할 필요성은 없어 보인다.

  참고 : 엄밀하게는 "SELECT ... FOR UPDATE" 또는 "SELECT ... FOR SHARE" 쿼리의 경우
         REPEATABLE READ 격리 수준에서 PHANTOM READ 현상이 발생할 수 있다.
         하지만 레코드의 변경 이력(언두 레코드)에 잠금을 걸 수는 없기 때문에,
         이러한 잠금을 동반한 SELECT 쿼리는 예외적인 상황으로 볼 수 있다.

```