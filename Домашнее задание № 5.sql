DROP DATABASE IF EXISTS shop;
CREATE DATABASE shop;
USE shop;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at VARCHAR(255),
  updated_at VARCHAR(255)
) COMMENT = 'Покупатели';

INSERT INTO 
	users (name, birthday_at, created_at, updated_at) 
VALUES
  ('Геннадий', '1990-10-05','10.10.2016 18:10','10.10.2016 18:10'),
  ('Наталья', '1984-11-12','20.10.2017 8:10','20.10.2017 8:10'),
  ('Александр', '1985-05-20','20.11.2017 8:10','20.11.2017 8:10'),
  ('Сергей', '1988-02-14','16.10.2014 8:10','16.10.2014 8:10'),
  ('Иван', '1998-01-12','11.10.2000 4:45','11.10.2000 4:45'),
  ('Мария', '1992-08-29','15.09.1999 6:35','15.09.1999 6:35');
 
SELECT * FROM users;
DESC users;
 
_______________________________________________________________________

 
 
 
 UPDATE 
 	users 
 SET 
 	created_at = NOW(),
 	updated_at = NOW();
 
_______________________________________________________________________
#Перед выполнением вернуть тип данных VARCHAR во избежание ошибки SQL Error [1411] [HY000]: Incorrect datetime value:


UPDATE users
SET created_at = STR_TO_DATE(created_at, '%d.%m.%Y %k:%i'),
	updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %k:%i');

ALTER TABLE users CHANGE created_at created_at DATETIME DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE users CHANGE updated_at updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

DESCRIBE users;
  
_______________________________________________________________________

ALTER TABLE users ADD COLUMN created_at_ts DATETIME DEFAULT NOW(),
	ADD COLUMN updated_at_ts DATETIME DEFAULT NOW();

SELECT * FROM users;

UPDATE users
	SET created_at_ts = (SELECT STR_TO_DATE(created_at, '%d.%m.%Y %k:%i')),
	    updated_at_ts = (SELECT STR_TO_DATE(updated_at, '%d.%m.%Y %k:%i'));

SELECT * FROM users;
	   
ALTER TABLE users DROP COLUMN created_at, DROP COLUMN updated_at;
ALTER TABLE users RENAME COLUMN created_at_ts to created_at, RENAME COLUMN updated_at_ts to updated_at;
ALTER TABLE users CHANGE COLUMN updated_at updated_at DATETIME DEFAULT NOW() ON UPDATE NOW();

_______________________________________________________________________

DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id INT UNSIGNED,
  product_id INT UNSIGNED,
  value INT UNSIGNED COMMENT 'Запас товарной позиции на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Запасы на складе';


INSERT INTO
	storehouses_products (storehouse_id, product_id, value)
VALUES
	(1, 543, 0),
	(1, 789, 2500),
	(1, 3452, 0),
	(1, 826, 30),
	(1, 719, 500),
	(1, 638, 1);

SELECT * FROM 
	storehouses_products
ORDER BY IF
	(value > 0, 0, 1), value;
	
_______________________________________________________________________


DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at VARCHAR(255),
  updated_at VARCHAR(255)
) COMMENT = 'Покупатели';

INSERT INTO 
	users (name, birthday_at, created_at, updated_at) 
VALUES
  ('Геннадий', '1990-10-05','10.10.2016 18:10','10.10.2016 18:10'),
  ('Наталья', '1984-11-12','20.10.2017 8:10','20.10.2017 8:10'),
  ('Александр', '1985-05-20','20.11.2017 8:10','20.11.2017 8:10'),
  ('Сергей', '1988-02-14','16.10.2014 8:10','16.10.2014 8:10'),
  ('Иван', '1998-01-12','11.10.2000 4:45','11.10.2000 4:45'),
  ('Мария', '1992-08-29','15.09.1999 6:35','15.09.1999 6:35');

SELECT * FROM users;

SELECT name
	FROM users
	WHERE DATE_FORMAT(birthday_at, '%M') IN ('may', 'august');

_______________________________________________________________________

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память');

 SELECT * FROM catalogs 
 WHERE id IN (5, 1, 2)
 ORDER BY FIELD(id, 5, 1, 2);
 #Фильтруем по индексу id
_______________________________________________________________________

SELECT * FROM users;

SELECT
	AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW())) AS age
FROM 
	users;
#Задание выполняется в 2021 году

_______________________________________________________________________

SELECT * FROM users;

SELECT
	DATE_FORMAT(DATE(CONCAT_WS('-', YEAR(NOW()), MONTH (birthday_at), DAY(birthday_at))), '%W') AS day,
	COUNT(*) AS total
FROM
	users
GROUP BY
	day
ORDER BY
	total DESC;

_______________________________________________________________________


SELECT ROUND(EXP(SUM(LN(id)))) FROM catalogs;































