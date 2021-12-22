-- 설정값 변경

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

   RESET PERSIST;  -- 전체취소


-- 사용자 인증방식 변경

   - SHOW GLOBAL VARIABLES LIKE 'default_authentication_plugin%';
     +-------------------------------+-----------------------+
     | Variable_name                 | Value                 |
     +-------------------------------+-----------------------+
     | default_authentication_plugin | caching_sha2_password |
     +-------------------------------+-----------------------+

   - SET GLOBAL       default_authentication_plugin=mysql_native_password;  -- 임시변경
     or
     SET PERSIST      default_authentication_plugin=mysql_native_password;  -- 영구변경
     or
     SET PERSIST_ONLY default_authentication_plugin=mysql_native_password;  -- SET PERSIST 에러시

     #RESET PERSIST IF EXISTS default_authentication_plugin;    -- 삭제시

   - my.cnf (caching_sha2_password => mysql_native_password)
     [mysqld]
     default_authentication_plugin=mysql_native_password


-- db 생성

   - CREATE DATABASE test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


-- Roll 생성 및 권한부여

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

   SET ROLE role_test_read;     -- 임시변경

   SELECT current_role();
   +----------------------+
   | current_role()       |
   +----------------------+
   | `role_test_read`@`%` |
   +----------------------+

   -- LOGIN시 SET ROLE 자동설정
   SHOW GLOBAL VARIABLES LIKE 'activate_all_roles_on_login%';
   +-----------------------------+-------+
   | Variable_name               | Value |
   +-----------------------------+-------+
   | activate_all_roles_on_login | OFF   |
   +-----------------------------+-------+

   SET GLOBAL       activate_all_roles_on_login=ON;     -- 임시변경
   or
   SET PERSIST      activate_all_roles_on_login=ON;     -- 영구변경
   or
   SET PERSIST_ONLY activate_all_roles_on_login=ON;     -- SET PERSIST 에러시

   #RESET PERSIST IF EXISTS activate_all_roles_on_login;    -- 삭제시

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


-- 사용자 생성및 권한주기

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