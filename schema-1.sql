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
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

INSERT INTO `test`.`dept` (dept_id, dept_name, salary)
VALUES (1001, '部门1', 1500),
       (1002, '部门2', 2500),
       (1003, '部门3', 3500),
       (1004, '部门4', 4500),
       (1005, '部门5', 5500),
       (1006, '部门6', 6500),
       (1007, '部门7', 7500),
       (1008, '部门8', 8500);
