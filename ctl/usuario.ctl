LOAD DATA
INFILE 'usuario.csv'
INTO TABLE usuario
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(idNumero, nombre, contrasena, telefono, email, tipoUsuario, puntuacionDonacion, cantIntercambios, cantDonaciones)