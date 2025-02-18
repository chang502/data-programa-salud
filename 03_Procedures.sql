SET GLOBAL log_bin_trust_function_creators = 1;

CREATE OR REPLACE FUNCTION programasalud.initcap(x varchar(50)) RETURNS varchar(50)
BEGIN
    RETURN concat(upper(substr(trim(X), 1,1)), lower(substr(trim(X), 2)));
END ;




CREATE OR REPLACE PROCEDURE programasalud.create_user (IN p_id_usuario VARCHAR(50), IN p_clave VARCHAR(64), IN p_id_persona INT, OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE v_temp INT;
    DECLARE v_activo INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;
    SET o_result = -1;
    SET o_mensaje = 'Ocurrió un error.';

    START TRANSACTION;

    SELECT count(activo), coalesce(activo,-1) INTO v_temp, v_activo from programasalud.usuario where id_usuario=lower(p_id_usuario);

    IF v_temp=1 THEN
        IF v_activo=1 THEN
            SET o_result = -1;
            SET o_mensaje = 'El usuario ya existe';
        ELSE
            UPDATE programasalud.usuario u
            SET
                u.activo = TRUE,
                u.clave = p_clave,
                u.id_persona = p_id_persona,
                u.cambiar_clave = FALSE
            WHERE
                u.id_usuario = LOWER(p_id_usuario);

            DELETE FROM programasalud.usuario_rol WHERE id_usuario = LOWER(p_id_usuario);

            INSERT INTO programasalud.usuario_rol (id_usuario, id_rol, activo)
            SELECT LOWER(p_id_usuario), id_rol, FALSE FROM programasalud.rol;

            SET o_result = 1;
            SET o_mensaje = 'Registro ingresado correctamente';
        END IF;
    ELSE
        INSERT INTO programasalud.usuario (id_usuario, clave, id_persona, activo, cambiar_clave)
        VALUES (LOWER(p_id_usuario), p_clave, p_id_persona, True, False);

        INSERT INTO programasalud.usuario_rol (id_usuario, id_rol, activo)
        SELECT LOWER(p_id_usuario), id_rol, FALSE FROM programasalud.rol;

        SET o_result = 1;
        SET o_mensaje = 'Registro ingresado correctamente';
    END IF;

    COMMIT;
END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.get_users()
BEGIN
    SELECT
        u.id_usuario, p.id_persona,
        p.nombre, p.apellido,
        CONCAT(p.nombre,' ',p.apellido) nombre_completo,
        p.email, p.sexo, if(p.sexo='M','Masculino',if(p.sexo='F','Femenino','')) nombre_sexo,
        DATE_FORMAT(p.fecha_nacimiento, '%d/%m/%Y') fecha_nacimiento,
        COALESCE(p.telefono,'') telefono, COALESCE(p.email,'') email,
           if(u.activo,'Activo','Inactivo') activo
    FROM usuario u
             JOIN persona p ON u.id_persona=p.id_persona
    WHERE u.activo
        and u.id_usuario!='ps_admin';
END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.get_user(IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
        u.id_usuario, p.id_persona,
        p.nombre, p.apellido,
        CONCAT(p.nombre,' ',p.apellido) nombre_completo,
        p.email, p.sexo, if(p.sexo='M','Masculino',if(p.sexo='F','Femenino','')) nombre_sexo,
        DATE_FORMAT(p.fecha_nacimiento, '%d/%m/%Y') fecha_nacimiento,
        COALESCE(p.telefono,'') telefono, COALESCE(p.email,'') email,
           if(u.activo,'Activo','Inactivo') activo
    FROM usuario u
             JOIN persona p ON u.id_persona=p.id_persona
    WHERE u.activo
        and u.id_usuario!='ps_admin'
        AND u.id_usuario=p_id_usuario;
END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.update_user(IN p_id_usuario VARCHAR(50), IN p_clave VARCHAR(64), IN p_id_persona INT, IN p_cambiar_clave VARCHAR(1), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE persona_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;


    SET persona_id = p_id_persona;


    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM usuario u
    WHERE u.id_usuario=p_id_usuario;



    if o_result>0 THEN




        IF p_clave = '' THEN
            UPDATE
                usuario u
            SET
                u.cambiar_clave = (p_cambiar_clave = '1')
            WHERE
                    u.id_usuario=p_id_usuario;
        ELSE
            UPDATE
                usuario u
            SET
                u.cambiar_clave = (p_cambiar_clave = '1'),
                u.clave = p_clave
            WHERE
                    u.id_usuario=p_id_usuario;
        END IF;


        SET o_mensaje = 'Registro actualizado correctamente';


    ELSE
        SET o_mensaje = 'Usuario no existe';
    END IF;




    COMMIT;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.get_user_roles(IN p_id_usuario VARCHAR(50))
BEGIN

    SELECT u.id_usuario_rol, r.nombre_rol, r.descripcion_rol, u.activo
    FROM usuario_rol u
             JOIN rol r ON u.id_rol=r.id_rol
    WHERE u.id_usuario=p_id_usuario
    ORDER BY u.id_usuario_rol
    ;
END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.update_user_role(IN p_id_usuario_rol VARCHAR(50), IN p_activo VARCHAR(50), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM usuario_rol u
    WHERE u.id_usuario_rol=p_id_usuario_rol;

    if o_result > 0 THEN

        UPDATE
            usuario_rol u
        SET
            u.activo=(p_activo='true')
        WHERE
                u.id_usuario_rol = p_id_usuario_rol;

        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;
    COMMIT;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.delete_user(IN p_id_usuario VARCHAR(50), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM usuario u
    WHERE u.id_usuario=p_id_usuario;


    if o_result>0 THEN
        UPDATE
            usuario u
        SET
            u.activo=false
        WHERE
                u.id_usuario = p_id_usuario;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Usuario no existe';
    END IF;


    COMMIT;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.create_doctor (IN p_id_usuario VARCHAR(50), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE v_activo INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;
    SET v_activo = -1;

    START TRANSACTION;

    SELECT count(1), coalesce(d.activo,-1) INTO v_temp, v_activo
    FROM doctor d
    JOIN usuario u on d.id_usuario = u.id_usuario
    WHERE u.id_usuario=p_id_usuario;


    IF v_temp = 0 THEN
        INSERT INTO programasalud.doctor (id_usuario, activo)
        VALUES ( p_id_usuario, TRUE);

        SET o_result = LAST_INSERT_ID();

        INSERT INTO programasalud.doctor_especialidad (id_doctor, id_especialidad, activo)
        SELECT o_result, id_especialidad, FALSE FROM programasalud.especialidad;


        INSERT INTO programasalud.clinica_doctor (id_clinica, id_doctor)
        SELECT id_clinica, o_result
        FROM clinica;

        SET o_mensaje = 'Registro ingresado correctamente';
    ELSE
        IF v_activo = 1 THEN
            SET o_result = -1;
            SET o_mensaje = 'Ya existe el registro';
        ELSE
            UPDATE doctor d
            SET d.activo = TRUE
            WHERE d.id_usuario=p_id_usuario;

            SELECT id_doctor INTO o_result
            FROM doctor d WHERE
            d.id_usuario=p_id_usuario;

            DELETE FROM doctor_especialidad WHERE id_doctor =o_result;

            INSERT INTO programasalud.clinica_doctor (id_clinica, id_doctor)
            SELECT id_clinica, o_result
            FROM clinica;

            SET o_result = 1;
            SET o_mensaje = 'Registro ingresado correctamente';
        END IF;
    END IF;

    COMMIT;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.get_doctores()
BEGIN

    SELECT
        d.id_doctor, u.id_usuario,
        CONCAT(p.nombre,' ',p.apellido) nombre_completo,
        DATE_FORMAT(p.fecha_nacimiento, '%d/%m/%Y') fecha_nacimiento, UPPER(p.sexo) sexo,
        p.telefono, p.email
    FROM doctor d
             JOIN usuario u ON d.id_usuario=u.id_usuario
             JOIN persona p ON u.id_persona=p.id_persona
    WHERE
        d.activo AND u.activo;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.get_doctor(IN p_id_doctor INT(20))
BEGIN

    SELECT
        d.id_usuario, d.id_doctor
    FROM
        doctor d
    WHERE
            d.activo = TRUE
      AND d.id_doctor= p_id_doctor ;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.update_doctor ( IN p_id_doctor INT, IN p_id_usuario VARCHAR(50), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;


    SELECT COUNT(1) INTO o_result
    FROM usuario u
    WHERE u.id_usuario= p_id_usuario
      AND u.activo=TRUE;

    SELECT count(*) INTO v_temp FROM doctor d  WHERE d.id_usuario=p_id_usuario AND d.activo;

    IF o_result > 0 THEN

        IF v_temp > 0 THEN
            UPDATE doctor d
            SET d.id_usuario=p_id_usuario,
                d.activo=TRUE
            WHERE
                    d.id_doctor=p_id_doctor;
        ELSE
            SET o_mensaje = 'Registro no existe';

        END IF;


        SET o_mensaje = 'Registro ingresado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;

    COMMIT;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.delete_doctor(IN p_id_doctor INT(20), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM doctor d
    WHERE d.id_doctor=p_id_doctor;


    if o_result>0 THEN
        UPDATE
            doctor d
        SET
            d.activo=false
        WHERE
                d.id_doctor=p_id_doctor;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;


    COMMIT;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.get_doctores_especialidades(IN p_id_doctor VARCHAR(50))
BEGIN

    SELECT id_doctor_especialidad, de.activo, e.especialidad
    FROM doctor_especialidad de
             JOIN doctor d ON de.id_doctor=d.id_doctor
             JOIN usuario u ON d.id_usuario=u.id_usuario
             JOIN especialidad e ON de.id_especialidad=e.id_especialidad
    WHERE d.activo AND u.activo AND e.activo
      AND de.id_doctor=p_id_doctor;
END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.update_doctor_especialidad(IN p_id_doctor_especialidad VARCHAR(50), IN p_activo VARCHAR(50), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM doctor_especialidad d
    WHERE d.id_doctor_especialidad=p_id_doctor_especialidad;

    if o_result > 0 THEN

        UPDATE
            doctor_especialidad u
        SET
            u.activo=(p_activo='true')
        WHERE
                u.id_doctor_especialidad=p_id_doctor_especialidad;

        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;
    COMMIT;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.get_tipos_medida()
BEGIN

    SELECT tdm.id_tipo_dato, tdm.tipo_dato
    FROM tipo_dato_medida tdm
    WHERE tdm.activo=TRUE
    ORDER BY tdm.id_tipo_dato;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.create_measurement (IN p_nombre VARCHAR(50), IN p_id_tipo_dato INT(20), IN p_unidad_medida VARCHAR(1000), IN p_valor_minimo VARCHAR(50),
                                                   IN p_valor_maximo VARCHAR(50), IN p_obligatorio VARCHAR(1), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El usuario ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;

    INSERT INTO programasalud.medida (nombre,
                                      id_tipo_dato, unidad_medida, valor_minimo,
                                      valor_maximo, obligatorio, activo)
    VALUES ( p_nombre, p_id_tipo_dato,
             p_unidad_medida, p_valor_minimo, p_valor_maximo, (p_obligatorio = '1'), TRUE);

    SET o_result = LAST_INSERT_ID();

    INSERT INTO programasalud.clinica_medida (id_clinica, id_medida)
    SELECT id_clinica, o_result
    FROM clinica;


    SET o_mensaje = 'Registro ingresado correctamente';

    COMMIT;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.get_measurements()
BEGIN

    SELECT
        m.id_medida,
        m.nombre nombre, tdm.tipo_dato,
        m.unidad_medida unidad_medida,
        m.valor_minimo, m.valor_maximo,
        if(m.obligatorio,'Sí','No') obligatorio
    FROM medida m
             JOIN tipo_dato_medida tdm ON m.id_tipo_dato=tdm.id_tipo_dato
    WHERE m.activo;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.get_measurement(IN p_id_medida INT)
BEGIN

    SELECT
        m.id_medida,
        m.nombre nombre, tdm.id_tipo_dato, tdm.tipo_dato,
        m.unidad_medida unidad_medida,
        m.valor_minimo, m.valor_maximo, m.obligatorio,
        if(m.obligatorio,'Sí','No') obligatorio_txt
    FROM medida m
             JOIN tipo_dato_medida tdm ON m.id_tipo_dato=tdm.id_tipo_dato
    WHERE m.activo
      AND m.id_medida=p_id_medida;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.update_measurement ( IN p_id_medida INT(20), IN p_nombre VARCHAR(50), IN p_id_tipo_dato INT(20), IN p_unidad_medida VARCHAR(1000), IN p_valor_minimo VARCHAR(50),
                                                    IN p_valor_maximo VARCHAR(50), IN p_obligatorio VARCHAR(1), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;


    SELECT COUNT(1) INTO o_result
    FROM medida m
    WHERE m.id_medida= p_id_medida
      AND m.activo;


    IF o_result > 0 THEN

        UPDATE medida m
        SET
            m.nombre=p_nombre,
            m.id_tipo_dato=p_id_tipo_dato,
            m.unidad_medida=p_unidad_medida,
            m.valor_minimo=p_valor_minimo,
            m.valor_maximo=p_valor_maximo,
            m.obligatorio=(p_obligatorio = '1')
        WHERE
                m.id_medida=p_id_medida;



        SET o_mensaje = 'Registro ingresado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;

    COMMIT;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.delete_measurement(IN p_id_medida INT(20), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM medida m
    WHERE m.id_medida=p_id_medida;


    if o_result>0 THEN
        UPDATE
            medida d
        SET
            d.activo=false
        WHERE
                d.id_medida=p_id_medida;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;


    COMMIT;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.create_clinic(IN p_nombre VARCHAR(50), IN p_ubicacion VARCHAR(50), IN p_descripcion VARCHAR(255), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El usuario ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;





    INSERT INTO programasalud.clinica (nombre, ubicacion,
                                       descripcion, activo)
    VALUES ( initcap(p_nombre), initcap(p_ubicacion), p_descripcion, TRUE);

    SET o_result = LAST_INSERT_ID();

    INSERT INTO programasalud.clinica_doctor (id_clinica, id_doctor)
    SELECT o_result, id_doctor
    FROM doctor;

    INSERT INTO programasalud.clinica_medida (id_clinica, id_medida)
    SELECT o_result, id_medida
    FROM medida;

    INSERT INTO programasalud.clinica_accion (id_clinica, id_accion)
    SELECT o_result, id_accion
    FROM accion;


    SET o_mensaje = 'Registro ingresado correctamente';

    COMMIT;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.get_clinics()
BEGIN

    SELECT
        c.id_clinica, c.nombre,
        c.ubicacion, c.descripcion
    FROM
        clinica c
    WHERE
        c.activo;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.get_clinic(IN p_id_clinica INT)
BEGIN

    SELECT
        c.id_clinica, c.nombre,
        c.ubicacion, c.descripcion
    FROM
        clinica c
    WHERE
        c.activo
      AND c.id_clinica=p_id_clinica;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.update_clinic (IN p_id_clinica INT, IN p_nombre VARCHAR(50), IN p_ubicacion VARCHAR(50), IN p_descripcion VARCHAR(255), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;


    SELECT COUNT(1) INTO o_result
    FROM clinica c
    WHERE c.id_clinica=p_id_clinica
      AND c.activo;


    IF o_result > 0 THEN

        UPDATE clinica c
        SET
            c.nombre=INITCAP(p_nombre),
            c.ubicacion=INITCAP(p_ubicacion),
            c.descripcion=p_descripcion,
            c.activo=TRUE
        WHERE
                c.id_clinica=p_id_clinica;



        SET o_mensaje = 'Registro ingresado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;

    COMMIT;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.delete_clinic(IN p_id_clinica INT(20), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(1) INTO o_result
    FROM clinica c
    WHERE c.id_clinica=p_id_clinica;


    if o_result>0 THEN
        UPDATE
            clinica c
        SET
            c.activo=false
        WHERE
                c.id_clinica=p_id_clinica;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;


    COMMIT;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.get_clinica_doctores(IN p_id_clinica VARCHAR(50))
BEGIN

    SELECT dc.id_clinica_doctor, CONCAT(p.nombre,' ',p.apellido) nombre_completo,
           dc.activo
    FROM clinica_doctor dc
             JOIN doctor d ON dc.id_doctor=d.id_doctor
             JOIN usuario u ON d.id_usuario=u.id_usuario
             JOIN persona p ON u.id_persona=p.id_persona
    WHERE d.activo AND u.activo AND dc.id_clinica=p_id_clinica;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.update_clinica_doctor(IN p_id_clinica_doctor VARCHAR(50), IN p_activo VARCHAR(50), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM clinica_doctor c
    WHERE c.id_clinica_doctor=p_id_clinica_doctor;

    if o_result > 0 THEN

        UPDATE
            clinica_doctor c
        SET
            c.activo=(p_activo='true')
        WHERE
                c.id_clinica_doctor=p_id_clinica_doctor;

        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;
    COMMIT;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.get_clinica_medidas(IN p_id_clinica VARCHAR(50))
BEGIN

    SELECT cm.id_clinica_medida, cm.activo, m.nombre, t.tipo_dato, m.valor_minimo, m.valor_maximo, if(m.obligatorio,'Sí','No') obligatorio
    FROM clinica_medida cm
             JOIN medida m ON cm.id_medida=m.id_medida
             JOIN tipo_dato_medida t ON m.id_tipo_dato=t.id_tipo_dato
    WHERE m.activo AND t.activo AND cm.id_clinica=p_id_clinica;

END;

-- ---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE programasalud.update_clinica_medida(IN p_id_clinica_medida VARCHAR(50), IN p_activo VARCHAR(50), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM clinica_medida c
    WHERE c.id_clinica_medida=p_id_clinica_medida;

    if o_result > 0 THEN

        UPDATE
            clinica_medida c
        SET
            c.activo=(p_activo='true')
        WHERE
                c.id_clinica_medida=p_id_clinica_medida;

        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;
    COMMIT;

END;












CREATE OR REPLACE PROCEDURE programasalud.do_password_reset(IN p_id_usuario VARCHAR(50), IN p_email VARCHAR(50), IN p_clave VARCHAR(64), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(1) INTO o_result
    FROM usuario u
             JOIN persona p ON u.id_persona = p.id_persona
    WHERE u.activo
      AND u.id_usuario=LOWER(p_id_usuario)
      AND p.email=LOWER(p_email);

    if o_result > 0 THEN

        UPDATE
            usuario u
        SET
            u.clave=p_clave,
            u.cambiar_clave=TRUE
        WHERE
                u.id_usuario=LOWER(p_id_usuario);

        SELECT
            TRIM(CONCAT(p.nombre,' ',p.apellido)) INTO o_mensaje
        FROM usuario u
                 JOIN persona p ON u.id_persona = p.id_persona
        WHERE u.activo
          AND u.id_usuario=LOWER(p_id_usuario)
          AND p.email=LOWER(p_email);

    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;
    COMMIT;



END;











CREATE OR REPLACE PROCEDURE programasalud.do_password_change(IN p_id_usuario VARCHAR(50), IN p_clave VARCHAR(64), IN p_nueva_clave VARCHAR(64), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(1) INTO o_result
    FROM usuario u
    WHERE u.id_usuario=LOWER(p_id_usuario)
      AND u.clave=p_clave
      AND u.activo;

    if o_result > 0 THEN

        UPDATE
            usuario u
        SET
            u.clave=p_nueva_clave,
            u.cambiar_clave=FALSE
        WHERE
                u.id_usuario=LOWER(p_id_usuario);

        SET o_mensaje = 'Registro actualizado correctamente';

    ELSE
        SET o_mensaje = 'Usuario o contraseña incorrectos';
    END IF;
    COMMIT;



END;























CREATE OR REPLACE PROCEDURE programasalud.get_semesters()
BEGIN

    SELECT DISTINCT anio, semestre FROM (
                                            select YEAR(DATE_ADD(NOW(),INTERVAL 6 MONTH)) ANIO, CONCAT(IF(MONTH(DATE_ADD(NOW(),INTERVAL 6 MONTH))<7,1,2),'S',YEAR(DATE_ADD(NOW(),INTERVAL 6 MONTH))) AS semestre
                                            UNION ALL
                                            select YEAR(NOW()), CONCAT(IF(MONTH(NOW())<7,1,2),'S',YEAR(NOW()))
                                            UNION ALL
                                            SELECT DISTINCT SUBSTRING(d.semestre,3), d.semestre FROM disciplina d) as tmp
    ORDER BY anio desc, semestre DESC;

END;
































CREATE OR REPLACE PROCEDURE programasalud.delete_discipline(IN p_id_disciplina INT(20), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM disciplina d
    WHERE d.id_disciplina=p_id_disciplina;


    if o_result>0 THEN
        UPDATE
            disciplina d
        SET
            d.activo=false
        WHERE
                d.id_disciplina=p_id_disciplina;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;


    COMMIT;

END;















CREATE OR REPLACE PROCEDURE programasalud.create_drinkfountain (IN p_nombre VARCHAR(100), IN p_ubicacion VARCHAR(250), IN p_fecha_mantenimiento VARCHAR(10),
                                                     IN p_estado VARCHAR(200), IN p_observaciones VARCHAR(1000), IN p_id_usuario VARCHAR(50), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET o_result = -1;

    START TRANSACTION;

    INSERT INTO programasalud.bebedero (nombre,
                                        ubicacion, fecha_mantenimiento, observaciones,
                                        estado, id_usuario)
    VALUES ( INITCAP(p_nombre), INITCAP(p_ubicacion),
             str_to_date(p_fecha_mantenimiento,'%d/%m/%Y'), p_observaciones, INITCAP(p_estado), p_id_usuario);

    SET o_result = LAST_INSERT_ID();

    SET o_mensaje = 'Registro ingresado correctamente';

    COMMIT;

END;












CREATE OR REPLACE PROCEDURE programasalud.get_drinkfountains( IN p_id_usuario VARCHAR(50))
BEGIN

    SELECT
        b.id_bebedero,
        b.nombre,
        b.ubicacion,
        DATE_FORMAT(b.fecha_mantenimiento, '%d/%m/%Y') fecha_mantenimiento,
        b.estado,
        b.observaciones,
        DATE_FORMAT(b.creado, '%d/%m/%Y %H:%i:%s') creado
    FROM
        bebedero b
    WHERE
        b.activo and b.id_usuario = p_id_usuario;

END;






CREATE OR REPLACE PROCEDURE programasalud.get_drinkfountain(IN p_id_bebedero INT)
BEGIN

    SELECT
        b.id_bebedero,
        b.nombre,
        b.ubicacion,
        DATE_FORMAT(b.fecha_mantenimiento, '%d/%m/%Y') fecha_mantenimiento,
        b.estado,
        b.observaciones
    FROM
        bebedero b
    WHERE
        b.activo
      AND b.id_bebedero=p_id_bebedero;

END;






CREATE OR REPLACE PROCEDURE programasalud.update_drinkfountain ( IN p_id_bebedero INT, IN p_nombre VARCHAR(100), IN p_ubicacion VARCHAR(250), IN p_fecha_mantenimiento VARCHAR(10),
                                                      IN p_estado VARCHAR(200), IN p_observaciones VARCHAR(1000),
                                                      OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;


    SELECT COUNT(1) INTO o_result
    FROM bebedero b
    WHERE b.id_bebedero=p_id_bebedero
      AND b.activo;


    IF o_result > 0 THEN

        UPDATE bebedero b
        SET
            b.nombre = INITCAP(trim(p_nombre)),
            b.ubicacion = INITCAP(trim(p_ubicacion)),
            b.fecha_mantenimiento = str_to_date(p_fecha_mantenimiento, '%d/%m/%Y'),
            b.estado = INITCAP(TRIM(p_estado)),
            b.observaciones = p_observaciones,
            b.actualizado=now()
        WHERE
                b.id_bebedero = p_id_bebedero;



        SET o_mensaje = 'Registro ingresado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;

    COMMIT;

END;









CREATE OR REPLACE PROCEDURE programasalud.delete_drinkfountain(IN p_id_bebedero INT, OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM bebedero b
    WHERE b.id_bebedero = p_id_bebedero;


    if o_result>0 THEN
        UPDATE
            bebedero b
        SET
            b.activo=false,
            b.actualizado=now()
        WHERE
                b.id_bebedero = p_id_bebedero;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;


    COMMIT;

END;














CREATE OR REPLACE PROCEDURE programasalud.get_measurement_units()
BEGIN

    SELECT
           u.id_unidad_medida,
           u.nombre,
           u.nombre_corto
    FROM programasalud.unidad_medida u
    WHERE u.activo;

END;


















CREATE OR REPLACE PROCEDURE programasalud.create_playground (IN p_nombre VARCHAR(100), IN p_id_lugar_convivencia INT, IN p_ubicacion VARCHAR(250), IN p_cantidad DECIMAL(10,4), IN p_id_unidad_medida INT,
                                                  IN p_anio INT, IN p_costo DECIMAL(10,4), IN p_estado VARCHAR(200), IN p_id_persona INT, IN p_observaciones VARCHAR(2000), IN p_id_usuario VARCHAR(50),
                                                  OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET o_result = -1;

    START TRANSACTION;

    INSERT INTO programasalud.espacio_convivencia (nombre,id_lugar_convivencia, ubicacion,cantidad,id_unidad_medida,anio,costo,estado, id_persona,observaciones,id_usuario)
    VALUES ( p_nombre, p_id_lugar_convivencia, p_ubicacion, p_cantidad,
             p_id_unidad_medida, p_anio, p_costo, p_estado, p_id_persona, p_observaciones,p_id_usuario);

    SET o_result = LAST_INSERT_ID();

    SET o_mensaje = 'Registro ingresado correctamente';

    COMMIT;

END;












CREATE OR REPLACE PROCEDURE programasalud.get_playgrounds(IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
        b.id_espacio_convivencia,
        lc.nombre lugar_convivencia,
        cc.nombre categoria_convivencia,
        b.nombre,
        b.ubicacion,
        b.cantidad,
        um.id_unidad_medida,
        um.nombre nombre_medida,
        um.nombre_corto,
        CONCAT(b.cantidad,' ', um.nombre_corto) cantidad_medida,
        b.anio,
        b.costo,
        b.estado,
        b.id_persona,
        CONCAT(p.nombre,' ',p.apellido) persona,
        b.observaciones
    FROM
        espacio_convivencia b
    JOIN unidad_medida um on b.id_unidad_medida = um.id_unidad_medida AND um.activo
    JOIN lugar_convivencia lc on b.id_lugar_convivencia = lc.id_lugar_convivencia
    JOIN categoria_convivencia cc on lc.id_categoria_convivencia = cc.id_categoria_convivencia
    JOIN persona p on b.id_persona = p.id_persona
    WHERE
        b.activo and b.id_usuario=p_id_usuario;

END;






CREATE OR REPLACE PROCEDURE programasalud.get_playground(IN p_id_espacio_convivencia INT)
BEGIN

    SELECT
        b.id_espacio_convivencia,
        lc.id_lugar_convivencia,
        lc.nombre lugar_convivencia,
        cc.id_categoria_convivencia,
        cc.nombre categoria_convivencia,
        b.nombre,
        b.ubicacion,
        b.cantidad,
        um.id_unidad_medida,
        um.nombre nombre_medida,
        um.nombre_corto,
        b.anio,
        b.costo,
        b.estado,
        b.id_persona,
        CONCAT(p.nombre,' ',p.apellido) persona,
        b.observaciones
    FROM
        espacio_convivencia b
    JOIN unidad_medida um on b.id_unidad_medida = um.id_unidad_medida AND um.activo
    JOIN lugar_convivencia lc on b.id_lugar_convivencia = lc.id_lugar_convivencia
    JOIN categoria_convivencia cc on lc.id_categoria_convivencia = cc.id_categoria_convivencia
    JOIN persona p on b.id_persona = p.id_persona
    WHERE
        b.activo
      AND b.id_espacio_convivencia=p_id_espacio_convivencia;

END;






CREATE OR REPLACE PROCEDURE programasalud.update_playground ( IN p_id_espacio_convivencia INT, IN p_nombre VARCHAR(100), IN p_id_lugar_convivencia INT, IN p_ubicacion VARCHAR(250), IN p_cantidad DECIMAL(10,4),
                                                   IN p_id_unidad_medida INT, IN p_anio INT, IN p_costo DECIMAL(10,4), IN p_estado VARCHAR(200), IN p_id_persona INT, IN p_observaciones VARCHAR(2000),
                                                   OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;


    SELECT COUNT(1) INTO o_result
    FROM espacio_convivencia b
    WHERE b.id_espacio_convivencia=p_id_espacio_convivencia
      AND b.activo;


    IF o_result > 0 THEN

        UPDATE espacio_convivencia b
        SET
            b.nombre = p_nombre,
            b.ubicacion = p_ubicacion,
            b.id_lugar_convivencia = p_id_lugar_convivencia,
            b.cantidad = p_cantidad,
            b.id_unidad_medida = p_id_unidad_medida,
            b.anio = p_anio,
            b.costo = p_costo,
            b.estado = p_estado,
            b.id_persona = p_id_persona,
            b.observaciones = p_observaciones,
            b.actualizado = now()
        WHERE
                b.id_espacio_convivencia = p_id_espacio_convivencia;



        SET o_mensaje = 'Registro ingresado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;

    COMMIT;

END;









CREATE OR REPLACE PROCEDURE programasalud.delete_playground(IN p_id_espacio_convivencia INT, OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM espacio_convivencia b
    WHERE b.id_espacio_convivencia = p_id_espacio_convivencia;


    if o_result>0 THEN
        UPDATE
            espacio_convivencia b
        SET
            b.activo=false,
            b.actualizado = now()
        WHERE
                b.id_espacio_convivencia = p_id_espacio_convivencia;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;


    COMMIT;

END;















CREATE OR REPLACE PROCEDURE programasalud.get_disability_types()
BEGIN

    SELECT
        t.id_tipo_discapacidad,
        t.nombre
    FROM
        tipo_discapacidad t
    WHERE
        t.activo;
END;




















-- scripts para deportes
drop procedure if exists inscripcion_deportes;
/*
CREATE OR REPLACE PROCEDURE programasalud.inscripcion_deportes (IN p_id_tipo_documento VARCHAR(255), IN p_descripcion VARCHAR(255), IN p_especialidad VARCHAR(255),
                                                     IN p_estado VARCHAR(255), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET o_result = -1;

    START TRANSACTION;

    INSERT INTO programasalud.seleccion (nombre,
                                         descripcion, especialidad,
                                         estado, activo)
    VALUES ( INITCAP(p_nombre), INITCAP(p_descripcion),
             INITCAP(p_especialidad), INITCAP(p_estado), TRUE);

    SET o_result = LAST_INSERT_ID();

    SET o_mensaje = 'Registro ingresado correctamente';

    COMMIT;

END;

*/















CREATE OR REPLACE PROCEDURE programasalud.get_students(IN p_semestre VARCHAR(6), IN p_id_disciplina INT)
BEGIN

    select ad.id_asignacion_deportes, p.id_persona, d.id_disciplina, concat(p.nombre,' ',p.apellido) nombre_completo, p.cui, coalesce(p.carnet,'') carnet, coalesce(p.nov,'') nov, d.nombre,
ad.semestre, concat(if(substr(d.semestre,1,1)='1','Primer semestre, ','Segundo semestre, '),substr(d.semestre,3,4)) sem, d.semestre,
       SUBSTR(concat(if(flg_lunes=1,'Lun, ',''),if(flg_martes=1,'Mar, ',''),if(flg_miercoles=1,'Mié, ',''),if(flg_jueves=1,'Jue, ',''),if(flg_viernes=1,'Vie, ',''),if(flg_sabado=1,'Sáb, ','')) , 1 ,
              ((if(flg_lunes=1,1,0)+if(flg_martes=1,1,0)+if(flg_miercoles=1,1,0)+if(flg_jueves=1,1,0)+if(flg_viernes=1,1,0)+if(flg_sabado=1,1,0))*5-2)) dias,
           concat(d.hora_inicio, ' - ', d.hora_fin) horas,
           d.hora_inicio, d.hora_fin
from asignacion_deportes ad
join persona p on ad.id_persona = p.id_persona
join disciplina d on ad.id_disciplina = d.id_disciplina and d.activo
where ad.activo
and (p_semestre IS NULL OR d.semestre=p_semestre)
and (p_id_disciplina IS NULL OR d.id_disciplina = p_id_disciplina);
END;








CREATE OR REPLACE PROCEDURE programasalud.get_student_disciplines(IN p_semestre VARCHAR(6))
BEGIN

select id_disciplina, nombre from disciplina
    where activo and (p_semestre IS NULL OR semestre=p_semestre);
END;













CREATE OR REPLACE PROCEDURE programasalud.delete_student(IN p_id_asignacion_deportes INT, OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(1) INTO o_result
    FROM asignacion_deportes e
    WHERE e.id_asignacion_deportes=p_id_asignacion_deportes
      AND e.activo;



    if o_result>0 THEN
        UPDATE
            asignacion_deportes e
        SET
            e.activo=false
        WHERE
                e.id_asignacion_deportes=p_id_asignacion_deportes;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;


    COMMIT;

END;



























CREATE OR REPLACE PROCEDURE programasalud.create_team (IN p_nombre VARCHAR(255), IN p_descripcion VARCHAR(255), IN p_especialidad VARCHAR(255),
                                            IN p_estado VARCHAR(255), IN p_id_usuario VARCHAR(50), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET o_result = -1;

    START TRANSACTION;

    INSERT INTO programasalud.seleccion (nombre,
                                         descripcion, especialidad,
                                         estado, id_usuario)
    VALUES ( INITCAP(p_nombre), INITCAP(p_descripcion),
             INITCAP(p_especialidad), INITCAP(p_estado), p_id_usuario);

    SET o_result = LAST_INSERT_ID();

    SET o_mensaje = 'Registro ingresado correctamente';

    COMMIT;

END;












CREATE OR REPLACE PROCEDURE programasalud.get_teams(IN p_id_usuario VARCHAR(50))
BEGIN

    SELECT
        b.id_seleccion,
        b.nombre,
        b.descripcion,
        b.especialidad,
        b.estado,
        DATE_FORMAT(b.creado, '%d/%m/%Y %H:%i:%s') creado
    FROM
        seleccion b
    WHERE
        b.activo and b.id_usuario=p_id_usuario;

END;






CREATE OR REPLACE PROCEDURE programasalud.get_team(IN p_id_seleccion INT)
BEGIN

    SELECT
        b.id_seleccion,
        b.nombre,
        b.descripcion,
        b.especialidad,
        b.estado
    FROM
        seleccion b
    WHERE
        b.activo
      AND b.id_seleccion=p_id_seleccion;

END;






CREATE OR REPLACE PROCEDURE programasalud.update_team ( IN p_id_seleccion INT, IN p_nombre VARCHAR(255), IN p_descripcion VARCHAR(255), IN p_especialidad VARCHAR(255),
                                             IN p_estado VARCHAR(255), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;


    SELECT COUNT(1) INTO o_result
    FROM seleccion b
    WHERE b.id_seleccion=p_id_seleccion
      AND b.activo;


    IF o_result > 0 THEN

        UPDATE seleccion b
        SET
            b.nombre = INITCAP(trim(p_nombre)),
            b.descripcion = INITCAP(trim(p_descripcion)),
            b.especialidad = INITCAP(TRIM(p_especialidad)),
            b.estado = INITCAP(TRIM(p_estado)),
            b.actualizado = now()
        WHERE
                b.id_seleccion = p_id_seleccion;



        SET o_mensaje = 'Registro ingresado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;

    COMMIT;

END;









CREATE OR REPLACE PROCEDURE programasalud.delete_team(IN p_id_seleccion INT, OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM seleccion b
    WHERE b.id_seleccion = p_id_seleccion;


    if o_result>0 THEN
        UPDATE
            seleccion b
        SET
            b.activo=false,
            b.actualizado = now()
        WHERE
                b.id_seleccion = p_id_seleccion;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;


    COMMIT;

END;
















/*
CREATE OR REPLACE PROCEDURE programasalud.get_person_types()
BEGIN

    SELECT
        t.id_tipo_persona,
        t.nombre
    FROM
        tipo_persona t
    WHERE
        t.activo;
END;*/








CREATE OR REPLACE PROCEDURE programasalud.create_championship (IN p_id_seleccion INT, IN p_nombre VARCHAR(255), IN p_fecha VARCHAR(10), IN p_victorioso VARCHAR(1),
                                                    IN p_observaciones VARCHAR(255), IN p_id_usuario VARCHAR(50), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET o_result = -1;

    START TRANSACTION;

    INSERT INTO programasalud.campeonato (id_seleccion,
                                          nombre, fecha, victorioso, observaciones,
                                          id_usuario)
    VALUES ( p_id_seleccion, INITCAP(p_nombre), str_to_date(p_fecha,'%d/%m/%Y'),
             IF (p_victorioso='1' , TRUE ,FALSE), p_observaciones, p_id_usuario);

    SET o_result = LAST_INSERT_ID();

    SET o_mensaje = 'Registro ingresado correctamente';

    COMMIT;

END;












CREATE OR REPLACE PROCEDURE programasalud.get_championships(IN p_id_usuario VARCHAR(50))
BEGIN

    SELECT
        c.id_campeonato,
        c.id_seleccion,
        s.nombre nombre_seleccion,
        c.nombre,
        DATE_FORMAT(c.fecha, '%d/%m/%Y') fecha,
        c.victorioso,
        if(c.victorioso,'Sí','No') victorioso_text,
        c.observaciones
    FROM
        campeonato c
            JOIN seleccion s ON c.id_seleccion = s.id_seleccion
    WHERE
        c.activo AND c.id_usuario=p_id_usuario;

END;






CREATE OR REPLACE PROCEDURE programasalud.get_championship(IN p_id_campeonato INT)
BEGIN

    SELECT
        c.id_campeonato,
        c.id_seleccion,
        s.nombre nombre_seleccion,
        c.nombre,
        DATE_FORMAT(c.fecha, '%d/%m/%Y') fecha,
        if(c.victorioso,1,0) victorioso,
        if(c.victorioso,'Sí','No') victorioso_text,
        c.observaciones
    FROM
        campeonato c
            JOIN seleccion s ON c.id_seleccion = s.id_seleccion
    WHERE
        c.activo
      AND c.id_campeonato=p_id_campeonato;

END;






CREATE OR REPLACE PROCEDURE programasalud.update_championship ( IN p_id_campeonato INT, IN p_id_seleccion INT, IN p_nombre VARCHAR(255), IN p_fecha VARCHAR(10), IN p_victorioso VARCHAR(1),
                                                     IN p_observaciones VARCHAR(255), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;


    SELECT COUNT(1) INTO o_result
    FROM campeonato c
    WHERE c.id_campeonato=p_id_campeonato
      AND c.activo;


    IF o_result > 0 THEN

        UPDATE campeonato c
        SET
            c.id_seleccion = p_id_seleccion,
            c.nombre = INITCAP(p_nombre),
            c.fecha = str_to_date(p_fecha,'%d/%m/%Y'),
            c.victorioso = if(p_victorioso='1',TRUE,FALSE),
            c.observaciones = INITCAP(p_observaciones),
            c.activo = TRUE,
            c.actualizado = now()
        WHERE
                c.id_campeonato=p_id_campeonato;



        SET o_mensaje = 'Registro ingresado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;

    COMMIT;

END;









CREATE OR REPLACE PROCEDURE programasalud.delete_championship(IN p_id_campeonato INT, OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM campeonato c
    WHERE c.id_campeonato = p_id_campeonato;


    if o_result>0 THEN
        UPDATE
            campeonato c
        SET
            c.activo=false, c.actualizado = now()
        WHERE
                c.id_campeonato = p_id_campeonato;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;


    COMMIT;

END;


/*-------------------------------*/







CREATE OR REPLACE PROCEDURE programasalud.create_discipline (IN p_semestre VARCHAR(6), IN p_nombre VARCHAR(100), IN p_limite INT,
                                        IN p_flg_lunes INT, IN p_flg_martes INT, IN p_flg_miercoles INT, IN p_flg_jueves INT, IN p_flg_viernes INT, IN p_flg_sabado INT,
                                        IN p_hora_inicio VARCHAR(5), IN p_hora_fin VARCHAR(5), IN p_id_persona INT,
                                        OUT o_result INT, OUT o_mensaje VARCHAR(500))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;


    INSERT INTO programasalud.disciplina (semestre, nombre, limite, flg_lunes, flg_martes, flg_miercoles,
                                          flg_jueves, flg_viernes, flg_sabado, hora_inicio, hora_fin,
                                          id_persona)
    VALUES ( p_semestre, UPPER(p_nombre), p_limite, (p_flg_lunes = 1), (p_flg_martes = 1), (p_flg_miercoles = 1),
            (p_flg_jueves = 1), (p_flg_viernes = 1), (p_flg_sabado = 1), p_hora_inicio, p_hora_fin, p_id_persona);

    SET o_result = LAST_INSERT_ID();

    SET o_mensaje = 'Registro ingresado correctamente';

    COMMIT;

END;





CREATE OR REPLACE PROCEDURE programasalud.get_disciplines()
BEGIN

    SELECT
    d.id_disciplina, d.nombre, d.limite, count(ad.id_disciplina) asignados, d.limite-count(ad.id_disciplina) disponible,
           concat(d.limite,' / ',count(ad.id_disciplina),' / ',(d.limite-count(ad.id_disciplina)),'') resumen_cantidad,
    concat(if(substr(d.semestre,1,1)='1','Primer semestre, ','Segundo semestre, '),substr(d.semestre,3,4)) sem, d.semestre,

    SUBSTR(concat(if(flg_lunes=1,'Lun, ',''),if(flg_martes=1,'Mar, ',''),if(flg_miercoles=1,'Mié, ',''),if(flg_jueves=1,'Jue, ',''),if(flg_viernes=1,'Vie, ',''),if(flg_sabado=1,'Sáb, ','')) , 1 ,
              ((if(flg_lunes=1,1,0)+if(flg_martes=1,1,0)+if(flg_miercoles=1,1,0)+if(flg_jueves=1,1,0)+if(flg_viernes=1,1,0)+if(flg_sabado=1,1,0))*5-2)) dias,
           concat(d.hora_inicio, ' - ', d.hora_fin) horas,
           d.hora_inicio, d.hora_fin,
           CONCAT(p.nombre,' ',p.apellido) nombre_completo
    FROM
    disciplina d
    JOIN persona p on d.id_persona = p.id_persona
    left join asignacion_deportes ad on d.id_disciplina = ad.id_disciplina AND ad.activo
    where d.activo
    group by d.id_disciplina;

END;


CREATE OR REPLACE PROCEDURE programasalud.get_discipline(IN p_id_disciplina INT)
BEGIN

    SELECT
        d.id_disciplina, d.semestre, d.nombre, d.limite, d.flg_lunes, d.flg_martes, d.flg_miercoles,
        d.flg_jueves, d.flg_viernes, d.flg_sabado, d.hora_inicio,d. hora_fin,
        d.id_persona, concat(p.nombre,' ',p.apellido) persona_encargada
    FROM
        disciplina d
        JOIN persona p on d.id_persona = p.id_persona
    where d.activo
      AND d.id_disciplina=p_id_disciplina;

END;






CREATE OR REPLACE PROCEDURE programasalud.update_discipline ( IN p_id_disciplina INT, IN p_semestre VARCHAR(6), IN p_nombre VARCHAR(100), IN p_limite INT,
                                        IN p_flg_lunes INT, IN p_flg_martes INT, IN p_flg_miercoles INT, IN p_flg_jueves INT, IN p_flg_viernes INT, IN p_flg_sabado INT,
                                        IN p_hora_inicio VARCHAR(5), IN p_hora_fin VARCHAR(5), IN p_id_persona INT,
                                        OUT o_result INT, OUT o_mensaje VARCHAR(500))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;


    select count(1) into v_temp
    from programasalud.disciplina d
    where d.activo and upper(trim(d.nombre))=upper(trim(p_nombre))
    and d.semestre = p_semestre;

    IF v_temp> 0 then
        set o_result = -1;
        set o_mensaje = 'Ya existe una disciplina con ese nombre';
    else
        UPDATE programasalud.disciplina
        SET
            semestre=p_semestre,
            nombre=UPPER(p_nombre),
            limite=p_limite,
            flg_lunes=(p_flg_lunes = 1),
            flg_martes=(p_flg_martes = 1),
            flg_miercoles=(p_flg_miercoles = 1),
            flg_jueves=(p_flg_jueves = 1),
            flg_viernes=(p_flg_viernes = 1),
            flg_sabado=(p_flg_sabado = 1),
            hora_inicio=p_hora_inicio,
            hora_fin=p_hora_fin,
            id_persona=p_id_persona
        WHERE
            id_disciplina=p_id_disciplina;

            SET o_result = 1;
            SET o_mensaje = 'Registro actualizado correctamente';
        end if;


    COMMIT;

END;


















CREATE OR REPLACE PROCEDURE programasalud.get_active_disciplines ()
BEGIN
        SELECT d.id_disciplina, d.nombre, count(ed.id_disciplina), d.limite, d.semestre FROM disciplina d
        left join asignacion_deportes ed on d.id_disciplina = ed.id_disciplina
        WHERE d.activo and coalesce(ed.activo,true) and  d.semestre=CONCAT(IF(MONTH(NOW())<7,1,2),'S',YEAR(NOW()))
        group by d.id_disciplina, d.nombre, d.limite, d.semestre having count(ed.id_disciplina)<d.limite
        ORDER BY d.nombre;
END;







CREATE OR REPLACE PROCEDURE programasalud.do_login(IN p_id_usuario VARCHAR(50), IN p_clave VARCHAR(64))
BEGIN
    SELECT u.id_usuario,
           nombre,
           apellido,
           CONCAT(nombre,' ',apellido) nombre_completo,
           COALESCE(p.email,'') email, COALESCE(p.telefono,'') telefono,
           COALESCE((SELECT TRUE FROM usuario_rol ur1 WHERE ur1.id_usuario=u.id_usuario AND ur1.activo AND ur1.id_rol=8701),FALSE) hasClinica,
           COALESCE((SELECT TRUE FROM usuario_rol ur1 WHERE ur1.id_usuario=u.id_usuario AND ur1.activo AND ur1.id_rol=8702),FALSE) hasDeportes,
           COALESCE((SELECT TRUE FROM usuario_rol ur1 WHERE ur1.id_usuario=u.id_usuario AND ur1.activo AND ur1.id_rol=8703),FALSE) hasProgramaSalud,
           COALESCE((SELECT TRUE FROM usuario_rol ur1 WHERE ur1.id_usuario=u.id_usuario AND ur1.activo AND ur1.id_rol=8705),FALSE) hasPlayground,
           COALESCE((SELECT TRUE FROM usuario_rol ur1 WHERE ur1.id_usuario=u.id_usuario AND ur1.activo AND ur1.id_rol=8706),FALSE) hasIngresoDatos,
           COALESCE((SELECT TRUE FROM usuario_rol ur1 WHERE ur1.id_usuario=u.id_usuario AND ur1.activo AND ur1.id_rol=8704),FALSE) isAdmin,
           COALESCE(u.cambiar_clave,FALSE) as cambiar_clave
    FROM usuario u
             JOIN persona p ON u.id_persona = p.id_persona
    WHERE u.activo
      AND u.id_usuario=p_id_usuario
      AND u.clave=p_clave;
END;








CREATE OR REPLACE FUNCTION programasalud.create_or_update_student_from_cc (p_nombre VARCHAR(500), p_apellido VARCHAR(500), p_fecha_nacimiento VARCHAR(10),
                                            p_sexo VARCHAR(50), p_email VARCHAR(50), p_telefono VARCHAR(8),
                                            p_cui VARCHAR(13), p_nov VARCHAR(10), p_carnet VARCHAR(9), p_carrera VARCHAR(2))
                                            RETURNS INT
BEGIN
    DECLARE v_temp INT;


    SET v_temp = -1;


        select case when count(id_persona) =0 then -1 else id_persona end into v_temp
        from persona
        where (cui=p_cui and cui is not null)
        or (nov=p_nov and nov is not null)
        /*or (regpersonal=p_regpersonal and regpersonal is not null)*/
        or (carnet = p_carnet and carnet is not null);

    IF v_temp = -1 THEN
        INSERT INTO programasalud.persona (nombre, apellido,
                                       fecha_nacimiento, sexo, email, telefono,
                                           cui, nov, carnet, carrera, source)
        VALUES ( UPPER(TRIM(p_nombre)), UPPER(TRIM(p_apellido)),
                 str_to_date(TRIM(p_fecha_nacimiento),'%Y-%m-%d'), UPPER(TRIM(p_sexo)), LOWER(TRIM(p_email)), p_telefono,
                if(p_cui is null or p_cui='',null,p_cui),
                if(p_nov is null or p_nov='',null,p_nov),
                if(p_carnet is null or p_carnet='',null,p_carnet), p_carrera, 'CC_STUDENT');

        SET v_temp = LAST_INSERT_ID();
        RETURN v_temp;
    ELSE
        UPDATE programasalud.persona
        SET
            nombre = UPPER(TRIM(p_nombre)),
            apellido= UPPER(TRIM(p_apellido)),
            fecha_nacimiento = str_to_date(TRIM(p_fecha_nacimiento),'%Y-%m-%d'),
            sexo = UPPER(TRIM(p_sexo)),
            email = LOWER(TRIM(p_email)),
            telefono = if(p_telefono is null or p_telefono='',telefono,p_telefono),
            cui = if(p_cui is null or p_cui='',null,p_cui),
            nov = if(p_nov is null or p_nov='',null,p_nov),
            carnet = if(p_carnet is null or p_carnet='',null,p_carnet),
            carrera = p_carrera,
            updated = now()
        WHERE id_persona = v_temp;
        RETURN v_temp;
    END IF;

    RETURN v_temp;

END;


CREATE OR REPLACE PROCEDURE programasalud.get_student_from_cc (IN p_nombre VARCHAR(500), IN p_apellido VARCHAR(500), IN p_fecha_nacimiento VARCHAR(10),
                                            IN p_sexo VARCHAR(50), IN p_email VARCHAR(50),
                                            IN p_cui VARCHAR(13), IN p_nov VARCHAR(10), IN p_carnet VARCHAR(9), IN p_carrera VARCHAR(2))
BEGIN
    DECLARE v_temp INT;

    SET v_temp = create_or_update_student_from_cc(p_nombre,p_apellido, p_fecha_nacimiento, p_sexo,p_email,null,p_cui,p_nov, p_carnet, p_carrera);

        SELECT p.id_persona, /*p.nombre, p.telefono, p.apellido, */CONCAT(nombre,' ',apellido) nombre_completo,
           DATE_FORMAT(p.fecha_nacimiento, '%d/%m/%Y') fecha_nacimiento, /*p.sexo, */
               p.email/*,
           p.cui, p.nov, p.carnet, p.carrera carrera_depto*/
    FROM programasalud.persona p
    where p.id_persona=v_temp;


END;


CREATE OR REPLACE PROCEDURE programasalud.search_person_by_carnet (IN p_carnet VARCHAR(13))
BEGIN

    SELECT p.id_persona,/* p.nombre, p.telefono, p.apellido,*/ CONCAT(nombre,' ',apellido) nombre_completo,
           DATE_FORMAT(p.fecha_nacimiento, '%d/%m/%Y') fecha_nacimiento,/* p.sexo,*/ p.email/*,
           p.cui, p.nov, p.carnet*/
    FROM programasalud.persona p
    where p.carnet = p_carnet AND p.carnet is not null;


END;


CREATE OR REPLACE PROCEDURE programasalud.search_person_by_cui (IN p_cui VARCHAR(13))
BEGIN

    SELECT p.id_persona, /*p.nombre, p.telefono, p.apellido, */CONCAT(nombre,' ',apellido) nombre_completo,
           DATE_FORMAT(p.fecha_nacimiento, '%d/%m/%Y') fecha_nacimiento,/* p.sexo,*/ p.email/*,
           p.cui, p.nov, p.carnet*/
    FROM programasalud.persona p
    where p.cui = p_cui AND p.cui is not null;


END;





CREATE OR REPLACE PROCEDURE programasalud.get_person_details_by_cui (IN p_cui VARCHAR(13))
BEGIN

    SELECT p.id_persona, p.nombre, p.apellido,
           DATE_FORMAT(p.fecha_nacimiento, '%Y-%m-%d') fecha_nacimiento, p.sexo, p.email,
           p.cui, p.regpersonal, p.departamento
    FROM programasalud.persona p
    where p.cui = p_cui AND p.cui is not null;


END;





CREATE OR REPLACE PROCEDURE programasalud.search_person_by_any_id (IN p_id VARCHAR(13))
BEGIN

    SELECT p.id_persona, /*p.nombre, p.telefono, p.apellido,Illegal mix of collations (utf8_unicode_ci,IMPLICIT) and (utf8_general_ci,IMPLICIT) for operation 'like'*/
           CONCAT(nombre,' ',apellido) nombre_completo,
           DATE_FORMAT(p.fecha_nacimiento, '%d/%m/%Y') fecha_nacimiento, /*p.sexo,*/
           p.email
           /*,
           p.cui, p.nov, p.carnet, p.regpersonal*/
    FROM programasalud.persona p
    where p.id_persona!=1 AND ((p.cui like concat('%',p_id,'%') AND p.cui is not null AND p_id!='')
    OR (p.carnet like concat('%',p_id,'%') AND p.carnet is not null AND p_id!='')
    OR (p.nov like concat('%',p_id,'%') AND p.nov is not null AND p_id!='')
    OR (p.regpersonal like concat('%',p_id,'%') AND p.regpersonal is not null AND p_id!='')
    OR (UPPER(CONCAT(p.nombre,' ',p.apellido)) LIKE CONCAT('%',REPLACE(UPPER(p_id /*COLLATE utf8_unicode_ci*/), ' ', '%'),'%')) )
    ORDER BY nombre
        limit 50;



END;








CREATE OR REPLACE FUNCTION programasalud.fn_create_person (p_nombre VARCHAR(500), p_apellido VARCHAR(500), p_fecha_nacimiento VARCHAR(10),
                                            p_sexo VARCHAR(50), p_email VARCHAR(50),
                                            p_cui VARCHAR(13), p_nov VARCHAR(10), p_regpersonal VARCHAR(10), p_carnet VARCHAR(9))
                                            RETURNS INT
BEGIN
    DECLARE v_temp INT;


    SET v_temp = -1;


        select count(id_persona) into v_temp
        from persona
        where (cui=p_cui and cui is not null)
        or (nov=p_nov and nov is not null)
        or (regpersonal=p_regpersonal and regpersonal is not null)
        or (carnet = p_carnet and carnet is not null);

    IF v_temp = 0 THEN
        INSERT INTO programasalud.persona (nombre, apellido,
                                       fecha_nacimiento, sexo, email,
                                           cui, nov, regpersonal, carnet, source)
        VALUES ( UPPER(TRIM(p_nombre)), UPPER(TRIM(p_apellido)),
                 str_to_date(TRIM(p_fecha_nacimiento),'%Y-%m-%d'), UPPER(TRIM(p_sexo)), LOWER(TRIM(p_email)),
                if(p_cui is null or p_cui='',null,p_cui),
                if(p_nov is null or p_nov='',null,p_nov),
                if(p_regpersonal is null or p_regpersonal='',null,p_regpersonal),
                if(p_carnet is null or p_carnet='',null,p_carnet), 'CREAR_PERSONA');

        SET v_temp = LAST_INSERT_ID();
        RETURN v_temp;
    ELSE

        SET v_temp = -1;
    END IF;

    RETURN v_temp;

END;





CREATE OR REPLACE PROCEDURE programasalud.create_person (IN p_nombre VARCHAR(500), IN p_apellido VARCHAR(500), IN p_fecha_nacimiento VARCHAR(10),
                                            IN p_sexo VARCHAR(50), IN p_email VARCHAR(50), IN p_telefono VARCHAR(8),
                                            IN p_cui VARCHAR(13), IN p_nov VARCHAR(10), IN p_regpersonal VARCHAR(9), IN p_carnet VARCHAR(9),
                                            OUT o_result INT, OUT o_mensaje VARCHAR(100), OUT o_id_persona INT, OUT o_nombre_completo VARCHAR(1001))
BEGIN
    DECLARE v_temp INT;

    /*SET v_temp = fn_create_person(p_nombre,p_apellido, p_fecha_nacimiento, p_sexo, p_email, p_telefono, p_cui, p_nov, p_regpersonal, p_carnet);*/

    START TRANSACTION;

    /* check for already created persons, search by id */
        select count(1) into v_temp
        from persona
        where (cui=p_cui and cui is not null and p_cui!='')
        or (nov=p_nov and nov is not null and p_nov!='')
        or (regpersonal=p_regpersonal and regpersonal is not null and p_regpersonal!='')
        or (carnet = p_carnet and carnet is not null and p_carnet!='');

    IF v_temp = 0 THEN
        INSERT INTO programasalud.persona (nombre, apellido,
                                       fecha_nacimiento, sexo, email, telefono,
                                           cui, nov, regpersonal, carnet)
        VALUES ( UPPER(p_nombre), UPPER(p_apellido),
                 str_to_date(p_fecha_nacimiento,'%d/%m/%Y'), UPPER(p_sexo), LOWER(p_email), p_telefono,
                if(p_cui is null or p_cui='',null,p_cui),
                if(p_nov is null or p_nov='',null,p_nov),
                if(p_regpersonal is null or p_regpersonal='',null,p_regpersonal),
                if(p_carnet is null or p_carnet='',null,p_carnet));

        SET o_result = LAST_INSERT_ID();
        SET o_mensaje = 'Registro ingresado correctamente';

        SELECT id_persona, CONCAT(TRIM(nombre),' ',TRIM(apellido))
        INTO o_id_persona, o_nombre_completo
        FROM persona
        WHERE id_persona=o_result;


    ELSE
        SET o_mensaje = 'Ya existe una persona con esa identificación';
    END IF;

    COMMIT;
END;









CREATE OR REPLACE FUNCTION programasalud.create_or_update_employee_from_cc (p_nombre VARCHAR(500), p_apellido VARCHAR(500), p_fecha_nacimiento VARCHAR(10),
                                            p_sexo VARCHAR(50), p_email VARCHAR(50),
                                            p_cui VARCHAR(13), p_regpersonal VARCHAR(9), p_departamento VARCHAR(120))
                                            RETURNS INT
BEGIN
    DECLARE v_temp INT;


    SET v_temp = -1;


        select case when count(id_persona) =0 then -1 else id_persona end into v_temp
        from persona
        where (cui=p_cui and cui is not null)
        or (regpersonal=p_regpersonal and regpersonal is not null);

    IF v_temp = -1 THEN
        INSERT INTO programasalud.persona (nombre, apellido,
                                       fecha_nacimiento, sexo, email,
                                           cui, regpersonal, departamento, source)
        VALUES ( UPPER(TRIM(p_nombre)), UPPER(TRIM(p_apellido)),
                 str_to_date(TRIM(p_fecha_nacimiento),'%Y-%m-%d'), UPPER(TRIM(p_sexo)), LOWER(TRIM(p_email)),
                if(p_cui is null or p_cui='',null,p_cui),
                if(p_regpersonal is null or p_regpersonal='',null,p_regpersonal), p_departamento,
                'CC_EMPLOYEE');

        SET v_temp = LAST_INSERT_ID();
        RETURN v_temp;
    ELSE
        UPDATE programasalud.persona
        SET
            nombre = UPPER(TRIM(p_nombre)),
            apellido= UPPER(TRIM(p_apellido)),
            fecha_nacimiento = str_to_date(TRIM(p_fecha_nacimiento),'%Y-%m-%d'),
            sexo = UPPER(TRIM(p_sexo)),
            email = LOWER(TRIM(p_email)),
            cui = if(p_cui is null or p_cui='',null,p_cui),
            regpersonal = if(p_regpersonal is null or p_regpersonal='',null,p_regpersonal),
            departamento = p_departamento,
            updated = now()
        WHERE id_persona = v_temp;
        RETURN v_temp;
    END IF;

    RETURN v_temp;

END;







CREATE OR REPLACE PROCEDURE programasalud.get_employee_from_cc (IN p_nombre VARCHAR(500), IN p_apellido VARCHAR(500), IN p_fecha_nacimiento VARCHAR(10),
                                            IN p_sexo VARCHAR(50), IN p_email VARCHAR(50),
                                            IN p_cui VARCHAR(13), IN p_regpersonal VARCHAR(9), IN p_departamento VARCHAR(120))
BEGIN
    DECLARE v_temp INT;

    SET v_temp = create_or_update_employee_from_cc(p_nombre,p_apellido, p_fecha_nacimiento, p_sexo,p_email,p_cui,p_regpersonal, p_departamento);

        SELECT p.id_persona, p.nombre, p.telefono, p.apellido, CONCAT(nombre,' ',apellido) nombre_completo,
           DATE_FORMAT(p.fecha_nacimiento, '%d/%m/%Y') fecha_nacimiento, p.sexo, p.email,
           p.cui, p.regpersonal
    FROM programasalud.persona p
    where p.id_persona=v_temp;


END;























CREATE OR REPLACE PROCEDURE programasalud.create_team_person (IN p_id_seleccion INT, IN p_id_persona INT, IN p_fecha_inicio VARCHAR(10), IN p_fecha_fin VARCHAR(10), IN p_id_usuario VARCHAR(50), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;

    INSERT INTO programasalud.seleccion_persona
        (id_seleccion, id_persona, fecha_inicio, fecha_fin, id_usuario)
    VALUES
           (p_id_seleccion, p_id_persona,str_to_date(TRIM(p_fecha_inicio),'%d/%m/%Y'),if(p_fecha_fin='',null,str_to_date(TRIM(p_fecha_fin),'%d/%m/%Y')),p_id_usuario);

    SET o_result = LAST_INSERT_ID();

    SET o_mensaje = 'Registro ingresado correctamente';

    COMMIT;

END;







CREATE OR REPLACE PROCEDURE programasalud.get_team_persons(IN p_id_usuario VARCHAR(50))
BEGIN

    SELECT
        s.id_seleccion_persona, s.id_seleccion, s2.nombre nombre_seleccion, s.id_persona,
        concat(p.nombre,' ',p.apellido) nombre_persona,
        DATE_FORMAT(s.fecha_inicio, '%d/%m/%Y') fecha_inicio,
        if((s.fecha_fin is null)=0,'',DATE_FORMAT(s.fecha_fin, '%d/%m/%Y'))  fecha_fin
    FROM
        seleccion_persona s
    JOIN persona p on s.id_persona = p.id_persona
    JOIN seleccion s2 on s.id_seleccion = s2.id_seleccion AND s2.activo
    WHERE
        s.activo and s.id_usuario = p_id_usuario;

END;






CREATE OR REPLACE PROCEDURE programasalud.get_team_person(IN p_id_seleccion_persona INT)
BEGIN

    SELECT
        s.id_seleccion_persona, s.id_seleccion, s2.nombre nombre_seleccion, s.id_persona,
        concat(p.nombre,' ',p.apellido) nombre_persona,
        DATE_FORMAT(s.fecha_inicio, '%d/%m/%Y') fecha_inicio,
        if(s.fecha_fin is null,'',DATE_FORMAT(s.fecha_fin, '%d/%m/%Y'))  fecha_fin
    FROM
        seleccion_persona s
    JOIN persona p on s.id_persona = p.id_persona
    JOIN seleccion s2 on s.id_seleccion = s2.id_seleccion AND s2.activo
    WHERE
        s.activo
        AND s.id_seleccion_persona = p_id_seleccion_persona;

END;









CREATE OR REPLACE PROCEDURE programasalud.update_team_person (IN p_id_seleccion_persona INT, IN p_id_seleccion INT,
                                IN p_id_persona INT, IN p_fecha_inicio VARCHAR(10), IN p_fecha_fin VARCHAR(10),
                                OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;


    SELECT COUNT(1) INTO o_result
    FROM seleccion_persona c
    WHERE c.id_seleccion_persona=p_id_seleccion_persona
      AND c.activo;


    IF o_result > 0 THEN

        UPDATE seleccion_persona s
        SET
            s.id_seleccion = p_id_seleccion,
            s.id_persona = p_id_persona,
            s.fecha_inicio = str_to_date(TRIM(p_fecha_inicio),'%d/%m/%Y'),
            s.fecha_fin = if(p_fecha_fin='',null,str_to_date(TRIM(p_fecha_fin),'%d/%m/%Y')),
            s.activo=TRUE
        WHERE
            s.id_seleccion_persona = p_id_seleccion_persona;



        SET o_mensaje = 'Registro ingresado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;

    COMMIT;

END;









CREATE OR REPLACE PROCEDURE programasalud.delete_team_person(IN p_id_seleccion_persona INT(20), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(1) INTO o_result
    FROM seleccion_persona c
    WHERE c.id_seleccion_persona=p_id_seleccion_persona
    AND c.activo;


    if o_result>0 THEN
        UPDATE
            seleccion_persona c
        SET
            c.activo=false
        WHERE
            c.id_seleccion_persona=p_id_seleccion_persona;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;


    COMMIT;

END;



























CREATE OR REPLACE PROCEDURE programasalud.create_training (IN p_nombre VARCHAR(250), IN p_descripcion VARCHAR(600), IN p_tipo_capacitacion VARCHAR(50),
                                            IN p_estado VARCHAR(100), IN p_fecha_inicio VARCHAR(10), IN p_fecha_fin VARCHAR(10), IN p_id_usuario VARCHAR(50), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;

    INSERT INTO programasalud.capacitacion
        (nombre, descripcion, tipo_capacitacion, estado, fecha_inicio, fecha_fin, id_usuario)
    VALUES
           (UPPER(p_nombre), UPPER(p_descripcion), UPPER(p_tipo_capacitacion), UPPER(p_estado),
            str_to_date(TRIM(p_fecha_inicio),'%d/%m/%Y'),if(p_fecha_fin='',null,str_to_date(TRIM(p_fecha_fin),'%d/%m/%Y')),p_id_usuario);

    SET o_result = LAST_INSERT_ID();

    SET o_mensaje = 'Registro ingresado correctamente';

    COMMIT;

END;







CREATE OR REPLACE PROCEDURE programasalud.get_trainings(IN p_id_usuario VARCHAR(50))
BEGIN

    SELECT
        c.id_capacitacion, nombre, descripcion, tipo_capacitacion,
        if(tipo_capacitacion='CURSOLIBRE','Curso Libre',if(tipo_capacitacion='CAPACITACION','Capacitación','')) nombre_tipo_capacitacion, estado,
        DATE_FORMAT(c.fecha_inicio, '%d/%m/%Y') fecha_inicio,
        if(c.fecha_fin is null,'',DATE_FORMAT(c.fecha_fin, '%d/%m/%Y')) fecha_fin
    FROM
         capacitacion c
    WHERE
        c.activo and c.id_usuario=p_id_usuario;



END;






CREATE OR REPLACE PROCEDURE programasalud.get_training(IN p_id_capacitacion INT)
BEGIN

    SELECT
        c.id_capacitacion, nombre, descripcion, tipo_capacitacion,
        if(tipo_capacitacion='CURSOLIBRE','Curso Libre',if(tipo_capacitacion='CAPACITACION','Capacitación','')) nombre_tipo_capacitacion, estado,
        DATE_FORMAT(c.fecha_inicio, '%d/%m/%Y') fecha_inicio,
        if(c.fecha_fin is null,'',DATE_FORMAT(c.fecha_fin, '%d/%m/%Y')) fecha_fin
    FROM
         capacitacion c
    WHERE
        c.activo
        AND c.id_capacitacion = p_id_capacitacion;

END;









CREATE OR REPLACE PROCEDURE programasalud.update_training (IN p_id_capacitacion INT, IN p_nombre VARCHAR(250), IN p_descripcion VARCHAR(600), IN p_tipo_capacitacion VARCHAR(50),
                                            IN p_estado VARCHAR(100), IN p_fecha_inicio VARCHAR(10), IN p_fecha_fin VARCHAR(10),
                                OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;


    SELECT COUNT(1) INTO o_result
    FROM capacitacion c
    WHERE c.id_capacitacion=p_id_capacitacion
      AND c.activo;


    IF o_result > 0 THEN

        UPDATE capacitacion c
        SET
            c.nombre = UPPER(p_nombre),
            c.descripcion = UPPER(p_descripcion),
            c.tipo_capacitacion = UPPER(TRIM(p_tipo_capacitacion)),
            c.estado = UPPER(p_estado),
            c.fecha_inicio = str_to_date(TRIM(p_fecha_inicio),'%d/%m/%Y'),
            c.fecha_fin = if(p_fecha_fin='',null,str_to_date(TRIM(p_fecha_fin),'%d/%m/%Y')),
            c.activo=TRUE,
            c.actualizado=now()
        WHERE
            c.id_capacitacion = p_id_capacitacion;



        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;

    COMMIT;

END;









CREATE OR REPLACE PROCEDURE programasalud.delete_training(IN p_id_capacitacion INT(20), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(1) INTO o_result
    FROM capacitacion c
    WHERE c.id_capacitacion=p_id_capacitacion
    AND c.activo;


    if o_result>0 THEN
        UPDATE
            capacitacion c
        SET
            c.activo=false,
            c.actualizado=now()
        WHERE
            c.id_capacitacion = p_id_capacitacion;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;


    COMMIT;

END;




























CREATE OR REPLACE PROCEDURE programasalud.create_training_attendee (IN p_id_capacitacion INT, IN p_id_persona INT, IN p_id_usuario VARCHAR(50), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE v_activo INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;
    SET v_activo = -1;

    START TRANSACTION;

    SELECT count(1), cp.activo INTO v_temp, v_activo
    FROM capacitacion_persona cp
    WHERE cp.id_capacitacion=p_id_capacitacion
    AND cp.id_persona = p_id_persona;

    IF v_temp>0 THEN
        IF v_activo THEN
            SET o_result=-1;
            SET o_mensaje = 'Ya existe un asistente a esta capacitación';
        ELSE
            UPDATE
                capacitacion_persona cp
            SET
                activo=TRUE,
                actualizado = now(),
                id_usuario = p_id_usuario
            WHERE
                cp.id_capacitacion = p_id_capacitacion
                AND cp.id_persona = p_id_persona;

            SET o_result = 1;
            SET o_mensaje = 'Registro ingresado correctamente';
        END IF;

    ELSEIF v_temp=0 THEN
        INSERT INTO programasalud.capacitacion_persona
            (id_capacitacion, id_persona, id_usuario)
        VALUES
           (p_id_capacitacion, p_id_persona, p_id_usuario);

        SET o_result = LAST_INSERT_ID();

        SET o_mensaje = 'Registro ingresado correctamente';
    END IF;

    COMMIT;

END;







CREATE OR REPLACE PROCEDURE programasalud.get_training_attendees(IN p_id_usuario VARCHAR(50))
BEGIN

    SELECT
        cp.id_capacitacion_persona, cp.id_capacitacion, c.nombre nombre_capacitacion,
           cp.id_persona, concat(p.nombre,' ',p.apellido) nombre_persona
    FROM programasalud.capacitacion_persona cp
    JOIN programasalud.capacitacion c ON cp.id_capacitacion = c.id_capacitacion AND c.activo
    JOIN programasalud.persona p ON cp.id_persona = p.id_persona
    WHERE cp.activo and c.id_usuario=p_id_usuario;

END;






CREATE OR REPLACE PROCEDURE programasalud.get_training_attendee(IN p_id_capacitacion_persona INT)
BEGIN

    SELECT
        cp.id_capacitacion_persona, cp.id_capacitacion, c.nombre nombre_capacitacion,
           cp.id_persona, concat(p.nombre,' ',p.apellido) nombre_persona
    FROM programasalud.capacitacion_persona cp
    JOIN programasalud.capacitacion c ON cp.id_capacitacion = c.id_capacitacion AND c.activo
    JOIN programasalud.persona p ON cp.id_persona = p.id_persona
    WHERE cp.activo
    AND cp.id_capacitacion_persona = p_id_capacitacion_persona;

END;









CREATE OR REPLACE PROCEDURE programasalud.update_training_attendee (IN p_id_capacitacion_persona INT,
                                IN p_id_capacitacion INT, IN p_id_persona INT,
                                OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;


    SELECT COUNT(1) INTO o_result
    FROM capacitacion_persona c
    WHERE c.id_capacitacion_persona=p_id_capacitacion_persona
      AND c.activo;


    IF o_result > 0 THEN

        UPDATE capacitacion_persona c
        SET
            c.id_capacitacion = p_id_capacitacion,
            c.id_persona = p_id_persona,
            c.activo=TRUE,
            c.actualizado=now()
        WHERE
            c.id_capacitacion = p_id_capacitacion;



        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;

    COMMIT;

END;









CREATE OR REPLACE PROCEDURE programasalud.delete_training_attendee(IN p_id_capacitacion_persona INT(20), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(1) INTO o_result
    FROM capacitacion_persona c
    WHERE c.id_capacitacion_persona=p_id_capacitacion_persona
    AND c.activo;


    if o_result>0 THEN
        UPDATE
            capacitacion_persona c
        SET
            c.activo=false,
            c.actualizado=now()
        WHERE
            c.id_capacitacion_persona = p_id_capacitacion_persona;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;


    COMMIT;

END;










CREATE OR REPLACE PROCEDURE programasalud.get_user_clinics(IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT c.id_clinica, c.nombre FROM clinica c
    JOIN clinica_doctor cd on c.id_clinica = cd.id_clinica AND cd.activo
    JOIN doctor d on cd.id_doctor = d.id_doctor AND d.activo
    JOIN usuario u on d.id_usuario = u.id_usuario AND u.activo
    JOIN usuario_rol ur on u.id_usuario = ur.id_usuario AND ur.activo AND ur.id_rol = 8701
    WHERE c.activo
    AND u.id_usuario = LOWER(p_id_usuario);
END;













CREATE OR REPLACE PROCEDURE programasalud.get_user_doctors(IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT  d.id_doctor,
        CONCAT(p.nombre,' ',p.apellido) nombre_completo
    FROM doctor d
    JOIN usuario u on d.id_usuario = u.id_usuario AND u.activo
    JOIN usuario_rol ur on u.id_usuario = ur.id_usuario AND ur.activo AND ur.id_rol = 8701
    JOIN persona p on u.id_persona = p.id_persona
    WHERE d.activo
    AND u.id_usuario = LOWER(p_id_usuario);
END;




CREATE OR REPLACE PROCEDURE programasalud.get_person_email(IN p_id_persona INT)
BEGIN
    SELECT id_persona, email FROM persona WHERE id_persona = p_id_persona;
    /*SELECT id_persona, 'andres.chang.h@gmail.com' email FROM persona WHERE id_persona = p_id_persona;*/
END;










CREATE OR REPLACE PROCEDURE programasalud.schedule_appointment (IN p_id_clinica INT, IN p_id_persona INT, IN p_id_doctor INT,
                                                                IN p_fecha VARCHAR(10), IN p_hora VARCHAR(5), IN p_sintoma VARCHAR(500), IN p_email VARCHAR(50),
                                                                OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE v_fecha DATETIME;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;

    SET v_fecha = str_to_date(concat(p_fecha,' ',p_hora),'%d/%m/%Y %H:%i');

    /* Valida disponibilidad de la clínica */
    SELECT count(1) INTO v_temp
    FROM cita c
    JOIN clinica c2 on c.id_clinica = c2.id_clinica AND c2.activo
    WHERE c.activo AND c.id_clinica = p_id_clinica AND c.fecha = v_fecha;

    IF v_temp>0 THEN

        SET o_result=-1;
        SET o_mensaje = 'Ya existe una cita a esa fecha y hora en la clínica';

    ELSE

        /* Valida disponibilidad del doctor */
        SELECT count(1) INTO v_temp
        FROM cita c
        JOIN doctor d on c.id_doctor = d.id_doctor AND d.activo
        WHERE c.activo AND c.id_doctor = p_id_doctor AND c.fecha = v_fecha;

        IF v_temp>0 THEN
            SET o_result=-1;
            SET o_mensaje = 'La persona (doctor) que atenderá la cita ya tiene una programada para la misma fecha y hora';
        ELSE

            /* Valida disponibilidad de la persona */
            SELECT count(1) INTO v_temp FROM cita c
            WHERE c.activo AND c.id_persona = p_id_persona AND c.fecha = v_fecha;

            IF v_temp>0 THEN
                SET o_result=-1;
                SET o_mensaje = 'La persona que asistirá a la cita ya tiene una programada para la misma fecha y hora';
            ELSE

                INSERT INTO programasalud.cita
                    (id_clinica, id_persona, id_doctor, fecha, email, sintoma)
                VALUES
                   (p_id_clinica, p_id_persona, p_id_doctor, v_fecha, LOWER(p_email), UPPER(p_sintoma));

                SET o_result = LAST_INSERT_ID();

                INSERT INTO programasalud.flujo_cita(id_cita) VALUES (o_result);

                SET o_mensaje = 'Registro ingresado correctamente';
            END IF;
        END IF;
    END IF;

    COMMIT;

END;









CREATE OR REPLACE PROCEDURE programasalud.get_todays_appointments(IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT c.id_cita, DATE_FORMAT(c.fecha,'%d/%m/%Y') fecha, DATE_FORMAT(c.fecha,'%H:%i') hora, p.id_persona id_paciente, concat(p.nombre,' ',p.apellido) paciente,
           p2.id_persona id_atiende, concat(p2.nombre,' ',p2.apellido) atiende, c2.id_clinica, c2.nombre clinica, c.sintoma, fc.paso
    FROM cita c
    JOIN persona p on c.id_persona = p.id_persona
    JOIN doctor d on c.id_doctor = d.id_doctor
    JOIN usuario u on d.id_usuario = u.id_usuario
    JOIN persona p2 on u.id_persona = p2.id_persona
    JOIN clinica c2 on c.id_clinica = c2.id_clinica
    JOIN flujo_cita fc on c.id_cita = fc.id_cita AND fc.activo
    WHERE c.activo
    AND date(c.fecha) <= date(now())
    AND fc.paso NOT IN ('FINALIZADO','CANCELADO')
    AND u.id_usuario=p_id_usuario
    ORDER BY c.fecha;
END;








CREATE OR REPLACE PROCEDURE programasalud.get_future_appointments(IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT c.id_cita, DATE_FORMAT(c.fecha,'%d/%m/%Y') fecha, DATE_FORMAT(c.fecha,'%H:%i') hora, p.id_persona id_paciente, concat(p.nombre,' ',p.apellido) paciente,
           p2.id_persona id_atiende, concat(p2.nombre,' ',p2.apellido) atiende, c2.id_clinica, c2.nombre clinica, c.sintoma
    FROM cita c
    JOIN persona p on c.id_persona = p.id_persona
    JOIN doctor d on c.id_doctor = d.id_doctor
    JOIN usuario u on d.id_usuario = u.id_usuario
    JOIN persona p2 on u.id_persona = p2.id_persona
    JOIN clinica c2 on c.id_clinica = c2.id_clinica
    JOIN flujo_cita fc on c.id_cita = fc.id_cita AND fc.activo
    WHERE c.activo
    AND date(c.fecha) > date(now())
    AND fc.paso NOT IN ('FINALIZADO','CANCELADO')
    AND u.id_usuario=p_id_usuario
    ORDER BY c.fecha;
END;




CREATE OR REPLACE PROCEDURE programasalud.get_appointment(IN p_id_cita INT, IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT c.id_cita, DATE_FORMAT(c.fecha,'%d/%m/%Y') fecha, DATE_FORMAT(c.fecha,'%H:%i') hora, p.id_persona id_paciente, concat(p.nombre,' ',p.apellido) paciente,
           c.id_doctor, p2.id_persona id_atiende, concat(p2.nombre,' ',p2.apellido) atiende, c2.id_clinica, c2.nombre clinica, c.email, c.sintoma
    FROM cita c
    JOIN persona p on c.id_persona = p.id_persona
    JOIN doctor d on c.id_doctor = d.id_doctor
    JOIN usuario u on d.id_usuario = u.id_usuario
    JOIN persona p2 on u.id_persona = p2.id_persona
    JOIN clinica c2 on c.id_clinica = c2.id_clinica
    JOIN flujo_cita fc on c.id_cita = fc.id_cita AND fc.activo
    WHERE c.activo
    AND c.id_cita = p_id_cita
    AND fc.paso NOT IN ('FINALIZADO','CANCELADO')
    AND u.id_usuario=p_id_usuario;
END;






CREATE OR REPLACE PROCEDURE programasalud.update_appointment (IN p_id_cita INT, IN p_id_clinica INT, IN p_id_doctor INT,
                                                IN p_fecha VARCHAR(10), IN p_hora VARCHAR(5), IN p_sintoma VARCHAR(500),
                                                                OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE v_paso ENUM('CREADO', 'ATENDIENDO', 'EDITADO', 'FINALIZADO', 'CANCELADO');
    DECLARE v_fecha DATETIME;

    DECLARE v_id_persona INT;

    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;
    SET v_id_persona = -1;

    START TRANSACTION;

    SET v_fecha = str_to_date(concat(p_fecha,' ',p_hora),'%d/%m/%Y %H:%i');



    SELECT count(1), c.id_persona INTO v_temp, v_id_persona
    FROM cita c
    WHERE c.activo
    AND c.id_cita = p_id_cita;

    /* Valida disponibilidad de la clínica */
    SELECT count(1) INTO v_temp
    FROM cita c
    JOIN clinica c2 on c.id_clinica = c2.id_clinica AND c2.activo
    WHERE c.activo AND c.id_clinica = p_id_clinica AND c.fecha = v_fecha
        AND c.id_cita != p_id_cita;

    IF v_temp>0 THEN

        SET o_result=-1;
        SET o_mensaje = 'Ya existe una cita a esa fecha y hora en la clínica';

    ELSE

        /* Valida disponibilidad del doctor */
        SELECT count(1) INTO v_temp
        FROM cita c
        JOIN doctor d on c.id_doctor = d.id_doctor AND d.activo
        WHERE c.activo AND c.id_doctor = p_id_doctor AND c.fecha = v_fecha
            AND c.id_cita != p_id_cita;

        IF v_temp>0 THEN
            SET o_result=-1;
            SET o_mensaje = 'La persona (doctor) que atenderá la cita ya tiene una programada para la misma fecha y hora';
        ELSE

            /* Valida disponibilidad de la persona */
            SELECT count(1) INTO v_temp FROM cita c
            WHERE c.activo AND c.id_persona = v_id_persona AND c.fecha = v_fecha
                AND c.id_cita != p_id_cita;

            IF v_temp>0 THEN
                SET o_result=-1;
                SET o_mensaje = 'La persona que asistirá a la cita ya tiene una programada para la misma fecha y hora';
            ELSE
                UPDATE cita c
                SET
                    id_clinica = p_id_clinica,
                    id_doctor = p_id_doctor,
                    fecha = v_fecha,
                    sintoma = UPPER(p_sintoma)
                WHERE
                      id_cita=p_id_cita;

                SELECT id_flujo_cita, paso INTO v_temp, v_paso
                FROM flujo_cita
                WHERE id_cita = p_id_cita
                AND activo;

                IF v_paso = 'EDITADO' THEN
                    UPDATE flujo_cita f
                    SET actualizado = now()
                    WHERE f.id_flujo_cita = v_temp
                    AND activo=1;
                ELSE
                    UPDATE flujo_cita f
                    SET activo = 0,
                    actualizado = now()
                    WHERE f.id_flujo_cita = v_temp
                    AND activo=1;

                    INSERT INTO flujo_cita (id_cita, paso, flujo_cita_padre)
                    VALUES (p_id_cita,'EDITADO',v_temp);
                END IF;

                SET o_result = p_id_cita;
                SET o_mensaje = 'Registro ingresado correctamente';
            END IF;
        END IF;
    END IF;

    COMMIT;

END;













CREATE OR REPLACE PROCEDURE programasalud.delete_appointment(IN p_id_cita INT(20), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(1) INTO o_result
    FROM cita c
    WHERE c.id_cita=p_id_cita
    AND c.activo;


    if o_result>0 THEN

        UPDATE
            cita c
        SET
            c.activo=false
        WHERE
            c.id_cita = p_id_cita;


        SELECT id_flujo_cita INTO o_result
        FROM flujo_cita
        WHERE id_cita = p_id_cita
        AND activo;

        UPDATE flujo_cita f
        SET activo = 0,
        actualizado = now()
        WHERE f.id_flujo_cita = o_result
        AND activo=1;

        INSERT INTO flujo_cita (id_cita, paso, flujo_cita_padre)
        VALUES (p_id_cita,'CANCELADO',o_result);

        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;


    COMMIT;

END;








CREATE OR REPLACE PROCEDURE programasalud.get_appointment_measurements(IN p_id_cita INT, IN p_id_usuario VARCHAR(50))
BEGIN

    SELECT m.id_medida, m.nombre fieldLabel, tdm.tipo_dato, coalesce(m.unidad_medida,'') unidad_medida,
        m.valor_minimo, m.valor_maximo, if(m.obligatorio=1,'true','false') obligatorio from clinica_medida cm
    JOIN clinica c on cm.id_clinica = c.id_clinica AND c.activo
    JOIN medida m on cm.id_medida = m.id_medida AND m.activo
    JOIN tipo_dato_medida tdm on m.id_tipo_dato = tdm.id_tipo_dato
    JOIN cita c2 on c.id_clinica = c2.id_clinica AND c2.activo AND c2.id_cita=p_id_cita
    JOIN doctor d on c2.id_doctor = d.id_doctor AND d.activo
    JOIN usuario u on d.id_usuario = u.id_usuario AND u.id_usuario=p_id_usuario AND u.activo
    WHERE cm.activo;

END;




CREATE OR REPLACE PROCEDURE programasalud.get_appointment_actions(IN p_id_cita INT, IN p_id_usuario VARCHAR(50))
BEGIN

    SELECT ca.id_accion, a.nombre
    from clinica_accion ca
    JOIN clinica c on ca.id_clinica = c.id_clinica AND c.activo
    JOIN accion a on ca.id_accion = a.id_accion AND a.activo
    JOIN cita c2 on c.id_clinica = c2.id_clinica AND c2.activo AND c2.id_cita=p_id_cita
    JOIN doctor d on c2.id_doctor = d.id_doctor AND d.activo
    JOIN usuario u on d.id_usuario = u.id_usuario AND u.id_usuario=p_id_usuario AND u.activo
    WHERE ca.activo;

END;









CREATE OR REPLACE PROCEDURE programasalud.start_appointment(IN p_id_cita INT(20), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE v_paso ENUM('CREADO', 'ATENDIENDO', 'EDITADO', 'FINALIZADO', 'CANCELADO');
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SET v_temp = -1;
    SET o_result = -1;

    SELECT count(1), fc.paso INTO v_temp, v_paso
    FROM cita c
    JOIN flujo_cita fc ON c.id_cita = fc.id_cita AND fc.paso NOT IN ('FINALIZADO', 'CANCELADO') AND fc.activo
    WHERE c.activo AND c.id_cita=p_id_cita;

    if v_temp>0 THEN
        IF v_paso IN ('CREADO', 'EDITADO') THEN
            SELECT id_flujo_cita INTO o_result
            FROM flujo_cita
            WHERE id_cita = p_id_cita
            AND activo;

            UPDATE flujo_cita f
            SET activo = 0,
            actualizado = now()
            WHERE f.id_flujo_cita = o_result
            AND activo=1;

            INSERT INTO flujo_cita (id_cita, paso, flujo_cita_padre)
            VALUES (p_id_cita,'ATENDIENDO',o_result);
        END IF;
        SET o_result = p_id_cita;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'La cita ya fue cancelada o finalizada';
    END IF;


    COMMIT;

END;




/*
**************************************************************
**************************************************************
**************************************************************
**************************************************************
**************************************************************
**************************************************************
**************************************************************
 */



CREATE OR REPLACE PROCEDURE programasalud.attend_appointment(IN p_id_usuario VARCHAR(50), IN p_id_cita INT)
BEGIN
    SELECT c.id_cita, DATE_FORMAT(c.fecha,'%d/%m/%Y') fecha, DATE_FORMAT(c.fecha,'%H:%i') hora, DATE_FORMAT(fc.creado,'%H:%i') hora_inicio, p.id_persona id_paciente, concat(p.nombre,' ',p.apellido) paciente,
           p2.id_persona id_atiende, concat(p2.nombre,' ',p2.apellido) atiende, c2.id_clinica, c2.nombre clinica, c.sintoma, fc.paso,
           pf.telefono_emergencia, pf.contacto_emergencia, pf.flag_tiene_discapacidad, pf.id_tipo_enfermedad
    FROM cita c
    JOIN persona p on c.id_persona = p.id_persona
    JOIN doctor d on c.id_doctor = d.id_doctor
    JOIN usuario u on d.id_usuario = u.id_usuario
    JOIN persona p2 on u.id_persona = p2.id_persona
    JOIN clinica c2 on c.id_clinica = c2.id_clinica
    JOIN flujo_cita fc on c.id_cita = fc.id_cita AND fc.activo
    LEFT JOIN persona_ficha pf on p.id_persona = pf.id_persona
    WHERE c.activo
    AND date(c.fecha) <= date(now())
    AND fc.paso = 'ATENDIENDO'
    AND u.id_usuario=p_id_usuario
    AND c.id_cita = p_id_cita
    ORDER BY c.fecha;
END;














CREATE OR REPLACE PROCEDURE programasalud.create_action(IN p_nombre VARCHAR(150), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SET v_temp = -1;
    SET o_result = -1;

    SELECT count(1) INTO v_temp
    FROM accion a
    WHERE lower(TRIM(a.nombre)) = lower(TRIM(p_nombre))
    AND a.activo;

    IF v_temp>0 THEN
        SET o_mensaje = 'Ya existe una acción con ese nombre';
    ELSE
        INSERT INTO accion(nombre)VALUES(INITCAP(p_nombre));
        SET o_result = LAST_INSERT_ID();

        INSERT INTO programasalud.clinica_accion (id_clinica, id_accion)
        SELECT id_clinica, o_result
        FROM clinica;

        SET o_mensaje = 'Registro ingresado correctamente';
    END IF;
    COMMIT;
END;



CREATE OR REPLACE PROCEDURE programasalud.get_actions()
BEGIN
    SELECT
        a.id_accion, a.nombre
    FROM accion a
    WHERE a.activo;
END;



CREATE OR REPLACE PROCEDURE programasalud.get_action(IN p_id_accion INT)
BEGIN
    SELECT
        a.id_accion, a.nombre
    FROM accion a
    WHERE a.activo
    AND a.id_accion=p_id_accion;
END;





CREATE OR REPLACE PROCEDURE programasalud.update_action( IN p_id_accion INT, IN p_nombre VARCHAR(150),
                                                   OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;


    SELECT count(1) INTO v_temp
    FROM accion a
    WHERE lower(TRIM(a.nombre)) = lower(TRIM(p_nombre))
    AND a.activo AND a.id_accion !=  p_id_accion;


    IF o_result > 0 THEN
        SET o_result = -1;
        SET o_mensaje = 'Ya existe una acción con ese nombre';

    ELSE
        UPDATE accion SET nombre = initcap(p_nombre) WHERE id_accion = p_id_accion;
        SET o_mensaje = 'Registro actualizado correctamente';
        SET o_result = p_id_accion;
    END IF;

    COMMIT;

END;









CREATE OR REPLACE PROCEDURE programasalud.delete_action(IN p_id_accion INT, OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM accion b
    WHERE b.id_accion = p_id_accion;


    if o_result>0 THEN
        UPDATE
            accion b
        SET
            b.activo=false
        WHERE
                b.id_accion = p_id_accion;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;


    COMMIT;

END;











CREATE OR REPLACE PROCEDURE programasalud.create_persona_medida(IN p_id_medida INT, IN p_id_persona INT, IN p_id_cita INT, IN p_valor VARCHAR(150), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    INSERT INTO persona_medida (id_medida, id_persona, id_cita, valor)
    VALUES (p_id_medida, p_id_persona, p_id_cita, p_valor);

    SET o_result = LAST_INSERT_ID();
    SET o_mensaje = o_result;
END;



CREATE OR REPLACE PROCEDURE programasalud.get_measurement_history(IN p_id_cita INT)
BEGIN
    SELECT pm.id_persona_medida, date_format(pm.creado,'%d/%m/%Y') fecha,
           date_format(pm.creado,'%H:%i') hora, c2.nombre clinica,
           CONCAT(p2.nombre,' ',p2.apellido) atiende, m.nombre medida,
           pm.valor, if(m.id_tipo_dato=8706,'', m.unidad_medida) unidad FROM persona_medida pm
    JOIN persona p on pm.id_persona = p.id_persona
    LEFT JOIN cita c on pm.id_cita = c.id_cita
    JOIN medida m on pm.id_medida = m.id_medida
    LEFT JOIN clinica c2 on c.id_clinica = c2.id_clinica
    LEFT JOIN doctor d on c.id_doctor = d.id_doctor
    LEFT JOIN usuario u on d.id_usuario = u.id_usuario
    LEFT JOIN persona p2 on u.id_persona = p2.id_persona
    WHERE
    pm.id_persona = (SELECT id_persona FROM cita where id_cita=p_id_cita)
    AND pm.activo
    ORDER BY pm.creado DESC;
END;



CREATE OR REPLACE PROCEDURE programasalud.get_measurement_history_persona(IN p_id_persona INT)
BEGIN
    SELECT pm.id_persona_medida, date_format(pm.creado,'%d/%m/%Y') fecha,
           date_format(pm.creado,'%H:%i') hora, c2.nombre clinica,
           CONCAT(p2.nombre,' ',p2.apellido) atiende, m.nombre medida,
           pm.valor, if(m.id_tipo_dato=8706,'', m.unidad_medida) unidad FROM persona_medida pm
    JOIN persona p on pm.id_persona = p.id_persona
    LEFT JOIN cita c on pm.id_cita = c.id_cita
    JOIN medida m on pm.id_medida = m.id_medida
    LEFT JOIN clinica c2 on c.id_clinica = c2.id_clinica
    LEFT JOIN doctor d on c.id_doctor = d.id_doctor
    LEFT JOIN usuario u on d.id_usuario = u.id_usuario
    LEFT JOIN persona p2 on u.id_persona = p2.id_persona
    WHERE
    pm.id_persona = p_id_persona
    AND pm.activo
    ORDER BY pm.creado DESC;
END;










CREATE OR REPLACE PROCEDURE programasalud.get_carreras_for_select()
BEGIN
   SELECT carrera, CONCAT(carrera,' ',nombre_corto) nombre
    FROM carrera
    WHERE activo
    ORDER BY carrera;
END;



CREATE OR REPLACE PROCEDURE programasalud.assign_discipline (IN p_carnet NUMERIC(13,0), IN p_nov NUMERIC(10,0), IN p_nombre VARCHAR(500), IN p_apellido VARCHAR(500),
                                                             IN p_fecha_nacimiento VARCHAR(10), IN p_sexo VARCHAR(1), IN p_email VARCHAR(50), IN p_telefono VARCHAR(8),
                                                             IN p_telefono_emergencia VARCHAR(8), IN p_contacto_emergencia VARCHAR(150),
                                                             IN p_carrera VARCHAR(2), IN p_peso INT, IN p_estatura DECIMAL(5,2),
                                                             IN p_flag_tiene_discapacidad VARCHAR(1), IN p_id_tipo_discapacidad INT,
                                                             IN p_id_tipo_enfermedad INT, IN p_id_disciplina_persona INT, IN p_id_disciplina INT,
                                                             OUT o_result INT, OUT o_mensaje VARCHAR(500))
BEGIN

    DECLARE v_temp INT;
    DECLARE v_flg_existe_persona INT;
    DECLARE v_flg_existe_ficha INT;
    DECLARE v_cupo_disciplina INT;
    DECLARE v_temp_id_asign INT;
    DECLARE v_semestre VARCHAR(6);
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET o_result = -1;
    SET v_temp_id_asign = -1;
    SET v_cupo_disciplina = -1;

    START TRANSACTION;

    SET v_semestre = CONCAT(IF(MONTH(NOW())<7,1,2),'S',YEAR(NOW()));

    -- revisar si existe la persona
    SELECT count(1), coalesce(id_persona,-1) INTO v_flg_existe_persona, v_temp
    FROM persona WHERE
       (carnet=p_carnet AND carnet IS NOT NULL)
        OR (nov=p_nov AND nov IS NOT NULL);

    -- revisar si existe asignación para la persona (si existe)
    IF v_flg_existe_persona > 0 THEN
        SELECT count(1) INTO v_temp_id_asign
        FROM asignacion_deportes
        WHERE
        activo
        AND semestre = v_semestre
        AND id_persona = v_temp;

        IF v_temp_id_asign>0 THEN
            SET o_result = -1;
            SET o_mensaje = 'Ya existe una asignación, dirigirse al departamento de deportes.';
        END IF ;
    END IF;

    IF v_temp_id_asign <= 0 THEN

        -- crear la persona
        IF v_flg_existe_persona= 0 THEN
            SET v_temp = create_or_update_student_from_cc(p_nombre,p_apellido, p_fecha_nacimiento, p_sexo,p_email,p_telefono,null,p_nov, p_carnet, p_carrera);
            UPDATE persona p SET source = 'DEPORTES' WHERE p.id_persona=v_temp;
        END IF;

        -- revisar si hay cupo para la asignación
        SELECT
        d.limite-count(ad.id_disciplina) INTO v_cupo_disciplina
        FROM
        disciplina d
        LEFT JOIN asignacion_deportes ad ON d.id_disciplina = ad.id_disciplina AND ad.activo
        WHERE d.activo
        AND d.semestre=v_semestre
        AND d.id_disciplina=p_id_disciplina;

        IF v_cupo_disciplina <=0 THEN
            SET o_result = -1;
            SET o_mensaje = 'No hay cupo para la disciplina seleccionada';
        ELSE
            INSERT INTO programasalud.asignacion_deportes (id_disciplina, id_persona, semestre) VALUES
            (p_id_disciplina, v_temp, v_semestre);
            SET o_result = LAST_INSERT_ID();

            -- ficha de la persona
            SELECT count(1) INTO v_flg_existe_ficha
            FROM persona_ficha
            WHERE id_persona = v_temp;

            IF v_flg_existe_ficha > 0 THEN
                UPDATE persona_ficha
                SET
                    telefono_emergencia = p_telefono_emergencia,
                    contacto_emergencia = p_contacto_emergencia,
                    flag_tiene_discapacidad = (p_flag_tiene_discapacidad = '1'),
                    id_tipo_discapacidad = if(p_flag_tiene_discapacidad = '1',p_id_tipo_discapacidad,null ),
                    id_tipo_enfermedad = p_id_tipo_enfermedad,
                    id_disciplina_persona = p_id_disciplina_persona,
                    actualizado = NOW()
                WHERE id_persona = v_temp;
            ELSE
                INSERT INTO persona_ficha (id_persona, flag_tiene_discapacidad, id_tipo_discapacidad, telefono_emergencia, contacto_emergencia, id_tipo_enfermedad, id_disciplina_persona)
                VALUES (v_temp,(p_flag_tiene_discapacidad = '1'), if(p_flag_tiene_discapacidad = '1',p_id_tipo_discapacidad,null ), p_telefono_emergencia, p_contacto_emergencia, p_id_tipo_enfermedad, p_id_disciplina_persona);
            END IF;

            -- medidas
            INSERT INTO persona_medida (id_medida, id_persona, valor)
            VALUES
            (1,v_temp,p_peso),
            (2,v_temp,p_estatura);

            SET o_mensaje = 'Registro ingresado correctamente';
        END IF;
    END IF;

    COMMIT;

END;









CREATE OR REPLACE PROCEDURE programasalud.get_persona_ficha(IN p_id_persona INT)
BEGIN
    SELECT id_persona, flag_tiene_discapacidad, id_tipo_discapacidad, telefono_emergencia, contacto_emergencia, id_tipo_enfermedad, id_disciplina_persona
    FROM persona_ficha
    WHERE id_persona = p_id_persona;
END;












CREATE OR REPLACE PROCEDURE programasalud.save_persona_ficha(IN p_id_persona INT, IN p_flag_tiene_discapacidad VARCHAR(1),
                                                             IN p_telefono_emergencia VARCHAR(8), IN p_contacto_emergencia VARCHAR(150),
                                                             IN p_id_tipo_discapacidad INT, IN p_id_tipo_enfermedad INT, IN p_id_disciplina_persona INT,
                                                             OUT o_result INT, OUT o_mensaje VARCHAR(255))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;


    SET v_temp = -1;
    SET o_result = -1;

    select COUNT(1) INTO v_temp
    FROM persona_ficha
    WHERE id_persona = p_id_persona;


    if v_temp>0 THEN

        UPDATE persona_ficha
        SET
            actualizado = now(),
            flag_tiene_discapacidad = (p_flag_tiene_discapacidad = '1'),
            id_tipo_discapacidad = IF(p_flag_tiene_discapacidad = '1', p_id_tipo_discapacidad, NULL),
            telefono_emergencia = p_telefono_emergencia,
            contacto_emergencia = p_contacto_emergencia,
            id_disciplina_persona = p_id_disciplina_persona,
            id_tipo_enfermedad = p_id_tipo_enfermedad
        WHERE
            id_persona = p_id_persona;

        SET o_result = p_id_persona;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE

        INSERT INTO persona_ficha (id_persona, flag_tiene_discapacidad, id_tipo_discapacidad, telefono_emergencia, contacto_emergencia, id_tipo_enfermedad, id_disciplina_persona)
        VALUES (p_id_persona, (p_flag_tiene_discapacidad = '1'),IF(p_flag_tiene_discapacidad = '1', p_id_tipo_discapacidad, NULL),
                p_telefono_emergencia, p_contacto_emergencia, p_id_tipo_enfermedad, p_id_disciplina_persona);
        SET o_result = p_id_persona;
        SET o_mensaje = 'Registro actualizado correctamente';
    END IF;


    COMMIT;

END;








CREATE OR REPLACE PROCEDURE programasalud.create_cita_accion(IN p_id_cita INT, IN p_id_accion INT,
                                                             IN p_observaciones VARCHAR(500),
                                                             OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;


    SET v_temp = -1;
    SET o_result = -1;

    INSERT INTO cita_accion (id_cita, id_accion, observaciones) VALUES (p_id_cita, p_id_accion, p_observaciones);
    SET o_result = LAST_INSERT_ID();
    SET o_mensaje = 'Registro actualizado correctamente';

    COMMIT;

END;


CREATE OR REPLACE PROCEDURE programasalud.get_cita_acciones(IN p_id_cita INT)
BEGIN
    SELECT ca.id_cita_accion, date_format(ca.creado,'%d/%m/%Y') fecha,
           date_format(ca.creado,'%H:%i') hora, c2.nombre clinica,
           CONCAT(p2.nombre,' ',p2.apellido) atiende, a.nombre accion, ca.observaciones
    FROM cita_accion ca
    JOIN cita c on ca.id_cita = c.id_cita
    JOIN accion a on ca.id_accion = a.id_accion
    JOIN clinica c2 on c.id_clinica = c2.id_clinica
    JOIN doctor d on c.id_doctor = d.id_doctor
    JOIN usuario u on d.id_usuario = u.id_usuario
    JOIN persona p2 on u.id_persona = p2.id_persona
    WHERE ca.activo and c.id_persona = (
        SELECT c.id_persona FROM cita c
        WHERE id_cita = p_id_cita )
    ORDER BY ca.creado DESC;
END;


CREATE OR REPLACE PROCEDURE programasalud.get_cita_acciones_persona(IN p_id_persona INT)
BEGIN
    SELECT ca.id_cita_accion, date_format(ca.creado,'%d/%m/%Y') fecha,
           date_format(ca.creado,'%H:%i') hora, c2.nombre clinica,
           CONCAT(p2.nombre,' ',p2.apellido) atiende, a.nombre accion, ca.observaciones
    FROM cita_accion ca
    JOIN cita c on ca.id_cita = c.id_cita
    JOIN accion a on ca.id_accion = a.id_accion
    JOIN clinica c2 on c.id_clinica = c2.id_clinica
    JOIN doctor d on c.id_doctor = d.id_doctor
    JOIN usuario u on d.id_usuario = u.id_usuario
    JOIN persona p2 on u.id_persona = p2.id_persona
    WHERE ca.activo and c.id_persona = p_id_persona
    ORDER BY ca.creado DESC;
END;









CREATE OR REPLACE PROCEDURE programasalud.delete_cita_accion(IN p_id_cita_accion INT, IN p_id_cita INT, OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM cita_accion u
    WHERE u.id_cita_accion=p_id_cita_accion
    AND u.id_cita=p_id_cita;


    IF o_result>0 THEN
        UPDATE
            cita_accion u
        SET
            u.activo=false,
            u.actualizado = now()
        WHERE
            u.id_cita_accion = p_id_cita_accion
            AND u.id_cita=p_id_cita;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Esta acción no fue registrada en esta cita';
    END IF;

    COMMIT;

END;






CREATE OR REPLACE PROCEDURE programasalud.delete_persona_medida(IN p_id_persona_medida INT, IN p_id_cita INT, OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM persona_medida pm
    WHERE pm.id_persona_medida = p_id_persona_medida
    AND pm.id_cita = p_id_cita;


    IF o_result>0 THEN
        UPDATE
            persona_medida pm
        SET
            pm.activo=false,
            pm.actualizado = now()
        WHERE
            pm.id_persona_medida = p_id_persona_medida
            AND pm.id_cita = p_id_cita;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Esta medida no fue registrada en esta cita';
    END IF;

    COMMIT;

END;




CREATE OR REPLACE PROCEDURE programasalud.finish_appointment(IN p_id_cita INT(20), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE v_estado INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SET v_temp = -1;
    SET v_estado = -1;
    SET o_result = -1;

    SELECT COUNT(1) INTO v_estado FROM cita c
    JOIN flujo_cita fc2 on c.id_cita = fc2.id_cita AND fc2.paso = 'ATENDIENDO' AND fc2.activo
    WHERE c.activo AND c.id_cita=p_id_cita;


    if v_estado>0 THEN

        SELECT sum(medidas) + sum(acciones) INTO v_temp FROM (
        SELECT count(1) medidas, 0 acciones FROM persona_medida pm WHERE id_cita=p_id_cita
        UNION
        SELECT 0, count(1) FROM cita_accion ca WHERE ca.activo AND id_cita =p_id_cita) totales;


        IF v_temp > 0 THEN
            SELECT id_flujo_cita INTO o_result
            FROM flujo_cita
            WHERE id_cita = p_id_cita
            AND activo;

            UPDATE flujo_cita f
            SET activo = 0,
            actualizado = now()
            WHERE f.id_flujo_cita = o_result
            AND activo=1;

            INSERT INTO flujo_cita (id_cita, paso, flujo_cita_padre)
            VALUES (p_id_cita,'FINALIZADO',o_result);

            UPDATE cita c SET activo = FALSE WHERE id_cita = p_id_cita;

            SET o_result = p_id_cita;
            SET o_mensaje = 'Cita finalizada correctamente';
        ELSE
            SET o_result = -1;
            SET o_mensaje = 'Debe tomar medidas o registrar una acción para poder finalizar la cita';
        END IF;
    ELSE
        SET o_mensaje = 'La cita ya fue cancelada o finalizada';
    END IF;


    COMMIT;

END;





CREATE OR REPLACE PROCEDURE programasalud.cancel_appointment(IN p_id_cita INT(20), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE v_estado INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SET v_temp = -1;
    SET v_estado = -1;
    SET o_result = -1;

    SELECT COUNT(1) INTO v_estado FROM cita c
    JOIN flujo_cita fc2 on c.id_cita = fc2.id_cita AND fc2.paso = 'ATENDIENDO' AND fc2.activo
    WHERE c.activo AND c.id_cita=p_id_cita;


    if v_estado>0 THEN


        SELECT id_flujo_cita INTO o_result
        FROM flujo_cita
        WHERE id_cita = p_id_cita
        AND activo;

        UPDATE flujo_cita f
        SET activo = 0,
        actualizado = now()
        WHERE f.id_flujo_cita = o_result
        AND activo=1;

        INSERT INTO flujo_cita (id_cita, paso, flujo_cita_padre)
        VALUES (p_id_cita,'CANCELADO',o_result);

        UPDATE cita c SET activo = FALSE WHERE id_cita = p_id_cita;

        SET o_result = p_id_cita;
        SET o_mensaje = 'Cita cancelada correctamente';

    ELSE
        SET o_mensaje = 'La cita ya fue cancelada o finalizada';
    END IF;


    COMMIT;

END;




CREATE OR REPLACE PROCEDURE programasalud.get_appointment_history(IN p_id_cita INT)
BEGIN

    SELECT date_format(c.fecha,'%d/%m/%Y %H:%i') programada,
           (SELECT date_format(fc2.creado ,'%d/%m/%Y %H:%i') FROM flujo_cita fc2 WHERE fc2.id_cita=fc.id_cita AND fc2.paso='ATENDIENDO' AND fc2.id_flujo_cita=fc.flujo_cita_padre) inicio,
           date_format(fc.creado ,'%d/%m/%Y %H:%i') fin,
           c2.nombre clinica,
           CONCAT(p2.nombre,' ',p2.apellido) atiende, c.sintoma
    FROM flujo_cita fc
    JOIN cita c on c.id_cita = fc.id_cita AND fc.paso = 'FINALIZADO'
    JOIN clinica c2 on c.id_clinica = c2.id_clinica
    JOIN doctor d on c.id_doctor = d.id_doctor
    JOIN usuario u on d.id_usuario = u.id_usuario
    JOIN persona p2 on u.id_persona = p2.id_persona
    WHERE c.id_persona = (
        SELECT c.id_persona FROM cita c
        WHERE id_cita = p_id_cita )
    ORDER BY c.fecha DESC;

END;




CREATE OR REPLACE PROCEDURE programasalud.get_appointment_history_persona(IN p_id_persona INT)
BEGIN

    SELECT date_format(c.fecha,'%d/%m/%Y %H:%i') programada,
           (SELECT date_format(fc2.creado ,'%d/%m/%Y %H:%i') FROM flujo_cita fc2 WHERE fc2.id_cita=fc.id_cita AND fc2.paso='ATENDIENDO' AND fc2.id_flujo_cita=fc.flujo_cita_padre) inicio,
           date_format(fc.creado ,'%d/%m/%Y %H:%i') fin,
           c2.nombre clinica,
           CONCAT(p2.nombre,' ',p2.apellido) atiende, c.sintoma
    FROM flujo_cita fc
    JOIN cita c on c.id_cita = fc.id_cita AND fc.paso = 'FINALIZADO'
    JOIN clinica c2 on c.id_clinica = c2.id_clinica
    JOIN doctor d on c.id_doctor = d.id_doctor
    JOIN usuario u on d.id_usuario = u.id_usuario
    JOIN persona p2 on u.id_persona = p2.id_persona
    WHERE c.id_persona = p_id_persona
    ORDER BY c.fecha DESC;

END;


CREATE OR REPLACE PROCEDURE programasalud.get_appointment_info_for_email(IN p_id_cita INT)
BEGIN
   select concat(p.nombre,' ',p.apellido) paciente, c.email,date_format(c.fecha,'%d/%m/%Y') fecha,
       date_format(c.fecha,'%H:%i') hora, concat(p2.nombre,' ',p2.apellido) atiende, c2.nombre clinica, c2.ubicacion from cita c
join persona p on c.id_persona = p.id_persona
join clinica c2 on c.id_clinica = c2.id_clinica
join doctor d on c.id_doctor = d.id_doctor
join usuario u on d.id_usuario = u.id_usuario
join persona p2 on u.id_persona = p2.id_persona
WHERE c.id_cita = p_id_cita;

END;





CREATE OR REPLACE PROCEDURE programasalud.get_assignment_info_for_email(IN p_id_asignacion_deportes INT)
BEGIN

    select ad.id_asignacion_deportes, concat(p.nombre,' ',p.apellido) persona, p.email, d.nombre disciplina from asignacion_deportes ad
    join persona p on ad.id_persona = p.id_persona
    join disciplina d on ad.id_disciplina = d.id_disciplina
    where ad.id_asignacion_deportes=p_id_asignacion_deportes;

END;







CREATE OR REPLACE PROCEDURE programasalud.get_patient(IN p_id_persona INT)
BEGIN
    SELECT p.id_persona, p.nombre, p.apellido, concat(p.nombre,' ',p.apellido) nombre_completo,
           DATE_FORMAT(p.fecha_nacimiento ,'%d/%m/%Y') fecha_nacimiento, p.sexo, p.email, COALESCE(p.telefono,'') telefono,
           COALESCE(p.cui,'') cui, COALESCE(p.carnet,'') carnet, COALESCE(p.nov,'') nov, COALESCE(p.regpersonal,'') regpersonal,
           p.source, if(p.source='CREATED','Creado manualmente',if(p.source='CC_STUDENT','Estudiante migrado',if(p.source='CC_EMPLOYEE','Empleado migrado',if(p.source='DEPORTES','Creado en el formulario de deportes','')))) origen,
           p.carrera, p.departamento
    FROM persona p
    WHERE p.id_persona !=1
    AND p.id_persona=p_id_persona;
END;














CREATE OR REPLACE PROCEDURE programasalud.update_person_info (IN p_id_persona INT, IN p_nombre VARCHAR(500), IN p_apellido VARCHAR(500), IN p_fecha_nacimiento VARCHAR(10),
                                            IN p_sexo VARCHAR(1), IN p_email VARCHAR(50), IN p_telefono VARCHAR(8),
                                            IN p_cui VARCHAR(13), IN p_nov VARCHAR(10), IN p_regpersonal VARCHAR(9), IN p_carnet VARCHAR(9),
                                            OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN

    DECLARE v_temp INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;


    START TRANSACTION;

    /* check for already created persons, search by id */
        select count(1) into v_temp
        from persona
        where id_persona != p_id_persona AND ((cui=p_cui and cui is not null and p_cui!='')
        or (nov=p_nov and nov is not null and p_nov!='')
        or (regpersonal=p_regpersonal and regpersonal is not null and p_regpersonal!='')
        or (carnet = p_carnet and carnet is not null and p_carnet!=''));

    IF v_temp = 0 THEN

        UPDATE persona
        SET
            nombre= UPPER(TRIM(p_nombre)),
            apellido = (UPPER(TRIM(p_apellido))),
            fecha_nacimiento = str_to_date(p_fecha_nacimiento,'%d/%m/%Y'),
            sexo = UPPER(p_sexo),
            email = LOWER(TRIM(p_email)),
            telefono = TRIM(p_telefono),
            cui = if(p_cui is null or p_cui='',null,p_cui),
            nov=if(p_nov is null or p_nov='',null,p_nov),
            regpersonal=if(p_regpersonal is null or p_regpersonal='',null,p_regpersonal),
            carnet=if(p_carnet is null or p_carnet='',null,p_carnet),
            updated = now()
        WHERE
              id_persona = p_id_persona;

        SET o_result = 1;
        SET o_mensaje = 'Registro actualizado correctamente';


    ELSE
        SET o_mensaje = 'Ya existe una persona con esa identificación';
    END IF;

    COMMIT;

END;







CREATE OR REPLACE PROCEDURE programasalud.get_categorias_convivencia()
BEGIN
    SELECT id_categoria_convivencia, nombre FROM categoria_convivencia
    WHERE activo;
END;





CREATE OR REPLACE PROCEDURE programasalud.get_lugares_convivencia(IN p_id_categoria_convivencia INT)
BEGIN
    SELECT id_lugar_convivencia, nombre FROM lugar_convivencia
    WHERE activo AND id_categoria_convivencia=p_id_categoria_convivencia;
END;












CREATE OR REPLACE PROCEDURE programasalud.registrar_datos_estudiante (IN p_nombre VARCHAR(500), IN p_apellido VARCHAR(500),
                                                             IN p_fecha_nacimiento VARCHAR(10), IN p_sexo VARCHAR(1), IN p_email VARCHAR(50),
                                                             IN p_cui NUMERIC(13,0), IN p_nov NUMERIC(10,0), IN p_carnet NUMERIC(9,0),  IN p_carrera VARCHAR(2),
                                                             IN p_telefono VARCHAR(8), IN p_telefono_emergencia VARCHAR(8), IN p_contacto_emergencia VARCHAR(150),
                                                             IN p_peso INT, IN p_estatura DECIMAL(5,2),
                                                             IN p_flag_tiene_discapacidad VARCHAR(1), IN p_id_tipo_discapacidad INT, IN p_id_tipo_enfermedad INT, IN p_id_disciplina_persona INT,
                                                             OUT o_result INT, OUT o_mensaje VARCHAR(500))
BEGIN

    DECLARE v_temp INT;
    DECLARE v_flg_existe_persona INT;
    DECLARE v_flg_existe_ficha INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET o_result = -1;

    START TRANSACTION;

    -- revisar si existe la persona
    SELECT count(1), coalesce(id_persona,-1) INTO v_flg_existe_persona, v_temp
    FROM persona WHERE
       (cui=p_cui AND cui IS NOT NULL)
        OR (nov=p_nov AND nov IS NOT NULL)
        OR (carnet=p_carnet AND carnet IS NOT NULL);



        -- crear la persona
    IF v_flg_existe_persona= 0 THEN
        SET v_temp = create_or_update_student_from_cc(p_nombre,p_apellido, p_fecha_nacimiento, p_sexo,p_email,p_telefono,p_cui,p_nov, p_carnet, p_carrera);
        UPDATE persona p SET source = 'ESTUDIANTE' WHERE p.id_persona=v_temp;
    END IF;


    -- ficha de la persona
    SELECT count(1) INTO v_flg_existe_ficha
    FROM persona_ficha
    WHERE id_persona = v_temp;

    IF v_flg_existe_ficha > 0 THEN
        UPDATE persona_ficha
        SET
            telefono_emergencia = p_telefono_emergencia,
            contacto_emergencia = p_contacto_emergencia,
            flag_tiene_discapacidad = (p_flag_tiene_discapacidad = '1'),
            id_tipo_discapacidad = if(p_flag_tiene_discapacidad = '1',p_id_tipo_discapacidad,null ),
            id_tipo_enfermedad = p_id_tipo_enfermedad,
            id_disciplina_persona = p_id_disciplina_persona,
            actualizado = NOW()
        WHERE id_persona = v_temp;
    ELSE
        INSERT INTO persona_ficha (id_persona, flag_tiene_discapacidad, id_tipo_discapacidad, telefono_emergencia, contacto_emergencia, id_tipo_enfermedad, id_disciplina_persona)
        VALUES (v_temp,(p_flag_tiene_discapacidad = '1'), if(p_flag_tiene_discapacidad = '1',p_id_tipo_discapacidad,null ), p_telefono_emergencia, p_contacto_emergencia, p_id_tipo_enfermedad,p_id_disciplina_persona);
    END IF;

    -- medidas
    INSERT INTO persona_medida (id_medida, id_persona, valor)
    VALUES
    (1,v_temp,p_peso),
    (2,v_temp,p_estatura);

    SET o_result = v_temp;
    SET o_mensaje = 'Registro ingresado correctamente';



    COMMIT;

END;




CREATE OR REPLACE PROCEDURE programasalud.get_disease_types()
BEGIN
    SELECT id_tipo_enfermedad, nombre
    FROM tipo_enfermedad
    WHERE activo;
END;




CREATE OR REPLACE PROCEDURE programasalud.get_discipline_types()
BEGIN
    SELECT id_disciplina_persona, nombre
    FROM disciplina_persona
    WHERE activo;
END;












CREATE OR REPLACE PROCEDURE programasalud.registrar_datos_empleado (IN p_cui NUMERIC(13,0),IN p_fecha_nacimiento VARCHAR(10),IN p_telefono VARCHAR(8),
                                                                    IN p_telefono_emergencia VARCHAR(8), IN p_contacto_emergencia VARCHAR(150),
                                                                    IN p_peso INT, IN p_estatura DECIMAL(5,2),
                                                                    IN p_flag_tiene_discapacidad VARCHAR(1), IN p_id_tipo_discapacidad INT, IN p_id_tipo_enfermedad INT, IN p_id_disciplina_persona INT,
                                                                    IN p_nombre VARCHAR(500), IN p_apellido VARCHAR(500),
                                                                    IN p_sexo VARCHAR(1), IN p_email VARCHAR(50),
                                                                    IN p_regpersonal NUMERIC(9,0),  IN p_departamento VARCHAR(120),
                                                                    OUT o_result INT, OUT o_mensaje VARCHAR(500))
BEGIN

    DECLARE v_temp INT;
    DECLARE v_flg_existe_persona INT;
    DECLARE v_flg_existe_ficha INT;
    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET o_result=-1;
            SET o_mensaje='El registro ya existe';
            ROLLBACK;
        END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_result=-1;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    SET o_result = -1;

    START TRANSACTION;

    -- revisar si existe la persona
    SELECT count(1), coalesce(id_persona,-1) INTO v_flg_existe_persona, v_temp
    FROM persona WHERE
       (cui=p_cui AND cui IS NOT NULL)
        OR (regpersonal=p_regpersonal AND regpersonal IS NOT NULL);



        -- crear la persona
    IF v_flg_existe_persona= 0 THEN
        SET v_temp = create_or_update_employee_from_cc(p_nombre,p_apellido, p_fecha_nacimiento, p_sexo,p_email,p_cui,p_regpersonal, p_departamento);
        UPDATE persona p SET source = 'EMPLEADO', p.telefono = p_telefono WHERE p.id_persona=v_temp;
    END IF;


    -- ficha de la persona
    SELECT count(1) INTO v_flg_existe_ficha
    FROM persona_ficha
    WHERE id_persona = v_temp;

    IF v_flg_existe_ficha > 0 THEN
        UPDATE persona_ficha
        SET
            telefono_emergencia = p_telefono_emergencia,
            contacto_emergencia = p_contacto_emergencia,
            flag_tiene_discapacidad = (p_flag_tiene_discapacidad = '1' OR p_flag_tiene_discapacidad = 1),
            id_tipo_discapacidad = if(p_flag_tiene_discapacidad = '1' OR p_flag_tiene_discapacidad = 1,p_id_tipo_discapacidad,null ),
            id_tipo_enfermedad = p_id_tipo_enfermedad,
            id_disciplina_persona = p_id_disciplina_persona,
            actualizado = NOW()
        WHERE id_persona = v_temp;
    ELSE
        INSERT INTO persona_ficha (id_persona, flag_tiene_discapacidad, id_tipo_discapacidad, telefono_emergencia, contacto_emergencia, id_tipo_enfermedad, id_disciplina_persona)
        VALUES (v_temp,(p_flag_tiene_discapacidad = '1' OR p_flag_tiene_discapacidad = 1), if(p_flag_tiene_discapacidad = '1' OR p_flag_tiene_discapacidad = 1,p_id_tipo_discapacidad,null ), p_telefono_emergencia, p_contacto_emergencia, p_id_tipo_enfermedad,p_id_disciplina_persona);
    END IF;

    -- medidas
    INSERT INTO persona_medida (id_medida, id_persona, valor)
    VALUES
    (1,v_temp,p_peso),
    (2,v_temp,p_estatura);

    SET o_result = 1;
    SET o_mensaje = 'Registro ingresado correctamente';



    COMMIT;

END;



CREATE OR REPLACE PROCEDURE programasalud.get_reports(IN p_id_usuario VARCHAR(50))
BEGIN
    select distinct r.id_reporte,nombre from reporte r
    join reporte_rol rr on r.id_reporte = rr.id_reporte
    join usuario_rol ur on rr.id_rol = ur.id_rol and ur.activo
    where r.activo and ur.id_usuario=p_id_usuario
    ORDER BY r.nombre;
END;





CREATE OR REPLACE PROCEDURE programasalud.get_reportparams(IN p_id_reporte INT, IN p_id_usuario VARCHAR(50))
BEGIN
    select distinct rp.id_reporte_parametro, rp.display_name, rp.var_name, rp.var_type, rp.moreinfo
from reporte_parametro rp
join reporte r on rp.id_reporte = r.id_reporte and r.id_reporte=p_id_reporte
join reporte_rol rr on r.id_reporte = rr.id_reporte
join usuario_rol ur on ur.id_rol=rr.id_rol and ur.id_usuario=p_id_usuario and ur.activo
    WHERE rp.activo ORDER BY rp.orden;
END;



CREATE OR REPLACE PROCEDURE programasalud.get_report_data_and_params(IN p_id_reporte INT, IN p_id_usuario VARCHAR(50))
BEGIN
    select distinct
        rp.id_reporte_parametro, r.nombre, r.sp_name, rp.display_name, rp.var_name, rp.var_type
    from reporte r
    left join reporte_parametro rp on r.id_reporte = rp.id_reporte AND rp.activo
    join reporte_rol rr on r.id_reporte = rr.id_reporte
    join usuario_rol ur on rr.id_rol = ur.id_rol and ur.activo
    where r.activo  and ur.id_usuario=p_id_usuario
     AND r.id_reporte=p_id_reporte
    order by rp.orden;

END;








CREATE OR REPLACE PROCEDURE programasalud.get_clinica_acciones(IN p_id_clinica VARCHAR(50))
BEGIN

    SELECT ca.id_clinica_accion, a.nombre,
           ca.activo
    FROM clinica_accion ca
    JOIN accion a on ca.id_accion = a.id_accion
    WHERE a.activo AND ca.id_clinica=p_id_clinica;

END;




CREATE OR REPLACE PROCEDURE programasalud.update_clinica_accion(IN p_id_clinica_accion VARCHAR(50), IN p_activo VARCHAR(50), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT('Ocurrió un error: ',@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM clinica_accion c
    WHERE c.id_clinica_accion=p_id_clinica_accion;

    if o_result > 0 THEN

        UPDATE
            clinica_accion c
        SET
            c.activo=(p_activo='true')
        WHERE
            c.id_clinica_accion=p_id_clinica_accion;

        SET o_result = 1;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_result = -1;
        SET o_mensaje = 'Registro no existe';
    END IF;
    COMMIT;

END;




CREATE OR REPLACE PROCEDURE programasalud.valida_estudiante(IN p_carnet VARCHAR(9))
BEGIN

    select count(p.id_persona) asignado from persona p
join persona_ficha pf on p.id_persona = pf.id_persona
where p.carnet=p_carnet;

END;