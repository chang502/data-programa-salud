
INSERT INTO programasalud.rol (id_rol, nombre_rol, descripcion_rol, activo) VALUES (8701,'Clínica','Personal de las clínicas',TRUE);
INSERT INTO programasalud.rol (id_rol, nombre_rol, descripcion_rol, activo) VALUES (8702,'Deportes','Usuarios del departamento de deportes',TRUE);
INSERT INTO programasalud.rol (id_rol, nombre_rol, descripcion_rol, activo) VALUES (8703,'Programa Salud','Usuarios de la unidad de salud',TRUE);
INSERT INTO programasalud.rol (id_rol, nombre_rol, descripcion_rol, activo) VALUES (8704,'Administrador','Administrador del sistema',TRUE);





INSERT INTO programasalud.especialidad (especialidad, activo) VALUES ('Enfermería',TRUE);
INSERT INTO programasalud.especialidad (especialidad, activo) VALUES ('Odontología',TRUE);
INSERT INTO programasalud.especialidad (especialidad, activo) VALUES ('Medicina General',TRUE);







INSERT INTO programasalud.tipo_dato_medida (id_tipo_dato, tipo_dato, activo) VALUES (8701, 'Entero',TRUE);
INSERT INTO programasalud.tipo_dato_medida (id_tipo_dato, tipo_dato, activo) VALUES (8702, 'Decimal',TRUE);
INSERT INTO programasalud.tipo_dato_medida (id_tipo_dato, tipo_dato, activo) VALUES (8703, 'Texto',TRUE);
INSERT INTO programasalud.tipo_dato_medida (id_tipo_dato, tipo_dato, activo) VALUES (8704, 'Fecha',TRUE);







INSERT INTO tipo_documento (nombre, activo) VALUES ('Registro Académico',true);
INSERT INTO tipo_documento (nombre, activo) VALUES ('Número de Orientación Vocacional',true);
INSERT INTO tipo_documento (nombre, activo) VALUES ('DPI',true);








INSERT INTO tipo_discapacidad (nombre, activo) VALUES ('Silla de Ruedas',true);
INSERT INTO tipo_discapacidad (nombre, activo) VALUES ('Muletas',true);
INSERT INTO tipo_discapacidad (nombre, activo) VALUES ('Aparato auditivo',true);
INSERT INTO tipo_discapacidad (nombre, activo) VALUES ('Dificultad para ver',true);
INSERT INTO tipo_discapacidad (nombre, activo) VALUES ('Otra',true);





INSERT INTO tipo_persona (nombre, activo) VALUES ('Estudiante',true);
INSERT INTO tipo_persona (nombre, activo) VALUES ('Personal Docente',true);
INSERT INTO tipo_persona (nombre, activo) VALUES ('Personal Administrativo',true);




INSERT INTO programasalud.persona (primer_nombre, primer_apellido, fecha_nacimiento, sexo)
VALUES
('Administrador','Administrador',str_to_date('01/08/2018','%d/%m/%Y'),'A');

INSERT INTO programasalud.usuario (id_usuario,clave,id_persona,activo,cambiar_clave) VALUES
('ps_admin','248e7becd1f5674c62a8c92af927b8cee38f639196cad08c179d95e7e5e4f340',1,TRUE,FALSE);