
INSERT INTO carrera (carrera, nombre, nombre_corto) VALUES
('01','Ingeniería Civil','Ing. Civil'),
('02','Ingeniería Química','Ing. Química'),
('03','Ingeniería Mecánica','Ing. Mecánica'),
('04','Ingeniería Eléctrica','Ing. Eléctrica'),
('05','Ingeniería Industrial','Ing. Industrial'),
('06','Ingeniería Mecánica Eléctrica','Ing. Mec. Eléctrica'),
('07','Ingeniería Mecánica Industrial','Ing. Mec. Industrial'),
('09','Ingeniería en Ciencias y Sistemas','Ing. Ciencias y Sis.'),
('10','Licenciatura en Matemática Aplicada','Lic. Mat. Aplicada'),
('12','Licenciatura en Física Aplicada','Lic. Fís. Aplicada'),
('13','Ingeniería Electrónica','Ing. Electrónica'),
('15','Ingeniería en Industrias Agropecuarias y Forestales','Ing. Agroindustrial'),
('35','Ingeniería Ambiental','Ing. Ambiental');




INSERT INTO programasalud.rol (id_rol, nombre_rol, descripcion_rol, activo) VALUES (8701,'Clínica','Personal de las clínicas',TRUE);
INSERT INTO programasalud.rol (id_rol, nombre_rol, descripcion_rol, activo) VALUES (8702,'Deportes','Usuarios del departamento de deportes',TRUE);
INSERT INTO programasalud.rol (id_rol, nombre_rol, descripcion_rol, activo) VALUES (8703,'Programa Salud','Usuarios de la unidad de salud',TRUE);
INSERT INTO programasalud.rol (id_rol, nombre_rol, descripcion_rol, activo) VALUES (8704,'Administrador','Administrador del sistema',TRUE);
INSERT INTO programasalud.rol (id_rol, nombre_rol, descripcion_rol, activo) VALUES (8705,'Espacios de Convivencia','Infraestructura y Planificación para la Convivencia',TRUE);





INSERT INTO programasalud.especialidad (especialidad, activo) VALUES ('Enfermería',TRUE);
INSERT INTO programasalud.especialidad (especialidad, activo) VALUES ('Odontología',TRUE);
INSERT INTO programasalud.especialidad (especialidad, activo) VALUES ('Medicina General',TRUE);







INSERT INTO programasalud.tipo_dato_medida (id_tipo_dato, tipo_dato, activo) VALUES (8701, 'Entero',TRUE);
INSERT INTO programasalud.tipo_dato_medida (id_tipo_dato, tipo_dato, activo) VALUES (8702, 'Decimal',TRUE);
INSERT INTO programasalud.tipo_dato_medida (id_tipo_dato, tipo_dato, activo) VALUES (8703, 'Texto',TRUE);
INSERT INTO programasalud.tipo_dato_medida (id_tipo_dato, tipo_dato, activo) VALUES (8704, 'Fecha',TRUE);
INSERT INTO programasalud.tipo_dato_medida (id_tipo_dato, tipo_dato, activo) VALUES (8705, 'Sí/No',TRUE);




INSERT INTO programasalud.unidad_medida (nombre, nombre_corto) VALUES ('Metros lineales','m');
INSERT INTO programasalud.unidad_medida (nombre, nombre_corto) VALUES ('Metros cuadrados','m²');
INSERT INTO programasalud.unidad_medida (nombre, nombre_corto) VALUES ('Unidades','u');













INSERT INTO tipo_discapacidad (nombre, activo) VALUES ('Silla de Ruedas',true);
INSERT INTO tipo_discapacidad (nombre, activo) VALUES ('Muletas',true);
INSERT INTO tipo_discapacidad (nombre, activo) VALUES ('Aparato auditivo',true);
INSERT INTO tipo_discapacidad (nombre, activo) VALUES ('Dificultad para ver',true);
INSERT INTO tipo_discapacidad (nombre, activo) VALUES ('Otra',true);





INSERT INTO tipo_persona (nombre, activo) VALUES ('Estudiante',true);
INSERT INTO tipo_persona (nombre, activo) VALUES ('Personal Docente',true);
INSERT INTO tipo_persona (nombre, activo) VALUES ('Personal Administrativo',true);




INSERT INTO programasalud.persona (nombre, apellido, fecha_nacimiento, sexo, email)
VALUES
('Administrador','Administrador',str_to_date('01/08/2018','%d/%m/%Y'),'A','saludfiusac@gmail.com');

INSERT INTO programasalud.usuario (id_usuario,clave,id_persona,activo,cambiar_clave) VALUES
('ps_admin','248e7becd1f5674c62a8c92af927b8cee38f639196cad08c179d95e7e5e4f340',
 (select id_persona from persona where email='saludfiusac@gmail.com'),TRUE,FALSE);

INSERT INTO usuario_rol (id_usuario,id_rol,activo)VALUES ('ps_admin',8701,TRUE);
INSERT INTO usuario_rol (id_usuario,id_rol,activo)VALUES ('ps_admin',8702,TRUE);
INSERT INTO usuario_rol (id_usuario,id_rol,activo)VALUES ('ps_admin',8703,TRUE);
INSERT INTO usuario_rol (id_usuario,id_rol,activo)VALUES ('ps_admin',8704,TRUE);
INSERT INTO usuario_rol (id_usuario,id_rol,activo)VALUES ('ps_admin',8705,TRUE);



/*-----------------------------------------*/
INSERT INTO tipo_documento (nombre, alcance) VALUES ('Registro Académico','Estudiante');
INSERT INTO tipo_documento (nombre, alcance) VALUES ('Número de Orientación Vocacional','Estudiante');
INSERT INTO tipo_documento (nombre, alcance) VALUES ('CUI','General');
INSERT INTO tipo_documento (nombre, alcance) VALUES ('Registro Personal','Empleado');







INSERT INTO accion (nombre)
VALUES
('Laboratorios'),
('Medicina');



INSERT INTO programasalud.categoria_convivencia (id_categoria_convivencia, nombre)
VALUES
(8701, 'Edificios'),
(8702, 'Áreas Abiertas'),
(8703, 'Parqueos'),
(8704, 'Equipo Urbano Exterior'),
(8705, 'Equipo Educacional / Lab');




INSERT INTO programasalud.lugar_convivencia (id_categoria_convivencia, nombre) VALUES
(8701,'Edificio T-3'),(8701,'Edificio T-1'),(8701,'Edificio T-4'),(8701,'Edificio T-5'),
(8701,'Edificio Caldera T-5'),(8701,'Edificio T-6'),(8701,'Edificio T-7'),(8701,'Edificio S-11'),
(8701,'Edificio S-12'),(8701,'Edificio Cii T-5'),(8701,'Edificio Cii nuevo'),(8701,'Edificio Cii sección madera'),
(8701,'Edificio Cii bodega bombas agua'),(8701,'Edificio Eris'),(8701,'Edificio Suelos'),(8701,'Edificio EPS'),
(8701,'Edificio Carpintería'),(8701,'Edificio Almacén'),(8701,'Edificio Mantenimiento'),(8701,'Edificio Ing. Corzo Agregados'),
(8701,'Bodega bienes Inventario'),(8701,'Bodega Postgrados'),(8702,'Jardines internos este Vela'),(8702,'Área juegos niños'),
(8702,'Área ranchitos este T-4'),(8702,'Área ranchitos sur T-3 - T-5'),(8702,'Área ranchitos norte T-7'),(8702,'Cancha'),
(8702,'Jardines Ingeniería (T-3 / T-5 / T-6 / T-4)'),(8702,'Jardines norte T-3'),(8702,'Jardines sur T-3'),
(8702,'Jardines sur T-1'),(8702,'Jardines Vela sur'),(8702,'Jardines Vela oeste'),(8702,'Prefabricados'),
(8702,'Pileta'),(8703,'Parqueo S-11 para post'),(8703,'Parqueo T-5 para prof'),(8703,'Parqueo T-1 para prof'),
(8703,'Parqueos Cii'),(8703,'Parqueos perímetro (T-3, T-5, T-6, T-7)'),(8703,'Garitas parqueos (T-3, T-5, T-6, T-7)'),
(8703,'Garita T-1'),(8704,'Bancas'),(8704,'Postes'),(8704,'Toldos'),(8704,'Rampas'),(8705,'Pantallas'),(8705,'Cañoneras'),
(8705,'Balanza');
