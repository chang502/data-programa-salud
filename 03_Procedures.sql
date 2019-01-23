

CREATE OR REPLACE FUNCTION programasalud.initcap(x varchar(50)) RETURNS varchar(50)
BEGIN
    RETURN concat(upper(substr(trim(X), 1,1)), lower(substr(trim(X), 2)));
END ;




CREATE OR REPLACE PROCEDURE programasalud.create_user (IN p_id_usuario VARCHAR(50), IN p_clave VARCHAR(64), IN p_primer_nombre VARCHAR(50), IN p_segundo_nombre VARCHAR(50),
                                            IN p_primer_apellido VARCHAR(50), IN p_segundo_apellido VARCHAR(50), IN p_fecha_nacimiento VARCHAR(10),
                                            IN p_sexo VARCHAR(50), IN p_email VARCHAR(50), IN p_telefono VARCHAR(8), OUT o_result INT, OUT o_mensaje VARCHAR(100))
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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;

    INSERT INTO programasalud.persona (primer_nombre,
                                       segundo_nombre, primer_apellido, segundo_apellido,
                                       fecha_nacimiento, sexo, email, telefono)
    VALUES ( INITCAP(p_primer_nombre), INITCAP(p_segundo_nombre),
             INITCAP(p_primer_apellido), INITCAP(p_segundo_apellido), str_to_date(p_fecha_nacimiento,'%d/%m/%Y'), UPPER(p_sexo), LOWER(p_email), p_telefono);

    SET v_temp = LAST_INSERT_ID();
    SET o_result = v_temp;


    INSERT INTO programasalud.usuario (id_usuario, clave, id_persona, activo, cambiar_clave)
    VALUES (LOWER(p_id_usuario), p_clave, v_temp, True, False);

    insert into programasalud.usuario_rol (id_usuario, id_rol, activo)
    select p_id_usuario, id_rol, false from programasalud.rol;

    SET o_mensaje = 'Registro ingresado correctamente';

    COMMIT;
END;










CREATE OR REPLACE PROCEDURE programasalud.get_user(IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT u.id_usuario, p.primer_nombre, p.segundo_nombre,
           p.primer_apellido, p.segundo_apellido,
           DATE_FORMAT(p.fecha_nacimiento, '%d/%m/%Y') fecha_nacimiento, LOWER(p.sexo) sexo, p.email, p.telefono
    FROM usuario u join persona p on u.id_persona=p.id_persona
    WHERE u.activo
      AND u.id_usuario=p_id_usuario;
END;












CREATE OR REPLACE PROCEDURE programasalud.update_user(IN p_id_usuario VARCHAR(50), IN p_clave VARCHAR(64), IN p_primer_nombre VARCHAR(50), IN p_segundo_nombre VARCHAR(50),
                                           IN p_primer_apellido VARCHAR(50), IN p_segundo_apellido VARCHAR(50), IN p_fecha_nacimiento VARCHAR(10),
                                           IN p_sexo VARCHAR(50), IN p_email VARCHAR(50), IN p_telefono VARCHAR(98), IN p_cambiar_clave VARCHAR(1), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE persona_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
        END;


    SET persona_id = -1;


    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM usuario u
    WHERE u.id_usuario=p_id_usuario;



    if o_result>0 THEN

        select u.id_persona into persona_id from usuario u
        where u.id_usuario=p_id_usuario;

        UPDATE
            persona p
        SET
            p.primer_nombre = INITCAP(p_primer_nombre),
            p.segundo_nombre = INITCAP(p_segundo_nombre),
            p.primer_apellido = INITCAP(p_primer_apellido),
            p.segundo_apellido = INITCAP(p_segundo_apellido),
            p.sexo = UPPER(p_sexo),
            p.fecha_nacimiento=str_to_date(p_fecha_nacimiento,'%d/%m/%Y'),
            p.email=LOWER(p_email),
            p.telefono=p_telefono
        WHERE
                p.id_persona = persona_id;


        IF p_clave = "" THEN
            UPDATE
                usuario u
            SET
                u.cambiar_clave = (p_cambiar_clave = "1")
            WHERE
                    u.id_usuario=p_id_usuario;
        ELSE
            UPDATE
                usuario u
            SET
                u.cambiar_clave = (p_cambiar_clave = "1"),
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










CREATE OR REPLACE PROCEDURE programasalud.get_user_roles(IN p_id_usuario VARCHAR(50))
BEGIN

    SELECT u.id_usuario_rol, r.nombre_rol, r.descripcion_rol, u.activo
    FROM usuario_rol u
             JOIN rol r ON u.id_rol=r.id_rol
    WHERE u.id_usuario=p_id_usuario
    ORDER BY u.id_usuario_rol
    ;
END;










CREATE OR REPLACE PROCEDURE programasalud.update_user_role(IN p_id_usuario_rol VARCHAR(50), IN p_activo VARCHAR(50), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
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















CREATE OR REPLACE PROCEDURE programasalud.delete_user(IN p_id_usuario VARCHAR(50), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
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










CREATE OR REPLACE PROCEDURE programasalud.create_doctor (IN p_id_usuario VARCHAR(50), OUT o_result INT, OUT o_mensaje VARCHAR(100))
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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;


    SELECT COUNT(1) INTO o_result
    FROM usuario u
    WHERE u.id_usuario= p_id_usuario
      AND u.activo=TRUE;

    SELECT count(*) INTO v_temp FROM doctor d  WHERE d.id_usuario=p_id_usuario AND d.activo=FALSE;

    IF o_result > 0 THEN

        IF v_temp > 0 THEN # ---- valor ya existe pero está inactivo

            UPDATE doctor d
            SET d.activo = TRUE
            WHERE
                    d.id_usuario=p_id_usuario;

        ELSE

            INSERT INTO programasalud.doctor (id_usuario, activo)
            VALUES ( p_id_usuario, TRUE);

            SET o_result = LAST_INSERT_ID();

            INSERT INTO programasalud.doctor_especialidad (id_doctor, id_especialidad, activo)
            SELECT o_result, id_especialidad, FALSE FROM programasalud.especialidad;


            INSERT INTO programasalud.clinica_doctor (id_clinica, id_doctor, activo)
            SELECT id_clinica, o_result, FALSE
            FROM clinica;



        END IF;





        SET o_mensaje = 'Registro ingresado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;

    COMMIT;

END;







CREATE OR REPLACE PROCEDURE programasalud.get_doctores()
BEGIN

    SELECT
        d.id_doctor, u.id_usuario,
        CONCAT(TRIM(CONCAT(p.primer_nombre,' ',p.segundo_nombre)),' ',TRIM(CONCAT(p.primer_apellido,' ', p.segundo_apellido))) nombre,
        DATE_FORMAT(p.fecha_nacimiento, '%d/%m/%Y') fecha_nacimiento, UPPER(p.sexo) sexo,
        p.telefono, p.email
    FROM doctor d
             JOIN usuario u ON d.id_usuario=u.id_usuario
             JOIN persona p ON u.id_persona=p.id_persona
    WHERE
        d.activo AND u.activo;

END;






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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
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









CREATE OR REPLACE PROCEDURE programasalud.delete_doctor(IN p_id_doctor INT(20), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
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








CREATE OR REPLACE PROCEDURE programasalud.update_doctor_especialidad(IN p_id_doctor_especialidad VARCHAR(50), IN p_activo VARCHAR(50), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
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

















CREATE OR REPLACE PROCEDURE programasalud.get_tipos_medida()
BEGIN

    SELECT tdm.id_tipo_dato, tdm.tipo_dato
    FROM tipo_dato_medida tdm
    WHERE tdm.activo=TRUE
    ORDER BY tdm.id_tipo_dato;

END;







CREATE OR REPLACE PROCEDURE programasalud.create_measurement (IN p_nombre VARCHAR(50), IN p_id_tipo_dato INT(20), IN p_unidad_medida VARCHAR(50), IN p_valor_minimo VARCHAR(50),
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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;





    INSERT INTO programasalud.medida (nombre,
                                      id_tipo_dato, unidad_medida, valor_minimo,
                                      valor_maximo, obligatorio, activo)
    VALUES ( initcap(p_nombre), p_id_tipo_dato,
             initcap(p_unidad_medida), p_valor_minimo, p_valor_maximo, (p_obligatorio = "1"), TRUE);

    SET o_result = LAST_INSERT_ID();



    INSERT INTO programasalud.clinica_medida (id_clinica, id_medida, activo)
    SELECT id_clinica, o_result, FALSE
    FROM clinica;



    SET o_mensaje = 'Registro ingresado correctamente';

    COMMIT;

END;







CREATE OR REPLACE PROCEDURE programasalud.get_measurements()
BEGIN

    SELECT
        m.id_medida,
        INITCAP(m.nombre) nombre, tdm.tipo_dato,
        INITCAP(m.unidad_medida) unidad_medida,
        m.valor_minimo, m.valor_maximo,
        if(m.obligatorio,'Sí','No') obligatorio
    FROM medida m
             JOIN tipo_dato_medida tdm ON m.id_tipo_dato=tdm.id_tipo_dato
    WHERE m.activo;

END;






CREATE OR REPLACE PROCEDURE programasalud.get_measurement(IN p_id_medida INT)
BEGIN

    SELECT
        m.id_medida,
        INITCAP(m.nombre) nombre, tdm.id_tipo_dato, tdm.tipo_dato,
        INITCAP(m.unidad_medida) unidad_medida,
        m.valor_minimo, m.valor_maximo, m.obligatorio,
        if(m.obligatorio,'Sí','No') obligatorio_txt
    FROM medida m
             JOIN tipo_dato_medida tdm ON m.id_tipo_dato=tdm.id_tipo_dato
    WHERE m.activo
      AND m.id_medida=p_id_medida;

END;









CREATE OR REPLACE PROCEDURE programasalud.update_measurement ( IN p_id_medida INT(20), IN p_nombre VARCHAR(50), IN p_id_tipo_dato INT(20), IN p_unidad_medida VARCHAR(50), IN p_valor_minimo VARCHAR(50),
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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
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
            m.nombre=INITCAP(p_nombre),
            m.id_tipo_dato=p_id_tipo_dato,
            m.unidad_medida=p_unidad_medida,
            m.valor_minimo=p_valor_minimo,
            m.valor_maximo=p_valor_maximo,
            m.obligatorio=(p_obligatorio = "1")
        WHERE
                m.id_medida=p_id_medida;



        SET o_mensaje = 'Registro ingresado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;

    COMMIT;

END;









CREATE OR REPLACE PROCEDURE programasalud.delete_measurement(IN p_id_medida INT(20), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
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



























CREATE OR REPLACE PROCEDURE programasalud.create_clinic (IN p_nombre VARCHAR(50), IN p_ubicacion VARCHAR(50), IN p_descripcion VARCHAR(255), OUT o_result INT, OUT o_mensaje VARCHAR(100))
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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;





    INSERT INTO programasalud.clinica (nombre, ubicacion,
                                       descripcion, activo)
    VALUES ( initcap(p_nombre), initcap(p_ubicacion), p_descripcion, TRUE);

    SET o_result = LAST_INSERT_ID();

    INSERT INTO programasalud.clinica_doctor (id_clinica, id_doctor, activo)
    SELECT o_result, id_doctor, FALSE
    FROM doctor;

    INSERT INTO programasalud.clinica_medida (id_clinica, id_medida, activo)
    SELECT o_result, id_medida, FALSE
    FROM medida;


    SET o_mensaje = 'Registro ingresado correctamente';

    COMMIT;

END;







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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
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









CREATE OR REPLACE PROCEDURE programasalud.delete_clinic(IN p_id_clinica INT(20), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
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








CREATE OR REPLACE PROCEDURE programasalud.get_clinica_doctores(IN p_id_clinica VARCHAR(50))
BEGIN

    SELECT dc.id_clinica_doctor, CONCAT(TRIM(CONCAT(p.primer_nombre,' ',p.segundo_nombre)),' ',TRIM(CONCAT(p.primer_apellido,' ', p.segundo_apellido))) nombre,
           dc.activo
    FROM clinica_doctor dc
             JOIN doctor d ON dc.id_doctor=d.id_doctor
             JOIN usuario u ON d.id_usuario=u.id_usuario
             JOIN persona p ON u.id_persona=p.id_persona
    WHERE d.activo AND u.activo AND dc.id_clinica=p_id_clinica;

END;







CREATE OR REPLACE PROCEDURE programasalud.update_clinica_doctor(IN p_id_clinica_doctor VARCHAR(50), IN p_activo VARCHAR(50), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
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












CREATE OR REPLACE PROCEDURE programasalud.get_clinica_medidas(IN p_id_clinica VARCHAR(50))
BEGIN

    SELECT cm.id_clinica_medida, cm.activo, m.nombre, t.tipo_dato, m.valor_minimo, m.valor_maximo, if(m.obligatorio,'Sí','No') obligatorio
    FROM clinica_medida cm
             JOIN medida m ON cm.id_medida=m.id_medida
             JOIN tipo_dato_medida t ON m.id_tipo_dato=t.id_tipo_dato
    WHERE m.activo AND t.activo AND cm.id_clinica=p_id_clinica;

END;











CREATE OR REPLACE PROCEDURE programasalud.update_clinica_medida(IN p_id_clinica_medida VARCHAR(50), IN p_activo VARCHAR(50), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
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






CREATE OR REPLACE PROCEDURE programasalud.do_login(IN p_id_usuario VARCHAR(50), IN p_clave VARCHAR(64))
BEGIN
    SELECT u.id_usuario,
           TRIM(CONCAT(p.primer_nombre,' ',COALESCE(p.segundo_nombre,''))) nombres,
           TRIM(CONCAT(p.primer_apellido,' ', COALESCE(p.segundo_apellido,''))) apellidos,
           CONCAT(TRIM(CONCAT(p.primer_nombre,' ',COALESCE(p.segundo_nombre,''))),' ',TRIM(CONCAT(p.primer_apellido,' ', COALESCE(p.segundo_apellido,'')))) nombre,
           COALESCE(p.email,'') email, COALESCE(p.telefono,'') telefono,
           COALESCE((SELECT TRUE FROM usuario_rol ur1 WHERE ur1.id_usuario=u.id_usuario AND ur1.activo AND ur1.id_rol=8701),FALSE) hasClinica,
           COALESCE((SELECT TRUE FROM usuario_rol ur1 WHERE ur1.id_usuario=u.id_usuario AND ur1.activo AND ur1.id_rol=8702),FALSE) hasDeportes,
           COALESCE((SELECT TRUE FROM usuario_rol ur1 WHERE ur1.id_usuario=u.id_usuario AND ur1.activo AND ur1.id_rol=8703),FALSE) hasProgramaSalud,
           COALESCE((SELECT TRUE FROM usuario_rol ur1 WHERE ur1.id_usuario=u.id_usuario AND ur1.activo AND ur1.id_rol=8704),FALSE) isAdmin,
           COALESCE(u.cambiar_clave,FALSE) as cambiar_clave
    FROM usuario u
             JOIN persona p ON u.id_persona = p.id_persona
    WHERE u.activo
      AND u.id_usuario=p_id_usuario
      AND u.clave=p_clave;
END;





CREATE OR REPLACE PROCEDURE programasalud.do_password_reset(IN p_id_usuario VARCHAR(50), IN p_email VARCHAR(50), IN p_clave VARCHAR(64), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
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
            TRIM(CONCAT(p.primer_nombre,' ',p.segundo_nombre)) INTO o_mensaje
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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
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








CREATE OR REPLACE PROCEDURE programasalud.create_discipline (IN p_nombre VARCHAR(100), IN p_limite INT, IN p_semestre VARCHAR(6), IN p_primer_nombre VARCHAR(50), IN p_segundo_nombre VARCHAR(50),
                                                  IN p_primer_apellido VARCHAR(50), IN p_segundo_apellido VARCHAR(50), IN p_fecha_nacimiento VARCHAR(10),
                                                  IN p_sexo VARCHAR(50), IN p_email VARCHAR(50), IN p_telefono VARCHAR(8), OUT o_result INT, OUT o_mensaje VARCHAR(100))
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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;

    INSERT INTO programasalud.persona (primer_nombre,
                                       segundo_nombre, primer_apellido, segundo_apellido,
                                       fecha_nacimiento, sexo, email, telefono)
    VALUES ( INITCAP(p_primer_nombre), INITCAP(p_segundo_nombre),
             INITCAP(p_primer_apellido), INITCAP(p_segundo_apellido), str_to_date(p_fecha_nacimiento,'%d/%m/%Y'), UPPER(p_sexo), LOWER(p_email), p_telefono);

    SET v_temp = LAST_INSERT_ID();
    SET o_result = v_temp;





    INSERT INTO programasalud.disciplina (nombre, limite, semestre, id_persona, activo)
    VALUES ( initcap(p_nombre), p_limite, upper(p_semestre), v_temp, TRUE);

    SET o_result = LAST_INSERT_ID();

    SET o_mensaje = 'Registro ingresado correctamente';

    COMMIT;

END;







CREATE OR REPLACE PROCEDURE programasalud.get_disciplines()
BEGIN

    SELECT
        d.id_disciplina,
        d.nombre,
        d.limite,
        d.semestre,
        CONCAT(TRIM(CONCAT(p.primer_nombre,' ',p.segundo_nombre)),' ',TRIM(CONCAT(p.primer_apellido,' ', p.segundo_apellido))) nombre_encargado
    FROM
        disciplina d
            JOIN persona p ON p.id_persona=d.id_persona
    WHERE
        d.activo;

END;






CREATE OR REPLACE PROCEDURE programasalud.get_discipline(IN p_id_disciplina INT)
BEGIN

    SELECT
        d.id_disciplina,
        d.nombre,
        d.limite,
        d.semestre,
        p.id_persona,
        p.primer_nombre,
        p.segundo_nombre,
        p.primer_apellido,
        p.segundo_apellido,
        DATE_FORMAT(p.fecha_nacimiento, '%d/%m/%Y') fecha_nacimiento,
        p.sexo,
        p.email,
        p.telefono
    FROM
        disciplina d
            JOIN persona p ON d.id_persona=p.id_persona
    WHERE
        d.activo
      AND d.id_disciplina=p_id_disciplina;

END;









CREATE OR REPLACE PROCEDURE programasalud.update_discipline ( IN p_id_disciplina INT, IN p_nombre VARCHAR(100), IN p_semestre VARCHAR(6), IN p_limite INT,
                                                   IN p_id_persona INT, IN p_primer_nombre VARCHAR(50), IN p_segundo_nombre VARCHAR(50),
                                                   IN p_primer_apellido VARCHAR(50), IN p_segundo_apellido VARCHAR(50), IN p_fecha_nacimiento VARCHAR(10),
                                                   IN p_sexo VARCHAR(50), IN p_email VARCHAR(50), IN p_telefono VARCHAR(8),
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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;


    SELECT COUNT(1) INTO o_result
    FROM disciplina d
    WHERE d.id_disciplina=p_id_disciplina
      AND d.activo;


    IF o_result > 0 THEN

        UPDATE disciplina d
        SET
            d.nombre = INITCAP(trim(p_nombre)),
            d.semestre = UPPER(trim(p_semestre)),
            d.limite = p_limite
        WHERE
                d.id_disciplina = p_id_disciplina;


        UPDATE persona p
        SET
            p.primer_nombre = INITCAP(p_primer_nombre),
            p.segundo_nombre = INITCAP(p_segundo_nombre),
            p.primer_apellido = INITCAP(p_primer_apellido),
            p.segundo_apellido = INITCAP(p_segundo_apellido),
            p.fecha_nacimiento = str_to_date(p_fecha_nacimiento,'%d/%m/%Y'),
            p.sexo = p_sexo,
            p.email = LOWER(p_email),
            p.telefono = p.telefono
        WHERE p.id_persona = p_id_persona;



        SET o_mensaje = 'Registro ingresado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;

    COMMIT;

END;









CREATE OR REPLACE PROCEDURE programasalud.delete_discipline(IN p_id_disciplina INT(20), OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
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
                                                     IN p_estado VARCHAR(200), IN p_observaciones VARCHAR(1000), OUT o_result INT, OUT o_mensaje VARCHAR(100))
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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
        END;

    SET o_result = -1;

    START TRANSACTION;

    INSERT INTO programasalud.bebedero (nombre,
                                        ubicacion, fecha_mantenimiento, observaciones,
                                        estado, activo)
    VALUES ( INITCAP(p_nombre), INITCAP(p_ubicacion),
             str_to_date(p_fecha_mantenimiento,'%d/%m/%Y'), INITCAP(p_observaciones), INITCAP(p_estado), TRUE);

    SET o_result = LAST_INSERT_ID();

    SET o_mensaje = 'Registro ingresado correctamente';

    COMMIT;

END;












CREATE OR REPLACE PROCEDURE programasalud.get_drinkfountains()
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
        b.activo;

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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
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
            b.observaciones = INITCAP(TRIM(p_observaciones))
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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM bebedero b
    WHERE b.id_bebedero = p_id_bebedero;


    if o_result>0 THEN
        UPDATE
            bebedero b
        SET
            b.activo=false
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


















CREATE OR REPLACE PROCEDURE programasalud.create_playground (IN p_nombre VARCHAR(100), IN p_ubicacion VARCHAR(250), IN p_cantidad DECIMAL(10,4), IN p_id_unidad_medida INT,
                                                  IN p_anio INT, IN p_costo DECIMAL(10,4), IN p_estado VARCHAR(200), IN p_observaciones VARCHAR(1000),
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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
        END;

    SET o_result = -1;

    START TRANSACTION;

    INSERT INTO programasalud.espacio_convivencia (nombre,ubicacion,cantidad,id_unidad_medida,anio,costo,estado,observaciones)
    VALUES ( INITCAP(p_nombre), INITCAP(p_ubicacion), p_cantidad,
             p_id_unidad_medida, p_anio, p_costo, INITCAP(p_estado), INITCAP(p_observaciones));

    SET o_result = LAST_INSERT_ID();

    SET o_mensaje = 'Registro ingresado correctamente';

    COMMIT;

END;












CREATE OR REPLACE PROCEDURE programasalud.get_playgrounds()
BEGIN
    SELECT
        b.id_espacio_convivencia,
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
        b.observaciones
    FROM
        espacio_convivencia b
    JOIN unidad_medida um on b.id_unidad_medida = um.id_unidad_medida AND um.activo
    WHERE
        b.activo;

END;






CREATE OR REPLACE PROCEDURE programasalud.get_playground(IN p_id_espacio_convivencia INT)
BEGIN

    SELECT
        b.id_espacio_convivencia,
        b.nombre,
        b.ubicacion,
        b.cantidad,
        um.id_unidad_medida,
        um.nombre nombre_medida,
        um.nombre_corto,
        b.anio,
        b.costo,
        b.estado,
        b.observaciones
    FROM
        espacio_convivencia b
    JOIN unidad_medida um on b.id_unidad_medida = um.id_unidad_medida AND um.activo
    WHERE
        b.activo
      AND b.id_espacio_convivencia=p_id_espacio_convivencia;

END;






CREATE OR REPLACE PROCEDURE programasalud.update_playground ( IN p_id_espacio_convivencia INT, IN p_nombre VARCHAR(100), IN p_ubicacion VARCHAR(250), IN p_cantidad DECIMAL(10,4),
                                                   IN p_id_unidad_medida INT, IN p_anio INT, IN p_costo DECIMAL(10,4), IN p_estado VARCHAR(200), IN p_observaciones VARCHAR(1000),
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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
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
            b.nombre = INITCAP(trim(p_nombre)),
            b.ubicacion = INITCAP(trim(p_ubicacion)),
            b.cantidad = p_cantidad,
            b.id_unidad_medida = p_id_unidad_medida,
            b.anio = p_anio,
            b.costo = p_costo,
            b.estado = INITCAP(TRIM(p_estado)),
            b.observaciones = INITCAP(TRIM(p_observaciones))
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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM espacio_convivencia b
    WHERE b.id_espacio_convivencia = p_id_espacio_convivencia;


    if o_result>0 THEN
        UPDATE
            espacio_convivencia b
        SET
            b.activo=false
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

















CREATE OR REPLACE PROCEDURE programasalud.get_document_types()
BEGIN

    SELECT
        t.id_tipo_documento,
        t.nombre
    FROM
        tipo_documento t
    WHERE
        t.activo;
END;












-- scripts para deportes


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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
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

















CREATE OR REPLACE PROCEDURE programasalud.get_students(IN p_id_tipo_documento INT, IN p_numero_documento VARCHAR(200), IN p_disciplina INT)
BEGIN

    SELECT
        e.id_estudiante_deportes,
        e.id_tipo_documento,
        t.nombre tipo_documento,
        e.numero_documento,
        LOWER(e.email) email,
        e.peso,
        e.estatura,
        if(e.cualidades_especiales,'Sí','No') cualidades_especiales,
        e.id_disciplina,
        d.nombre disciplina
    FROM
        estudiante_deportes e
            JOIN tipo_documento t ON e.id_tipo_documento=t.id_tipo_documento AND t.activo
            JOIN disciplina d ON e.id_disciplina = d.id_disciplina AND d.activo
    WHERE
        e.activo
      AND (p_id_tipo_documento IS NULL OR e.id_tipo_documento=p_id_tipo_documento)
      AND (p_numero_documento IS NULL OR LOWER(e.numero_documento) like p_numero_documento)
      AND (p_disciplina IS NULL OR e.id_disciplina = p_disciplina)
    ;

END;






CREATE OR REPLACE PROCEDURE programasalud.get_student(IN p_id_estudiante_deportes INT)
BEGIN

    SELECT
        e.id_estudiante_deportes,
        e.id_tipo_documento,
        t.nombre tipo_documento,
        e.numero_documento,
        LOWER(e.email) email,
        e.peso,
        e.estatura,
        if(e.cualidades_especiales,1,0) cualidadesespeciales,
        if(e.cualidades_especiales,'Sí','No') cualidades_especiales,
        e.id_disciplina,
        d.nombre disciplina
    FROM
        estudiante_deportes e
            JOIN tipo_documento t ON e.id_tipo_documento=t.id_tipo_documento AND t.activo
            JOIN disciplina d ON e.id_disciplina = d.id_disciplina AND d.activo
    WHERE
        e.activo
      AND e.id_estudiante_deportes = p_id_estudiante_deportes
    ;

END;






CREATE OR REPLACE PROCEDURE programasalud.update_student ( IN p_id_estudiante_deportes INT, IN p_id_tipo_documento INT, IN p_numero_documento VARCHAR(200),
                                                IN p_email VARCHAR(50), IN p_peso INT, IN p_estatura DECIMAL(5,2), IN p_cualidades_especiales VARCHAR(20), IN p_id_disciplina INT,
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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
        END;

    SET v_temp = -1;

    START TRANSACTION;


    SELECT COUNT(1) INTO o_result
    FROM estudiante_deportes e
    WHERE e.id_estudiante_deportes=p_id_estudiante_deportes
      AND e.activo;


    IF o_result > 0 THEN

        UPDATE estudiante_deportes e
        SET
            e.id_tipo_documento = p_id_tipo_documento,
            e.numero_documento = p_numero_documento,
            e.email = lower(trim(p_email)),
            e.peso = p_peso,
            e.estatura = p_estatura,
            e.cualidades_especiales = p_cualidades_especiales,
            e.id_disciplina = p_id_disciplina
        WHERE
                e.id_estudiante_deportes = p_id_estudiante_deportes;



        SET o_mensaje = 'Registro ingresado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;

    COMMIT;

END;









CREATE OR REPLACE PROCEDURE programasalud.delete_student(IN p_id_estudiante_deportes INT, OUT o_result INT, OUT o_mensaje VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
            ROLLBACK;
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(1) INTO o_result
    FROM estudiante_deportes e
    WHERE e.id_estudiante_deportes=p_id_estudiante_deportes
      AND e.activo;



    if o_result>0 THEN
        UPDATE
            estudiante_deportes e
        SET
            e.activo=false
        WHERE
                e.id_estudiante_deportes=p_id_estudiante_deportes;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;


    COMMIT;

END;



























CREATE OR REPLACE PROCEDURE programasalud.create_team (IN p_nombre VARCHAR(255), IN p_descripcion VARCHAR(255), IN p_especialidad VARCHAR(255),
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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
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












CREATE OR REPLACE PROCEDURE programasalud.get_teams()
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
        b.activo;

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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
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
            b.estado = INITCAP(TRIM(p_estado))
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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM seleccion b
    WHERE b.id_seleccion = p_id_seleccion;


    if o_result>0 THEN
        UPDATE
            seleccion b
        SET
            b.activo=false
        WHERE
                b.id_seleccion = p_id_seleccion;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;


    COMMIT;

END;

















CREATE OR REPLACE PROCEDURE programasalud.get_person_types()
BEGIN

    SELECT
        t.id_tipo_persona,
        t.nombre
    FROM
        tipo_persona t
    WHERE
        t.activo;
END;








CREATE OR REPLACE PROCEDURE programasalud.create_championship (IN p_id_seleccion INT, IN p_nombre VARCHAR(255), IN p_fecha VARCHAR(10), IN p_victorioso VARCHAR(1),
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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
        END;

    SET o_result = -1;

    START TRANSACTION;

    INSERT INTO programasalud.campeonato (id_seleccion,
                                          nombre, fecha, victorioso, observaciones,
                                          activo)
    VALUES ( p_id_seleccion, INITCAP(p_nombre), str_to_date(p_fecha,'%d/%m/%Y'),
             IF (p_victorioso='1' , TRUE ,FALSE), p_observaciones, TRUE);

    SET o_result = LAST_INSERT_ID();

    SET o_mensaje = 'Registro ingresado correctamente';

    COMMIT;

END;












CREATE OR REPLACE PROCEDURE programasalud.get_championships()
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
        c.activo;

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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
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
            c.activo = TRUE
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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
        END;

    START TRANSACTION;

    SELECT COUNT(*) INTO o_result
    FROM campeonato c
    WHERE c.id_campeonato = p_id_campeonato;


    if o_result>0 THEN
        UPDATE
            campeonato c
        SET
            c.activo=false
        WHERE
                c.id_campeonato = p_id_campeonato;
        SET o_mensaje = 'Registro actualizado correctamente';
    ELSE
        SET o_mensaje = 'Registro no existe';
    END IF;


    COMMIT;

END;


























































CREATE OR REPLACE PROCEDURE programasalud.assign_discipline (IN p_id_tipo_documento INT, IN p_numero_documento VARCHAR(200), IN p_email VARCHAR(50),
                                            IN p_peso INT, IN p_estatura DECIMAL(5,2),
                                            IN p_cualidades_especiales VARCHAR(1), IN p_id_tipo_discapacidad INT,
                                            IN p_id_disciplina INT,
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
            SET o_mensaje=CONCAT("Ocurrió un error: ",@p2);
        END;

    SET o_result = -1;

    START TRANSACTION;

    INSERT INTO estudiante_deportes (semestre, id_tipo_documento,numero_documento,
                                     email,peso,estatura,cualidades_especiales,
                                     id_tipo_discapacidad,id_disciplina,activo)
                                     VALUES (CONCAT(IF(MONTH(NOW())<7,1,2),'S',YEAR(NOW())),
                                    p_id_tipo_documento,p_numero_documento,p_email, p_peso,
                                             p_estatura, if(p_cualidades_especiales='1',TRUE,FALSE), p_id_tipo_discapacidad, p_id_disciplina,true);

    SET o_result = LAST_INSERT_ID();

    SET o_mensaje = 'Registro ingresado correctamente';

    COMMIT;

END;















/*-------------------------------*/


CREATE OR REPLACE PROCEDURE programasalud.get_users()
BEGIN
    SELECT
        u.id_usuario,
        CONCAT(TRIM(CONCAT(p.primer_nombre,' ',COALESCE(p.segundo_nombre,''))),' ',TRIM(CONCAT(p.primer_apellido,' ', COALESCE(p.segundo_apellido,'')))) nombre,
        p.email, if(u.activo,'Activo','Inactivo') activo
    FROM usuario u
             JOIN persona p ON u.id_persona=p.id_persona
    WHERE u.activo;
END;











CREATE OR REPLACE PROCEDURE programasalud.search_person(IN p_identificacion VARCHAR(50), IN p_nombre_completo VARCHAR(203))
BEGIN
select p.id_persona, primer_nombre, segundo_nombre, primer_apellido, segundo_apellido,
       CONCAT(TRIM(CONCAT(p.primer_nombre,' ',p.segundo_nombre)),' ',TRIM(CONCAT(p.primer_apellido,' ', p.segundo_apellido))) nombre,
       DATE_FORMAT(p.fecha_nacimiento, '%d/%m/%Y') fecha_nacimiento, sexo, email, telefono from persona p
 where lower(CONCAT(TRIM(CONCAT(p.primer_nombre,' ',COALESCE(p.segundo_nombre,''))),' ',TRIM(CONCAT(p.primer_apellido,' ', COALESCE(p.segundo_apellido,''))))) like CONCAT('%',lower(p_nombre_completo),'%')
    limit 30;


END;
