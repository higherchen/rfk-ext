CREATE TABLE `archive` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `title` varchar(16) NOT NULL COMMENT '文章标题',
  `body` varchar(200) NOT NULL DEFAULT '' COMMENT '文章内容',
  `ctime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `mtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='文章表';

INSERT INTO `archive` VALUES (1,'Hello World','新的起点，新的开始 Hello world!','2017-03-05 22:55:28','2017-03-05 22:55:28');
