SET GLOBAL log_bin_trust_function_creators = 1;

CREATE OR REPLACE PROCEDURE programasalud.rpt_citas(IN p_fecha_inicio VARCHAR(10),IN p_fecha_fin VARCHAR(10), IN p_id_usuario VARCHAR(50))
BEGIN
    select concat(p.nombre,' ',p.apellido) "Paciente", c2.nombre "Carrera", p.departamento "Departamento / Área", p.fecha_nacimiento "Fecha Nacimiento", p.sexo "Sexo",
    c.sintoma "Síntoma", fc.paso "Estado", fc2.creado "Fecha Creación", c.fecha "Fecha Programada", fc3.creado "Fecha Inicio", fc4.creado "Fecha Finalización", fc5.creado "Fecha Cancelación",
    c3.nombre "Clínica"
    from cita c
    join flujo_cita fc on c.id_cita = fc.id_cita and fc.activo
    join clinica c3 on c.id_clinica = c3.id_clinica
    left join flujo_cita fc2 on c.id_cita = fc2.id_cita and fc2.paso='CREADO'
    left join flujo_cita fc3 on c.id_cita = fc3.id_cita and fc3.paso='ATENDIENDO'
    left join flujo_cita fc4 on c.id_cita = fc4.id_cita and fc4.paso='FINALIZADO'
    left join flujo_cita fc5 on c.id_cita = fc5.id_cita and fc5.paso IN('EDITADO','CANCELADO')
    join persona p on c.id_persona = p.id_persona
    left join carrera c2 on p.carrera = c2.carrera
    join doctor d on c.id_doctor = d.id_doctor and d.id_usuario=p_id_usuario
    WHERE c.fecha between str_to_date(p_fecha_inicio,'%d/%m/%Y') AND str_to_date(p_fecha_fin,'%d/%m/%Y');
END;


CREATE OR REPLACE PROCEDURE programasalud.rpt_citas_admin(IN p_fecha_inicio VARCHAR(10),IN p_fecha_fin VARCHAR(10), IN p_id_usuario VARCHAR(50))
BEGIN
    select concat(p.nombre,' ',p.apellido) "Paciente", c2.nombre "Carrera", p.departamento "Departamento / Área", p.fecha_nacimiento "Fecha Nacimiento", p.sexo "Sexo",
    c.sintoma "Síntoma", fc.paso "Estado", fc2.creado "Fecha Creación", c.fecha "Fecha Programada", fc3.creado "Fecha Inicio", fc4.creado "Fecha Finalización", fc5.creado "Fecha Cancelación",
    c3.nombre "Clínica", concat(p2.nombre,' ',p2.apellido) "Atiende"
    from cita c
    join flujo_cita fc on c.id_cita = fc.id_cita and fc.activo
    join clinica c3 on c.id_clinica = c3.id_clinica
    left join flujo_cita fc2 on c.id_cita = fc2.id_cita and fc2.paso='CREADO'
    left join flujo_cita fc3 on c.id_cita = fc3.id_cita and fc3.paso='ATENDIENDO'
    left join flujo_cita fc4 on c.id_cita = fc4.id_cita and fc4.paso='FINALIZADO'
    left join flujo_cita fc5 on c.id_cita = fc5.id_cita and fc5.paso IN('EDITADO','CANCELADO')
    join persona p on c.id_persona = p.id_persona
    left join carrera c2 on p.carrera = c2.carrera
    join doctor d on c.id_doctor = d.id_doctor
    join usuario u on d.id_usuario = u.id_usuario
    join persona p2 on u.id_persona = p2.id_persona
    WHERE c.fecha between str_to_date(p_fecha_inicio,'%d/%m/%Y') AND str_to_date(p_fecha_fin,'%d/%m/%Y');
END;


CREATE OR REPLACE PROCEDURE programasalud.rpt_espacios_convivencia(IN p_anio INT, IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
           ec.nombre "Nombre",
           ec.ubicacion "Ubicación",
           ec.cantidad "Cantidad",
           um.nombre "Unidad Medida",
           trim(concat(ec.cantidad,' ',um.nombre_corto)) "Cantidad y Medida",
           cc.nombre "Categoría",
           lc.nombre "Espacio/Ubicación",
           ec.anio "Año",
           ec.costo "Costo Proyecto",
           ec.estado "Estado",
           concat(p.nombre,' ',p.apellido) "Persona a Cargo",
           ec.observaciones "Observaciones"
    FROM espacio_convivencia ec
    JOIN unidad_medida um on ec.id_unidad_medida = um.id_unidad_medida
    JOIN lugar_convivencia lc on ec.id_lugar_convivencia = lc.id_lugar_convivencia
    JOIN categoria_convivencia cc on lc.id_categoria_convivencia = cc.id_categoria_convivencia
    JOIN persona p ON ec.id_persona = p.id_persona
    WHERE ec.activo
    AND ec.anio=p_anio
    AND ec.id_usuario=p_id_usuario;
END;


CREATE OR REPLACE PROCEDURE programasalud.rpt_espacios_convivencia_admin(IN p_anio INT, IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
        ec.nombre "Nombre",
        ec.ubicacion "Ubicación",
        ec.cantidad "Cantidad",
        um.nombre "Unidad Medida",
        trim(concat(ec.cantidad,' ',um.nombre_corto)) "Cantidad y Medida",
        cc.nombre "Categoría",
        lc.nombre "Espacio/Ubicación",
        ec.anio "Año",
        ec.costo "Costo Proyecto",
        ec.estado "Estado",
        concat(p.nombre,' ',p.apellido) "Persona a Cargo",
        ec.observaciones "Observaciones",
        concat(p2.nombre,' ',p2.apellido) "Ingresado por",
        u.id_usuario "Usuario Ingreso",
        ec.creado "Fecha Ingreso"
    FROM espacio_convivencia ec
    JOIN unidad_medida um on ec.id_unidad_medida = um.id_unidad_medida
    JOIN lugar_convivencia lc on ec.id_lugar_convivencia = lc.id_lugar_convivencia
    JOIN categoria_convivencia cc on lc.id_categoria_convivencia = cc.id_categoria_convivencia
    JOIN persona p ON ec.id_persona = p.id_persona
    JOIN usuario u on ec.id_usuario = u.id_usuario
    JOIN persona p2 ON u.id_persona = p2.id_persona
    WHERE ec.activo
    AND ec.anio=p_anio
    AND EXISTS(select 1 from usuario_rol where activo and id_rol=8704 and id_usuario=p_id_usuario);
END;


CREATE OR REPLACE PROCEDURE programasalud.rpt_personas_federadas(IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT concat(p.nombre,' ',p.apellido) "Paciente", c.nombre "Carrera", p.departamento "Departamento / Área", p.fecha_nacimiento "Fecha Nacimiento", p.sexo "Sexo", dp.nombre "Disciplina", p.email "Correo electrónico", p.telefono "Teléfono"
    FROM persona_ficha pf
    JOIN persona p ON pf.id_persona = p.id_persona
    left JOIN carrera c ON p.carrera = c.carrera
    JOIN disciplina_persona dp ON pf.id_disciplina_persona = dp.id_disciplina_persona AND dp.nombre != 'Ninguna';
END;


CREATE OR REPLACE PROCEDURE programasalud.rpt_personas_enfermedades(IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT concat(p.nombre,' ',p.apellido) "Paciente", c.nombre "Carrera", p.departamento "Departamento / Área", p.fecha_nacimiento "Fecha Nacimiento", p.sexo "Sexo", te.nombre "Enfermedad", p.email "Correo electrónico", p.telefono "Teléfono"
    FROM persona_ficha pf
    JOIN persona p ON pf.id_persona = p.id_persona
    left JOIN carrera c ON p.carrera = c.carrera
    JOIN tipo_enfermedad te ON pf.id_tipo_enfermedad = te.id_tipo_enfermedad AND te.nombre != 'Ninguna';
END;


CREATE OR REPLACE PROCEDURE programasalud.rpt_personas_cualidades_especiales(IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT concat(p.nombre,' ',p.apellido) "Paciente", c.nombre "Carrera", p.departamento "Departamento / Área", p.fecha_nacimiento "Fecha Nacimiento", p.sexo "Sexo", td.nombre "Enfermedad", p.email "Correo electrónico", p.telefono "Teléfono"
    FROM persona_ficha pf
    JOIN persona p ON pf.id_persona = p.id_persona
    left JOIN carrera c ON p.carrera = c.carrera
    JOIN tipo_discapacidad td ON pf.id_tipo_discapacidad = td.id_tipo_discapacidad
        ;
END;


CREATE OR REPLACE PROCEDURE programasalud.rpt_bebederos(IN p_fecha_inicio VARCHAR(10),IN p_fecha_fin VARCHAR(10), IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
        b.nombre "Nombre",
        b.ubicacion "Ubicación",
        b.fecha_mantenimiento "Fecha Mangenimiento",
        b.estado "Estado",
        b.observaciones "Observaciones",
        b.creado "Fecha Ingreso"
    FROM
        bebedero b
    WHERE
        b.activo
        and b.id_usuario = p_id_usuario
        and b.creado between str_to_date(p_fecha_inicio,'%d/%m/%Y') AND str_to_date(p_fecha_fin,'%d/%m/%Y');
END;


CREATE OR REPLACE PROCEDURE programasalud.rpt_capacitaciones(IN p_fecha_inicio VARCHAR(10),IN p_fecha_fin VARCHAR(10), IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
        c.nombre "Nombre",
        c.descripcion "Descripción",
        if(c.tipo_capacitacion='CAPACITACION','Capacitación',if(c.tipo_capacitacion='CURSOLIBRE','Curso Libre',c.tipo_capacitacion)) "Tipo",
        c.estado "Estado",
        c.fecha_inicio "Fecha Inicio",
        c.fecha_fin "Fecha Fin",
        c.creado "Fecha Ingreso"
    FROM capacitacion c
    WHERE c.activo
    AND c.id_usuario=p_id_usuario
    AND c.fecha_inicio >=  str_to_date(p_fecha_inicio,'%d/%m/%Y')
    AND (c.fecha_fin IS NULL OR c.fecha_fin <= str_to_date(p_fecha_fin,'%d/%m/%Y'));
END;


CREATE OR REPLACE PROCEDURE programasalud.rpt_capacitaciones_asistentes(IN p_fecha_inicio VARCHAR(10),IN p_fecha_fin VARCHAR(10), IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
        c.nombre "Nombre",
        c.descripcion "Descripción",
        if(c.tipo_capacitacion='CAPACITACION','Capacitación',if(c.tipo_capacitacion='CURSOLIBRE','Curso Libre',c.tipo_capacitacion)) "Tipo",
        c.estado "Estado",
        c.fecha_inicio "Fecha Inicio",
        c.fecha_fin "Fecha Fin",
        concat(p.nombre,' ',p.apellido) "Asistente", c2.nombre "Carrera", p.departamento "Departamento / Área", p.fecha_nacimiento "Fecha Nacimiento", p.sexo "Sexo", p.telefono "Teléfono", p.email "Correo Electrónico",
        cp.creado "Fecha Ingreso"
    FROM capacitacion c
    JOIN capacitacion_persona cp on c.id_capacitacion = cp.id_capacitacion AND cp.activo
    JOIN persona p ON cp.id_persona = p.id_persona
    LEFT JOIN carrera c2 on p.carrera = c2.carrera
    WHERE c.activo
    AND cp.activo
    AND c.id_usuario = p_id_usuario
    AND c.fecha_inicio >=  str_to_date(p_fecha_inicio,'%d/%m/%Y')
    AND (c.fecha_fin IS NULL OR c.fecha_fin <= str_to_date(p_fecha_fin,'%d/%m/%Y'));
END;

CREATE OR REPLACE PROCEDURE programasalud.rpt_selecciones(IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
        s.nombre "Nombre",
        s.descripcion "Descripción",
        s.especialidad "Especialidad",
        s.estado "Estado",
        s.creado"Fecha Ingreso"
    FROM seleccion s
    WHERE s.activo
    AND s.id_usuario=p_id_usuario;
END;

CREATE OR REPLACE PROCEDURE programasalud.rpt_seleccion_integrantes(IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
        s.nombre "Nombre",
        s.descripcion "Descripción",
        s.especialidad "Especialidad",
        s.estado "Estado",
        concat(p.nombre,' ',p.apellido) "Integrante", c.nombre "Carrera", p.departamento "Departamento / Área", p.fecha_nacimiento "Fecha Nacimiento", p.sexo "Sexo", p.telefono "Teléfono", p.email "Correo Electrónico",
        s.creado "Fecha Ingreso"
    FROM seleccion s
    JOIN seleccion_persona sp on s.id_seleccion = sp.id_seleccion AND sp.activo
    JOIN persona p ON sp.id_persona = p.id_persona
    LEFT JOIN carrera c on p.carrera = c.carrera
    WHERE s.activo
    AND s.id_usuario=p_id_usuario
    ORDER BY sp.id_seleccion;
END;




CREATE OR REPLACE PROCEDURE programasalud.rpt_campeonatos(IN p_fecha_inicio VARCHAR(10),IN p_fecha_fin VARCHAR(10), IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
        s.nombre "Selección",
        c.nombre "Campeonato",
        c.fecha "Fecha Participación",
        if(c.victorioso=1,'Sí','No') "Victorioso",
        c.observaciones "Observaciones",
        c.creado "Fecha Ingreso"
    FROM campeonato c
    JOIN seleccion s ON c.id_seleccion = s.id_seleccion AND s.activo
    WHERE c.activo
    AND c.id_usuario = p_id_usuario
    AND c.fecha BETWEEN str_to_date(p_fecha_inicio,'%d/%m/%Y') AND str_to_date(p_fecha_fin,'%d/%m/%Y');
END;







CREATE OR REPLACE PROCEDURE programasalud.rpt_asignacion_deportes_semestre(IN p_semestre INT,IN p_anio INT, IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
        d.nombre "Disciplina", d.limite "Límite",
        concat(if(substr(d.semestre,1,1)='1','Primer semestre, ','Segundo semestre, '),substr(d.semestre,3,4)) "Semestre", d.semestre "Nombre Semestre",
        SUBSTR(concat(if(flg_lunes=1,'Lun, ',''),if(flg_martes=1,'Mar, ',''),if(flg_miercoles=1,'Mié, ',''),if(flg_jueves=1,'Jue, ',''),if(flg_viernes=1,'Vie, ',''),if(flg_sabado=1,'Sáb, ','')) , 1 ,
        ((if(flg_lunes=1,1,0)+if(flg_martes=1,1,0)+if(flg_miercoles=1,1,0)+if(flg_jueves=1,1,0)+if(flg_viernes=1,1,0)+if(flg_sabado=1,1,0))*5-2))  "Días",
        concat(d.hora_inicio, ' - ', d.hora_fin)  "Horas", CONCAT(p2.nombre,' ',p2.apellido)  "Instructor",
        p.carnet "Carnet", p.cui "CUI", p.nov "Número Orientación Vocacional",
        concat(p.nombre,' ',p.apellido) "Estudiante", c.nombre "Carrera", p.departamento "Departamento", p.fecha_nacimiento "Fecha Nacimiento", p.sexo "Sexo", p.telefono "Teléfono", p.email "Correo Electrónico"
    FROM asignacion_deportes ad
    JOIN disciplina d on ad.id_disciplina = d.id_disciplina AND d.activo
    JOIN persona p2 on d.id_persona = p2.id_persona
    JOIN persona p on ad.id_persona = p.id_persona
    LEFT JOIN carrera c on p.carrera = c.carrera
    WHERE ad.activo AND d.semestre=CONCAT(p_semestre,'S',p_anio);
END;


CREATE OR REPLACE PROCEDURE programasalud.rpt_asignacion_deportes_fecha(IN p_fecha_inicio VARCHAR(10),IN p_fecha_fin VARCHAR(10), IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
        d.nombre "Disciplina", d.limite "Límite",
        concat(if(substr(d.semestre,1,1)='1','Primer semestre, ','Segundo semestre, '),substr(d.semestre,3,4)) "Semestre", d.semestre "Nombre Semestre",
        SUBSTR(concat(if(flg_lunes=1,'Lun, ',''),if(flg_martes=1,'Mar, ',''),if(flg_miercoles=1,'Mié, ',''),if(flg_jueves=1,'Jue, ',''),if(flg_viernes=1,'Vie, ',''),if(flg_sabado=1,'Sáb, ','')) , 1 ,
        ((if(flg_lunes=1,1,0)+if(flg_martes=1,1,0)+if(flg_miercoles=1,1,0)+if(flg_jueves=1,1,0)+if(flg_viernes=1,1,0)+if(flg_sabado=1,1,0))*5-2))  "Días",
        concat(d.hora_inicio, ' - ', d.hora_fin)  "Horas", CONCAT(p2.nombre,' ',p2.apellido)  "Instructor",
        p.carnet "Carnet", p.cui "CUI", p.nov "Número Orientación Vocacional",
           concat(p.nombre,' ',p.apellido) "Estudiante", ad.creado "Fecha Asignación" , c.nombre "Carrera", p.departamento "Departamento", p.fecha_nacimiento "Fecha Nacimiento", p.sexo "Sexo", p.telefono "Teléfono", p.email "Correo Electrónico"
    FROM asignacion_deportes ad
    JOIN disciplina d on ad.id_disciplina = d.id_disciplina AND d.activo
    JOIN persona p2 on d.id_persona = p2.id_persona
    JOIN persona p on ad.id_persona = p.id_persona
    LEFT JOIN carrera c on p.carrera = c.carrera
    WHERE ad.activo AND ad.creado  BETWEEN str_to_date(p_fecha_inicio,'%d/%m/%Y') AND str_to_date(p_fecha_fin,'%d/%m/%Y');
END;


CREATE OR REPLACE PROCEDURE programasalud.rpt_disciplinas(IN p_id_usuario VARCHAR(50))
BEGIN
        SELECT
      d.nombre "Nombre", d.limite "Límite", count(ad.id_disciplina) "Cantidad Asignados",
     d.limite-count(ad.id_disciplina)  "Cantidad Disponible",
    concat(if(substr(d.semestre,1,1)='1','Primer semestre, ','Segundo semestre, '),substr(d.semestre,3,4)) "Semestre", d.semestre "Nombre Semestre",
    SUBSTR(concat(if(flg_lunes=1,'Lun, ',''),if(flg_martes=1,'Mar, ',''),if(flg_miercoles=1,'Mié, ',''),if(flg_jueves=1,'Jue, ',''),if(flg_viernes=1,'Vie, ',''),if(flg_sabado=1,'Sáb, ','')) , 1 ,
              ((if(flg_lunes=1,1,0)+if(flg_martes=1,1,0)+if(flg_miercoles=1,1,0)+if(flg_jueves=1,1,0)+if(flg_viernes=1,1,0)+if(flg_sabado=1,1,0))*5-2))  "Días",
               flg_lunes=1 "Lunes", flg_martes=1 "Martes", flg_miercoles=1 "Miércoles", flg_jueves=1 "Jueves", flg_viernes=1 "Viernes", flg_sabado=1 "Sábado",
           concat(d.hora_inicio, ' - ', d.hora_fin)  "Horas",
           d.hora_inicio "Hora Inicio", d.hora_fin "Hora Fin",
           CONCAT(p.nombre,' ',p.apellido)  "Instructor"
    FROM
    disciplina d
    JOIN persona p on d.id_persona = p.id_persona
    left join asignacion_deportes ad on d.id_disciplina = ad.id_disciplina AND ad.activo
    where d.activo
    group by d.id_disciplina
    ORDER BY d.semestre;
END;



CREATE OR REPLACE PROCEDURE programasalud.rpt_medidas(IN p_fecha_inicio VARCHAR(10),IN p_fecha_fin VARCHAR(10), IN p_id_usuario VARCHAR(50))
BEGIN
       SELECT pm.creado "Fecha Medición",
           concat(p.nombre,' ',p.apellido) "Paciente", c3.nombre "Carrera", p.departamento "Departamento / Área", p.fecha_nacimiento "Fecha Nacimiento", p.sexo "Sexo",
           c2.nombre "Clínica", c.sintoma "Síntoma Cita",
           CONCAT(p2.nombre,' ',p2.apellido) "Atiende", m.nombre "Medida",
           pm.valor "Valor", if(m.id_tipo_dato=8706,'', m.unidad_medida) "Unidad Medida" FROM persona_medida pm
    JOIN persona p on pm.id_persona = p.id_persona
    LEFT JOIN cita c on pm.id_cita = c.id_cita
    LEFT JOIN carrera c3 ON p.carrera = c3.carrera
    JOIN medida m on pm.id_medida = m.id_medida
    LEFT JOIN clinica c2 on c.id_clinica = c2.id_clinica
    JOIN doctor d on c.id_doctor = d.id_doctor
    JOIN usuario u on d.id_usuario = u.id_usuario AND u.id_usuario=p_id_usuario
    LEFT JOIN persona p2 on u.id_persona = p2.id_persona
    WHERE
    pm.activo
    AND pm.creado BETWEEN str_to_date(p_fecha_inicio,'%d/%m/%Y') AND str_to_date(p_fecha_fin,'%d/%m/%Y')
    ORDER BY pm.creado DESC;
END;


CREATE OR REPLACE PROCEDURE programasalud.rpt_medidas_admin(IN p_fecha_inicio VARCHAR(10),IN p_fecha_fin VARCHAR(10), IN p_id_usuario VARCHAR(50))
BEGIN
       SELECT pm.creado "Fecha Medición",
           concat(p.nombre,' ',p.apellido) "Paciente", c3.nombre "Carrera", p.departamento "Departamento / Área", p.fecha_nacimiento "Fecha Nacimiento", p.sexo "Sexo",
           c2.nombre "Clínica", c.sintoma "Síntoma Cita",
           CONCAT(p2.nombre,' ',p2.apellido) "Atiende", m.nombre "Medida",
           pm.valor "Valor", if(m.id_tipo_dato=8706,'', m.unidad_medida) "Unidad Medida" ,
        concat(p2.nombre,' ',p2.apellido) "Ingresado por",
        u.id_usuario "Usuario Ingreso",
        pm.creado "Fecha Ingreso"
       FROM persona_medida pm
    JOIN persona p on pm.id_persona = p.id_persona
    LEFT JOIN cita c on pm.id_cita = c.id_cita
    LEFT JOIN carrera c3 ON p.carrera = c3.carrera
    JOIN medida m on pm.id_medida = m.id_medida
    LEFT JOIN clinica c2 on c.id_clinica = c2.id_clinica
    LEFT JOIN doctor d on c.id_doctor = d.id_doctor
    LEFT JOIN usuario u on d.id_usuario = u.id_usuario
    LEFT JOIN persona p2 on u.id_persona = p2.id_persona
    WHERE
    pm.activo
    AND EXISTS(select 1 from usuario_rol where activo and id_rol=8704 and id_usuario=p_id_usuario)
    AND pm.creado BETWEEN str_to_date(p_fecha_inicio,'%d/%m/%Y') AND str_to_date(p_fecha_fin,'%d/%m/%Y')
    ORDER BY pm.creado DESC;
END;







CREATE OR REPLACE PROCEDURE programasalud.rpt_bebederos_admin(IN p_fecha_inicio VARCHAR(10),IN p_fecha_fin VARCHAR(10), IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
        b.nombre "Nombre",
        b.ubicacion "Ubicación",
        b.fecha_mantenimiento "Fecha Mangenimiento",
        b.estado "Estado",
        b.observaciones "Observaciones",
        concat(p.nombre,' ',p.apellido) "Ingresado por",
        u.id_usuario "Usuario Ingreso",
        b.creado "Fecha Ingreso"
    FROM
        bebedero b
        JOIN usuario u on b.id_usuario = u.id_usuario
        JOIN persona p on u.id_persona = p.id_persona
    WHERE
        b.activo
        AND EXISTS(select 1 from usuario_rol where activo and id_rol=8704 and id_usuario=p_id_usuario)
        and b.creado between str_to_date(p_fecha_inicio,'%d/%m/%Y') AND str_to_date(p_fecha_fin,'%d/%m/%Y');
END;




CREATE OR REPLACE PROCEDURE programasalud.rpt_selecciones_admin(IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
        s.nombre "Nombre",
        s.descripcion "Descripción",
        s.especialidad "Especialidad",
        s.estado "Estado",
        concat(p.nombre,' ',p.apellido) "Ingresado por",
        u.id_usuario "Usuario Ingreso",
        s.creado "Fecha Ingreso"
    FROM seleccion s
        JOIN usuario u on s.id_usuario = u.id_usuario
        JOIN persona p on u.id_persona = p.id_persona
    WHERE s.activo
    AND EXISTS(select 1 from usuario_rol where activo and id_rol=8704 and id_usuario=p_id_usuario);
END;




CREATE OR REPLACE PROCEDURE programasalud.rpt_selecciones_deportes(IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
        s.nombre "Nombre",
        s.descripcion "Descripción",
        s.especialidad "Especialidad",
        s.estado "Estado",
        s.creado "Fecha Ingreso"
    FROM seleccion s
    WHERE s.activo
    AND EXISTS(select 1 from usuario_rol where activo and id_rol=8702 and id_usuario=p_id_usuario);
END;




CREATE OR REPLACE PROCEDURE programasalud.rpt_capacitaciones_admin(IN p_fecha_inicio VARCHAR(10),IN p_fecha_fin VARCHAR(10), IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
        c.nombre "Nombre",
        c.descripcion "Descripción",
        if(c.tipo_capacitacion='CAPACITACION','Capacitación',if(c.tipo_capacitacion='CURSOLIBRE','Curso Libre',c.tipo_capacitacion)) "Tipo",
        c.estado "Estado",
        c.fecha_inicio "Fecha Inicio",
        c.fecha_fin "Fecha Fin",
        concat(p.nombre,' ',p.apellido) "Ingresado por",
        u.id_usuario "Usuario Ingreso",
        c.creado "Fecha Ingreso"
    FROM capacitacion c
        JOIN usuario u on c.id_usuario = u.id_usuario
        JOIN persona p on u.id_persona = p.id_persona
    WHERE c.activo
    AND EXISTS(select 1 from usuario_rol where activo and id_rol=8704 and id_usuario=p_id_usuario)
    AND c.fecha_inicio >=  str_to_date(p_fecha_inicio,'%d/%m/%Y')
    AND (c.fecha_fin IS NULL OR c.fecha_fin <= str_to_date(p_fecha_fin,'%d/%m/%Y'));
END;


CREATE OR REPLACE PROCEDURE programasalud.rpt_capacitaciones_asistentes_admin(IN p_fecha_inicio VARCHAR(10),IN p_fecha_fin VARCHAR(10), IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
        c.nombre "Nombre",
        c.descripcion "Descripción",
        if(c.tipo_capacitacion='CAPACITACION','Capacitación',if(c.tipo_capacitacion='CURSOLIBRE','Curso Libre',c.tipo_capacitacion)) "Tipo",
        c.estado "Estado",
        c.fecha_inicio "Fecha Inicio",
        c.fecha_fin "Fecha Fin",
        concat(p.nombre,' ',p.apellido) "Asistente", c2.nombre "Carrera", p.departamento "Departamento / Área", p.fecha_nacimiento "Fecha Nacimiento", p.sexo "Sexo", p.telefono "Teléfono", p.email "Correo Electrónico",
        concat(p2.nombre,' ',p2.apellido) "Ingresado por",
        u.id_usuario "Usuario Ingreso",
        c.creado "Fecha Ingreso"
    FROM capacitacion c
    JOIN capacitacion_persona cp on c.id_capacitacion = cp.id_capacitacion AND cp.activo
    JOIN persona p ON cp.id_persona = p.id_persona
    LEFT JOIN carrera c2 on p.carrera = c2.carrera
        JOIN usuario u on c.id_usuario = u.id_usuario
        JOIN persona p2 on u.id_persona = p2.id_persona
    WHERE c.activo
    AND cp.activo
    AND EXISTS (select 1 from usuario_rol where activo and id_rol=8704 and id_usuario=p_id_usuario)
    AND c.fecha_inicio >=  str_to_date(p_fecha_inicio,'%d/%m/%Y')
    AND (c.fecha_fin IS NULL OR c.fecha_fin <= str_to_date(p_fecha_fin,'%d/%m/%Y'));
END;




CREATE OR REPLACE PROCEDURE programasalud.rpt_campeonatos_admin(IN p_fecha_inicio VARCHAR(10),IN p_fecha_fin VARCHAR(10), IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
        s.nombre "Selección",
        c.nombre "Campeonato",
        c.fecha "Fecha Participación",
        if(c.victorioso=1,'Sí','No') "Victorioso",
        c.observaciones "Observaciones",
        concat(p2.nombre,' ',p2.apellido) "Ingresado por",
        u.id_usuario "Usuario Ingreso",
        c.creado "Fecha Ingreso"
    FROM campeonato c
    JOIN seleccion s ON c.id_seleccion = s.id_seleccion AND s.activo
        JOIN usuario u on c.id_usuario = u.id_usuario
        JOIN persona p2 on u.id_persona = p2.id_persona
    WHERE c.activo
    AND EXISTS (select 1 from usuario_rol where activo and id_rol=8704 and id_usuario=p_id_usuario)
    AND c.fecha BETWEEN str_to_date(p_fecha_inicio,'%d/%m/%Y') AND str_to_date(p_fecha_fin,'%d/%m/%Y');
END;



CREATE OR REPLACE PROCEDURE programasalud.rpt_campeonatos_deportes(IN p_fecha_inicio VARCHAR(10),IN p_fecha_fin VARCHAR(10), IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
        s.nombre "Selección",
        c.nombre "Campeonato",
        c.fecha "Fecha Participación",
        if(c.victorioso=1,'Sí','No') "Victorioso",
        c.observaciones "Observaciones",
        c.creado "Fecha Ingreso"
    FROM campeonato c
    JOIN seleccion s ON c.id_seleccion = s.id_seleccion AND s.activo
    WHERE c.activo
    AND EXISTS (select 1 from usuario_rol where activo and id_rol=8702 and id_usuario=p_id_usuario)
    AND c.fecha BETWEEN str_to_date(p_fecha_inicio,'%d/%m/%Y') AND str_to_date(p_fecha_fin,'%d/%m/%Y');
END;



CREATE OR REPLACE PROCEDURE programasalud.rpt_seleccion_integrantes_admin(IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
        s.nombre "Nombre",
        s.descripcion "Descripción",
        s.especialidad "Especialidad",
        s.estado "Estado",
         p.carnet "Carnet", p.cui "CUI", p.nov "Número Orientación Vocacional",
        concat(p.nombre,' ',p.apellido) "Integrante", c.nombre "Carrera", p.departamento "Departamento / Área", p.fecha_nacimiento "Fecha Nacimiento", p.sexo "Sexo", p.telefono "Teléfono", p.email "Correo Electrónico",
        concat(p2.nombre,' ',p2.apellido) "Ingresado por",
        u.id_usuario "Usuario Ingreso",
        s.creado "Fecha Ingreso"
    FROM seleccion s
    JOIN seleccion_persona sp on s.id_seleccion = sp.id_seleccion AND sp.activo
    JOIN persona p ON sp.id_persona = p.id_persona
    LEFT JOIN carrera c on p.carrera = c.carrera
    JOIN usuario u on s.id_usuario = u.id_usuario
        JOIN persona p2 on u.id_persona = p2.id_persona
    WHERE s.activo
    AND EXISTS (select 1 from usuario_rol where activo and id_rol=8704 and id_usuario=p_id_usuario)
    ORDER BY sp.id_seleccion;
END;



CREATE OR REPLACE PROCEDURE programasalud.rpt_seleccion_integrantes_deportes(IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT
        s.nombre "Nombre",
        s.descripcion "Descripción",
        s.especialidad "Especialidad",
        s.estado "Estado",
         p.carnet "Carnet", p.cui "CUI", p.nov "Número Orientación Vocacional",
        concat(p.nombre,' ',p.apellido) "Integrante", c.nombre "Carrera", p.departamento "Departamento / Área", p.fecha_nacimiento "Fecha Nacimiento", p.sexo "Sexo", p.telefono "Teléfono", p.email "Correo Electrónico",
        s.creado "Fecha Ingreso"
    FROM seleccion s
    JOIN seleccion_persona sp on s.id_seleccion = sp.id_seleccion AND sp.activo
    JOIN persona p ON sp.id_persona = p.id_persona
    LEFT JOIN carrera c on p.carrera = c.carrera
    JOIN usuario u on s.id_usuario = u.id_usuario
        JOIN persona p2 on u.id_persona = p2.id_persona
    WHERE s.activo
    AND EXISTS (select 1 from usuario_rol where activo and id_rol=8702 and id_usuario=p_id_usuario)
    ORDER BY sp.id_seleccion;
END;








CREATE OR REPLACE PROCEDURE programasalud.rpt_acciones(IN p_fecha_inicio VARCHAR(10),IN p_fecha_fin VARCHAR(10), IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT ca.creado "Fecha Ingreso", c2.nombre "Clínica",
           concat(p.nombre,' ',p.apellido) "Paciente", car.nombre "Carrera", p.departamento "Departamento / Área", p.fecha_nacimiento "Fecha Nacimiento", p.sexo "Sexo",
           c2.nombre "Clínica", c.sintoma "Síntoma Cita",
           CONCAT(p2.nombre,' ',p2.apellido) "Atiende", a.nombre "Acción", ca.observaciones "Observaciones", u.id_usuario "Usuario Atiende"
    FROM cita_accion ca
    JOIN cita c on ca.id_cita = c.id_cita
    JOIN persona p on c.id_persona = p.id_persona
    LEFT JOIN carrera car on car.carrera=p.carrera
    JOIN accion a on ca.id_accion = a.id_accion
    JOIN clinica c2 on c.id_clinica = c2.id_clinica
    JOIN doctor d on c.id_doctor = d.id_doctor
    JOIN usuario u on d.id_usuario = u.id_usuario
    JOIN persona p2 on u.id_persona = p2.id_persona
    WHERE ca.activo
    and u.id_usuario=p_id_usuario
    AND ca.creado BETWEEN str_to_date(p_fecha_inicio,'%d/%m/%Y') AND str_to_date(p_fecha_fin,'%d/%m/%Y')
    ORDER BY ca.creado DESC;
END;



CREATE OR REPLACE PROCEDURE programasalud.rpt_acciones_admin(IN p_fecha_inicio VARCHAR(10),IN p_fecha_fin VARCHAR(10), IN p_id_usuario VARCHAR(50))
BEGIN
    SELECT ca.creado "Fecha Ingreso", c2.nombre "Clínica",
           concat(p.nombre,' ',p.apellido) "Paciente", car.nombre "Carrera", p.departamento "Departamento / Área", p.fecha_nacimiento "Fecha Nacimiento", p.sexo "Sexo",
           c2.nombre "Clínica", c.sintoma "Síntoma Cita",
           CONCAT(p2.nombre,' ',p2.apellido) "Atiende", a.nombre "Acción", ca.observaciones "Observaciones", u.id_usuario "Usuario Atiende"
    FROM cita_accion ca
    JOIN cita c on ca.id_cita = c.id_cita
    JOIN persona p on c.id_persona = p.id_persona
    LEFT JOIN carrera car on car.carrera=p.carrera
    JOIN accion a on ca.id_accion = a.id_accion
    JOIN clinica c2 on c.id_clinica = c2.id_clinica
    JOIN doctor d on c.id_doctor = d.id_doctor
    JOIN usuario u on d.id_usuario = u.id_usuario
    JOIN persona p2 on u.id_persona = p2.id_persona
    WHERE ca.activo
    and EXISTS(select 1 from usuario_rol where activo and id_rol=8704 and id_usuario=p_id_usuario)
    AND ca.creado BETWEEN str_to_date(p_fecha_inicio,'%d/%m/%Y') AND str_to_date(p_fecha_fin,'%d/%m/%Y')
    ORDER BY ca.creado DESC;
END;

