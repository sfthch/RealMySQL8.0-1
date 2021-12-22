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