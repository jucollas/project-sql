-- Tipo de fila
CREATE OR REPLACE TYPE historial_row_type_1 AS OBJECT (
  nombre_usuario         VARCHAR2(50),
  fecha_intercambio      DATE,
  entregado_o_recibido   VARCHAR2(10),

  titulo_libro_ofrecido  VARCHAR2(100),
  genero_libro_ofrecido  VARCHAR2(50),
  estado_libro_ofrecido  VARCHAR2(50),

  titulo_libro_recibido  VARCHAR2(100),
  genero_libro_recibido  VARCHAR2(50),
  estado_libro_recibido  VARCHAR2(50)
);
/

-- Tipo tabla
CREATE OR REPLACE TYPE historial_table_type_1 AS TABLE OF historial_row_type_1;
/

-- Función que devuelve la tabla
CREATE OR REPLACE FUNCTION historial_intercambios(p_usuario_id NUMBER)
  RETURN historial_table_type_1
IS
  v_result historial_table_type_1 := historial_table_type_1();
BEGIN
  FOR rec IN (
    SELECT 
      u.nombre AS nombre_usuario,
      i.fecha AS fecha_intercambio,
      d.tipoRol AS entregado_o_recibido,

      l1.titulo AS titulo_libro_ofrecido,
      lit1.nombre AS genero_libro_ofrecido,
      e1.estadoFisico AS estado_libro_ofrecido,

      l2.titulo AS titulo_libro_recibido,
      lit2.nombre AS genero_libro_recibido,
      e2.estadoFisico AS estado_libro_recibido

    FROM intercambio i
    JOIN usuario u ON i.usuario = u.idNumero
    JOIN detalleIntercambio d ON d.idIntercambio = i.idNumero
    JOIN ejemplar e1 ON e1.idEjemplar = d.idEjemplarOfrecido
    JOIN libro l1 ON e1.idLibro = l1.idNumero
    JOIN literatura lit1 ON l1.literatura = lit1.idNumero
    JOIN ejemplar e2 ON e2.idEjemplar = d.idEjemplarRecibido
    JOIN libro l2 ON e2.idLibro = l2.idNumero
    JOIN literatura lit2 ON l2.literatura = lit2.idNumero
    WHERE u.idNumero = p_usuario_id
  ) LOOP
    v_result.EXTEND;
    v_result(v_result.LAST) := historial_row_type_1(
      rec.nombre_usuario,
      rec.fecha_intercambio,
      rec.entregado_o_recibido,
      rec.titulo_libro_ofrecido,
      rec.genero_libro_ofrecido,
      rec.estado_libro_ofrecido,
      rec.titulo_libro_recibido,
      rec.genero_libro_recibido,
      rec.estado_libro_recibido
    );
  END LOOP;

  RETURN v_result;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20001, 'Error al obtener historial: ' || SQLERRM);
END;
/
