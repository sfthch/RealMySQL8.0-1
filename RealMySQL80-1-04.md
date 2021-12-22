```
-- MySQL 엔진

   - 커넥션 핸들러, SQL 파서, 전처리기, 옵티마이저


-- 스토리 엔진
   - MySQL 엔진은 하나 디스크 스토리지는 여러개를 동시에 사용가능.
   - 디스크 스토리지에서 read / write
   - CREATE TABLE test_table ( fd1 INT, fd2 INT ) ENGINE=INNODB;
   - 성능향상을 위해 키 캐시(MyISAM 스토리지 엔진), InnoDB 버퍼 풀(InnoDB 스토리지 엔진)


-- 핸들러 API

   - 핸들러 요청이란 각 스토리지 엔진에서 read / write 요청하는것,
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

   - MySQL 서버는 프로세스 기반이 아니라 스레드 기반으로 작동,
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
   - 클라이언트 사용자가 작업을 마치고 커넥션을 종료하면,
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

   - 데이터를 MySQL의 데이터 버퍼나 캐시로부터 가져오며,
     버퍼나 없는 경우에는 직접 디스크의 데이터나 인덱스 파일로부터 데이터를 읽어와서 처리.
   - MyISAM 테이블은 디스크 쓰기 작업까지 포그라운드 스레드가 처리하나
     MyISAM도 지연된 쓰기가 있지만 일반적인 방식은 아님.
   - InnoDB 테이블은 데이터 버퍼나 캐시까지만 포그라운드 스레드가 처리하고,
     나머지 버퍼로부터 디스크까지 기록하는 작업은 백그라운드 스레드가 처리.


-- [참고]

   - MySQL에서 사용자 스레드와 포그라운드 스레드는 똑같은 의미로 사용.
   - 클라이언트가 MySQL 서버에 접속하게 되면 MySQL 서버는 그 클라이언트의 요청을 처리해 줄 스레드를 생성해 그 클라이언트에 할당해 준다.
   - 이 스레드는 DBMS의 앞단에서 사용자(클라이언트)와 통신하기 때문에 포그라운드 스레드라고 하며,
     또한 사용자가 요청한 작업을 처리하기 때문에 사용자 스레드라고도 한다.


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
   - 쓰기 스레드는 아주 많은 작업을 백그라운드로 처리하기 때문에 일반적인 내장 디스크를 사용할 때는 2~4정도,
     DAS나 SAN과 같은 스토리지를 사용할 때는 4개 이상으로 충분히 설정.
   - 사용자의 요청을 처리하는 도중 데이터의 쓰기 작업은 지연(버퍼링)되어 처리될 수 있지만 데이터의 읽기 작업은 절대 지연될 수 없다
   - 일반적인 상용 DBMS에는 대부분 쓰기 작업을 버퍼링해서 일괄 처리하는 기능이 탑재되어 있으며 InnoDB 또한 이러한 방식으로 처리.
   - InnoDB에서는 INSERT와 UPDATE 그리고 DELETE 쿼리로 데이터가 변경되는 경우,
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
   - MySQL 서버에서는 클라이언트 커넥션으로부터의 요청을 처리하기 위해 스레드를 하나씩 할당하게 되는데,
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
   - 부가적인 기능을 더 제공하는 스토리지 엔진이 필요할 수도 있으며,
     이러한 요건을 기초로 다룬 전문 개발 회사 또는 직접 스토리지 엔진을 제작하는 것도 가능.
   - 쿼리가 실행되는 과정은 거의 대부분의 작업이 MySQL 엔진에서 처리, 마지막 "데이터 읽기/쓰기" 작업만 스토리지 엔진에 의해 처리된다.
   - 직접 아주 새로운 용도의 스토리지 엔진을 만든다 하더라도 DBMS의 전체 기능이 아닌 일부분의 기능만 수행하는 엔진을 작성.
   - MySQL 서버에서는 MySQL 엔진은 사람 역할을 하고, 각 스토리지 엔진은 자동차 역할을 하게 되는데,
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
    - MyISAM 테이블을 조작하는 경우에는 핸들러가 MyISAM 스토리지 엔진이 되고,
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

   - 테이블의 구조 정보와 스토어드 프로그램 등의 정보를 데이터 딕셔너리 또는 메타데이터라고 하는데,
     MySQL 서버는 5.7 버젼까지는 테이블 구조를 FRM 파일에 저장하고 일부 스토어드 프로그램도 파일기반으로 관리.
   - 파일기반의 메타데이터는 생성 및 변경 작업이 트랜잭션을 지원하지 않기 때문에 테이블의 생성 또는 변경 도중에
     MySQL 서버가 비정상적으로 종료가 되면 테이블 정보들이 정확하지 않게 되기 때문에 "DB나 테이블이 깨졌다"라고 한다.
   - MySQL 8.0 부터는 테이블의 구조 정보나 스토어드 프로그램의 코드 관련정보들을 InnoDB의 테이블에 저장하도록 개선하고
     시스템 테이블과 데이터 딕셔너리 정보를 모두 모아서 mysql DB에 저장하며 mysql DB는 통째로 mysql.idb라는 테이블스페이스에 저장.


-- [참고]

   - MySQL 서버는 데이터 딕셔너리 정보를 information_schema DB와 Tables와 Columns 등과 같은 뷰를 통해서 조회가 가능.

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
     | innodb_buffer_pool_size | 8388608 |
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
```