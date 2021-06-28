create database perUsuarios
use perUsuarios

create table menu(
id_menu int not null IDENTITY (1,1) primary key,
Nombre varchar(50),
Icono varchar(50)
)

create table submenu(
id_sub int not null IDENTITY (1,1) primary key,
NombreSub varchar(50),
NomForm varchar(50),
FK_Menu int references menu(id_menu) on delete cascade on update cascade
)

create table rol(
id_rol int not null IDENTITY (1,1) primary key,
NombreRol varchar(50),
)

create table permiso(
id_permiso int not null IDENTITY (1,1) primary key,
activo bit,
FK_rol int references rol(id_rol) on delete cascade on update cascade,
FK_submenu int references submenu(id_sub) on delete cascade on update cascade
)

create table usuarios(
id_usuario int not null IDENTITY (1,1) primary key,
NombreUs varchar(50),
Usuario varchar(50),
Password varchar(50),
FK_rol int references rol(id_rol) on delete cascade on update cascade
)

insert into menu(Nombre, Icono) values 
	('Usuarios','\Iconos\Usuario.png'),
	('Ventas','\Iconos\Ventas.png'),
	('Reportes','\Iconos\Reportes.png')

--MENU PARA EL USUARIO
	insert into submenu(NombreSub, NomForm, FK_Menu) values
	 ('Crear Usuario','frmCrearUsuario',1),
	 ('Editar Usuario','frmEditarUsuario',1),
	 ('Eliminar Usuario','frmEliminarUsuario',1)

--MENU PARA LAS VENTAS
	 insert into SUBMENU(NombreSub, NomForm, FK_Menu) values
	 ('Crear Venta','frmCrearVenta',2),
	 ('Editar Venta','frmEditarVenta',2)

--MENU PARA LOS REPORTES
	insert into SUBMENU(NombreSub, NomForm, FK_Menu) values
	 ('Reporte Ventas','frmReporteVenta',3),
	 ('Reporte Cliente','frmReporteCliente',3)

select * from MENU m
 inner join submenu sb on m.id_menu = sb.FK_Menu

insert into rol(NombreRol) values
 ('ADMINISTRADOR'),
 ('EMPLEADO')

 --PERMISOS PARA ADMINISTRADOR
 -- EL TIPO DE DATO PARA ACTIVO ES BIT POR ESO SE LE ASIGNA EL #1 QUE INDICA QUE ESTA ENCENDIDO
 -- *RECORDEMOS QUE EL ID PARA EL ADMINISTRADOR ES EL #1 POR ELLO EN FK_rol TIENE DICHO NÚMERO

 insert into permiso(activo, FK_rol,FK_submenu) values
	 (1,1,1),
	 (1,1,2),
	 (1,1,3),
	 (1,1,4),
	 (1,1,5),
	 (1,1,6),
	 (1,1,7)

 --PERMISOS DEL EMPLEADO
 -- EL TIPO DE DATO PARA ACTIVO ES BIT POR ESO SE LE ASIGNA EL #0 QUE INDICA QUE ESTA APAGADO
 -- *RECORDEMOS QUE EL ID PARA EL EMPLEADO ES EL #2 POR ELLO EN FK_rol TIENE DICHO NÚMERO

  insert into permiso(activo, FK_rol,FK_submenu) values
	 (0,2,1),
	 (0,2,2),
	 (0,2,3),
	 (1,2,4),
	 (1,2,5),
	 (0,2,6),
	 (0,2,7)

 insert into usuarios(NombreUs, Usuario, Password, FK_rol) values
 ('hola','ADMIN','123',1);
 ('Jesús','EMPLEADO','456',2)



 select * from usuarios

--PROCEDMIENTO PARA OBTENER USUARIO



create procedure LoginUsuario(
	@Usuario varchar(60),
	@Password varchar(60),
	@id_usuario int output)
as
begin
	set @id_usuario = 0
	if exists(
	select * from usuarios 
	where Usuario COLLATE Latin1_General_CS_AS = @Usuario 
	and Password COLLATE Latin1_General_CS_AS = @Password
	)

	set @id_usuario = (
	select id_usuario from usuarios 
	where Usuario COLLATE Latin1_General_CS_AS = @Usuario 
	and Password COLLATE Latin1_General_CS_AS = @Password
	)
end

 --MENUS
 -- La M.* hace referencia a la tabla MENU

 select distinct M.* from permiso P
 join rol R on R.id_rol = P.FK_rol
 join submenu SM on SM.id_sub = P.FK_submenu
 join menu M on M.id_menu = SM.FK_Menu
 join usuarios U on U.FK_rol = P.FK_rol and P.activo = 1
 where U.id_usuario = 2

 
 --SUBMENUS
 select distinct SM.* from permiso P
 join rol R on R.id_rol = P.FK_rol
 join submenu SM on SM.id_sub = P.FK_submenu
 join menu M on M.id_menu = SM.FK_Menu
 join usuarios U on U.FK_rol = P.FK_rol and P.activo = 1
 where U.id_usuario = 2

 -- ESTAS CONSULTAS FUERON CREADAS CON LA FINALIDAD DE CREAR UN XML Y ASÍ PUEDA SER LEÍDO DESDE C#

 --PROCEDMIENTO PARA OBTENER DETALLE USUARIO


create proc ObtenerPermisos(
@id_usuario int
)
as
begin

SELECT
	 
	 (select vistamenu.Nombre, vistamenu.Icono, 
		 
		 (select distinct SM.NombreSub,SM.NomForm from permiso P
		 join rol R on R.id_rol = P.FK_rol
		 join submenu SM on SM.id_sub = P.FK_submenu
		 join menu M on M.id_menu = SM.FK_Menu
		 join usuarios U on U.FK_rol = P.FK_rol and P.activo = 1
		 where U.id_usuario = US.id_usuario and SM.FK_Menu = vistamenu.id_menu
		
		FOR XML PATH('SubMenu'),TYPE) AS 'DetalleSubMenu'

	 from
		(
		 select distinct M.* from permiso P
		 join rol R on R.id_rol = P.FK_rol
		 join submenu SM on SM.id_sub = P.FK_submenu
		 join menu M on M.id_menu = SM.FK_Menu
		 join usuarios U on U.FK_rol = P.FK_rol and P.activo = 1
		 where U.id_usuario = US.id_usuario
	
		)vistamenu
		FOR XML PATH('Menu'),TYPE) AS 'DetalleMenu'

		FROM usuarios US
		WHERE id_usuario = @id_usuario
		FOR XML PATH(''), ROOT('PERMISOS') 
end

exec ObtenerPermisos 2