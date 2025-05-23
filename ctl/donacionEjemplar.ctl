LOAD DATA
INFILE 'donacionEjemplar.csv'
INTO TABLE donacionEjemplar
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(idDonacion, idUsuario, idEjemplar, fechaDonacion DATE "YYYY-MM-DD")