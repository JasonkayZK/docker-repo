CREATE DATABASE IF NOT EXISTS `test`;

DROP TABLE IF EXISTS `test`.`dept`;
CREATE TABLE `test`.`dept`
(
    `id`        bigint(32) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    `dept_id`   bigint(32) NOT NULL COMMENT '部门Id',
    `dept_name` varchar(255) DEFAULT '' COMMENT '部门名字',
    `salary`    int(10)      DEFAULT 0 COMMENT '部门薪水',
    PRIMARY KEY (`id`),
    KEY `idx_dept_id` (`dept_id`)
) ENGINE = FEDERATED
  DEFAULT CHARSET = utf8mb4
  CONNECTION = 'mysql://root:123456@<your-ip-address>:33331/test/dept' COMMENT ='部门基本信息表－链接表';

DROP TABLE IF EXISTS `test`.`employee`;
CREATE TABLE `test`.`employee`
(
    `id`        bigint(32) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    `uid`       bigint(32) NOT NULL COMMENT '员工Id',
    `dept_id`   bigint(32) NOT NULL COMMENT '员工部门Id',
    `user_name` varchar(255) DEFAULT '' COMMENT '部门名字',
    PRIMARY KEY (`id`),
    KEY `idx_dept_id` (`dept_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

INSERT INTO `test`.`employee` (uid, dept_id, user_name)
VALUES (10, 1001, 'user-1'),
       (11, 1001, 'user-2'),
       (12, 1002, 'user-3'),
       (13, 1002, 'user-4'),
       (14, 1003, 'user-5'),
       (15, 1003, 'user-6'),
       (16, 1004, 'user-7'),
       (17, 1004, 'user-8'),
       (18, 1005, 'user-9'),
       (19, 1005, 'user-10'),
       (20, 1006, 'user-11'),
       (21, 1006, 'user-12'),
       (22, 1007, 'user-13'),
       (23, 1007, 'user-14'),
       (24, 1008, 'user-15'),
       (25, 1008, 'user-16');
