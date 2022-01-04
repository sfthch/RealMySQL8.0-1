```sql
-- MySQL 엔진

   - 커넥션 핸들러, SQL 파서, 전처리기, 옵티마이저


-- 스토리 엔진
   - MySQL 엔진은 하나 디스크 스토리지는 여러개를 동시에 사용가능.
   - 디스크 스토리지에서 read / write
   - CREATE TABLE test_table ( fd1 INT, fd2 INT ) ENGINE=INNODB;
   - 성능향상을 위해 키 캐시(MyISAM 스토리지 엔진), InnoDB 버퍼 풀(InnoDB 스토리지 엔진)


-- 핸들러 API

   - 핸들러 요청이란 각 스토리지 엔진에서 read / write 요청하는것
     여기에서 사용되는 API를 핸들러 API라 한다.
   - 핸들러 API를 통해서 얼마나 많은 DATA 작업이 있었는지 파악하는 명령어.

     SHOW GLOBAL STATUS LIKE 'Handler%';
     +----------------------------+-------+
     | Variable_name              | Value |
     +----------------------------+-------+
     | Handler_commit             | 1030  |
     | Handler_delete             | 2     |
     | Handler_discover           | 0     |
     | Handler_external_lock      | 10245 |
     | Handler_mrr_init           | 0     |
     | Handler_prepare            | 48    |
     | Handler_read_first         | 177   |
     | Handler_read_key           | 4575  |
     | Handler_read_last          | 0     |
     | Handler_read_next          | 7747  |
     | Handler_read_prev          | 0     |
     | Handler_read_rnd           | 362   |
     | Handler_read_rnd_next      | 19883 |
     | Handler_rollback           | 6     |
     | Handler_savepoint          | 0     |
     | Handler_savepoint_rollback | 0     |
     | Handler_update             | 337   |
     | Handler_write              | 2371  |
     +----------------------------+-------+


-- MySQL 스레딩 구조

   - MySQL 서버는 프로세스 기반이 아니라 스레드 기반으로 작동
     포그라운드(Foregroud) 스레드와 백그라운드(Background) 스레드로 구분.
   - MySQL 서버에서 실행중인 스레드 목록 확인.

     SELECT thread_id
          , name
          , type
          , processlist_user
          , processlist_host
         -- SELECT *
       FROM performance_schema.threads
      ORDER BY type
             , thread_id
      ;
      +-----------+---------------------------------------------+------------+------------------+------------------+
      | thread_id | name                                        | type       | processlist_user | processlist_host |
      +-----------+---------------------------------------------+------------+------------------+------------------+
      |         1 | thread/sql/main                             | BACKGROUND | NULL             | NULL             |
      |         2 | thread/mysys/thread_timer_notifier          | BACKGROUND | NULL             | NULL             |
      |         4 | thread/innodb/io_ibuf_thread                | BACKGROUND | NULL             | NULL             |
      |         5 | thread/innodb/io_log_thread                 | BACKGROUND | NULL             | NULL             |
      |         6 | thread/innodb/io_read_thread                | BACKGROUND | NULL             | NULL             |
      |         7 | thread/innodb/io_read_thread                | BACKGROUND | NULL             | NULL             |
      |         8 | thread/innodb/io_read_thread                | BACKGROUND | NULL             | NULL             |
      |         9 | thread/innodb/io_read_thread                | BACKGROUND | NULL             | NULL             |
      |        10 | thread/innodb/io_write_thread               | BACKGROUND | NULL             | NULL             |
      |        11 | thread/innodb/io_write_thread               | BACKGROUND | NULL             | NULL             |
      |        12 | thread/innodb/io_write_thread               | BACKGROUND | NULL             | NULL             |
      |        13 | thread/innodb/io_write_thread               | BACKGROUND | NULL             | NULL             |
      |        14 | thread/innodb/page_flush_coordinator_thread | BACKGROUND | NULL             | NULL             |
      |        15 | thread/innodb/log_checkpointer_thread       | BACKGROUND | NULL             | NULL             |
      |        16 | thread/innodb/log_flush_notifier_thread     | BACKGROUND | NULL             | NULL             |
      |        17 | thread/innodb/log_flusher_thread            | BACKGROUND | NULL             | NULL             |
      |        18 | thread/innodb/log_write_notifier_thread     | BACKGROUND | NULL             | NULL             |
      |        19 | thread/innodb/log_writer_thread             | BACKGROUND | NULL             | NULL             |
      |        24 | thread/innodb/srv_lock_timeout_thread       | BACKGROUND | NULL             | NULL             |
      |        25 | thread/innodb/srv_error_monitor_thread      | BACKGROUND | NULL             | NULL             |
      |        26 | thread/innodb/srv_monitor_thread            | BACKGROUND | NULL             | NULL             |
      |        27 | thread/innodb/buf_resize_thread             | BACKGROUND | NULL             | NULL             |
      |        28 | thread/innodb/srv_master_thread             | BACKGROUND | NULL             | NULL             |
      |        29 | thread/innodb/dict_stats_thread             | BACKGROUND | NULL             | NULL             |
      |        30 | thread/innodb/fts_optimize_thread           | BACKGROUND | NULL             | NULL             |
      |        31 | thread/mysqlx/worker                        | BACKGROUND | NULL             | NULL             |
      |        32 | thread/mysqlx/worker                        | BACKGROUND | NULL             | NULL             |
      |        33 | thread/mysqlx/acceptor_network              | BACKGROUND | NULL             | NULL             |
      |        37 | thread/innodb/buf_dump_thread               | BACKGROUND | NULL             | NULL             |
      |        38 | thread/innodb/clone_gtid_thread             | BACKGROUND | NULL             | NULL             |
      |        39 | thread/innodb/srv_purge_thread              | BACKGROUND | NULL             | NULL             |
      |        40 | thread/innodb/srv_worker_thread             | BACKGROUND | NULL             | NULL             |
      |        41 | thread/innodb/srv_worker_thread             | BACKGROUND | NULL             | NULL             |
      |        42 | thread/innodb/srv_worker_thread             | BACKGROUND | NULL             | NULL             |
      |        44 | thread/mysqlx/acceptor_network              | BACKGROUND | NULL             | NULL             |
      |        47 | thread/sql/con_sockets                      | BACKGROUND | NULL             | NULL             |
      |        43 | thread/sql/event_scheduler                  | FOREGROUND | event_scheduler  | localhost        |
      |        46 | thread/sql/compress_gtid_table              | FOREGROUND | NULL             | NULL             |
      |        49 | thread/sql/one_connection                   | FOREGROUND | root             | localhost        |
      |        50 | thread/sql/one_connection                   | FOREGROUND | root             | localhost        |
      |        67 | thread/sql/one_connection                   | FOREGROUND | root             | localhost        |
      +-----------+---------------------------------------------+------------+------------------+------------------+

      - 이중에 'thread/sql/one_connection' 스레드만이 사용자 요청을 처리하는 포그라운드 스레드임.


-- 포그라운드 스레드(클라이언트 스레드)

   - 최소한 MySQL 서버에 접속된 클라이언트의 수만큼 존재.
   - 각 클라이언트 사용자가 요청하는 쿼리 문장을 처리.
   - 클라이언트 사용자가 작업을 마치고 커넥션을 종료하면
     해당 커넥션을 담당하던 스레드는 다시 스레드 캐시(Thread pool)로 되돌아간다.
   - 스레드 캐시에 일정 개수 이상의 대기 중인 스레드가 있으면
     스레드 캐시에 넣지 않고 스레드를 종료시켜 일정 개수의 스레드만 스레드 캐시에 존재.
   - 스레드 캐시에 일정하게 유지하게 만들어주는 최대 스레드 개수.

     SHOW VARIABLES LIKE 'thread_cache_size%';
     +-------------------+-------+
     | Variable_name     | Value |
     +-------------------+-------+
     | thread_cache_size | 10    |
     +-------------------+-------+

   - 데이터를 MySQL의 데이터 버퍼나 캐시로부터 가져오며
     버퍼나 없는 경우에는 직접 디스크의 데이터나 인덱스 파일로부터 데이터를 읽어와서 처리.
   - MyISAM 테이블은 디스크 쓰기 작업까지 포그라운드 스레드가 처리하나
     MyISAM도 지연된 쓰기가 있지만 일반적인 방식은 아님.
   - InnoDB 테이블은 데이터 버퍼나 캐시까지만 포그라운드 스레드가 처리하고
     나머지 버퍼로부터 디스크까지 기록하는 작업은 백그라운드 스레드가 처리.


   - 참고 : MySQL에서 사용자 스레드와 포그라운드 스레드는 똑같은 의미로 사용하며 클라이언트가 MySQL 서버에 접속하게 되면 MySQL 서버는
            그 클라이언트의 요청을 처리해 줄 스레드를 생성해 그 클라이언트에 할당해 주고 이 스레드는 DBMS의 앞단에서 사용자(클라이언트)와
            통신하기 때문에 포그라운드 스레드라고 하며 또한 사용자가 요청한 작업을 처리하기 때문에 사용자 스레드라고도 한다.


-- 백그라운드 스레드

   - InnoDB는 여러 가지 작업이 백그라운드로 처리.
     . 인서트 버퍼(Insert Buffer)를 병합하는 스레드
     . 로그를 디스크로 기록하는 스레드
     . InnoDB 버퍼 풀의 데이터를 디스크에 기록하는 스레드
     . 데이터를 버퍼로 읽어들이는 스레드
     . 잠금이나 데드락을 모니터링하는 스레드
   - 가장 중요한 것은 로그 스레드(Log thread)와 버퍼의 데이터를 디스크로 내려 쓰는 작업을 처리하는 쓰기 쓰레드(Write thread)임.
   - 쓰기 스레드는 MySQL 5.5 버전부터 read / write 스레드 개수를 2개 이상 지정이 가능.

     SHOW VARIABLES LIKE '%io_threads';
     +-------------------------+-------+
     | Variable_name           | Value |
     +-------------------------+-------+
     | innodb_read_io_threads  | 4     |
     | innodb_write_io_threads | 4     |
     +-------------------------+-------+

   - InnoDB에서도 데이터를 읽는 작업은 주로 클라이언트 스레드에서 처리되기 때문에 읽기 쓰레드는 많이 설정할 필요가 없다.
   - 쓰기 스레드는 아주 많은 작업을 백그라운드로 처리하기 때문에 일반적인 내장 디스크를 사용할 때는 2~4정도
     DAS나 SAN과 같은 스토리지를 사용할 때는 4개 이상으로 충분히 설정.
   - 사용자의 요청을 처리하는 도중 데이터의 쓰기 작업은 지연(버퍼링)되어 처리될 수 있지만 데이터의 읽기 작업은 절대 지연될 수 없다
   - 일반적인 상용 DBMS에는 대부분 쓰기 작업을 버퍼링해서 일괄 처리하는 기능이 탑재되어 있으며 InnoDB 또한 이러한 방식으로 처리.
   - InnoDB에서는 INSERT와 UPDATE 그리고 DELETE 쿼리로 데이터가 변경되는 경우
     데이터가 디스크의 데이터 파일로 완전히 저장될 때까지 기다리지 않아도 된다.
   - MyISAM에서 일반적인 쿼리는 쓰기 버퍼링 기능을 사용할 수 없다.


-- 메모리 할당 및 사용 구조

   - MySQL에서 사용되는 메모리 공간은 크게 글로벌 메모리 영역과 로컬 메모리 영역으로 구분.
   - 글로벌 메모리 영역의 모든 메모리 공간은 MySQL 서버가 시작되면서 무조건 운영체제로부터 할당.
   - MySQL의 파라미터로 설정해 둔 만큼 운영체제로부터 메모리를 할당받는다고 생각하는 것이 좋을 듯 하다.


-- 글로벌 메모리 영역

   - 클라이언트 스레드의 수와 무관하게 일반적으로는 하나의 메모리 공간만 할당.
   - 필요에 따라 2개 이상의 메모리 공간을 할당받을 수도 있지만 클라이언트의 스레드 수와는 무관.
   - 생성된 글로벌 영역이 N개라 하더라도 모든 스레드에 의해 공유.
   - 대표적인 글로벌 메모리 영역
     . 테이블 캐시
     . InnoDB 버퍼 풀
     . InnoDB 어댑티브 해시 인덱스
     . InnoDB 리두 로그 버퍼


-- 로컬 메모리 영역

   - 세션 메모리 영역이라고도 표현.
   - MySQl 서버상에 존재하는 클라이언트 스레드가 쿼리를 처리하는 메모리 영역. 대표적으로 커넥션 버퍼와 정렬(소드) 버퍼가 있다.
   - MySQL 서버에서는 클라이언트 커넥션으로부터의 요청을 처리하기 위해 스레드를 하나씩 할당하게 되는데
     클라이언트 스레드가 사용하는 메모리 공간이라고 해서 클라이언트 메모리 영역 이라고도 한다.
   - 클라이언트와 MySQL 서버와의 커넥션을 세션이라고도 하기때문에 로컬 메모리 영역을 세션 메모리 영역이라고도 표현.
   - 로컬 메모리는 각 클라이언트 스레드별로 독립적으로 할당되며 절대 공유되어 사용되지 않는다.
   - 글로벌 메모리 영역의 크기는 주의해서 설정하지만 소트 버퍼와 같은 로컬 메모리 영역은 크게 신경 쓰지 않고 설정.
   - 최악의 경우(가능성은 희박하지만)에는 MySQL 서버가 메모리 부족으로 멈춰 버릴 수도 있으므로 적절한 메모리 공간을 설정하는 것이 중요.
   - 로컬 메모리 공간의 또 한 가지 중요한 특징은 각 쿼리의 용도별로 필요할 때만 공간이 할당되고 필요하지 않은 경우에는
     MySQL이 메모리 공간을 할당조차도 하지 않을수도 있다는 점이다. 대표적으로 소트 버퍼나 조인 버퍼와 같은 공간이다.
   - 로컬 메모리 공간은 커넥션이 열려 있는 동안 계속 할당된 상태로 남아 있는 공간도 있고(커넥션 버퍼나 결과 버퍼)
     그렇지 않고 쿼리를 실행하는 순간에만 할당했다가 다시 해제하는 공간(소트 버퍼나 조인 버퍼)도 있다.
   - 대표적인 로컬 메모리 영역
     . 정렬 버퍼(Sort buffer)
     . 조인 버퍼
     . 바이너리 로그 캐시
     . 네트워크 버퍼


-- 플러그인 스토리지 엔진 모델

   - MySQL의 독특한 구조 중 대표적인 것이 바로 플러그인 모델이다.
   - 플러그인해서 사용할 수 있는 것이 스토리지 엔진만 가능한 것은 아니다.
   - 전문 검색 엔진을 위한 검색어 파서(인덱싱할 키워드를 분리해내는 작업)도 플러그인 형태로 개발해서 사용할 수 있다.
   - 사용자 인증을 위해서 Native Authentication 과 Caching SHA-2 Authentication 등도 모두 플러인 형태로 제공.
   - 부가적인 기능을 더 제공하는 스토리지 엔진이 필요할 수도 있으며
     이러한 요건을 기초로 다룬 전문 개발 회사 또는 직접 스토리지 엔진을 제작하는 것도 가능.
   - 쿼리가 실행되는 과정은 거의 대부분의 작업이 MySQL 엔진에서 처리, 마지막 "데이터 읽기/쓰기" 작업만 스토리지 엔진에 의해 처리된다.
   - 직접 아주 새로운 용도의 스토리지 엔진을 만든다 하더라도 DBMS의 전체 기능이 아닌 일부분의 기능만 수행하는 엔진을 작성.
   - MySQL 서버에서는 MySQL 엔진은 사람 역할을 하고, 각 스토리지 엔진은 자동차 역할을 하게 되는데
     MySQL 엔진이 스토리지 엔진을 조정하기 위해 핸들러라는 것을 사용.
   - MySQL 엔진이 각 스토리지 엔진에게 데이터를 읽어오거나 저장하도록 명령하려면 핸들러를 꼭 통해야 한다.
   - "Handler_"로 시작하는 상태 변수는 "MySQL 엔진이 각 스토리지 엔진에게 보낸 명령의 횟수를 의미하는 변수"라고 이해하면 된다.
   - MySQl에서 MyISAM이나 InnoDB와같이 다른 스토리지 엔진을 사용하는 테이블에 대해 쿼리를 실행하더라도
     MySQL의 처리 내용은 대부분 동일하다. 단순히 "데이터 읽기/쓰기" 영역의 처리만 차이가 있을 뿐이다.
   - 실질적인 GROUP BY나 ORDER BY 등 많은 복잡한 처리는 스토리지 엔진 영역이 아니라 MySQL 엔진의 처리 영역인 "쿼리 실행기"에서 처리.
   - MyISAM이나 InnoDB 스토리지 엔진 가운데 뭘 사용하든 별 차이가 없는 것 아닌가, 라고 생각할 수 있지만 그렇진 않다.
     스토리지 엔진 가운데 어떤 걸 사용하느냐에 따라 "데이터 읽기/쓰기" 작업 처리 방식이 많이 달라질 수 있다.
   - 하나의 쿼리 작업은 여러 하위 작업으로 나뉘는데, 각 하위 작업이
     MySQL 엔진 영역에서 처리되는지 아니면 스토리지 엔진 영역에서 처리되는지 구분할 줄 알아야 한다.
   - MySQL 서버(mysqld)에서 지원되는 스토리지 엔진를 확인해 보면

     SHOW ENGINES;
     +--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
     | Engine             | Support | Comment                                                        | Transactions | XA   | Savepoints |
     +--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
     | MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables      | NO           | NO   | NO         |
     | MRG_MYISAM         | YES     | Collection of identical MyISAM tables                          | NO           | NO   | NO         |
     | CSV                | YES     | CSV storage engine                                             | NO           | NO   | NO         |
     | FEDERATED          | NO      | Federated MySQL storage engine                                 | NULL         | NULL | NULL       |
     | PERFORMANCE_SCHEMA | YES     | Performance Schema                                             | NO           | NO   | NO         |
     | MyISAM             | YES     | MyISAM storage engine                                          | NO           | NO   | NO         |
     | InnoDB             | DEFAULT | Supports transactions, row-level locking, and foreign keys     | YES          | YES  | YES        |
     | BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it disappears) | NO           | NO   | NO         |
     | ARCHIVE            | YES     | Archive storage engine                                         | NO           | NO   | NO         |
     +--------------------+---------+----------------------------------------------------------------+--------------+------+------------+

     - Support 칼럼에 표시될 수 있는 값은 아래 4가지다.
       . YES      : MySQl 서버(mysqld)에 해당 스토리지 엔진이 포함돼 있고, 사용 가능으로 활성화된 상태임.
       . DEFAULT  : "YES"와 동일한 상태이지만 필수 스토리지 엔진임을 의미함.(이 스토리지 엔진이 없으면 MySQL이 시작되지 않을 수도 있음을 의미한다)
       . NO       : 현재 MySQL 서버(mysqld)에 포함되지 않았음을 의미함.
       . DISABLED : 현재 MySQL 서버(mysqld)에 포함됐지만 파라미터에 의해 비활성화된 상태임.

   - MySQl 서버(mysqld)에 포함되지 않은 스토리지 엔진(Support 칼럼이 NO로 표시되는) 을 사용하려면 MySQL 서버를 다시 빌드(컴파일)해야 한다.
   - MySQL 서버가 적절히 준비만 돼 있다면 플러그인 형태로 빌드된 스토리지 엔진 라이브러리를 내려받아 끼워 넣기만 하면 사용할 수 있다.
   - 플러그인 형태의 스토리지 엔진은 손쉽게 업그레이드 할 수 있다. 스토리지 엔진뿐 아니라 모든 플러그인의 내용은 다음과 같이 확인할 수 있다.
   - 아래의 명령으로 스토리지 엔진뿐 아니라 전문 검색용 파서와 같은 플러그인도 (만약 설치돼 있다면) 확인할 수 있다.

     SHOW PLUGINS;
     +---------------------------------+----------+--------------------+---------+---------+
     | Name                            | Status   | Type               | Library | License |
     +---------------------------------+----------+--------------------+---------+---------+
     | binlog                          | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
     | mysql_native_password           | ACTIVE   | AUTHENTICATION     | NULL    | GPL     |
     | sha256_password                 | ACTIVE   | AUTHENTICATION     | NULL    | GPL     |
     | caching_sha2_password           | ACTIVE   | AUTHENTICATION     | NULL    | GPL     |
     | sha2_cache_cleaner              | ACTIVE   | AUDIT              | NULL    | GPL     |
     | daemon_keyring_proxy_plugin     | ACTIVE   | DAEMON             | NULL    | GPL     |
     | CSV                             | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
     | MEMORY                          | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
     | InnoDB                          | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
     | INNODB_TRX                      | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_CMP                      | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_CMP_RESET                | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_CMPMEM                   | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_CMPMEM_RESET             | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_CMP_PER_INDEX            | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_CMP_PER_INDEX_RESET      | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_BUFFER_PAGE              | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_BUFFER_PAGE_LRU          | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_BUFFER_POOL_STATS        | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_TEMP_TABLE_INFO          | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_METRICS                  | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_FT_DEFAULT_STOPWORD      | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_FT_DELETED               | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_FT_BEING_DELETED         | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_FT_CONFIG                | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_FT_INDEX_CACHE           | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_FT_INDEX_TABLE           | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_TABLES                   | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_TABLESTATS               | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_INDEXES                  | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_TABLESPACES              | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_COLUMNS                  | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_VIRTUAL                  | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_CACHED_INDEXES           | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | INNODB_SESSION_TEMP_TABLESPACES | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
     | MyISAM                          | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
     | MRG_MYISAM                      | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
     | PERFORMANCE_SCHEMA              | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
     | TempTable                       | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
     | ARCHIVE                         | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
     | BLACKHOLE                       | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
     | FEDERATED                       | DISABLED | STORAGE ENGINE     | NULL    | GPL     |
     | ngram                           | ACTIVE   | FTPARSER           | NULL    | GPL     |
     | mysqlx_cache_cleaner            | ACTIVE   | AUDIT              | NULL    | GPL     |
     | mysqlx                          | ACTIVE   | DAEMON             | NULL    | GPL     |
     +---------------------------------+----------+--------------------+---------+---------+

   - MySQL 서버에서는 스토리지 엔지뿐만 아니라 다향한 기능을 플러그인 형태로 지원.
   - 인증이나 전문 검색 파서 또는 쿼리 재작성과 같은 플러그인 있으며, 비밀번호 검증과 커넥션 제어 등에 관련된 다양한 플러그인을 제공.
   - MySQL 서버의 기능을 커스텀하게 확장할 수 있게 플러그인 API가 매뉴얼에 공개함.
   - MySQL 서버에서 제공하던 기능들을 확장하거나 완전히 새로운 기능들을 플러그인으로 구현이 가능.


-- 컴포넌트

   - 기존의 플러그인 아키텍처를 대체하기 위해서 컴포넌트 아키텍처가 지원.
   - MySQL 서버의 플러그인은 몇가지 단점들이 있는데, 이러한 단점들을 보완해서 구현.
     . 플러그인은 오직 MySQL 서버와 인터페이스할 수 있고, 플러그인끼리는 통신할 수 없음.
     . 플러그인은 MySQL 서버의 변수나 함수를 직접 호출하기 때문에 안전하지 않음(캡술화 않됨)
     . 플러그인은 상호 의존 관계를 설정할 수 없어서 초기화가 어려움.
   - 컴포넌트의 간단한 사용법을 비밀번호 검증 컴포넌트를 통해서 살펴보면 아래와 같다.

       mysql> INSTALL COMPONENT 'file://component_validate_password';

       SELECT * FROM mysql.component;
       +--------------+--------------------+------------------------------------+
       | component_id | component_group_id | component_urn                      |
       +--------------+--------------------+------------------------------------+
       |            1 |                  1 | file://component_validate_password |
       +--------------+--------------------+------------------------------------+

       - 플러그인과 마찬가지로 컴포넌트도 설치하면 새로운 시스템 변수를 설정해야 할 수도 있으니 관련 매뉴얼을 보자.
       - 삭제 후 다시 설치 가능
         mysql> UNINSTALL COMPONENT 'file://component_validate_password';


-- 쿼리 실행 구조


-- 쿼리 파서

    - 사용자 요청으로 들어온 쿼리 문장을 토큰(MySQL이 인식할 수 있는 최소 단위의 어휘나 기호)으로 분리해 트리 형태의 구조로 만들어 내는 작업.
    - 쿼리 문장의 기본 문법 오류는 이 과정에서 발견되며 사용자에게 오류 메시지를 전달.


-- 전처리기

    - 파서 과정에서 만들어진 파서 트리를 기반으로 쿼리 문장에 구조적인 문제점이 있는지 확인.
    - 각 토큰을 테이블 이름이나 칼럼 이름 또는 내장 함수와 같은 개체를 매핑해 해당 객체의 존재 여부와
      객체의 접근 여부와 같이 객체의 접근권한 등을 확인하는 과정을 이 단계에서 수행.
    - 실제 존재하지 않거나 권한상 사용할 수 없는 개체의 토큰은 이 단계에서 걸러진다.


-- 옵티마이저

    - 사용자의 요청으로 들어온 쿼리 문장을 저렴한 비용으로 가장 빠르게 처리할지 결정하는 역할을 담당하는데, DBMS의 두뇌에 해당.


-- 실행 엔진

    - 옵티마이저가 두뇌라면 실행 엔진과 핸들러는 손과 발에 비유할 수 있다.
    - 옵티마이저가 GROUP BY를 처리하기 위해 임시 테이블을 사용하기로 결정했다고 해보자.
      1. 실행 엔진은 핸들러에게 임시 테이블을 만들라고 요청.
      2. 다시 실행 엔진은 WHERE 절에 일치하는 레코드를 읽어오라고 핸들러에게 요청.
      3. 읽어온 레코드들을 1번에서 준비한 임시 테이블로 저장하라고 다시 핸들러에게 요청.
      4. 데이터가 준비된 임시 테이블에서 필요한 방식으로 데이터를 읽어오라고 핸들러에게 다시 요청.
      5. 최종적으로 실행 엔진은 결과를 사용자나 다른 모듈로 넘김.
    - 실행 엔진은 만들어진 계획대로 각 핸들러에게 요청해서 받은 결과를 또 다른 핸들러 요청의 입력으로 연결하는 역할을 수행.


-- 핸들러(스토리지 엔진)

    - MySQL 서버의 가장 밑단에서 MySQL 실행 엔진의 요청에 따라 데이터를 디스크로 저장하고 디스크로부터 읽어 오는 역할을 담당.
    - MyISAM 테이블을 조작하는 경우에는 핸들러가 MyISAM 스토리지 엔진이 되고
      InnoDB 테이블을 조작하는 경우에는 핸들러가 InnoDB 스토리지 엔진이 된다.


-- 복제

    - 별도의 장에서...


-- 쿼리 캐시

    - SQL의 실행 결과를 메모리에 캐시하고, 동일 SQL 쿼리가 실행되면 테이블을 읽지 않고 즉시 결과를 반환하기 때문에 매우 빠른 성능을 보임.
      하지만 테이블 데이타가 변경되면 캐시에 저장된 결과 중에서 변경된 테이블과 관련된 데이타들은 모두 삭제가 되어 심각한 성능 저하가 발생.
    - 성능이 개선되는 과정에서 쿼리 캐시는 계속된 동시 처리 성능 저하와 많은 버그의 원인이 됨.
      그래서 MySQL 8.0에서는 완전히 제거되고, 관련 시스템 변수도 모두 제거됨.


-- 스트레스 풀

    - 사용자의 요청을 처리하는 스레드 개수를 줄여서 동시 처리되는 요청이 많아도
      MySQL 서버의 CPU가 제한된 개수의 스레드 처리만 집중할 수 있게 해서 서버의 자원소모를 줄이는 것이 목적.
    - 스케줄링 과정에서 CPU 시간을 제대도 확보하지 못하면 쿼리 처리가 더 느려질 수 있음.
    - 제한된 수의 스레드만으로 CPU가 처리 하도록 적절히 유도한다면 CPU의 프로세서 친화도(Process affinity)도 높이고
      OS 입장에서는 불필요한 컨텍스트 스위치(Context switch)를 줄여서 오버헤드를 줄일 수 있다.


-- 트랜잭션 지원 메타데이터

   - 테이블의 구조 정보와 스토어드 프로그램 등의 정보를 데이터 딕셔너리 또는 메타데이터라고 하는데
     MySQL 서버는 5.7 버젼까지는 테이블 구조를 FRM 파일에 저장하고 일부 스토어드 프로그램도 파일기반으로 관리.
   - 파일기반의 메타데이터는 생성 및 변경 작업이 트랜잭션을 지원하지 않기 때문에 테이블의 생성 또는 변경 도중에
     MySQL 서버가 비정상적으로 종료가 되면 테이블 정보들이 정확하지 않게 되기 때문에 "DB나 테이블이 깨졌다"라고 한다.
   - MySQL 8.0 부터는 테이블의 구조 정보나 스토어드 프로그램의 코드 관련정보들을 InnoDB의 테이블에 저장하도록 개선하고
     시스템 테이블과 데이터 딕셔너리 정보를 모두 모아서 mysql DB에 저장하며 mysql DB는 통째로 mysql.idb라는 테이블스페이스에 저장.


   - 참고 : MySQL 서버는 데이터 딕셔너리 정보를 information_schema DB와 Tables와 Columns 등과 같은 뷰를 통해서 조회가 가능.

     SHOW CREATE TABLE information_schema.tables;
     +--------+-------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+
     | View   | Create View                                                                                                             | character_set_client | collation_connection |
     +--------+-------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+
     | TABLES | CREATE ALGORITHM=UNDEFINED DEFINER=`mysql.infoschema`@`localhost` SQL SECURITY DEFINER                                  | utf8                 | utf8_general_ci      |
     |        |   VIEW `information_schema`.`TABLES`                                                                                    |                      |                      |
     |        |     AS SELECT (`cat`.`name` collate utf8_tolower_ci)                AS `TABLE_CATALOG`                                  |                      |                      |
     |        |             , (`sch`.`name` collate utf8_tolower_ci)                AS `TABLE_SCHEMA`                                   |                      |                      |
     |        |             , (`tbl`.`name` collate utf8_tolower_ci)                AS `TABLE_NAME`                                     |                      |                      |
     |        |             , `tbl`.`type`                                          AS `TABLE_TYPE`                                     |                      |                      |
     |        |             , if((`tbl`.`type` = 'BASE TABLE'),`tbl`.`engine`,NULL) AS `ENGINE`                                         |                      |                      |
     |        |             , if((`tbl`.`type` = 'VIEW'),NULL,10)                   AS `VERSION`                                        |                      |                      |
     |        |             , `tbl`.`row_format`                                    AS `ROW_FORMAT`                                     |                      |                      |
     |        |             , if( (`tbl`.`type` = 'VIEW'), NULL                                                                         |                      |                      |
     |        |                 , internal_table_rows( `sch`.`name`                                                                     |                      |                      |
     |        |                                      , `tbl`.`name`                                                                     |                      |                      |
     |        |                                      , if((`tbl`.`partition_type` is null),`tbl`.`engine`,'')                           |                      |                      |
     |        |                                      , `tbl`.`se_private_id`                                                            |                      |                      |
     |        |                                      , (`tbl`.`hidden` <> 'Visible')                                                    |                      |                      |
     |        |                                      , `ts`.`se_private_data`                                                           |                      |                      |
     |        |                                      , coalesce(`stat`.`table_rows`,0)                                                  |                      |                      |
     |        |                                      , coalesce(cast(`stat`.`cached_time` as unsigned),0)                               |                      |                      |
     |        |                                      )                                                                                  |                      |                      |
     |        |                 ) AS `TABLE_ROWS`                                                                                       |                      |                      |
     |        |             , if( (`tbl`.`type` = 'VIEW'), NULL                                                                         |                      |                      |
     |        |                 , internal_avg_row_length( `sch`.`name`                                                                 |                      |                      |
     |        |                                          , `tbl`.`name`                                                                 |                      |                      |
     |        |                                          , if((`tbl`.`partition_type` is null),`tbl`.`engine`,'')                       |                      |                      |
     |        |                                          , `tbl`.`se_private_id`                                                        |                      |                      |
     |        |                                          , (`tbl`.`hidden` <> 'Visible')                                                |                      |                      |
     |        |                                          , `ts`.`se_private_data`                                                       |                      |                      |
     |        |                                          , coalesce(`stat`.`avg_row_length`,0)                                          |                      |                      |
     |        |                                          , coalesce(cast(`stat`.`cached_time` as unsigned),0)                           |                      |                      |
     |        |                                          )                                                                              |                      |                      |
     |        |                 ) AS `AVG_ROW_LENGTH`                                                                                   |                      |                      |
     |        |             , if( (`tbl`.`type` = 'VIEW'), NULL                                                                         |                      |                      |
     |        |                 , internal_data_length( `sch`.`name`                                                                    |                      |                      |
     |        |                                       , `tbl`.`name`                                                                    |                      |                      |
     |        |                                       , if((`tbl`.`partition_type` is null),`tbl`.`engine`,'')                          |                      |                      |
     |        |                                       , `tbl`.`se_private_id`                                                           |                      |                      |
     |        |                                       , (`tbl`.`hidden` <> 'Visible')                                                   |                      |                      |
     |        |                                       , `ts`.`se_private_data`                                                          |                      |                      |
     |        |                                       , coalesce(`stat`.`data_length`,0)                                                |                      |                      |
     |        |                                       , coalesce(cast(`stat`.`cached_time` as unsigned),0)                              |                      |                      |
     |        |                                       )                                                                                 |                      |                      |
     |        |                 ) AS `DATA_LENGTH`                                                                                      |                      |                      |
     |        |             , if( (`tbl`.`type` = 'VIEW'), NULL                                                                         |                      |                      |
     |        |                 , internal_max_data_length( `sch`.`name`                                                                |                      |                      |
     |        |                                           , `tbl`.`name`                                                                |                      |                      |
     |        |                                           , if((`tbl`.`partition_type` is null),`tbl`.`engine`,'')                      |                      |                      |
     |        |                                           , `tbl`.`se_private_id`                                                       |                      |                      |
     |        |                                           , (`tbl`.`hidden` <> 'Visible')                                               |                      |                      |
     |        |                                           , `ts`.`se_private_data`                                                      |                      |                      |
     |        |                                           , coalesce(`stat`.`max_data_length`,0)                                        |                      |                      |
     |        |                                           , coalesce(cast(`stat`.`cached_time` as unsigned),0)                          |                      |                      |
     |        |                                           )                                                                             |                      |                      |
     |        |                 ) AS `MAX_DATA_LENGTH`                                                                                  |                      |                      |
     |        |             , if( (`tbl`.`type` = 'VIEW'), NULL                                                                         |                      |                      |
     |        |                 , internal_index_length( `sch`.`name`                                                                   |                      |                      |
     |        |                                        , `tbl`.`name`                                                                   |                      |                      |
     |        |                                        , if((`tbl`.`partition_type` is null),`tbl`.`engine`,'')                         |                      |                      |
     |        |                                        , `tbl`.`se_private_id`                                                          |                      |                      |
     |        |                                        , (`tbl`.`hidden` <> 'Visible')                                                  |                      |                      |
     |        |                                        , `ts`.`se_private_data`                                                         |                      |                      |
     |        |                                        , coalesce(`stat`.`index_length`,0)                                              |                      |                      |
     |        |                                        , coalesce(cast(`stat`.`cached_time` as unsigned),0)                             |                      |                      |
     |        |                                        )                                                                                |                      |                      |
     |        |                 ) AS `INDEX_LENGTH`                                                                                     |                      |                      |
     |        |             , if( (`tbl`.`type` = 'VIEW'), NULL                                                                         |                      |                      |
     |        |                 , internal_data_free( `sch`.`name`                                                                      |                      |                      |
     |        |                                     , `tbl`.`name`                                                                      |                      |                      |
     |        |                                     , if((`tbl`.`partition_type` is null),`tbl`.`engine`,'')                            |                      |                      |
     |        |                                     , `tbl`.`se_private_id`                                                             |                      |                      |
     |        |                                     , (`tbl`.`hidden` <> 'Visible')                                                     |                      |                      |
     |        |                                     , `ts`.`se_private_data`                                                            |                      |                      |
     |        |                                     , coalesce(`stat`.`data_free`,0)                                                    |                      |                      |
     |        |                                     , coalesce(cast(`stat`.`cached_time` as unsigned),0)                                |                      |                      |
     |        |                                     )                                                                                   |                      |                      |
     |        |                 ) AS `DATA_FREE`                                                                                        |                      |                      |
     |        |             , if( (`tbl`.`type` = 'VIEW'), NULL                                                                         |                      |                      |
     |        |                 , internal_auto_increment( `sch`.`name`                                                                 |                      |                      |
     |        |                                          , `tbl`.`name`                                                                 |                      |                      |
     |        |                                          , if((`tbl`.`partition_type` is null),`tbl`.`engine`,'')                       |                      |                      |
     |        |                                          , `tbl`.`se_private_id`                                                        |                      |                      |
     |        |                                          , (`tbl`.`hidden` <> 'Visible')                                                |                      |                      |
     |        |                                          , `ts`.`se_private_data`                                                       |                      |                      |
     |        |                                          , coalesce(`stat`.`auto_increment`,0)                                          |                      |                      |
     |        |                                          , coalesce(cast(`stat`.`cached_time` as unsigned),0)                           |                      |                      |
     |        |                                          , `tbl`.`se_private_data`                                                      |                      |                      |
     |        |                                          )                                                                              |                      |                      |
     |        |                 ) AS `AUTO_INCREMENT`                                                                                   |                      |                      |
     |        |             , `tbl`.`created` AS `CREATE_TIME`                                                                          |                      |                      |
     |        |             , if( (`tbl`.`type` = 'VIEW'), NULL                                                                         |                      |                      |
     |        |                 , internal_update_time( `sch`.`name`                                                                    |                      |                      |
     |        |                                       , `tbl`.`name`                                                                    |                      |                      |
     |        |                                       , if((`tbl`.`partition_type` is null),`tbl`.`engine`,'')                          |                      |                      |
     |        |                                       , `tbl`.`se_private_id`                                                           |                      |                      |
     |        |                                       , (`tbl`.`hidden` <> 'Visible')                                                   |                      |                      |
     |        |                                       , `ts`.`se_private_data`                                                          |                      |                      |
     |        |                                       , coalesce(cast(`stat`.`update_time` as unsigned),0)                              |                      |                      |
     |        |                                       , coalesce(cast(`stat`.`cached_time` as unsigned),0)                              |                      |                      |
     |        |                                       )                                                                                 |                      |                      |
     |        |                 ) AS `UPDATE_TIME`                                                                                      |                      |                      |
     |        |             , if( (`tbl`.`type` = 'VIEW'), NULL                                                                         |                      |                      |
     |        |                 , internal_check_time( `sch`.`name`                                                                     |                      |                      |
     |        |                                      , `tbl`.`name`                                                                     |                      |                      |
     |        |                                      , if((`tbl`.`partition_type` is null),`tbl`.`engine`,'')                           |                      |                      |
     |        |                                      , `tbl`.`se_private_id`                                                            |                      |                      |
     |        |                                      , (`tbl`.`hidden` <> 'Visible')                                                    |                      |                      |
     |        |                                      , `ts`.`se_private_data`                                                           |                      |                      |
     |        |                                      , coalesce(cast(`stat`.`check_time` as unsigned),0)                                |                      |                      |
     |        |                                      , coalesce(cast(`stat`.`cached_time` as unsigned),0)                               |                      |                      |
     |        |                                      )                                                                                  |                      |                      |
     |        |                 ) AS `CHECK_TIME`                                                                                       |                      |                      |
     |        |             , `col`.`name` AS `TABLE_COLLATION`                                                                         |                      |                      |
     |        |             , if( (`tbl`.`type` = 'VIEW'), NULL                                                                         |                      |                      |
     |        |                 , internal_checksum( `sch`.`name`                                                                       |                      |                      |
     |        |                                    , `tbl`.`name`                                                                       |                      |                      |
     |        |                                    , if((`tbl`.`partition_type` is null),`tbl`.`engine`,'')                             |                      |                      |
     |        |                                    , `tbl`.`se_private_id`                                                              |                      |                      |
     |        |                                    , (`tbl`.`hidden` <> 'Visible')                                                      |                      |                      |
     |        |                                    , `ts`.`se_private_data`                                                             |                      |                      |
     |        |                                    , coalesce(`stat`.`checksum`,0)                                                      |                      |                      |
     |        |                                    , coalesce(cast(`stat`.`cached_time` as unsigned),0)                                 |                      |                      |
     |        |                                    )                                                                                    |                      |                      |
     |        |                 ) AS `CHECKSUM`                                                                                         |                      |                      |
     |        |             , if( (`tbl`.`type` = 'VIEW'), NULL                                                                         |                      |                      |
     |        |                 , get_dd_create_options( `tbl`.`options`                                                                |                      |                      |
     |        |                                        , if((ifnull(`tbl`.`partition_expression`,'NOT_PART_TBL') = 'NOT_PART_TBL'),0,1) |                      |                      |
     |        |                                        , if((`sch`.`default_encryption` = 'YES'),1,0)                                   |                      |                      |
     |        |                                        )                                                                                |                      |                      |
     |        |                 ) AS `CREATE_OPTIONS`                                                                                   |                      |                      |
     |        |             , internal_get_comment_or_error( `sch`.`name`                                                               |                      |                      |
     |        |                                            , `tbl`.`name`                                                               |                      |                      |
     |        |                                            , `tbl`.`type`                                                               |                      |                      |
     |        |                                            , `tbl`.`options`                                                            |                      |                      |
     |        |                                            , `tbl`.`comment`                                                            |                      |                      |
     |        |                                            ) AS `TABLE_COMMENT`                                                         |                      |                      |
     |        |          FROM ( ( ( ( (      `tables` `tbl`                                                                             |                      |                      |
     |        |                         join `schemata` `sch`                                                                           |                      |                      |
     |        |                           on ( (`tbl`.`schema_id` = `sch`.`id`) )                                                       |                      |                      |
     |        |                       ) join `catalogs` `cat`                                                                           |                      |                      |
     |        |                           on ( (`cat`.`id` = `sch`.`catalog_id`) )                                                      |                      |                      |
     |        |                     )   left                                                                                            |                      |                      |
     |        |                         join `collations` `col`                                                                         |                      |                      |
     |        |                           on ( (`tbl`.`collation_id` = `col`.`id`) )                                                    |                      |                      |
     |        |                   )     left                                                                                            |                      |                      |
     |        |                         join `tablespaces` `ts`                                                                         |                      |                      |
     |        |                           on ( (`tbl`.`tablespace_id` = `ts`.`id`) )                                                    |                      |                      |
     |        |                 )       left                                                                                            |                      |                      |
     |        |                         join `table_stats` `stat`                                                                       |                      |                      |
     |        |                           on ( (     (`tbl`.`name` = `stat`.`table_name`)                                               |                      |                      |
     |        |                                  and (`sch`.`name` = `stat`.`schema_name`)                                              |                      |                      |
     |        |                                )                                                                                        |                      |                      |
     |        |                              )                                                                                          |                      |                      |
     |        |               )                                                                                                         |                      |                      |
     |        |         WHERE (     (0 <> can_access_table(`sch`.`name`,`tbl`.`name`))                                                  |                      |                      |
     |        |                 and (0 <> is_visible_dd_object(`tbl`.`hidden`))                                                         |                      |                      |
     |        |               )                                                                                                         |                      |                      |
     +--------+-------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+


-- InnoDB 스토리지 엔진 아키텍처

   - MySQL에서 지원하는 스토리지 엔진 중 거의 유일하게 레코드 기반 잠금 제공.
   - 높은 동시성 처리 가능, 안정적이며 성능이 뛰어남.


-- 프라이머리 키에 의한 클러스터링

   - InnoDB 테이블은 기본적으로 프라이머리 키를 기준으로 클러스터링 되어 저장.
   - 프라이머리 키 값의 순서대로 디스크에 저장되므로 모든 세컨터리 인덱스는 레코드의 주소 대신 프라이머리 키의 값을 논리적인 주소로 사용.
   - 프라이머리 키를 이용한 레인지 스캔은 성능적으로 빠른것은 프라이머리 키가 클러스터링 인덱스이기 때문.
   - 실행계획에서 프라이머리 키는 다른 보조 인덱스보다 비중이 높게 설정되며, 다른 인덱스보다 프라이머리 키가 선택될 확률이 높음.
   - 오라클의 IOT(Index organized table)구조가 InnoDB에서는 일반적인 테이블 구조.
   - MyISAM는 클러스터링 키를 지원하지 않기 때문에 프라이머리 키, 세컨더리 인덱스의 구조적 차이가 없음.
   - MyISAM는 프라이머리 키는 유니크 제약을 가진 세컨더리 인덱스이며 프라이머리 키와 모든 인덱스는 물리적인 레코드의 주소 값(ROWID)을 가짐.


-- 외래 키 지원

   - InnoDB 스토리지 엔진 레벨에서는 지원하는 기능으로 MyISAM이나 MEMORY 테이블에서 사용 불가.
   - 데이터베이스 서버 운영시 불편함으로 서비스용 데이터베이스에서 생성하지 않는 경우도 있음.
   - InnoDB 에서 외래 키는 부모 테이블과 자식 테이블 모두 해당 컬럼에 인덱스 생성이 필요하고 변경시에는 반드시
     부모 테이블이나 자식 테이블에서 데이터가 있는지 체크하기 때문에 데드락이 발생 하기도 하기 때문에 개발할때도 주의가 필요.
   - 위와 같은 이유로 수동으로 데이터를 적재하거나 스키마 변경 등의 작업에서 문제가 될 수도 있음.
     그러므로 부모 테이블과 자식 테이블의 관계를 정확하게 파악후에 작업을 진행해야 함.
   - 서비스 운영에 긴급하게 작업을 진행 할 경우에는 foreign_key_checks 시스템 변수를 OFF 로 설정 후에 작업을 진행.
   - 위와 같이 설정을 바꾸어서 외래 키의 체크를 일시적으로 중지 시키면 데이터 적재나 삭제등의 작업을 빠르게 진행가능.

     SHOW VARIABLES LIKE '%foreign_key_checks%';
     +--------------------+-------+
     | Variable_name      | Value |
     +--------------------+-------+
     | foreign_key_checks | ON    |
     +--------------------+-------+

     SET SESSION foreign_key_checks=OFF;

     SHOW VARIABLES LIKE '%foreign_key_checks%';
     +--------------------+-------+
     | Variable_name      | Value |
     +--------------------+-------+
     | foreign_key_checks | OFF   |
     +--------------------+-------+

   - 외래 키를 일시적으로 중지한 상태에서 부모 테이블에서 데이터를 삭제했다면 반드시 자식 테이블에서도 관련 데이터를 삭제해서
     부모 테이블의 데이터와 자식 테이블의 데이터 사이의 정합성을 맞추어 준후에 외래 키의 설정을 원래대로 바꾸어 주어야 한다.
   - foreign_key_checks 가 OFF 인 상태에서는 부모 테이블에 걸려있는 ON DELETE CASECADE 와 ON UPDATE CASECADE 옵션도 무시함.


-- MVCC(Multi Version Concurrency Control)

   - 레코드 레벨의 트랜잭션을 지원한는 DBMS가 제공하며 락을 발생하지 않고 데이터 읽을 수 있도록 InnoDB는 언두 로그(Undo log)를 사용.
   - 멀티 버전이라는 것은 하나의 레코드에 대해서 여러 개의 버전이 동시에 관리.
   - 새로운 데이터를 넣거나 기존의 데이터를 변경한 후에 COMMIT이나 ROLLBACK이 되지 않은 상태에서 다른 사용자가
     작업중인 테이터를 조회 한다면 InnoDB 스토리지 엔진을 사용하는 테이블의 데이터 변경에 대한 격리 수준(Isolation level)이
     READ_UNCOMMITTED 이라면 InnoDB 버퍼 풀이나 데이터 파일로 부터 데이터를 읽어서 변경된 데이터를 조회하게 되며 그러나
     격리 수준(Isolation level)이 READ_COMMITTED / REPEATABLE-READ / SERIALIZABLE 인 경우에는 COMMIT이 되지 않았다면
     버퍼 풀이나 데이터 파일에서 읽는 것이 아니라 언두 로그(Undo log)에서 변경 전의 데이터를 읽어서 조회 하도록 한다.

     SHOW VARIABLES LIKE '%transaction_isolation%';
     +-----------------------+-----------------+
     | Variable_name         | Value           |
     +-----------------------+-----------------+
     | transaction_isolation | REPEATABLE-READ |
     +-----------------------+-----------------+


-- 잠금 없는 일괄된 읽기(Non-Locking Consistent Read)

   - InnoDB 스토리지 엔진에서의 읽기 작업은 MVCC를 이용해서 락을 걸지 않기 때문에 다른 읽기 작업과 상관없이 바로 읽기 작업이 가능.
   - 격리 수준이 READ_UNCOMMITTED / READ_COMMITTED / REPEATABLE-READ 이라면 INSERT시에 데이타를 읽는것이 아니고
     순수하게 SELECT로 읽는것이라면 다른 트랜잭션의 변경 작업의 락과는 상관없이 바로 읽는 작업이 가능하며
     이는 특정 사용자가 데이터를 변경하고 아직 COMMIT를 실행하지 않아도 다른 사용자의 SELECT 작업에는 영향을 받지 않음.
   - InnoDB에서는 항상 변경되기 전의 데이터를 언두 로그에 보관하여 사용하며 데이터를 변경 후에 오랜시간 동안에
     COMMIT이나 ROLLBACK를 하지 않으면 MySQL DB가 느려지기 때문에 빠른 시간에 COMMIT이나 ROLLBACK이 필요.


-- 자동 데드락 감지

   - InnoDB 스토리지 엔진은 내부적으로 락이 서로 교착 상태로 빠지는 데드락을 체크하기 위해서 락 대기 목록을 그래프(Wait-for-List) 형태로 관리.
   - InnoDB 스토리지 엔진은 데드락 감지 스레드가 주기적으로 락 대기 그래프를 검사해 데드락 상태로 빠진 트랜잭션들을 찾아 주기적으로 종료.
   - 강제로 종료시키는 트랜잭션은 보다 작은 언두 로그(Undo log)를 가진 트랜잭션을 강제로 ROLLBACK 하여야 MySQL DB의 부하도 줄일 수 있음.
   - MySQL DB 엔진에서 관리하는 테이블의 락(LOCK TABLES 명령으로)으로 발생한 데드락은 찾기가 쉽지 않기 때문에 innodb_table_locks를 ON으로
     설정하게 되면 내부의 레코드 락뿐만 아니라 테이블 락도 찾을 수 있기 때문에 특별한 이유가 없다면 innodb_table_locks 는 ON 상태로 유지.

     SHOW VARIABLES LIKE '%innodb_table_locks%';
     +--------------------+-------+
     | Variable_name      | Value |
     +--------------------+-------+
     | innodb_table_locks | ON    |
     +--------------------+-------+

   - 동시 처리 스레드가 많거나 각 트랜잭션이 많은 락을 가지고 있다면 데드락 감지 스레드는 락 목록을 검사하기 위하여 다시 새로운 락을 걸고
     다시 데드락 감지 스레드를 찾는 악 순환으로 더 많은 CPU 자원를 사용하며서 서비스가 느려지고 더이상 작업을 진행하지 못하고 대기 상태로 빠짐.
   - MySQL DB는 시스템 변수인 innodb_deadlock_detect를 OFF 로 설정하면 데드락 감지 스레드는 작동을 하지 않으므로 해서 2개 이상의 트랜잭션이
     데드락에 빠지는 상황이 발생하게 되어도 데드락 감지 스레드가 작동하지 않기 때문에 무한대기에 빠지게 됨.

     SHOW VARIABLES LIKE '%innodb_deadlock_detect%';
     +------------------------+-------+
     | Variable_name          | Value |
     +------------------------+-------+
     | innodb_deadlock_detect | ON    |
     +------------------------+-------+

   - 하지만 innodb_lock_wait_timeout 시스템 변수에 타임(초)를 설정하게 되면 데드락 상황에서 설정된 시간이 지나면 자동으로 에러 메세지를 반환.

     SHOW VARIABLES LIKE '%innodb_lock_wait_timeout%';
     +--------------------------+-------+
     | Variable_name            | Value |
     +--------------------------+-------+
     | innodb_lock_wait_timeout | 50    |
     +--------------------------+-------+

   - 데드락 감지 스레드가 부담되어 innodb_deadlock_detect를 OFF로 설정했다면 innodb_lock_wait_timeout 설정 시간을 기본값인 50초 보다도 작게 설정.


-- 자동화된 장애 복구

   - InnoDB는 MySQL DB가 시작될 때 완료되지 못한 작업이나 디스크에 일부만 기록된(Partial write) 데이터 페이지에 대한 복구 작업을 자동으로 수행.
   - MySQL DB와 무관하게 디스크나 하드웨어의 문제로 자동 복구를 하지 못하는 경우에는 정상적인 복구가 쉽지 않다.
   - InnoDB는 MySQL DB가 시작될 때에 항상 자동 복구를 수행하지만 이 단계에서 복구할 수 없다면 자동 복구를 멈추고 MySQL DB를 종료한다.
   - MySQL DB의 설정 파일에 innodb_force_recovery 시스템 변수를 설정해서 MySQL DB를 다시 시작해야 하는데
     이는 InnoDB 스토리지 엔진이 데이터 파일이나 로그 파일의 손상 여부를 검사해서 선별적으로 복구를 진행.

     SHOW VARIABLES LIKE '%innodb_force_recovery%';
     +-----------------------+-------+
     | Variable_name         | Value |
     +-----------------------+-------+
     | innodb_force_recovery | 0     |
     +-----------------------+-------+

     . InnoDB의 로그 파일이 손상됐다면 6으로 설정하고 MyQL DB를 재시작.
     . InnoDB의 테이블 데이터 파일이 손상됐다면 1로 설정하고 MyQL DB를 재시작.
     . 만약에 어떤 부분이 문제인지를 파악을 못했다면 1 ~ 6까지 차례대로 변경하면서 MySQL DB를 재시작.
     . innodb_force_recovery값이 커질수록 심각한 상황이라 데이터 손실 가능성은 커지고 복구 가능성은 작아진다.

   - 일단 MySQL DB가 시작이 되고 InnoDB 테이블이 인식된다면 mysqldump를 이용해 데이터를 백업하고 그 데이터로 MySQL DB와 테이블을 재생성.
   - innodb_force_recovery값이 0이 아닌 복구 모드에서는 오직 SELECT만 가능하고 INSERT나 UPDATE, DELETE는 수행이 불가능함.

     . 1(SRV_FORCE_IGNORE_CORRUPT)
        InnoDB의 테이블 스페이스의 데이터나 인덱스 페이지에서 손상된 부분이 발견되어도 무시하고 MySQL DB를 시작하고
        이때는 mysqldump이나 SELECT INTO OUTFILE... 명령을 이용해서 덤프를 만들어서 데이터베이스를 재구축.
        (에러 로그 파일에 'Database page corruption on disk or a failed' 메세지가 출력됨)

     . 2(SRV_FORCE_NO_BACKGROUND)
        InnoDB는 쿼리처리를 위해 여러종류의 백그라운드 스레드를 사용하는데 메인 스레드를 시작하지 않고 MySQL DB를 시작함.
        InnoDB는 트랜잭션의 롤백을 위해 언두 데이터를 관리하는데 트랜잭션이 커밋된 불필요한 언두 데이터는
        InnoDB의 메인 스레드에 의해서 주기적으로 삭제(이를 Undo Purge라고 함)를 하게 되는데 이과정에서 장애가 발생.

     . 3(SRV_FORCE_NO_TRX_UNDO)
        InnoDB에서 트랜잭션이 실행되면 롤백에 대비해 변경 전의 데이터를 언두 영역에 기록.
        MySQL DB는 다시 시작을 하면서 언두 영역의 데이터를 먼저 데이터 파일에 변경된 사항을 적용하고
        다음으로 리두 로그의 내용을 다시 덮어써서 장애 시점의 데이터 상태로 복구함.
        정상적인 MySQL DB의 시작에서는 최종적으로 커밋되지 않은 트랜잭션은 롤백으로 복구를 하지만
        innodb_force_recovery값이 3으로 설정하면 커밋되지 않은 트랜잭션의 작업의 복구를 하지 않음.
        이때로 MySQL DB가 시작되면 mysqldump를 이용하여 데이터를 백업후에 다시 데이터베이스를 구축.

     . 4(SRV_FORCE_NO_IBUF_MERGE)
        InnoDB는 INSERT, UPDATE, DELETE 등의 데이터 변경으로 인한 인덱스 변경 작업은 상황에 따라 즉시 처리될 수도 있고
        인서트 버퍼에 저장하고 나중에 처리할 수도 있는데 이렇게 기록된 내용은 언제 데이터 파일에 반영 될지 알 수가 없는데
        이때 MySQL DB가 종료해도 반영 되지 않을 수도 있고 만약에 MySQL DB가 재시작 하면서 인서트 버퍼의 손상을 감지하면
        InnoDB는 에러를 발생 시키고 MySQL DB를 재시작 하지 않을 수도 있음.

     . 5(SRV_FORCE_NO_UNDO_LOG_SCAN)
        MySQL DB가 장애나 정상적으로 종료되는 시점에 진행중인 트랜잭션이 있었다면 MySQL DB는 단순히 DB 커넥션을 강제로 끊어 버리고 종료함.
        MySQL DB를 재시작하면 InnoDB는 언두 레코드를 이용해서 데이터 페이지를 복구하고 리두 로그를 적용해서 종료 시점이나
        장애가 발생한 시점을 복구해 내고 커밋되지 않은 트랜잭션에서 변경한 작업은 모두 롤백 처리.
        이때 InnoDB의 언두 로그를 사용할 수 없다면 InnoDB의 에러로 인하여 MySQL DB를 재시작할 수 없는데
        innodb_force_recovery값을 5로 설정하면 InnoDB의 언두 로그를 모두 무시하고 MySQL DB를 재시작함.
        이 모드로 복구를 하게되면 MySQL DB가 종료되던 시점에 커밋되지 않았던 트랜잭션 작업이 모두 커밋된 것처럼 처리하는데
        이러게 되면 잘못된 데이터가 데이터베이스에 남은 것으로 볼 수 있으므로 mysqldump를 이용해서 데이터를 백업하고 데이터베이스를 재구축.

     . 6(SRV_FORCE_NO_LOG_REDO)
        InnoDB 스토리지 엔진의 리두 로그 손상으로 MySQL DB가 기동을 하지 못할때 이 복구 모드는 InnoDB는 리두 로그를 무시하고 MySQL DB를 시작됨.
        정상적으로 커밋이 되었다 하더라도 리두 로그에만 기록되고 데이터 파일에 기록되지 않은 데이터는 무시하고 마지막 체크 포인트 데이터만 남음.
        기존의 InnoDB의 리두 로그는 모두 삭제(또는 별도의 디렉토리에 백업)하고 MySQL DB를 재시작 하는것이 좋으며 재시작시에 리두 로그가 없으면
        새로히 생성하므로 별도로 파일을 만들지 않아도 되고 이때도 mysqldump를 이용해서 데이터를 백업하고 데이터베이스를 재구축.

   - 위와 같이 진행을 했음에도 MySQL DB를 시작하지 못했다면 백업을 이용해서 데이터베이스를 재구축하고 바이너리 로그를 이용해
     최대한 장애 시점까지의 데이터를 복구 하도록 하고 마지막 풀 백업한 시점부터 장애 시점까지의 바이너리 로그가 있다면
     InnoDB의 복구를 이용하는 것보다 풀 백업과 바이너리 로그로 복구하는 편이 데이터 손실을 줄이는 방법이나 백업은 있지만
     복제의 바이너리 로그가 없거나 손실이 되었다면 마지막 백업 시점까지만이라도 복구를 진행해서 데이터베이스를 재구축.


-- InnoDB 버퍼 풀

   - InnoDB 스토리지 엔진에서 가장 핵심이며 디스크의 데이터 파일이나 인덱스 정보를 인덱스 정보를
     메모리에 캐시를 해 두고 쓰기 작업을 지연시켜 일괄 작업으로 처리할 수 있게 해주는 버퍼 역할.
   - 일반적인 애플리케이션에서 INSERT, UPDATE, DELETE처럼 데이터를 변경하는 쿼리는 데이터 파일의 이곳저곳에 위치한 레코드를 변경하기
     때문에 램덤하게 디스크에 쓰기 작업을 발생하지만 버퍼 풀이 이러한 변경된 데이터를 모아서 처리하면 랜덤한 디스크 작업의 횟수를 줄임.


-- 버퍼 풀의 크기 설정

   - 일반적으로 전체 물리 메모리의 80%를 버퍼 풀로 설정하라고 하는지만 그렇게 단순하게 설정되는 것이 아니라
     운영체제와 각 클라이언트 스레드가 사용하는 메모리도 충분히 고려해서 설정.
   - MySQL DB에서 크게 메모리를 필요한 경우는 없지만 특히한 경우에 레코드 버퍼가 상당한 메모리 사용을 요구.
   - 레코드 버퍼는 각 클라이언트 세션에서 테이블의 레코드를 읽고 쓸때 버퍼로 사용하는 공간이며
     커넥션이 많고 사용하는 테이블도 많다면 레코드 버퍼로 사용되는 메모리 공간을 많이 필요.
   - MySQL DB가 사용하는 레코드 버퍼 공간은 별도로 설정이 불가 하므로 전체 커넥션 개수와 각 커넥션에서
     읽고 쓰는 테이블의 개수에 따라서 결정되며 버퍼 공간은 동적으로 관리 되어서 정확한 메모리 공간는 측정이 불가.
   - MySQL 5.7 버전부터는 InnoDB 버퍼 풀의 크기를 동적으로 조절이 가능하면 버퍼 풀의 크기를 작은 값부터 크기를 조금씩 늘려가는 방법이 최적.
   - MySQL DB를 이미 사용하고 있다면 그 DB의 메모리 설정을 기준으로 InnoDB 버퍼 풀의 크기를 조정하고 처음으로 MySQL DB를 운영하는 것이라면
     운영체제의 전체 메모리가 8GB 미만이라면 50% 정도를 InnoDB 버퍼 풀로 설정하고 8GB 이상이라면 InnoDB 버퍼 풀의 크기를 50%에서 조금씩 증가.
   - InnoDB 버퍼 풀은 innodb_buffer_pool_size 시스템 변수로 크기를 동적으로 설정이 가능하지만 버퍼 풀의 크기 변경은 MySQL DB에 민감한 영향을
     주기 때문에 하가한 시간에 진행하고 버퍼 풀을 더 크게 변경하는 작업은 시스템 영향이 크지 않지만 작게하는 작업은 영향이 크기 때문에 주의.


     SHOW VARIABLES LIKE '%innodb_buffer_pool_size%';
     +-------------------------+---------+
     | Variable_name           | Value   |
     +-------------------------+---------+
     | innodb_buffer_pool_size | 8388608 | # (8*1024*1024)
     +-------------------------+---------+

   - InnoDB 버퍼 풀은 128MB 단위로 분산 관리 되어 버퍼 풀의 크기를 줄이거나 늘리는 단위로 사용하여 128MB 단위로 늘리거나 줄여야 함.
   - InnoDB 버퍼 풀은 버퍼 풀 전체를 관리하는 락(세마포어)으로 인해 내부 락 경합을 많이 유발했으며 경합을 줄이기 위해 버퍼 풀을 여러개로
     분산하여 관리가 가능하도록 개선 되었고 버퍼 풀이 분산되면서 개별 버퍼 풀 전체를 관리하는 락(세마포어) 자체도 경합이 분산되는 효과를 냄.
   - InnoDB 버퍼 풀은 innodb_buffer_pool_instances 시스템 변수로 버퍼 풀을 여러개로 분산 관리 가능하며 각 버퍼 풀을 버퍼 풀 인스턴스라고 표현.

     SHOW VARIABLES LIKE '%innodb_buffer_pool_instances%';
     +------------------------------+-------+
     | Variable_name                | Value |
     +------------------------------+-------+
     | innodb_buffer_pool_instances | 1     |
     +------------------------------+-------+

   - 기본적인 InnoDB 버퍼 풀 인스턱스 개수는 8개로 초기화 되지만 전체 풀을 위한 메모리가 1GB 미만이면 1개를 설정
     메모리가 40GB 이하라면 기본값 8개로 메모리가 크다면 버퍼 풀 인스턴스당 5GB 정도가 되게 인스턴스 개수를 설정.


-- 버퍼 풀의 구조

   - InnoDB 스토리지 엔진은 버퍼 풀이라는 거대한 메모리 공간을 페이지 크기(innodb_page_size 시스템 변수에 설정)의 조각으로 분산하여
     InnoDB 스토리지 엔진이 데이터를 필요로 할 때 해당 데이터 페이지를 읽어서 각 조각에 저장함.

     SHOW VARIABLES LIKE '%innodb_page_size%';
     +------------------+-------+
     | Variable_name    | Value |
     +------------------+-------+
     | innodb_page_size | 16384 | # (16*1024)
     +------------------+-------+

   - 버퍼 풀의 페이지 크기 조각을 관리하기 위해 InnoDB 스토리지 엔진은 LRU(Least Recently Used) 리스트와
     플러시(Flush) 리스트 그리고 프리(Free) 리스트라는 3개의 자료 구조를 관리함.
   - 프리 리스트는 InnoDB 버퍼 풀에서 실제 사용자 데이터로 채워지지 않은 비어 있는 페이지들의 목록이며
     사용자의 쿼리가 새롭게 디스크의 데이터 페이지를 읽어와야 하는 경우에 사용.
   - LRU 리스트를 관리하는 목적은 디스크로 부터 한 번 읽어온 페이지를 최대한 오랫동안 InnoDB 버퍼 풀의 메모리에 유지하여 디스크 읽기를 최소화.
   - InnoDB 스토리지 엔진에서 데이터를 찾는 과정은 다음과 같다.
     1. 필요한 레코드가 저장된 데이터 페이지가 버퍼 풀에 있는지 검사.
        . InnoDB 어댑티브 해시 인덱스를 이용해 페이지를 검색.
        . 해당 테이블의 인덱스(B-Tree)를 이용해 버퍼 풀에서 페이지를 검색.
        . 버퍼 풀에 이미 데이터 페이지가 있었다면 해당 페이지의 포인터를 MRU 방향으로 올림.
     2. 디스크에서 필요한 데이터 페이지를 버퍼 풀에 적재하고 적재된 페이지에 대한 포인터를 LRU 헤더 부분에 추가.
     3. 버퍼 풀의 LRU 헤더 부분에 적재된 데이터 페이지가 실제로 읽히면 MRU 헤더 부분으로 이동 (Read Ahead와 같이 대량 읽기의 경우
        디스크의 데이터 페이지가 버퍼 풀로 적재는 되지만 실제 쿼리에서 사용되지 않을 수도 있으며 이런 경우에는 MRU로 이동되지 않음)
     4. 버퍼 풀에 상주하는 데이터 페이지는 사용자 쿼리가 얼마나 최근에 사용된것인지에 따라 우선순위를 높여 부여하고
        버퍼 풀에 상주하는 동안 쿼리에서 오랫동안 사용되지 않으면 데이터 페이지에 부여된 우선순위를 낮추어 결국 해당 페이지는
        버퍼 풀에서 제거되고 버퍼 풀의 데이타 페이지가 쿼리에 의해 사용되면 우선순위가 높아져서 MRU의 헤더 부분으로 옮김.
     5. 필요한 데이터가 자주 사용되었다면 해당 페이지의 인덱스 키를 어댑티브 해시 인덱스에 추가.
   - 처음 한 번 읽힌 데이터 페이지가 이후에 자주 사용된다면 그 데이터 페이지는 InnoDB 버퍼 풀의 MRU 영역에서 계속해서 상주하게 되고
     반대로 거의 사용되지 않는다면 새롭게 디스크에서 읽히는 데이터 페이지들에게 밀려서 LRU의 끝으로 밀려나 결국엔 InnoDB 버퍼 풀에서 제거.
   - 플러시 리스트는 디스크로 동기화되지 않은 데이터를 가진 데이터 페이지(이를 더티 페이지라고 함)의 변경 시점 기준의 페이지 목록을 관리.
   - 디스크에서 읽은 상태 그대로 전혀 변경이 없다면 플러시 리스트에 괸리되지 않지만 일단 한 번 데이터 변경이 되었다면
     데이터 페이지는 플러시 리스트에 관리되고 특정 시점이 되면 디스크로 내려서 기록되고 데이터가 변경되면
     InnoDB는 변경 내용을 리두 로그에 기록하고 버퍼 풀의 데이터 페이지에도 변경 내용을 반영.
   - 리두 로그의 각 엔트리는 특정 데이터 페이지와 연결이 되는데 하지만 리두 로그가 디스크에 기록됐다고 해서
     데이터 페이지가 디스크로 기록됐다는 것을 항상 보장하지 않는데 그 반대의 경우도 발생할 수 있고
     InnoDB 스토리지 엔진은 체크포인트를 발생시켜 디스크의 리두 로그와 데이터 페이지의 상태를 동기화 시킴.
   - 체크 포인트는 MySQL DB가 시작될 때 InnoDB 스토리지 엔지이 리두 로그의 오느 부분부터 복구를 실행해야 할지 판단하는 기준점을 만드는 역할.


-- 버퍼 풀과 리두 로그

   - InnoDB의 버퍼 풀은 서버의 메모리가 허용하는 만큼 크게 설정하면 할수록 쿼리의 성능이 빨라지는데
     이미 디스크의 모든 데이터 파일이 버퍼 풀에 적재 될 정도의 버퍼 풀 공간이라면 더 이상 버퍼 풀을 늘려도 성능의 향상은 되지 않음.
   - InnoDB의 버퍼 풀은 데이터베이스 서버의 성능 향상을 위해 데이터 캐시와 쓰기 버퍼링이라는 두 가지 용도가 있느데
     버퍼 풀의 메모리 공간만 단순히 늘리는 것은 데이터 캐시 기능만 향상시킴.
   - InnoDB의 버퍼 풀은 디스크에서 읽은 상태로 전혀 변경되지 않은 클린 페이지(Clean Page)와 함께 INSERT, UPDATE, DELETE 명령에 의해서
     변경된 데이터를 가진 더티 페이지(Dirty Page)도 가지고 있는데 더티 페이지는 디스크와 메모리(버퍼 풀)의 데이터가 다르기 때문에
     언젠가는 디스크로 기록이 되야 한는데 더티 페이지는 버퍼 풀에서 무하정 머무를 수 있는것이 아님.
   - InnoDB 스토리지 엔진에서 리두 로그는 1개 이상의 고정 크기 파일을 연결해서 순환 고리처럼 돌려가면서 사용하는데
     즉 데이터 변경이 계속 되면 리두 로그 파일에 기록됐던 로그 엔트리는 어느 순간 다시 새로운 로그 엔트리로 덮어 쓰임.
   - InnoDB 스토리지 엔진은 전체 리두 로그 파일에서 재사용이 가능한 공간과 당장 재사용이 불가능한 공간을 구분해서 관리하는데
     재사용이 불가능한 공간을 활성 리두 로그(Active Redo Log)라 함.

   - 리두 로그 파일의 공간은 계속 순환되어 재사용되지만 매번 기록될 때마다 로그 포지션은 계속 증가된 값이 LSN(Log Sequence Number)임.
   - InnoDB 스토리지 엔진은 주기적으로 체크포인트 이벤트를 발생시켜서 리두 로그와 버퍼 풀의 더티 페이지를 디스크로 동기화하는데
     이때 발생한 가장 최근에 발생한 체크포인트 지점의 LSN이 활성 리두 로그 공간의 시작점이 되지만
     활성 리두 로그 공간의 마지막은 계속해서 증가하기 때문에 체크포인트와는 아무런 상관이 없음.
   - 가장 최근 체크포인트의 LSN과 마지막 리두 로그 엔트리의 LSN의 차이를 체크포인트 에이지(Checkpoint Age)라 하고
     즉 체크포인트 에이지는 활성 리두 로그 공간의 크기를 말함.

   - InnoDB의 버퍼 풀의 더티 페이지는 특정 리두 로그 엔트리와 관계를 가지고 있으므로 체크포인트가 발생하면
     체크포인트 LSN보다 작은 리두 로그 엔트리와 관련된 더티 페이지는 모두 디스크로 동기화가 되어야 하며
     당연히 체크포인트 LSN보다 작은 LSN 값을 가진 리두 로그 엔트리도 디스크로 동기화가 되야 함.

   - 실제 버퍼 풀의 더티 페이지 비율과 리두 로그 파일의 전체 크기와의 관계를 살펴보면

     1. InnoDB의 버퍼 풀은 100GB이며 리두 로그 파일의 천제 크기는 100MB인 경우
     2. InnoDB의 버퍼 풀은 100MB이며 리두 로그 파일의 천제 크기는 100GB인 경우

     . 1번의 경우 리두 로그 파일의 크기가 100MB밖에 않되기 때문에 체크포인트 에이지(Checkpoint Age)도 최대호 100MB만 허용되는데
       예를 들면 평균 리두 로드 엔트리가 4KB였다면 100MB / 4KB 해서 약 25,600개의 더티 페이지만 버퍼 풀에 보관이 가능하고
       데이터 페이지가 16KB라고 가정하면 허용 가능한 전체 더티 페이지의 크기는 400MB 수준밖에 않되는 것으로 이 경우에는
       버퍼 풀의 크기는 매우 크지만 실제 쓰기 버퍼링을 위한 효과는 거의 보지 못하는 상황임.
     . 2번의 경우도 계산은 1번과 같이 적용해 보면 대략 400GB 정도의 더티 페이지를 가질 수 있지만 버퍼 풀의 크기가 100MB이기 때문에
       최대 허용 가능한 더티 페이지는 100MB 크기가 됨(InnoDB의 버퍼 풀의 여러 가지 설정으로 100MB까지는 되지 않음)

   - 어느 경우가 좋을까? 둘다 좋은 설정이 아니다. 1번은 바로 잘못된 설정이라는 것을 알 수 있고
     2번의 경우는 리두 로그의 공간이 무조건 큰게 좋다면 기본값으로 리두 로그 공간을 1~200GB로 설정하지 않았을까를 생각해 보면
     이론적으로 아무런 문제가 없지만 실제로 이 상태로 MySQL InnoDB 서버를 운영하다 보면 갑자기 디스크 쓰기가 발생할 가능성이 높음.
   - 그래서 버퍼 풀에 더티 페이지의 비율이 너무 높은 상태에서 갑자기 대량의 버퍼 풀이 필요해지는 상황이 오면
     InnoDB 스토리지 엔진은 매우 많은 더티 페이지를 한 번에 모두를 기록해야 하는 상황을 맞이하게 되므로
     처음부터 리두 로그 파일의 크기를 설정하기 어렵다면 버퍼 풀의 크기가 100GB 이하의 MySQL InnoDB 서버에서는
     리두 로그 파일의 전체 크기를 대략 5~10GB 수준으로 설정후에 차후에 차례로 조금씩 늘려서 최적값을 찾은것이 좋음.


-- 버퍼 풀 플러시(Buffer Pool Flush)

   - MySQL 5.6 버전까지는 InnoDB 스토리지 더티 페이지 플러시 기능이 제대로 작동하지 않아서
     갑자기 디스크 기록이 폭증해서 MySQL DB 서버의 사용자 쿼리 처리 성능에 영향을 미침.
   - MySQL 5.7 버전을 거쳐서 MySQL 8.0 버전으로 업그레이드 되면서 대부분의 서비스에서 더티 페이지를
     디스크에 동기화하는 부분(더티 페이지 플러시)에서 예전버전과 같은 디스크 쓰기 폭증는 발생하지 않음.
   - 특별히 서비스를 운영할때 성능상의 문제가 없는 상태라면 기존의 시스템 변수값들을 조정할 필요없음.

   - InnoDB 스토리지 엔진은 버퍼 풀에서 아직 디스크로 기록되지 않는 더티 페이지들을 성능상의 악영향 없이
     디스크에 동기화하기 위해 다음과 같이 2개의 플러시 기능을 백그라운드로 실행.

     . 플러시 리스트(Flush list) 플러시
     . URL 리스트(URL list) 플러시


-- 플러시 리스트 플러시

   - InnoDB 스토리지 엔진은 리두 로그 공간의 재활용을 위해서 주기적으로 오래된 리두 로그 엔트리가 사용하는 공간을 비워야 하는데
     이때 오래된 리두 로그 공간이 지워지려면 반드시 InnoDB 버퍼 풀의 더티 페이지가 먼저 디스크로 동기화가 되야함.
   - InnoDB 스토리지 엔진은 주기적으로 플러시 리스트(Flush list) 플러시 함수를 호출해서 플러시 리스트에서
     오래전에 변경된 데이타 페이지 순서대로 디스크에 동기화하는 작업을 수행하는데 이때 언제부터 얼마나 많은
     더티 페이지를 한 번에 디스크로 기록하느냐에 따라서 사용자의 쿼리 처리가 악영향을 받지 않으면서 부드럽게 처리가 됨.

     SHOW VARIABLES LIKE 'innodb%';
     +------------------------------------------+-----------+
     | Variable_name                            | Value     |
     +------------------------------------------+-----------+
     | innodb_page_cleaners                     | 1         |
     | innodb_buffer_pool_instances             | 1         |
     | innodb_max_dirty_pages_pct_lwm           | 10.000000 |
     | innodb_max_dirty_pages_pct               | 90.000000 |
     | innodb_io_capacity                       | 200       |
     | innodb_io_capacity_max                   | 600       |
     | innodb_flush_neighbors                   | 0         |
     | innodb_adaptive_flushing                 | ON        |
     | innodb_adaptive_flushing_lwm             | 10        |
     | ...                                      | ...       |
     +------------------------------------------+-----------+

   - InnoDB 스토리지 엔진에서 더티 페이지를 디스크로 동기화하는 스레드를 클리너 스레드(Cleaner Thread)라고 하며
     innodb_page_cleaners 시스템 변수는 클리너 스레드의 개수를 조정함.
   - InnoDB 스토리지 엔진은 여러 개의 InnoDB 버퍼 풀 인스턴스를 동시에 사용할 수 있는데 innodb_page_cleaners 설정값이
     버퍼 풀 인스턴스 개수보다 많은 경우에는 innodb_buffer_pool_instances 설정값으로 자동으로 설정 변경함.
   - 즉 하나의 클리너 스레드가 하나의 버퍼 풀 인스턴스를 처리하도록 자동으로 맞추어 주지만 innodb_page_cleaners 시스템 변수의
     설정값이 버퍼 풀 인스턴스 개수보다 적은 경우에는 하나의 클리너 스레드가 여러 개의 버퍼 풀 인스턴스를 처리함.
   - 가능하면 innodb_page_cleaners 설정값은 innodb_buffer_pool_instances 설정값과 동일한 값으로 설정하자.

   - InnoDB 버퍼 풀은 클린 페이지뿐만 아니라 사용자의 DML(INSERT, UPDATE, DELETE)에 의한 변경된 더티 페이지도 함께 가지고 있고
     InnoDB 버퍼 풀은 한계가 있기 때문에 무한정 더티 페이지를 그대로 유지할 수 없음.
   - 기본적으로 InnoDB 스토리지 엔진은 전체 버퍼 풀이 가진 페이지의 90%까지 더티 페이지를 가질 수 있는데 때로는 이 값이 너무 높을 수도 있고
     이런 경우에는 innodb_max_dirty_pages_pct라는 시스템 설정 변수를 이용해 더티 페이지의 비율을 조정할 수 있음.
   - 일반적으로 InnoDB 버퍼 풀은 더티 페이지를 많이 가지고 있을수록 디스크 쓰기 작업을 버퍼링함으로써 여러 번의 디스크 쓰기를
     한 번으로 줄이는 효과를 극대화할 수 있고 그래서 innodb_max_dirty_pages_pct 시스템 설정값은 가능하면 기본값을 유지하는 것이 좋다.

   - InnoDB 버퍼 풀에 더티 페이지가 많으면 많을수록 디스크 쓰기 폭발(Disk IO Burst) 현상이 발생할 가능성이 높고
     InnoDB 스토리지 엔진은 innodb_io_capacity 시스템 변수에 설정된 값을 기준으로 더티 페이지 쓰기를 실행함.
   - 하지만 디스크로 기록되는 더티 페이지 개수보다 더 많은 더티 페이지가 발생하면 버퍼 풀에 더티 페이지가 계속 증가하게 되고
     어느 순간 더티 페이지의 비율이 90%를 넘어가면 InnoDB 스토리지 엔진은 급작스럽게 더티 페이지를 디스크로 기록해야 한다고 판단하고
     그래서 갑자기 디스크 쓰기가 폭증하는 현상이 발생함.
   - 이 문제를 해결하기 위해서 InnoDB 스토리지 엔진에서는 innodb_max_dirty_pages_pct_lwm이라는 시스템 설정 변수를 이용해
     일정 수준 이상의 더티 페이지가 발생하면 조금씩 더티 페이지를 디스크로 기록하게 함.
   - innodb_max_dirty_pages_pct_lwm 시스템 변수의 기본값은 10% 수준인데 만약 더티 페이지의 비율이 얼마 되지 않는 상태에서
     디스크 쓰기가 많이 발생하고 더티 페이지의 비율이 너무 낮은 상태로 계속 머물러 있다면 innodb_max_dirty_pages_pct_lwm 시스템 변수를
     조금 더 높은 값으로 조정하는 것도 디스크 쓰기 횟수를 줄이는 효과를 얻을 수 있음.

   - innodb_io_capacity와 innodb_io_capacity_max 시스템 변수는 각 데이터베이스 서버에서 어느 정도의 디스크 읽고 쓰기가 가능하지를 설정하는 값.
   - innodb_io_capacity는 일반적인 상황에서 디스크가 적절히 처리할 수 있는 수준의 값을 설정하며
     innodb_io_capacity_max 시스템 변수는 디스크가 최대희 성능을 발휘할 때 오느 정도의 디스크 읽고 쓰기가 가능한지를 설정.
   - 디스크 읽고 쓰기란 InnoDB 스토리지 엔진의 백그라운드 스레드가 수행하는 디스크 작업을 의미하고 대부분 InnoDB 버퍼 풀의 더티 페이지 쓰기임.
   - 하지만 InnoDB 스토리지 엔진은 사용자의 쿼리를 처리하기 위해 디스크를 읽기도 해야 하므로 현재 장착된 디스크가
     초당 1000 IOPS를 처리할 수 있다고 해서 이 값을 그대로 innodb_io_capacity와 innodb_io_capacity_max 시스템 변수에 설정해서는 않됨.

   - 참고 : innodb_io_capacity와 innodb_io_capacity_max 시스템 변수에 1000을 설정한다고 해서 초당 1000번의 디스크 쓰기를 보장하는 것은 아니며
            InnoDB 스토리지 엔진은 내부적으로 최적화 알고리즘을 가지고 있어서 설정된 값들을 기준으로 적당히 계산된 횟수만큼
            더티 페이지 쓰기를 하기 때문이며 그래서 innodb_io_capacity와 innodb_io_capacity_max 시스템 변수를 설정하고
            어느 정도 디스크 쓰기를 하는지 모니터링후에 분석하고 패턴을 관찰하여 익히는 것이 중요함.

   - 관리해야 할 MySQL DB 서버가 많다면 일일이 서버의 트랙필을 봐 가면서 innodb_io_capacity와 innodb_io_capacity_max를 설정하는 것은 번거롭고
     그래서 InnoDB 스토리지 엔진은 어댑티브 플러시(Adaptive flush)라는 기능을 제공.
   - 어댑티브 플러시는 innodb_adaptive_flushing 시스템 변수로 커고 끌 수 있는데 기본값은 어댑티브 플러시를 사용하는 것이고
     어댑티브 플러시 기능이 활성화되면 InnoDB 스토리지 엔진은 단순히 버퍼 풀의 데티 페이지 비율이나 innodb_io_capacity
     innodb_io_capacity_max 설정값에 의존하지 않고 새로운 알고리즘으로 사용함.
   - 더티 페이지를 어느 정도 디스크로 기록해야 할지는 사실 어느 정도 속도로 더티 페이지가 생성되는지를 분석한는 것인데
     이는 결국 리두 로그의 증가 속도를 분석하는 것과 같고 그래서 어댑티브 클러시 알고리즘은 리두 로그의 증가 속도를 분석해서
     적절한 수준의 더티 페이지가 버퍼 풀에 유지될 수 있도록 디스크 쓰기를 실행함.
   - innodb_adaptive_flushing_lwm 시스템 변수의 기본값이 10%인데 이는 10%를 넘어서면 그때부터 어댑티브 플러시 알고리즘을 작동.

   - innodb_flush_neighbors 시스템 변수는 더티 페이지를 디스크에 기록할 때 디스크에서 근접한 페이지 중에서 더티 페이지가 있다면
     InnoDB 스토리지 엔진이 함께 묶어서 디스크로 기록하게 해주는 기능을 활성화할지 결정함.
   - 예전에 많이 사용하던 하드디스크(HDD)의 경우 디스크 읽고 쓰기는 매우 고비용의 작업이며 그래서 많은 데이터베이스 서버들은
     한 번이라도 디스크 읽고 쓰기를 줄이기 위해 많은 노력을 하였고 이웃 페이지들의 동시 쓰기(innodb_flush_neighbors)는 노력의 결과임.
   - 데이터의 저장을 하드디스크로 하고 있다면 innodb_flush_neighbors 시스템 변수를 1또는 2로 설정해서 활성화하는 것이 좋지만
     요즘은 대부분 솔리드 스테이트 드라이브(SSD)를 사용하기 때문에 기본값이 비활성 모드로 유지하는 것이 좋음.


-- URL 리스트 플러시

     SHOW VARIABLES LIKE '%innodb_lru_scan_depth%';
     +-----------------------+-------+
     | Variable_name         | Value |
     +-----------------------+-------+
     | innodb_lru_scan_depth | 1024  |
     +-----------------------+-------+

   - InnoDB 스토리지 엔진은 LRU 리스트에서 사용 빈도가 낮은 데이터 페이지들을 제거해서 새로운 페이지들을
     읽어올 공간을 만들어야 하는데 이를 위해 LRU 리스트(LRU list) 플러시 함수가 사용되고 LRU 리스트 끝부분부터
     시작해서 최대 innodb_lru_scan_depth 시스템 변수에 설정된 개수만큼의 페이지들을 스캔함.

     SHOW VARIABLES LIKE '%innodb_buffer_pool_instances%';
     +------------------------------+-------+
     | Variable_name                | Value |
     +------------------------------+-------+
     | innodb_buffer_pool_instances | 1     |
     +------------------------------+-------+

   - InnoDB 스토리지 엔진은 이때 스캔하면서 더티 페이지는 디스크에 동기화하게 하며 클린 페이지는 즉시 플(Free) 리스트로
     페이지를 옮기고 InnoDB 버퍼 풀 인스턴스별로 최대 innodb_lru_scan_depth 개수만큼 스캔하기 때문에
     실질적으로 LRU 리스트 스캔은 (innodb_buffer_pool_instances * innodb_lru_scan_depth) 수 만큼 수행함.


-- 버퍼 풀 상태 백업 및 복구

   - InnoDB 서버의 버퍼 풀은 쿼리의 성능에 매우 밀접하게 연결되 있고 쿼리 요청이 매우 빈번한 서버를 셧다운했다가
     다시 시작하고 서비스를 시작하면 쿼리 처리 성능이 평사시보다 1/10도 않되는 경우가 대부분임.
   - 버퍼 풀에 쿼리들이 사용할 데이터가 이미 준비돼 있으므로 디스크에서 데이터를 읽지 않아도 쿼리가 처리될 수 있기 때문이고
     디스크의 데이터가 버퍼 풀에 적재돼 있는 상태를 워밍업(Warming Up)이라도 표현하는데 버퍼 풀이 잘 워밍업된 상태에서는
     그렇지 않은 경우보다 몇십 배의 쿼리 처리 속도를 보이는것이 일반적임.
   - MySQL 5.5 버전에서는 점검을 위해 MySQL 서버를 셧다운했다가 다시 시작하는 경우 서비스를 오픈하기 전에 강제 워밍없을 위해
     주요 테이블과 인덱스에 대해 풀 스캔을 한 번씩 실행하고 서비스를 오픈함.

     SHOW VARIABLES LIKE '%innodb_buffer_pool%';
     +-------------------------------------+-------+
     | Variable_name                       | Value |
     +-------------------------------------+-------+
     | innodb_buffer_pool_dump_now         | OFF   |
     | innodb_buffer_pool_load_now         | OFF   |
     | innodb_buffer_pool_load_abort       | OFF   |
     | innodb_buffer_pool_dump_at_shutdown | ON    |
     | innodb_buffer_pool_load_at_startup  | ON    |
     | ...                                 | ...   |
     +-------------------------------------+-------+

   - MySQL 5.6 버전부터는 버퍼 풀 덤프 및 적재 기능이 도입됐고 서버 점검이나 기타 작업을 위해 MySQL 서버를 재시작해야 한는 경우
     MySQL 서버를 셧다운하기 전에 다음과 같이 innodb_buffer_pool_dump_now 시스템 변수를 이용해 현재 InnoDB 버퍼 풀의 상태를 백업할 수 있고
     MySQL 서버를 다시 시작하면 innodb_buffer_pool_load_now 시스템 변수를 이용해 백업된 버퍼 풀의 상태를 다시 복구함.

     # MySQL 서버 셧다운 전에 버퍼 풀의 상태 백업
     SET GLOBAL innodb_buffer_pool_dump_now=ON;

     # MySQL 서버 재시작 후 백업된 버퍼 풀의 상태 복구
     SET GLOBAL innodb_buffer_pool_load_now=ON;

   - InnoDB 버퍼 풀의 백업은 데이터 디렉터리에 ib_buffer_pool이라는 이름의 파일로 생성되는데 실제 이 파일의 크기를 보면 아무리
     InnoDB 버퍼 풀이 크다 하더라도 몇십 MB 이하이고 이는 InnoDB 스토리지 엔진이 버퍼 풀의 LRU 리스트에서 적재된 데이터 페이지의
     메타 정보만 가져와 저장하기 때문이며 그래서 버퍼 풀의 백업은 매우 빨리 완료됨.
   - 하지만 백업된 버퍼 풀의 내용을 다시 버퍼 풀로 복구하는 과정은 InnoDB 버퍼 풀의 크기에 따라 상당한 시간이 걸릴 수도 있으며
     이는 백업되 내용에서 각 테이블의 데이터 페이지를 다시 디스크에서 읽어와야 하기 때문이고
     그래서 InnoDB 스토리지 엔진은 버퍼 풀을 다시 복구하는 과정이 어느 정도 진행됐는지 확인 할 수 있게 상태값을 제공함.

     SHOW STATUS LIKE 'innodb_buffer_pool_dump_status' \G
     *************************** 1. row ***************************
     Variable_name: Innodb_buffer_pool_dump_status
             Value: Dumping of buffer pool not started

   - 버퍼 풀 적재 작업에 너무 시간이 오래 걸려서 중간에 멈추고자 한다면 innodb_buffer_pool_load_abort 시스템 변수를 이용.
   - InnoDB의 버퍼 풀을 다시 복구하는 작업은 상당히 많은 디스크 읽기를 필요로 하기 때문에 버퍼 풀 복구가 실행 중인 상태에서 서비스를
     재개하는 것은 좋지 않은 선택이고 그래서 버퍼 풀 복구 도중에 급히 서비를 재시작해야 한다면 다음과 같이 버퍼 풀 복구를 멈출 것을 권장.

     SET GLOBAL innodb_buffer_pool_load_abort=ON;

   - 수동으로 InnoDB 버퍼 풀의 백업과 복구는 수동으로 하기는 쉽지 않기 때문에 다른 작업을 위해 MySQL 서버를 재시작하는 경우
     해야 할 작업에 집중한 나머지 버퍼 풀의 백업과 복구 과정을 잊어버리기 쉽고 그래서 InnoDB 스토리지 엔진은 MySQL 서버가 셧다운
     되기 직전에 버퍼 풀의 백업을 실행하고 MySQL 서버가 시작되면 자동으로 백업된 버퍼 풀의 상태를 복구할 수 있는 기능을 제공함.
   - 버퍼 풀의 백업과 복구를 자동화하려면 innodb_buffer_pool_dump_at_shutdown과
     innodb_buffer_pool_load_at_startup 설정을 MySQL 서버의 설정 파일에 넣어두면 됨.

   - 참고 : InnoDB 버퍼 풀의 백업은 ib_buffer_pool 파일에 기록되는데 그렇다고 반드시 셧다운하기 직전의 파일일 필요는 없고
            InnoDB 스토리지 엔진은 ib_buffer_pool 파일에서 데이터 페이지의 목록을 가져와서 실제 존재하는 데이터 페이지이면
            InnoDB 버퍼 풀로 적재하지만 그렇지 않으면 그냥 조용히 무시하고 그래서 실제 존재하지 않는 데이터 페이지 정보가
            ib_buffer_pool 파일에 명시돼 있다고 해서 MySQL 서버가 비정상적으로 종료되거나 하지 않음.


-- 버퍼 풀의 적재 내용 확인

   - MySQL 5.6 버전부터 MySQL 서버의 information_schema 데이터베이스의 innodb_buffer_page 테이블을 이용해 InnoDB 버퍼 풀의 메모리에
     어떤 테이블의 페이지들이 적재돼 있는지 확인할 수 있지만 InnoDB 버퍼 풀이 큰 경우에는 이 테이블 조회가 상당히 큰 부하를 일으켜서
     서비스 쿼리가 많이 느려지는 문제가 있고 그래서 실제 서비스용으로 사용되는 MySQL 서버에서는 버퍼 풀의 상태를 확인하는 것은 불가능.

   -  MySQL 8.0 버전에서는 이러한 문제점을 해결하기 위해서 information_schema 데이터베이스에 innodb_cache_indexes 테이블을 새로 추가하고
      이 테이블을 이용하면 테이블의 인덱스별로 데이터 페이지가 얼마나 InnoDB 버퍼 풀에 적재돼 있는지 확인이 가능함.

     SELECT it.name            table_name
          , ii.name            index_name
          , ici.n_cached_pages n_cached_pages
          # SELECT it.*, ii.*, ici.*
       FROM information_schema.innodb_tables it
      INNER
       JOIN information_schema.innodb_indexes ii
         ON ii.table_id = it.table_id
       LEFT OUTER
       JOIN information_schema.innodb_cached_indexes ici
         ON ici.index_id = ii.index_id
      WHERE it.name = CONCAT('sakila', '/', 'rental')
     ;
     +---------------+---------------------+----------------+
     | table_name    | index_name          | n_cached_pages |
     +---------------+---------------------+----------------+
     | sakila/rental | PRIMARY             |              4 |
     | sakila/rental | rental_date         |           NULL |
     | sakila/rental | idx_fk_inventory_id |           NULL |
     | sakila/rental | idx_fk_customer_id  |           NULL |
     | sakila/rental | idx_fk_staff_id     |           NULL |
     +---------------+---------------------+----------------+

   - 조금만 응용하면 테이블 전체(인덱스 포함) 페이지 중에서 대략 어느 정도 비율이 InnoDB 버퍼 풀에 적재돼 있는지 다음과 같이 확인이 가능.

     SELECT t.table_schema
          , t.table_name
          , ( SELECT SUM(ici.n_cached_pages) n_cached_pages
                FROM information_schema.innodb_tables it
               INNER
                JOIN information_schema.innodb_indexes ii
                  ON ii.table_id = it.table_id
                LEFT OUTER
                JOIN information_schema.innodb_cached_indexes ici
                  ON ici.index_id = ii.index_id
               WHERE it.name = CONCAT(t.table_schema, '/', t.table_name)
            )     AS total_cached_pages
          , t.data_length
          , t.index_length
          , t.data_free
          , @@innodb_page_size
          , ( ( t.data_length
              + t.index_length
              - t.data_free
              )
            / @@innodb_page_size
            ) AS total_pages
          # SELECT t.*
       FROM information_schema.tables t
      WHERE t.table_schema = 'sakila'
      # AND t.table_name   = 'rental'
      ORDER BY total_cached_pages IS NULL ASC
             , total_cached_pages ASC
     ;
     +--------------+----------------------------+--------------------+-------------+--------------+-----------+--------------------+-------------+
     | TABLE_SCHEMA | TABLE_NAME                 | total_cached_pages | DATA_LENGTH | INDEX_LENGTH | DATA_FREE | @@innodb_page_size | total_pages |
     +--------------+----------------------------+--------------------+-------------+--------------+-----------+--------------------+-------------+
     | sakila       | rental                     |                  4 |     1589248 |      1196032 |         0 |              16384 |    170.0000 |
     | sakila       | actor                      |               NULL |       16384 |        16384 |         0 |              16384 |      2.0000 |
     | sakila       | actor_info                 |               NULL |        NULL |         NULL |      NULL |              16384 |        NULL |
     | sakila       | address                    |               NULL |       98304 |        16384 |         0 |              16384 |      7.0000 |
     | sakila       | category                   |               NULL |       16384 |            0 |         0 |              16384 |      1.0000 |
     | sakila       | city                       |               NULL |       49152 |        16384 |         0 |              16384 |      4.0000 |
     | sakila       | country                    |               NULL |       16384 |            0 |         0 |              16384 |      1.0000 |
     | sakila       | customer                   |               NULL |       81920 |        49152 |         0 |              16384 |      8.0000 |
     | sakila       | customer_list              |               NULL |        NULL |         NULL |      NULL |              16384 |        NULL |
     | sakila       | film                       |               NULL |      196608 |        81920 |         0 |              16384 |     17.0000 |
     | sakila       | film_actor                 |               NULL |      196608 |        81920 |         0 |              16384 |     17.0000 |
     | sakila       | film_category              |               NULL |       65536 |        16384 |         0 |              16384 |      5.0000 |
     | sakila       | film_list                  |               NULL |        NULL |         NULL |      NULL |              16384 |        NULL |
     | sakila       | film_text                  |               NULL |      180224 |        16384 |         0 |              16384 |     12.0000 |
     | sakila       | inventory                  |               NULL |      180224 |       196608 |         0 |              16384 |     23.0000 |
     | sakila       | language                   |               NULL |       16384 |            0 |         0 |              16384 |      1.0000 |
     | sakila       | nicer_but_slower_film_list |               NULL |        NULL |         NULL |      NULL |              16384 |        NULL |
     | sakila       | payment                    |               NULL |     1589248 |       638976 |         0 |              16384 |    136.0000 |
     | sakila       | sales_by_film_category     |               NULL |        NULL |         NULL |      NULL |              16384 |        NULL |
     | sakila       | sales_by_store             |               NULL |        NULL |         NULL |      NULL |              16384 |        NULL |
     | sakila       | staff                      |               NULL |       65536 |        32768 |         0 |              16384 |      6.0000 |
     | sakila       | staff_list                 |               NULL |        NULL |         NULL |      NULL |              16384 |        NULL |
     | sakila       | store                      |               NULL |       16384 |        32768 |         0 |              16384 |      3.0000 |
     +--------------+----------------------------+--------------------+-------------+--------------+-----------+--------------------+-------------+

     - 아직 MySQL 서버는 개별 인덱스별로 전체 페이지 개수가 몇 개인지는 사용자에게 알려주지 않기 때문에 information_schema의 테이블을
       이용해도 테이블의 인덱스별로 페이지가 InnoDB 버퍼 풀에 적재된 비율은 확인이 불가능 해서 앞의 예제에서는
       테이블 단위로 전체 데이터 페이지 개수를 InnoDB 버퍼 풀에 적재된 데이터 페이지 개수의 합을 조회함.


-- Double Write Buffer

   - InnoDB 스토리지 엔진의 리두 로그는 리두 로그 공간의 낭비를 막기 위해 페이지의 변경된 내용만 기록하는데 이로 인해 InnoDB 스토리지 엔진에서
     더티 페이지르 디스크 파일로 플러시할 때 일부만 기록되는 문제가 발생하면 그 페이지의 내용은 복구할 수 없을 수도 있음.
   - 이렇게 페이지 일부만 기록되는 현상을 파셜 페이지(Partial-page) 또는 톤 페이지(Torn-page)라고 하며
     이런 현상은 하드웨어의 오작동이나 시스템의 비정상 종료 등으로 발생할 수 있음.
   - InnoDB 스토리지 엔진에서는 이 같은 문제를 막기 위해 Double-Write 기법을 이용하는데 InnoDB에서 'A' ~ 'E'까지의 더티 페이지를
     디스크로 플러시 한다고 하면 이때 InnoDB 스토리지 엔진은 실제 데이터 파일에 변경 내용을 기록하기 전에 'A' ~ 'E'까지의 더티 페이지를
     우선 묶어서 한 번의 디스크 쓰기로 시스템 테이블스페이스의 Double Write 버퍼에 기록후에 InnoDB 스토리지 엔진은
     각 더티 페이지를 파일의 적당한 위치에 랜덤으로 쓰기를 실행함.

     SHOW VARIABLES LIKE '%innodb_doublewrite%';
     +-------------------------------+-------+
     | Variable_name                 | Value |
     +-------------------------------+-------+
     | innodb_doublewrite            | ON    |
     | innodb_doublewrite_batch_size | 0     |
     | innodb_doublewrite_dir        |       |
     | innodb_doublewrite_files      | 2     |
     | innodb_doublewrite_pages      | 4     |
     +-------------------------------+-------+

   - 시스템 테이블스페이스의 Double Write 버퍼 공간에 기록되 변경 내용은 실제 데이터 파일에 'A' ~ 'E' 더티 페이지가 정상적으로 기록되면
     더이상 필요가 없는데 Double Write 버퍼의 내용은 실제 데이터 파일의 쓰기가 중간에 실패할 때만 원래의 목적으로 사용됨.
   - 'A'와'B' 페이지는 정상적으로 기록됐지만 'C'페이지가 기록되는 도중에 운영체제가 비정상적으로 종료되었다면 InnoDB 스토리지 엔진은
     재시작될 때 항상 Double Write 버퍼의 내용과 데이터 파일의 페이지들을 모두 비교해서 다른 내용을 담고 있는 페이지가 있으면
     Double Write 버퍼의 내용을 데이터 파일의 페이지로 복사하는데 Double Write 기능을 사용할지 여부는 innodb_doublewrite 시스템 변수로 제어함.

     SHOW VARIABLES LIKE '%innodb_flush_log_at_trx_commit%';
     +--------------------------------+-------+
     | Variable_name                  | Value |
     +--------------------------------+-------+
     | innodb_flush_log_at_trx_commit | 1     |
     +--------------------------------+-------+

   - Double Write 버퍼는 데이터의 안정성을 위해 자주 사용하는데 HDD처럼 자기 원판(Platter)이 회전하는 저장 시스템에서는 어차피 한 번의 순차
     디스크 쓰기를 하는 것이기 때문에 별로 부담이 되지 않지만 SSD처럼 랜덤IO나 순차IO의 비용이 비슷한 저장 시스템에서는 상당히 부담임.
   - 하지만 데이터의 무결성이 중요한 서비스에서는 Double Write의 활성화를 고려하고 만약에 데이터베이스 서버의 성능을 위해 InnoDB 리두 로그
     동기화 설정(innodb_flush_log_at_trx_commit 시스템 변수)을 1이 아닌 값으로 설정했다면 innodb_flush_log_at_trx_commit도 비활성화 해야함.

   - 참고 : 일반적으로 MySQL 서버에서는 복제를 이용해 동일 데이터에 대해 여러 개의 사본을 유지하기 때문에 MySQL 서버가 비정상 종료되면
            기존 데이터는 버리고 백업과 바이너리 로그를 이용해 다시 동기화하는 경우도 많고 MySQL 서버의 데이터 무결성에 민감한 서비스라면
            Double Write뿐만 아니라 InnoDB 리두 로그와 복제를 위한 바이너리 로그 등도 트랙잭션을 COMMIT하는 시점에 동기화할 것들이 많아서
            리두 로그는 동기화하지 않으면서(innodb_flush_log_at_trx_commit 시스템 변수가 1이 아닌경우) Double Write만 활성화는 잘못된 것임.


-- 언두 로그

   - InnoDB 스토리지 엔진은 트랜잭션과 격리 수준을 보장하기 위해 DML(INSERT, UPDATE, DELETE)로 변경되기
     이전 비전의 데이터를 별도로 백업를 하고 백업된 데이터를 언두 로그(Undo Log)라 함.

     . 트랜잭션 보장  : 트랜잭션이 롤백되면 트랜잭션 도중에 변경된 데이터를 변경 전 데이터로 복구를 하는데
                        이때 언두 로그에 백업해둔 이전 버전의 데이터로 복구함.
     . 격리 수준 보장 : 특정 커넥션에서 데이터를 변경하는 도중에 다른 커넥션에서 데이터를 조회하면 트랜잭션 격리 수준에 맞게
                        변경중인 레코드를 읽지 않고 언두 로그에 백업해둔 데이터를 읽어서 반환함.

   - 언두 로그는 InnoDB 스토리지 엔진에서 매우 중요한 역할을 담당하지만 관리 비용도 많이 필요함.


-- 언두 로그 레코드 모니터링

   - 언두 영역은 INSERT, UPDATE, DELETE 같은 문장으로 데이터를 변경했을 때 변경되기 전의 데이터(이전 데이터)를 보관하는 곳.

     UPDATE member
        SET name = '홍길도'
      WHERE member_id = 1
     ;

   - 위 문장이 실행되면 트랜잭션을 커밋하지 않아도 실제 데이터 파일(데이터/인덱스 버퍼) 내용은 '홍길동'으로 변경되고
     변경되기 전의 값이 '벽계수'라는 값은 백업되어서 사용자가 커밋을 하면 현재 상태가 유지되고
     롤백을 하면 언두 영역에서 백업된 데이터를 다시 데이터 파일로 복구함.

   - 언두 로그의 데이터는 크게 두 가지 용도로 사용 되는데 첫 번째 용도는 바로 위에서 언급한 트랜잭션의 롤백에 대한 대비용이고
     두 번째 용도는 트랜잭션의 격리 수준을 유지하면서 높은 동시성을 제공하는데 있음.
   - 트랜잭션 격리 수준이라는 개념은 동시에 여러 트랜잭션이 데이터를 변경하거나 조회할 때
     한 트랜잭션의 작업 내용이 다른 트랜잭션에 어떻게 보일지를 결정하는 기준임.

   - MySQL 5.5 버전의 서버에서는 한 번 증가한 언두 로그 공간은 다시 줄어들지 않은데 예를 들어서 1억 건의 레코드가 저장된 100GB 크기의 테이블을
     DELETE로 삭제 한다고 하면 MySQL 서버는 이 테이블에서 레코드 한 건 삭제하고 언두 로그에 삭제되기 전 값을 저장하고 이렇게 1억 건의 레코드가
     테이블에서 삭제되지만 언두 로그로 복사돼야 하는데 테이블의 크기만큼 언두 로그의 공간 사용량이 늘어나 결국 언두 로그 공간이 100GB가 됨.

   - 대용량의 데이터를 처리하는 트랜잭션뿐만 아니라 트랜잭션이 오랜 시간 동안 실행될 때도 언두 로그의 양은 급격히 증가할 수 있고
     트랜잭션이 완료됐다고 해서 해당 트랜잭션이 생성한 언두 로그를 즉시 삭제할 수 있는 것도 아님.

     트랜잭션 A : BEGIN SELECT ------------------------->
     트랜잭션 B : --------- BEGIN UPDATE COMMIT
     트랜잭션 C : --------------- BEGIN DELETE COMMIT

   - 위와 같이 3개의 트랜잭션이 서로 시작과 종료 시점이 다르게 진행이 되었을때 B 트랜잭션과 C 트랜잭션은 완료되었지만
     가장 먼저 시작된 A는 아직 완료되지 않았고 이때 트랜잭션 B와 C는 각각 UPDATE와 DELETE를 실행했으므로
     변경 이전의 데이터를 언두 로그에 백업을 했지만 먼저 시작된 A 트랜잭션이 아직 활성 상태이기 때문에
     B와 C 트랜잭션의 완료 여부와 관계없이 B와 C 트랜잭션이 만들어낸 언두 로그는 삭제 되지 않음.

   - 일반적으로 응용 프로그램에서 트랜잭션 관리가 잘못된 경우에 이러한 현상이 발생하지만 사용자의 잘못으로 발생하는 경우가 더 문제가 되며
     서비스용으로 사용되는 MySQL 서버에서 사용자가 트랜잭션을 시작한 상태에서 완료하지 않고 하루 정도 방치했다면 InnoDB 스토리지 엔진은
     이 트랜잭션이 시작되 시점부터 생성되 언두 로그를 계속 보관할 것이고 결국 InnoDB 스토리지 엔진의 언두 로그는 하루치 데이터 변경을
     모두 저장하고 디스크의 언두 로그 저장 공간은 계속 증가함.
   - 이렇게 누적된 언두 로그로 인해 디스크의 사용량이 증가하는 것은 그다지 큰 문제가 아닐 수도 있지만
     그 동안 빈번하게 변경된 레코드를 조회하는 쿼리가 실행되면 InnoDB 스토리지 엔진은 언두 로그의 이력을 필요한 만큼 스캔해야만
     필요한 레코드를 찾을 수 있기 때문에 쿼리의 성능이 전반적으로 떨어짐.

   - MySQL 5.5 버전까지는 이렇게 언두 로그의 사용 공간이 한 번 늘어나면 MySQL 서버를 새로 구축하지 않는 한 줄일 수 없었고
     언두 로그가 늘어나면 디스크 사용량뿐만 아니라 매번 백업할 때도 그만큼 더 복사를 해야 하는 문제점이 발생하는데
     MySQL 5.7과 MySQL 8.0으로 업그레이드 되면서 언두 로그 공간의 문제점은 완전히 해결됨.
   - MySQL 8.0에서는 언두 로그를 돌아가면서 순차적으로 사용해 디스크 공간을 줄이는 것도 가능하며
     때로는 MySQL 서버가 필요한 시점에 사용 공간을 자동으로 줄이기도 함.

   - 하지만 여전히 서비스 중인 MySQL 서버에서 활성화 상태의 트랜잭션이 장시간 유지되는 것은 성능상 좋지 않고
     그래서 MySQL 서버의 언두 로그 레코드가 얼마나 되는지는 항상 모니터링하는 것이 좋은데
     다음과 같이 MySQL 서버의 언두 로그 레코드 건수 확인이 가능함.

     # MySQL 서버의 모든 버전에서 사용 가능한 명령
     SHOW ENGINE INNODB STATUS \G
     ...
     ------------
     TRANSACTIONS
     ------------
     Trx id counter 4301
     Purge done for trx's n:o < 4301 undo n:o < 0 state: running but idle
     History list length 0
     ...

     # MySQL 8.0 버전에서 사용 가능한 명령
     SELECT i.name
          , i.subsystem
          , i.count
          # SELECT i.*
       FROM information_schema.innodb_metrics i
      WHERE i.name      = 'trx_rseg_history_len'
        AND i.subsystem = 'transaction'
     ;
     +----------------------+-------------+-------+
     | NAME                 | SUBSYSTEM   | COUNT |
     +----------------------+-------------+-------+
     | trx_rseg_history_len | transaction |     0 |
     +----------------------+-------------+-------+
                            +-----------+-----------+-----------+-------------+-----------------+-----------------+-----------------+
                            | MAX_COUNT | MIN_COUNT | AVG_COUNT | COUNT_RESET | MAX_COUNT_RESET | MIN_COUNT_RESET | AVG_COUNT_RESET |
                            +-----------+-----------+-----------+-------------+-----------------+-----------------+-----------------+
                            |         0 |         0 |      NULL |           0 |               0 |               0 |            NULL |
                            +-----------+-----------+-----------+-------------+-----------------+-----------------+-----------------+
                            +---------------------+---------------+--------------+------------+---------+-------+
                            | TIME_ENABLED        | TIME_DISABLED | TIME_ELAPSED | TIME_RESET | STATUS  | TYPE  |
                            +---------------------+---------------+--------------+------------+---------+-------+
                            | 2021-12-28 07:25:23 | NULL          |        29886 | NULL       | enabled | value |
                            +---------------------+---------------+--------------+------------+---------+-------+
                            +-------------------------------------+
                            | COMMENT                             |
                            +-------------------------------------+
                            | Length of the TRX_RSEG_HISTORY list |
                            +-------------------------------------+

   - MySQL 서버에서 실행되는 INSERT, UPDATE, DELETE 문장이 얼마나 많은 데이터르 변경하는냐에 따라 평상시 언두 로그에
     존재하는 레코드 건수는 상이할 수 있는데 그래서 MySQL 서버별로 이 값은 차이를 보일수 있으며 서버별로 안정적인 시점의
     언두 로그 레코드 건수를 확인해서 이를 기준으로 언두 로그의 급증 여부를 모니터링 하는것이 좋음.


-- 언두 테이블스페이스 관리

   - 언두 로그가 저장되는 공간을 언두 테이블스페이스(Undo Tablespace)라고 하고 언두 테이블스페이스는 MySQL 서버의 버전별로
     많은 변화로 인해 MySQL 5.6 이전 버전에서는 언두 로그가 모두 시스템 테이블스페이스(ibdata.ibd)에 저장이 되었고
     하지만 시스템 테이블스페이스의 언두 로그는 MySQL 서버가 초기화될 때 생성되기 때문에 확장의 한계가 있음.

     SHOW VARIABLES LIKE '%innodb_undo_tablespaces%';
     +-------------------------+-------+
     | Variable_name           | Value |
     +-------------------------+-------+
     | innodb_undo_tablespaces | 2     |
     +-------------------------+-------+

   - MySQL 5.6 버전에서는 innodb_undo_tablespaces 시스템 변수가 도입됐고 innodb_undo_tablespaces 시스템 변수 값을 2보다 큰 값을 설정하면
     InnoDB 스토리지 엔진은 더 이상 언두 로그를 시스템 테이블스페이스에 저장하지 않고 별도의 언두 로그 파일을 사용함.
   - 하지만 MySQL 5.6 이후 버전에서도 innodb_undo_tablespaces 값을 0으로 설정하면
     여전히 MySQL 5.6 이전의 버전과 동일게 언두 로그가 시스템 테이블스페이스에 저장됨.
   - MySQL 8.0으로 업그레이드(MySQL 8.0.14 버전부터) 되면서 innodb_undo_tablespaces 시스템 변수는 효력이 없어지고(Deprecated)
     언두 로그는 항상 시스템 테이블스페이스 외부의 별도 로그 파일에 기록되도록 개선됨.
   - 언두 테이블스페이스의 형태를 보면 하나의 언두 테이블스페이스는 1개 이상 128개 이하의 롤백 세그먼트를 가지며 롤백 세글먼트는 1개 이상의
     언두 슬롯(Undo Slot)을 가지고 하나의 롤백 세그먼트는 InnoDB의 페이지 크기를 16바이트로 나눈 값의 개수 만큼의 언두 슬롯을 가짐.
   - 예를 들어서 InnoDB의 페이지 크기가 16KB라면 하나의 롤백 세그먼트는 1024개의 언두 슬롯을 가지고 하나의 트랜잭션이 필요로 하는
     언두 슬롯의 개수는 트랜잭션이 실행하는 INSERT, UPDATE, DELETE 문장의 특성에 따라 최대 4개까지 언두 슬롯을 사용하게 됨.
   - 일반적으로 트랜잭션이 임시 테이블을 사용하지 않으므로 하나의 트랜잭션은 대략 2개 정도의 언두 슬롯을 필요로 한다고
     가정하면 최대 동시에 처리가 가능한 트랜잭션의 개수는 다음 수식으로 예즉해볼 수 있음.

     최대 동시 트랜잭션 수 = (InnoDB 페이지 크기) / 16 * (롤백 세크먼트 개수) * (언두 테이블스페이즈 개수)

     SHOW VARIABLES LIKE '%innodb_rollback_segments%';
     +----------------------------+-------+
     | Variable_name              | Value |
     +----------------------------+-------+
     | innodb_rollback_segments   | 128   |
     +----------------------------+-------+

   - 가장 일반적인 설정인 16KB InnoDB에서 기본 설정(innodb_undo_tablespaces=2, innodb_rollback_segments=128)을 사용한다고 가정하면
     대략 2097152(=16*1024 * 128 * 2 / 2)개 정도의 트랜잭션이 동시에 처리가 가능해지는데 일반적인 서비스에서 이 정도까지
     동시 트랜잭션이 필요하진 않겠지만 기본값으로 해서 크게 문제될 건 없으므로 가능하면 기본값을 유지하자.
   - 언두 로그 공간이 남은 것은 크게 문제되지 않지만 언두 로그 슬롯이 부족한 경우에는 트랜잭션을 시작할 수 없는 심각한 문제가 발생하며
     언두 로그 관련 시스템 변수를 변경해야 한다면 적절히 필요한 동시 트랜잭션 개수에 맞게 언두 테이블스페이스와 롤백 세그먼트의 개수을 설정.

   - MySQL 8.0 이전까지는 한 번 생성된 언두 로그는 변경이 허용되지 않고 정적으로 사용됐지만 MySQL 8.0 버전부터는
     CREATE UNDO TABLESPACE나 DROP TABLESPACE 같은 명령으로 새로운 언두 테이블스페이스르 동적으로 추가하고 삭제할 수 있게 개선함.

     SELECT f.tablespace_name
          , f.file_name
          , f.data_free
          # SELECT f.*
       FROM information_schema.files f
      WHERE file_type LIKE 'UNDO LOG'
     ;
     +-----------------+------------+-----------+
     | TABLESPACE_NAME | FILE_NAME  | DATA_FREE |
     +-----------------+------------+-----------+
     | innodb_undo_001 | ./undo_001 |   7340032 |
     | innodb_undo_002 | ./undo_002 |   6291456 |
     +-----------------+------------+-----------+

     CREATE UNDO TABLESPACE extra_undo_003 ADD DATAFILE '/data/undo_dir/undo_003';

     SELECT f.tablespace_name
          , f.file_name
          # f.data_free
          # SELECT f.*
       FROM information_schema.files f
      WHERE file_type = 'UNDO LOG'
     ;
     +-----------------+-----------------------------+
     | TABLESPACE_NAME | FILE_NAME                   |
     +-----------------+-----------------------------+
     | innodb_undo_001 | ./undo_001                  |
     | innodb_undo_002 | ./undo_002                  |
     | extra_undo_003  | /data/undo_dir/undo_003.ibu |
     +-----------------+-----------------------------+

     # 언두 테이블스페이스를 비활성화
     ALTER UNDO TABLESPACE extra_undo_003 SET INACTIVE;

     # 비활성화된 언두 테이블스페이스 삭제
     DROP UNDO TABLESPACE extra_undo_003;

     SHOW VARIABLES LIKE '%innodb_undo_log_truncate%';
     +--------------------------+-------+
     | Variable_name            | Value |
     +--------------------------+-------+
     | innodb_undo_log_truncate | ON    |
     +--------------------------+-------+

     SHOW VARIABLES LIKE '%innodb_purge_rseg_truncate_frequency%';
     +--------------------------------------+-------+
     | Variable_name                        | Value |
     +--------------------------------------+-------+
     | innodb_purge_rseg_truncate_frequency | 128   |
     +--------------------------------------+-------+

   - 언두 테이블스페이스 공간을 필요한 만큼만 남기고 불필요하거나 과도하게 할당된 공간을 운영체제로 반납하는 것을
     'Undo tablespace truncate'라고 하고 언두 테이블스페이스의 불필요한 공간을 잘라내는(Truncate)방법은
     자동과 수동 두 가지 방법 모두 MySQL 8.0부터 지원.

     . 자동 모드 : 트랜잭션이 데이터를 변경하면 변경전의 데이터를 언두 로그로 기록하고 트랜잭션이 커밋되면 더 이상 언두 로그에 복사된
                   변경전 값은 필요가 없게되는데 InnoDB 스토리지 엔진의 퍼지 스레스(Purge Thread)는 주기적으로 언두 로그 공간에서 불필요한
                   언두 로그를 삭제하는 작업을 실행하는데 이를 언두 퍼지(Undo Purge)라고 함.
                   MySQL 서버의 innodb_undo_log_truncate 시스템 변수가 ON으로 설정되면 퍼지 스레드는 주기적으로 언두 로그 파일에서 사용되지
                   않는 공간을 비우고 운영체제로 반납하는데 언두 로그 파일을 비우는 작업을 더 자주 또는 천천히 실행하게 하려면
                   innodb_purge_rseg_truncate_frequency 시스템 변수의 값을 조정.

     . 수동 모드 : innodb_undo_log_truncate 시스템 변수가 OFF로 설정되어 언두 로그 파일의 비우기가 자동으로 실행되지 않거나
                   예상보다 자동 모드로 언두 테이블스페이의 공간 반납이 부진한 경우에는 언두 테이블스페이스를 비활성화해서
                   언두 테이블스페이스가 더 이상 사용되지 않도록 설정하면 퍼지 스레드는 비활성 상태의 언두 테이블스페이스를
                   찾아서 불필요한 공간을 비우고 운영체제로 해당 공간을 반납하며 반납이 완료되면 언두 테이블스페이스를
                   다시 활성화 하고 수동모드는 언두 테이블스페이스가 최소 3개 이상은 되야 작동한다는 것도 기억해야 함.

     # 언두 테이블스페이스를 비활성화
     ALTER UNDO TABLESPACE tablespace_name SET INACTIVE;

     # 퍼지 스레드에 의해 언두 테이블스페이스 공간이 반납되면 다시 활성화
     ALTER UNDO TABLESPACE tablespace_name SET ACTIVE;


-- 체인지 버퍼

   - RDBMS에서 레코드가 INSERT되거나 UPDATE될 때는 데이터 파일을 변경하는 작업뿐 아니라 해당 테이블에 포함된 인덱스를 업데이트하는 작업도 필요.
   - 인덱스를 업데이트하는 작업은 랜덤하게 디스크를 읽는 작업이 필요하므로 테이블에 인덱스가 많다면 이 작업은 상당히 많은 자원을 소모하게 됨.
   - InnoDB는 변경해야 할 인덱스 페이지가 버퍼 풀에 있으면 바로 업데이트를 수행하지만 그렇지 않고 디스크로 부터 읽어와서
     업데이트해야 한다면 이를 즉시 실행하지 않고 임시 공간에 저장해 두고 바로 사용자에게 결과를 반환하는 형태로 성능을 향상시키는데
     이때 사용하는 임시 메모리 공간을 체인지 버퍼(Chang Buffer)라고 함.

   - 사용자에게 결과를 전달하기 전에 반드시 중복 여부를 체크해야 하는 유니크 인덱스는 체인지 버퍼를 사용할 수 없고 체인지 버퍼에 임시로
     저장된 인덱스 레코드 조각은 이후 백그라운드 스레드에 의해 병합되는데 이 스레드를 체인지 버퍼 머지 스레드(Merge thread)라고 함.
   - MySQL 5.5 이전 버전까지는 INSERT 작업에 대해서만 이러한 버퍼링이 가능하고 이를 인서트 버퍼라고 함.
   - MySQL 5.5 부터 개선되어서 MySQL 8.0에서는 INSERT, DELETE, UPDATE로 인해 키를 추가 하거나 삭제하는 작업에 대해서도 버퍼링이 됨.
   - MySQL 5.5 이전에서는 별도의 설정이 없이 기본적으로 활성화됐지만 MySQL 5.5부터는 innodb_chang_buffering이라는 시스템 변수가 새로 도입되어
     작업의 종류별로 체인지 버퍼를 활성화 할 수 있으며 체인지 버퍼가 비효율적일 때는 체인지 버퍼를 사용하지 않게 설정할 수 있게 개선 됨.

     SHOW VARIABLES LIKE '%innodb_change_buffering%';
     +-------------------------------+-------+
     | Variable_name                 | Value |
     +-------------------------------+-------+
     | innodb_change_buffering       | all   |
     +-------------------------------+-------+
     . all     : 모든 인덱스 관련 작업(inserts + deletes + purges)을 버퍼링
     . none    : 버퍼링 안함
     . inserts : 인덱스에 새로운 아이템을 추가하는 작업만 버퍼링
     . deletes : 인덱스에서 기존 아이템을 삭제하는 작업(삭제됐다는 마킹 작업)만 버퍼링
     . changes : 인덱스에 추가하고 삭제하는 작업만(inserts + deletes)버퍼링
     . purges  : 인덱스 아이템을 영구적으로 삭제하는 작업만 버퍼링(백그라운드 작업)

   - 체인지 버퍼는 기본적으로 InnoDB 버퍼 풀로 설정된 메모리 공간의 25%까지 사용할 수 있게 설정돼 있으며 필요하다면
     InnoDB 버퍼 풀의 50%까지 가능하며 체인지 버퍼가 너무 많은 버퍼 풀 공간을 사용하지 못하도록 한다거나 INSERT나 UPDATE 등이 너부 빈번하게
     실행되어 체인지 버퍼가 더 많은 버풀을 사용할 수 있게 하고자 한다면 innodb_change_buffer_max_size 시스템 변수에 비율을 설정.

     SHOW VARIABLES LIKE '%innodb_change_buffer_max_size%';
     +-------------------------------+-------+
     | Variable_name                 | Value |
     +-------------------------------+-------+
     | innodb_change_buffer_max_size | 25    |
     +-------------------------------+-------+

   - 체인지 버퍼가 버퍼 풀의 메모리를 얼마나 사용 중인지 그리고 얼마나 많은 변경 사항을 버퍼링하고 있는지는 다음과 같이 확인이 가능.

     SELECT m.event_name
          , m.current_number_of_bytes_used
          # SELECT m.*
       FROM performance_schema.memory_summary_global_by_event_name m
      WHERE m.event_name = 'memory/innodb/ibuf0ibuf'
     ;
     +-------------------------+-------------+------------+---------------------------+
     | EVENT_NAME              | COUNT_ALLOC | COUNT_FREE | SUM_NUMBER_OF_BYTES_ALLOC |
     +-------------------------+-------------+------------+---------------------------+
     | memory/innodb/ibuf0ibuf |           1 |          0 |                       136 |
     +-------------------------+-------------+------------+---------------------------+
                               +--------------------------+----------------+--------------------+-----------------+
                               | SUM_NUMBER_OF_BYTES_FREE | LOW_COUNT_USED | CURRENT_COUNT_USED | HIGH_COUNT_USED |
                               +--------------------------+----------------+--------------------+-----------------+
                               |                        0 |              0 |                  1 |               1 |
                               +--------------------------+----------------+--------------------+-----------------+
                               +--------------------------+------------------------------+---------------------------+
                               | LOW_NUMBER_OF_BYTES_USED | CURRENT_NUMBER_OF_BYTES_USED | HIGH_NUMBER_OF_BYTES_USED |
                               +--------------------------+------------------------------+---------------------------+
                               |                        0 |                          136 |                       136 |
                               +--------------------------+------------------------------+---------------------------+

     - 체인지 관련 오퍼레이션 처리 횟수

     SHOW ENGINE INNODB STATUS \G
     ...
     -------------------------------------
     INSERT BUFFER AND ADAPTIVE HASH INDEX
     -------------------------------------
     Ibuf: size 1, free list len 0, seg size 2, 0 merges
     merged operations:
      insert 0, delete mark 0, delete 0
     discarded operations:
      insert 0, delete mark 0, delete 0
     ...


-- 리두 로그 및 로그 버퍼

   - 리두 로그(Redo Log)는 트랜잭션의 4가지 요소인 ACID중에서 D(Durable)에 해당하는 영속성과 가장 밀접하게 연관되 있으며
     하드웨어나 소프트웨어 등 여러 가지 문제점으로 인해 MySQL 서버가 비정상적으로 종료됐을 때
     데이터 파일에 기록되지 못한 데이터를 잃지 않게 해주는 안전장치.
   - MySQL 서버를 포함한 대부분 데이터베이스 서버는 데이터 변경 내용을 로그로 먼저 기록하고 거의 모든 DBMS에서 데이터 파일은 쓰기보다
     읽기 성능을 고려한 자료 구조를 가지고 있기 때문에 데이터 파일 쓰기는 디스크의 랜덤 액세스가 필요.
   - 그래서 변경된 데이터를 데이터 파일에 기록하려면 상대적으로 큰 비용이 필요하고 이로 인한 성능 저하를 막기 위해
     데이터베이스 서버는 쓰기 비용이 낮은 자료 구조를 가진 리두 로그를 가지고 있으며 비정상 종료가 발생하면
     리두 로그의 내용을 이용해 데이터 파일을 다시 서버가 종료되기 직전의 상태로 복구한다.
   - 데이터베이스 서버는 ACID도 중요하지만 성능도 중요하기 때문에 데이터 파일뿐만 아니라
     리두 로그를 버퍼링할 수 있는 InnoDB 버퍼 풀이나 리두 로그를 버퍼링할 수 있는 로그 버퍼와 같은 자료 구조도 가지고 있다.

   - MySQL 서버가 비정상 종료되는 경우 InnoDB 스토리지 엔진의 데이터 파일은 다음과 같은 두 가지 종류의 일관되지 않은 데이터를 가질 수 있다.

     . 커밋됐지만 데이터 파일에 기록되지 않은 데이터
     . 롤백됐지만 데이터 파일에 이미 기록된 데이터

     - 1번의 경우 리두 로그에 저장된 데이터를 데이터 파일에 다시 복사하기만 하면 된다.
     - 2번의 경우에는 리두 로그로는 해결할 수 없는데, 이때는 변경되기 전 데이터를 가진 언두 로그의 내용을 가져와 데이터 파일에 복사하면 된다.
     - 그렇다고 해서 2번의 경우 리두 로그가 전혀 필요하지 않은 것은 아니며 최소한 그 변경이 커밋됐는지, 롤백됐는지
       아니면 트랜잭션의 실행 중간 상태였는지를 확인하기 위해서라도 리두 로그가 필요하다.

   - 데이터베이스 서버에서 리두 로그는 트랜잭션이 커밋되면 즉시 디스크로 기록되도록 시스템 변수를 설정하는 것을 권장하며 그리고 당연히
     그렇게 돼야만 서버가 비정상적으로 종료됐을 때 직전까지의 트랜잭션 커밋 내용이 리두 로그에 기록될 수 있고 그 리두 로그를 이용해
     장애 직전 시점까지의 복구가 가능해지며 하지만 이처럼 트랜잭션이 커밋될 때마다 리두 로그를 디스크에 기록하는 작업은 많은 부하를 유발한다.
   - 그래서 InnoDB 스토리지 엔진에서 리두 로그를 어느 주기로 디스크에 동기화할지를 결정하는 innodb_flush_log_at_trx_commit 시스템 변수를 제공.
   - innodb_flush_log_at_trx_commit 시스템 변수는 다음과 같은 값을 가질 수 있다.

     SHOW VARIABLES LIKE '%innodb_flush_log_at%';
     +--------------------------------+-------+
     | Variable_name                  | Value |
     +--------------------------------+-------+
     | innodb_flush_log_at_timeout    | 1     |
     | innodb_flush_log_at_trx_commit | 1     |
     +--------------------------------+-------+
     .innodb_flush_log_at_trx_commit = 0 : 1초에 한 번씩 리두 로그를 디스크로 기록(write)하고 동기화(sync)를 실행한다.
                                           그래서 서버가 비정상 종료되면 최대 1초 동안의 트랜잭션은 커밋됐다고 하더라도
                                           해당 트랜잭션에서 변경한 데이터는 사라질 수 있다.
     .innodb_flush_log_at_trx_commit = 1 : 매번 트랜잭션이 커밋될 때마다 디스크로 기록되고 동기화까지 수행된다.
                                           그래서 트랜잭션이 일단 커밋되면 해당 트랜잭션에서 변경한 데이터는 사라진다.
     .innodb_flush_log_at_trx_commit = 2 : 매번 트랜잭션이 커밋될 때마다 디스크로 기록(write)은 되지만 실질적인 동기화(sync)는 1초에 한 번씩 실행.
                                           일단 트랜잭션이 커밋되면 변경 내용이 운영체제의 메모리 버퍼로 기록되는 것이 보장.
                                           MySQL 서버가 비정상 종료됐더라도 운영체제가 정상적으로 작동하면 해당 트랜잭션 데이터는 사라지지 않음.
                                           MySQL 서버와 운영체제가 모두 비정상적으로 종료되면 최근 1초 동안의 트랜잭션 데이터는 사라질 수도 있다.

   - innodb_flush_log_at_trx_commit 시스템 변수가 0이나 2로 설정되는 경우 디스크 동기화 작업이 항상 1초 간격으로 실행되는 것은 아니며
     스키마 변경을 위한 DDL이 실행되면 리두 로그가 디스크로 동기화되기 때문에
     InnoDB 스토리지 엔진이 스키마 변경을 위한 DDL을 실행했다면 1초보다 간격이 작을수도 있다.
   - 하지만 스키마 변경 작업은 자주 실행되는 작업은 아니므로 리두 로그는 최대 1초 정도 손실이 발생할 수 있다는 정도로 기억해두자.
   - 또한 innodb_flush_log_at_trx_commit 시스템 변수가 0이나 2인 경우
     디스크 동기화 시간 간격을 innodb_flush_log_at_timeout 시스템 변수를 이용해 변경할 수 있다.
   - 기본값은 1초이며, 일반적인 서비스에서 이 간격을 변경할 만한 특별한 이유는 없을 것으로 보인다.

   - InnoDB 스토리지 엔진의 리두 로그 파일들의 전체 크기는 InnoDB 스토리지 엔진이 가지고 있는 바퍼 풀의 효율성을 결정하기 때문에 신중히 결정.
   - 리두 로그 파일의 크기는 innodb_log_file_size 시스템 변수로 결정하며, innodb_log_files_in_group 시스템 변수는 리두 로그 파일의 개수를 결정.
   - 그래서 전체 리두 로그 파일의 크기는 두 시스템 변수의 곱으로 결정된다. 그리고 리두 로그 파일의 전체 크기가 InnoDB 버퍼 풀의
     크기에 맞게 적절히 선택돼야 InnoDB 스토리지 엔진이 적절히 변경된 내용을 버퍼 풀에 모았다가 한 번에 모아서 디스크에 기록할 수 있다.
   - 하지만 사용량(특히 변경 작업)이 매우 많은 DBMS 서버의 경우에는 이 리두 로그의 기록 작업이 큰 문제가 되는데, 이러한 부분을 보완하기 위해
     최대한 ACID 속성을 보장하는 수준에서 버퍼링하며 이러한 리두 로그 버퍼링에 사용되는 공간이 로그 버퍼다.

     SHOW VARIABLES LIKE '%innodb_log_file%';
     +---------------------------+----------+
     | Variable_name             | Value    |
     +---------------------------+----------+
     | innodb_log_file_size      | 50331648 | # (48*1024*1024)
     | innodb_log_files_in_group | 2        |
     +---------------------------+----------+

   - 로그 버퍼의 크기는 기본값인 16MB 수준에서 설정하는 것이 적합한데
     BLOB이나 TEXT와 같이 큰데이터를 자주 변경하는 경우에는 더 크게 설정하는 것이 좋다.

   - 참고 : ACID는 데이터베이스에서 트랜잭션의 무결성을 보장하기 위해 꼭 필요한 4가지 요소(기능)를 의미한다.

            . 'A'는 Atomic의 첫 글자로, 트랜잭션은 원자성 작업이어야 함을 의미한다.
            . 'C'는 Consistenl의 첫 글자로, 일관성을 의미한다.
            . 'I'는 Isolaled의 첫 글자로, 격리성을 의미한다.
            . 'D'는 Durable의 첫 글자이며, 한 번 저장된 데이터는 지속적으로 유지돼야 함을 의미한다.

            일관성과 격리성은 쉽게 정의하기는 힘들지만
            이 두 가지 속성은 서로 다른 두 개의 트랜잭션에서 동일 데이터를 조회하고 변경하는 경우에도 상호 간섭이 없어야 한다는 것을 의미한다.



-- 리두 로그 아카이빙

   - MySQL 8.0 버전부터 InnoDB 스토리지 엔진의 리두 로그를 아카이빙할 수 있는 기능이 추가됬으며 MySQL 엔터프리이즈 백업이나
     Xtralbackup 툴은 데이터 파일을 복사하는 동안 InnoDB 스토리지 엔진의 리두 로그에 쌓인 내용을 계속 추적하면서
     새로 추가된 리두 로그 엔트리를 복사하고 데이터파일을 복사하는 동안 추가된 리두 로그 엔트리가 같이 백업되지 않는다면
     복사된 데이터 백업 파일은일관된 상태를 유지하지 못한다.
   - 그런데 MySQL 서버에 유입되는 데이터 변경이 너무 많으면 리두 로그가 매우 빠르게 증가하고
     엔터프리이즈 백업이나 Xtralbackup 툴이 새로 추가되는 리두 로그 내용을 복사하기도 전에 덮어쓰일 수도 있다.
   - 이렇게 아직 복사하지 못한 리두 로그가 덮어쓰이면 백업 툴이 리두 로그 엔트리를 복사할 수 없어서 백업은 실패하게 하고
     MySQL 8.0의 리두 로그 아카이빙 기능은 데이터 변경이 많아서 리두 로그가 덮어쓰인다고 하더라도 백업이 실패하지 않게 해준다.

   - 백업 툴이 리두 로그 아카이빙을 사용하려면 먼저 MySQL 서버에서 아카이빙된 리두 로그가 저장될디렉터리를
     innodb_redo_log_archive_dirs 시스템 변수에 설정해야 하며
     이 디렉터리는 운영체제의 MySQL 서버를 실행하는 유저(일반적으로 mysql 유저)만 접근이 가능해야 한다.

     SHOW VARIABLES LIKE '%innodb_redo_log_archive_dirs%';
     +------------------------------+-------+
     | Variable_name                | Value |
     +------------------------------+-------+
     | innodb_redo_log_archive_dirs |       |
     +------------------------------+-------+

     C:
     cd C:\Temp
     mkdir .\mysql\log\archive
     cd .\mysql\log\archive
     mkdir .\21122817

     SET GLOBAL innodb_redo_log_archive_dirs='backup:C:\Temp\mysql\log\archive';

   - 디렉터리가 준비되면 다음과 같이 리두 로그 아카이빙을 시작하도록
     innodb_redo_log_archive UDE(사용자 정의 함수: User Defined Function)를 실행하면 된다.
   - innodb_redo_log_archive_start UDF는 1개 또는 2개의 파라미터를 입력할 수 있는데
     첫 번째 파라미터는 리두 로그를 아카이빙할 디렉터리에 대한 레이블이며 두 번째 파라미터는 서브디렉터리의 이름이다.
     두 번째 파라미터는 입력하지 않아도 되는데
     이때는 innodb_redo_log_archive_dirs 시스템 변수의 레이블에 해당하는 디렉터리 별도 서브디렉터리 없이 리두 로그를 복사한다.

     SELECT innodb_redo_log_archive_start('backup', '21122817');
     or
     DO innodb_redo_log_archive_start('backup', '21122817');

   - 이제 리두 로그 아카이빙이 정상적으로 실행되는지 확인하기 위해 간단히 데이터 변경 명령을 몇 개 실행해보자.

     CREATE TABLE test
     (  id bigint auto increment
     ,  data      mediumtext
     ,  PRIMARY   KEY(id)
     )  ;

     INSERT
       INTO test (data)
     SELECT repeat('123456789',10000)
       FROM employees salaries
      LIMIT 100
     ;

   - INSERT를 실행하고 리두 로그 아카이빙 디렉터리를 확인해보면 다음과 같이 리두 로그의 내용이 아카이빙 파일로 복사된 것을 확인할 수 있다.
     InnoDB의 리두 로그 아카이빙은 로그 파일이 로테이션될때 복사되는 것이 아니라 리두 로그 파일에 로그 엔트리가 추가될 때
     함께 기록되는 방식을 사용하고 있어서 데이터 변경이 발생하면 즉시 아카이빙된 로그 파일의 크기가 조금씩 늘어나는 것을 확인할 수 있다.

     linux) ls -alh 20200722/
     -r--r--- 1 matt.lee 991M 7 22 11:12 archive 56 30884e-726c-11ea-951c-f91ea9f6d340.000001.log


   - 리두 로그 아카이빙을 종료할 때는 innodb_redo_log_archive_stop UDF를 실행하면 된다.
     innodb_redo_log_archive_stop UDF를 실행하면 InnoDB 스토리지 엔진은 리두 로그 아카이빙을 멈추고 아카이빙 파일도 종료한다.
     하지만 아카이빙 파일을 삭제하지 않기 때문에 사용이 완료되면 사용자가 수동으로 삭제해야 한다.

     SELECT innodb_redo_log_archive_stop();
     or
     DO innodb_redo_log_archive_stop();

   - innodb_redo_log_archive_start UDF를 실행한 세션이 계속 연결이 끊어지지 않고 유지돼야 리두 로그 아카이빙이 계속 실행된다.
     만약 리두 로그 아카이빙을 시작한 세션이 innodb_redo_log_archive_stop UDF를 실행하기 전에 연결이 끊어진다면
     InnoDB 스토리지 엔진은 리두 로그 아카이빙을 멈추고 아카이빙 파일도 자동으로 삭제해버린다.
   - 아카이빙을 시작한 세션이 비정상적으로 종료되면서 아카이빙된 리두 로그도 쓸모가 없기 때문이고
     그래서 아카이빙된 리두 로그를 정상적으로 사용하려면 커넥션을 그대로 유지해야 하며
     작업이 완료되면 반드시 innodb_redo_log_archive_stop UDF를 호출해서 아카이빙을 정상적으로 종료해야 한다.


-- 리두 로그 활성화 및 비활성화

   - InnoDB 스토리지 엔진의 리두 로그는 하드웨어나 소프트웨어 등 여러 가지 문제점으로 MySQL 서버가 비정상적으로 종료됐을 때
     데이터 파일에 기록되지 못한 트랜잭션을 복구하기 위해 항상 활성화돼 있다.
   - MySQL 서버에서 트랜잭션이 커밋돼도 데이터 파일은 즉시 디스크로 동기화되지 않는 반면, 리두 로그(트랜잭션 로그)는 항상 디스크로 기록된다.

   - MySQL 8.0 이전 버전까지는 수동으로 리두 로그를 비활성화할 수 있는 방법이 없었지만
     MySQL 8.0 버전부터는 수동으로 리두 로그를 활성화하거나 비활성화할 수 있게 됐다.
   - 그래서 MySQL 8.0 버전부터는 데이터를 복구하거나 대용량 데이터를 한번에 적재하는 경우
     다음과 같이 리두 로그를 비활성화해서 데이터의 적재 시간을 단축시킬 수 있다.

     ALTER INSTANCE DISABLE INNODB REDO_LOG;

     -- // 리두 로그를 비활성화한 후 대량 데이터 적재를 실행 mysql) LOAD DATA
     ALTER INSTANCE ENABLE INNODB REDO_LOG;

   - ALTER INSTANCE [ENABLE { DISABLE] INNODB REDO_LOG 명령을 실행한 후
     Innodb_redo_log_enabled 상태 변수를 살펴보면 리두 로그가 활성화되거나 비활성화됐는지 확인할 수 있다.

     SHOW GLOBAL STATUS LIKE '%Innodb_redo_log_enabled%';
     +-------------------------+-------+
     | Variable_name           | Value |
     +-------------------------+-------+
     | Innodb_redo_log_enabled | ON    |
     +-------------------------+-------+

     ALTER INSTANCE DISABLE INNODB REDO_LOG;

     SHOW GLOBAL STATUS LIKE 'Innodb_redo_log_enabled';
     +-------------------------+-------+
     | Variable_name           | Value |
     +-------------------------+-------+
     | Innodb_redo_log_enabled | OFF   |
     +-------------------------+-------+

   - 리두 로그를 비활성화하고 데이터 적재 작업을 실행했다면 데이터 적재 완료 후 리두 로그를 다시 활성화하는 것을 잊지 말자.
     리두 로그가 비활성화된 상태에서 MySQL 서버가 비정상적으로 종료된다면 MySQL 서버의 마지막 체크포인트 이후 시점의 데이터는
     모두 복구할 수 없게 되며 더 심각한 문제는 MySQL 서버의 데이터가 마지막 체크포인트 시점의 일관된 상태가 아닐 수 있다는 것이다.
   - 예를 들어 마지막 체크포인트가 10시 정각에 실행됐고, 10시 1분에 MySQL 서버가 비정상적으로 종료됐다고 가정해보자.
     이때 리두 로그가 없었다면 재시작된 MySQL 서버의 데이터 파일의 각 부분들은 10시 정각부터 10시 1분까지
     다양한 시점의 데이터를 골고루 갖게 되는 것이다.

   - 주의 : MySQL 서버는 항상 새롭게 시작될 때 자신이 가진 리두 로그에서 데이터 파일에 기록되지 못한 데이터가 있는지 검사를 하게 된다.
            그런데 ALTER INSTANCE DISABLE INNODB REDO_LOG 명령으로 리두 로그가 비활성화된 상태에서 MySQL 서버가 비정상적으로 종료되면
            리두 로그를 이용한 복구가 불가능하기 때문에 MySQL 서버는 정상적으로 시작되지 못할 수도 있다.
            이렇게 리두 로그가 비활성화된 상태에서 MySQL 서버가 재시작되는 경우에는
            innodb_force_recovery 시스템 변수를 6으로 설정 후 다시 시작해야 한다.
            ALTER INSTANCE DISABLE INNODB REDO_LOG 명령으로 리두 로그를 비활성화한 후
            이런저런 작업을 하다 보면 다시 리두로그를 활성화하는 것을 잊어버리기도 하는데,
            이러한 경우 의도하지 않게 데이터가 손실될 수도 있으니 주의하자.
   - 그래서 데이터가 중요하지 않다 하더라도 서비스 도중에는 리두 로그를 활성화해서 MySQL 서버가 비정상적으로 종료돼도
     특정 시점의 일관된 데이터를 가질 수 있게 하자.
   - 만약 MySQL 서버가 비정상적으로 종료되어 데이터가 일부 손실돼도 괜찮다면 리두 로그를 비활성화하는 것보다
     innodb_flush_log.at_trx_commit 시스템 변수를 1이 아닌 0 또는 2로 설정해서 사용할 것을 권장한다.


-- 어댑티브 해시 인덱스

   - 일반적으로 '인덱스'라고 하면 이는 테이블에 사용자가 생성해둔 B-Tree 인덱스를 의미하며 인덱스가 사용하는 알고리즘이 B-Tree는 아니더라도
     사용자가 직접 테이블에 생성해둔 인덱스가 우리가 일반적으로 알고 있는 인덱스일 것이다.
   - 하지만 여기서 언급하는 '어댑티브 해시 인덱스(Adaptive HashIndex)'는 사용자가 수동으로 생성하는 인덱스가 아니라
     InnoDB 스토리지 엔진에서 사용자가 자주 요청하는 데이터에 대해 자동으로 생성하는 인덱스이며
     사용자는 innodb_adaptive_hash_index 시스템변수를 이용해서 어댑티브 해시 인덱스 기능을 활성화하거나 비활성화할 수 있다.

     SHOW VARIABLES LIKE '%innodb_adaptive_hash_index%';
     +----------------------------------+-------+
     | Variable_name                    | Value |
     +----------------------------------+-------+
     | innodb_adaptive_hash_index       | ON    |
     | innodb_adaptive_hash_index_parts | 8     |
     +----------------------------------+-------+

   - B-Tree 인덱스에서 특정 값을 찾는 과정은 매우 빠르게 처리된다고 많은 사람이 생각 하지만 결국 빠르냐 느리냐의 기준은 상대적인 것이며
     데이터베이스 서버가 얼마나 많은 일을 하느냐에 따라 B-Tree 인덱스에서 값을 찾는 과정이 느려질 수도 있고 빨라질 수도 있다.
   - B-Tree 인덱스에서 특정값을 찾기 위해서는 B-Tree의 루트 노드를 거쳐서 브랜치 노드
     그리고 최종적으로 리프 노드까지 찾아가야 원하는 레코드를 읽을 수 있다.
   - 적당한 사양의 컴퓨터에서 이런 작업을 동시에 몇 개 실행한다고 해서 성능 저하가 보이지는 않을 것이며 하지만
     이런 작업을 동시에 몇천 개의 스레드로 실행하면 컴퓨터의 CPU는 엄청난 프로세스 스케줄링을 하게 되고 자연히 쿼리의 성능은 떨어진다.

   - 어댑티브 해시 인덱스는 이러한 B-Tree 검색 시간을 줄여주기 위해 도입된 기능이고 InnoDB 스토리지 엔진은 자주 읽히는 데이터 페이지의 키 값을
     이용해 해시 인덱스를 만들고, 필요할 때마다 어댑티브 해시 인덱스를 검색해서 레코드가 저장된 데이터 페이지를 즉시 찾아갈 수 있다.
   - B-Tree를 루트노드부터 리프 노드까지 찾아가는 비용이 없어지고 그만큼 CPU는 적은 일을 하지만 쿼리의 성능은 빨라지고
     그와 동시에 컴퓨터는 더 많은 쿼리를 동시에 처리할 수 있게 된다.

   - 해시 인덱스는 인덱스 키 값과 해당 인덱스 키 값이 저장된 데이터 페이지 주소'의 쌍으로 관리되는데,
     인덱스 키 값은 'B-Tree 인덱스의 고유번호(Id)와 B-Tree 인덱스의 실제 키 값' 조합으로 생성된다.
   - 어댑티브 해시 인덱스의 키 값에 B-Tree 인덱스의 고유번호가 포함되는 이유는 InnoDB 스토리지 엔진에서
     어댑티브 해시 인덱스는 하나만 존재(물론 파티션되는 기능이 있지만)하기 때문이다.
   - 즉, 모든 B-Tree 인덱스에 대한 어댑티브 해시 인덱스가 하나의 해시 인덱스에 저장되며
     특정 키 값이 어느 인덱스에 속한 것인지도 구분해야 하기 때문이다.
   - 그리고 '데이터 페이지 주소'는 실제 키 값이 저장된 데이터 페이지의 메모리 주소를 가지는데
     이는 InnoDB 버퍼 풀에 로딩된 페이지의 주소를 의미하고 어댑티브 해시 인덱스는 버퍼 풀에 올려진 데이터 페이지에 대해서만 관리되고
     버퍼 풀에서 해당 데이터 페이지가 없어지면 어댑티브 해시 인덱스에서도 해당 페이지의 정보는 사라진다.

   - 다음과 같이 단순한 쿼리를 MySQL 서버가 최대한 처리할 수 있는 수준까지 실행하는 상태에서 어댑티브 해시 인덱스를 활성화했을 때의 변화를 보임.

     SELECT fd1 FROM tab WHERE idx_fd2 IN (?, ?, ?, ?, ...);

   - 어댑티브 해시 인덱스가 활성화되지 않았을 때는 초당 20,000개 정도의 쿼리를 처리하면서 CPU AS률은 100%였다.
     그런데 어댑티브 해시 인덱스를 활성화한 후 쿼리의 처리량은 2배 가까이 늘어났음도 불구하고 CPU 사용률은 오히려 떨어진 것을 볼 수 있다.
     물론 B-Tree의 루트 노드부터 검색이 등이 줄면서 InnoDB 내부 잠금(세마포어)의 횟수도 획기적으로 줄어든다.

   - 예전 버전까지는 어댑티브 해시 인덱스는 하나의 메모리 객체인 이유로 어댑티브 해시 인덱스의 경합(Contention)이 상당히 심했다.
     그래서 MySQL 8.0부터는 내부 잠금(세마포어) 경합을 줄이기 위해 어댑티브 해시 인덱스의 파티션 기능을 제공한다.
   - innodb_adaptive_hash_index_parts 시스템 변수를 이용해 파티션 개수를 변경할 수 있는데 기본값은 8개이며 만약 어댑티브 해시 인덱스가 성능에
     많은 도움이 된다면 파티션 개수를 더 많이 설정하는 것도 어댑티브 해시 인덱스의 내부 잠금 경합을 줄이는데 많은 도움이 될 것이다.

   - 여기까지만 보면 InnoDB 스토리지 엔진의 어댑티브 해시 인덱스는 팔방미인처럼 보이지만
     실제 어댑티브 해시 인덱스를 의도적으로 비활성화하는 경우도 많다.
     어댑티브 해시 인덱스가 성능 향상에 크게 도움이 되지 않는 경우는 다음과 같다.

     . 디스크 읽기가 많은 경우
     . 특정 패턴의 쿼리가 많은 경우(조인이나 LIKE 패턴 검색)
     . 매우 큰 데이터를 가진 테이블의 레코드를 폭넓게 읽는 경우

     그리고 다음과 같은 경우에는 성능 향상에 많은 도움이 된다.

     . 디스크의 데이터가 InnoDB 버퍼 크기와 비슷한 경우(디스크 읽기가 많지 않은 경우)
     . 동등 조건 검색(동등 비교와 IN 연산자)이 많은 경우
     . 쿼리가 데이터 중에서 일부 데이터에만 집중되는 경우

   - 하지만 단순히 어댑티브 해시 인덱스가 도움이 될지 아닐지를 판단하기는 쉽지 않고 한 가지 확실한것은 어댑티브 해시 인덱스는
     데이터 페이지를 메모리(버퍼 풀) 내에서 접근하는 것을 더 빠르게 만드는 기능이기 때문에
     데이터 페이지를 디스크에서 읽어오는 경우가 빈번한 데이터베이스 서버에서는 아무런 도움이 되지 않는다는 점이다.
   - 하나 더 기억해야 할 것은 어댑티브 해시 인덱스는 '공짜 점심'이 아니고 어댑티브 해시 인덱스 또한 저장 공간인 메모리를 사용하며
     때로는 상당히 큰 메모리공간을 사용할 수도 있다.
   - 어댑티브 해시 인덱스 또한 데이터 페이지의 인덱스 키가 해시 인덱스로 만들어져야 하고 불필요한 경우 제거돼야 하며
     어댑티브 해시 인덱스가 활성화되면 InnoDB 스토리지 엔진은 그 키 값이 해시 인덱스에 있든 없든 검색해봐야 한다는 것이며
     즉, 해시 인덱스의 효율이 없는경우에도 InnoDB는 계속 해시 인덱스를 사용할 것이다.

   - 어댑티브 해시 인덱스는 테이블의 삭제 작업에도 많은 영향을 미치고 어떤 테이블의 인덱스가 어댑티브 해시 인덱스에 적재돼 있다고 가정해보자.
   - 이때 이 테이블을 삭제(DROP) 하거나 변경(ALTER) 하려고하면 InnoDB 스토리지 엔진은
     이 테이블이 가진 모든 데이터 페이지의 내용을 어댑티브 해시 인덱스에서 제거해이 한다.
   - 이로 인해 테이블이 삭제되거나 스키마가 변경되는 동안 상당히 많은 CD사용하고, 그만큼 데이터베이스 서버의 처리 성능이 느려지고
     이후 버전에서는 개선되겠지만 MySQL8.0.20 버전에서는 다음과 같은 INSTANT 알고리즘의 Online DDL도 상당한 시간이 소요되기도 한다.

     ALTER TABLE employees ADD address VARCHAR(200), ALGORITHM=INSTANT;

   - 어댑티브 해시 인덱스의 도움을 많이 받을수록 테이블 삭제 또는 변경 작업(Online DDL, 포)치명적인 작업이 되는 것이다.
     이는 어댑티브 해시 인덱스의 사용에 있어서 매우 중요한 부분이므로 기억해 두자.

   - 어댑티브 해시 인덱스가 우리 서비스 패턴에 맞게 도움이 되는지 아니면 불필요한 오버헤드만 만들고 있는지를 판단해야 하는데
     정확한 판단을 할 수 있는 가장 쉬운 방법은 MySQL 서버의 상태 값들을 살펴보는 것이다.
   - MySQL 서버에서 어댑티브 해시 인덱스는 기본적으로 활성화돼 있기 때문에 특서버 설정을 변경하지 않았다면
     이미 어댑티브 해시 인덱스를 사용 중인 상태이며, 아래 상태 값들이 유효한 통계를 가지고 있을 것고
     어댑티브 해시 인덱스가 비활성화돼 있다면 다음 상태 값 중에서 'hash searches/s' 의 값이 0으로 표시될 것이다.

     SHOW ENGINE INNODB STATUS \G
     ...
     -------------------------------------
     INSERT BUFFER AND ADAPTIVE HASH INDEX
     -------------------------------------
     ...
     Hash table size 2267, node heap has 1 buffer(s)
     Hash table size 2267, node heap has 1 buffer(s)
     Hash table size 2267, node heap has 0 buffer(s)
     Hash table size 2267, node heap has 1 buffer(s)
     Hash table size 2267, node heap has 1 buffer(s)
     Hash table size 2267, node heap has 1 buffer(s)
     Hash table size 2267, node heap has 2 buffer(s)
     Hash table size 2267, node heap has 4 buffer(s)
     0.00 hash searches/s, 0.00 non-hash searches/s
     ...

   - 위의 결과를 보면, 초당 3,67(=2.64 + 1.03)번의 검색이 실행됐는데,
     그중 1.03번은 어댑티브 해시 인데스를 사용했으며 2,64번은 해시 인덱스를 사용하지 못했다는 것을 알 수 있다.
     여기서 searches는 쿼리의 실행 횟수를 의미하는 것이 아니라 쿼리가 처리되기 위해 내부적으로 키 값의 검색이 몇 번 실행됐느나를 의미한다.
   - 어댑티브 해시 인덱스의 효율은 검색 횟수가 아니라 두 값의 비율(해시 인덱스 히트율)과 이댑티브 해시 인덱스가 사용 중인 메모리 공간
     그리고 서버의 CPU 사용량을 종합해서 판단해야 하며 위 예제에서는 28% 징도가 어댑티브 헤시 인덱스를 이용했다는 것을 알 수 있다.
   - 이 서버의 CPU 사용량이 100%에 근접하다면 어댑티브 해시 인덱스는 효율적이라고 볼 수 있고
     그런데 CPU 사용량은 높지 않은데 28% 정도의 히트율이라면 어댑티브 해시 인덱스를 비활성화하는 편이 더 나을 수도 있다.
   - 이 경우에는 어댑티브 해시 인덱스가 사용 중인 메모리 사용량이 높다면 어댑티브 해시 인덱스를 비활성화해서
     InnoDB 버퍼 풀이 더 많은 메모리를 사용할 수 있게 유도하는 것도 좋은 방법이다.
   - 어딥티브 해시 인덱스의 메모리 사용량은 다음과 같이 performance_schema를 이용해서 확인 가능하다.

     SELECT m.event_name
          , m.current_number_of_bytes_used
          # SELECT m.*
       FROM performance_schema.memory_summary_global_by_event_name m
      WHERE m.event_name LIKE '%memory/innodb/adaptive hash index%'
     ;
     +-----------------------------------+------------------------------+
     | event_name                        | current_number_of_bytes_used |
     +-----------------------------------+------------------------------+
     | memory/innodb/adaptive hash index |                         1232 |
     +-----------------------------------+------------------------------+


-- InnoDB와 MyISAM, MEMORY 스토리지 엔진 비교

   - 지금까지는 MyISAM이 기본 스토리지 엔진으로 사용되는 경우가 많았고 MySQL 5.5부터는 InnoDB 스토리지 엔진이 기본 스토리지 엔진으로 채택됐지만
     MySQL 서버의 시스템 테이블(사용자 인증 관련된 정보와 복제 관련된 정보가 저장된 mysql DB의 테이블)은 여전히 MyISAM 테이블을 사용했다.
   - 또한 전문 검색이나 공간 좌표 검색 기능은 MyISAM 테이블에서만 지원됐고
     하지만 MySQL 8.0으로 업그레이드되면서 MySQL 서버의 모든 시스템 테이블이 InnoDB 스토리지 엔진으로 교체됐고
     공간 좌표 검색이나 전문 김색 기능이 모두 InnoDB 스토리지 엔진을 지원하도록 개선됐다.
   - MySQL 8.0 버전부터는 MySQL 서버의 모든 기능을 InnoDB 스토리지 엔진만으로 구현할 수 있게 된 것이고
     InnoDB 스토리지 엔진에 대한 기능이 개선되는 만큼 MyISAM 스토리지 엔진의 기능은 도태되는 상황이며
     이후 버전에서는 MyISAN 스토리지 엔진은 없어질 것으로 예상한다.

   - 지금도 가끔씩 MyISAMM이나 MEMORY 스토리지 엔진에 대한 성능상 장점을 기대하는 사용자이는데
     MySQL 5.1과 5.5 버전이라면 의미가 있는 비교겠지만 MySQL 8.0에서는 더이상 무의미한 비교가 될 것으로 보인다.
     이미 MySQL 8.0에서는 MySQL 서버의 모든 기능이 InnoDB 스토리지 엔지 기반으로 재편됐고 MyISAM 스토리지 엔진만이 가지는 장점이 없는 상태다.

   - 때로는 MEMORY 스토리지 엔진이 'MEMORY'라는 이름 때문에 과대평가를 받는 경우가 있지만
     MEMORY 스토리지 엔진 또한 동시 처리 성능에 있어서 InnoDB 스토리지 엔진을 따라갈 수 없다.
   - MEMORY 스토리지 엔진은 모든 처리를 메모리에서만 수행하니 빠를 것이라고 예상할 수 있지만
     하나의 스레드에서만 데이터를 읽고 쓴다면 InnoDB보다 빠를 수 있다.
   - 하지만 MySQL 서버는 일반적으로 온라인 트랜잭션 처리를 위한 목적으로 사용되며 온라인 트랜잭션 처리에서는 동시 처리, 능이 매우 중요하다.
     동시에 몇십 또는 몇백 개의 클라이언트에서 쿼리 요청이 실행되는 경우라면
     MEMORY 스토리지 엔진은 테이블 수준의 잠금으로 인해 제대로 된 성능을 내지 못할 것이다.

   - MySQL 서버는 사용자의 쿼리를 처리하기 위해 내부적으로 임시 테이블을 사용할 수도 있다.
     MySQL 5.7 버전까지만 해도 MEMORY 스토리지 엔진이 내부 임시 테이블의 용도로 사용됐다.
   - 하지만 MEMORY 스토리지 엔진은 가변 길이 타입의 칼럼을 지원하지 않는다는 문제점 때문에
     MySQL 8.0부터는 TempTable 스토리지 엔진이 MEMORY 스토리지 엔진을 대체해 사용되고 있다.
   - MySQL 8.0에서는 internal_tmp_mem_storage_engine 시스템 변수를 이용해 내부 임시 테이블을 위해
     TempTabie 엔진을 사용할지 MEMORY 엔진을 사용할지 선택할 수 있다.

     SHOW VARIABLES LIKE '%internal_tmp_mem_storage_engine%';
     +---------------------------------+-----------+
     | Variable_name                   | Value     |
     +---------------------------------+-----------+
     | internal_tmp_mem_storage_engine | TempTable |
     +---------------------------------+-----------+

   - internal_tmp_mem_storage_engine 시스템 변수의 기본값은 TempTable인데 이를 MEMORY 스토리지 엔진으로 변경할 수 있고
     하지만 굴이 MEMORY 스토리지 엔진을 선택해서 얻을 수 있는 장점이 없어졌으며
     MEMORY 스토리지 엔진은 이전 버전과의 호환성 유지 차원일 뿐 향후 비전에서는 제거될 것으로 보인다.


-- MyISAM 스토리지 엔지 아키텍처


-- 키 캐시

   - InnoDB의 버퍼 풀과 비슷한 역할을 하는 것이 MyISAM의 키 캐시(Key cache, 키 버퍼라고도 불림)다.
     하지만 이름 그대로 MyISAM 키 캐시는 인덱스만을 대상으로 작동하며 또한 인덱스의 디스크 쓰기 작업에 대해서만 부분적으로 버퍼링 역할을 한다.
     키 캐시가 얼마나 효율적으로 작동하는지는 다음 수식으로 간단히 확인할 수 있다.

     키 캐시 히트율(Hit rate) = 100 - (Key_reads / Key_read_requests * 100)

   - Key_reads는 인덱스를 디스크에서 읽어 들인 횟수를 저장하는 상태 변수이며
     Key_read_requests는 키캐시로부터 인덱스를 읽은 횟수를 저장하는 상태 변수다.
     이 상태 값을 알아보려면 다음과 같이 SHOWGLOBAL STATUS 명령을 사용하면 된다.

     SHOW GLOBAL STATUS LIKE 'key%';
     +------------------------+-------+
     | Variable_name          | Value |
     +------------------------+-------+
     | Key_blocks_not_flushed | 0     |
     | Key_blocks_unused      | 6698  |
     | Key_blocks_used        | 0     |
     | Key_read_requests      | 0     |
     | Key_reads              | 0     |
     | Key_write_requests     | 0     |
     | Key_writes             | 0     |
     +------------------------+-------+

   - 매뉴얼에서는 일반적으로 키 캐시를 이용한 쿼리의 비율(히트율, Hit rate)을 99% 이상으로 유지하다고 권장한다.
     히트율이 99% 미만이라면 키 캐시를 조금 더 크게 설정하는 것이 좋다.
   - 32비트 운영체제에서는 하나의 키 캐시에 4GB 이상의 메모리 공간을 설정할 수 없고
     64비트 운영체계에서는 OS_PER_PROCESS_LIMIT 값에 설정된 크기만큼의 메모리를 할당할 수 있다.
   - 제한 값 이상의 키 캐시를 할당하고 싶다면 기본(Default) 키 캐시 이외에 별도의 명명된(이름이 붙은) 키 캐시 공간을 설정해야 하고
     기본(Default) 키 캐시 공간을 설정하는 파라미터는 key_buffer_size다.

     SHOW VARIABLES LIKE '%key_buffer_size%';
     +-----------------+---------+
     | Variable_name   | Value   |
     +-----------------+---------+
     | key_buffer_size | 8388608 | # (8*1024*1024)
     +-----------------+---------+

     key_buffer_size = 4GB
     kbuf_board.key_buffer_size = 2GB
     kbuf_comment.key_buffer_size = 2GB

   - 위와 같이 설정하면 기본 키 캐시 4GB와 kbuf board와 kbuf_comment라는 이름의 키 캐시가 각각 2GB씩 생성된다.
     하지만 기본 기 캐시 이외의 명명된 기 캐시 영역은 아무런 설정을 하지 않으면 메모리 할당만 해두고 사용하지 않게 된다는 점에 주의해야 한다.
   - 즉, 기본(Default)이 아닌 명명된 추가 키 캐시는 어떤 인덱스를 캐시할지 MySQL(MyISAM 스토리지 엔진)에 알려줘야 한다
     (왜 키 캐시의 이름을 kbuf_board와 kbuf_comment로 지정했는지 이해될 것이다).
     그럼 명명된 각 키 캐시에 게시판 테이블(board)의 인덱스와 코멘트 테이블(comment)의 인덱스가 개시되도록 설정해 보자.

     CACHE INDEX db1.board, db2.board IN kbuf_board;
     CACHE INDEX db1.comment, db2.comment IN kbuf_comment;

   - 이렇게 설정하면 비로소 board 테이블의 인덱스는 kbuf_board 키 캐시를 Comment 테이블의 인덱스는 kbuf_commnet 키 캐시를 사용할 수 있다.
     나머지 테이블의 인덱스는 예전과 동일하게 기본 키 캐시를 사용한다.
     키 캐시에 대한 더 자세한 설명은 MySQL 매뉴얼의 'Multiple Key caches' 부분을 참고하자.


-- 운영체제의 캐시 및 버퍼

   - MyISAM 테이블의 인덱스는 키 캐시를 이용해 디스크를 검색하지 않고도 충분히 빠르게 검색할 수 있지만 MyISAM 테이블의 데이터에 대해서는
     디스크로부터의 I/O를 해결해 줄 만한 어떠한 캐시나 버퍼링 기능도 MyISAM 스토리지 엔진은 가지고 있지 않다.
     그래서 MyISAM 테이블의 데이터 읽기나 쓰기 작업은 항상 운영체제의 디스크 읽기 또는 쓰기 작업으로 요청될 수밖에 없다.
   - 물론 대부분의 운영체제에는 디스크로부터 읽고 쓰는 파일에 대한 캐시나 버퍼링 메커니즘을 탑재하고 있기 때문에
     MySQL 서버가 요청하는 디스크 읽기 작업을 위해 매번 디스크의 파일을 읽지는 않는다.
   - 운영체제의 캐시 기능은 InnoDB처럼 데이터의 특성을 알고 전문적으로 캐시나 버퍼링을 하지는 못하지만 그래도 여전히 없는 것보다는 낫다.
   - 운영체제의 캐시 공간은 남는 메모리를 사용하는 것이 기본 원칙이고 전체 메모리가 8GB인데 MySQL이나 다른 애플리케이션에서 메모리를
     모두 사용해 버린다면 운영체제가 캐시 용도로 사용할 수 있는 메모리 공간이 없어진다.
     이런 경우에는 MyISAM 테이블의 데이터를 캐시하지 못하며 결론적으로 MyISAM 테이블에 대한 쿼리 처리가 느려진다.
   - 데이터베이스에서 MyISAM 테이블을 주로 사용한다면 운영체제가 사용할 수 있는 캐시 공간을 위해
     충분한 메모리를 비워둬야 이러한 문제를 방지할 수 있다.
   - MyISAM이 주로 사용되는 MySQL에서 일반적으로 키 캐시는 최대 물리 메모리의 40% 이상을 넘지 않게 설정하고
     나머지 메모리 공간은 운영체제가 자체적인 파일 시스템을 위한 캐시 공간을 마련할 수 있게 해주는 것이 좋다.


-- 데이터 파일과 프라이머리 키(인덱스) 구조

   - InnoDB 스토리지 엔진을 사용하는 테이블은 프라이머리 키에 의해서 클러스터링되어 저장되는 반면
     MyISAM 테이블은 프라이머리 키에 의한 클러스터링 없이 데이터 파일이 힙(Heap) 공간처럼 활용된다.
     즉 MyISAM 테이블에 레코드는 프라이머리 키 값과 무관하게 INSERT되는 순서대로 데이터 파일에 저장된다.
   - 그리고 MyISAM 테이블에 저장되는 레코드는 모두 ROWID라는 물리적인 주솟값을 가지는데
     프라이머리 키와 세컨더리 인덱스는 모두 데이터 파일에 저장된 레코드의 ROWID 값을 포인터로 가진다.
   - MyISAM 테이블에서 ROWID는 가변 길이와 고정 길이의 두 가지 방법으로 저장될 수 있다.

     . 고정 길이 ROWID
       자주 사용되지는 않지만 MyISAM 테이블을 생성할 때 MAX_ROWS 옵션을 사용할 수 있는데
       MyISAM 테이블을 생성할 때 MAX_ROWS 옵션을 명시하면 MySQL 서버는 최대로 가질 수 있는 레코드가 한정된 테이블을 생성한다.
       이렇게 MAX_ROWS 옵션에 의해 MyISAM 테이블이 가질 수 있는 레코드의 개수가 한정되면
       MyISAM 테이블은 ROWID 값으로 4바이트 정수를 사용한다. 이때 레코드가 INSERT된 순번이 ROWID로 사용된다.

     . 가변 길이 ROWID
       MyISAM 테이블을 생성할 때 MAX_ROWS 옵션을 설정하지 않으면 MyISAM 테이블의 ROWID는
       최대 myisam_data_pointer_size 시스템 변수에 설정된 바이트 수만큼의 공간을 사용할 수 있다.
       myisam_data_pointer_size 시스템 변수의 기본값은 7이므로 MyISAM 테이블의 ROWID는 2바이트부터 7바이트까지 가변적인 ROMO를 기는데
       그중에서 첫 번째 바이트는 ROWID의 길이를 저장하는 용도로 사용하고 나머지 공간은 실제 RONIOS TAL하는 데 사용한다.
       MyISAM 테이블이 가변적인 ROWID를 가지면 데이터 파일에서 레코드의 위치(offset)가 ROWID로 사용된다.
       그래서 MAX_ROWS 옵션이 명시되지 않은 MyISAM 테이블의 최대 크기는 256TB가 되는 것이다.
       만약 256TB 이상 크기의 데이터 파일이 필요한 경우에는 myisam_data_pointer_size 시스템 변수를 로정하면
       MyISAM 테이블의 데이터 파일 크기를 최대 64PB까지 저장할 수 있게 된다.

       SHOW VARIABLES LIKE '%myisam%';
       +---------------------------+----------------------+
       | Variable_name             | Value                |
       +---------------------------+----------------------+
       | myisam_data_pointer_size  | 6                    |
       | myisam_max_sort_file_size | 107374182400         | # (100*1024*1024*1024)
       | myisam_mmap_size          | 18446744073709551615 | # (16*1024*1024*1024*1024*1024*1024)
       | myisam_recover_options    | OFF                  |
       | myisam_repair_threads     | 1                    |
       | myisam_sort_buffer_size   | 38797312             | # (37*1024*1024)
       | myisam_stats_method       | nulls_unequal        |
       | myisam_use_mmap           | OFF                  |
       +---------------------------+----------------------+


-- MySQL 로그 파일

   - MySQL 서버에서 서버의 상태를 진단할 수 있는 많은 도구들이 지원되지만 이러한 기능들은 많은 기식을 필요로 하는 경우가 많다.
     하지만 로그 파일을 이용하면 MySQL 서버의 깊은 내부 지식이 없어도 MySQL의 상태나 부하를 일으키는 원인을 쉽게 찾아서 해결할 수 있다.
   - 많은 사용자가 로그 파일의용을 무시하고 다른 방법으로 해결책을 찾으려고 노력하곤 하는데
     무엇보다 MySQL 서버에 문제가 생겼을 때는 다음에 설명하는 로그 파일들을 자세히 확인하는 습관을 들일 필요가 있다.


-- 에러 로그 파일

   - MySQL이 실행되는 도중에 발생하는 에러나 경고 메시지가 출력되는 로그 파일이고
     에러 로그 파일의 위치는 MySQL 설정 파일(my.cnf)에서 log.eror라는 이름의 파라미터로 정의된 경로에 생성된다.
   - MySQL 설정 파일에 별도로 정의되지 않은 경우에는 데이터 디렉터리(datadir 파라미터에 설정된 디렉터리)에 .err라는 확장자가 붙은 파일로 생성.
     여러 가지 메시지가 다양하게 출력되지만 다음의 소개되는 메시지들을 가장 자주 보게 될 것이다.


-- MySQL이 시작하는 과정과 관련된 정보성 및 에러 메시지

   - MySQL의 설정 파일을 빈경하거나 데이터베이스가 비정상적으로 종료된 이후 다시 시작하는 경우에는
     반드시 MySQL 에러 로그 파일을 통해 설정된 변수의 이름이나 값이 명확하게 설정되고 의도한 대로 사용됐는지 확인해야 한다.
   - MySQL 서비가 정상적으로 기동했고('mysqld: ready forconnections' 메시지 확인)
     새로 변경하거나 추가한 파라미터에 대한 특별한 에러나 경고성 메시지가 없다면 정상적으로 적용된 것으로 판단하면 된다.
   - 그렇지 않고 특정 변수가 무시(fignore)된 경우에는 MySQL 서버는 정상적으로 기동하지만 해당 파라미터는 MySQL에 적용되지 못했음을 의미한다.
     그리고 변수명을 인식하지 못하거나 설정된 파라미터 값의 내용을 인식하지 못하는 경우에는
     MySQL 서버가 에러 메시지를 출력하고 시작하지 못했다는 메시지를 보여줄 것이다.



-- 마지막으로 종료할 때 비정상적으로 종료된 경우 나타나는 InnoDB의 트랜잭션 복구 메시지

   - InnoDB의 경우에는 MySQL 서버가 비정상적 또는 강제적으로 종료됐다면 다시 시작되면서 완료되지 못한 트랜잭션을 정리하고
     디스크에 기록되지 못한 데이터가 있다면 다시 기록하는 재처리 작업을 하게 된다.
     이 과정에 대한 간단한 메시지가 출력되는데 간혹 문제가 있어서 복구되지 못할 때는 해당 에러 메시지를 출력하고 MySQL은 다시 종료될 것이다.
   - 일반적으로 이 단계에서 발생하는 문제는 상대적으로 해결하기가 어려운 문재심일 때가 많고 때로는
     innodb_force_recovery 파라미터를 0보다 큰 값으로 설정하고 재시작해야만 MSOL이 시작될 수도 있으며
     innodb_force_recovery 파라미터에 대한 자세한 내용은 4.2.6질 자동화된 장에 복구를 참조하거나 MySQL, 매뉴얼을 참조하자.

     SHOW VARIABLES LIKE '%innodb_force_recovery%';
     +-----------------------------+-------+
     | Variable_name               | Value |
     +-----------------------------+-------+
     | innodb_force_recovery       | 0     |
     +-----------------------------+-------+


-- 쿼리 처리 도중에 발생하는 문제에 대한 에러 메시지

   - 쿼리 도중 발생하는 문제점은 사전 예방이 어려우며 주기적으로 에러 로그 파일을 검토하는 과정에서 알게 된다.
     쿼리의 실행 도중 발생한 에러나 복제에서 문제가 될 만한 쿼리에 대한 경고 메시지가 에러 로그에 기록된다.
     그래서 자주 에러 로그 파일을 검토하는 것이 데이터베이스의 숨겨진 문제점을 해결하는 데 많이 도움될 것이다.


-- 비정상적으로 종료된 커넥션 메시지(Aborted connection)

   - 어떤 데이터베이스 서버의 로그 파일을 보면 이 메시지가 상당히 많이 누적돼 있는 경우가 있다.
     클라이언트 애플리케이션에서 정상적으로 접속 종료를 하지 못하고 프로그램이 종료된 경우 MySQL 서버의 에러 로그 파일에 이런 내용이 기록된다.
   - 물론 중간에 네트워크에 문제가 있어서 의도하지 A속이 끊어지는 경우에도 이런 메시지가 기록되고
     이런 메시지가 아주 많이 기록된다면 애플리의 커넥션 종료 로직을 한번 검토해볼 필요가 있다.
   - max_connect_errors 시스템 변숫값이 너무 낮게 정된 경우 클라이언트 프로그램이 MySQL 서버에 접속하지 못하고
     "Host 'host_name' is blockeld" 라는 에러가 발생할 수도 있다.
   - 이 메시지는 클라이언트 호스트에서 발생한 에러(커넥션 실패나 강제 연결 종료와 같은)의 횟수가
     max_connect_errors 시스템 변수의 값을 증가시키면 되고 하지만 먼저 이 에러가 어떻게 발생하게 됐는지 그 원인을 살펴보는 것이 좋다.

     SHOW VARIABLES LIKE '%max_connect_errors%';
     +------------------------+-------+
     | Variable_name          | Value |
     +------------------------+-------+
     | max_connect_errors     | 100   |
     +------------------------+-------+


-- InnoDB의 모니터링 또는 상태 조회명령(SHOW ENGINE INNODB STATUS 같은)의 결과 메시지

   - InnoDB의 테이블 모니터링이나 락 모니터링
     또는 InnoDB의 엔진 상태를 조회하는 명령은 상대가으로 큰 메시지를 에러 로그 파일에 기록한다.
   - InnoDB의 모니터링을 활성화 상태로 만들어 두고 그대로 유지하는 경우에는
     에러 로그 파일이 매우 커져서 파일 시스템의 공간을 다 사용해 버릴지도 모르고
     모니터링을 사용한 이후에는 다시 비활성화해서 에러 로그 파일이 커지지 않게 만들어야 한다.


-- 제너럴 쿼리 로그 파일(제너럴 로그 파일, General log)

   - 가끔 MySQL 서버에서 실행되는 쿼리로 어떤 것들이 있는지 전체 목록을 뽑아서 검토해 볼 때가 있는데
     이때는 쿼리 로그를 활성화해서 쿼리를 쿼리 로그 파일로 기록하게 한 다음 그 파일을 검토하면 되고
     쿼리 로그 파일에는 다음과 같이 시간 단위로 실행됐던 쿼리의 내용이 모두 기록된다.
   - 슬로우 쿼리로 그와는 조금 다르게 제너럴 쿼리 로그는 실행되기 전에 MySQL이 쿼리 요청을 받으면 바로 기록하기 때문에
     쿼리 실행 중에 에러가 발생해도 일단 로그 파일에 기록된다.

   - 쿼리 로그 파일의 경로는 general_log_file이라는 이름의 파라미터에 설정돼 있다.
     또한 쿼리 로그를 파일이 아닌 테이블에 저장하도록 설정할 수 있으므로 이 경우에는 파일이 아닌 테이블을 SQL로 조회해서 검토해야 한다.

     SHOW VARIABLES LIKE '%general_%';
     +------------------+---------------------+
     | Variable_name    | Value               |
     +------------------+---------------------+
     | general_log      | OFF                 |
     | general_log_file | CHANGHEE-NOTEBO.log |
     +------------------+---------------------+

   - 쿼리 로그를 파일로 저장할지 테이블로 저장할지는 log_output 파라미터로 결정된다.
     제너럴 로그와 관련된 상세한 내용은 MSOL 매뉴얼의 'log output 설정 파라미터와 The General Query Log' 절을 참조하자.
     또한 로그 파일의 경로에 관련된 상세한 내용은 MySQL 매뉴얼의 'Selecting General Query and Slow Quer Log Output Destinations'를 참조하자.

     SHOW VARIABLES LIKE '%log_output%';
     +---------------+-------+
     | Variable_name | Value |
     +---------------+-------+
     | log_output    | FILE  |
     +---------------+-------+


-- 슬로우 쿼리 로그

   - MySQL 서버의 쿼리 튜닝은 크게 서비스가 적용되기 전에 전체적으로 튜닝하는 경우와 서비스 운영중에
     MySQL 서버의 전체적인 성능 저하를 검사하거나 정기적인 점검을 위한 튜닝으로 나눌 수 이다.
   - 전자의 경우에는 검토해야 할 대상 쿼리가 전부라서 모두 튜닝하면 되지만 후자의 경우에는 어떤 쿼리가 문제의 쿼리인지 판단하기가 상당히 어렵다.
     이런 경우에 서비스에서 사용되는 쿼리 중에서 어떤 쿼리가 문제인지를 판단하는데 슬로우 쿼리 로그가 상당히 많은 도움이 된다.
   - 슬로우 쿼리 로그 파일에는 long_query_time 시스템 변수에 설정한 시간
     (long_query_time 파라미터는초단위로 설정하지만 소수점 값으로 설정하면 마이크로 초 단위로 설정 가능함)
     이상의 시간이 소요된 쿼리가 모두 기록된다.
   - 슬로우 쿼리 로그는 MySQL이 쿼리를 실행한 후 실제 소요된 시간을 기준이슬로우 쿼리 로그에 기록할지 여부를 판단하기 때문에
     반드시 쿼리가 정상적으로 실행이 완료돼야로우 쿼리 로그에 기록될 수 있다.
     즉, 슬로우 쿼리 로그 파일에 기록되는 쿼리는 일단 정상적으로 실이 완료됐고 실행하는데 걸린 시간이
     long_query_time에 정의된 시간보다 많이 걸린 쿼리인 것이다.

     SHOW VARIABLES LIKE '%long_query_time%';
     +-----------------+-----------+
     | Variable_name   | Value     |
     +-----------------+-----------+
     | long_query_time | 10.000000 |
     +-----------------+-----------+

   - log_output 옵션을 이용해 슬로우 쿼리 로그를 파일로 기록할지 테이블로 기록할지 선택할 수 있고
     log_output 옵션을 TABLE로 설정하면 제너럴 로그나 슬로우 쿼리 로그를 mysql DB의 테이(generallog와 slow_log 테이블)에
     저장하며 FILE로 설정하면 로그의 내용을 디스크의 파일로 저장한다.
   - log_output 옵션을 TABLE로 설정하더라도 mysql DIB의 slow_log 테이블과 general_log 테이블은
     CSV 스토리지 엔진을 사용하기 때문에 결국 CSV 파일로 저장하는 것과 동일하게 작동한다.

   - 위와 같이 설정하면 실제 슬로우 쿼리 로그 파일에는 다음과 같은 형태로 내용이 출력되고
     MySQL의 잠금 처리는 MySQL 엔진 레벨과 스토리지 엔진 레벨의 두 가지 레이어로 처리되는데
     MyISAN이나 MEMORY 스토리지 엔진과 같은 경우에는 별도의 스토리지 엔진 레벨의 잠금을 가지지 않지만
     InnoDB의 경우 MySQL 엔진 레벨의 잠금과 스토리지 엔진 자체 잠금을 가지고 있다.
     이런 이유로 슬로우 쿼리 로그에 출력되는 내용이 상당히 혼란스러울 수 있다.

     # Time: 2020-07-19T15:44:22.178484+09:00
     # UserHost: root[root] g localhost U Id: 14
     # Query_time: 1.180245 Lock_time: 0.002658 Rows_sent: 1 Rows examined: 2844047
     use employees;
     SET timestamp=1595141060;
     select emp_no, max(salary) from salaries;

   - 위의 슬로우 쿼리 로그 내용을 한 번 확인해 보자.
     이 내용은 슬로우 쿼리가 파일로 기록된 것을 일부 발췌한 내용인데 테이블로 저장된 슬로우 쿼리도 내용은 동일하다.

     . 'Time' 항목은 쿼리가 시작된 시간이 아니라 쿼리가 종료된 시점을 의미한다.
       그래서 쿼리가 언제 시작됐는지 확인하려면 'Time' 항목에 나온 시간에서 'Query_time'만큼 빼야 한다.
     . 'UserHost'는 쿼리를 실행한 사용자의 계정이다.
     . 'Query_time'은 쿼리가 실행되는 데 걸린 전체 시간을 의미한다.
       많이 혼동되는 부분 중 하나인 'Lock_time'은 사실 위에서 설명한 두 가지 레벨의 잠금 가운데
       MySQL 엔진 레벨에서 관장하는 테이블 잠금에 대한 대기 시간만 표현한다.
       위 예제의 경우, 이 SELECT 문장을 실행하기 위해 0.002658초간 테이블 락을 기다렸다는 의미가 되는데
       여기서 한 가지 더 중요한 것은 이 값이 0이 아니라고 해서 무조건 잠금 대기가 있었다고 판단하기는 어렵다는 것이다.
       'Lock_time'에 표기된 시간은 실제 쿼리가 실행되는 데 필요한 잠금 체크와 같은 코드 실행 부분의 시간까지 모두 포함되기 때문이다.
       즉, 이 값이 매우 작은 값이면 무시해도 무방하다.
     . 'Rows_examined'는 이 쿼리가 처리되기 위해 몇 건의 레코드에 접근했는지를 의미하며
       'Rows_sent'는 실제 몇 건의 처리 결과를 클라이언트로 보냈는지를 의미한다.
       일반적으로 'Rows_examined'의 레코드 건수는 높지만 'Rows_sent'에 표시된 레코드 건수가 상당히 적다면
       이 쿼리는 조금 더 적은 레코드만 접근하도록 튜닝해 볼 가치가 있는 것이다
       (GROUP BY나 COUNT( ), MIN(), MAX( ), AVG() 등과 같은 집합 함수가 아닌 쿼리인 경우만 해당).

   - MyISAM이나 MEMORY 스토리지 엔진에서는 테이블 단위의 잠금을 사용하고 MVCC와 같은 메커니즘이 없기 때문에
     SELECT 쿼리라고 하더라도 Lock_time이 1초 이상 소요될 가능성이 있다.
   - 하지만 가끔 InnoDB 테이블에 대한 SELECT 쿼리의 경우에도 Lock_time이 상대적으로 큰 값이 발생할 수 있는데
     이는 InnoDB의 레코드 수준의 잠금이 아닌 MySQL 엔진 레벨에서 설정한 테이블 잠금 때문일 가능성이 높다.
     그래서 InnoDB 테이블에만 접근하는 쿼리 문장의 슬로우 쿼리 로그에서는 Lock_time 값은 튜닝이나 쿼리 분석에 별로 도움이 되지 않는다.

   - 일반적으로 슬로우 쿼리 또는 제너럴 로그 파일의 내용이 상당히 많아서 직접 쿼리를 하나씩 검토하기에는 시간이 너무 많이 걸리거나
     어느 쿼리를 집중적으로 튜닝해야 할지 식별하기가 어려울 수도 있다.
   - 이런 경우에는 Percona에서 개발한 Perconau Toolkit의 pt-query-digest 스크립트를 이용하면
     쉽게 빈도나 처리 성능별로 쿼리를 정렬해서 살펴볼 수 있다.

     ## General Log 파일 분석
        linux> pt-query-digest --type='genlog' general.log > parsed_general.log

     ## Slow Log 파일 분석
        linux> pt-query-digest --type='slowlog' mysql-slow. log > parsed_mysql-slog.log

     로그 파일의 분석이 완료되면 그 결과는 다음과 같이 3개의 그룹으로 나뉘어 저장된다.


-- 슬로우 쿼리 통계

   - 분석 결과의 최상단에 표시되며
     모든 쿼리를 대상으로 슬로우 쿼리 로그의 실행 시간(Exec ting)고 잠금 대기 시간(Lock time) 등에 대해 평균 및 최소/최대 값을 표시한다.

-- 실행 빈도 및 누적 실행 시간순 랭킹

   - 각 쿼리별로 응답 시간과 실행 횟수를 보여주는데
     pt-query-digest 명령 실행 시 --order-by 옵션으로 정렬 순서를 변경할 수 있다.
     Query ID는 실행된 쿼리 문장을 정규화(쿼리에 사용된 리터럴을 제거)해서 만들어진 해시 값을 의미하는데
     일반적으로 같은 모양의 쿼리라면 동일한 Query ID를 가지게 된다.


-- 쿼리별 실행 횟수 및 누적 실행 시간 상세 정보

   - Query ID별 쿼리를 쿼리 랭킹에 표시된 순서대로 자세한 내용을 보여준다.
     랭킹별 쿼리에서는 이블에 대해 어떤 쿼리인지만을 표시하는데, 실제 상세한 쿼리 내용은 개별 쿼리의 정보를 확인해보면 된다.
     여기서는 쿼리가 얼마나 실행됐는지 쿼리의 응답 시간에 대한 히스토그램 같은 상세한 내용을 보여준다.
```
