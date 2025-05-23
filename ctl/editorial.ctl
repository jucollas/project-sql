LOAD DATA
INFILE 'editorial.csv'
INTO TABLE editorial
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(idNumero, nombre)