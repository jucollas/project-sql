CREATE OR REPLACE TRIGGER trg_validar_disponibilidad_ejemplar
BEFORE INSERT OR UPDATE ON detalleIntercambio
FOR EACH ROW
DECLARE
  v_count NUMBER;
BEGIN
  -- Verificar disponibilidad del ejemplar ofrecido
  SELECT COUNT(*) INTO v_count
  FROM ejemplar e
  WHERE e.idEjemplar = :NEW.idEjemplarOfrecido
    AND e.estadoBiblioteca = 'Disponible'
    AND e.aceptadoBiblioteca = 'S'
    AND NOT EXISTS (
      SELECT 1
      FROM libroLeido ll
      WHERE ll.idUsuario = e.usuario
        AND ll.idLibro = e.idLibro
    );

  IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'El ejemplar ofrecido no está disponible para intercambio.');
  END IF;

  -- Verificar disponibilidad del ejemplar recibido
  SELECT COUNT(*) INTO v_count
  FROM ejemplar e
  WHERE e.idEjemplar = :NEW.idEjemplarRecibido
    AND e.estadoBiblioteca = 'Disponible'
    AND e.aceptadoBiblioteca = 'S'
    AND NOT EXISTS (
      SELECT 1
      FROM libroLeido ll
      WHERE ll.idUsuario = e.usuario
        AND ll.idLibro = e.idLibro
    );

  IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'El ejemplar recibido no está disponible para intercambio.');
  END IF;
END;
/

/*Diploma Reconocimineto*/

CREATE OR REPLACE TRIGGER trg_diploma_reconocimiento
AFTER INSERT ON intercambio
FOR EACH ROW
WHEN (NEW.tipoIntercambio = 'Donación')
DECLARE
  v_total_donaciones NUMBER;
BEGIN
  -- Contar el total de donaciones que ha hecho el usuario
  SELECT COUNT(*)
  INTO v_total_donaciones
  FROM intercambio
  WHERE usuario = :NEW.usuario
    AND tipoIntercambio = 'Donación';

  -- Si la cantidad es múltiplo de 10, insertar reconocimiento
  IF MOD(v_total_donaciones, 10) = 0 THEN
    INSERT INTO reconocimiento (idUsuario)
    VALUES (:NEW.usuario);
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_bloquear_modificaciones_intercambio
BEFORE UPDATE ON intercambio
FOR EACH ROW
DECLARE
  v_msg VARCHAR2(200);
BEGIN
  -- Si el estado es 'Aceptado' (ya realizado), solo se puede modificar fechaFin si es Temporal
  IF :OLD.estado = 'Aceptado' THEN

    -- Si se modifica algún campo diferente de fechaFin
    IF (
        NVL(:NEW.tipoIntercambio, 'x')       != NVL(:OLD.tipoIntercambio, 'x') OR
        NVL(:NEW.estado, 'x')                != NVL(:OLD.estado, 'x') OR
        NVL(:NEW.usuario, -1)                != NVL(:OLD.usuario, -1) OR
        NVL(:NEW.fecha, TO_DATE('1900', 'YYYY')) != NVL(:OLD.fecha, TO_DATE('1900', 'YYYY')) OR
        NVL(:NEW.fechaIni, TO_DATE('1900', 'YYYY')) != NVL(:OLD.fechaIni, TO_DATE('1900', 'YYYY')) OR
        NVL(:NEW.cantDonada, -1)             != NVL(:OLD.cantDonada, -1) OR
        NVL(:NEW.puntuacionDonacion, -1)     != NVL(:OLD.puntuacionDonacion, -1)
    ) THEN
      v_msg := 'No se pueden modificar los datos de un intercambio aceptado.';
      RAISE_APPLICATION_ERROR(-20002, v_msg);
    END IF;

    -- Si cambia fechaFin pero el tipo no es Temporal, también está prohibido
    IF :NEW.fechaFin != :OLD.fechaFin AND :OLD.tipoIntercambio != 'Temporal' THEN
      v_msg := 'Solo se puede modificar la fecha de retorno en intercambios temporales.';
      RAISE_APPLICATION_ERROR(-20003, v_msg);
    END IF;

  END IF;
END;
/



