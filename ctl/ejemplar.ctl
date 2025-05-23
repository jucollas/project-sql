OPTIONS (SKIP=1)
LOAD DATA
INFILE 'ejemplar.csv'
INTO TABLE ejemplar
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  idEjemplar,
  idLibro,
  tipo,
  estadoFisico,
  puntuacion,
  imagen_nombre FILLER CHAR(255),
  imagen LOBFILE(imagen_nombre) TERMINATED BY EOF,
  usuario,
  intercambio,
  fechaAdquisicion DATE "YYYY-MM-DD",
  aceptadoBiblioteca,
  estadoBiblioteca,
  propietarioOriginal
)
