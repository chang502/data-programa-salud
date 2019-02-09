
DROP TABLE IF EXISTS programasalud.persona;

CREATE TABLE programasalud.persona
(
    id_persona        INT AUTO_INCREMENT NOT NULL,
    primer_nombre     VARCHAR(50) NOT NULL,
    segundo_nombre    VARCHAR(50) NULL,
    primer_apellido   VARCHAR(50) NOT NULL,
    segundo_apellido  VARCHAR(50) NULL,
    fecha_nacimiento  DATE NOT NULL,
    sexo              CHAR(1) NOT NULL,
    email             VARCHAR(50) NULL,
    telefono          VARCHAR(8) NULL,
    PRIMARY KEY(id_persona)
);

DROP TABLE IF EXISTS programasalud.usuario;

CREATE TABLE programasalud.usuario
(
    id_usuario    VARCHAR(50) NOT NULL,
    clave         CHAR(64) NOT NULL,
    id_persona    INT(11) NOT NULL,
    activo        BOOLEAN NOT NULL,
    cambiar_clave BOOLEAN NOT NULL,
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
    activo             BOOLEAN NOT NULL,
    PRIMARY KEY(id_rol)
);



DROP TABLE IF EXISTS programasalud.usuario_rol;

CREATE TABLE programasalud.usuario_rol
(
    id_usuario_rol    INTEGER(20) AUTO_INCREMENT NOT NULL,
    id_usuario        VARCHAR(50) NOT NULL,
    id_rol            INT(11) NOT NULL,
    activo            BOOLEAN NOT NULL,
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
    activo            BOOLEAN NOT NULL,
    PRIMARY KEY(id_especialidad)
);








DROP TABLE IF EXISTS programasalud.doctor;

CREATE TABLE programasalud.doctor
(
    id_doctor         INT(20) AUTO_INCREMENT NOT NULL,
    id_usuario        VARCHAR(50) NOT NULL,
    activo            BOOLEAN NOT NULL,
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
    activo          BOOLEAN NOT NULL,
    PRIMARY KEY(id_clinica)
);



DROP TABLE IF EXISTS programasalud.tipo_dato_medida;

CREATE TABLE programasalud.tipo_dato_medida
(
    id_tipo_dato   INT  NOT NULL,
    tipo_dato      VARCHAR(50) NOT NULL,
    activo         BOOLEAN NOT NULL,
    PRIMARY KEY(id_tipo_dato)
);












DROP TABLE IF EXISTS programasalud.medida;

CREATE TABLE programasalud.medida
(
    id_medida       INT(20) AUTO_INCREMENT NOT NULL,
    nombre          VARCHAR(50) NOT NULL,
    id_tipo_dato    INT NOT NULL,
    unidad_medida   VARCHAR(50) NOT NULL,
    valor_minimo    VARCHAR(50) NULL,
    valor_maximo    VARCHAR(50) NULL,
    obligatorio     BOOLEAN NOT NULL,
    activo          BOOLEAN NOT NULL,
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
    activo             BOOLEAN NOT NULL,
    PRIMARY KEY(id_clinica_doctor)
);

ALTER TABLE programasalud.clinica_doctor
    ADD CONSTRAINT FK_clinica_doctor_clinica FOREIGN KEY(id_clinica)
        REFERENCES programasalud.clinica (id_clinica) ON DELETE CASCADE;

ALTER TABLE programasalud.clinica_doctor
    ADD CONSTRAINT FK_clinica_doctor_doctor FOREIGN KEY(id_doctor)
        REFERENCES programasalud.doctor (id_doctor) ON DELETE CASCADE;





DROP TABLE IF EXISTS programasalud.clinica_medida;

CREATE TABLE programasalud.clinica_medida
(
    id_clinica_medida  INT AUTO_INCREMENT NOT NULL,
    id_clinica         INT NOT NULL,
    id_medida          INT NOT NULL,
    activo             BOOLEAN NOT NULL,
    PRIMARY KEY(id_clinica_medida)
);

ALTER TABLE programasalud.clinica_medida
    ADD CONSTRAINT FK_clinica_medida_clinica FOREIGN KEY(id_clinica)
        REFERENCES programasalud.clinica (id_clinica) ON DELETE CASCADE;

ALTER TABLE programasalud.clinica_medida
    ADD CONSTRAINT FK_clinica_medida_medida FOREIGN KEY(id_medida)
        REFERENCES programasalud.medida (id_medida) ON DELETE CASCADE;












DROP TABLE IF EXISTS programasalud.bebedero;

CREATE TABLE programasalud.bebedero
(
    id_bebedero             INT AUTO_INCREMENT NOT NULL,
    nombre                  VARCHAR(100) NOT NULL,
    ubicacion               VARCHAR(250) NOT NULL,
    fecha_mantenimiento     DATE NOT NULL,
    estado                  VARCHAR(200) NOT NULL,
    observaciones           VARCHAR(1000),
    activo                  BOOLEAN NOT NULL,
    PRIMARY KEY(id_bebedero)
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
    ubicacion               VARCHAR(250) NOT NULL,
    cantidad                DECIMAL(10,4) NOT NULL,
    id_unidad_medida        INT NOT NULL,
    anio                    INT NOT NULL,
    costo                   DECIMAL(10,4) NOT NULL,
    estado                  VARCHAR(200) NOT NULL,
    observaciones           VARCHAR(1000),
    activo                  BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_espacio_convivencia)
);

ALTER TABLE programasalud.espacio_convivencia
    ADD CONSTRAINT FK_espacio_convivencia_medida FOREIGN KEY(id_unidad_medida)
        REFERENCES programasalud.unidad_medida (id_unidad_medida);












DROP TABLE IF EXISTS programasalud.tipo_discapacidad;

CREATE TABLE programasalud.tipo_discapacidad
(
    id_tipo_discapacidad    INT AUTO_INCREMENT NOT NULL,
    nombre                  VARCHAR(250) NOT NULL,
    activo                  BOOLEAN NOT NULL,
    PRIMARY KEY(id_tipo_discapacidad)
);















DROP TABLE IF EXISTS programasalud.seleccion;

CREATE TABLE programasalud.seleccion
(
    id_seleccion              INT AUTO_INCREMENT NOT NULL,
    nombre                    VARCHAR(255) NOT NULL,
    descripcion               VARCHAR(255),
    especialidad              VARCHAR(255) NOT NULL,
    estado                    VARCHAR(255) NOT NULL,
    activo                    BOOLEAN NOT NULL,
    PRIMARY KEY(id_seleccion)
);
















DROP TABLE IF EXISTS programasalud.tipo_persona;

CREATE TABLE programasalud.tipo_persona
(
    id_tipo_persona         INT AUTO_INCREMENT NOT NULL,
    nombre                  VARCHAR(255) NOT NULL,
    activo                  BOOLEAN NOT NULL,
    PRIMARY KEY(id_tipo_persona)
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
    activo               BOOLEAN NOT NULL,
    PRIMARY KEY(id_campeonato)
);


ALTER TABLE programasalud.campeonato
    ADD CONSTRAINT FK_campeonato_seleccion FOREIGN KEY(id_seleccion)
        REFERENCES programasalud.seleccion (id_seleccion);




/*-------------------------------------------------------------*/
-- delete from estudiante_deportes;
-- delete from tipo_documento;


-- DROP TABLE IF EXISTS programasalud.estudiante_deportes;
DROP TABLE IF EXISTS programasalud.tipo_documento;

CREATE TABLE programasalud.tipo_documento
(
    id_tipo_documento       INT AUTO_INCREMENT NOT NULL,
    nombre                  VARCHAR(250) NOT NULL,
    alcance                 VARCHAR(20) NOT NULL,
    activo                  BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_tipo_documento)
);










delete from estudiante_deportes;
delete from disciplina;


DROP TABLE IF EXISTS programasalud.estudiante_deportes;
DROP TABLE IF EXISTS programasalud.asignacion_deportes;
DROP TABLE IF EXISTS programasalud.disciplina;

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











DROP TABLE IF EXISTS programasalud.estudiante_deportes;
DROP TABLE IF EXISTS programasalud.asignacion_deportes;

CREATE TABLE programasalud.asignacion_deportes
(
    id_estudiante_deportes    INT AUTO_INCREMENT NOT NULL,
    id_tipo_documento         INT NOT NULL,
    numero_documento          VARCHAR(200),
    email                     VARCHAR(50),
    peso                      INT NOT NULL,
    estatura                  DECIMAL(5,2) NOT NULL,
    cualidades_especiales     BOOLEAN NOT NULL,
    id_tipo_discapacidad      INT NULL,
    id_disciplina             INT NOT NULL,
    semestre                  VARCHAR(6) NOT NULL,
    id_persona                INT NOT NULL,
    activo                    BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_estudiante_deportes)
);

ALTER TABLE programasalud.asignacion_deportes
    ADD CONSTRAINT FK_estudiante_deportes_persona FOREIGN KEY(id_persona)
        REFERENCES programasalud.persona (id_persona);

ALTER TABLE programasalud.asignacion_deportes
    ADD CONSTRAINT FK_estudiante_deportes_tipo_documento FOREIGN KEY(id_tipo_documento)
        REFERENCES programasalud.tipo_documento (id_tipo_documento);

ALTER TABLE programasalud.asignacion_deportes
    ADD CONSTRAINT FK_estudiante_deportes_disciplina FOREIGN KEY(id_disciplina)
        REFERENCES programasalud.disciplina (id_disciplina);


ALTER TABLE programasalud.asignacion_deportes
    ADD CONSTRAINT FK_estudiante_deportes_tipo_discapacidad FOREIGN KEY(id_tipo_discapacidad)
        REFERENCES programasalud.tipo_discapacidad (id_tipo_discapacidad);














/*------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------
 */





ALTER TABLE programasalud.usuario
    DROP foreign key FK_persona_usuario;


ALTER TABLE programasalud.disciplina
    DROP foreign key FK_disciplina_persona;


ALTER TABLE programasalud.asignacion_deportes
    DROP foreign key FK_estudiante_deportes_persona;





DROP TABLE IF EXISTS programasalud.persona;

CREATE TABLE programasalud.persona
(
    id_persona        INT AUTO_INCREMENT NOT NULL,
    nombre            VARCHAR(500) NOT NULL,
    apellido          VARCHAR(500) NOT NULL,
    fecha_nacimiento  DATE NOT NULL,
    sexo              CHAR(1) NOT NULL,
    email             VARCHAR(50) NULL,
    telefono          VARCHAR(8) NULL,
    cui               DECIMAL(13,0) NULL,
    nov               DECIMAL(10,0) NULL,
    regpersonal       DECIMAL(9,0) NULL,
    carnet            DECIMAL(9,0) NULL,
    created           TIMESTAMP NOT NULL DEFAULT NOW(),
    updated           TIMESTAMP NOT NULL DEFAULT NOW(),
    source            VARCHAR(120) NOT NULL DEFAULT 'CREATED',
    activo            BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_persona)
);





DELETE FROM usuario;

ALTER TABLE programasalud.usuario
    ADD CONSTRAINT FK_persona_usuario FOREIGN KEY(id_persona)
        REFERENCES programasalud.persona (id_persona);

DELETE FROM disciplina;

ALTER TABLE programasalud.disciplina
    ADD CONSTRAINT FK_disciplina_persona FOREIGN KEY(id_persona)
        REFERENCES programasalud.persona (id_persona) ON DELETE CASCADE;


DELETE FROM asignacion_deportes;

ALTER TABLE programasalud.asignacion_deportes
    ADD CONSTRAINT FK_estudiante_deportes_persona FOREIGN KEY(id_persona)
        REFERENCES programasalud.persona (id_persona);










DROP TABLE IF EXISTS programasalud.seleccion_persona;

CREATE TABLE programasalud.seleccion_persona
(
    id_seleccion_persona        INT AUTO_INCREMENT NOT NULL,
    id_seleccion                INT NOT NULL,
    id_persona                  INT NOT NULL,
    fecha_inicio                DATE NOT NULL,
    fecha_fin                   DATE NULL,
    activo                      BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_seleccion_persona)
);


ALTER TABLE programasalud.seleccion_persona
    ADD CONSTRAINT FK_seleccion_persona_seleccion FOREIGN KEY(id_seleccion)
        REFERENCES programasalud.seleccion (id_seleccion);


ALTER TABLE programasalud.seleccion_persona
    ADD CONSTRAINT FK_seleccion_persona_persona FOREIGN KEY(id_persona)
        REFERENCES programasalud.persona (id_persona);