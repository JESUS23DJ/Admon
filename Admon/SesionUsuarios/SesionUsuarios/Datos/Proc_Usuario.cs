using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;
using SesionUsuarios.Modelo;
using System.Xml;
using System.Xml.Linq;

namespace SesionUsuarios.Datos
{
    public class Proc_Usuario
    {
        public static int Logeo(string usuario, string password)
        {
            int id_usuario = 0;

            using (SqlConnection cn = new SqlConnection(Conexion.cn))
            {

                try
                {
                    SqlCommand cmd = new SqlCommand("LoginUsuario", cn);
                    cmd.Parameters.AddWithValue("Usuario", usuario);
                    cmd.Parameters.AddWithValue("Password", password);
                    cmd.Parameters.Add("id_usuario", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.CommandType = CommandType.StoredProcedure;

                    cn.Open();

                    cmd.ExecuteNonQuery();

                    id_usuario = Convert.ToInt32(cmd.Parameters["id_usuario"].Value);

                }
                catch
                {
                    id_usuario = 0;
                }

            }

            return id_usuario;

        }


        public static List<Menu> ObtenerPermisos(int P_id_usuario)
        {

            List<Menu> Permisos = new List<Menu>();

            using (SqlConnection cn = new SqlConnection(Conexion.cn))
            {

                try
                {
                    SqlCommand cmd = new SqlCommand("ObtenerPermisos", cn);
                    cmd.Parameters.AddWithValue("id_usuario", P_id_usuario);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cn.Open();

                    XmlReader leerXML = cmd.ExecuteXmlReader();

                    while (leerXML.Read())
                    {

                        XDocument doc = XDocument.Load(leerXML);

                        if (doc.Element("PERMISOS") != null)
                        {

                            Permisos = doc.Element("PERMISOS").Element("DetalleMenu") == null ? new List<Menu>() :

                                       (from menu in doc.Element("PERMISOS").Element("DetalleMenu").Elements("Menu")
                                        select new Menu()
                                        {
                                            Nombre = menu.Element("Nombre").Value,
                                            Icono = menu.Element("Icono").Value,
                                            ListaSubMenu = menu.Element("DetalleSubMenu") == null ? new List<SubMenu>() :
                                            (from submenu in menu.Element("DetalleSubMenu").Elements("SubMenu")
                                             
                                             select new SubMenu()
                                             {
                                                 NombreSub = submenu.Element("NombreSub").Value,
                                                 NomForm = submenu.Element("NomForm").Value
                                             }
                                            ).ToList()
                                        }).ToList();

                        }

                    }

                }
                catch
                {
                    Permisos = new List<Menu>();
                }

            }

            return Permisos;
        }

    }
}
