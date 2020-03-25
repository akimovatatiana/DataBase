CREATE TABLE hairdresser
(
	id_hairdresser INT PRIMARY KEY IDENTITY,
	first_name nvarchar(50) NOT NULL,
	last_name nvarchar(50) NOT NULL,
	age TINYINT NOT NULL,
	salary INT NOT NULL
)
GO

CREATE TABLE service
(
	id_service int PRIMARY KEY IDENTITY,
	name nvarchar(50) NOT NULL,
	description nvarchar(255) NOT NULL,
	time TIME NOT NULL,
	cost INT NOT NULL,
	id_hairdresser INT REFERENCES hairdresser(id_hairdresser)
)
GO
--DROP TABLE service;
CREATE TABLE completed
(
	id_completed int PRIMARY KEY IDENTITY,
	date DATETIME NOT NULL,
	time_spent TIME NOT NULL,
	complexity TINYINT NOT NULL,
	rating TINYINT NOT NULL,
	id_hairdresser INT REFERENCES hairdresser(id_hairdresser),
	id_service INT REFERENCES service(id_service),
	id_client INT REFERENCES client(id_client)
)
GO
--DROP TABLE completed;

CREATE TABLE salon
(
	id_salon INT PRIMARY KEY IDENTITY,
	name VARCHAR(50) NOT NULL,
	address VARCHAR(100) NOT NULL,
	phone VARCHAR(15) NOT NULL,
	email VARCHAR(255) NOT NULL
)
GO
DROP TABLE salon;
CREATE TABLE hairdresser_salon
(
	id_hairdresser_salon INT PRIMARY KEY IDENTITY,
	id_hairdresser INT REFERENCES hairdresser(id_hairdresser),
	id_salon INT REFERENCES salon(id_salon)
)
GO
DROP TABLE hairdresser_salon;
CREATE TABLE client
(
	id_client INT PRIMARY KEY IDENTITY,
	first_name nvarchar(50) NOT NULL,
	last_name nvarchar(50) NOT NULL,
	age TINYINT NOT NULL,
	phone nvarchar(15) NOT NULL,
)
GO
--DROP TABLE client;