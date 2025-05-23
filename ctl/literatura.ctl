LOAD DATA
INFILE 'literatura.csv'
INTO TABLE literatura
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(idNumero, nombre, descripcion)