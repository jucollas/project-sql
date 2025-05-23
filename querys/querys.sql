/*1 Se requiere listar el título, ISBN, calidad y tipo (físico/digital) de los 
ejemplares que han sido intercambiados (entregados o recibidos), indicando si 
el intercambio es permanente o temporal, con la información del usuario que 
intervino en el intercambio (identificación y nombre), el nombre del(os) 
autor(es) y el género de cada libro. Incluir los intercambios que se han realizado
en un rango de fechas dado.*/

SELECT
    l.titulo AS TituloLibro,
    l.isbn AS ISBN,
    eOfrecido.estadoFisico AS CalidadEjemplar,
    eOfrecido.tipo AS TipoEjemplar,
    i.tipoIntercambio AS TipoIntercambio,
    u.idNumero AS IdUsuario,
    u.nombre AS NombreUsuario,
    a.nombre AS NombreAutor,
    lit.nombre AS GeneroLibro,
    i.fecha AS FechaIntercambio
FROM
    detalleIntercambio di
JOIN
    intercambio i ON di.idIntercambio = i.idNumero
JOIN
    ejemplar eOfrecido ON di.idEjemplarOfrecido = eOfrecido.idEjemplar
JOIN
    libro l ON eOfrecido.idLibro = l.idNumero
JOIN
    usuario u ON i.usuario = u.idNumero
JOIN
    libroAutor la ON l.idNumero = la.codLibro
JOIN
    autor a ON la.idAutor = a.idNumero
JOIN
    literatura lit ON l.literatura = lit.idNumero
WHERE
    i.fecha BETWEEN DATE '2024-01-01' AND DATE '2024-12-31' -- Ajusta el rango de fechas
UNION ALL
SELECT
    l.titulo AS TituloLibro,
    l.isbn AS ISBN,
    eRecibido.estadoFisico AS CalidadEjemplar,
    eRecibido.tipo AS TipoEjemplar,
    i.tipoIntercambio AS TipoIntercambio,
    u.idNumero AS IdUsuario,
    u.nombre AS NombreUsuario,
    a.nombre AS NombreAutor,
    lit.nombre AS GeneroLibro,
    i.fecha AS FechaIntercambio
FROM
    detalleIntercambio di
JOIN
    intercambio i ON di.idIntercambio = i.idNumero
JOIN
    ejemplar eRecibido ON di.idEjemplarRecibido = eRecibido.idEjemplar
JOIN
    libro l ON eRecibido.idLibro = l.idNumero
JOIN
    usuario u ON i.usuario = u.idNumero
JOIN
    libroAutor la ON l.idNumero = la.codLibro
JOIN
    autor a ON la.idAutor = a.idNumero
JOIN
    literatura lit ON l.literatura = lit.idNumero
WHERE
    i.fecha BETWEEN DATE '2024-01-01' AND DATE '2024-12-31'; -- Ajusta el rango de fechas


/*2 Realice un reporte donde aparezcan los usuarios que han realizado
 donaciones, incluyendo el “saldo o crédito” actual por sus donaciones*/

WITH ConteoDonacionesCalidad AS (
    SELECT
        de.idUsuario,
        SUM(CASE WHEN e.puntuacion <= 3 THEN 1 ELSE 0 END) AS MalaCalidad,
        SUM(CASE WHEN e.puntuacion > 3 AND e.puntuacion <= 7 THEN 1 ELSE 0 END) AS MedianaCalidad,
        SUM(CASE WHEN e.puntuacion > 7 THEN 1 ELSE 0 END) AS BuenaCalidad
    FROM
        donacionEjemplar de
    JOIN
        ejemplar e ON de.idEjemplar = e.idEjemplar
    GROUP BY
        de.idUsuario
), ConteoRecompensas AS (
    SELECT
        rd.idUsuario,
        COUNT(*) AS RecompensasRecibidas
    FROM
        recompensaDonacion rd
    GROUP BY
        rd.idUsuario
)
SELECT
    u.idNumero AS IdUsuario,
    u.nombre AS NombreUsuario,
    ccd.MalaCalidad AS LibrosDonadosMalaCalidad,
    ccd.MedianaCalidad AS LibrosDonadosMedianaCalidad,
    ccd.BuenaCalidad AS LibrosDonadosBuenaCalidad,
    cr.RecompensasRecibidas AS LibrosRecibidosRecompensa,
    FLOOR(ccd.MalaCalidad / 10) AS RecompensasPotencialesMediana,
    FLOOR(ccd.MedianaCalidad / 10) AS RecompensasPotencialesBuena,
    ccd.BuenaCalidad AS RecompensasPotencialesCualquier -- Cada 10 buena calidad da 1 cualquiera
FROM
    usuario u
LEFT JOIN
    ConteoDonacionesCalidad ccd ON u.idNumero = ccd.idUsuario
LEFT JOIN
    ConteoRecompensas cr ON u.idNumero = cr.idUsuario
WHERE
    ccd.MalaCalidad > 0 OR ccd.MedianaCalidad > 0 OR ccd.BuenaCalidad > 0
ORDER BY
    u.nombre;

/*3. Liste los meses (mes y año) en los que se han intercambiado más 
de X libros, contando libros entrantes y salientes.*/

SELECT
    TO_CHAR(i.fecha, 'YYYY-MM') AS MesAnio,
    COUNT(*) AS TotalIntercambios
FROM
    detalleIntercambio di
JOIN
    intercambio i ON di.idIntercambio = i.idNumero
GROUP BY
    TO_CHAR(i.fecha, 'YYYY-MM')
HAVING
    COUNT(*) > 5; -- Reemplaza 5 con el valor de X

/*4 Realice un reporte donde aparezcan los usuarios que no 
son administradores (id, nombre) con la cantidad de libros 
que ha entregado en intercambio, la cantidad de libros que 
ha recibido en intercambio, la cantidad de libros que ha 
donado, y la cantidad de libros que ha recibido en recompensa 
por la donación.*/

SELECT
    u.idNumero AS IdUsuario,
    u.nombre AS NombreUsuario,
    (SELECT COUNT(di.idEjemplarOfrecido)
     FROM detalleIntercambio di
     JOIN intercambio i ON di.idIntercambio = i.idNumero
     WHERE i.usuario = u.idNumero AND i.tipoIntercambio IN ('Permanente', 'Temporal')) AS LibrosEntregadosIntercambio,
    (SELECT COUNT(di.idEjemplarRecibido)
     FROM detalleIntercambio di
     JOIN intercambio i ON di.idIntercambio = i.idNumero
     WHERE i.usuario = u.idNumero AND i.tipoIntercambio IN ('Permanente', 'Temporal')) AS LibrosRecibidosIntercambio,
    (SELECT COUNT(e.idEjemplar)
     FROM ejemplar e
     JOIN intercambio i ON e.intercambio = i.idNumero
     WHERE e.propietarioOriginal = u.idNumero AND i.tipoIntercambio = 'Donación') AS LibrosDonados,
    (SELECT COUNT(di.idEjemplarRecibido)
     FROM detalleIntercambio di
     JOIN intercambio i ON di.idIntercambio = i.idNumero
     WHERE i.usuario = u.idNumero AND i.tipoIntercambio = 'Donación' AND di.tipoRol = 'Recibe') AS LibrosRecibidosRecompensa
FROM
    usuario u
WHERE
    u.tipoUsuario = 'Normal';

/*5. Realizar un reporte de los intercambios “temporales” que se vencen 
en los próximos 30 días, mostrando toda la información de contacto del 
usuario, la información pertinente de los libros, y la fecha en que se vence 
el intercambio.*/
SELECT
    u.idNumero AS IdUsuario,
    u.nombre AS NombreUsuario,
    u.telefono AS TelefonoUsuario,
    u.email AS EmailUsuario,
    l.titulo AS TituloLibro,
    l.isbn AS ISBN,
    e.tipo AS TipoEjemplar,
    i.fechaIni AS FechaInicioIntercambio,
    i.fechaFin AS FechaVencimiento
FROM
    intercambio i
JOIN
    usuario u ON i.usuario = u.idNumero
JOIN
    detalleIntercambio di ON i.idNumero = di.idIntercambio
LEFT JOIN
    ejemplar e ON di.idEjemplarRecibido = e.idEjemplar -- Asumiendo que el libro temporalmente en posesion esta en Recibido
JOIN
    libro l ON e.idLibro = l.idNumero
WHERE
    i.tipoIntercambio = 'Temporal'
    AND i.fechaFin BETWEEN SYSDATE AND SYSDATE + INTERVAL '30' DAY; -- Ajusta la sintaxis de intervalo segun tu base de datos

/*6. Generar una consulta que liste todas las donaciones que han propuesto
 los usuarios, que incluya los datos del usuario (id, nombre), la fecha de 
 la donación, la cantidad de los libros recibidos en la donación 
 (título, autor(es), tipo de libro), y si ha recibido libros en recompensa 
 por esa donación, los datos de los libros recibidos (título, autor(es), 
 tipo de libro –digital o físico)*/
SELECT
    u.idNumero AS IdUsuarioDonante,
    u.nombre AS NombreUsuarioDonante,
    de.fechaDonacion AS FechaDonacion,
    lDonado.titulo AS TituloLibroDonado,
    aDonado.nombre AS AutorLibroDonado,
    eDonado.tipo AS TipoLibroDonado,
    eDonado.estadoFisico AS CalidadLibroDonado,
    ur.idNumero AS IdUsuarioRecompensa,
    ur.nombre AS NombreUsuarioRecompensa,
    lr.titulo AS TituloLibroRecompensa,
    ar.nombre AS AutorLibroRecompensa,
    er.tipo AS TipoLibroRecompensa
FROM
    donacionEjemplar de
JOIN
    usuario u ON de.idUsuario = u.idNumero
JOIN
    ejemplar eDonado ON de.idEjemplar = eDonado.idEjemplar
JOIN
    libro lDonado ON eDonado.idLibro = lDonado.idNumero
LEFT JOIN
    libroAutor lad ON lDonado.idNumero = lad.codLibro
LEFT JOIN
    autor aDonado ON lad.idAutor = aDonado.idNumero
LEFT JOIN
    recompensaDonacion rd ON de.idUsuario = rd.idUsuario -- Podemos intentar relacionar por usuario
LEFT JOIN
    usuario ur ON rd.idUsuario = ur.idNumero
LEFT JOIN
    ejemplar er ON rd.idEjemplar = er.idEjemplar
LEFT JOIN
    libro lr ON er.idLibro = lr.idNumero
LEFT JOIN
    libroAutor lar ON lr.idNumero = lar.codLibro
LEFT JOIN
    autor ar ON lar.idAutor = ar.idNumero
ORDER BY
    de.fechaDonacion;



/*
7. Consulta que requiere subconsultas:
Requerimiento en lenguaje natural: Obtener los títulos de los libros que pertenecen a algún tema que tiene la palabra "ciencia" en su nombre.
Explicación de relevancia: Esta consulta es útil para identificar libros relacionados con áreas específicas de interés, en este caso, aquellos temas que se identifican por la palabra "ciencia". Permite a los usuarios encontrar rápidamente libros dentro de categorías temáticas particulares.
*/
SELECT titulo
FROM libro
WHERE idNumero IN (
    SELECT codLibro
    FROM libroTema
    WHERE codTema IN (
        SELECT idNumero
        FROM tema
        WHERE nombre LIKE '%ciencia%'
    )
);

/*
8.Consulta que usa operadores de conjuntos (Unión):
Requerimiento en lenguaje natural: Listar todos los nombres de los usuarios que han realizado algún intercambio (de cualquier tipo) o que han donado algún ejemplar.
Explicación de relevancia: Esta consulta permite tener una visión general de todos los usuarios activos en el sistema, ya sea participando en intercambios o contribuyendo a la biblioteca mediante donaciones. Es útil para identificar la base de usuarios involucrados en la dinámica de la plataforma.
*/

SELECT u.nombre
FROM usuario u
WHERE u.idNumero IN (SELECT DISTINCT usuario FROM intercambio)
UNION
SELECT u.nombre
FROM usuario u
WHERE u.idNumero IN (SELECT DISTINCT idUsuario FROM donacionEjemplar);

/*
9. Consulta que requiere outer join (Left Outer Join):
Requerimiento en lenguaje natural: Mostrar todos los libros y, si tienen algún tema asociado, mostrar también el nombre del primer tema asociado. Si un libro no tiene ningún tema asignado, aún debe aparecer en la lista con un valor nulo para el nombre del tema.
Explicación de relevancia: Esta consulta es importante para tener un catálogo completo de todos los libros, incluso aquellos que aún no han sido categorizados por temas. El uso de LEFT OUTER JOIN asegura que cada libro se liste, proporcionando información sobre sus temas cuando esté disponible.
*/

SELECT l.titulo, t.nombre AS nombre_tema
FROM libro l
LEFT OUTER JOIN libroTema lt ON l.idNumero = lt.codLibro
LEFT OUTER JOIN tema t ON lt.codTema = t.idNumero;

/*
10. Consulta que requiere agrupamiento:
Requerimiento en lenguaje natural: Contar cuántos ejemplares de cada tipo ('fisico', 'digital') tiene cada usuario en la biblioteca. Mostrar el nombre del usuario, el tipo de ejemplar y la cantidad.
Explicación de relevancia: Esta consulta proporciona una visión general de la distribución de los tipos de ejemplares entre los usuarios. Es útil para entender las preferencias de los usuarios y la disponibilidad de los diferentes formatos de libros en la plataforma.
*/

SELECT u.nombre AS nombre_usuario, e.tipo AS tipo_ejemplar, COUNT(e.idEjemplar) AS cantidad_ejemplares
FROM ejemplar e
JOIN usuario u ON e.usuario = u.idNumero
GROUP BY u.nombre, e.tipo
ORDER BY u.nombre, e.tipo;