LOAD DATA
INFILE 'intercambio.csv'
INTO TABLE intercambio
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(idNumero, tipoIntercambio, estado, usuario, fecha DATE "YYYY-MM-DD", fechaIni DATE "YYYY-MM-DD", fechaFin DATE "YYYY-MM-DD", cantDonada, puntuacionDonacion)