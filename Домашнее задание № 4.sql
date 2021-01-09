-- Урок 4
-- CRUD операции

-- Работа с БД vk
-- Загружаем дамп консольным клиентом
DROP DATABASE vk;
CREATE DATABASE vk;
USE vk;

SELECT * FROM users;


-- Переходим в папку с дампом (/home/user)
-- mysql -u root -p vk < vk.dump.sql
-- mysql vk < vk.dump.sql

-- Загружаем через выполнение скрипта в DBeaver

-- ************** Дорабатываем БД
/*
Вариант 1
telephone и email выделены в отдельные таблички со связью с users при помощи foreign key.
Т.к. адресов почты и телефонов может быть больше одного.

По-хорошему все личные данные юзера неплохо было бы выделить в разные таблицы, чтобы users содержала только id,
updated/created и статус пользователя и (хотя и нежелательно) логин.

В таблице Profile, gender сделан boolean для экономии места и добавил foreign key для ссылки на users.

Немного по таблицам раскидал FOREIGN KEYS для лучшей связности. Не добавлял, но надо бы - UUID в качестве id для всех таблиц.

Вариант 2
Из доработок - поля с именем и фамилией перенесла в profiles.
Логика следующая: users - таблица, используемая для идентификации пользователя,
пользователь сам ее менять будет реже, чем данные в profiles.

Плюс на изменения телефонов и email'ов отдельно запрашивается подтверждение,
изменение этой информации и дата оного - очень важна. (?)

Вариант 3
1. Поле пол можно вынести в отдельный справочник для того,
чтобы возможные варианты были заданы не программно, а выбирались из БД.
По 1 символу не всегда можно понять что за пол подразумевается https://subscribe.ru/group/razumno-o-svoem-i-nabolevshem/6678982/
Это также будет удобней для построения запросов, т.к., если нет доступа к программной обололочке,
то для понимания возможных вариантов пола не будет необходимости перебирать всю базу
и выбирать уникальные значения по данному полю. 

2. Можно избавиться от возможной избыточности в таблице frienship,
когда и первый и второй пользователь отпраявят запрос на дружбу друг другу. UNIQUE (friend_id, user_id) (?)
*/

/*
Из варианта 1
Контактную информацию вынести в отдельную таблицу (email, телефон и т.д.)
*/

CREATE TABLE contacts (
  id int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Идентификатор сроки',
  user_id int(10) UNSIGNED NOT NULL COMMENT 'Ссылка на профиль пользователя',
  contact_type varchar(30) COMMENT 'Тип контакта',
  contact_info varchar(1000) COMMENT 'контактная информация',
  created_at datetime DEFAULT current_timestamp() COMMENT 'Время создания строки',
  updated_at datetime DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Время обновления строки',
  PRIMARY KEY (id)
) COMMENT='Контактная информация';

/*
Из варианта 2
Вынести имя и фамилию в profiles
*/

ALTER TABLE profiles
  ADD first_name varchar(100) NOT NULL COMMENT 'Имя пользователя' AFTER country,
  ADD last_name varchar(100)  NOT NULL COMMENT 'Фамилия пользователя' AFTER first_name
;

/*
Из варианта 3
Справочник для полов
*/

CREATE TABLE gender (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки", 
  gender VARCHAR(25) COMMENT "Название пола",
  gender_info VARCHAR(150) COMMENT "Информация о поле",
  active BOOLEAN COMMENT "Активен/Неактивен. Доступность для выбора",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Варианты полов";

ALTER TABLE profiles
ADD gender_id INT NOT NULL COMMENT "Ссылка на пол" AFTER gender;

DESC profiles;
SELECT * FROM profiles;

/*  
Дополнительно: добавить справочник статусов
*/
CREATE TABLE user_statuses (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки", 
  name VARCHAR(100) NOT NULL COMMENT "Название статуса (уникально)",
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Справочник стран";  

UPDATE profiles SET status = null;

SELECT * FROM user_statuses;

INSERT INTO user_statuses (name) VALUES
 ('single'),
 ('married');

ALTER TABLE profiles RENAME COLUMN status TO user_status_id; 
ALTER TABLE profiles MODIFY COLUMN user_status_id INT UNSIGNED; 
DESCRIBE profiles;
SELECT * FROM profiles;


-- ************** Дорабатываем тестовые данные
-- Анализируем данные пользователей
SELECT * FROM users LIMIT 10;
-- Смотрим структуру таблицы пользователей
DESC users;

-- Дата обновления не должна быть раньше даты создания  
UPDATE users SET updated_at = CURRENT_TIMESTAMP()
WHERE updated_at < created_at;

-- Анализируем данные
SELECT * FROM gender LIMIT 10;
DESC gender;

-- Заполняем справочник полов (при необходимости)
INSERT INTO gender (gender, gender_info) VALUES
 ('M', 'Мужской'),
 ('F', 'Женский');

-- Анализируем данные
SELECT * FROM user_statuses LIMIT 10;
DESC user_statuses;

-- Заполняем справочник статусов (при необходимости)
INSERT INTO user_statuses (name) VALUES
 ('Single'),
 ('Married');

-- Анализируем данные
SELECT * FROM profiles LIMIT 10;
DESC profiles;

-- Заполняем значения полов в profiles
-- SELECT id FROM gender ORDER BY rand() LIMIT 1;
UPDATE profiles SET gender_id = (SELECT id FROM gender ORDER BY rand() LIMIT 1); 
-- SELECT floor(1 + RAND() * 2);

-- Проверяем id в user_statuses и заполняем ими соответствующее поле profiles
-- select * from user_statuses 
UPDATE profiles SET user_status_id = floor(1 + RAND() * 2); 

-- Переносим значения first_name и last_name из users в profiles
UPDATE profiles p SET p.first_name = 
(SELECT u.first_name FROM users u WHERE u.id = p.user_id); 
UPDATE profiles p SET p.last_name = 
(SELECT u.last_name FROM users u WHERE u.id = p.user_id); 

-- удаляем столбцы, которые перенесли в друге таблицы
ALTER TABLE profiles DROP COLUMN gender;
ALTER TABLE users DROP COLUMN first_name, DROP COLUMN last_name;

-- Анализируем данные
SELECT * FROM contacts LIMIT 10;
DESC contacts;

-- Переносим email и phone каждого пользователя из users в contacts
INSERT INTO contacts (user_id, contact_type, contact_info)
SELECT id, 'email', email FROM users
UNION ALL
SELECT id, 'phone', phone FROM users;

-- Анализируем данные

SELECT * FROM messages LIMIT 10;
DESC messages;

-- Эмулируем ситуацию, когда пользователь пишет сам себе, чтобы далее её исправить
-- UPDATE messages SET from_user_id = id, to_user_id = id;

-- заполняем случайными значениями, от кого и кому сообщение
UPDATE messages SET
  from_user_id = floor(1 + RAND() * 100),
  to_user_id = floor(1 + RAND() * 100)
;

-- Анализируем данные
SELECT * FROM media_types LIMIT 10;
DESC media_types;

-- Заполняем справочник типов медиа (при необходимости)
INSERT INTO media_types (name) VALUES
 ('Video'),
 ('Audio'),
 ('Image');

-- Анализируем данные
SELECT * FROM media LIMIT 10;
DESC media;

-- Заполняем media с id типаа от 1 до 3 
UPDATE media SET
  media_type_id = floor(1 + RAND() * 3);

 -- Анализируем данные
SELECT * FROM friendship_statuses LIMIT 10;
DESC friendship_statuses;

-- Очищаем таблицу friendship_statuses (при необходимости)
-- При TRUNCATE нумерация новых строк снова будет начинаться с 1
TRUNCATE friendship_statuses;

-- Заполняем справочник статусов дружбы (при необходимости)
INSERT INTO friendship_statuses (name)
VALUES ('Requested'), ('Approved'), ('Declined');

-- Анализируем данные
SELECT * FROM friendship LIMIT 10;
DESC friendship;

-- Обновляем таблицу дружбы. Вариант 1
UPDATE friendship SET
  user_id   = floor(1 + RAND() * 100), 
  friend_id = floor(1 + RAND() * 100),
  status_id = floor(1 + RAND() * 3) 
;

-- Обновляем таблицу дружбы. Вариант 2
-- Несмотря на то, что данный вариант длиннее/сложнее, желательно при заполнении таблиц тестовыми данными
-- везде использовать такой подход, т.к. в данном случае нет необходимости,
-- чтобы id в справочниках и связанных таблицах начинались с 1 и шли последовательно
-- Всегда будут подставляться только те значения, которые есть в связанных таблицах 
UPDATE friendship SET
  user_id   = (SELECT id FROM users ORDER BY rand() LIMIT 1), 
  friend_id = (SELECT id FROM users ORDER BY rand() LIMIT 1),
  status_id = (SELECT id FROM friendship_statuses ORDER BY rand() LIMIT 1) 
;

-- Анализируем данные
SELECT * FROM communities LIMIT 10;
DESC communities;
-- Удаляем 
DELETE FROM communities;
-- Создаем несколько (при необходимости)
INSERT INTO communities (name) values ('Популярная музыка');
INSERT INTO communities (name) values ('Экскурсии');
INSERT INTO communities (name) values ('Школа танцев');
-- Обратим внимание, что при выполнении DELETE и последующей вставке id первой записи начинается не с 1 
SELECT * FROM communities LIMIT 10;

-- Анализируем данные
SELECT * FROM communities_users LIMIT 10;
DESC communities_users;

-- Очищаем таблицу пользователей сообществ(групп) (при необходимости)
DELETE FROM communities_users;

-- Несколько раз выполним запрос, каждое выполнение которого
-- будет добавлять по 1 случайному пользователю в каждую группу 
-- В некоторых случаях может выдаваться ошибка, означающая, что случайном в наборе
-- вставляемых данных в группе уже есть этот пользователь
-- Duplicate entry '..-..' for key 'communities_users.PRIMARY'
-- Данную ошибку можно пропустить
INSERT INTO communities_users (community_id, user_id)
SELECT id, (SELECT id FROM users ORDER BY rand() LIMIT 1)
 FROM communities;

-- Анализируем данные
SELECT * FROM profiles;

-- Заполним photo_id ссылками на случайные media из набора, содержащего только изображения
UPDATE profiles SET photo_id =  
(
  SELECT id FROM media WHERE media_type_id =
    (SELECT id FROM media_types WHERE name = 'Image')
    ORDER BY rand() LIMIT 1
); 

-- Дополнительно
-- Удаляем поля, которые перенесли в contacts
ALTER TABLE users DROP email, DROP phone;

-- Анализируем данные
SELECT * FROM media LIMIT 10;
DESC media;

-- Увеличим размер файлов там, где он слишком мал
UPDATE media SET SIZE = floor(SIZE + RAND() * 10000000) WHERE SIZE <10000;

-- Сервис filldb заменил тип поля metadata с json на longtext
DESC media;

-- Возвращаем столбцу метаданных правильный тип
ALTER TABLE media MODIFY COLUMN metadata JSON;

-- Заполним поле metadata значениями из полей filename, size, user_id и media_type_id
-- с использованием функции JSON_OBJECT
UPDATE media SET metadata = 
JSON_OBJECT ('filename', filename, 'size', size, 'user_id', user_id, 'media_type_id', media_type_id);

-- Доп. вопрос: как перейти со строк на справочники?
SELECT * FROM gender;
SELECT * FROM profiles;

-- ALTER TABLE profiles
-- ADD gender char(1) COMMENT "пол" AFTER gender_id;

-- UPDATE profiles SET gender = if(rand() > 0.5, 'M', 'F'); 
-- UPDATE profiles SET gender_id  = 0; 

UPDATE profiles p SET p.gender_id  =
  (SELECT g.id FROM gender g WHERE g.gender = p.gender); 

-- ALTER TABLE profiles DROP COLUMN gender;

-- Практическое задание по теме “CRUD - операции”
-- 1. Повторить все действия по доработке БД ВК: структура таблиц и данные
-- 2. Подобрать сервис который будет служить основой для вашей курсовой работы.
-- 3. (по желанию) Предложить свою реализацию лайков и постов.
 
 
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
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT 'Идентификатор строки',
  `email` varchar(100) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL COMMENT 'Почта',
  `phone` varchar(100) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL COMMENT 'Телефон',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания строки',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Время обновления строки',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Пользователи';
/*!40101 SET character_set_client = @saved_cs_client */;
 
 
 
 
 
 
 