
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
INSERT INTO programasalud.rol (id_rol, nombre_rol, descripcion_rol, activo) VALUES (8706,'Ingreso Datos','Para el ingreso de datos',TRUE);




delete from reporte_parametro where activo;
delete from reporte_rol where activo;
delete from reporte where activo;

INSERT INTO programasalud.reporte (id_reporte, nombre, sp_name) VALUES (8701, 'Reporte de citas','rpt_citas');
INSERT INTO programasalud.reporte_rol(id_reporte, id_rol) VALUES (8701,8701);
INSERT INTO programasalud.reporte_parametro (id_reporte, display_name, var_name, var_type, orden, moreinfo) VALUES
            (8701, 'Fecha Inicio','fecha_inicio','datefield',1,'{ "emptyText" : "Fecha Inicio"}'),
            (8701, 'Fecha Fin','fecha_fin','datefield',2,'{ "emptyText" : "Fecha Fin"}');

INSERT INTO programasalud.reporte (id_reporte, nombre, sp_name) VALUES (8702, '[Admin] Reporte de citas','rpt_citas_admin');
INSERT INTO programasalud.reporte_rol(id_reporte, id_rol) VALUES (8702,8704);
INSERT INTO programasalud.reporte_parametro (id_reporte, display_name, var_name, var_type, orden, moreinfo) VALUES
            (8702, 'Fecha Inicio','fecha_inicio','datefield',1,'{ "emptyText" : "Fecha Inicio"}'),
            (8702, 'Fecha Fin','fecha_fin','datefield',2,'{ "emptyText" : "Fecha Fin"}');

INSERT INTO programasalud.reporte (id_reporte, nombre, sp_name) VALUES (8703, 'Espacios de Convivencia','rpt_espacios_convivencia');
INSERT INTO programasalud.reporte_rol(id_reporte, id_rol) VALUES (8703,8705),(8703,8704);
INSERT INTO programasalud.reporte_parametro (id_reporte, display_name, var_name, var_type, orden, moreinfo) VALUES
            (8703, 'Año','anio','numberfield',1,'{ hideTrigger: true,allowDecimals: false,enforceMaxLength: true,minValue: 1900,maxValue: 2999}');

INSERT INTO programasalud.reporte (id_reporte, nombre, sp_name) VALUES (8704, 'Personas federadas','rpt_personas_federadas');
INSERT INTO programasalud.reporte_rol(id_reporte, id_rol) VALUES (8704,8701),(8704,8702),(8704,8703),(8704,8704);

INSERT INTO programasalud.reporte (id_reporte, nombre, sp_name) VALUES (8705, 'Personas con enfermedades crónicas','rpt_personas_enfermedades');
INSERT INTO programasalud.reporte_rol(id_reporte, id_rol) VALUES (8705,8701),(8705,8702),(8705,8703),(8705,8704);

INSERT INTO programasalud.reporte (id_reporte, nombre, sp_name) VALUES (8706, 'Personas con capacidades especiales','rpt_personas_cualidades_especiales');
INSERT INTO programasalud.reporte_rol(id_reporte, id_rol) VALUES (8706,8701),(8706,8702),(8706,8703),(8706,8704);

INSERT INTO programasalud.reporte (id_reporte, nombre, sp_name) VALUES (8707, 'Reporte de bebederos','rpt_bebederos');
INSERT INTO programasalud.reporte_rol(id_reporte, id_rol) VALUES (8707,8703),(8707,8704);
INSERT INTO programasalud.reporte_parametro (id_reporte, display_name, var_name, var_type, orden, moreinfo) VALUES
            (8707, 'Fecha mant. entre','fecha_inicio','datefield',1,'{ "emptyText" : "Fecha Inicio"}'),
            (8707, 'y','fecha_fin','datefield',2,'{ "emptyText" : "Fecha Fin"}');

INSERT INTO programasalud.reporte (id_reporte, nombre, sp_name) VALUES (8708, 'Reporte de capacitaciones','rpt_capacitaciones');
INSERT INTO programasalud.reporte_rol(id_reporte, id_rol) VALUES (8708,8703),(8708,8704);
INSERT INTO programasalud.reporte_parametro (id_reporte, display_name, var_name, var_type, orden, moreinfo) VALUES
            (8708, 'Fecha Inicio','fecha_inicio','datefield',1,'{ "emptyText" : "Fecha Inicio"}'),
            (8708, 'Fecha Fin','fecha_fin','datefield',2,'{ "emptyText" : "Fecha Fin"}');


INSERT INTO programasalud.reporte (id_reporte, nombre, sp_name) VALUES (8709, 'Reporte de capacitaciones con asistentes','rpt_capacitaciones_asistentes');
INSERT INTO programasalud.reporte_rol(id_reporte, id_rol) VALUES (8709,8703),(8709,8704);
INSERT INTO programasalud.reporte_parametro (id_reporte, display_name, var_name, var_type, orden, moreinfo) VALUES
            (8709, 'Fecha Inicio','fecha_inicio','datefield',1,'{ "emptyText" : "Fecha Inicio"}'),
            (8709, 'Fecha Fin','fecha_fin','datefield',2,'{ "emptyText" : "Fecha Fin"}');

INSERT INTO programasalud.reporte (id_reporte, nombre, sp_name) VALUES (8710, 'Selecciones','rpt_selecciones');
INSERT INTO programasalud.reporte_rol(id_reporte, id_rol) VALUES (8710,8702),(8710,8703),(8710,8704);

INSERT INTO programasalud.reporte (id_reporte, nombre, sp_name) VALUES (8711, 'Selecciones e integrantes','rpt_seleccion_integrantes');
INSERT INTO programasalud.reporte_rol(id_reporte, id_rol) VALUES (8711,8702),(8711,8703),(8711,8704);

INSERT INTO programasalud.reporte (id_reporte, nombre, sp_name) VALUES (8712, 'Campeonatos','rpt_campeonatos');
INSERT INTO programasalud.reporte_rol(id_reporte, id_rol) VALUES (8712,8702),(8712,8703),(8712,8704);
INSERT INTO programasalud.reporte_parametro (id_reporte, display_name, var_name, var_type, orden, moreinfo) VALUES
            (8712, 'Fecha Participación Inicio','fecha_inicio','datefield',1,'{ "emptyText" : "Fecha Inicio"}'),
            (8712, 'Fecha Participación Fin','fecha_fin','datefield',2,'{ "emptyText" : "Fecha Fin"}');

INSERT INTO programasalud.reporte (id_reporte, nombre, sp_name) VALUES (8713, 'Asignaciones deportes por semestre','rpt_asignacion_deportes_semestre');
INSERT INTO programasalud.reporte_rol(id_reporte, id_rol) VALUES (8713,8702),(8713,8704);
INSERT INTO programasalud.reporte_parametro (id_reporte, display_name, var_name, var_type, orden, moreinfo) VALUES
            (8713, 'Semestre','semestre','numberfield',1,'{ hideTrigger: true,allowDecimals: false,enforceMaxLength: true,minValue: 1,maxValue: 2}'),
            (8713, 'Año','anio','numberfield',2,'{ hideTrigger: true,allowDecimals: false,enforceMaxLength: true,minValue: 2018,maxValue: 2999}');

INSERT INTO programasalud.reporte (id_reporte, nombre, sp_name) VALUES (8714, 'Asignaciones deportes por fecha','rpt_asignacion_deportes_fecha');
INSERT INTO programasalud.reporte_rol(id_reporte, id_rol) VALUES (8714,8702),(8714,8704);
INSERT INTO programasalud.reporte_parametro (id_reporte, display_name, var_name, var_type, orden, moreinfo) VALUES
            (8714, 'Fecha Asignación inicio','fecha_inicio','datefield',1,'{ "emptyText" : "Fecha Inicio"}'),
            (8714, 'Fecha Asignación Fin','fecha_fin','datefield',2,'{ "emptyText" : "Fecha Fin"}');

INSERT INTO programasalud.reporte (id_reporte, nombre, sp_name) VALUES (8715, 'Disciplinas deportivas','rpt_disciplinas');
INSERT INTO programasalud.reporte_rol(id_reporte, id_rol) VALUES (8715,8702),(8715,8704);






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
INSERT INTO programasalud.unidad_medida (nombre, nombre_corto) VALUES ('Global',' ');




INSERT INTO programasalud.disciplina_persona(nombre)VALUES
('Ninguna'),
('Asociación de Ecuestres'),
('Asociación de Golf'),
('Asociación de Hockey'),
('Asociación de Navegación a Vela'),
('Asociación de Paracaidismo'),
('Asociación de Pentatlon'),
('Asociación de Sóftbol'),
('Asociación de Surf'),
('Asociación de Tiro con Arco'),
('Asociación de Tiro con Arma de Caza'),
('Asociación de Vuelo Libre'),
('Asociación de Rugby'),
('Asociación de Billar'),
('Asociación de Pesca Deportiva'),
('Asociación de Polo'),
('Asociación de Raquetbol'),
('Asociación de Squash'),
('Federación de Ajedrez'),
('Federación de Andinismo'),
('Federación de Atletismo'),
('Federación de Bádminton'),
('Federación de Baloncesto'),
('Federación de Balonmano'),
('Federación de Béisbol'),
('Federación de Boliche'),
('Federación de Boxeo'),
('Federación de Ciclismo'),
('Federación de Esgrima'),
('Federación de Fisicoculturismo'),
('Federación de Fútbol'),
('Federación de Gimnasia'),
('Federación de Judo'),
('Federación de Karate'),
('Federación de Levantamiento de Pesas'),
('Federación de Levantamiento de Potencia'),
('Federación de Luchas'),
('Federación de Motociclismo'),
('Federación de Natación, Clavados, Polo Acuático y Nado Sincronizado'),
('Federación de Patinaje'),
('Federación de Remo y Canotaje'),
('Federación de Taekwondo'),
('Federación de Tenis de Campo'),
('Federación de Tenis de Mesa'),
('Federación de Tiro Deportivo'),
('Federación de Triatrlón'),
('Federación de Voleibol');




INSERT INTO tipo_discapacidad (nombre, activo) VALUES ('Silla de Ruedas',true);
INSERT INTO tipo_discapacidad (nombre, activo) VALUES ('Muletas',true);
INSERT INTO tipo_discapacidad (nombre, activo) VALUES ('Aparato auditivo',true);
INSERT INTO tipo_discapacidad (nombre, activo) VALUES ('Dificultad para ver',true);
INSERT INTO tipo_discapacidad (nombre, activo) VALUES ('Otra',true);




INSERT INTO tipo_enfermedad (nombre) VALUES
('Ninguna'),
('Enfermedades Cardiovasculares'),
('Cáncer'),
('Enfermedad Pulmonar Obstructiva Crónica'),
('Diabetes'),
('Parkinson'),
('Alzheimer'),
('Esclerosis múltiple'),
('Hipertensión'),
('Lumbalgia'),
('Colesterol'),
('Depresión'),
('Ansiedad'),
('Tiroides'),
('Osteoporosis'),
('Otra');



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
INSERT INTO usuario_rol (id_usuario,id_rol,activo)VALUES ('ps_admin',8706,TRUE);



/*-----------------------------------------*/







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


insert into medida (id_medida, nombre, id_tipo_dato, unidad_medida, valor_minimo, valor_maximo, obligatorio, activo) VALUES
(1, 'Peso', 8701,'Libras',0,999,1,1),
(2, 'Estatura', 8702, 'Metros',0,3,1,1);




