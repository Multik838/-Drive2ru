-- ���� 4
-- CRUD ��������

-- ������ � �� vk
-- ��������� ���� ���������� ��������
DROP DATABASE vk;
CREATE DATABASE vk;
USE vk;

SELECT * FROM users;


-- ��������� � ����� � ������ (/home/user)
-- mysql -u root -p vk < vk.dump.sql
-- mysql vk < vk.dump.sql

-- ��������� ����� ���������� ������� � DBeaver

-- ************** ������������ ��
/*
������� 1
telephone � email �������� � ��������� �������� �� ������ � users ��� ������ foreign key.
�.�. ������� ����� � ��������� ����� ���� ������ ������.

��-�������� ��� ������ ������ ����� ������� ���� �� �������� � ������ �������, ����� users ��������� ������ id,
updated/created � ������ ������������ � (���� � ������������) �����.

� ������� Profile, gender ������ boolean ��� �������� ����� � ������� foreign key ��� ������ �� users.

������� �� �������� �������� FOREIGN KEYS ��� ������ ���������. �� ��������, �� ���� �� - UUID � �������� id ��� ���� ������.

������� 2
�� ��������� - ���� � ������ � �������� ��������� � profiles.
������ ���������: users - �������, ������������ ��� ������������� ������������,
������������ ��� �� ������ ����� ����, ��� ������ � profiles.

���� �� ��������� ��������� � email'�� �������� ������������� �������������,
��������� ���� ���������� � ���� ����� - ����� �����. (?)

������� 3
1. ���� ��� ����� ������� � ��������� ���������� ��� ����,
����� ��������� �������� ���� ������ �� ����������, � ���������� �� ��.
�� 1 ������� �� ������ ����� ������ ��� �� ��� ��������������� https://subscribe.ru/group/razumno-o-svoem-i-nabolevshem/6678982/
��� ����� ����� ������� ��� ���������� ��������, �.�., ���� ��� ������� � ����������� ����������,
�� ��� ��������� ��������� ��������� ���� �� ����� ������������� ���������� ��� ����
� �������� ���������� �������� �� ������� ����. 

2. ����� ���������� �� ��������� ������������ � ������� frienship,
����� � ������ � ������ ������������ ��������� ������ �� ������ ���� �����. UNIQUE (friend_id, user_id) (?)
*/

/*
�� �������� 1
���������� ���������� ������� � ��������� ������� (email, ������� � �.�.)
*/

CREATE TABLE contacts (
  id int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '������������� �����',
  user_id int(10) UNSIGNED NOT NULL COMMENT '������ �� ������� ������������',
  contact_type varchar(30) COMMENT '��� ��������',
  contact_info varchar(1000) COMMENT '���������� ����������',
  created_at datetime DEFAULT current_timestamp() COMMENT '����� �������� ������',
  updated_at datetime DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '����� ���������� ������',
  PRIMARY KEY (id)
) COMMENT='���������� ����������';

/*
�� �������� 2
������� ��� � ������� � profiles
*/

ALTER TABLE profiles
  ADD first_name varchar(100) NOT NULL COMMENT '��� ������������' AFTER country,
  ADD last_name varchar(100)  NOT NULL COMMENT '������� ������������' AFTER first_name
;

/*
�� �������� 3
���������� ��� �����
*/

CREATE TABLE gender (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "������������� ������", 
  gender VARCHAR(25) COMMENT "�������� ����",
  gender_info VARCHAR(150) COMMENT "���������� � ����",
  active BOOLEAN COMMENT "�������/���������. ����������� ��� ������",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "����� �������� ������",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "����� ���������� ������"
) COMMENT "�������� �����";

ALTER TABLE profiles
ADD gender_id INT NOT NULL COMMENT "������ �� ���" AFTER gender;

DESC profiles;
SELECT * FROM profiles;

/*  
�������������: �������� ���������� ��������
*/
CREATE TABLE user_statuses (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "������������� ������", 
  name VARCHAR(100) NOT NULL COMMENT "�������� ������� (���������)",
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT "����� �������� ������",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "����� ���������� ������"
) COMMENT "���������� �����";  

UPDATE profiles SET status = null;

SELECT * FROM user_statuses;

INSERT INTO user_statuses (name) VALUES
 ('single'),
 ('married');

ALTER TABLE profiles RENAME COLUMN status TO user_status_id; 
ALTER TABLE profiles MODIFY COLUMN user_status_id INT UNSIGNED; 
DESCRIBE profiles;
SELECT * FROM profiles;


-- ************** ������������ �������� ������
-- ����������� ������ �������������
SELECT * FROM users LIMIT 10;
-- ������� ��������� ������� �������������
DESC users;

-- ���� ���������� �� ������ ���� ������ ���� ��������  
UPDATE users SET updated_at = CURRENT_TIMESTAMP()
WHERE updated_at < created_at;

-- ����������� ������
SELECT * FROM gender LIMIT 10;
DESC gender;

-- ��������� ���������� ����� (��� �������������)
INSERT INTO gender (gender, gender_info) VALUES
 ('M', '�������'),
 ('F', '�������');

-- ����������� ������
SELECT * FROM user_statuses LIMIT 10;
DESC user_statuses;

-- ��������� ���������� �������� (��� �������������)
INSERT INTO user_statuses (name) VALUES
 ('Single'),
 ('Married');

-- ����������� ������
SELECT * FROM profiles LIMIT 10;
DESC profiles;

-- ��������� �������� ����� � profiles
-- SELECT id FROM gender ORDER BY rand() LIMIT 1;
UPDATE profiles SET gender_id = (SELECT id FROM gender ORDER BY rand() LIMIT 1); 
-- SELECT floor(1 + RAND() * 2);

-- ��������� id � user_statuses � ��������� ��� ��������������� ���� profiles
-- select * from user_statuses 
UPDATE profiles SET user_status_id = floor(1 + RAND() * 2); 

-- ��������� �������� first_name � last_name �� users � profiles
UPDATE profiles p SET p.first_name = 
(SELECT u.first_name FROM users u WHERE u.id = p.user_id); 
UPDATE profiles p SET p.last_name = 
(SELECT u.last_name FROM users u WHERE u.id = p.user_id); 

-- ������� �������, ������� ��������� � ����� �������
ALTER TABLE profiles DROP COLUMN gender;
ALTER TABLE users DROP COLUMN first_name, DROP COLUMN last_name;

-- ����������� ������
SELECT * FROM contacts LIMIT 10;
DESC contacts;

-- ��������� email � phone ������� ������������ �� users � contacts
INSERT INTO contacts (user_id, contact_type, contact_info)
SELECT id, 'email', email FROM users
UNION ALL
SELECT id, 'phone', phone FROM users;

-- ����������� ������

SELECT * FROM messages LIMIT 10;
DESC messages;

-- ��������� ��������, ����� ������������ ����� ��� ����, ����� ����� � ���������
-- UPDATE messages SET from_user_id = id, to_user_id = id;

-- ��������� ���������� ����������, �� ���� � ���� ���������
UPDATE messages SET
  from_user_id = floor(1 + RAND() * 100),
  to_user_id = floor(1 + RAND() * 100)
;

-- ����������� ������
SELECT * FROM media_types LIMIT 10;
DESC media_types;

-- ��������� ���������� ����� ����� (��� �������������)
INSERT INTO media_types (name) VALUES
 ('Video'),
 ('Audio'),
 ('Image');

-- ����������� ������
SELECT * FROM media LIMIT 10;
DESC media;

-- ��������� media � id ����� �� 1 �� 3 
UPDATE media SET
  media_type_id = floor(1 + RAND() * 3);

 -- ����������� ������
SELECT * FROM friendship_statuses LIMIT 10;
DESC friendship_statuses;

-- ������� ������� friendship_statuses (��� �������������)
-- ��� TRUNCATE ��������� ����� ����� ����� ����� ���������� � 1
TRUNCATE friendship_statuses;

-- ��������� ���������� �������� ������ (��� �������������)
INSERT INTO friendship_statuses (name)
VALUES ('Requested'), ('Approved'), ('Declined');

-- ����������� ������
SELECT * FROM friendship LIMIT 10;
DESC friendship;

-- ��������� ������� ������. ������� 1
UPDATE friendship SET
  user_id   = floor(1 + RAND() * 100), 
  friend_id = floor(1 + RAND() * 100),
  status_id = floor(1 + RAND() * 3) 
;

-- ��������� ������� ������. ������� 2
-- �������� �� ��, ��� ������ ������� �������/�������, ���������� ��� ���������� ������ ��������� �������
-- ����� ������������ ����� ������, �.�. � ������ ������ ��� �������������,
-- ����� id � ������������ � ��������� �������� ���������� � 1 � ��� ���������������
-- ������ ����� ������������� ������ �� ��������, ������� ���� � ��������� �������� 
UPDATE friendship SET
  user_id   = (SELECT id FROM users ORDER BY rand() LIMIT 1), 
  friend_id = (SELECT id FROM users ORDER BY rand() LIMIT 1),
  status_id = (SELECT id FROM friendship_statuses ORDER BY rand() LIMIT 1) 
;

-- ����������� ������
SELECT * FROM communities LIMIT 10;
DESC communities;
-- ������� 
DELETE FROM communities;
-- ������� ��������� (��� �������������)
INSERT INTO communities (name) values ('���������� ������');
INSERT INTO communities (name) values ('���������');
INSERT INTO communities (name) values ('����� ������');
-- ������� ��������, ��� ��� ���������� DELETE � ����������� ������� id ������ ������ ���������� �� � 1 
SELECT * FROM communities LIMIT 10;

-- ����������� ������
SELECT * FROM communities_users LIMIT 10;
DESC communities_users;

-- ������� ������� ������������� ���������(�����) (��� �������������)
DELETE FROM communities_users;

-- ��������� ��� �������� ������, ������ ���������� ��������
-- ����� ��������� �� 1 ���������� ������������ � ������ ������ 
-- � ��������� ������� ����� ���������� ������, ����������, ��� ��������� � ������
-- ����������� ������ � ������ ��� ���� ���� ������������
-- Duplicate entry '..-..' for key 'communities_users.PRIMARY'
-- ������ ������ ����� ����������
INSERT INTO communities_users (community_id, user_id)
SELECT id, (SELECT id FROM users ORDER BY rand() LIMIT 1)
 FROM communities;

-- ����������� ������
SELECT * FROM profiles;

-- �������� photo_id �������� �� ��������� media �� ������, ����������� ������ �����������
UPDATE profiles SET photo_id =  
(
  SELECT id FROM media WHERE media_type_id =
    (SELECT id FROM media_types WHERE name = 'Image')
    ORDER BY rand() LIMIT 1
); 

-- �������������
-- ������� ����, ������� ��������� � contacts
ALTER TABLE users DROP email, DROP phone;

-- ����������� ������
SELECT * FROM media LIMIT 10;
DESC media;

-- �������� ������ ������ ���, ��� �� ������� ���
UPDATE media SET SIZE = floor(SIZE + RAND() * 10000000) WHERE SIZE <10000;

-- ������ filldb ������� ��� ���� metadata � json �� longtext
DESC media;

-- ���������� ������� ���������� ���������� ���
ALTER TABLE media MODIFY COLUMN metadata JSON;

-- �������� ���� metadata ���������� �� ����� filename, size, user_id � media_type_id
-- � �������������� ������� JSON_OBJECT
UPDATE media SET metadata = 
JSON_OBJECT ('filename', filename, 'size', size, 'user_id', user_id, 'media_type_id', media_type_id);

-- ���. ������: ��� ������� �� ����� �� �����������?
SELECT * FROM gender;
SELECT * FROM profiles;

-- ALTER TABLE profiles
-- ADD gender char(1) COMMENT "���" AFTER gender_id;

-- UPDATE profiles SET gender = if(rand() > 0.5, 'M', 'F'); 
-- UPDATE profiles SET gender_id  = 0; 

UPDATE profiles p SET p.gender_id  =
  (SELECT g.id FROM gender g WHERE g.gender = p.gender); 

-- ALTER TABLE profiles DROP COLUMN gender;

-- ������������ ������� �� ���� �CRUD - ��������
-- 1. ��������� ��� �������� �� ��������� �� ��: ��������� ������ � ������
-- 2. ��������� ������ ������� ����� ������� ������� ��� ����� �������� ������.
-- 3. (�� �������) ���������� ���� ���������� ������ � ������.
 
 
DROP DATABASE vk;
CREATE DATABASE vk;
USE vk;


CREATE TABLE `likes` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`post_id` INT UNSIGNED DEFAULT NULL COMMENT 'post id from posts',
	`user_like_id` INT UNSIGNED DEFAULT NULL COMMENT 'user id from users',
	`like_date` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'date of like creation',
	PRIMARY KEY (`id`),
	KEY `fk_post_like_id` (`post_id`),
	KEY `fk_user_post_id` (`user_like_id`),
	CONSTRAINT `fk_post_like_id` FOREIGN KEY (`post_id`) REFERENCES `posts`(`id`),
	CONSTRAINT `fk_user_like_id` FOREIGN KEY (`user_like_id`) REFERENCES `users`(`id`));

CREATE TABLE `posts` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`user_id` INT UNSIGNED DEFAULT NULL COMMENT 'user id from users',
	`message` VARCHAR(5000) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
	`media` INT DEFAULT NULL COMMENT 'link to media from appropriate table',
	`deleted` TINYINT(1) DEFAULT '0',
	PRIMARY KEY (`id`),
	KEY `fk_user_id` (`user_id`),
	CONSTRAINT `fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`));

 DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT '������������� ������',
  `email` varchar(100) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL COMMENT '�����',
  `phone` varchar(100) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL COMMENT '�������',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '����� �������� ������',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '����� ���������� ������',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='������������';
/*!40101 SET character_set_client = @saved_cs_client */;
 
 
 
 
 
 
 