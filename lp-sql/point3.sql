CREATE OR REPLACE TYPE usuario_activo_row_type AS OBJECT (
  anio              NUMBER,
  nombre_usuario    VARCHAR2(100),
  libros_entregados NUMBER
);
/

CREATE OR REPLACE TYPE usuario_activo_table_type AS TABLE OF usuario_activo_row_type;
/
CREATE OR REPLACE FUNCTION usuarios_mas_activos(p_n NUMBER, p_anio_inicio NUMBER)
  RETURN usuario_activo_table_type
IS
  v_result usuario_activo_table_type := usuario_activo_table_type();
BEGIN
  FOR rec IN (
    SELECT *
    FROM (
      SELECT
        EXTRACT(YEAR FROM i.fecha) AS anio,
        u.nombre AS nombre_usuario,
        SUM(
          CASE 
            WHEN i.tipoIntercambio = 'Donación' THEN NVL(i.cantDonada, 0)
            WHEN i.tipoIntercambio IN ('Permanente', 'Temporal') THEN (
              SELECT COUNT(*) FROM detalleIntercambio d WHERE d.idIntercambio = i.idNumero
            )
            ELSE 0
          END
        ) AS libros_entregados,
        ROW_NUMBER() OVER (PARTITION BY EXTRACT(YEAR FROM i.fecha) ORDER BY 
                           SUM(
                             CASE 
                               WHEN i.tipoIntercambio = 'Donación' THEN NVL(i.cantDonada, 0)
                               WHEN i.tipoIntercambio IN ('Permanente', 'Temporal') THEN (
                                 SELECT COUNT(*) FROM detalleIntercambio d WHERE d.idIntercambio = i.idNumero
                               )
                               ELSE 0
                             END
                           ) DESC) AS ranking
      FROM intercambio i
      JOIN usuario u ON u.idNumero = i.usuario
      WHERE EXTRACT(YEAR FROM i.fecha) >= p_anio_inicio
      GROUP BY EXTRACT(YEAR FROM i.fecha), u.nombre
    )
    WHERE ranking <= p_n
    ORDER BY anio, ranking
  ) LOOP
    v_result.EXTEND;
    v_result(v_result.LAST) := usuario_activo_row_type(
      rec.anio,
      rec.nombre_usuario,
      rec.libros_entregados
    );
  END LOOP;

  RETURN v_result;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20003, 'Error al calcular usuarios más activos: ' || SQLERRM);
END;
/
