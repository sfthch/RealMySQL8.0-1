MySQL 5.7 버전부터 지원되기 시작한 데이터 암호화 기능은 처음에는 데이터 파일(테이블스페이스)에 대해서만 암호화 기능이 제공됐다.
그러다 MySQL 8.0으로 업그레이드되면서 데이터 파일뿐만 아니라 리두 로그나 언두 로그,
복제를 위한 바이너리 로그 등도 모두 암호화 기능을 지원하기 시작했다.

데이터 암호화 여부는 보안 감사에서 필수적으로 언급되는 부분이며,
핀테크 서비스처럼 중요한 정보를 저장하는 서비스에서는 응용 프로그램에서 암호화한 데이터를
데이터베이스 서버에서 다시 암호화하는 이중 암호화 방법을 선택하기도 한다.
응용 프로그램의 암호화는 주로 중요 정보를 가진 칼럼 단위로 암호화를 수행하며,
데이터베이스 수준에서는 테이블 단위로 암호화를 적용한다.

7.1 MySQL 서버의 데이터 암호화

  MySQL 서버의 암호화 기능은 그림 7.1에서와같이 데이터베이스 서버와 디스크 사이의 데이터 읽고 쓰기 지점에서 암호화 또는 복호화를 수행한다.
  그래서 MySQL 서버에서 디스크 입출력 이외의 부분에서는 암호화 처리가 전혀 필요치 않다.
  즉, MySQL 서버(InnoDB 스토리지 엔진)의 I/O 레이어에서만 데이터의 암호화 및 복호화 과정이 실행되는 것이다.

  MySQL 서버 InnoDB 스토리지 엔진 InnoDB I/O 2010 디스크 데이터 파일

  그림 7.1 MySQL 서버의 디스크 입출력

  MySQL 서버에서 사용자의 쿼리를 처리하는 과정에서 테이블의 데이터가 암호화돼 있는지 여부를 식별할 필요가 없으며,
  암호화된 테이블도 그렇지 않은 테이블과 동일한 처리 과정을 거친다.
  데이터 암호화 기능이 활성화돼 있다고 하더라도 MySQL 내부와 사용자 입장에서는 아무런 차이가 없기 때문에
  이러한 암호화 방식을 가리켜 TDE(Transparent Data Encryption)이라고 한다.
  또한 Data at Rest Encryption"라고도 하는데,
  여기서 "Data at Rest"는 메모리(In-Process)나 네트워크 전송(InTransit) 단계가 아닌
  디스크에 저장(At Rest)된 단계에서만 암호화된다는 의미로 사용되는 표현이다.
  MySQL 서버에서는 둘 모두 거의 동일한 표현으로 사용되지만 MySQL 매뉴얼에서는 TDE라는 표현을 사용한다.

7.1.1 2단계 키 관리

  MySQL 서버의 TDE에서 암호화 키는 키링(KeyRing) 플러그인에 의해 관리되며,
  MySQL 8.0 버전에서 지원되는 키링 플러그인은 다음과 같다.
  하지만 MySQL 커뮤니티 에디션에서는 keyring_file 플러그인만 사용 가능하고,
  나머지 플러그인은 모두 MySQL 엔터프라이즈 에디션에서만 사용 가능하다.

    - keyring_file File Based                   플러그인
    - keyring_encrypted_file Keyring            플러그인
    - keyring_okv KMIP                          플러그인
    - keyring_aws Amazon Web Services Keyring   플러그인

  다양한 플러그인이 제공되지만 마스터 키를 관리하는 방법만 다를 뿐 MySQL 서버 내부적으로 작동하는 방식은 모두 동일하다.
  MySQL 서버의 키링 플러그인은 2단계(2-Tier) 키 관리 방식을 사용하는데,
  그림 7.2는 2단계 키 관리 아키텍처를 보여준다.

  마스터 키키링 플러그인 MySQL 서버 Nkeyring_file KEY HashiCorpMySQL 플러그인 서비스 VVaultskeyring vault InnoDB A 212 01121 I/O 핸들러 디스크테이블스페이스 키 암호화되지 않은 데이터 파일 암호화된 데이터 파일

  그림 7.2 2단계 암호화 아키텍처

  MySQL 서버의 데이터 암호화는 마스터 키(naster key)와 테이블스페이스 키(tablespace key)라 두 가지 종류의 키를 가지고 있는데,
  테이블스페이스 키는 프라이빗 키(private key)라고도 한다.
  그림 7.2에서 보는 바와 같이 MySQL 서버는 HasliCorp Vault 같은 외부 키 관리 솔루션(KMS, KuryManagement Service) 또는
  디스크의 파일(keyring_file 또는 keyring_encrypted_file 플러그인 사용시)에서 마스터 키를 가져오고,
  암호화된 테이블이 생성될 때마다 해당 테이블을 위한 임의의 테이블스페이스 키를 발급한다.
  그리고 MySQL 서버는 마스터 키를 이용해 테이블스페이스키를 암호화해서 테이블의 데이터 파일 헤더에 저장한다.
  이렇게 생성된 테이블스페이스 키는 테이블이 삭제되지 않는이상 절대 변경되지 않는다.
  하지만 테이블스페이스 키는 절대 MySQL 서버 외부로 노출되지 않기 때문에
  테이블스페이스 키를 주기적으로 변경하지 않아도 보안상 취약점이 되지는 않는다.

  하지만 마스터 키는 외부의 파일을 이용하기 때문에 노출될 가능성이 있다.
  그래서 마스터 키는 주기적으로 변경해야 한다.
  MySQL 서버의 마스터 키는 다음과 같이 변경할 수 있다.

  mysql> ALTER INSTANCE ROTATE INNODB MASTER KEY;

  마스터 키를 변경하면 MySQL 서버는 기존의 마스터 키를 이용해 각 테이블의 테이블스페이스 키를복호화한 다음 새로운 마스터 키로 다시 암호화한다.
  마스터 키가 변경되는 동안 MySQL 서버의 테이블스페이스 키 자체와 데이터 파일의 데이터는 전혀 변경되지 않는다.
  MySQL 서버에서 이렇게 2단계암호화 방식을 사용하는 이유는 암호화 키 변경으로 인한 과도한 시스템 부하를 피하기 위해서다.
  테이블스페이스 키가 변경된다면 MySQL 서버는 데이터 파일의 모든 데이터를 다시 복호화했다가 다시 암호화해야 한다.
  이로 인해 키를 변경할 때마다 엄청난 작업을 해야 하며, 사용자 쿼리를 처리하는 데도상당한 영향을 미치게 된다.

  MySQL 서버의 TDE에서 지원되는 암호화 알고리즘은 AES 256비트이며, 이외의 알고리즘은 지원되지 않는다.
  테이블스페이스 키는 AES-256 ECB(Electronic CodeBook)   알고리즘을 이용해 암호화되고,
  실제 데이터 파일은  AES-256 CBC(Cipher Block Chaining) 알고리즘을 이용해 암호화된다.

7.1.2 암호화와 성능

  MySQL 서버의 암호화는 TDE(Transparent Data Encryption) 방식이기 때문에
  디스크로부터 한 번읽은 데이터 페이지는 복호화되어 InnoDB의 버퍼 풀에 적재된다.
  그래서 데이터 페이지가 한 번 메모리에 적재되면 암호화되지 않은 테이블과 동일한 성능을 보인다.
  하지만 쿼리가 InnoDB 버퍼 풀에 존재하지 않는 데이터 페이지를 읽어야 하는 경우에는
  복호화 과정을 거치기 때문에 복호화 시간 동안 쿼리 처리가 지연될 것이다.
  그리고 암호화된 테이블이 변경되면 다시 디스크로 동기화될 때 암호화돼야 하기 때문에 디스크에 저장할 때도 추가로 시간이 더 걸린다.
  하지만 데이터 페이지 저장은 사용자의 쿼리를 처리하는 스레드가 아닌
  MySQL 서버의 백그라운드 스레드가 수행하기 때문에 실제 사용자 쿼리가 지연되는 것은 아니다.
  SELECT뿐만 아니라 UPDATE, DELETE 명령 또한 변경하고자 하는 레코드를 InnoDB 버퍼 풀로 읽어와야 하기 때문에
  새롭게 디스크에서 읽어야 하는 데이터 페이지의 개수에 따라서 그만큼의 복호화 지연이 발생한다.

  AES(Advanced Encryption Standard) 암호화 알고리즘은 암호화하고자 하는 평문의 길이가 짧은 경우
  암호화 키의 크기에 따라 암호화된 결과의 용량이 더 커질 수도 있지만,
  이미 데이터 페이지는 암호화 키보다 훨씬 크기 때문에 암호화 결과가 평문의 결과와 동일한 크기의 암호문을 반환한다.
  그래서 TDE를 적용한다고 해도 데이터 파일의 크기는 암호화되지 않은 테이블과 동일한 크기를 가진다.
  즉 암호화한다고 해서 InnoDB 버퍼 풀의 효율이 달라지거나 메모리 사용 효율이 떨어지는 현상은 발생하지 않는다.

  같은 테이블에 대해 암호화와 압축이 동시에 적용되면 MySQL 서버는 압축을 먼저 실행하고 암호화를 적용한다.
  압축이 암호화보다 먼저 실행되는 이유는 다음과 같다.

    - 일반적으로 암호화된 결과문은 아주 랜덤한 바이트의 배열을 가지게 되는데, 이는 압축률을 상당히 떨어뜨린다.
      그래서 최대한 압축 효율을 높이기 위해 사용자의 데이터를 그대로 압축해서 용량을 최소화한 후 암호화를 적용한다.
    - 또한 암호화된 테이블의 데이터 페이지는 복호화된 상태로 InnoDB 버퍼 풀에 저장되지만,
      압축된 데이터 페이지는 압축 또는 압축 해제의 모든 상태로 InnoDB 버퍼 풀에 존재할 수 있다.
      그래서 암호화가 먼저 실행되고 압축이 적용된다면 MySQL 서버는 InnoDB 버퍼 풀에 존재하는
      데이터 페이지에 대해서도 매번 암복호화 작업을 수행해야 된다.

  다음 표는 암호화된 테이블과 그렇지 않은 테이블의 디스크 읽고 쓰기에 걸리는 평균 시간을 수집한 정보다.
  물론 수집된 정보에는 어느 정도 오차는 있겠지만 암호화된 테이블의 경우 읽기는 3~5배 정도 느리며,
  쓰기의 경우에는 5~6배 정도 느린 것을 확인할 수 있다.
  물론 밀리초 단위이므로 수치가 워낙 낮은 편이어서 크게 체감되지는 않을 수도 있다.

  암호화 테이블명 테이블 크기(GB) Read Latency(ms) Write Latency(ms) table_1 1.3 0.56 0.02 table_2 2.7 0.16 0.02 No table_3 3.7 0.49 0.02 table_4 106.6 0.34 0.02 table_5 141.0 0.25 0.02 table_6 2.0 1.19 0.11 Yes table_7 4.8 1.50 0.13 table_8 206.5 1.44 0.12

  참고 : 앞의 표에 보이는 디스크 읽고 쓰기 속도는 performance_schema의 file_summary_by_instance 테이블에
         수집된 결과를 이용해 다음의 쿼리로 조회했다.
         암호화된 테이블의 읽고 쓰기 성능을 직접 확인해보고자 한다면 다음 쿼리를 활용하면 된다.

  mysql> SELECT ( SUM(SUM_TIMER_READ)
                / SUM(COUNT_READ)
                ) / 1000000000 as avg_read_latency_ms
              , ( SUM(SUM_TIMER_WRITE)
                / SUM(COUNT_WRITE)
                ) / 1000000000 as avg_write_latency_ms
           FROM performance_schema.file_summary_by_instance
          WHERE file_name LIKE '%DB_NAME/TABLE_NAME%'
         ;

7.1.3 암호화와 복제

  MySQL 서버의 복제에서 레플리카 서버는 소스 서버의 모든 사용자 데이터를 동기화하기 때문에 실제 데이터 파일도 동일할 것이라 생각할 수 있다.
  하지만 TDE를 이용한 암호화 사용 시 마스터 키와 테이블스페이스 키는 그렇지 않다.
  MySQL 서버에서 기본적으로 모든 노드는 각자의 마스터 키를 할당해야 한다.
  데이터베이스 서버의 로컬 디렉터리에 마스터 키를 관리하는 경우에는
  소스 서버와 레플리카 서버가 다른 키를 가질 수밖에 없겠지만 원격으로 키 관리 솔루션을 사용하는 경우에도
  소스 서버와 레플리카 서버는 서로 다른 마스터 키를 갖도록 설정해야 한다.
  마스터 키 자체가 레플리카로 복제되지 않기 때문에 테이블스페이스 키 또한 레플리카로 복제되지 않는다.
  결국 소스 서버와 레플리카 서버는 서로 각자의 마스터 키와 테이블스페이스 키를 관리하기 때문에
  복제 멤버들의 데이터 파일은 암호화되기 전의 값이 동일하더라도 실제 암호화된 데이터가 저장된 데이터 파일의 내용은 완전히 달라진다.

  복제 소스 서버의 마스터 키를 변경할 때는 ALTER INSTANCE ROTATE INNODB MASTER KEY 냉령을 실행하는데,
  이때 ALTER INSTANCE ROTATE INNODB MASTER KEY 명령 자체는 레플리카 서비로 복제되지만
  실제 소스버의 마스터 키 자체가 레플리카 서버로 전달되는 것은 아니다.
  그래서 마스터 키 로테이션을 실행하면 소스 서버와 레플리카 서버가 각각 서로 다른 마스터 키를 새로 발급받는다.
  MySQL 서비의 백업에서 TDE의 키링(Key Ring) 파일을 백업하지 않는 경우가 있는데,
  이 경우 키링 파일을 찾지 못하면 데이터 복구를 할 수 없게 된다.
  키링 파일을 데이터 백업과 별도로 백업한다면 마스터 키 로테이션 명령으로 TDE의 마스터 키가 언제 변경됐는지까지 기억하고 있어야 한다.
  물론 보안을 위해 키링 파일을 데이터 파일과 별도로 보관하는 것을 권장하지만 복구를 감안하고 백업 방식을 선택해야 한다.
  이미 언급한 바와 같이 마스터 키도 계속 변경될 수 있기 때문에 백업마다 키링 파일의 백업도 함께 고려하자.

7.2 keyring_file 플러그인 설치

  MySQL 서버의 데이터 암호화 기능인 TDE의 암호화 키 관리는 플러그인 방식으로 제공된다.
  MySQL 엔터프라이즈 에디션에서 사용할 수 있는 플러그인은 다양하지만 MySQL 커뮤니티 에디션에서는 keyring_file 플러그인만 가능하다.
  여기서는 keyring_file 플러그인을 설치하고 사용하는 방법을 간단히 살펴보겠다.
  우선 keyring_file 플러그인은 테이블스페이스 키를 암호화하기 위한 마스터 키를 디스크의 파일로 관리하는데,
  이때 마스터 키는 평문으로 디스크에 저장된다. 즉 마스터 키가 저장된 파일이 외부에 노출된다면 데이터 암호화는 무용지물이 된다.

  주의 : keyring_file 플러그인은 마스터 키를 암호화하지 않은 상태의 평문으로 로컬 디스크에
         저장하기 때문에 그다지 보안 요건을 충족시켜주진 않는다.
         그럼에도 꼭 keyring_file 플러그인을 사용하고자 한다면
         MySQL 서버가 시작될 때만 키링 파일을 다른 서버로부터 다운로드해서
         로컬 디스크에 저장한 후 MySQL 서버를 시작하는 방법을 고려해보자.
         그리고 일단 MySQL 서버가 시작되면 MySQL 서버가 마스터 키를 메모리에 캐시하기 때문에
         로컬 디스크의 키링 파일을 삭제해도 MySQL 서버가 작동하는 데는 아무런 문제가 없다.
         마스터 키를 로테이션하는 경우에는 로컬의 키링 파일이 최신이 되므로 다시 외부 서버에 복사해 둬야 한다.

         Percona Server'는 HashiCorp Vault 를 연동하는 키 관리 플러그인을 오픈소스로 제공한다.
         MySQL 커뮤니티 에디션에서도 문제없이 사용할 수 있으므로
         Percona Server의 keyring_vault 플러그인도 함께 검토해볼 것을 권장한다.

  MySQL 서버의 다른 플러그인과는 달리,
  TDE 플러그인의 경우 MySQL 서버가 시작되는 단계에서도가장 빨리 초기화돼야 한다.
  그래서 다음과 같이 MySQL 서버의 설정 파일(my.cnf)에서
  early-pluginload 시스템 변수에 keyring_file 플러그인을 위한 라이브러리("keyring_file.so")를 명시하면 된다.
  그리고 keyring_file 플러그인이 마스터 키를 저장할 키링 파일의 경로를 keyring_file_data 설정에 명시하면 된다.
  keyring_file_data 설정의 경로는 오직 하나의 MySQL 서버만 참조해야 한다.
  하나의 리눅스 서버에 MySQL 서버가 2개 이상 실행 중이라면 각 MySQL 서버가 서로 다른 키링 파일을 사용하도록 설정해야 한다.

  early-plugin-load = keyring_file.so keyring_file_data = /very/secure/directory/tde_master.key

  MySQL 서버의 설정 파일이 준비되면 MySQL 서버를 재시작하면 자동으로 keyring_file 플러그인이초기화된다.
  keyring_file 플러그인의 초기화 여부는 다음과 같이 SHOW PLUGINS 명령으로 확인 가능하다.

  mysql> SHOW PLUGINS;

  Name Status | Type | Library { License | ACTIVE KEYRING { keyring_file | binlog { mysql_native_password { keyring_file.so | GPL I NULL | GPL ACTIVE STORAGE ENGINE ACTIVE | AUTHENTICATION NULL | GPL

  keyring_file 플러그인이 초기화되면 MySQL 서버는 플러그인의 초기화와 동시에 keyring_file_data시스템 변수의 경로에 빈 파일을 생성한다.
  플러그인만 초기화된 상태일 뿐, 아직 마스터 키를 사용한적이 없기 때문에 실제 키링 파일의 내용은 비어 있다.
  데이터 암호화 기능을 사용하는 테이블을 생성하거나 마스터 로테이션을 실행하면 키링 파일의 마스터 키가 초기화된다.

  linux) ls -alh tde_master. key -rw-r----- 1 matt OB 7 27 14:24 tde_master. key

  mysql) ALTER INSTANCE ROTATE INNODB MASTER KEY;

  | 202 Real MySQL 8.0: 개발자와 DBA를 위한 MySQL 실전 가이드


  linux) ls -alh tde_master. key 1 matt 1878 7 27 14:24 tde_master.key -w-r-----

  참고 : ALTER INSTANCE ROTATE INNODB MASTER KEY 명령을 실행하고 바이너리 로그의 내용을 살펴보면 다음과 같이 표시된다.
         바이너리 로그의 내용에서 "ALTER INSTANCE ROTATE INNODB MASTER KEY" 이벤트는 Event_type 칼럼값이 "Query"인 것을 알 수 있다.
         즉 마스터 키 로테이션을 실행하면 SQL 문장이 레플리카 서버로 전달되며,
         이는 실제 새로 생성된 마스터 키의 값이 바이너리 로그로 전달되지 않음을 의미한다.
         가독성을 위해 SHOW BINLOG 명령의 결과에서 일부 내용은 삭제했으므로 결과는 다음과 같지 않을 수 있다.

  mysql> SHOW BINLOG EVENTS IN 'mysql-bin.000010';

  | Pos | Event_type { Log_name | Info { mysql-bin.000010 4 | Format_desc | Server ver: 8.0.21, Binlog ver: 4 { mysql-bin.000010 | 125 | Previous_gtids | { mysql-bin.000010 | 156 | Anonymous_Gtid | SET @OSESSION. GTID_NEXT= 'ANONYMOUS' { mysql-bin.000010 | 233 | Query | ALTER INSTANCE ROTATE INNODB MASTER KEY

7.3 테이블 암호화

  키링 플러그인은 마스터 키를 생성하고 관리하는 부분까지만 담당하기 때문에
  어떤 키링 플러그인을 사용하든 관계없이 암호화된 테이블을 생성하고 활용하는 방법은 모두 동일하다.

7.3.1 테이블 생성

  TDE를 이용하는 테이블은 다음과 같이 생성할 수 있다.

  mysql> CREATE TABLE tab_encrypted
         ( id      INT
         , data    VARCHAR(100)
         , PRIMARY KEY(id)
         ) ENCRYPTION='Y'
         ;

  mysql> INSERT INTO tab_encrypted VALUES (1, 'test_data');

  mysql> SELECT * FROM tab_encrypted;

  +----

  { id | data

  +--

  1 | test_data |

  일반적인 테이블 생성 구문과 동일하며, 마지막에 "ENCRYPTION=Y" 옵션만 추가로 넣으면 된다.
  그러면 이제부터 이 테이블의 데이터가 디스크에 기록될 때는 데이터가 자동으로 암호화되어 저장되고,
  다시 디스크에서 메모리로 읽어올 때 복호화된다.
  MySQL 서버에서 암호화된 테이블만 검색할 때는 information_schema의 TABLES 뷰를 이용하면 된다.

  mysql> SELECT table_schema
              , table_name
              , create_options
           FROM information_schema.tables
          WHERE table_name = 'tab_encrypted'
         ;
         +--------------+---------------+----------------+
         | TABLE_SCHEMA | TABLE_NAME    | CREATE_OPTIONS |
         +--------------+---------------+----------------+
         | test         | tab_encrypted | ENCRYPTION='Y' |
         +--------------+---------------+----------------+

  테이블을 생성할 때마다 ENCRYPTION 옵션을 설정하면 실수로 암호화 적용을 잊어버릴 수도 있다.
  MySQL 서버의 모든 테이블에 대해 암호화를 적용하고자 한다면 default_table_encryption 시스템 변수를
  ON으로 설정하면 ENCRYPTION 옵션을 별도로 설정하지 않아도 암호화된 테이블로 생성된다.

7.3.2 응용 프로그램 암호화와의 비교

  응용 프로그램에서 직접 암호화해서 MySQL 서버에 저장하는 경우도 있는데,
  이 경우 저장되는 칼럼의 값이 이미 암호화된 것인지 여부를 MySQL 서버는 인지하지 못한다.
  그래서 응용 프로그램에서 암호화된 칼럼은 인덱스를 생성하더라도 인덱스의 기능을 100% 활용할 수 없다.
  다음과 같은 테이블의 인덱스를 한번 생각해보자.

  mysql) CREATE TABLE app_user
         ( id             BIGINT
         , enc_birth_year VARCHAR (50) /* 응용 프로그램에서 미리 암호화해서 저장된 칼럼 *
         ...
         , PRIMARY KEY (id)
         , INDEX ix_birthyear (birth_year)
         ) ;

  app_user테이블은 암호화되지 않았지만 enc_birth_year 칼럼은 응용 프로그램에서 이미 암호화해서 app_user 테이블에 저장됐다.
  이제 app_user 테이블에서 다음 2개의 쿼리 문장을 한번 생각해보자.

  mysql> SELECT * FROM app_user WHERE enc_birth_year=#{encryptedyear} ;
  mysql> SELECT * FROM app_user WHERE enc_birth_year BETWEEN #{encryptedMinYear} AND #{encryptedMaxYear} ;
  mysql> SELECT * FROM app_user ORDER BY enc_birth_year LIMIT 10 ;

  첫 번째 쿼리는 동일 값만 검색하는 쿼리이기 때문에 "enc_birth_year=#{encryptedYear}" 조건으로 검색할 수 있다.
  하지만 출생 연도 범위의 사용자를 검색한다거나 출생 연도를 기준으로 정렬해서 상위 10개만 가져오는 등의 쿼리는 사용할 수가 없다.
  MySQL 서버는 이미 암호화된 값을 기준으로 정렬했기 때문에 암호화되기 전의 값을 기준으로 정렬할 수가 없다.
  하지만 응용 프로그램에서 직접 암호화하지 않고 MySQL 서버의 암호화 기능(TDE)을 사용한다면
  MySQL 서버는 인덱스 관련된 작업을 모두 처리한 후 최종 디스크에 데이터 페이지를 저장할 때만 암호화하기 때문에 이 같은 제약은 없다.

  응용 프로그램의 암호화와 MySQL 서버의 암호화 기능 중 선택해야 하는 상황이라면
  고민할 필요 없이 MySQL 서버의 암호화 기능을 선택할 것을 권장한다.
  물론 응용 프로그램의 암호화와 MySQL 서버의 암호화는 목적과 용도가 조금 다르다.
  MySQL 서버의 TDE 기능으로 암호화한다면 실행 중인 MySQL 서버에 로그인만 할 수 있다면 모든 데이터를 평문으로 확인할 수 있다.
  하지만 응용 프로그램 암호화는 MySQL 서버에 로그인할 수 있다고 하더라도 평문의 내용을 확인할 수 없다.
  그래서 응용 프로그램에서의 암호화 기능은 서비스의 요건과 성능을 고려해서 선택해야 하고,
  MySQL 서버의 암호화 기능과 혼합해서 사용한다면 더 안전한 서비스를 구축할 수 있을 것이다.

7.3.3 테이블스페이스 이동

  MySQL 서버의 데이터베이스 관리자라면 테이블스페이스만 이동하는 기능을 자주 사용하게 될 것이다.
  테이블을 다른 서버로 복사해야 하는 경우 또는 특정 테이블의 데이터 파일만 백업했다가 복구하는 경우라면
  테이블스페이스 이동(Export & Inport) 기능이 레코드를 덤프했다가 복구하는 방식보다 훨씬 효율적이고 빠르다.

  그런데 TDE가 적용되어 암호화된 테이블의 경우 원본 MySQL 서버와 목적지 MySQL 서버의 암호화 키(마스터 키)가 다르기 때문에
  하나 더 신경 써야 할 부분이 있다. MySQL 서버에서 다음과 같이 FLUSH TABLES 명령으로 테이블스페이스를 익스포트(Export)할 수 있다.

  mysql> FLUSH TABLES source_table FOR EXPORT;

  이 명령이 실행되면 MySQL 서버는 Source_table의 저장되지 않은 변경 사항을 모두 디스크로 기록하고,
  더이상 source_table에 접근할 수 없게 잠금을 건다.
  그와 동시에 source_table의 구조를 source_table.cfg 파일로 기록해 둔다.
  그러면 source_table.ibd 파일과 source_table.cfg 파일을 목적지 서버로 복사한다.
  복사가 모두 완료되면 UNLOCK TABLES 명령을 실행해 source_table을 사용할 수 있게 하면 된다.
  지금까지의 과정이 암호화되지 않은 테이블의 테이블스페이스 복사 과정이다.

  TDE로 암호화된 테이블에 대해 "FLUSH TABLES source_table FOR EXPORT" 명령을 실행하면
  MySQL 서버는 임시로 사용할 마스터 키를 발급해서 source_table.cfp라는 파일로 기록한다.
  그리고 암호화된 테이블의 테이블스페이스 키를 기존 마스터 키로 복호화한 후,
  임시로 발급한 마스터 키를 이용해 다시 암호화해서 데이터 파일의 헤더 부분에 저장한다.
  그래서 암호화된 테이블의 경우 테이블스페이스 이동 기능을 사용할 때는
  반드시 데이터 파일과 임시 마스터 키가 저장된 *.cfp 파일을 함께 복사해야 한다.
  *.cfg 파일은 단순히 테이블의 구조만 가지고 있기 때문에 파일이 없어져도 경고만 발생하고
  테이블스페이스를 복구할 수 있지만 *.cfp 파일이 없어지면 복구가 불가능해진다.

7.4 언두 로그 및 리두 로그 암호화

  테이블의 암호화를 적용하더라도 디스크로 저장되는 데이터만 암호화되고 MySQL 서버의 메모리에 존재하는 데이터는 복호화된 평문으로 관리되며,
  이 평문 데이터가 테이블의 데이터 파일 이외의 디스크 파일로 기록되는 경우에는 여전히 평문으로 저장된다.
  그래서 테이블 암호화를 적용해도 리두 로그나 언두 로그, 그리고 복제를 위한 바이너리 로그에는 평문으로 지장되는 것이다.
  MySQL. 8.010 버진부터는 innodb_undo_log_encrypt 시스템 변수와 innodb_redo_log_encrypt 시스템 변수를 이용해
  InnoDB 스토리지 엔진의 리두 로그와 인두 로그를 암호화된 상태로 저장할 수 있게 개선됐다.

  테이블의 암호화는 일단 테이블 하나에 대해 암호화가 적용되면 해당 테이블의 모든 데이터가 암호화 대야 한다.
  하지만 리두 로그나 언두 로그는 그렇게 적용할 수가 없다.
  즉 실행 중인 MySQL 서버에서 언두 로그나 리두 로그를 활성화한다고 하더라도
  모든 리두 로그나 인두 로그의 데이터를 해당 시점에 한 번에 암호화해서 다시 지장할 수 없다.
  그래서 MySQL 서버는 리두 로그나 언두 로그를 평문으로 지장하다가 암호화활성화되면
  그때부터 생성되는 리두 로그나 언두 로그만 암호화해서 저장한다.
  반대로 리두 로그와 언두 로그가 암호화되는 상태에서 암호화를 비활성화하면 그때부터 저장되는 로그만 평문으로 저장한다.
  그래서 리두 로그와 언두 로그는 암호화를 활성화했다가 비활성화한다고 해서 즉시 암호화에 사용된 키가 불필요해지는 것이 아니다.
  특히 언두 로그의 경우 암호화를 비활성화한다고 하더라도 새로 생성되는 언두 로그는 평문으로 저장되겠지만
  기존의 언두 로그는 여전히 암호화된 상태로 남아있다.
  그래서 상황에 따라 며칠 또는 몇 달 동안 여전히 암호화키가 필요할 수도 있다.

  리두 로그와 언두 로그 데이터 모두 각각의 테이블스페이스 키로 암호화되고,
  테이블스페이스 키는 다시 마스터 키로 암호화된다.
  즉 ALTER INSTANCE ROTATE INNODB MASTER KEY 명령이 실행되면 새로운 마스터 키가 발급되고
  테이블 암호화에 사용된 테이블스페이스 키와 동일하게 그 새로운 마스터 키에 의해 다시 암호화된다.
  리두 로그와 언두 로그 데이터의 암호화에 테이블스페이스 키가 사용된다고 했는데,
  여기서 이야기한 테이블스페이스 키는 실제 테이블의 암호화에 사용된 테이블스페이스 키가 아니라
  리두 로그와 언두 로그 파일을 위한 프라이빗 키를 의미한다.
  즉 리두 로그와 언두 로그를 위한 각각의 프라이빗 키가 발급되고,
  해당 프라이빗 키는 마스터 키로 암호화되어 리두 로그 파일과 언두 로그 파일의 헤더에 저장되는 것이다.

  InnoDB 리두 로그가 암호화됐는지는 다음과 같이 간단히 확인할 수 있다.

  mysql> SHOW GLOBAL VARIABLES LIKE 'innodb_redo_log_encrypt';

  { Variable_name

  | Value {

  { innodb_redo_log_encrypt

  | OFF

  mysql> INSERT INTO enc VALUES (2, 'Real-MySQL');

  mysql> SET GLOBAL innodb_redo_log_encrypt=ON; mysql> INSERT INTO enc VALUES (2, 'Real-MongoDB');

  INSERT된 레코드의 문자열이 InnoDB의 리두 로그에 보이는지만 확인해보면 된다.
  grep 명령을 이용한 단순한 검색 결과에서 암호화되기 전에 INSERT한 "Real-MySQL" 문자열은 검색되지만
  암호화 이후 INSERT된 "Real-MongoDB 문자열은 검색되지 않는 것을 확인할 수 있다.

  ## grep 명령의 결과, 문자열이 존재하면 "matches"라는 메시지를 보여준다.
  ## 그리고 검색한 문자열이 존재한다면 grep 명령은 반환 값으로 "0"을 리턴한다.
  linux) grep 'Real-MySQL' ib_logfileo ib_logfile1 Binary file ib_logfile0 matcheslinux) echo $? 0

  ## grep 명령의 결과, 문자열이 존재하지 않으면 아무런 메시지 출력이 없다.
  ### 그리고 검색한 문자열이 존재하지 않으면 grep 명령은 반환 값으로 "1"을 리턴한다.
  linux) grep 'Real-MongoDB' ib_logfileo ib_logfile1linux) echo $? 1

7.5 바이너리 로그 암호화

  테이블 암호화가 적용돼도 바이너리 로그와 릴레이 로그 파일 또한 리두 로그나 언두 로그처럼 평문을 저장한다.
  일반적으로 언두 로그와 리두 로그는 길지 않은 시간 동안의 데이터만 가지기 때문에
  크게 보안에 민감하지 않을 수 있지만 바이너리 로그는 의도적으로 상당히 긴 시간 동안 보관하는 서비스도 있고
  때로는 증분 백업(Incremental Backup)을 위해 바이너리 로그를 보관하기도 한다.
  이런 이유로 바이너리 로그 파일의 암호화는 상황에 따라 중요도가 높아질 수도 있다.

  바이너리 로그와 릴레이 로그 파일 암호화 기능은 디스크에 저장된 로그 파일에 대한 암호화만 담당고,
  MySQL 서버의 메모리 내부 또는 소스 서버와 레플리카 서버 간의 네트워크 구간에서 로그 데이터를 암호화하지는 않는다.
  복제 멤버 간의 네트워크 구간에서도 바이너리 로그를 암호화하고자 한다면

  MySOL 복제를 위한 계정이 SSL을 사용하도록 설정하면 된다.
  복제 시 네트워크 구간으로 전송되는| 이터의 암호화에 대해서는 3장 사용자 및 권한을 참조하자.

7.5.1 바이너리 로그 암호화 키 관리

  바이너리 로그와 릴레이 로그 파일 데이터의 암호화를 위해서도 MySQL 서버는 그림 7.3과 같이 2단대 암호화 키 관리 방식을 사용한다.

  바이너리 로그암호화 키                MySOL 서버
                            키링 플러그인Skeyring fileKEYHashi CorpMy SOL 플러그인 서비스- Vaultikeyring vault바이너리 로그 1/0 핸들러디스크INIAN출바이너리 로그파일 키바이너리 로그(1)바이너리 로그(2)

  그림 7.3 바이너리 로그 파일의 암호화 방식

  바이너리 로그와 릴레이 로그 파일의 데이터는 파일 키(File Key)로 암호화해서 디스크로 저장하고,
  파일 키는 "바이너리 로그 암호화 키"로 암호화해서 각 바이너리 로그와 릴레이 로그 파일의 헤더에 저장된다.
  즉 "바이너리 로그 암호화 키"는 테이블 암호화의 마스터 키와 동일한 역할을 하며,
  파일 키는 바이너리 로그와 릴레이 로그 파일 단위로 자동으로 생성되어 해당 로그 파일의 데이터 암호화에만 사용된다.

7.5.2 바이너리 로그 암호화 키 변경

  바이너리 로그 암호화 키는 다음과 같이 변경(로테이션)할 수 있다.

  mysql) ALTER INSTANCE ROTATE BINLOG MASTER KEY;

  바이너리 로그 암호화 키가 변경되면 다음의 과정을 거친다.

  1. 증가된 시퀀스 번호와 함께 새로운 바이너리 로그 암호화 키 발급 후 키링 파일에 저장
  2. 바이너리 로그 파일과 릴레이 로그 파일 스위치(새로운 로그 파일로 로테이션)
  3. 새로 생성되는 바이너리 로그와 릴레이 로그 파일의 암호화를 위해 파일 키를 생성하고,
     파일 키는 바이너리 로그 파일 키(마스터 키)로 암호화해서 각 로그 파일에 저장
  4. 기존 바이너리 로그와 릴레이 로그 파일의 파일 키를 읽어서 새로운 바이너리 로그 파일 키로
     암호화해서 다시 저장(암호화되지 않은 로그 파일은 무시)
  5. 모든 바이너리 로그와 릴레이 로그 파일이 새로운 바이너리 로그 암호화 키로
     다시 암호화됐다면 기존 바이너리 로그 암호화 키를 키링 파일에서 제거

  이 절차에서 4번 과정은 상당히 시간이 걸리는 작업일 수 있는데,
  이를 위해 키링 파일에서 "바이너리로그 암호화 키"는 내부적으로 버전(시퀀스 번호) 관리가 이뤄진다.
  예를 들어, 많은 바이너리 로그와 릴레이 로그를 가진 MySQL 서버에서 ALTER INSTANCE ROTATE BINLOG MASTER KEY 명령을 연속으로 2번 실행한다면
  키링 파일에는 순차적인 시퀀스 번호를 가지는 3개의 바이너리 로그 암호화 키가 존재할 것이다.
  그리고 바이너리 로그와 릴레이 로그 파일들을 최근 순서대로 파일 키를 다시 암호화해서 저장하는 작업을 수행한다.
  모든 바이너리 로그와 릴레이 로그 파일의 파일 키가 새로운 바이너리 로그 암호화 키로 암호화되어 저장되면
  더이상 기존 바이너리 로그 암호화 키는 필요치 않으므로 키링 파일에서 제거될 것이다.

  MySQL 서버의 바이너리 로그 파일이 암호화돼 있는지 여부는 다음과 같이 확인할 수 있다.

  mysql> SHOW BINARY LOGS;

  | Log_name { File_size { Encrypted | 2853 | No { inysql-bin.000010 | { mysql-bin.000011 | 1337 | Yes

7.5.3 mysqlbinlog 도구 활용

  MySOL 서버에서는 트랜잭션의 내용을 추적하거나 백업 복구를 위해 암호화된 바이너리 로그를 평문으로 복호화할 일이 자주 발생한다.
  하지만 한 번 바이너리 로그 파일이 암호화되면 바이너리 로그 암키가 없으면 복호화할 수 없다.
  그런데 바이너리 로그 암호화 키는 MySQL 서버만 가지고 있어서 보조화가 불가능하다.
  mysqlbinlog 도구를 이용해 암호화된 바이너리 로그 파일의 내용을 SQL 문장으로 한번 풀어보면
  다음과 같이 암호화된 바이너리 로그 파일을 직접 열어 볼 수는 없다는 에러 메시지를 출력한다.

  linux) mysqlbinlog -vvv mysql-bin.000011
         Enter password:
         /*!50530 SET COSESSION.PSEUDO_SLAVE_MODE=1*/;
         /*!50003 SET GOLD_COMPLETION_TYPE=COCOMPLETION_TYPE, COMPLETION_TYPE=0*/;
         DELIMITER /*!*/;
         ERROR: Reading encrypted log files directly is not supported.
         SET @ESESSION.GTID_NEXT= 'AUTOMATIC' /* added by mysqlbinlog */ /*!*/;
         DELIMITER;
         End of log file
         /*! 50003 SET COMPLETION_TYPE=COLD_COMPLETION_TYPE*/;
         /*!50530 SET COSESSION.PSEUDO_SLAVE_MODE=0*/;

  바이너리 로그 암호화 키는 그 바이너리 로그나 릴레이 로그 파일을 생성한 MySQL 서버만 가지고 있기 때문에
  MSSQL 서버와 관계없이 mysqlbinlog 도구만으로는 복호화할 방법이 없다.
  그래서 예전처럼 다른 서버로 복사하거나 바이너리 로그 파일을 백업하는 것은 소용없어졌다.

  그나마 바이너리 로그 파일의 내용을 볼 수 있는 방법은 MySQL 서버를 통해 가져오는 방법이 유일하다.
  즉 현재 MySQL 서버가 mysql-bin.000011 로그 파일을 가지고 있다는 가정하에 mysqlbin.000011 로그 파일의 내용을 확인하고자 한다면
  다음과 같이 mysqlbinlog 도구가 MySQL 서버에 접속해서 바이너리 로그를 가져오는 방법밖에 없다.
  다음 예제에서 파라미터로 주어진 mysqlbin.000011은 MySQL 서버에게 요청할 바이너리 로그 파일의 이름일 뿐,
  mysqlbinlog 도구가 직접 mysql-bin.000011 파일을 읽는 것은 아니다.
  그래서 mysqlbinlog 명령을 실행할 때 "--read-fromremote-server" 파라미터와 함께 MySQL 서버 접속 정보를 입력한다.

  linux) mysqlbinlog --read-from-remote-server -uroot -p -vuv mysql-bin.000011
         Enter password:
         ...
         BINLOG
         c4YjXxOBAAAASQAAAH8BAACAADFpbnNlcnQgaw50byBlbmMgdmFsdWVzICgyLCdlbmNyeXBOZWRF
         YmluYXJ5IGxvZycpv4dkcA=
         c4YjXXMBAAAANWAAALYBAAAAAF SAAAAAAAEABHRIC3QAA2VuYWACAwCKAEDAQEAAgEtHm4rfQ==
         c4YjXx4BAAAAPgAAAPQBAAAAAFSAAAAAAAEAAQAC/WACAAAAFABlbmNyeXBOZWRfYmluYXJ5IGXV
         ZzSCia4=
         '/*!*/;
  ### INSERT INTO `test . 'enc
  ### SET
  ### @1=2 /* INT meta=0 nullable=1 is null=0 */
  ### @2='encrypted_binary log' /* VARSTRING(400) meta=400 nullable=1 is_null=0 */
```