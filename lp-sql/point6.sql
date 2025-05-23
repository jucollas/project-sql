/*
Trigger para evitar que un usuario haga un intercambio consigo mismo
En el sistema, un intercambio debe ser entre dos usuarios diferentes (quien ofrece un libro y quien recibe otro). Permitir que un usuario se intercambie libros a sí mismo no tiene sentido lógico y podría corromper la integridad del modelo.
*/
CREATE OR REPLACE TRIGGER trg_no_autointercambio
BEFORE INSERT OR UPDATE ON detalleIntercambio
FOR EACH ROW
DECLARE
  v_usuario_iniciador NUMBER;
  v_usuario_receptor NUMBER;
BEGIN
  -- Obtener el usuario que inició el intercambio
  SELECT usuario INTO v_usuario_iniciador
  FROM intercambio
  WHERE idNumero = :NEW.idIntercambio;

  -- Obtener el propietario original del libro recibido (como receptor)
  SELECT propietarioOriginal INTO v_usuario_receptor
  FROM ejemplar
  WHERE idEjemplar = :NEW.idEjemplarRecibido;

  IF v_usuario_iniciador = v_usuario_receptor THEN
    RAISE_APPLICATION_ERROR(-20010, 'Error: No se permite intercambio entre el mismo usuario.');
  END IF;
END;
/
