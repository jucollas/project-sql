CREATE OR REPLACE TYPE donacion_consecutiva_row_type AS OBJECT (
  nombre_usuario      VARCHAR2(100),
  fecha_donacion_1    DATE,
  libros_donados_1    NUMBER,
  fecha_donacion_2    DATE,
  libros_donados_2    NUMBER
);
/

CREATE OR REPLACE TYPE donacion_consecutiva_table_type AS TABLE OF donacion_consecutiva_row_type;
/
CREATE OR REPLACE FUNCTION donaciones_consecutivas
  RETURN donacion_consecutiva_table_type
IS
  v_result donacion_consecutiva_table_type := donacion_consecutiva_table_type();
BEGIN
  FOR rec IN (
    SELECT 
      u.nombre AS nombre_usuario,
      d1.fecha AS fecha_donacion_1,
      d1.cantDonada AS libros_donados_1,
      d2.fecha AS fecha_donacion_2,
      d2.cantDonada AS libros_donados_2
    FROM intercambio d1
    JOIN intercambio d2 ON d1.usuario = d2.usuario
                       AND d1.tipoIntercambio = 'Donación'
                       AND d2.tipoIntercambio = 'Donación'
                       AND d2.fecha > d1.fecha
    JOIN usuario u ON d1.usuario = u.idNumero
    WHERE NOT EXISTS (
      SELECT 1 FROM intercambio i
      WHERE i.usuario = d1.usuario
        AND i.fecha > d1.fecha
        AND i.fecha < d2.fecha
    )
    AND NOT EXISTS (
      SELECT 1 FROM intercambio d3
      WHERE d3.usuario = d1.usuario
        AND d3.tipoIntercambio = 'Donación'
        AND d3.fecha > d1.fecha
        AND d3.fecha < d2.fecha
    )
    AND NOT EXISTS (
      SELECT 1 FROM intercambio d4
      WHERE d4.usuario = d1.usuario
        AND d4.tipoIntercambio = 'Donación'
        AND d4.fecha = d2.fecha
        AND d4.idNumero < d2.idNumero -- para evitar duplicados si hay dos en la misma fecha
    )
  ) LOOP
    v_result.EXTEND;
    v_result(v_result.LAST) := donacion_consecutiva_row_type(
      rec.nombre_usuario,
      rec.fecha_donacion_1,
      rec.libros_donados_1,
      rec.fecha_donacion_2,
      rec.libros_donados_2
    );
  END LOOP;

  RETURN v_result;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20002, 'Error al obtener donaciones consecutivas: ' || SQLERRM);
END;
/

