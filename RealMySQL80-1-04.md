```sql
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


-- 버퍼 풀의 구조

   - InnoDB 스토리지 엔진은 버퍼 풀이라는 거대한 메모리 공간을 페이지 크기(innodb_page_size 시스템 변수에 설정)의 조각으로 분산하여
     InnoDB 스토리지 엔진이 데이터를 필요로 할 때 해당 데이터 페이지를 읽어서 각 조각에 저장함.

     SHOW VARIABLES LIKE '%innodb_page_size%';
     +------------------+-------+
     | Variable_name    | Value |
     +------------------+-------+
     | innodb_page_size | 16384 |
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
     어댑티브 플러시 기능이 활성화되면 InnoDB 스토리지 엔진은 단순히 버퍼 풀의 데티 페이지 비율이나 innodb_io_capacity,
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

     SHOW VARIABLES LIKE '%innodb_flush_log_at_trx_commit%';
     +--------------------------------+-------+
     | Variable_name                  | Value |
     +--------------------------------+-------+
     | innodb_flush_log_at_trx_commit | 1     |
     +--------------------------------+-------+


-- 언두 로그


-- 언두 로그 레코드 모니터링

     UPDATE member
        SET name = '홍길도'
      WHERE member_id = 1
     ;

     SHOW ENGINE INNODB STATUS \G
     ...
     ------------
     TRANSACTIONS
     ------------
     Trx id counter 4301
     Purge done for trx's n:o < 4301 undo n:o < 0 state: running but idle
     History list length 0
     ...

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


-- 언두 테이블스페이스 관리

     SHOW VARIABLES LIKE '%innodb_undo_tablespaces%';
     +-------------------------+-------+
     | Variable_name           | Value |
     +-------------------------+-------+
     | innodb_undo_tablespaces | 2     |
     +-------------------------+-------+

     SHOW VARIABLES LIKE '%innodb_rollback_segments%';
     +----------------------------+-------+
     | Variable_name              | Value |
     +----------------------------+-------+
     | innodb_rollback_segments   | 128   |
     +----------------------------+-------+

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
      WHERE file_type LIKE 'UNDO LOG'
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

     # 언두 테이블스페이스를 비활성화
     ALTER UNDO TABLESPACE tablespace_name SET INACTIVE;

     # 퍼지 스레드에 의해 언두 테이블스페이스 공간이 반납되면 다시 활성화
     ALTER UNDO TABLESPACE tablespace_name SET ACTIVE;



-- 체인지 버퍼

     SHOW VARIABLES LIKE '%innodb_change_buffering%';
     +-------------------------------+-------+
     | Variable_name                 | Value |
     +-------------------------------+-------+
     | innodb_change_buffering       | all   |
     +-------------------------------+-------+
     . all     :
     . none    :
     . inserts :
     . deletes :
     . changes :
     . purges  :

     SHOW VARIABLES LIKE '%innodb_change_buffer_max_size%';
     +-------------------------------+-------+
     | Variable_name                 | Value |
     +-------------------------------+-------+
     | innodb_change_buffer_max_size | 25    |
     +-------------------------------+-------+

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

     SHOW VARIABLES LIKE '%innodb_flush_log_at%';
     +--------------------------------+-------+
     | Variable_name                  | Value |
     +--------------------------------+-------+
     | innodb_flush_log_at_timeout    | 1     |
     | innodb_flush_log_at_trx_commit | 1     |
     +--------------------------------+-------+
     .innodb_flush_log_at_trx_commit = 0 :
     .innodb_flush_log_at_trx_commit = 1 :
     .innodb_flush_log_at_trx_commit = 2 :

     SHOW VARIABLES LIKE '%innodb_log_file%';
     +---------------------------+----------+
     | Variable_name             | Value    |
     +---------------------------+----------+
     | innodb_log_file_size      | 50331648 |
     | innodb_log_files_in_group | 2        |
     +---------------------------+----------+


-- 리두 로그 아카이빙

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

     SELECT innodb_redo_log_archive_start('backup', '21122817');
     or
     DO innodb_redo_log_archive_start('backup', '21122817');

     SELECT innodb_redo_log_archive_stop();
     or
     DO innodb_redo_log_archive_stop();


-- 리두 로그 활성화 및 비활성화

     SHOW GLOBAL STATUS LIKE '%Innodb_redo_log_enabled%';
     +-------------------------+-------+
     | Variable_name           | Value |
     +-------------------------+-------+
     | Innodb_redo_log_enabled | ON    |
     +-------------------------+-------+


-- 어댑티브 해시 인덱스

     SHOW VARIABLES LIKE '%innodb_adaptive_hash_index%';
     +----------------------------------+-------+
     | Variable_name                    | Value |
     +----------------------------------+-------+
     | innodb_adaptive_hash_index       | ON    |
     | innodb_adaptive_hash_index_parts | 8     |
     +----------------------------------+-------+

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

     SHOW VARIABLES LIKE '%internal_tmp_mem_storage_engine%';
     +---------------------------------+-----------+
     | Variable_name                   | Value     |
     +---------------------------------+-----------+
     | internal_tmp_mem_storage_engine | TempTable |
     +---------------------------------+-----------+


-- MyISAM 스토리지 엔지 아키텍처


-- 키 캐시

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

     SHOW VARIABLES LIKE '%key_buffer_size%';
     +-----------------+---------+
     | Variable_name   | Value   |
     +-----------------+---------+
     | key_buffer_size | 8388608 |
     +-----------------+---------+

     key_buffer_size = 4GB
     kbuf_board.key_buffer_size = 2GB
     kbuf_comment.key_buffer_size = 2GB

     CACHE INDEX db1.board, db2.board IN kbuf_board;
     CACHE INDEX db1.comment, db2.comment IN kbuf_comment;


-- 운영체제의 캐시 및 버퍼


-- 데이터 파일과 프라이머리 키(인덱스) 구조

     SHOW VARIABLES LIKE '%myisam%';
     +---------------------------+----------------------+
     | Variable_name             | Value                |
     +---------------------------+----------------------+
     | myisam_data_pointer_size  | 6                    |
     | myisam_max_sort_file_size | 107374182400         |
     | myisam_mmap_size          | 18446744073709551615 |
     | myisam_recover_options    | OFF                  |
     | myisam_repair_threads     | 1                    |
     | myisam_sort_buffer_size   | 38797312             |
     | myisam_stats_method       | nulls_unequal        |
     | myisam_use_mmap           | OFF                  |
     +---------------------------+----------------------+


-- MySQL 로그 파일


-- 에러 로그 파일


-- MySQL이 시작하는 과정과 관련된 정보성 및 에러 메시지


-- 마지막으로 종료할 때 비정상적으로 종료된 경우 나타나는 InnoDB의 트랜잭션 복구 메시지

     SHOW VARIABLES LIKE '%innodb_force_recovery%';
     +-----------------------------+-------+
     | Variable_name               | Value |
     +-----------------------------+-------+
     | innodb_force_recovery       | 0     |
     +-----------------------------+-------+


-- 쿼리 처리 도중에 발생하는 문제에 대한 에러 메시지


-- 비정상적으로 종료된 커넥션 메시지(Aborted connection)

     SHOW VARIABLES LIKE '%max_connect_errors%';
     +------------------------+-------+
     | Variable_name          | Value |
     +------------------------+-------+
     | max_connect_errors     | 100   |
     +------------------------+-------+


-- InnoDB의 모니터링 또는 상태 조회명령(SHOW ENGINE INNODB STATUS 같은)의 결과 메시지


-- 제너럴 쿼리 로그 파일(제너럴 로그 파일, General log)

     SHOW VARIABLES LIKE '%general_%';
     +------------------+---------------------+
     | Variable_name    | Value               |
     +------------------+---------------------+
     | general_log      | OFF                 |
     | general_log_file | CHANGHEE-NOTEBO.log |
     +------------------+---------------------+

     SHOW VARIABLES LIKE '%log_output%';
     +---------------+-------+
     | Variable_name | Value |
     +---------------+-------+
     | log_output    | FILE  |
     +---------------+-------+


-- 슬로우 쿼리 로그

     SHOW VARIABLES LIKE '%long_query_time%';
     +-----------------+-----------+
     | Variable_name   | Value     |
     +-----------------+-----------+
     | long_query_time | 10.000000 |
     +-----------------+-----------+


-- 슬로우 쿼리 통계


-- 실행 빈도 및 누적 실행 시간순 랭킹


-- 쿼리별 실행 횟수 및 누적 실행 시간 상세 정보



```