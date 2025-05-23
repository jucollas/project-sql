OPTIONS (SKIP=1)
LOAD DATA
INFILE 'libro.csv'
INTO TABLE libro
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(idNumero, isbn, titulo, edicion, fechaPublicacion DATE "YYYY-MM-DD", categoria, editorial, literatura)