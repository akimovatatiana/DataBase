-- 1. Добавить внешние ключи.
	ALTER TABLE room 
		ADD FOREIGN KEY (id_hotel) REFERENCES hotel (id_hotel);

	ALTER TABLE room 
		ADD FOREIGN KEY (id_room_category) REFERENCES room_category (id_room_category);

	ALTER TABLE room_in_booking
		ADD FOREIGN KEY (id_booking) REFERENCES booking (id_booking);

	ALTER TABLE room_in_booking
		ADD FOREIGN KEY (id_room) REFERENCES room (id_room);

	ALTER TABLE booking
		ADD FOREIGN KEY (id_client) REFERENCES client (id_client);

-- 2. Выдать информацию о клиентах гостиницы "Космос", проживающих в номерах категории "Люкс" на 1 апреля 2019г. 
	SELECT client.id_client, client.name, client.phone FROM room_in_booking
	LEFT JOIN room ON room_in_booking.id_room = room.id_room
	LEFT JOIN hotel ON hotel.id_hotel = room.id_hotel
	LEFT JOIN room_category ON room_category.id_room_category = room.id_room_category
	LEFT JOIN booking ON booking.id_booking = room_in_booking.id_booking
	LEFT JOIN client ON client.id_client = booking.id_client
	WHERE
		hotel.name = 'Космос' AND 
		room_category.name = 'Люкс' AND 
		('2019-04-01' >= room_in_booking.checkin_date AND '2019-04-01' < room_in_booking.checkout_date);

-- 3. Дать список свободных номеров всех гостиниц на 22 апреля. 
	SELECT * FROM room WHERE id_room NOT IN (
	SELECT room.id_room FROM room_in_booking 
	RIGHT JOIN room ON room.id_room = room_in_booking.id_room
	WHERE '2019-04-22' >= room_in_booking.checkin_date AND '2019-04-22' <= room_in_booking.checkout_date
		)
	ORDER BY id_room, id_hotel

-- 4. Дать количество проживающих в гостинице "Космос" на 23 марта по каждой категории номеров	
	SELECT COUNT(room_in_booking.id_room) AS residents, room_category.id_room_category, 
	(SELECT name FROM room_category AS r WHERE r.id_room_category = room_category.id_room_category) 
	FROM room_category 
	INNER JOIN room ON room_category.id_room_category = room.id_room_category
	INNER JOIN hotel ON hotel.id_hotel = room.id_hotel
	INNER JOIN room_in_booking ON room.id_room = room_in_booking.id_room
	WHERE
		hotel.name = 'Космос' AND 
		('2019-03-23' >= room_in_booking.checkin_date AND '2019-03-23' < room_in_booking.checkout_date)
	GROUP BY
	    room_category.id_room_category
	
-- 5. Дать список последних проживавших клиентов по всем комнатам гостиницы "Космос", выехавшим в апреле с указанием даты выезда. 
-- доработать вывод записи room_in_booking по наименьшему id
	SELECT
		room_in_booking.id_room,
		MAX(room_in_booking.checkout_date) AS departure_date
	INTO #temp_table
	FROM room_in_booking
		LEFT JOIN room ON room.id_room = room_in_booking.id_room
	WHERE room.id_hotel = 1 AND checkout_date BETWEEN '2019-04-01' AND '2019-04-30'
	GROUP BY room_in_booking.id_room

	SELECT
	  client.name,
	  MAX(#temp_table.departure_date) AS depature_date,
	  #temp_table.id_room
	FROM #temp_table
	  LEFT JOIN room_in_booking
		ON #temp_table.id_room = room_in_booking.id_room AND #temp_table.departure_date = room_in_booking.checkout_date
	  LEFT JOIN booking ON room_in_booking.id_booking = booking.id_booking
	  LEFT JOIN client ON booking.id_client = client.id_client
	GROUP BY client.name, #temp_table.id_room
	ORDER BY client.name

-- 6. Продлить на 2 дня дату проживания в гостинице "Космос" всем клиентам комнат категории "Бизнес", которые заселились 10 мая.
	UPDATE room_in_booking
	SET room_in_booking.checkout_date = DATEADD(day, 2, checkout_date)
	FROM room
		INNER JOIN hotel ON room.id_hotel = hotel.id_hotel
		INNER JOIN room_category ON room.id_room_category = room_category.id_room_category
	WHERE 
		hotel.name = 'Космос' AND 
		room_category.name = 'Бизнес' AND
		room_in_booking.checkin_date = '2019-05-10';

--7. Найти все "пересекающиеся" варианты проживания.
	SELECT *
	FROM room_in_booking t1, room_in_booking t2
	WHERE 
		t1.id_room = t2.id_room AND
		t1.id_room_in_booking != t2.id_room_in_booking AND 
		(t1.checkin_date <= t2.checkin_date AND t2.checkin_date < t1.checkout_date)
	ORDER BY t1.id_room_in_booking

-- 8. Создать бронирование в транзакции
	BEGIN TRANSACTION

	INSERT INTO client (name, phone)
	VALUES 
		('Иванов Павел Игоревич', '7(897)785-87-12');

	INSERT INTO booking (id_client, booking_date)
	VALUES 
		((SELECT id_client FROM client WHERE id_client = SCOPE_IDENTITY()), CONVERT(date, CURRENT_TIMESTAMP));

	INSERT INTO room_in_booking (id_booking, id_room, checkin_date, checkout_date)
	VALUES 
		(2003, 12, '2020-04-12', '2020-04-16');
	 
	COMMIT;
--
	BEGIN TRANSACTION

	INSERT INTO client (name, phone)
	VALUES 
		('Сергеев Иван Алексеевич', '7(897)785-89-15');

	INSERT INTO booking (id_client, booking_date)
	VALUES 
		((SELECT id_client FROM client WHERE id_client = SCOPE_IDENTITY()), CONVERT(date, CURRENT_TIMESTAMP));

	DECLARE @IdBooking INT;
	SELECT @IdBooking = id_booking FROM booking WHERE id_booking = SCOPE_IDENTITY();

	INSERT INTO room_in_booking (id_booking, id_room, checkin_date, checkout_date)
	VALUES 
		(@IdBooking, 15, '2020-05-08', '2020-05-16');
	 
	COMMIT;

-- 9. Добавить необходимые индексы для всех таблиц
	CREATE NONCLUSTERED INDEX [IX_room_id_booking_checkin_date-checkout_date] ON [dbo].[room_in_booking]
	(
		[checkin_date] ASC,
		[checkout_date] ASC
	)
	CREATE NONCLUSTERED INDEX [IX_room_in_booking_id_room-id_booking] ON [dbo].[room_in_booking]
	(
		[id_room] ASC,
		[id_booking] ASC
	)
	CREATE NONCLUSTERED INDEX [IX_room_id_hotel-id_room_category] ON [dbo].[room]
	(
		[id_hotel] ASC,
		[id_room_category] ASC
	)
	CREATE NONCLUSTERED INDEX [IX_booking_id_client] ON [dbo].[booking]
	(
		[id_client] ASC
	)
	CREATE UNIQUE NONCLUSTERED INDEX [IU_client_phone] ON [dbo].[client]
	(
		[phone] ASC
	)
	CREATE NONCLUSTERED INDEX [IX_hotel_name] ON [dbo].[hotel]
	(
		[name] ASC
	)
	CREATE NONCLUSTERED INDEX [IX_room_category_name] ON [dbo].[room_category]
	(
		[name] ASC
	)

