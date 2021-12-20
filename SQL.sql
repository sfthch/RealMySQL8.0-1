--------
-- 03 --
--------

-- ������ ����

   SHOW VARIABLES LIKE 'innodb_io%';
   +------------------------+-------+
   | Variable_name          | Value |
   +------------------------+-------+
   | innodb_io_capacity     | 200   |
   | innodb_io_capacity_max | 600   |
   +------------------------+-------+

   SET PERSIST max_connections=100;
   SET PERSIST innodb_io_capacity=100;
   SET PERSIST innodb_io_capacity_max=400;

   SELECT a.variable_name
        , a.set_time
        , a.set_user
        , a.set_host
        , b.variable_value
       -- SELECT a.*, b.*
     FROM performance_schema.variables_info a
     JOIN performance_schema.persisted_variables b
       ON a.variable_name = b.variable_name
   ;
   +------------------------+----------------------------+----------+-----------+----------------+
   | variable_name          | set_time                   | set_user | set_host  | variable_value |
   +------------------------+----------------------------+----------+-----------+----------------+
   | innodb_io_capacity     | 2021-12-15 17:22:59.475477 | root     | localhost | 100            |
   | innodb_io_capacity_max | 2021-12-15 17:23:10.487589 | root     | localhost | 400            |
   | max_connections        | 2021-12-15 17:13:56.901221 | root     | localhost | 100            |
   +------------------------+----------------------------+----------+-----------+----------------+

   SHOW VARIABLES LIKE 'innodb_io%';
   +------------------------+-------+
   | Variable_name          | Value |
   +------------------------+-------+
   | innodb_io_capacity     | 100   |
   | innodb_io_capacity_max | 400   |
   +------------------------+-------+

   RESET PERSIST;  -- ��ü���


-- ����� ������� ����

   - SHOW GLOBAL VARIABLES LIKE 'default_authentication_plugin%';
     +-------------------------------+-----------------------+
     | Variable_name                 | Value                 |
     +-------------------------------+-----------------------+
     | default_authentication_plugin | caching_sha2_password |
     +-------------------------------+-----------------------+

   - SET GLOBAL       default_authentication_plugin=mysql_native_password;  -- �ӽú���
     or
     SET PERSIST      default_authentication_plugin=mysql_native_password;  -- ��������
     or
     SET PERSIST_ONLY default_authentication_plugin=mysql_native_password;  -- SET PERSIST ������

     #RESET PERSIST IF EXISTS default_authentication_plugin;    -- ������

   - my.cnf (caching_sha2_password => mysql_native_password)
     [mysqld]
     default_authentication_plugin=mysql_native_password


-- db ����

   - CREATE DATABASE test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


-- Roll ���� �� ���Ѻο�

   CREATE ROLE role_test_read
             , role_test_write
             , role_test_dba
             , role_test_admin
             ;

   GRANT select ON test.* TO role_test_read;
   #GRANT role_test_read  TO 'hch'@'192.168.50.223';
   GRANT select
       , insert
       , update
       , delete ON test.* TO role_test_write;
   GRANT EVENT  ON test.* TO role_test_dba;
   GRANT SUPER  ON    *.* TO role_test_admin;

   REVOKE select ON test.* FROM role_test_write;

   SELECT current_role();
   +----------------+
   | current_role() |
   +----------------+
   | NONE           |
   +----------------+

   SET ROLE role_test_read;     -- �ӽú���

   SELECT current_role();
   +----------------------+
   | current_role()       |
   +----------------------+
   | `role_test_read`@`%` |
   +----------------------+

   -- LOGIN�� SET ROLE �ڵ�����
   SHOW GLOBAL VARIABLES LIKE 'activate_all_roles_on_login%';
   +-----------------------------+-------+
   | Variable_name               | Value |
   +-----------------------------+-------+
   | activate_all_roles_on_login | OFF   |
   +-----------------------------+-------+

   SET GLOBAL       activate_all_roles_on_login=ON;     -- �ӽú���
   or
   SET PERSIST      activate_all_roles_on_login=ON;     -- ��������
   or
   SET PERSIST_ONLY activate_all_roles_on_login=ON;     -- SET PERSIST ������

   #RESET PERSIST IF EXISTS activate_all_roles_on_login;    -- ������

   SHOW GLOBAL VARIABLES LIKE 'activate_all_roles_on_login%';
   +-----------------------------+-------+
   | Variable_name               | Value |
   +-----------------------------+-------+
   | activate_all_roles_on_login | ON    |
   +-----------------------------+-------+

   SELECT * FROM mysql.global_grants;
   SELECT * FROM mysql.default_roles;
   SELECT * FROM mysql.role_edges;
   SELECT * FROM mysql.user;
   SELECT * FROM mysql.db;


-- ����� ������ �����ֱ�

   CREATE USER 'hch'@'localhost' IDENTIFIED WITH mysql_native_password BY 'hch7759' PASSWORD EXPIRE NEVER;
   GRANT ALL PRIVILEGES ON test.* TO 'hch'@'localhost';
   GRANT EVENT          ON test.* TO 'hch'@'localhost';
   GRANT SUPER          ON    *.* TO 'hch'@'localhost';
   #GRANT role_test_read, role_test_write, role_test_dba, role_test_admin TO 'hch'@'localhost';
   SHOW GRANTS FOR 'hch'@'localhost';

   CREATE USER 'hch'@'127.0.0.1' IDENTIFIED BY '7759' PASSWORD EXPIRE NEVER;
   ALTER  USER 'hch'@'127.0.0.1' IDENTIFIED WITH mysql_native_password BY '7759';
   GRANT select, insert, update, delete ON test.* TO 'hch'@'127.0.0.1';
   #GRANT role_test_read, role_test_write TO 'hch'@'127.0.0.1';
   SHOW GRANTS FOR 'hch'@'127.0.0.1';

   #REVOKE select ON test.* FROM 'hch'@'127.0.0.1';

   CREATE USER 'hch'@'%' IDENTIFIED BY 'hch' PASSWORD EXPIRE NEVER;
   ALTER  USER 'hch'@'%' IDENTIFIED WITH mysql_native_password BY 'hch';
   GRANT select ON test.* TO 'hch'@'%';
   #GRANT role_test_read  TO 'hch'@'%';
   SHOW GRANTS FOR 'hch'@'%'; -- '192.168.50.223'

   SELECT user
        , account_locked
        , authentication_string
        , host
        , plugin
     FROM mysql.user
   ;



--------
-- 04 --
--------

-- MySQL ����

   - Ŀ�ؼ� �ڵ鷯, SQL �ļ�, ��ó����, ��Ƽ������


-- ���丮 ����
   - MySQL ������ �ϳ� ��ũ ���丮���� �������� ���ÿ� ��밡��.
   - ��ũ ���丮������ read / write
   - CREATE TABLE test_table ( fd1 INT, fd2 INT ) ENGINE=INNODB;
   - ��������� ���� Ű ĳ��(MyISAM ���丮�� ����), InnoDB ���� Ǯ(InnoDB ���丮�� ����)


-- �ڵ鷯 API

   - �ڵ鷯 ��û�̶� �� ���丮�� �������� read / write ��û�ϴ°�,
     ���⿡�� ���Ǵ� API�� �ڵ鷯 API�� �Ѵ�.
   - �ڵ鷯 API�� ���ؼ� �󸶳� ���� DATA �۾��� �־����� �ľ��ϴ� ��ɾ�.

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


-- MySQL ������ ����

   - MySQL ������ ���μ��� ����� �ƴ϶� ������ ������� �۵�,
     ���׶���(Foregroud) ������� ��׶���(Background) ������� ����.
   - MySQL �������� �������� ������ ��� Ȯ��.

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
      - ���߿� 'thread/sql/one_connection' �����常�� ����� ��û�� ó���ϴ� ���׶��� ��������.


-- ���׶��� ������(Ŭ���̾�Ʈ ������)

   - �ּ��� MySQL ������ ���ӵ� Ŭ���̾�Ʈ�� ����ŭ ����.
   - �� Ŭ���̾�Ʈ ����ڰ� ��û�ϴ� ���� ������ ó��.
   - Ŭ���̾�Ʈ ����ڰ� �۾��� ��ġ�� Ŀ�ؼ��� �����ϸ�,
     �ش� Ŀ�ؼ��� ����ϴ� ������� �ٽ� ������ ĳ��(Thread pool)�� �ǵ��ư���.
   - ������ ĳ�ÿ� ���� ���� �̻��� ��� ���� �����尡 ������
     ������ ĳ�ÿ� ���� �ʰ� �����带 ������� ���� ������ �����常 ������ ĳ�ÿ� ����.
   - ������ ĳ�ÿ� �����ϰ� �����ϰ� ������ִ� �ִ� ������ ����.

     SHOW VARIABLES LIKE 'thread_cache_size%';
     +-------------------+-------+
     | Variable_name     | Value |
     +-------------------+-------+
     | thread_cache_size | 10    |
     +-------------------+-------+

   - �����͸� MySQL�� ������ ���۳� ĳ�÷κ��� ��������,
     ���۳� ���� ��쿡�� ���� ��ũ�� �����ͳ� �ε��� ���Ϸκ��� �����͸� �о�ͼ� ó��.
   - MyISAM ���̺��� ��ũ ���� �۾����� ���׶��� �����尡 ó���ϳ�
     MyISAM�� ������ ���Ⱑ ������ �Ϲ����� ����� �ƴ�.
   - InnoDB ���̺��� ������ ���۳� ĳ�ñ����� ���׶��� �����尡 ó���ϰ�,
     ������ ���۷κ��� ��ũ���� ����ϴ� �۾��� ��׶��� �����尡 ó��.


-- [����]

   - MySQL���� ����� ������� ���׶��� ������� �Ȱ��� �ǹ̷� ���.
   - Ŭ���̾�Ʈ�� MySQL ������ �����ϰ� �Ǹ� MySQL ������ �� Ŭ���̾�Ʈ�� ��û�� ó���� �� �����带 ������ �� Ŭ���̾�Ʈ�� �Ҵ��� �ش�.
   - �� ������� DBMS�� �մܿ��� �����(Ŭ���̾�Ʈ)�� ����ϱ� ������ ���׶��� �������� �ϸ�,
     ���� ����ڰ� ��û�� �۾��� ó���ϱ� ������ ����� �������� �Ѵ�.


-- ��׶��� ������

   - InnoDB�� ���� ���� �۾��� ��׶���� ó��.
     . �μ�Ʈ ����(Insert Buffer)�� �����ϴ� ������
     . �α׸� ��ũ�� ����ϴ� ������
     . InnoDB ���� Ǯ�� �����͸� ��ũ�� ����ϴ� ������
     . �����͸� ���۷� �о���̴� ������
     . ����̳� ������� ����͸��ϴ� ������
   - ���� �߿��� ���� �α� ������(Log thread)�� ������ �����͸� ��ũ�� ���� ���� �۾��� ó���ϴ� ���� ������(Write thread)��.
   - ���� ������� MySQL 5.5 �������� read / write ������ ������ 2�� �̻� ������ ����.

     SHOW VARIABLES LIKE '%io_threads';
     +-------------------------+-------+
     | Variable_name           | Value |
     +-------------------------+-------+
     | innodb_read_io_threads  | 4     |
     | innodb_write_io_threads | 4     |
     +-------------------------+-------+

   - InnoDB������ �����͸� �д� �۾��� �ַ� Ŭ���̾�Ʈ �����忡�� ó���Ǳ� ������ �б� ������� ���� ������ �ʿ䰡 ����.
   - ���� ������� ���� ���� �۾��� ��׶���� ó���ϱ� ������ �Ϲ����� ���� ��ũ�� ����� ���� 2~4����,
     DAS�� SAN�� ���� ���丮���� ����� ���� 4�� �̻����� ����� ����.
   - ������� ��û�� ó���ϴ� ���� �������� ���� �۾��� ����(���۸�)�Ǿ� ó���� �� ������ �������� �б� �۾��� ���� ������ �� ����
   - �Ϲ����� ��� DBMS���� ��κ� ���� �۾��� ���۸��ؼ� �ϰ� ó���ϴ� ����� ž��Ǿ� ������ InnoDB ���� �̷��� ������� ó��.
   - InnoDB������ INSERT�� UPDATE �׸��� DELETE ������ �����Ͱ� ����Ǵ� ���,
     �����Ͱ� ��ũ�� ������ ���Ϸ� ������ ����� ������ ��ٸ��� �ʾƵ� �ȴ�.
   - MyISAM���� �Ϲ����� ������ ���� ���۸� ����� ����� �� ����.


-- �޸� �Ҵ� �� ��� ����

   - MySQL���� ���Ǵ� �޸� ������ ũ�� �۷ι� �޸� ������ ���� �޸� �������� ����.
   - �۷ι� �޸� ������ ��� �޸� ������ MySQL ������ ���۵Ǹ鼭 ������ �ü���κ��� �Ҵ�.
   - MySQL�� �Ķ���ͷ� ������ �� ��ŭ �ü���κ��� �޸𸮸� �Ҵ�޴´ٰ� �����ϴ� ���� ���� �� �ϴ�.


-- �۷ι� �޸� ����

   - Ŭ���̾�Ʈ �������� ���� �����ϰ� �Ϲ������δ� �ϳ��� �޸� ������ �Ҵ�.
   - �ʿ信 ���� 2�� �̻��� �޸� ������ �Ҵ���� ���� ������ Ŭ���̾�Ʈ�� ������ ���ʹ� ����.
   - ������ �۷ι� ������ N���� �ϴ��� ��� �����忡 ���� ����.
   - ��ǥ���� �۷ι� �޸� ����
     . ���̺� ĳ��
     . InnoDB ���� Ǯ
     . InnoDB ���Ƽ�� �ؽ� �ε���
     . InnoDB ���� �α� ����


-- ���� �޸� ����

   - ���� �޸� �����̶�� ǥ��.
   - MySQl ������ �����ϴ� Ŭ���̾�Ʈ �����尡 ������ ó���ϴ� �޸� ����. ��ǥ������ Ŀ�ؼ� ���ۿ� ����(�ҵ�) ���۰� �ִ�.
   - MySQL ���������� Ŭ���̾�Ʈ Ŀ�ؼ����κ����� ��û�� ó���ϱ� ���� �����带 �ϳ��� �Ҵ��ϰ� �Ǵµ�,
     Ŭ���̾�Ʈ �����尡 ����ϴ� �޸� �����̶�� �ؼ� Ŭ���̾�Ʈ �޸� ���� �̶�� �Ѵ�.
   - Ŭ���̾�Ʈ�� MySQL �������� Ŀ�ؼ��� �����̶�� �ϱ⶧���� ���� �޸� ������ ���� �޸� �����̶�� ǥ��.
   - ���� �޸𸮴� �� Ŭ���̾�Ʈ �����庰�� ���������� �Ҵ�Ǹ� ���� �����Ǿ� ������ �ʴ´�.
   - �۷ι� �޸� ������ ũ��� �����ؼ� ���������� ��Ʈ ���ۿ� ���� ���� �޸� ������ ũ�� �Ű� ���� �ʰ� ����.
   - �־��� ���(���ɼ��� ���������)���� MySQL ������ �޸� �������� ���� ���� ���� �����Ƿ� ������ �޸� ������ �����ϴ� ���� �߿�.
   - ���� �޸� ������ �� �� ���� �߿��� Ư¡�� �� ������ �뵵���� �ʿ��� ���� ������ �Ҵ�ǰ� �ʿ����� ���� ��쿡��
     MySQL�� �޸� ������ �Ҵ������� ���� �������� �ִٴ� ���̴�. ��ǥ������ ��Ʈ ���۳� ���� ���ۿ� ���� �����̴�.
   - ���� �޸� ������ Ŀ�ؼ��� ���� �ִ� ���� ��� �Ҵ�� ���·� ���� �ִ� ������ �ְ�(Ŀ�ؼ� ���۳� ��� ����)
     �׷��� �ʰ� ������ �����ϴ� �������� �Ҵ��ߴٰ� �ٽ� �����ϴ� ����(��Ʈ ���۳� ���� ����)�� �ִ�.
   - ��ǥ���� ���� �޸� ����
     . ���� ����(Sort buffer)
     . ���� ����
     . ���̳ʸ� �α� ĳ��
     . ��Ʈ��ũ ����


-- �÷����� ���丮�� ���� ��

   - MySQL�� ��Ư�� ���� �� ��ǥ���� ���� �ٷ� �÷����� ���̴�.
   - �÷������ؼ� ����� �� �ִ� ���� ���丮�� ������ ������ ���� �ƴϴ�.
   - ���� �˻� ������ ���� �˻��� �ļ�(�ε����� Ű���带 �и��س��� �۾�)�� �÷����� ���·� �����ؼ� ����� �� �ִ�.
   - ����� ������ ���ؼ� Native Authentication �� Caching SHA-2 Authentication � ��� �÷��� ���·� ����.
   - �ΰ����� ����� �� �����ϴ� ���丮�� ������ �ʿ��� ���� ������,
     �̷��� ����� ���ʷ� �ٷ� ���� ���� ȸ�� �Ǵ� ���� ���丮�� ������ �����ϴ� �͵� ����.
   - ������ ����Ǵ� ������ ���� ��κ��� �۾��� MySQL �������� ó��, ������ "������ �б�/����" �۾��� ���丮�� ������ ���� ó���ȴ�.
   - ���� ���� ���ο� �뵵�� ���丮�� ������ ����� �ϴ��� DBMS�� ��ü ����� �ƴ� �Ϻκ��� ��ɸ� �����ϴ� ������ �ۼ�.
   - MySQL ���������� MySQL ������ ��� ������ �ϰ�, �� ���丮�� ������ �ڵ��� ������ �ϰ� �Ǵµ�,
     MySQL ������ ���丮�� ������ �����ϱ� ���� �ڵ鷯��� ���� ���.
   - MySQL ������ �� ���丮�� �������� �����͸� �о���ų� �����ϵ��� ����Ϸ��� �ڵ鷯�� �� ���ؾ� �Ѵ�.
   - "Handler_"�� �����ϴ� ���� ������ "MySQL ������ �� ���丮�� �������� ���� ����� Ƚ���� �ǹ��ϴ� ����"��� �����ϸ� �ȴ�.
   - MySQl���� MyISAM�̳� InnoDB�Ͱ��� �ٸ� ���丮�� ������ ����ϴ� ���̺� ���� ������ �����ϴ���
     MySQL�� ó�� ������ ��κ� �����ϴ�. �ܼ��� "������ �б�/����" ������ ó���� ���̰� ���� ���̴�.
   - �������� GROUP BY�� ORDER BY �� ���� ������ ó���� ���丮�� ���� ������ �ƴ϶� MySQL ������ ó�� ������ "���� �����"���� ó��.
   - MyISAM�̳� InnoDB ���丮�� ���� ��� �� ����ϵ� �� ���̰� ���� �� �ƴѰ�, ��� ������ �� ������ �׷��� �ʴ�.
     ���丮�� ���� ��� � �� ����ϴ��Ŀ� ���� "������ �б�/����" �۾� ó�� ����� ���� �޶��� �� �ִ�.
   - �ϳ��� ���� �۾��� ���� ���� �۾����� �����µ�, �� ���� �۾���
     MySQL ���� �������� ó���Ǵ��� �ƴϸ� ���丮�� ���� �������� ó���Ǵ��� ������ �� �˾ƾ� �Ѵ�.
   - MySQL ����(mysqld)���� �����Ǵ� ���丮�� ������ Ȯ���� ����

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
     - Support Į���� ǥ�õ� �� �ִ� ���� �Ʒ� 4������.
       . YES      : MySQl ����(mysqld)�� �ش� ���丮�� ������ ���Ե� �ְ�, ��� �������� Ȱ��ȭ�� ������.
       . DEFAULT  : "YES"�� ������ ���������� �ʼ� ���丮�� �������� �ǹ���.(�� ���丮�� ������ ������ MySQL�� ���۵��� ���� ���� ������ �ǹ��Ѵ�)
       . NO       : ���� MySQL ����(mysqld)�� ���Ե��� �ʾ����� �ǹ���.
       . DISABLED : ���� MySQL ����(mysqld)�� ���Ե����� �Ķ���Ϳ� ���� ��Ȱ��ȭ�� ������.

   - MySQl ����(mysqld)�� ���Ե��� ���� ���丮�� ����(Support Į���� NO�� ǥ�õǴ�) �� ����Ϸ��� MySQL ������ �ٽ� ����(������)�ؾ� �Ѵ�.
   - MySQL ������ ������ �غ� �� �ִٸ� �÷����� ���·� ����� ���丮�� ���� ���̺귯���� �����޾� ���� �ֱ⸸ �ϸ� ����� �� �ִ�.
   - �÷����� ������ ���丮�� ������ �ս��� ���׷��̵� �� �� �ִ�. ���丮�� ������ �ƴ϶� ��� �÷������� ������ ������ ���� Ȯ���� �� �ִ�.
   - �Ʒ��� ������� ���丮�� ������ �ƴ϶� ���� �˻��� �ļ��� ���� �÷����ε� (���� ��ġ�� �ִٸ�) Ȯ���� �� �ִ�.

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

   - MySQL ���������� ���丮�� �����Ӹ� �ƴ϶� ������ ����� �÷����� ���·� ����.
   - �����̳� ���� �˻� �ļ� �Ǵ� ���� ���ۼ��� ���� �÷����� ������, ��й�ȣ ������ Ŀ�ؼ� ���� � ���õ� �پ��� �÷������� ����.
   - MySQL ������ ����� Ŀ�����ϰ� Ȯ���� �� �ְ� �÷����� API�� �Ŵ��� ������.
   - MySQL �������� �����ϴ� ��ɵ��� Ȯ���ϰų� ������ ���ο� ��ɵ��� �÷��������� ������ ����.


-- ������Ʈ

   - ������ �÷����� ��Ű��ó�� ��ü�ϱ� ���ؼ� ������Ʈ ��Ű��ó�� ����.
   - MySQL ������ �÷������� ��� �������� �ִµ�, �̷��� �������� �����ؼ� ����.
     . �÷������� ���� MySQL ������ �������̽��� �� �ְ�, �÷����γ����� ����� �� ����.
     . �÷������� MySQL ������ ������ �Լ��� ���� ȣ���ϱ� ������ �������� ����(ĸ��ȭ �ʵ�)
     . �÷������� ��ȣ ���� ���踦 ������ �� ��� �ʱ�ȭ�� �����.
   - ������Ʈ�� ������ ������ ��й�ȣ ���� ������Ʈ�� ���ؼ� ���캸�� �Ʒ��� ����.

       mysql> INSTALL COMPONENT 'file://component_validate_password';

       SELECT * FROM mysql.component;
       +--------------+--------------------+------------------------------------+
       | component_id | component_group_id | component_urn                      |
       +--------------+--------------------+------------------------------------+
       |            1 |                  1 | file://component_validate_password |
       +--------------+--------------------+------------------------------------+
       - �÷����ΰ� ���������� ������Ʈ�� ��ġ�ϸ� ���ο� �ý��� ������ �����ؾ� �� ���� ������ ���� �Ŵ����� ����.
       - ���� �� �ٽ� ��ġ ����
         mysql> UNINSTALL COMPONENT 'file://component_validate_password';


-- ���� ���� ����


-- ���� �ļ�

    - ����� ��û���� ���� ���� ������ ��ū(MySQL�� �ν��� �� �ִ� �ּ� ������ ���ֳ� ��ȣ)���� �и��� Ʈ�� ������ ������ ����� ���� �۾�.
    - ���� ������ �⺻ ���� ������ �� �������� �߰ߵǸ� ����ڿ��� ���� �޽����� ����.


-- ��ó����

    - �ļ� �������� ������� �ļ� Ʈ���� ������� ���� ���忡 �������� �������� �ִ��� Ȯ��.
    - �� ��ū�� ���̺� �̸��̳� Į�� �̸� �Ǵ� ���� �Լ��� ���� ��ü�� ������ �ش� ��ü�� ���� ���ο�
      ��ü�� ���� ���ο� ���� ��ü�� ���ٱ��� ���� Ȯ���ϴ� ������ �� �ܰ迡�� ����.
    - ���� �������� �ʰų� ���ѻ� ����� �� ���� ��ü�� ��ū�� �� �ܰ迡�� �ɷ�����.


-- ��Ƽ������

    - ������� ��û���� ���� ���� ������ ������ ������� ���� ������ ó������ �����ϴ� ������ ����ϴµ�, DBMS�� �γ��� �ش�.


-- ���� ����

    - ��Ƽ�������� �γ���� ���� ������ �ڵ鷯�� �հ� �߿� ������ �� �ִ�.
    - ��Ƽ�������� GROUP BY�� ó���ϱ� ���� �ӽ� ���̺��� ����ϱ�� �����ߴٰ� �غ���.
      1. ���� ������ �ڵ鷯���� �ӽ� ���̺��� ������ ��û.
      2. �ٽ� ���� ������ WHERE ���� ��ġ�ϴ� ���ڵ带 �о����� �ڵ鷯���� ��û.
      3. �о�� ���ڵ���� 1������ �غ��� �ӽ� ���̺�� �����϶�� �ٽ� �ڵ鷯���� ��û.
      4. �����Ͱ� �غ�� �ӽ� ���̺��� �ʿ��� ������� �����͸� �о����� �ڵ鷯���� �ٽ� ��û.
      5. ���������� ���� ������ ����� ����ڳ� �ٸ� ���� �ѱ�.
    - ���� ������ ������� ��ȹ��� �� �ڵ鷯���� ��û�ؼ� ���� ����� �� �ٸ� �ڵ鷯 ��û�� �Է����� �����ϴ� ������ ����.


-- �ڵ鷯(���丮�� ����)

    - MySQL ������ ���� �شܿ��� MySQL ���� ������ ��û�� ���� �����͸� ��ũ�� �����ϰ� ��ũ�κ��� �о� ���� ������ ���.
    - MyISAM ���̺��� �����ϴ� ��쿡�� �ڵ鷯�� MyISAM ���丮�� ������ �ǰ�,
      InnoDB ���̺��� �����ϴ� ��쿡�� �ڵ鷯�� InnoDB ���丮�� ������ �ȴ�.


-- ����

    - ������ �忡��...


-- ���� ĳ��

    - SQL�� ���� ����� �޸𸮿� ĳ���ϰ�, ���� SQL ������ ����Ǹ� ���̺��� ���� �ʰ� ��� ����� ��ȯ�ϱ� ������ �ſ� ���� ������ ����.
      ������ ���̺� ����Ÿ�� ����Ǹ� ĳ�ÿ� ����� ��� �߿��� ����� ���̺�� ���õ� ����Ÿ���� ��� ������ �Ǿ� �ɰ��� ���� ���ϰ� �߻�.
    - ������ �����Ǵ� �������� ���� ĳ�ô� ��ӵ� ���� ó�� ���� ���Ͽ� ���� ������ ������ ��.
      �׷��� MySQL 8.0������ ������ ���ŵǰ�, ���� �ý��� ������ ��� ���ŵ�.


-- ��Ʈ���� Ǯ

    - ������� ��û�� ó���ϴ� ������ ������ �ٿ��� ���� ó���Ǵ� ��û�� ���Ƶ�
      MySQL ������ CPU�� ���ѵ� ������ ������ ó���� ������ �� �ְ� �ؼ� ������ �ڿ��Ҹ� ���̴� ���� ����.
    - �����ٸ� �������� CPU �ð��� ���뵵 Ȯ������ ���ϸ� ���� ó���� �� ������ �� ����.
    - ���ѵ� ���� �����常���� CPU�� ó�� �ϵ��� ������ �����Ѵٸ� CPU�� ���μ��� ģȭ��(Process affinity)�� ���̰�
      OS ���忡���� ���ʿ��� ���ؽ�Ʈ ����ġ(Context switch)�� �ٿ��� ������带 ���� �� �ִ�.


-- Ʈ����� ���� ��Ÿ������

   - ���̺��� ���� ������ ������ ���α׷� ���� ������ ������ ��ųʸ� �Ǵ� ��Ÿ�����Ͷ�� �ϴµ�,
     MySQL ������ 5.7 ���������� ���̺� ������ FRM ���Ͽ� �����ϰ� �Ϻ� ������ ���α׷��� ���ϱ������ ����.
   - ���ϱ���� ��Ÿ�����ʹ� ���� �� ���� �۾��� Ʈ������� �������� �ʱ� ������ ���̺��� ���� �Ǵ� ���� ���߿�
     MySQL ������ ������������ ���ᰡ �Ǹ� ���̺� �������� ��Ȯ���� �ʰ� �Ǳ� ������ "DB�� ���̺��� ������"��� �Ѵ�.
   - MySQL 8.0 ���ʹ� ���̺��� ���� ������ ������ ���α׷��� �ڵ� ������������ InnoDB�� ���̺� �����ϵ��� �����ϰ�
     �ý��� ���̺�� ������ ��ųʸ� ������ ��� ��Ƽ� mysql DB�� �����ϸ� mysql DB�� ��°�� mysql.idb��� ���̺����̽��� ����.


-- [����]

   - MySQL ������ ������ ��ųʸ� ������ information_schema DB�� Tables�� Columns ��� ���� �並 ���ؼ� ��ȸ�� ����.

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


-- InnoDB ���丮�� ���� ��Ű��ó

   - MySQL���� �����ϴ� ���丮�� ���� �� ���� �����ϰ� ���ڵ� ��� ��� ����.
   - ���� ���ü� ó�� ����, �������̸� ������ �پ.


-- �����̸Ӹ� Ű�� ���� Ŭ�����͸�

   - InnoDB ���̺��� �⺻������ �����̸Ӹ� Ű�� �������� Ŭ�����͸� �Ǿ� �����.




-- �ߺ� ����Ÿ ����
DELETE
  FROM contacts
 WHERE id IN ( SELECT id
                 FROM ( SELECT id
                             , ROW_NUMBER() OVER (PARTITION BY first_name
                                                             , last_name
                                                             , email
                                                             ) AS row_num
                          FROM contacts
                      ) tmp
                WHERE row_num > 1
             )
;

SELECT *
  FROM ( SELECT id
              , first_name
              , last_name
              , email
              , ROW_NUMBER() OVER (PARTITION BY first_name
                                              , last_name
                                              , email
                                              ) AS row_num
           FROM contacts
       ) a
 WHERE row_num > 1
 ORDER BY first_name    -- �ܼ� ���� �뵵
;

DELETE t1
  FROM contacts t1
  JOIN contacts t2
    ON t1.first_name = t2.first_name
   AND t1.last_name = t2.last_name
   AND t1.email = t2.email
 WHERE t1.id > t2.id
;

SELECT t1.*
  FROM contacts t1
  JOIN contacts t2
    ON t1.first_name = t2.first_name
   AND t1.last_name  = t2.last_name
   AND t1.email = t2.email
 WHERE t1.id > t2.id
;
