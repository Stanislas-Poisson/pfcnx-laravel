[mysqld]
general_log = 1
general_log_file = /var/lib/mysql/general.log
character-set-server = utf8
collation-server = utf8_unicode_ci
skip-character-set-client-handshake
sql_mode = "STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
