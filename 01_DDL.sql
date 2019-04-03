
DROP DATABASE IF EXISTS programasalud;

CREATE DATABASE programasalud CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

DROP USER IF EXISTS saludfiusac;

# CREATE OR REPLACE USER 'saludfiusac' IDENTIFIED BY 'prosalud2019';


# grant all privileges on programasalud.* to saludfiusac@'%' identified by 'prosalud2019';

USE programasalud;












DROP TABLE IF EXISTS programasalud.carrera;

CREATE TABLE programasalud.carrera
(
    carrera           VARCHAR(2) COLLATE utf8_unicode_ci  NOT NULL,
    nombre            VARCHAR(100) NOT NULL,
    nombre_corto      VARCHAR(100) NOT NULL,
    activo            BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(carrera)
);







DROP TABLE IF EXISTS programasalud.persona;

CREATE TABLE programasalud.persona
(
    id_persona        INT AUTO_INCREMENT NOT NULL,
    nombre            VARCHAR(500) COLLATE utf8_unicode_ci NOT NULL,
    apellido          VARCHAR(500) COLLATE utf8_unicode_ci NOT NULL,
    fecha_nacimiento  DATE NOT NULL,
    sexo              CHAR(1) NOT NULL,
    email             VARCHAR(50) COLLATE utf8_unicode_ci NULL,
    telefono          VARCHAR(8) COLLATE utf8_unicode_ci NULL,
    cui               DECIMAL(13,0) NULL,
    nov               DECIMAL(10,0) NULL,
    regpersonal       DECIMAL(9,0) NULL,
    carnet            DECIMAL(9,0) NULL,
    carrera           VARCHAR(2) COLLATE utf8_unicode_ci NULL,
    departamento      VARCHAR(120) COLLATE utf8_unicode_ci NULL,
    created           TIMESTAMP NOT NULL DEFAULT NOW(),
    updated           TIMESTAMP NOT NULL DEFAULT NOW(),
    source            VARCHAR(120) NOT NULL DEFAULT 'CREATED',
    activo            BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_persona)
) DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


ALTER TABLE programasalud.persona
    ADD CONSTRAINT FK_persona_carrera FOREIGN KEY(carrera)
        REFERENCES programasalud.carrera (carrera);












DROP TABLE IF EXISTS programasalud.usuario;

CREATE TABLE programasalud.usuario
(
    id_usuario    VARCHAR(50) NOT NULL,
    clave         CHAR(64) NOT NULL,
    id_persona    INT(11) NOT NULL,
    cambiar_clave BOOLEAN NOT NULL,
    activo        BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_usuario)
);

ALTER TABLE programasalud.usuario
    ADD CONSTRAINT FK_persona_usuario FOREIGN KEY(id_persona)
        REFERENCES programasalud.persona (id_persona);


DROP TABLE IF EXISTS programasalud.rol;

CREATE TABLE programasalud.rol
(
    id_rol             INT NOT NULL,
    nombre_rol         VARCHAR(40) NOT NULL,
    descripcion_rol    VARCHAR(100) NULL,
    activo             BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_rol)
);



DROP TABLE IF EXISTS programasalud.usuario_rol;

CREATE TABLE programasalud.usuario_rol
(
    id_usuario_rol    INTEGER(20) AUTO_INCREMENT NOT NULL,
    id_usuario        VARCHAR(50) NOT NULL,
    id_rol            INT(11) NOT NULL,
    activo            BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_usuario_rol)
);

ALTER TABLE programasalud.usuario_rol
    ADD CONSTRAINT FK_usuario_rol_rol FOREIGN KEY(id_rol)
        REFERENCES programasalud.rol (id_rol) ON DELETE CASCADE;

ALTER TABLE programasalud.usuario_rol
    ADD CONSTRAINT FK_usuario_rol_usuario FOREIGN KEY(id_usuario)
        REFERENCES programasalud.usuario (id_usuario) ON DELETE CASCADE;







DROP TABLE IF EXISTS programasalud.especialidad;

CREATE TABLE programasalud.especialidad
(
    id_especialidad   INT AUTO_INCREMENT NOT NULL,
    especialidad      VARCHAR(50) NOT NULL,
    activo            BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_especialidad)
);








DROP TABLE IF EXISTS programasalud.doctor;

CREATE TABLE programasalud.doctor
(
    id_doctor         INT(20) AUTO_INCREMENT NOT NULL,
    id_usuario        VARCHAR(50) NOT NULL,
    activo            BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_doctor)
);

ALTER TABLE programasalud.doctor
    ADD CONSTRAINT FK_doctor_usuario FOREIGN KEY(id_usuario)
        REFERENCES programasalud.usuario (id_usuario) ON DELETE CASCADE;




DROP TABLE IF EXISTS programasalud.doctor_especialidad;

CREATE TABLE programasalud.doctor_especialidad
(
    id_doctor_especialidad  INT AUTO_INCREMENT NOT NULL,
    id_doctor               INT NOT NULL,
    id_especialidad         INT NOT NULL,
    activo                  BOOLEAN NOT NULL,
    PRIMARY KEY(id_doctor_especialidad)
);

ALTER TABLE programasalud.doctor_especialidad
    ADD CONSTRAINT FK_doctor_especialidad_doctor FOREIGN KEY(id_doctor)
        REFERENCES programasalud.doctor (id_doctor) ON DELETE CASCADE;

ALTER TABLE programasalud.doctor_especialidad
    ADD CONSTRAINT FK_doctor_especialidad_especialidad FOREIGN KEY(id_especialidad)
        REFERENCES programasalud.especialidad (id_especialidad) ON DELETE CASCADE;




DROP TABLE IF EXISTS programasalud.clinica;

CREATE TABLE programasalud.clinica
(
    id_clinica      INT(20) AUTO_INCREMENT NOT NULL,
    nombre          VARCHAR(50) NOT NULL,
    ubicacion       VARCHAR(50) NOT NULL,
    descripcion     VARCHAR(255) NULL,
    columnas        TINYINT NOT NULL DEFAULT 1,
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_clinica)
);



DROP TABLE IF EXISTS programasalud.tipo_dato_medida;

CREATE TABLE programasalud.tipo_dato_medida
(
    id_tipo_dato   INT  NOT NULL,
    tipo_dato      VARCHAR(50) NOT NULL,
    activo         BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_tipo_dato)
);












DROP TABLE IF EXISTS programasalud.medida;

CREATE TABLE programasalud.medida
(
    id_medida       INT(20) AUTO_INCREMENT NOT NULL,
    nombre          VARCHAR(50) NOT NULL,
    id_tipo_dato    INT NOT NULL,
    unidad_medida   VARCHAR(1000) NOT NULL,
    valor_minimo    VARCHAR(50) NULL,
    valor_maximo    VARCHAR(50) NULL,
    obligatorio     BOOLEAN NOT NULL,
    colspan         TINYINT NOT NULL DEFAULT 1,
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_medida)
);


ALTER TABLE programasalud.medida
    ADD CONSTRAINT FK_medida_tipo_dato FOREIGN KEY(id_tipo_dato)
        REFERENCES programasalud.tipo_dato_medida (id_tipo_dato) ON DELETE CASCADE;




DROP TABLE IF EXISTS programasalud.clinica_doctor;

CREATE TABLE programasalud.clinica_doctor
(
    id_clinica_doctor  INT AUTO_INCREMENT NOT NULL,
    id_clinica         INT NOT NULL,
    id_doctor          INT NOT NULL,
    activo             BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT FK_clinica_doctor_clinica FOREIGN KEY(id_clinica)REFERENCES programasalud.clinica (id_clinica) ON DELETE CASCADE,
    CONSTRAINT FK_clinica_doctor_doctor FOREIGN KEY(id_doctor)REFERENCES programasalud.doctor (id_doctor) ON DELETE CASCADE,
    PRIMARY KEY(id_clinica_doctor)
);







DROP TABLE IF EXISTS programasalud.clinica_medida;

CREATE TABLE programasalud.clinica_medida
(
    id_clinica_medida  INT AUTO_INCREMENT NOT NULL,
    id_clinica         INT NOT NULL,
    id_medida          INT NOT NULL,
    activo             BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT FK_clinica_medida_clinica FOREIGN KEY(id_clinica) REFERENCES programasalud.clinica (id_clinica) ON DELETE CASCADE,
    CONSTRAINT FK_clinica_medida_medida FOREIGN KEY(id_medida) REFERENCES programasalud.medida (id_medida) ON DELETE CASCADE,
    PRIMARY KEY(id_clinica_medida)
);




DROP TABLE IF EXISTS programasalud.accion;

CREATE TABLE programasalud.accion
(
    id_accion               INT AUTO_INCREMENT NOT NULL,
    nombre                  VARCHAR(150) NOT NULL,
    activo                  BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_accion)
);




DROP TABLE IF EXISTS programasalud.clinica_accion;

CREATE TABLE programasalud.clinica_accion
(
    id_clinica_accion  INT AUTO_INCREMENT NOT NULL,
    id_clinica         INT NOT NULL,
    id_accion          INT NOT NULL,
    activo             BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT FK_clinica_acion_clinica FOREIGN KEY(id_clinica)REFERENCES programasalud.clinica (id_clinica) ON DELETE CASCADE,
    CONSTRAINT FK_clinica_accion_accion FOREIGN KEY(id_accion)REFERENCES programasalud.accion (id_accion) ON DELETE CASCADE,
    PRIMARY KEY(id_clinica_accion)
);














DROP TABLE IF EXISTS programasalud.bebedero;

CREATE TABLE programasalud.bebedero
(
    id_bebedero             INT AUTO_INCREMENT NOT NULL,
    nombre                  VARCHAR(100) NOT NULL,
    ubicacion               VARCHAR(250) NOT NULL,
    fecha_mantenimiento     DATE NOT NULL,
    estado                  VARCHAR(200) NOT NULL,
    observaciones           VARCHAR(1000),
    activo                  BOOLEAN NOT NULL DEFAULT TRUE,
    id_usuario VARCHAR(50) NOT NULL,
    creado DATETIME NOT NULL DEFAULT NOW(),
    actualizado DATETIME NOT NULL DEFAULT NOW(),
    CONSTRAINT FK_bebedero_usuario FOREIGN KEY(id_usuario) REFERENCES programasalud.usuario(id_usuario),
    PRIMARY KEY(id_bebedero)
) ;










DROP TABLE IF EXISTS programasalud.tipo_discapacidad;

CREATE TABLE programasalud.tipo_discapacidad
(
    id_tipo_discapacidad    INT AUTO_INCREMENT NOT NULL,
    nombre                  VARCHAR(250) NOT NULL,
    activo                  BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_tipo_discapacidad)
);














DROP TABLE IF EXISTS programasalud.seleccion_persona;
DROP TABLE IF EXISTS programasalud.campeonato;
DROP TABLE IF EXISTS programasalud.seleccion;

CREATE TABLE programasalud.seleccion
(
    id_seleccion              INT AUTO_INCREMENT NOT NULL,
    nombre                    VARCHAR(255) NOT NULL,
    descripcion               VARCHAR(255),
    especialidad              VARCHAR(255) NOT NULL,
    estado                    VARCHAR(255) NOT NULL,
    activo                    BOOLEAN NOT NULL DEFAULT TRUE,
    id_usuario VARCHAR(50) NOT NULL,
    creado DATETIME NOT NULL DEFAULT NOW(),
    actualizado DATETIME NOT NULL DEFAULT NOW(),
    CONSTRAINT FK_seleccion_usuario FOREIGN KEY(id_usuario) REFERENCES programasalud.usuario(id_usuario),
    PRIMARY KEY(id_seleccion)
);







DROP TABLE IF EXISTS programasalud.seleccion_persona;

CREATE TABLE programasalud.seleccion_persona
(
    id_seleccion_persona     INT AUTO_INCREMENT NOT NULL,
    id_seleccion             INT NOT NULL,
    id_persona               INT NOT NULL,
    fecha_inicio             DATE NOT NULL,
    fecha_fin                DATE NULL,
    activo                   BOOLEAN NOT NULL DEFAULT TRUE,
    id_usuario VARCHAR(50) NOT NULL,
    creado DATETIME NOT NULL DEFAULT NOW(),
    actualizado DATETIME NOT NULL DEFAULT NOW(),
    CONSTRAINT FK_seleccion_persona_usuario FOREIGN KEY(id_usuario) REFERENCES programasalud.usuario(id_usuario),
    PRIMARY KEY(id_seleccion_persona),
    CONSTRAINT FK_seleccion_persona_seleccion FOREIGN KEY(id_seleccion) REFERENCES programasalud.seleccion(id_seleccion),
    CONSTRAINT FK_seleccion_persona_persona FOREIGN KEY(id_persona) REFERENCES programasalud.persona(id_persona)
);






DROP TABLE IF EXISTS programasalud.campeonato;

CREATE TABLE programasalud.campeonato
(
    id_campeonato        INT AUTO_INCREMENT NOT NULL,
    id_seleccion         INT NOT NULL,
    nombre               VARCHAR(255) NOT NULL,
    fecha                DATE NOT NULL,
    victorioso           BOOLEAN NOT NULL,
    observaciones        VARCHAR(255) NULL,
    activo               BOOLEAN NOT NULL DEFAULT TRUE,
    id_usuario VARCHAR(50) NOT NULL,
    creado DATETIME NOT NULL DEFAULT NOW(),
    actualizado DATETIME NOT NULL DEFAULT NOW(),
    CONSTRAINT FK_campeonato_seleccion FOREIGN KEY(id_seleccion) REFERENCES programasalud.seleccion (id_seleccion),
    CONSTRAINT FK_campeonato_usuario FOREIGN KEY(id_usuario) REFERENCES programasalud.usuario(id_usuario),
    PRIMARY KEY(id_campeonato)
);






/*
DROP TABLE IF EXISTS programasalud.tipo_persona;

CREATE TABLE programasalud.tipo_persona
(
    id_tipo_persona         INT AUTO_INCREMENT NOT NULL,
    nombre                  VARCHAR(255) NOT NULL,
    activo                  BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_tipo_persona)
);*/













/*-------------------------------------------------------------*/






/*


delete from estudiante_deportes;
delete from disciplina;


DROP TABLE IF EXISTS programasalud.estudiante_deportes;
DROP TABLE IF EXISTS programasalud.asignacion_deportes;
DROP TABLE IF EXISTS programasalud.disciplina;

*/

CREATE TABLE programasalud.disciplina
(
    id_disciplina       INT AUTO_INCREMENT NOT NULL,
    semestre            VARCHAR(6) NOT NULL,
    nombre              VARCHAR(100) NOT NULL,
    limite              INT NOT NULL,
    flg_lunes           BOOLEAN NOT NULL DEFAULT FALSE,
    flg_martes          BOOLEAN NOT NULL DEFAULT FALSE,
    flg_miercoles       BOOLEAN NOT NULL DEFAULT FALSE,
    flg_jueves          BOOLEAN NOT NULL DEFAULT FALSE,
    flg_viernes         BOOLEAN NOT NULL DEFAULT FALSE,
    flg_sabado          BOOLEAN NOT NULL DEFAULT FALSE,
    hora_inicio         VARCHAR(5) NOT NULL,
    hora_fin            VARCHAR(5) NOT NULL,
    id_persona          INT NOT NULL,
    activo              BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_disciplina)
);

ALTER TABLE programasalud.disciplina
    ADD CONSTRAINT FK_disciplina_persona FOREIGN KEY(id_persona)
        REFERENCES programasalud.persona (id_persona) ON DELETE CASCADE;








/*------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------
 */












DROP TABLE IF EXISTS programasalud.capacitacion_persona;
DROP TABLE IF EXISTS programasalud.capacitacion;

CREATE TABLE programasalud.capacitacion
(
    id_capacitacion             INT AUTO_INCREMENT NOT NULL,
    nombre                      VARCHAR(250) NOT NULL,
    descripcion                 VARCHAR(600) NOT NULL,
    tipo_capacitacion           VARCHAR(50) NOT NULL,
    estado                      VARCHAR(100) NOT NULL,
    fecha_inicio                DATE NOT NULL,
    fecha_fin                   DATE NULL,
    activo                      BOOLEAN NOT NULL DEFAULT TRUE,
    id_usuario VARCHAR(50) NOT NULL,
    creado DATETIME NOT NULL DEFAULT NOW(),
    actualizado DATETIME NOT NULL DEFAULT NOW(),
    CONSTRAINT FK_capacitacion_usuario FOREIGN KEY(id_usuario) REFERENCES programasalud.usuario(id_usuario),
    PRIMARY KEY(id_capacitacion)
);







DROP TABLE IF EXISTS programasalud.capacitacion_persona;

CREATE TABLE programasalud.capacitacion_persona
(
    id_capacitacion_persona     INT AUTO_INCREMENT NOT NULL,
    id_capacitacion             INT NOT NULL,
    id_persona                  INT NOT NULL,
    activo                      BOOLEAN NOT NULL DEFAULT TRUE,
    id_usuario VARCHAR(50) NOT NULL,
    creado DATETIME NOT NULL DEFAULT NOW(),
    actualizado DATETIME NOT NULL DEFAULT NOW(),
    CONSTRAINT FK_capacitacion_persona_usuario FOREIGN KEY(id_usuario) REFERENCES programasalud.usuario(id_usuario),
    PRIMARY KEY(id_capacitacion_persona),
    CONSTRAINT FK_capacitacion_persona_persona FOREIGN KEY(id_persona) REFERENCES programasalud.persona (id_persona),
    CONSTRAINT FK_capacitacion_persona_capacitacion FOREIGN KEY(id_capacitacion) REFERENCES programasalud.capacitacion (id_capacitacion)
);
























DROP TABLE IF EXISTS programasalud.cita;

CREATE TABLE programasalud.cita
(
    id_cita                     INT AUTO_INCREMENT NOT NULL,
    id_clinica                  INT NOT NULL,
    id_persona                  INT NOT NULL,
    id_doctor                   INT NOT NULL,
    fecha                       DATETIME NOT NULL,
    email                       VARCHAR(50) NOT NULL,
    sintoma                     VARCHAR(500) NOT NULL,
    activo                      BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_cita)
);

ALTER TABLE programasalud.cita
    ADD CONSTRAINT FK_cita_clinica FOREIGN KEY(id_clinica)
        REFERENCES programasalud.clinica (id_clinica);


ALTER TABLE programasalud.cita
    ADD CONSTRAINT FK_clinica_persona FOREIGN KEY(id_persona)
        REFERENCES programasalud.persona (id_persona);


ALTER TABLE programasalud.cita
    ADD CONSTRAINT FK_clinica_doctor FOREIGN KEY(id_doctor)
        REFERENCES programasalud.doctor (id_doctor);












DROP TABLE IF EXISTS programasalud.flujo_cita;

CREATE TABLE programasalud.flujo_cita
(
    id_flujo_cita               INT AUTO_INCREMENT NOT NULL,
    id_cita                     INT NOT NULL,
    paso                        ENUM('CREADO', 'ATENDIENDO', 'EDITADO', 'FINALIZADO', 'CANCELADO') NOT NULL DEFAULT 'CREADO',
    creado                      DATETIME NOT NULL DEFAULT NOW(),
    actualizado                 DATETIME NOT NULL DEFAULT NOW(),
    observaciones               VARCHAR(500) NULL,
    flg_automatico              BOOLEAN NOT NULL DEFAULT TRUE,
    activo                      BOOLEAN NOT NULL DEFAULT TRUE,
    flujo_cita_padre            INT NULL,
    PRIMARY KEY(id_flujo_cita)
);

ALTER TABLE programasalud.flujo_cita
    ADD CONSTRAINT FK_flujo_cita_cita FOREIGN KEY(id_cita)
        REFERENCES programasalud.cita (id_cita);

ALTER TABLE programasalud.flujo_cita
    ADD CONSTRAINT FK_flujo_cita_flujo_cita FOREIGN KEY(flujo_cita_padre)
        REFERENCES programasalud.flujo_cita (id_flujo_cita);








/*
**************************************************************
**************************************************************
**************************************************************
**************************************************************
**************************************************************
**************************************************************
**************************************************************
 */




DROP TABLE IF EXISTS programasalud.persona_medida;

CREATE TABLE programasalud.persona_medida
(
    id_persona_medida       INT AUTO_INCREMENT NOT NULL,
    id_medida               INT NOT NULL,
    id_persona              INT NOT NULL,
    id_cita                 INT NULL,
    valor                   VARCHAR(150) NOT NULL,
    creado                  DATETIME NOT NULL DEFAULT NOW(),
    actualizado             DATETIME NOT NULL DEFAULT NOW(),
    activo                  BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_persona_medida)
);

ALTER TABLE programasalud.persona_medida
    ADD CONSTRAINT FK_persona_medida_medida FOREIGN KEY(id_medida)
        REFERENCES programasalud.medida (id_medida);

ALTER TABLE programasalud.persona_medida
    ADD CONSTRAINT FK_persona_medida_persona FOREIGN KEY(id_persona)
        REFERENCES programasalud.persona (id_persona);

ALTER TABLE programasalud.persona_medida
    ADD CONSTRAINT FK_persona_medida_cita FOREIGN KEY(id_cita)
        REFERENCES programasalud.cita (id_cita);











DROP TABLE IF EXISTS programasalud.asignacion_deportes;

CREATE TABLE programasalud.asignacion_deportes
(
    id_asignacion_deportes    INT AUTO_INCREMENT NOT NULL,
    id_disciplina             INT NOT NULL,
    id_persona                INT NOT NULL,
    semestre                  VARCHAR(6) NOT NULL,
    creado                    DATETIME NOT NULL DEFAULT NOW(),
    activo                    BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_asignacion_deportes)
);

ALTER TABLE programasalud.asignacion_deportes
    ADD CONSTRAINT FK_asignacion_deportes_disciplina FOREIGN KEY(id_disciplina)
        REFERENCES programasalud.disciplina (id_disciplina);

ALTER TABLE programasalud.asignacion_deportes
    ADD CONSTRAINT FK_asignacion_deportes_persona FOREIGN KEY(id_persona)
        REFERENCES programasalud.persona (id_persona);











DROP TABLE IF EXISTS programasalud.tipo_enfermedad;

CREATE TABLE programasalud.tipo_enfermedad
(
    id_tipo_enfermedad          INT AUTO_INCREMENT NOT NULL,
    nombre                      VARCHAR(255) NOT NULL,
    activo                      BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_tipo_enfermedad)
);




DROP TABLE IF EXISTS programasalud.disciplina_persona;

CREATE TABLE programasalud.disciplina_persona
(
    id_disciplina_persona       INT AUTO_INCREMENT NOT NULL,
    nombre                      VARCHAR(255) NOT NULL,
    activo                      BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_disciplina_persona)
);







DROP TABLE IF EXISTS programasalud.persona_ficha;

CREATE TABLE programasalud.persona_ficha
(
    id_persona                INT NOT NULL,
    flag_tiene_discapacidad   BOOLEAN NOT NULL,
    id_tipo_discapacidad      INT NULL,
    telefono_emergencia       VARCHAR(8) NOT NULL,
    contacto_emergencia       VARCHAR(255) NOT NULL,
    id_tipo_enfermedad        INT NOT NULL,
    id_disciplina_persona     INT NOT NULL,
    creado                    DATETIME NOT NULL DEFAULT NOW(),
    actualizado               DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY(id_persona),
    CONSTRAINT FK_persona_ficha_persona FOREIGN KEY(id_persona) REFERENCES programasalud.persona(id_persona),
    CONSTRAINT FK_persona_ficha_tipo_discapacidad FOREIGN KEY(id_tipo_discapacidad) REFERENCES programasalud.tipo_discapacidad(id_tipo_discapacidad),
    CONSTRAINT FK_persona_ficha_tipo_enfermedad FOREIGN KEY(id_tipo_enfermedad) REFERENCES programasalud.tipo_enfermedad(id_tipo_enfermedad),
    CONSTRAINT FK_persona_ficha_disciplina FOREIGN KEY(id_disciplina_persona) REFERENCES programasalud.disciplina_persona(id_disciplina_persona)
);






DROP TABLE IF EXISTS programasalud.cita_accion;

CREATE TABLE programasalud.cita_accion
(
    id_cita_accion              INT AUTO_INCREMENT NOT NULL,
    id_cita                     INT NOT NULL,
    id_accion                   INT NOT NULL,
    observaciones               VARCHAR(500) NOT NULL,
    activo                      BOOLEAN NOT NULL DEFAULT TRUE,
    creado                      DATETIME NOT NULL DEFAULT NOW(),
    actualizado                 DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY(id_cita_accion),
    CONSTRAINT FK_cita_accion_cita FOREIGN KEY(id_cita) REFERENCES programasalud.cita(id_cita),
    CONSTRAINT FK_cita_accion_accion FOREIGN KEY(id_accion) REFERENCES programasalud.accion(id_accion)
);










DROP TABLE IF EXISTS programasalud.categoria_convivencia;

CREATE TABLE programasalud.categoria_convivencia
(
    id_categoria_convivencia    INT AUTO_INCREMENT NOT NULL,
    nombre                      VARCHAR(500) NOT NULL,
    activo                      BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_categoria_convivencia)
);



DROP TABLE IF EXISTS programasalud.lugar_convivencia;

CREATE TABLE programasalud.lugar_convivencia
(
    id_lugar_convivencia        INT AUTO_INCREMENT NOT NULL,
    id_categoria_convivencia    INT NOT NULL,
    nombre                      VARCHAR(500) NOT NULL,
    activo                      BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_lugar_convivencia),
    CONSTRAINT FK_lugar_convivencia_categoria FOREIGN KEY(id_categoria_convivencia)
        REFERENCES programasalud.categoria_convivencia(id_categoria_convivencia)
);







DROP TABLE IF EXISTS programasalud.unidad_medida;

CREATE TABLE programasalud.unidad_medida
(
    id_unidad_medida        INT AUTO_INCREMENT NOT NULL,
    nombre                  VARCHAR(100) NOT NULL,
    nombre_corto            VARCHAR(50) NOT NULL,
    activo                  BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_unidad_medida)
);




DROP TABLE IF EXISTS programasalud.espacio_convivencia;

CREATE TABLE programasalud.espacio_convivencia
(
    id_espacio_convivencia  INT AUTO_INCREMENT NOT NULL,
    nombre                  VARCHAR(100) NOT NULL,
    ubicacion               VARCHAR(250) NULL,
    cantidad                DECIMAL(10,4) NOT NULL,
    id_unidad_medida        INT NOT NULL,
    id_lugar_convivencia    INT NOT NULL,
    anio                    INT NOT NULL,
    costo                   DECIMAL(10,4) NOT NULL,
    estado                  ENUM('PLANIFICACION', 'EJECUCION', 'SUPERVISION', 'FINALIZADO', 'VIGENTE', 'SUSPENDIDO') NOT NULL,
    id_persona              INT NOT NULL,
    observaciones           VARCHAR(2000),
    activo                  BOOLEAN NOT NULL DEFAULT TRUE,
    id_usuario VARCHAR(50) NOT NULL,
    creado DATETIME NOT NULL DEFAULT NOW(),
    actualizado DATETIME NOT NULL DEFAULT NOW(),
    CONSTRAINT FK_espacio_convivencia_usuario FOREIGN KEY(id_usuario) REFERENCES programasalud.usuario(id_usuario),
    PRIMARY KEY(id_espacio_convivencia),
    CONSTRAINT FK_espacio_convivencia_medida FOREIGN KEY(id_unidad_medida)
        REFERENCES programasalud.unidad_medida (id_unidad_medida),
    CONSTRAINT FK_espacio_convivencia_lugar FOREIGN KEY(id_lugar_convivencia)
        REFERENCES programasalud.lugar_convivencia (id_lugar_convivencia),
    CONSTRAINT FK_espacio_convivencia_persona FOREIGN KEY(id_persona)
        REFERENCES programasalud.persona (id_persona)
);











DROP TABLE IF EXISTS programasalud.reporte_rol;
DROP TABLE IF EXISTS programasalud.reporte_parametro;
DROP TABLE IF EXISTS programasalud.reporte;

CREATE TABLE programasalud.reporte
(
    id_reporte      INT NOT NULL,
    nombre          VARCHAR(255) NOT NULL,
    sp_name         VARCHAR(255) NOT NULL,
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_reporte)
);



DROP TABLE IF EXISTS programasalud.reporte_rol;

CREATE TABLE programasalud.reporte_rol
(
    id_reporte_rol  INT AUTO_INCREMENT NOT NULL,
    id_reporte      INT NOT NULL,
    id_rol          INT NOT NULL,
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_reporte_rol),
    CONSTRAINT FK_reporte_rol_reporte FOREIGN KEY(id_reporte) REFERENCES programasalud.reporte (id_reporte),
    CONSTRAINT FK_reporte_rol_rol FOREIGN KEY(id_rol) REFERENCES programasalud.rol (id_rol)
);

DROP TABLE IF EXISTS programasalud.reporte_parametro;

CREATE TABLE programasalud.reporte_parametro
(
    id_reporte_parametro        INT AUTO_INCREMENT NOT NULL,
    id_reporte                  INT NOT NULL,
    display_name                VARCHAR(255) NOT NULL,
    var_name                    VARCHAR(255) NOT NULL,
    var_type                    VARCHAR(255) NOT NULL,
    moreinfo                    VARCHAR(500) NOT NULL DEFAULT '{}',
    orden                       INT NOT NULL DEFAULT 0,
    activo                      BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_reporte_parametro),
    CONSTRAINT FK_reporte_parametro_reporte FOREIGN KEY(id_reporte) REFERENCES programasalud.reporte(id_reporte)
);

