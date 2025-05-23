/*
Esta función sugiere libros disponibles para intercambio según el historial de lectura de un usuario, evitando recomendar libros ya leídos. Además, permite filtrar por género literario.

- Ayuda a los usuarios a encontrar libros relevantes que aún no han leído.
- Facilita la participación activa al proponer títulos potenciales.
- Utiliza datos existentes (historial de lectura y disponibilidad) para dar valor agregado.
*/


CREATE OR REPLACE TYPE libro_sugerido AS OBJECT (
  idLibro NUMBER,
  titulo VARCHAR2(100),
  genero VARCHAR2(50),
  estadoFisico VARCHAR2(20)
);
/

CREATE OR REPLACE TYPE lista_libros_sugeridos AS TABLE OF libro_sugerido;
/
CREATE OR REPLACE FUNCTION sugerir_intercambio(
  p_usuario_id NUMBER,
  p_genero_filtro VARCHAR2 DEFAULT NULL
) RETURN lista_libros_sugeridos
IS
  v_result lista_libros_sugeridos := lista_libros_sugeridos();
BEGIN
  FOR rec IN (
    SELECT DISTINCT
      l.idNumero AS idLibro,
      l.titulo,
      lit.nombre AS genero,
      e.estadoFisico
    FROM ejemplar e
    JOIN libro l ON e.idLibro = l.idNumero
    JOIN literatura lit ON l.literatura = lit.idNumero
    WHERE
      e.estadoBiblioteca = 'Disponible'
      AND e.idLibro NOT IN (
        SELECT idLibro FROM libroLeido WHERE idUsuario = p_usuario_id
      )
      AND (p_genero_filtro IS NULL OR lit.nombre = p_genero_filtro)
  ) LOOP
    v_result.EXTEND;
    v_result(v_result.LAST) := libro_sugerido(
      rec.idLibro,
      rec.titulo,
      rec.genero,
      rec.estadoFisico
    );
  END LOOP;

  RETURN v_result;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20004, 'Error al sugerir libros: ' || SQLERRM);
END;
/

