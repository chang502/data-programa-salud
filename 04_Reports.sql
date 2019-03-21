CREATE OR REPLACE PROCEDURE programasalud.rpt_citas()
BEGIN
    select concat(p.nombre,' ',p.apellido) paciente, c2.nombre carrera, p.departamento,
    c.sintoma, fc.paso estado
    from cita c
    join flujo_cita fc on c.id_cita = fc.id_cita and fc.activo
    join persona p on c.id_persona = p.id_persona
    left join carrera c2 on p.carrera = c2.carrera;
END;