LOAD DATA
INFILE 'categoria.csv'
INTO TABLE categoria
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(idNumero, nombre, nivel)