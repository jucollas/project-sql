SELECT * FROM TABLE(historial_intercambios(18));

SELECT * FROM TABLE(donaciones_consecutivas);



SELECT * FROM TABLE(usuarios_mas_activos(5, 2020));


SELECT * FROM TABLE(sugerir_intercambio(18)); -- usuario 101, sin filtro
SELECT * FROM TABLE(sugerir_intercambio(18, 'Lit1')); -- con filtro de género
